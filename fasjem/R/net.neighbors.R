net.neighbors <-
function(theta,index)
{
	#index = (row.names(theta[[1]])==name)
	K = length(theta)
	p = dim(theta[[1]])[1]
	neighbors = list()
	for(k in 1:K)
	{
	  neighbors[[k]] = which(theta[[k]][index,]!=0)
	}
	return(neighbors)
}

