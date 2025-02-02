#' Complex Linear Model
#'
#' Function estimates complex variables model
#'
#' This is a function, similar to \link[stats]{lm}, but supporting several estimation
#' techniques for complex variables regression.
#'
#' @template author
#' @template keywords
#' @template references
#'
#' @param formula an object of class "formula" (or one that can be coerced to
#' that class): a symbolic description of the model to be fitted. Can also include
#' \code{trend}, which would add the global trend.
#' @param data a data frame or a matrix, containing the variables in the model.
#' @param subset an optional vector specifying a subset of observations to be
#' used in the fitting process.
#' @param na.action	a function which indicates what should happen when the
#' data contain NAs. The default is set by the na.action setting of
#' \link[base]{options}, and is \link[stats]{na.fail} if that is unset. The
#' factory-fresh default is \link[stats]{na.omit}. Another possible value
#' is NULL, no action. Value \link[stats]{na.exclude} can be useful.
#' @param loss The type of Loss Function used in optimization. \code{loss} can
#' be:
#' \itemize{
#' \item \code{OLS} - Ordinary Least Squares method, relying on the minimisation of
#' the conjoint variance of the error term;
#' \item \code{CLS} - Complex Least Squares method, relying on the minimisation of
#' the complex variance of the error term;
#' \item \code{likelihood} - the model is estimated via the maximisation of the
#' likelihood of the complex Normal distribution;
#' \item \code{MSE} (Mean Squared Error),
#' \item \code{MAE} (Mean Absolute Error),
#' \item \code{HAM} (Half Absolute Moment),
#' }
#'
#' A user can also provide their own function here as well, making sure
#' that it accepts parameters \code{actual}, \code{fitted} and \code{B}. Here is an
#' example:
#'
#' \code{lossFunction <- function(actual, fitted, B, xreg) return(mean(abs(actual-fitted)))}
#' \code{loss=lossFunction}
#'
#' @param orders vector of orders of complex ARIMA(p,d,q).
#' @param scaling NOT YET IMPLEMENTED!!! Defines what type of scaling to do for the variables.
#' See \link[complex]{cscale} for the explanation of the options.
#' @param parameters vector of parameters of the linear model. When \code{NULL}, it
#' is estimated.
#' @param fast if \code{TRUE}, then the function won't check whether
#' the data has variability and whether the regressors are correlated. Might
#' cause trouble, especially in cases of multicollinearity.
#' @param ... additional parameters to pass to distribution functions. This
#' includes:
#' \itemize{
#' \item \code{FI=TRUE} will make the function also produce Fisher Information
#' matrix, which then can be used to calculated variances of smoothing parameters
#' and initial states of the model. This is used in the \link[stats]{vcov} method;
#' }
#'
#' You can also pass parameters to the optimiser:
#' \enumerate{
#' \item \code{B} - the vector of starting values of parameters for the optimiser,
#' should correspond to the explanatory variables. If formula for scale was provided,
#' the parameters for that part should follow the parameters for location;
#' \item \code{algorithm} - the algorithm to use in optimisation
#' (\code{"NLOPT_LN_SBPLX"} by default);
#' \item \code{maxeval} - maximum number of evaluations to carry out. Default is 40 per
#' estimated parameter. In case of LASSO / RIDGE the default is 80 per estimated parameter;
#' \item \code{maxtime} - stop, when the optimisation time (in seconds) exceeds this;
#' \item \code{xtol_rel} - the precision of the optimiser (the default is 1E-6);
#' \item \code{xtol_abs} - the absolute precision of the optimiser (the default is 1E-8);
#' \item \code{ftol_rel} - the stopping criterion in case of the relative change in the loss
#' function (the default is 1E-4);
#' \item \code{ftol_abs} - the stopping criterion in case of the absolute change in the loss
#' function (the default is 0 - not used);
#' \item \code{print_level} - the level of output for the optimiser (0 by default).
#' If equal to 41, then the detailed results of the optimisation are returned.
#' }
#' You can read more about these parameters by running the function
#' \link[nloptr]{nloptr.print.options}.
#'
#' @return Function returns \code{model} - the final model of the class
#' "clm", which contains:
#' \itemize{
#' \item coefficients - estimated parameters of the model,
#' \item FI - Fisher Information of parameters of the model. Returned only when \code{FI=TRUE},
#' \item fitted - fitted values,
#' \item residuals - residuals of the model,
#' \item mu - the estimated location parameter of the distribution,
#' \item scale - the estimated scale parameter of the distribution. If a formula was provided for
#' scale, then an object of class "scale" will be returned.
#' \item logLik - log-likelihood of the model. Only returned, when \code{loss="likelihood"}
#' and in a special case of complex least squares.
#' \item loss - the type of the loss function used in the estimation,
#' \item lossFunction - the loss function, if the custom is provided by the user,
#' \item lossValue - the value of the loss function,
#' \item df.residual - number of degrees of freedom of the residuals of the model,
#' \item df - number of degrees of freedom of the model,
#' \item call - how the model was called,
#' \item rank - rank of the model,
#' \item data - data used for the model construction,
#' \item terms - terms of the data. Needed for some additional methods to work,
#' \item B - the value of the optimised parameters. Typically, this is a duplicate of coefficients,
#' \item other - the list of all the other parameters either passed to the
#' function or estimated in the process, but not included in the standard output
#' (e.g. \code{alpha} for Asymmetric Laplace),
#' \item timeElapsed - the time elapsed for the estimation of the model.
#' }
#'
#' @seealso \code{\link[greybox]{alm}}
#'
#' @examples
#'
#' ### An example with mtcars data and factors
#' x <- complex(real=rnorm(1000,10,10), imaginary=rnorm(1000,10,10))
#' a0 <- 10 + 15i
#' a1 <- 2-1.5i
#' y <- a0 + a1 * x + 1.5*complex(real=rnorm(length(x),0,1), imaginary=rnorm(length(x),0,1))
#'
#' complexData <- cbind(y=y,x=x)
#' complexModel <- clm(y~x, complexData)
#' summary(complexModel)
#'
#' plot(complexModel, 7)
#'
#' @importFrom nloptr nloptr
#' @importFrom stats model.frame sd terms model.matrix update.formula as.formula
#' @importFrom stats formula residuals sigma rnorm
#' @importFrom graphics abline lines par points
#' @importFrom stats AIC BIC contrasts<- deltat fitted frequency start time ts
#' @importFrom greybox AICc BICc measures
#' @importFrom pracma hessian
#' @importFrom utils tail
#' @import legion
#' @rdname clm
#' @export clm
clm <- function(formula, data, subset, na.action,
                loss=c("likelihood","OLS","CLS","MSE","MAE","HAM"),
                orders=c(0,0,0), scaling=c("normalisation","standardisation","max","none"),
                parameters=NULL, fast=FALSE, ...){
    # Start measuring the time of calculations
    startTime <- Sys.time();

    # Create substitute and remove the original data
    dataSubstitute <- substitute(data);

    cl <- match.call();
    # This is needed in order to have a reasonable formula saved, so that there are no issues with it
    cl$formula <- eval(cl$formula);
    if(is.function(loss)){
        lossFunction <- loss;
        loss <- "custom";
    }
    else{
        lossFunction <- NULL;
        loss <- match.arg(loss);
    }

    scaling <- match.arg(scaling);

    #### Functions used in the estimation ####
    ifelseFast <- function(condition, yes, no){
        if(condition){
            return(yes);
        }
        else{
            return(no);
        }
    }

    # Function that calculates mean. Works faster than mean()
    meanFast <- function(x){
        return(sum(x) / length(x));
    }

    fitterRecursive <- function(y, B, matrixXreg){

        maIndex <- maOrder;
        # Initialise MA part of the model
        # matrixXreg[c(1:maIndex),nVariablesExo+arOrder+iOrder+1:maIndex] <- 0;
        for(i in 1:obsInsample){
            maIndex[] <- min(maOrder, obsInsample-i);
            # Produce one-step-ahead fitted
            mu[i] <- matrixXreg[i,] %*% B;
            if(maIndex>0){
                # Add the residuals to the matrix
                matrixXreg[cbind(i+c(1:maIndex),nVariablesExo+arOrder+iOrder+1:maIndex)] <- rep(y[i]-mu[i], maIndex);
            }
        }

        return(list(mu=mu,matrixXreg=matrixXreg));
    }

    # Basic fitter for non-dynamic models
    fitter <- function(B, y, matrixXreg){

        # If the vector B is not complex then it is estimated in nloptr. Make it complex
        if(!is.complex(B)){
            nVariables <- length(B);
            B <- complex(real=B[1:(nVariables/2)],imaginary=B[(nVariables/2+1):nVariables]);
        }

        # If there is ARIMA, then calculate polynomials
        if(arimaModel){
            if(maOrder>0){
                BMA <- tail(B, maOrder);
            }
            else{
                BMA <- NULL;
            }

            if(arOrder>0){
                poly1[-1] <- -B[nVariablesExo+1:arOrder];
            }

            # This condition is needed for cases of pure ARI models
            if(nVariablesExo>0){
                B <- c(B[1:nVariablesExo], -polyprodcomplex(poly2,poly1)[-1], BMA);
            }
            else{
                B <- -c(polyprodcomplex(poly2,poly1)[-1], BMA);
            }
        }

        if(maOrder>0){
            recursiveFit <- fitterRecursive(y, B, matrixXreg);
            mu[] <- recursiveFit$mu;
            matrixXreg[] <- recursiveFit$matrixXreg;
        }
        else{
            mu[] <- matrixXreg %*% B
        }

        # Get the scale value
        if(loss=="CLS"){
            scale <- sqrt(sum((y-mu)^2)/obsInsample)
        }
        else if(loss=="OLS"){
            scale <- Re(sqrt(sum(Conj((y-mu))*(y-mu))/obsInsample));
        }
        else if(loss=="likelihood"){
            errors <- complex2vec(y-mu);
            scale <- t(errors) %*% errors / obsInsample;
        }

        return(list(mu=mu, scale=scale, matrixXreg=matrixXreg));
    }

    ### Fitted values in the scale of the original variable
    extractorFitted <- function(mu, scale){
        return(mu);
    }

    ### Error term in the transformed scale
    extractorResiduals <- function(mu, yFitted){
        return(y - mu);
    }

    CF <- function(B, loss, y, matrixXreg){
        fitterReturn <- fitter(B, y, matrixXreg);

        if(loss=="likelihood"){
            # # Concentrated logLik
            CFValue <- obsInsample*(log(2*pi) + 1 + 0.5*log(det(fitterReturn$scale)));

            # Another options that give the same result
            # CFValue <- obsInsample*(log(2*pi) + 0.5*log(det(sigmaMat))) +
            #     0.5*sum(diag(errors %*% Re(invert(sigmaMat)) %*% t(errors)));
            ### Likelihood using dcnorm
            # errors <- y - fitterReturn$mu;
            # sigma2 <- mean(errors * Conj(errors));
            # varsigma2 <- mean(errors^2);
            # CFValue <- -sum(dcnorm(errors, mu=0, sigma2=sigma2, varsigma2=varsigma2, log=TRUE));
            ### Likelihood using MVNorm
            # CFValue <- -sum(dmvnorm(errors, mean=c(0,0), sigma=sigmaMat, log=TRUE));
        }
        else if(loss=="CLS"){
            CFValue <- sum((y - fitterReturn$mu)^2);
        }
        else if(loss=="OLS"){
            CFValue <- sum(abs(y - fitterReturn$mu)^2);
        }
        else{
            yFitted[] <- extractorFitted(fitterReturn$mu, fitterReturn$scale);

            if(loss=="MSE"){
                CFValue <- meanFast((y-yFitted)^2);
            }
            else if(loss=="MAE"){
                CFValue <- meanFast(abs(y-yFitted));
            }
            else if(loss=="HAM"){
                CFValue <- meanFast(sqrt(abs(y-yFitted)));
            }
            else if(loss=="custom"){
                CFValue <- lossFunction(actual=y,fitted=yFitted,B=B,xreg=matrixXreg);
            }
        }

        if(is.nan(CFValue) || is.na(CFValue) || is.infinite(CFValue)){
            CFValue[] <- 1E+300;
        }

        return(CFValue);
    }

    estimator <- function(B, print_level){
        print_level_hidden <- print_level;
        if(print_level==41){
            print_level[] <- 0;
        }

        #### Define what to do with the maxeval ####
        if(is.null(ellipsis$maxeval)){
            maxeval <- nVariables * 40;
        }
        else{
            maxeval <- ellipsis$maxeval;
        }

        # Retransform the vector of parameters into a real-valued one
        BReal <- c(Re(B),Im(B));
        nVariables <- length(BReal);

        # Although this is not needed in case of distribution="dnorm", we do that in a way, for the code consistency purposes
        res <- nloptr(BReal, CF,
                      opts=list(algorithm=algorithm, xtol_rel=xtol_rel, maxeval=maxeval, print_level=print_level,
                                maxtime=maxtime, xtol_abs=xtol_abs, ftol_rel=ftol_rel, ftol_abs=ftol_abs),
                      # lb=BLower, ub=BUpper,
                      loss=loss, y=y, matrixXreg=matrixXreg);
        BReal[] <- res$solution;
        B[] <- complex(real=BReal[1:(nVariables/2)],imaginary=BReal[(nVariables/2+1):nVariables]);
        nVariables <- length(B);
        CFValue <- res$objective;

        if(print_level_hidden>0){
            print(res);
        }

        return(list(B=B, CFValue=CFValue));
    }

    #### Define the rest of parameters ####
    ellipsis <- list(...);
    # ellipsis <- match.call(expand.dots = FALSE)$`...`;

    # Fisher Information
    if(is.null(ellipsis$FI)){
        FI <- FALSE;
    }
    else{
        FI <- ellipsis$FI;
    }

    # Starting values for the optimiser
    if(is.null(ellipsis$B)){
        B <- NULL;
    }
    else{
        B <- ellipsis$B;
    }
    # Parameters for the nloptr from the ellipsis
    if(is.null(ellipsis$xtol_rel)){
        xtol_rel <- 1E-6;
    }
    else{
        xtol_rel <- ellipsis$xtol_rel;
    }
    if(is.null(ellipsis$algorithm)){
        # if(recursiveModel){
        # algorithm <- "NLOPT_LN_BOBYQA";
        # }
        # else{
        algorithm <- "NLOPT_LN_SBPLX";
        # }
    }
    else{
        algorithm <- ellipsis$algorithm;
    }
    if(is.null(ellipsis$maxtime)){
        maxtime <- -1;
    }
    else{
        maxtime <- ellipsis$maxtime;
    }
    if(is.null(ellipsis$xtol_abs)){
        xtol_abs <- 1E-8;
    }
    else{
        xtol_abs <- ellipsis$xtol_abs;
    }
    if(is.null(ellipsis$ftol_rel)){
        ftol_rel <- 1E-4;
    }
    else{
        ftol_rel <- ellipsis$ftol_rel;
    }
    if(is.null(ellipsis$ftol_abs)){
        ftol_abs <- 0;
    }
    else{
        ftol_abs <- ellipsis$ftol_abs;
    }
    if(is.null(ellipsis$print_level)){
        print_level <- 0;
    }
    else{
        print_level <- ellipsis$print_level;
    }
    if(is.null(ellipsis$stepSize)){
        stepSize <- .Machine$double.eps^(1/4);
    }
    else{
        stepSize <- ellipsis$stepSize;
    }

    #### Form the necessary matrices -- needs to be rewritten for complex variables ####
    # Call similar to lm in order to form appropriate data.frame
    mf <- match.call(expand.dots = FALSE);
    m <- match(c("formula", "data", "subset", "na.action"), names(mf), 0L);
    mf <- mf[c(1L, m)];
    mf$drop.unused.levels <- TRUE;
    mf[[1L]] <- quote(stats::model.frame);

    # If data is provided explicitly, check it
    if(exists("data",inherits=FALSE,mode="numeric") || exists("data",inherits=FALSE,mode="complex") ||
       exists("data",inherits=FALSE,mode="list")){
        if(!is.data.frame(data)){
            data <- as.data.frame(data);
        }
        else{
            dataOrders <- unlist(lapply(data,is.ordered));
            # If there is an ordered factor, remove the bloody ordering!
            if(any(dataOrders)){
                data[dataOrders] <- lapply(data[dataOrders],function(x) factor(x, levels=levels(x), ordered=FALSE));
            }
        }
        mf$data <- data;
        rm(data);

        # If there are NaN values, remove the respective observations
        if(any(sapply(mf$data,is.nan))){
            warning("There are NaN values in the data. This might cause problems. Removing these observations.", call.=FALSE);
            NonNaNValues <- !apply(sapply(mf$data,is.nan),1,any);
            # If subset was not provided, change it
            if(is.null(mf$subset)){
                mf$subset <- NonNaNValues
            }
            else{
                mf$subset <- NonNaNValues & mf$subset;
            }
            dataContainsNaNs <- TRUE;
        }
        else{
            dataContainsNaNs <- FALSE;
        }

        # If there are spaces in names, give a warning
        if(any(grepl("[^A-Za-z0-9,;._-]", all.vars(formula))) ||
           # If the names only contain numbers
           any(suppressWarnings(!is.na(as.numeric(all.vars(formula)))))){
            warning("The names of your variables contain special characters ",
                    "(such as numbers, spaces, comas, brackets etc). clm() might not work properly. ",
                    "It is recommended to use `make.names()` function to fix the names of variables.",
                    call.=FALSE);
            formula <- as.formula(paste0(gsub(paste0("`",all.vars(formula)[1],"`"),
                                              make.names(all.vars(formula)[1]),
                                              all.vars(formula)[1]),"~",
                                         paste0(mapply(gsub, paste0("`",all.vars(formula)[-1],"`"),
                                                       make.names(all.vars(formula)[-1]),
                                                       labels(terms(formula))),
                                                collapse="+")));
            mf$formula <- formula;
        }
        # Fix names of variables. Switch this off to avoid conflicts between formula and data, when numbers are used
        colnames(mf$data) <- make.names(colnames(mf$data), unique=TRUE);

        # If the data is a matrix / data.frame, get the nrows
        if(!is.null(dim(mf$data))){
            obsAll <- nrow(mf$data);
        }
        else{
            obsAll <- length(mf$data);
        }

        # If the user asked for trend, but it's not in the data, add it
        if(any(all.vars(formula)=="trend") && all(colnames(mf$data)!="trend")){
            mf$data <- cbind(mf$data,trend=c(1:obsAll));
        }
    }
    else{
        dataContainsNaNs <- FALSE;
    }

    responseName <- all.vars(formula)[1];

    dataWork <- eval(mf, parent.frame());

    #### Temporary solution for model.matrix() ####
    if(is.data.frame(dataWork)){
        complexVariables <- sapply(dataWork, is.complex);
    }
    else{
        complexVariables <- apply(dataWork, 2, is.complex);
    }
    complexVariablesNames <- names(complexVariables)[complexVariables];
    complexVariablesNames <- complexVariablesNames[complexVariablesNames!=responseName];
    # Save the original data to come back to it
    originalData <- dataWork;
    dataWork[,complexVariables] <- sapply(dataWork[,complexVariables], Re);

    dataTerms <- terms(dataWork);
    cl$formula <- formula(dataTerms);

    interceptIsNeeded <- attr(dataTerms,"intercept")!=0;
    # Create a model from the provided stuff. This way we can work with factors
    dataWork <- model.matrix(dataWork, data=dataWork);
    # And this small function will do all necessary transformations of complex variables
    dataWorkComplex <- cmodel.matrix(originalData, data=originalData);
    #### FIX: Get interraction effects and substitute non-zeroes with the correct values ####
    complexVariablesNamesUsed <- complexVariablesNames[complexVariablesNames %in% colnames(dataWork)];
    dataWork[,complexVariablesNamesUsed] <- as.matrix(dataWorkComplex[,complexVariablesNamesUsed]);
    y <- dataWorkComplex[,1];
    obsInsample <- nrow(dataWork);

    # matrixXreg should not contain 1 for the further checks
    if(interceptIsNeeded){
        variablesNames <- colnames(dataWork)[-1];
        matrixXreg <- as.matrix(dataWork[,-1,drop=FALSE]);
    }
    else{
        variablesNames <- colnames(dataWork);
        matrixXreg <- dataWork;
        warning("You have asked not to include intercept in the model. We will try to fit the model, ",
                "but this is a very naughty thing to do, and we cannot guarantee that it will work...", call.=FALSE);
    }
    rm(dataWork, originalData);

    nVariables <- length(variablesNames);
    colnames(matrixXreg) <- variablesNames;

    # Record the subset used in the model
    if(is.null(mf$subset)){
        subset <- rep(TRUE, obsInsample);
    }
    else{
        if(dataContainsNaNs){
            subset <- mf$subset[NonNaNValues];
        }
        else{
            subset <- mf$subset;
        }
    }

    mu <- vector("numeric", obsInsample);
    yFitted <- vector("numeric", obsInsample);
    errors <- vector("numeric", obsInsample);
    ot <- vector("logical", obsInsample);

    #### Checks of the exogenous variables ####
    if(!fast){
        # Remove the data for which sd=0
        noVariability <- vector("logical",nVariables);
        noVariability[] <- apply((matrixXreg==matrix(matrixXreg[1,],obsInsample,nVariables,byrow=TRUE)),2,all);
        if(any(noVariability)){
            if(all(noVariability)){
                warning("None of exogenous variables has variability. Fitting the straight line.",
                        call.=FALSE);
                matrixXreg <- matrix(1,obsInsample,1);
                nVariables <- 1;
                variablesNames <- "(Intercept)";
            }
            else{
                warning("Some exogenous variables did not have any variability. We dropped them out.",
                        call.=FALSE);
                matrixXreg <- matrixXreg[,!noVariability,drop=FALSE];
                nVariables <- ncol(matrixXreg);
                variablesNames <- variablesNames[!noVariability];
            }
        }

        #### Not clear yet how to check multicollinearity for complex models ####
        # Check the multicollinearity.
        # corThreshold <- 0.999;
        # if(nVariables>1){
        #     # Check perfectly correlated cases
        #     corMatrix <- cor(matrixXreg,use="pairwise.complete.obs");
        #     corHigh <- upper.tri(corMatrix) & abs(corMatrix)>=corThreshold;
        #     if(any(corHigh)){
        #         removexreg <- unique(which(corHigh,arr.ind=TRUE)[,1]);
        #         matrixXreg <- matrixXreg[,-removexreg,drop=FALSE];
        #         nVariables <- ncol(matrixXreg);
        #         variablesNames <- colnames(matrixXreg);
        #         if(!occurrenceModel && !CDF){
        #             warning("Some exogenous variables were perfectly correlated. We've dropped them out.",
        #                     call.=FALSE);
        #         }
        #     }
        # }
        #
        # # Do these checks only when intercept is needed. Otherwise in case of dummies this might cause chaos
        # if(nVariables>1 & interceptIsNeeded){
        #     # Check dummy variables trap
        #     detHigh <- suppressWarnings(determination(matrixXreg))>=corThreshold;
        #     if(any(detHigh)){
        #         while(any(detHigh)){
        #             removexreg <- which(detHigh>=corThreshold)[1];
        #             matrixXreg <- matrixXreg[,-removexreg,drop=FALSE];
        #             nVariables <- ncol(matrixXreg);
        #             variablesNames <- colnames(matrixXreg);
        #
        #             detHigh <- suppressWarnings(determination(matrixXreg))>=corThreshold;
        #         }
        #         if(!occurrenceModel){
        #             warning("Some combinations of exogenous variables were perfectly correlated. We've dropped them out.",
        #                     call.=FALSE);
        #         }
        #     }
        # }

        #### Finish forming the matrix of exogenous variables ####
        # Remove the redundant dummies, if there are any
        varsToLeave <- apply(matrixXreg,2,cvar)!=0;
        matrixXreg <- matrixXreg[,varsToLeave,drop=FALSE];
        variablesNames <- variablesNames[varsToLeave];
        nVariables <- length(variablesNames);
    }

    # Reintroduce intercept
    if(interceptIsNeeded){
        matrixXreg <- cbind(1,matrixXreg);
        variablesNames <- c("(Intercept)",variablesNames);
        colnames(matrixXreg) <- variablesNames;

        #### Not clear yet how to check multicollinearity for complex models ####
        # Check, if redundant dummies are left. Remove the first if this is the case
        # Don't do the check for LASSO / RIDGE
        # if(is.null(parameters) && !fast){
        #     determValues <- suppressWarnings(determination(matrixXreg[, -1, drop=FALSE]));
        #     determValues[is.nan(determValues)] <- 0;
        #     if(any(determValues==1)){
        #         matrixXreg <- matrixXreg[,-(which(determValues==1)[1]+1),drop=FALSE];
        #         variablesNames <- colnames(matrixXreg);
        #     }
        # }
        nVariables <- length(variablesNames);
    }
    variablesNamesAll <- variablesNames;
    parametersNames <- variablesNames;
    # The number of exogenous variables
    nVariablesExo <- nVariables;

    #### ARIMA orders ####
    arOrder <- orders[1];
    iOrder <- orders[2];
    maOrder <- orders[3];

    # Check AR, I and form ARI order
    if(arOrder<0){
        warning("p in AR(p) must be positive. Taking the absolute value.", call.=FALSE);
        arOrder <- abs(arOrder);
    }
    if(iOrder<0){
        warning("d in I(d) must be positive. Taking the absolute value.", call.=FALSE);
        iOrder <- abs(iOrder);
    }
    if(maOrder<0){
        warning("q in MA(q) must be positive. Taking the absolute value.", call.=FALSE);
        maOrder <- abs(maOrder);
    }
    ariOrder <- arOrder + iOrder;

    arOrderUsed <- arOrder>0;
    iOrderUsed <- iOrder>0;
    ariOrderUsed <- ariOrder>0;
    maOrderUsed <- maOrder>0;

    arimaModel <- ifelseFast(ariOrderUsed, TRUE, FALSE) || ifelseFast(maOrderUsed, TRUE, FALSE);

    # Permutations for the ARIMA
    if(arimaModel){
        # Create polynomials for the ar, i and ma orders
        if(arOrderUsed){
            poly1 <- rep(1,arOrder+1);
        }
        else{
            poly1 <- c(1);
        }
        if(iOrderUsed){
            poly2 <- c(1,-1);
            if(iOrder>1){
                for(j in 1:(iOrder-1)){
                    poly2 <- polyprodcomplex(poly2,c(1,-1));
                }
            }
        }
        else{
            poly2 <- c(1);
        }
        if(maOrderUsed){
            poly3 <- rep(1,maOrder+1);
        }
        else{
            poly3 <- c(1);
        }

        if(ariOrderUsed){
            # Expand the response variable to have ARI
            ariElements <- xregExpander(complex2vec(y), lags=-c(1:ariOrder), gaps="auto")[,-c(1,ariOrder+2),drop=FALSE];
            ariElements <- vec2complex(ariElements[,rep(1:ariOrder,each=2)+rep(c(0,ariOrder),ariOrder)]);

            # Fill in zeroes with the mean values
            ariElements[ariElements==0] <- mean(ariElements[ariElements[,1]!=0,1]);

            # Fix names of lags
            # class(ariElements) <- "matrix";
            ariNames <- paste0(responseName,"Lag",c(1:ariOrder));
            colnames(ariElements) <- ariNames;
            variablesNames <- c(variablesNames,ariNames);
        }
        else{
            ariElements <- NULL;
            ariNames <- NULL;
        }

        # Adjust number of variables
        nVariables <- nVariables + arOrder * arOrderUsed + maOrder * maOrderUsed;

        # Give names to AR elements
        if(arOrderUsed){
            arNames <- paste0(responseName,"Lag",c(1:arOrder));
            parametersNames <- c(parametersNames,arNames);
        }

        # Amend the matrix for MA to have columns for the previous errors
        if(maOrderUsed){
            maElements <- matrix(0,obsInsample,maOrder);
            maNames <- paste0("eLag",c(1:maOrder));
            variablesNames <- c(variablesNames,maNames);
            parametersNames <- c(parametersNames,maNames);
        }
        else{
            maElements <- NULL;
            maNames <- vector("character",0);
        }
        variablesNamesAll <- variablesNames;

        # Add ARIMA elements to the design matrix
        matrixXreg <- cbind(matrixXreg, ariElements, maElements);

    }

    iModelDesign <- function(...){
        # Use only AR elements of the matrix, take differences for the initialisation purposes
        # This matrix does not contain columns for iOrder and has fewer observations to match diff(y)
        matrixXregForDiffs <- matrixXreg[,-(nVariablesExo+arOrder+1:(iOrder+maOrder)),drop=FALSE];
        if(arOrderUsed){
            matrixXregForDiffs[-c(1:iOrder),nVariablesExo+c(1:arOrder)] <- diff(matrixXregForDiffs[,nVariablesExo+c(1:arOrder)],
                                                                                differences=iOrder);
            # matrixXregForDiffs[c(1:iOrder),nVariablesExo+c(1:arOrder)] <- colMeans(matrixXregForDiffs[,nVariablesExo+c(1:arOrder), drop=FALSE]);
        }
        # else{
        #     matrixXregForDiffs <- matrixXregForDiffs[-c(1:iOrder),,drop=FALSE];
        # }
        # Drop first d observations
        matrixXregForDiffs <- matrixXregForDiffs[-c(1:iOrder),,drop=FALSE];

        # Check variability in the new data. Have we removed important observations?
        noVariability <- apply(matrixXregForDiffs[,-interceptIsNeeded,drop=FALSE]==
                                   matrix(matrixXregForDiffs[1,-interceptIsNeeded],
                                          nrow(matrixXregForDiffs),ncol(matrixXregForDiffs)-interceptIsNeeded,
                                          byrow=TRUE),
                               2,all);
        if(any(noVariability)){
            warning("Some variables had no variability after taking differences. ",
                    "This might mean that all the variability for them happened ",
                    "in the very beginning of the series. We'll try to fix this, but the model might fail.",
                    call.=FALSE);
            matrixXregForDiffs[1,which(noVariability)+1] <- rnorm(sum(noVariability));
        }

        return(matrixXregForDiffs)
    }

    # Scale all variables if this is required
    # if(scaling!="none"){
    # }

    #### Estimate parameters of the model ####
    if(is.null(parameters)){
        if(loss=="CLS"){
            # If this is d=0 model
            if(iOrder==0){
                B <- as.vector(invert(t(matrixXreg[,1:(nVariablesExo+arOrder), drop=FALSE]) %*%
                                          matrixXreg[,1:(nVariablesExo+arOrder), drop=FALSE]) %*%
                                   t(matrixXreg[,1:(nVariablesExo+arOrder), drop=FALSE]) %*% y);
            }
            else{
                matrixXregForDiffs <- iModelDesign();
                B <- as.vector(invert(t(matrixXregForDiffs) %*% matrixXregForDiffs) %*%
                                   t(matrixXregForDiffs) %*% diff(y,differences=iOrder));
            }
            if(maOrderUsed){
                # Add initial values for the maOrder
                B <- c(B, rep(0.1*(1+1i),maOrder));
                # Estimate the model
                res <- estimator(B, print_level);
                B <- res$B;
                CFValue <- res$CFValue;
            }
            else{
                CFValue <- CF(B, loss, y, matrixXreg);
            }
        }
        else if(loss=="OLS"){
            # If this is d=0 model
            if(iOrder==0){
                B <- as.vector(invert(t(Conj(matrixXreg[,1:(nVariablesExo+arOrder), drop=FALSE])) %*%
                                          matrixXreg[,1:(nVariablesExo+arOrder), drop=FALSE]) %*%
                                   t(Conj(matrixXreg[,1:(nVariablesExo+arOrder), drop=FALSE])) %*% y);
            }
            else{
                matrixXregForDiffs <- iModelDesign();
                B <- as.vector(invert(t(Conj(matrixXregForDiffs)) %*% matrixXregForDiffs) %*%
                                   t(Conj(matrixXregForDiffs)) %*% diff(y,differences=iOrder));
            }
            if(maOrderUsed){
                # Add initial values for the maOrder
                B <- c(B, rep(0.1*(1+1i),maOrder));
                # Estimate the model
                res <- estimator(B, print_level);
                B <- res$B;
                CFValue <- res$CFValue;
            }
            else{
                CFValue <- CF(B, loss, y, matrixXreg);
            }
        }
        else{
            # The vector B contains (in this sequence):
            # 1. paramExo,
            # 2. paramAR,
            # 3. paramMA.
            if(is.null(B)){
                # If this is d=0 model
                if(iOrder==0){
                    B <- as.vector(invert(t(Conj(matrixXreg[,1:(nVariablesExo+arOrder), drop=FALSE])) %*%
                                              matrixXreg[,1:(nVariablesExo+arOrder), drop=FALSE]) %*%
                                       t(Conj(matrixXreg[,1:(nVariablesExo+arOrder), drop=FALSE])) %*% y);
                }
                else{
                    matrixXregForDiffs <- iModelDesign();
                    B <- as.vector(invert(t(Conj(matrixXregForDiffs)) %*% matrixXregForDiffs) %*%
                                       t(Conj(matrixXregForDiffs)) %*% diff(y,differences=iOrder));
                }
                if(maOrderUsed){
                    # Add initial values for the maOrder
                    B <- c(B, rep(0.1*(1+1i),maOrder));
                }
            }
            res <- estimator(B, print_level);
            B <- res$B;
            CFValue <- res$CFValue;
        }
    }
    # If the parameters are provided
    else{
        B <- parameters;
        nVariables <- length(B);
        if(!is.null(names(B))){
            parametersNames <- names(B);
        }
        else{
            names(B) <- parametersNames;
            names(parameters) <- parametersNames;
        }
        variablesNamesAll <- colnames(matrixXreg);
        CFValue <- CF(B, loss, y, matrixXreg);
    }

    # If there were ARI, write down the polynomial
    if(arimaModel){
        ellipsis$orders <- orders;
        # Some models save the first parameter for scale
        nVariablesForReal <- length(B);
        if(arOrderUsed){
            poly1[-1] <- -B[nVariablesExo+c(1:arOrder)];
        }
        ellipsis$polynomial <- -polyprodcomplex(poly2,poly1)[-1];
        names(ellipsis$polynomial) <- ariNames;
        ellipsis$arima <- paste0("cARIMA(",paste0(orders,collapse=","),")");
    }

    fitterReturn <- fitter(B, y, matrixXreg);
    mu[] <- fitterReturn$mu;
    scale <- fitterReturn$scale;
    matrixXreg[] <- fitterReturn$matrixXreg;

    #### Produce Fisher Information ####
    if(FI){
        FI <- hessian(CF, B, h=stepSize, loss="likelihood", y=y, matrixXreg=matrixXreg);

        if(any(is.nan(FI))){
            warning("Something went wrong and we failed to produce the covariance matrix of the parameters.\n",
                    "Obviously, it's not our fault. Probably Russians have hacked your computer...\n",
                    "Try a different distribution maybe?", call.=FALSE);
            FI <- diag(1e+100,nVariables);
        }
        dimnames(FI) <- list(parametersNames,parametersNames);
    }

    # Give names to additional parameters
    if(is.null(parameters)){
        parameters <- B;
        names(parameters) <- parametersNames;
        names(B) <- parametersNames;
    }

    ### Fitted values in the scale of the original variable
    yFitted[] <- extractorFitted(mu, scale);

    ### Error term in the transformed scale
    errors[] <- extractorResiduals(mu, yFitted);

    nParam <- nVariables + (loss=="likelihood")*3/2;

    if(interceptIsNeeded){
        # This shit is needed, because R has habit of converting everything into vectors...
        dataWork <- cbind(y,matrixXreg[,-1,drop=FALSE]);
        variablesUsed <- variablesNamesAll[variablesNamesAll!="(Intercept)"];
    }
    else{
        dataWork <- cbind(y,matrixXreg);
        variablesUsed <- variablesNamesAll;
    }
    colnames(dataWork) <- c(responseName, variablesUsed);

    # Return LogLik, depending on the used loss
    if(loss=="likelihood"){
        logLik <- -CFValue;
    }
    # else if(loss=="CLS"){
    #     logLik <- -CF(B, loss="likelihood", y, matrixXreg);
    # }
    else{
        logLik <- NA;
    }

    modelName <- "Complex Linear Regression";
    if(arimaModel){
        if(nVariablesExo-interceptIsNeeded==0){
            modelName <- ellipsis$arima;
        }
        else{
            modelName <- paste0("cARIMAX(",orders[1],",",orders[2],",",orders[3],")");
        }
    }

    #### Return the model ####
    finalModel <- structure(list(coefficients=parameters, FI=FI, fitted=yFitted, residuals=as.vector(errors),
                                 mu=mu, scale=scale, logLik=logLik, model=modelName,
                                 loss=loss, lossFunction=lossFunction, lossValue=CFValue,
                                 df.residual=obsInsample-nParam, df=nParam, call=cl, rank=nParam,
                                 data=dataWork, terms=dataTerms,
                                 subset=subset, other=ellipsis, B=B,
                                 timeElapsed=Sys.time()-startTime),
                            class=c("clm","greybox"));

    return(finalModel);
}

#' @importFrom greybox actuals
#' @export
actuals.clm <- function(object, all=TRUE, ...){
    return(object$data[,1]);
}

#' @importFrom stats nobs
#' @export
nobs.clm <- function(object, all=TRUE, ...){
    return(length(actuals(object, ...)));
}

#' @importFrom greybox nparam
#' @export
nparam.clm <- function(object, all=TRUE, ...){
    return(object$rank);
    # x <- c(Re(coef(object)),Im(coef(object)));
    # x <- x[x!=0];
    # # Divide by two, because we calculate df per series
    # return(length(x)/2);
}

#' @importFrom stats logLik
#' @export
logLik.clm <- function(object, ...){
    return(structure(object$logLik,nobs=nobs(object),df=nparam(object),class="logLik"));
}

#' @rdname clm
#' @param object Model estimated using \code{clm()} function.
#' @param type Type of sigma to return. This is calculated based on the residuals
#' of the estimated model and can be \code{"direct"}, based on the direct variance,
#' \code{"conjugate"}, based on the conjugate variance and \code{"matrix"}, returning
#' covariance matrix for the complex error. If \code{NULL} then will return value based
#' on the loss used in the estimation: OLS -> "conjugate", CLS -> "direct", likelihood ->
#' "matrix".
#' @param ... Other parameters passed to internal functions.
#' @importFrom stats sigma
#' @export
sigma.clm <- function(object, type=NULL, ...){

    # See the type
    if(!is.null(type)){
        type <- match.arg(type, c("direct","conjugate","matrix"));
    }
    else{
        # Default values
        type <- switch(object$loss,
                       "CLS"="direct",
                       "OLS"="conjugate",
                       "likelihood"="matrix")
    }

    errors <- resid(object);
    sigmaValue <- switch(type,
                         "direct"=sqrt(sum(errors^2, ...)/(nobs(object) - nparam(object))),
                         "conjugate"=sqrt(sum(errors * Conj(errors), ...)/(nobs(object) - nparam(object))),
                         covar(errors, df=nobs(object)-nparam(object)));

    if(type=="matrix"){
        colnames(sigmaValue) <- rownames(sigmaValue) <- c("e_r", "e_i");
    }

    return(sigmaValue);
}

#' @rdname clm
#' @importFrom stats vcov
#' @export
vcov.clm <- function(object, type=NULL, ...){

    # See the type
    if(!is.null(type)){
        type <- match.arg(type, c("direct","conjugate","matrix"));
    }
    else{
        # Default values
        type <- switch(object$loss,
                       "CLS"="direct",
                       "OLS"="conjugate",
                       "likelihood"="matrix")
    }

    nVariables <- length(coef(object));
    parametersNames <- names(coef(object));
    interceptIsNeeded <- any(parametersNames=="(Intercept)");
    ellipsis <- list(...);

    matrixXreg <- object$data;
    if(interceptIsNeeded){
        matrixXreg[,1] <- 1;
        colnames(matrixXreg)[1] <- "(Intercept)";
    }
    else{
        matrixXreg <- matrixXreg[,-1,drop=FALSE];
    }

    # If there are ARIMA orders, define them.
    if(!is.null(object$other$arima)){
        arOrders <- object$other$orders[1];
        iOrders <- object$other$orders[2];
        maOrders <- object$other$orders[3];
    }
    else{
        arOrders <- iOrders <- maOrders <- 0;
    }

    sigmaValue <- sigma(object, type);

    if(iOrders==0 && maOrders==0){
        if(type=="conjugate"){
            # Get variance
            sigmaValue[] <- sigmaValue^2;
            if(object$loss=="CLS"){
                # Conjugate matrix
                matrixXregConj <- Conj(matrixXreg);
                # Transposed original
                matrixXregTrans <- t(matrixXreg);
                # Conjugate transposed matrix
                matrixXregConjTrans <- t(Conj(matrixXreg));

                # Calculate the (X'X)^{-1} X'X~ (X~' X~)^{-1'}
                vcov <-
                    invert(matrixXregTrans %*% matrixXreg) %*%
                    (matrixXregTrans %*% matrixXregConj) %*%
                    t(invert(t(matrixXregConj) %*% matrixXregConj));
            }
            # OLS and likelihood
            else {
                # Conjugate matrix
                matrixXregConj <- Conj(matrixXreg);
                # Transposed conjugate original
                matrixXregConjTrans <- t(Conj(matrixXreg));
                # Transposed matrix
                matrixXregTrans <- t(matrixXreg);

                # Calculate the (X'X)^{-1} X'X~ (X~' X~)^{-1'}
                vcov <-
                    invert(matrixXregConjTrans %*% matrixXreg) %*%
                    (matrixXregConjTrans %*% matrixXreg) %*%
                    t(Conj(invert(matrixXregTrans %*% matrixXregConj)));
            }
        }
        else if(type=="direct"){
            # Get variance
            sigmaValue[] <- sigmaValue^2;
            if(object$loss=="CLS"){
                # Simple transposition of the matrix
                matrixXregTrans <- t(matrixXreg);
                matrixXreg <- matrixXreg;
            }
            # OLS and likelihood
            else {
                # Simple transposition of the matrix
                matrixXregTrans <- t(Conj(matrixXreg));
            }

            # Calculate the (X' X)^{-1}
            vcov <- invert(matrixXregTrans %*% matrixXreg);
        }
        else{
            # Transform the complex matrix to be a matrix
            matrixXreg <- complex2mat(matrixXreg);
            # Conjugate transposition
            matrixXregTrans <- t(matrixXreg);

            # Calculate the (X'X)^{-1}
            # Re() is needed to drop the 0i
            vcov <- Re(invert(matrixXregTrans %*% matrixXreg));
        }
        ndimVcov <- ncol(vcov);

        if(any(type==c("direct","conjugate"))){
            vcov[] <- vcov * sigmaValue;
            rownames(vcov) <- colnames(vcov) <- names(coef(object));
        }
        # Likelihood estimate
        else{
            for(i in 1:(ndimVcov/2)){
                for(j in 1:(ndimVcov/2)){
                    vcov[(1:2)+(i-1)*2,(1:2)+(j-1)*2] <- vcov[(1:2)+(i-1)*2,(1:2)+(j-1)*2] * sigmaValue;
                }
            }
            rownames(vcov) <- colnames(vcov) <- names(complex2mat(coef(object))[,1]);
        }
    }
    else{
        type <- "matrix";

        # Form the call for alm
        newCall <- object$call;
        if(interceptIsNeeded){
            newCall$formula <- as.formula(paste0("`",all.vars(newCall$formula)[1],"`~."));
        }
        else{
            newCall$formula <- as.formula(paste0("`",all.vars(newCall$formula)[1],"`~.-1"));
        }
        newCall$data <- object$data[,!(colnames(object$data) %in% names(object$other$polynomial)), drop=FALSE];
        newCall$subset <- object$subset;
        # This needs to be likelihood, otherwise it won't work with complex variables
        newCall$loss <- "likelihood";
        newCall$orders <- object$other$orders;
        newCall$parameters <- c(Re(coef(object)),Im(coef(object)));
        newCall$scale <- object$scale;
        newCall$fast <- TRUE;
        newCall$FI <- TRUE;
        # Include bloody ellipsis
        newCall <- as.call(c(as.list(newCall),substitute(ellipsis)));
        # Make sure that print_level is zero, not to print redundant things out
        newCall$print_level <- 0;

        # Recall alm to get Hessian
        FIMatrix <- eval(newCall)$FI;
        # If any row contains all zeroes, then it means that the variable does not impact the likelihood
        brokenVariables <- apply(FIMatrix==0,1,all) | apply(is.nan(FIMatrix),1,any);
        # If there are issues, try the same stuff, but with a different step size for Hessian
        if(any(brokenVariables)){
            newCall$stepSize <- .Machine$double.eps^(1/6);
            FIMatrix <- eval(newCall)$FI;
        }

        # Take inverse of the matrix
        vcovMatrixTry <- try(solve(FIMatrix, diag(nVariables*2), tol=1e-20), silent=TRUE);
        if(inherits(vcovMatrixTry,"try-error")){
            vcov <- diag(1e+100,nVariables*2);
            rownames(vcov) <- rep(parametersNames,2);
        }
        else{
            vcov <- vcovMatrixTry;
        }
        ndimVcovHalf <- ncol(vcov)/2;

        rownames(vcov)[1:ndimVcovHalf] <- paste0(rownames(vcov)[1:ndimVcovHalf],"_r");
        rownames(vcov)[ndimVcovHalf+1:ndimVcovHalf] <- paste0(rownames(vcov)[ndimVcovHalf+1:ndimVcovHalf],"_i");
        colnames(vcov) <- rownames(vcov);

        # Change the order of parameteres
        parametersNamesAllComplex <- paste0(rep(parametersNames,each=2),c("_r","_i"));
        vcov <- vcov[parametersNamesAllComplex,parametersNamesAllComplex];
    }

    return(vcov);
}

#' @importFrom stats resid qt
#' @export
confint.clm <- function(object, parm, level = 0.95, ...){

    confintNames <- c(paste0((1-level)/2*100,"%"),
                      paste0((1+level)/2*100,"%"));

    # Extract coefficients
    parameters <- complex2mat(coef(object))[,1];
    parametersNames <- names(parameters);
    parametersLength <- length(parametersNames);

    # If this is the likelihood or we did the numeric vcov
    if(object$loss=="likelihood" ||
       (!is.null(object$other$arima) && (object$other$orders[2]!=0 || object$other$orders[3]!=0))){
        # Get covariance matrix. abs() is a failsafe mechanism
        parametersSE <- sqrt(diag(abs(vcov(object, type="matrix", ...))));
    }
    else{
        parametersSEDir <- Re(diag(vcov(object, type="direct", ...)));
        parametersSEConj <- Re(diag(vcov(object, type="conjugate", ...)));
        parametersSE <- vector("numeric", parametersLength);
        # Real values
        parametersSE[1:(parametersLength/2)*2-1] <- sqrt((parametersSEConj + parametersSEDir)/2);
        # Imaginary values
        parametersSE[1:(parametersLength/2)*2] <- sqrt((parametersSEConj - parametersSEDir)/2);
    }
    varLength <- length(parametersSE);

    # Define quantiles using Student distribution
    paramQuantiles <- qt((1+level)/2,df=object$df.residual);

    # We can use normal distribution, because of the asymptotics of MLE
    confintValues <- cbind(parameters-paramQuantiles*parametersSE,
                           parameters+paramQuantiles*parametersSE);
    colnames(confintValues) <- confintNames;

    # Return S.E. as well, so not to repeat the thing twice...
    confintValues <- cbind(parametersSE, confintValues);
    # Give the name to the first column
    colnames(confintValues)[1] <- "S.E.";
    rownames(confintValues) <- parametersNames;

    return(confintValues);
}

#' @importFrom stats coef confint
#' @importFrom greybox nparam
#' @rdname clm
#' @param object Object of class "clm" estimated via \code{clm()} function.
#' @param level What confidence level to use for the parameters of the model.
#' @export
summary.clm <- function(object, level=0.95, ...){
    bootstrap <- FALSE;
    errors <- residuals(object);
    obs <- nobs(object, all=TRUE);

    # Collect parameters and their standard errors
    parametersConfint <- confint(object, level=level, bootstrap=bootstrap, ...);
    parameters <- complex2mat(coef(object))[,1];
    parametersLength <- length(parameters);
    parametersTable <- cbind(parameters,parametersConfint);
    parametersTableColnames <- c("Estimate","Std. Error",
                                 paste0("Lower ",(1-level)/2*100,"%"),
                                 paste0("Upper ",(1+level)/2*100,"%"));
    parametersTableRownames <- names(parameters)
    rownames(parametersTable) <- parametersTableRownames;
    colnames(parametersTable) <- parametersTableColnames;

    ourReturn <- list(coefficients=parametersTable);

    # Mark those that are significant on the selected level
    ourReturn$significance <- !(parametersTable[,3]<=0 & parametersTable[,4]>=0);

    # If there is a likelihood, then produce ICs
    if(!is.na(logLik(object))){
        ICs <- c(AIC(object),AICc(object),BIC(object),BICc(object));
        names(ICs) <- c("AIC","AICc","BIC","BICc");
        ourReturn$ICs <- ICs;
    }
    ourReturn$loss <- object$loss;
    ourReturn$model <- object$model;
    ourReturn$other <- object$other;
    ourReturn$responseName <- formula(object)[[2]];

    # Table with degrees of freedom
    dfTable <- c(obs,nparam(object),obs-nparam(object));
    names(dfTable) <- c("n","k","df");

    ourReturn$r.squared <- 1 - sum(errors^2) / sum((actuals(object)-mean(actuals(object)))^2);
    ourReturn$adj.r.squared <- 1 - (1 - ourReturn$r.squared) * (obs - 1) / (dfTable[3]);

    ourReturn$dfTable <- dfTable;
    ourReturn$s2 <- sigma(object, type="matrix");

    ourReturn <- structure(ourReturn,class=c("summary.clm","summary.greybox"));
    return(ourReturn);
}

#' @export
print.summary.clm <- function(x, ...){
    ellipsis <- list(...);
    if(!any(names(ellipsis)=="digits")){
        digits <- 4;
    }
    else{
        digits <- ellipsis$digits;
    }

    cat(x$model, "estimated via clm()\n");
    cat(paste0("Response variable: ", paste0(x$responseName,collapse="")));
    cat(paste0("\nLoss function used in estimation: ",x$loss));

    cat("\nCoefficients:\n");
    stars <- setNames(vector("character",length(x$significance)),
                      names(x$significance));
    stars[x$significance] <- "*";
    print(data.frame(round(x$coefficients,digits),stars,
                     check.names=FALSE,fix.empty.names=FALSE));

    cat("\nError covariance matrix:\n"); print(round(x$s2,digits));
    cat("\nSample size: "); cat(x$dfTable[1]);
    cat("\nNumber of estimated parameters: "); cat(x$dfTable[2]);
    cat("\nNumber of degrees of freedom: "); cat(x$dfTable[3]);
    if(!is.null(x$ICs)){
        cat("\nInformation criteria:\n");
        print(round(x$ICs,digits));
    }
    cat("\n");
}

#' @export
plot.clm <- function(x, which=c(1,2,4,6), ...){
    # Amend the object to make it work with legion plots
    x$Sigma <- sigma(x, type="matrix");
    x$data <- complex2vec(actuals(x));
    x$fitted <- complex2vec(fitted(x));
    x$residuals <- complex2vec(residuals(x));
    x$forecast <- matrix(NA,1,2);
    class(x) <- "legion";

    # This is just a fix to make errorType() and plot.legion() work
    x$model <- "VETS(ANN)"

    if(any(which>=12)){
        which <- which[which<12];
    }

    plot(x, which=which, ...);
}

#' @export
predict.clm <- function(object, newdata=NULL, interval=c("none", "confidence", "prediction"),
                        level=0.95, side=c("both","upper","lower"), ...){
    interval <- match.arg(interval);
    side <- match.arg(side);

    parameters <- coef(object);
    parametersNames <- parametersNamesAll <- names(parameters);

    interceptIsNeeded <- attr(terms(object),"intercept")!=0;

    arimaModel <- !is.null(object$other$arima);
    nParametersExo <- length(parameters);
    if(arimaModel){
        y <- actuals(object);
        ariOrder <- length(object$other$polynomial);
        arOrder <- object$other$orders[1];
        iOrder <- object$other$orders[2];
        maOrder <- object$other$orders[3];

        arOrderUsed <- arOrder>0;
        ariOrderUsed <- ariOrder>0;
        maOrderUsed <- maOrder>0;

        if(ariOrderUsed){
            ariParameters <- object$other$polynomial;
        }
        else{
            ariParameters <- NULL;
        }
        if(maOrderUsed){
            maParameters <- tail(parameters, maOrder);
        }
        else{
            maParameters <- NULL;
        }
        ariNames <- names(ariParameters);
        maNames <- names(maParameters);

        nParametersExo[] <- nParametersExo - arOrder - maOrder;

        # Split the parameters into normal and polynomial (for ARI)
        if(arOrderUsed || maOrderUsed){
            parameters <- parameters[1:nParametersExo];
        }
        parametersNames <- names(parameters);

        # Add ARI polynomials to the parameters
        parameters <- c(parameters,ariParameters,maParameters);
    }

    nLevels <- length(level);
    levelLow <- levelUp <- vector("numeric",nLevels);
    if(side=="upper"){
        levelLow[] <- 0;
        levelUp[] <- level;
    }
    else if(side=="lower"){
        levelLow[] <- 1-level;
        levelUp[] <- 1;
    }
    else{
        levelLow[] <- (1-level) / 2;
        levelUp[] <- (1+level) / 2;
    }
    paramQuantiles <- qt(c(levelLow, levelUp),df=object$df.residual);

    if(is.null(newdata)){
        matrixOfxreg <- object$data;
        newdataProvided <- FALSE;
        # The first column is the response variable. Either substitute it by ones or remove it.
        if(any(parametersNames=="(Intercept)")){
            matrixOfxreg[,1] <- 1;
        }
        else{
            matrixOfxreg <- matrixOfxreg[,-1,drop=FALSE];
        }
    }
    else{
        newdataProvided <- TRUE;
        h <- nrow(newdata);

        # If the formula contains more than just intercept
        if(length(all.vars(formula(object)))>1){
            if(!is.data.frame(newdata)){
                if(is.vector(newdata)){
                    newdataNames <- names(newdata);
                    newdata <- matrix(newdata, nrow=1, dimnames=list(NULL, newdataNames));
                }
                newdata <- as.data.frame(newdata);
            }
            else{
                dataOrders <- unlist(lapply(newdata,is.ordered));
                # If there is an ordered factor, remove the bloody ordering!
                if(any(dataOrders)){
                    newdata[dataOrders] <- lapply(newdata[dataOrders],function(x) factor(x, levels=levels(x), ordered=FALSE));
                }
            }

            # The gsub is needed in order to remove accidental special characters
            colnames(newdata) <- make.names(colnames(newdata), unique=TRUE);

            # Extract the formula and get rid of the response variable
            testFormula <- formula(object);

            # If the user asked for trend, but it's not in the data, add it
            if(any(all.vars(testFormula)=="trend") && all(colnames(newdata)!="trend")){
                newdata <- cbind(newdata,trend=nobs(object)+c(1:nrow(newdata)));
            }

            testFormula[[2]] <- NULL;
            # Expand the data frame
            newdataExpanded <- model.frame(testFormula, newdata);

            #### Temporary solution for model.matrix() ####
            responseName <- all.vars(formula(object))[[1]];
            if(is.data.frame(newdataExpanded)){
                complexVariables <- sapply(newdataExpanded, is.complex);
            }
            else{
                complexVariables <- apply(newdataExpanded, 2, is.complex);
            }
            complexVariablesNames <- names(complexVariables)[complexVariables];
            complexVariablesNames <- complexVariablesNames[complexVariablesNames!=responseName];
            # Save the original data to come back to it
            originalData <- newdataExpanded;
            newdataExpanded[,complexVariables] <- sapply(newdataExpanded[,complexVariables], Re);

            # Create a model from the provided stuff. This way we can work with factors
            matrixOfxreg <- model.matrix(newdataExpanded,data=newdataExpanded);
            # And this small function will do all necessary transformations of complex variables
            matrixOfxregComplex <- cmodel.matrix(originalData, data=originalData);
            complexVariablesNamesUsed <- complexVariablesNames[complexVariablesNames %in% colnames(matrixOfxreg)];
            matrixOfxreg[,complexVariablesNamesUsed] <- as.matrix(matrixOfxregComplex[,complexVariablesNamesUsed]);
            matrixOfxreg <- matrixOfxreg[,parametersNames,drop=FALSE];
        }
        else{
            matrixOfxreg <- matrix(1, h, 1);
            if(interceptIsNeeded){
                colnames(matrixOfxreg) <- "(Intercept)";
            }
        }
    }

    if(!is.matrix(matrixOfxreg)){
        matrixOfxreg <- as.matrix(matrixOfxreg);
    }

    if(h==1){
        matrixOfxreg <- matrix(matrixOfxreg, nrow=1);
    }

    if(arimaModel){
        # Fill in the tails with the available data
        matrixOfxregFull <- cbind(matrixOfxreg, matrix(0,h,ariOrder+maOrder,dimnames=list(NULL,c(ariNames,maNames))));
        if(ariOrderUsed){
            for(i in 1:ariOrder){
                matrixOfxregFull[1:min(h,i),nParametersExo+i] <- tail(y,i)[1:min(h,i)];
            }
        }
        # Fill in the tails with the residuals for the MA
        if(maOrderUsed){
            errors <- residuals(object);
            for(i in 1:maOrder){
                matrixOfxregFull[1:min(h,i),nParametersExo+ariOrder+i] <- tail(errors,i)[1:min(h,i)];
            }
        }

        # Produce forecasts iteratively
        ourForecast <- vector("numeric", h);
        for(i in 1:h){
            ourForecast[i] <- matrixOfxregFull[i,] %*% parameters;
            if(ariOrderUsed){
                for(j in 1:ariOrder){
                    if(i+j-1==h){
                        break;
                    }
                    matrixOfxregFull[i+j,nParametersExo+j] <- ourForecast[i];
                }
            }
        }
        if(maOrderUsed){
            # Redefine the matrix for the vcov
            matrixOfxreg <- matrixOfxregFull[,c(1:(nParametersExo+arOrder),nParametersExo+ariOrder+c(1:maOrder)),drop=FALSE];
        }
        else{
            matrixOfxreg <- matrixOfxregFull[,1:(nParametersExo+arOrder),drop=FALSE];
        }
    }
    else{
        ourForecast <- as.vector(matrixOfxreg %*% parameters);
    }
    vectorOfVariances <- NULL;

    if(interval!="none"){
        if(arimaModel){
            warning("Prediction and confidence intervals in cARIMA is still work in progress. ",
                    "Use with care.", call.=FALSE);
        }
        matrixOfxreg <- complex2mat(matrixOfxreg);
        ourVcov <- vcov(object, type="matrix");
        # abs is needed for some cases, when the likelihood was not fully optimised
        vectorOfVariances <- matrix(diag(matrixOfxreg %*% ourVcov %*% t(matrixOfxreg)),h,2,byrow=TRUE);

        #### cARIMA variance is different and needs to be calculated correctly here ####

        yUpper <- yLower <- matrix(NA, h, nLevels);
        if(interval=="confidence"){
            for(i in 1:nLevels){
                yLower[,i] <- ourForecast + paramQuantiles[i] * vec2complex(sqrt(abs(vectorOfVariances)));
                yUpper[,i] <- ourForecast + paramQuantiles[i+nLevels] * vec2complex(sqrt(abs(vectorOfVariances)));
            }
        }
        else if(interval=="prediction"){
            sigmaValues <- sigma(object, type="matrix");
            vectorOfVariances[] <- vectorOfVariances + matrix(diag(sigmaValues),h,2,byrow=TRUE);
            for(i in 1:nLevels){
                yLower[,i] <- ourForecast + paramQuantiles[i] * vec2complex(sqrt(vectorOfVariances));
                yUpper[,i] <- ourForecast + paramQuantiles[i+nLevels] * vec2complex(sqrt(vectorOfVariances));
            }
        }

        colnames(yLower) <- switch(side,
                                   "both"=,
                                   "lower"=paste0("Lower bound (",levelLow*100,"%)"),
                                   "upper"=rep("Lower 0%",nLevels));

        colnames(yUpper) <- switch(side,
                                   "both"=,
                                   "upper"=paste0("Upper bound (",levelUp*100,"%)"),
                                   "lower"=rep("Upper 100%",nLevels));
    }
    else{
        yLower <- NULL;
        yUpper <- NULL;
    }

    ourModel <- list(model=object, mean=ourForecast, lower=yLower, upper=yUpper, level=c(levelLow, levelUp), newdata=newdata,
                     variances=vectorOfVariances, newdataProvided=newdataProvided);
    return(structure(ourModel,class=c("predict.clm","predict.greybox")));
}

#' @export
plot.predict.clm <- function(x, ...){
    # Amend the object to make it work with legion plots
    x$data <- complex2vec(actuals(x$model));
    x$fitted <- complex2vec(fitted(x$model));
    x$forecast <- complex2vec(x$mean);
    if(!is.null(x$lower)){
        x$PI <- complex2vec(cbind(x$lower,x$upper))[,c(1,3,2,4)];
    }
    x$model <- x$model$model;
    class(x) <- "legion";

    plot(x, which=7, ...);
}
