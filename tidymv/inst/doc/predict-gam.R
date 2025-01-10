## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  out.width = "300px", fig.align = "center", dpi = 300
)
library(ggplot2)
theme_set(theme_bw())
library(dplyr)
library(mgcv)
library(tidymv)

## ----load, eval=FALSE---------------------------------------------------------
#  library(ggplot2)
#  theme_set(theme_bw())
#  library(dplyr)
#  library(mgcv)
#  library(tidymv)

## ----model--------------------------------------------------------------------
library(mgcv)
set.seed(10)
data <- gamSim(4, 400)

model <- gam(
  y ~
    fac +
    s(x2, by = fac),
  data = data
)

summary(model)

## ----model-p------------------------------------------------------------------
model_p <- predict_gam(model)
model_p

## ----model-plot---------------------------------------------------------------
model_p %>%
  ggplot(aes(x2, fit)) +
  geom_smooth_ci(fac)

## ----model-2------------------------------------------------------------------
model_2 <- gam(
  y ~
    s(x2) +
    s(f1) +
    ti(x2, f1),
  data = data
)

summary(model_2)

## ----model-2-p----------------------------------------------------------------
model_2_p <- predict_gam(model_2)
model_2_p

## ----model-2-plot-------------------------------------------------------------
model_2_p %>%
  ggplot(aes(x2, f1, z = fit)) +
  geom_raster(aes(fill = fit)) +
  geom_contour(colour = "white") +
  scale_fill_continuous(name = "y") +
  theme_minimal() +
  theme(legend.position = "top")

## ----model-2-values-----------------------------------------------------------
predict_gam(model_2, values = list(f1 = c(0.5, 1, 1.5))) %>%
  ggplot(aes(x2, fit)) +
  geom_smooth_ci(f1)

## ----model-3------------------------------------------------------------------
data_re <- data %>%
  mutate(rand = rep(letters[1:4], each = 100), rand = as.factor(rand))

model_3 <- gam(
  y ~
    s(x2) +
    s(x2, rand, bs = "fs", m = 1),
  data = data_re
)

summary(model_3)

## ----model-3-plot-------------------------------------------------------------
predict_gam(model_3, exclude_terms = "s(x2,rand)") %>%
  filter(rand == "a") %>%
  ggplot(aes(x2, fit)) +
  geom_smooth_ci()

## ----model-3-plot-2-----------------------------------------------------------
predict_gam(model_3, exclude_terms = "s(x2,rand)", values = list(rand = NULL)) %>%
  ggplot(aes(x2, fit)) +
  geom_smooth_ci()

## ----model-3-rand-------------------------------------------------------------
predict_gam(model_3) %>%
  ggplot(aes(x2, fit)) +
  geom_smooth_ci() +
  facet_wrap(~rand)

