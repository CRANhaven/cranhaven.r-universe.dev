#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' List Authorized Investigators at Institution
#'
#' @param party_id Target party ID.
#' @param rq An `httr2`-style request object. If NULL, then a new request will
#' be generated using `make_default_request()`.
#'
#' @returns A data frame with information the institution's authorized investigators.
#'
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' list_institutional_affiliates() # Default is Penn State (party 12)
#' }
#' }
#' @export
list_authorized_investigators <- function(party_id = 12,
                                          vb = options::opt("vb"),
                                          rq = NULL) {
  assertthat::is.number(party_id)
  assertthat::assert_that(is.numeric(party_id))
  assertthat::assert_that(party_id >= 1)
  assertthat::assert_that(length(party_id) == 1)
  
  assertthat::assert_that(is.logical(vb))
  assertthat::assert_that(length(vb) == 1)
  
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
  
  this_party <- databraryr::get_party_by_id(party_id, vb = vb, rq = rq)
  
  if (is.null(this_party)) {
    if (vb)
      message("No data for party ", party_id)
    return(NULL)
  }
  
  if (!("institution" %in% names(this_party))) {
    if (vb)
      message("Party ", party_id, " not an institution.")
    return(NULL)
  }
  
  if (dim(as.data.frame(this_party$children))[1] == 0) {
    if (vb)
      message("Party ", party_id, " has no affiliates.")
    return(NULL)
  }
  
  purrr::map(this_party$children, as.data.frame, .progress = TRUE) %>%
    purrr::list_rbind()
}