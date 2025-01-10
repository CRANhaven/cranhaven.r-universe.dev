#' Draw the color data
#'
#' \code{kg_plot_color} This function draw the color data.
#' @importFrom grDevices colorRampPalette rgb
#' @importFrom graphics image rect text axis
#' @importFrom stats setNames
#'
#' @param name Color palette color palette name. (default: \code{"Sapporo_Sta"})
#' @param color Color data. Precedence over name except NULL. (default: NULL)
#' @param n Number of colors to create.
#' @param showcode Add a color code to the plot.
#'
#' @return Vector containing a hex color code representation for the chosen
#'   palette
#' @export
#' @examples
#' #Draw the color palette of the KaradaColor
#' kg_plot_color(name = "Amanohashidate", n = 5, showcode = FALSE)
#' #Draw the KG_create_cc command
#' kg_plot_color(color = kg_create_cc(c("#ff48ac", "yellow")), showcode = TRUE)
#' #Draw the KG_create_tc command
#' kg_plot_color(color = kg_create_tc("yellow"), showcode = TRUE)
#' #Color data
#' kg_plot_color(color = c("gray"), showcode = FALSE)
kg_plot_color <- function(name = "Sapporo_Sta", color = NULL, n = 5, showcode = TRUE) {

  if (is.null(color)) {

    if(name %in% names(df_KG_palettes)){

      coldata <- setNames(data.frame(df_KG_palettes[[name]]), name)

    }else{

      stop("Palette not found.")

    }

  }else{

    coldata <- color

  }

  cxlist <- convert_colTodf(coldata)

  image_add_textAcode(cxlist$coldata, cxlist$xlab, cxlist$ylab,
                      cxlist$get_colpalnames, showcode = TRUE)

}

#' Add to image() command text and color code
#'
#' \code{image_add_textAcode} This function add to image() command text and color code.
#' @importFrom grDevices colorRampPalette rgb
#' @importFrom graphics image rect text axis
#' @importFrom stats setNames
#'
#' @param coldata Color data. Only for matrix class.
#' @param xlab x axis label.
#' @param ylab x axis label.
#' @param colornames Color name.
#' @param showcode Add a color code to the plot.
#'
#' @return Display hex color code and color on console.
#' @export
#' @examples
#' image_add_textAcode(coldata = t(as.matrix(c("red", "#ff48ac"))),
#'                     colornames = "color", showcode = TRUE)
image_add_textAcode <- function(coldata, xlab = NULL, ylab = NULL,
                                colornames = "color", showcode = TRUE) {


  image(x = seq_len(ncol(coldata)), y = seq_len(nrow(coldata)),
        z = t(matrix(data = seq_len(ncol(coldata)*nrow(coldata)),
                     nrow = nrow(coldata), ncol = ncol(coldata))),
        col = as.character(coldata), xlab = "", ylab = "",
        xaxt = "n", yaxt = "n", bty = "n")

  if (nrow(coldata) < 2) {

    rect(xleft = 0, ybottom = 0.9, xright = ncol(coldata) + 1, ytop = 1.1,
         col = rgb(1, 1, 1, 0.8), border = NA)

    if (length(colornames) == 1){

      x_range <- (ncol(coldata) + 1)/2

    }else{

      x_range <- seq_len(ncol(coldata))

    }

    text(labels = colornames, x = x_range, y = 1, cex = 2)

    if (showcode) {

      rect(xleft = 0, ybottom = 0.6, xright = ncol(coldata) + 1, ytop = 0.65,
           col = rgb(1, 1, 1, 0.8), border = NA)
      text(labels = as.character(coldata), x = seq_len(ncol(coldata)), y = 0.625, cex = 1)

    }

    return(kg_show_console(as.character(coldata)))

  }else{

    axis(side = 3, at = seq(1, 2, length = length(xlab)), lwd = 0,
         labels = xlab)
    axis(side = 2, at = seq(1, nrow(coldata), length = length(ylab)), lwd = 0,
         labels = ylab, pos = 0.55, las = 2)

    if (showcode) {

      rect(xleft = 0, ybottom = seq_len(nrow(coldata))-0.15,
           xright = ncol(coldata) + 1, ytop = seq_len(nrow(coldata))+0.15,
           col = rgb(1, 1, 1, 0.8), border = NA)
      text(labels = as.character(coldata),
           x = rep(seq_len(ncol(coldata)), each = nrow(coldata)),
           y = rep(seq_len(nrow(coldata)), time = ncol(coldata)),
           cex = 1)

    }

    return(kg_show_console(as.character(coldata)))

  }
}

#' Convert color data to list class
#'
#' \code{convert_colTodf} This function convert color data to list class.
#' @importFrom stats setNames
#' @param coldata Color data.
#'
#' @return list class containing palette name (or color name),
#'    original color data (data.frame), column name, and row name.
#' @export
#' @examples
#' convert_colTodf(coldata = c("red", "#ff48ac"))
convert_colTodf <- function (coldata) {

  col_data <- coldata
  get_colnames <- NULL
  xlab <- NULL
  ylab <- NULL

  if(is.character(col_data)) {

    col_data <- setNames(data.frame(col_data), "color")

    }

  if(ncol(col_data) < 2 | nrow(col_data) < 2) {

    get_colpalnames <- colnames(col_data)

    if(nrow(col_data) == 1) {

      col_data <- as.matrix(col_data)

      }else{

      col_data <- t(as.matrix(col_data))

      }

    }else{

      get_colpalnames <- colnames(col_data)
      col_data <- as.matrix(col_data)[nrow(col_data):1, ]
      xlab <- colnames(col_data)
      ylab <- rownames(col_data)

    }

  return(list(get_colpalnames = get_colpalnames,
              coldata = col_data, xlab = xlab, ylab = ylab))

  }
