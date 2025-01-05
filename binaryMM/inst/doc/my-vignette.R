## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, warning=FALSE, message=FALSE--------------------------------------
library(binaryMM)

## -----------------------------------------------------------------------------
data(madras)
str(madras)

## -----------------------------------------------------------------------------
mod.mt <- mm(thought ~ month*gender + month*age, t.formula = ~1,  
             data = madras, id = id)
summary(mod.mt)

## -----------------------------------------------------------------------------
mod.mlv <- mm(thought ~ month*gender + month*age, lv.formula = ~1, 
              data = madras, id = id)
summary(mod.mlv)

## -----------------------------------------------------------------------------
mod.mtlv <- mm(thought ~ month*gender + month*age,
               t.formula = ~1, lv.formula = ~1, 
               data = madras, id = id)
summary(mod.mtlv)

## -----------------------------------------------------------------------------
mod.mtgender <- mm(thought ~ month*gender + month*age,
                   t.formula = ~gender, data = madras, id = id)
summary(mod.mtgender)

## -----------------------------------------------------------------------------
# set-up two new indicator variables for gender
madras$g0    <- ifelse(madras$gender == 0, 1, 0)
madras$g1    <- ifelse(madras$gender == 1, 1, 0)
mod.mlvgender <- mm(thought ~ month*gender + month*age,
                   lv.formula = ~0+g0+g1, data = madras, id = id)
summary(mod.mlvgender)

## -----------------------------------------------------------------------------
data(datrand)
str(datrand)

## -----------------------------------------------------------------------------
# create the sampling scheme
Ymean     <- tapply(datrand$Y, FUN = mean, INDEX = datrand$id)
some.id   <- names(Ymean[Ymean != 0])
none.id   <- names(Ymean)[!(names(Ymean) %in% some.id)]
samp.some <- some.id[rbinom(length(none.id), 1, 1) == 1]
samp.none <- none.id[rbinom(length(none.id), 1, 0.20) == 1]

# sample subjects and create a weight vector
datrand$sampled <- ifelse(datrand$id %in% c(samp.none, samp.some), 1, 0)
dat.small       <- subset(datrand, sampled == 1)
wt              <- ifelse(dat.small$id %in% samp.none, 1/1, 1/0.2)

# fit the mTLV model
mod.wt          <- mm(Y ~ time*binary, t.formula = ~1, data = dat.small, 
                      id = id, weight = wt)
summary(mod.wt)

