.http_status_ok <- function(x) {
  if (!utils::hasName(x, "status_code")) return(TRUE)
  if (x$status_code >= 100 && x$status_code <= 199) {
    message(sprintf("Unexpected informational response from online resource (status %i).", x$status_code))
    return(FALSE)
  }
  if (x$status_code >= 300 && x$status_code <= 399) {
    message(sprintf("Unexpected redirection from online resource (status %i).", x$status_code))
    return(FALSE)
  }
  if (x$status_code >= 400 && x$status_code <= 499) {
    message(sprintf(paste("Online resource reported a client error (status %i).",
                          "You may have requested information that is not available,",
                          "please check your input.",
                          sep = "\n"), x$status_code))
    return(FALSE)
  }
  if (x$status_code >= 500 && x$status_code <= 599) {
    message(sprintf("Online resource reported a server error (status %i).\nPlease try again later.", x$status_code))
    return(FALSE)
  }
  if (x$status_code < 100 || x$status_code >= 600) {
    message(sprintf("Online resource responded with unknown status (status %i).", x$status_code))
    return(FALSE)
  }
  return(TRUE)
}

.try_online <- function(expr, resource) {
  result <- tryCatch(expr, error = function(e) {
    message(sprintf("Failed to collect information from %s.\n%s", resource, e$message))
    return(NULL)
  })
  if (is.null(result)) return(NULL)
  if (!.http_status_ok(result)) return(NULL)
  return(result)
}

.check_namespace <- function() {
  result <- requireNamespace("httr2") && requireNamespace("xml2")
  if (!result) message("Please install required packages 'httr2' and 'xml2' first!")
  result
}

.check_api <- function(api) {
  api <- as.character(api[[1]])
  if (is.na(api) || api == "") {
    api <- ""
    message(
      paste("This function will only work with a valid API key for modarchive.org",
            "please provide one")
    )
  }
  api
}