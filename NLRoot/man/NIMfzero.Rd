\name{NIMfzero}
\alias{NIMfzero}
\title{Newton iteration method}
\description{
Newton iteration method to Find the Root of Nonlinear Equation.
}
\usage{
NIMfzero(f, f1, x0 = 0, num = 100, eps = 1e-05, eps1 = 1e-05)
}
\arguments{
  \item{f}{
the objective function which we will use to solve for the root
}
  \item{f1}{
the derivative of the objective function (say f)
}
  \item{x0}{
the initial value of Newton iteration method or Newton downhill method
}
  \item{num}{
the number of sections that the interval which from Brent's method devide        into. num=100 when it is default
}
  \item{eps}{
the level of precision that |x(k+1)-x(k)| should be satisfied in order to get the      idear real root. eps=1e-5 when it is default

}
  \item{eps1}{
the level of precision that |f(x)| should be satisfied, where x comes from the       program. when it is not satisified we will fail to get the root
}
}
\details{
the root we found out is based on the x0. So it is better to choose x0 carefully
}
\value{
the root of the function
}
\references{
Luis Torgo (2003) Data Mining with R:learning by case studies. LIACC-FEP, University of Porto
}
\author{
Zheng Sengui,Lu Xufen,Hou Qiongchen,Zheng Jianhui
}
\note{Maintainer:Zheng Sengui<1225620446@qq.com>
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{BFfzero}},\code{\link{NDHfzero}},\code{\link{SMfzero}}
}
\examples{
f<-function(x){x^3-x-1};f1<-function(x){3*x^2-1};
NIMfzero(f,f1,0)

##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as


function (f, f1, x0 = 0, num = 100, eps = 1e-05, eps1 = 1e-05) 
{
    a = x0
    b = a - f(a)/f1(a)
    i = 0
    while ((abs(b - a) > eps) & (i < num)) {
        a = b
        b = a - f(a)/f1(a)
        i = i + 1
    }
    print(b)
    print(f(b))
    if (abs(f(b)) < eps1) {
        print("finding root is successful")
    }
    else print("finding root is fail")
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
