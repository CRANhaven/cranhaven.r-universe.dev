## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----modarchive-download------------------------------------------------------
library(openmpt)

unreal <- modarchive_download(60395)
unreal

## ----modarchive-info----------------------------------------------------------
if (modarchive_api() != "") {
  info <- modarchive_info(60395)
  info$genretext
}

## ----modarchive-requests------------------------------------------------------
if (modarchive_api() != "")
  modarchive_requests()

