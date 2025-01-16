


indexes = function(data.x,data.y,
 type='fixed-base'){
 data.x2 = as.matrix(data.x)
 data.y2 = as.matrix(data.y)
 
 if(!(type %in% c('fixed-base','chained'))){
  stop("'type' argument should be either 'chained' or 'fixed-base'")
 } 
 
 #require(matrixStats)
 
 nShares = ncol(data.x2)
 matShares = matrix(0,ncol=nShares,nrow=nrow(data.x2))
 for(j in 1:ncol(matShares)){
   for(i in 1:nrow(matShares)){
    matShares[i,j] = (data.x2[i,j] %*% data.y2[i,j]) /
	 (data.x2[i,] %*% data.y2[i,])
	}
  }
 
 laspeyres = vector('list')
 paasche = vector('list')
 tornqvist = matrix(0,nrow=nrow(data.x2),ncol=ncol(data.x2))
 torn= vector('list')
 
  
  for(i in 1:nrow(data.x2)){
    laspeyres[[i]] = (data.x2[i,]%*%data.y2[1,])/(t(data.x2[1,])%*%data.y2[1,])   
    paasche[[i]] = (data.x2[i,]%*%data.y2[i,])/(t(data.x2[1,])%*%data.y2[i,])
  }
  
   for(j in 1:ncol(matShares)){
     for(i in 1:nrow(matShares)){
      tornqvist[i,j] = (data.x2[i,j]/data.x2[1,j])^
	   (0.5*(matShares[1,j]+matShares[i,j]))
    }
   }
 out=data.frame(laspeyres=unlist(laspeyres),
                paasche = unlist(paasche))
 out$fisher = sqrt(out$laspeyres * out$paasche)
 out$tornqvist =apply(tornqvist,1,function(x) prod(x,na.rm=T))
 out$spreadPL = abs(log(out$laspeyres/out$paasche))
 
 if(type=='chained'){out=chaining(data.x2,data.y2)}
 
 out.list = list(indexes=out,shares=matShares)
 return(out.list)
}



multicomp = function(data.x,data.y,
  idx='fisher',transitivity='mst',
  var.agg,bench,period,
  plotting=FALSE){
 
  
	
	indxVars = var.agg	
	selVars = which(!(names(data.x) %in% indxVars))
    labVars = which(names(data.x) %in% indxVars)
	
	if(!is.null(period)){
	 rownames(data.x) = paste(data.x[,indxVars[2]],
	  data.x[,indxVars[1]],sep='.')
	 rownames(data.y) = paste(data.y[,indxVars[2]],
	  data.y[,indxVars[1]],sep='.')
	}else{
	 rownames(data.x) = data.x[,var.agg]
	 rownames(data.y) = data.y[,var.agg]
	}
	
	I = diag(nrow(data.x))
	n = nrow(I)
	
	if(transitivity != 'mst'){
  #   print(paste('total iterations:',n))

    for(i in 1:n){
	 if(idx %in% c('fisher','tornqvist')){
        I[i:n,i] = indexes(data.x[i:n,selVars], # indexFunF implements Fisher only.
		 data.y[i:n,selVars])$indexes[,idx]
        
	        I[i,i:n] = 1./I[i:n,i] # factor reversal property
	#		print(paste('iteration:',i))
        }else{
	       # for those indexes which do not satisfy 
		   # the factor reversal property, we should
		   # develop a more complex algorithm
		   tempQuant = rbind(data.x[i,],data.x)
		   tempPrice = rbind(data.y[i,],data.y)
	       I[,i] = indexes(tempQuant[,selVars],
		             tempPrice[,selVars])$indexes[,idx][-1] 
		   #all.equal(I[-c(1:(i-1)),i],tempIndx[-c(1:i)])						   
		}
	}
	rownames(I)=rownames(data.x)
	colnames(I)=rownames(I)
   }
   
   
 if(transitivity == 'eks' & !(idx %in% c('laspeyres','paasche')) ){
    out = eks(I)
	if(!is.null(period)){benchmark = paste(bench,period,sep='.')}
	if(is.null(period)){benchmark=bench}
	out = out[,which(colnames(out)==benchmark)]
	out 
	
	return(out)
 }else if(transitivity == 'mst'){
   #require(ape)
   if(!idx %in% c('fisher','tornqvist')){
    warning('MST should be comuted using the Fisher or Tornqvist formula')
   }
  # print(paste('total iterations:',n))
   
      # data.x = price[1:7,1:7]
     # ord = sample(1:nrow(data.x),nrow(data.x),replace=FALSE) 
     # data.xr = data.x[ord,]
  
     # data.y = quant[1:7,1:7]
     # data.yr = data.y[ord,]
	
     # rownames(data.x) = paste(data.x[,indxVars[2]],
     # data.x[,indxVars[1]],sep='.')
     # rownames(data.y) = paste(data.y[,indxVars[2]],
      # data.y[,indxVars[1]],sep='.')
   
      # rownames(data.xr) = paste(data.xr[,indxVars[2]],
      # data.xr[,indxVars[1]],sep='.')
     # rownames(data.yr) = paste(data.yr[,indxVars[2]],
      # data.yr[,indxVars[1]],sep='.')
   
    # n = nrow(data.x)
  
   listCheck = list()
  
   for(i in 1:n){
   # print(paste('iteration:',i))
    tempQuant = rbind(data.x[i,],data.x)
    tempPrice = rbind(data.y[i,],data.y)
	 # listCheck[[i]] = list()
	 # listCheck[[i]][[1]] = tempQuant[,1:7]
	 # listCheck[[i]][[2]] = tempPrice[,1:7]
	
    I[,i] = indexes(tempQuant[,selVars],
             tempPrice[,selVars])$indexes[,'spreadPL'][-1] 
			 
	 # listCheck[[i]][[3]] = indexes(tempQuant[,selVars],
              # tempPrice[,selVars])$indexes 		 
		   # #all.equal(I[-c(1:(i-1)),i],tempIndx[-c(1:i)])
   }
   
   # I2 = matrix(0,nrow=nrow(data.xr),ncol=nrow(data.xr))
    # listCheck2 = list()
      # for(i in 1:n){
      # print(paste('iteration:',i))
	  # print(rownames(data.xr)[i])
      # tempQuant = rbind(data.xr[i,],data.xr)
      # tempPrice = rbind(data.yr[i,],data.yr)
	 # listCheck2[[i]] = list()
	 # listCheck2[[i]][[1]] = tempQuant[,1:7]
	  # listCheck2[[i]][[2]] = tempPrice[,1:7]
	
      # I2[,i] = indexes(tempQuant[,selVars],
               # tempPrice[,selVars])$indexes[,'spreadPL'][-1] 
			 
	 # listCheck2[[i]][[3]] = indexes(tempQuant[,selVars],
               # tempPrice[,selVars])$indexes 
		   # # # #all.equal(I[-c(1:(i-1)),i],tempIndx[-c(1:i)])
     # }
   
   #require(igraph)
   netwk = ape::mst(I)
   rownames(netwk) = rownames(data.x)
   colnames(netwk) = rownames(data.x)
   rownames(I) = rownames(data.x)
   colnames(I) = rownames(data.x)
   
     # netwk2 = ape::mst(I2)
     # rownames(netwk2) = rownames(data.xr)
     # colnames(netwk2) = rownames(data.xr)
     # rownames(I2) = rownames(data.xr)
     # colnames(I2) = rownames(data.xr)
   
    # par(mfrow=c(1,2))
    # plot(netwk)
    # plot(netwk2)
   
   
   ig = igraph::graph.adjacency(netwk)
  # ig1 = graph.adjacency(netwk2)
   mst0 = igraph::minimum.spanning.tree(ig)
  # mst1 = minimum.spanning.tree(ig1)   
   
   if(plotting==TRUE){
   igraph::tkplot(ig,vertex.size=10,
   #layout=layout.auto,
    vertex.color='gold2',
	vertex.label.font=2,
    edge.arrow.width=0.6,
	edge.arrow.size=0.6)
   }
   degrees = list()
   for(u in 1:length(igraph::V(ig)$name)){
    degrees[[u]] = igraph::degree(ig,igraph::V(ig)$name[u]) 
   }
   outerVerts = which(unlist(degrees)==2)
   
	
   if(!is.null(period)){bench=paste(bench,period,sep='.')}
   outerVerts = outerVerts[!(names(outerVerts) %in% bench)]
 

   paths = list()  
   for(w in 1:length(outerVerts)){
    startNode = which(as.character(igraph::V(ig)$name)== bench)
	endNode = which(as.character(igraph::V(ig)$name) == names(outerVerts)[w])
  #  print(paste('Starting node:',startNode))
	#print(paste('Ending node:',endNode))
    paths[[w]] = names(igraph::shortest_paths(ig,from=startNode,
	 to=endNode)$vpath[[1]])
   }
 
  # print(paste('total number of  paths:',length(paths))) 
   conns = list()
   for(j in 1:length(paths)){
  #   print(paste('path:',j))
    conns[[j]] = list()
	conns[[j]][[1]] = paths[[j]]
	conns[[j]][[2]] = matrix(0,nrow=length(paths[[j]]),
	 ncol=length(paths[[j]]))
	ghindx = 1
	

	for(gh in paths[[j]]){
	
     tempQuant = rbind(data.x[rownames(data.x) == gh,],data.x[match(paths[[j]],rownames(data.x)), ])
     tempPrice = rbind(data.y[rownames(data.y) ==gh,],data.y[match(paths[[j]],rownames(data.y)), ])
     conns[[j]][[2]][,ghindx] = indexes(tempQuant[,selVars],
              tempPrice[,selVars])$indexes[,idx][-1] 
		   #all.equal(I[-c(1:(i-1)),i],tempIndx[-c(1:i)])
	 ghindx= ghindx+1	   
    }
	ghindx=1
	
	 rownames(conns[[j]][[2]]) = paths[[j]]
	 colnames(conns[[j]][[2]]) = paths[[j]]
	
	
	matLinks = as.matrix(conns[[j]][[2]][,1])
	for(ab in 2:nrow(conns[[j]][[2]])){
	 matLinks[ab,1] = conns[[j]][[2]][ab,ab-1] * matLinks[ab-1,1]  
    } 
	conns[[j]][[3]]=matLinks	
   } 	
   
   res = conns[[1]][[3]]
   # ora devo collegare i diversi indici tra di loro
   if(length(paths)>1){
    for(g in 2:length(conns)){
     resTemp = conns[[g]][[3]]
     resTemp = as.matrix(resTemp[which(!(rownames(resTemp) %in% rownames(res))),1]) 
     res = rbind(res,resTemp)
    }
   }
   out=res
 #  out = res[order(as.numeric(rownames(res)),decreasing=FALSE),]
 #  names(out) = rownames(data.x)
   
   return(out)
 }else{
  
  warning('Returning non-transitive indexes, besides in degenerate cases')
  out = eks(I)
  rownames(out) = rownames(data.x)
  colnames(out) = rownames(data.x)
  if(!is.null(period)){benchmark = paste(bench,period,sep='.')}
  if(is.null(period)){benchmark=bench}
  out = out[,which(colnames(out)==benchmark)]
  out   
  return(out)
 
 }
} 



multicompPAR = function(data.x,data.y,
  idx='fisher', transitivity='mst',
  var.agg,bench,period,
  plotting=FALSE,
  Cores){
 
  #require(parallel)
	
	indxVars = var.agg	
	selVars = which(!(names(data.x) %in% indxVars))
    labVars = which(names(data.x) %in% indxVars)
	
	if(!is.null(period)){
	 rownames(data.x) = paste(data.x[,indxVars[2]],
	  data.x[,indxVars[1]],sep='.')
	 rownames(data.y) = paste(data.y[,indxVars[2]],
	  data.y[,indxVars[1]],sep='.')
	}else{
	 rownames(data.x) = data.x[,var.agg]
	 rownames(data.y) = data.y[,var.agg]
	}
	
	I = diag(nrow(data.x))
	n = nrow(I)
	
	if(transitivity != 'mst'){
    # print(paste('total iterations:',n))

    for(i in 1:n){
       if(idx %in% c('fisher','tornqvist')){ 
       I[i:n,i] = indexes(data.x[i:n,selVars], # indexFunF implements Fisher only.
		 data.y[i:n,selVars])$indexes[,idx]
    
	        I[i,i:n] = 1./I[i:n,i] # factor reversal property
	#		print(paste('iteration:',i))
        }else{
	       # for those indexes which do not satisfy 
		   # the factor reversal property, we should
		   # develop a more complex algorithm
		   tempQuant = rbind(data.x[i,],data.x)
		   tempPrice = rbind(data.y[i,],data.y)
	       I[,i] = indexes(tempQuant[,selVars],
		             tempPrice[,selVars])$indexes[,idx][-1] 
		}
	}
	rownames(I)=rownames(data.x)
	colnames(I)=rownames(I)
   }
   
   
 if(transitivity == 'eks' & !(idx %in% c('laspeyres','paasche')) ){
    out = eks(I)
	if(!is.null(period)){benchmark = paste(bench,period,sep='.')}
	if(is.null(period)){benchmark=bench}
	out = out[,which(colnames(out)==benchmark)]

	return(out)
 }else if(transitivity == 'mst'){
   #require(ape)
   if(!idx %in% c('fisher','tornqvist')){
    warning('MST should be computed using the Fisher or Tornqvist formula')
   }
#   print(paste('total iterations:',n))
	cl=parallel::makePSOCKcluster(Cores,outfile=NULL)
   parallel::clusterExport(cl=cl, varlist=c('data.x',
  'data.y','selVars','n','indexes','chaining'),
  envir=environment())
 
 
   
  # data.x = price[1:7,]
  # ord = sample(1:nrow(data.x),nrow(data.x),replace=FALSE) 
  # data.xr = data.x[ord,]
  
  # data.y = quant[1:7,]
    # data.yr = data.y[ord,]
	
  # rownames(data.x) = paste(data.x[,indxVars[2]],
   # data.x[,indxVars[1]],sep='.')
  # rownames(data.y) = paste(data.y[,indxVars[2]],
   # data.y[,indxVars[1]],sep='.')
   
   # rownames(data.xr) = paste(data.xr[,indxVars[2]],
   # data.xr[,indxVars[1]],sep='.')
  # rownames(data.yr) = paste(data.yr[,indxVars[2]],
   # data.yr[,indxVars[1]],sep='.')
   
  # n = nrow(data.x)
  
   I=parallel::parSapply(cl,1:n, function(i){
  #  print(paste('iteration:',i))
    tempQuant = rbind(data.x[i,],data.x)
    tempPrice = rbind(data.y[i,],data.y)
	
	
     indexes(tempQuant[,selVars],
             tempPrice[,selVars])$indexes[,'spreadPL'][-1] 
		 		   
   })
   
   # I2=parallel::parSapply(cl,1:n, function(i){
    # print(paste('iteration:',i))
    # tempQuant = rbind(data.xr[i,],data.xr)
    # tempPrice = rbind(data.yr[i,],data.yr)

	
     # indexes(tempQuant[,selVars],
             # tempPrice[,selVars])$indexes[,'spreadPL'][-1] 
		 		   
   # })
   
   set.seed(123)
   #require(igraph)
   netwk = ape::mst(I)
  # netwk0 = graph.adjacency(I,weighted=TRUE)
   #netwk0 = mst(netwk0)
   rownames(netwk) = rownames(data.x)
   colnames(netwk) = rownames(data.x)
   rownames(I) = rownames(data.x)
   colnames(I) = rownames(data.x)
   
   # la = I[order(I)]
   
   # netwk2 = ape::mst(I2)
   
   # netwk3 = graph.adjacency(I2,weighted=TRUE)
   # netwk3 = mst(netwk3)
   # rownames(netwk2) = rownames(data.xr)
   # colnames(netwk2) = rownames(data.xr)
   # rownames(I2) = rownames(data.xr)
   # colnames(I2) = rownames(data.xr)
   
   # lb = I2[order(I2)]
   
   # par(mfrow=c(2,2))
   # plot(netwk)
   # plot(netwk2)
   # plot(netwk0)
   # plot(netwk3)
     
   
   
   ig = igraph::graph.adjacency(netwk)
   if(plotting==TRUE){
   igraph::tkplot(ig,vertex.size=10,
   #layout=layout.auto,
    vertex.color='gold2',
	vertex.label.font=2,
    edge.arrow.width=0.6,
	edge.arrow.size=0.6)
   }
   degrees = list()
   for(u in 1:length(igraph::V(ig)$name)){
    degrees[[u]] = igraph::degree(ig,igraph::V(ig)$name[u]) 
   }
  outerVerts = which(unlist(degrees)==2)
   
 	
	
   if(!is.null(period)){bench=paste(bench,period,sep='.')}
   outerVerts = outerVerts[!(names(outerVerts) %in% bench)]
 

   paths = list()  
   for(w in 1:length(outerVerts)){
    startNode = which(as.character(igraph::V(ig)$name)== bench)
	endNode = which(as.character(igraph::V(ig)$name) == names(outerVerts)[w])
   # print(paste('Starting node:',startNode))
   # print(paste('Ending node:',endNode))
    paths[[w]] = names(igraph::shortest_paths(ig,from=startNode,
	 to=endNode)$vpath[[1]])
   }
 
#   print(paste('total number of  paths:',length(paths))) 
   conns = list()
   
    parallel::clusterExport(cl=cl, varlist=c('paths',
  'conns','idx'),
  envir=environment())
   
   conns = parallel::parLapply(cl,1:length(paths),function(j){
   #  print(paste('path:',j))
    conns[[j]] = list()
	conns[[j]][[1]] = paths[[j]]
	conns[[j]][[2]] = matrix(0,nrow=length(paths[[j]]),
	 ncol=length(paths[[j]]))
	ghindx = 1
	

	for(gh in paths[[j]]){
	
     tempQuant = rbind(data.x[rownames(data.x) == gh,],data.x[match(paths[[j]],rownames(data.x)), ])
     tempPrice = rbind(data.y[rownames(data.y) == gh,],data.y[match(paths[[j]],rownames(data.y)), ])
     conns[[j]][[2]][,ghindx] = indexes(tempQuant[,selVars],
              tempPrice[,selVars])$indexes[,idx][-1] 
		   #all.equal(I[-c(1:(i-1)),i],tempIndx[-c(1:i)])
	 ghindx= ghindx+1	   
    }
	ghindx=1
	
	 rownames(conns[[j]][[2]]) = paths[[j]]
	 colnames(conns[[j]][[2]]) = paths[[j]]
	
	
	matLinks = as.matrix(conns[[j]][[2]][,1])
	for(ab in 2:nrow(conns[[j]][[2]])){
	 matLinks[ab,1] = conns[[j]][[2]][ab,ab-1] * matLinks[ab-1,1]  
    } 
	conns[[j]][[3]]=matLinks
    matLinks	
   })	
   
   res = conns[[1]]
   # ora devo collegare i diversi indici tra di loro
   if(length(paths)>1){
    for(g in 2:length(conns)){
     resTemp = conns[[g]]
     resTemp = as.matrix(resTemp[which(!(rownames(resTemp) %in% rownames(res))),1]) 
     res = rbind(res,resTemp)
    }
   }
   #out = res[order(as.numeric(rownames(res)),decreasing=FALSE),]
   out=res
   parallel::stopCluster(cl) 
   #names(out) = rownames(data.x)
   return(out)
 }else{
  warning('Returning non-transitive indexes, besides in degenerate cases')
  out = eks(I)
  rownames(out) = rownames(data.x)
  colnames(out) = rownames(data.x)
  if(!is.null(period)){benchmark = paste(bench,period,sep='.')}
  if(is.null(period)){benchmark=bench}
  out = out[,which(colnames(out)==benchmark)]
  out   
  return(out)
 
 }
} 






growth = function(dataset,var.agg){
 varAggs = var.agg
 selVars = which(!(names(dataset) %in% varAggs))
 selVars0 = which(names(dataset) %in% varAggs)
 
 livelli = levels(as.factor(dataset[[var.agg[2]]]))
 res = dataset[1,]
 res = res[-1,]
 for(i in 1:length(livelli)){
  subN = subset(dataset,dataset[[var.agg[2]]]==livelli[i])  
  subRowsT = 2:nrow(subN)
  subRows0 = 1:(nrow(subN)-1)
  subIndx = (subN[subRowsT,selVars]-subN[subRows0,selVars])/
   subN[subRows0,selVars]
  subIndxC = cbind(subN[subRowsT,selVars0],subIndx) 
  res = rbind(res,subIndxC)
 }
  res[[var.agg[2]]] = as.numeric(as.character(res[[var.agg[2]]]))
 
 return(res)
}


eks = function(mat){
 Idx = mat 
 for(i in 1:nrow(mat)){
    for(j in 1:ncol(mat)){ # for each element in the matrix
	 idx = vector('list',length=length(nrow(mat))) # create a list of results to be later multiplied together
	  for(k in 1:nrow(mat)){
	    idx[[k]] =  (mat[i,k]*mat[k,j])^(1/nrow(mat)) # the list of results is the the product of 
	  }												  # geometric means of all the elements														
    Idx[i,j] = prod(unlist(idx))
    }
  }
  return(Idx)
}


multilateral = function(
  data.x,
  data.y,
  idx='fisher',
  transitivity='mst',
  var.agg,
  bench,
  period,
  PAR=TRUE,
  plotting=FALSE,
  Cores){
  
  
 if(!(idx %in% c('paasche','laspeyres','fisher','tornqvist'))){
  stop("'idx' argument should be either 'paasche','laspeyres','fisher' or 'tornqvist'")
 } 
 
 if(!(transitivity %in% c('eks','mst'))){
  stop("'transitivity' argument should be either 'eks' or 'mst'")
 }  
 
 if(!all(var.agg %in% names(data.x))){
  stop("'var.agg' arguments should be among data columns names")
 }  
 
  
  if(PAR==TRUE){
  
   out =  multicompPAR(data.x,data.y,
    idx=idx, transitivity=transitivity,
    var.agg=var.agg,
    bench=bench,period=period,
    plotting=plotting,
	Cores=Cores)  
  
  }else{
  
    out =  multicomp(data.x,data.y,
     idx=idx, transitivity=transitivity,
     var.agg=var.agg,
     bench=bench,period=period,
     plotting=plotting)  
  
  }
  if(transitivity=='mst' & length(var.agg)==2){
  name = paste(data.x[,var.agg[2]],data.x[,var.agg[1]],sep='.')
  out = out[match(name,rownames(out)),]
  }else if(transitivity=='mst' & length(var.agg)==1){
  name = data.x[,var.agg]
  out = out[match(name,rownames(out)),]
  }
  return(out)
 
}



chaining = function(data.x,data.y){
  listIndex = list()
  listIndex[[1]]=cbind(1,1,1)
  colnames(listIndex[[1]]) = c('laspeyres','paasche','tornqvist')
  data.x = as.matrix(data.x)
  data.y = as.matrix(data.y)
  for(i in 1:(nrow(data.x)-1)){
   listIndex[[i+1]] = indexes(data.x[i:(i+1),],
                                  data.y[i:(i+1),])$indexes[2,c('laspeyres','paasche','tornqvist')]								  
  }
  out = do.call('rbind',listIndex)
  out = as.data.frame(apply(out,2,function(x) cumprod(x)))
  out$fisher = sqrt(out$laspeyres * out$paasche)
  out$spreadPL = abs(log(out$laspeyres/out$paasche))
  out = out[,c('laspeyres','paasche','fisher','tornqvist','spreadPL')]
  return(out)
}  


