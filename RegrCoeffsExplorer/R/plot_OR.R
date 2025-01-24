#' Plot Odds Ratio
#'
#' @description
#' The function accepts input in the form of a generalized linear model (GLM)
#' or a glmnet object, specifically those employing binomial families, and
#' proceeds to generate a suite of visualizations illustrating alterations in
#' Odds Ratios for given predictor variable corresponding to changes between
#' minimum, first quartile (Q1), median (Q2), third quartile (Q3), and maximum
#' values observed in empirical data. These plots offer a graphical depiction
#' of the influence exerted by individual predictors on the odds of the outcome,
#' facilitating a clear interpretation of their respective significance. Such
#' a tool aids in comprehending the interplay between predictors and outcomes
#' within the logistic regression framework, particularly within the context
#' of empirical data distributions.
#'
#' @param func A fitted model object with binomial family, expected to be one
#'             of the following classes:
#'
#'    - `glm lm`             : Generalized Linear Models.
#'
#'    - `lognet glmnet`      : Regularized Logistic Models.
#'
#' @param data Input data frame that was used to fit the input function
#'               (`data.frame` object).
#' @param var_name Name of a variable to plot graphs for (`string` object).
#' @param color_filling Vector with color numbers to plot in bar plot
#'                        (`vector` object).
#'                        Default is `grey.colors(4, start=0.1, end=0.9)`.
#' @param verbose `TRUE` to print additional information such as Warnings,
#'                  `FALSE` otherwise (`bool` object). Default is `FALSE`.
#' @return A list with the following components:
#'   - `$BarPlot`    : A `ggplot` object that visualizes dependency of a change
#'                     in Variable values on function's Odds Ratio values.
#'
#'   - `$BoxPlot`    : A `ggplot` object that visualizes distribution of data
#'                     points for a given variable.
#'
#'   - `$SidebySide` : A `ggarrange` object containing both visualizations
#'                     side-by-side.
#' @importFrom "grDevices" "grey.colors"
#' @importFrom "glmnet" "glmnet"
#' @importFrom "magrittr" "%>%"
#' @importFrom "ggpubr" "ggarrange"
#' @importFrom "ggplot2" "ggplot" "geom_boxplot" "geom_jitter" "xlim" "xlab"
#'                       "ylab" "theme_minimal" "geom_bar" "geom_line"
#'                       "geom_point" "guides" "theme" "aes" "guide_legend"
#'                       "element_blank"
#' @importFrom rlang .data
#'
#' @examples
#' ### Prepare Sample Binomial Data
#' set.seed(42)
#' obs_num = 100
#'
#' x1 = rnorm(obs_num)
#' x2 = rnorm(obs_num)
#' x3 = rnorm(obs_num)
#'
#' prob = plogis(1 + 0.3 * x1 + 0.2 * x2 + 0.1 * x3)
#' y = rbinom(obs_num, 1, prob)
#' data = data.frame(x1, x2, x3, y)
#'
#'
#' ### GLM Object Exmaple
#' # Get GLM model
#' glm_object = glm(y ~ x1 + x2 + x3,
#'                  family=binomial(link="logit"),
#'                  data=data)
#' summary(glm_object)
#'
#' # Plot Odds Ratio graphs
#' plot_OR(glm_object, data, var_name="x2")$"SidebySide"
#'
#'
#' ### GLMNET Object Example
#' require(glmnet)
#'
#' # Get Lasso model
#' y_lasso = data$y
#' x_lasso = model.matrix(as.formula(paste("~",
#'                                         paste(colnames(subset(data,
#'                                                               select=-c(y))),
#'                                               collapse = "+"),
#'                                         sep = "")),
#'                        data=data)
#' x_lasso = x_lasso[,-1]
#' ndim_lasso = dim(x_lasso)[1]
#'
#' # Select the 1se lambda from cross validation
#' cv_model_lasso = cv.glmnet(x_lasso, y_lasso, family="binomial", alpha=1)
#' lambda_lasso = cv_model_lasso$lambda.1se
#' plot(cv_model_lasso)
#'
#' # Get a model with the specified lambda
#' model_lasso = glmnet(x_lasso, y_lasso, family="binomial",
#'                      alpha=0.5, lambda=lambda_lasso)
#' summary(model_lasso)
#'
#' # Plot Odds Ratio graphs
#' plot_OR(model_lasso, data, var_name="x2")$"SidebySide"
#' @export
plot_OR <- function(func,
                    data,
                    var_name,
                    color_filling=grey.colors(4, start=0.1, end=0.9),
                    verbose=FALSE) {
  # get variable values from dataframe
  values=data[[var_name]]

  # check var_name value
  if (!(var_name %in% names(data))) {
    stop("Variable name '", var_name, "' is not in data.")
  } else if (all(is.na(values))) {
    stop("Variable '", var_name, "' is null.\n")
  } else if (!(class(values) %in% c("numeric","integer"))) {
    stop("Variable name '", var_name, "' is not numeric.")
  }

  # check input function
  object_class_name=paste(class(func), collapse=',')

  if (grepl("glmnet", object_class_name)) {
    # if an input function is a glmnet object
    if (func$call$'family' != "binomial") {
      stop("The function family must be 'binomial'. Obtained: '",
           func$call$'family', "'.")
    }
    if (var_name %in% rownames(coef(func))) {
      var_coef=exp(coef(func))[var_name,]
    } else {
      stop("Variable '", var_name, "' is not in the function.\n")
    }
  } else if (grepl("glm", object_class_name)) {
    # if an input function is a glm object
    if (func$family$family != "binomial") {
      stop("The function family must be 'binomial'. Obtained: '",
           func$family$family, "'.")
    }
    if (var_name %in% names(coef(func))) {
      var_coef=exp(coef(func)[var_name])
    } else {
      stop("Variable '", var_name, "' is not in the function.\n")
    }
  } else {
    stop("The function is not glm or glmnet.")
  }

  # plot graphs
  plot_or_graphs(var_name, var_coef, values, color_filling)
}


plot_or_graphs = function(var_name, var_coef, values, color_filling) {
  values=values%>%sort()

  m_min=min(values)
  m_max=max(values)
  vals_range=m_max-m_min
  offset_val=vals_range*.05

  xx=c(quantile(values, c(0.25,0.50,0.75), names=F), m_max)
  xx_diff=xx-m_min
  eff_size=var_coef^xx_diff

  xx_all=values[-1]
  xx_diff_all=xx_all-m_min
  eff_size_all=var_coef^xx_diff_all

  yy=eff_size
  yy_all=eff_size_all

  dat2=data.frame(x=xx, y=yy, fct=factor(c("min --> Q1",
                                           "min --> Q2",
                                           "min --> Q3",
                                           "min --> max"),
                                         levels=c("min --> Q1",
                                                  "min --> Q2",
                                                  "min --> Q3",
                                                  "min --> max")))
  dat3=data.frame(x=xx_all, y=yy_all)

  bar_plot = ggplot(data=dat2) +
    geom_bar(aes(x = .data[["x"]], y = .data[["y"]], fill = .data[["fct"]]), stat="identity", width=offset_val) +
    xlim(m_min-offset_val, m_max+offset_val) +
    ylab("OR") +
    geom_line(data = dat3, aes(x = .data[["x"]], y = .data[["y"]]), linetype="dashed", linewidth=0.5) +
    geom_point(data = dat3, aes(x = .data[["x"]], y = .data[["y"]]), shape=1) +
    guides(fill=guide_legend(title="Size Effect")) +
    theme_minimal() +
    theme(axis.title.x = element_blank(), axis.text.x = element_blank()) +
    theme(legend.title.align = 0.5, legend.position = "bottom") +
    scale_fill_manual(values = color_filling)

  box_plot = ggplot(data.frame(values), aes(x = .data[["values"]], y = "")) +
    geom_boxplot(notch = TRUE) +
    geom_jitter() +
    xlim(m_min-offset_val, m_max+offset_val) +
    xlab(var_name) +
    ylab("Boxplot") +
    theme_minimal()

  sbs_plot = ggarrange(bar_plot, box_plot, ncol=1, nrow=2,
                       common.legend=TRUE, legend="bottom")

  return_list=list("BarPlot"=bar_plot, "BoxPlot"=box_plot,
                   "SidebySide"=sbs_plot)
  return(return_list)
}
