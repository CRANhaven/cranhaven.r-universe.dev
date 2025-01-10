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

#include "h.h"


SEXP hIndepCopula(SEXP X, SEXP V) {
    return X;
}

/* See Aas, K., Czado, C., Frigessi, A. & Bakken, H. Pair-copula
 * constructions of multiple dependence. Insurance Mathematics and
 * Economics, 2009, Vol. 44, pp. 182-198. for the expression for the
 * Gaussian, Student's t, Clayton and Gumbel copulas.
 */

SEXP hNormalCopula(SEXP Rho, SEXP X, SEXP V, SEXP Eps) {
    double eps;
    double rho;
    double *x, *v, *u;
    double vi, ui, num;
    SEXP U;

    PROTECT(U = allocVector(REALSXP, LENGTH(X)));
    eps = asReal(Eps);
    rho = asReal(Rho);
    x = REAL(X);
    v = REAL(V);
    u = REAL(U);

    for (int i = 0; i < LENGTH(X); i++) {
        if (x[i] <= eps || (rho >= 1 - eps && fabs(x[i] - v[i]) <= eps && x[i] < 1 - eps)) {
            u[i] = eps;
        } else if (1 - x[i] <= eps || (rho <= -1 + eps && x[i] + v[i] >= 1 - eps)) {
            u[i] = 1 - eps;
        } else {
	    vi = (v[i] <= eps) ? eps : ((v[i] >= 1 - eps) ? 1 - eps : v[i]);
	    num = qnorm(x[i], 0, 1, TRUE, FALSE) - rho*qnorm(vi, 0, 1, TRUE, FALSE);
	    ui = pnorm(num / sqrt(1 - rho*rho), 0, 1, TRUE, FALSE);
	    if (!isfinite(ui)) ui = (num < 0) ? 0 : 1;
	    u[i] = (ui <= eps) ? eps : ((ui >= 1 - eps) ? 1 - eps : ui);
        }
    }

    UNPROTECT(1);

    return U;
}

SEXP hTCopula(SEXP Rho, SEXP Df, SEXP X, SEXP V, SEXP Eps) {
    double eps;
    double rho, df;
    double *x, *v, *u;
    double vi, ui, tmp;
    SEXP U;

    PROTECT(U = allocVector(REALSXP, LENGTH(X)));
    eps = asReal(Eps);
    rho = asReal(Rho);
    df = asReal(Df);
    x = REAL(X);
    v = REAL(V);
    u = REAL(U);

    for (int i = 0; i < LENGTH(X); i++) {
        if (x[i] <= eps || (rho >= 1 - eps && fabs(x[i] - v[i]) <= eps && x[i] < 1 - eps)) {
            u[i] = eps;
        } else if (1 - x[i] <= eps || (rho <= -1 + eps && x[i] + v[i] >= 1 - eps)) {
            u[i] = 1 - eps;
        } else {
            vi = (v[i] <= eps) ? eps : ((v[i] >= 1 - eps) ? 1 - eps : v[i]);
            tmp = qt(vi, df, TRUE, FALSE);
            ui = pt((qt(x[i], df, TRUE, FALSE) - rho * tmp) /
                    sqrt(((df + tmp * tmp) * (1 - rho * rho)) / (df + 1)),
                    df + 1, TRUE, FALSE);
            u[i] = (ui <= eps) ? eps : ((ui >= 1 - eps) ? 1 - eps : ui);
        }
    }

    UNPROTECT(1);

    return U;
}

SEXP hClaytonCopula(SEXP Theta, SEXP X, SEXP V, SEXP Eps) {
    double eps;
    double theta;
    double *x, *v, *u;
    double vi, ui;
    SEXP U;

    eps = asReal(Eps);
    theta = asReal(Theta);

    if (theta <= eps) {
        return X;
    }

    PROTECT(U = allocVector(REALSXP, LENGTH(X)));
    x = REAL(X);
    v = REAL(V);
    u = REAL(U);

    for (int i = 0; i < LENGTH(X); i++) {
        if (x[i] <= eps) {
            u[i] = eps;
        } else if (1 - x[i] <= eps) {
            u[i] = 1 - eps;
        } else {
            vi = (v[i] <= eps) ? eps : ((v[i] >= 1 - eps) ? 1 - eps : v[i]);
            ui = (R_pow(vi, -theta - 1) *
                  R_pow(R_pow(x[i], -theta) + R_pow(vi, -theta) - 1, -1-1/theta));
            u[i] = (ui <= eps) ? eps : ((ui >= 1 - eps) ? 1 - eps : ui);
        }
    }

    UNPROTECT(1);

    return U;
}

SEXP hGumbelCopula(SEXP Theta, SEXP X, SEXP V, SEXP Eps) {
    double eps;
    double theta;
    double *x, *v, *u;
    double vi, ui, tmp, mlogxi, mlogvi;
    SEXP U;

    eps = asReal(Eps);
    theta = asReal(Theta);

    if (theta <= eps) {
        return X;
    }

    PROTECT(U = allocVector(REALSXP, LENGTH(X)));
    x = REAL(X);
    v = REAL(V);
    u = REAL(U);

    for (int i = 0; i < LENGTH(X); i++) {
        if (x[i] <= eps) {
            u[i] = eps;
        } else if (1 - x[i] <= eps) {
            u[i] = 1 - eps;
        } else {
            vi = (v[i] <= eps) ? eps : ((v[i] >= 1 - eps) ? 1 - eps : v[i]);
            mlogxi = -log(x[i]);
            mlogvi = -log(vi);
            tmp = R_pow(mlogxi, theta) + R_pow(mlogvi, theta);
            ui = (exp(-R_pow(tmp, 1/theta)) * R_pow(mlogvi, theta-1) *
                  R_pow(tmp, 1/theta-1) / vi);
            u[i] = (ui <= eps) ? eps : ((ui >= 1 - eps) ? 1 - eps : ui);
        }
    }

    UNPROTECT(1);

    return U;
}

SEXP hFGMCopula(SEXP Theta, SEXP X, SEXP V, SEXP Eps) {
    double eps;
    double theta;
    double *x, *v, *u;
    double ui;
    SEXP U;

    eps = asReal(Eps);
    theta = asReal(Theta);

    PROTECT(U = allocVector(REALSXP, LENGTH(X)));
    x = REAL(X);
    v = REAL(V);
    u = REAL(U);

    for (int i = 0; i < LENGTH(X); i++) {
        if (x[i] <= eps) {
            u[i] = eps;
        } else if (1 - x[i] <= eps) {
            u[i] = 1 - eps;
        } else {
            ui = (1 + theta * (-1 + 2*v[i]) * (-1 + x[i])) * x[i];
            u[i] = (ui <= eps) ? eps : ((ui >= 1 - eps) ? 1 - eps : ui);
        }
    }

    UNPROTECT(1);

    return U;
}

/* See Schirmacher, D. and Schirmacher, E. (2008) Multivariate dependence
 * modeling using pair-copulas. Enterprise Risk Management Symposium, Chicago.
 * for the expression for the Galambos and Frank copulas.
 */

SEXP hGalambosCopula(SEXP Theta, SEXP X, SEXP V, SEXP Eps) {
    double eps;
    double theta;
    double *x, *v, *u;
    double vi, ui, mlogxi, mlogvi, cdf;
    SEXP U;

    eps = asReal(Eps);
    theta = asReal(Theta);

    if (theta <= eps) {
        return X;
    }

    PROTECT(U = allocVector(REALSXP, LENGTH(X)));
    x = REAL(X);
    v = REAL(V);
    u = REAL(U);

    for (int i = 0; i < LENGTH(X); i++) {
        if (x[i] <= eps) {
            u[i] = eps;
        } else if (1 - x[i] <= eps) {
            u[i] = 1 - eps;
        } else {
            vi = (v[i] <= eps) ? eps : ((v[i] >= 1 - eps) ? 1 - eps : v[i]);
            mlogxi = -log(x[i]);
            mlogvi = -log(vi);
            cdf = x[i] * vi * exp(R_pow(R_pow(mlogxi, -theta) +
                                        R_pow(mlogvi, -theta), -1/theta));
            ui = (cdf/vi) * (1 - R_pow(1 + R_pow(mlogvi/mlogxi, theta),
                                       -1-1/theta));
            u[i] = (ui <= eps) ? eps : ((ui >= 1 - eps) ? 1 - eps : ui);
        }
    }

    UNPROTECT(1);

    return U;
}

SEXP hFrankCopula(SEXP Theta, SEXP X, SEXP V, SEXP Eps) {
    double eps;
    double theta;
    double *x, *v, *u;
    double vi, ui;
    SEXP U;

    eps = asReal(Eps);
    theta = asReal(Theta);

    if (fabs(theta) <= eps) {
        return X;
    }

    PROTECT(U = allocVector(REALSXP, LENGTH(X)));
    x = REAL(X);
    v = REAL(V);
    u = REAL(U);

    for (int i = 0; i < LENGTH(X); i++) {
        if (x[i] <= eps) {
            u[i] = eps;
        } else if (1 - x[i] <= eps) {
            u[i] = 1 - eps;
        } else {
            vi = (v[i] <= eps) ? eps : ((v[i] >= 1 - eps) ? 1 - eps : v[i]);
            ui = exp(-theta*vi) / (((1 - exp(-theta)) /
                                    (1 - exp(-theta*x[i]))) +
                                   exp(-theta*vi) - 1);
            u[i] = (ui <= eps) ? eps : ((ui >= 1 - eps) ? 1 - eps : ui);
        }
    }

    UNPROTECT(1);

    return U;
}
