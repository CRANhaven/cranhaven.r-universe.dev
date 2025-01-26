#' @keywords internal
"_PACKAGE"
NULL

.onUnload <- function(libpath) {
  ## Unload the dynamic binding (particularly useful on Windows)
  library.dynam.unload("openmpt", libpath)
}

#' @useDynLib openmpt, .registration = TRUE
NULL
