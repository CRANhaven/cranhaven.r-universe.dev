#' waterfall plot for \code{PPKernelSHAP}
#'
#' Waterfall plot is mainly used to explain individual predictions,
#' and is suitable for showing an explanation when a single piece of data is
#' entered as an input using \code{PPKernelSHAP} values.
#'
#' @title Waterfall plot
#' @param PPTreeregOBJ PPTreereg class object - a model to be explained
#' @param testObs test data observation
#' @param final.rule final rule to assign numerical values in the final nodes.
#'             1: mean value in the final nodes
#'             2: median value in the final nodes
#'             3: using optimal projection
#'             4: using all independent variables
#'             5: using several significant independent variables
#' @param method simple or empirical method to calculate \code{PPKernelSHAP}
#' @param final.leaf location of final leaf
#' @export
#' @return An object of the class \code{ggplot}
#' @examples
#' data(dataXY)
#' testX <- dataXY[1,-1]
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' waterfallplot(Model, testX, final.rule =5, method="simple")
#'
#'
waterfallplot <- function(PPTreeregOBJ, testObs, final.rule = 5, method="simple", final.leaf = NULL){
  icols <- V1 <-  ..icols <- rowname <- finalLeaf <- NULL # due to NSE notes in R CMD check
  if(method=="simple"){
    tmp <- ppshapr.simple(PPTreeregOBJ,testObs,final.rule,final.leaf = final.leaf)$dt
  }else{
    tmp <- ppshapr.empirical(PPTreeregOBJ,testObs,final.rule,final.leaf = final.leaf)$dt
  }
  PPshapvalue <- tmp %>% as.data.frame() %>%
    tibble::rownames_to_column() %>%
    dplyr::select(-c(rowname, finalLeaf)) %>%
    reshape2::melt(id.vars = NULL) #  tmp
  plotT <- PPshapvalue %>% waterfalls::waterfall(calc_total=TRUE,
                                                 rect_text_labels = round(PPshapvalue$value, 3),
                                                 total_rect_text = round(sum(PPshapvalue$value),5),
                                                 total_axis_text = "Prediction",
                                                 total_rect_text_color="black",
                                                 lines_anchors = c("left", "right"),
                                                 total_rect_color="goldenrod1")+
    ggplot2::coord_flip()+
    ggplot2::labs(
      title = "Decision plot for test data",
      subtitle = paste0("final leaf = ", tmp[,"finalLeaf"]),
      y="",
      x="")+
    ggplot2::theme_minimal()

  plotT
}


