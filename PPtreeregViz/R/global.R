.onLoad <- function(libname, pkgname)
{
  # make data set names global to avoid CHECK notes
  utils::globalVariables("where")
  invisible()
}
