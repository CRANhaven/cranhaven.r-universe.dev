\name{suRtex}
\alias{suRtex}
\title{
LaTeX descriptive statistic reporting for survey data
}
\description{
suRtex was designed for easy descriptive statistic reporting of categorical survey data (e.g., Likert scales) in LaTeX. suRtex takes a matrix or data frame and produces the LaTeX code necessary for a sideways table creation. Mean, median, standard deviation, and sample size are optional.
}
\usage{
suRtex(data, mean = FALSE, median = FALSE, sd = FALSE, 
n = TRUE, sub = "", digits = 2, startdoc = FALSE, 
enddoc = FALSE)
}
\arguments{
  \item{data}{
an object of class "data.frame" or "matrix". 
}
  \item{mean, median, sd, n}{
logicals. If TRUE then an additional column is added to the LaTeX table with the corresponding descriptive statistic.
}
  \item{sub}{
a character string to be used as a caption.
}
  \item{digits}{
numeric quantity describing the length of digits to display 
}
  \item{startdoc, enddoc}{
logicals. If TRUE then additional LaTeX code is displayed to make a complete LaTeX document. If FALSE then only the code required for the LaTeX sideways table is given.
}
}
\author{
Dustin Landers (http://www.intensely-curious.com)
}
\note{
suRtex assumes all variables in the data frame or matrix have equivalent levels, such as likert scales.  
}
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
