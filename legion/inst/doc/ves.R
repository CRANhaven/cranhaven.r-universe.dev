## ----global_options, include=FALSE--------------------------------------------
knitr::opts_chunk$set(fig.width=6, fig.height=5.5, fig.path='Figs/', fig.show='hold',
                      warning=FALSE, message=FALSE)

## ----load_libraries, message=FALSE, warning=FALSE-----------------------------
require(legion)

## ----form_the_vector, message=FALSE, warning=FALSE----------------------------
Y <- ts(cbind(1000+0.5*c(1:100)+rnorm(100,0,10),
              cbind(1000+1.5*c(1:100)+rnorm(100,0,10))),
        frequency=12);

## ----ves_basic----------------------------------------------------------------
ves(Y, h=18, holdout=TRUE, silent=FALSE)

## ----ves_AAN_persistence_dep--------------------------------------------------
ourModel <- ves(Y, "AAN", persistence="d", h=18, holdout=TRUE, silent=FALSE)

## ----ves_AAN_persistence_dep_value--------------------------------------------
ourModel$persistence

## ----ves_MMdM-----------------------------------------------------------------
ourModel <- ves(Y, "MMdM", phi="i", persistence="i", h=18, holdout=TRUE)

## -----------------------------------------------------------------------------
ourForecast <- forecast(ourModel, h=18, interval="prediction")

## -----------------------------------------------------------------------------
oldpar <- par(mfcol=c(2,1))
plot(ourForecast)
par(oldpar)

## ----simulate_smooth_ves------------------------------------------------------
x <- sim.ves("ANN",frequency=4,obs=40,nvariate=3,randomizer="rnorm",mean=0,sd=100)

## ----simulate_smooth_ves_estimated--------------------------------------------
ourModel <- ves(x$data,model="AAN",persistence="dependent")
Y <- simulate(ourModel)
plot(Y)

