
<!-- README.md is generated form README.Rmd. Please edit that file -->

# zerotradeflow

<!-- badges: start -->

[![build](https://github.com/AlexandreLoures/zerotradeflow/actions/workflows/main.yml/badge.svg)](https://github.com/AlexandreLoures/zerotradeflow/actions)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/zerotradeflows)](https://cran.r-project.org/package=zerotradeflow)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![License:
Mit](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Github
commit](https://img.shields.io/github/last-commit/AlexandreLoures/zerotradeflow)](https://github.com/AlexandreLoures/zerotradeflow/commit/main)
[![](https://cranlogs.r-pkg.org/badges/grand-total/zerotradeflow?color=blue)](https://cran.r-project.org/package=zerotradeflow)
<!-- badges: end -->

`zerotradeflow` is a system for creating the bilateral trade flow
between a country pair equal to zero. You provide the data, tell
`zerotradeflow` which variables are of interest and it expands the base
by creating the bilateral zero trade flow. The bases on the flow of
trade between countries only report positive trade (greater than zero),
however, for some analyzes of gravitacional models, data on zero flow is
also necessary.

# Installation

To install the `package`, one of the two standard methods for installing
`packages` in R can be adopted. Directly through the
[cran](https://cran.r-project.org/package=zerotradeflow) (choosing the
closest repository):

``` r
install.packages ("zerotradeflow")
```

Or the development version from GitHub:

``` r
# install.packages ("devtools")
devtools::install_github ("AlexandreLoures/zerotradeflow")
```

In the latter case, the latest version of the `package` will be
installed.

# Usage

The operation of the `zerotradeflow` package consists of informing where
the data are (the base) to be expanded and indicating the variables:
year, exporting country, importing country, Harmonized Commodity
Designation and Coding System (or other classification) and value of
exports/imports. It takes into account that the order must be obeyed:
data, year, exporter, importer, designation and coding and flow value.

# An application for Gravitational Models of Trade

<img src="figures/zeros.png" width="100%" />

## Reference

Figueiredo and Loures (2016) **O efeito do Mercosul sobre a
comercialização de novos produtos**.
<a href="https://doi.org/10.5935/0034-7140.20160015"
target="_blank">https://doi.org/10.5935/0034-7140.20160015</a>

<!--
[![](http://cranlogs.r-pkg.org/badges/grand-total/covid19brazil?color=green)](https://cran.r-project.org/package=covid19brazil) 
 
[![](http://cranlogs.r-pkg.org/badges/grand-total/covid19brazil?color=blue)](https://cran.r-project.org/package=covid19brazil)

[![](http://cranlogs.r-pkg.org/badges/last-month/covid19brazil?color=green)](https://cran.r-project.org/package=covid19brazil)

[![](http://cranlogs.r-pkg.org/badges/last-month/covid19brazil?color=blue)](https://cran.r-project.org/package=covid19brazil)

# Installation

[![](http://cranlogs.r-pkg.org/badges/grand-total/covid19italy?color=green)](https://cran.r-project.org/package=covid19italy)

[![](http://cranlogs.r-pkg.org/badges/last-month/covid19italy?color=green)](https://cran.r-project.org/package=covid19italy)
-->
