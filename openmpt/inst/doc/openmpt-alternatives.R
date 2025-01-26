## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----tab-feat, echo=FALSE, message=FALSE, warning=FALSE-----------------------
library(kableExtra)
data.frame(
  Software =
    c("[`openmpt` R package](https://pepijn-devries.github.io/openmpt/)",
      "[OpenMPT (with GUI)](https://openmpt.org)",
      "[`ProTrackR2` R package](https://pepijn-devries.github.io/ProTrackR2/)",
      "[`fluidsynth` R package](https://docs.ropensci.org/fluidsynth/)"),
  `Runs in R`  =
    c("&#10004;", "", "&#10004;", "&#10004;"),
  `Allows editing` =
    c("", "&#10004;", "&#10004;", ""),
  `Supported file formats` =
    c("mptm mod s3m xm it 667 669 amf ams c67 dbm digi dmf dsm dsym dtm far fmt fst imf ice j2b m15 mdl med mms mt2 mtm mus nst okt plm psm pt36 ptm sfx sfx2 st26 stk stm stx stp symmod gtk gt2 ult wow xmf gdm mo3 oxm umx xpk ppm mmcmp",
      "same as `openmpt` R package",
      "mod (ProTracker compatible only)", "mid"),
  `Operating systems` =
    c("Windows, MacOS, Ubuntu, Fedora",
      "Windows",
      "Windows, MacOS, Ubuntu, Fedora",
      "Windows, MacOS, Ubuntu, Fedora"),
  check.names = FALSE
) |>
  kbl(escape = FALSE)

