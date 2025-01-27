#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' List Activity History in Databrary Session.
#'
#' If a user has access to a volume and session, this function returns the
#' history of modifications to that session.
#'
#' @param session_id Selected session/slot number.
#' @param rq An `httr2` request object. Defaults to NULL. To access the activity
#' history on a volume a user has privileges on. Create a request 
#' (`rq <- make_default_request()`); login using `make_login_client(rq = rq)`; 
#' then run `list_session_activity(session_id = <YOUR_SESSION_ID>, rq = rq)`

#' @returns A list with the activity history on a session/slot.
#' 
#' @inheritParams options_params 
#'
#' @examples
#' \donttest{
#' \dontrun{
#' # The following will only return output if the user has write privileges
#' # on the session.
#'
#' list_session_activity(session_id = 6256, vb = FALSE) # Activity for session 6256.
#' }
#' }
#' @export
list_session_activity <-
  function(session_id = 6256,
           vb = options::opt("vb"),
           rq = NULL) {
    # Check parameters
    assertthat::assert_that(length(session_id) == 1)
    assertthat::assert_that(is.numeric(session_id))
    assertthat::assert_that(session_id > 0)
    
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
      httr2::req_url(sprintf(GET_SESSION_ACTIVITY, session_id))
    
    if (vb) message("Retrieving activity for session id, ", session_id, ".")
    resp <- tryCatch(
      httr2::req_perform(rq),
      httr2_error = function(cnd) {
        NULL
      }
    )
    
    if (is.null(resp)) {
      message("Cannot access requested resource on Databrary. Exiting.")
      return(resp)
    } else {
      httr2::resp_body_json(resp)
    }
    #TODO: Reformat response.
  }
