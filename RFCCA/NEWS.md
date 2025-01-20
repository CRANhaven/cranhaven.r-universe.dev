## RFCCA 2.0.0
* Internal lapacke.h and cblas.h files are removed. Instead, LAPACK and BLAS libraries are used.

## RFCCA 1.0.12
* Fixed warning: format string is not a string literal.

## RFCCA 1.0.11
* Copyright information for LAPACK and BLAS libraries are added to the DESCRIPTION file.

## RFCCA 1.0.10
* Fixed function declaration without a prototype.
* Fixed sprintf calls per Prof. Ripley.

## RFCCA 1.0.9
* Fixed the 'length > 1 in coercion to logical' errors.
* Fixed Fortran calls for BLAS functions.

## RFCCA 1.0.7
* Added CITATION file.
* Updated paper reference information in package description and vignette.
* Added X and Y mean-centering options as arguments to rfcca() and globalsignificance().

## RFCCA 1.0.6
Fixed the omp.h declaration before R headers per Prof. Ripley, in anticipation of clang 13.0.0.

## RFCCA 1.0.4
* Added 'samptype' and 'sampsize' arguments to rfcca() function.
* Fixed the displaying with 'ndisp' argument in plot.vimp.rfcca() function.

## RFCCA 1.0.3
* Fixed the BOP construction for test observations.
* Updated README file.
* Added NEWS file.

## RFCCA 1.0.2
This is the first CRAN release of the `RFCCA` package.
