#' @title Madras Longitudinal Schizophrenia Study: Thought Disorder Subset
#' @description \code{madras} contains a subset of the data from the Madras Longitudinal Schizophrenia Study, which collected monthly symptom data on 86 schizophrenia patients after their initial hospitalization. The primary question of interest is whether subjects with an older age-at-onset tend to recover more or less quickly, and whether female patients recover more or less quickly. Recovery is measured by a reduction in the presentation of symptoms.
#' @format A data frame with 922 rows and 5 variables:
#' \describe{
#'   \item{\code{id}}{integer. An indicator for thought disorders}
#'   \item{\code{thought}}{integer. COLUMN_DESCRIPTION}
#'   \item{\code{month}}{integer. Months since hospitalization}
#'   \item{\code{gender}}{integer. An indicator for female gender}
#'   \item{\code{age}}{double. An indicator for age-at-onset \eqn{>= 20} years}
#'}
#' @source Peter Diggle, Patrick J. Heagerty, Kung-Yee Liang, and Scott L. Zeger. Analysis of longitudinal data. Oxford University Press, 2002.
"madras"

#' @title Simulated data set
#' @description A simulated data set. Data were created using fixed marginal mean parameters (beta0, beta1, beta2, beta3) = (-1.85, -0.15, 1.00, 0.15) and association parameters (gamma, sigma) = (1.5, 0.0). These data were created assuming an autocorrelation dependence structure.
#' @format A data frame with 24999 rows and 4 variables:
#' \describe{
#'   \item{\code{id}}{integer. A patient identifier}
#'   \item{\code{Y}}{integer. A binary outcome}
#'   \item{\code{time}}{double. A time-varying covariate}
#'   \item{\code{binary}}{double. A time-invariant covariate}
#'}
"datrand"
