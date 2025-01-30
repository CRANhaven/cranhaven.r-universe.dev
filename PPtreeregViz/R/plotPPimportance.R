#' Visualize importance measure of trained \code{PPTreereg} model.
#'
#' To visualize the variable importance values of \code{PPTreereg} model, two types of plots are
#' provided - importance of variables for each final node and global variable importance.
#' @title Variable importance plot of \code{PPTreereg}
#' @param x an importance object of the class \code{PPimpobj}, created with \code{\link{PPimportance}} function
#' @param marginal plot global importance. Default value is FALSE.
#' @param num_var number of variables to show.
#' @param ... arguments to be passed to methods
#' @export
#' @return An object of the class \code{ggplot}
#' @keywords tree
#' @examples
#' data(dataXY)
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' Tree.Imp <- PPimportance(Model)
#' plot(Tree.Imp)
#' plot(Tree.Imp, marginal = TRUE)
#'


plot.PPimportance <- function(x, marginal = FALSE, num_var = 5,...){
  Final_Node = Importance_value = importance = variable = 1
  if(marginal == FALSE){
    imp_nodes_final <- x$imp_node_final %>% data.frame()
    imp_nodes_final$variable <- row.names(imp_nodes_final)
    imp_nodes_final <- imp_nodes_final %>%
      reshape2::melt(id.vars = c("variable"),variable.name = "Final_Node", value.name = "Importance_value")%>%
      dplyr::group_by(Final_Node) %>%
      dplyr::arrange(abs(Importance_value), .by_group = TRUE)

    pd <- imp_nodes_final %>% dplyr::top_n(num_var, abs(Importance_value)) %>%
      dplyr::ungroup() %>%
      dplyr::arrange(Final_Node, abs(Importance_value)) %>% dplyr::mutate(order = dplyr::row_number())

    p <-  pd %>%  ggplot2::ggplot( ggplot2::aes(order, Importance_value, fill = sign(Importance_value)))+
      ggplot2::geom_bar(stat = "identity", show.legend = FALSE)+
      ggplot2::scale_fill_gradient2(low = "red3", high = "dodgerblue3") +
      ggplot2::facet_wrap(Final_Node~., scales = "free") +
      ggplot2::theme_bw()+
      ggplot2::xlab("")+
      ggplot2::coord_flip()+
      ggplot2::scale_x_continuous(
        breaks = pd$order,
        labels = pd$variable,
        expand = c(0,0)) +
      ggplot2::scale_y_continuous(limits = c(min(pd$Importance_value),max(pd$Importance_value)))

  }else{

    final_imp <-x$imp_var
    final_imp_df <- data.frame("variable"= final_imp %>% names(), "importance"=final_imp)

    p<- final_imp_df  %>%
      dplyr::top_n(num_var, abs(importance)) %>%
      ggplot2::ggplot(ggplot2::aes(x=stats::reorder(variable,importance), y=importance,fill=importance))+
      ggplot2::geom_bar(stat="identity", position="dodge")+
      ggplot2::coord_flip()+
      ggplot2::ylab("Variable Importance")+
      ggplot2::xlab("")+
      ggplot2::theme_bw()+
      ggplot2::ggtitle("Variable Importance Value Summary")+
      ggplot2::guides(fill="none")+
      ggplot2::scale_fill_gradient(low="dodgerblue1", high="dodgerblue4")
  }
  p
}

