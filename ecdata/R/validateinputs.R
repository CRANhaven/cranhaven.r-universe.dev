#' Get latest release 
#' keywords @internal 
#' @returns No return. This function is meant to check the inputs of the load_ecd function
#' @noRd




get_ecd_release = function(){
  
 ecd_versions = piggyback::pb_releases(repo = 'Executive-Communications-Dataset/ecdata')
  
 versions = ecd_versions$release_name 
 

return(versions)
}



#' Validate input parameters
#' keywords @internal 
#' @noRd

validate_inputs = function(country = NULL,language = NULL, full_ecd = FALSE, version = '1.0.0'){
 
  versions = get_ecd_release()

  countries = country_dictionary()

  countries = countries |>
    within({
      name_in_dataset = tolower(name_in_dataset)
      language = tolower(language)
      abbr = tolower(abbr)
    })


  arrow_check = rlang::is_installed(pkg = 'arrow')

  parquet_check = arrow::arrow_info()$capabilities[4]
   
  country_lower = tolower(country)

  check_country = countries$name_in_dataset

  check_language = countries$language

  lower_lang = tolower(language)

  check_abr = countries$abbr


  invalid_countries = any(country_lower %in% check_country)

  invalid_abr = any(country_lower %in%  check_abr)


  invalid_language = any(lower_lang %in% check_language)




  if(isTRUE(is.null(country)) && full_ecd == FALSE && isTRUE(is.null(language))){

   cli::cli_abort('Please provide a country name, a language, or set full_ecd to TRUE')

  }

  if(!isTRUE(is.character(country)) && full_ecd == FALSE && isTRUE(is.null(language))){

    country_type = typeof(country)

    cli::cli_abort('Country should be a character vector but is {country_type}')


  }

  if(!isTRUE(is.character(language)) && full_ecd == FALSE && isTRUE(is.null(country))){

    lang_type = typeof(language)

    cli::cli_abort('Language should be a character vector but is {lang_type}')

  }

  if(!version %in% versions){


   cli::cli_abort('Stop version is {version} please set it to one of {versions}')


  }
  if(invalid_countries == FALSE && invalid_abr == FALSE && !isTRUE(is.null(country)) && isTRUE(is.null(language))){

    countries = country_dictionary()$name_in_dataset

    countries_not_in_dataset = setdiff(country, countries)

    cli::cli_abort('{countries_not_in_dataset} is not in our dataset. Call ecd_country_dictionary() for a list of valid country names')



  }

  if(invalid_language == FALSE &&  !isTRUE(is.null(language)) && isTRUE(is.null(country))){ 

   langs = country_dictionary()$language

   lang_not_in_dataset = setdiff(language, langs)

   cli::cli_abort("{lang_not_in_dataset} is not in our dataset. Call ecd_country_dictionary for a list of valid languages")
  }

  if(!isTRUE(arrow_check)){

    cli::cli_abort("Arrow is not installed please install arrow")

  }

  if(!isTRUE(arrow_check) && Sys.info()['sysname'] == 'Darwin'){

   cli::cli_abort('Parquet support was not detected and it looks like you are on a Mac. This is usually resolved by installing the development version of arrow. Please run \n install.packages("arrow", repos = "https://apache.r-universe.dev") ')

  }



  }




