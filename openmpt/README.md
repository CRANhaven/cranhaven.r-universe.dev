
# openmpt

<!-- badges: start -->

[![R-CMD-check](https://github.com/pepijn-devries/openmpt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pepijn-devries/openmpt/actions/workflows/R-CMD-check.yaml)
[![openmpt status
badge](https://pepijn-devries.r-universe.dev/badges/openmpt)](https://pepijn-devries.r-universe.dev/openmpt)
<!--[![version](https://www.r-pkg.org/badges/version/openmpt)](https://CRAN.R-project.org/package=openmpt)-->
<!--![cranlogs](https://cranlogs.r-pkg.org/badges/openmpt)-->
[![codecov](https://codecov.io/gh/pepijn-devries/openmpt/graph/badge.svg?token=HAV50SM4TF)](https://app.codecov.io/gh/pepijn-devries/openmpt)
<!-- badges: end -->

<img src="man/figures/logo.svg" align="right" height="139" copyright="cc-sa" alt="logo" class="pkgdown-hide" />

A [libopenmpt](https://lib.openmpt.org/) port for `R`. It reads, plays
and converts [Open ModPlug](https://openmpt.org) Tracker music. It
supports a wide range of music [file
formats](https://wiki.openmpt.org/Manual:_Module_formats).

## Installation

Install latest developmental version from R-Universe:

``` r
install.packages("openmpt", repos = c('https://pepijn-devries.r-universe.dev', 'https://cloud.r-project.org'))
```

On Debian/Ubuntu you need to install the developer version of libopenmpt
and portaudio first:

``` sh
sudo apt-get install libopenmpt-dev portaudio19-dev
```

And on Fedora you need:

``` sh
sudo dnf install libopenmpt-devel portaudio-devel
```

On RHEL/CentOS/RockyLinux you first need to enable EPEL:

``` sh
yum install -y epel-release
sudo yum install libopenmpt-dev portaudio19-dev
```

## Example

You only need 3 lines of code to load the library, read a module and
play it:

``` r
library(openmpt)

mod <- read_mod(system.file("cyberrid", "cyberrid.mod", package = "openmpt"))

play(mod)
```

## Code of Conduct

Please note that the openmpt project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
