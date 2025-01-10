//
#if 1
//
extern void R_registerRoutines(void);
extern void R_useDynamicSymbols(void);
//
void dummy(void) {
    R_registerRoutines();
    R_useDynamicSymbols();
}
#else
//
#include "Rip-0-5-1.h"
//
SEXP Rip_ipv4_init_0(SEXP Ripv4, SEXP Ripstrings);
//
static const R_CallMethodDef R_CallDef[] = {
  #include "templates/Rip-register-routine.c"
  {NULL, NULL, 0}
};
//
void R_init_IP(DllInfo *dll) {
    R_registerRoutines(dll, NULL, R_CallDef, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
    // R_forceSymbols(dll, TRUE);
}
#endif
