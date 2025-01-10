---
title: CoFRA for complete functional regulation analysis
author: "Ana Sofia Carvalho and Rune Matthiesen"
date: "2017-04-06"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{CoFRA for complete functional regulation analysis}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteKeywords{functional analysis, enrichment analysis, sub cellular fractionation, proteomics, drug profiling} 
  %\VignetteEncoding{UTF-8}
---

# CoFRA for complete functional regulation analysis

## *Ana Sofia Carvalho and Rune Matthiesen*

date: 2017-04-06

## Introduction

CoFRA is a simple package for complete functional regulation analysis of large scale quantitative biological data. It combines statistical testing for regulation of functional groups of entities (e.g. using t test or Wilcox test) with 
statistical tests for enrichment of functional groups of entities (e.g. by applying hyper geometric function). 

## Dependencies

- LinkingTo: Rcpp
- Imports: Rcpp, gplots, grid
- Suggests: knitr, rmarkdown

The R package CoFRA has been tested using R version 3.2.3 (2015-12-10) -- "Wooden Christmas-Tree" and R version 3.3.2 (2016-10-31) -- "Sincere Pumpkin Patch" on windows 7 and Ubuntu. The package has 3 dependencies 
and mainly R core functions are used so it is expected that the package works with most R versions. Version >=1.2 allows use of multiple cores based on the parallel packages.

## Example analysis

Load the package:

```r
library(CoFRA)
```

CoFRA expects a quantitative matrix obtained from large scale biological measurements such as mass spectrometry, micro arrays and next generation sequencing experiments. The current proof of concept version accepts a data frame with a number of
quantitative values followed by a column named "pro" which should contain UniProt FASTA headers or UniProt accession numbers. In CoFRA version >=1.2 a matrix with UniProt FASTAheaders or UniProt accession numbers can be used instead of the data frame.
The data frame may contain any number of additional meta data columns. The code below loads example data from the article referenced in the reference section below.


```r
data("iBAQ")
str(iBAQ)
```

```
## 'data.frame':	18889 obs. of  33 variables:
##  $ MCCTT1: num  1640402 406709 0 0 0 ...
##  $ MCCTT2: num  1601663 1034359 0 0 0 ...
##  $ MCCTT3: num  1750248 470516 0 0 0 ...
##  $ MCCT1 : num  1983702 571217 0 0 0 ...
##  $ MCCT2 : num  1937308 187646 0 0 0 ...
##  $ MCCT3 : num  2146814 538094 0 0 0 ...
##  $ MC1   : num  0 2296029 0 0 1531801 ...
##  $ MC2   : num  0 2030153 0 0 1601609 ...
##  $ MC3   : num  0 1738694 0 0 1427439 ...
##  $ MCT1  : num  0 3120390 0 0 1160932 ...
##  $ MCT2  : num  0 2940770 0 0 1013242 ...
##  $ MCT3  : num  0 2962826 0 0 1037076 ...
##  $ MTT1  : num  0 200596 0 272392 0 ...
##  $ MTT2  : num  0 173634 0 162482 0 ...
##  $ MTT3  : num  0 440984 0 145186 0 ...
##  $ MT1   : num  0 650861 0 67055 0 ...
##  $ MT2   : num  0 776528 0 208875 0 ...
##  $ MT3   : num  0 881158 0 190807 0 ...
##  $ sN1   : num  0 2413200 969444 0 0 ...
##  $ sN2   : num  0 1676394 1040963 0 0 ...
##  $ sN3   : num  0 2413451 1113879 0 0 ...
##  $ sNT1  : num  0 3102772 978134 0 0 ...
##  $ sNT2  : num  0 3345828 895450 0 0 ...
##  $ sNT3  : num  0 2341355 708835 0 0 ...
##  $ iN1   : num  0 0 404521 0 0 ...
##  $ iN2   : num  0 0 511543 0 0 ...
##  $ iN3   : num  0 0 702408 0 0 ...
##  $ iNT1  : num  0e+00 0e+00 9e+05 0e+00 0e+00 ...
##  $ iNT2  : num  0e+00 0e+00 9e+05 0e+00 0e+00 ...
##  $ iNT3  : num  0 0 1229942 0 0 ...
##  $ pro   : chr  ">sp|A0AVT1|UBA6_HUMAN Ubiquitin-like modifier-activating enzyme 6 OS=Homo sapiens GN=UBA6 PE=1 SV=1" ">sp|A0FGR8|ESYT2_HUMAN Extended synaptotagmin-2 OS=Homo sapiens GN=ESYT2 PE=1 SV=1" ">sp|A0JLT2|MED19_HUMAN Mediator of RNA polymerase II transcription subunit 19 OS=Homo sapiens GN=MED19 PE=1 SV=2" ">sp|A0PJW6|TM223_HUMAN Transmembrane protein 223 OS=Homo sapiens GN=TMEM223 PE=1 SV=1" ...
##  $ E     : int  1 3 1 1 1 2 1 2 2 1 ...
##  $ FDR   : num  0 0 0 0 0 ...
```

The columns containing quantitative values maintain the raw file names indicating the origin of quantitative columns. The next step is to define a factor for the quantitative columns
see reference 1 below for details on the different samples of example data. This version of CoFRA only supports experimental designs with two experimental conditions, any number replicas (>=3) 
and any number of fractionations. 


```r
Fac=factor(c("MCCTT","MCCTT","MCCTT","MCCT","MCCT","MCCT","MC","MC","MC","MCT","MCT","MCT","MTT","MTT","MTT","MT","MT","MT","sN","sN","sN","sNT","sNT","sNT","iN","iN","iN","iNT","iNT","iNT"))
```

CoFRA also needs to know how the different levels should be compared. This is specified as a data frame as described below:


```r
dfComp=data.frame(Con=c("MCCT","MT","MC","iN","sN","AllC,MCCT,MT,MC,iN,sN"),Tre=c("MCCTT","MTT","MCT","iNT","sNT","AllT,MCCTT,MTT,MCT,iNT,sNT"))
```

Note that if factors are merged then the first string will be the name of the factor and the subsequent string list the factors to be merged.

The statistical calculations are resumed in a single command (see reference 1 below for details on the statistical calculations). The parameter "CC" is for cellular component.


```r
Func=CoFRA::getFunctionalCategories("CC")
str(Func)
CC1=CoFRA::completeFunctionalRegulationAnalysis(iBAQ,Func,Fac,dfComp,no_cores =-1) 
CoFRA::HeatMapEnrichment(CC1,"CC")
```

The statistical calculations can now be summarized in a single heatmap. For no_cores =-1 a single core will be used. no_cores =0 number of availble cores minus one will be used. 
If no_cores is set higher than one then this number of cores will be used. "CC" is for the title of the plot. The plotting works fine from the standard R terminal on Windows and Ubuntu. 
If you are plotting from Rstudio then you will get an error because of the way Rstudio plotting device is setup. Therefore from Rstudio you will need to plot directly to pdf as below.


```r
getwd() # check that the following commands don't overwrite any files
pdf("CC.pdf")
CoFRA::HeatMapEnrichment(CC1,"CC")
dev.off()
```

You can also use the standard functions plot and summary.


```r
plot(CC1)
summary(CC1)
```

Similar analysis can be made for "MF" (molecular function) and "BP" (biological process). More functional categories will be supported in the future.


```r
Func=CoFRA::getFunctionalCategories("MF")
str(Func)
MF1=CoFRA::completeFunctionalRegulationAnalysis(iBAQ,Func,Fac,dfComp) 
CoFRA::HeatMapEnrichment(MF1,"MF")
```

and for BP


```r
Func=CoFRA::getFunctionalCategories("BP")
str(Func)
BP1=CoFRA::completeFunctionalRegulationAnalysis(iBAQ,Func,Fac,dfComp) 
CoFRA::HeatMapEnrichment(BP1,"BP")
```



## Please cite if you use CoFRA for your research

1. Ana Sofia Carvalho, Henrik Molina and Rune Matthiesen, *New insights into functional regulation in MS-based drug profiling*, Scientific Reports, Jan, 2016

