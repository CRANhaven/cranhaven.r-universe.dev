#' @title Detect Python Module
#' @description  A function to detect Python module.
#' @name req_py
#' @aliases req_py
#' @author Xuewei Cheng \email{xwcheng@hunnu.edu.cn}
#' @usage req_py()
#'
#' @import reticulate
#' @importFrom crayon cyan
#' @importFrom crayon blue
#' @import cli
#'
#' @export req_py
req_py <- function() {
  have_python <- reticulate::py_available()
  if (have_python) {
    message(paste0(crayon::cyan(cli::symbol$tick), crayon::blue("It is detected that you have configured the necessary Python environmemt! \n")))
  } else {
    message(paste0(crayon::cyan(cli::symbol$tick), crayon::blue("You should have the Python testing environment!\n")))
  }
  have_numpy <- reticulate::py_module_available("numpy")
  if (!have_numpy) {
    message(paste0(crayon::cyan(cli::symbol$tick), crayon::blue("Install the requirement Python module! \n")))
    reticulate::py_install("numpy")
  } else {
    message(paste0(crayon::cyan(cli::symbol$tick), crayon::blue("It is detected that you have configured the necessary Python module! \n")))
  }
}
