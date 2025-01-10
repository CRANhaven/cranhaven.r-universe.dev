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

SEXP hNormalCopula(SEXP Rho, SEXP X, SEXP V, SEXP Eps);
SEXP hIndepCopula(SEXP X, SEXP V);
SEXP hTCopula(SEXP Rho, SEXP Df, SEXP X, SEXP V, SEXP Eps);
SEXP hClaytonCopula(SEXP Theta, SEXP X, SEXP V, SEXP Eps);
SEXP hGumbelCopula(SEXP Theta, SEXP X, SEXP V, SEXP Eps);
SEXP hFGMCopula(SEXP Theta, SEXP X, SEXP V, SEXP Eps);
SEXP hGalambosCopula(SEXP Theta, SEXP X, SEXP V, SEXP Eps);
SEXP hFrankCopula(SEXP Theta, SEXP X, SEXP V, SEXP Eps);
