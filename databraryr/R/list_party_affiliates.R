#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' List Affiliates For A Party
#'
#' @param party_id Target party ID.
#' @param rq An `httr2` request object. Defaults to NULL.
#' 
#' @returns A data frame with information about a party's affiliates.
#' 
#' @inheritParams options_params
#' 
#' @examples
#' \donttest{
#' list_party_affiliates() # Default is Rick Gilmore (party 6)
#' }
#' @export
list_party_affiliates <- function(party_id = 6,
                                  vb = options::opt("vb"),
                                  rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(party_id) == 1)
  assertthat::assert_that(is.numeric(party_id))
  assertthat::assert_that(party_id > 0)
  
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
  
  if (vb)
    message(paste0("Getting affiliates for party ", party_id, "."))
  
  g <- databraryr::get_party_by_id(party_id = party_id, vb = vb, rq = rq)
  
  party.id <- NULL
  party.prename <- NULL
  party.sortname <- NULL
  party.affiliation <- NULL
  affiliate_id <- NULL
  affiliate_sortname <- NULL
  affiliate_prename <- NULL
  affiliate_affiliation <- NULL
  
  if (!is.null(g)) {
    if (vb)
      message(paste0("Retrieving data for party ", party_id, "."))
    purrr::map(g$children, as.data.frame) %>%
      purrr::list_rbind() %>%
      dplyr::rename(
        affiliate_id = party.id,
        affiliate_sortname = party.sortname,
        affiliate_prename = party.prename,
        affiliate_affiliation = party.affiliation
      ) %>%
      dplyr::select(
        affiliate_id,
        affiliate_sortname,
        affiliate_prename,
        affiliate_affiliation
      )
  } else {
    if (vb)
      message(paste0("No data for party ", party_id, "."))
    NULL
  }
}
