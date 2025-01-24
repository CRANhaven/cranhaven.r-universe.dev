#' Connect and pull/get data from a DHIS2 instance
#' @format An R6 class called Dhis2r.
#' @description
#' To create a DHIS2 connection, you need a DHIS2 base URL, username, password, and an API version
#' The R6 Class called `Dhis2r` representing a DHIS2 instance connection
#'
#' @details
#' You can use a DHIS2 instance connection to get data several times without needing to manually supply your user credentials on each API call.
#'
#' @export
#'
#' @examplesIf interactive() && curl::has_internet()
#'
#' # Load dhis2r
#' library(dhis2r)
#' # connect to the DHIS2 instance
#' dhis2_play_connection <- Dhis2r$new(base_url = "https://play.im.dhis2.org/stable-2-40-5",
#' username = "admin",
#' password = "district")
#'
#' # get all the available resources
#' dhis2_play_connection$get_metadata()
#'
#' # get organisation Units with the default fields i.e c("name","id")
#'
#' dhis2_play_connection$get_metadata(endpoint = "organisationUnits")
#'
#' # get a vector of all possible fields of a organisation unit resource
#' dhis2_play_connection$get_metadata_fields(endpoint = "organisationUnits")
#'
#' # get organisation Units with additional fields i.e c("name","id", "level")
#'
#' dhis2_play_connection$get_metadata(endpoint = "organisationUnits",
#' fields =  c("name","id", "level"))
#'
#' dhis2_play_connection$get_analytics(analytic = c("Uvn6LCg7dVU"),
#' org_unit =   c("O6uvpzGd5pu", "fdc6uOvgoji"),
#' period = "LAST_12_MONTHS",
#'  output_scheme = "NAME")
#'
#'

Dhis2r <- R6::R6Class(

  "Dhis2r",
  public = list(


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @field request_sent The request used to perform an API call
    #' @field name Name of the user
    #' @field  access_rights The access rights the user has on the DHIS2 instance
    #' @field account_info Information of the logged account credentials
    #'
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    request_sent = NULL,
    name = NULL,
    access_rights = NULL,
    account_info = NULL,
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description
    #' Create a connection to a DHIS2 instance using basic authentication
    #' @param base_url Base url e.g https://play.dhis2.org/
    #' @param username Registered username e.g "admin"
    #' @param password Registered password e.g "district"
    #' @param api_token Personal Access Token (PAT) to use instead of username and password
    #' @param api_version The api version e.g "33"
    #' @param api_version_position position where the api_version is after or before in web API url i.e /api/
    #' @return A new `Dhis2r` object
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initialize = function(base_url , username = NULL,  password = NULL, api_token = NULL, api_version = NULL, api_version_position = c("after", "before")) {

      api_version_position <- match.arg(api_version_position)

      args <- list(base_url = base_url, api_version_position = api_version_position)
      #Check that at least one argument is not null

      attempt::stop_if_any(args, is.null,"You need to specify all arguements")
      attempt::stop_if_none(args, is.character, "All arguements should be type character")

      if(is.null(api_token)){
        up <- list(username = username, password = password)
        attempt::stop_if_any(up, is.null,"You need to specify either api_token or both, username and password")
        attempt::stop_if_none(up, is.character, "The username and password argument should be type character")
        self$request_sent <- request(base_url = base_url) |>
          req_auth_basic(username = username, password = password )
      }else if(!is.character(api_token)) {
        stop("The api_token argument should be type character")
      }
      else {
        self$request_sent <- request(base_url = base_url) |>
          req_headers("Authorization" = paste("ApiToken", api_token, sep=" "))
      }


      if(is.null(api_version)){
        self$request_sent <- self$request_sent |>
          req_url_path_append("api")


      }else if(!is.null(api_version) &  api_version_position == "before"){

        self$request_sent <- self$request_sent |>
          req_url_path_append(api_version) |>
          req_url_path_append("api")


      }else if(!is.null(api_version) &  api_version_position == "after"){

        self$request_sent <- self$request_sent |>
          req_url_path_append("api") |>
          req_url_path_append(api_version)

      }

      self$request_sent <-  self$request_sent |>
      #  req_url_query(paging = "false") |>
        req_headers("Accept" = "application/json") |>
        httr2::req_user_agent("dhis2r (http://www.dhis2r.amanyiraho.com/") |>
        httr2::req_retry(max_tries = 5)

    },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description
    #' Get information of the logged in user
    #'
    #' @return A vector
    #'
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    get_user_info =  function() {
                  # Check for internet
        if(has_internet()){

          response_object <- self$request_sent  |>
            req_url_path_append("me") |>
           # req_error(body = dhis2_error_message) |>
            req_perform()

          message(response_object$url)

          response_data  <-  response_object |>
            resp_body_json(simplifyVector = TRUE)

          self$access_rights <- unlist(response_data[["access"]])

          self$account_info <- unlist(list(response_data[["userCredentials"]][["createdBy"]][c("name", "username")], response_data["created"]))

          unlist( list( response_data["name"],
                        response_data["phoneNumber"],
                        response_data["email"]))


        }else{
          message("No internet connection!")
        }
      },
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #' @description
    #' Get metadata about any available resource from a DHIS2 instance e.g "dataElements",
    #' "organisationUnits", "indicators", "periodTypes"
    #'
    #' @return A data frame
    #'
    #' @param endpoint a resource, get the available resources using `get_metadata()` without any arguments
    #' @param fields The specific columns to be return in the dataframe e.g c("name","id")
    #'
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    get_metadata = function(endpoint = NULL, fields = c("name","id")) {


      if(has_internet()){

        if(is.null(endpoint)){

          response_object <- self$request_sent |>
            req_url_path_append("resources") |>
            req_perform()

          message(response_object$url)

          response_data  <-  response_object |>
            resp_body_json(simplifyVector = TRUE)

          tibble::tibble(response_data$resources)

        }else{


          attempt::stop_if_not(endpoint, is.character, "endpoint should be type character")

          response_object <- self$request_sent |>
            req_url_path_append(endpoint) |>
            req_url_query(fields = paste0(fields, collapse = ",")) |>
            req_perform()

          message(response_object$url)


          response_data  <-  response_object |>
            resp_body_json(simplifyVector = TRUE)

          tibble::tibble( response_data[[endpoint]])

        }

      }else{
        message("No internet connection!")
      }
      },
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #' @description Get all possible fields for a specific metadata resource from a DHIS2 instance
    #'
    #' @return A vector of all possible fields for a specific metadata
    #'
    #' @param endpoint a resource, get the available resources using `get_metadata()` without any arguments
    #'
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    get_metadata_fields = function(endpoint) {
      # Check for internet

      if(has_internet()){

        attempt::stop_if(endpoint, is.null, "endpoint shouldnot be NULL")
        attempt::stop_if_not(endpoint, is.character, "endpoint should be type character")

        response_object <- self$request_sent |>
          req_url_path_append(endpoint) |>
          req_url_query(fields = ":all") |>
          req_url_query(paging = "true") |>
          req_url_query(pageSize = "1") |>
          req_perform()

        message(response_object$url)

        response_data  <-  response_object |>
          resp_body_json(simplifyVector = TRUE)

        sort(names(response_data[[endpoint]]))
      }else{
        message("No internet connection!")
      }
  },
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Get all possible analytics resources from a DHIS2 instance i.e
    #'
    #' @return A data frame of the analytics resource
    #'
    #' @param analytic  vector of ID of specific analytic(s) from a DHIS2 instance
    #' @param org_unit  vector of ID of specific organisation unit(s) from a DHIS2 instance
    #' @param period  vector of relative or fixed periods from a DHIS2 instance
    #' @param output_scheme  Output type ID or Names of fields
    #'
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    get_analytics= function(analytic,org_unit ,period, output_scheme= c("UID", "NAME")) {

      if(has_internet()){

        # Check for internet

        args <- list(analytic = analytic,org_unit= org_unit ,period = period, output_scheme = output_scheme)
        #Check that at least one argument is not null

        attempt::stop_if_any(args, is.null,"You need to specify all arguements")
        attempt::stop_if_none(args, is.character, "All arguements should be type character")

        output_scheme <- match.arg(output_scheme)

        analytic <- paste0("dx:", paste0(analytic,collapse = ";"))
        org_unit <- paste0("dimension=ou:", paste0(org_unit,collapse = ";"))
        period <- paste0("dimension=pe:",  paste0(period,collapse = ";"))

        response_object <- self$request_sent |>
          req_url_path_append("analytics") |>
          req_url_query(dimension= I(paste(analytic, org_unit, period, sep = "&"))) |>
          req_url_query(outputIdScheme = output_scheme) |>
          req_perform()

        message(response_object$url)


        response_data  <-  response_object |>
          resp_body_json(simplifyVector = TRUE, flatten = TRUE)

        if(length(response_data$rows) == 0){

          as.data.frame(response_data$rows)

        }else{
          as.data.frame(response_data$rows) |>
            setNames(c("analytic", "org_unit", "period", "value")) |>
            tibble::as_tibble() |>
            dplyr::mutate(analytic = as.factor(analytic),
                          org_unit = as.factor(org_unit),
                          value = as.numeric(value))
        }

      }else{
        message("No internet connection!")
      }
      },

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #' @description Get all any analytics resource from a DHIS2 instance to cater for long DHIS2 favorites
    #'
    #' @return A data frame of the analytics resource
    #'
    #' @param endpoint_url string part of Analytic(s) from a DHIS2 instance api endpoint starting from 'analytics.json?dimension='
    #'
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    get_any_analytic = function(endpoint_url) {


      if(has_internet()){

        args <- list(endpoint_url = endpoint_url)
        #Check that at least one argument is not null

        attempt::stop_if_any(args, is.null,"You need to specify all arguements")
        attempt::stop_if_none(args, is.character, "All arguements should be type character")


        response_object <- self$request_sent |>
          req_url_path_append(endpoint_url) |>
          req_perform()

        message(response_object$url)

        response_data  <-  response_object |>
          resp_body_json(simplifyVector = TRUE, flatten = TRUE)

        if(length(response_data$rows) == 0){

          as.data.frame(response_data$rows)

        }else{
          as.data.frame(response_data$rows) |>
            tibble::as_tibble()
        }

      }else{
        message("No internet connection!")
      }
    }
    )
  )


