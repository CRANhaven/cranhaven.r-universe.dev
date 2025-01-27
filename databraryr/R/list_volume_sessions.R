#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' List Sessions in Databrary Volume.
#'
#' @param vol_id Target volume number.
#' @param include_vol_data A Boolean value. Include volume-level metadata
#' or not. Default is FALSE.
#' @param rq An `httr2` request object. If NULL (the default)
#' a request will be generated, but this will only permit public information
#' to be returned.
#'
#' @returns A data frame with information about all assets in a volume.
#' 
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' list_volume_sessions() # Sessions in Volume 1
#' }
#' }
#' @export
list_volume_sessions <-
  function(vol_id = 1,
           include_vol_data = FALSE,
           vb = options::opt("vb"),
           rq = NULL) {
    # Check parameters
    assertthat::assert_that(length(vol_id) == 1)
    assertthat::assert_that(is.numeric(vol_id))
    assertthat::assert_that(vol_id >= 1)
    
    assertthat::assert_that(is.logical(include_vol_data))
    assertthat::assert_that(length(include_vol_data) == 1)
    
    assertthat::assert_that(length(vb) == 1)
    assertthat::assert_that(is.logical(vb))
    
    assertthat::assert_that(is.null(rq) |
                              ("httr2_request" %in% class(rq)))
    
    # Handle NULL rq
    if (is.null(rq)) {
      if (vb) {
        message("\nNULL request object. Will generate default.")
        message("Not logged in. Only public information will be returned.")  
      }
      rq <- databraryr::make_default_request()
    }
    
    # Make character array of "release" constants to decode release index
    constants <- databraryr::assign_constants()
    release_levels <- constants$release |>
      as.character()
    
    #-------------------------------------------------------------------------------
    get_info_from_session <-
      function(volume_container, ignore_materials = FALSE, release_levels) {
        # ignore materials
        if (ignore_materials) {
          if ("top" %in% names(volume_container))
            return(NULL)
        } else {
          if (!("name" %in% names(volume_container)))
            volume_container$name <- NA
          if (!("date" %in% names(volume_container)))
            volume_container$date <- NA
          if (!("release" %in% names(volume_container)))
            volume_container$release <- NA
        }
        
        tibble::tibble(
          session_id = volume_container$id,
          session_name = volume_container$name,
          session_date = volume_container$date,
          session_release = release_levels[volume_container$release]
        )
      }
    #-------------------------------------------------------------------------------
    
    vol_list <- get_volume_by_id(vol_id = vol_id, vb = vb, rq = rq)
    if (!("containers" %in% names(vol_list))) {
      if (vb)
        message("No session/containers data from volume ", vol_id)
      return(NULL)
    }
    
    df <- purrr::map(vol_list$containers, get_info_from_session, 
                     release_levels = release_levels) %>%
      purrr::list_rbind()
    
    if (include_vol_data) {
      df <- df %>%
        dplyr::mutate(
          vol_id = vol_list$id,
          vol_name = vol_list$name,
          vol_creation = vol_list$creation,
          vol_publicaccess = vol_list$publicaccess
        )
    }
    
    df
  }

