print.MMLong <-
function(x, ...) {
  cat('\nClass:\n',class(x),'\n',sep='')
  cat('\nCall:\n', paste(deparse(x$call), sep = '\n', collapse = '\n'),'\n', sep = '')
  cat('\nInformation Criterion:\n')
  print.default(format(x$info_stats, ...), print.gap = 2L, quote = FALSE)
  cat("\nMarginal Mean Parameters:\n")
  print.default(format(x$beta, ...), print.gap = 2L, quote = FALSE)
  cat('\n')
  cat("Association Parameters:\n")
  print.default(format(x$alpha,...), print.gap = 2L, quote = FALSE)
  cat('\n')
  cat('Convergence status (nlm code): ',x$control[2],'\n')
  cat('Number of iterations:          ',x$control[3])
  cat('\n')
}
