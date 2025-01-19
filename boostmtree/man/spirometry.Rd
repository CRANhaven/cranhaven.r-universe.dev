\name{spirometry}
\docType{data}
\alias{spirometry}
\title{Spirometry Data}
\description{
    Data consists of 9471 longitudinal evaluations of forced 1-second
    expiratory volume (FEV1-percentage of predicted) after lung
    transplant from 509 patients who underwent lung transplant (LTx) at
    the Cleveland Clinic.  Twenty three patient/procedure variables were
    collected at the time of the transplant.  The major objectives are
    to evaluate the temporal trend of FEV1 after LTx, and to identify
    factors associated with post-LTx FEV1 and assessing the differences
    in the trends after Single LTx versus Double LTx. 
}
\format{
  A list containing four elements:
  \enumerate{
    \item  The 23 patient variables (features).
    \item  Time points (time).
    \item  Unique patient identifier (id).
    \item  FEV1-outcomes (y).
  }
}
\references{
  Mason D.P., Rajeswaran J., Li L., Murthy S.C., Su J.W., Pettersson G.B.,
  Blackstone E.H. Effect of changes in postoperative spirometry on
  survival after lung transplantation. \emph{J. Thorac. Cardiovasc. Surg.},
  144:197-203, 2012.
}
\examples{data(spirometry, package = "boostmtree")}
\keyword{datasets}
