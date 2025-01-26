\name{afcSKAT}
\alias{afcSKAT}

\title{
Allele Frequency Comparison Sequence Kernel Association Test
}
\description{
Sequence Kernel Association Test, afcSKAT(), for multiple rare variant association
test using the difference of sum of minor allele frequencies between cases and controls.
This test handles related individuals, unrelated individuals, or both. Plus, it is
robust againt the inclusion of both protective and risk variants in the same model.
}
\usage{
afcSKAT(MAF, Pheno, Kin, Correlation, Weights)
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
\value{
A vector with two values is returned, the 1st is the p-value calculated by the Satterwaite method
and the second is calculated via Davies.
}

\references{
Saad M and Wijsman EM, Association score testing for rare variants and binary traits in family
data with shared controls, Briefings in Bioinformatics, 2017.
Schaid DJ , McDonnell SK , Sinnwell JP , et al.   Multiple genetic variant association testing
by collapsing and kernel methods with pedigree or population structured data.
Genet Epidemiol 2013 ;37 :409 –18.
}

\seealso{
\code{\link{AssocAFC}}
\code{\link{Wqls}}
\code{\link{Wcorrected}}
}
\examples{

P_afcSKAT_Satterwaite <- vector("numeric")
P_afcSKAT_Davies <- vector("numeric")
#This data corresponds to what is used in the 1st iteration with the raw data
data("maf.afc")
data("phenotype.afc")
data("kin.afc")
data("cor.afc")
data("weights.afc")
SKAT <- afcSKAT(MAF = maf.afc , Pheno = phenotype.afc, Kin = kin.afc , Correlation=cor.afc,
                Weights = weights.afc)
P_afcSKAT_Satterwaite <- c(P_afcSKAT_Satterwaite, SKAT[1])
P_afcSKAT_Davies <- c(P_afcSKAT_Davies, SKAT[2])
print(P_afcSKAT_Satterwaite)
print(P_afcSKAT_Davies)

\dontrun{
#This example shows processing the raw data and uses kinship2,
#which AFC does not depend on

library(kinship2)
library(CompQuadForm)

P_afcSKAT_Satterwaite <- vector("numeric")
P_afcSKAT_Davies <- vector("numeric")

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
  geno.afc <- as.matrix(geno.afc[,Set])

  weights.afc <- matrix(1/(maf.afc[,2]+1),nc=1,nr=length(Set))
  SKAT <- afcSKAT(MAF = maf.afc , Pheno = phenotype.afc, Kin = kin.afc , Correlation=cor.afc,
                  Weights = weights.afc)
  P_afcSKAT_Satterwaite <- c(P_afcSKAT_Satterwaite, SKAT[1])
  P_afcSKAT_Davies <- c(P_afcSKAT_Davies, SKAT[2])
}
print(P_afcSKAT_Satterwaite)
print(P_afcSKAT_Davies)
}

## The function is currently defined as
function(MAF, Pheno, Kin, Correlation, Weights)
{
  Na     <- length(Pheno[Pheno[,1]==1,])
  Nu     <- length(Pheno[Pheno[,1]==0,])
  N      <- Na + Nu

  # The three following lines: prepare the phenotype variables
  OneN  <- matrix(1, ncol=1, nrow = N)
  Y  <- Pheno
  OneHat <- matrix( Na/N, ncol=1 , nrow=N)

  # Estimate MAF in all subjects
  P  <- (MAF[,1]*Na + MAF[,2]*Nu)/N
  if (is.null(Weights))
  {
    # Variance of SNPs (2p(1-p))
    VarSnps <- sqrt(P*(1-P))
  } else
  {
    # Variance of SNPs (2p(1-p)) accounting for the prespecified Snp weights
    VarSnps <- Weights*sqrt(P*(1-P))
  }
  VarSnps <- matrix(VarSnps,ncol=1)
  cz <- 2* sum((Y - OneHat) \%*\% t(Y - OneHat) * Kin )
  Vz <- cz * VarSnps \%*\% t(VarSnps)*Correlation
  if (is.null(Weights))
  {
  	# Quadratic form without Weights
    Q <-  4*Na^2*(sum ( (MAF[,1] - P)^2 ))
  } else
  {
  	# Quadratic form with Weights
    Q <-  4*Na^2*(sum ( Weights*(MAF[,1] - P)^2 ))
  }
  # Satterwaite approximation (1)
  E_Q <- sum(diag(Vz))
  # Satterwaite approximation (2)
  V_Q <- 2* sum( diag (Vz \%*\% Vz))
  # Satterwaite approximation (3)
  Delta <- V_Q/(2*E_Q)
  # Satterwaite approximation (4)
  df<- 2*E_Q^2/V_Q
  # Satterwaite approximation (5)
  Qscaled <- Q / Delta
  # Satterwaite approximation (6)
  Pvalue_Sat <- 1-pchisq(Qscaled, df)

	# Davies approximation (1)
  eig <- eigen(Vz, symmetric = T, only.values = T)
  # Davies approximation (2)
  evals <- eig$values[eig$values > 1e-06 * eig$values[1]]
  # Davies approximation (3)
  Pvalue_Dav <-davies(Q, evals, acc = 1e-5)$Qq
  out <- t(data.frame(c(Pvalue_Sat,Pvalue_Dav)))
  colnames(out)<- c("Satterwaite","Davies")
  rownames(out) <- "Pvalue"
  return(out)
}
}

\keyword{ ~methods }
\keyword{ ~htest }
