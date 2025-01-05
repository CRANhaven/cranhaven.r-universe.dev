print.summary.MMLong <-
function(x,...) {
  cat('\nClass:\n',x$class,'\n',sep='')
  cat("\nCall:\n", paste(x$call, sep = "\n", collapse = "\n"),"\n", sep = "")
  cat('\nInformation Criterion:\n')
  print.default(format(x$info, ...), print.gap = 2L, quote = FALSE)
  cat("\nMarginal Mean Parameters:\n")
  printCoefmat(x$mean.table,signif.stars = FALSE)
  cat('\n')
  cat("Dependence Model Parameters:\n")
  printCoefmat(x$assoc.table,signif.stars = FALSE)
  cat('\n')
  cat('Number of clusters:            ',x$control["n_subj"],'\n')
  cat('Maximum cluster size:          ',x$control["max_n_visit"],'\n')
  cat('Convergence status (nlm code): ',x$control["convergence_code"],'\n')
  cat('Number of iterations:          ',x$control["n_iter"])
  cat('\n')
}



