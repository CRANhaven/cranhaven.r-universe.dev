
install_EBImage <- function(){
  #The EBImage package is indispensable for ExpImage to function. Since this package is not available on CRAN, this function installs it automatically; otherwise, cran-check will not work.
  if(!requireNamespace("EBImage", quietly = TRUE)) {

    if(!requireNamespace("BiocManager", quietly = TRUE)) {
      install.packages("BiocManager", quiet = TRUE)
    }
    BiocManager::install("EBImage",
                         update = FALSE,
                         ask = FALSE,
                         quiet = TRUE)
  }
  #require(raster)
}
