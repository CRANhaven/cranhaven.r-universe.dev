#' Correlation, Variance and Covariance (Matrices) for complex variables
#'
#' Functions \code{cvar()}, \code{ccov()} and \code{ccor()} return respectively
#' complex variance, covariance and correlation based on the
#' provided complex vector/matrix \code{x}. Function \code{covar()} returns the covariance
#' matrix based on a complex vector/matrix.
#'
#' Only the parametric correlation is supported by the function. If \code{x}
#' is matrix, then \code{y} is ignored.
#'
#' \code{covar()} function returns a covariance matrix calculated for the provided complex
#' vector or matrix \code{x}.
#'
#' @template references
#' @template author
#'
#' @keywords univar
#'
#' @param x vector or matrix of complex variables. If it is matrix then the
#' variable \code{y} is ignored.
#' @param y second vector to calculate covariance or correlations with.
#' @param method method to use in the calculation of the measure. \code{"conjugate"} means that it is based
#' on the multiplication by conjugate number. \code{"direct"} means the calculation
#' without the conjugate (i.e. "pseudo" moment). For \code{ccor} the variable \code{method}
#' can also be "pearson", "kendall", or "spearman", defining what correlation coefficient
#' to use after the MDS transformation of complex variables \code{x} and \code{y}.
#' @param ... parameters passed to \code{mean()} functions. For example, this can be
#' \code{na.rm=TRUE} to remove missing values or \code{trim} to define the trimming
#' in the mean (see \link[base]{mean}).
#'
#' @return A scalar or a matrix with resulting complex variables.
#'
#' @seealso \code{\link[stats]{cor}}
#'
#' @examples
#'
#' # Generate random complex variables
#' x <- complex(real=rnorm(100,10,10), imaginary=rnorm(100,10,10))
#' y <- complex(real=rnorm(100,10,10), imaginary=rnorm(100,10,10))
#'
#' # Create a matrix of complex variables
#' z <- cbind(x,y)
#'
#' # Calculate measures
#' cvar(x)
#' cvar(z)
#' ccor(x,y)
#' ccor(z)
#'
#' @rdname ccor
#' @export
cvar <- function(x, method=c("direct","conjugate"),
                 df=NULL, ...){
    method <- match.arg(method);
    # Remove data frame. We don't care about the categorical variables...
    if(is.data.frame(x)){
        x <- as.matrix(x);
    }
    if(method=="direct"){
        if(is.matrix(x)){
            if(is.null(df)){
                df <- nrow(x)-1;
            }
            xMeans <- matrix(colMeans(x, ...),nrow(x),ncol(x),byrow=TRUE);
            return(t(x-xMeans) %*% (x-xMeans) / df);
        }
        else{
            if(is.null(df)){
                df <- length(x)-1;
            }
            return(sum((x-mean(x, ...))^2, ...) / df);
        }
    }
    else{
        if(is.matrix(x)){
            if(is.null(df)){
                df <- nrow(x)-1;
            }
            xMeans <- matrix(colMeans(x, ...),nrow(x),ncol(x),byrow=TRUE);
            return(Conj(t(x-xMeans)) %*% (x-xMeans) / df);
        }
        else{
            if(is.null(df)){
                df <- length(x)-1;
            }
            return(sum(Conj(x-mean(x, ...)) * (x-mean(x, ...)), ...) / df);
        }
    }
}

#' @rdname ccor
#' @export
ccov <- function(x, y, method=c("direct","conjugate"),
                 df=NULL, ...){
    method <- match.arg(method);
    # Remove data frame. We don't care about the categorical variables...
    if(is.data.frame(x)){
        x <- as.matrix(x);
    }
    if(method=="direct"){
        if(is.matrix(x)){
            return(cvar(x, method=method, ...));
        }
        else{
            if(is.null(df)){
                df <- length(x)-1;
            }
            return(sum((x-mean(x, ...))*(y-mean(y, ...)), ...) / df);
        }
    }
    else{
        if(is.matrix(x)){
            return(cvar(x, method=method, ...));
        }
        else{
            if(is.null(df)){
                df <- length(x)-1;
            }
            return(sum(Conj(x-mean(x, ...))*(y-mean(y, ...)), ...) / df);
        }
    }
}

#' @rdname ccor
#' @importFrom stats cor
#' @export
ccor <- function(x, y, method=c("direct","conjugate","pearson","kendall", "spearman"),
                 ...){
    method <- match.arg(method);
    # Remove data frame. We don't care about the categorical variables...
    if(is.data.frame(x)){
        x <- as.matrix(x);
    }
    if(any(method==c("direct","conjugate"))){
        if(is.matrix(x)){
            if(method=="direct"){
                ccor <- ccov2cor(cvar(x, method=method, ...));
            }
            else if(method=="conjugate"){
                # Take geometric mean of the two to fix the issue with conjugates
                ccor <- Re(ccov2cor(sqrt(cvar(x, method=method, ...) * cvar(Conj(x), method=method, ...))));
            }
        }
        else{
            ccor <- switch(method,
                           "conjugate"=Re(sqrt((ccov(x, y, method=method, ...) * ccov(y, x, method=method, ...)) /
                                                   (cvar(x, method=method, ...)*cvar(y, method=method, ...)))),
                           "direct"=(ccov(y, x, method=method, ...) /
                                         sqrt((cvar(x, method=method, ...)*cvar(y, method=method, ...)))));
        }
    }
    else{
        if(is.matrix(x)){
            nvariables <- ncol(x);
            xScaled <- matrix(NA, nrow(x), nvariables,
                              dimnames=list(NULL, colnames(x)));
            for(i in 1:nvariables){
                xScaled[,i] <- cmdscale(dist(complex2vec(x[,i])), k=1);
            }
            ccor <- cor(xScaled, method=method, ...);
        }
        else{
            xScaled <- cmdscale(dist(complex2vec(x)), k=1);
            yScaled <- cmdscale(dist(complex2vec(y)), k=1);
            ccor <- cor(xScaled, yScaled, method=method, ...);
        }
    }
    return(ccor);
}

#' @param V complex (pseudo)covariance matrix.
#' @rdname ccor
#' @export
ccov2cor <- function(V){
    return(V / sqrt(diag(V) %*% t(diag(V))));
}


#' @param df Number of degrees of freedom to use in the calculation of the statistics.
#' @rdname ccor
#' @export
covar <- function(x, df=NULL){
    # Remove data frame. We don't care about the categorical variables...
    if(is.data.frame(x)){
        x <- as.matrix(x);
    }
    if(is.complex(x)){
        x <- complex2vec(x);
    }

    # Centre the variable
    if(is.matrix(x)){
        obs <- nrow(x);
        if(is.null(df)){
            df <- obs-1;
        }
        x[] <- x - matrix(colMeans(x), nrow=obs, ncol=ncol(x), byrow=TRUE);
    }
    else{
        if(is.null(df)){
            df <- length(x)-1;
        }
        x[] <- x - mean(x);
    }

    return(t(x) %*% x / df);
}
