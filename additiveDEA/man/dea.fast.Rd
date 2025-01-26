\name{dea.fast}
\alias{dea.fast}
\title{
Faster Solving of Additive DEA Models with Large Datasets
}
\description{
Reduce calculation time of additive DEA efficiency models when the data comprise of several thousand DMUs
}
\usage{
dea.fast(base, noutput, fixed = NULL, rts = 2, bound = NULL,
  add.model = c("additive", "RAM", "BAM", "MIP", "LovPast", "SBM"),
  blockSize = 200)
}
\arguments{
  \item{base}{
  A data frame with N rows and S+M columns, where N is the number of Decision-Making Units (DMUs), S is the number of
  outputs and M is the number of inputs. 
}
  \item{noutput}{
  The number of outputs produced by the DMUs. All DMUs must produce the same number of outputs.
}
  \item{fixed}{
  A numeric vector containing column indices for fixed (non-controllable) outputs and/or inputs (if any) in the data.
  Defaults to NULL.
}
  \item{rts}{
  Returns to scale specification. 1 for constant returns to scale and 2 (default) for variable returns to scale.
}
  \item{bound}{
  A data frame with N rows and S+M columns containing user-defined bounds on the slacks of each DMU. If bounds are
  supplied by the user in cases where some outputs and/or inputs are fixed, values should be 0 for these fixed
  variables. Same for slacks that do not require bounds. Defaults to NULL.
}
  \item{add.model}{
  Additive model to calculate efficiency. additive: unweighted additive model (Cooper et al., 2007); RAM: Range
  Adjusted Measure (Cooper et al., 1999; 2001); BAM: Bounded Adjusted Measure (Cooper et al., 2011); MIP: Measure
  of Inefficiency Proportions (Cooper et al., 1999); LovPast: the Lovell-Pastor Measure (Lovell and Pastor, 1995); SBM:   Slacks-Based Measure (Tone, 2001).
}
  \item{blockSize}{
  How many DMUs should each sub-problem comprise of? Defaults to 200.
}
}
\details{
\code{\link{dea.fast}} speeds up computation time of functions \code{\link{dea.gem}} and \code{\link{dea.sbm}} when the data comprise of several thousand DMUs. It does so by dividing the data into several blocks consisting of a few hundred DMUs. Then, it finds the efficient DMUs in each block. The next step is to merge the efficient DMUs into one final set and to find the efficient DMUs in this set. Finally, the DMUs in each block are benchmarked against the DMUs that were found to be efficient in the final set of the previous step. See Newsletter 16 in \url{http://www.saitech-inc.com/Products/Prod-DSP.asp}.
If N is not divisible by blockSize, dea.fast will split the data into a number of even blocks plus a final block with the remaining DMUs. For instance, if N=1050 and blockSize=200, there will be five blocks with 200 DMUs and a sixth one with 50 DMUs.
}
\value{
Returns a numeric vector containing the (in)efficiency scores of the DMUs.
}
\note{
The presence of DMUs with solution status other than 0 (see dea.gem and dea.sbm) will result in dea.fast NOT working. Ensure that there is a solution for all DMUs or, when the solution status is 5, that the data are scaled appropriately.

Extreme care is needed when add.model = 'RAM' when ranges are too large relative to the slacks. In such a case, the slack-range ratios can be so small that an inefficient DMU may seem to have near-zero inefficiency (see Cooper et al., 1999). This makes it extremely hard for the algorithm to distinguish between efficient and inefficient DMUs when the former must be separated from the latter within each block (as described earlier). Avoiding using RAM with \code{\link{dea.fast}} for the time being is strongly recommended.
}
\author{
Andreas Diomedes Soteriades, \email{andreassot10@yahoo.com}
}
\references{
Cooper W. W., Park K. S., Pastor J. T. (1999) RAM: a range adjusted measure of inefficiency for use with additive models, and relations to other models and measures in DEA. \emph{Journal of Productivity Analysis}, \bold{11}, 5--42

Cooper W. W., Park K. S., Pastor J. T. (2001) The range adjusted measure (RAM) in DEA: a response to the comment by Steinmann and Zweifel. \emph{Journal of Productivity Analysis}, \bold{15}, 145--152

Cooper W. W., Pastor J. T., Borras F., Aparicio J., Pastor D. (2011) BAM: a bounded adjusted measure of efficiency for use with bounded additive models. \emph{Journal of Productivity Analysis}, \bold{35}, 85--94

Cooper W. W., Seiford L., Tone K. (2007) \emph{Data Envelopment Analysis: a comprehensive text with models, applications, references and DEA-Solver software}. New York: Springer

Lovell, C. A. K., Pastor J. T. (1995) Units invariant and translation invariant DEA models. \emph{Operations Research Letters}, \bold{18}, 147--151

Tone K. (2001) A slacks-based measure of efficiency in data envelopment analysis. \emph{European Journal of Operational Research}, \bold{130}, 498--509
}
\seealso{
  \code{\link{dea.gem}}, \code{\link{dea.sbm}}
}
\examples{
# Get data from package Benchmarking:
library(Benchmarking)
data(pigdata)
base <- pigdata[, 2:9][, c(7,8,1:6)]
# Create trivial but large dataset
base <- rbind(base,base,base,base)
system.time(dea.fast(base, noutput= 2, rts= 2,
  add.model= "LovPast", blockSize = 200))

## The function is currently defined as
function (base, noutput, fixed = NULL, rts = 2, bound = NULL, 
    add.model = c("additive", "RAM", "BAM", "MIP", "LovPast", 
        "SBM"), blockSize = 200) 
{
    baseEfficient <- list()
    n <- nrow(base)
    mod <- (n - (n\%\%blockSize))/blockSize
    blocks <- c(1, 1:mod * blockSize + 1)
    for (i in 1:mod) {
        aux <- blocks[i]:(blocks[i + 1] - 1)
        base1 <- base[aux, ]
        bound1 <- bound[aux, ]
        if (add.model != "SBM") {
            eff <- round(dea.gem(base = base1, noutput, fixed, 
                rts, bound = bound1, add.model)$eff, 7)
            index <- which(is.na(eff))
            if (length(index) > 0) {
                eff[index] <- round(dea.gem(base = base1, noutput, 
                  fixed, rts, bound = bound1, add.model, whichDMUs = index)$eff, 
                  7)
            }
            baseEfficient[[i]] <- base1[which(eff == 0), ]
        }
        else {
            eff <- round(dea.sbm(base = base1, noutput, fixed, 
                rts, bound = bound1)$eff, 7)
            index <- which(is.na(eff))
            if (length(index) > 0) {
                eff[index] <- round(dea.sbm(base = base1, noutput, 
                  fixed, rts, bound = bound1, whichDMUs = index)$eff, 
                  7)
            }
            baseEfficient[[i]] <- base1[which(eff == 1), ]
        }
    }
    if (n\%\%blockSize != 0) {
        aux <- (n - (n\%\%blockSize) + 1):n
        base1 <- base[aux, ]
        bound1 <- bound[aux, ]
        if (add.model != "SBM") {
            eff <- round(dea.gem(base = base1, noutput, fixed, 
                rts, bound = bound1, add.model)$eff, 7)
            index <- which(is.na(eff))
            if (length(index) > 0) {
                eff[index] <- round(dea.gem(base = base1, noutput, 
                  fixed, rts, bound = bound1, add.model, whichDMUs = index)$eff, 
                  7)
            }
            baseEfficient[[i + 1]] <- base1[which(eff == 0), 
                ]
        }
        else {
            eff <- round(dea.sbm(base = base1, noutput, fixed, 
                rts, bound = bound1)$eff, 7)
            index <- which(is.na(eff))
            if (length(index) > 0) {
                eff[index] <- round(dea.sbm(base = base1, noutput, 
                  fixed, rts, bound = bound1, whichDMUs = index)$eff, 
                  7)
            }
            baseEfficient[[i + 1]] <- base1[which(eff == 1), 
                ]
        }
    }
    baseEfficient <- do.call("rbind", baseEfficient)
    if (add.model != "SBM") {
        eff <- round(dea.gem(base = base1, noutput, fixed, rts, 
            bound = bound1, add.model)$eff, 7)
        index <- which(is.na(eff))
        if (length(index) > 0) {
            eff[index] <- round(dea.gem(base = base1, noutput, 
                fixed, rts, bound = bound1, add.model, whichDMUs = index)$eff, 
                7)
        }
        baseEfficient <- base1[which(eff == 0), ]
    }
    else {
        eff <- round(dea.sbm(base = base1, noutput, fixed, rts, 
            bound = bound1)$eff, 7)
        index <- which(is.na(eff))
        if (length(index) > 0) {
            eff[index] <- round(dea.sbm(base = base1, noutput, 
                fixed, rts, bound = bound1, whichDMUs = index)$eff, 
                7)
        }
        baseEfficient <- base1[which(eff == 1), ]
    }
    eff <- list()
    for (i in 1:mod) {
        aux <- blocks[i]:(blocks[i + 1] - 1)
        base1 <- base[aux, ]
        base1 <- rbind(base1, baseEfficient)
        bound1 <- bound[aux, ]
        if (!is.null(bound)) {
            df <- data.frame(matrix(0, nrow = nrow(base1[1:(nrow(base1) - 
                blockSize), ]), ncol = ncol(base1)))
            names(df) <- names(bound1)
            bound1 <- rbind(bound1, df)
        }
        if (add.model != "SBM") {
            eff[[i]] <- dea.gem(base = base1, noutput, fixed, 
                rts, bound = bound1, add.model, whichDMUs = 1:blockSize)$eff
            index <- which(is.na(eff[[i]]))
            if (length(index) > 0) {
                eff[[i]][index] <- dea.gem(base = base1, noutput, 
                  fixed, rts, bound = bound1, add.model, whichDMUs = index)$eff
            }
        }
        else {
            eff[[i]] <- dea.sbm(base = base1, noutput, fixed, 
                rts, bound = bound1, whichDMUs = 1:blockSize)$eff
            index <- which(is.na(eff[[i]]))
            if (length(index) > 0) {
                eff[[i]][index] <- dea.sbm(base = base1, noutput, 
                  fixed, rts, bound = bound1, whichDMUs = index)$eff
            }
        }
    }
    if (n\%\%blockSize != 0) {
        aux <- (n - (n\%\%blockSize) + 1):n
        base1 <- base[aux, ]
        base1 <- rbind(base1, baseEfficient)
        bound1 <- bound[aux, ]
        newBlockSize <- nrow(base) - mod * blockSize
        if (!is.null(bound)) {
            df <- data.frame(matrix(0, nrow = nrow(base1[1:(nrow(base1) - 
                newBlockSize), ]), ncol = ncol(base1)))
            names(df) <- names(bound1)
            bound1 <- rbind(bound1, df)
        }
        if (add.model != "SBM") {
            eff[[i + 1]] <- dea.gem(base = base1, noutput, fixed, 
                rts, bound = bound1, add.model, whichDMUs = 1:newBlockSize)$eff
            index <- which(is.na(eff[[i + 1]]))
            if (length(index) > 0) {
                eff[[i + 1]][index] <- dea.gem(base = base1, 
                  noutput, fixed, rts, bound = bound1, add.model, 
                  whichDMUs = index)$eff
            }
        }
        else {
            eff[[i + 1]] <- dea.sbm(base = base1, noutput, fixed, 
                rts, bound = bound1, whichDMUs = 1:newBlockSize)$eff
            index <- which(is.na(eff[[i + 1]]))
            if (length(index) > 0) {
                eff[[i + 1]][index] <- dea.sbm(base = base1, 
                  noutput, fixed, rts, bound = bound1, whichDMUs = index)$eff
            }
        }
    }
    eff <- unlist(eff)
    return(eff)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
