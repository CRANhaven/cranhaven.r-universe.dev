## ----setup, echo=FALSE, include=FALSE-----------------------------------------
knitr::opts_chunk$set(out.width = "300px", fig.align = "center", dpi = 300)
library(readr)
library(dplyr)
library(stringr)
library(ggplot2)
theme_set(theme_bw())
library(rticulate)

## ----load, eval=FALSE---------------------------------------------------------
# library(rticulate)

## ----columns------------------------------------------------------------------
columns <- c(
    "speaker",
    "seconds",
    "rec_date",
    "prompt",
    "label",
    "TT_displacement",
    "TT_velocity",
    "TT_abs_velocity",
    "TD_displacement",
    "TD_velocity",
    "TD_abs_velocity"
)

## ----read-aaa-----------------------------------------------------------------
# system.file() is needed here because the example files reside in the package.
# You can just include the file path directly in read_aaa, like 
# read_aaa("~/Desktop/splines.tsv", columns)
file_path <- system.file("extdata", "it01.tsv", package = "rticulate")

tongue <- read_aaa(file_path, columns)

## ----tibble-------------------------------------------------------------------
tongue

## ----join---------------------------------------------------------------------
stimuli <- read_csv(system.file("extdata", "stimuli.csv", package = "rticulate"))

tongue <- mutate(tongue, word = word(prompt, 2)) %>%
    left_join(y = stimuli) %>%
    mutate_if(is.character, as.factor)

## ----tibble-2-----------------------------------------------------------------
tongue

## ----plot-splines-------------------------------------------------------------
plot_tongue(tongue)

## ----filter-plot--------------------------------------------------------------
filter(tongue, label == "max_TD") %>%
    plot_tongue()

## ----plot-options-------------------------------------------------------------
plot_tongue(tongue, alpha = 0.5) +
    aes(group = rec_date, colour = c2_place) +
    theme(legend.position = "bottom")

## ----plot-geom----------------------------------------------------------------
plot_tongue(tongue, geom = "point", alpha = 0.5) +
    aes(group = rec_date, colour = c2_place) +
    theme(legend.position = "bottom")

## ----plot-palate--------------------------------------------------------------
palate <- read_aaa(system.file("extdata", "it01-palate.tsv", package = "rticulate"), columns)

filter(tongue, label == "max_TD") %>%
    plot_tongue(palate = palate, alpha = 0.5) + aes(group = rec_date)

## ----read-multiple------------------------------------------------------------
tongue2 <- list.files(
    path = system.file("extdata", package = "rticulate"),
    pattern = "*\\d.tsv",
    full.names = TRUE
    ) %>%
    read_aaa(., columns)

## ----plot-speakers------------------------------------------------------------
plot_tongue(tongue2, alpha = 0.5) +
    aes(group = rec_date) +
    facet_grid(. ~ speaker)

