\name{gdi}
\alias{gdi}
\docType{data}
\title{
%%   ~~ data name/kind ... ~~
Investment in advanced countries. }
\description{
%%  ~~ A concise (1-5 lines) description of the dataset. ~~
Gross domestic investment as a share of GDP (in percent) for 25 high income OECD countries, 1973-2013.
Retrieved from the World Development Indicators Worldbank Database.
}
\usage{data(gdi)}
\format{
  The format is:
 num [1:41, 1:25] 29.1 28.6 25.9 26.3 25.9 ...
 - attr(*, "dimnames")=List of 2
  ..$ : chr [1:41] "X1973..YR1973." "X1974..YR1974." "X1975..YR1975." "X1976..YR1976." ...
  ..$ : chr [1:25] "AUS" "AUT" "BEL" "CAN" ...
}
\details{
%%  ~~ If necessary, more details than the __description__ above ~~
Gross fixed capital formation (percent of GDP), "Gross fixed capital formation (NE.GDI.FTOT.ZS, formerly gross domestic fixed investment).", "World Bank national accounts data, and OECD National Accounts data files."
}
\source{
%%  ~~ reference to a publication or URL from which the data were obtained ~~
http://databank.worldbank.org/data/reports.aspx?source=world-development-indicators
}
\references{
%%  ~~ possibly secondary sources and usages ~~
The World Bank: Dataset name: Gross fixed capital formation (percent of GDP). 
}
\examples{
data(gdi)
plot(gdi)
## maybe str(gdi) ; plot(gdi) ...
}
\keyword{datasets}
