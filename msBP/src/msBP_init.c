#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .C calls */
extern void allTrees_C(void *, void *, void *, void *, void *, void *, void *);
extern void computeprob_C(void *, void *, void *, void *, void *, void *, void *);
extern void dmsBP_C(void *, void *, void *, void *, void *);
extern void marginalBeta_C(void *, void *, void *);
extern void msBPgibbs(void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *);
extern void pmsBP_C(void *, void *, void *, void *, void *, void *);
extern void postCluster_C(void *, void *, void *, void *, void *, void *, void *);
extern void randtree_C(void *, void *, void *, void *, void *);
extern void rsample_msBP_C(void *, void *, void *, void *, void *, void *, void *);

static const R_CMethodDef CEntries[] = {
    {"allTrees_C",     (DL_FUNC) &allTrees_C,      7},
    {"computeprob_C",  (DL_FUNC) &computeprob_C,   7},
    {"dmsBP_C",        (DL_FUNC) &dmsBP_C,         5},
    {"marginalBeta_C", (DL_FUNC) &marginalBeta_C,  3},
    {"msBPgibbs",      (DL_FUNC) &msBPgibbs,      28},
    {"pmsBP_C",        (DL_FUNC) &pmsBP_C,         6},
    {"postCluster_C",  (DL_FUNC) &postCluster_C,   7},
    {"randtree_C",     (DL_FUNC) &randtree_C,      5},
    {"rsample_msBP_C", (DL_FUNC) &rsample_msBP_C,  7},
    {NULL, NULL, 0}
};

void R_init_msBP(DllInfo *dll)
{
    R_registerRoutines(dll, CEntries, NULL, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
