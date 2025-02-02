# complex package for R
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/complex)](https://cran.r-project.org/package=complex)
[![Downloads](https://cranlogs.r-pkg.org/badges/complex)](https://cran.r-project.org/package=complex)
[![R-CMD-check](https://github.com/config-i1/complex/actions/workflows/test.yml/badge.svg)](https://github.com/config-i1/complex/actions/workflows/test.yml)
[![ko-fi](https://ivan.svetunkov.ru/ko-fi.png)](https://ko-fi.com/G2G51C4C4)

Time series analysis and forecasting using complex variables

![hex-sticker of the complex package for R](https://github.com/config-i1/complex/blob/master/man/figures/complex-web.png?raw=true)

The package includes basic instruments for correlation and regression analysis of complex-valued variables. The package supports the monograph by Svetunkov & Svetunkov "Complex-valued Econometrics with Examples in R", which is to be published by Springer in 2024.


### Installation
Stable version can be installed from CRAN:
```r
install.packages("complex")
```

For installation from github use the remotes package:
```r
if (!require("remotes")){install.packages("remotes")}
remotes::install_github("config-i1/complex")
```
