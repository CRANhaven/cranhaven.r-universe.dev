#' Reading Executive Communications Dataset lazily
#'  
#' This function imports data from the ECD lazily meaning the data is out loaded out of memory
#' @param country a character vector  with a country or countries in our dataset to download. 
#' @param language a character vector with a lanaguage or languages in our dataset to download. 
#' @param full_ecd to download the full Executive Communications Dataset set full_ecd to TRUE
#' @param ecd_version a character of ecd versions. 
#' @returns A tibble with the specified country/countries or language/languages
#' @importFrom curl multi_download
#' @export
#' @examples
#' \donttest{
#' library(ecdata)
#' 
#' ## load one country 
#' 
#' load_ecd(country = 'United States of America')
#' 
#' ## displays data from the USA
#' 
#' 
#' ## load multiple countries 
#' 
#' load_ecd(country = c('Turkey', 'Republic of South Korea', 'India'))
#'
#' ## displays data from Turkey, South Korea, and India
#' 
#' # load full ecd 
#' 
#' 
#' load_ecd(full_ecd = TRUE)
#' }
#' 


lazy_load_ecd = function(country=NULL, language=NULL , full_ecd=FALSE, ecd_version = '1.0.0'){

  validate_inputs(country = country ,language = language, full_ecd = full_ecd,version = ecd_version)

  cache_message()

  tmp = tempdir()

  if(full_ecd == TRUE && isTRUE(is.null(country)) && isTRUE(is.null(language))){
  
  
  url <- glue::glue('https://github.com/Executive-Communications-Dataset/ecdata/releases/download/{ecd_version}/full_ecd.parquet')
  
  multi_download(url, file.path(tmp, basename(url)))
  
  ecd_data <- arrow::open_dataset(tmp)
    
  if(nrow(ecd_data) > 0){
    cli::cli_alert_success('Successfully downloaded the full ECD. To bring data into memory call dplyr::collect')

  }
  else{

    cli::cli_alert_danger('Download of ECD  failed')
  }
    
  }
  

if(full_ecd == FALSE && !isTRUE(is.null(country)) && isTRUE(is.null(language))){
  

      links_to_read <- link_builder(country = country, ecd_version = ecd_version)

      multi_download(links_to_read, file.path(tmp, basename(links_to_read)))

      ecd_data = arrow::open_dataset(tmp)
   
if(nrow(ecd_data) > 0){

  cli::cli_alert_success('Note: Data for: {country} was successfully downloaded. To bring data into memory call dplyr::collect()')
}

  

}

if(full_ecd == FALSE && isTRUE(is.null(country)) && !isTRUE(is.null(language))){

     
    if('English' %in% language){
      cli::cli_alert_info('One of the languages in language is set to English. Note due to data availability Azerbaijan and Russian will be included in this data')
    }

    links_to_read = link_builder(language = language, ecd_version = ecd_version)
    
    multi_download(links_to_read, file.path(tmp, basename(links_to_read)))

    ecd_data = arrow::open_dataset(tmp)
   
    if(nrow(ecd_data) > 0){

      cli::cli_alert_success('Note: Data for: {language} was successfully downloaded. To bring data into memory call dplyr::collect()')
    }

  }
    
if(full_ecd == FALSE && !isTRUE(is.null(country)) && !isTRUE(is.null(language))){

     links_to_read = link_builder(country = country, language = language)
    
     multi_download(links_to_read, file.path(tmp, basename(links_to_read)))

      ecd_data = arrow::open_dataset(tmp)

      if(nrow(ecd_data) > 0){
        
        cli::cli_alert_success('Note: Data for: {language} and {country} were successfully downloaded. To bring data into memory call dplyr::collect')

      }
  
    }

  
    return(ecd_data)
  
}