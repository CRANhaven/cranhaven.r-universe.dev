// Include the R headers
#include <R.h>
#include <Rinternals.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>
#include <Rmath.h>
#include <R_ext/Parse.h>

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#define ETA_TOLERANCE 1e-7
#define ETA_MAX_ITER 100
#define ETA_EPS 1e-7

/*--------------------------------------------------------------*/
static double expit ( double x)
{
    double out, expX;
	expX = exp(x);
    out = expX / (1.0+expX);
    return out;
}
/*--------------------------------------------------------------*/

// utility function to eval R functions
// NOTE: for information about how variable arguments work, look here:
//       http://www.gnu.org/software/libc/manual/html_node/Variadic-Functions.html
// parameters:
//    func  - the function name
//    env   - the environment you want the function to be called in
//            (most of the time this will probably be R_GlobalEnv)
//    nArgs - the number of arguments to the function
//    ...   - comma-seperated list of SEXP objects
SEXP evalR(const char *func, SEXP env, int nArgs, ...) {
    SEXP Rfunc, expr, retval, tail;
    va_list args;
    int i;

    // initialize variable-argument pointer
    va_start(args, nArgs);

    // this part finds the R object that the function lives in
    Rfunc = findFun(install(func), env);

    // set up an R function call
    PROTECT(expr = allocVector(LANGSXP, nArgs+1));
    SETCAR(expr, Rfunc);
    tail = CDR(expr);
    for(i = 1; i <= nArgs; i++) {
        SETCAR(tail, va_arg(args, SEXP));
        tail = CDR(tail);
    }

    // call the function
    retval = eval(expr, env);
    UNPROTECT(1);   // unprotects expr
    va_end(args);

    return retval;
}

// utility function to print an R object
void printR(SEXP obj) { evalR("print", R_GlobalEnv, 1, obj); }

// utility function to print C arrays as R vectors/matrices
void printMat(const double *array, int nrows, int ncols) {
    SEXP SEXP_tmp;
    int i;

    // assume that array is a regular vector if nrows == 1
    if (nrows == 1)
        PROTECT(SEXP_tmp = allocVector(REALSXP, ncols));
    else
        PROTECT(SEXP_tmp = allocMatrix(REALSXP, nrows, ncols));
    // populate the R object
    for(i = 0; i < nrows*ncols; i++) REAL(SEXP_tmp)[i] = array[i];

    // print it
    printR(SEXP_tmp);
    UNPROTECT(1);
}

//
// Using vectors eta, gamma and sigma, calculate delta using the convolution equation
// Here, gamma and sigma are vectors of length n and are Xgam %*% gam and Xsig %*% sig
//
SEXP DeconvolveGH_CALL(SEXP SEXP_eta,
                           SEXP SEXP_gamma,
                           SEXP SEXP_sigma,
                           SEXP SEXP_z,
                           SEXP SEXP_w){
//                           double offset ){
    double etai, gamma, sigma, z, w;
    int q_points = 0;
    int n, s, t;
    double deltai, dmuiddeltai, new_mui, delmu, mu;
    int j, count, eta_converge;
    double h_0, h_1, p_z;
    double *p_z_lag, p_z_lag_q;

    /*** Added for the change to .Call ***/
    double *S_eta, *S_gamma, *S_sigma, *S_z, *S_w;
    double *S_Delta_C;
    SEXP SEXP_Delta_C;

    PROTECT(SEXP_eta = coerceVector(SEXP_eta, REALSXP));
    S_eta = REAL(SEXP_eta);
    n     = LENGTH(SEXP_eta);

    PROTECT(SEXP_gamma = coerceVector(SEXP_gamma, REALSXP));
    S_gamma = REAL(SEXP_gamma);

    PROTECT(SEXP_sigma = coerceVector(SEXP_sigma, REALSXP));
    S_sigma = REAL(SEXP_sigma);

    PROTECT(SEXP_z = coerceVector(SEXP_z, REALSXP));
    S_z = REAL(SEXP_z);
    q_points = LENGTH(SEXP_z);

    PROTECT(SEXP_w = coerceVector(SEXP_w, REALSXP));
    S_w = REAL(SEXP_w);

    PROTECT(SEXP_Delta_C = allocVector(REALSXP,n));
    S_Delta_C = REAL(SEXP_Delta_C);

    p_z_lag = (double *)malloc((unsigned) (q_points)*sizeof(double));
    for(t=0; t<q_points; t++) *(p_z_lag+t) = 0.0;

    //printf("blah --------- %f ", offset);
    /*************************************/
    for (s=0; s<n; s++){

        gamma = *(S_gamma+s);
        sigma = *(S_sigma+s);
        etai  = *(S_eta+s);

        deltai = etai;
        mu     = expit(etai);

        eta_converge  = 0;
        count         = 0;

        do{

            dmuiddeltai = 0.0;
            new_mui = 0.0;

            for(j=0; j<q_points; j++){

                z          = *(S_z+j);
                w          = *(S_w+j);
                p_z_lag_q  = *(p_z_lag+j);

                h_0 = expit( deltai +         sigma*z );
                h_1 = expit( deltai + gamma + sigma*z );

                p_z = h_0 * (1.0-p_z_lag_q) + h_1 * p_z_lag_q;

                new_mui = new_mui + (w * p_z);

                dmuiddeltai = dmuiddeltai + (w * ( h_0 * (1-h_0) * (1.0-p_z_lag_q) +
                                                   h_1 * (1-h_1) * (    p_z_lag_q) ));
            }

            delmu = (new_mui - mu) / (dmuiddeltai+ETA_EPS);

            if (delmu< -0.5) delmu = -0.5;
            if (delmu>  0.5) delmu =  0.5;

            deltai= deltai - delmu;

            if( fabs(delmu) < ETA_TOLERANCE ) eta_converge=1;
            count++;

        } while(count<ETA_MAX_ITER && !eta_converge );
        *(S_Delta_C+s) = deltai;

        for(j=0; j<q_points; j++){
            z            = *(S_z+j);
            p_z_lag_q    = *(p_z_lag+j);
            *(p_z_lag+j) = (expit( deltai +         sigma*z) *(1.0-p_z_lag_q))+
                           (expit( deltai + gamma + sigma*z) *(    p_z_lag_q)) ;
        }

    }
    /*printf("%f", p_z_lag);*/
    free(p_z_lag);
    UNPROTECT(6);
    return SEXP_Delta_C;
}

/*---------------------------------------------------------------------------------------*/

//
// Calculate the partial derivative of delta with response to the parameter theta
// This also calculated the partial derivative of the partly conditional mdean w.r.t. theta
//
void dDeltadTheta( double *S_MuiPC_lag,
                   double *S_z,
                   double *S_w,
                   double *S_ddtheta_MuiPC_lag,
                   double *S_h0,
                   double *S_h1,
                   double ddtheta_MuiM,
                   double ddtheta_sig,
                   double ddtheta_gam,
                   int    q_points,
                   double *ret_ddtheta_Deltai,
                   double *ret_ddtheta_MuiPC_lag){

    double ddtheta_MuiPC_lag;
    double MuiPC_lag;
    double z, w;
    int s;
    double h0, h1, denoms, ddtheta_delta_num;
    double ddtheta_Delta;

    denoms=0;
    ddtheta_delta_num=0;

    for(s=0; s<q_points; s++){

        MuiPC_lag = *(S_MuiPC_lag+s);
        ddtheta_MuiPC_lag = *(S_ddtheta_MuiPC_lag+s);
        z = *(S_z+s);
        w = *(S_w+s);
        h0 = *(S_h0+s);
        h1 = *(S_h1+s);

        denoms = denoms + ((h0*(1.0-h0)*(1.0-MuiPC_lag) + h1*(1.0-h1)*MuiPC_lag)*w);

        ddtheta_delta_num = ddtheta_delta_num + (h1-h0) * ddtheta_MuiPC_lag * w +
                            h0 * (1.0-h0) * ddtheta_sig * z * (1.0-MuiPC_lag) * w +
                            h1 * (1.0-h1) * (ddtheta_gam + ddtheta_sig * z) * MuiPC_lag * w;
    }

    ddtheta_Delta    = (ddtheta_MuiM -  ddtheta_delta_num) / denoms;
    *ret_ddtheta_Deltai = ddtheta_Delta;

    for(s=0; s<q_points; s++){

        MuiPC_lag         = *(S_MuiPC_lag+s);
        ddtheta_MuiPC_lag = *(S_ddtheta_MuiPC_lag+s);
        z                 = *(S_z+s);
        w                 = *(S_w+s);
        h0                = *(S_h0+s);
        h1                = *(S_h1+s);
        *(ret_ddtheta_MuiPC_lag+s) =  ddtheta_Delta    * h0 * (1.0-h0) * (1.0-MuiPC_lag) +
                                      ddtheta_Delta    * h1 * (1.0-h1) * MuiPC_lag +
                                      ddtheta_sig * z  * h0 * (1.0-h0) * (1.0-MuiPC_lag) +
                                      ddtheta_gam      * h1 * (1.0-h1) * MuiPC_lag +
                                      ddtheta_sig * z  * h1 * (1.0-h1) * MuiPC_lag +
                                      (h1-h0)*ddtheta_MuiPC_lag;
    }
}

//
// Calculate the log likelihood contibution by subject i as well as the partial derivative with
// respect to the parameter theta
//

void LogLScoreTheta( double *S_Delta,
                     double *S_Yij,
                     double *S_Yij_1,
                     double *S_gamma,
                     double *S_sigma,
                     double *S_ddtheta_delta,
                     double *S_ddtheta_gamma,
                     double *S_ddtheta_sigma,
                     double *S_z,
                     double *S_w,
                     int     q_points,
                     int     n,
                     double *ret_dli1_dtheta,
                     double *ret_li1){
    double Delta, Yij, Yij_1, gamma, sigma, ddtheta_delta, ddtheta_gamma, ddtheta_sigma, z, w;
    int s, j;//, g;
    double Li, Li_temp, lp_c, MuC, dLi_dtheta, Y_MuC_dALL;

    Li         = 0;
    dLi_dtheta = 0;

    for(s=0; s<q_points; s++){
        Li_temp    = 0;
        Y_MuC_dALL = 0;

        z = *(S_z+s);
        w = *(S_w+s);

        for(j=0; j<n; j++){

            gamma   = *(S_gamma+j);
            sigma   = *(S_sigma+j);

            Delta   = *(S_Delta+j);
            Yij     = *(S_Yij+j);
            Yij_1   = *(S_Yij_1+j);

            ddtheta_delta = *(S_ddtheta_delta+j);
            ddtheta_gamma = *(S_ddtheta_gamma+j);
            ddtheta_sigma = *(S_ddtheta_sigma+j);

			      lp_c     =  Delta + gamma*Yij_1 + sigma*z;
            Li_temp += ( Yij * lp_c - log( 1.0 + exp( lp_c) ) );

            MuC         = expit(lp_c);
            Y_MuC_dALL += (Yij-MuC)*(ddtheta_delta + ddtheta_gamma*Yij_1 + ddtheta_sigma*z  );
        }
        Li         += exp(Li_temp)*w;
        dLi_dtheta += exp(Li_temp)*Y_MuC_dALL*w;
    }
    *ret_dli1_dtheta = dLi_dtheta / Li;
    *ret_li1         = log(Li);
}

/*------------------------------------------------------------------------------------*/
SEXP LogLScoreCalc_CALL( SEXP SEXP_betaM,
                         SEXP SEXP_gamma,
                         SEXP SEXP_sigma,
                         SEXP SEXP_subjectData,
                         SEXP SEXP_EmpiricalCheeseCalc,
                         SEXP SEXP_Q,
                         SEXP SEXP_W,
                         SEXP SEXP_Z,
                         SEXP SEXP_AdaptiveQuad ){

    // grab pointers from SEXP objects
    double *sigma     = REAL(SEXP_sigma);    // For gradient calculations
    double *Z         = REAL(SEXP_Z);
    double *W         = REAL(SEXP_W);

    int EmpiricalCheeseCalc = LOGICAL(SEXP_EmpiricalCheeseCalc)[0];
    int Q                   = (int)REAL(SEXP_Q)[0];

    // counting variables and such
    int i, j, k, l, f, e;   // for loops
    int p, p_gam, p_sig, p_ALL, ni;
    int NumSubj = length(SEXP_subjectData);

    // pointers to SEXP data
    double *Xi, *Xi_gam, *Xi_sig, *etai, *Yi, *Yilag,  *GAM,  *SIG, *Weighti, *Offset;

    // SEXP variables needed
    SEXP SEXP_subject, SEXP_etai, SEXP_Deltai,
         SEXP_Xi, SEXP_Xi_gam, SEXP_Xi_sig, SEXP_Yi, SEXP_Yilag, SEXP_GAM, SEXP_SIG, SEXP_Weighti,
         SEXP_Offset, SEXP_etaitmp;

    p     = length(SEXP_betaM);
    p_gam = length(SEXP_gamma);
    p_sig = length(SEXP_sigma);
    p_ALL = p + p_gam + p_sig;

    //double li[NumSubj], Li[NumSubj], ACi[NumSubj];
    double li[NumSubj], Li[NumSubj];
    for(i = 0; i < NumSubj; i++) { li[i] = 0;
                                   Li[i] = 0;
    }
							       //ACi[i]= 0; }

    double ddtheta_loglikei[p_ALL*NumSubj];
    double MuiPC_z_lagged[Q], ddtheta_MuiPC_z_lagged[p_ALL*Q], h0[Q], h1[Q];

    // Subject specific calculations

    for(i = 0; i < NumSubj; i++) {
        // This loop iterates over each "row" in SEXP_subjectData.  SEXP_subjectData is
        // a list where each subject has their own "row", which has personal X, Y, and
        // Ylag data.  SEXP_subjectData is a VECSXP of length NumSubj.  The first element
        // in it is the subject id, which is a STRSXP.  Next is X, which is a REALSXP
        // matrix.  Then Y and Ylag, which are both INTSXP's.  The id 'column' in the list
        // is ignored in this loop, as it's just for identification purposes.

        SEXP_subject = VECTOR_ELT(SEXP_subjectData, i);
        SEXP_Xi      = VECTOR_ELT(SEXP_subject, 1);
        Xi           = REAL(SEXP_Xi);
        SEXP_Yi      = VECTOR_ELT(SEXP_subject, 2);
        Yi           = REAL(SEXP_Yi);
        SEXP_Yilag   = VECTOR_ELT(SEXP_subject, 3);
        Yilag        = REAL(SEXP_Yilag);
        SEXP_Xi_gam  = VECTOR_ELT(SEXP_subject, 4);
        Xi_gam       = REAL(SEXP_Xi_gam);
        SEXP_Xi_sig  = VECTOR_ELT(SEXP_subject, 5);
        Xi_sig       = REAL(SEXP_Xi_sig);
        SEXP_Weighti = VECTOR_ELT(SEXP_subject, 6);
        Weighti      = REAL(SEXP_Weighti);
        SEXP_Offset    = VECTOR_ELT(SEXP_subject, 7);
        Offset         = REAL(SEXP_Offset);

        ni = length(VECTOR_ELT(SEXP_subject, 2));

        for(l = 0; l < Q; l++) MuiPC_z_lagged[l] = 0.0;
        for(l = 0; l < p_ALL*Q; l++) ddtheta_MuiPC_z_lagged[l] = 0.0;

        // To get etai, the easiest way is to eval R code to do it
		    PROTECT(SEXP_etaitmp = evalR("%*%", R_GlobalEnv, 2, SEXP_Xi, SEXP_betaM));
		    PROTECT(SEXP_etai =  evalR("+", R_GlobalEnv, 2, SEXP_etaitmp, SEXP_Offset));
        etai = REAL(SEXP_etai);

        PROTECT(SEXP_GAM = evalR("%*%", R_GlobalEnv, 2, SEXP_Xi_gam, SEXP_gamma));
        GAM = REAL(SEXP_GAM);

        PROTECT(SEXP_SIG = evalR("%*%", R_GlobalEnv, 2, SEXP_Xi_sig, SEXP_sigma));
        SIG = REAL(SEXP_SIG);

        // CALCULATE DELTA

        double *Deltai;
        SEXP_Deltai = DeconvolveGH_CALL(SEXP_etai, SEXP_GAM, SEXP_SIG, SEXP_Z, SEXP_W);
        UNPROTECT(2); // unprotects SEXP_GAM and SEXP_SIG
        PROTECT(SEXP_Deltai);
        Deltai = REAL(SEXP_Deltai);

        // Initialized and calculate the 'n_i by p_all matrix' of partial derivatives of the marginal mean w.r.t.
        // the parameters

        double dmuimdtheta[p_ALL*ni];
        for(j = 0; j < p_ALL*ni; j++) dmuimdtheta[j] = 0;

        double MuiM;
        for(j = 0; j < p; j++) {
            for(k = 0; k < ni; k++) {  MuiM                     = expit(etai[k]);
                                       dmuimdtheta[k*p_ALL + j] = MuiM * (1-MuiM) * Xi[k + j*ni];
            }
        }

        // Calculate the partial derivates of the GAMMA and SIGMA components with respect to each of the parameter
        // in the parameter vector.  Note that for all parameters in betaM, this value will be 0.  Simiilarly
        // dGAMdTHETA=0 if theta = a parameter in SIGMA and dSIGdTHETA=0 if theta = a parameter in GAMMA.
        // Notice here that dGAMdTHETA is X_gam %*% dgamdtheta where dgamdtheta has components that are all partial
        // derivative w.r.t. the parameter theta.  Same goes for dSIGdTHETA

        int tmp1, tmp2, tmp3;

        tmp1 = ni*p;
        tmp2 = ni*(p+p_gam);
        tmp3 = ni*(p+p_gam+p_sig);

        double *dSIGdTHETA, *dGAMdTHETA;

        dGAMdTHETA     = (double *)malloc(sizeof(double) * ni * p_ALL);
        dSIGdTHETA     = (double *)malloc(sizeof(double) * ni * p_ALL);

        for(j = 0;    j < tmp1; j++){    dGAMdTHETA[j] = 0;              dSIGdTHETA[j] = 0;}
        for(j = tmp1; j < tmp2; j++){    dGAMdTHETA[j] = Xi_gam[j-tmp1]; dSIGdTHETA[j] = 0;}
        for(j = tmp2; j < tmp3; j++){    dGAMdTHETA[j] = 0;              dSIGdTHETA[j] = Xi_sig[j-tmp2];}

        // Initialize the 'n_i by p_all matrix' of partial derivative of delta with respect to each of the parameters

        double ddtheta_Deltai[p_ALL*ni];
        for(j = 0; j < p_ALL*ni; j++) ddtheta_Deltai[j] = NA_REAL;

        // Calculate partial derivatives of delta w.r.t. all parameters adn for all timepoints
        // This calculation relies on the value of the partial derivative of \mu_{i, j-1}^{pc,z}
        // w.r.t. each parameter.  This must all be done sequentially as follows.  Note, WE ARE
        // DEALING WITH PARTIAL DERIVATIVES HERE!!!
        // \mu_{i, 0}^{pc,z} -> \Delta_{i1} -> \mu_{i, 1}^{pc,z} ->  \Delta_{i2}-> \mu_{i, 2}^{pc,z} ... -> \Delta_{in_i}

        for(j = 0; j < ni; j++) {
            for(k = 0; k < Q; k++) { h0[k] = expit(Deltai[j]          + SIG[j] * Z[k]);
                                     h1[k] = expit(Deltai[j] + GAM[j] + SIG[j] * Z[k]);
            }
            double tmp_lag[Q];

            for(f = 0; f < p_ALL; f++) {

                for(l = 0; l < Q; l++) tmp_lag[l] = ddtheta_MuiPC_z_lagged[l*p_ALL + f];
                // In R, Xi_sig and Xi_gam are cbind(1, X) (e.g. 2 by n_i).  When conversion in C
                // occurs this gets converted to an array which is column major, so in this array,
                // we only want the n_i +1 to 2*n_i elements.
                dDeltadTheta(MuiPC_z_lagged, Z, W, tmp_lag, h0, h1, dmuimdtheta[j*p_ALL + f],
                             dSIGdTHETA[f*ni + j], dGAMdTHETA[f*ni + j],
                             Q, &ddtheta_Deltai[j*p_ALL + f], tmp_lag);

                // put tmp_lag back into row f of ddtheta_MuiPC_z_lagged
                for(l = 0; l < Q; l++) ddtheta_MuiPC_z_lagged[l*p_ALL + f] = tmp_lag[l];
            }

            for(l = 0; l < Q; l++)  MuiPC_z_lagged[l] = h0[l]*(1-MuiPC_z_lagged[l]) + h1[l]*MuiPC_z_lagged[l];

        }

        // likelihood contribution by subject i and partial derivatives w.r.t. all parameters */

        double Muijc_z[ni*Q], lp_c[ni*Q], Lijc_z[ni*Q], YminMu[ni*Q], Li_C[Q];
        for (l = 0; l < Q; l++)    Li_C[l]    = NA_REAL;
        for (l = 0; l < ni*Q; l++) Muijc_z[l] = lp_c[l] = Lijc_z[l] = YminMu[l] = NA_REAL;

        double dli1_dtheta[p_ALL];
        double li1;

        for(e = 0; e < p_ALL; e++) {

            double ddtheta_deltai_tmp[ni], ddtheta_gamma_tmp[ni], ddtheta_sigma_tmp[ni];
            for(l = 0; l < ni; l++) { ddtheta_deltai_tmp[l] = ddtheta_Deltai[l*p_ALL + e];
                                      ddtheta_gamma_tmp[l]  = dGAMdTHETA[e*ni + l];
                                      ddtheta_sigma_tmp[l]  = dSIGdTHETA[e*ni + l];
            }


            li1 = 0;

            // Calculate log likelihood and score
            LogLScoreTheta(Deltai, Yi, Yilag, GAM, SIG,
                           ddtheta_deltai_tmp, ddtheta_gamma_tmp, ddtheta_sigma_tmp, Z, W,
                           Q, length(SEXP_Deltai), &dli1_dtheta[e], &li1);

        }
        //printf("Samps ===== %f ========= %f% =========== %f ----- \n", SampProbi[0], li2, li1);

	      li[i] = li1 * Weighti[0];

        for(e = 0; e < p_ALL; e++) {
          ddtheta_loglikei[i*p_ALL + e] = dli1_dtheta[e]*Weighti[0];
        }
        free(dGAMdTHETA);
        free(dSIGdTHETA);
        UNPROTECT(3);// clean up free(dsigdtheta); free(dgamdtheta); free(dsig_moddtheta); free(dgam_moddtheta);
    }

    // END OF SUBJECT SPECIFIC CALCULATIONS

    SEXP SEXP_retval, SEXP_temp_retval;
    double *temp_retval, tmp_sum; //*retval,
    if (!EmpiricalCheeseCalc) {

        // Calculate and print the gradient

        PROTECT(SEXP_retval = allocVector(REALSXP, 1));
        tmp_sum = 0;

        for(i = 0; i < NumSubj; i++) tmp_sum += li[i];
        REAL(SEXP_retval)[0] = tmp_sum * -1;

        double ddtheta_llikei[p_ALL];
        for(e = 0; e < p_ALL; e++) {

            tmp_sum = 0;
            for(i = 0; i < NumSubj; i++) tmp_sum += ddtheta_loglikei[i*p_ALL + e];
            ddtheta_llikei[e] = -1*tmp_sum;

        }

        // Gradient Calculation
        SEXP SEXP_Gradient;
        double *Gradient;

        PROTECT(SEXP_Gradient = allocVector(REALSXP, p_ALL));
        Gradient              = REAL(SEXP_Gradient);

        for(i = 0; i < (p+p_gam); i++)   Gradient[i] = ddtheta_llikei[i];
        for(i = p+p_gam; i < p_ALL; i++) Gradient[i] = sigma[i-(p+p_gam)]*ddtheta_llikei[i];

        setAttrib(SEXP_retval, install("gradient"), SEXP_Gradient);
        UNPROTECT(1);   // unprotect SEXP_Gradient


        SEXP SEXP_LogLikeI;
        double *LogLikeI;

        PROTECT(SEXP_LogLikeI = allocVector(REALSXP, NumSubj));
        LogLikeI              = REAL(SEXP_LogLikeI);

        for(i = 0; i < (NumSubj); i++)   LogLikeI[i] = li[i];

        setAttrib(SEXP_retval, install("LogLikeSubj"), SEXP_LogLikeI);
        UNPROTECT(1);   // unprotect SEXP_LogLikeI

        //SEXP SEXP_ACSubj;
        //double *ACSubj;

        //PROTECT(SEXP_ACSubj = allocVector(REALSXP, NumSubj));
        //ACSubj              = REAL(SEXP_ACSubj);

        //for(i = 0; i < (NumSubj); i++)   ACSubj[i] = ACi[i];

        //setAttrib(SEXP_retval, install("ACSubj"), SEXP_ACSubj);
        //UNPROTECT(1);   // unprotect SEXP_ACSubj

        SEXP SEXP_ddtheta_loglikei;
        double *out_ddtheta_loglikei;

        PROTECT(SEXP_ddtheta_loglikei = allocVector(REALSXP, p_ALL*NumSubj));
        out_ddtheta_loglikei          = REAL(SEXP_ddtheta_loglikei);

        for(e = 0; e < p_ALL; e++) {
            for(i = 0; i < NumSubj; i++) out_ddtheta_loglikei[i*p_ALL + e] = ddtheta_loglikei[i*p_ALL + e];
        }

        setAttrib(SEXP_retval, install("ddtheta_loglikei"), SEXP_ddtheta_loglikei);
        UNPROTECT(1);
    }
    else {  // EmpiricalCheeseCalc == TRUE

        // CHEESE PART OF Empirical covariance
        double SigmaRows[p_sig*NumSubj];
        for(i = 0; i < p_sig; i++) {

            for(j = 0; j < NumSubj; j++) {
                SigmaRows[j*p_sig + i] = sigma[i] * ddtheta_loglikei[j*p_ALL + p + p_gam + i]; }
        }

        PROTECT(SEXP_temp_retval = allocMatrix( REALSXP, p_ALL, NumSubj ));
        temp_retval = REAL(SEXP_temp_retval);

        for(i = 0; i < (p+p_gam); i++){
            for(j = 0; j < NumSubj; j++) temp_retval[j*p_ALL + i] = ddtheta_loglikei[j*p_ALL + i];
        }

        for(i = p+p_gam, k = 0; i < p_ALL; i++, k++) {
            for(j = 0; j < NumSubj; j++) { temp_retval[j*p_ALL + i] = SigmaRows[j*p_sig + k];}
        }

        SEXP_retval = evalR("tcrossprod", R_GlobalEnv, 2, SEXP_temp_retval, SEXP_temp_retval);
        UNPROTECT(1);   // unprotects SEXP_temp_retval
        PROTECT(SEXP_retval);
    }
    UNPROTECT(1);   // unprotects SEXP_retval
    return SEXP_retval;
}

/*----------------------------------------------------------------------------*/

#define ENTRY(name, n)  { #name, (DL_FUNC) &name, n }

static R_CallMethodDef callMethods[] = { ENTRY(DeconvolveGH_CALL,6),
                                         ENTRY(LogLScoreCalc_CALL,11),
                                         {NULL,NULL,0}
};

void R_init_MTLVM(DllInfo *dll){ R_useDynamicSymbols(dll, FALSE);
                                 R_registerRoutines(dll,NULL,callMethods,NULL,NULL);
}
