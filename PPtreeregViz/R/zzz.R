.onLoad <- function(libname = find.package("PPtreeregViz"), pkgname = "PPtreeregViz") {

  # CRAN Note avoidance
  utils::globalVariables(
    c(
      ".", ".N", ".I", ".GRP", ".SD"
    )
  )
  invisible()
}
