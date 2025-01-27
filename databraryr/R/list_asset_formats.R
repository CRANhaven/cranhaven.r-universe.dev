#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' List Stored Assets (Files) By Type.
#' 
#' @returns A data frame with information about the data formats Databrary
#' supports.
#' 
#' @inheritParams options_params
#' 
#' @examples
#' \donttest{
#' list_asset_formats()
#' }
#' @export
list_asset_formats <- function(vb = options::opt("vb")) {
  # Check parameters
  assertthat::assert_that(length(vb) == 1)
  assertthat::assert_that(is.logical(vb))
  
  db_constants <- databraryr::assign_constants()
  
  id <- NULL
  mimetype <- NULL
  extension <- NULL
  name <- NULL
  transcodable <- NULL
  
  if (!is.null(db_constants$format)) {
    purrr::map(db_constants$format, as.data.frame) %>%
      purrr::list_rbind() %>%
      dplyr::rename(format_id = id,
                    format_mimetype = mimetype,
                    format_extension = extension,
                    format_name = name,
                    format_transcodable = transcodable)
  } else {
    if (vb)
      message("No format information retrieved.")
    return(NULL)
  }
}
