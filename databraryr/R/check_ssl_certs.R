#' Check SSL Certificates For nyu.databary.org.
#' 
#' `check_ssl_certs` checks the SSL certificates for nyu.databrary.org
#' and returns a data frame with the relevant information.
#' 
#' @param host Target URL. Defaults to 'nyu.databrary.org'.
#' 
#' @returns A data frame with information about the SSL certificates.
#' 
#' @examples
#' \donttest{
#' check_ssl_certs()
#' }
#' @export
check_ssl_certs <- function(host = "nyu.databrary.org") {
  # Check parameter
  assertthat::assert_that(is.character(host))

  x <- openssl::download_ssl_cert(host)
  validity_dates <- lapply(x, `[[`, "validity")
  issuer <- lapply(x, `[[`, "issuer")
  
  df <- data.frame(issuer = unlist(issuer),
                   start_date = unlist(lapply(validity_dates, '[[', 1)),
                   exp_date = unlist(lapply(validity_dates, '[[', 2)))
  
  df
}
