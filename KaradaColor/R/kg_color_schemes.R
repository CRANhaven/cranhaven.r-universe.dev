#' Create complementary color
#'
#' \code{kg_create_cc} This function create complementary color.
#' @importFrom grDevices colorRamp rgb
#'
#' @param basecols Set color data.
#' @param alpha	The alpha transparency. Numbers range from 0-1.
#'      see argument alpha in \code{\link[grDevices]{rgb}}.
#' @return Return base and complementary color in a data frame
#' @export
#' @examples
#' kg_show_console(kg_create_cc())
#' kg_plot_color(color = kg_create_cc())
kg_create_cc <- function(basecols = c("#ff48ac", "red"), alpha = 1){

  n <- length(basecols)
  getRGB <- grDevices::colorRamp(colors = basecols, space = "Lab", interpolate = "spline")
  create_RGB <- getRGB(seq(0, 1, length.out = n))/255
  check_minmax <- apply(create_RGB, 1, max) + apply(create_RGB, 1, min)

  rgb_cols <- check_minmax - create_RGB
  bind_cols <- rbind(create_RGB, rgb_cols)
  result_cols <- grDevices::rgb(bind_cols[, 1], bind_cols[, 2], bind_cols[, 3],
                                alpha = alpha)

  result_data <- as.data.frame(matrix(result_cols, ncol = 2, byrow = FALSE))
  colnames(result_data) <- c("Base", "Complementary")
  rownames(result_data) <- paste0("No_", seq(n))
  return(result_data)

  }

#' Create triad color
#'
#' \code{kg_create_tc} This function create triad color.
#' @importFrom grDevices colorRamp rgb
#'
#' @param basecols Set basecol color data.
#' @param alpha	The alpha transparency. Numbers range from 0-1.
#'      see argument alpha in \code{\link[grDevices]{rgb}}.
#'
#' @return Return triad color in a data frame
#' @export
#' @examples
#' kg_show_console(kg_create_tc())
#' kg_plot_color(color = kg_create_tc())
kg_create_tc <- function(basecols = "#4E5C78", alpha = 1){

  getRGB <- grDevices::colorRamp(color = basecols, space = "Lab", interpolate = "spline")
  create_RGB <- getRGB(seq(0, 1, length.out = 1))/255
  get_triadic <- rbind(create_RGB[c(2, 3, 1)], create_RGB, create_RGB[c(3, 1, 2)])
  result_cols <- grDevices::rgb(get_triadic[, 1], get_triadic[, 2], get_triadic[, 3],
                                alpha = alpha)
  result_data <- as.data.frame(result_cols)
  colnames(result_data) <- "Triadic"
  rownames(result_data) <- paste0("No_", seq(3))
  return(result_data)

  }
