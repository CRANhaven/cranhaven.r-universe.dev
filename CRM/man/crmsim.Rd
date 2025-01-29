\name{crmsim}
\alias{crmsim}
\alias{crmsiminc1}
\alias{crmsiminc2}
\title{CRM Simulator}
\description{
  crmsim, crmsiminc1 and crmsiminc2 implement the continued reassessment method (CRM) for dose
  finding in Phase I clinical trials.  The operating characteristics of
  CRM are summarized through simulations.

  crmsim allows users to select a variety of cohort sizes.  A cohort of
  subjects are treated at the same dose.

  The cohort size is fixed to 1 in crmsiminc1 and crmsiminc2.
  crmsiminc1 implements an algorithm that allows a clinical trial to proceed to the next subject's
  dose assignment before observing the last subject's toxicity data.
  crmsiminc2 allows a clinical trial to proceed to the next
  subject's dose assignment before observing the last two subject's
  toxicity data (see Iasonos et al. for details).
}
\usage{
crmsim(target,prior,true,rate,cycle,cohort=1,nsubject=24,nsim=1000,
       model=1,a0=1,b=3,jump=FALSE,start.dose=1,seed=777)
crmsiminc1(target,prior,true,rate,cycle,nsubject=24,nsim=1000,
           model=1,a0=1,b=3,jump=FALSE,start.dose=1,seed=777)
crmsiminc2(target,prior,true,rate,cycle,nsubject=24,nsim=1000,
           model=1,a0=1,b=3,jump=FALSE,start.dose=1,seed=777)
}
\arguments{
  \item{target}{Target probability of toxicity. The value must be in (0, 1).}
  \item{prior}{Prior probabilities of toxicity for each dose.
    The values must be in (0,1) and in an ascending order.  For
    example, prior=c(0.05,0.1,0.2,0.3,0.5,0.7),which corresponds to dose
    levels 1, 2, 3, 4, 5 and 6,respectively.}
  \item{true}{True probabilities of toxicity. The values must be in
    (0,1) and in an ascending order.  e.g. (0.1,0.2,0,3,0.4,0.5,0.8)}
  \item{rate}{Recruitment/accrual rate of subjects in a 30 window.
    For example,if 1 subject can be recruited per 30 days, then set rate
    = 1/30 = 0.033; if 2 patients per 30 day then rate = 2/30 = 0.0667.}
  \item{cycle}{The length of treatment cycle in days.}
  \item{cohort}{Cohort size of subjects entering into the trials. Default
    is 1.  The value for cohort must be less than or equal to the value
    for nsubject.}
  \item{nsubject}{Total number of subjects in one simulation(or
    trial). Default is 24.  nsubject should be equal to n*cohort,where
    n is positive integer.}
  \item{nsim}{Total number of simulations. Default is 1000.}
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
  \item{jump}{jump=FALSE means NOT allowing that the proposed dose by the
    CRM program has an increase of more than one level than the
    previous level;  jump=TRUE means allowing more-than-one-level
    increase of the proposed dose by the CRM program.}
  \item{start.dose}{Initial dose for each trial.  Default is 1.}
  \item{seed}{Seed for the random number generator.  Default is 777.}
}
\seealso{
  \code{\link{crm}}
}
\value{
  SimResult is a matrix that summarizes the operating characteristics of
  CRM.  The column names are the dose levels.  The row names are the
  operating characteristics.
  
  \item{\% Selection}{the percentage of selection of each dose as MTD}
  \item{\% Subjects Treated}{the percentage of subjects treated at each
    dose}
  \item{# Subjects Treated}{the average number of subjects treated at
    each dose} 
  \item{Average Toxicities}{the average toxicities per trial at each dose}
  \item{True Probabilities}{the true probability of toxicity of each
    dose}
  
  TrialDuration is a table that summarizes the time needed for the
  trial based on the simulation.
}

\examples{

prior1 <- c(0.05,0.1,0.2,0.3,0.5,0.7)
true1 <- c(0.1,0.15,0.2,0.4,0.5,0.8)

### simulations using model 1 (hyperbolic tangent model)

### uncomment the following code to run ###
#crmsim(target=0.2,prior=prior1,true=true1,rate=0.1,cycle=21,cohort=1,nsubject=24,nsim=1000,
#       model=1,a0=1,b=3,jump=FALSE,start.dose=1,seed=777)

#crmsiminc1(target=0.2,prior=prior1,true=true1,rate=0.1,cycle=21,nsubject=24,nsim=1000,
#           model=1,a0=1,b=3,jump=FALSE,start.dose=1,seed=777)

#crmsiminc2(target=0.2,prior=prior1,true=true1,rate=0.1,cycle=21,nsubject=24,nsim=1000,
#           model=1,a0=1,b=3,jump=FALSE,start.dose=1,seed=777)

# simulations using model 2 (one-parameter logistic model)
#crmsim(target=0.2,prior=prior1,true=true1,rate=0.1,cycle=21,cohort=1,nsubject=24,nsim=1000,
#       model=2,a0=1,b=3,jump=FALSE,start.dose=1,seed=777)

#crmsiminc1(target=0.2,prior=prior1,true=true1,rate=0.1,cycle=21,nsubject=24,nsim=1000,
#           model=2,a0=1,b=3,jump=FALSE,start.dose=1,seed=777)

#crmsiminc2(target=0.2,prior=prior1,true=true1,rate=0.1,cycle=21,nsubject=24,nsim=1000,
#           model=2,a0=1,b=3,jump=FALSE,start.dose=1,seed=777)
}

\author{Qianxing Mo; \email{qianxing.mo@moffitt.org}}

\references{
  John O'Quigley, Margaret Pepe,and Lloyd Fisher. (1990). Continual
  Reassessment Method: A Practical Design for Phase 1 Clinical Trials in Cancer.
  \emph{Biometrics}, 46, pp.33-48

  Alexia Iasonos,Andrew S Wilton,Elyn R Riedel,Venkatraman E Seshan and
  David R Spriggs.  A comprehensive comparison of the continual
  reassessment method to the standard 3+3 dose escalation scheme in
  Phase I dose-finding studies.  \emph{Clinical Trials},2008,nil:1-12
}
\keyword{design}
