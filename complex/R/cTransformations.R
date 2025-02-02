#' Functions scale real and imaginary parts of a complex variable
#'
#' Function \code{cscale()} will do the scaling based on the selected method, while
#' the function \code{cdescale()} will transform the variable to get to the
#' original units.
#'
#' @template references
#' @template author
#'
#' @keywords univar
#'
#' @param y vector of a complex variable in the original scale.
#' @param yScaled vector of the already scaled complex variable.
#' @param scaling scaling method to use. "normalisation" implies scaling
#' to make sure that \code{y} lie in [0, 1] (subtract the minimum value and divide by
#' the range). "standardisation" standardises the variable (i.e. subtract the mean
#' then divide by standard deviation). "max" just divides the variable by the
#' maximum value.
#'
#' @return A vector of the same size as \code{y}, containing scaled complex variable.
#'
#' @seealso \code{\link[base]{scale}}
#'
#' @examples
#'
#' # Generate random complex variables
#' y <- complex(real=rnorm(100,10,10), imaginary=rnorm(100,10,10))
#'
#' yScaled <- cscale(y)
#' cdescale(yScaled, y)
#'
#' @rdname cscale
#' @export
cscale <- function(y, scaling=c("normalisation","standardisation","max")){
    # The function scales both parts of the complex variable
    scaling <- match.arg(scaling);

    yRe <- Re(y);
    yIm <- Im(y);

    if(scaling=="normalisation"){
        y[] <- complex(real=(yRe-min(yRe))/(max(yRe)-min(yRe)),
                       imaginary=(yIm-min(yIm))/(max(yIm)-min(yIm)));
    }
    else if(scaling=="standardisation"){
        y[] <- complex(real=(yRe-mean(yRe))/sd(yRe),
                       imaginary=(yIm-mean(yIm))/sd(yIm));
    }
    else{
        y[] <- complex(real=yRe/max(yRe),
                       imaginary=yIm/max(yIm));
    }

    if(all(yIm==0)){
        return(Re(y));
    }
    else{
        return(y);
    }
}

#' @rdname cscale
#' @export
cdescale <- function(yScaled, y, scaling=c("normalisation","standardisation","max")){
    # The function scales both parts of the complex variable
    scaling <- match.arg(scaling);

    yRe <- Re(y);
    yIm <- Im(y);

    yScaledRe <- Re(yScaled);
    yScaledIm <- Im(yScaled);

    if(scaling=="normalisation"){
        yScaled[] <- complex(real=yScaledRe*(max(yRe)-min(yRe)) + min(yRe),
                             imaginary=yScaledIm*(max(yIm)-min(yIm)) + min(yIm));
    }
    else if(scaling=="standardisation"){
        yScaled[] <- complex(real=yScaledRe * sd(yRe) + mean(yRe),
                             imaginary=yScaledIm * sd(yIm) + mean(yIm));
    }
    else{
        yScaled[] <- complex(real=yScaledRe*max(yRe),
                             imaginary=yScaledIm*max(yIm));
    }

    if(all(yIm==0)){
        return(Re(yScaled));
    }
    else{
        return(yScaled);
    }
}

#' Functions that transform real and imaginary parts of a complex variable
#'
#' Function \code{clog()} will take logarithm of real and imaginary parts separately
#' and then merge the resulting variable in the complex one. The function
#' \code{cexp()} does the opposite transform, taking exponent of parts and then
#' merging them.
#'
#' @template references
#' @template author
#'
#' @keywords univar
#'
#' @param y vector of a complex variable in the original scale.
#' @param base a positive or complex number: the base with respect to which
#' logarithms/powers are computed. Defaults to exp(1).
#'
#' @return A vector of the same size as \code{y}, containing transformed complex variable.
#'
#' @seealso \code{\link[complex]{cscale}}
#'
#' @examples
#'
#' # Generate random complex variables
#' y <- complex(real=rnorm(100,100,10), imaginary=rnorm(100,100,10))
#'
#' yLog <- clog(y)
#' cexp(yLog)
#'
#' @rdname clog
#' @export
clog <- function(y, base=exp(1)){
    # The function takes logarithms of both parts of the complex variable

    yRe <- Re(y);
    yIm <- Im(y);

    y[] <- complex(real=log(yRe, base),
                   imaginary=log(yIm, base));

    if(all(yIm==0)){
        return(Re(y));
    }
    else{
        return(y);
    }
}

#' @rdname clog
#' @export
cexp <- function(y, base=exp(1)){
    # The function takes exponent of both parts of the complex variable

    yRe <- Re(y);
    yIm <- Im(y);

    y[] <- complex(real=base^yRe,
                   imaginary=base^yIm);

    if(all(yIm==0)){
        return(Re(y));
    }
    else{
        return(y);
    }
}
