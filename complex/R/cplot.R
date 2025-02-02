#' Scatterplots for complex variables
#'
#' Function produces six scatterplots to show relations between the two complex variables x and y.
#'
#' The plots are positioned to satisfy two rules:
#' 1. When a scatterplot for a c.r.v. is produced, the real part should be in x-axis,
#' while the imaginary should be in the y-axis.
#' 2. When parts of variables x and y are compared, the part for $x$ should be in x-axis,
#' while the part for y should be in y-axis, which should the reflect the idea that x could
#'  be an explanatory variable for y.
#'
#' @template references
#' @template author
#'
#' @keywords univar
#'
#' @param x vector of a complex variable.
#' @param y second vector of a complex variable.
#' @param which defines, what type of plot to produce. \code{which=1} will produce
#' six scatterplots, while \code{which=2} will produce a scatterplot of data after
#' multidimensional scaling (creating projections of complex variables to x and y axes).
#' @param ... otehr parameters passed to plot method. Works only for \code{which=2}.
#'
#' @return The function produces a plot and does not return any value
#'
#' @seealso \code{\link[complex]{ccor}}
#'
#' @examples
#'
#' # Generate random complex variables
#' x <- complex(real=rnorm(100,10,10), imaginary=rnorm(100,10,10))
#' y <- complex(real=rnorm(100,10,10), imaginary=rnorm(100,10,10))
#'
#' cplot(x, y)
#'
#' @importFrom graphics axis box mtext
#' @importFrom grDevices grey palette
#' @importFrom stats dist cmdscale
#' @export
cplot <- function(x, y, which=1, ...){
    # The function creates scatterplots for two complex variables, x and y

    xName <- substitute(x);
    yName <- substitute(y);
    ellipsis <- list(...);

    which <- which[1];

    if(which==1){
        obs <- length(x)
        if(length(y)!=obs){
            stop("The length of x and y differs, cannot proceed", call.=FALSE);
        }

        ourData <- data.frame(x=x, y=y);
        ourData <- ourData[order(abs(ourData$x-complex(real=min(Re(ourData$x)), imaginary=min(Im(ourData$x))))),];

        parDefault <- par(no.readonly=TRUE);
        on.exit(par(parDefault));

        nColours <- min(1000,obs);
        nColoursTimes <- floor(obs/nColours);
        colours <- rep(grey(seq(0.9, 0.1, len=nColours)), each=nColoursTimes);
        omaValues <- c(5,5,2,2);

        par(mfcol=c(3,3), mar=rep(0.1,4), oma=omaValues, xaxt="s",yaxt="s",cex.main=1.5);

        plot(Re(ourData$x),Im(ourData$x), col=colours, xlab=Re(x), ylab="Im(x)", axes=F);
        axis(side=2);
        box(col="darkred", lwd=3);
        mtext(paste0("Im(",xName,")"), side=2, line=3, at=2.5/3, outer=TRUE);
        plot(Re(ourData$x),Re(ourData$y), col=colours, xlab="Re(x)", ylab="Re(y)", axes=F);
        axis(side=2);
        box(col="darkblue", lwd=3);
        mtext(paste0("Re(",yName,")"), side=2, line=3, outer=TRUE);
        plot(Re(ourData$x),Im(ourData$y), col=colours, xlab="Re(x)", ylab="Im(y)", axes=F);
        axis(side=2);
        axis(side=1);
        box(col="darkgreen", lwd=3);
        mtext(paste0("Im(",yName,")"), side=2, line=3, at=0.5/3, outer=TRUE);
        mtext(paste0("Re(",xName,")"), side=1, line=3, at=0.5/3, outer=TRUE);

        plot(0,0, col="white", xlab="", ylab="", axes=F);
        plot(Im(ourData$x),Re(ourData$y), col=colours, ylab="Re(y)", xlab="Im(x)", axes=F);
        box(col="darkgreen", lwd=3);
        plot(Im(ourData$x),Im(ourData$y), col=colours, xlab="Im(x)", ylab="Im(y)", axes=F);
        axis(side=1);
        box(col="darkblue", lwd=3);
        mtext(paste0("Im(",xName,")"), side=1, line=3, outer=TRUE);

        plot(0,0, col="white", xlab="", ylab="", axes=F);
        plot(0,0, col="white", xlab="", ylab="", axes=F);
        plot(Re(ourData$y),Im(ourData$y), col=colours, xlab="Re(y)", ylab="Im(y)", axes=F);
        axis(side=1);
        box(col="darkred", lwd=3);
        mtext(paste0("Re(",yName,")"), side=1, line=3, at=2.5/3, outer=TRUE);
    }
    else{
        # MDS plot
        if(is.null(ellipsis$xlab)){
            ellipsis$xlab <- as.character(xName);
        }
        if(is.null(ellipsis$ylab)){
            ellipsis$ylab <- as.character(yName);
        }
        if(is.null(ellipsis$main)){
            ellipsis$main <- "MDS representation of relation between complex variables";
        }
        xScaled <- cmdscale(dist(complex2vec(x)), k=1);
        yScaled <- cmdscale(dist(complex2vec(y)), k=1);

        ellipsis$x <- xScaled;
        ellipsis$y <- yScaled;

        do.call("plot",ellipsis);
    }
}
