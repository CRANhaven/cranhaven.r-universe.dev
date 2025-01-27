#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Download Session Spreadsheet As CSV
#'
#' @description Databrary generates a CSV-formated spreadsheet that summarizes
#' information about individual sessions. This command downloads that CSV file
#' as a temporary file or with a name specified by the user.
#'
#' @param vol_id An integer. Target volume number. Default is 1.
#' @param file_name A character string. Name for the output file.
#' Default is 'test.csv'.
#' @param target_dir A character string. Directory to save downloaded file.
#' Default is `tempdir()`.
#' @param as_df A logical value. Convert the data from a list to a data frame.
#' Default is FALSE.
#' @param rq An `httr2` request object. Default is NULL.
#'
#' @returns A character string that is the name of the downloaded file or a data frame if `as_df` is TRUE.
#'
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' download_session_csv() # Downloads "session" CSV for volume 1
#' }
#' }
#'
#' @export
download_session_csv <- function(vol_id = 1,
                                 file_name = "test.csv",
                                 target_dir = tempdir(),
                                 as_df = FALSE,
                                 vb = options::opt("vb"),
                                 rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(vol_id) == 1)
  assertthat::assert_that(is.numeric(vol_id))
  assertthat::assert_that(vol_id >= 1)
  
  assertthat::assert_that(length(file_name) == 1)
  assertthat::assert_that(is.character(file_name))
  
  assertthat::assert_that(length(target_dir) == 1)
  assertthat::assert_that(is.character(target_dir))
  
  assertthat::assert_that(length(as_df) == 1)
  assertthat::assert_that(is.logical(as_df))
  
  assertthat::assert_that(length(vb) == 1)
  assertthat::assert_that(is.logical(vb))
  
  assertthat::assert_that(is.null(rq) |
                            ("httr2_request" %in% class(rq)))
  
  # Handle NULL request
  if (is.null(rq)) {
    if (vb) {
      message("NULL request object. Will generate default.")
      message("Not logged in. Only public information will be returned.")
    }
    rq <- databraryr::make_default_request()
  }
  this_rq <- rq %>%
    httr2::req_url(sprintf(GET_SESSION_CSV, vol_id))
  
  if (vb)
    message(paste0("Downloading spreadsheet from vol_id ", vol_id, '.'))
  resp <- tryCatch(
    httr2::req_perform(this_rq),
    httr2_error = function(cnd) {
      if (vb)
        message("Error retrieving spreadsheet from vol_id ", vol_id, ".")
      NULL
    }
  )
  
  if (is.null(resp)) {
    message("Cannot access requested resource on Databrary. Exiting.")
    return(resp)
  }
  
  if (vb)
    message("Valid CSV downloaded from ", sprintf(GET_SESSION_CSV, vol_id))
  
  resp_txt <- httr2::resp_body_string(resp)
  df <-
    readr::read_csv(
      resp_txt,
      show_col_types = FALSE,
      col_types = readr::cols(.default = readr::col_character())
    ) %>%
    # Replace dashes in column names with underscores
    dplyr::rename_with(~ gsub("-", "_", .x, fixed = TRUE))
  if (as_df == TRUE) {
    df
  } else {
    if (vb)
      message("Saving CSV.")
    assertthat::is.writeable(target_dir)
    full_fn <- file.path(target_dir, file_name)
    assertthat::is.string(full_fn)
    readr::write_csv(df, full_fn)
    full_fn
  }
}
