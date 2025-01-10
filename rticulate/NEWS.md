# rticulate v1.7.4

* Fix CRAN note about language field.


# rticulate v1.7.3

## Added

* Zenodo DOI in Readme, plus other Readme updates.

## Developer

* Fix CRAN notes about HTML5.


# rticulate v1.7.2

## Added

* 📝 - @return filled in the documentation of functions.

## Changed

* 📝 - Use `\donttest` instead of `\dontrun`.




# rticulate v1.7.0

## Added

* rticulate logo!

* Use GitHub Actions for R CMD check.

## Changed

* use `tidy::pivot_longer()` and `tidy::pivot_wider()` in `read_aaa_data()`

* add `.index` column to `read_aaa_data()` output to group contours if needed.

* changed index name of `polar-gams.Rmd` vignette.

* Now uses `README.Rmd`.

## Removed

* Remove Travis CI (use GitHub Actions).



# rticulate v1.6.0

## Changed

* expand documentation of `transform_coordinates()` and `get_origin()`

* better handling of fit errors in `get_origin()`

## Deprecated

* `geom_polar_ci()`, see vignette "polar-gam" for a working alternative

# rticulate v1.5.0

## Added

* examples for `predict_polar_gam()` and plotting

## Changed

* extend `polar-gam.Rmd`

## Deprecated

* ⚠️ `time_series` is now deprecated and replaced with `series`. `time_series` will be removed in future releases.

# rticulate v1.4.0

## Added

* examples in docs

* section in `polar-gams.Rmd` about multiple predictors

* function `predict_polar_gam()`

* geom `geom_polar_ci()`

# rticulate v1.3.5

## Changed

* README now uses new `install_github` argument for building vignettes

# rticulate v1.3.4

## Added

* support for NULL comparison argument in `plot_polar_smooths()`

## Fixed

* error after `rlang` update

# rticulate v1.3.3

## Added

* `split` argument for splitting factor interactions into separate factors

# rticulate v1.3.2

## Added

* argument in `read_aaa()` for choosing format (wide or long)

## Changed

* removed `tidymv` version from README

## Fixed

* polar GAMs vignette title

* error in Polar GAMs vignette

* error when using `AR.start`

# rticulate v1.3.1

## Fixed

* fix several bugs

* fix issue #1

# rticulate v1.3.0

## Added

* functions for transforming coordinates

* vignette about coordinates transformation

* polar gams

## Changed

* dropped levels in `tongue` data set

* use underscores in names everywhere

# rticulate v1.2.0

## Added

* argument in `read_aaa` to choose coordinate system

* `read_aaa_data` for internal use

* `it02` data

* example in vignette for multiple import

* added `point` and `path` options to `plot_tongue`

## Changed

* updates to `NEWS.md`

* clarified documentation

* `read_aaa` can now accept a list of files

* column `fan` now properly named `fan.line`

* data names

* renamed `plot_splines` to `plot_tongue`

## Fixed

* name of package in documentation

* name of vignette

* title in README

# rticulate v1.0.1

## Added

* depends and imports in DESCRIPTION

* globalVariables for data frame variables in functions

* NEWS.md

## Fixed

* data documentation (wrong variable names)

* missing parameter in `plot_splines`

* missing `stats::` in `read_aaa`

* `aes` call which caused notes on R CMD check using `aes_`
