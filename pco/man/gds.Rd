\name{gds}
\alias{gds}
\docType{data}
\title{
%%   ~~ data name/kind ... ~~
Savings in advanced countries.
}
\description{
%%  ~~ A concise (1-5 lines) description of the dataset. ~~
Gross domestic savings as a share of GDP (in percent) for 25 high income OECD countries, 1973-2013.
Retrieved from the World Development Indicators Worldbank Database.
}
\usage{data(gds)}
\format{
  The format is:
 num [1:41, 1:25] 31.5 30.5 26.4 26.6 26.4 ...
 - attr(*, "dimnames")=List of 2
  ..$ : chr [1:41] "X1973..YR1973." "X1974..YR1974." "X1975..YR1975." "X1976..YR1976." ...
  ..$ : chr [1:25] "AUS" "AUT" "BEL" "CAN" ...
}
\details{
%%  ~~ If necessary, more details than the __description__ above ~~
Gross domestic savings (percent of GDP), Gross domestic savings (NY.GDS.TOTL.ZS) are calculated as GDP less final consumption expenditure (total consumption)., "World Bank national accounts data, and OECD National Accounts data files."
}
\source{
%%  ~~ reference to a publication or URL from which the data were obtained ~~
http://databank.worldbank.org/data/reports.aspx?source=world-development-indicators
}
\references{
%%  ~~ possibly secondary sources and usages ~~
The World Bank: Dataset name: Gross domestic savings (percent of GDP). 
}
\examples{
data(gds)
plot(gds)
## maybe str(gds) ; plot(gds) ...
}
\keyword{datasets}
