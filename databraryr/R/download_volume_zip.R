#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Download Zip Archive of All Data in a Volume.
#'
#' @param vol_id Volume number.
#' @param out_dir Directory to save output file.
#' @param file_name Name for downloaded file, default is 'test.mp4'.
#' @param rq An `httr2` request object. Default is NULL.
#'
#' @returns Full filename of the downloaded file.
#' 
#' @inheritParams options_params
#' 
#' @examples
#' \donttest{
#' \dontrun{
#' download_volume_zip() # Zip file of all data from volume 31, the default.
#' }
#' }
#'
#' @export
download_volume_zip <- function(vol_id = 31,
                                out_dir = tempdir(),
                                file_name = "test.zip",
                                vb = options::opt("vb"),
                                rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(vol_id) == 1)
  assertthat::assert_that(is.numeric(vol_id))
  assertthat::assert_that(vol_id >= 1)
  
  assertthat::assert_that(length(out_dir) == 1)
  assertthat::assert_that(is.character(out_dir))
  
  assertthat::assert_that(length(file_name) == 1)
  assertthat::assert_that(is.character(file_name))
  
  assertthat::assert_that(length(vb) == 1)
  assertthat::assert_that(is.logical(vb))
  
  assertthat::assert_that(is.null(rq) |
                            ("httr2_request" %in% class(rq)))
  
  # Handle NULL request
  if (is.null(rq)) {
    if (vb) {
      message("\nNULL request object. Will generate default.")
      message("Not logged in. Only public information will be returned.")
    }
    rq <- databraryr::make_default_request()
  }
  rq <- rq %>%
    httr2::req_url(sprintf(GET_VOLUME_ZIP, vol_id))
  
  resp <- tryCatch(
    httr2::req_perform(rq),
    httr2_error = function(cnd) {
      if (vb) message("Error downloading zip archive from vol_id ", vol_id)
      NULL
    }
  )
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  }
  
  bin <- NULL
  bin <- httr2::resp_body_raw(resp)

  if (is.null(bin)) {
    if (vb) message("Null file returned")
    return(NULL)
  }
  
  if (file_name == "test.zip") {
    if (vb) {
      if (vb)
        message("File name unspecified. Generating unique name.")
    }
    file_name <- make_zip_fn_vol(out_dir, vol_id)
  }
  if (vb) {
    if (vb)
      message(paste0("Downloading zip file as: \n'", file_name, "'."))
  }
  writeBin(bin, file_name)
  file_name
}

#-------------------------------------------------------------------------------
make_zip_fn_vol <- function(out_dir, vol_id) {
  
  # Check parameters
  assertthat::is.string(out_dir)
  assertthat::is.writeable(out_dir)
  assertthat::assert_that(length(out_dir) == 1)
  
  assertthat::assert_that(length(vol_id) == 1)
  assertthat::assert_that(is.numeric(vol_id))
  assertthat::assert_that(vol_id >= 1)
  
  paste0(
    out_dir,
    "/vol-",
    vol_id,
    "-",
    format(Sys.time(), "%F-%H%M-%S"),
    ".zip"
  )
}
