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

## ----gam----------------------------------------------------------------------
set.seed(10)
data <- gamSim(4)
model <- gam(
  y ~
    fac +
    s(x2) +
    s(x2, by = fac) +
    s(x0),
  data = data
)

## ----plot-gam-----------------------------------------------------------------
plot_smooths(
  model = model,
  series = x2,
  comparison = fac
) +
  theme(legend.position = "top")

## ----pois-gam-----------------------------------------------------------------
data("pois_df")
pois_gam <- gam(y ~ s(x, by = fac), data = pois_df, family = poisson)

## ----plot-pois-gam------------------------------------------------------------
plot_smooths(pois_gam, x, fac, transform = exp, series_length = 70) +
  theme(legend.position = "top")

## ----gam-2--------------------------------------------------------------------
model_2 <- gam(
  y ~
    s(x0) +
    s(x2),
  data = data
)

plot_smooths(
  model = model_2,
  series = x0
)

## ----interaction-data---------------------------------------------------------
data("inter_df")
inter_df <- inter_df %>%
  mutate(
    x1x2 = interaction(x1, x2)
  )

model_inter <- bam(
  y ~
    x1x2 +
    s(x0, k = 8, by = x1x2),
  data = inter_df
)

## ----plot-interactions--------------------------------------------------------
plot_smooths(
  model = model_inter,
  series = x0,
  comparison = x1,
  facet_terms = x2,
  split = list(x1x2 = c("x1", "x2"))
) +
  theme(legend.position = "top")

## ----plot-interactions-2------------------------------------------------------
plot_smooths(
  model = model_inter,
  series = x0,
  comparison = x1,
  facet_terms = x2,
  conditions = quos(x2 == "b"),
  split = list(x1x2 = c("x1", "x2"))
) +
  theme(legend.position = "top")

## ----plot-interactions-3------------------------------------------------------
plot_smooths(
  model = model_inter,
  series = x0,
  comparison = x1,
  facet_terms = x2,
  conditions = quos(x1 %in% c(1, 3)),
  split = list(x1x2 = c("x1", "x2"))
) +
  theme(legend.position = "top")

## ----get-gam-pred-------------------------------------------------------------
preds <- get_gam_predictions(model_inter, x0, split = list(x1x2 = c("x1", "x2")))

preds %>%
  ggplot(aes(x0, y)) +
  geom_ribbon(aes(ymin = CI_lower, ymax = CI_upper, fill = x1, group = .idx), alpha = 0.3) +
  geom_line(aes(colour = x1, linetype = x2))

## ----plot-diff-model----------------------------------------------------------
plot_difference(
  pois_gam,
  series = x,
  difference = list(fac = c("b", "a"))
)

## ----plot-diff-inter-1--------------------------------------------------------
plot_difference(
  model_inter,
  x0,
  difference = list(x1x2 = c("2.a", "3.a"))
)

## ----plot-diff-inter-3--------------------------------------------------------
plot_difference(
  model_inter,
  x0,
  difference = list(x1x2 = c("1.b", "2.b"))
)

## ----get-smooths-diff---------------------------------------------------------
inter_diff <- get_smooths_difference(model_inter, x0, list(x1x2 = c("2.a", "3.a")))

inter_diff %>%
  ggplot(aes(x0, difference, group = group)) +
  geom_hline(aes(yintercept = 0), colour = "#8f5f3f") +
  geom_ribbon(aes(ymin = CI_lower, ymax = CI_upper, fill = sig_diff), alpha = 0.3) +
  geom_line(aes(colour = sig_diff), size = 1) +
  scale_colour_manual(values = c("#e35760", "#6f849c")) +
  scale_fill_manual(values = c("#e35760", "#6f849c")) +
  labs(colour = "significant", fill = "significant") +
  theme(legend.position = "top")

## ----diff-gam-----------------------------------------------------------------
set.seed(10)
data <- gamSim(4)
fac_gam <- gam(y ~ fac + s(x2) + s(x2, by = fac) + s(x0), data = data)

## ----diff-gam-plot------------------------------------------------------------
fac_diff <- get_smooths_difference(model, x2, list(fac = c("1", "2")))

fac_diff %>%
  ggplot(aes(x2, difference)) +
  geom_hline(aes(yintercept = 0)) +
  geom_ribbon(aes(ymin = -Inf, ymax = Inf, fill = sig_diff, group = group), alpha = 0.2) +
  geom_ribbon(aes(ymin = CI_lower, ymax = CI_upper), alpha = 0.3) +
  geom_line(size = 1) +
  labs(colour = "significant", fill = "significant") +
  theme(legend.position = "top")

