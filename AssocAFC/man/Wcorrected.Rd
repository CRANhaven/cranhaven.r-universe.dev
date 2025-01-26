\name{Wcorrected}
\alias{Wcorrected}

\title{
Corrected Chi Squared Test
}
\description{
Corrected Chi Squared Test, Wcorrected(), for multiple rare variant association using the
difference of the sum of minor allele frequencies between cases and controls. This test handles
related individuals, unrelated individuals, or both.  Note: this is referred to as X (Chi) Squared Corrected in the reference rather than W Corrected.
}
\usage{
Wcorrected(MAF, Pheno, Kin, Correlation, Weights)
}

\arguments{
  \item{MAF}{
matrix (#Snps * 2): First column contains Minor Allele Frequency (MAF) in cases; Second column contains MAF in controls.
  }
  \item{Pheno}{
matrix (#subjects * 1): this one-column matrix contains 0's amd 1's: 1 for cases and 0 for controls. No missing values are allowed.
  }
  \item{Kin}{
The kinship matrix (#subjects * #subjects): the subjects must be ordered as the Pheno variable.
  }
  \item{Correlation}{
Correlation matrix between SNPs (#Snps * #Snps). The user should calculate this matrix beforehand. Either based on own genotype data (in cases, controls, or both) or based on public databases (e.g., 1000 Genomes Projects, ESP, etc.). NA values are not allowed. They have to be replaced by zeros.
  }
  \item{Weights}{
The weights values that can be used to up-weight or down-weight SNPs. This size of this
vector is the number of Snps by 1. By default, the weights are 1 for all Snps.
  }
}
\references{
Saad M and Wijsman EM, Association score testing for rare variants and binary traits in family
data with shared controls, Briefings in Bioinformatics, 2017.
Schaid DJ , McDonnell SK , Sinnwell JP , et al.   Multiple genetic variant association testing
by collapsing and kernel methods with pedigree or population structured data.
Genet Epidemiol 2013 ;37 :409 –18.
Choi Y , Wijsman EM , Weir BS.  Case-control association testing in the presence of unknown
relationships. Genet Epidemiol 2009 ;33 :668 –78.
}
\value{
A vector with the following values: the sum of MAF for cases, the sum of MAF for controls, the sum of MAF for all weighted by the phenotype, the numerator of the test, the denominator of the test, the Wcorrected value (the main value calculated by the test), and the P-value.
}

\seealso{
\code{\link{AssocAFC}}
\code{\link{Wqls}}
\code{\link{afcSKAT}}
}
\examples{

P_Wcorrected <- vector("numeric")
#This data corresponds to what is used in the 1st iteration with the raw data
data("maf.afc")
data("phenotype.afc")
data("kin.afc")
data("cor.afc")
data("weights.afc")
CORREC <- Wcorrected(MAF = maf.afc , Pheno = phenotype.afc, Kin = kin.afc , Correlation=cor.afc,
                                                                Weights = weights.afc)
P_Wcorrected <- c(P_Wcorrected, CORREC[7])
print(P_Wcorrected)


\dontrun{
#This example shows processing the raw data and uses kinship2,
#which AFC does not depend on

library(kinship2)
library(CompQuadForm)

P_Wcorrected <- vector("numeric")

for (j in 1:10)
{
  geno.afc <- read.table(system.file("extdata", "Additive_Genotyped_Truncated.txt",
                         package = "AFC"), header = TRUE)
  geno.afc[ , "IID"] <- paste(geno.afc[ , "FID"]  , geno.afc[ , "IID"]  ,sep=".")
  geno.afc[geno.afc[,"FA"]!=0 , "FA"] <- paste(geno.afc[geno.afc[,"FA"]!=0 , "FID"],
                                      geno.afc[geno.afc[,"FA"]!=0 , "FA"]  ,sep=".")
  geno.afc[geno.afc[,"FA"]!=0 , "MO"] <- paste(geno.afc[geno.afc[,"FA"]!=0 , "FID"],
                                      geno.afc[geno.afc[,"FA"]!=0 , "MO"]  ,sep=".")
  Kinship <- makekinship(geno.afc$FID , geno.afc$IID , geno.afc$FA, geno.afc$MO)
  kin.afc <- as.matrix(Kinship)
  pheno.afc <- read.table(system.file("extdata", "Phenotype", package = "AFC"))
  phenotype.afc <- matrix(pheno.afc[,j],nc=1,nr=nrow(pheno.afc))
  geno.afc <- geno.afc[,7:ncol(geno.afc)]
  Na <- nrow(pheno.afc[pheno.afc[,j]==1,])
  Nu <- nrow(pheno.afc[pheno.afc[,j]==0,])
  N <- Nu + Na
  maf.afc <- matrix(NA , nr=ncol(geno.afc) , nc=2)
  maf.afc[,1] <- colMeans(geno.afc[phenotype.afc==1,])/2;
  maf.afc[,2] <- colMeans(geno.afc[phenotype.afc==0,])/2;
  P  <- (maf.afc[,1]*Na + maf.afc[,2]*Nu)/N
  Set <- which(P<0.05)
  maf.afc <- maf.afc[c(Set),]
  cor.afc <- cor(geno.afc[,c(Set)])
  cor.afc[is.na(cor.afc)] <- 0

  weights.afc <- matrix(1/(maf.afc[,2]+1),nc=1,nr=length(Set))
  CORREC <- Wcorrected(MAF = maf.afc , Pheno = phenotype.afc, Kin = kin.afc , Correlation=cor.afc,
                                                                Weights = weights.afc)
  P_Wcorrected <- c(P_Wcorrected, CORREC[7])
}
print(P_Wcorrected)
}

## The function is currently defined as
function(MAF, Pheno, Kin, Correlation, Weights)
{
  Na     <- length(Pheno[Pheno[, 1] == 1,])
  Nu     <- length(Pheno[Pheno[, 1] == 0,])
  N      <- Na + Nu

  # The three following lines: prepare the phenotype variables
  OneN  <- matrix(1, ncol = 1, nrow = N)
  Y  <- Pheno
  OneHat <- matrix(Na / N, ncol = 1 , nrow = N)

  # Estimate MAF in all subjects
  P  <- (MAF[, 1] * Na + MAF[, 2] * Nu) / N
  if (is.null(Weights))
  {
    # Variance of SNPs (2p(1-p))
    VarSnps <- sqrt(P * (1 - P))
  } else
  {
    # Variance of SNPs (2p(1-p)) accounting for the prespecified Snp weights
    VarSnps <- Weights * sqrt(P * (1 - P))
  }
  VarSnps <- matrix(VarSnps, ncol = 1)
  # This value will account for the correlation between Snps.
  cs <- 2 * t(VarSnps) \%*\% Correlation \%*\% VarSnps

  if (is.null(Weights))

  {
    # Numerator of the Xcorrec test statistic
    num <- 4 * (sum (Na * MAF[, 1] - Na * P)) ^ 2
  } else{
    # Numerator of the Xcorrec test statistic
    num <- 4 * (sum (Na * Weights * MAF[, 1] - Na * Weights * P)) ^ 2
  }
  # Denominator of the Xcorrec test statistic
  denom <- 2 * as.numeric(cs) * t(Y - OneHat) \%*\% Kin \%*\% (Y - OneHat)
  # Xcorrec test statistic
  W <- num / denom
  # Pvalue from a chi-square proba distribution
  Pvalue <- 1 - pchisq(W, 1)
  out <- t(data.frame(c(sum(MAF[,1]), sum(MAF[,2]), sum(P), num, denom, W, Pvalue)))
  colnames(out) <- c("Sum MAF Cases", "Sum MAF Controls", "Sum MAF All Weighted", "Numerator",
                     "Denominator", "Wcorrected", "Pvalue")
  rownames(out) <- "Statistics"
  return(out)
}

}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }
