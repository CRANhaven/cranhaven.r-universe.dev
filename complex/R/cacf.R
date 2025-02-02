#' Complex Correlation Function Estimation
#'
#' The functions compute (and by default plot) estimates of the Complex Autocovariance,
#' or Complex Autocorrelation, or Partial Complex Autocorrelation functions.
#'
#' For \code{type="correlation"} and \code{"covariance"}, the estimates are based
#' on the sample pseudo covariance and use pseudo correlation \link[complex]{ccor} and complex
#' covariance \link[complex]{ccov} respectively. Note that the function does not calculate values for
#' lag 0. Also, the function will automatically remove NAs. Finally, function does not have
#' \code{demean} parameter (as, for example, is done in \link[stats]{acf}), because \code{ccov()}
#' and \code{ccor()} do that automatically.
#'
#' \code{cpacf()} produces the partial complex ACF based on complex regression model of variable
#' on its lags.
#'
#' The generic function plot has a method for objects of class "cacf".
#'
#' The lag is returned and plotted in units of time, and not numbers of observations.
#'
#' There is a print and plot methods for objects of class "cacf".
#'
#' @template author
#' @template references
#'
#' @keywords univar
#'
#' @param x vector of complex variables.
#' @param lag.max maximum number of lags. See \link[stats]{acf} for more details.
#' @param method method to use in the calculation of the measure. \code{"conjugate"} means that it is based
#' on the multiplication by conjugate number. \code{"direct"} means the calculation
#' without the conjugate (i.e. "pseudo" moment). \code{method}
#' can also be "pearson", "kendall", or "spearman", defining what correlation coefficient
#' to use after the MDS transformation of complex variables \code{x} and \code{y}.
#' @param type character string giving the type of cACF to be computed. Allowed values
#' are "correlation" (the default) and "covariance". Will be partially matched.
#' @param plot logical. If \code{TRUE} (the default) the cACF is plotted on complex plane
#' and as two linear graphs for real and imaginary parts.
#'
#' @return An object of class "cacf", which is a list with the following elements:
#' \itemize{
#' \item \code{lag} A three dimensional array containing the lags at which the cACF is estimated.
#' \item \code{acf} An array with the same dimensions as lag containing the estimated cACF.
#' \item \code{method} The method used in calculation (same as the method argument).
#' \item \code{type} The type of correlation (same as the type argument).
#' \item \code{n.used} The number of observations in the time series.
#' \item \code{series} The name of the series x.
#' }
#'
#' @seealso \link[stats]{acf}, \link[complex]{ccor}
#'
#' @examples
#'
#' # Generate random complex variables
#' x <- complex(real=rnorm(100,10,10), imaginary=rnorm(100,10,10))
#'
#' # Calculate cACF
#' cacf(x)
#'
#' @rdname cACF
#' @importFrom stats cov
#' @importFrom greybox xregExpander
#' @export
cacf <- function(x, lag.max=NULL, method=c("direct","conjugate","pearson","kendall", "spearman"),
                 type=c("correlation","covariance","partial"),
                 plot=TRUE, ...){
    # Function is based on acf() from stats
    # Remove names of observations - they cause issues with xregExpander().
    names(x) <- NULL;

    method <- match.arg(method);
    type <- match.arg(type);

    if(type=="partial"){
        return(cpacf(x=x, lag.max=lag.max, plot=plot, method=method));
    }

    series <- deparse1(substitute(x))

    obs <- length(x);

    if(is.null(lag.max)){
        lag.max <- floor(10*log10(obs));
    }
    lag.max <- as.integer(min(lag.max, obs - 1));
    if(is.na(lag.max) || lag.max < 1){
        stop("'lag.max' must be at least 1");
    }

    if(any(method==c("direct","conjugate"))){
        xACF <- vector("complex", lag.max);
        xLagged <- xregExpander(x, lags=-c(1:lag.max), gaps="NAs");
        for(i in 1:lag.max){
            xACF[i] <- switch(type,
                              "covariance"=ccov(xLagged[,1], xLagged[,i+1], method=method, na.rm=TRUE),
                              "correlation"=ccor(xLagged[,1], xLagged[,i+1], method=method, na.rm=TRUE));
        }
        # Conjugate correlation does not have imaginary part. Drop it
        if(method=="conjugate" && type=="correlation"){
            xACF <- Re(xACF);
        }
    }
    else{
        xACF <- vector("numeric", lag.max);
        xScaled <- cmdscale(dist(complex2vec(x)), k=1)
        xLagged <- xregExpander(xScaled, lags=-c(1:lag.max), gaps="NAs");
        for(i in 1:lag.max){
            xACF[i] <- switch(type,
                              "covariance"=cov(xLagged[,1], xLagged[,i+1], method=method, use="complete.obs"),
                              "correlation"=cor(xLagged[,1], xLagged[,i+1], method=method, use="complete.obs"));
        }
    }

    acf.out <- structure(list(acf=xACF, method=method, type=type, n.used=obs,
                              lag=c(1:lag.max), series=series), class="cacf");

    if(plot){
        plot(acf.out, 1, ...);
        invisible(acf.out);
    }
    else{
        return(acf.out);
    }
}

#' @rdname cACF
#' @importFrom stats pacf
#' @export
cpacf <- function(x, lag.max=NULL, method=c("direct","conjugate","pearson","kendall", "spearman"),
                  plot=TRUE, ...){
    # Function is based on acf() from stats
    # Remove names of observations - they cause issues with xregExpander().
    names(x) <- NULL;

    method <- match.arg(method);
    series <- deparse1(substitute(x))

    obs <- length(x);

    if(is.null(lag.max)){
        lag.max <- floor(10*log10(obs));
    }
    lag.max <- as.integer(min(lag.max, obs - 1));
    if(is.na(lag.max) || lag.max < 1){
        stop("'lag.max' must be at least 1");
    }

    xLagged <- xregExpander(x, lags=-c(1:lag.max), gaps="NAs");
    # Set the first column for the intercept
    xLagged[,1] <- 1;
    xPACF <- vector("complex", lag.max);

    i <- 1

    # Extract estimated parameters of the complex regression
    if(method=="direct"){
        for(i in 1:lag.max){
            xPACF[i] <- (invert(t(xLagged[-c(1:i),1:(i+1),drop=FALSE]) %*% xLagged[-c(1:i),1:(i+1),drop=FALSE]) %*%
                             t(xLagged[-c(1:i),1:(i+1),drop=FALSE]) %*%
                             x[-c(1:i)])[i+1,];
        }
    }
    else if(method=="conjugate"){
        for(i in 1:lag.max){
            xPACF[i] <- (invert(t(Conj(xLagged[-c(1:i),1:(i+1),drop=FALSE])) %*% xLagged[-c(1:i),1:(i+1),drop=FALSE]) %*%
                             t(Conj(xLagged[-c(1:i),1:(i+1),drop=FALSE])) %*%
                             x[-c(1:i)])[i+1,];
        }
    }
    else{
        xPACF <- pacf(cmdscale(dist(complex2vec(x)), k=1), lag.max=lag.max, plot=FALSE)$acf;
    }

    acf.out <- structure(list(acf=xPACF, method=method, type="partial", n.used=obs,
                              lag=c(1:lag.max), series=series), class="cacf");

    if(plot){
        plot(acf.out, 1, ...);
        invisible(acf.out);
    }
    else{
        return(acf.out);
    }
}

#' @importFrom stats setNames
#' @rdname cACF
#' @export
print.cacf <- function(x, ...){
    cat("Complex Autocorrelations of series", x$series, "by lag\n\n");
    x$acf |> setNames(x$lag) |> print();
}

#' @param which Determines, which of the plots to produce. 1 is the plot of real
#' and imaginary parts. 2 is the plot of absolute value and the argument.
#' @param ask Determines, whether to ask before producing a new plot or not.
#' @param level Confidence level for the non-rejection region of the correlation
#' coefficient.
#' @param ... Parameter for the plot() function.
#'
#' @importFrom graphics layout text
#' @importFrom grDevices devAskNewPage
#' @rdname cACF
#' @export
plot.cacf <- function(x, which=c(1,2), ask=length(which)>1, level=0.95, ...){
    ellipsis <- list(...);

    # Number of degrees of freedom: n-tau-1, where n-tau is the sample size
    df <- (x$n.used - c(1:length(x$acf)) - 1);
    tValues <- qt((1+level)/2,df=df);
    rCritical <- tValues/sqrt(x$n.used-2+tValues^2);
    xMethod <- paste(toupper(substr(x$method, 1, 1)), substr(x$method, 2, nchar(x$method)), sep="")

    if(x$method=="direct" || (x$method=="conjugate" && any(x$type==c("covariance","partial")))){
        if(is.null(ellipsis$main)){
            ellipsis$main <- switch(x$type,
                                    "covariance"=paste0(xMethod," complex autocovariance function"),
                                    "correlation"=paste0(xMethod," complex autocorrelation function"),
                                    "partial"=paste0(xMethod," complex partial autocorrelation function"));
        }
        mainLabel <- ellipsis$main;
        # Define, whether to wait for the hit of "Enter"
        if(ask){
            devAskNewPage(TRUE);
            on.exit(devAskNewPage(FALSE));
        }
        xReLab <- switch(x$type,
                         "covariance"="Real cACF",
                         "correlation"="Real cACF",
                         "partial"="Real cPACF");
        xImLab <- switch(x$type,
                         "covariance"="Imaginary cACF",
                         "correlation"="Imaginary cACF",
                         "partial"="Imaginary cPACF");
        for(i in which){
            if(i==1){
                parDefault <- par(no.readonly=TRUE);
                on.exit(par(parDefault),add=TRUE);

                xRange <- c(min(Re(x$acf),-1),max(Re(x$acf),1))
                yRange <- c(min(Im(x$acf),-1),max(Im(x$acf),1))
                layout(matrix(c(1,2,1,3),2,2));
                par(mar=c(4,4,4,2));
                plot(x$acf, type="b",
                     xlab=xReLab, ylab=xImLab, main=mainLabel,
                     xlim=xRange, ylim=yRange);
                abline(h=0, col="grey", lty=2);
                abline(v=0, col="grey", lty=2);
                abline(h=c(-1,1)*rCritical, col="red", lty=2);
                abline(v=c(-1,1)*rCritical, col="red", lty=2);
                text(Re(x$acf), Im(x$acf), c(1:length(x$acf)), pos=3);

                par(mar=c(4,4,1,2))
                plot(Re(x$acf), type="h", xlab="Lag", ylab=xReLab,
                     ylim=xRange);
                abline(h=0);
                lines(rCritical, col="red", lty=2);
                lines(-rCritical, col="red", lty=2);
                # Add text for the significant ones
                signigicantOnes <- which(abs(Re(x$acf))>rCritical);
                if(length(signigicantOnes)>0){
                    acfSignificant <- Re(x$acf)[signigicantOnes];
                    points(signigicantOnes, acfSignificant, pch=16);
                    text(signigicantOnes, acfSignificant, signigicantOnes, pos=c(1,3)[(acfSignificant>0)*1+1]);
                }

                plot(Im(x$acf), type="h", xlab="Lag", ylab=xImLab,
                     ylim=yRange);
                abline(h=0);
                lines(rCritical, col="red", lty=2);
                lines(-rCritical, col="red", lty=2);
                # Add text for the significant ones
                signigicantOnes <- which(abs(Im(x$acf))>rCritical);
                if(length(signigicantOnes)>0){
                    acfSignificant <- Im(x$acf)[signigicantOnes];
                    points(signigicantOnes, acfSignificant, pch=16);
                    text(signigicantOnes, acfSignificant, signigicantOnes, pos=c(1,3)[(acfSignificant>0)*1+1]);
                }
            }
            if(i==2){
                parDefault <- par(no.readonly=TRUE);
                on.exit(par(parDefault),add=TRUE);

                layout(matrix(c(1,2,1,3),2,2))
                par(mar=c(4,4,4,2))
                plot(abs(x$acf), Arg(x$acf), type="b",
                     xlab="Absolute of cACF", ylab="Argument of cACF", main=mainLabel);
                # points(abs(x$acf), Arg(x$acf));
                text(abs(x$acf), Arg(x$acf), c(1:length(x$acf)), pos=3);

                par(mar=c(4,4,1,2))
                plot(abs(x$acf), type="h", xlab="Lag", ylab="Absolute of cACF");
                abline(h=0);

                plot(Arg(x$acf), type="h", xlab="Lag", ylab="Argument of cACF");
                abline(h=0);
            }
        }
    }
    else{
        if(is.null(ellipsis$main)){
            if(x$method!="conjugate"){
                ellipsis$main <- switch(x$type,
                                        "covariance"="Autocovariance function of MDS of a complex variable",
                                        "correlation"=paste0(xMethod, " autocorrelation function of MDS of a complex variable"),
                                        "partial"="Partial autocorrelation function of MDS of a complex variable");
            }
            else{
                ellipsis$main <-  "Conjugate complex autocorrelation function";
            }
        }
        if(is.null(ellipsis$ylab)){
            ellipsis$ylab <- switch(x$type,
                                    "covariance"="Autocovariance",
                                    "correlation"="ACF",
                                    "partial"="PACF");
        }
        if(is.null(ellipsis$xlab)){
            ellipsis$xlab <- "Lag";
        }
        if(is.null(ellipsis$type)){
            ellipsis$type <- "h";
        }
        if(is.null(ellipsis$ylim)){
            ellipsis$ylim <- c(min(x$acf,-1),max(x$acf,1));
        }
        ellipsis$x <- x$acf;

        do.call("plot", ellipsis);
        abline(h=0);
        lines(rCritical, col="red", lty=2);
        if(x$method=="pearson"){
            lines(-rCritical, col="red", lty=2);
        }

        # Add text for the significant ones
        signigicantOnes <- which(abs(x$acf)>rCritical);
        if(length(signigicantOnes)>0){
            acfSignificant <- x$acf[signigicantOnes];
            points(signigicantOnes, acfSignificant, pch=16);
            text(signigicantOnes, acfSignificant, signigicantOnes, pos=c(1,3)[(acfSignificant>0)*1+1]);
        }
    }
}
