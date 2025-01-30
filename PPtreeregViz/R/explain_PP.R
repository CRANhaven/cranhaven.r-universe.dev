#' Create Model Explainer for PPTreereg
#'
#' This function creates a unified representation explain of PPTreereg model for cooperate with \code{DALEX} package.
#'
#' @title Make explain of \code{PPTreeregObj} for \code{DALEX} package
#' @usage explain_PP(PPTreeregOBJ, data, y, final.rule,...)
#' @param PPTreeregOBJ PPTreereg class object - a model to be explained
#' @param data data.frame or matrix - data that was used for fitting. If not provided then will be extracted from the model. Data should be passed without target column (this shall be provided as the y argument).
#' @param y numeric vector with outputs / scores. If provided then it shall have the same size as data
#' @param final.rule rule to calculate the final node value
#' @param ... arguments to be passed to methods
#'
#' @references Explanatory Model Analysis. Explore, Explain and Examine Predictive Models. \url{https://ema.drwhy.ai/}
#' @export
#' @examples
#' library("DALEX")
#' library("dplyr")
#' data(dataXY)
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' new_explainer <- explain_PP(Model, data = dataXY[,-1],y = dataXY[,1],final.rule= 5)
#' DALEX::model_performance(new_explainer) %>% plot(geom = "ecdf")
#'
#' @return An object of the class \code{explainer}.

explain_PP <- function(PPTreeregOBJ, data, y, final.rule,...){
  explainer_PPTreereg <- DALEX::explain(
    model = PPTreeregOBJ,
    data = data,
    y = y,
    predict_function = function(m,x) as.numeric(predict.PPTreereg(m, x, final.rule = final.rule)),
    label = paste("PPTreereg with final rule: ",final.rule)
  )
  explainer_PPTreereg
}
