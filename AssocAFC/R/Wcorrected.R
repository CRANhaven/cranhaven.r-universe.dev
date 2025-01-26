###### Wcorrected
# X being Chi
# MAF: matrix (#Snps * 2): First column contains Minor Allele Frequency (MAF) in cases; Second column contains MAF in controls
# Pheno: matrix (#subjects * 1): this one-column matrix contains 0's amd 1's: 1 for cases and 0 for controls. No missing values are allowed.
# Kin: The kinship matrix (#subjects * #subjects): the subjects must be ordered as the Pheno variable.
# Correlation: Correlation matrix between SNPs (#Snps * #Snps). The user should calculate this matrix beforehand. Either based on own genotype data (in cases, controls, or both) or based on public databases (e.g., 1000 Genomes Projects, ESP, etc.). NA values are not allowed. They have to be replaced by zeros.
######

#Correlation <- cor(IND[pheno>=0,7:ncol(IND)])
#Correlation[is.na(Correlation)] <- 0

Wcorrected <- function(MAF, Pheno, Kin, Correlation, Weights)
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
  cs <- 2 * t(VarSnps) %*% Correlation %*% VarSnps

  if (is.null(Weights))

  {
    # Numerator of the Xcorrec test statistic
    num <- 4 * (sum (Na * MAF[, 1] - Na * P)) ^ 2
  } else{
    # Numerator of the Xcorrec test statistic
    num <- 4 * (sum (Na * Weights * MAF[, 1] - Na * Weights * P)) ^ 2
  }
  # Denominator of the Xcorrec test statistic
  denom <- 2 * as.numeric(cs) * t(Y - OneHat) %*% Kin %*% (Y - OneHat)
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
