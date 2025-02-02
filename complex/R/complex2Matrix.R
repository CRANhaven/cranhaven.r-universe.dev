#' Functions to manipulate complex variables and matrices
#'
#' \code{complex2mat()} constructs a matrix from the provided complex variable,
#' while \code{complex2vec()} returns a vector (in mathematical sense), both of them
#' split the real and imaginary parts. \code{mat2complex()} and \code{vec2complex()} do
#' the reverse of the respective functions. See details for explanation.
#'
#' Complex variable x + iy can be represented as a vector (x y)' or as a matrix:
#' (x -y)
#' (y  x)
#'
#' \code{complex2mat()} returns the latter, while \code{complex2vec()} returns the
#' former. If a user provides a vector of complex variables, the values are stacked above
#' each other. If a matrix is provided, a higher dimensional matrix is returned.
#'
#' \code{mat2complex()} and \code{vec2complex()} return complex variables based on provided
#' matrix.
#'
#' The function is needed to calculate some statistics for complex variables in vector form.
#'
#' @template author
#' @template references
#'
#' @keywords univar
#'
#' @param x vector or matrix of complex variables.
#'
#' @return A matrix with real and imaginary parts of x split into columns (and rows in case
#' of \code{complex2mat()}).
#'
#' #' @references \itemize{
#' \item Svetunkov, S. & Svetunkov I (2022) Complex Autoregressions. In Press.
#' }
#'
#' @seealso \code{\link[complex]{clm}}
#'
#' @examples
#'
#' # Generate random complex variables
#' x <- complex(real=rnorm(100,10,10), imaginary=rnorm(100,10,10))
#'
#' # Get a matrix and a vector for one value
#' complex2mat(x[1])
#' complex2vec(x[1])
#'
#' # Get matrices for all values
#' complex2mat(x)
#' complex2vec(x)
#'
#' @rdname complex2mat
#' @export
complex2mat <- function(x){
    # Function creates a matrix based on the provided vector/matrix of complex variables
    # Remove data frame. We don't care about the categorical variables...
    if(is.data.frame(x)){
        x <- as.matrix(x);
    }

    if(is.matrix(x)){
        nrowX <- nrow(x);
        ncolX <- ncol(x);
        rownamesX <- rownames(x);
        if(!is.null(rownamesX)){
            rownamesX <- paste0(rep(rownamesX,each=2), c("_r","_i"));
        }
        colnamesX <- colnames(x);
        if(!is.null(colnamesX)){
            colnamesX <- paste0(rep(colnamesX,each=2), c("_r","_i"));
        }
    }
    else{
        nrowX <- length(x);
        ncolX <- 1;
        rownamesX <- names(x);
        if(!is.null(rownamesX)){
            rownamesX <- paste0(rep(rownamesX,each=2), c("_r","_i"));
        }
        colnamesX <- c("x_r", "x_i");
        x <- as.matrix(x);
    }

    # The matrix that will contain the values
    complexMatrix <- matrix(NA, nrowX*2, ncolX*2, dimnames=list(rownamesX, colnamesX));

    complexMatrix[1:nrowX*2-1,(1:ncolX)*2-1] <- Re(x[,(1:ncolX)]);
    complexMatrix[1:nrowX*2,(1:ncolX)*2] <- Re(x[,(1:ncolX)]);
    complexMatrix[1:nrowX*2-1,(1:ncolX)*2] <- -Im(x[,(1:ncolX)]);
    complexMatrix[1:nrowX*2,(1:ncolX)*2-1] <- Im(x[,(1:ncolX)]);

    return(complexMatrix);
}

#' @rdname complex2mat
#' @export
complex2vec <- function(x){
    # Function creates a vector (mathematical) based on the provided vector/matrix of complex variables
    # Remove data frame. We don't care about the categorical variables...
    if(is.data.frame(x)){
        x <- as.matrix(x);
    }

    if(is.matrix(x)){
        nrowX <- nrow(x);
        ncolX <- ncol(x);
        rownamesX <- rownames(x);
        colnamesX <- colnames(x);
        if(!is.null(colnamesX)){
            colnamesX <- paste0(rep(colnamesX,each=2), c("_r","_i"));
        }
    }
    else{
        nrowX <- length(x);
        ncolX <- 1;
        rownamesX <- names(x);
        colnamesX <- c("x_r", "x_i");
        x <- as.matrix(x);
    }

    # The matrix that will contain the values
    complexMatrix <- matrix(NA, nrowX, ncolX*2, dimnames=list(rownamesX, colnamesX));

    complexMatrix[,(1:ncolX)*2-1] <- Re(x[,(1:ncolX)]);
    complexMatrix[,(1:ncolX)*2] <- Im(x[,(1:ncolX)]);

    return(complexMatrix);
}

#' @rdname complex2mat
#' @export
mat2complex <- function(x){
    # Function creates a matrix/vector of complex variables based on the provided vector/matrix
    # Remove data frame. We don't care about the categorical variables...
    if(is.data.frame(x)){
        x <- as.matrix(x);
    }

    if(is.matrix(x)){
        nrowX <- nrow(x);
        ncolX <- ncol(x);
        rownamesX <- rownames(x);
        if(!is.null(rownamesX)){
            rownamesX <- rownamesX[1:(nrowX/2)*2-1];
        }
        colnamesX <- colnames(x);
        if(!is.null(colnamesX)){
            colnamesX <- colnamesX[1:(ncolX/2)*2-1];
        }
    }
    else{
        stop("x is not a matrix! Cannot proceed.");
    }

    # The matrix that will contain the values
    complexMatrix <- matrix(NA, nrowX/2, ncolX/2, dimnames=list(rownamesX, colnamesX));

    complexMatrix[,1:(ncolX/2)] <- complex(real=x[1:(nrowX/2)*2,1:(ncolX/2)*2], imaginary=x[1:(nrowX/2)*2-1,1:(ncolX/2)*2]);

    return(complexMatrix);
}

#' @rdname complex2mat
#' @export
vec2complex <- function(x){
    # Function creates a complex vector/matrix based on the provided matrix
    # Remove data frame. We don't care about the categorical variables...
    if(is.data.frame(x)){
        x <- as.matrix(x);
    }

    if(is.matrix(x)){
        nrowX <- nrow(x);
        ncolX <- ncol(x);
        rownamesX <- rownames(x);
        colnamesX <- colnames(x);
        if(!is.null(colnamesX)){
            colnamesX <- colnamesX[1:(ncolX/2)*2-1];
        }
    }
    else{
        stop("x is not a matrix! Cannot proceed.");
    }

    # The matrix that will contain the values
    complexMatrix <- matrix(NA, nrowX, ncolX/2, dimnames=list(rownamesX, colnamesX));
    complexMatrix[] <- complex(real=x[,(1:(ncolX/2))*2-1], imaginary=x[,(1:(ncolX/2))*2]);

    return(complexMatrix);
}
