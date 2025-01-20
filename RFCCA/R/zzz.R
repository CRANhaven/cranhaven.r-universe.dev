.onAttach <- function(libname, pkgname) {
  rfcca.version <- read.dcf(file=system.file("DESCRIPTION", package=pkgname),
                            fields="Version")
  packageStartupMessage(paste("\n",
                              pkgname,
                              rfcca.version))
}
