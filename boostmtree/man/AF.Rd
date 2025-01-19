\name{AF}
\docType{data}
\alias{AF}
\title{
Atrial Fibrillation Data
}
\description{
Atrial Fibrillation (AF) data is obtained from a randomized trial to study
the effect of surgical ablation as a treatment option for AF 
among patients with persistent and
long-standing persistent AF who requires mitral valve surgery.
Patients were randomized into two groups: mitral valve
surgery with ablation and mitral valve surgery without ablation.
Patients in the ablation group were further randomized into
two types of procedure: pulmonary vain isolation (PVI)
and biatrial maze procedure.
These patients were followed weekly for a period of 12 months. The
primary outcome of the study is the presence/absence of AF
(binary longitudinal response).
Data includes 228 patients. From 228 patients, 7949 AF measurements
are available with average of 35 measurements per patient.
}
\format{
  A list containing four elements:
  \enumerate{
    \item  The 84 patient variables (features).
    \item  Time points (time).
    \item  Unique patient identifier (id).
    \item  Presence or absence of AF (y).
  }
}
\references{
Gillinov A. M., Gelijns A.C., Parides M.K., DeRose J.J.Jr.,
Moskowitz~A.J. et al. Surgical ablation of atrial fibrillation during mitral
valve surgery.
\emph{The New England Journal of Medicine} 372(15):1399--1408, 2015.
}
\examples{data(AF, package = "boostmtree")}
\keyword{datasets}
