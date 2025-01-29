\name{crm}
\alias{crm}
\title{A function for the continued reassessment method (CRM) used in Phase I clinical trials}
\description{
  Function crm implement the continued reassessment method (CRM) for dose
  finding in Phase I clinical trials. 
}
\usage{
crm(target,prior,ptdata,model=1,a0=1,b=3)
}
\arguments{
  \item{target}{Target probability of toxicity. The value must be in (0, 1).}
  \item{prior}{Prior probabilities of toxicity for each dose.
    The values must be in (0,1) and in an ascending order.  For
    example, prior=c(0.05,0.1,0.2,0.3,0.5,0.7),which corresponds to dose
    levels 1, 2, 3, 4, 5 and 6,respectively.}
  \item{ptdata}{A n by 2 matrix in which the first column contains dose
    levels and the second column contains toxicity indicators.  Dose levels
    must be integers (e.g., 1, 2, 3, ..., N).  Toxicity indicators must be
    0 and 1, where 0 indicates no toxicity and 1 indicates toxicity.}
  \item{model}{Dose-toxicity model.  The value must be 1 (hyperbolic
    tangent model) or 2 (one-parameter logistic model).  Default is 1.
    Hyperbolic tangent model: $p(y=1|x,a) = ((tanh(x)+1)/2)^a$.
    One-parameter logistic model: $p(y=1|x,a,b) = exp(b+ax)/(1+exp(b+ax))$.
    For both models, y=1 indicates toxicity is observed; a is the
    parameter that can be updated based on the outcome of the trail;
    b is a fixed parameter. The prior for a is exp(-a).}
  \item{a0}{Initial value for parameter a.  Default is 1.0.}
  \item{b}{A fixed parameter for the one-parameter logistic model.
    Default is 3.0.}
}
\seealso{
  \code{\link{crmsim}}, \code{\link{crmsiminc1}}, \code{\link{crmsiminc2}}
}
\value{
  A list with the following two objects:  
  \item{MTD}{The dose level proposed as the maximum tolerated dose (MTD) based on the patient data}
  \item{a}{The updated value for parameter a}
}

\examples{

#The table 1 in O'Quingley et al.'s paper, page 40
#This example is used to illustrate how the program is used to find
#the MTD and the updated parameter 
 
target <- 0.2
prior <- c(0.05,0.1,0.2,0.3,0.5,0.7)
x <- c(3,4,4,3,3,2,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1)
y <- c(0,0,1,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,1,1)
ptdata <- cbind(x,y)
for(i in 1:25){
  if(i == 1){
    cat(1,1,3,0,"\n")
  }
  res <- crm(target,prior,ptdata[1:i,],model=1,a0=1)
  if(i < 25){
    cat(i+1,res$a,res$MTD,ptdata[i+1,2],"\n")
  }else {
    cat(i+1,res$a,res$MTD,"\n")
  }
}

#the proposed MTD is
res$MTD

}

\author{Qianxing Mo; \email{qianxing.mo@moffitt.org}}

\references{
  John O'Quigley, Margaret Pepe,and Lloyd Fisher. (1990). Continual
  Reassessment Method: A Practical Design for Phase 1 Clinical Trials in Cancer.
  \emph{Biometrics}, 46, pp.33-48
}
\keyword{design}
