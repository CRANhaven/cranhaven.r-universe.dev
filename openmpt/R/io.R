#' Read Open ModPlug module
#' 
#' Read any of the music tracker module file formats supported by libopenmpt:
#' <https://wiki.openmpt.org/Manual:_Module_formats>.
#' @param file File path or URL to read the file from. Binary connections are also supported.
#' @param ... Ignored
#' @returns A `modplug` class object. It is an external pointer, pointing to the module object
#' in memory. It can be used for rendering audio.
#' @examples
#' ## You can read from files
#' mod1 <- read_mod(system.file("cyberrid", "cyberrid.mod", package = "openmpt"))
#' 
#' \donttest{
#' ## but also URLs
#' mod2 <- read_mod("https://api.modarchive.org/downloads.php?moduleid=41529#elektric_funk.mod")
#' }
#' @export
read_mod <- function(file, ...) {
  x <- raw()
  if (inherits(file, "connection")) {
    if (!summary(file)$mode %in% c("rb", "r+b"))
      stop("Need a readable binary connection")
  } else {
    file <- file(file, "rb", ...)
  }
  repeat {
    chunk <- readBin(file, "raw", 1024*1024)
    x <- c(x, chunk)
    if (length(chunk) == 0) break
  }
  close(file)
  read_from_raw_(x)
}
