## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE---------------------------------------------------------------
#  library(databraryr)

## ----get_party_by_id----------------------------------------------------------
# The default parameter settings return a very detailed set of information about 
# a party that we do not need for this example.
party_6 <- databraryr::get_party_by_id(parents_children_access = FALSE)

party_6 |>
  as.data.frame()

## ----list-people-5-7----------------------------------------------------------
# Helper function
get_party_as_df <- function(party_id) {
  this_party <- databraryr::get_party_by_id(party_id, 
                                            parents_children_access = FALSE)
  if (!is.null(this_party)) {
    as.data.frame(this_party)
  } else {
    NULL
  }
}

# Party's 5, 6, and 7 are Databrary's founders
purrr::map(5:7, get_party_as_df, .progress = TRUE) |>
  purrr::list_rbind()

## ----get-db-stats-------------------------------------------------------------
databraryr::get_db_stats("stats")
databraryr::get_db_stats("people")
databraryr::get_db_stats("institutions")
databraryr::get_db_stats("datasets")

