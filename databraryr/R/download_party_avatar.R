#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Returns the Avatar(s) (images) for Authorized User(s).
#'
#' @param party_id A number or range of numbers. Party number or numbers to retrieve information about. Default is 6
#' (Rick Gilmore).
#' @param show_party_info A logical value. Show the person's name and affiliation in the output.
#' Default is TRUE.
#' @param rq An `httr2` request object. If not provided, a new request is
#' generated via `make_default_request()`.
#'
#' @returns An list with the avatar (image) file and a name_affil string.
#' 
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' download_party_avatar() # Show Rick Gilmore's (party 6) avatar.
#'
#' # Download avatars from Databrary's founders (without name/affiliations)
#' download_party_avatar(5:7, show_party_info = FALSE)
#'
#' # Download NYU logo
#' download_party_avatar(party = 8)
#' }
#' }
#' @export
download_party_avatar <- function(party_id = 6,
                                  show_party_info = TRUE,
                                  vb = options::opt("vb"),
                                  rq = NULL) {
  
  # Check parameters
  assertthat::is.number(party_id)
  assertthat::assert_that(!is.character(party_id))
  assertthat::assert_that(!is.logical(party_id))
  assertthat::assert_that(sum(party_id >= 1) == length(party_id))
  
  assertthat::assert_that(length(show_party_info) == 1)
  assertthat::assert_that(is.logical(show_party_info))
  
  assertthat::assert_that(length(vb) == 1)
  assertthat::assert_that(is.logical(vb))
  
  assertthat::assert_that(is.null(rq) |
                            ("httr2_request" %in% class(rq)))
  
  # Handle NULL request
  if (is.null(rq)) {
    if (vb) {
      message("NULL request object. Will generate default.")
      message("Not logged in. Only public information will be returned.")  
    }
    rq <- databraryr::make_default_request()
  }
  
  if (vb)
    message("Attempting to retrieve avatars for parties: ",
            min(party_id),
            ":",
            max(party_id))
  
  purrr::map(
    party_id,
    get_single_avatar,
    show_party_info = show_party_info,
    vb = vb,
    rq = rq,
    .progress = TRUE
  )
}

#------------------------------------------------------------------------------
# Helper function for handling multiple queries
get_single_avatar <- function(party_id = 6,
                              show_party_info = TRUE,
                              vb = FALSE,
                              rq = NULL) {
  if (is.null(rq)) {
    if (vb) {
      message("NULL request object. Will generate default.")
      message("Only public information will be returned.")
    }
    rq <- databraryr::make_default_request()
  }
  
  arq <- rq %>%
    httr2::req_url(sprintf(GET_PARTY_AVATAR, party_id))
  
  resp <- tryCatch(
    httr2::req_perform(arq),
    httr2_error = function(cnd) {
      if (vb)
        message("Error retrieving avatar for party_id ", party_id)
      NULL
    }
  )
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  }
  
  # Download avatar
  party_avatar <- httr2::resp_body_raw(resp) %>%
    magick::image_read()
  
  if (show_party_info) {
    party_str = paste0("Data for Databrary party ", party_id, ":")
    
    party_info <- databraryr::get_party_by_id(party_id)
    if (is.list(party_info)) {
      if ("affiliation" %in% names(party_info)) {
        if (vb)
          message(party_str)
        party_str <-
          paste0(party_info$prename,
                 " ",
                 party_info$sortname,
                 ", ",
                 party_info$affiliation)
      } else {
        party_str <-
          paste0(party_info$sortname)
      }
    } else {
      message("Unable to extract info for party '", party_id, "'.")
    }
  }
  
  list(avatar = party_avatar, name_affil = party_str)
}
