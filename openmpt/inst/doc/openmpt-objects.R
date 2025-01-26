## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----initiate-----------------------------------------------------------------
library(openmpt)
mod <- read_mod(system.file("cyberrid", "cyberrid.mod", package = "openmpt"))

