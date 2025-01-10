#' Update the Package Datasets
#' @export
#' @description Checks if new data is available on the package dev version (Github).
#' In case new data is available the function will enable the user the update the datasets
#'
#' @return Check the github repository for updates
#'
#' @example
#'
#' \dontrun{
#'
#' update_data()
#'
#' }
update_data <- function() {
  flag <- FALSE

  total_current <- covid19brazil::brazil_total
  region_current <- covid19brazil::brazil_region
  state_current <- covid19brazil::brazil_state
  municipality_current <- covid19brazil::brazil_municipality

  total_git <- dplyr::as_tibble (load ('https://raw.githubusercontent.com/alexandreloures/covid19Brazil/main/data/brazil_total.rda'
                                       )
                                 )


  region_git <- dplyr::as_tibble (load ('https://raw.githubusercontent.com/alexandreloures/covid19Brazil/main/data/brazil_region.rda'
                                        )
                                  )


  state_git <- dplyr::as_tibble (load ('https://raw.githubusercontent.com/alexandreloures/covid19Brazil/main/data/brazil_state.rda'
                                       )
                                 )


  municipality_git <- dplyr::as_tibble (load ('https://raw.githubusercontent.com/alexandreloures/covid19Brazil/main/data/brazil_municipality.rda'
                                              )
                                        )

  if (!base::identical (dim (total_git), dim (total_current))) {
    if (base::nrow (total_git) > base::nrow (total_current)) {
      flag <- TRUE
    }
  }

  if (!base::identical (dim(region_git), dim (region_current))) {
    if (base::nrow (region_git) > base::nrow (region_current)) {
      flag <- TRUE
    }
  }

  if (!base::identical (dim (state_git), dim (state_current))) {
    if (base::nrow (state_git) > base::nrow (state_current)) {
      flag <- TRUE
    }
  }

  if (!base::identical (dim(municipality_git), dim (municipality_current))) {
    if (base::nrow (municipality_git) > base::nrow (municipality_current)) {
      flag <- TRUE
    }
  }

  if (flag) {
    q <- base::tolower (base::readline ('Updates are available on the covid19brazil Dev version, do you want to update? n/Y'))

    if (q == 'y' | q == 'yes' | q == 'Y' | q == 'Yes') {

      base::tryCatch (
        expr = {
      devtools::install_github ('alexandreloures/covid19Brazil')

          base::message ('The data was refresed, please restart your session to have the new data available')
        },
      error = function (e) {
        message('Caught an error!')
        print (e)
      },
      warning = function (w) {
        message('Caught an warning!')
        print (w)
      }

      )
    }
  } else {
    base::message ('No updates are available')
  }


}
