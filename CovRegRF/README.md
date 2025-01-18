# CovRegRF
R package which implements **Cov**ariance **Reg**ression with **R**andom **F**orests (**CovRegRF**).

**CovRegRF** is a random forest method for estimating the covariance matrix of a multivariate response *Y*, given a set of covariates *X*. The forest trees are built with a splitting rule specifically designed to partition the data to maximize the distance between the sample covariance matrix estimates of the child nodes.

For theoretical details and example data analysis, you can look at the vignette from within `R` by using the following command:

```R
vignette("CovRegRF")
```

## Installation
The package **CovRegRF** can be installed from GitHub using the `devtools` package. Run the following code in `R` to install:

```R
if (!require(devtools)) {
  install.packages("devtools")
  library(devtools)
}
devtools::install_github('calakus/CovRegRF', build_vignettes = TRUE)
```   
## References

- Alakus, C., Larocque, D., and Labbe, A. (2023). Covariance regression with random forests. *BMC Bioinformatics* 24, 258.
