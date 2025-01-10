/*-------------------------------------------------------------------------------
 Multiscale Bernstein polynomial [msBP]
 wrapper.hpp - Header for the wrappers 
 Version 0.1 of September 2013
 2013 - Antonio Canale (antonio.canale@unito.it)
-------------------------------------------------------------------------------*/
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<R.h>
#include<Rmath.h>
#include "bintree.h"
#include "msBP.h"
void computeprob_C(double *S, double * R, int *maxS, double *a, double *b, double *ans);
void dmsBP_C(double *weights, double * grid, int * ngrid, int *maxS, double * out);
void randtree_C(double *a, double *b, int *maxS, double *ansS, double *ansR);
void rsample_msBP_C(int *N, double * Rvec, double *Svec, double *a, double *b, int * maxS, double *ans);
void marginalBeta_C(double * out, double *y, int *maxS);
void allTrees_C(int *s, int *h, int * maxS, int *N, double * nvec, double * rvec, double * vvec);
void postCluster_C(int *s, int *h, double *y, double *pi, int *maxS, int *N, int *printscreen);
