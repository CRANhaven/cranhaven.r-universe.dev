## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(ecdata)


## ----load-full-ecd, eval = FALSE----------------------------------------------
# 
# full_ecd = load_ecd(full_ecd = TRUE)
# 
# 
# 

## ----country-example, eval = FALSE--------------------------------------------
# 
# load_ecd(country = 'Greece')
# 

## ----lang-example, eval=FALSE-------------------------------------------------
# 
# english = load_ecd(language = 'English')
# 
# polyglot = load_ecd(language = c('French', 'Italian', 'Korean'))
# 

## -----------------------------------------------------------------------------

ecd_country_dictionary |>
  head()

## ----eval = FALSE-------------------------------------------------------------
# 
# nigeria = lazy_load_ecd(country = 'Nigeria')
# 
# 
# 

## ----eval = FALSE-------------------------------------------------------------
# 
# nigeria |>
#   dplyr::collect()
# 

## ----eval = FALSE-------------------------------------------------------------
# 
# clear_cache()
# 

