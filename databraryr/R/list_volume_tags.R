#' @eval options::as_params()
#' @name options_params
#'
NULL

#' Lists Keywords And Tags For A Volume.
#'
#' @param vol_id Target volume number.
#' @param rq An `httr2` request object. Default is NULL.
#'
#' @returns A data frame with the requested data.
#'
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' list_volume_tags()
#' }
#' @export
list_volume_tags <- function(vol_id = 1,
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
  
  # Handle NULL rq
  if (is.null(rq)) {
    if (vb) {
      message("NULL request object. Will generate default.")
      message("Not logged in. Only public information will be returned.")
    }
    rq <- databraryr::make_default_request()
  }
  rq <- rq %>%
    httr2::req_url(sprintf(GET_VOLUME_TAGS, vol_id))
  
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
    res <- httr2::resp_body_json(resp)
    if (!(is.null(res$tags))) {
      purrr::map(res$tags, extract_vol_tag) %>%
        purrr::list_rbind() %>%
        dplyr::mutate(vol_id = vol_id)
    }
  }
}

#-------------------------------------------------------------------------------
extract_vol_tag <- function(tag_list_item) {
  tibble::tibble(tag_id = tag_list_item$id, tag_weight = tag_list_item$weight)
}
