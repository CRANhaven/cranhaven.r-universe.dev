#' Example 1: gastric carcinoma trial data
#'
#' A two-arm gastric carcinoma clinical trial: ninety patients with locally advanced, non-resectable gastric carcinoma received either chemotherapy alone (N = 45) or chemotherapy plus radiation (N = 45).
#'
#' @format A data frame with 90 rows and 3 variables:
#' \describe{
#'   \item{trt}{treatment indicator, 1=chemotherapy + radiation, 0=chemotherapy alone.}
#'   \item{status}{event indicator, 1=death, 0=censored.}
#'   \item{time}{follow up time, in days}
#' }
#' @source K. R. Hess, Assessing time-by-covariate interactions in proportional hazards regression models using cubic spline functions, Statistics in medicine 13 (10) (1994) 1045–1062.
"gast"
