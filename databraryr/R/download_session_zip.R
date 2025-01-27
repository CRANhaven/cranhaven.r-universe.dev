#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Download Zip Archive From Databrary Session.
#'
#' @param vol_id Volume number.
#' @param session_id Slot/session number.
#' @param out_dir Directory to save output file.
#' @param file_name Name for downloaded file, default is 'test.zip'.
#' @param rq An `httr2` request object. Default is NULL.
#'
#' @returns Full filename of the downloaded file.
#' 
#' @inheritParams options_params
#' 
#' @examples
#' \donttest{
#' \dontrun{
#' download_session_zip() # Downloads Zip Archive from volume 31, session 9803
#' }
#' }
#'
#' @export
download_session_zip <- function(vol_id = 31,
                                 session_id = 9803,
                                 out_dir = tempdir(),
                                 file_name = "test.zip",
                                 vb = options::opt("vb"),
                                 rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(vol_id) == 1)
  assertthat::assert_that(is.numeric(vol_id))
  assertthat::assert_that(vol_id >= 1)
  
  assertthat::assert_that(length(session_id) == 1)
  assertthat::assert_that(is.numeric(session_id))
  assertthat::assert_that(session_id >= 1)
  
  assertthat::assert_that(length(out_dir) == 1)
  assertthat::assert_that(is.character(out_dir))
  
  assertthat::assert_that(length(file_name) == 1)
  assertthat::assert_that(is.character(file_name))
  
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
  rq <- rq %>%
    httr2::req_url(sprintf(GET_SESSION_ZIP, vol_id, session_id))
  
  resp <- tryCatch(
    httr2::req_perform(rq),
    httr2_error = function(cnd) {
      if (vb)
        message("Error downloading zip from sprintf(GET_SESSION_ZIP, vol_id, session_id)")
      NULL
    }
  )
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(NULL)
  }
  
  bin <- NULL
  bin <- httr2::resp_body_raw(resp)
  
  if (is.null(bin)) {
    if (vb)
      message("Null file returned")
    return(NULL)
  }
  
  if (file_name == "test.zip") {
    if (vb) {
      if (vb)
        message("File name unspecified. Generating unique name.")
    }
    file_name <- make_zip_fn_sess(out_dir, vol_id, session_id)
  }
  if (vb) {
    if (vb)
      message(paste0("Downloading zip file as: \n'", file_name, "'."))
  }
  writeBin(bin, file_name)
  file_name
}

#-------------------------------------------------------------------------------
make_zip_fn_sess <- function(out_dir, vol_id, session_id) {
  # Check parameters
  assertthat::is.string(out_dir)
  assertthat::is.writeable(out_dir)
  assertthat::assert_that(length(out_dir) == 1)
  
  assertthat::assert_that(length(vol_id) == 1)
  assertthat::assert_that(is.numeric(vol_id))
  assertthat::assert_that(vol_id >= 1)
  
  assertthat::assert_that(length(session_id) == 1)
  assertthat::assert_that(is.numeric(session_id))
  assertthat::assert_that(session_id >= 1)
  
  paste0(
    out_dir,
    "/vol-",
    vol_id,
    "-sess-",
    session_id,
    "-",
    format(Sys.time(), "%F-%H%M-%S"),
    ".zip"
  )
}
