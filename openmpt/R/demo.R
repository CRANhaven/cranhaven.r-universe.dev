#' Loads demo module included with the package
#' 
#' Reads the file `cyberrid.mod`. It is a [ProTracker](https://en.wikipedia.org/wiki/Protracker)
#' file create by [Jester](https://modarchive.org/index.php?request=view_profile&query=69138).
#' It is redistributed under the
#' [Attribution Non-commercial Share Alike license](https://creativecommons.org/licenses/by-nc-sa/4.0/).
#' The music was part of an Amiga computer demo named 'Extension' and was originally released in 1993.
#' @returns Returns the demo module tracker object of class `openmpt`
#' @examples
#' mod <- demo_mod()
#' @export
demo_mod <- function() {
  read_mod(system.file("cyberrid", "cyberrid.mod", package = "openmpt"))
}
