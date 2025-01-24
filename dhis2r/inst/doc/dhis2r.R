## ----include = FALSE----------------------------------------------------------

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

library(httptest2)
start_vignette("dhis2r")

## ----setup--------------------------------------------------------------------
library(dhis2r)

## -----------------------------------------------------------------------------
dhis2_play_connection <- Dhis2r$new(base_url = "https://play.im.dhis2.org/stable-2-40-5",
                                    username = "admin",
                                    password = "district")

## -----------------------------------------------------------------------------
# [Ways of keeping your user credentials safe](https://solutions.posit.co/connections/db/best-practices/managing-credentials/)
dhis2_play_connection$get_user_info()

## -----------------------------------------------------------------------------
dhis2_play_connection$account_info

## -----------------------------------------------------------------------------
dhis2_play_connection$access_rights

## -----------------------------------------------------------------------------
 dhis2_play_connection$get_metadata()


## -----------------------------------------------------------------------------
dhis2_play_connection$get_metadata(endpoint = "dataElements")


## -----------------------------------------------------------------------------
 dhis2_play_connection$get_metadata_fields(endpoint = "dataElements")


## -----------------------------------------------------------------------------
 dhis2_play_connection$get_metadata_fields(endpoint = "organisationUnits")


## -----------------------------------------------------------------------------
 dhis2_play_connection$get_metadata_fields(endpoint = "indicators")

## -----------------------------------------------------------------------------
 dhis2_play_connection$get_metadata(endpoint = "dataElements", fields = c("name","id","aggregationType"))


## -----------------------------------------------------------------------------
dhis2_play_connection$get_metadata(endpoint = "organisationUnits",
                                                        fields =  c("name","id", "level"))


## -----------------------------------------------------------------------------
dhis2_play_connection$get_metadata(endpoint = "periodTypes", fields = ":all")

## -----------------------------------------------------------------------------
dhis2_play_connection$get_metadata(endpoint = "indicators")

## -----------------------------------------------------------------------------
dhis2_play_connection$get_analytics(analytic = "s46m5MS0hxu",
                                    org_unit = c("O6uvpzGd5pu", "fdc6uOvgoji"),
                                    period = "202101",
                                    output_scheme = "NAME")


## -----------------------------------------------------------------------------
dhis2_play_connection$get_analytics(analytic = "FTRrcoaog83", #Accute Flaccid Paralysis (Deaths < 5 yrs)
                                    org_unit =   c("ImspTQPwCqd"), #Sierra Leone (National level)
                                    period = "LAST_12_MONTHS",
                                    output_scheme = "NAME")


## ----include = FALSE----------------------------------------------------------
end_vignette()

