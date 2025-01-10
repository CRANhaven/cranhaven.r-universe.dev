#' Plot tongue contours from spline data.
#'
#' It plots tongue contours from data imported from AAA.
#'
#' @param data A data frame with splines data.
#' @param geom Type of geom to plot. Possible values are: \code{line} (the default),
#' \code{point}, \code{path}.
#' @param ... List of arguments to be passed to \code{geom}.
#' @param palate An optional data frame with the palate spline. If provided,
#' the palate is plotted.
#' @param palate_col The colour of the palate spline (the default is \code{green}).
#'
#' @return An object of class \code{\link[ggplot2]{ggplot}}.
#'
#' @examples
#' plot_tongue(tongue, geom = "point")
#'
#' @export
plot_tongue <- function(data, geom = "line", ..., palate = NULL, palate_col = "green") {
    spline_plot <- ggplot2::ggplot(data, ggplot2::aes_(x = ~X, y = ~Y)) +
    {if (geom == "line") {
        ggplot2::geom_line(stat = "smooth", method = "loess", se = FALSE, ...)
    } else if (geom == "point") {
        ggplot2::geom_point(...)
    } else if (geom == "path") {
        ggplot2::geom_path(...)
    }} +
        ggplot2::coord_fixed(ratio = 1) +
        ggplot2::labs(x = "antero-posterior",
                      y = "supero-inferior"
        )

    if (is.null(palate) == FALSE) {
        spline_plot <- spline_plot +
            ggplot2::geom_line(stat = "smooth", method = "loess",
                               data = palate, se = F, colour = palate_col
            )
    }

    return(spline_plot)
}

#' Plot smooths from a polar \code{gam}
#'
#' It plots the smooths of a polar GAM fitted with \code{polar_gam()}.
#'
#' @inheritParams tidymv::plot_smooths
#' @inheritParams transform_coord
#' @param split Columns to separate as a named list.
#' @param sep Separator between columns (default is \code{"\\."}, which is the default with \code{}). If character, it is interpreted as a regular expression.
#'
#' @return An object of class \code{\link[ggplot2]{ggplot}}.
#'
#' @examples
#' \donttest{
#' library(dplyr)
#' tongue_it01 <- filter(tongue, speaker == "it01")
#' pgam <- polar_gam(Y ~ s(X, by = as.factor(label)), data = tongue_it01)
#'
#' plot_polar_smooths(pgam, X, label)
#' }
#' @export
plot_polar_smooths <- function(model, series, comparison = NULL, origin = NULL, facet_terms = NULL, conditions = NULL, exclude_random = TRUE, series_length = 100, split = NULL, sep = "\\.", time_series) {
    if(!missing(time_series)) {
      warning("This argument has been deprecated and will be removed in the future. Please use `series` instead.")

      series_q = dplyr::enquo(time_series)
    } else {
      time_series = NULL
      series_q <- dplyr::enquo(series)
    }

    comparison_q <- dplyr::enquo(comparison)
    facet_terms_q <- dplyr::enquo(facet_terms)
    if (rlang::quo_is_null(comparison_q)) {
      comparison_q <- NULL
    }
    if (rlang::quo_is_null(facet_terms_q)) {
        facet_terms_q <- NULL
    }
    outcome_q <- model$formula[[2]]

    predicted_tbl <- tidymv::get_gam_predictions(model, !!series_q, conditions, exclude_random = exclude_random, series_length = series_length, split = split, sep = sep)

    if (is.null(origin)) {
        origin <- model$polar_origin
    }

    cartesian_predicted <- predicted_tbl %>%
        transform_coord(
            to = "cartesian",
            origin = origin,
            use_XY = TRUE
        )

    cartesian_ci <- transform_ci(
        predicted_tbl,
        origin = origin
    )

    smooths_plot <- cartesian_predicted %>%
        ggplot2::ggplot(
            ggplot2::aes_string(
                rlang::quo_name(series_q), rlang::quo_name(outcome_q)
            )
        ) +
        {if (!is.null(comparison_q)) {
          ggplot2::geom_polygon(
              data = cartesian_ci,
              ggplot2::aes_string(
                  x = "CI_X",
                  y = "CI_Y",
                  fill = rlang::quo_name(comparison_q)
              ),
              alpha = 0.2
          )
        }} +
        {if (is.null(comparison_q)) {
          ggplot2::geom_polygon(
            data = cartesian_ci,
            ggplot2::aes_string(
              x = "CI_X",
              y = "CI_Y"
            ),
            alpha = 0.2
          )
        }} +
        {if (!is.null(comparison_q)) {
          ggplot2::geom_path(
              ggplot2::aes_string(
                  colour = rlang::quo_name(comparison_q),
                  linetype = rlang::quo_name(comparison_q)
              )
          )
        }} +
        {if (is.null(comparison_q)) {
          ggplot2::geom_path(
            ggplot2::aes_string()
          )
        }} +
        {if (!is.null(facet_terms_q)) {
            ggplot2::facet_wrap(facet_terms_q)
        }}

    return(smooths_plot)
}

#' Polar confidence intervals.
#'
#' It provides a `geom` for plotting polar confidence intervals from the output of \link[rticulate]{predict_polar_gam} with the argument \code{return_ci = true}.
#'
#' @param data A tibble which is the output of \link[rticulate]{predict_polar_gam} with the argument \code{return_ci = true}.
#' @param group The optional grouping factor.
#' @param ci_z The z-value for calculating the CIs (the default is \code{1.96} for 95 percent CI).
#' @param ci_alpha Transparency value of CIs (the default is \code{0.1}).
#'
#' @name geom_polar_ci-deprecated
#' @usage geom_polar_ci(data, group, ci_z, ci_alpha)
#' @seealso \code{\link{rticulate-deprecated}}
#' @keywords internal
NULL

#' @rdname rticulate-deprecated
#' @section \code{geom_polar_ci()}:
#' For \code{geom_polar_ci()}, see \code{vignette("polar-gams", package = "rticulate")}.
#'
#' @export
geom_polar_ci <- function(data, group = NULL, ci_z = 1.96, ci_alpha = 0.1) {
  .Deprecated('vignette("polar-gam", package = "rticulate")', msg = "'geom_polar_ci()' has been deprecated. Check the vignette 'polar-gam' for a working alternative.")
  group_q <- rlang::enquo(group)

  if (rlang::quo_is_null(group_q)) {
    group_q <- NULL
  }

  if (is.null(group_q)) {
    ggplot2::geom_polygon(
      data = data,
      ggplot2::aes(
        x = CI_X,
        y = CI_Y
      ),
      alpha = ci_alpha
    )
  } else {
    ggplot2::geom_polygon(
      data = data,
      ggplot2::aes(
        x = CI_X,
        y = CI_Y,
        group = !!group_q
      ),
      alpha = ci_alpha
    )
  }
}
