riditsrefgroup <-
function(x, margin, ref=NULL) {
  if (length(ref) > 1) {
    refgroup <- ref
  } else if (length(ref) == 1) {
    if (margin==1) {
      refgroup <- x[ref,]
    } else {
      refgroup <- x[, ref]
    }
  } else {
    refgroup <- apply(x, 3-margin, sum)
  }
}
