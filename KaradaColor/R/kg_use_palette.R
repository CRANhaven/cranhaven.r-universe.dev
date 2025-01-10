#' Get color palette data
#'
#' \code{kg_get_color} This function creates a vector of \code{n} color palette
#' data for the KaradaColor Package.
#'
#' @importFrom grDevices colorRamp rgb
#' @param n Number of colors to create.
#' @param name color palette name. (default: \code{"Sapporo_Sta"})
#' @param alpha	The alpha transparency. Numbers range from 0-1. see argument
#'   alpha in \code{\link[grDevices]{rgb}}.
#'
#' @return Vector containing a hex color code representation for the chosen
#'   palette.
#' @export
#' @examples
#' library("scales")
#' show_col(kg_get_color(n = 20, name = "Totan", alpha = 0.5))
#'
#' library("aRtsy")
#' set.seed(1234)
#' canvas_strokes(colors = kg_get_color(name = "Otaru_Unga"),
#'                neighbors = 1, p = 0.02, iterations = 1,
#'                resolution = 350)
kg_get_color <- function(n = 5, name = "Sapporo_Sta", alpha = 1){

  pal_col <- df_KG_palettes[[name]]
  cols <- grDevices::colorRamp(pal_col, space = "Lab", interpolate = "spline")
  result <- cols(seq(0, 1, length.out = n)) / 255
  return(grDevices::rgb(result[, 1], result[, 2], result[, 3], alpha = alpha))

  }

#' @rdname kg_get_color
#' @importFrom grDevices colorRamp rgb
#' @export
kg_get_palette <- function(name = "Sapporo_Sta", alpha = 1){

  function(n) {

    return(kg_get_color(n, name, alpha))

    }
}

#' Use color scales on 'ggplot2'
#'
#' {scale_color_kg} Use color palette on 'ggplot2' colors.
#' @importFrom ggplot2 discrete_scale scale_color_gradientn
#'
#' @param name color palette name. (default: \code{"Sapporo_Sta"})
#' @param alpha	The alpha transparency. Numbers range from 0-1. see argument
#'   alpha in \code{\link[grDevices]{rgb}}.
#' @param na.value Color of missing value.
#' @param discrete Generate a discrete palette. (\code{FALSE} - generate
#'   continuous palette)
#'
#' @return Create a user defined color palette for ggplot2.
#' @export
#' @examples
#' library("ggplot2")
#' ggplot(data = diamonds, aes(x = cut, y = price,
#'                             color = cut, fill = cut)) +
#'   geom_boxplot() +
#'   scale_color_kg(name = "Hanamushiro", alpha = 0.2) +
#'   scale_fill_kg(name = "Hokkaido_Sky", alpha = 0.2) +
#'   theme_dark()
scale_color_kg <- function(name = "Sapporo_Sta", alpha = 1,
                           na.value = "red", discrete = TRUE) {

  if(discrete){

    ggplot2::discrete_scale(aesthetics = "color",
                            scale_name = name,
                            palette = kg_get_palette(name, alpha),
                            na.value = na.value)

  }else{

    ggplot2::scale_color_gradientn(colours = kg_get_color(n = 255, name, alpha),
                                   na.value = na.value)

  }

 }

#' @rdname scale_color_kg
#' @importFrom ggplot2 discrete_scale
#' @export
scale_colour_kg <- scale_color_kg

#' Use Color fills on 'ggplot2'
#'
#' \code{scale_fill_kg} Use color palette on 'ggplot2' fills.
#' @importFrom ggplot2 discrete_scale scale_fill_gradientn
#'
#' @param name color palette name. (default: \code{"Sapporo_Sta"})
#' @param alpha	The alpha transparency. Numbers range from 0-1.
#'    see argument alpha in \code{\link[grDevices]{rgb}}.
#' @param na.value Color of missing value.(default: "red")
#' @param discrete Generate a discrete palette.
#'    (\code{FALSE} - generate continuous palette)
#'
#' @return Create a user defined color palette for 'ggplot2'.
#' @export scale_fill_kg
#' @examples
#' set.seed(1)
#' x <- LETTERS[1:20]
#' y <- paste0("var", seq(1,20))
#' data <- expand.grid(X=x, Y=y)
#' data$Z <- sample(c(NA, rnorm(15)), 20, replace = TRUE)
#' library("ggplot2")
#' ggplot(data, aes(X, Y, fill= Z)) +
#'   geom_tile() +
#'   scale_fill_kg(discrete = FALSE, name = "Hanamushiro",
#'                 alpha = 0.4, na.value = "red")
scale_fill_kg <- function(name = "Sapporo_Sta", alpha = 1,
                          na.value = "red", discrete = TRUE) {

  if(discrete){

    ggplot2::discrete_scale(aesthetics = "fill",
                            scale_name = name,
                            palette = kg_get_palette(name, alpha),
                            na.value = na.value)

  }else{

    ggplot2::scale_fill_gradientn(colours = kg_get_color(n = 255, name, alpha),
                                  na.value = na.value)

  }

}
