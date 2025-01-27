#' @eval options::as_params()
#' @name options_params
#'
NULL

#' Retrieves URL Links From A Databrary Volume.
#'
#' @param vol_id Target volume number.
#' @param rq An `httr2` request object.
#'
#' @returns A data frame with the requested data.
#'
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' list_volume_links() # Links from volume 1
#' }
#' }
#' @export
list_volume_links <- function(vol_id = 1,
                              vb = options::opt("vb"),
                              rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(vol_id) == 1)
  assertthat::assert_that(is.numeric(vol_id))
  assertthat::assert_that(vol_id > 0)
  
  assertthat::assert_that(length(vb) == 1)
  assertthat::assert_that(is.logical(vb))
  
  if (is.null(rq)) {
    if (vb) {
      message("NULL request object. Will generate default.")
      message("Not logged in. Only public information will be returned.")
    }
    rq <- databraryr::make_default_request()
  }
  rq <- rq %>%
    httr2::req_url(sprintf(GET_VOLUME_LINKS, vol_id))
  
  resp <- tryCatch(
    httr2::req_perform(rq),
    httr2_error = function(cnd) {
      NULL
    }
  )
  
  head <- NULL
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  } else {
    res <- httr2::resp_body_json(resp)
    if (!(is.null(res$links))) {
      purrr::map(res$links, tibble::as_tibble) %>%
        purrr::list_rbind() %>%
        dplyr::rename(link_name = head, link_url = url) %>%
        dplyr::mutate(vol_id = vol_id)
    }
  }
}
