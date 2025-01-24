#' Detransform Centered/Scaled Data
#'
#' This function back transforms centered/scaled data.
#'
#' @param x_data Model matrix that has been centered and/or scaled.
#'
#' @param ... Additional arguments specifying centering/scaling attributes.
#'
#' @return Returns de-centered and de-scaled model matrix.
#'
#' @details
#'
#' The following additional arguments can be passed:
#'
#' * `attr_center` : Centering attributes.
#'    - If none specified, `attr(x_data,'scaled:center')` is utilized.
#'
#' * `attr_scale` : Scaling attributes.
#'    - If none specified, `attr(x_data,'scaled:scale')` is utilized.
#'
#' @examples
#' # Set seed for reproducibility
#' set.seed(1964)
#' # Generate a 10x10 matrix with random numbers
#' original_data <- matrix(rnorm(100), nrow = 10)
#' # Scale and center the data
#' scaled_centered_data <- scale(original_data, center = TRUE,
#' scale = TRUE)
#' # Transform the scaled/centered data back to its original form
#' original_data_recovered <- detransform(scaled_centered_data)
#' # Compare the original data and the recovered data
#' all.equal(original_data,original_data_recovered)
#' @seealso
#' * \code{\link[base]{scale}} for centering and scaling.
#' * \code{\link[base]{all.equal}} for testing "near equality".
#' @export

detransform = function(x_data, ...){

  args=list(...)

  if("attr_center" %in% names(args)){
    attr_center = args$attr_center
  }
  else{
    if(is.null(attr(x_data,'scaled:center'))){
      stop("Please specify centering attributes")
    }else{
      attr_center=attr(x_data,'scaled:center')
    }
  }

  if("attr_scale" %in% names(args)){
    attr_scale = args$attr_scale
  }
  else{
    if(is.null(attr(x_data, 'scaled:scale'))){
      stop("Please specify scaling attributes")
    }else{
      attr_scale=attr(x_data, 'scaled:scale')
    }
  }

  if (is.null(attr_center)){
    decenter = 0
  }
  else{
    decenter = attr_center
  }
  if (is.null(attr_scale)){
    rescale = 1
  }
  else{
    rescale = attr_scale
  }

  x_data_orig = t(apply(x_data, 1, function(x) x*rescale+decenter))       # original data via back transformation

  return(x_data_orig)

}
