/*
CRM program for running in R, modified from CRM.c. Final version used in CRM package
This program doesn't depend on GSL functions.  
Program for Continual Reassessment Method: A practical Design for phase 1 clinical trials
in cancer (o'Quigley, Pepe and Fisher,Biometrics 46, 33-48, March 1990)

Two models are implemented:

model 1 (hyperbolic tangent)
        p(dose) = ((tanh(dose)+1)/2)^a, where a is the parameter

model 2 (one-parameter logistic)
       p(dose)= exp(b+a*dose)/(1+exp(b+a*dose)),
       where b is a constant (the default value should be set to b=3), and
       a is the parameter.

In both models, the parameter a is updated based on one-patients cohorts. 

Author: Quincy Mo(qianxing.mo@moffitt.org),Department of Biostatistics & Bioinformatics, H. Lee Moffitt Cancer Center
August, 2007

Last update: 11/29/08 this code is used in CRM R packageversion 1.0

*/

#include <R.h>
#include <stdio.h>
#include <math.h>
#include <R_ext/Applic.h>

#define probtanh(a,x) (exp(a*log((tanh(x)+1)/2)))
#define problogistic(a,b,x) (exp(b+a*(x))/(1+exp(b+a*(x))))

typedef struct mypar MYPAR;
struct mypar {int size; double *x; double *y; double b;};

/*hyperbolic tangent model */
void md1Getdose(int size, double* dose, double* prob, double md1a0) {
  int i;
  double temp;
  for(i=0;i<size;i++){
    temp = log(prob[i])/md1a0;
    temp = exp(temp);
    dose[i] = atanh(2*temp-1);
  }      
}

/* one parameter logistic regression model */
void md2Getdose(int size, double* dose, double* prob,double md2b0,double md2a0){
  int i;
  for(i=0;i<size;i++){
    dose[i] = (log(prob[i]/(1-prob[i]))-md2b0)/md2a0;
  } 
}

/* hyperbolic tangent model */
double hypertan (double a, void * par) {
  MYPAR * xy = (MYPAR *) par;
  double prob,like;
  int i;
  like = 1.0;
  for(i=0; i < xy->size; i++) {
    prob = probtanh(a,xy->x[i]);
    like = like*pow(prob,xy->y[i])*pow((1-prob),1-xy->y[i]);
  }
  return exp(-a)*like;
}

static void hyperintfn(double *x, int n, void *par){
  int i;
  for(i=0; i<n; i++){
    x[i] = hypertan(x[i],par);
  }
}

double muhypertan (double a, void * par) {
  MYPAR * xy = (MYPAR *) par;
  double prob,like;
  int i;
  like = 1.0;
  for(i=0; i < xy->size; i++) {
    prob = probtanh(a,xy->x[i]);
    like = like*pow(prob,xy->y[i])*pow((1-prob),1-xy->y[i]);
  }
  return a*exp(-a)*like;
}

static void muhyperintfn(double *x, int n, void *par){
  int i;
  for(i=0; i<n; i++){
    x[i] = muhypertan(x[i],par);
  }
}

/* one parameter logistic regression model */
double logistic (double a, void * par) {
  MYPAR * xy = (MYPAR *) par;
  double prob,like;
  int i;
  like = 1.0;
  for(i=0; i < xy->size; i++){
    prob = problogistic(a,xy->b,xy->x[i]);
    like = like*pow(prob,xy->y[i])*pow((1-prob),1-xy->y[i]);
  }
  return exp(-1.0*a)*like;
}

static void logisticintfn(double *x, int n, void *par){
  int i;
  for(i=0; i<n; i++){
    x[i] = logistic(x[i],par);
  }
}

double mulogistic (double a, void * par) {
  MYPAR * xy = (MYPAR *) par;
  double prob,like;
  int i;
  like = 1.0;
  for(i=0; i < xy->size; i++){
    prob = problogistic(a,xy->b,xy->x[i]); 
    like = like*pow(prob,xy->y[i])*pow((1-prob),1-xy->y[i]);
  }
  return a*exp(-1.0*a)*like;
}

static void mulogisticintfn(double *x, int n, void *par){
  int i;
  for(i=0; i<n; i++){
    x[i] = mulogistic(x[i],par);
  }
}

void checkErr(int istrue, char * mess) {
  if(istrue == 1) {
    Rprintf("Error: %s\n", mess);
    error("Exit due to error\n"); 
  }
}

/*
model 1: p(dose) = ((tanh(dose)+1)/2)^a
model 2: p(dose)= exp(b+a*dose)/(1+exp(b+a*dose))
*/

/* index is next dose level */
void CRM(int *model,double *tarToxiRate,double* priorProb,int *probSize, double *a0,double *b0,int * ptData,int *rowSize,int * index,double * amean) {
  MYPAR par;  
  double *delta,*dose,*work,denom,numer,errmesg,lowbound,epsabs,epsrel,small;
  int **patientData,*iwork,i,j,smallID,neval,ier,limit,lenw,last,inf;
  lowbound = 0;
  epsabs = 0;
  epsrel = 1e-7;
  inf = 1;
  limit = 1000;
  lenw = 4*limit;
  iwork = (int *) R_alloc(limit,sizeof(int));
  work = (double *) R_alloc(lenw,sizeof(double));
  
  checkErr((*model != 1) && (*model != 2), "*Model must be 1 or 2.");
  checkErr(priorProb==NULL, "Prior Probabilities were not initialized!");
  checkErr(ptData==NULL, "Historical Data were not initialized!");

  delta = (double *)malloc((*probSize)*sizeof(double));
  dose = (double *)malloc((*probSize)*sizeof(double));
  patientData = (int **)malloc((*rowSize)*sizeof(int *));
  checkErr((delta==NULL)||(dose==NULL)||(patientData==NULL), "Failed to allocate memory!");

  for(i=0;i<*rowSize;i++){
    patientData[i] = (int *)malloc(2*sizeof(int));
    checkErr(patientData[i]==NULL, "Failed to allocate memory!");
  }

  for(i=0;i<*rowSize;i++){ 
    patientData[i][0] = ptData[i];
    patientData[i][1] = ptData[(*rowSize)+i];
    /*   printf("%d %d \n",ptData[i], ptData[(*rowSize)+1]); */
  }

  par.size = *rowSize; /* *rowSize is the number of patients */
  par.b = *b0;
  par.x = (double *)calloc(par.size, sizeof(double));
  par.y = (double *)calloc(par.size, sizeof(double));
  checkErr((par.x==NULL)||(par.y==NULL), "Failed to allocate memory!");
  
  if(*model == 1) {
    md1Getdose(*probSize,dose,priorProb,*a0); /* calculate the normalized dose */
    /* this for loop can not be outside the if statement since it uses dose */
    for(i=0;i<par.size;i++){
      par.x[i] = dose[patientData[i][0] - 1]; /* dose[n-1] corresponds to dose level n */
      par.y[i] = patientData[i][1];
    } 
    Rdqagi(hyperintfn,&par,&lowbound,&inf,&epsabs,&epsrel,&denom,&errmesg,&neval,&ier,&limit,&lenw,&last,iwork,work);
    Rdqagi(muhyperintfn,&par,&lowbound,&inf,&epsabs,&epsrel,&numer,&errmesg,&neval,&ier,&limit,&lenw,&last,iwork,work);
    *amean = numer/denom;
    for(j=0;j<*probSize;j++){
      delta[j] = fabs(*tarToxiRate - probtanh(*amean,dose[j])); 
    }
    small = delta[0];
    smallID = 0;
    for(j=1; j<*probSize; j++){
      if(small > delta[j]){
	small = delta[j];
	smallID = j;
      }
    }
    *index = smallID + 1;  /* next dose level = index + 1 */
  } else if(*model == 2) {
    md2Getdose(*probSize,dose,priorProb,*b0,*a0);
    for(i=0;i<par.size;i++){
      par.x[i] = dose[patientData[i][0] - 1]; /*  dose[n-1] corresponds to dose level n */
      par.y[i] = patientData[i][1];
    }
    Rdqagi(logisticintfn,&par,&lowbound,&inf,&epsabs,&epsrel,&denom,&errmesg,&neval,&ier,&limit,&lenw,&last,iwork,work);
    Rdqagi(mulogisticintfn,&par,&lowbound,&inf,&epsabs,&epsrel,&numer,&errmesg,&neval,&ier,&limit,&lenw,&last,iwork,work);
    *amean = numer/denom;
    for(j=0;j<*probSize;j++){
      delta[j] = fabs(*tarToxiRate - problogistic(*amean, *b0, dose[j])); 
    }
    small = delta[0];
    smallID = 0;
    for(j=1; j<*probSize; j++){
      if(small > delta[j]){
	small = delta[j];
	smallID = j;
      }
    }
    *index = smallID + 1; /* next dose level = index + 1 */
  } else {
    error("Error: model must be 1 or 2. \n");
    /*    exit(1); */
  }
  free(delta);
  free(dose);
  free(par.x);
  free(par.y);
  for(i=0;i<*rowSize;i++){
    free(patientData[i]);
  }
  free(patientData);
}




