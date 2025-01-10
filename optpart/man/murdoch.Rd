\name{murdoch}
\alias{murdoch}
\alias{summary.murdoch}
\alias{plot.murdoch}
\alias{print.murdoch}

\title{Indicator Species Analysis by Murdoch Preference Function}
\description{Calculates the indicator value 
of species in a single cluster or environment type using the Murdoch Preference Function}

\usage{
murdoch(comm,type,minval=0,minplt=10)
\method{summary}{murdoch}(object,pval=0.05,digits=3,\dots)
\method{plot}{murdoch}(x,axtype=1,pval=0.05,\dots)
\method{print}{murdoch}(x,digits = 5, ...)
}

\arguments{
    \item{comm}{a matrix or data.frame of samples with species as columns and
               samples as rows}
    \item{type}{a logical vector with values of TRUE for samples in a specific cluster
                 or type}
    \item{minval}{a threshold minimum abundance value to count as a presence}
    \item{minplt}{the minimum number of presences to include a species in the calculation}
    \item{object}{and object of class \sQuote{murdoch}}
    \item{pval}{the maximum probability to include a species in the summary table}
    \item{digits}{the number of digits to report}
    \item{\dots}{ancillary arguments to maintain compatibility with the generic summary function}
    \item{x}{an object of class \sQuote{murdoch}}
    \item{axtype}{a switch to control scaling of the x axis in the plot.  1=number of plots in the 
    data set, other = number of presences in the type}
    
}
\details{Calculates the indicator value of species for a specific type using the modified Murdoch
statistic:
\deqn{log((p/a) * (n-p_i)/n_i)}
where:
  \eqn{p} = number of samples where species is present,
  \eqn{a} = number of samples where species is absent,
  \eqn{n} = total number of samples (p+a),
  \eqn{p_i} = number of samples in type i where species is present,
  \eqn{n_i} = number of samples in type i.

Probabilities are based on the hypergeometric distribution calculation of 
having as many or more presences in a type as observed.}

\value{a list object of class \sQuote{murdoch} with components:
    \item{minplt}{the minimum number of presences to be included}
    \item{nplots}{the number of plots a species occurs in}
    \item{type}{the plot membership vector for the type}
    \item{pres}{the number of presences for species in the type} 
    \item{abs}{the number of absences of species in the type}
    \item{murdoch}{the Murdoch value for species in the type}
    \item{pval}{the probability of getting such a high murdoch value}
}

\note{Indicator value analysis is a set of techniques designed to identify
species of special interest in clusters or types.  The most widely used indicator species
analysis was proposed by Dufrene and Legendre (1997), and is included in package
\sQuote{labdsv} as \code{\link[labdsv]{indval}}. murdoch differs significantly from
indval in assumption and objective, seeking to identify species that have improbable occurrences
in types, regardless of their relative frequency in the type}

\author{
    David W. Roberts with help from Ken Aho
    \email{droberts@montana.edu}
    \url{http://ecology.msu.montana.edu/labdsv/R}
}

\seealso{\code{\link[labdsv]{indval}}, \code{\link[optpart]{tabdev}}}

\examples{
data(shoshveg)                           # returns a vegetation dataframe
dis.bc <- dsvdis(shoshveg,'bray/curtis') # returns a dissimilarity 
                                         #   matrix
opt.5 <- optpart(5,dis.bc)
plot(murdoch(shoshveg,opt.5$clustering==1))
}
\keyword{cluster}
