# Function returns all diagonals of a matrix
diags = function(m)
{
  nCol = ncol(m)
  nRow = nrow(m)
  newNRow = nRow + nCol - 1
  result = array(NA, c(newNRow, nCol))
  for(j in 1:nCol) {
    result[(nCol+1-j):(nCol-j+nRow), j] = m[,j]
  }
  return(result)
}
