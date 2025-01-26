\name{BSSM_FC}
\alias{BSSM_FC}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Optimal Allocation - Minimum Sample Size}
\description{Allocation of the overall sample size n to the strata for the following purpose:

The total variable survey cost C (c1.n1+c2.n2+...+cH.nH)is minimized, subject to having Coefficients of Variation (CVs) for the estimates of totals of the m survey variables below specified thresholds.

If the unit level survey costs for sampling from the various strata are unknown or are assumed to be the same, then c1,c2,...,cH may all be set to one and the alternative objective function to minimize is n1+n2+...+nH.
}
\usage{BSSM_FC(Nh,Sh2j,Yj,cvt,nmin,ch,certain)}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Nh}{Vector with total number of population units in each stratum (h=1,...,H)}
  \item{Sh2j}{Matrix (or vector) mxH (m = number of variables and H =number of strata) with Population variance for each variable of the hth  stratum}
  \item{Yj}{Vector with population total Yj for the jth survey variable}
  \item{cvt}{Vector with target cvs asociated with survey variables}
  \item{nmin}{Smallest possible sample size in any stratum}
  \item{ch}{Vector with the unit level survey costs for sampling from stratum h}
  \item{certain}{if (nH=NH) => certain=TRUE else certain=FALSE }
}
\details{Function that uses an integer programming formulation}
\value{
\item{n}{Sample size}
\item{nh}{Sample of size by stratum}
\item{cvs}{Coefficients of variation for the estimators of totals of the survey variables considered}
\item{time_cpu}{Time consumed by the algorithm (seconds)}
%% ...
}
\references{Brito, J.A.M, Silva, P.L.N.,Semaan, G.S. and Maculan, N. (2015). Integer Programming Formulations Applied to Optimal Allocation in Stratified Sampling. Survey Methodology, 41, No.2, pp.427-442.}
\author{
Jose Brito (jambrito@gmail.com), Pedro Silva, Gustavo Semaan and Nelson Maculan
}
%%\note{
%%  ~~further notes~~
%%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{BSSM_FD}
\examples{
#Example1 - Number of survey variables (m=2) and seven strata (H=7)
Nh<-c(49,78,20,39,73,82,89)
Yj<-c(542350,56089251)
Sh2j<-rbind(c(4436978,5581445,33454902,5763294,8689167,3716130,13938505),
            c(11034299660,40919330279,33519355946,18228286901,74247764986,49062224184,5783096806))
cvt<-c(0.02,0.02)
result<-BSSM_FC(Nh,Sh2j,Yj,cvt)

#Example2
#nmin>2
Nh<-c(49,78,20,39,73,82,89)
Yj<-c(542350,56089251)
Sh2j<-rbind(c(4436978,5581445,33454902,5763294,8689167,3716130,13938505),
            c(11034299660,40919330279,33519355946,18228286901,74247764986,49062224184,5783096806))
cvt<-c(0.1,0.1)
nmin<-20
result<-BSSM_FC(Nh,Sh2j,Yj,cvt,nmin)

#Example3
#certain=TRUE
Nh<-c(49,78,20,39,73,82,89)
Yj<-c(542350,56089251)
Sh2j<-rbind(c(4436978,5581445,33454902,5763294,8689167,3716130,13938505),
            c(11034299660,40919330279,33519355946,18228286901,74247764986,49062224184,5783096806))
cvt<-c(0.1,0.1)
result<-BSSM_FC(Nh,Sh2j,Yj,cvt,certain=TRUE)


#Example4
#Number of survey variables m=1
Nh<-c(49,78,20,39,73,82,89)
Yj<-542350
Sh2j<-c(4436978,5581445,33454902,5763294,8689167,3716130,13938505)
cvt<-0.1
result<-BSSM_FC(Nh,Sh2j,Yj,cvt)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line



