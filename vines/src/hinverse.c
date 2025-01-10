// vines: Multivariate Dependence Modeling with Vines
// Copyright (C) 2011-2015 Yasser Gonzalez Fernandez
// Copyright (C) 2011-2015 Marta Soto Ortiz
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

#include <R.h>
#include <Rinternals.h>
#include <Rmath.h>

#include "hinverse.h"


SEXP hinverseIndepCopula(SEXP U, SEXP V) {
    return U;
}

/* See Aas, K., Czado, C., Frigessi, A. & Bakken, H. Pair-copula
 * constructions of multiple dependence. Insurance Mathematics and
 * Economics, 2009, Vol. 44, pp. 182-198. for the expression for the
 * Gaussian, Student's t, Clayton and Gumbel copulas.
 */

SEXP hinverseNormalCopula(SEXP Rho, SEXP U, SEXP V, SEXP Eps) {
    double eps;
    double rho;
    double *u, *v, *x;
    double vi, xi;
    SEXP X;

    PROTECT(X = allocVector(REALSXP, LENGTH(U)));
    eps = asReal(Eps);
    rho = asReal(Rho);
    u = REAL(U);
    v = REAL(V);
    x = REAL(X);

    for (int i = 0; i < LENGTH(U); i++) {
        if (u[i] <= eps) {
            x[i] = eps;
        } else if (1 - u[i] <= eps) {
            x[i] = 1 - eps;
        } else {
            vi = (v[i] <= eps) ? eps : ((v[i] >= 1 - eps) ? 1 - eps : v[i]);
            xi = pnorm(qnorm(u[i], 0, 1, TRUE, FALSE) * sqrt(1 - rho * rho) +
                       rho * qnorm(vi, 0, 1, 1, 0), 0, 1, TRUE, FALSE);
            x[i] = (xi <= eps) ? eps : ((xi >= 1 - eps) ? 1 - eps : xi);
        }
    }

    UNPROTECT(1);

    return X;
}

SEXP hinverseTCopula(SEXP Rho, SEXP Df, SEXP U, SEXP V, SEXP Eps) {
    double eps;
    double rho, df;
    double *u, *v, *x;
    double vi, xi, b2;
    SEXP X;

    PROTECT(X = allocVector(REALSXP, LENGTH(U)));
    eps = asReal(Eps);
    rho = asReal(Rho);
    df = asReal(Df);
    u = REAL(U);
    v = REAL(V);
    x = REAL(X);

    for (int i = 0; i < LENGTH(U); i++) {
        if (u[i] <= eps) {
            x[i] = eps;
        } else if (1 - u[i] <= eps) {
            x[i] = 1 - eps;
        } else {
            vi = (v[i] <= eps) ? eps : ((v[i] >= 1 - eps) ? 1 - eps : v[i]);
            b2 = qt(vi, df, TRUE, FALSE);
            xi = pt(qt(u[i], df+1, TRUE, FALSE) *
                    sqrt(((df + b2 * b2) * (1 - rho * rho)) / (df+1)) +
                    rho * b2, df, TRUE, FALSE);
            x[i] = (xi <= eps) ? eps : ((xi >= 1 - eps) ? 1 - eps : xi);
        }
    }

    UNPROTECT(1);

    return X;
}

SEXP hinverseClaytonCopula(SEXP Theta, SEXP U, SEXP V, SEXP Eps) {
    double eps;
    double theta;
    double *u, *v, *x;
    double vi, xi;
    SEXP X;

    eps = asReal(Eps);
    theta = asReal(Theta);

    if (theta <= eps) {
        return U;
    }

    PROTECT(X = allocVector(REALSXP, LENGTH(U)));
    u = REAL(U);
    v = REAL(V);
    x = REAL(X);

    for (int i = 0; i < LENGTH(U); i++) {
        if (u[i] <= eps) {
            x[i] = eps;
        } else if (1 - u[i] <= eps) {
            x[i] = 1 - eps;
        } else {
            vi = (v[i] <= eps) ? eps : ((v[i] >= 1 - eps) ? 1 - eps : v[i]);
            xi = R_pow(R_pow(u[i] * R_pow(vi, theta+1), -theta/(theta+1)) +
                       1 - R_pow(vi, -theta), -1/theta);
            x[i] = (xi <= eps) ? eps : ((xi >= 1 - eps) ? 1 - eps : xi);
        }
    }

    UNPROTECT(1);

    return X;
}

/* See Schirmacher, D. and Schirmacher, E. (2008) Multivariate dependence
 * modeling using pair-copulas. Enterprise Risk Management Symposium, Chicago.
 * for the expression for the Frank copula.
 */

SEXP hinverseFrankCopula(SEXP Theta, SEXP U, SEXP V, SEXP Eps) {
    double eps;
    double theta;
    double *u, *v, *x;
    double xi;
    SEXP X;

    eps = asReal(Eps);
    theta = asReal(Theta);

    if (fabs(theta) <= eps) {
        return U;
    }

    PROTECT(X = allocVector(REALSXP, LENGTH(U)));
    u = REAL(U);
    v = REAL(V);
    x = REAL(X);

    for (int i = 0; i < LENGTH(U); i++) {
        if (u[i] <= eps) {
            x[i] = eps;
        } else if (1 - u[i] <= eps) {
            x[i] = 1 - eps;
        } else {
            xi = -log(1 - ((1 - exp(-theta)) /
                           ((R_pow(u[i], -1) - 1) *
                             exp(-theta*v[i]) + 1))) / theta;
            x[i] = (xi <= eps) ? eps : ((xi >= 1 - eps) ? 1 - eps : xi);
        }
    }

    UNPROTECT(1);

    return X;
}
