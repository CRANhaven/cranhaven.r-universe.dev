\name{sLRcontrast}
\alias{sLRcontrast}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Calculate LR test statistics
}
\description{
The function calculates LR test statistics for the competing models which are defined by the argument 'models' 
(see \code{\link[DoseFinding]{drmodels}}). 
}
\usage{
sLRcontrast(dose, resp, models, off = 0.01 * max(dose), scal = 1.2 * max(dose))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dose, resp}{
Vectors of equal length specifying dose and response values.
}
  \item{models}{
A subvector of c("linear", "emax", "exponential", "linlog", "sigEmax", "quadratic", "betaMod", "logistic") (see \code{\link[DoseFinding]{drmodels}})
which specifies the competing models.
}
  \item{off}{
Positive and fixed offset parameter in the 'linlog' model (see \code{\link[DoseFinding]{drmodels}}).
}
  \item{scal}{
Positive and fixed dose scaling parameter in the 'betaMod' with '\eqn{scal\ge} max(dose)' (see \code{\link[DoseFinding]{drmodels}}).
}
}
\value{
A matrix containing the LR test statistic for one model in each row. The last row contains the value of the maximum statistic.
}
\references{
Dette, H., Titoff, S., Volgushev, S. and Bretz, F. (2015), Dose
response signal detection under model uncertainty. Biometrics. doi:
10.1111/biom.12357
}
\author{
Kevin Kokot
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link[DoseFinding:DoseFinding-package]{DoseFinding}}
}
\examples{
## Simulate the power of the LR contrast test

# five dose levels will be used
doselvl <- c(0, 0.05, 0.2, 0.6, 1)
dose <- c(rep(0, 10), rep(0.05, 10), rep(0.2, 10), rep(0.6, 10), rep(1, 10))

# each row of 'resp' will contain one sample of size 50
resp <- matrix(nrow=100, ncol=50)

# the linear model will serve as the data generating model
linear <- function(dose, e0, delta){e0 + delta * dose} 

# now 'resp' is generated:
for (i in 1:100)
     {for(j in 1:5)
        {resp[i,(j*10-9):(10*j)]<-rnorm(10, mean=linear(doselvl[j], 0.2, 0.6), sd=1.478)}}  

# the simulated 95% quantile in this case:
quantile <- 4.349362

# now the power is simulated
count <- 0
for (i in 1:100)
     {if(sLRcontrast(dose = dose, resp = resp[i,], models = c("linear", "emax", 
                     "exponential", "linlog"))[5] > quantile)
         {count <- count + 1}}

#power:
count/100
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
