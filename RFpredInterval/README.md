# RFpredInterval
R package which implements Prediction Intervals with Random Forests and Boosted Forests

`RFpredInterval` package has two main R functions as below:

*    `pibf`: Constructs prediction intervals with **P**rediction **I**ntervals with **B**oosted **F**orests (PIBF) proposed by Alakus et al. (2021)
*    `rfpi`: Constructs prediction intervals with 15 distinct variations to produce **P**rediction **I**ntervals with **R**andom **F**orests (RFPI) proposed by Roy and Larocque (2020)

## Installation
This package is available on [CRAN](https://CRAN.R-project.org/package=RFpredInterval). Alternatively, you can install **RFpredInterval** from GitHub using the `devtools` package. Run the following code in `R` to install:

```R
if (!require(devtools)) {
  install.packages("devtools")
  library(devtools)
}
devtools::install_github('calakus/RFpredInterval')
```   
## References

- Alakus, C., Larocque, D., and Labbe, A. (2021). RFpredInterval: An R Package for Prediction Intervals with Random Forests and Boosted Forests. *arXiv preprint* <https://arxiv.org/abs/2106.08217>.
- M.-H. Roy and D. Larocque. Prediction intervals with random forests. *Statistical Methods in Medical Research*, 29(1):205–229, Jan. 2020. URL <https://doi.org/10.1177/0962280219829885>.
