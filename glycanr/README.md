glycanr
=======

Glycomics is rapidly emerging field in high-throughput biology that
aims to systematically study glycan structures of a given protein, cell type or
organic system. As within other high-throughput methods in biology (microarrays,
metabolomics, proteomics), accuracy of high-throughput methods is highly affected
by complicated experimental procedures leading to differences between replicates
and the existence of batch effects, among others.

This package tries to fill the gap in N-glycan data analysis by providing
easy to use functions for glycomics analysis. At the moment it is mostly
oriented to data obtained by UPLC and LCMS analysis of Plasma and IgG
glycome.

For a broader introduction take a look at "Introduction" vignette.

This project has received funding from:

- the European Union’s Horizon FP7 research and innovation programme through the EU research project MIMOmics (Grant Agreement no. 305280),
- the European Union’s Horizon 2020 research and innovation programme through the EU research project Back-UP (Grant Agreement no. 777090).

# Install

## From CRAN

```r
install.packages('glycanr')
```

## From GitHub

The package can be installed for example with  **devtools** package.

```r
install.packages('devtools')
```

Load the **devtools** package.

```r
library(devtools)
```

Install the package.

```r
install_github('iugrina/glycanr', build_vignette=TRUE)
```


