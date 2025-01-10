#' A sample of the UN Comtrade Database.
#'
#' In the following example the original base (comtrade.rda) has only 229,585
#' information on positive bilateral trade flow (greater than zero). However,
#' after expanding this base to also present the bilateral trade flow equal to
#' zero, the new base will have 1,255,892 observations (both positive and zero
#' flow). Note that the final size of the base will depend on the number of
#' years, the number of exporting and importing countries and the items present
#' in the base. Since the distinct number of exporting and importing countries
#' has an important determining factor in the expansion of the base (see the
#' examples with the distinct.rda and same.rda bases).
#'
#' @description A sample of the UN Comtrade Database prepared by the United
#' Nations Department of Statistics with official international trade
#' information.
#' @format A dataframe object.
#' @source Repository UN Comtrade.
#' @keywords comtrade sample trade international.
#' @details A dataset consisting of two years, 24 exporting countries, 24
#' importing countries, 1,241 Harmonized System codes and the value of exports
#' in dollars. The data includes the following fields:
#'
#' * ano - Numeric. Year in which exports were carried out.
#' * ido - String. ISO code corresponding to the exporting country.
#' * idd - String. ISO code corresponding to the importing country.
#' * HS4 - Numeric. HS4 code corresponding to the merchandise sold.
#' * comercio - Numeric. Dollar value of exports.
#'
#' @return a dataframe object contains the five variables passed as parameters
#' to the get_zerotradeflow() function (year, exporter, importer, item, trade)
#' including the bilateral trade flow equal to zero.
#'
#' @examples
#'
#'
#' \donttest{
#'
#' zeroflow <- get_zerotradeflow(comtrade, ano, ido, idd, HS4, comercio)
#'
#' }
#'
#'

"comtrade"

#' Dataset composed of six different countries.
#'
#' @description A dummy dataset to illustrate the final size of the base after
#' expansion.
#' @format A dataframe object.
#' @details A dataset consisting of three years, three exporting countries,
#' three importing countries, three Harmonized System code and value of
#' exports (all data is fictitious). The data includes the following fields:
#'
#' * ano - Numeric. Year in which exports were carried out.
#' * ido - String. ISO code corresponding to the exporting country.
#' * idd - String. ISO code corresponding to the importign country.
#' * HS4 - Numeric. HS4 code corresponding to the merchandise sold.
#' * comercio - Numeric. Dollar value of exports.
#'
#' @return a dataframe object contains the five variables passed as parameters
#' to the get_zerotradeflow() function (year, exporter, importer, item, trade)
#' including the bilateral trade flow equal to zero.
#'
#' @examples
#'
#' # Note that the distinct.rda base has six different countries (three
#' # exporters and three importers). Thus, when expanding this base, we have 81
#' # observations as a result.
#'
#'
#' \donttest{
#'
#' distinctflow <- get_zerotradeflow(distinct, ano, ido, idd, HS4, comercio)
#'
#' }
#'
#'

"distinct"

#' Dataset composed of five different countries (BRA appears as both exporter
#' and importer).
#'
#' @description A dummy dataset to illustrate the final size of the base after
#' expansion.
#' @format A dataframe object.
#' @details A dataset cosisting of three years, three exporting countries,
#' three importing countries, three Harmonized System code and value of exports
#' (all data is fictitious). The data includes the following fields:
#'
#' * ano - Numeric. Year in which exports were carried out.
#' * ido - String. ISO code corresponding to the exporting country.
#' * idd - String. ISO code corresponding to the importing country.
#' * HS4 - Numeric. HS4 code corresponding to the merchandise sold.
#' * comercio - Numeric. Dollar value of exports.
#'
#' @return a dataframe object contains the five variables passed as parameters
#' to the get_zerotradeflow() function (year, exporter, importer, item, trade)
#' including the bilateral trade flow equal to zero.
#'
#' @examples
#'
#' # On the other hand, in the same.rda base, Brazil (BRA) appears as both an
#' # exporter and an importer and, in this case, when expanding the base, there
#' # are 72 observations as a result.
#'
#'
#' \donttest{
#'
#' sameflow <- get_zerotradeflow(same, ano, ido, idd, HS4, comercio)
#'
#' }
#'
#'

"same"

#' Expand the dataset from the passed database as parameters.
#'
#' The zerotradeflow package allows generating the bilateral trade flow equal
#' to zero of each country pair in each year present in the database passed in
#' data parameter. Since, by default, data on bilateral trade flows of countries
#' only report positive trade flows (flows greater than zero).
#'
#' @description Creates zero bilateral trade flow for a given pair of countries.
#' @return a dataframe object contains the five variables passed as parameters
#' to the get_zerotradeflow() function (year, exporter, importer, item, trade)
#' including the bilateral trade flow equal to zero.
#' @details Function to expand the database with the bilateral trade flow equal
#' to zero, passing the following parameters:
#'
#'
#' @param data a data set containing the variables that will be used to guide
#' the expansion of the base including all possible combinations of the reference
#' variables.
#' @param year refers to the column in the database that contains information for
#' the years under review.
#' @param exporter refers to the column with the ISO codes (ISO 3166 standard -
#' Codes for the representation of names of countries and their subdivisions,
#' created and maintains by International Organization for Standardization - ISO)
#' of each exporter country (Ex.: BRA, PRT, ITA, USA,...).
#' @param importer refers to the column with the ISO codes (ISO 3166 standard -
#' Codes for the representation of names of countries and their subdivisions,
#' created and maintains by International Organization for Standardization - ISO)
#' of each importer country (Ex.: BRA, PRT, ITA, USA,...).
#' @param item refers to the column in the database that contains information
#' about Harmonized System (HS) codes, or other classification. Harmonized
#' System is an acronym for Harmonized Commodity Designation and Coding System,
#' and it is a customs nomenclature, used internationally as a standardized
#' system of coding and classification of import and export products, developed
#' and maintained by the World Customs Organization (WCO).
#' @param trade refers to the column in the database that contains information
#' about the value of exports/imports
#'
#'
#' @importFrom magrittr %>%
#' @importFrom magrittr %<>%
#' @importFrom dplyr left_join
#' @importFrom tidyr replace_na
#' @importFrom rlang :=
#' @importFrom purrr lift_vd
#' @importFrom cli cli_abort
#'
#' @export

get_zerotradeflow <- function (data, year, exporter, importer, item, trade) {

  df <- data %>% tidyr::expand ({{year}}, {{exporter}}, {{importer}}, {{item}})

  year <- deparse (substitute (year))
  exporter <- deparse (substitute (exporter))
  importer <- deparse (substitute (importer))
  item <- deparse (substitute (item))

  df %<>% left_join (data, by = c ({{year}}, {{exporter}}, {{importer}}, {{item}}))

  df %<>% dplyr::mutate ({{trade}} := replace_na ({{trade}}, 0))

  df [df [, {{exporter}}] != df [, {{importer}}], ]
}

"get_zerotradeflow"
