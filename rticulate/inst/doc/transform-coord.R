## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  out.width = "300px", fig.align = "center", dpi = 300
)
library(dplyr)
library(ggplot2)
theme_set(theme_bw())
library(rticulate)

## ----load-data----------------------------------------------------------------
library(rticulate)
data(tongue)
tongue

## -----------------------------------------------------------------------------
polar <- tongue %>%
    filter(speaker == "it01") %>%
    transform_coord()

## -----------------------------------------------------------------------------
polar %>%
    ggplot(aes(angle, radius, colour = c2_place)) +
    geom_point() +
    scale_colour_discrete(name = "Place of C2") +
    theme(legend.position = "top")

## -----------------------------------------------------------------------------
polar %>%
    ggplot(aes(angle, radius, colour = c2_place)) +
    geom_point(alpha = 0.5) +
    scale_colour_discrete(name = "Place of C2") +
    coord_polar(start = pi) +
    xlim(min(polar$angle) - pi / 2, max(polar$angle) + pi / 2) +
    ylim(0, max(polar$radius)) +
    theme_void() +
    theme(legend.position = "top")

