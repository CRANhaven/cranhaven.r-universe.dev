#include <math.h>

void WS2linear(double *phi1, double *phi2, double *weight, double *dose, double *Z, double *Y, int *doselength)
{

	double numerator = 0;
	double denominator = 0;
	int i;
	
	//linear_tilde = dose[i]
	
	for (i=0; i<doselength[0]; i++)
	{
		numerator += sqrt(weight[i])*((cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*dose[i])*Z[i]+sqrt(2)*sin(phi1[0])*cos(phi2[0])*Y[i]);
	}
	
	for (i=0; i<doselength[0]; i++)
	{
		denominator += weight[i]*(pow(cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*dose[i],2)+2*pow(sin(phi1[0])*cos(phi2[0]),2));
	}
	
	//result of the function
	phi1[0] = (-1)*numerator/sqrt(denominator);
}

void WS2emax(double *phi1, double *phi2, double *ed50, double *weight, double *dose, double *Z, double *Y, int *doselength)
{
	double numerator = 0;
	double denominator = 0;
	int i;
	
	//emax_tilde = (dose[i]/(ed50[0]+dose[i]));
	
	ed50[0] = fmax(ed50[0], 0.000000000000000001);
	
	for (i=0; i<doselength[0]; i++)
	{
		numerator += sqrt(weight[i])*((cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*(dose[i]/(ed50[0]+dose[i])))*Z[i]+sqrt(2)*sin(phi1[0])*cos(phi2[0])*Y[i]);
	}
	
	for (i=0; i<doselength[0]; i++)
	{
		denominator += weight[i]*(pow(cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*(dose[i]/(ed50[0]+dose[i])),2)+2*pow(sin(phi1[0])*cos(phi2[0]),2));
	}
	
	//result of the function
	phi1[0] = (-1)*numerator/sqrt(denominator);
}

void WS2exponential(double *phi1, double *phi2, double *delta, double *weight, double *dose, double *Z, double *Y, int *doselength)
{
	double numerator = 0;
	double denominator = 0;
	int i;
	
	//exponential_tilde = (exp(fmin(dose[i]/delta[0],350))-1);
	
	delta[0] = fmax(delta[0], 0.0015);
	
	for (i=0; i<doselength[0]; i++)
	{
		numerator += sqrt(weight[i])*((cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*(exp(fmin(dose[i]/delta[0],350))-1))*Z[i]+sqrt(2)*sin(phi1[0])*cos(phi2[0])*Y[i]);
	}
	
	for (i=0; i<doselength[0]; i++)
	{
		denominator += weight[i]*(pow(cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*(exp(fmin(dose[i]/delta[0],350))-1),2)+2*pow(sin(phi1[0])*cos(phi2[0]),2));
	}
	
	//result of the function
	phi1[0] = (-1)*numerator/sqrt(denominator);
}

void WS2linlog(double *phi1, double *phi2, double *off, double *weight, double *dose, double *Z, double *Y, int *doselength)
{

	double numerator = 0;
	double denominator = 0;
	int i;
	
	//linlog_tilde = log(dose[i]+off[0])
	
	for (i=0; i<doselength[0]; i++)
	{
		numerator += sqrt(weight[i])*((cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*log(dose[i]+off[0]))*Z[i]+sqrt(2)*sin(phi1[0])*cos(phi2[0])*Y[i]);
	}
	
	for (i=0; i<doselength[0]; i++)
	{
		denominator += weight[i]*(pow(cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*log(dose[i]+off[0]),2)+2*pow(sin(phi1[0])*cos(phi2[0]),2));
	}
	
	//result of the function
	phi1[0] = (-1)*numerator/sqrt(denominator);
}

void WS2sigEmax(double *phi1, double *phi2, double *ed50, double *h, double *weight, double *dose, double *Z, double *Y, int *doselength)
{
	double numerator = 0;
	double denominator = 0;
	int i;
	
	//sigEmax_tilde = (pow(dose[i], h[0])/fmax((pow(ed50[0], h[0]) + pow(dose[i], h[0])),0.000000000000000001));
	
	h[0] = fmax(h[0], 0);
	/* ed50[0] = fmax(ed50[0], 0.000000000000000001); */
	
	
	for (i=0; i<doselength[0]; i++)
	{
		numerator += sqrt(weight[i])*((cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*(pow(dose[i], h[0])/fmax((pow(ed50[0], h[0]) + pow(dose[i], h[0])),0.000000000000000001)))*Z[i]+sqrt(2)*sin(phi1[0])*cos(phi2[0])*Y[i]);
	}
	
	for (i=0; i<doselength[0]; i++)
	{
		denominator += weight[i]*(pow(cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*(pow(dose[i], h[0])/fmax((pow(ed50[0], h[0]) + pow(dose[i], h[0])),0.000000000000000001)),2)+2*pow(sin(phi1[0])*cos(phi2[0]),2));
	}
	
	//result of the function
	phi1[0] = (-1)*numerator/sqrt(denominator);
}

void WS2quadratic(double *phi1, double *phi2, double *b, double *weight, double *dose, double *Z, double *Y, int *doselength)
{
	double numerator = 0;
	double denominator = 0;
	int i;
	
	//quadratic_tilde = (dose[i] + b[0] * pow(dose[i], 2));
	
	for (i=0; i<doselength[0]; i++)
	{
		numerator += sqrt(weight[i])*((cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*(dose[i] + b[0] * pow(dose[i], 2)))*Z[i]+sqrt(2)*sin(phi1[0])*cos(phi2[0])*Y[i]);
	}
	
	for (i=0; i<doselength[0]; i++)
	{
		denominator += weight[i]*(pow(cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*(dose[i] + b[0] * pow(dose[i], 2)),2)+2*pow(sin(phi1[0])*cos(phi2[0]),2));
	}
	
	//result of the function
	phi1[0] = (-1)*numerator/sqrt(denominator);
}

void WS2betaMod(double *phi1, double *phi2, double *delta1, double *delta2, double *scal, double *weight, double *dose, double *Z, double *Y, int *doselength)
{
	double numerator = 0;
	double denominator = 0;
	int i;
	
	//betaMod_tilde = ( B * pow(dose[i] / scal[0], delta1[0]) * pow(1 - dose[i] / scal[0], delta2[0]));
	
	delta1[0] = fmax(delta1[0],0.000000000000000001);
	delta2[0] = fmax(delta2[0],0.000000000000000001);
	double B = pow(delta1[0] + delta2[0], delta1[0] + delta2[0])/(pow(delta1[0], delta1[0])*pow(delta2[0], delta2[0]));
	
	
	for (i=0; i<doselength[0]; i++)
	{
		numerator += sqrt(weight[i])*((cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*( B * pow(dose[i] / scal[0], delta1[0]) * pow(1 - dose[i] / scal[0], delta2[0])))*Z[i]+sqrt(2)*sin(phi1[0])*cos(phi2[0])*Y[i]);
	}
	
	for (i=0; i<doselength[0]; i++)
	{
		denominator += weight[i]*(pow(cos(phi1[0])*cos(phi2[0])+sin(phi2[0])*( B * pow(dose[i] / scal[0], delta1[0]) * pow(1 - dose[i] / scal[0], delta2[0])),2)+2*pow(sin(phi1[0])*cos(phi2[0]),2));
	}
	
	//result of the function
	phi1[0] = (-1)*numerator/sqrt(denominator);
}

void WS2logistic(double *phi1, double *phi2, double *ed50, double *delta, double *weight, double *dose, double *Z, double *Y, int *doselength)
{
	double numerator = 0;
	double denominator = 0;
	int i;
	
	//logistic_tilde = (1/(1 + exp((ed50[0] - dose[i])/delta[0])));
	
	delta[0] = fmax(delta[0],0.000000000000000001);
	
	
	for (i=0; i<doselength[0]; i++)
	{
		numerator += sqrt(weight[i])*((cos(phi1[0])*cos(phi2[0])+sin(phi2[0])* (1/(1 + exp((ed50[0] - dose[i])/delta[0]))) )*Z[i]+sqrt(2)*sin(phi1[0])*cos(phi2[0])*Y[i]);
	}
	
	for (i=0; i<doselength[0]; i++)
	{
		denominator += weight[i]*(pow(cos(phi1[0])*cos(phi2[0])+sin(phi2[0])* (1/(1 + exp((ed50[0] - dose[i])/delta[0]))) ,2)+2*pow(sin(phi1[0])*cos(phi2[0]),2));
	}
	
	//result of the function
	phi1[0] = (-1)*numerator/sqrt(denominator);
}
