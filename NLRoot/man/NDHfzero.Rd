\name{NDHfzero}
\alias{NDHfzero}
\title{Newton Downhill Method
}
\description{Newton Downhill Method to Find the Root of Nonlinear Equation}
\usage{
NDHfzero(f, f1, x0 = 0, num = 1000, eps = 1e-05, eps1 = 1e-05)
}

\arguments{
  \item{f}{the objective function which we will use to solve for the root}
  \item{f1}{the derivative of the objective function (say f)
}
  \item{x0}{the initial value of Newton iteration method or Newton downhill method
}
  \item{num}{num  the number of sections that the interval which from Brent's method devide  into. num=1000 when it is default 
}
  \item{eps}{the level of precision that |x(k+1)-x(k)| should be satisfied in order to get the idear real root. eps=1e-5 when it is default
}
  \item{eps1}{the level of precision that |f(x)| should be satisfied, where x comes from the  program. when it is not satisified we will fail to get the root}
}
\details{eps1 of precision that |f(x)| should be satisfied, where x comes from the  program. when it is not satisified we will fail to get the root}
\value{a root of the objective function }
\references{
Luis Torgo (2003) Data Mining with R:learning by case studies. LIACC-FEP, University of Porto}
\author{Zheng Sengui,Lu Xufen,Hou Qiongchen,Zheng Jianhui}
\note{Maintainer:Zheng Sengui<1225620446@qq.com>
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{BFfzero}},\code{\link{NIMfzero}},\code{\link{SMfzero}}
}
\examples{f<-function(x){x^3-x-1};f1<-function(x){3*x^2-1};
NDHfzero(f,f1,2)

##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (f, f1, x0 = 0, num = 1000, eps = 1e-05, eps1 = 1e-05) 
{
    a = x0
    b = a - f(a)/f1(a)
    i = 0
    while ((abs(b - a) > eps)) {
        c = 1
        j = 0
        while (abs(f(b)) >= abs(f(a))) {
            b = a - c * f(a)/f1(a)
            j = j + 1
            c = 1/(2^j)
        }
        a = b
        b = a - f(a)/f1(a)
        c = 1
        j = 0
        while (abs(f(b)) >= abs(f(a))) {
            b = a - c * f(a)/f1(a)
            j = j + 1
            c = 1/(2^j)
        }
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
