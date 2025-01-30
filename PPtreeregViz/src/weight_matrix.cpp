#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]
using namespace arma;
using namespace Rcpp;

//' Calculate weight matrix
//'
//' @param subsets List. Each of the elements equals an integer
//' vector representing a valid combination of features/feature groups.
//' @param m Integer. Number of features/feature groups
//' @param n Integer. Number of combinations
//' @param w Numeric vector of length \code{n}, i.e. \code{w[i]} equals
//' the Shapley weight of feature/feature group combination \code{i}, represented by
//' \code{subsets[[i]]}.
//'
//' @export
//' @keywords internal
//'
//' @return Matrix of dimension n x m + 1
//' @author Nikolai Sellereite
// [[Rcpp::export]]
arma::mat weight_matrix_cpp(List subsets, int m, int n, NumericVector w){
    int n_elements;
    IntegerVector subset_vec;
    arma::mat Z(n, m + 1, arma::fill::zeros), X(n, m + 1, arma::fill::zeros);
    arma::mat R(m + 1, n, arma::fill::zeros);

    // Populate Z
    for (int i = 0; i < n; i++) {

        // Set all elements in the first column equal to 1
        Z(i, 0) = 1;

        // Extract subsets
        subset_vec = subsets[i];
        n_elements = subset_vec.length();
        if (n_elements > 0) {
            for (int j = 0; j < n_elements; j++)
                Z(i, subset_vec[j]) = 1;
        }
    }

    // Populate X
    for (int i = 0; i < n; i++) {

        for (int j = 0; j < Z.n_cols; j++) {

            X(i, j) = w[i] * Z(i, j);
        }
    }

    R = inv(X.t() * Z) * X.t();

    return R;
}
