## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----echo=TRUE, include=TRUE,  warning=FALSE, message=FALSE-------------------
library(RegrCoeffsExplorer)
library(gridExtra)
library(glmnet)
library(selectiveInference)
library(dplyr)
library(faraway)
library(MASS)
library(psych)
library(ggplot2)
library(rlang)

## -----------------------------------------------------------------------------

# help(mtcars)

df_mtcars=as.data.frame(mtcars)

df_mtcars[c("cyl","vs","am","gear")] =
  lapply(df_mtcars[c("cyl","vs","am","gear")] , factor) # convert to factor

head(df_mtcars)

lm_object=lm(mpg~cyl+hp+wt+disp+vs+am+carb,data=df_mtcars)

summary(lm_object)


## ----fig.height=6,fig.width=12, warning=F-------------------------------------

grid.arrange(vis_reg(lm_object)$"SidebySide")


## ----fig.height=6,fig.width=7, warning=F--------------------------------------

vis_reg(lm_object, intercept=T)$"PerUnitVis"


## ----fig.height=6,fig.width=7, warning=F--------------------------------------

vis_reg(lm_object, intercept=T, CI=T)$"PerUnitVis"


## ----fig.height=6,fig.width=12, warning=F-------------------------------------

grid.arrange(vis_reg(
             lm_object, CI=T,palette=c("palegreen4","tomato1"),
             eff_size_diff=c(1,5),
             title=c(
               "Regression - Unit Change", 
               "Regression - Effective Change (min --> max)"
                     )
                     )$"SidebySide"
             )


## ----fig.height=6,fig.width=7, warning=F--------------------------------------

# obtain coefficients for vs and wt
vline1=lm_object$coefficients['vs1'][[1]]
vline2=lm_object$coefficients['wt'][[1]]

vis_reg(lm_object)$"PerUnitVis"+
  geom_hline(yintercept=vline1, linetype="dashed", color = "blue", size=1)+   # add a vertical line
  geom_hline(yintercept=vline2, linetype="dashed", color = "orange", size=1)+
  ggtitle("Visualization of Regression Results (per unit change)")+
  ylim(-5,5)+                                                                 # note the coordinate flip
  xlab("aspects")+
  ylab("coefficients")+
  theme_bw()+
  scale_fill_manual(values = c("black","pink" ))+                             # change mappings 
  theme(plot.title = element_text(hjust = 0.5))                               # place title in the center
 

## -----------------------------------------------------------------------------

# ?hsb

glm_object=glm(
  I(prog == "academic") ~ gender +math+ read + write + science + socst,
  family = binomial(link="logit"), 
  data = faraway::hsb)

summary(glm_object)


## ----fig.height=6,fig.width=12, warning=F-------------------------------------

grid.arrange(vis_reg(
             glm_object,
             CI=T, 
             alpha=0.01
                    )$"SidebySide"
             )


## -----------------------------------------------------------------------------

df_glmnet=data.frame(Cars93)

df_glmnet[sample(dim(df_glmnet)[1], 5), ] # examine 5 randomly selected rows

levels(df_glmnet$Origin)                                                        # check level attributes

df_glmnet=df_glmnet %>% mutate(MPG.avg = (MPG.city + MPG.highway) / 2)          # calculate average MPG


## ----fig.height=6,fig.width=7, warning=F--------------------------------------

y_lasso=df_glmnet$Price

x_lasso=model.matrix(
        as.formula(paste("~",
                         paste(c("MPG.avg","Horsepower","RPM","Wheelbase", 
                                 "Passengers","Length", "Width", "Weight",
                                 "Origin","Man.trans.avail"
                                 ), collapse = "+"
                               ),sep = ""
                         )
                   ), data=df_glmnet
                     )
                                                   

x_lasso = x_lasso[, -1]                                                         # remove intercept

ndim_lasso=dim(x_lasso)[1]

cv_model_lasso = cv.glmnet(x_lasso, y_lasso, family="gaussian", alpha=1)        # LASSO regression

# extract value of lambda that gives minimum mean cross-validated error
best_lambda_lasso = cv_model_lasso$lambda.min                                   

plot(cv_model_lasso)

best_model_lasso = glmnet(x_lasso, y_lasso, family="gaussian", alpha=1, 
                            lambda=best_lambda_lasso)

coefficients(best_model_lasso)



## ----fig.height=8,fig.width=8, warning=F--------------------------------------

df_glmnet_num=df_glmnet%>%select_if(function(x) is.numeric(x))                  

cols_to_select = c("MPG.avg","Horsepower","RPM","Wheelbase","Passengers",
                   "Length", "Width", "Weight")

df_glmnet_num=df_glmnet_num %>%select(all_of(cols_to_select))                 

corPlot(df_glmnet_num,xlas=2)


## ----fig.height=6,fig.width=12, warning=F-------------------------------------

grid.arrange(vis_reg(best_model_lasso,eff_size_diff=c(1,3),         # Q2 - minimum
                     glmnet_fct_var="Originnon-USA")$"SidebySide")  # note the naming pattern for categorical variables
    


## ----fig.height=6,fig.width=12, warning=F-------------------------------------

plt_1=vis_reg(best_model_lasso,eff_size_diff=c(1,3),
              glmnet_fct_var="Originnon-USA")$"PerUnitVis"+
              ggtitle("Visualization of CV.GLMNET Results (per unit change)")+
              ylim(-4,4)+
              xlab("Car characteristics")+
              ylab("LASSO coefficients")+
              theme_bw()+
              scale_fill_manual(values = c("red","whitesmoke" ))+                            
              theme(plot.title = element_text(hjust = 0.5))   

plt_2=vis_reg(best_model_lasso, eff_size_diff=c(1,3), 
              glmnet_fct_var="Originnon-USA")$"RealizedEffectVis"+
              ggtitle("Visualization of CV.GLMNET Results (effective:min --> Q2)")+
              ylim(-15,15)+        
              xlab("Car characteristics")+
              ylab("LASSO coefficients")+
              theme_bw()+
              scale_fill_manual(values = c("maroon1","palegreen1" ))+                            
              theme(plot.title = element_text(hjust = 0.5))   

plt_3=arrangeGrob(plt_1,plt_2, nrow=1, widths = c(1,1))

grid.arrange(plt_3)


## -----------------------------------------------------------------------------

# ?jasa

heart_df=as.data.frame(survival::jasa)

heart_df_filtered = heart_df %>%filter(!rowSums(is.na(.)))                      # remove rows containing NaN values

# check last 6 rows of the data frame
tail(heart_df_filtered)


## ----fig.height=6,fig.width=12, warning=F-------------------------------------

# filtered data only contains patients who received a transplant,
sum(heart_df_filtered$transplant!=1)

# mismatch scores are weakly correlated,
print('Correlation between mismatch scores:')
cor(heart_df_filtered$mscore,heart_df_filtered$mismatch)

# if rejection occurs, the death is certain, at least, in this data set
heart_cont_table=table(heart_df_filtered$reject,heart_df_filtered$fustat)
dimnames(heart_cont_table) =list(
  Reject = c("No", "Yes"), 
  Status = c("Alive", "Deceased")
  )
heart_cont_table
                       
# 'age' is skewed variable with a very big range
paste("Range of '\ age \' variable is : ",diff(range(heart_df_filtered$age)))

old_par = par()      
par(mfrow=c(2,2))
hist(heart_df_filtered$age, main="Histogram of Age", xlab="age")
boxplot(heart_df_filtered$age,main="Boxplot of Age", ylab="age")
hist(sqrt(heart_df_filtered$age),main="Histogram of transformed data", xlab="Sqrt(age)")
boxplot(sqrt(heart_df_filtered$age),main="Boxplot of transformed data", ylab="Sqrt(age)")
par(old_par)          


## -----------------------------------------------------------------------------

# observe that age variable is not rounded

# it is calculated in the following manner
age_calc_example=difftime(heart_df_filtered$accept.dt, 
                          heart_df_filtered$birth.dt,units = "days")/365.25

# check the first calculated value
age_calc_example[1]==heart_df_filtered[1,]$age

# check randomly selected value
n_samp=sample(dim(heart_df_filtered)[1],1)
age_calc_example[n_samp]==heart_df_filtered[n_samp,]$age

# check 5 point summary 
heart_df_filtered$age%>%summary()

# check 5 point summary for data rounded down to the nearest integer
heart_df_filtered$age%>%floor()%>%summary()


## -----------------------------------------------------------------------------

# reject categorical variable in not included due to the reason previously stated
heart_df_filtered = heart_df_filtered %>%
  mutate(across(all_of(c("surgery")), as.factor))

# apply 'sqrt()' transformation to 'age' variable
heart_df_filtered$sqrt.age=sqrt(heart_df_filtered$age)

y_heart=heart_df_filtered$fustat

x_heart=model.matrix(as.formula(paste("~",
         paste(c("sqrt.age" ,"mismatch","mscore", "surgery"),collapse = "+"),
         sep = "")), data=heart_df_filtered)

x_heart=x_heart[, -1]
x_heart_orig=x_heart                                                            # save original data set
x_heart=scale(x_heart,T,T)                                                    

gfit_heart = cv.glmnet(x_heart,y_heart,standardize=F,family="binomial")

lambda_heart=gfit_heart$lambda.min
n_heart=dim(x_heart)[1]

beta_hat_heart=coef(gfit_heart, x=x_heart, y=y_heart, s=lambda_heart, exact=T)

# note that lambda should be multiplied by the number of rows
out_heart = fixedLassoInf(x_heart,y_heart,beta_hat_heart,lambda_heart*n_heart,
                          family="binomial")
#check the output
out_heart

# note the class
class(out_heart)


## -----------------------------------------------------------------------------
 
# back transformation logic
 x_heart_reconstructed = t(apply(x_heart, 1, function(x) 
   x*attr(x_heart,'scaled:scale') + attr(x_heart, 'scaled:center')))

 # check
 all.equal(x_heart_orig,x_heart_reconstructed)
 
 # same via a function
 x_heart_reconstructed.2=detransform(x_heart)
 all.equal(x_heart_orig,x_heart_reconstructed.2)


## ----fig.height=6,fig.width=12, warning=F-------------------------------------

grid.arrange(vis_reg(out_heart, CI=T, glmnet_fct_var=c("surgery1"), 
                     round_func="none",eff_size_diff=c(1,3))$"SidebySide"
             )


## -----------------------------------------------------------------------------

set.seed(43)
n = 50
p = 10
sigma = 1
x = matrix(rnorm(n*p),n,p)
x=scale(x,TRUE,TRUE)
beta = c(3,2,rep(0,p-2))
y = x%*%beta + sigma*rnorm(n)
pf=c(rep(1,7),rep(.1,3)) #define penalty factors
pf=p*pf/sum(pf) # penalty factors should be rescaled so they sum to p
xs=scale(x,FALSE,pf) #scale cols of x by penalty factors
# first run glmnet
gfit = glmnet(xs, y, standardize=FALSE)
# extract coef for a given lambda; note the 1/n factor!
# (and we don't save the intercept term)
lambda = .8
beta_hat = coef(gfit, x=xs, y=y, s=lambda/n, exact=TRUE)[-1]
# compute fixed lambda p-values and selection intervals
out = fixedLassoInf(xs,y,beta_hat,lambda,sigma=sigma)
#rescale conf points to undo the penalty factor
out$ci=t(scale(t(out$ci),FALSE,pf[out$vars]))
out


## -----------------------------------------------------------------------------

pf_heart=c(0.3, 0.1,0.1,0.1)
p_l=length(pf_heart)
pf_heart=p_l*pf_heart/sum(pf_heart)

xs_heart_res=scale(x_heart,FALSE,pf_heart)                                      # note that the data is being scaled again

gfit_heart_pef_fac_res = cv.glmnet(xs_heart_res, y_heart, standardize=FALSE, 
                                   family="binomial")

lambda_heart_pef_fac_res=gfit_heart_pef_fac_res$lambda.min

beta_hat_heart_res=coef(gfit_heart_pef_fac_res, x=xs_heart_res, y=y_heart,
                        s=lambda_heart_pef_fac_res, exact=F)

out_heart_res = fixedLassoInf(xs_heart_res,y_heart,beta_hat_heart_res,
                              lambda_heart_pef_fac_res*n_heart,family="binomial")

out_heart_res$ci=t(scale(t(out_heart_res$ci),FALSE,pf_heart[out_heart_res$vars]))

out_heart_res


## ----fig.height=6,fig.width=12, warning=F-------------------------------------

x_heart_test_3=detransform(xs_heart_res, attr_center=NULL)

x_heart_test_3=detransform(x_heart_test_3,
                           attr_scale=attr(x_heart, 'scaled:scale'),
                           attr_center=attr(x_heart, 'scaled:center')
                           )
# check
all.equal(x_heart_test_3,x_heart_orig)


## ----fig.height=6,fig.width=12,warning=F--------------------------------------

# note that case_penalty=T and x_data_orig must be specified

# effective change between Q1(2) and max(5)
grid.arrange(vis_reg(out_heart_res, CI=T, glmnet_fct_var=c("surgery1"), 
                     case_penalty=T, x_data_orig=x_heart_orig,
                     eff_size_diff=c(2,5))$"SidebySide")


