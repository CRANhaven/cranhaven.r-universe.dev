#' Boston housing data set
#'
#' Housing data for 506 census tracts of Boston from the 1970 census. The
#' data set contains the original data by Harrison and Rubinfeld (1979).
#'
#' @format A data frame with three 506 rows observations on 14 variables.
#'   \code{medv} is the target variable. The variables are as follows:
#'   \itemize{
#'   \item{\code{crim}: per capita crime rate by town}
#'   \item{\code{zn}:	proportion
#'   of residential land zoned for lots over 25,000 sq.ft}
#'   \item{\code{indus}: proportion of non-retail business acres per town}
#'   \item{\code{chas}:	Charles River dummy variable (= 1 if tract bounds
#'   river; 0 otherwise)}
#'   \item{\code{nox}: nitric oxides concentration (parts per 10 million)}
#'   \item{\code{rm}:	average number of rooms per dwelling}
#'   \item{\code{age}: proportion of owner-occupied units built prior to 1940}
#'   \item{\code{dis}: weighted distances to five Boston employment centres}
#'   \item{\code{rad}: index of accessibility to radial highways}
#'   \item{\code{tax}: full-value property-tax rate per USD 10,000}
#'   \item{\code{ptratio}: pupil-teacher ratio by town}
#'   \item{\code{b}: 1000(B - 0.63)^2 where B is the proportion of blacks by
#'   town}
#'   \item{\code{lstat}: percentage of lower status of the population}
#'   \item{\code{medv}:	median value of owner-occupied homes in USD 1000's}
#'   }
#'
#' @examples
#' ## load data
#' data(BostonHousing, package = "RFpredInterval")
"BostonHousing"
