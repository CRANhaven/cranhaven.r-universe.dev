#include <RcppArmadillo.h>
#include <cmath>
#include <boost/math/special_functions/digamma.hpp>
#include "parse_split_vector.h"
#include "get_nearest_neighbors.h"
#include "lnc_compute.h"
using namespace std;

//' kNN Mutual Information Estimators
//'
//' Computes mutual information based on the distribution of nearest neighborhood distances. Method available are KSG1 and KSG2 as described by Kraskov, et. al (2004) and the Local Non-Uniformity Corrected (LNC) KSG as described by Gao, et. al (2015). The LNC method is based on KSG2  but with PCA volume corrections to adjust for observed non-uniformity of the local neighborhood of each point in the sample.
//'
//' @param  data Matrix of sample observations, each row is an observation.
//' @param  splits A vector that describes which sets of columns in \code{data} to compute the mutual information between. For example, to compute mutual information between two variables use \code{splits = c(1,1)}. To compute \emph{redundancy} among multiple random variables use \code{splits = rep(1,ncol(data))}. To compute the mutual information between two random vector list the dimensions of each vector.
//' @param  options A list that specifies the estimator and its necessary parameters (see details).
//' @section Details: Current available methods are LNC, KSG1 and KSG2.
//'
//' For KSG1 use: \code{options = list(method = "KSG1", k = 5)}
//'
//' For KSG2 use: \code{options = list(method = "KSG2", k = 5)}
//'
//' For LNC use: \code{options = list(method = "LNC", k = 10, alpha = 0.65)}, order needed \code{k > ncol(data)}.
//'
//' @section Author:
//' Isaac Michaud, North Carolina State University, \email{ijmichau@ncsu.edu}
//' @section References:
//' Gao, S., Ver Steeg G., & Galstyan A. (2015). Efficient estimation of mutual information for strongly dependent variables. Artificial Intelligence and Statistics: 277-286.
//'
//' Kraskov, A., Stogbauer, H., & Grassberger, P. (2004). Estimating mutual information. Physical review E 69(6): 066138.
//' @examples
//' set.seed(123)
//' x <- rnorm(1000)
//' y <- x + rnorm(1000)
//' knn_mi(cbind(x,y),c(1,1),options = list(method = "KSG2", k = 6))
//'
//' set.seed(123)
//' x <- rnorm(1000)
//' y <- 100*x + rnorm(1000)
//' knn_mi(cbind(x,y),c(1,1),options = list(method = "LNC", alpha = 0.65, k = 10))
//' #approximate analytic value of mutual information
//' -0.5*log(1-cor(x,y)^2)
//'
//' z <- rnorm(1000)
//' #redundancy I(x;y;z) is approximately the same as I(x;y)
//' knn_mi(cbind(x,y,z),c(1,1,1),options = list(method = "LNC", alpha = c(0.5,0,0,0), k = 10))
//' #mutual information I((x,y);z) is approximately 0
//' knn_mi(cbind(x,y,z),c(2,1),options = list(method = "LNC", alpha = c(0.5,0.65,0), k = 10))
//'
//' @export
//' @useDynLib rmi
//'
// [[Rcpp::export]]
double knn_mi(arma::mat data,
              Rcpp::NumericVector splits,
              const Rcpp::List & options) {

  std::string method = Rcpp::as<std::string>(options["method"]);
  int              k = Rcpp::as<int>(options["k"]);
  int            lnc = 0;

  int K     = k+1;
  int N     = data.n_rows;
  int vars  = splits.length();
  arma::colvec alpha(vars+1);

  if (method == "LNC") {
    lnc     = 1;
    method  = "KSG2";
    alpha   = Rcpp::as<arma::colvec>(options["alpha"]);
    for (int i = 0; i < alpha.size(); i++) {
      if (alpha(i) >= 0) {
        alpha(i) = log(alpha(i));
      }
    }
  }

  arma::imat nn_inds(N,K);
  arma::mat nn_dist(N,K);

  arma::icolvec d(vars+1);
  arma::icolvec d_start(vars+1);
  arma::icolvec d_end(vars+1);

  parse_split_vector(splits,d,d_start,d_end);
  get_nearest_neighbors(data, nn_dist, nn_inds,k);
  double digamma_x = 0;
  double mi = (vars-1)*boost::math::digamma(N) + boost::math::digamma(k);
  int N_x;
  double epsilon;
  double dist;
  double proposed_correction;
  double lnc_correction = 0;

  if (method == "KSG1") { //ksg1
    for (int i = 0; i < N; i++) { // for point i
      for (int j = 1; j <= vars; j++) { // count marginal sum for jth block
        N_x     = 0;
        epsilon = nn_dist(i,k);

        for (int m = 0; m < N; m++) { // iterate over all points
          dist = 0;

          for (int n = d_start(j); n <= d_end(j); n++) {
            if (dist < abs(data(i,n)-data(m,n))) {
              dist = abs(data(i,n)-data(m,n));
            }
          }
          if (dist < epsilon) N_x++;
        }
        digamma_x = digamma_x + boost::math::digamma(N_x);
      }
    }
   // printf("mi: %f, digamma:%f",mi,digamma_x);
    mi = mi - digamma_x/(double)N;
  }

  if (method == "KSG2") { //ksg2
    for (int i = 0; i < N; i++) { // for point i
      for (int j = 1; j <= vars; j++) { // count marginal sum for jth block
        N_x = 0;
        epsilon = 0;

        for (int m = 1; m < K; m++) {
          dist = 0;
          for (int n = d_start(j); n <= d_end(j); n++) {
            if (dist < abs(data(i,n)-data(nn_inds(i,m),n))) {
              dist = abs(data(i,n)-data(nn_inds(i,m),n));
            }
          }
          if (dist > epsilon) {
            epsilon = dist;
          }
        }

        for (int m = 0; m < N; m++) { // iterate over all points
          // printf("%d\n",j);
          dist = 0;

          for (int n = d_start(j); n <= d_end(j); n++) {
            if (dist < abs(data(i,n)-data(m,n))) {
              dist = abs(data(i,n)-data(m,n));
            }
          }
          //  printf("dist:%f\n",dist);
          if (dist <= epsilon) N_x++;
        }
        digamma_x = digamma_x + boost::math::digamma(N_x-1);
      }
    }
    //printf("mi: %f, digamma:%f",mi,digamma_x);
    mi = mi - digamma_x/(double)N - (vars - 1)/(double)k ;
  }

  // if (lnc == 1) { //LNC corrections
  //   for (int j = 0; j < N; j++) {
  //     proposed_correction = lnc_compute(XY, XY_inds, i,d,K);
  //     if (proposed_correction < log(alpha(0))) {
  //       // printf("%d : %f, %f\n",j,proposed_correction,log(alpha(0)));
  //       lnc_correction = lnc_correction - proposed_correction;
  //     }
  //     for (int i = 1; i <= vars; i++) {
  //       if (splits(i-1) == 1) continue;
  //       proposed_correction = lnc_compute(X, X_inds, i,d_x,K);
  //       if (proposed_correction < alpha(i)) {
  //         // printf("%d : %f, %f\n",j,proposed_correction,log(alpha(i)));
  //         lnc_correction = lnc_correction - proposed_correction;
  //       }
  //     }
  //   }
  // }

  if (lnc == 1) { //LNC corrections (new version)
    for (int i = 0; i < N; i++) {
      if (d_end(0) - d_start(0) == 0) continue; //probably will never get triggered (check that joint is 2 dimension or more)
      proposed_correction = lnc_compute(data, nn_inds, i, d_start(0), d_end(0));
      if (proposed_correction < alpha(0)) { //apply joint correction
        lnc_correction = lnc_correction - proposed_correction;
        for (int j = 1; j <= vars; j++) {
          //skip any coordinates with 1 variable
          if (d_end(j) - d_start(j) == 0) continue;
          proposed_correction = lnc_compute(data, nn_inds, i, d_start(j), d_end(j));
          if (proposed_correction < alpha(j)) {
              lnc_correction = lnc_correction + proposed_correction;
           }
        }
      }
    }
  }

  // if (lnc == 1) { //LNC corrections
  //   for (int i = 0; i < N; i++) {
  //     for (int j = 0; j <= vars; j++) {
  //       //skip any coordinates with 1 variable
  //       if (d_end(j) - d_start(j) == 0) continue;
  //       proposed_correction = lnc_compute(data, nn_inds, i, d_start(j), d_end(j));
  //       if (proposed_correction < alpha(j)) {
  //         //printf("%d : %f, %f\n",j,proposed_correction,log(alpha(0)));
  //         if (j == 0) {
  //           lnc_correction = lnc_correction - proposed_correction;
  //         } else {
  //           lnc_correction = lnc_correction + proposed_correction;
  //         }
  //       }
  //     }
  //   }
  // }

  return mi + lnc_correction/(double)N;
}

