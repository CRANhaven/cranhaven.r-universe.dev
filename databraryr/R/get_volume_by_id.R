#' @eval options::as_params()
#' @name options_params
#'
NULL

#' Get Data From A Databrary Volume
#'
#' @param vol_id Volume ID.
#' @param rq An `httr2` request object. If NULL (the default), a new request
#' is generated using `make_default_request()`. To access restricted data,
#' the user must login with a specific request object using `login_db()`.
#'
#' @returns A JSON blob with the volume data. If the user has previously logged
#' in to Databrary via `login_db()`, then volume(s) that have restricted access
#' can be downloaded, subject to the sharing release levels on those volume(s).
#'
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' get_volume_by_id() # Default is Volume 1
#' }
#'
#' @export
get_volume_by_id <- function(vol_id = 1,
                             vb = options::opt("vb"),
                             rq = NULL) {
  assertthat::assert_that(is.numeric(vol_id))
  assertthat::assert_that(vol_id > 0)
  assertthat::assert_that(length(vol_id) == 1)
  
  assertthat::assert_that(is.logical(vb))
  assertthat::assert_that(length(vb) == 1)
  
  assertthat::assert_that(is.null(rq) |
                            ("httr2_request" %in% class(rq)))
  
  # Handle NULL rq
  if (is.null(rq)) {
    if (vb) {
      message("\nNULL request object. Will generate default.")
      message("Not logged in. Only public information will be returned.")
    }
    rq <- databraryr::make_default_request()
  }
  rq <- rq %>%
    httr2::req_url(sprintf(GET_VOL_BY_ID, vol_id))
  
  if (vb)
    message("Retrieving data for volume id ", vol_id, ".")
  resp <- tryCatch(
    httr2::req_perform(rq),
    httr2_error = function(cnd)
      NULL
  )
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  } else {
    httr2::resp_body_json(resp)
  }
}