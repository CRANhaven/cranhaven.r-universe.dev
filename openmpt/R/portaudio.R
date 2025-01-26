#' Test if there is an audio device
#' 
#' Tests if an audio device is present on the system.
#' @returns Returns a logical value.
#' @export
has_audio_device <- function() {
  has_audio_device_()
}