# binaryMM: Fitting Flexible Marginalized Models for Binary Correlated Outcomes

The `binaryMM` package allows users to fit marginalized transition and latent variables (mTLV) models for binary correlated data. You can install the development version from GitHub with:

```{r, eval = FALSE}
install.packages("devtools")
devtools::install_github("ChiaraDG/binaryMM")
```

## Examples

### Fitting Marginalized Models

The function `mm` allows users to fit marginalized models with a transition and/or a latent term. Users specify the marginal mean model with `mean.formula`, the transition component of the dependence model with `t.formula` and the latent variable component of the dependence model with `lv.formula`. The model below specifies both a transition and a latent variable term in the dependence model:

```{r, eval = FALSE}
mod.mtlv <- mm(mean.formula = thought ~ month*gender + month*age,
               t.formula = ~1, lv.formula = ~1, 
               data = madras, id = id)
```

Results from the model above can be displayed using the `summary`function:

```{r}
#> 
#> Class:
#> MMLong
#> 
#> Call:
#> mm(mean.formula = thought ~ month * gender + month * age, lv.formula = ~1, 
#>     t.formula = ~1, id = id, data = madras)
#> 
#> Information Criterion:
#>       AIC        BIC     logLik   Deviance  
#>  680.1283   699.7631  -332.0642   664.1283  
#> 
#> Marginal Mean Parameters:
#>               Estimate  Model SE Chi Square  Pr(>Chi)
#> (Intercept)   1.327440  0.434588     9.3299  0.002255
#> month        -0.367564  0.077443    22.5268 2.072e-06
#> gender       -0.282497  0.402015     0.4938  0.482241
#> age          -0.732176  0.436180     2.8177  0.093228
#> month:gender -0.111740  0.078306     2.0362  0.153591
#> month:age     0.117705  0.080870     2.1184  0.145536
#> 
#> Association Parameters:
#>                        Estimate Model SE Chi Square Pr(>Chi)
#> gamma:(Intercept)      2.511119 0.303963    68.2486   <2e-16
#> log(sigma):(Intercept) 0.074494 0.244870     0.0925    0.761
#> 
#> Number of clusters:             86 
#> Maximum cluster size:           12 
#> Convergence status (nlm code):  1 
#> Number of iterations:           50
```

User can speficy a dependence model with a transition term only with the code below:

```{r, eval = FALSE}
mod.mt <- mm(mean.formula = thought ~ month*gender + month*age,
               t.formula = ~1, lv.formula = NULL, 
               data = madras, id = id)
summary(mod.mt)

#> 
#> Class:
#> MMLong
#> 
#> Call:
#> mm(mean.formula = thought ~ month * gender + month * age, t.formula = ~1, 
#>     id = id, data = madras)
#> 
#> Information Criterion:
#>       AIC        BIC     logLik   Deviance  
#>  688.3789   705.5594  -337.1895   674.3789  
#> 
#> Marginal Mean Parameters:
#>               Estimate  Model SE Chi Square  Pr(>Chi)
#> (Intercept)   1.183683  0.444318     7.0971  0.007721
#> month        -0.342857  0.081841    17.5501 2.798e-05
#> gender       -0.141884  0.416152     0.1162  0.733147
#> age          -0.649770  0.449183     2.0925  0.148021
#> month:gender -0.143788  0.081853     3.0859  0.078975
#> month:age     0.111555  0.085896     1.6867  0.194040
#> 
#> Association Parameters:
#>                   Estimate Model SE Chi Square  Pr(>Chi)
#> gamma:(Intercept)  3.16583  0.23014     189.23 < 2.2e-16
#> 
#> Number of clusters:             86 
#> Maximum cluster size:           12 
#> Convergence status (nlm code):  1 
#> Number of iterations:           22
```

### Generate Outcome Data under a Marginalized Model Framework

The function `GenerateBinayY` in the `binaryMM` package allows users to generate outcome data under a marginalized model framework. The code below shows how the data can be generated. Note that the output of `GenerateBinayY` is the longitudinal outcome vector.

```{r}
set.seed(1)
N       = 100
nclust  = sample( seq(10,10), N, replace=TRUE)
id      = rep(seq(N), nclust)
Xe      = rep(rbinom(N,size=1,prob=.5), nclust) # binary exposure
time    = unlist( sapply( as.list(nclust), function(ZZ) seq(ZZ)-1 ) )
data    = data.frame(id, time, Xe)
data    = data[order(data$id, data$time),]
Y = GenBinaryY(mean.formula=~time*Xe, lv.formula=~1, t.formula=~1,
          beta=c(-2.5, 0.25, 0.25, 0.1), sigma=1, gamma=1, id=id, data=data, q=20, Yname = "binY")
```
