#' @eval options::as_params()
#' @name options_params
#'
NULL

#' List Assets in a Databrary Session.
#'
#' #' @description
#' `r lifecycle::badge("experimental")`
#'
#' As of v0.6.3 `list_session_assets()` replaces an older function that is now
#' named `list_volume_session_assets()`.  The older function requires both
#' a volume ID and a session ID. The new function requires only a session ID.
#'
#' @param session_id An integer. A Databrary session number. Default is 9807,
#' the "materials" folder from Databrary volume 1.
#' @param rq An `httr2` request object. If NULL, a default request is generated
#' from databraryr::make_default_request().
#'
#' @returns A data frame with information about all assets in a volume.
#'
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' list_session_assets() # Session 9807 in volume 1
#' }
#' }
#' @export
list_session_assets <- function(session_id = 9807,
                                vb = options::opt("vb"),
                                rq = NULL) {
  assertthat::assert_that(length(session_id) == 1)
  assertthat::assert_that(is.numeric(session_id))
  assertthat::assert_that(session_id >= 1)
  
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
  
  this_rq <- rq %>%
    httr2::req_url(sprintf(QUERY_SLOT, session_id)) %>%
    httr2::req_progress()
  
  if (vb)
    message("Retrieving assets from session id ", session_id, ".")
  resp <- tryCatch(
    httr2::req_perform(this_rq),
    httr2_error = function(cnd)
      NULL
  )
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  } else {
    session_list <- httr2::resp_body_json(resp)
    if ("assets" %in% names(session_list)) {
      assets_df <- purrr::map(session_list$assets, as.data.frame) %>%
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
        dplyr::select(format_id,
                      format_mimetype,
                      format_extension,
                      format_name)
      
      # Join assets with asset format info
      out_df <- dplyr::left_join(assets_df,
                                 asset_formats_df,
                                 by = dplyr::join_by(asset_format_id == format_id)) %>%
        dplyr::mutate(session_id = session_id)
      
      out_df
    } else {
      if (vb)
        message("No assets for session_id ", session_id)
      session_list
    }
  }
}