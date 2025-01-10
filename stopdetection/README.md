
<!-- README.md is generated from README.Rmd. Please edit that file -->

# stopdetection

<!-- badges: start -->
<!-- badges: end -->

This package implements the stop detection algorithm as outlined in Ye
et al. (2009). This package provides a set of tools to cluster
timestamped movement trajectories into sets of stops (or stay points)
and tracks (or trajectories). Time-adjacent clusters are formed by first
identifying stops on the basis of provided dwell time and radius
parameters. A stop is created if all subsequent locations are within a
certain distance of an initiating location for at least as long as the
dwell time. For example, 200 meters and 5 minutes may be used in order
to find all clusters within the trajectory for which a person remained
within a circle with radius 200 meters for at least five minutes.

It is recommended to merge stops following the initial stop
identification, as documented in Montoliu, Blom, and Gatica-Perez
(2013). Merging stops requires a parameter for the maximum distance away
from each other that two stops may be while being considered the same
stop. Single points between two stops adjacent in time are removed
during this step. In data where locations are measured without error,
this step is optional. Where locations are generated with error, this
step provides an error correcting mechanism for erroneous and
low-accuracy locations.

## Installation

You can install the development version of stopdetection from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("daniellemccool/stopdetection")
```

## Example

The following demonstrates the stopFinder algorithm with a distance
radius parameter of 200 meters, and a minimum time parameter of 200
seconds.

``` r
library(data.table)
library(stopdetection)
data("loc_data_2019")
setDT(loc_data_2019)
stopFinder(loc_data_2019, thetaD = 200, thetaT = 200)
```

## Extract states

Use to quickly extract a data.table containing information about the
stops and tracks

``` r
returnStateEvents(loc_data_2019)
#>      state_id   state  meanlat  meanlon          begin_time            end_time
#>         <int>  <char>    <num>    <num>              <POSc>              <POSc>
#>   1:        1 stopped 52.07212 5.123761 2019-11-01 00:02:46 2019-11-01 08:05:39
#>   2:        2  moving       NA       NA 2019-11-01 08:05:55 2019-11-01 08:06:27
#>   3:        3 stopped 52.07788 5.122714 2019-11-01 08:06:42 2019-11-01 08:11:29
#>   4:        4  moving       NA       NA 2019-11-01 08:12:00 2019-11-01 08:15:24
#>   5:        5 stopped 52.08902 5.109717 2019-11-01 08:15:40 2019-11-01 08:24:10
#>  ---                                                                           
#> 323:      323  moving       NA       NA 2019-11-14 19:02:43 2019-11-14 19:11:46
#> 324:      324 stopped 52.08177 5.138043 2019-11-14 19:12:02 2019-11-14 19:57:11
#> 325:      325 stopped 52.08252 5.134228 2019-11-14 19:57:40 2019-11-14 20:01:05
#> 326:      326  moving       NA       NA 2019-11-14 20:01:20 2019-11-14 20:08:32
#> 327:      327 stopped 52.07213 5.123719 2019-11-14 20:08:47 2019-11-14 23:59:23
#>      raw_travel_dist stop_id move_id n_locations
#>                <num>   <int>   <int>       <int>
#>   1:              NA       1      NA         471
#>   2:        158.2833      NA       1           2
#>   3:              NA       2      NA          21
#>   4:       1253.8918      NA       2          13
#>   5:              NA       3      NA          36
#>  ---                                            
#> 323:       2171.3438      NA     110          33
#> 324:              NA     214      NA          65
#> 325:              NA     215      NA          12
#> 326:       1589.1137      NA     111          26
#> 327:              NA     216      NA         205
```

## Merge stops/handle short tracks

Subsequent nearby stops can be merged based on the distance of their
centroids. This is often useful if they represent the same stop
subjectively. Short tracks can be either merged into the previous stop
or excluded. Often short ‘tracks’ represent erroneously measured GNSS
locations of one or two points, so excluding them is helpful. The
combination of excluding short tracks and merging stops can be used to
handle noisy location data.

``` r
mergingCycle(loc_data_2019, thetaD = 200, small_track_action = "exclude", max_locs = Inf, max_dist = 200)
returnStateEvents(loc_data_2019)
#>      state_id    state  meanlat  meanlon          begin_time
#>         <int>   <char>    <num>    <num>              <POSc>
#>   1:        1  stopped 52.07212 5.123760 2019-11-01 00:02:46
#>   2:       NA excluded       NA       NA 2019-11-01 08:05:55
#>   3:        2  stopped 52.07785 5.122780 2019-11-01 08:06:42
#>   4:        3   moving       NA       NA 2019-11-01 08:12:00
#>   5:        4  stopped 52.08902 5.109717 2019-11-01 08:15:40
#>  ---                                                        
#> 251:      250   moving       NA       NA 2019-11-14 19:02:43
#> 252:      251  stopped 52.08177 5.138043 2019-11-14 19:12:02
#> 253:      252  stopped 52.08252 5.134228 2019-11-14 19:57:40
#> 254:      253   moving       NA       NA 2019-11-14 20:01:20
#> 255:      254  stopped 52.07213 5.123719 2019-11-14 20:08:47
#>                 end_time raw_travel_dist stop_id move_id n_locations
#>                   <POSc>           <num>   <int>   <int>       <int>
#>   1: 2019-11-01 08:05:39              NA       1      NA         471
#>   2: 2019-11-14 16:44:47              NA      NA      NA          68
#>   3: 2019-11-01 08:11:29              NA       2      NA          21
#>   4: 2019-11-01 08:15:24        1253.892      NA       1          13
#>   5: 2019-11-01 08:24:10              NA       3      NA          36
#>  ---                                                                
#> 251: 2019-11-14 19:11:46        2171.344      NA      77          33
#> 252: 2019-11-14 19:57:11              NA     174      NA          65
#> 253: 2019-11-14 20:01:05              NA     175      NA          12
#> 254: 2019-11-14 20:08:32        1589.114      NA      78          26
#> 255: 2019-11-14 23:59:23              NA     176      NA         205
```

# References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-Montoliu2013-tb" class="csl-entry">

Montoliu, Raul, Jan Blom, and Daniel Gatica-Perez. 2013. “Discovering
Places of Interest in Everyday Life from Smartphone Data.” *Multimedia
Tools and Applications* 62 (1): 179–207.
<https://doi.org/10.1007/s11042-011-0982-z>.

</div>

<div id="ref-Ye2009-dv" class="csl-entry">

Ye, Yang, Yu Zheng, Yukun Chen, Jianhua Feng, and Xing Xie. 2009.
“Mining Individual Life Pattern Based on Location History.” In
*Proceedings of the 2009 Tenth International Conference on Mobile Data
Management: Systems, Services and Middleware*, 1–10. MDM ’09. USA: IEEE
Computer Society. <https://doi.org/10.1109/MDM.2009.11>.

</div>

</div>
