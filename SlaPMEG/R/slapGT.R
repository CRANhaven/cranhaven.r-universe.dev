#' @title Run step II via globaltest package
#'
#' @description Globaltest is used to test the association between phenotype variable and
#' estimated random effects from step I.
#'
#' @param EBS  Estimated random effects by either joint or pairwise approach
#'
#' @param data_inf  Dataframe with variables required for the test
#'
#' @param rand_nam  Names of random effects defined in model
#'
#' @param Ynames  Name of omics in pathway
#'
#' @param grouping Name of the covariate representing the grouping by the phenotype
#'
#' @param Emethod Estimation method for the random effects which is either joint or pairwise
#'
#' @return A GT object containing globaltest results
#'
#' @author Mitra Ebrahimpoor
#'
#' \email{m.ebrahimpoor@@lumc.nl}
#'
#' @importFrom globaltest gt

slapGT<-function(EBS, data_inf, rand_nam, Ynames, grouping, Emethod){

  #get the gt model
  gr<-data_inf[,grouping]
  if(length(levels(gr))<2){stop("Grouping variable should have at leat 2 levels.")}
  if(length(levels(gr))==2)  gtmod ="logistic"
  if(length(levels(gr))>2)  gtmod ="multinomial"

  ##gt for joint approach
  if(Emethod=="joint"){

  formula_gtp<-formula(paste0("~",paste0(rand_nam,collapse = "+"),"+",paste0(Ynames,collapse ="+")))

  joint_gt<-globaltest::gt(data_inf[,grouping], formula_gtp, data=EBS, permutations=1e5, model =gtmod)
  gt_obj<-c(joint_gt@result[,1],joint_gt@result[,2],joint_gt@result[,3],
            joint_gt@result[,4],joint_gt@result[,5])
  names(gt_obj)<-c("p-value","Statistic","Expected","Std.dev","Cov")

  }

  ##gt for pairwise approach
  if(Emethod=="pairwise"){
    formula_gtp<-formula(paste0("~",
                                paste0(rand_nam,collapse = "+"),"+",
                                paste0(Ynames,collapse ="+")))

    pair_gt<-globaltest::gt(data_inf[,grouping], formula_gtp, data=EBS, permutations=1e5, model =gtmod)
    gt_obj<-c(pair_gt@result[,1],pair_gt@result[,2],pair_gt@result[,3],
              pair_gt@result[,4],pair_gt@result[,5])
    names(gt_obj)<-c("p-value","Statistic","Expected","Std.dev","Cov")
  }

  gt_obj<-c(gt_obj,GT.model=gtmod)

  return(gt_obj)

}



