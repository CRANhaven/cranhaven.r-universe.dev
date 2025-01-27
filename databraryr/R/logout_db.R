#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Log Out of Databrary.org.
#'
#' @param rq An `httr2` request object. Defaults to NULL.
#' 
#' @returns TRUE if logging out succeeds, FALSE otherwise.
#' 
#' @inheritParams options_params
#' 
#' @examples
#' \donttest{
#' logout_db()
#' }
#' @export
logout_db <- function(vb = options::opt("vb"), rq = NULL){

  assertthat::assert_that(is.logical(vb))
  
  if (is.null(rq)) {
    if (vb) message("Empty request. Generating new one.")
    rq <- databraryr::make_default_request()
  }
  rq <- rq %>%
    httr2::req_url(LOGOUT)
  
  r <- httr2::req_perform(rq)

  delete_cookie <- file.remove(rq$options$cookiefile)
  if (httr2::resp_status(r) == 200 & delete_cookie) {
    if (vb) message('Logout Successful.')
    TRUE
  } else {
    if (vb) message(paste0('Logout Failed, HTTP status: ', httr2::resp_status(r), '.\n'))
    FALSE
  }
}
