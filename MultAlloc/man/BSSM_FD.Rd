\name{BSSM_FD}
\alias{BSSM_FD}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Optimal Allocation - Minimum Sum of Relative Variances}
\description{Allocation of the overall sample size n to the strata for the following purpose:

A weighted sum of variances (or relative variances) of the estimates of totals for the m survey variables is minimized.
}
\usage{BSSM_FD(Nh,Sh2j,Yj,Cust,nmin,ch,w,certain)}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{Nh}{Vector with total number of population units in each stratum (h=1,...,H)}
  \item{Sh2j}{Matrix (or vector) mxH (m = number of variables and H =number of strata) with Population variance for each variable of the hth  stratum}
  \item{Yj}{Vector with population total Yj for the jth survey variable}
  \item{Cust}{Corresponds to the overall variable cost budget for the survey C}
  \item{nmin}{Smallest possible sample size in any stratum}
  \item{ch}{Vector with the unit level survey costs for sampling from stratum h}
  \item{w}{Vector with Variable-specific weights, set a priori to represent the relative importance of the survey variables}
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
\references{Brito, J.A.M, Silva, P.L.N.,Semaan, G.Srogramming Formulations Applied to Optimal Allocation in Stratified Sampling. Survey Methodology, 41, No.2, pp.427-442.}
\author{
Jose Brito (jambrito@gmail.com), Pedro Silva, Gustavo Semaan and Nelson Maculan
}
%%\note{
%%  ~~further notes~~
%%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{BSSM_FC}
\examples{
#Example1
#Unit level survey costs for sampling from the strata are assumed to be the same.
#Number of survey variables (m=2) and seven strata (H=7)
#ch=1 ==> Cust = n
Nh<-c(49,78,20,39,73,82,89)
Yj<-c(542350,56089251)
Sh2j<-rbind(c(4436978,5581445,33454902,5763294,8689167,3716130,13938505),
            c(11034299660,40919330279,33519355946,18228286901,74247764986,49062224184,5783096806))
n<-200 #sample size
result<-BSSM_FD(Nh,Sh2j,Yj,Cust=n)

#Example2
#Unit level survey costs for sampling from the strata are assumed to be the same.
#ch=1 ==> Cust = n
#nmin>2
Nh<-c(49,78,20,39,73,82,89)
Yj<-c(542350,56089251)
Sh2j<-rbind(c(4436978,5581445,33454902,5763294,8689167,3716130,13938505),
            c(11034299660,40919330279,33519355946,18228286901,74247764986,49062224184,5783096806))
nmin<-20
n<-200
result<-BSSM_FD(Nh,Sh2j,Yj,nmin,Cust=n)

#Example3
#certain=TRUE
Nh<-c(49,78,20,39,73,82,89)
Yj<-c(542350,56089251)
Sh2j<-rbind(c(4436978,5581445,33454902,5763294,8689167,3716130,13938505),
            c(11034299660,40919330279,33519355946,18228286901,74247764986,49062224184,5783096806))
n<-200
result<-BSSM_FD(Nh,Sh2j,Yj,Cust=n,certain=TRUE)


#Example4
#Relative importance of the survey variables is different
w<-c(0.3,0.7)
Nh<-c(49,78,20,39,73,82,89)
Yj<-c(542350,56089251)
Sh2j<-rbind(c(4436978,5581445,33454902,5763294,8689167,3716130,13938505),
            c(11034299660,40919330279,33519355946,18228286901,74247764986,49062224184,5783096806))
n<-200
result<-BSSM_FD(Nh,Sh2j,Yj,Cust=n,w=w)


#Example5
#Number of survey variables m=1
Nh<-c(49,78,20,39,73,82,89)
Yj<-542350
Sh2j<-c(4436978,5581445,33454902,5763294,8689167,3716130,13938505)
n<-100
result<-BSSM_FD(Nh,Sh2j,Yj,Cust=n)


}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
