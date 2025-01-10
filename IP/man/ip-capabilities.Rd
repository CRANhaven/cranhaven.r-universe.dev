%%
\name{IP Capabilities}
%%
\alias{ip.capabilities}
%%
\title{Report Capabilities of this Build of the IP Package}
%%
%% 
%%
\description{
  Report on the optional features which have been compiled into this build of the IP Package.
}
%%
\value{
A named logical vector. Current components are :
  \item{AVX2}{was the IP package compiled with AVX2 support ?}
  \item{IDN}{is \link[=idn]{Internationalized domain name available} available} %%
}
%%
\seealso{
  \link{IP-package}, \link[=idn]{IDN}
}
%%
\examples{
ip.capabilities()
}
