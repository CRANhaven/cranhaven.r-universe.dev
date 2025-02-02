deparse2 <- function(x)
    paste(deparse(x, width.cutoff = 500L,
                  backtick = !is.symbol(x) && is.language(x)),
          collapse = " ")

# This is a copy-paste of the model.matrix.default() function from the stats package
# It is modified to return the data before going to the contrasts to transform complex variables
cmodel.matrix <- function (object, data = environment(object), contrasts.arg = NULL,
                           xlev = NULL, ...)
{
    t <- if (missing(data))
        terms(object)
    else terms(object, data = data)
    if (is.null(attr(data, "terms")))
        data <- model.frame(object, data, xlev = xlev)
    else {
        reorder <- match(vapply(attr(t, "variables"), deparse2,
                                "")[-1L], names(data))
        if (anyNA(reorder))
            stop("model frame and formula mismatch in model.matrix()")
        if (!identical(reorder, seq_len(ncol(data))))
            data <- data[, reorder, drop = FALSE]
    }
    int <- attr(t, "response")
    if (length(data)) {
        contr.funs <- as.character(getOption("contrasts"))
        namD <- names(data)
        for (i in namD) if (is.character(data[[i]]))
            data[[i]] <- factor(data[[i]])
        isF <- vapply(data, function(x) is.factor(x) || is.logical(x),
                      NA)
        isF[int] <- FALSE
        isOF <- vapply(data, is.ordered, NA)
        for (nn in namD[isF]) if (is.null(attr(data[[nn]], "contrasts")))
            contrasts(data[[nn]]) <- contr.funs[1 + isOF[nn]]
        if (!is.null(contrasts.arg)) {
            if (!is.list(contrasts.arg))
                warning("non-list contrasts argument ignored")
            else {
                if (is.null(namC <- names(contrasts.arg)))
                    stop("'contrasts.arg' argument must be named")
                for (nn in namC) {
                    if (is.na(ni <- match(nn, namD)))
                        warning(gettextf("variable '%s' is absent, its contrast will be ignored",
                                         nn), domain = NA)
                    else {
                        ca <- contrasts.arg[[nn]]
                        if (is.matrix(ca))
                            contrasts(data[[ni]], ncol(ca)) <- ca
                        else contrasts(data[[ni]]) <- ca
                    }
                }
            }
        }
    }
    else {
        isF <- FALSE
        data[["x"]] <- raw(nrow(data))
    }
    return(data)
}
