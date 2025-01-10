/*-------------------------------------------------------------------------------
 Multiscale Bernstein polynomials [msBP]
 gibbs.cpp - Gibbs sampling code for msBP density estimation
 Version 1.0 of April 2016
 2014 - 2016 Antonio Canale (antonio.canale@unito.it)
-------------------------------------------------------------------------------*/
#include<R.h>
#include<Rmath.h>
#include "bintree.h"
#include "msBP.h"
#include "auxGibbs.h"
//------------------------------------------------------------------------------
extern "C"{
void msBPgibbs(
	double *x,				//original data
	double *y, 				//transformed data
	double *par, 			//paramters
	int *sClus, 			//starting values for the scale labels (n-size vector)
	int *hClus,				//starting values for the node labels (n-size vector) 
	double *Rstart, 		//starting values for the R tree
	double *Sstart, 		//starting values for the S tree
	double * wstart, 		//starting values for the tree of weights
	int *hyperpriors, 		//three logical paramters if hyperpriors are assumed
	int *nrep, 				//number of MCMC iterations
	int *nb, 				//number of burn in iterations
	int *aux, 				//auxiliary paramters (see comments below)
	int *printing, 			//auxiliary parameters for standard output printing
	double *grid, 			//grid for density
	int *ngrid, 			//length of grid
	double *griddy, 		//grid for posterior evaluation of b is b is random (griddy gibbs)
	int *griddy_length,		//length of griddy
	double *postDens, 		//density value on a grid
	double *postScale, 		//sum of the weighs in each scale 
	double *postS, 			//tree3vec of posterior stopping probs S
	double *postR, 			//tree3vec of posterior righ-descending probs R			
	double *postPi, 		//tree3vec of posterior weights
	double *postA, 			//vector of random a if hyperprior 
	double *postB, 			//vector of random b if hyperprior 
	int *posts, 			//vec(matrix) of scale labels for each subject through the MCMC
	int *posth, 			//vec(matrix) of node labels for each subject through the MCMC
	double *mu, 			//vector for the random mu (if base is normal and random hyperpar)	
	double *sigma2			//vector for the random sigma2 (if base is normal and random hyperpar)
		)			
{
	int i, j, s, h;
	int N = aux[0];  // 1st element of the auxiliary parameters is the dimension n
	int MAXS = aux[1];  // 2nd element of the auxiliary parameters is the maximum depth allowed
	int MAXVEC = aux[2];  // 3rd element of the auxiliary parameters is length of vector induced by MAXS
	int maxSstart = aux[3];  // 4th element of the auxiliary parameters is scale of starting trees
	int maxS = maxSstart;
	int maxH = 1;
	int flag = 0;
	double a, b;
	a = par[0];
	b = par[1];
	double delta, gamma, lambda, beta;
	beta = par[2];
	gamma = par[3];
	delta = par[4];
	lambda = par[5];
	double nsh, rsh, vsh;
	int every = printing[0];
	int printclustering = printing[1];
	double intoR = 0.5;
	double intoS = 0;
	double log1_S = 0;
	int *ZERO;
	ZERO = ( int* ) R_alloc(1, sizeof(int));
	ZERO[0] = 0;

	//bunch of allocations if centering measure with random paramters
	double likstar = 0.0;  // devo trasformare in puntatori listar e likold
	double likold = 0.0; 
	double mustar = 0.0;
	double tau2star = 1.0;
	double mu0, kappa0, alpha0, beta0;
	mu0 = par[6];
	kappa0 = par[7];
	alpha0 = par[8];
	beta0 = par[9];
	double * g0_x_old, * G0_x_old, * g0_x_star, * G0_x_star;
	g0_x_old = ( double* ) R_alloc(N, sizeof(double));
	G0_x_old = ( double* ) R_alloc(N, sizeof(double));
	g0_x_star = ( double* ) R_alloc(N, sizeof(double));
	G0_x_star = ( double* ) R_alloc(N, sizeof(double));
	double mhprob = 1.0;
	double rU = 1.0;
	double * grid_new;
	grid_new = ( double* ) R_alloc(ngrid[0], sizeof(double));
	std::memcpy(&(grid_new[0]), &(grid[0]), ngrid[0] * sizeof(double));

	//we start from trees of depth 4 (arbitrary choice)
//	struct bintree *S = newtree(1); //rStree(a, 4);
//	struct bintree *R = newtree(0.5); //rRtree(b, 4);
//	struct bintree *w = newtree(1); //computeprob(S, R, a, b, 4, 0);
	struct bintree *S = new struct bintree; //rStree(a, 4);
	struct bintree *R = new struct bintree; //rRtree(b, 4);
	struct bintree *w = new struct bintree; //computeprob(S, R, a, b, 4, 0);
	setTree(1.0, S);
	setTree(0.5, R);
	setTree(1.0, w);
	array2tree(Sstart, maxSstart, S);
	array2tree(Rstart, maxSstart, R);
	array2tree(wstart, maxSstart, w);

//	struct bintree *n = newtree(0);
//	struct bintree *r = newtree(0);
//	struct bintree *v = newtree(0);
	struct bintree *n = new struct bintree;
	struct bintree *r = new struct bintree;
	struct bintree *v = new struct bintree;
	setTree(0, n);
	setTree(0, r);
	setTree(0, v);
	auxiliaryTrees(sClus, hClus, N, n, r, v);

	GetRNGstate();
	for(i=1; i<nrep[0]; i++)
	{
		if(((i-1) % every) == 0) flag = 1;
		else flag = 0;
		if(flag)  Rprintf("Iteration %i over %i \n",i-1,nrep[0]);
  		R_CheckUserInterrupt();
		// from version 1.2 new gibbs sampling step for the parameters of g0
		if(hyperpriors[2])
		{
			likstar = 0.0;
			likold = 0.0; 
			//proposal
			tau2star = rgamma(alpha0, 1/beta0);
			mustar = rnorm(mu0, kappa0/tau2star);
			//transform the data
			for(j=0; j<N; j++)
			{
				g0_x_old[j] = dnorm(x[j], mu[i-1], sqrt(sigma2[i-1]), 0 );
				G0_x_old[j] = pnorm(x[j], mu[i-1], sqrt(sigma2[i-1]), 1, 0 );
				g0_x_star[j] = dnorm(x[j], mustar, 1/sqrt(tau2star), 0 );
				G0_x_star[j] = pnorm(x[j], mustar, 1/sqrt(tau2star), 1, 0 );
			}
			//compute the posterior ratio for MH acceptance probability
			likmsBP(w, &(likstar), g0_x_star, G0_x_star, &(N));
			likmsBP(w, &(likold),  g0_x_old,  G0_x_old,  &(N));
			mhprob = exp(likstar-likold);
			if(mhprob>1)
			{
				mu[i] = mustar;
				sigma2[i] = 1/tau2star;
				std::memcpy(&(y[0]), &(G0_x_star[0]), N * sizeof(double));
				for(j=0; j<ngrid[0]; j++)
				{
					grid_new[j] = pnorm(grid[j], mu[i], sqrt(sigma2[i]), 1, 0);
				}
				//Rprintf("proposal accepted deterministically\n");
				
			}
			else
			{
				rU = unif_rand();
				if(mhprob>rU)
				{
					mu[i] = mustar;
					sigma2[i] = 1/tau2star;
					std::memcpy(&(y[0]), &(G0_x_star[0]), N * sizeof(double));
					for(j=0; j<ngrid[0]; j++)
					{
						grid_new[j] = pnorm(grid[j], mustar, 1/sqrt(tau2star), 1, 0);
					}
					//Rprintf("proposal accepted after sampling\n");
				}
				else
				{
					mu[i] = mu[i-1];
					sigma2[i] = sigma2[i-1];
					std::memcpy(&(y[0]), &(G0_x_old[0]), N * sizeof(double));					
					//Rprintf("kept the past\n");	
				}
			}	
		}		
		
		postCluster(sClus, hClus, y, w, maxS+1, N, printclustering); 
		clearTree(n);
		clearTree(r);
		clearTree(v);
		allTrees(sClus, hClus, maxS, N, n, r, v);
		maxS = 0;
		for(j=0; j<N; j++) maxS = (int) fmax(maxS, sClus[j]);
		maxS = fmin(maxS, MAXS);

		clearTree(S);
		clearTree(R);
		clearTree(w);
		log1_S = 0;
		for(s=0; s<=maxS; s++)
		{
			maxH = (int) std::pow(2.0, s);		
			for(h=1; h<=maxH; h++)
			{
				vsh = (double) extractNode(v, s, h, 0);
				if(vsh!=0)
				{
				nsh = (double) extractNode(n, s, h, 0);
				rsh = (double) extractNode(r, s, h, 0);
				}
				else
				{
				nsh = 0; rsh = 0;	
				}
				intoS = rbeta(1 + nsh, postA[i-1] + vsh - nsh);
				intoR = rbeta(postB[i-1] + rsh, postB[i-1] + vsh - nsh - rsh);
				if(s==0)
				{
					writeNode(S, 0, s, h);
				}
				else 
				{
					writeNode(S, intoS, s, h);
					log1_S += log(1 - intoS);
				}
				writeNode(R, intoR, s, h);

			}
		}
		if(hyperpriors[0])
		{
			postA[i] = rgamma(beta+std::pow(2.0,maxS+1)-1, 1/(gamma - log1_S));
			if(ISNAN(postA[i]) || (postA[i]<=0)) 
			{
				//Rprintf("NA! or 0 at ite %i\n", i+1);
				postA[i] = rgamma(beta, 1/gamma);
			}
		}
		if(hyperpriors[1])
		{
			//Rprintf("The grid of griddy b has length %i\n", griddy_length[0]);
			postB[i] = griddy_B(delta, lambda, R, maxS, griddy, griddy_length[0]);
			if(ISNAN(postB[i]) || (postB[i]<=griddy[0]) || (postB[i]>=griddy[griddy_length[0]-1])) 
			{
				//Rprintf("NA! or out of range (%f, %f) at ite %i\n", i+1, griddy[0], griddy[griddy_length[0]-1]);
				postB[i] = postB[i-1];//rgamma(delta, 1/lambda);
			}
		}

		//compute probability tree
		w = computeprob(S, R, a, b, maxS, 0);
		//store posterior quantities
		if(i >= nb[0]) 
		{
			scaleProb(w, &(postScale[(MAXS+1)*(i-1)]), MAXS);
			//vec version of S
			tree2array(S, &(postS[(i)*MAXVEC]), MAXS, 0);
			tree2array(R, &(postR[(i)*MAXVEC]), MAXS, 0);
			tree2array(computeprob(S, R, postA[i], postB[i], maxS, 1), &(postPi[(i)*MAXVEC]), MAXS, 0);
			std::memcpy(&(posts[(i)*N]), &(sClus[0]), N*sizeof(int));
			std::memcpy(&(posth[(i)*N]), &(hClus[0]), N*sizeof(int));
			dmsBP(computeprob(S, R, postA[i], postB[i], maxS, 1), &postDens[ngrid[0]*(i)], grid_new, ngrid);
			if(hyperpriors[2])
			{
				for(j=0; j<ngrid[0]; j++)
				{
					postDens[ngrid[0] * i + j] = dnorm(grid[j], mu[i], sqrt(sigma2[i]), 0) * postDens[ngrid[0]*(i) + j];
				}
			}
		}
	}
	deleteTree(S);
	deleteTree(R);
	deleteTree(w);
	deleteTree(n);
	deleteTree(r);
	deleteTree(v);
	PutRNGstate();
}

//------------------------------------------------------------------------------
}
