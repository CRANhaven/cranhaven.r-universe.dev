## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(databraryr)

## ----make_default_request, eval=FALSE-----------------------------------------
#  drq <- make_default_request()

## ----login, eval=FALSE--------------------------------------------------------
#  databraryr::login_db(email = "<YOUR_EMAIL@PROVIDER.COM>", rq = drq)

## ----login-w-env-var, eval=FALSE----------------------------------------------
#  databraryr::login_db(email = Sys.getenv("DATABRARY_LOGIN"), rq = drq)

## ----eval=FALSE---------------------------------------------------------------
#  databraryr::login_db(email = "<YOUR_EMAIL@PROVIDER.COM>", store = TRUE,
#                       overwrite = TRUE, rq = drq)

## ----eval=FALSE---------------------------------------------------------------
#  databraryr::login_db(email = "<YOUR_EMAIL@PROVIDER.COM>", store = TRUE, rq = drq)

## ----eval=FALSE---------------------------------------------------------------
#  databraryr::login_db(email = Sys.getenv("DATABRARY_LOGIN"), store = TRUE, rq = drq)

## ----eval=FALSE---------------------------------------------------------------
#  databraryr::logout_db(rq = drq)

