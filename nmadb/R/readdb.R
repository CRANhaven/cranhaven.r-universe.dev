#' NMA catalog
#'
#' Petropoulou et al. compiled a database of network meta-analyses to 
#' serve as a source for empirical studies Petropoulou (2016).
#' The database is hosted in a REDcap database at the 
#' Institute of Social and Preventive Medicine (ISPM) in the University of Bern.
#' Function getNMADB downloads the list of networks included in Petropoulou
#' (2016).
#'
#' @references  
#' Petropoulou M, Nikolakopoulou A A, Veroniki A, Rios P, Vafaei A,
#' Zarin W, Giannatsi M, Sullivan S, Tricco A C, Chaimani A, Egger M, Salanti G
#' (2016) <doi:10.1016/j.jclinepi.2016.11.002>.
#' 
#' @examples
#' catalog = getNMADB()
#' \dontrun{
#'   Networks that labeled Verified have outcome data 
#'   that allow the analysis to be repeated.
#' }
#' nmalist = catalog[catalog$Verified=="True",]
#' nmalist
#' @return A data.frame with the network meta-analyses included in [1]. 
#' Several characterstics related to the publications 
#' (e.g. Journal.Name, Title) are included in the data.frame.
#' @export getNMADB
getNMADB = function () {
  tryCatch({
    response <- RCurl::postForm(
      uri=NMADBURL,
      token=PUBLICTOKEN,
      content='record',
      format='csv',
      type='flat',
      rawOrLabel='label',
      csvDelimiter=';',
      rawOrLabelHeaders='label'
    )
    rfn = tempfile()
    write(file=rfn, response)
    if (file.exists(rfn)){
      catalog = utils::read.csv2(file=file(rfn), header = T, sep=";")
      file.remove(rfn)
    }else{
      stop("could not create tmp db file")
    }
    return (catalog)
  },error=function(cond){
    message(paste("could not open database connection",cond))
    return(NULL)
  })
}

#' Read NMA dataset
#'
#' ReadByID downloads the dataset and main characteristics 
#' of the specified network meta-analysis.
#' You can list all ids from the catalog by calling \code{getNMADB}.
#' 
#' @examples
#' \dontrun{
#'   Download network with id 479999
#" }
#' net = readByID(479999)
#' net$data
#' @param recid Record id of network
#' @return A list with the name (id), data (dataset), type (continuous, binary,
#' rate, survival), effect (type of measure: RR OR RR RD ...), 
#' format (long, wide, iv). 
#' \itemize{
#' \item 'long' refers to data where each row represents a study treatment arm
#' \item 'wide' refers to data where each row represents a study treatment comparison
#' \item 'iv' refers to an 'inverse variance' format, where a comparison specific 
#'   estimate of the treatment effect and its standard error are reported.  
#' }
#' @export readByID
readByID = function(recid) {
  exportData = function (recid, filename) {
    print(paste(c("getting dataset:",recid)))
    writeBin(as.vector(
                  RCurl::postForm(
                  uri=NMADBURL,
                  token=PUBLICTOKEN,
                  content='file',
                  action='export',
                  record=as.character(recid),
                  field='dataset',
                  event='',
                  returnFormat='json',
                  binary=TRUE
                )
            ), filename) 
  }
  catalog = getNMADB()
  fl = tempfile(fileext=".xlsx")
  tryCatch({
  exportData(recid,fl)
  dts = as.data.frame(readxl::read_xlsx(fl))
  dtsformat = catalog[catalog$Record.ID %in% recid,]$Format 
  dtstype = catalog[catalog$Record.ID %in% recid,]$Type.of.Outcome
  effecttype = as.character(catalog[catalog$Record.ID %in% recid,]$Effect.Measure)
  dtseffect = switch( effecttype
                    , "odds ratio"={"OR"}
                    , "risk ratio"={"RR"}
                    , "hazard ratio"={"HR"}
                    , "rate ratio"={"IRR"}
                    , "risk difference"={"RD"}
                    , "mean difference"={"MD"}
                    , "standardized mean difference"={"SMD"}
                    , "other"={"other"}
                    )
    out = dts
    return (list( name   = recid
                , data   = out
                , type   = tolower(dtstype)
                , effect = dtseffect
                , format = dtsformat))
  },error=function(cond){
    message(paste("Could not download dataset ",cond))
    return(NULL)
  })
}
