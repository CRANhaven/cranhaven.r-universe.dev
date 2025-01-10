/*-------------------------------------------------------------------------------
 Multiscale Bernstein polynomials [msBP]
 auxGibbs.cpp - Auxiliary functions for gibbs.cpp 
 Version 0.2 of October 2014
 2013/2014 - Antonio Canale (antonio.canale@unito.it)
-------------------------------------------------------------------------------*/
#include<R.h>
#include<Rmath.h>
#include "bintree.h"
#include "msBP.h"
extern "C++" {
//------------------------------------------------------------------------------
// compute the three auxiliary trees with r, n, and v
void auxiliaryTrees(int *s, int *h, int N, struct bintree *n, struct bintree *r, struct bintree *v)
{

void *vmax = vmaxget();

int vecsize = 0;
int i=0;
int j=0;

int maxS = 0;
for(i=0; i<N; i++) 
{
maxS = (int) fmax(maxS, s[i]);
}

vecsize = (int) std::pow((double) 2.0, maxS + 1) - 1;

//directly the size of each cluster
whichnode2(n, s, h, maxS, N);

//global vectors
double *vVec, *rVec;
vVec = ( double* ) R_alloc(vecsize, sizeof(double));
rVec = ( double* ) R_alloc(vecsize, sizeof(double));

for(j=0; j<vecsize; j++)
	{
		vVec[j] = 0;
		rVec[j] = 0;
	}

//i-th subject specific vectors 
struct bintree *vi = new struct bintree;
struct bintree *ri = new struct bintree;
setTree(0, vi);
setTree(0, ri);

//single vectors
double *vVeci, *rVeci;
vVeci = ( double* ) R_alloc(vecsize, sizeof(double));
rVeci = ( double* ) R_alloc(vecsize, sizeof(double));

for(i=0; i<N; i++)
{
	for(j=0; j<vecsize; j++)
	{
		vVeci[j] = 0;
		rVeci[j] = 0;
	}
	clearTree(ri);
	clearTree(vi);
	vi = path(vi, s[i], h[i]);
	tree2array(vi, vVeci, maxS, 0);
	ri = wentright(ri, s[i], h[i]);
	tree2array(ri, rVeci, maxS, 0);
	for(j=0; j<vecsize; j++)
	{
		vVec[j] = vVec[j] + vVeci[j];
		rVec[j] = rVec[j] + rVeci[j];
	}
}
deleteTree(vi);
deleteTree(ri);
array2tree(vVec, maxS, v);
array2tree(rVec, maxS, r);
//liberare vVec, rVec, vVeci, rVeci (4 x vecsize) sizeof(double)
vmaxset(vmax);
}
//------------------------------------------------------------------------------
// compute allocation probabilities given slice -- [Algorithm 2]
void postCluster(int *s, int *h, double *y, struct bintree *pi, int maxS, int N, int printscreen)
{
	void *vmax = vmaxget();
	// initialize indexes and stuff
	int sInd=0, hInd=1;
	double slice=0.0;
	double totweight = 0;
	int i = 0;	
	int maxH = (int) std::pow((double) 2.0, maxS);
	//vector of probability for each scale (0, 1, ..., max)
	double  *pi_s;
	pi_s = ( double* ) R_alloc(maxS+1, sizeof(double));
	for(sInd=0; sInd<(maxS+1); sInd++) pi_s[sInd] = 0;
	//vector of probability for each scale (0, 1, ..., max) (subject specific)
	double  *ps;
	ps = ( double* ) R_alloc(maxS+1, sizeof(double));
	for(sInd=0; sInd<(maxS+1); sInd++) ps[sInd] = 0;
	//vector of probability for each node in a scale (subject specific)
	double  *ph;
	ph = ( double* ) R_alloc(maxH, sizeof(double));
	for(hInd=0; hInd<maxH; hInd++) ph[hInd] = 0;
	scaleProb(pi, pi_s, maxS);
	if(printscreen)
	{
		Rprintf("\nP(scale)");
		for(sInd=0; sInd<(maxS+1); sInd++) 
		{
			totweight += pi_s[sInd];
			Rprintf("%f, ", pi_s[sInd]);
		}
		Rprintf("and %f", 1-totweight);	
	}

	// then for each subject	
	for(i=0; i<N; i++)
	{
		slice = unif_rand();
		// (1) slice which the scale
		slice = unif_rand()*pi_s[s[i]];
		if(printscreen) 
		{
			Rprintf("\nCurrently subject %i (%f) at scale %i: %f~U(0,%f)", i+1, y[i], s[i], slice, pi_s[s[i]]);
		}
		for(sInd=0; sInd<=maxS; sInd++)
		{
			ps[sInd] = 0;
			if(pi_s[sInd]>slice)
			{
				maxH = (int) std::pow((double) 2.0, sInd);		
				for(hInd=1; hInd<=maxH; hInd++) ps[sInd] += extractNode(pi, sInd, hInd, 0)*dbeta(y[i], hInd, maxH-hInd+1, 0);  
				ps[sInd] = ps[sInd]/pi_s[sInd];
				if(printscreen) 
				{	
					Rprintf("\n   pi_%i > slice <-> (%f>%f)", sInd, ps[sInd], slice);
				}
			}
		}
		s[i] = sampleC(ps, maxS+1)-1;

		// (2) given the scale, allocate to one node
		maxH = (int) std::pow((double) 2.0, s[i]);		
		for(hInd=1; hInd<=maxH; hInd++) ph[hInd-1] = extractNode(pi, s[i], hInd, 0) * dbeta(y[i], hInd, maxH - hInd + 1, 0); 
		h[i] = sampleC(ph, maxH);

		if(printscreen) 
		{
			Rprintf("\n      Prob subject scales:\n      ");
			for(sInd=0; sInd<=maxS; sInd++) Rprintf("p(%i)=%f,",sInd, ps[sInd]);	
			Rprintf("\n      Prob subject node:  \n      ");		
			for(hInd=1; hInd<=maxH; hInd++) Rprintf("p(%i)=%f,",hInd, ph[hInd-1]);	
			Rprintf("\n      Node (%i, %i)", s[i], h[i]);
		}
	//}
	}
vmaxset(vmax);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
double griddy_B(double deltapar, double lambdapar, struct bintree *R, 
	int maxS, double *griddy, int griddy_length)
{
int index=0;

double * post;
post = ( double* ) R_alloc(griddy_length, sizeof(double));
double Rsh;
int i, s, h;
int maxH;

for(i=0; i<griddy_length; i++) post[i] = dgamma(griddy[i], deltapar, 1/lambdapar, 1);
//Rprintf("\nLength grid%i. posterior prob:", griddy_length);
for(s=0; s<(maxS+1); s++)
{
	maxH = (int) std::pow((double) 2.0, s);		
	for(h=1; h<=maxH; h++)
	{
		Rsh = extractNode(R,s,h,0);
		for(i=0; i<griddy_length; i++)
		{
			post[i] += dbeta(Rsh, griddy[i], griddy[i], 1);
		}
	}
}

//for(i=0; i<griddy_length; i++)	Rprintf("%f_[%i], ", post[i],i);

for(i=0; i<griddy_length; i++) post[i] = exp(post[i]);
//Rprintf("\-----------------------------------------------------:");
//Rprintf("\nGriddy:");
//for(i=0; i<griddy_length; i++) Rprintf("%f ", post[i]);
index = sampleC(post, griddy_length);
//Rprintf("\nTake %i (%f)", index, griddy[index-1]);
return(griddy[index-1]);
}
}
