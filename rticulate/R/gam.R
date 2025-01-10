#' Polar generalised additive model (polar GAM)
#'
#' It fits a generalised additive model (GAM) to transformed polar tongue data
#' and it returns a model in polar coordinates. Use \code{plot_polar_smooths()}
#' for plotting.
#'
#' It is advised to fit a separate model per speaker, unless you have a working
#' method for inter-speaker normalisation of the coordinates.
#'
#' @param formula A GAM formula.
#' @inheritParams transform_coord
#' @param AR_start The \code{AR.start} argument to be passed to \code{mgcv::bam()}.
#' @param ... Arguments to be passed to \code{mgcv::bam()}.
#'
#' @return An object of class \code{"gam"} as described in
#'   \code{\link[mgcv]{gamObject}}.
#'
#' @examples
#' \donttest{
#' library(dplyr)
#' tongue_it01 <- filter(tongue, speaker == "it01")
#' pgam <- polar_gam(Y ~ s(X, by = c2_place) + s(X, word, bs = "fs"),
#' data = tongue_it01)
#' }
#' @export
polar_gam <- function(formula, data, origin = NULL, fan_lines = c(10, 25), AR_start = NULL, ...) {
    if (is.null(origin)) {
        origin <- rticulate::get_origin(data, fan_lines = fan_lines)
    }

    polar_data <- rticulate::transform_coord(
        data,
        to = "polar",
        origin = origin,
        use_XY = TRUE
    )

    fn_call <- match.call()
    fn_call$formula <- formula
    fn_call$data <- polar_data
    fn_call$AR.start <- AR_start
    fn_call[[1]] <- mgcv::bam

    model <- eval(fn_call)

    model$polar_origin <- origin

    return(model)
}

#' Get all predictions from a polar GAM model
#'
#' It returns a tibble with the predictions from all the terms in a \link[rticulate]{polar_gam} model.
#'
#' The function behaves like \link[tidymv]{predict_gam} but it converts the
#' coordinates from polar to cartesian automatically. Check
#' \code{vignette("predict-gam", package = "tidymv")} to an overview of the
#' predict method.
#'
#' To see an example of plotting, see the examples in \link[rticulate]{geom_polar_ci}.
#'
#' @param model A \link[rticulate]{polar_gam} model object.
#' @param origin The coordinates of the origin as a vector of \code{c(x, y)} coordinates.
#' @param exclude_terms Terms to be excluded from the prediction. Term names should be given as they appear in the model summary (for example, \code{"s(x0,x1)"}).
#' @param length_out An integer indicating how many values along the numeric predictors to use for predicting the outcome term (the default is \code{50}).
#' @param values User supplied values for numeric terms as a named list.
#' @param return_ci Whether to return a tibble with cartesian confidence intervals (for use with \link[rticulate]{geom_polar_ci}).
#' @param ci_z The z-value for calculating the CIs (the default is \code{1.96} for 95 percent CI).
#'
#' @return A tibble with predictions from a \link[rticulate]{polar_gam} model.
#' @examples
#' \donttest{
#' library(dplyr)
#' tongue_it01 <- filter(tongue, speaker == "it01")
#' it01_pol <- polar_gam(Y ~ s(X, by = c2_place) + s(X, word, bs = "fs"),
#' data = tongue_it01)
#'
#' # get predictions
#' it01_pred <- predict_polar_gam(it01_pol)
#'
#' # get predictions excluding the random smooth for word (the coefficient for
#' # the random smooth is set to 0)
#' it01_excl_rand <- predict_polar_gam(it01_pol, exclude_terms = "s(X,word)")
#' }
#' @export
predict_polar_gam <- function(model, origin = NULL, exclude_terms = NULL, length_out = 50, values = NULL, return_ci = FALSE, ci_z = 1.96) {
  n_terms <- length(model[["var.summary"]])

  term_list <- list()

  for (term in 1:n_terms) {
    term_summary <- model[["var.summary"]][[term]]
    term_name <- names(model[["var.summary"]])[term]

    if (term_name %in% names(values)) {
      new_term <- values[[which(names(values) == term_name)]]
    } else {
      if (is.numeric(term_summary)) {

        min_value <- min(term_summary)
        max_value <- max(term_summary)

        new_term <- seq(min_value, max_value, length.out = length_out)

      } else if (is.factor(term_summary)) {

        new_term <- levels(term_summary)

      } else {
        stop("The terms are not numeric or factor.\n")
      }
    }

    term_list <- append(term_list, list(new_term))

    names(term_list)[term] <- term_name
  }

  new_data <- expand.grid(term_list)

  predicted <- as.data.frame(mgcv::predict.gam(model, new_data, exclude = exclude_terms, se.fit = TRUE))

  predictions <- cbind(new_data, predicted)
  predictions <- tibble::as_tibble(predictions)
  predictions <- dplyr::rename(predictions, Y = "fit")

  if (is.null(origin)) {
    origin <- model$polar_origin
  }

  if (return_ci) {
    predictions <- dplyr::mutate(
      predictions,
      CI_upper = Y + ci_z * se.fit,
      CI_lower = Y - ci_z * se.fit
    )

    predictions <- transform_ci(
      predictions,
      origin = origin
    ) %>%
      dplyr::select(-CI_upper, -CI_lower)

  } else {
    predictions <- transform_coord(
      data = predictions,
      to = "cartesian",
      origin = origin,
      use_XY = TRUE
    )
  }

  attributes(predictions)$origin <- origin

  return(predictions)
}
