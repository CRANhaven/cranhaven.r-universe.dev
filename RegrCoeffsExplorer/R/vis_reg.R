#' Visualize Regression Coefficients Within the Context of Empirical Data
#'
#' @description
#' Typically, regression coefficients for continuous variables are interpreted
#' on a per-unit basis and compared against coefficients for categorical
#' variables. However, this method of interpretation is flawed as it
#' overlooks the distribution of empirical data. This visualization tool
#' provides a more nuanced understanding of the regression
#' model's dynamics, illustrating not only the immediate effect of a unit change
#' but also the broader implications of larger shifts such as interquartile
#' changes.
#'
#' @import ggplot2
#' @importFrom gridExtra arrangeGrob
#' @importFrom magrittr `%>%`
#' @importFrom dplyr select_if mutate
#' @importFrom stats coef coefficients confint quantile reorder
#' @importFrom rlang .data
#'
#' @param object A fitted model object, expected to be one of the following classes:
#'   - `lm`                 : Linear Models.
#'   - `glm lm`             : Generalized Linear Models.
#'   - `elnet glmnet`       : Regularized Linear Models.
#'   - `lognet glmnet`      : Regularized Logistic Models.
#'   - `fixedLassoInf`      : Inference for the lassso for the linear models.
#'   - `fixedLogitLassoInf` : Inference for the lassso for the logistic models.
#'
#' @param ... Additional parameters.Please refer to details.
#'
#' @return A list with the following components:
#'   - `$PerUnitVis`: A `ggplot` object that visualizes regression coefficients
#'   on a per-unit basis
#'   - `$RealizedEffectVis`: A `ggplot` object that visualizes regression
#'   coefficients on a basis of realized effect calculation.
#'   - `$SidebySide`: A `grob` object containing both visualizations side-by-side.
#'
#'@details
#' The following additional arguments can be passed:
#'
#' * `CI`: A logical value indicating whether to include Confidence Intervals.
#'    - The default is `FALSE`.
#'    - For `fixedLassoInf` or `fixedLogitLassoInf` classes it is set to `TRUE`.
#'    - `confint()` is used to generate CIs for the `lm` and `glm lm` classes.
#'    - `If CIs are desired for the regularized models, please, fit your model
#'       using `fixedLassoInf()` function from the `selectiveInference` package
#'       following the steps outlined in the documentation for this package and
#'       pass the object of class `fixedLassoInf` or `fixedLogitLassoInf`.
#'
#' * `x_data_orig`: Original non-centered and non-scaled model matrix without
#'    intercept.
#'    - Please, pass the model matrix when CIs desired for `fixedLassoInf` and/or
#'    `fixedLogitLassoInf` object classes with penalty factors.
#'    - For objects fitted without penalty factors this argument is not required
#'     as original data can be reconstructed from the object passed.
#'
#' * `intercept`: A logical value indicating whether to include the intercept.
#'    - The default is `FALSE`.
#'    - For the regularized models it is set to `FALSE`.
#'
#' * `title` : Custom vectors of strings specifying titles  for both plots.
#'
#' * `alpha` : A numeric value between 0 and 1 specifying the significance level.
#'    - The default is 0.05.
#'
#' * `palette` : Custom vector of colors to highlight the direction of estimated
#'   regression coefficients or Odds Ratio.
#'    - Grey scale is implemented by default.
#'    - Values at low and high ends of the grey scale palette can be specified.
#'
#' * `start` : grey value at low end of palette.
#'    - The default value is 0.5.
#'
#' * `end`   : grey value at high end of palette.
#'    - The default value is 0.9.
#'
#' * `eff_size_diff` : A vector specifying which values to utilize for realized
#'    effect size calculation.It is applied to all independent variables. By
#'    default it is c(4,2) which is Q3 - Q1. The following coding scheme is used:
#'    - 1 is the minimum.
#'    - 2 is the first quartile.
#'    - 3 is the second quartile.
#'    - 4 is the third quartile.
#'    - 5 is the maximum.
#'
#' * `round_func` : A string specifying how to round the realized effect size.
#'    - Can be either "floor", "ceiling", or "none".
#'    - The default value is "none".
#'
#' * `glmnet_fct_var` : names of categorical variables for regularized models.
#'    - Glmnet treats all variables as numeric.
#'    - If any of the variables utilized are, in fact,  categorical, please,
#'      specify their name(s).
#'    - Please, note that that by default `model.matrix()`will create k-1
#'      dummy variables in lieu of k levels of a categorical variable.
#'      For example,if you have a factor variable called "sex" with two levels 0
#'      and 1, and 0 being the base level, `mode.matrix()` will create a dummy
#'      variable called "sex1". Please, utilize the names created by
#'      `mode.matrix()` here and not the original factor name.
#'
#' * `verbose` : A logical value indicating whether to display warning messages.
#'    - The default is `FALSE`.
#'
#' Please note the following:
#'
#' * Only `Gaussian` and `binomial` families are currently supported.
#'
#' * Certain steps should be followed in order to produce Confidence Intervals
#'   for the regularized models. Please, refer to the vignette for the `vis_reg()`
#'   function and the documentation of the `selectiveInference` package.
#'
#' * Penalty factor of 0 is not currently supported and no Confidence Intervals
#'   will be produced in this case.
#'
#' @examples
#' # Set seed for reproducibility
#' set.seed(38)
#' # Set the number of observations
#' n = 1000
#' # Generate predictor variables
#' X1 = rnorm(n)
#' X2 = rnorm(n)
#' X3 = rnorm(n)
#' # Define coefficients for each predictor
#' beta_0 = -1
#' beta_1 = 0.5
#' beta_2 = -0.25
#' beta_3 = 0.75
#' # Generate the latent variable
#' latent_variable = beta_0 + beta_1 * X1+ beta_2 * X2 + beta_3 * X3
#' # convert it to probabilities
#' p = pnorm(latent_variable)
#' # Generate binomial outcomes based on these probabilities
#' y = rbinom(n, size = 1, prob = p)
#' # Fit a GLM with a probit link
#' glm_model <- glm(y ~ X1 + X2 + X3, family = binomial(link = "probit"),
#'                  data = data.frame(y, X1, X2, X3))
#' # Specify additional parameters and Plot Odds Ratio for the Realized Effect
#' vis_reg(glm_model, CI=TRUE,intercept=TRUE,
#'         palette=c("greenyellow","red4"))$RealizedEffectVis
#'
#' @seealso
#' * \code{\link[stats]{lm}} for linear models.
#' * \code{\link[stats]{glm}} for generalized linear models.
#' * \code{\link[glmnet]{glmnet}} and \code{\link[glmnet]{cv.glmnet}} for
#'   lasso and elastic-net regularized generalized linear models.
#' * \code{\link[stats]{model.matrix}} for design matrices.
#' * \code{\link[ggplot2]{ggplot}} for ggplot objects.
#' * \code{\link[gridExtra]{arrangeGrob}} for grobs, gtables, and ggplots.
#' * \code{\link[selectiveInference]{fixedLassoInf}} for post-selection inference.
#'
#' @export

vis_reg = function(object,...){

  # require(ggplot2)
  # require(dplyr)
  # require(gridExtra)
  # source("detransform.R")

  # obtain a list of optional arguments passed
  args=list(...)

  # check family passed and set defaults
  if(is.null(eval(object$call$'family'))){
    args$family="gaussian"
  }else{args$family=eval(object$call$'family')}

  if("binomial" %in% eval(object$call$'family')){
    args$family="binomial"
  }

  if(!(args$family %in% c("gaussian", "binomial"))){
    stop("This visualization tool currently only supports Gaussian
         and Binomial families")
  }

  obj_family=args$family

  # set defaults for all cases which must be explicitly declared
  case_all_factors=case_glm_lm=case_lm=case_glmnet=FALSE

  if ("case_penalty" %in% names(args)){
    case_penalty = args$case_penalty
  }else{
    case_penalty=F                                                              # case_penalty=T must be specified
  }                                                                             # for fixedLassoInf/fixedLogitLassoInf objects

  if(obj_family=="binomial"){
    case_binomial=T
  }else{case_binomial=F}

  if ("CI" %in% names(args)){
    CI = args$CI
  }else{
    CI=F                                                                        # no CIs by default
  }

  if ("verbose" %in% names(args)){
    verbose = args$verbose
  }else{
    verbose=F                                                                   # no warning messages by default
  }

  # obtain names of continuous variables
  # extract data frame based on the class of object passed
  # check if all variables are categorical

  if(any(paste(class(object),collapse = ',')==c("glm,lm"))){
    case_glm_lm = T
    df_temp=object$data
    num_col_names=names(df_temp%>%select_if(is.numeric))
    num_col_names=num_col_names[num_col_names %in% all.vars(object$formula)[-1]] # first var is response
  }

  else if (any(paste(class(object),collapse = ',')==c("lm"))){
    case_lm = T
    df_temp=eval(object$call$data)
    num_col_names=names(df_temp%>%select_if(is.numeric))
    num_col_names=num_col_names[num_col_names %in%
                                  all.vars(eval(object$call$formula))[-1]]
  }

  else if (any(paste(class(object),collapse = ',')==c("elnet,glmnet")) ||
           any(paste(class(object),collapse = ',')==c("lognet,glmnet"))||
           any(class(object) %in% c("fixedLassoInf","fixedLogitLassoInf"))){

    case_glmnet = T
    args$intercept=F
    x_data=eval(object$call$x)

    #check if there any penalty factors passed
    if (!is.null(object$call$penalty.factor)){                                  # check for elnet/lognet objects
      case_penalty=T
      penfac=eval(object$call$penalty.factor)

      # check if any of penalty factors passed is set to 0
      if (any(penfac)==0){
        CI = F
        if (verbose){
        warning("No CIs are currently produced if any of the penalty factors
                 is equal to 0. Please,refer to documentation for the package
                 \"selectiveInference\" for additional information")
        }
      }
    }

    # Coefficients and CIs returned are always on the original scale
    # Check if data passed was centered and scaled and detransform data
    # Note that for LASSO with penalty data is being scaled twice

    if(any(class(object) %in% c("fixedLassoInf","fixedLogitLassoInf")) &
       case_penalty){
      CI=T                                                                      # CI must be true for fixedLassoInf type objects
      if ("x_data_orig" %in% names(args)){
        x_data_orig=args$x_data_orig
        df_temp=as.data.frame(as.matrix(x_data_orig))
      }else{
        stop("Please, provide data matrix on the original scale")
      }
    }

    else if(any(class(object) %in% c("fixedLassoInf","fixedLogitLassoInf"))){
      CI=T
      x_data_orig=detransform(x_data)
      df_temp=as.data.frame(as.matrix(x_data_orig))
    }

    else{
      df_temp=as.data.frame(as.matrix(x_data))
    }

    # glmnet might shrink several coefficients to zero
    # CIs for those coefficients do not exist

    if (isTRUE(CI) & isTRUE(case_glmnet)){
      if(length(object$vars)!=length(names(df_temp))){
        df_temp = df_temp[, names(df_temp) %in% names(object$vars)]
      }
    }

    # glmnet treats all variables as continuous
    # names of categorical variables should be supplied

    if (!("glmnet_fct_var" %in% names(args))){
      num_col_names=names(df_temp)
      cat_col_names=NULL
      if(verbose){
      warning("All variables are treated as numeric, as no names for categorical
              variables have been provided")
      }
    }else{
      cat_col_names=args$glmnet_fct_var
      coef_names=names(df_temp)
      cat_exist=sapply(cat_col_names,
                       function(x) exists(x, where = as.environment(df_temp)))  # check if factor name(s) exist(s)

      # check if all user-specified names of categorical variables exist in the data frame
      if (sum(cat_exist==T)!=length(cat_col_names)){
        cat_dnt_exist=names(which(cat_exist==F))
        if(length(cat_dnt_exist)==1){
          stop(paste(cat_dnt_exist, " name does not exist"))
        }else{
          stop(paste(paste(cat_dnt_exist, collapse = ", "), " names do not exist"))
        }
      }

      if(length(cat_col_names)==length(coef_names)){                            # only factors
        case_all_factors=T
        num_col_names=NULL
      }
      else{
        num_col_names=coef_names[!coef_names %in% cat_col_names]
      }
    }
  }else{
    stop("Object should be of one of the following classes: \"elnet\" \"glmnet\",
           \"lognet\" \"glmnet\",\"fixedLassoInf\", \"fixedLogitLassoInf\",
           \"glm\" \"lm\", \"lm\" ")
  }

  if(case_lm || case_glm_lm){
    if(sum(sapply(df_temp, is.factor))==dim(df_temp)[2] ||
           length(num_col_names)==0){
      case_all_factors=T
      num_col_names=NULL
      cat_col_names=names(object$coefficients)
      args$title=c("Regression with categorical variables only", "This is a placeholder")
      if(verbose){
      warning("All variables passed are factor variables")
      }
    }
  }

  # check that all variables for LM/GLM are either numeric or factor variables
  # remove the ones that are not numeric/factor (for example, ordinal)

  if((case_lm || case_glm_lm) && !case_all_factors){
    coef_names=names(object$coefficients)
    check_var_type = sapply(df_temp, function(x) is.numeric(x) || is.factor(x))
    if (any(!check_var_type)){                                                  # if any of variables is not factor or numeric
      non_num_fac_vars = names(df_temp)[!check_var_type]
      coef_names=coef_names[-which(coef_names==non_num_fac_vars)]
      if (verbose){
        if (length(non_num_fac_vars)==1){
          warning(paste(non_num_fac_vars),
                  "is not a numeric or a factor variable and will not be used")
      } else{
        warning(paste(non_num_fac_vars),
                "are not numeric or factor variables and will not be used")
        }
      }
    }
    cat_col_names=coef_names[!coef_names %in% num_col_names]                    # names of categorical variables + `Intercept`
  }

  # extract user-specified parameters and define defaults

  if ("title" %in% names(args)){
    title = args$title
    if (length(title)!=2){
      stop("Titles for both graphs should be supplied")
    }else{
      title1=title[1]
      title2=title[2]
    }
  }else{
    title1 = "Visualization of Regression Results (Unit)"                       # default title for plot 1
    title2 = "Visualization of Regression Results (Realized)"                   # default title for plot 2
  }

  if ("intercept" %in% names(args)){
    intercept = args$intercept
  }else{
    intercept = F                                                               # no intercept by default
  }

  if (isTRUE(CI)){
    if ("alpha" %in% names(args)){
      alpha=args$alpha
    }else{
      alpha=0.05                                                                # default confidence level is 95%
    }
  }

  # user-specified palette associated with increase/decrease in Odds Ratio or estimated coefficients
  if ("palette" %in% names(args)){
    scale_filling=scale_fill_manual(values=c("Increases" = args$palette[1],
                                             "Decreases" = args$palette[2]))
  }else {
    if ('start' %in% args){grey_start=args$start} else{grey_start=0.5}
    if ('end' %in% args){grey_end=args$end} else{grey_end=0.9}
    scale_filling=scale_fill_grey(start = grey_start, end = grey_end)           # default grey-scale palette
  }

  # if all variables passed are factors, then realized effect is irrelevant
  if(!case_all_factors){
    if ("eff_size_diff" %in% names(args)){
      eff_size_diff = args$eff_size_diff
      if (length(eff_size_diff)!=2){
        stop("In order to measure the effect size, two values should be supplied")
      }
      eff_size_diff=sort(eff_size_diff)
    }
    else{
      eff_size_diff=c(2,4)                                                      # by default, Q1 and Q3 are utilized
    }

    # for many problems, non-integer quantiles are not realistic

    if ("round_func" %in% names(args)){
      round_func = args$round_func
    }
    else{
      round_func = "none"                                                       # "floor" or "ceiling"
    }

    L=eff_size_diff[1]                                                          # effect size from (Q1 by default)
    U=eff_size_diff[2]                                                          # effect size to   (Q3 by default)

    # calculate the change between L and U                                      # effect size difference calculation
    diff_Q=apply(df_temp[,num_col_names],2,quantile)[U,]-
      apply(df_temp[,num_col_names],2,quantile)[L,]

    if (round_func!="none"){
      diff_Q=sapply(diff_Q,noquote(round_func))
    }

  }

  # calculate realized effect size for the glm object
  if(case_glm_lm){
    bottom_line = 1
    ylab_title = "Estimated Odds Ratio"
    coefs=exp(coefficients(object))
    if(!case_all_factors){
      coefs_eff_size=c(coefs[c(cat_col_names)],
                       coefs[c(num_col_names)]^diff_Q)
    }
    # calculate CIs for unit and effective changes (note for categorical variables and intercept CIs should not)
    if (isTRUE(CI)){
      conf_inf=suppressMessages(exp(confint(object,level=(1-alpha))))
      if(!case_all_factors){
        conf_inf_eff_size=suppressMessages(
          rbind(exp(confint(object,level=(1-alpha)))[c(cat_col_names),],
                exp(confint(object,level=(1-alpha))[c(num_col_names),])^diff_Q))
      }
    }
  }
  else if (case_lm){# calculate realized effect size for the lm object
    bottom_line = 0
    ylab_title = "Estimated Regression Coefficients"
    coefs=coefficients(object)
    if(!case_all_factors){
      coefs_eff_size=c(coefs[c(cat_col_names)],
                       coefs[c(num_col_names)]*diff_Q)
    }
    if (isTRUE(CI)){
      conf_inf=suppressMessages(confint(object,level=(1-alpha)))
      if(!case_all_factors){
        conf_inf_eff_size=suppressMessages(
          rbind(confint(object,level=(1-alpha))[c(cat_col_names),],
                confint(object,level=(1-alpha))[c(num_col_names),]*diff_Q))
      }
    }
  }else{                                                                        # calculate realized effect size for the glmnet object
    if(isTRUE(CI)){
      coefs=object$coef0                                                        # extract coefficients
      conf_inf=object$ci                                                        # extract CIs
      coefs=as.vector(coefs)                                                    # convert matrix to a vector
      rownames(conf_inf)=names(object$vars)                                     # rename CIs
      names(coefs)=names(object$vars)                                           # rename coefficients
    }
    else{
      # glmnet type objects produce matrices for coefs as compared to a vectors produced by glm,lm objects
      coefs=object$beta
      coefs_names=rownames(coefs)
      coefs=as.vector(coefs)                                                    # convert matrix to a vector
      names(coefs)=coefs_names                                                  # preserve names
    }

    if(obj_family=="gaussian"){
      bottom_line = 0
      ylab_title = "Estimated Regression Coefficients"
      if(!case_all_factors){
        coefs_eff_size=c(coefs[c(cat_col_names)],
                         coefs[c(num_col_names)]*diff_Q)
        if(isTRUE(CI)){
          conf_inf_eff_size=rbind(conf_inf[c(cat_col_names),],
                                  conf_inf[c(num_col_names),]*diff_Q)
        }
      }
    }
    else{
      bottom_line = 1
      ylab_title = "Estimated Odds Ratio"
      coefs=exp(coefs)
      if(!case_all_factors){
        coefs_eff_size=c(coefs[c(cat_col_names)],
                         coefs[c(num_col_names)]^diff_Q)
      }
      if(isTRUE(CI)){
        conf_inf=exp(conf_inf)
        conf_inf_eff_size=rbind(conf_inf[c(cat_col_names),],
                                (conf_inf[c(num_col_names),])^diff_Q)
      }
    }
  }

  if(isTRUE(intercept) | isTRUE(case_glmnet)){                                  # intercept is set to F for the glmnet-type objects
    temp_df = as.data.frame(as.matrix(coefs))
    if(!case_all_factors){
      temp_df_eff_size= as.data.frame(as.matrix(coefs_eff_size))
    }
  } else{
    temp_df = as.data.frame(as.matrix(coefs)[-1, ])                             # remove intercept
    if(!case_all_factors){
      temp_df_eff_size = as.data.frame(as.matrix(coefs_eff_size)[-1, ])         # remove intercept
    }
    if(isTRUE(CI)){
      conf_inf=conf_inf[-1,]                                                    # remove intercept
      if(!case_all_factors){
        conf_inf_eff_size=conf_inf_eff_size[-1,]                                # remove intercept
      }
    }
  }

  if(isTRUE(CI)){
    temp_df = cbind(rownames(temp_df), temp_df, conf_inf[,1],conf_inf[,2])
    colnames(temp_df) = c("Variables", "Estimates", "LowerL", "UpperL")
    rownames(temp_df) = 1:nrow(temp_df)
    if(!case_all_factors){
      temp_df_eff_size = cbind(rownames(temp_df_eff_size), temp_df_eff_size,
                               conf_inf_eff_size[,1],conf_inf_eff_size[,2])
      colnames(temp_df_eff_size) = c("Variables", "Estimates",
                                     "LowerL", "UpperL")
      rownames(temp_df_eff_size) = 1:nrow(temp_df_eff_size)
    }
  } else{
    temp_df = cbind(rownames(temp_df), temp_df)
    colnames(temp_df) = c("Variables", "Estimates")
    rownames(temp_df) = 1:nrow(temp_df)
    if(!case_all_factors){
      temp_df_eff_size = cbind(rownames(temp_df_eff_size), temp_df_eff_size)
      colnames(temp_df_eff_size) = c("Variables", "Estimates")
      rownames(temp_df_eff_size) = 1:nrow(temp_df_eff_size)
    }
  }

  plt1 = ggplot(temp_df %>% mutate(
    filling = ifelse(.data[["Estimates"]] > bottom_line,
                     "Increases", "Decreases")),
              aes(x = reorder(.data[["Variables"]], .data[["Estimates"]]),
                  y = .data[["Estimates"]],
                  fill = .data[["filling"]])) +
    geom_hline(yintercept = bottom_line, linetype = "dashed",
               color = "grey", size = 1) +
    geom_bar(stat = "identity") +
    coord_flip() +
    xlab("Variables") +
    ylab(ylab_title) +
    labs(fill = "Direction") +
    ggtitle(title1) +
    scale_filling +
    {if (isTRUE(CI)) {
      geom_errorbar(aes(ymin = .data[["LowerL"]],
                        ymax = .data[["UpperL"]]),
                    colour = "black", width = .2)
    }} +
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme(legend.title.align = 0.5) +
    theme(axis.line = element_line(colour = "black"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank())


  if(!case_all_factors){
    plt2 = ggplot(temp_df_eff_size %>% mutate(
      filling = ifelse(.data[["Estimates"]] > bottom_line, "Increases",
                       "Decreases")),
                aes(x = reorder(.data[["Variables"]], .data[["Estimates"]]),
                    y = .data[["Estimates"]],
                    fill = .data[["filling"]])) +
      geom_hline(yintercept = bottom_line, linetype = "dashed",
                 color = "grey", size = 1) +
      geom_bar(stat = "identity") +
      coord_flip() +
      xlab("Variables") +
      ylab(ylab_title) +
      labs(fill = "Direction") +
      ggtitle(title2) +
      scale_filling +
      {if (isTRUE(CI)) {
        geom_errorbar(aes(ymin = .data[["LowerL"]],
                          ymax = .data[["UpperL"]]),
                      colour = "black", width = .2)
      }} +
      theme_bw() +
      theme(plot.title = element_text(hjust = 0.5)) +
      theme(legend.title.align = 0.5) +
      theme(axis.line = element_line(colour = "black"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank())

    plt3=arrangeGrob(plt1,plt2, nrow=1, widths = c(1,1))                        # call grid.arrange() to display

    l=list("PerUnitVis"=plt1, "RealizedEffectVis" = plt2, "SidebySide"=plt3)
  }else{
    l=list("PerUnitVis"=plt1)
  }

  return(l)

}
