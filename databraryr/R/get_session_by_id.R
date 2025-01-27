#' @eval options::as_params()
#' @name options_params
#' 
NULL

#' Get Session (Slot) Data From A Databrary Volume
#'
#' @param session_id An integer indicating a valid session/slot identifier
#' linked to a volume. Default value is 9807, the materials folder for volume 1.
#' @param vol_id An integer indicating the volume identifier. Default is 1.
#' @param rq An httr2 request object.
#'
#' @returns A JSON blob with the session data. If the user has previously logged
#' in to Databrary via `login_db()`, then session(s) that have restricted access
#' can be downloaded, subject to the sharing release levels on those session(s).
#'
#' @inheritParams options_params
#'
#' @examples
#' \donttest{
#' \dontrun{
#' get_session_by_id() # Default is Volume 1, Session 9807, the Materials folder
#' }
#' }
#' @export
get_session_by_id <-
  function(session_id = 9807,
           vol_id = 1,
           vb = options::opt("vb"),
           rq = NULL) {
    
    assertthat::assert_that(is.numeric(session_id))
    assertthat::assert_that(session_id > 0)
    assertthat::assert_that(length(session_id) == 1)
    
    assertthat::assert_that(is.numeric(vol_id))
    assertthat::assert_that(vol_id > 0)
    assertthat::assert_that(length(vol_id) == 1)
    
    assertthat::assert_that(is.logical(vb))
    assertthat::assert_that(length(vb) == 1)
    
    assertthat::assert_that(is.null(rq) |
                              ("httr2_request" %in% class(rq)))
    
    # Handle NULL rq
    if (is.null(rq)) {
      if (vb) {
        message("\nNULL request object. Will generate default.")
        message("Not logged in. Only public information will be returned.")  
      }
      rq <- databraryr::make_default_request()
    }
    
    #--------------------------------------------------------------------------
    extract_session_metadata <- function(volume_json) {
      
      assertthat::assert_that(is.list(volume_json))
      
      extract_single_session <- function(i, sessions) {
        this_session <- sessions$value[[i]]
        tibble::tibble(id = this_session$id, top = this_session$top, name = this_session$name)
      }
      
      these_sessions <- tibble::enframe(volume_json$containers)
      n_sessions <- dim(these_sessions)[1]
      purrr::map(1:n_sessions, extract_single_session, these_sessions) %>%
        purrr::list_rbind()
    }
    #--------------------------------------------------------------------------
    
    volume_json <- NULL
    volume_json <- get_volume_by_id(vol_id, vb, rq)
    
    if (!is.null(volume_json)) {
      session_metadata <- extract_session_metadata(volume_json)
      if (!(session_id %in% session_metadata$id)) {
        if (vb) message("Session ", session_id, " not found.")
        return(NULL)
      } else {
        rq <- rq %>%
          httr2::req_url(sprintf(QUERY_SLOT, session_id))
        resp <- tryCatch(
          httr2::req_perform(rq),
          httr2_error = function(cnd)
            NULL
        )
        if (is.null(resp)) {
          message("Cannot access requested resource on Databrary. Exiting.")
          return(resp)
        } else {
          httr2::resp_body_json(resp) 
        }
      }
    } else {
      if (vb) message("No data returned from volume ", vol_id)
      NULL
    }
  }
