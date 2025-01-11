#' adding this is just to grab the 
#' keywords @internal 
#' @returns a data frame with the country names, languages, and abbreviations for building links.
#' @noRd

  
  country_dictionary = \(){
  
    country_names = data.frame(
      file_name = rep(
        c(
          "argentina", "australia", "austria", "azerbaijan", "bolivia", "brazil",
          "canada", "chile", "colombia", "costa_rica", "czechia", "denmark",
          "dominican_republic", "ecuador", "france", "georgia", "germany", "greece",
          "hong_kong", "hungary", "iceland", "india", "indonesia", "israel", "italy",
          "jamaica", "japan", "mexico", "new_zealand", "nigeria", "norway",
          "philippines", "poland", "portugal", "russia", "spain", "turkey",
          "united_kingdom", "uruguay", "venezuela", "united_states_of_america",
          "republic_of_korea"
        ),
        rep(
          c(2L, 4L, 2L, 4L, 2L, 4L, 2L, 6L, 2L, 4L),
          c(3L, 1L, 17L, 1L, 12L, 1L, 2L, 1L, 2L, 2L)
        )
      ),
      language = rep(
        c(
          "Spanish", "English", "German", "English", "Spanish", "Portugese", "English",
          "Spanish", "Czech", "Danish", "Spanish", "French", "Georgian", "German",
          "Greek", "Chinese", "Hungarian", "Icelandic", "English", "Hindi",
          "Indonesian", "Hebrew", "Italian", "English", "Japanese", "Spanish",
          "English", "Norwegian", "Filipino", "Polish", "Portugese", "English",
          "Spanish", "Turkish", "English", "Spanish", "English", "Korean"
        ),
        rep(
          c(2L, 4L, 2L, 6L, 2L, 4L, 2L, 4L, 2L, 4L, 2L, 6L, 4L),
          c(3L, 1L, 3L, 1L, 2L, 1L, 15L, 1L, 4L, 1L, 2L, 1L, 3L)
        )
      ),
      abbr = c(
        "ARG", "AR", "AUS", "AU", "AUT", "AT", "AZE", "AZ", "AZE", "AZ", "BOL", "BO",
        "BRA", "BR", "CAN", "CA", "CHL", "CL", "COL", "CO", "CRI", "CR", "CZE", "CZ",
        "DNK", "DK", "DOM", "DO", "ECU", "EC", "FRA", "FR", "GEO", "GE", "DEU", "DE",
        "GRC", "GR", "HKG", "HK", "HUN", "HU", "ISL", "IS", "IND", "IN", "IND", "IN",
        "IDN", "ID", "ISR", "IL", "ITA", "IT", "JAM", "JM", "JPN", "JP", "MEX", "MX",
        "NZL", "NZ", "NGA", "NG", "NOR", "NO", "PHL", "PH", "POL", "PL", "PRT", "PT",
        "RUS", "RU", "RUS", "RU", "ESP", "ES", "TUR", "TR", "GBR", "GBR", "GB", "GB",
        "UK", "UK", "URY", "UY", "VEN", "VE", "USA", "USA", "US", "US", "KOR", "KOR",
        "KR", "KR"
      ),
      name_in_dataset = c(
        "Argentina", "Argentina", "Australia", "Australia", "Austria", "Austria",
        "Azerbaijan", "Azerbaijan", "Azerbaijan", "Azerbaijan", "Bolivia", "Bolivia",
        "Brazil", "Brazil", "Canada", "Canada", "Chile", "Chile", "Colombia",
        "Colombia", "Costa Rica", "Costa Rica", "Czechia", "Czechia", "Denmark",
        "Denmark", "Dominican Republic", "Dominican Republic", "Ecuador", "Ecuador",
        "France", "France", "Georgia", "Georgia", "Germany", "Germany", "Greece",
        "Greece", "Hong Kong", "Hong Kong", "Hungary", "Hungary", "Iceland",
        "Iceland", "India", "India", "India", "India", "Indonesia", "Indonesia",
        "Israel", "Israel", "Italy", "Italy", "Jamaica", "Jamaica", "Japan", "Japan",
        "Mexico", "Mexico", "New Zealand", "New Zealand", "Nigeria", "Nigeria",
        "Norway", "Norway", "Philippines", "Philippines", "Poland", "Poland",
        "Portugal", "Portugal", "Russia", "Russia", "Russia", "Russia", "Spain",
        "Spain", "Turkey", "Turkey", "United Kingdom", "Great Britain",
        "United Kingdom", "Great Britain", "United Kingdom", "Great Britain",
        "Uruguay", "Uruguay", "Venezuela", "Venezuela", "United States of America",
        "United States", "United States of America", "United States",
        "Republic of Korea", "South Korea", "Republic of Korea", "South Korea"
      )
    )
    
  
    
  
  for (i in 2:4) {
  
    country_names[[i]] = trimws(country_names[[i]])
    
  }
  
  return(country_names)
  
  }


