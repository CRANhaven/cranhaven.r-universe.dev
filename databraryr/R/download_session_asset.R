#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Download Asset From Databrary.
#'
#' @description Databrary stores file types (assets) of many types. This
#' function downloads an asset based on its system-unique integer identifer
#' (asset_id) and system-unique session (slot) identifier (session_id).
#'
#' @param asset_id An integer. Asset id for target file. Default is 1.
#' @param session_id An integer. Slot/session number where target file is 
#' stored. Default is 9807.
#' @param file_name A character string. Name for downloaded file. Default is NULL.
#' 
#' @param target_dir A character string. Directory to save the downloaded file.
#' Default is a temporary directory given by a call to `tempdir()`.
#' @param rq A list in the form of an `httr2` request object. Default is NULL.
#' @param timeout_secs An integer constant. The default value, defined in 
#' CONSTANTS.R is REQUEST_TIMEOUT. This value determines the default timeout
#' value for the httr2 request object. When downloading large files, it can be
#' useful to set this value to a large number.
#' 
#' @returns Full file name to the asset or NULL.
#' 
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' download_session_asset() # Download's 'numbers' file from volume 1.
#' download_session_asset(asset_id = 11643, session_id = 9825, file_name = "rdk.mp4")
#' # Downloads a display with a random dot kinematogram (RDK).
#' }
#' }
#' @export
download_session_asset <- function(asset_id = 1,
                                   session_id = 9807,
                                   file_name = NULL,
                                   #target_dir = paste0("./", session_id),
                                   target_dir = tempdir(),
                                   timeout_secs = REQUEST_TIMEOUT,
                                   vb = options::opt("vb"),
                                   rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(asset_id) == 1)
  assertthat::assert_that(is.numeric(asset_id))
  assertthat::assert_that(asset_id >= 1)
  
  assertthat::assert_that(is.numeric(session_id))
  assertthat::assert_that(length(session_id) == 1)
  assertthat::assert_that(session_id >= 1)
  
  assertthat::assert_that(is.character(target_dir))
  assertthat::assert_that(length(target_dir) == 1)
  assertthat::assert_that(dir.exists(target_dir))
  
  assertthat::is.number(timeout_secs)
  assertthat::assert_that(length(timeout_secs) == 1)
  assertthat::assert_that(timeout_secs > 0)
  
  assertthat::assert_that(length(vb) == 1)
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
  
  this_rq <- rq %>%
    httr2::req_url(sprintf(DOWNLOAD_FILE, session_id, asset_id)) %>%
    httr2::req_progress()
  
  if (vb)
    message("Attempting to download file with asset_id ",
            asset_id,
            " from session_id ",
            session_id, ".")
  
  resp <- tryCatch(
    httr2::req_perform(this_rq),
    httr2_error = function(cnd) {
      if (vb)
      message("Error downloading file with asset_id ",
              asset_id,
              " from session_id ",
              session_id, ".")
      NULL
    }

  )
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  }
  
  # Gather asset format info
  format_mimetype <- NULL
  format_extension <- NULL
  this_file_extension <- list_asset_formats(vb = vb) %>%
    dplyr::filter(httr2::resp_content_type(resp) == format_mimetype) %>%
    dplyr::select(format_extension) %>%
    as.character()
  
  # Check file name or generate
  if (is.null(this_file_extension)) {
    if (vb)
      message("No matching file extension for ",
              httr2::resp_content_type(resp))
    return(NULL)
  }
  
  if (is.null(file_name)) {
    if (vb)
      message("Missing file name, creating temporary file name.")
    file_name = tempfile(paste0(session_id, "_", asset_id, "_"),
                         fileext = paste0(".", this_file_extension))
  }
  assertthat::is.string(file_name)
  
  if (file.exists(file_name)) {
    if (vb)
      message("File exists. Generating new unique name.\n")
    file_name <- file.path(dirname(file_name),
                           paste0(
                             session_id,
                             "-",
                             asset_id,
                             "-",
                             format(Sys.time(), "%F-%H%M-%S"),
                             paste0(".", this_file_extension)
                           ))
  }
  
  if (!(this_file_extension == xfun::file_ext(file_name))) {
    if (vb)
      message("File name ",
              file_name,
              " doesn't match extension ",
              this_file_extension)
    return(NULL)
  }
  
  write_file <- tryCatch(
    error = function(cnd) {
      if (vb)
        message("Failure writing file ", file_name)
      NULL
    },
    {
      file_con <- file(file_name, "wb")
      writeBin(resp$body, file_con)
      close(file_con)
    }
  )
  
  if (!is.null(write_file)) {
    file_name
  } else {
    write_file
  }
}
