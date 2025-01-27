# R/utils.R
#
# Utility functions.

#-------------------------------------------------------------------------------
#' @eval options::as_params()
#' @name options_params
#'
NULL

#' Get Duration (In ms) Of A File.
#'
#' @param asset_id Asset number.
#' @param types_w_durations Asset types that have valid durations.
#' @param rq An `httr2` request object. Default is NULL.
#'
#' @returns Duration of a file in ms.
#'
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' get_file_duration() # default is the test video from databrary.org/volume/1
#' }
#'
#' @export
get_file_duration <- function(asset_id = 1,
                              types_w_durations = c("-600", "-800"),
                              vb = options::opt("vb"),
                              rq = NULL) {
  assertthat::assert_that(is.numeric(asset_id))
  assertthat::assert_that(asset_id > 0)
  assertthat::assert_that(length(asset_id) == 1)
  
  assertthat::assert_that(is.character(types_w_durations))
  
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
  rq <- rq %>%
    httr2::req_url(sprintf(GET_ASSET_BY_ID, asset_id))
  
  resp <- tryCatch(
    httr2::req_perform(rq),
    httr2_error = function(cnd)
      NULL
  )
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  } else {
    asset_df <- httr2::resp_body_json(resp)
    if (asset_df$format %in% types_w_durations) {
      asset_df$duration
    }
  }
}
  
  #-------------------------------------------------------------------------------
  #' Get Time Range For An Asset.
  #'
  #' @param vol_id Volume ID
  #' @param session_id Slot/session number.
  #' @param asset_id Asset number.
  #' @param convert_JSON A Boolean value. If TRUE, convert JSON to a data frame. Default is TRUE.
  #' @param segment_only A Boolean value. If TRUE, returns only the segment values. Otherwise returns
  #' a data frame with two fields, segment and permission. Default is TRUE.
  #' @param rq An `httr2` request object. Default is NULL.
  #'
  #' @returns The time range (in ms) for an asset, if one is indicated.
  #'
  #' @inheritParams options_params
  #'
  #' @examples
  #' \donttest{
  #' get_asset_segment_range()
  #' }
  #'
  #' @export
  get_asset_segment_range <- function(vol_id = 1,
                                      session_id = 9807,
                                      asset_id = 1,
                                      convert_JSON = TRUE,
                                      segment_only = TRUE,
                                      vb = options::opt("vb"),
                                      rq = NULL) {
    assertthat::assert_that(is.numeric(vol_id))
    assertthat::assert_that(vol_id > 0)
    assertthat::assert_that(length(vol_id) == 1)
    
    assertthat::assert_that(is.numeric(session_id))
    assertthat::assert_that(session_id > 0)
    assertthat::assert_that(length(session_id) == 1)
    
    assertthat::assert_that(is.numeric(asset_id))
    assertthat::assert_that(asset_id > 0)
    assertthat::assert_that(length(asset_id) == 1)
    
    assertthat::assert_that(is.logical(convert_JSON))
    assertthat::assert_that(length(convert_JSON) == 1)
    
    assertthat::assert_that(is.logical(convert_JSON))
    assertthat::assert_that(length(convert_JSON) == 1)
    
    assertthat::assert_that(is.logical(segment_only))
    assertthat::assert_that(length(segment_only) == 1)
    
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
    rq <- rq %>%
      httr2::req_url(sprintf(
        GET_ASSET_BY_VOLUME_SESSION_ID,
        vol_id,
        session_id,
        asset_id
      ))
    
    resp <- tryCatch(
      httr2::req_perform(rq),
      httr2_error = function(cnd)
        NULL
    )
    if (is.null(resp)) {
      message("Cannot access requested resource on Databrary. Exiting.")
      return(resp)
    } else {
      asset_info <- httr2::resp_body_json(resp)
      if (vb) {
        message(
          "Returning segment start & end times (in ms) from volume ",
          vol_id,
          ", session ",
          session_id,
          ", asset ",
          asset_id
        )
      }
      if (segment_only) {
        asset_info$segment %>% unlist()
      } else {
        asset_info
      }
    }
  }
  
  #-------------------------------------------------------------------------------
  #' Extract Databrary Permission Levels.
  #'
  #' @returns An array with the permission levels that can be assigned to data.
  #'
  #' @inheritParams options_params
  #'
  #' @examples
  #' \donttest{
  #' get_permission_levels()
  #' }
  #'
  #' @export
  get_permission_levels <- function(vb = options::opt("vb")) {
    c <- assign_constants(vb = vb)
    c$permission %>% unlist()
  }
  
  #-------------------------------------------------------------------------------
  #' Convert Timestamp String To ms.
  #'
  #' @param HHMMSSmmm a string in the format "HH:MM:SS:mmm"
  #'
  #' @returns A numeric value in ms from the input string.
  #'
  #' @examples
  #' HHMMSSmmm_to_ms() # 01:01:01:333 in ms
  #' @export
  HHMMSSmmm_to_ms <- function(HHMMSSmmm = "01:01:01:333") {
    # Check parameters
    if (!is.character(HHMMSSmmm)) {
      stop("HHMMSSmmm must be a string.")
    }
    
    if (stringr::str_detect(HHMMSSmmm,
                            "([0-9]{2}):([0-9]{2}):([0-9]{2}):([0-9]{3})")) {
      time_segs <- stringr::str_match(HHMMSSmmm,
                                      "([0-9]{2}):([0-9]{2}):([0-9]{2}):([0-9]{3})")
      as.numeric(time_segs[5]) + as.numeric(time_segs[4]) * 1000 + as.numeric(time_segs[3]) *
        1000 * 60 +
        as.numeric(time_segs[2]) * 1000 * 60 * 60
    } else {
      NULL
    }
  }
  
  #-------------------------------------------------------------------------------
  #' Show Databrary Release Levels
  #'
  #' @returns A data frame with Databrary's release levels.
  #'
  #' @inheritParams options_params
  #'
  #' @examples
  #' \donttest{
  #' get_release_levels()
  #' }
  #'
  #' @export
  get_release_levels <- function(vb = options::opt("vb")) {
    c <- assign_constants(vb = vb)
    c$release %>% unlist()
  }
  
  #-------------------------------------------------------------------------------
  #' Extracts File Types Supported by Databrary.
  #'
  #'
  #' @returns A data frame with the file types permitted on Databrary.
  #'
  #' @inheritParams options_params
  #'
  #' @examples
  #' \donttest{
  #' get_supported_file_types()
  #' }
  #'
  #' @export
  get_supported_file_types <- function(vb = options::opt("vb")) {
    c <- assign_constants(vb = vb)
    ft <- Reduce(function(x, y)
      merge(x, y, all = TRUE), c$format)
    ft <- dplyr::rename(ft, asset_type = "name", asset_type_id = "id")
    ft
  }
  
  #-------------------------------------------------------------------------------
  #' Is This Party An Institution?
  #'
  #' @param party_id Databrary party ID
  #' @param rq An `httr2` request object.
  #'
  #' @returns TRUE if the party is an institution, FALSE otherwise.
  #'
  #' @inheritParams options_params
  #'
  #' @examples
  #' \donttest{
  #' is_institution() # Is party 8 (NYU) an institution.
  #' }
  #'
  #' @export
  is_institution <- function(party_id = 8,
                             vb = options::opt("vb"),
                             rq = NULL) {
    assertthat::assert_that(is.numeric(party_id))
    assertthat::assert_that(party_id > 0)
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
    
    party_info <- databraryr::get_party_by_id(party_id = party_id,
                                              vb = vb,
                                              rq = rq)
    
    if (("institution" %in% names(party_info)) &&
        (!is.null(party_info[['institution']]))) {
      TRUE
    } else {
      FALSE
    }
  }
  
  #-------------------------------------------------------------------------------
  #' Is This Party A Person?
  #'
  #' @param party_id Databrary party ID
  #' @param rq An `httr2` request object.
  #'
  #' @returns TRUE if the party is a person, FALSE otherwise.
  #'
  #' @inheritParams options_params
  #'
  #' @examples
  #' \donttest{
  #' is_person()
  #' }
  #'
  #' @export
  is_person <- function(party_id = 7,
                        vb = options::opt("vb"),
                        rq = NULL) {
    return(!is_institution(
      party_id = party_id,
      vb = vb,
      rq = rq
    ))
  }
  
  #-------------------------------------------------------------------------------
  #' Make Portable File Names
  #'
  #' @param fn Databrary party ID
  #' @param replace_regex A character string. A regular expression to capture
  #' the "non-portable" characters in fn.
  #' @param replacement_char A character string. The character(s) that will replace
  #' the non-portable characters.
  #'
  #' @returns A "cleaned" portable file name
  #'
  #' @inheritParams options_params
  #'
  make_fn_portable <- function(fn,
                               vb = options::opt("vb"),
                               replace_regex = "[ &\\!\\)\\(\\}\\{\\[\\]\\+\\=@#\\$%\\^\\*]",
                               replacement_char = "_") {
    assertthat::is.string(fn)
    assertthat::assert_that(!is.numeric(fn))
    assertthat::assert_that(!is.logical(fn))
    assertthat::assert_that(length(fn) == 1)
    
    assertthat::assert_that(is.logical(vb))
    assertthat::assert_that(length(vb) == 1)
    
    assertthat::is.string(replace_regex)
    assertthat::assert_that(length(replace_regex) == 1)
    
    assertthat::is.string(replacement_char)
    assertthat::assert_that(length(replacement_char) == 1)
    
    if (vb) {
      non_portable_chars <- stringr::str_detect(fn, replace_regex)
      message("There are ", sum(non_portable_chars), " in ", fn)
    }
    new_fn <- stringr::str_replace_all(fn, replace_regex, replacement_char)
    new_fn
  }
  