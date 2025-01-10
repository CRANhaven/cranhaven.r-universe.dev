/*-------------------------------------------------------------------------------
 Multiscale Bernstein polynomials [msBP]
 bintree.cpp - Auxiliary C++ functions to deal with binary tree structures
 Version 0.1 of September 2013
 2013 - Antonio Canale (antonio.canale@unito.it)
-------------------------------------------------------------------------------*/
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<R.h>
#include "bintree.h"
extern "C++" {
//------------------------------------------------------------------------------
//create a new (empty) tree
struct bintree *newtree(double data) 
{
	struct bintree *node = new struct bintree;
	node->data =  data;
	node->left = NULL;
	node->right = NULL;
	return node;
}
//------------------------------------------------------------------------------
void setTree(double data, struct bintree *node){
node->data = data;
node->left = NULL;
node->right = NULL;
}
//------------------------------------------------------------------------------
//write at scale s and node h of a tree the value x 
struct bintree* writeNode(struct bintree *tree, double x, int s, int h)
{
	if(tree == NULL)
	{
//		tree = newtree(0);
		tree = new struct bintree;
		setTree(0, tree);
	}
	if(s == 0){
		tree->data = x;
		return tree;
	}
	else {
	double s_, h_;
	s_ = (double) s;
	h_ = (double) h;
	double condition;
	condition = h_/pow(2.0, s_); 
	int right_h;
	right_h = h - pow(2.0, s-1);
	    if(condition > 0.5)
		tree->right = writeNode(tree->right, x, s-1, right_h);
	    else
		tree->left  = writeNode(tree->left,  x, s-1, h);
	}
	return tree;
}
//------------------------------------------------------------------------------
// extract from a tree the number located at scale s and node h
double extractNode(struct bintree *tree, int s, int h, double ifempty)
{
	double s_, h_;
	s_ = (double) s;
	h_ = (double) h;
	if(tree == NULL)
	{
//		tree = newtree(ifempty);
		tree = new struct bintree;
		setTree(ifempty, tree);
	}
	if(s == 0) {return tree->data;}
	else {
	double condition;
	condition = h_/pow(2.0, s_);
	int right_h;
	right_h = h - pow(2.0, s-1);
	    if(condition > 0.5)
		return extractNode(tree->right, s-1, right_h, ifempty);
	    else
		return extractNode(tree->left,  s-1, h, ifempty);
	}
}
//------------------------------------------------------------------------------
//convert a tree structure into an array
void tree2array(struct bintree *node, double *array, int maxScale, double ifempty){ 
	int s = 0;
	int h = 1;
	int ind = 0;
	int max = maxScale+1;
	for(s=0; s<max; s++)
	{
		for(h=1; h<pow(2.0,s)+1; h++)
		{
			array[ind] = extractNode(node, s, h, ifempty);
			ind = ind + 1;
		}
	}
	return;
}
//------------------------------------------------------------------------------
//convert an array into a binary tree struct
void array2tree(double *a, int maxScale, struct bintree *node)
{
	int s = 0;
	int h = 1;
	int ind = 0;
	for(s=0; s<maxScale+1; s++)
	{
		for(h=1; h<pow(2.0,s)+1; h++)
		{
			writeNode(node, a[ind], s, h);
			ind = ind + 1;
		}
	}
	return;
}
//------------------------------------------------------------------------------
//print a tree up to scale S
void printTree(struct bintree *node, int maxS){ 
	int s = 0;
	int h = 1;
	for(s=0; s<(maxS+1); s++)
	{
		Rprintf("S=%i - ", s);
		for(h=1; h<pow(2.0,s)+1; h++)
		{
			Rprintf("%f ", extractNode(node, s, h, 0));
		}
		Rprintf("\n");
	}
	return;
}
//------------------------------------------------------------------------------
//compute the maximum depth of a binary tree
int maxDepth(struct bintree *node)
{
	if(node == NULL || (node->left == NULL && node->right == NULL)) 
            return 0;

	int leftDepth = maxDepth(node->left);
	int rightDepth = maxDepth(node->right);

	return leftDepth > rightDepth ? 
				leftDepth + 1 : rightDepth + 1;
}
//------------------------------------------------------------------------------
//clear a tree
void clearTree(struct bintree *node)
{
	if(node != NULL) {
	    node->data = 0;
	    clearTree(node->left);
	    clearTree(node->right);
\
	}
}
//------------------------------------------------------------------------------
//delete tree
void deleteTree(struct bintree *node)
{
	if(node != NULL) {
	    deleteTree(node->left);
	    deleteTree(node->right);
	    delete node;
	}
}
}
