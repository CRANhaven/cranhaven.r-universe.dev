checksite <- function (site,printsum=FALSE) 
{
    if (printsum) print(summary(site))
    if (any(is.na(site))) {
        cat("\n")
        for (i in 1:ncol(site)) {
            if (any(is.na(site[,i]))) {
                nas <- which(is.na(site[,i]))
                for (j in nas) {
                    cat(paste("Variable",names(site)[i],
                    "has missing values in plots(s)",
                    row.names(site)[j],"\n"))
                }
            }
        }
    } else {
        cat("\nThere are no missing values\n")
    }
    attr(site,'class') <- c('data.frame','site')
    invisible(site)
}

