#' Setting up the package dartR.popgenomics
#'
#' Setting up dartR.captive
#' @importFrom utils packageVersion read.csv read.delim read.table write.csv write.table
#' @importFrom methods getPackageName is new
#' @importFrom grDevices rainbow hcl
#' @importFrom graphics lines par
#' @importFrom stats ave pchisq var variable.names complete.cases pnorm quantile sd
#' @import adegenet
#' @import dartR.base
#' @import ggplot2
#' @importFrom crayon red yellow green blue cyan
#' @keywords internal


# needed to avoid error
zzz <- NULL

build <- "Jody"
error <- crayon::red
warn <- crayon::yellow
report <- crayon::green
important <- crayon::blue
code <- crayon::cyan


# WELCOME MESSAGE
.onAttach <- function(...) {
  pn <- getPackageName()
  packageStartupMessage(important(
    paste(
      "**** Welcome to", pn, "[Version",
      packageVersion(pn),
      "] ****\n"
    )
  ))
}
