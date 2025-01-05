print.anova.MMLong <-
function(x, ...) {
  cat('\nClass:\n',class(x),'\n',sep='')
  cat("\nModels:\n",
      paste(paste(c('Model 1','Model 2'),x$models,sep=': '), sep = "\n",
            collapse = "\n"),"\n", sep = "")
  printCoefmat(x$atable,signif.stars = FALSE,na.print='',P.values=TRUE, has.Pvalue=TRUE)
  cat('\n')
}
