#' Functions to interact with modArchive
#' 
#' [ModArchive](https://ModArchive.org) is one of the largest online archives of module
#' files. These functions will assist in accessing this archive.
#' For mor information see `vignette("modarchive")`.
#' @seealso [modland_search()]
#' @param mod_id An `integer` code used as module identifier in the
#' ModArchive database. A `mod_id` can be obtained by performing a
#' search with for instance `modarchive_search_mod()`.
#' @param api Most ModArchive functions require a personal secret API key.
#' This key can be obtained from the ModArchive forum. See
#' `vignette("modarchive")` for more details.
#' @param read_fun Function that accepts an URL first argument.
#' By default it is [`read_mod()`] and is used to read the file.
#' You can replace it with other functions such as `ProTrackR2::pt2_read_mod()`.
#' @param text Text (`character`) used for searching. In some functions
#' the asterisk symbol `*` can be used as a wildcard in the search.
#' @param genre A genre of music to limit your search to. See
#' `modarchive_genres()` for a list of available values.
#' @param where A `character` string specifying where to search.
#' See the 'usage' section for allowed values.
#' @param by A `character` string specifying which aspect to view the
#' results by. See the 'usage' section for allowed values.
#' @param format A `character` string specifying to which file format
#' the search should be limited. See 'usage' section for allowed values.
#' @param size A vector of two `integer` values, specifying a filter
#' to apply to the search results. It filters the results to the file size range
#' specified here in kB. When omitted, all file sizes are returned.
#' @param channels A vector of two `integer` values, specifying a filter
#' to apply to the search results. It filters the results to the specified range
#' of number of channels in the module. When omitted, modules with any
#' number of channels are returned.
#' @param page Many of the ModArchive functions return paginated tables.
#' When this argument is omitted, the first page is returned. Use an
#' `integer` value to return a specific page. The total number of pages
#' of a search or view is returned as an attribute to the returned
#' `data.frame`.
#' @param ... Arguments passed on to `read_fun`
#' @returns Most functions documented here return a `data.frame`
#' with information about one or more modules, or an artist. `NULL`
#' is returned in case a search has no results.
#' 
#' `modarchive_download()` returns the result of calling `read_fun`
#' on the requested module.
#' 
#' `modarchive_requests()` returns the number of requests that
#' you made this month using the API key, and how many are available.
#' 
#' `modarchive_api()` returns your API key, when you have set it as
#' environmental variable (`"MODARCHIVE_API"`) or session option
#' (`"modarchive_api"`). When it is not set it will return `""`.
#' 
#' `modarchive_genres()` returns a vector of `character` strings,
#' listing the music genres specified by ModArchive.
#' @examples
#' elekfunk <- modarchive_download(41529)
#' 
#' ## Check how many API requests are left this month
#' reqs <- modarchive_requests()
#' if (length(reqs) > 0) {
#'   reqs <- 1 - reqs$current / reqs$maximum
#' } else {
#'   reqs <- 0
#' }
#' 
#' ## The examples below will only work with a valid
#' ## API key for modArchive and if more than 25%
#' ## of the monthly requests are left:
#' if (modarchive_api() != "" && reqs > 0.25) {
#'   
#'   mod_info <- modarchive_info(41529)
#'   if (nrow(mod_info) > 0) mod_info$url[[1]]
#'   info_search <- modarchive_search_mod("*intro.mod",
#'                                        size = c(8L, 10L),
#'                                        channels = c(1L, 4L))
#'   info_genre  <- modarchive_search_genre("Chiptune", "IT")
#'   info_hash   <- modarchive_search_hash("8f80bcab909f700619025bd7f2975749")
#'   info_artist <- modarchive_search_artist("89200")
#'   info_list   <- modarchive_view_by("A", "view_by_list", "XM",
#'                                     page = 2)
#'   info_random <- modarchive_random("Comedy")
#' }
#' @rdname modarchive
#' @export
modarchive_info <- function(mod_id, api = modarchive_api()) {
  mod_id      <- as.integer(mod_id[[1]])
  api         <- .check_api(api)
  result      <- NULL
  
  .modarchive_info(
    key     = api,
    request = "view_by_moduleid",
    query   = mod_id
  )
}

#' @rdname modarchive
#' @export
modarchive_search_mod <- function(
    text,
    where = c("filename_or_songtitle", "filename_and_songtitle", "filename",
              "songtitle", "module_instruments", "module_comments"),
    format = c("unset", "669", "AHX", "DMF", "HVL", "IT", "MED", "MO3",
               "MOD", "MTM", "OCT", "OKT", "S3M", "STM", "XM"),
    size,
    channels,
    page,
    api = modarchive_api()
) {
  api         <- .check_api(api)
  where       <- match.arg(where)
  format      <- match.arg(format)
  if (missing(size)) size <- NULL else {
    size <- sprintf("%i-%i", size[[1]], size[[2]])
  }
  if (missing(channels)) channels <- NULL else {
    channels <- sprintf("%i-%i", channels[[1]], channels[[2]])
  }
  if (format == "unset") format <- NULL
  if (missing(page))       page <- NULL
  if(!is.null(page))       page <- as.integer(page[[1]])

  .modarchive_info(
    key      = api,
    request  = "search",
    query    = text,
    type     = where,
    format   = format,
    size     = size,
    channels = channels,
    page     = page
  )
}

#' @rdname modarchive
#' @export
modarchive_search_genre <- function(
    genre  = c("unset", modarchive_genres()),
    format = c("unset", "669", "AHX", "DMF", "HVL", "IT", "MED", "MO3",
               "MOD", "MTM", "OCT", "OKT", "S3M", "STM", "XM"),
    size,
    channels,
    page,
    api = modarchive_api()) {
  api         <- .check_api(api)
  format      <- match.arg(format)
  if (missing(size)) size <- NULL else {
    size <- sprintf("%i-%i", size[[1]], size[[2]])
  }
  if (missing(channels)) channels <- NULL else {
    channels <- sprintf("%i-%i", channels[[1]], channels[[2]])
  }
  genre       <- match.arg(genre)
  genre       <- .genre.table$genre.id[.genre.table$genre == genre]
  
  if (genre == "unset")   genre <- ""
  if (format == "unset") format <- NULL
  if (missing(page))       page <- NULL
  if(!is.null(page))       page <- as.integer(page[[1]])
  
  .modarchive_info(
    key      = api,
    request  = "search",
    type     = "genre",
    query    = genre,
    format   = format,
    size     = size,
    channels = channels,
    page     = page
  )
}

#' @rdname modarchive
#' @export
modarchive_search_hash <- function(text, api = modarchive_api()) {
  text <- as.character(text[[1]])
  api  <- .check_api(api)
  .modarchive_info(
    key     = api,
    request = "search",
    type    = "hash",
    query   = text
  )
}

#' @rdname modarchive
#' @export
modarchive_random <- function(
    genre  = modarchive_genres(),
    format = c("unset", "669", "AHX", "DMF", "HVL", "IT", "MED", "MO3",
               "MOD", "MTM", "OCT", "OKT", "S3M", "STM", "XM"),
    size,
    page,
    api = modarchive_api()) {
  api         <- .check_api(api)
  format      <- match.arg(format)
  if (missing(size)) size <- NULL else {
    size <- sprintf("%i-%i", size[[1]], size[[2]])
  }
  genre       <- match.arg(genre)
  genre       <- .genre.table$genre.id[.genre.table$genre == genre]
  
  if (format == "unset") format <- NULL
  if (missing(page))       page <- NULL
  if(!is.null(page))       page <- as.integer(page[[1]])
  .modarchive_info(
    key     = api,
    request = "random",
    genreid = genre,
    format  = format,
    size    = size,
    page    = page
  )
}

#' @rdname modarchive
#' @export
modarchive_search_artist <- function(text, page, api = modarchive_api()) {
  api  <- .check_api(api)
  text <- as.character(text[[1]])
  if (missing(page))       page <- NULL
  if(!is.null(page))       page <- as.integer(page[[1]])
  
  .modarchive_info(
    key     = api,
    request = "search_artist",
    query   = text,
    page    = page,
    pick    = "items/item"
  )
}

#' @rdname modarchive
#' @export
modarchive_view_by <- function(
    text,
    by = c("view_by_list",
           "view_by_rating_comments",
           "view_by_rating_reviews",
           "view_modules_by_artistid",
           "view_modules_by_guessed_artist"),
    format = c("unset", "669", "AHX", "DMF", "HVL", "IT", "MED", "MO3",
               "MOD", "MTM", "OCT", "OKT", "S3M", "STM", "XM"),
    size,
    page,
    api = modarchive_api()) {
  text        <- substr(text, 0L, 1L) |> toupper()
  api         <- .check_api(api)
  request     <- match.arg(by)
  format      <- match.arg(format)
  if (missing(size)) size <- NULL else {
    size <- sprintf("%i-%i", size[[1]], size[[2]])
  }
  if (format == "unset") format <- NULL
  if (missing(page))       page <- NULL
  if(!is.null(page))       page <- as.integer(page[[1]])
  
  .modarchive_info(
    key     = api,
    request = request,
    query   = text,
    format  = format,
    size    = size,
    page    = page
  )
}

#' @rdname modarchive
#' @export
modarchive_download <- function(mod_id, read_fun = read_mod, ...) {
  mod_id <- as.integer(mod_id[[1]])
  url <- paste0("https://api.modarchive.org/downloads.php?moduleid=", mod_id)
  .try_online({
    read_fun(url, ...) |> suppressWarnings()
  }, "modarchive")
}

#' @rdname modarchive
#' @export
modarchive_api <- function() {
  api <- Sys.getenv("MODARCHIVE_API")
  if (api == "") {
    api <- getOption("modarchive_api", "")
  }
  return(api)
}

#' @rdname modarchive
#' @export
modarchive_requests <- function(api = modarchive_api()) {
  result <- .modarchive_req(request = "view_requests", key = api)
  if (is.null(result)) return(NULL)
  xml2::xml_find_all(result, "requests") |> xml2::as_list() |>
    unlist() |> as.list() |> lapply(as.integer)
}

#' @rdname modarchive
#' @export
modarchive_genres <- function() {
  .genre.table$genre[-1]
}

.modarchive_tool <- "https://api.modarchive.org/xml-tools.php"

.modarchive_req <- function(...) {
  if ((list(...))[["key"]] != "" && .check_namespace()) {
    x <- .try_online({
      httr2::request(.modarchive_tool) |>
        httr2::req_url_query(...) |>
        httr2::req_perform()
    }, "modarchive")
    if (!is.null(x)) httr2::resp_body_xml(x) else NULL
  } else NULL
}

.modarchive_info <- function(..., pick = "module") {
  ## Only try if we have an API key and httr2 namespace is available
  x <- .modarchive_req(...)
  if (!is.null(x)) {
    atts <-
      x |>
      xml2::as_list()
    atts <- atts$modarchive[names(atts$modarchive) != pick]
    errors <- xml2::xml_find_all(x, "error") |> xml2::as_list()
    if (length(errors) > 0) {
      message(paste0(unlist(errors), collapse = "\n"))
      return(NULL)
    }
    result <-
      x |>
      xml2::xml_find_all(pick) |>
      xml2::as_list()
    result <-
      do.call(rbind, result) |>
      as.data.frame()
    fun <- \(x) {
      if (length(x) == 0) return(x)
      if (is.null(names(x[[1]]))) {
        unlist(x)
      } else {
        lapply(x, fun)
      }
    }
    
    temp <- lapply(result, fun)
    result <- data.frame(row = seq_len(length(result[[1]])))
    for (col_name in names(temp)) {
      result[[col_name]] <- temp[[col_name]]
    }
    rm(temp)
    result <- result[-1]
    
    attributes(result) <-
      c(attributes(result), atts)
    return(result)
  }
  NULL
}

.genre.table <- read.table(
  text = "
genre,                 genre.id
unset,                    unset
Alternative,                 48
Gothic,                      38
Grunge,                     103
Metal - Extreme,             37
Metal (general),             36
Punk,                        35
Chiptune,                    54
Demo Style,                  55
One Hour Compo,              53
Chillout,                   106
Electronic - Ambient,         2
Electronic - Breakbeat,       9
Electronic - Dance,           3
Electronic - Drum and Bass,   6
Electronic - Gabber,         40
Electronic - Hardcore,       39
Electronic - House,          10
Electronic - IDM,            99
Electronic - Industrial,     34
Electronic - Jungle,         60
Electronic - Minimal,       101
Electronic - Other,         100
Electronic - Progressive,    11
Electronic - Rave,           65
Electronic - Techno,          7
Electronic (general),         1
Trance - Acid,               63
Trance - Dream,              67
Trance - Goa,                66
Trance - Hard,               64
Trance - Progressive,        85
Trance - Tribal,             70
Trance (general),            71
Big Band,                    74
Blues,                       19
Jazz - Acid,                 30
Jazz - Modern,               31
Jazz (general),              29
Swing,                       75
Bluegrass,                  105
Classical,                   20
Comedy,                      45
Country,                     18
Experimental,                46
Fantasy,                     52
Folk,                        21
Fusion,                     102
Medieval,                    28
New Ages,                    44
Orchestral,                  50
Other,                       41
Piano,                       59
Religious,                   49
Soundtrack,                  43
Spiritual,                   47
Video Game,                   8
Vocal Montage,               76
World,                       42
Ballad,                      56
Disco,                       58
Easy Listening,             107
Funk,                        32
Pop - Soft,                  62
Pop - Synth,                 61
Pop (general),               12
Rock - Hard,                 14
Rock - Soft,                 15
Rock (general),              13
Christmas,                   72
Halloween,                   82
Hip-Hop,                     22
R and B,                     26
Reggae,                      27
Ska,                         24
Soul,                        25",
  header = T, sep = ",", stringsAsFactors = F, strip.white = T)
