#' @importFrom attempt stop_if_not message_if_not
#' @importFrom curl has_internet
#' @import httr2
#' @import R6
check_internet <- function(){
  attempt::message_if_not(.x = has_internet(), msg = "Please check your internet connection")
}

#' Provide additional error information
#' @param resp response to be captured
#' @return An error character vector
#'
dhis2_error_message <- function(resp) {
 resp_status_desc(resp)
}
