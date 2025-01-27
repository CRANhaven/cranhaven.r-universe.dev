#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Log In To Databrary.org.
#'
#' @param email Databrary account email address.
#' @param password Databrary password (not recommended as it will displayed as you type)
#' @param store A boolean value. If TRUE store/retrieve credentials from the system keyring/keychain.
#' @param overwrite A boolean value. If TRUE and store is TRUE, overwrite/ update stored credentials in keyring/keychain.
#' @param SERVICE A character label for stored credentials in the keyring. Default is "databrary"
#' @param rq An `http` request object. Defaults to NULL.
#' 
#' @returns Logical value indicating whether log in is successful or not.
#' 
#' @inheritParams options_params
#' 
#' @examplesIf interactive()
#' login_db() # Queries user for email and password interactively.
#' @examples
#' \donttest{
#' \dontrun{
#'# The following shows how to use credentials that have been stored previously.
#'
#' login_db(email = "you@provider.com", store = TRUE)
#' 
#' }
#' }
#' @export
login_db <- function(email = NULL,
                     password = NULL,
                     store = FALSE,
                     overwrite = FALSE,
                     vb = options::opt("vb"),
                     SERVICE = KEYRING_SERVICE,
                     rq = NULL) {
  # Check parameters
  assertthat::assert_that(length(store) == 1)
  assertthat::assert_that(is.logical(store))
  
  assertthat::assert_that(length(overwrite) == 1)
  assertthat::assert_that(is.logical(overwrite))
  
  assertthat::assert_that(length(vb) == 1)
  assertthat::assert_that(is.logical(vb))
  
  assertthat::assert_that(length(SERVICE) == 1)
  assertthat::assert_that(is.character(SERVICE))
  
  assertthat::assert_that(is.null(rq) |
                            ("httr2_request" %in% class(rq)))
  # Handle NULL request
  if (is.null(rq)) {
    if (vb) {
      message("NULL request object. Will generate default.")
    }
    rq <- databraryr::make_default_request()
  }
  
  # If the user wants to store or use their stored credentials, check for keyring support
  if (store) {
    assertthat::assert_that(keyring::has_keyring_support(),
                            msg = "No keyring support; please use store=FALSE")
  }
  
  # Check or get email
  if (!is.null(email)) {
    assertthat::assert_that(assertthat::is.string(email))
  } else {
    message("Please enter your Databrary user ID (email).")
    email <- readline(prompt = "Email: ")
  }
  
  do_collect_password <- TRUE
  
  if (!is.null(password)) {
    assertthat::assert_that(assertthat::is.string(password))
    do_collect_password <- FALSE
  }
  
  # If the user wants to store or use their stored credentials and
  # doesn't provide a password
  if (store && is.null(password) && !overwrite) {
    if (vb)
      message("Retrieving password for service='",
              SERVICE,
              "' from keyring.")
    kl <- keyring::key_list(service = SERVICE)
    # Make sure our service is in the keyring
    if (exists('kl') && is.data.frame(kl)) {
      # If it is under the email entered, keep it to try later and not collect it here
      password <-
        try(keyring::key_get(service = SERVICE, username = email),
            silent = TRUE)
      if ("try-error" %in% class(password)) {
        do_collect_password <- TRUE
        if (vb)
          message("No password found in keyring for service='", SERVICE, ".")
      } else {
        do_collect_password <- FALSE
        if (vb)
          message("Password retrieved from keyring.")
      }
    } else {
      if (vb)
        message("Error retrieving keyring data for service='",
                SERVICE,
                "'.")
    }
  }
  
  # If we need to, securely collect the password
  if (do_collect_password) {
    password <-
      getPass::getPass("Please enter your Databrary password ")
  }
  
  is_login_successful <- FALSE
  
  if (is.null(rq))
    rq <- make_default_request()
  
  rq <- rq %>%
    httr2::req_url(LOGIN) %>%
    httr2::req_body_json(list(email = email, password = password))
  
  resp <- tryCatch(
    httr2::req_perform(rq),
    httr2_error = function(cnd)
      NULL
  )
  
  if (!is.null(resp) & httr2::resp_status(resp) == 200) {
    is_login_successful <- TRUE
  }
  
  # If the username/password was successful and the user wanted to store their credentials
  # Store them in the keyring
  if (is_login_successful) {
    if (store && (do_collect_password || overwrite)) {
      keyring::key_set_with_value(service = SERVICE,
                                  username = email,
                                  password = password)
      if (vb)
        message(paste0("Login successful; password stored in keyring/keychain"))
    } else {
      if (vb)
        message(paste("Login successful."))
    }
    return(TRUE)
  }
  
  if (store) {
    if (vb)
      message(
        paste0(
          'Login failed; nothing stored in keyring; HTTP status ',
          httr2::resp_status(resp),
          '\n'
        )
      )
  } else {
    if (vb)
      message(paste0('Login failed; HTTP status ', 
                     httr2::resp_status(resp), '\n'))
  }
  
  return(FALSE)
}
