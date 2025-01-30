#' weight_matrix
#'
#' The original source for much of this came from 'shapr' package
#' code in github.com/NorskRegnesentral/shapr/blob/master/R/shapley.R
#' Below is the original license statement for 'shapr' package.
#'
#' MIT License
#' Copyright (c) 2019 Norsk Regnesentral
#' Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#' The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#'
#' @param X X
#' @param normalize_W_weights default is TRUE
#' @author Nikolai Sellereite
#' @return Numeric matrix
#' @references The \code{shapr} package developed by
#' Nikolai Sellereite, Martin Jullum, Annabelle Redelmeier, Norsk Regnesentral.
#' \doi{10.1016/j.artint.2021.103502} and modified some codes at
#' \url{https://github.com/NorskRegnesentral/shapr}
#'
weight_matrix <- function(X, normalize_W_weights = TRUE) {

  # Fetch weights
  w <- X[["shapley_weight"]]

  if (normalize_W_weights) {
    w[-c(1, length(w))] <- w[-c(1, length(w))] / sum(w[-c(1, length(w))])
  }

  W <- weight_matrix_cpp(
    subsets = X[["features"]],
    m = X[.N][["n_features"]],
    n = X[, .N],
    w = w
  )

  return(W)
}

#' feature_exact
#'
#' The original source for much of this came from 'shapr' package
#' code in github.com/NorskRegnesentral/shapr/blob/master/R/features.R
#'
#' Below is the original license statement for 'shapr' package.
#'
#' MIT License
#' Copyright (c) 2019 Norsk Regnesentral
#' Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#' The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#'
#'
#' @param m List. Contains vector of integers indicating the feature numbers for the different groups.
#' @param weight_zero_m  weight_zero_m
#' @author Nikolai Sellereite
#' @return A data.table with all feature group combinations, shapley weights etc.
#' @references The \code{shapr} package developed by
#' Nikolai Sellereite, Martin Jullum, Annabelle Redelmeier, Norsk Regnesentral.
#' \doi{10.1016/j.artint.2021.103502} and modified some codes at
#' \url{https://github.com/NorskRegnesentral/shapr}
#'
feature_exact <- function(m, weight_zero_m = 10^6) {
  features <- id_combination <- n_features <- shapley_weight <- N <- NULL # due to NSE notes in R CMD check

  dt <- data.table::data.table(id_combination = seq(2^m))
  combinations <- lapply(0:m, utils::combn, x = m, simplify = FALSE)
  dt[, features := unlist(combinations, recursive = FALSE)]
  dt[, n_features := length(features[[1]]), id_combination]
  dt[, N := .N, n_features]
  dt[, shapley_weight := shapley_weights(m = m, N = N, n_components = n_features, weight_zero_m)]

  return(dt)
}

#' shapley_weights
#'
#'  The original source for much of this came from 'shapr' package
#' code in github.com/NorskRegnesentral/shapr/blob/master/R/shapley.R
#' Below is the original license statement for 'shapr' package.
#'
#' MIT License
#' Copyright (c) 2019 Norsk Regnesentral
#' Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#' The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#'
#' @param m m
#' @param N N
#' @param n_components n_components
#' @param weight_zero_m weight_zero_m
#' @return Numeric
#' @author Nikolai Sellereite
#' @references The \code{shapr} package developed by
#' Nikolai Sellereite, Martin Jullum, Annabelle Redelmeier, Norsk Regnesentral.
#' \doi{10.1016/j.artint.2021.103502} and modified some codes at
#' \url{https://github.com/NorskRegnesentral/shapr}
#'
shapley_weights <- function(m, N, n_components, weight_zero_m = 10^6) {
  x <- (m - 1) / (N * n_components * (m - n_components))
  x[!is.finite(x)] <- weight_zero_m
  x
}

#' Calculate \code{PPKernelSHAP} values with simple methods
#'
#' This function should only be called internally, and not be used as
#' a stand-alone function.
#' The original source for much of this came from 'shapr' package
#' code in github.com/NorskRegnesentral/shapr/blob/master/R/predictions.R
#'
#' Below is the original license statement for 'shapr' package.
#'
#' MIT License
#' Copyright (c) 2019 Norsk Regnesentral
#' Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#' The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#'
#'
#' @param PPTreeregOBJ PPTreereg class object - a model to be explained
#' @param testObs test data observation
#' @param final.rule final rule to assign numerical values in the final nodes.
#'             1: mean value in the final nodes
#'             2: median value in the final nodes
#'             3: using optimal projection
#'             4: using all independent variables
#'             5: using several significant independent variables
#' @param final.leaf location of final leaf
#' @return List of simple methods and model values
#'
ppshapr.simple <- function(PPTreeregOBJ, testObs, final.rule, final.leaf = NULL){
  origclass <- id_combination <- leafid <- p_hat <- finalLeaf <-  NULL # due to NSE notes in R CMD check
  finalRule = as.integer(final.rule)
  leaf_len = length(PPTreeregOBJ$class.num)

  x_train <- data.table::as.data.table(PPTreeregOBJ$Tree.result$origdata)


  if(is.null(nrow(testObs))){
    testObs <- as.data.frame(t(testObs))
  }
  x_test <- data.table::as.data.table(testObs)

  if(nrow(x_test)>1){
    stop("nrow of test observation is more than 1")
  }

  feature_names <- names(x_train)
  n_features <- ncol(x_train)

  dt_combinations <- feature_exact(n_features, weight_zero_m= 10^6)
  weighted_mat <- weight_matrix(X = dt_combinations , normalize_W_weights = TRUE)
  feature_matrix <- shapr::feature_matrix_cpp(features =  dt_combinations[["features"]], m = n_features)
  n_combinations <- nrow(feature_matrix)
  n_samples <- 1e3

  x_train$origclass <- data.table::as.data.table(PPTreeregOBJ$Tree.result$origclass)

  index_features <- dt_combinations[, .I]
  S <-feature_matrix[index_features, ]

  dt_l <- list()

  for (l in seq(leaf_len)){
    x_train_ <- as.matrix(x_train[origclass==l,][,origclass:=NULL])
    n_train_ <- nrow(x_train_)
    n_samples_ <- min(n_samples, n_train_)
    index_simple <- seq(1,nrow(S))
    w <- 1 /n_samples_
    x_test <- as.matrix(x_test[1, , drop = FALSE])
    x_bars <- as.matrix( data.table::as.data.table(PPTreeregOBJ$class.origX.mean)[l,])

    dt_p <- observation_impute_cpp_simple(
      xbar = x_bars,
      index_simple = index_simple,
      xtest = x_test,
      S = S
    )

    # Add keys
    dt_l[[l]] <- data.table::as.data.table(dt_p)
    data.table::setnames(dt_l[[l]], colnames(x_train_))
    dt_l[[l]][, id_combination := index_simple]
    dt_l[[l]][, w := w]
    dt_l[[l]][, leafid := l]
  }

  dt = data.table::rbindlist(dt_l, use.names = TRUE, fill = TRUE)
  data.table::setkeyv(dt, c("leafid", "id_combination"))
  max_id_combination <- dt[, max(id_combination)]



  # Predictions
  prediction_zero = predict.PPTreereg(PPTreeregOBJ,PPTreeregOBJ$class.origX.mean,final.rule = finalRule)
  dt[id_combination != 1, p_hat := predict.PPTreereg(PPTreeregOBJ,newdata = .SD,final.rule = finalRule), .SDcols = feature_names]
  dt[id_combination == 1, p_hat := prediction_zero]

  p_all <- unique(dt[id_combination == max(id_combination), p_hat])
  names(p_all) <- names(x_test)

  # Calculate contributions
  dt_res <- dt[, .(k = sum((p_hat * w) / sum(w))), .( leafid, id_combination)]
  data.table::setkeyv(dt_res, c( "leafid", "id_combination"))

  dt_mat <- data.table::dcast(dt_res, id_combination ~ leafid ,value.var = "k")
  dt_mat[, id_combination := NULL] # contribution_mat
  kshap <- t(weighted_mat %*% as.matrix(dt_mat))

  dt_kshap <- data.table::as.data.table(kshap)
  dt_kshap[,finalLeaf := seq(leaf_len)]
  colnames(dt_kshap) <- c("none", feature_names, "finalLeaf")

  if(is.null(final.leaf)){
    # get_class_info
    class_info <- predict.PPTreereg(PPTreeregOBJ,testObs,final.rule = finalRule,classinfo = TRUE)$Yhat.class
    dt_kshap_final <- dt_kshap[class_info,]
  }else{
    dt_kshap_final <- dt_kshap[final.leaf,]
  }


  r <- list(
    dt = dt_kshap_final,
    model = PPTreeregOBJ,
    p = p_all,
    final.rule = finalRule,
    x_test = x_test
  )

  return(r)

}

#' Calculate \code{PPKernelSHAP} values with empirical methods
#'
#' This function should only be called internally, and not be used as
#' a stand-alone function.
#' The original source for much of this came from 'shapr' package
#' code in github.com/NorskRegnesentral/shapr/blob/master/R/predictions.R
#'
#' Below is the original license statement for 'shapr' package.
#'
#' MIT License
#' Copyright (c) 2019 Norsk Regnesentral
#' Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#' The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#'
#'
#' @param PPTreeregOBJ PPTreereg class object - a model to be explained
#' @param testObs test data observation
#' @param final.rule final rule to assign numerical values in the final nodes.
#'             1: mean value in the final nodes
#'             2: median value in the final nodes
#'             3: using optimal projection
#'             4: using all independent variables
#'             5: using several significant independent variables
#' @param final.leaf location of final leaf
#' @return List of empirical methods and model values
#'
ppshapr.empirical <- function(PPTreeregOBJ, testObs, final.rule, final.leaf = NULL){
  origclass <- id_combination <- leafid <- V1 <- p_hat <- finalLeaf <- keep <- NULL # due to NSE notes in R CMD check

  finalRule = as.integer(final.rule)
  leaf_len = length(PPTreeregOBJ$class.num)
  x_train <- data.table::as.data.table(PPTreeregOBJ$Tree.result$origdata)

  if(is.null(nrow(testObs))){
    testObs <- as.data.frame(t(testObs))
  }
  x_test <- data.table::as.data.table(testObs)

  if(nrow(x_test)>1){
    stop("nrow of test observation is more than 1")
  }


  feature_names <- names(x_train)
  n_features <- ncol(x_train)

  dt_combinations <- feature_exact(n_features, weight_zero_m= 10^6)
  weighted_mat <- weight_matrix(X = dt_combinations , normalize_W_weights = TRUE)
  feature_matrix <- shapr::feature_matrix_cpp(features =  dt_combinations[["features"]], m = n_features)
  n_combinations <- nrow(feature_matrix)
  n_samples <- 1e3

  x_train$origclass <- data.table::as.data.table(PPTreeregOBJ$Tree.result$origclass)

  index_features <- dt_combinations[, .I]
  S <-feature_matrix[index_features, ]

  dt_l <- list()

  for (l in seq(leaf_len)){
    x_train_ <- as.matrix(x_train[origclass==l,][,origclass:=NULL])
    n_train_ <- nrow(x_train_)
    n_samples_ <- min(n_samples, n_train_)
    index_s_ <- rep(index_features, each = n_samples_)
    w <- 1 /n_samples_

    index_xtrain <- c(replicate(nrow(S), seq(n_train_)))

    x_test <- as.matrix(x_test[1, , drop = FALSE])
    dt_p <- shapr::observation_impute_cpp(
      index_xtrain = index_xtrain,
      index_s = index_s_,
      xtrain = x_train_,
      xtest = x_test,
      S = S
    )

    # Add keys
    dt_l[[l]] <- data.table::as.data.table(dt_p)
    data.table::setnames(dt_l[[l]], colnames(x_train_))
    dt_l[[l]][, id_combination := index_s_]
    dt_l[[l]][, w := w]
    dt_l[[l]][, leafid := l]
  }

  dt = data.table::rbindlist(dt_l, use.names = TRUE, fill = TRUE)
  data.table::setkeyv(dt, c("leafid", "id_combination"))
  dt[, keep := TRUE]
  max_id_combination <- dt[, max(id_combination)]

  first_element <- dt[, tail(.I, 1), .(leafid, id_combination)][id_combination %in% c(1, max_id_combination), V1]
  dt[id_combination %in% c(1, max_id_combination), keep := FALSE]
  dt[first_element, c("keep", "w") := list(TRUE, 1.0)]
  dt <- dt[keep == TRUE][, keep := NULL]

  # Predictions
  prediction_zero = predict.PPTreereg(PPTreeregOBJ,PPTreeregOBJ$class.origX.mean,final.rule = finalRule)
  dt[id_combination != 1, p_hat := predict.PPTreereg(PPTreeregOBJ,newdata = .SD,final.rule = finalRule), .SDcols = feature_names]
  dt[id_combination == 1, p_hat := prediction_zero]

  p_all <- unique(dt[id_combination == max(id_combination), p_hat])
  names(p_all) <- names(x_test)

  # Calculate contributions
  dt_res <- dt[, .(k = sum((p_hat * w) / sum(w))), .( leafid, id_combination)]
  data.table::setkeyv(dt_res, c( "leafid", "id_combination"))

  dt_mat <- data.table::dcast(dt_res, id_combination ~ leafid ,value.var = "k")
  dt_mat[, id_combination := NULL] # contribution_mat
  kshap <- t(weighted_mat %*% as.matrix(dt_mat))

  dt_kshap <- data.table::as.data.table(kshap)
  dt_kshap[,finalLeaf := seq(leaf_len)]
  colnames(dt_kshap) <- c("none", feature_names, "finalLeaf")

  if(is.null(final.leaf)){
    # get_class_info
    class_info <- predict.PPTreereg(PPTreeregOBJ,testObs,final.rule = finalRule,classinfo = TRUE)$Yhat.class
    dt_kshap_final <- dt_kshap[class_info,]
  }else{
    dt_kshap_final <- dt_kshap[final.leaf,]
  }

  r <- list(
    dt = dt_kshap_final,
    model = PPTreeregOBJ,
    p = p_all,
    final.rule = finalRule,
    x_test = x_test
  )
  return(r)
}
