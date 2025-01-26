#' Functions to interact with modLand
#' 
#' [ModLand](https://modland.com/) is an online archive containing over 400,000
#' module files. These functions allow you to search in and download from this archive.
#' @seealso [modarchive_search_mod()]
#' @param text Search text, to look for on [modland](https://modland.com/).
#' @param format A single length `character` vector, indicating the
#' tracker file format. Can be obtained from a `modland_search()`.
#' @param author A single length `character` vector, indicating the
#' module author name. Can be obtained from a `modland_search()`.
#' @param title A single length `character` vector, indicating the
#' module title. Can be obtained from a `modland_search()`.
#' @param mirror A single length `character` vector. Should contain one of the
#' mirrors listed in the 'usage' section. Select a mirror site from which
#' the module file needs to be downloaded.
#' @param read_fun Function that accepts an URL first argument.
#' By default it is [`read_mod()`] and is used to read the file.
#' You can replace it with other functions such as `ProTrackR2::pt2_read_mod()`.
#' @param ... Arguments passed on to `read_fun`
#' @returns In case of `modland_search()` a `data.frame` with search
#' results are returned (or `NULL` if there are no results).
#' 
#' `modland_download()` will return the result of the function
#' specified by `read_fun`. By default it will return an `openmpt` class object.
#' @examples
#' search_result <- modland_search("elekfunk mod")
#' 
#' ## The URL in the search results will download a rendered
#' ## ogg file. If you want to download te original mod file,
#' ## use this: 
#' if (length(search_result) > 0) {
#'   mod <- modland_download(search_result$format[[1]],
#'                           search_result$author[[1]],
#'                           search_result$title[[1]])
#' }
#' @rdname modland
#' @export
modland_search <- function(text, ...) {
  x <- .try_online({
    httr2::request("https://www.exotica.org.uk/mediawiki/extensions/ExoticASearch/Modland_xbmc.php") |>
      httr2::req_url_query(qs = text) |>
      httr2::req_perform()
  }, "modland")
  if (!is.null(x)) {
    x <-
      x |>
      httr2::resp_body_html() |>
      xml2::xml_find_all("body/results/item") |>
      xml2::as_list() |>
      lapply(\(x) lapply(x, `[[`, 1L)) |>
      lapply(as.data.frame, stringsAsFactors = FALSE)
    x <- do.call(rbind, x)
    x
  }
}

#' @rdname modland
#' @export
modland_download <- function(
    format, author, title,
    mirror = c("modland.com",
               "ftp.modland.com",
               "antarctica.no",
               "ziphoid.com",
               "exotica.org.uk"),
    read_fun = read_mod,
    ...) {
  mirror_args <- args(modland_download) |> as.list()
  mirror_args <- mirror_args[["mirror"]] |> eval()
  mirror <- match(match.arg(mirror), mirror_args)
  mirror <- c("https://modland.com/pub/modules/",
              "ftp://ftp.modland.com/pub/modules/",
              "https://modland.antarctica.no/pub/modules/",
              "https://modland.ziphoid.com/pub/modules/",
              "https://files.exotica.org.uk/modland/?file=pub/modules/")[mirror]
  url_suffix <- paste(utils::URLencode(format),
                      utils::URLencode(author),
                      utils::URLencode(title),
                      sep = "/")
  .try_online({
    read_fun(paste0(mirror, url_suffix), ...)
  }, "modland")
}