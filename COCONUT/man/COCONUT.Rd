
\name{COCONUT}
\alias{COCONUT}

\title{
 COmbat CO-Normalization Using conTrols: COCONUT
}
\description{
 COCONUT is a modified version of the ComBat empiric Bayes batch correction method (Johnson et al., Biostatistics 2007). It allows for batch correction of microarray datasets using control samples, which allows for diseased samples to be compared in pooled analysis. It makes a strong assumption that all controls come from the same distribution.
}
\usage{
COCONUT(GSEs, control.0.col, disease.col=NULL, byPlatform = FALSE, platformCol,
        par.prior=TRUE, itConv=1e-04, parallel=FALSE, mc.cores=1)
}
\arguments{
  \item{GSEs}{
A list of data objects. See details below.
}
  \item{control.0.col}{
The column name in the $pheno data.frames (in GSEs) that notes which samples are controls. These samples MUST be marked with a 0 (zero).
}
  \item{disease.col}{
Optional; if passed, refers to a column name in the $pheno data.frames (in GSEs) from which disease samples are returned. Only checks to remove missing (NA) samples from disease.col. Useful if there is a class of samples that need to be removed from the analysis (i.e., samples that are not controls but also not the disease of interest). If NOT supplied, COCONUT assumes all non-0 rows in control.0.col are diseased.
}
  \item{byPlatform}{
Natively, byPlatform=F. If T, will group datasets by the batches found in platformCol.
}
  \item{platformCol}{
If byPlatform=T, platformCol is the name of a column in $pheno data.frames (in GSEs) that indicates platform type. For instance, in the data example, each $pheno has a $platform_id which contains that dataset's GPL ID. Note: the microarray ID type supplied should be constant within a column (but of course can vary between datasets).
}
 \item{par.prior}{
Whether to use parametric or non-parametric priors in empiric Bayes updates. Defaults to parametric. Non-parametric can be quite time-consuming.
}
 \item{itConv}{
 Allows user to change threshold for iterative solver. For advanced users only.
}
 \item{parallel}{
 Parallel derivation of priors. Uses parallel:mclapply, and so will not work on Windows machines (sorry).
}
 \item{mc.cores}{
 If parallel=T, mc.cores should be set to the desired number of cores. Defaults to 1, so unless this is changed, functionality will be serial.
}
}
\details{
GSEs:
A list of (named) data objects. Each data object must have two components, $pheno (a data.frame of phenotype information with samples in rows and phenotype variables in columns), and $genes (a matrix of genes in rows and samples in columns). Further, the rownames of $pheno should match the colnames of $genes within each dataset. See the example data object for details.

byPlatform:
Natively, COCONUT will assume each dataset in GSEs is a batch. However, there is enough similarity between microarrays (if the same normalization protocols are used) that each TYPE of microarray can be considered a batch. The advantage to this process is that datasets that share platforms can pool control samples, meaning datasets without controls can be potentially brought into the pool. The drawback is that there is still a substantial batch effect among datasets that used the same microarray type but were processed separately. Quantile normalization is used to overcome this to some degree, but it cannot be fixed altogether.

}
\value{
COCONUT returns a list of lists. In the main list:
\item{COCONUTList}{
COCONUTList is itself a list, with the same names as the datasets in the input objects. Only diseased (or non-control) samples are passed back here (controls are dealt with separately, as below). The post-COCONUT-conormalized values are found in $COCONUTList[GSEname]$genes. See example below for single-line code to collapse these into a single matrix for pooled analysis.
}
\item{rawDiseaseList}{
rawDiseaseList is returned so that the user can make easy comparisons between pre- and post-COCONUT-co-normalized disease data. This contains the same data as the input object, except that all control samples have been removed.
}
\item{controlList}{
controlList returns the ComBat-normalized controls in $GSEs, and the derived empiric Bayes parameters in $bayesParams. It is generally assumed that these will be useful mainly for proving what COCONUT has done, etc., and not for downstream analyses. Note that this does NOT contain the non-co-normalized control data. To compare distributions, for example, you will need the original data object. See example below.
}
}
\references{
Sweeney TE et al., "Robust classification of bacterial and viral infections via integrated host gene expression diagnostics", Science Translational Medicine, 2016
}
\author{
Timothy E Sweeney, MD, PhD (tes17 [at] stanford [dot] edu)
}

\section{Warning }{
COCONUT makes the strong assumption that the control data are from the same distribution. This may not always be an appropriate assumption. Users are advised to think carefully about how to apply COCONUT locally.
}
\seealso{
  \code{\link{COCONUT-package}}
}
\examples{
data(GSEs.test)

## apply COCONUT to a very small test case
## (3 datasets with 10 patients and 2000 genes)
GSEs.COCONUT <- COCONUT(GSEs=GSEs.test,
                        control.0.col="Healthy0.Sepsis1",
                        byPlatform=FALSE)

## make gene matrices
COCONUTgenes <- Reduce(cbind, lapply(GSEs.COCONUT$COCONUTList, function(x) x$genes))
rawgenes <- Reduce(cbind, lapply(GSEs.COCONUT$rawDiseaseList, function(x) x$genes))

### plot not run; (uncomment for plot)
### plot pre- and post-normalized data
# plot(x=1:ncol(COCONUTgenes), y=COCONUTgenes["ATP6V1B1", ], ylim=c(0,6), pch=20, col=1)
# points(x=1:ncol(rawgenes), y=rawgenes["ATP6V1B1", ], ylim=c(0,6), pch=20, col=2)


## compare distributions before and after COCONUT
classvec <- GSEs.test$GSE28750$pheno$Healthy0.Sepsis1
prior <- GSEs.test$GSE28750$genes
post <- cbind(GSEs.COCONUT$controlList$GSEs$GSE28750$genes,
              GSEs.COCONUT$COCONUTList$GSE28750$genes)

prior.t.stats <- apply(prior, 1, function(geneRow){
    geneByClass <- split(geneRow, classvec)
    gene.test <- t.test(geneByClass[[1]], geneByClass[[2]])
    gene.test$statistic
})

post.t.stats <- apply(post, 1, function(geneRow){
    geneByClass <- split(geneRow, classvec)
    gene.test <- t.test(geneByClass[[1]], geneByClass[[2]])
    gene.test$statistic
})

summary(prior.t.stats-post.t.stats)

## thus gene distributions are preserved within datasets, but normalized
## between datasets

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
