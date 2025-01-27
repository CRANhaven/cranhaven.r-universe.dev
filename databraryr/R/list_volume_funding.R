#' @eval options::as_params()
#' @name options_params
#'
NULL

#' Lists Funders Associated With a Databrary Volume.
#'
#' @param vol_id Target volume number.
#' @param add_id A logical value. Include the volume ID in the output. Default is TRUE.
#' @param rq An `httr2` request object.
#'
#' @returns A data frame with funder information for the volume.
#'
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' list_volume_funding() # Funding for volume 1
#'
#' list_volume_funding(vol_id = c(1:10))
#' }
#' }
#'
#' @export
list_volume_funding <- function(vol_id = 1,
                                add_id = TRUE,
                                vb = options::opt("vb"),
                                rq = NULL) {
  # Check parameters
  assertthat::assert_that(is.numeric(vol_id))
  assertthat::assert_that(sum(vol_id >= 1) == length(vol_id))
  
  assertthat::assert_that(length(add_id) == 1)
  assertthat::assert_that(is.logical(add_id))
  
  assertthat::assert_that(length(vb) == 1)
  assertthat::assert_that(is.logical(vb))
  
  assertthat::assert_that(is.null(rq) |
                            ("httr2_request" %in% class(rq)))
  
  if (is.null(rq)) {
    if (vb) {
      message("NULL request object. Will generate default.")
      message("Not logged in. Only public information will be returned.")
    }
    rq <- databraryr::make_default_request()
  }
  
  #------------------------------------------------------------
  if (vb)
    message("Summarizing funding for n=", length(vol_id), " volumes.")
  purrr::map(
    vol_id,
    list_single_volume_funding,
    add_id = add_id,
    vb = vb,
    rq = rq,
    .progress = "Volume funding: "
  ) %>%
    purrr::list_rbind()
}


#-------------------------------------------------------------------------------
# Helper function for handling lists
list_single_volume_funding <-
  function(vol_id = NULL,
           add_id = NULL,
           vb = NULL,
           rq) {
    if (is.null(rq)) {
      rq <- databraryr::make_default_request()
    }
    rq <- rq %>%
      httr2::req_url(sprintf(GET_VOLUME_FUNDING, vol_id))
    
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
      if (!(is.null(res))) {
        out_df <- purrr::map(res$funding, extract_funder_info) %>%
          purrr::list_rbind()
        if (add_id)
          out_df <- dplyr::mutate(out_df, vol_id = vol_id)
        out_df
      }
    }
  }

#-------------------------------------------------------------------------------
extract_funder_info <- function(vol_funder_list_item) {
  assertthat::assert_that("list" %in% class(vol_funder_list_item))
  assertthat::assert_that("funder" %in% names(vol_funder_list_item))
  assertthat::assert_that("awards" %in% names(vol_funder_list_item))
  
  funder_id <- vol_funder_list_item$funder$id
  funder_name <- vol_funder_list_item$funder$name
  if (length(vol_funder_list_item$awards) == 0) {
    funder_award <- NA
  } else {
    funder_award <- vol_funder_list_item$awards %>% unlist()
  }
  tibble::tibble(
    funder_id = funder_id,
    funder_name = funder_name,
    funder_award = funder_award
  )
}
