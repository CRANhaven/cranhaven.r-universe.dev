##
if(!file.exists("../windows/libidn/include/idna.h")){
  unlink("../windows", recursive = TRUE)
  url <- if(grepl("aarch", R.version$platform)){
    "https://github.com/r-windows/bundles/releases/download/libidn-1.42/libidn-1.42-clang-aarch64.tar.xz"
  } else if(grepl("clang", Sys.getenv('R_COMPILED_BY'))){
    "https://github.com/r-windows/bundles/releases/download/libidn-1.42/libidn-1.42-clang-x86_64.tar.xz"
  } else {
    "https://github.com/r-windows/bundles/releases/download/libidn-1.42/libidn-1.42-ucrt-x86_64.tar.xz"
  }
  download.file(url, basename(url), quiet = TRUE)
  dir.create("../windows", showWarnings = FALSE)
  untar(basename(url), exdir = "../windows", tar = 'internal')
  unlink(basename(url))
  setwd("../windows")
  file.rename(list.files(), 'libidn')
}
