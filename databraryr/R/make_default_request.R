#' Set default httr request parameters.
#'
#' `make_default_request` sets default parameters for httr requests.
#' @returns An `httr2` request object.
#' 
#' @examples
#' make_default_request()
#' @export
make_default_request <- function() {
  path <- tempfile()
  rq <- httr2::request(DATABRARY_API) %>%
    httr2::req_user_agent(USER_AGENT) %>%
    httr2::req_retry(max_tries = RETRY_LIMIT) %>%
    httr2::req_timeout(REQUEST_TIMEOUT) %>%
    httr2::req_cookie_preserve(path)
  rq
}