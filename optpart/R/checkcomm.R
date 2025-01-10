checkcomm <- function (data,maxvals=15) 
{
    test <- table(as.matrix(data))
    if (length(test) <= maxvals) {
        cat("The data appear to be categorical\n")
        print(test)
    } else {
        cat("The data appear to be numeric\n")
        print(summary(as.numeric(as.matrix(data))))
    }
    if (any(is.na(data))) {
        cat("\n")
        for (i in 1:ncol(data)) {
            if(any(is.na(data[,i]))) {
                nas <- which(is.na(data[,i]))
                for (j in nas) {
                    cat(paste("Species",names(data)[i],
                    "has missing values in plots(s)",
                    row.names(data)[j],"\n"))
                }
            }
        }
    } else {
       cat("\nThere are no missing values\n")
    }

    attr(data,'class') <- c("data.frame","comm")
    invisible(data)
}

