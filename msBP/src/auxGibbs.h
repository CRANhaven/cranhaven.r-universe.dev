/*-------------------------------------------------------------------------------
 Multiscale Bernstein polynomial [msBP]
 auxGibbs.hpp - Header with the auxiliary functions for gibbs.cpp 
 Version 0.1 of September-October 2013
 2013 - Antonio Canale (antonio.canale@unito.it)
-------------------------------------------------------------------------------*/
double griddy_B(double deltapar, double lambdapar, struct bintree *R,int maxS, double *griddy, int griddy_length);
void auxiliaryTrees(int *s, int *h, int N, struct bintree *n, struct bintree *r, struct bintree *v);
void postCluster(int *s, int *h, double *y, struct bintree *pi, int maxS, int N, int printscreen);
