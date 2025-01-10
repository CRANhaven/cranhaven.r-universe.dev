flexbeta <- function (dis,beta=-0.25,alpha=(1-beta)/2,gamma=0) 
{
    if (!inherits(dis,'dist')) stop("You must pass an argument of type 'dist'")

    dendro <- as.hclust(agnes(dis,method='flex',
               par.method=c(alpha,alpha,beta,gamma)))
    dendro
}

