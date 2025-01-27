#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' List Image or Video Excerpts On A Databrary Volume.
#'
#' @param vol_id Target volume number.
#' @param rq An `httr2` request object. Default is NULL.
#'
#' @returns A list with information about any available excerpts.
#' 
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' list_volume_excerpts()
#' }
#'
#' @export
list_volume_excerpts <-
  function(vol_id = 1,
           vb = options::opt("vb"),
           rq = NULL) {
    # Check parameters
    assertthat::assert_that(length(vol_id) == 1)
    assertthat::assert_that(is.numeric(vol_id))
    assertthat::assert_that(vol_id > 0)
    
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
    rq <- rq %>%
      httr2::req_url(sprintf(GET_VOLUME_EXCERPTS, vol_id))
    
    resp <- tryCatch(
      httr2::req_perform(rq),
      httr2_error = function(cnd) {
        NULL
      }
    )
    
    if (is.null(resp)) {
      message("Cannot access requested resource on Databrary. Exiting.")
      return(resp)
    } else {
      httr2::resp_body_json(resp)
    }
    # TODO: Reformat response.
  }
