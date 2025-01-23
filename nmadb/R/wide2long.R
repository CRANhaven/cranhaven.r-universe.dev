wide2long = function (data,type="binary") {
  js <- V8::v8(typed_arrays = TRUE)
  #js$source(file=system.file("js/underscore-min.js", package="V8"))
  #js$source(file="js/combinations.js")
  tryCatch({
    js$source("https://raw.githubusercontent.com/esm-ispm-unibe-ch/dataformatter/master/js/underscore-min.js")
    js$source("https://raw.githubusercontent.com/esm-ispm-unibe-ch/dataformatter/master/js/wide2Long.js")
  }, error = function(cond){
    message(cond)
  })
  result = js$call("wideToLong",data,type)
  return (result)
}


