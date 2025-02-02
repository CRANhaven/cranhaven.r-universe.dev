#' @importFrom utils packageVersion
.onAttach <- function(libname, pkgname) {
    startUpMessage <- paste0("Package \"complex\", v",packageVersion(pkgname)," loaded.");
    packageStartupMessage(startUpMessage);
}

.onUnload <- function (libpath) {
  library.dynam.unload("complex", libpath);
}
