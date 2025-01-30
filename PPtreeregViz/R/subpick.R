#' Pick several data containing various information for each final node for \code{PPTreereg}

#' \code{submodular} Pick (\code{SP-LIME}) was developed (Ribeiro et al., 2016) to selects
#' representative data with important information to determine the
#' reliability of model based on the \code{LIME} algorithm.
#' In order to extract data for each final node in the \code{PPTreereg} model,
#'  \code{PP SP-LIME} was proposed based on \code{SP-LIME}.

#' @title projection pursuit \code{submodular} pick algorithm \code{PP SP-LIME}
#' @usage subpick(data_long, final.leaf, obsnum = 5)
#' @param data_long \code{ppshapr_prep} class object.
#' @param final.leaf location of final leaf
#' @param obsnum The number of budgets (instance to be selected). Default value is 1.
#'
#' @return Observation names and their original values as data
#' @references
#' Ribeiro, Marco Tulio, Sameer Singh, and Carlos Guestrin.
#' "" Why should i trust you?" Explaining the predictions of any classifier." Proceedings of the 22nd ACM SIGKDD international conference on knowledge discovery and data mining. 2016.
#' \doi{10.1145/2939672.2939778}
#' \url{https://github.com/marcotcr/lime/blob/master/lime/submodular_pick.py}
#' @keywords submodular
#' @export
#'
#' @examples
#' data("dataXY")
#' Model <- PPTreereg(Y~., data = dataXY, DEPTH = 2)
#' shap_long=ppshapr_prep(Model,final.rule =3,method="simple")
#' subpick(shap_long,final.leaf = 1, obsnum = 5)
#'
#'

subpick <- function(data_long,final.leaf, obsnum = 5){
  variable <- id <- finalLeaf <- feature_dict <- NULL # due to NSE notes in R CMD check
  feature_dict = levels(data_long[,variable])
  d_prime = length(feature_dict)

  data.table::setkey(data_long, id)
  data_long_f = data_long[finalLeaf==final.leaf]

  W_ = data.table::dcast(data_long_f, finalLeaf+id ~variable, value.var = "value")
  sample_size = length(unique(W_[,id]))

  W <- W_[,feature_dict, with=FALSE]

  # Create the global importance vector, I_j described in the paper
  importance = sqrt(colSums(abs(W)))

  # NoW1 run the SP-LIME greedy algorithm
  remaining_indices = W_[,id]
  remaining_indices = remaining_indices[!duplicated(remaining_indices)]

  V <- c()
  V_times <- c()

  for( k in c(1:obsnum)){
    best = 0
    best_ind = NA
    current = 0

    for (j in remaining_indices){
      current = sum(abs(W_)[id %in% c(V,j),feature_dict, with=FALSE]*importance)
      if(current >= best){
        best = current
        best_ind = j}
    }
    V <- c(V, best_ind)
    remaining_indices <-  setdiff(remaining_indices, best_ind)
  }
  V_ <- sort(V)

  origdata_ = data.table::dcast(data_long_f[id %in% V_], finalLeaf+id ~variable,value.var = "rfvalue")

  result <- list(df = origdata_[,feature_dict, with=FALSE], obs= V_)

  return(result)
}
