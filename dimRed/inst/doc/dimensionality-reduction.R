## ----"pca_isomap_example",include=FALSE,fig.width=4,fig.height=4--------------
if(Sys.getenv("BNET_BUILD_VIGNETTE") != "") {
library(dimRed); library(ggplot2); #library(dplyr); library(tidyr)
## define which methods to apply
embed_methods <- c("Isomap", "PCA")
## load test data set
data_set <- loadDataSet("3D S Curve", n = 1000)
## apply dimensionality reduction
data_emb <- lapply(embed_methods, function(x) embed(data_set, x))
names(data_emb) <- embed_methods
## plot data set, embeddings, and quality analysis
## plot(data_set, type = "3vars")
## lapply(data_emb, plot, type = "2vars")
## plot_R_NX(data_emb)

add_label <- function(label)
grid::grid.text(label, 0.2, 1, hjust = 0, vjust = 1,
gp = grid::gpar(fontface = "bold",
cex = 1.5))
## pdf('~/phd/text/dimRedPackage/plots/plot_example.pdf', width = 4, height = 4)
## plot the results
plot(data_set, type = "3vars", angle = 15, mar = c(3, 3, 0, 0), box = FALSE, grid = FALSE, pch = 16)
add_label("a")
par(mar = c(4, 4, 0, 0) + 0.1, bty = "n", las = 1)
plot(data_emb$Isomap, type = "2vars", pch = 16)
add_label("b")
plot(data_emb$PCA,    type = "2vars", pch = 16)
add_label("d")
## calculate quality scores
print(
plot_R_NX(data_emb) +
theme(legend.title = element_blank(),
legend.position = c(0.5, 0.1),
legend.justification = c(0.5, 0.1))
)
add_label("c")
} else {
# These cannot all be plot(1:10)!!! It's a mistery to me.
plot(1:10)
barplot(1:10)
hist(1:10)
plot(1:10)
}

## ----eval=FALSE---------------------------------------------------------------
#  ## define which methods to apply
#  embed_methods <- c("Isomap", "PCA")
#  ## load test data set
#  data_set <- loadDataSet("3D S Curve", n = 1000)
#  ## apply dimensionality reduction
#  data_emb <- lapply(embed_methods, function(x) embed(data_set, x))
#  names(data_emb) <- embed_methods
#  ## figure \ref{fig:plotexample}a, the data set
#  plot(data_set, type = "3vars")
#  ## figures \ref{fig:plotexample}b (Isomap) and \ref{fig:plotexample}d (PCA)
#  lapply(data_emb, plot, type = "2vars")
#  ## figure \ref{fig:plotexample}c, quality analysis
#  plot_R_NX(data_emb)

## ----include=FALSE------------------------------------------------------------
if(Sys.getenv("BNET_BUILD_VIGNETTE") != "") {
library(dimRed)
library(cccd)
## Load data
ss <- loadDataSet("3D S Curve", n = 500)
## Parameter space
kk <- floor(seq(5, 100, length.out = 40))
## Embedding over parameter space
emb <- lapply(kk, function(x) embed(ss, "Isomap", knn = x))
## Quality over embeddings
qual <- sapply(emb, function(x) quality(x, "Q_local"))
## Find best value for K
ind_max <- which.max(qual)
k_max <- kk[ind_max]

add_label <- function(label){
  par(xpd = TRUE)
  b = par("usr")
  text(b[1], b[4], label, adj = c(0, 1), cex = 1.5, font = 2)
  par(xpd = FALSE)
}

names(qual) <- kk
}

## ----"select_k",include=FALSE,fig.width=11,fig.height=5-----------------------
if(Sys.getenv("BNET_BUILD_VIGNETTE") != "") {
par(mfrow = c(1, 2),
    mar = c(5, 4, 0, 0) + 0.1,
    oma = c(0, 0, 0, 0))
plot(kk, qual, type = "l", xlab = "k", ylab = expression(Q[local]), bty = "n")
abline(v = k_max, col = "red")
add_label("a")
plot(ss, type = "3vars", angle = 15, mar = c(3, 3, 0, 0), box = FALSE, grid = FALSE, pch = 16)
add_label("b")
} else {
plot(1:10)
plot(1:10)
}

## ----"knngraphs",include=FALSE,fig.width=8,fig.height=3-----------------------
if(Sys.getenv("BNET_BUILD_VIGNETTE") != "") {
par(mfrow = c(1, 3),
    mar = c(5, 4, 0, 0) + 0.1,
    oma = c(0, 0, 0, 0))
add_knn_graph <- function(ind) {
    nn1 <- nng(ss@data, k = kk[ind])
    el <- get.edgelist(nn1)
    segments(x0 = emb[[ind]]@data@data[el[, 1], 1],
             y0 = emb[[ind]]@data@data[el[, 1], 2],
             x1 = emb[[ind]]@data@data[el[, 2], 1],
             y1 = emb[[ind]]@data@data[el[, 2], 2],
             col = "#00000010")
}
plot(emb[[2]]@data@data, type = "n", bty = "n")
add_knn_graph(2)
points(emb[[2]]@data@data, col = dimRed:::colorize(ss@meta),
       pch = 16)
add_label("c")
plot(emb[[ind_max]]@data@data, type = "n", bty = "n")
add_knn_graph(ind_max)
points(emb[[ind_max]]@data@data, col = dimRed:::colorize(ss@meta),
       pch = 16)
add_label("d")
plot(emb[[length(emb)]]@data@data, type = "n", bty = "n")
add_knn_graph(length(emb))
points(emb[[length(emb)]]@data@data, col = dimRed:::colorize(ss@meta),
       pch = 16)
add_label("e")
} else {
plot(1:10)
plot(1:10)
plot(1:10)
}

## ----eval=FALSE---------------------------------------------------------------
#  ## Load data
#  ss <- loadDataSet("3D S Curve", n = 500)
#  ## Parameter space
#  kk <- floor(seq(5, 100, length.out = 40))
#  ## Embedding over parameter space
#  emb <- lapply(kk, function(x) embed(ss, "Isomap", knn = x))
#  ## Quality over embeddings
#  qual <- sapply(emb, function(x) quality(x, "Q_local"))
#  ## Find best value for K
#  ind_max <- which.max(qual)
#  k_max <- kk[ind_max]

## ----"plot_quality",include=FALSE---------------------------------------------
if(Sys.getenv("BNET_BUILD_VIGNETTE") != "") {
embed_methods <- dimRedMethodList()
quality_methods <- c("Q_local", "Q_global", "AUC_lnK_R_NX",
                     "cophenetic_correlation")
iris_data <- loadDataSet("Iris")
quality_results <- matrix(
    NA, length(embed_methods), length(quality_methods),
    dimnames = list(embed_methods, quality_methods)
)
embedded_data <- list()

for (e in embed_methods) {
  try(embedded_data[[e]] <- embed(iris_data, e))
  for (q in quality_methods)
    try(quality_results[e,q] <- quality(embedded_data[[e]], q))
}

quality_results <- quality_results[order(rowMeans(quality_results)), ]

palette(c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e"))
col_hsv <- rgb2hsv(col2rgb(palette()))
## col_hsv["v", ] <- col_hsv["v", ] * 3 / 1
palette(hsv(col_hsv["h",], col_hsv["s",], col_hsv["v",]))
par(mar = c(2, 8, 0, 0) + 0.1)
barplot(t(quality_results), beside = TRUE, col = 1:4,
        legend.text = quality_methods, horiz = TRUE, las = 1,
        cex.names = 0.85,
        args.legend = list(x = "topleft", bg = "white", cex = 0.8))
} else {
plot(1:10)
}

## ----eval=FALSE---------------------------------------------------------------
#  embed_methods <- dimRedMethodList()
#  quality_methods <- c("Q_local", "Q_global", "AUC_lnK_R_NX",
#                       "cophenetic_correlation")
#  scurve <- loadDataSet("3D S Curve", n = 2000)
#  quality_results <- matrix(
#    NA, length(embed_methods), length(quality_methods),
#    dimnames = list(embed_methods, quality_methods)
#  )
#  
#  embedded_data <- list()
#  for (e in embed_methods) {
#  embedded_data[[e]] <- embed(scurve, e)
#  for (q in quality_methods)
#    try(quality_results[e, q] <- quality(embedded_data[[e]], q))
#  }

