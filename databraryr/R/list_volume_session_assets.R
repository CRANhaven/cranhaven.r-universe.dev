#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' List Assets in a Session from a Databrary volume.
#'
#'#' @description
#' `r lifecycle::badge("experimental")`
#' 
#' `list_volume_session_assets()` is a new name for the <v0.6.2 `list_session_assets()` as
#' function. There is a new `list_session_assets()` function that does not
#' requre the volume ID. The `list_volume_session_assets()` *requires* a volume
#' ID.
#'
#' @param vol_id Target volume number.
#' @param session_id The session number in the selected volume.
#' @param rq An `httr2` request object.
#' 
#' @returns A data frame with information about all assets in a volume.
#' 
#' @inheritParams options_params
#' 
#' @examples
#' \donttest{
#' \dontrun{
#' list_volume_session_assets() # Session 9807 in volume 1
#' }
#' }
#' @export
list_volume_session_assets <-
  function(vol_id = 1,
           session_id = 9807,
           vb = options::opt("vb"),
           rq = NULL) {
    # Check parameters
    assertthat::assert_that(length(vol_id) == 1)
    assertthat::assert_that(is.numeric(vol_id))
    assertthat::assert_that(vol_id >= 1)
    
    assertthat::assert_that(length(session_id) == 1)
    assertthat::assert_that(is.numeric(session_id))
    assertthat::assert_that(session_id >= 1)
    
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
    
    vol_list <- databraryr::get_volume_by_id(vol_id, vb, rq)
    
    if (!("containers" %in% names(vol_list))) {
      if (vb)
        message("No session/containers data from volume ", vol_id)
      return(NULL)
    }
    
    #--------------------------------------------------------------------------
    get_sessions <- function(volume_container) {
      tibble::tibble(session_id = volume_container$id)
    }
    #--------------------------------------------------------------------------
    
    # Select session info
    these_sessions <-
      purrr::map(vol_list$containers, get_sessions) %>%
      purrr::list_rbind()
    
    session_match <- (session_id == these_sessions$session_id)
    if (sum(session_match) == 0) {
      if (vb)
        message("No matching session_id: ", session_id)
      return(NULL)
    }
    session_match_index <- seq_along(session_match)[session_match]
    
    this_session <- vol_list$containers[[session_match_index]]
    if (is.null(this_session))
      return(NULL)
    
    assets_df <-
      purrr::map(this_session$assets, as.data.frame) %>%
      purrr::list_rbind()
    
    # ignore empty sessions
    if (dim(assets_df)[1] == 0)
      return(NULL)
    
    if (!('size' %in% names(assets_df)))
      assets_df$size = NA
    if (!('duration' %in% names(assets_df)))
      assets_df$duration = NA
    if (!('name' %in% names(assets_df)))
      assets_df$name = NA
    
    id <- NULL
    format <- NULL
    name <- NULL
    duration <- NULL
    permission <- NULL
    size <- NULL
    asset_format_id <- NULL
    
    assets_df <- assets_df %>%
      dplyr::select(id, format, duration, name, permission, size) %>%
      dplyr::rename(
        asset_id = id,
        asset_format_id = format,
        asset_name = name,
        asset_duration = duration,
        asset_permission = permission,
        asset_size = size
      )
    
    format_id <- NULL
    format_mimetype <- NULL
    format_extension <- NULL
    format_name <- NULL
    
    # Gather asset format info
    asset_formats_df <- list_asset_formats(vb = vb) %>%
      dplyr::select(format_id, format_mimetype, format_extension, format_name)
    
    # Join assets with asset format info
    out_df <- dplyr::left_join(assets_df,
                               asset_formats_df,
                               by = dplyr::join_by(asset_format_id == format_id))
    out_df
  }
