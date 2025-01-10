## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(readxlsb)

## ----eval = FALSE-------------------------------------------------------------
#  read_xlsb(path, sheet, range, col_names, col_types, na, trim_ws, skip, ...)

## ----eval = TRUE--------------------------------------------------------------
res = read_xlsb(path = system.file("extdata", "TestBook.xlsb", package = "readxlsb"), range = "PORTFOLIO", debug = TRUE)

ls(res$env)

res$env$named_ranges

