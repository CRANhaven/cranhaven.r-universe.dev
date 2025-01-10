# Prints the result of smoothing (object of class \code{smAPC})
#
# @param x Result of smoothing (object of class \code{smAPC}).
# @param ... Other parameters. They are currently ignored.
# @examples
# \donttest{
#
# library(demography)
# m = log(fr.mort$rate$female[1:30, 150:160])
# sm = autoDemogSmooth(m)
# sm
#
# }
# @author Alexander Dokumentov

#' @export

print.smAPC = function(x, ...)
{
  translate = list(
    cohortEffect = "Extracted cohort effects",
    original = "Original data",
    parameters = "Estimated parameters",
    result = "Smooth surface",
    yearsEffect = "Extracted period effects"
  )
  cat("Object of class smAPC with components:")
  for(component in sort(ls(x))) {
    cat("\n\t"); cat(translate[[component]])
  }
  return(invisible(x))
}
