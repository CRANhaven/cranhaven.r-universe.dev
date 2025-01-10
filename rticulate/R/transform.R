#' Transform the coordinates of spline data
#'
#' This function transforms the coordinates of spline data between Cartesian and
#' polar coordinate systems. The origin x and y coordinates can be supplied by
#' the user, or calculated automatically (see Details).
#'
#' The transformation between the coordinate systems require the selection of an
#' origin in Cartesian coordinates (x and y). The origin ideally corresponds to
#' the virtual origin of the ultrasound waves from the probe. The origin
#' coordinates can be supplied by the user as a vector with the \code{origin}
#' argument, or they can be estimated automatically if \code{origin = NULL} (the
#' default). The estimation is performed by \code{\link{get_origin}} (see that
#' function documentation for details).
#'
#' @param data A data set containing the spline coordinates (cartesian coordinates must be in columns named \code{X} and \code{Y}, polar coordinates in columns named \code{angle} and \code{radius}; these are the defaults in data imported with \code{read_aaa()}).
#' @param to Which system to convert to, as a string, either \code{"polar"} or \code{"cartesian"} (the default is \code{"polar"}).
#' @param origin The coordinates of the origin as a vector of \code{c(x, y)} coordinates.
#' @param use_XY Whether to use the column names \code{X} and \code{Y} when converting to and from polar coordinates, rather than the default \code{angle} and \code{radius} (the default is \code{FALSE}. If \code{TRUE}, the columns \code{X} and \code{Y} are overwritten with the converted values. If converting to polar, \code{X} is the \code{angle} and \code{Y} the \code{radius}.
#' @inheritParams get_origin
#'
#' @return An object of class \code{\link[tibble]{tbl_df-class}} (a tibble).
#'
#' @export
transform_coord <- function(data, to = "polar", origin = NULL, fan_lines = c(10, 25), use_XY = FALSE) {
    if (!(to %in% c("polar", "cartesian"))) {
        stop("Please, specify either 'polar' or 'cartesian' as the value of 'to'.")
    }

    if (is.null(origin)) {
        origin <- rticulate::get_origin(data, fan_lines = fan_lines)
    }

    if (!use_XY) {
        if (to == "polar") {
            transformed_data <- data %>%
                dplyr::mutate(
                    radius = sqrt((X - origin[1]) ^ 2 + (Y - origin[2]) ^ 2),
                    angle = pi + atan2(Y - origin[2], X - origin[1])
                )
        } else {
            transformed_data <- data %>%
                dplyr::mutate(
                    X = origin[1] - radius * cos(angle),
                    Y = -(radius * sin(angle) - origin[2])
                )
        }
    } else {
        if (to == "polar") {
            transformed_data <- data %>%
                dplyr::mutate(
                    X_new = pi + atan2(Y - origin[2], X - origin[1]),
                    Y_new = sqrt((X - origin[1]) ^ 2 + (Y - origin[2]) ^ 2)
                ) %>%
                dplyr::select(-X, -Y) %>%
                dplyr::rename(
                    X = X_new,
                    Y = Y_new
                )
        } else {
            transformed_data <- data %>%
                dplyr::mutate(
                    X_new = origin[1] - Y * cos(X),
                    Y_new = -(Y * sin(X) - origin[2])
                ) %>%
                dplyr::select(-X, -Y) %>%
                dplyr::rename(
                    X = X_new,
                    Y = Y_new
                )
        }
    }

    return(transformed_data)
}

#' Get the origin of spline data
#'
#' It returns the Cartesian \code{x, y} coordinates of the virtual origin of the
#' ultrasonic waves/probe surface (see Details).
#'
#' The function estimates the origin of the ultrasond waves from the probe using
#' the spline data and the provided fan lines. The estimation method is based on
#' Heyne, Matthias & Donald Derrick (2015) Using a radial ultrasound probe's
#' virtual origin to compute midsagittal smoothing splines in polar coordinates.
#' \emph{The Journal of the Acoustical Society of America} 138(6), EL509–EL514,
#' DOI:10.1121/1.4937168.
#'
#' @section Origin estimation: The equations of the two fan lines (10 and 25 by
#'   default) are set equal to find their intersection. The intersection is the
#'   origin. In some cases, the linear estimation of the equation fails, and an
#'   error related to fit is returned. In these cases, try different fan lines
#'   by increasing the minimum fan line and/or changing the maximum fan line
#'   (for example, if \code{c(10, 25)} returns an error, try \code{c(15, 30)}).
#'
#' @param data The spline data (the cartesian coordinates must be in two columns
#'   named \code{X} and \code{Y}).
#' @param fan_lines A numeric vector with two fan lines (the default is
#'   \code{c(10, 25)}).
#'
#' @return A numeric vector with the Cartesian \code{(x, y)} coordinates of the virtual origin of the
#'   ultrasonic waves/probe surface.
#'
#' @export
get_origin <- function(data, fan_lines = c(10, 25)) {
    if (!("X" %in% colnames(data)) || !("Y" %in% colnames(data))) {
        stop(glue::glue("`data` does not contain columns named `X` and/or `Y`. Please, change the column names in `data` or add the columns `X` and `Y` to it."))
    }

    if (!("fan_line" %in% colnames(data))) {
        stop(glue::glue("'{fan_line_col}' is not a column of data. Please, specify the name of the fan line column in your data."))
    }

    if (nrow(data) == 0) {
        stop("Cannot work with empty data. Please, choose non-empty data.")
    }

    line_1 <- dplyr::filter(data, fan_line == fan_lines[1])
    line_2 <- dplyr::filter(data, fan_line == fan_lines[2])

    line_1_model <- try(
        stats::lm(
            Y ~ X,
            data = line_1
        ),
        silent = TRUE
    )
    line_2_model <- try(
        stats::lm(
            Y ~ X,
            data = line_2
        ),
        silent = TRUE
    )

    if (inherits(line_1_model, "try-error") | inherits(line_2_model, "try-error")) {
        stop(glue::glue("The chosen fan lines ({fan_lines}) lead to a bad fit. Please, choose other fan lines."))
    }

    coefficient_matrix <- rbind(stats::coef(line_1_model), stats::coef(line_2_model))

    origin <- try(c(
        -solve(cbind(coefficient_matrix[,2], -1)) %*% coefficient_matrix[,1]
    ), silent = TRUE)

    if (inherits(origin, "try-error")) {
        fan_lines_print <- paste("c(", fan_lines[1], ", ", fan_lines[2], ")", sep = "")
        stop(glue::glue("The chosen fan lines {fan_lines_print} lead to a bad fit. Please, choose other fan lines."))
    }

    if (anyNA(origin)) {
        fan_lines_print <- paste("c(", fan_lines[1], ", ", fan_lines[2], ")", sep = "")
        stop(glue::glue("Could not calculate origin. The chosen fan_lines ({fan_lines_print}) do not contain data. Please, try different fan lines."))
    }

    message(glue::glue("The origin is x = {origin[1]}, y = {origin[2]}."))
    return(origin)
}

#' Transform confidence intervals to cartesian
#'
#' It returns the cartesian coordinates of the confidence intervals from a polar
#' \code{gam}/\code{bam}.
#'
#' @param predictions A data frame containing the predictions obtained from a
#'   polar \code{gam}/\code{bam}.
#' @param origin The coordinates of the origin as a vector of \code{c(x, y)}
#'   coordinates.
#'
#' @return An object of class \code{\link[tibble]{tbl_df-class}} (a tibble).
#'
#' @keywords internal
#' @importFrom dplyr "n"
transform_ci <- function(predictions, origin = NULL) {
    predictions <- predictions %>%
        dplyr::mutate(
            CI_upper_X = origin[1] - CI_upper * cos(X),
            CI_upper_Y = -(CI_upper * sin(X) - origin[2]),
            CI_lower_X = origin[1] - CI_lower * cos(X),
            CI_lower_Y = -(CI_lower * sin(X) - origin[2]),
            index = seq(1, n())
        )

    predictions_upper <- predictions %>%
        dplyr::select(-CI_lower_X, -CI_lower_Y) %>%
        dplyr::rename(
            CI_X = CI_upper_X,
            CI_Y = CI_upper_Y
        )

    predictions_lower <- predictions %>%
        dplyr::select(-CI_upper_X, -CI_upper_Y) %>%
        dplyr::arrange(dplyr::desc(index)) %>%
        dplyr::rename(
            CI_X = CI_lower_X,
            CI_Y = CI_lower_Y
        )

    predictions <- rbind(predictions_upper, predictions_lower)

    return(predictions)
}
