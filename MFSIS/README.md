---
title: "MFSIS"
---


## Description

An implementation of popular screening methods that are commonly employed in ultra-high and high dimensional data. Through this publicly available package, we provide a unified framework to carry out model-free screening procedures including 
SIS (Fan and Lv (2008) [doi:10.1111/j.1467-9868.2008.00674.x]), 
SIRS(Zhu et al. (2011)[doi:10.1198/jasa.2011.tm10563]), 
DC-SIS (Li et al. (2012) [doi:10.1080/01621459.2012.695654]), 
MDC-SIS(Shao and Zhang (2014) [doi:10.1080/01621459.2014.887012]), 
Bcor-SIS (Pan et al. (2019) [doi:10.1080/01621459.2018.1462709]), 
PC-Screen (Liu et al. (2020) [doi:10.1080/01621459.2020.1783274]), 
WLS (Zhong et al.(2021) [doi:10.1080/01621459.2021.1918554]), 
Kfilter (Mai and Zou (2015) [doi:10.1214/14-AOS1303]),
MVSIS (Cui et al. (2015) [doi:10.1080/01621459.2014.920256]),
PSIS (Pan et al. (2016) [doi:10.1080/01621459.2014.998760]),
CAS (Xie et al. (2020) [doi:101080/01621459.2019.1573734]),
CI-SIS (Cheng and Wang (2022) [doi:10.1016/j.cmpb.2022.107269]),
and CSIS (Cheng et al. (2023) [doi:10.1007/s00180-023-01399-5]).

## Installation
```{r install}
install.packages("MFSIS")
```

## Example
Here are many extensive examples that can let you quickly learn how to use this package. The author's original intention in writing this package is ease of use. Here is a simple example to illustrate its use. For example, I want to use SIRS method to screen high-dimensional data. I want to get the most active 30 features.
```{r SIRS}
library(MFSIS)
n=100;
p=200;
pho=0.5;
data=gendata1(n,p,pho)
data=cbind(data[[1]],data[[2]])
colnames(data)[1:ncol(data)]=c(paste0("X",1:(ncol(data)-1)),"Y")
data=as.matrix(data)
X=data[,1:(ncol(data)-1)];
Y=data[,ncol(data)];
A=SIRS(X,Y,30);A
```

