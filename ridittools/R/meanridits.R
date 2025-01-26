meanridits <-
function(x, margin, ref=NULL) {
  apply(x, margin, meanridit, riditsrefgroup(x,margin,ref))
}
