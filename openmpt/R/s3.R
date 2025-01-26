#' Implementation of basic S3 generics
#' 
#' Implementation of basic S3 generics such as [`print()`].
#' @param x Object to apply the method to.
#' @param ... Ignored.
#' @returns In case of `print` and `format` a formatted string
#' with basic information about the module is returned.
#' @method print openmpt
#' @rdname s3methods
#' @export
print.openmpt <- function(x, ...) {
  format.openmpt(x, ...) |> paste0("\n") |> cat()
}

#' @method format openmpt
#' @rdname s3methods
#' @export
format.openmpt <- function(x, ...) {
  sprintf("openmpt module '%s' [%s].",
          get_metadata(x, "title"),
          get_metadata(x, "tracker"))
}