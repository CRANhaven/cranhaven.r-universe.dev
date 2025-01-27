#' @eval options::as_params()
#' @name options_params
#'
NULL

#' List Owners of a Databrary Volume.
#'
#' @param vol_id Selected volume number. Default is volume 1.
#' @param rq An `httr2` request object. If NULL (the default)
#' a request will be generated, but this will only permit public information
#' to be returned.
#'
#' @returns A data frame with information about a volume's owner(s).
#'
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' list_volume_owners() # Lists information about the owners of volume 1.
#' }
#' @export
list_volume_owners <- function(vol_id = 1,
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
    httr2::req_url(sprintf(GET_VOLUME_MINIMUM, vol_id))
  
  resp <- tryCatch(
    httr2::req_perform(rq),
    httr2_error = function(cnd) {
      NULL
    }
  )
  
  # Initialize
  party_id <- NULL
  id <- NULL
  owner_name <- NULL
  name <- NULL
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  } else {
    res <- httr2::resp_body_json(resp)
    if (!(is.null(res$owners))) {
      purrr::map(res$owners, tibble::as_tibble) %>%
        purrr::list_rbind() %>%
        dplyr::rename(party_id = id, owner_name = name) %>%
        dplyr::filter(!(stringr::str_detect(owner_name, "Databrary")))
    }
    
  }
}
