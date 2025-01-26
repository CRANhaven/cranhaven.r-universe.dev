###### Wqls
# Genotypes: matrix(#Subjects * #Snps). The genotypes are coded as 0, 1, or 2 copies of the minor allele.
# MAF: matrix (#Snps * 2): First column contains Minor Allele Frequency (MAF) in cases; Second column contains MAF in controls
# Pheno: matrix (#subjects * 1): this one-column matrix contains 0's amd 1's: 1 for cases and 0 for controls. No missing values are allowed.
# Kin: The kinship matrix (#subjects * #subjects): the subjects must be ordered as the Pheno variable.
# Correlation: Correlation matrix between SNPs (#Snps * #Snps). The user should calculate this matrix beforehand. Either based on own genotype data (in cases, controls, or both) or based on public databases (e.g., 1000 Genomes Projects, ESP, etc.). NA values are not allowed. They have to be replaced by zeros.
######
Wqls <- function(Genotypes, MAF, Pheno, Kin, Correlation, Weights)
{
  Na     <- length(Pheno[Pheno[,1]==1,])
  Nu     <- length(Pheno[Pheno[,1]==0,])
  N      <- Na + Nu

  # The three following lines: prepare the phenotype variables
  OneN  <- matrix(1, ncol=1, nrow = N)
  Y  <- Pheno
  OneHat <- matrix( Na/N, ncol=1 , nrow=N)
  temp <- Y - OneHat

  # Estimate MAF in all subjects
  P  <- (MAF[,1]*Na + MAF[,2]*Nu)/N
  # Number of Snps
  Nsnps   <- nrow(MAF)
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
  # This value will account for the correlation between Snps.
  cs      <- 2*t(VarSnps) %*% Correlation %*% VarSnps

  if (Nsnps==1)
  {
    S<-Genotypes
  }else
  {
    if (is.null(Weights))
    {
      # Rare variant score: sum of minor alleles accross all Snps.
      S <- apply(Genotypes , 1 , sum)
    }else
    {
      # Rare variant score: sum of minor alleles accross all Snps.
      S <- Genotypes %*% Weights
    }
  }
  S <- matrix(S,ncol=1,nrow=length(S))
  Kin <- 2*Kin
  KinInv <- solve(Kin)
  A <- as.numeric(t(Y) %*% KinInv %*% OneN %*% solve(t(OneN) %*% KinInv %*% OneN))
  V <- KinInv %*% Y - A * KinInv %*% OneN
  if (is.null(Weights))
  {
    num <- (sum((S[Y==1]) * rowSums(KinInv[Y==1,Y==1]))*(1-A) -2*sum(MAF[,2])*(A)*Nu)^2;
  }else
  {
    num <- (sum((S[Y==1]) * rowSums(KinInv[Y==1,Y==1]))*(1-A) -2*sum(Weights*MAF[,2])*(A)*Nu)^2;
  }
  denom <- as.numeric(cs) * (t(V)%*% Kin %*% V) ;
  W <- num/denom ;
  Pvalue <- 1-pchisq(W,1) ;
  out <- t(data.frame(c(sum(MAF[,1]), sum(MAF[,2]), sum(P), num, denom, W, Pvalue)))
  colnames(out) <- c("Sum MAF Cases", "Sum MAF Controls", "Sum MAF All Weighted", "Numerator",
                     "Denominator", "Wqls", "Pvalue")
  rownames(out) <- "Statistics"
  return(out)
}
