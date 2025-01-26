\name{BFfzero}
\alias{BFfzero}
\title{Bisection Method}
\description{Bisection Method to Find the Root of Nonlinear Equation}
\usage{
BFfzero(f, a, b, num = 10, eps = 1e-05)
}
\arguments{
  \item{f}{the objective function which we will use to solve for the root}
  \item{a}{mininum of the interval  which cantains the root from Bisection Method}
  \item{b}{maxinum of the interval which cantains the root from Bisection Method }
  \item{num}{the number of sections that the interval which from Bisection Method }
  \item{eps}{the level of precision that |x(k+1)-x(k)| should be satisfied in order to get the idear real root. eps=1e-5 when it is default
}
}
\details{ Be careful to choose a & b. If not we maybe fail to find the root}

\value{ a root of the objective function which between the interwal from a to b}
\references{
Luis Torgo (2003) Data Mining with R:learning by case studies. LIACC-FEP, University of Porto
}
\author{Zheng Sengui,Lu Xufen,Hou Qiongchen,Zheng Jianhui}
\note{Maintainer:Zheng Sengui<1225620446@qq.com>
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{NDHfzero}},\code{\link{NIMfzero}},\code{\link{SMfzero}}
}
\examples{f<-function(x){x^3-x-1};f1<-function(x){3*x^2-1};

    BFfzero(f,0,2)
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (f, a, b, num = 10, eps = 1e-05) 
{
    h = abs(b - a)/num
    i = 0
    j = 0
    a1 = b1 = 0
    while (i <= num) {
        a1 = a + i * h
        b1 = a1 + h
        if (f(a1) == 0) {
            print(a1)
            print(f(a1))
        }
        else if (f(b1) == 0) {
            print(b1)
            print(f(b1))
        }
        else if (f(a1) * f(b1) < 0) {
            repeat {
                if (abs(b1 - a1) < eps) 
                  break
                x <- (a1 + b1)/2
                if (f(a1) * f(x) < 0) 
                  b1 <- x
                else a1 <- x
            }
            print(j + 1)
            j = j + 1
            print((a1 + b1)/2)
            print(f((a1 + b1)/2))
        }
        i = i + 1
    }
    if (j == 0) 
        print("finding root is fail")
    else print("finding root is successful")
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
