#' Build our links 
#' 
#' @keywords internal
#' @returns A glue string with the correct links to the Github data.
#' @export
#' 


link_builder = \(country = NULL, language = NULL, ecd_version){

  if(!isTRUE(is.null(country)) && isTRUE(is.null(language))){
  
    countries = country_dictionary()

    countries = countries |>
      within({
        name_in_dataset = tolower(name_in_dataset)
        abbr = tolower(abbr)
      })
    
    country_lower = tolower(country)
  
    country_names = countries[countries$name_in_dataset %in% country_lower | countries$abbr %in% country_lower,]


  
    country_names = country_names |>
      within({
        
        file_names = glue::glue('https://github.com/Executive-Communications-Dataset/ecdata/releases/download/{ecd_version}/{file_name}.parquet')
      }) 
       
    
      country_names = country_names$file_names
    
      country_names = unique(country_names)
  
  }
    
  if(isTRUE(is.null(country)) && !isTRUE(is.null(language))){
  
    countries = country_dictionary()

    countries = countries |>
      within({
        language = tolower(language)
      })
    
    lang_lower = tolower(language)
  
    country_names = countries[countries$language %in% lang_lower,]

  
    country_names = country_names |>
      within({
        file_names = glue::glue('https://github.com/Executive-Communications-Dataset/ecdata/releases/download/{ecd_version}/{file_name}.parquet')
      })
    
      country_names = country_names$file_names
      country_names = unique(country_names)
  
  }
    
    if(!isTRUE(is.null(country)) && !isTRUE(is.null(language))){
  
      countries = country_dictionary()

      countries = countries |>
        within({
          name_in_dataset = tolower(name_in_dataset)
          language = tolower(language)
          abbr = tolower(abbr)
        })
      
        lang_lower = tolower(language)
      
        country_lower = tolower(country)
        
  
       country_names = countries[countries$language %in% lang_lower | countries$name_in_dataset %in% country_lower |
                                 countries$abbr %in% country_lower,]
        
      

      country_names = country_names |>
        within({
          file_names = glue::glue('https://github.com/Executive-Communications-Dataset/ecdata/releases/download/{ecd_version}/{file_name}.parquet')
        })
      
      
        country_names = country_names$file_names
       
        country_names = unique(country_names)
  
    }
    
   
  
    return(country_names)
  
  }

#' keywords @internal 
#' @returns A cache message
#' @noRd
#' 

  cache_message = function(){
    do_it <- getOption("ecdata.verbose", default = interactive()) && getOption("ecdata.cache_warning", default = interactive())
     
     if(isTRUE(do_it)){
     rlang::inform(
       message = c(
         "Note: ecdata cache (i.e., stores a saved version) data by default. \n If you expect different outputs try one of the following:",
         i  = 'Restart your R session or',
         i = "Run ecdata::.clear_cache()",
         "To disable this warning, run `options(ecddata.verbose = FALSE)` of add it to your .Rprofile"
       ),
       .frequency = "regularly",
       .frequency_id = "cache_messages"
     )
   
     }
   
   
   }
    