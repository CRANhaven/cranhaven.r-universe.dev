#include <RcppArmadillo.h>

using namespace std;

void get_nearest_neighbors(arma::mat X,
                           arma::mat&  X_dist,
                           arma::imat& X_inds,
                           int k) {
  int d = X.n_cols;
  int N = X.n_rows;
  int K = k + 1;

  arma::mat temp_dist(N,N);
  arma::uvec temp_inds(N);

  double dist;

  for (int i = 0; i < N; i++) { //for each point in sample
    for (int j = i; j < N; j++) {
      if (i == j) {
        temp_dist(i,j) = 0.0;
      } else {
        dist = 0.0;
        for (int m = 0; m < d; m++) {
          if (dist < abs(X(i,m) - X(j,m))) {
            dist = abs(X(i,m) - X(j,m));
          }
        }
        temp_dist(i,j) = dist;
        temp_dist(j,i) = dist;
      }
    }
  }

  for (int i = 0; i < N; i++) {
    temp_inds        = arma::sort_index(temp_dist.row(i));
    temp_dist.row(i) = arma::sort(temp_dist.row(i));
    for (int j = 0; j < K; j++) {
     X_dist(i,j) = temp_dist(i,j);
     X_inds(i,j) = temp_inds(j);
    }
  }

  return;
}

// [[Rcpp::export]]
Rcpp::List nearest_neighbors(arma::mat data, int k) {
  int K = k+1;
  int N = data.n_rows;
  arma::imat nn_inds(N,K);
  arma::mat  nn_dist(N,K);
  get_nearest_neighbors(data, nn_dist, nn_inds,k);
  return Rcpp::List::create(Rcpp::Named("nn_dist") = nn_dist,
                            Rcpp::Named("nn_inds") = nn_inds);
}
