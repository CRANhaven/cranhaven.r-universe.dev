\name{SMfzero}
\alias{SMfzero}
\title{Secant Method }
\description{
Secant Method to Find the Root of Nonlinear Equation.
}
\usage{
SMfzero(f, x1, x2, num = 1000, eps = 1e-05, eps1 = 1e-05)
}
\arguments{
  \item{f}{
the objective function which we will use to solve for the root
}
  \item{x1}{
the initial value of Secant Method
}
  \item{x2}{
the initial value of Secant Method
}
  \item{num}{
the number of sections that the interval which from Brent's method devide        into. num=1000 when it is default
}
  \item{eps}{
the level of precision that |x(k+1)-x(k)| should be satisfied in order to get the      idear real root. eps=1e-5 when it is default
}
  \item{eps1}{
the level of precision that |f(x)| should be satisfied, where x comes from the       program. when it is not satisified we will fail to get the root
}
}
\details{Be careful to choose x1 & x2.if not we maybe fail to get the root}
\value{
the root of the function
}
\references{
Luis Torgo (2003) Data Mining with R:learning by case studies. LIACC-FEP, University of Porto}
\author{
Zheng Sengui,Lu Xufen,Hou Qiongchen,Zheng Jianhui

}
\note{
Maintainer:Zheng Sengui<1225620446@qq.com>
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{BFfzero}},\code{\link{NDHfzero}},\code{\link{NIMfzero}}}
\examples{
f<-function(x){x^3-x-1};f1<-function(x){3*x^2-1};
SMfzero(f,0,2)


##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as


function (f, x1, x2, num = 1000, eps = 1e-05, eps1 = 1e-05) 
{
    i = 0
    while ((abs(x1 - x2) > eps) & (i < num)) {
        c = x2 - f(x2) * (x2 - x1)/(f(x2) - f(x1))
        x1 = x2
        x2 = c
        i = i + 1
    }
    print(x2)
    print(f(x2))
    if (abs(f(x2)) < eps1) {
        print("finding root is successful")
    }
    else print("finding root is fail")
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
