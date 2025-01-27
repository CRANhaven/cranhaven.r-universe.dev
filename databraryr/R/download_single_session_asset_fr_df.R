#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Download Single Asset From Databrary
#'
#' @description Databrary stores file types (assets) of many types. This
#' function downloads an asset based on its system-unique integer identifer
#' (asset_id) and system-unique session (slot) identifier (session_id). It
#' is designed to work with download_session_assets_fr_df() so that multiple
#' files can be downloaded simultaneously.
#'
#' @param i An integer. Index into a row of the session asset data frame.
#' Default is NULL.
#' @param session_df A row from a data frame from `list_session_assets()`
#' or `list_volume_assets()`. Default is NULL>
#' @param target_dir A character string. Directory to save the downloaded file.
#' Default is a temporary directory given by a call to `tempdir()`.
#' @param add_session_subdir A logical value. Add add the session name to the
#' file path so that files are in a subdirectory specific to the session. Default
#' is TRUE.
#' @param overwrite A logical value. Overwrite an existing file. Default is TRUE.
#' @param make_portable_fn A logical value. Replace characters in file names
#' that are not broadly portable across file systems. Default is FALSE.
#' @param timeout_secs An integer. The seconds an httr2 request will run before
#' timing out. Default is 600 (10 min). This is to handle very large files.
#' @param rq A list in the form of an `httr2` request object. Default is NULL.
#'
#' @returns Full file name to the asset or NULL.
#' 
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' vol_1 <- list_session_assets(session_id = 9807)
#' a_1 <- vol_1[1,]
#' tmp_dir <- tempdir()
#' fn <- file.path(tmp_dir, paste0(a_1$asset_name, ".", a_1$format_extension))
#' download_single_session_asset_fr_df(a_1$asset_id,
#'   fn,
#'   session_id = a_1$session_id,
#'   vb = TRUE)
#'
#' }
#' }
#' @export
download_single_session_asset_fr_df <- function(i = NULL,
                                                session_df = NULL,
                                                target_dir = tempdir(),
                                                add_session_subdir = TRUE,
                                                overwrite = TRUE,
                                                make_portable_fn = FALSE,
                                                timeout_secs = REQUEST_TIMEOUT_VERY_LONG,
                                                vb = options::opt("vb"),
                                                rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(i) == 1)
  assertthat::is.number(i)
  assertthat::assert_that(i > 0)
  
  assertthat::assert_that(is.data.frame(session_df))
  assertthat::assert_that("session_id" %in% names(session_df))
  assertthat::assert_that("asset_id" %in% names(session_df))
  assertthat::assert_that("format_extension" %in% names(session_df))
  assertthat::assert_that("asset_name" %in% names(session_df))
  
  assertthat::assert_that(length(target_dir) == 1)
  assertthat::is.string(target_dir)
  assertthat::is.writeable(target_dir)
  
  assertthat::assert_that(length(add_session_subdir) == 1)
  assertthat::assert_that(is.logical(add_session_subdir))
  
  assertthat::assert_that(length(overwrite) == 1)
  assertthat::assert_that(is.logical(overwrite))
  
  assertthat::assert_that(length(make_portable_fn) == 1)
  assertthat::assert_that(is.logical(make_portable_fn))
  
  assertthat::is.number(timeout_secs)
  assertthat::assert_that(length(timeout_secs) == 1)
  assertthat::assert_that(timeout_secs > 0)
  
  assertthat::assert_that(length(vb) == 1)
  assertthat::assert_that(is.logical(vb))
  
  assertthat::assert_that(is.null(rq) |
                            ("httr2_request" %in% class(rq)))
  
  this_asset <- session_df[i, ]
  if (is.null(this_asset)) {
    if (vb)
      message("No asset for index ", i)
    return(NULL)
  }
  
  if (add_session_subdir) {
    full_fn <- file.path(
      target_dir,
      this_asset$session_id,
      paste0(this_asset$asset_name, ".", this_asset$format_extension)
    )
    if (vb)
      message("`add_session_subdir` is TRUE.")
  } else {
    full_fn <- file.path(target_dir,
                         paste0(this_asset$asset_name, ".", this_asset$format_extension))
    if (vb)
      message("`add_session_subdir` is FALSE.")
  }
  
  if (file.exists(full_fn)) {
    if (vb)
      message("File exists: ", full_fn)
    if (!overwrite) {
      if (vb)
        message("Generating new unique (time-stamped) file name.")
      full_fn <- file.path(
        dirname(full_fn),
        paste0(
          this_asset$session_id,
          "-",
          this_asset$asset_id,
          "-",
          format(Sys.time(), "%F-%H%M-%S"),
          paste0(".", this_asset$format_extension)
        )
      )
    } else {
      if (vb)
        message("Will overwrite existing file.")
    }
  }
  
  if (make_portable_fn) {
    if (vb)
      message("Making file name '", full_fn, "' portable.")
    full_fn <- make_fn_portable(full_fn, vb = vb)
  }
  assertthat::is.string(full_fn)
  
  if (!dir.exists(dirname(full_fn))) {
    if (vb) {
      message("Target directory not found: ", dirname(full_fn))
      message("Creating: ", dirname(full_fn))
    }
    dir.create(dirname(full_fn), recursive = TRUE)
  } else {
    if (vb)
      message("Target directory exists: ", dirname(full_fn))
    if (overwrite) {
      if (vb)
        message("Overwriting directory: ", dirname(full_fn))
    } else {
      if (vb)
        message("`overwrite` is FALSE. Skipping.")
      return(NULL)
    }
  }
  assertthat::is.writeable(dirname(full_fn))
  
  # Handle NULL rq
  if (is.null(rq)) {
    if (vb) {
      message("NULL request object. Will generate default.")
      message("Not logged in. Only public information will be returned.")
    }
    rq <- databraryr::make_default_request()
  }
  
  if (vb)
    message(
      "Downloading file with asset_id ",
      this_asset$asset_id,
      " from session_id ",
      this_asset$session_id
    )
  
  # Up default timeout for possibly big files
  rq <-
    httr2::req_timeout(rq, seconds = timeout_secs)
  
  this_rq <- rq %>%
    httr2::req_url(sprintf(DOWNLOAD_FILE, this_asset$session_id, this_asset$asset_id)) %>%
    httr2::req_progress()
  
  resp <- tryCatch(
    httr2::req_perform(this_rq),
    httr2_error = function(cnd)
      if (vb)
        message(
          "Error downloading asset ",
          this_asset$asset_name,
          " from session_id ",
          this_asset$session_id
        ),
    NULL
  )
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  }
  
  # if (is.null(resp)) {
  #   if (vb)
  #     message(
  #       "Download request for session ",
  #       this_asset$session_id,
  #       " asset ",
  #       this_asset$asset_id,
  #       " returned NULL. Skipping."
  #     )
  #   return(NULL)
  # }
  
  write_file <- tryCatch(
    error = function(cnd) {
      if (vb)
        message("Failure writing file ", full_fn)
      NULL
    },
    {
      file_con <- file(full_fn, "wb")
      writeBin(resp$body, file_con)
      close(file_con)
    }
  )
  
  if (!is.null(write_file)) {
    full_fn
  } else {
    write_file
  }
}
