#
# All the internal functions used for plotting the enrichment network.
#

#'
#' Enrichment network plot
#'
#' @description Plots the enrichment network graph.
#'
#' @param nodes coordinates of all the nodes in the graph and the cluster they belong to
#' @param edges all edges that connect the nodes
#' @param theme object of class \code{aPEAR.theme.config}
#' 
#' @importFrom ggforce geom_link0 geom_mark_ellipse
#' @importFrom ggplot2 geom_point aes theme element_blank element_rect labs coord_fixed scale_color_distiller scale_linewidth_manual
#'
#' @noRd
#'
.plotNodesAndEdges <- function(
  nodes,
  edges,
  theme = aPEAR.theme
) {
  plot <- ggplot2::ggplot()

  if (theme$drawEllipses) {
    # Will hide the warning from ggplot: 'Ignoring unknown aesthetics: linewidth'
    suppressWarnings({
      plot <- plot +
        ggforce::geom_mark_ellipse(data = nodes, ggplot2::aes(x = x, y = y, group = Cluster, linewidth = 'default'), show.legend = FALSE) +
        ggplot2::scale_linewidth_manual(values = c('default' = 0.05))
    }, classes = 'warning')
  }

  plot +
    ggforce::geom_link0(data = edges,
                        ggplot2::aes(x = xStart, y = yStart, xend = xEnd, yend = yEnd),
                        linewidth = 0.25, alpha = 0.2) +
    ggplot2::geom_point(data = nodes,
                        ggplot2::aes(x = x, y = y, color = Color, size = Size)) +
    ggplot2::theme(axis.title.x = ggplot2::element_blank(),
                   axis.text.x = ggplot2::element_blank(),
                   axis.ticks.x = ggplot2::element_blank(),
                   axis.title.y = ggplot2::element_blank(),
                   axis.text.y = ggplot2::element_blank(),
                   axis.ticks.y = ggplot2::element_blank(),
                   panel.grid.major = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   panel.background = ggplot2::element_blank(),
                   legend.position = 'right',
                   legend.key = ggplot2::element_rect(fill = 'white')) +
    ggplot2::labs(color = theme$colorBy, size = 'Pathway size') +
    ggplot2::coord_fixed() +
    geom_cluster_labels(nodes, theme) +
    geom_cluster_colors(nodes, theme) +
    expand_x_axis(nodes) +
    expand_y_axis(nodes)
}


#' 
#' Enrichment network plot
#' 
#' @description Displays a label for each cluster.
#' 
#' @param nodes coordinates of all the nodes in the graph and the cluster they belong to
#' @param theme object of class \code{aPEAR.theme.config}
#' 
#' @importFrom data.table .I .BY ':='
#' @importFrom ggplot2 geom_text aes
#' @importFrom ggrepel geom_text_repel
#' 
#' @return ggplot2 object (either \code{geom_text_repel} or \code{geom_text})
#'
#' @noRd
#' 
geom_cluster_labels <- function(nodes, theme) {
  if (theme$repelLabels) {
    labels <- nodes %>%
      .[ , list(x = mean(x), y = max(y)), by = Cluster ] %>%
      .[ , Label := strwrap(Cluster, width = 20) %>% paste(collapse = '\n'), by = Cluster ]

    return(ggrepel::geom_text_repel(data = labels, ggplot2::aes(x = x, y = y, label = Label), size = theme$fontSize, lineheight = 0.6))
  }

  labels <- nodes %>%
    .[ , list(x = mean(x), y = max(y) + 0.25), by = Cluster ] %>%
    .[ , Label := strwrap(Cluster, width = 20) %>% paste(collapse = '\n'), by = Cluster ]

  return(ggplot2::geom_text(data = labels, ggplot2::aes(x = x, y = y, label = Label), size = theme$fontSize, lineheight = 0.6))
}

#'
#' Enrichment network plot
#'
#' @description Creates color palette for the enrichment network plat based on color type.
#'
#' @param nodes coordinates of all the nodes in the graph and their assigned color
#' @param theme object of class \code{aPEAR.theme.config}
#'
#' @importFrom data.table .I
#' @importFrom ggplot2 scale_color_distiller
#'
#' @noRd
#'
geom_cluster_colors <- function(nodes, theme) {
  if (theme$colorType == 'nes') {
    range <- max(abs(nodes[ , Color ]))
    colors <- ggplot2::scale_color_distiller(limits = c(-range, range), palette = 'Spectral')
  }

  if (theme$colorType == 'pval') {
    colors <- ggplot2::scale_color_distiller(limits = c(theme$pCutoff, 0), direction = -1, palette = 'OrRd')
  }

  return(colors)
}

#' 
#' Enrichment network plot
#' 
#' @description Increases x-axis limits by the percentage specified.
#' 
#' @param nodes coordinates of all the nodes in the graph
#' @param expansion Expansion percentage (default: 0.05)
#' 
#' @importFrom ggplot2 expand_limits
#' @importFrom data.table .I
#' 
#' @noRd
#' 
expand_x_axis <- function(nodes, expansion = 0.075) {
  minX <- nodes[ , min(x) ]
  maxX <- nodes[ , max(x) ]
  width <- maxX - minX
  increase <- width * expansion
  minX <- minX - increase
  maxX <- maxX + increase

  ggplot2::expand_limits(x = c(minX, maxX))
}

#' 
#' Enrichment network plot
#' 
#' @description Increases y-axis limits by the percentage specified.
#' 
#' @param nodes coordinates of all the nodes in the graph
#' @param expansion Expansion percentage (default: 0.05)
#' 
#' @importFrom ggplot2 expand_limits
#' @importFrom data.table .I
#' 
#' @noRd
#' 
expand_y_axis <- function(nodes, expansion = 0.05) {
  minY <- nodes[ , min(y) ]
  maxY <- nodes[ , max(y) ]
  width <- maxY - minY
  increase <- width * expansion
  minY <- minY - increase
  maxY <- maxY + increase

  ggplot2::expand_limits(y = c(minY, maxY))
}
