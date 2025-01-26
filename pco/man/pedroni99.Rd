\name{pedroni99}
\alias{pedroni99}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
panel cointegration tests - bivatiate case
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
Computation of the Pedroni (1999) panel cointegration test statistics.  
All statistics are asymptotically normal. Reported are their empirical values and their standardized values (as suggested in Pedroni, 1999).  
}
\usage{
pedroni99(Y, X, kk = 0, type.stat = 1, ka = 2)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Y}{
%%     ~~Describe \code{Y} here~~
The 'dependent' variable in the cointegration regression.  Must be a matrix (TxN), 'time' in rows, 'individuals' in columns.  No missing values are allowed.  
}
  \item{X}{
%%     ~~Describe \code{X} here~~
The 'independent' variable in the cointegration regression.  Must be a matrix (TxN), 'time' in rows, 'individuals' in columns.  No missing values are allowed.  
}
  \item{kk}{
%%     ~~Describe \code{kk} here~~
Parameter for the Newey-West (1994) long term variance estimation (number of lags).  Can be a vector, with a different value for each individual series, or a scalar.  By default it is set to 'round(4 * (T/100)^(2/9))'.  
}
  \item{type.stat}{
%%     ~~Describe \code{type.stat} here~~
Type of the main regresion: 1 - 'none', 2 - 'intercept', 3 - 'intercept and time trend'.
}
  \item{ka}{
%%     ~~Describe \code{ka} here~~
Number of lags for the ADF type regression on residuals, for the parametric statistics. 
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
The function closely follows the instructions in Pedroni (1999).  Calculated and reported are the 7 statistics on page 660 in Pedroni (1999) for the bivariate case.  Also reported are their standardized values, as described on page 665 and by use of the adjustment terms in Table 2, page 666, op.cit.  
H0 is 'no cointegration'.  
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
\item{CALL}{The result of 'match.call()'.}
\item{METHOD}{Title of the test.}
\item{STATISTIC}{The 7 test statistics in Pedroni (1999), in two columns - for the empirical and the standardized values.}
}
\references{
%% ~put references to the literature/web site here ~
Newey, Whitney K.; West, Kenneth D. (1994). "Automatic lag selection in covariance matrix estimation". Review of Economic Studies 61 (4): 631-654. 
 
Pedroni, Peter, 1999. "Critical Values for Cointegration Tests in Heterogeneous Panels with Multiple Regressors," Oxford Bulletin of Economics and Statistics, Department of Economics, University of Oxford, vol. 61(0), pages 653-70, Special I. 
}
\author{
%%  ~~who you are~~
Georgi Marinov
}
\note{
%%  ~~further notes~~
Under H0 ('no cointegration') the autoregressive coefficients, gamma_i = 1 for all i, versus H1: gamma_i < 1 for all i.  

The standardized values of the test statistics are asymptotically normal (0,1) under H0.  
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
\code{\link{pedroni99m}}
}
\examples{

data(gdi)
data(gds)
# An illustration for the (non-existent) Feldstein-Horioka paradox.
pedroni99(gdi,gds) 

## The function is currently defined as
function (Y, X, kk = 0, type.stat = 1, ka = 2) 
{
    ff <- function(Y1, X1) {
        NN = ncol(X1)
        sapply(1:NN, function(l) {
            lm(Y1[, l] ~ X1[, l] - 1)$residuals
        })
    }
    ff1 <- function(Y1, X1) {
        NN = ncol(X1)
        sapply(1:NN, function(l) {
            lm(Y1[, l] ~ X1[, l])$residuals
        })
    }
    ff2 <- function(Y1, X1) {
        NN = ncol(X1)
        trend = 1:nrow(X1)
        sapply(1:NN, function(l) {
            lm(Y1[, l] ~ X1[, l] + trend)$residuals
        })
    }
    nw <- function(xx, ki) {
        tt = length(xx)
        (1/tt) * sum(sapply(1:ki, function(s) {
            (1 - s/(ki + 1)) * sum(xx[(s + 1):tt] * xx[1:(tt - 
                s)])
        }))
    }
	adfl<-function (ee, lags) {
		nn<-length(ee)
		z<-ee[(lags+1):nn]
		zl<-ee[lags:(nn-1)]
		zd<-matrix(cbind(rep(z,lags)),ncol=lags)
		ii<-embed(1:nn,lags)
		ii<-ii[-(nrow(ii)),]
		zd<-zd-ee[ii]
		zd<-zd[,-1]
		z<-ee[(lags+1):nn]
		zl<-ee[lags:(nn-1)]
		return(lm(z ~ zl + zd -1)$residuals)
	}
    Y <- as.matrix(Y)
    X <- as.matrix(X)
    if (any((dim(Y) != dim(X)))) {
        stop("Y and X are not compatible.")
    }
    na.fail(Y)
    na.fail(X)
    TD = nrow(X)
    N = ncol(X)
    if (is.vector(kk) && length(kk) == N) {
        k = kk
    }
    else if (kk > 0) {
        k = rep(round(kk), N)
    }
    else {
        i = round(4 * (TD/100)^(2/9))
        k = rep(i, N)
    }
    if (ka < 2) {
        ka = 2
        warning("Parameter 'ka' was changed to 2.")
    }
    ka <- as.vector(ka)
    if (length(ka) != N) {
        ka <- rep(ka[1], N)
    }
    stats <- matrix(nrow = 7, ncol = 2)
    rownames(stats) <- c("nipanel", "rhopanel", "tpanelnonpar", 
        "tpanelpar", "rhogroup", "tgroupnonpar", "tgrouppar")
    colnames(stats) <- c("empirical", "standardized")
    statsm <- cbind(c(6.982, -6.388, -1.662, -1.662, -9.889, 
        -1.992, -1.992), c(11.754, -9.495, -2.177, -2.177, -12.938, 
        -2.453, -2.453), c(21.162, -14.011, -2.648, -2.648, -17.359, 
        -2.872, -2.872))
    rownames(statsm) <- c("nipanel", "rhopanel", "tpanel", "tpanelp", 
        "rhogroup", "tgroup", "tgroupp")
    colnames(statsm) <- c("none", "intercept", "trend")
    statsv <- cbind(c(81.145, 64.288, 1.559, 1.559, 41.943, 0.649, 
        0.649), c(104.546, 57.61, 0.964, 0.964, 51.49, 0.618, 
        0.618), c(160.249, 64.219, 0.69, 0.69, 66.387, 0.555, 
        0.555))
    rownames(statsv) <- c("nipanel", "rhopanel", "tpanel", "tpanelp", 
        "rhogroup", "tgroup", "tgroupp")
    colnames(statsv) <- c("none", "intercept", "trend")
    e <- matrix(ncol = N, nrow = TD)
    if (type.stat == 2) {
        e <- ff1(Y, X)
    }
    else if (type.stat == 3) {
        e <- ff2(Y, X)
    }
    else {
        e <- ff(Y, X)
        type.stat = 1
    }
    De <- diff(e)
    estar <- e
    Destar <- diff(estar)
    DX <- diff(X)
    DY <- diff(Y)
    eta <- matrix(ncol = ncol(DX), nrow = nrow(DX))
    eta <- ff(DY, DX)
    L11hat2 <- sapply(1:N, function(i) {
        (1/nrow(eta)) * sum(eta[, i]^2) + 2 * nw(eta[, i], k[i])
    })
    mu <- matrix(ncol = ncol(DX), nrow = nrow(DX))
    mu <- ff(e[2:TD, ], e[1:(TD - 1), ])
    lambdahat <- sapply(1:N, function(i) {
        nw(mu[, i], k[i])
    })
    mustar <- matrix(ncol = ncol(DX), nrow = nrow(DX))
    mustar <- sapply(1:N, function(i) {
        adfl(e[, i], ka[i])
    })
    shatstar2 <- sapply(1:N, function(i) {
        (1/nrow(mustar)) * sum(mustar[, i]^2)
    })
    stildestar2 <- (1/N) * sum(shatstar2)
    shat2 <- sapply(1:N, function(i) {
        (1/nrow(mu)) * sum(mu[, i]^2)
    })
    sigmahat2 <- shat2 + 2 * lambdahat
    sigmatilde2 <- (1/N) * sum(L11hat2^(-2) * sigmahat2)
    nipa <- sum(sapply(1:N, function(i) {
        sum((L11hat2[i]^(-2)) * (e[1:(TD - 1), i]^2))
    }))
    lel <- sum(sapply(1:N, function(i) {
        (L11hat2[i]^(-2)) * sum(sapply(1:(nrow(De)), function(ttt) {
            (e[(ttt), i] * De[ttt, i] - lambdahat[i])
        }))
    }))
    nipanel <- (TD^2) * (N^(3/2)) * nipa^(-1)
    stats[1, 1] <- nipanel
    rhopanel <- TD * (N^(1/2)) * (nipa^(-1)) * lel
    stats[2, 1] <- rhopanel
    tpanelnonpar <- ((sigmatilde2 * nipa)^(-1/2)) * lel
    stats[3, 1] <- tpanelnonpar
    tpanelpar <- ((stildestar2 * sum(sapply(1:N, function(i) {
        sum((L11hat2[i]^(-2)) * estar[1:(nrow(estar) - 1), i]^2)
    })))^(-1/2)) * sum(sapply(1:N, function(i) {
        sum(sapply(1:(nrow(Destar)), function(ttt) {
            (L11hat2[i]^(-2)) * (estar[ttt, i] * Destar[ttt, 
                i])
        }))
    }))
    stats[4, 1] <- tpanelpar
    rhogroup <- TD * (N^(-1/2)) * sum(sapply(1:N, function(i) {
        ((sum(e[1:(nrow(e) - 1), i]^2))^(-1)) * sum(sapply(1:(nrow(De)), 
            function(ttt) {
                (e[ttt, i] * De[ttt, i] - lambdahat[i])
            }))
    }))
    stats[5, 1] <- rhogroup
    tgroupnonpar <- (N^(-1/2)) * sum(sapply(1:N, function(i) {
        ((sigmahat2[i] * sum(e[1:(nrow(e) - 1), i]^2))^(-1/2)) * 
            sum(sapply(1:(nrow(De)), function(ttt) {
                (e[(ttt), i] * De[ttt, i] - lambdahat[i])
            }))
    }))
    stats[6, 1] <- tgroupnonpar
    tgrouppar <- (N^(-1/2)) * sum(sapply(1:N, function(i) {
        (sum(shat2[i] * estar[1:(nrow(estar) - 1), i]^2))^(-1/2) * 
            sum(estar[1:(nrow(estar) - 1), i] * Destar[1:(nrow(estar) - 
                1), i])
    }))
    stats[7, 1] <- tgrouppar
    stats[, 2] <- sapply(1:7, function(i) {
        (stats[i, 1] - statsm[i, type.stat] * sqrt(N))/sqrt(statsv[i, 
            type.stat])
    })
    list(CALL = match.call(), METHOD = "Pedroni(1999) panel tests for cointegration", 
        STATISTIC = stats)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
