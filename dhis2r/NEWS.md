# dhis2r 0.3.0

## Improvements

* Updated the package to fail gracefully with an informative message if the resource is not available or has changed and doesn't give a check warning nor error

* Now API calls function print a massage "No internet connection!" if there is no internet connection instead of an error

* The url is of the queried API endpoint is printed using `message()` instead of `print()`

# dhis2r 0.2.1

## Bug fix

* Updated the vignette to use the `username` and `password` instead of `PAT` since the public server is regularly updated 


# dhis2r 0.2.0

## New features

* In `Dhis2r$new()` now includes `api_token = NULL` for authentication via personal access token option(@Brar, #12).

* New `dhis2_connection$get_any_analytic()` to GET long DHIS2 resources.

* Functions now print out the resource link being queried 

## Minor improvements and fixes

* Updated the public server URL in examples and vignettes to "https://play.im.dhis2.org/stable-2-40-5"

# dhis2r 0.1.1

* Fix R CMD check failures on CRAN.

* Added a NEWS.md file to track changes to the package.
