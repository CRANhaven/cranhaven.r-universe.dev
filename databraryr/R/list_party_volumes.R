#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' List Volumes A Party Has Access To
#'
#' @param party_id Target party ID.
#' @param rq An `httr2`-style request object. If NULL, then a new request will
#' be generated using `make_default_request()`.
#' 
#' @returns A data frame with information about a party's sponsors.
#' 
#' @inheritParams options_params
#' 
#' @examples
#' \donttest{
#' \dontrun{
#' list_party_volumes() # Default is Rick Gilmore (party 6)
#' }
#' }
#' @export
list_party_volumes <- function(party_id = 6,
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
  
  vol_id <- NULL
  
  if (vb)
    message(paste0("Retrieving data for party ", party_id, "."))
  party_info <- databraryr::get_party_by_id(party_id = party_id, vb = vb, 
                                            rq = rq)
  
  if (!is.null(party_info)) {
    if (vb)
      message(paste0("Info retrieved. Filtering."))
    purrr::map(party_info$access, extract_vol_fr_party) %>%
      purrr::list_rbind() %>%
      dplyr::mutate(
        party_id = party_id,
        party_prename = party_info$prename,
        party_sortname = party_info$sortname,
        party_affiliation = party_info$affiliation
      ) %>%
      dplyr::arrange(vol_id)
  } else {
    if (vb)
      message(paste0("No data for party ", party_id, "."))
    party_info
  }
}

#---------------------------------------------------------------------------
# This is a private, not exported,
# helper function for list_party_volumes()
#
extract_vol_fr_party <- function(p_info) {
  assertthat::assert_that(is.list(p_info))

  this_vol <- p_info$volume
  
  vol_names <- names(this_vol)
  assertthat::assert_that("id" %in% vol_names)
  assertthat::assert_that("name" %in% vol_names)
  assertthat::assert_that("body" %in% vol_names)
  assertthat::assert_that("creation" %in% vol_names)
  assertthat::assert_that("permission" %in% vol_names)
  
  vol_id <- this_vol$id
  vol_name <- this_vol$name
  vol_body <- this_vol$body
  if (!("alias" %in% vol_names)) {
    vol_alias = NA
  } else {
    vol_alias <- this_vol$alias    
  }
  vol_creation <- this_vol$creation
  vol_permission <- this_vol$permission
  
  tibble::tibble(vol_id,
                 vol_name,
                 vol_body,
                 vol_alias,
                 vol_creation,
                 vol_permission)
}