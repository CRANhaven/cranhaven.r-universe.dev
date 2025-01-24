
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dhis2r <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/amanyiraho/dhis2r/branch/master/graph/badge.svg)](https://app.codecov.io/gh/amanyiraho/dhis2r?branch=master)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/amanyiraho/dhis2r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/amanyiraho/dhis2r/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/dhis2r)](https://CRAN.R-project.org/package=dhis2r)
[![](https://cranlogs.r-pkg.org/badges/grand-total/dhis2r)](https://cranlogs.r-pkg.org/badges/grand-total/dhis2r)
[![](https://cranlogs.r-pkg.org/badges/dhis2r)](https://cran.r-project.org/package=dhis2r)

<!-- badges: end -->

## Overview

`dhis2r` is an R client for the DHIS2 web API.

Pull data from a DHIS2 instance into R without logging into the DHIS2
user interface.

`dhis2r`, if used with Rmarkdown, quarto, Rshiny, etc., can improve
routine reporting and data requests.

### Motivation for this package

[DHIS2](https://dhis2.org/) is an open-source, web-based Health
Management Information System (HMIS), and currently being adopted in the
education sector as the Education Management Information System (EMIS)
in several countries.

More than 73 countries worldwide use DHIS2 for collecting and analyzing
health data. 2.4 billion people (30% of the world’s population) live in
countries where DHIS2 is used. (source: <https://dhis2.org/>)

With the increasing number of data managers/analysts downloading data
from DHIS2 instances to make **routine period** reports, data
visualisation and dashboards, this R package can make it much easier to
pull the required data.

There are over 2 million R users, some of whom periodically analyse data
from DHIS2; and support health programs which affect over the 2.4
billion people.

## Installation

You can install the stable version of dhis2r from CRAN with:

``` r
install.packages("dhis2r")
```

You can install also the development version of dhis2r from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("amanyiraho/dhis2r")
```

## Usage

### How to connect to a DHIS2?

Users must be authenticated to access a specific DHIS2 instance before
connecting to it. You can use

1.  `username` and `password`

2.  Personal Access Token (PAT)

#### 1. Using `username` and `password`

The easiest way to connect to a DHIS2 instance using dhis2r is to use
the `username` and `password` of the DHIS2 user.

``` r
library(dhis2r)
dhis2_play_connection <- Dhis2r$new(base_url = "https://play.im.dhis2.org/stable-2-40-5",
                                    username = "admin",
                                    password = "district")
```

#### 2. Using Personal Access Token (PAT)

Alternatively you can generate a [personal access
token](https://docs.dhis2.org/en/develop/using-the-api/dhis-core-version-master/introduction.html#webapi_pat_authentication)
and use that to connect.

``` r
library(dhis2r)

# Replace the value of api_token with the token you have generated

dhis2_play_connection <- Dhis2r$new(base_url = "https://play.im.dhis2.org/stable-2-40-5",
                                    api_token = "d2pat_2EkxmqdxtwAGDGe1hXzpWEixYdvHGRw71587176066")
```

`Dhis2r$new()` returns a `Dhis2r` R6 class which represents a DHIS2
connection and can be used to query the DHIS2 instance

*No need to log in again when performing other querying tasks.*

### How to pull data from DHIS2

As an example, let’s pull Analytics data of `BCG doses given`

Analytics data can include data from indicators, dataElements, program
indicators, etc.

``` r
 dhis2_play_connection$get_analytics(analytic = "s46m5MS0hxu", #BCG doses given
                                     org_unit = "ImspTQPwCqd", #Sierra Leone (National level)
                                     period = "202101",
                                     output_scheme = "NAME" )
```

You can pull data on the following:

- Information about the account
- Access rights information about the account
- Metadata
- Organisation units
- Analytics
- All possible resources

For more in depth illustration use the vignette `dhis2r`
`vignette("dhis2r")`

Please note that the dhis2r project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
