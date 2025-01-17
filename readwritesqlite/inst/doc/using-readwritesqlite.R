## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(readwritesqlite)
conn <- rws_connect(":memory:")

## -----------------------------------------------------------------------------
rws_write(rws_data, exists = FALSE, conn = conn)
rws_list_tables(conn)

## -----------------------------------------------------------------------------
a_table <- rws_data[c("date", "logical")]
another_table <- rws_data[c("factor", "ordered")]
not_a_table <- 1
rws_write(environment(), exists = FALSE, all = FALSE, conn = conn)
rws_list_tables(conn)

## -----------------------------------------------------------------------------
tables <- rws_read(conn)
names(tables)
tables$rws_data

## ---- eval=FALSE--------------------------------------------------------------
#  names(tables) <- toupper(names(tables))
#  list2env(tables, environment())

## -----------------------------------------------------------------------------
rws_read_table("rws_data", conn = conn)

## -----------------------------------------------------------------------------
rws_read_meta(conn)

## -----------------------------------------------------------------------------
rws_disconnect(conn)

