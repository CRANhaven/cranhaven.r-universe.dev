#' Convert a ModPlug Tracker module to an audio file
#' 
#' Renders ModPlug Tracker music to an audio file and encodes it to a desired
#' output format (e.g. .mp3, .ogg, etc) using [`av::av_audio_convert()`].
#' @param mod A tracker module object of class `openmpt`
#' @param file Output audio file where the rendered audio is stored. The file name
#' extension is used to determine the type of encoding to be applied.
#' @param start_order Starting position (`integer` index starting at 0) in the pattern sequence table.
#' @param start_row Starting row (`integer` index starting at 0) of the pattern table.
#' @param sample_rate Output sample rate in Hz (samples per seconds).
#' @param duration Duration in seconds. Rendered sample will not be longer than this duration.
#' if set to `NA_real_` it is ignored and the module keeps rendering conform the specified [`control()`].
#' @param verbose Passed on to [`av::av_audio_convert()`].
#' @param ... Ignored
#' @returns Returns `NULL` invisibly
#' @examples
#' mod <- demo_mod()
#' 
#' destination <- tempfile(fileext = ".mp3")
#' 
#' convert_mod(mod, destination, duration = 2)
#' @export
convert_mod <- function(mod, file, start_order = 0L, start_row = 0L,
                        sample_rate = 44100L, duration = NA_real_, verbose = FALSE, ...) {
  curpos  <- position_seconds(mod)
  tryCatch({
    set_position_order_row(mod, start_order, start_row)
    tempwav <- tempfile(fileext = ".wav")
    render_(mod, tempwav, as.integer(sample_rate), duration)
    con     <- file(tempwav, "rb")
    temp    <- readBin(con, "raw", 1000)
    close(con)
    if (file |> toupper() |> endsWith(".WAV")) {
      file.rename(tempwav, file)
    } else {
      av::av_audio_convert(tempwav, file, verbose = verbose)
      unlink(tempwav)
    }
  }, finally = {
    position_seconds(mod) <- curpos
  })
  invisible(NULL)
}
