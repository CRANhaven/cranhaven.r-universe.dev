#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' List Assets in Databrary Volume.
#'
#' @param vol_id Target volume number. Default is 1.
#' @param rq An `httr2` request object. Default is NULL.
#' 
#' @returns A data frame with information about all assets in a volume.
#' 
#' @inheritParams options_params
#' 
#' @examples
#' \donttest{
#' \dontrun{
#' list_volume_assets() # Assets in volume 1
#' }
#' }
#' @export
list_volume_assets <- function(vol_id = 1,
                               vb = options::opt("vb"),
                               rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(vol_id) == 1)
  assertthat::assert_that(is.numeric(vol_id))
  assertthat::assert_that(vol_id >= 1)
  
  assertthat::assert_that(length(vb) == 1)
  assertthat::assert_that(is.logical(vb))
  
  # Handle NULL rq
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
  
  this_volume_assets_df <-
    purrr::map(
      vol_list$containers,
      get_assets_from_session,
      ignore_materials = FALSE,
      .progress = TRUE
    ) %>%
    purrr::list_rbind()
  
  if (dim(this_volume_assets_df)[1] == 0) {
    if (vb) message("No assets in volume_id ", vol_id, ".")
    return(NULL)
  }
  if (!("asset_format_id" %in% names(this_volume_assets_df))) {
    if (vb) message("'asset_format_id' field not found in assets data frame.")
    return(NULL)
  }
  
  format_id <- NULL
  format_mimetype <- NULL
  format_extension <- NULL
  format_name <- NULL
  asset_format_id <- NULL
  
  asset_formats_df <- databraryr::list_asset_formats(vb = vb) %>%
    dplyr::select(format_id, format_mimetype, format_extension, format_name)
  
  dplyr::left_join(
    this_volume_assets_df,
    asset_formats_df,
    by = dplyr::join_by(asset_format_id == format_id)
  )
}

#-------------------------------------------------------------------------------
#' Helper function for list_volume_assets
#' 
#' @param volume_container The 'container' list from a volume.
#' @param ignore_materials A logical value.
#' 
get_assets_from_session <-
  function(volume_container, ignore_materials = TRUE) {
    # ignore materials
    if (ignore_materials) {
      if ("top" %in% names(volume_container))
        return(NULL)
    }
    
    assets_df <- purrr::map(volume_container$assets, as.data.frame) %>%
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
    
    # Initialize values to avoid check() error
    id <- NULL
    duration <- NULL
    name <- NULL
    permission <- NULL
    size <- NULL
    
    assets_df %>%
      dplyr::select(id, format, duration, name, permission, size) %>%
      dplyr::rename(
        asset_id = id,
        asset_format_id = format,
        asset_name = name,
        asset_duration = duration,
        asset_permission = permission,
        asset_size = size
      ) %>%
      dplyr::mutate(
        session_id = volume_container$id,
        session_date = volume_container$date,
        session_release = volume_container$release
      )
  }
