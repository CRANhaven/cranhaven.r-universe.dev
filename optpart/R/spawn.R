spawn <- function (name,comm,site,clust) 
{
    nas <- is.na(clust)
    
    commname <- deparse(substitute(comm))
    sitename <- deparse(substitute(site))

    eval(parse(text=paste(commname,"<- dropspc(comm[-nas,])")))
    eval(parse(text=paste(sitename,"<- site[-nas,]")))

    string <- paste("save(file='",name,".Rda',",commname,',',sitename,sep='')

    frame <- ls(parent.frame())
    for (i in frame) {
        tmp <- eval(parse(text=i))
        distname <- deparse(substitute(i))
        if (inherits(tmp,'dist')) {
            eval(parse(text=paste(distname,"<- dropnadist(clust,tmp)")))
            string <-paste(string,i,sep=',')
        }
    }
    string <- paste(string,')',sep='')

    eval(parse(text=string)) 
}

