#include "RcppArmadillo.h"
#include "Rcpp.h"
// [[Rcpp::depends(RcppArmadillo)]]
using namespace arma;
using namespace Rcpp;

// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::depends(Rcpp)]]

//' @exportPattern "^[[:alpha:]]+"
//' @importFrom Rcpp evalCpp
//' @useDynLib PPtreeregViz


//' Get imputed data
//'
//' @param xbar mean of each leaf.
//'
//' @param index_simple Positive integer.
//'
//' @param xtest Numeric matrix. Represents a single test observation.
//'
//' @param S Integer matrix of dimension \code{n_combinations x m}, where \code{n_combinations} equals
//' the total number of sampled/non-sampled feature combinations and \code{m} equals
//' the total number of unique features. Note that \code{m = ncol(xtrain)}. See details
//' for more information.
//'
//' @export
//' @keywords internal
//'
//' @return Numeric matrix
//'
//' @author Nikolai Sellereite
// [[Rcpp::export]]
NumericMatrix observation_impute_cpp_simple(NumericMatrix xbar,
                                     IntegerVector index_simple,
                                     NumericMatrix xtest,
                                     IntegerMatrix S) {

    if (xbar.ncol() != xtest.ncol())
        Rcpp::stop("Number of columns in xtrain and xtest should be equal.");

    NumericMatrix X(S.nrow(), xbar.ncol());
      for (int i = 0; i < X.nrow(); ++i){
        for (int j = 0; j < X.ncol(); ++j){

          if (S(index_simple[i] - 1, j) > 0 ) {
            X(i, j) = xtest(0,j);
          } else {
            X(i, j) = xbar(0,j);
          }
        }
      }
    return X;
}
