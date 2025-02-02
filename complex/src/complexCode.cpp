#include <RcppArmadillo.h>
#include <iostream>
// [[Rcpp::depends(RcppArmadillo)]]

using namespace Rcpp;

/* # Function calculates inverse of matrix of complex variables */
//' Function calculates inverse of matrix of complex variables
//'
//' The function accepts a square complex matrix and returns inverse of it.
//'
//' @param x The square matrix of complex variables.
//'
//' @template author
//'
//' @return The function returns a matrix of the same size as the original
//' matrix \code{x}
//'
//' @seealso \link[base]{solve}
//'
//' @examples
//'
//' invert(matrix(complex(real=c(1,2), imaginary=c(1.1,2.1)), 2, 2))
//'
//' @useDynLib complex
//' @export
// [[Rcpp::export]]
arma::cx_mat invert(arma::cx_mat x) {
  return x.i();
}


/* # Function allows to multiply polinomails */
// [[Rcpp::export]]
ComplexVector polyprodcomplex(ComplexVector const &poly1, ComplexVector const &poly2){

    int poly1Nonzero = poly1.size()-1;
    int poly2Nonzero = poly2.size()-1;

    ComplexVector poly3(poly1Nonzero + poly2Nonzero + 1);

    for(int i = 0; i <= poly1Nonzero; ++i){
        for(int j = 0; j <= poly2Nonzero; ++j){
            poly3[i+j] = poly3[i+j] + poly1[i] * poly2[j];
        }
    }

    return poly3;
}
