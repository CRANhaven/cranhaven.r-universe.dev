#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Download Video From Databrary.
#'
#' @param asset_id Asset id for target file.
#' @param session_id Slot/session number where target file is stored.
#' @param file_name Name for downloaded file.
#' @param target_dir Directory to save the downloaded file.
#' Default is a temporary directory given by a call to `tempdir()`.
#' @param rq An `httr2` request object.
#'
#' @returns Full file name to the asset.
#' 
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' download_video() # Download's 'numbers' file from volume 1.
#' download_video(asset_id = 11643, session_id = 9825, file_name = "rdk.mp4")
#' #' # Downloads a display with a random dot kinematogram (RDK).
#' }
#' }
#'
#' @export
download_video <- function(asset_id = 1,
                           session_id = 9807,
                           file_name = tempfile(paste0(session_id, "_", asset_id, "_"), fileext = ".mp4"),
                           target_dir = tempdir(),
                           vb = options::opt("vb"),
                           rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(asset_id) == 1)
  assertthat::assert_that(is.numeric(asset_id))
  assertthat::assert_that(asset_id >= 1)
  
  assertthat::assert_that(length(session_id) == 1)
  assertthat::assert_that(is.numeric(session_id))
  assertthat::assert_that(session_id >= 1)
  
  assertthat::assert_that(length(file_name) == 1)
  assertthat::assert_that(is.character(file_name))
  
  assertthat::assert_that(length(target_dir) == 1)
  assertthat::assert_that(is.character(target_dir))
  assertthat::assert_that(dir.exists(target_dir))
  
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
  
  this_rq <- rq %>%
    httr2::req_url(sprintf(DOWNLOAD_FILE, session_id, asset_id)) %>%
    httr2::req_progress()
  
  if (file.exists(file_name)) {
    if (vb)
      message("File exists. Generating new unique name.\n")
    file_name <- file.path(tempdir(),
                           paste0(
                             session_id,
                             "-",
                             asset_id,
                             "-",
                             format(Sys.time(), "%F-%H%M-%S"),
                             ".mp4"
                           ))
  }
  
  if (vb)
    message("Attempting to download video with asset_id ",
            asset_id,
            " from session_id ",
            session_id)
  
  resp <- tryCatch(
    httr2::req_perform(this_rq),
    httr2_error = function(cnd) {
      if (vb)
        message(
          message(
            "Error retrieving video with asset_id ",
            asset_id,
            " from session_id ",
            session_id
          )
        )
      NULL
    }
  )
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  }
  
  if (httr2::resp_content_type(resp) == "video/mp4") {
    file_con <- file(file_name, "wb")
    writeBin(resp$body, file_con)
    close(file_con)
    file_name
  } else {
    message("Content type is ", httr2::resp_content_type(resp))
    NULL
  }
}
