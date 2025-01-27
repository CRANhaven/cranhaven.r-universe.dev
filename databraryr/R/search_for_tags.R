#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Search For Tags on Volumes or Sessions.
#'
#' @param search_string String to search.
#' @param rq An `httr2` request object. Default is NULL.
#'
#' @returns An array of tags that match the tag_string.
#' 
#' @inheritParams options_params
#'
#' @examples
#' \dontrun{
#' search_for_tags() # Searches for volumes that have the tag "ICIS"
#' }
#'
#' @export
search_for_tags <-
  function(search_string = "ICIS",
           vb = options::opt("vb"),
           rq = NULL) {
    # Check parameters
    assertthat::assert_that(length(search_string) == 1)
    assertthat::assert_that(is.character(search_string))
    
    assertthat::assert_that(length(vb) == 1)
    assertthat::assert_that(is.logical(vb))
    
    assertthat::assert_that(is.null(rq) |
                              ("httr2_request" %in% class(rq)))
    
    if (is.null(rq)) {
      if (vb) {
        message("NULL request object. Will generate default.")
        message("Not logged in. Only public information will be returned.")  
      }
      rq <- databraryr::make_default_request()
    }
    rq <- rq |>
      httr2::req_url(sprintf(QUERY_TAGS, search_string))
    
    resp <- tryCatch(
      httr2::req_perform(rq),
      httr2_error = function(cnd) {
        NULL
      }
    )
    
    if (!is.null(resp)) {
      httr2::resp_body_string(resp)
    } else {
      resp
    }
    #TODO: Reformat search data; handle multiple tags (separate with '+')
  }
