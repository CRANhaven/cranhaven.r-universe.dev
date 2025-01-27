#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Get Stats About Databrary.
#'
#' `get_db_stats` returns basic summary information about
#' the institutions, people, and data hosted on 'Databrary.org'.
#'
#' @param type Type of Databrary report to run "institutions", "people", "data"
#' @param rq An `httr2` request object.
#'
#' @returns A data frame with the requested data or NULL if there is no new information.
#'
#' @inheritParams options_params
#' 
#' @examples
#' \donttest{
#' get_db_stats()
#' get_db_stats("stats")
#' get_db_stats("people") # Information about the newest authorized investigators.
#' get_db_stats("places") # Information about the newest institutions.
#' }
#' @export
get_db_stats <- function(type = "stats",
                         vb = options::opt("vb"),
                         rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(type) == 1)
  assertthat::assert_that(is.character(type))
  assertthat::assert_that(
    type %in% c(
      "institutions",
      "places",
      "people",
      "researchers",
      "investigators",
      "datasets",
      "data",
      "volumes",
      "stats",
      "numbers"
    )
  )
  
  assertthat::assert_that(length(vb) == 1)
  assertthat::assert_that(is.logical(vb))
  
  assertthat::assert_that(is.null(rq) |
                            ("httr2_request" %in% class(rq)))
  
  if (is.null(rq)) {
    if (vb) {
      message("\nNULL request object. Will generate default.")
      message("Not logged in. Only public information will be returned.")
    }
    rq <- databraryr::make_default_request()
  }
  rq <- rq %>%
    httr2::req_url(GET_ACTIVITY_DATA)
  
  resp <- tryCatch(
    httr2::req_perform(rq),
    httr2_error = function(cnd) {
      if (vb)
        message("Error retrieving Databrary '", type, "' stats.")
      NULL
    }
  )
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  }
  
  if (httr2::resp_status(resp) == 200) {
    r <- httr2::resp_body_json(resp)
    
    if (type %in% c("stats", "numbers")) {
      tibble::tibble(
        date = Sys.time(),
        investigators = unlist(r$stats$authorized[5]),
        affiliates = unlist(r$stats$authorized[4]),
        institutions = unlist(r$stats$authorized[6]),
        datasets_total = r$stats$volumes,
        datasets_shared = r$stats$shared,
        n_files = r$stats$assets,
        hours = r$stats$duration / (1000 * 60 * 60),
        TB = r$stats$bytes / (1e12)
      ) # seems incorrect
    } else {
      purrr::map(r$activity, process_db_activity_blob_item, type) |>
        purrr::list_rbind()
    }
  }
}

#------------------------------------------------------------------------------
process_db_activity_blob_item <- function(activity_blob, type) {
  df <- activity_blob |>
    purrr::flatten() |>
    tibble::as_tibble()
  
  if (!is.null(df)) {
    if (type %in% c("datasets", "volumes", "data")) {
      if ("owners" %in% names(df)) {
        df <- dplyr::filter(df, !is.na(df$id))
      } else {
        return(NULL)
      }
    } else if (type %in% c("institutions", "places")) {
      if ("institution" %in% names(df)) {
        df <- dplyr::filter(df, !is.na(df$id), !is.na(df$institution))
      } else {
        return(NULL)
      }
    } else if (type %in% c("people", "researchers", "investigators")) {
      if ("affiliation" %in% names(df)) {
        df <- dplyr::filter(
          df,
          !is.na(df$id),
          !is.na(df$affiliation),
          !is.na(df$sortname),
          !is.na(df$prename)
        )
      } else {
        return(NULL)
      }
    }
    df
  }
}
