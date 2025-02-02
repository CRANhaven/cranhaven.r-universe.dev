## ----global_options, include=FALSE--------------------------------------------
knitr::opts_chunk$set(fig.width=6, fig.height=5.5, fig.path='Figs/', fig.show='hold',
                      warning=FALSE, message=FALSE)

## ----load_libraries, message=FALSE, warning=FALSE-----------------------------
require(legion)

## ----form_the_vector, message=FALSE, warning=FALSE----------------------------
Y <- ts(cbind(1000+0.5*c(1:100)+rnorm(100,0,10),
              cbind(1000+1.5*c(1:100)+rnorm(100,0,10))),
        frequency=12);

## ----vets_basic---------------------------------------------------------------
vetsModel <- vets(Y, "MMdM", h=18, holdout=TRUE, silent=FALSE)

## ----autovets-----------------------------------------------------------------
vetsModel <- auto.vets(Y, "PPP", h=18, holdout=TRUE, silent=FALSE)

## -----------------------------------------------------------------------------
oldpar <- par(mfcol=c(2,1))
plot(vetsModel,1)
plot(vetsModel,7)
par(oldpar)

## -----------------------------------------------------------------------------
modelType(vetsModel)
modelType(vetsModel,pic=TRUE)

## ----eval=FALSE---------------------------------------------------------------
#  actuals(vetsModel)
#  fitted(vetsModel)
#  residuals(vetsModel)

## -----------------------------------------------------------------------------
vetsForecast <- forecast(vetsModel, h=18, interval="prediction")
oldpar <- par(mfcol=c(2,1))
plot(vetsForecast)
par(oldpar)

