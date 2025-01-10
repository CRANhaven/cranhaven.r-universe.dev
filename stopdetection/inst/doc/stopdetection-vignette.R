## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----echo=FALSE, fig.height=5, fig.width=5, message=FALSE, warning=FALSE------
library(stopdetection)
data("loc_data_2019")
sm <- data.table::setDT(loc_data_2019)[1:500]
# sm <- loc_data_2019[1:500]
data.table::set(sm,
    j = c("lon1", "lat1"),
    value = list(
      sm[["longitude"]][1],
      sm[["latitude"]][1]))
# sm[, lon1 := longitude[1]]
# sm[, lat1 := latitude[1]]
sm[, dist := geodist::geodist_vec(x1 = lon1, y1 = lat1, x2 = longitude, y2 = latitude, measure = "geodesic", paired = TRUE, pad = TRUE)]
with(sm, {
  plot(longitude, latitude, asp=1, main = "Impact of deltaD parameter", sub = "Red: 100m, blue: 200m, green: 500m", type = "b")
  points(longitude[dist < 100], latitude[dist < 100], col = "red")
  points(lon1[1], lat1[1], col = "red", cex = 15)
  points(longitude[dist > 100 & dist < 200], latitude[dist > 100 & dist < 200], col = "blue")
  points(lon1[1], lat1[1], col = "blue", cex = 28)
  points(longitude[dist > 200 & dist < 500], latitude[dist > 200 & dist < 500], col = "darkgreen")
  points(lon1[1], lat1[1], col = "darkgreen", cex = 50)
})
# rm(sm)
# rm(loc_data_2019)

## ----echo=FALSE, message=FALSE, warning=FALSE---------------------------------
sm2 <- sm[400:500]
stopFinder(sm2, 200, thetaT = 60*3)
sm2[, threeminstateid := ifelse(state == "stopped", state_id, 99)]
stopFinder(sm2, 200, thetaT = 60*5)
sm2[, fiveminstateid := ifelse(state == "stopped", state_id, 99)]
with(sm2, {
  plot(timestamp, latitude, type = "b", cex = 1, main = "thetaT of 3 minutes", sub = "Filled points are stops, unfilled are tracks")
  points(timestamp, latitude,
         col = ifelse(threeminstateid == 1, "red", ifelse(threeminstateid == 3, "blue", "black")),
         pch = ifelse(threeminstateid %in% c(1, 3), 16, 1))
    plot(timestamp, latitude, type = "b", cex = 1, main = "thetaT of 5 minutes", sub = "Filled points are stops, unfilled are tracks")
  points(timestamp, latitude,
         col = ifelse(fiveminstateid == 1, "red", "black"),
         pch = ifelse(fiveminstateid == 1, 16, 1))
})

rm(sm)
rm(loc_data_2019)

## ----data---------------------------------------------------------------------
data("loc_data_2019")

## ----datatable----------------------------------------------------------------
library(data.table)
setDT(loc_data_2019)
loc_data_2019

## ----stopfinder---------------------------------------------------------------
stopFinder(loc_data_2019, thetaD = 200, thetaT = 300)[]

## ----returnstateevents--------------------------------------------------------
events <- returnStateEvents(loc_data_2019)
events[]

## -----------------------------------------------------------------------------
mergingCycle(loc_data_2019,
             thetaD = 200,
             small_track_action = "exclude",
             max_time = 600,
             max_dist = 2000,
             max_locs = 20)
returnStateEvents(loc_data_2019)[]

