## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width=7, fig.height=5
)
library(dplyr)
library(ggplot2)
theme_set(theme_bw())
library(rticulate)

## ----load-data----------------------------------------------------------------
library(rticulate)
data(tongue)
tongue

## ----polar-place--------------------------------------------------------------
tongue_it05 <- filter(tongue, speaker == "it05", vowel == "a", fan_line < 38) %>% droplevels()

polar_place <- polar_gam(
  Y ~
    s(X, by = c2_place),
  data = tongue_it05
)
summary(polar_place)

## ----plot-smooths-------------------------------------------------------------
plot_polar_smooths(
  polar_place,
  X,
  c2_place
) +
  theme(legend.position = "top")

## ----polar-multi--------------------------------------------------------------
tongue_it05 <- filter(tongue, speaker == "it05", fan_line < 38) %>% droplevels()

polar_multi <- polar_gam(
  Y ~
    s(X, by = c2_place) +
    s(X, by = vowel),
  data = tongue_it05
)
summary(polar_multi)

## ----plot-smooths-2-----------------------------------------------------------
plot_polar_smooths(
  polar_multi,
  X,
  c2_place,
  facet_terms = vowel
) +
  theme(legend.position = "top")

## ----polar-place-2------------------------------------------------------------
polar_2 <- polar_gam(
  Y ~
    s(X) +
    s(X, by = c2_place) +
    s(TR_abs_velocity, k = 6) +
    ti(X, TR_abs_velocity, k = c(9, 6)) +
    s(X, word, bs = "fs"),
  data = tongue_it05
)
summary(polar_2)

## ----place-pred---------------------------------------------------------------
polar_pred <- predict_polar_gam(
  polar_2,
  values = list(TR_abs_velocity = seq(2, 24, 5)),
  exclude_terms = "s(X,word)"
) %>%
  filter(word == "paca") # filter data by choosing any value for word

polar_pred

## ----place-pred-plot, fig.width=7, fig.height=5-------------------------------
polar_pred %>%
  ggplot(aes(X, Y, colour = as.factor(TR_abs_velocity), linetype = as.factor(TR_abs_velocity))) +
  geom_path() +
  facet_grid(c2_place ~ .)

## ----ci-data------------------------------------------------------------------
polar_multi_p <- predict_polar_gam(
  polar_multi
)

ci_data <- predict_polar_gam(
  polar_multi,
  return_ci = TRUE,
)

## ----place-pred-ci------------------------------------------------------------
polar_multi_p %>%
  ggplot(aes(X, Y)) +
  geom_polygon(data = ci_data, aes(CI_X, CI_Y, group = c2_place), alpha = 0.1) +
  geom_path(aes(colour = c2_place)) +
  facet_grid(. ~ vowel) +
  theme(legend.position = "top")

