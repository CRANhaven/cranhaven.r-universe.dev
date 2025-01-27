#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Download Databrary Constants From API.
#' 
#' @param rq An `httr2` request object. Defaults to NULL.
#'
#' @returns A data frame with the constants.
#' 
#' @inheritParams options_params
#' 
#' @examples
#' \donttest{
#' assign_constants()
#' }
#' @export
assign_constants <- function(vb = options::opt("vb"), rq = NULL) {
  # Check parameter
  assertthat::assert_that(is.logical(vb))
  
  if (is.null(rq))
    rq <- databraryr::make_default_request()
  arq <- rq %>%
    httr2::req_url(GET_CONSTANTS)
  
  if (vb) message("Retrieving constants.")
  resp <- tryCatch(
    httr2::req_perform(arq),
    httr2_error = function(cnd) {
      if (vb) message("Error loading Databrary constants.")
      NULL
    }
  )
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    resp
  } else {
    httr2::resp_body_json(resp)
  }
}
