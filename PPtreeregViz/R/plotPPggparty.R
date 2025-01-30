#' projection pursuit regression tree plot with independent variable
#'
#' Draw projection pursuit regression tree with independent variable. It is modified
#' from a function in \code{partykit} library.
#' @title PPTreereg plot with independent variable
#' @usage pp_ggparty(PPTreeregOBJ,ind_variable,final.rule=5,Rule=1, ...)
#' @param PPTreeregOBJ PPTreereg class object
#' @param ind_variable independent variable to show
#' @param final.rule final rule to assign numerical values in the final nodes.
#'             1: mean value in the final nodes
#'             2: median value in the final nodes
#'             3: using optimal projection
#'             4: using all independent variables
#'             5: using several significant independent variables
#'
#' @param Rule split rule
#'             1: mean of two group means
#'             2: weighted mean of two group means - weight with group size
#'             3: weighted mean of two group means - weight with group sd
#'             4: weighted mean of two group means - weight with group se
#'             5: mean of two group medians
#'             6: weighted mean of two group medians - weight with group size
#'             7: weighted mean of two group median - weight with group IQR
#'             8: weighted mean of two group median - weight with group IQR
#'                                                    and group size
#' @param ... arguments to be passed to methods
#' @export
#' @keywords tree
#' @return An object of the class \code{ggplot}
#'
#' @examples
#' data(dataXY)
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' pp_ggparty(Model, "X1", final.rule=5)
#'

pp_ggparty <- function(PPTreeregOBJ,ind_variable,final.rule=5, Rule=1, ...){

  as_party <- function(PPTreeregOBJ, finalRule = final.rule , ...){
    ff <- data.frame(PPTreeregOBJ$Tree.result$Tree.Struct)
    ff <- ff[c(1,3,2,5,4,7,6),]

    n <- nrow(ff)
    if (n == 1)
      return(partykit::partynode(as.integer(1)))
    is.leaf <- (ff$Index == 0)
    ncomplete<-rep(2,n)
    ncomplete[is.leaf]<-0
    index<-cumsum(c(1,ncomplete+1*(!is.leaf)))
    primary<-numeric(n)
    primary[!is.leaf]<-index[c(!is.leaf,FALSE)]
    mf<-PPTreeregOBJ$Tree.result$origdata%*%t(PPTreeregOBJ$Tree.result$projbest.node)
    rownames(mf)<-rownames(PPTreeregOBJ$Tree.result$origdata)
    colnames(mf)<-paste("proj",1:ncol(mf),sep="")
    mf<-data.frame(mf)

    mf$origclass <- PPTreeregOBJ$Tree.result$origclass
    mf$predict <- predict.PPTreereg(PPTreeregOBJ, final.rule = final.rule)
    mf<-cbind(mf,PPTreeregOBJ$Tree.result$origdata)
    mf<-data.frame(mf)


    PPtreereg_fitted <- function() {
      ret <- as.data.frame(matrix(nrow = NROW(mf), ncol = 0))
      ret[["(fitted)"]] <- apply(matrix(as.numeric(predict.PPTreereg(PPTreeregOBJ, final.rule = final.rule, classinfo = TRUE)$Yhat.class,ncol=1)),1,
                                 function(x) which((data.frame(ff)$R.node.ID==x)*is.leaf==1))

      ret[["(response)"]] <- PPTreeregOBJ$origclass
      ret
    }

    fitted <- PPtreereg_fitted()
    PPtreereg_kids <- function(i) {
      if (is.leaf[i])
        return(NULL)
      else
        return(c(ff[i,c(3,2)]))
    }

    PPtreereg_split <- function(j) {
      if (j < 1)
        return(NULL)
      idj <- as.integer(ff$Coef.ID[j])
      ret <- partykit::partysplit(varid = idj,
                                  breaks = round(as.double(PPTreeregOBJ$Tree.result$splitCutoff.node[idj, Rule]),4),
                                  right = FALSE,
                                  #index = 2L:1L
                                  index = 1L:2L)
      ret
    }


    PPtreereg_node <- function(i) {
      if (is.null(PPtreereg_kids(i)))
        return(partykit::partynode(as.integer(i)))
      nd <- partykit::partynode(as.integer(i), split = PPtreereg_split(i),
                                kids = lapply(PPtreereg_kids(i),PPtreereg_node))
      left <- partykit::nodeids(partykit::kids_node(nd)[[1L]], terminal = TRUE)
      right <- partykit::nodeids(partykit::kids_node(nd)[[2L]], terminal = TRUE)
      nd$split$prob <- c(0, 0)
      nl <- sum(fitted[["(fitted)"]] %in% left)
      nr <- sum(fitted[["(fitted)"]] %in% right)
      if(nl > nr) {
        nd$split$prob <- c(1, 0)
      } else {
        nd$split$prob <- c(0, 1)
      }
      nd$split$prob <- as.double(nd$split$prob)
      return(nd)
    }
    node <- PPtreereg_node(1)
    rval <- partykit::party(node = node,
                            data = mf,
                            fitted = fitted,
                            terms = PPTreeregOBJ$terms,
                            info = list(method = "PPTreereg"))
    class(rval) <- c(class(rval),"constparty")
    return(rval)
  }

  origclass = id = nodesize = fianl.rule = predict = 1
  partyOBJ <- as_party(PPTreeregOBJ, finalRule = fianl.rule)
  p <- ggparty::ggparty(partyOBJ, terminal_space = 0.75 )+
    ggparty::geom_edge() +
    ggparty::geom_node_splitvar()  +
    # plot first row
    ggparty::geom_node_plot(gglist = list(ggplot2::geom_point(ggplot2::aes(x = eval(parse(text = ind_variable)),
                                                                           y = predict,
                                                                           col = origclass),
                                                              alpha = 0.4),
                                          ggplot2::xlab(" "),
                                          ggplot2::ylab("                                          predict"),
                                          ggplot2::theme_bw()),
                            height = 0.45,
                            nudge_x = -0.02,
                            shared_axis_labels = TRUE)+
    # plot second row
    ggparty::geom_node_plot(gglist = list(ggplot2::geom_point(ggplot2::aes(x = eval(parse(text = ind_variable)),
                                                                           y = origclass,
                                                                           col = origclass),
                                                              alpha = 0.4),

                                          ggplot2::xlab(ind_variable),
                                          ggplot2::ylab("             origclass"),
                                          ggplot2::theme_bw()),
                            height = 0.45,
                            shared_axis_labels = TRUE,
                            nudge_y = -0.32,
                            legend_separator = TRUE)+

    ggparty::geom_node_label(
      ggplot2::aes(label = paste0("Node ", id, ", N = ", nodesize)),
      ids = "terminal",
      size = 3,
      nudge_y = 0.02
    )

  p
}
