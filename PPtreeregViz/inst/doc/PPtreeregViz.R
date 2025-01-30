## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  out.width = "80%"
)

## ----setup--------------------------------------------------------------------
knitr::opts_chunk$set(include = FALSE)
library(PPtreeregViz)
library(ggplot2)
library(dplyr)

## -----------------------------------------------------------------------------
library(MASS)
data("Boston")

set.seed(1234)
proportion = 0.7
idx_train = sample(1:nrow(Boston), size = round(proportion * nrow(Boston)))
sample_train = Boston[idx_train, ]
sample_test =  Boston[-idx_train, ]
sample_one <- sample_test[sample(1:nrow(sample_test),1),-14]

## -----------------------------------------------------------------------------
library(PPtreeregViz)
Model <- PPtreeregViz::PPTreereg(medv ~., data = sample_train, DEPTH = 2)

## ----fig.height=5, fig.width=7------------------------------------------------
plot(Model)

## ----fig.height=5, fig.width=7------------------------------------------------
pp_ggparty(Model, "lstat", final.rule = 1)

## ----fig.height=5, fig.width=7------------------------------------------------
pp_ggparty(Model, "lstat", final.rule = 4)

## ----fig.height=5, fig.width=7------------------------------------------------
pp_ggparty(Model, "lstat", final.rule = 5)

## -----------------------------------------------------------------------------
Tree.Imp <- PPimportance(Model) 
plot(Tree.Imp)

## -----------------------------------------------------------------------------
plot(Tree.Imp, marginal = TRUE, num_var = 5)

## ----fig.height=4, fig.width=8------------------------------------------------
PPregNodeViz(Model, node.id = 1)

## ----fig.height=4, fig.width=8------------------------------------------------
PPregNodeViz(Model, node.id = 4)

## ----fig.height=4, fig.width=8------------------------------------------------
PPregNodeViz(Model,node.id = 7)

## ----fig.height=5, fig.width=5------------------------------------------------
PPregVarViz(Model,"lstat")

## ----fig.height=5, fig.width=5------------------------------------------------
PPregVarViz(Model,"lstat",indiv = TRUE)

## ----fig.height=5, fig.width=5------------------------------------------------
PPregVarViz(Model,"chas",var.factor = TRUE)

## ----fig.height=5, fig.width=5------------------------------------------------
PPregVarViz(Model,"chas",indiv = TRUE, var.factor = TRUE)

## -----------------------------------------------------------------------------
sample_one

## -----------------------------------------------------------------------------
ppshapr.simple(PPTreeregOBJ = Model, testObs = sample_one, final.rule = 5)$dt

## -----------------------------------------------------------------------------
decisionplot(Model, testObs = sample_one, method="simple",varImp = "shapImp",final.rule=5)

## ----warning=FALSE------------------------------------------------------------
waterfallplot(Model, testObs = sample_one, method="simple", final.rule=5)

