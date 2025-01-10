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

SEXP hinverseCopula(SEXP Copula, SEXP U, SEXP V);
SEXP hinverseNormalCopula(SEXP Rho, SEXP U, SEXP V, SEXP Eps);
SEXP hinverseIndepCopula(SEXP U, SEXP V);
SEXP hinverseTCopula(SEXP Rho, SEXP Df, SEXP U, SEXP V, SEXP Eps);
SEXP hinverseClaytonCopula(SEXP THETA, SEXP U, SEXP V, SEXP Eps);
SEXP hinverseFrankCopula(SEXP Theta, SEXP U, SEXP V, SEXP Eps);
