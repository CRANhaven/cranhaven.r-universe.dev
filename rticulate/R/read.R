#' Data import function.
#'
#' It reads a file with data exported from AAA. The data are automatically
#' transformed from a wide to a long format (each row has values of X or Y axes
#' for each fan line). The imported tibble can then be used for plotting and
#' statistical analysis.
#'
#' @param file The file or files with AAA data.
#' @param column_names The names of the columns without including the splines columns.
#' @param fan_lines The number of fan lines.
#' @param coordinates A string specifying the coordinate system. Possible values are \code{"cartesian"} and \code{"polar"}.
#' @param na_rm Remove NAs.
#' @param format A string specifying the data format. Possible values are \code{"long"} and \code{"wide"} (the default is \code{"long"}).
#'
#' @return An object of class \code{\link[tibble]{tbl_df-class}} (a tibble).
#'
#' @importFrom magrittr "%>%"
#' @keywords internal
read_aaa_data <- function(file, column_names, fan_lines, coordinates, na_rm, format) {
    if (coordinates == "cartesian") {
        coord_names <- paste0(
            rep(c("X_", "Y_"), fan_lines),
            rep(1:fan_lines, each = 2)
        )
    } else {
        coord_names <- paste0(
            rep(c("radius_", "theta_"), each = fan_lines),
            rep(1:fan_lines)
        )
    }

    columns <- c(
        column_names,
        coord_names
    )

    if (format == "long") {
        data <- readr::read_tsv(
            file,
            col_names = columns,
            na = "*",
            trim_ws = TRUE
        ) %>%
            # Add index column for cases where contours don't have an identifier
            dplyr::mutate(
                .index = dplyr::row_number()
            ) %>%
            dplyr::mutate_at(
                dplyr::vars(dplyr::matches("(^[XY]_)|(^radius_)|(^theta_)")),
                as.numeric
            ) %>%
            tidyr::pivot_longer(
                cols = dplyr::matches("(^[XY]_)|(^radius_)|(^theta_)"),
                names_to = "spline",
                values_to = "coordinate"
            ) %>%
            tidyr::separate(spline, c("axis", "fan_line"), convert = TRUE) %>%
            tidyr::pivot_wider(
                names_from = "axis",
                values_from = "coordinate"
            ) %>%
            dplyr::relocate(.index, .after = tidyselect::last_col())
    } else if (format == "wide") {
        data <- readr::read_tsv(
            file,
            col_names = columns,
            na = "*",
            trim_ws = TRUE
        ) %>%
        dplyr::mutate_at(dplyr::vars(dplyr::matches("(^[XY]_)|(^radius_)|(^theta_)")),
                         as.numeric)
    } else {
        stop("Format not recognised. Available formats are 'long' and 'wide'.")
    }

    if (na_rm == TRUE) {
        data <- stats::na.omit(data)
    }

    return(data)
}

#' Read tab separated files with AAA spline data.
#'
#' It reads a file or a list of files with data exported from AAA. The data are
#' automatically transformed from a wide to a long format (each row has values
#' of X or Y axes for each fan line). The imported tibble can then be used for
#' plotting and statistical analysis.
#'
#' @param file The path of the file with AAA data. It can also be a character vector with multiple paths as separate strings..
#' @param column_names The names of the columns without including the splines columns.
#' @param fan_lines The number of fan lines (the default is \code{42}).
#' @param coordinates A string specifying the coordinate system. Possible values are \code{"cartesian"} (the default) and \code{"polar"}.
#' @param na_rm Remove NAs (the default is \code{FALSE}).
#' @param format A string specifying the data format. Possible values are \code{"long"} and \code{"wide"} (the default is \code{"long"}).
#'
#' @return A tibble. An \code{.index} column is added which indexes (groups) each tongue contour.
#'
#' @examples
#' columns <- c("speaker","seconds","rec_date","prompt","label",
#' "TT_displacement","TT_velocity","TT_abs_velocity","TD_displacement",
#' "TD_velocity","TD_abs_velocity")
#' file_path <- system.file("extdata", "it01.tsv", package = "rticulate")
#'
#' tongue <- read_aaa(file_path, columns, na_rm = TRUE)
#'
#' @export
read_aaa <- function(file, column_names, fan_lines = 42, coordinates = "cartesian", na_rm = FALSE, format = "long") {
    if (!coordinates %in% c("cartesian", "polar")) {
        stop("The chosen coordinate system is not supported. Possible values are cartesian or polar.")
    }

    if (length(file) == 1) {
        read_aaa_data(file, column_names, fan_lines, coordinates, na_rm, format)
    } else {
        purrr::map_df(.x = file, .f = ~read_aaa_data(.x, column_names, fan_lines, coordinates, na_rm, format))
    }
}
