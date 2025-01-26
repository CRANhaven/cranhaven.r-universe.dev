###### afcSKAT
# MAF: matrix (#Snps * 2): First column contains Minor Allele Frequency (MAF) in cases; Second column contains MAF in controls
# Pheno: matrix (#subjects * 1): this one-column matrix contains 0's amd 1's: 1 for cases and 0 for controls. No missing values are allowed.
# Kin: The kinship matrix (#subjects * #subjects): the subjects must be ordered as the Pheno variable.
# Correlation: Correlation matrix between SNPs (#Snps * #Snps). The user should calculate this matrix beforehand. Either based on own genotype data (in cases, controls, or both) or based on public databases (e.g., 1000 Genomes Projects, ESP, etc.). NA values are not allowed. They have to be replaced by zeros.
######
afcSKAT <- function(MAF, Pheno, Kin, Correlation, Weights)
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
  cz <- 2* sum((Y - OneHat) %*% t(Y - OneHat) * Kin )
  Vz <- cz * VarSnps %*% t(VarSnps)*Correlation
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
  V_Q <- 2* sum( diag (Vz %*% Vz))
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

