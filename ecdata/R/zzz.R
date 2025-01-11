

.onLoad = function(libname,pkgname){



  ## this is a direct rip of the nflreadr cachemethod found 
  ## here https://github.com/nflverse/nflreadr/blob/main/R/zzz.R

 memoise_option = getOption('ecdata.cache', default = "memory")
  
  if(!memoise_option %in% c('memory', 'filesystem', 'off'))  memoise_option <- 'memory'


  if (is.null(getOption("ecdata.cache"))) {
    options("ecdata.cache" = "memory")
  }

  if(memoise_option == "filesystem"){
    
    cache_dir = tools::R_user_dir(package = "ecdata", which = 'cache')

    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
    
    cache = cachem::cache_disk(dir = cache_dir)
  }

  if(memoise_option == "memory") cache <- cachem::cache_mem()

 if(memoise_option != 'off'){
   
  assign(x = "load_ecd",
           value = memoise::memoise(load_ecd, ~ memoise::timeout(86400), cache = cache),
           envir = rlang::ns_env("ecdata"))
   assign(x = "lazy_load_ecd",
          value = memoise::memoise(lazy_load_ecd, ~ memoise::timeout(86400), cache = cache),
        envir = rlang::ns_env("ecdata"))
   
 }

 if(is.null(getOption("ecdata.verbose")) && isFALSE(getOption("ecdata.cache_warning"))) {
  options("ecdata.verbose" = TRUE)
  
}
  }


.onAttach = function(libname, pkgname) {

  memoise_option = getOption("ecdata.cache", default = "memory")

  if (!memoise_option %in% c("memory", "filesystem", "off")) {
    packageStartupMessage(
      'Note: ecdata.cache is set to "',
      memoise_option,
      '" and should be one of c("memory", "filesystem", "off"). \n',
      'Defaulting to "memory".'
    )
    options("ecdata.cache" = "memory")
  }

  if (memoise_option == "off") {
    packageStartupMessage('Note: ecdata.cache is set to "off"')
  }
}
