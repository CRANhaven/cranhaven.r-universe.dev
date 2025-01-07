#include <RcppArmadillo.h>

using namespace std;

void get_nearest_neighbors(arma::mat, arma::mat&, arma::imat&, int);

Rcpp::List nearest_neighbors(arma::mat, int);
