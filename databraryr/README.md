
<!-- README.md is generated from README.Rmd. Please edit that file -->

# databraryr <a href="https://databrary.github.io/databraryr/"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/databraryr)](https://CRAN.R-project.org/package=databraryr)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/databrary/databraryr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/databrary/databraryr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

databraryr is a wrapper for the [Databrary](https://databrary.org) data
library’s application programming interface (API). The package can be
used to create reproducible data wrangling, analysis, and visualization
pipelines from data stored and shared on Databrary.

## Installation

``` r
# The easiest way to install databraryr is from CRAN
install.packages("databraryr")

# The development release can be installed from GitHub
install.packages("pak")
pak::pak("databrary/databraryr")
```

## Usage

Databrary ([databrary.org](https://databrary.org)) is a
restricted-access research data library specialized for storing and
sharing video with capabilities of storing [other
types](https://nyu.databrary.org/asset/formats/) of associated data.
Access to restricted data requires registration and formal approval by
an institution. The registration process involves the creation of an
(email-account-based) user account and secure password. Once
institutional authorization has been granted, a user may gain access to
shared video, audio, and other data. See
<https://databrary.org/about.html> for more information about gaining
access to restricted data.

However, many commands in the `databraryr` package return meaningful
results *without* or *prior to* formal authorization. These commands
access public data or metadata.

``` r
library(databraryr)
#> Welcome to the databraryr package.

get_db_stats()
#> # A tibble: 1 × 9
#>   date                investigators affiliates institutions datasets_total
#>   <dttm>                      <int>      <int>        <int>          <int>
#> 1 2024-03-29 14:38:54          1740        680          784           1670
#> # ℹ 4 more variables: datasets_shared <int>, n_files <int>, hours <dbl>,
#> #   TB <dbl>

list_volume_assets() |> 
  head()
#>   asset_id asset_format_id asset_duration                 asset_name
#> 1     9826            -800         335883               Introduction
#> 2     9830            -800        4277835         Databrary 1.0 plan
#> 3     9832            -800        3107147                    Datavyu
#> 4    22412               6             NA                     Slides
#> 5     9828            -800        4425483             Databrary demo
#> 6     9834            -800        4964011 Overview and Policy Update
#>   asset_permission asset_size session_id session_date session_release
#> 1                1   88610655       6256   2013-10-28               3
#> 2                1  899912341       6256   2013-10-28               3
#> 3                1  764340542       6256   2013-10-28               3
#> 4                1    4573426       6256   2013-10-28               3
#> 5                1  917124852       6256   2013-10-28               3
#> 6                1 1301079971       6257   2014-04-07               3
#>   format_mimetype format_extension       format_name
#> 1       video/mp4              mp4      MPEG-4 video
#> 2       video/mp4              mp4      MPEG-4 video
#> 3       video/mp4              mp4      MPEG-4 video
#> 4 application/pdf              pdf Portable document
#> 5       video/mp4              mp4      MPEG-4 video
#> 6       video/mp4              mp4      MPEG-4 video
```

## Lifecycle

Rick Gilmore has been using experimental versions of databraryr for many
years, but the package was only released to CRAN in the fall of 2023.
Some new features are on the roadmap, but the package is largely stable.
