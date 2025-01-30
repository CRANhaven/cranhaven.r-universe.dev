#' decision plot for \code{PPKernelSHAP}
#'
#' Decision plots are mainly used to explain individual predictions that how the model makes decision,
#' by focusing more on how model’s  predictions reach to their expected y value with \code{PPKernelSHAP} values.
#'
#' @title Decision plot
#' @param PPTreeregOBJ PPTreereg class object - a model to be explained
#' @param testObs test data observation
#' @param final.rule final rule to assign numerical values in the final nodes.
#'             1: mean value in the final nodes
#'             2: median value in the final nodes
#'             3: using optimal projection
#'             4: using all independent variables
#'             5: using several significant independent variables
#' @param method simple or empirical method to calculate \code{PPKernelSHAP}
#' @param varImp \code{shapImp} or \code{treeImp} - Sorted by descending order of variance or the variable importance from coefficient values of the nodes inside
#' the \code{PPTreereg}.
#' @param final.leaf location of final leaf
#' @param Yrange show the entire final prediction range of the dependent variable. Default value is FALSE.
#' @export
#' @return An object of the class \code{ggplot}
#' @examples
#' data(dataXY)
#' testX <- dataXY[1,-1]
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' decisionplot(Model, testX, final.rule =5, method="simple")
#'
decisionplot <- function(PPTreeregOBJ, testObs, final.rule = 5, method="simple",varImp = "shapImp",final.leaf = NULL, Yrange = FALSE){

  icols <- V1 <- finalLeaf <- shapsums <- none <- value <- id <- yhat <- impOrderings <- impOrdering <- variable <- NULL
  if(method=="simple"){
    if(nrow(testObs)==1){
      ppSHAP <- ppshapr.simple(PPTreeregOBJ, testObs, final.rule = final.rule, final.leaf = final.leaf)$dt %>% dplyr::as_tibble()
    }else if(nrow(testObs)>1){
      ppSHAP <- c()
      testNum = nrow(testObs)
      for(p in 1:testNum){
        ppSHAP[[p]] <-  ppshapr.simple(PPTreeregOBJ, testObs[p,], final.rule = final.rule, final.leaf = final.leaf)$dt
        ppSHAP[[p]][,':='(id,p)]
      }
      ppSHAP <- data.table::rbindlist(ppSHAP)
    }else{
      print("nrow(testObs) < 1")
    }
  }else{
    if(nrow(testObs)==1){
      ppSHAP <- ppshapr.empirical(PPTreeregOBJ, testObs, final.rule = final.rule, final.leaf = final.leaf)$dt %>% dplyr::as_tibble()
    }else if(nrow(testObs)>1){
      ppSHAP <- c()
      testNum = nrow(testObs)
      for(p in 1:testNum){
        ppSHAP[[p]] <-  ppshapr.empirical(PPTreeregOBJ,testObs[p,], final.rule = final.rule, final.leaf = final.leaf)$dt
        ppSHAP[[p]][,':='(id,p)]
      }
      ppSHAP <- data.table::rbindlist(ppSHAP)
    }else{
      print("nrow(testObs) < 1")
    }
  }


  if(varImp == "shapImp"){
    if(nrow(ppSHAP)==1){
      namesImp <- ppSHAP %>% dplyr::select(-none, -finalLeaf)
      shapImp_value <- namesImp %>% as.numeric()
      namesImp <- namesImp %>% colnames()
      impOrdering <-  c("none", namesImp[c(shapImp_value %>% abs() %>%  order(decreasing = FALSE))],"finalLeaf")
      ppSHAP_reorder <- ppSHAP[,impOrdering]
      ppSHAP_reorder$id <- 1
    }else{
      namesImp <- ppSHAP %>% dplyr::select(-none, -finalLeaf, -id)
      shapImp_value <- namesImp %>% dplyr::summarise_all(var) %>% as.numeric()
      namesImp <- namesImp %>% colnames()
      impOrderings <- c("none", namesImp[c(shapImp_value %>% abs()%>%  order(decreasing = FALSE))],"finalLeaf","id")
      ppSHAP_reorder <- ppSHAP[,impOrderings, with=FALSE]
    }
  }else{
    TreeImp <- PPimportance(PPTreeregOBJ)
    namesImp <- TreeImp$imp_var %>% names()
    impOrdering <- c("none",namesImp[c(TreeImp$imp_var %>% order(decreasing = FALSE))],"finalLeaf")
    ppSHAP_reorder <- ppSHAP[,impOrdering, with=FALSE]
  }

  ppSHAP_melt <- ppSHAP_reorder %>%
    dplyr::select(-finalLeaf) %>%
    reshape2::melt("id") %>% dplyr::arrange(id)%>%
    dplyr::group_by(id) %>%
    dplyr::mutate(shapsums = cumsum(value)) %>% dplyr::select(-value) %>%
    dplyr::mutate(id = as.factor(id))%>%
    dplyr::mutate(yhat = dplyr::last(shapsums))

  Yhat_var <- var(c(PPTreeregOBJ$origY, predict.PPTreereg(PPTreeregOBJ, testObs = testObs, final.rule = final.rule)))
  Yhat_range <- range(c(PPTreeregOBJ$origY, predict.PPTreereg(PPTreeregOBJ, testObs = testObs, final.rule = final.rule)))
  Yhat_range <- round(range(c(Yhat_range-0.1*Yhat_var, Yhat_range+0.1*Yhat_var)),4)


  p <- ppSHAP_melt %>%
    ggplot2::ggplot(ggplot2::aes(x=variable,y=shapsums, group=id, color=yhat)) +
    ggplot2::geom_line()+
    ggplot2::scale_colour_stepsn(colours = c("#3300FF", "#FF0033"),
                                 breaks = round(PPTreeregOBJ$cut.class,4),
                                 guide = ggplot2::guide_coloursteps(show.limits = TRUE),
                                 limits = Yhat_range)+
    ggplot2::coord_flip()+
    ggplot2::scale_x_discrete(expand = c(0,0))+
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = "white",colour = NA),
                   panel.border = ggplot2::element_rect(fill = NA,colour = "grey20"),
                   panel.grid.major.y =  ggplot2::element_line(colour = "grey92"),
                   panel.grid.minor.y = ggplot2::element_line(colour = "grey92"),
                   panel.grid.major.x =  ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank(),
                   legend.position = "bottom",
                   legend.key.width = ggplot2::unit(3, "line")
    )+
    ggplot2::labs(title=paste0("Decision plot"),
                  y = "Model output value", x = "")

  p+ list(
    if(Yrange){
      ggplot2::scale_y_continuous(sec.axis = ggplot2:: dup_axis(name = "Yhat"), limits = Yhat_range)
    }
    else{
      ggplot2::scale_y_continuous(sec.axis = ggplot2:: dup_axis(name = "Yhat"))
    }
  )
}

