/*-------------------------------------------------------------------------------
 Multiscale Bernstein polynomials [msBP]
 msBP.cpp - Set of C++ functions for msBP densities
 Version 0.1 of September 2013
 2013 - Antonio Canale (antonio.canale@unito.it)
-------------------------------------------------------------------------------*/
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<R.h>
#include<Rmath.h>
#include <algorithm>
#include "bintree.h"
int ceil(int a, int b) {return (a/b + (a % b !=0));}
extern "C++" {
// compute the weigths given a tree truncating after the maximum scale of S 
struct bintree *computeprob(struct bintree * Stree, struct bintree * Rtree, double a, double b, int maxS, int trunc)
{
struct bintree * tree = new struct bintree;
setTree(1.0, tree);
//struct bintree *tree = newtree(1);
writeNode(tree, extractNode(Stree, 0, 1,1), 0,1);
int maxH =1;
int s, h, r, g_shr;
int went_right;
double T_shr;
double I_S = 1;
for(s=1; s<=(maxS); s++)
{
	R_CheckUserInterrupt();
	maxH = std::pow(2.0, s);
	for(h=1; h<=maxH; h++)
	{
		I_S = 1;
		for(r=0; r<s; r++)
		{
			g_shr = ceil(h, (int) std::pow(2.0,s-r)); 	
			went_right = ((2*g_shr) == ceil(h, (int)std::pow(2.0,(s-r-1))) ); //as above
			if(went_right) T_shr = extractNode(Rtree, r, g_shr,0.5);
			else T_shr = 1 - extractNode(Rtree, r, g_shr, 0.5);
			I_S = I_S * (1 - extractNode(Stree, r, g_shr,1/(a+1)))*T_shr;
		}
		writeNode(tree, extractNode(Stree,s,h,1/(a+1))*I_S,s,h);
	}
}
	s = maxS + 1;
	maxH = std::pow(2.0, maxS + 1);
	GetRNGstate();
	for(h=1; h<=maxH; h++)
	{
		I_S = 1;
		for(r=0; r<s; r++)
		{
			g_shr = ceil(h, (int)std::pow(2.0,s-r));
			went_right = ((2*g_shr) == ceil(h, (int)std::pow(2.0,(s-r-1))) ); 
			if(went_right) T_shr = extractNode(Rtree, r, g_shr,0.5);
			else T_shr = 1 - extractNode(Rtree, r, g_shr, 0.5);
			I_S = I_S * (1 - extractNode(Stree, r, g_shr,1/(a+1)))*T_shr;
		}
		if(trunc) writeNode(tree, I_S, s, h);
		else writeNode(tree, rbeta(1,a)*I_S,s,h);
	}
	PutRNGstate();
	return tree;
}
//------------------------------------------------------------------------------
// compute the log-likelihood of the mixture model on a set of (non trasformed) data points
void likmsBP(struct bintree *weights, double * lik, double * g0_x, double * G0_x, int * n)
{
int maxS;
maxS = maxDepth(weights);
int maxH = 1;
int s, h, i;
double lik_i = 0.0;
lik[0] = 0;
for(i=0; i<n[0]; i++)
{
	lik_i = 0.0;
	for(s=0; s<=maxS; s++)
	{
		R_CheckUserInterrupt();
		maxH = (int) std::pow(2.0, s);
		for(h=1; h<=maxH; h++)
		{		
			lik_i = lik_i + extractNode(weights, s, h,0) * dbeta(G0_x[i], (double) h, (double) (maxH - h +1), 0);
		}
	}
	lik[0] = lik[0] +  log(lik_i) + log(g0_x[i]); 
}
}
//------------------------------------------------------------------------------
// compute the density of the mixture model on finite grid of points
void dmsBP(struct bintree *weights, double * out, double * grid, int * ngrid)
{
int maxS;
maxS = maxDepth(weights);
int maxH = 1;
int s, h, j;
for(j=0; j<ngrid[0]; j++) out[j] = 0;
for(s=0; s<=maxS; s++)
{
	R_CheckUserInterrupt();
	maxH = (int) std::pow(2.0, s);
	for(h=1; h<=maxH; h++)
	{
		for(j=0; j<ngrid[0]; j++)
		{
			out[j] = out[j] + extractNode(weights, s, h,0) * dbeta(grid[j], (double) h, (double) (maxH - h +1), 0);
		}
	}
}
}
//------------------------------------------------------------------------------
// compute the cdf of the mixture model on finite grid of points
void pmsBP(struct bintree *weights, double * out, double * grid, int * ngrid, int *log_p)
{
int maxS;
maxS = maxDepth(weights);
int maxH = 1;
int s, h, j;
for(j=0; j<ngrid[0]; j++) out[j] = 0;
for(s=0; s<=maxS; s++)
{
	R_CheckUserInterrupt();
	maxH = (int) std::pow(2.0, s);
	for(h=1; h<=maxH; h++)
	{
		for(j=0; j<ngrid[0]; j++)
		{
			out[j] = out[j] + extractNode(weights, s, h,0) * pbeta(grid[j], (double) h, (double) (maxH - h +1), 1, log_p[0]);
		}
	}
}
}
//------------------------------------------------------------------------------
// compute the marginal beta likelihood for all the dictionary densities for a given (scalar) y 
void marginalBeta(double * out, double y, int maxS)
{
int maxH = 1;
int s, h;
struct bintree * tree = new struct bintree;
setTree(1.0, tree);
//struct bintree *tree = newtree(1);
for(s=0; s<=maxS; s++)
{
	R_CheckUserInterrupt();
	maxH = (int) std::pow(2.0, s);
	for(h=1; h<=maxH; h++)
	{
		writeNode(tree, dbeta(y, (double) h, (double) (maxH - h +1), 0), s, h);
	}
}
tree2array(tree, out, maxS, 0.0);
deleteTree(tree);
}
//------------------------------------------------------------------------------
//compute a random S tree fixing S = 1 for all h of scale maxS
struct bintree *rStree (double a, int maxS)
{
int s=0;
int h=1;
int maxH;
struct bintree * tree = new struct bintree;
setTree(1.0, tree);
//struct bintree *tree = newtree(1);
GetRNGstate();
for(s=0; s<maxS; s++)
{
	R_CheckUserInterrupt();
	maxH = (int) std::pow(2.0, s);
	for(h=1; h<=maxH; h++)
	{
		writeNode(tree, rbeta(1,a), s,h);
	}
}
PutRNGstate();
maxH = (int) std::pow(2.0, maxS);
for(h=1; h<=maxH; h++) writeNode(tree, 1, s,h);
return tree;
}
//------------------------------------------------------------------------------
//compute a random R tree
struct bintree *rRtree (double b, int maxS)
{
int s=0;
int h=1;
int maxH;
struct bintree * tree = new struct bintree;
setTree(1.0, tree);
//struct bintree *tree = newtree(1);
GetRNGstate();
for(s=0; s<(maxS+1); s++)
{
	R_CheckUserInterrupt();
	maxH = (int) std::pow(2.0, s);
	for(h=1; h<=maxH; h++)
	{
		writeNode(tree, rbeta(b,b), s,h);
	}
}
PutRNGstate();
return tree;
}
//------------------------------------------------------------------------------
// random sample from a random msBP mixture density [Algorithm 1]
double rsample_msBP(struct bintree * Rtree, struct bintree * Stree, int a, int b)
{
	int stop = 0;
	int h = 1; 
	int s = 0;
	double u, y, S, R;
	GetRNGstate();
	while(!stop)
	{
		R_CheckUserInterrupt();
		S = extractNode(Stree, s, h, rbeta(1,a) );	
		u = runif(0,1);
		if(u<= (1-S)) stop = 0;
		else stop = 1;
		if(!stop)
		{
			R = extractNode(Rtree,s,h, rbeta(b,b) ); 
			u = runif(0,1);
			if(u<R) h =  2*h;
			else h = 2*h-1;
			s = s + 1;
		}
	}
	y = rbeta(h, (int) std::pow(2.0,s) - h + 1);
	PutRNGstate();
	return y;
}
//------------------------------------------------------------------------------
//create a tree with 1 in the node if it is on the path of node (si, hi)
struct bintree * path(struct bintree * tree, int si, int hi)
{
	if(tree == NULL)
	{
		tree = new struct bintree;
		setTree(1.0, tree);
		//tree = newtree(1);
	}
	tree->data = 1;
	if(si==0) return tree;
	else
	{
	    R_CheckUserInterrupt();
	    if(hi > std::pow(2.0, si-1))
		{
			int right_hi;
			right_hi = hi - (int) std::pow(2.0, si-1);
			tree->right = path(tree->right, si-1, right_hi);
		}
	    else
		tree->left  = path(tree->left,  si-1, hi);
	}
	return tree;
}
//------------------------------------------------------------------------------
//create a tree with 1 in the node if, in the path to node (si, hi), a right is taken
struct bintree * wentright(struct bintree * tree, int si, int hi)
{
	if(tree == NULL)
	{
		tree = new struct bintree;
		setTree(1.0, tree);
		//tree = newtree(1);
	}
	tree->data = 0;
	if(si==0) return tree;
	else
	{
	    if(hi > std::pow(2.0, si-1))
		{
			tree->data = 1;
			int right_hi;
			right_hi = hi - (int) std::pow(2.0, si-1);
			tree->right = wentright(tree->right, si-1, right_hi);
		}
	    else
		tree->left  = wentright(tree->left,  si-1, hi);
	}
	return tree;
}
//------------------------------------------------------------------------------
//create a tree with 1 in the node (si, hi) and zero elsewhere
struct bintree * whichnode(struct bintree * tree, int si, int hi)
{
	if(tree == NULL)
	{
		tree = new struct bintree;
		setTree(0, tree);
		//tree = newtree(0);
	}
	else tree->data =0;
	if(si==0)
	{
		tree->data = 1;
		return tree;
	}
	else
	{
	    if(hi > std::pow(2.0, si-1))
		{
			int right_hi;
			right_hi = hi - (int) std::pow(2.0, si-1);
			tree->right = whichnode(tree->right, si-1, right_hi);
		}
	    else
		tree->left  = whichnode(tree->left,  si-1, hi);
	}
	return tree;
}
//------------------------------------------------------------------------------
//create a tree with n_sh in the node (s, h) and zero elsewhere
void whichnode2(struct bintree * tree, int *s, int *h, int maxS, int N)
{
int maxH=1;
int sInd = 0;
int hInd = 1;
int j;
double clussize = 0;
for(sInd=0; sInd<=maxS; sInd++)
{
	maxH = (int) std::pow(2.0, sInd);
	for(hInd=1; hInd<=maxH; hInd++)
	{
		clussize = 0;
		for(j=0; j<N; j++)
			if(s[j] == sInd && h[j] == hInd) clussize += 1;
		writeNode(tree, clussize, sInd,hInd);
	}
}
}
//------------------------------------------------------------------------------
//create a tree with n_sh in the node (s, h) and zero elsewhere
void allTrees(int *s, int *h, int maxS, int N, struct bintree * n, struct bintree * r, struct bintree * v)
{
int maxH=1;
int sInd = 0;
int hInd = 1;
int j;
double node_n = 0;
double node_v = 0;
double node_r = 0;
int rel_s = 0;

for(sInd=0; sInd<=maxS; sInd++)
{

	maxH = (int) std::pow(2.0, sInd);
	for(hInd=1; hInd<=maxH; hInd++)
	{
		node_n = 0;
		node_r = 0;
		node_v = 0;
		for(j=0; j<N; j++)
		{
			if((s[j] == sInd) && (h[j] == hInd))
			{	
				node_n += 1;			
				node_v += 1;
			}
			rel_s = s[j] - sInd;
			if(rel_s > 0)
			{
				if( ceil( h[j], ( (int) std::pow(2.0,rel_s))) == hInd) node_v += 1;
				if( ceil( h[j], ( (int) std::pow(2.0,rel_s-1))) == 2*hInd) node_r += 1;
			}
		}	
		writeNode(n, node_n, sInd,hInd);
		writeNode(r, node_r, sInd,hInd);
		writeNode(v, node_v, sInd,hInd);
	}
}
}
//------------------------------------------------------------------------------
//sample a node from a probability tree
void sampleTree(struct bintree *p, int maxS, int *res)
{
	double rU;
	double cumprob = 0;
	rU = unif_rand();
	double mass = 0;
	int s, h;
	int maxH = 1;
	for (s = 0; s <= maxS; s++)
	{ 
		maxH = (int) std::pow(2.0, s);
		for (h = 1; h <= maxH; h++)
		{
			mass += extractNode(p, s, h, 0);
		}
	}
	for (s = 0; s <= maxS; s++)
	{ 
		maxH = (int) std::pow(2.0, s);
		for (h = 1; h <= maxH; h++)
		{
			cumprob += extractNode(p, s, h, 0)/mass;
		   	if (rU <= cumprob)
			{
				res[0] = s;
				res[1] = h;
				s = maxS+1;
				h = maxH+1;
			}
		}
	}
	return;
}
//------------------------------------------------------------------------------
//sample the labels 1:k with probability p 
int sampleC(double *p, int k)
{
	double rU;
	int j;
	double cumprob = 0;
	rU = unif_rand();
	double mass = 0;
	for (j = 0; j < k; j++) mass = mass + p[j];
	for (j = 0; j < k; j++) 
	{
	cumprob = cumprob + p[j]/mass;
	    if (rU <= cumprob)
		break;
	}
	return j+1;
}
//------------------------------------------------------------------------------
void scaleProb(struct bintree *pi, double *save, int maxS)
{	// get the scale probability to compare with the slice variable 

int s;
int h;
int maxH =1;

for(s=0; s<=maxS; s++)
{
	save[s] = 0;
	maxH = (int) std::pow(2.0, s);	
	for(h=1; h<=maxH; h++) 
		save[s] += extractNode(pi, s, h, 0);
}
}

}
