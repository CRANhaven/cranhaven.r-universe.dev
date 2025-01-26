seriditdiff <- function(g1, g2) {
  sqrt(sum(g1) + sum(g2)) / (2 * sqrt(3 * sum(g1) * sum(g2)))
}