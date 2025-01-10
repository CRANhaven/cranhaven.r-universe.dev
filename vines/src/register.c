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
#include <R_ext/Rdynload.h>

#include "h.h"
#include "hinverse.h"


R_CallMethodDef callMethods[] = {
    { "hIndepCopula", (DL_FUNC) &hIndepCopula, 2 },
    { "hNormalCopula", (DL_FUNC) &hNormalCopula, 4 },
    { "hinverseNormalCopula", (DL_FUNC) &hinverseNormalCopula, 4 },
    { "hinverseIndepCopula", (DL_FUNC) &hinverseIndepCopula, 2 },
    { "hTCopula", (DL_FUNC) &hTCopula, 5 },
    { "hinverseTCopula", (DL_FUNC) &hinverseTCopula, 5 },
    { "hClaytonCopula", (DL_FUNC) &hClaytonCopula, 4 },
    { "hinverseClaytonCopula", (DL_FUNC) &hinverseClaytonCopula, 4 },
    { "hGumbelCopula", (DL_FUNC) &hGumbelCopula, 4 },
    { "hFGMCopula", (DL_FUNC) &hFGMCopula, 4 },
    { "hGalambosCopula", (DL_FUNC) &hGalambosCopula, 4 },
    { "hFrankCopula", (DL_FUNC) &hFrankCopula, 4 },
    { "hinverseFrankCopula", (DL_FUNC) &hinverseFrankCopula, 4 },
    { NULL, NULL, 0 }
};

void R_init_vines(DllInfo *info) {
    R_registerRoutines(info, NULL, callMethods, NULL, NULL);
}
