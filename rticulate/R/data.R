#' Tongue contours dataset.
#'
#' A dataset containing tongue contour coordinates of a single speaker.
#'
#' @format A data frame with 3612 rows and 28 variables.
#' \describe{
#'     \item{speaker}{speaker ID}
#'     \item{seconds}{time of coordinate, in seconds}
#'     \item{rec_date}{date and time of recording}
#'     \item{prompt}{prompt string}
#'     \item{label}{label of annotation}
#'     \item{TT_displacement}{smoothed displacement of tongue tip}
#'     \item{TT_velocity}{velocity of tongue tip displacement}
#'     \item{TT_abs_velocity}{absolute velocity of tongue tip displacement}
#'     \item{TD_displacement}{smoothed displacement of tongue dorsum}
#'     \item{TD_velocity}{velocity of tongue dorsum displacement}
#'     \item{TD_abs_velocity}{absolute velocity of tongue dorsum displacement}
#'     \item{TR_displacement}{smoothed displacement of tongue root}
#'     \item{TR_velocity}{velocity of tongue root displacement}
#'     \item{TR_abs_velocity}{absolute velocity of tongue root displacement}
#'     \item{fan_line}{fan line number}
#'     \item{X}{horizontal coordinate at time \code{seconds}}
#'     \item{Y}{vertical coordinate at time \code{seconds}}
#'     \item{word}{words of the form CVCV}
#'     \item{item}{item ID}
#'     \item{ipa}{IPA transcription of the words}
#'     \item{c1}{first consonant}
#'     \item{c1_phonation}{phonation of the first consonant, \code{voiceless}}
#'     \item{vowel}{first and second vowel}
#'     \item{anteropost}{backness of the vowel, \code{back} or \code{central}}
#'     \item{height}{height of the vowel, \code{high}, \code{mid} or \code{low}}
#'     \item{c2}{second consonant}
#'     \item{c2_phonation}{phonation of the second consonant, \code{voiceless} or \code{voiced}}
#'     \item{c2_place}{place of the second consonant, \code{coronal} or \code{velar}}
#' }
"tongue"

#' Palate profile dataset.
#'
#' A dataset containing the palate profile of a single speaker.
#'
#' @format A data frame with 42 rows and 14 variables.
#' \describe{
#'     \item{speaker}{speaker ID}
#'     \item{seconds}{time of coordinate, in seconds}
#'     \item{rec_date}{date and time of recording}
#'     \item{prompt}{prompt string}
#'     \item{label}{label of annotation}
#'     \item{TT_displacement}{smoothed displacement of tongue tip}
#'     \item{TT_velocity}{velocity of tongue tip displacement}
#'     \item{TT_abs_velocity}{absolute velocity of tongue tip displacement}
#'     \item{TD_displacement}{smoothed displacement of tongue dorsum}
#'     \item{TD_velocity}{velocity of tongue dorsum displacement}
#'     \item{TD_abs_velocity}{absolute velocity of tongue dorsum displacement}
#'     \item{fan_line}{fan line number}
#'     \item{X}{horizontal coordinate at time \code{seconds}}
#'     \item{Y}{vertical coordinate at time \code{seconds}}
#' }
"palate"

#' Stimuli dataset.
#'
#' A dataset with linguistic information on the stimuli.
#'
#' @format A data frame with 12 rows and 11 variables.
#' \describe{
#'     \item{item}{item ID}
#'     \item{word}{words of the form CVCV}
#'     \item{ipa}{IPA transcription of the words}
#'     \item{c1}{first consonant}
#'     \item{c1_phonation}{phonation of the first consonant, \code{voiceless}}
#'     \item{vowel}{first and second vowel}
#'     \item{anteropost}{backness of the vowel, \code{back} or \code{central}}
#'     \item{height}{height of the vowel, \code{high}, \code{mid} or \code{low}}
#'     \item{c2}{second consonant}
#'     \item{c2_phonation}{phonation of the second consonant, \code{voiceless} or \code{voiced}}
#'     \item{c2_place}{place of the second consonant, \code{coronal} or \code{velar}}
#' }
"stimuli"
