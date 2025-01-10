#include <R.h>
#include <Rmath.h>
void F77_SUB(rndstart)(void){GetRNGstate();}
void F77_SUB(rndend)(void){PutRNGstate();}
double F77_SUB(unifrnd)(void){return runif(0,1);}
