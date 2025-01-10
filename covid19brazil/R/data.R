#' The dataset with information about the new Coronavirus (COVID-19) for Brazil
#'
#' @description  Daily information about the new Coronavirus (COVID-19) pandemic in Brazil
#'
#' @format A data.frame object
#' @source Ministerio da Saude - Sistema Unico de Saude (SUS) \href{https://www.gov.br/saude/pt-br}{website}
#' @keywords datasets coronavirus COVID-19 Brazil sars-cov-2
#' @details The dataset contains the daily summary of the Coronavirus pandemic cases in Brazil. The data includes the following fields:
#'
#' * region - String. Indicates the country of coverage
#'
#' * date - Date. Ocurrence notification date
#'
#' * epidWeek - Numeric. Epidemiological week of ocurrence by notification date
#'
#' * population - Numeric. Population size at the date of ocurrence notification
#'
#' * accumCases - Numeric. Cumulative cases of COVID-19 by notification date
#'
#' * newCases - Numeric. Number of new COVID-19 cases by notification date
#'
#' * accumDeaths - Numeric. Accumulated COVID-19 deaths by notification date
#'
#' * newDeaths - Numeric. Number of new COVID-19 deaths by notification date
#'
#' * newRecov - Numeric. Number of new recovered COVID-19 patients by notification date
#'
#' * followUp - Numeric. Number of new COVID-19 cases being followed up by notification date
#'
#' @return load the database for the current environment
#'
#' @examples
#'
#' data (brazil_total)
#'

"brazil_total"


#' The dataset with information on the new Coronavirus (COVID-19) for the five regions of Brazil
#'
#' @description  Daily information about the new Coronavirus (COVID-19) pandemic in Brazil's regions
#'
#' @format A data.frame object
#' @source Ministerio da Saude - Sistema Unico de Saude (SUS) \href{https://www.gov.br/saude/pt-br}{website}
#' @keywords datasets coronavirus COVID-19 Brazil sars-cov-2
#' @details The dataset contains the daily summary of the Coronavirus pandemic cases in Brazil's regions. The data includes the following fields:
#'
#' * region - String. Indicates the regions coverage (Centro-Oeste, Nordeste, Norte, Sudeste, Sul)
#'
#' * date - Date. Ocurrence notification date
#'
#' * epidWeek - Numeric. Epidemiological week of ocurrence by notification date
#'
#' * population - Numeric. Population of the size, of each region, on the date of notification of the ocurrence
#'
#' * accumCases - Numeric. Cumulative cases of COVID-19 by notification date
#'
#' * newCases - Numeric. Number of new COVID-19 cases by notification date
#'
#' * accumDeaths - Numeric. Accumulated COVID-19 deaths by notification date
#'
#' * newDeaths - Numeric. Number of new COVID-19 deaths by notification date
#'
#' @return load the database for the current environment
#'
#' @examples
#'
#' data (brazil_region)
#'

"brazil_region"


#' The dataset with information on the new Coronavirus (COVID-19) for the twenty-seven states of Brazil
#'
#' @description  Daily information about the new Coronavirus (COVID-19) pandemic in Brazil's states
#'
#' @format A data.frame object
#' @source Ministerio da Saude - Sistema Unico de Saude (SUS) \href{https://www.gov.br/saude/pt-br}{website}
#' @keywords datasets coronavirus COVID-19 Brazil sars-cov-2
#' @details The dataset contains the daily summary of the Coronavirus pandemic cases in Brazil's states. The data includes the following fields:
#'
#' * region - String. Indicates to which region the state belongs
#'
#' * state - String. Acronym (abbreviation) for state name
#'
#' * coduf - Numeric. Number that identifies the state
#'
#' * date - Date. Ocurrence notification date
#'
#' * epidWeek - Numeric. Epidemiological week of ocurrence by notification date
#'
#' * population - Numeric. Population of the size, of each state, on the date of notification of the ocurrence
#'
#' * accumCases - Numeric. Cumulative cases of COVID-19 by notification date
#'
#' * newCases - Numeric. Number of new COVID-19 cases by notification date
#'
#' * accumDeaths - Numeric. Accumulated COVID-19 deaths by notification date
#'
#' * newDeaths - Numeric. Number of new COVID-19 deaths by notification date
#'
#' @return load the database for the current environment
#'
#' @examples
#'
#' data (brazil_state)
#'

"brazil_state"


#' The dataset with information on the new Coronavirus (COVID-19) for the 5,570 municipalities in Brasil
#'
#' @description  Daily information about the new Coronavirus (COVID-19) pandemic cases in Brazil's municipalities
#'
#' @format A data.frame object
#' @source Ministerio da Saude - Sistema Unico de Saude (SUS) \href{https://www.gov.br/saude/pt-br}{website}
#' @keywords datasets coronavirus COVID-19 Brazil sars-cov-2
#' @details The dataset contains the daily summary of the Coronavirus pandemic cases in Brazil's municipalities. The data includes the following fields:
#'
#' * region - String. Indicates to which region the municipality belongs
#'
#' * state - String. Indicates to which state the municipality belongs
#'
#' * municipality - String. Municipality name
#'
#' * coduf - Numeric. Number that identifies the state
#'
#' * codmun - Numeric. Number that identifies the municipality
#'
#' * date - Date. Ocurrence notification date
#'
#' * epidWeek - Numeric. Epidemiological week of ocurrence by notification date
#'
#' * population - Numeric. Population of the size, of each municipality, on the date of notification of the ocurrence
#'
#' * accumCases - Numeric. Cumulative cases of COVID-19 by notification date
#'
#' * newCases - Numeric. Number of new COVID-19 cases by notification date
#'
#' * accumDeaths - Numeric. Accumulated COVID-19 deaths by notitication date
#'
#' * newDeaths - Numeric. Number of new COVID-19 deaths by notification date
#'
#' @return load the database for the current environment
#'
#' @examples
#'
#' data (brazil_municipality)
#'

"brazil_municipality"
