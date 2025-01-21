#' @title save_dyn_files
#'
#' @description
#' This function allows the user to save dynamic forest data to CSV files. It prompts the user
#' to select a directory via a graphical interface (using the `tcltk` package), and then saves
#' several data frames containing forest dynamics information to predefined file names in that directory.
#'
#' @param dynamics A list containing four data frames with different forest dynamics data:
#'                 1) number of plots (`n_plot`),
#'                 2) number of species (`n_species`),
#'                 3) basal area by species (`basal_area_species`),
#'                 4) basal area by plots (`basal_area_plot`).
#' @param verbose Logical. If `TRUE`, the function will print messages indicating the status of the saving process.
#'                Default is `TRUE`.
#'
#' @return NULL If the user does not select a folder, the function will return NULL and no files will be saved.
#'              Otherwise, the function saves four CSV files and returns a confirmation message.
#'
#' @export
#'
#' @importFrom tcltk tk_choose.dir
#' @importFrom utils write.csv2

save_dyn_files <- function(dynamics, verbose = TRUE) {
  folder_path <- tcltk::tk_choose.dir(default = "", caption = "Select the folder to save the files")

  if (is.na(folder_path) || folder_path == "") {
    message("No folder selected. The files will not be saved.")
    return(NULL)
  }

  file_paths <- c(
    paste0(folder_path, "/dynamics_n_parcelas.csv"),
    paste0(folder_path, "/dynamics_n_especies.csv"),
    paste0(folder_path, "/dynamics_ab_especies.csv"),
    paste0(folder_path, "/dynamics_ab_parcelas.csv")
  )

  write.csv2(dynamics[[1]], file = file_paths[1], row.names = TRUE)
  write.csv2(dynamics[[2]], file = file_paths[2], row.names = TRUE)
  write.csv2(dynamics[[4]], file = file_paths[3], row.names = TRUE)
  write.csv2(dynamics[[3]], file = file_paths[4], row.names = TRUE)

  if (verbose) {
    message("Files have been saved to:")
    message(paste(file_paths, collapse = "\n"))
  }
}


