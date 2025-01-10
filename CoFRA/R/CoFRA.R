
#'  get named vector with functional categories
#' @param func string ("BP","CC","MF")
#' @keywords Gene ontology
#' @examples
#' library(CoFRA)
#' Acc=getFunctionalCategories(func="CC")
#' @export
getFunctionalCategories <- function(func = "CC") {
if (func == "BP") {
funcU = BP
}
if (func == "CC") {
funcU = CC
}
if (func == "MF") {
funcU = MF
}
return(funcU)  # invisible()
}


#' This function filter a data frame on column named "pro"
#' @param dfPro data frame with iBAQ values
#' @param filter character vector with items to remove
#' @keywords filter
#' @examples
#' library(CoFRA)
#' data(iBAQ)
#' iBAQ2=filterData(iBAQ,">CON") # filter headers starting with >CON
#' @export
filterData <- function(dfPro,filter){
if (base::is.data.frame(dfPro)==F)
{
stop("Data frame expected for dfPro")
}
if (length(which(names(dfPro)=="pro"))==0)
{
stop("Column named 'pro' expected")
}
if (base::is.character(filter)==F)
{
stop("Character expected for filter")
}

li="("
for (i in 1:length(filter)){
if (i!=length(filter)) {
li=paste(li,"^(",filter[i],")|",sep="")
}
if (i==length(filter)) {
li=paste(li,"^(",filter[i],"))",sep="")}
}
sel=grep(li, dfPro$pro,invert = T)
res=dfPro[sel,]
return(res)
}


phyperSets <- function(Query,Ref,Nbackground){
NumberOfMatch=length(base::intersect(Query,Ref))
NumberInCat=length(Ref)
res=data.frame(NumberOfMatch=NumberOfMatch,NumberInCat=NumberInCat,Genes=paste(base::intersect(Query,Ref),collapse=" "),Pvalue=1-stats::phyper(NumberOfMatch,NumberInCat,Nbackground-NumberInCat,length(Query)))
return(res) 
}


mapAc2Func <- function(AcList,funcL,NbackGround=length(unique(unlist(funcL)))){
#
vecL=lapply(funcL,phyperSets,Query=AcList,Nbackground=NbackGround)
res=base::as.data.frame(base::do.call(base::rbind, vecL))
res$Cat=base::rownames(res)
#
res$FDR=stats::p.adjust(res$Pvalue,"fdr")
res$holm=stats::p.adjust(res$Pvalue,"holm")
res$BH=stats::p.adjust(res$Pvalue,"BH")
res=res[order(res$"NumberOfMatch",decreasing =T),]
res=res[order(res$Pvalue),]
return(res)
}

functionalAnalysisOfAcList <- function(Ac,funcL,TopProteins=1000,Max=100,
NbackGround=length(unique(unlist(funcL))),MinHits=10,FDR=0.000001){
if (TopProteins>0)
{
res=mapAc2Func(Ac[1:TopProteins],funcL,NbackGround)
} else {
res=mapAc2Func(Ac,funcL,NbackGround)
}
#names(res)=names(Ac)
if (MinHits<=0)
{
if (Max>0){
res=res[1:Max,]
}
} else {
if (FDR>0) {
res=res[res$"NumberOfMatch">MinHits & res$"FDR"<FDR,]
} else {
res=res[res$"NumberOfMatch">MinHits,]
}
}
return(res)
}

functionalAnalysisOfAcListOfList <- function(AcL,funcL,TopProteins=1000,Max=100,
NbackGround=length(unique(unlist(funcL))),MinHits=10,FDR=0.000001,no_cores=-1){ 
if (no_cores>-1){
e=new.env()
e$funcL=funcL
e$TopProteins=TopProteins
e$Max=Max
e$NbackGround=NbackGround
e$MinHits=MinHits
e$FDR=FDR
e$mapAc2Func=mapAc2Func
e$phyperSets=phyperSets
if (no_cores==0){
no_cores <- parallel::detectCores()-1
}
# Initiate cluster
cl <- parallel::makeCluster(no_cores)
parallel::clusterEvalQ(cl, library(stats))
parallel::clusterExport(cl,varlist=c("AcL","funcL","TopProteins","Max",
"NbackGround","MinHits","FDR","mapAc2Func","phyperSets"),envir =e) 
res=parallel::parLapply(cl,AcL,functionalAnalysisOfAcList,funcL=funcL,
TopProteins=TopProteins,Max=Max,NbackGround=NbackGround,MinHits=MinHits,FDR=FDR) 
parallel::stopCluster(cl)} else {
res=lapply(AcL,functionalAnalysisOfAcList,funcL=funcL,TopProteins=TopProteins,Max=Max,NbackGround=NbackGround,MinHits=MinHits,FDR=FDR)
}
#
return(res)
}



EnrichmentAnalysisFromDFcompleteAnnotation <- function(df,funcL,Fac,DFcompare,NbackGround=length(unique(unlist(funcL))),no_cores=-1){
ProL=list()
for (i in 1:nrow(DFcompare)){
if (gregexpr(",",DFcompare[i,1])[[1]][1]==-1){
idxL1=which(DFcompare[i,1]==as.character(Fac))
idxL2=which(DFcompare[i,2]==as.character(Fac))
} else {
tmp=unlist(strsplit(DFcompare[i,1],","))
idxL1=c()
for (l in 2:length(tmp)){
idxL1=append(idxL1,which(tmp[l]==as.character(Fac)))
}
DFcompare[i,1]=tmp[1]
#
tmp=unlist(strsplit(DFcompare[i,2],","))
idxL2=c()
for (l in 2:length(tmp)){
idxL2=append(idxL2,which(tmp[l]==as.character(Fac)))
}
DFcompare[i,2]=tmp[1]
}
#
idxL=append(idxL1,idxL2)
dfSub=df[,idxL]
#
sel=apply(dfSub,1,max)>0
#
pro=df$pro[sel]
if (stringr::str_count(pro, "\\|")[1]>=2){
pro=lapply(stringr::str_split(pro,"\\|"),'[[',2)
}
ProL[[length(ProL)+1]]=pro #
names(ProL)[length(ProL)]=paste(DFcompare[i,2]," vs ",DFcompare[i,1])
}
# enrichment
res=functionalAnalysisOfAcListOfList(ProL,funcL,TopProteins=-1,Max=-1,NbackGround=NbackGround,MinHits=-1,no_cores=no_cores)
return(res)
}

MergeDFlist <- function(dfL,keyCol,valueCol){
tmpL=dfL[[1]][,keyCol]
for (i in 2:length(dfL)){
tmpL=append(tmpL,dfL[[i]][,keyCol])
tmpL=unique(tmpL)
}
mat=matrix(0,nrow=length(tmpL),ncol=length(dfL))
res=as.data.frame(mat)
rownames(res)=tmpL
names(res)=names(dfL)
for (i in 1:length(dfL)){
df=dfL[[i]]
for (j in 1:nrow(df)){
idx=which(rownames(res)==df[j,keyCol])
res[idx,i]=df[j,valueCol]
}
}
return(res)
}

t.testPvalue <- function(...) {
obj<-try(stats::t.test(...), silent=TRUE)
if (methods::is(obj, "try-error")) return(NA) else return(obj$p.value)}

wilcox.testPvalue  <- function(...) {
obj<-try(wilcox.test(...), silent=TRUE)
if (is(obj, "try-error")) return(NA) else return(obj$p.value)}

TtestAndLogRatioForOneCategory <- function(Func,df,Fac,DFcompare,Test="t.test"){
tmp=Func;tmp=tmp[tmp!=""]
if (length(tmp)>0) {
dfSub=as.matrix(df[rownames(df) %in% tmp,1:length(Fac)])
# compare with tests
res=list(res=c(),res2=c(),res3=c(),res4=c())
for (i in 1:nrow(DFcompare)){
#
if (gregexpr(",",DFcompare[i,1])[[1]][1]==-1){
idxL1=which(DFcompare[i,1]==as.character(Fac))
idxL2=which(DFcompare[i,2]==as.character(Fac))
} else {
# merge samples groups
tmp=unlist(strsplit(DFcompare[i,1],","))
idxL1=c()
for (l in 2:length(tmp)){
idxL1=append(idxL1,which(tmp[l]==as.character(Fac)))
}
#
tmp=unlist(strsplit(DFcompare[i,2],","))
idxL2=c()
for (l in 2:length(tmp)){
idxL2=append(idxL2,which(tmp[l]==as.character(Fac)))
}
#
}
# counts
Nsub=0
if (!is.null(dfSub)){
if (nrow(dfSub)>0){
dfSubC1=dfSub[,idxL1,drop=FALSE] 
for (k in 1:nrow(dfSubC1)){
ok=F
for (m in 1:ncol(dfSubC1)){
if (dfSubC1[k,m]>0){ok=T;break}
}
if (ok==T){Nsub=Nsub+1}
}
}
}
#res3[j,i]=Nsub
res[["res3"]]=append(res[["res3"]],Nsub)
#
if (!is.null(dfSub)){
if (nrow(dfSub)>0){
dfSubC2=dfSub[,idxL2,drop=FALSE]
Nsub=0
for (k in 1:nrow(dfSubC2)){
ok=F
for (m in 1:ncol(dfSubC2)){
if (dfSubC2[k,m]>0){ok=T;break}
}
if (ok==T){Nsub=Nsub+1}
}
}
}
#res4[j,i]=Nsub
res[["res4"]]=append(res[["res4"]],Nsub)
# end counts
Con=mean(as.vector(dfSub[,idxL1]))
Tre=mean(as.vector(dfSub[,idxL2]))
#res2[j,i]=Tre-Con
res[["res2"]]=append(res[["res2"]],Tre-Con)
if (Test=="t.test"){
Pvalue=t.testPvalue(as.vector(dfSub[,idxL1]),as.vector(dfSub[,idxL2]),paired=TRUE) # paired since same group of proteins from two different conditions
} else {
Pvalue=wilcox.testPvalue(as.vector(dfSub[,idxL1]),as.vector(dfSub[,idxL2]),paired=TRUE) # paired since same group of proteins from two different conditions
}
if (is.na(Pvalue)==T){
#res[j,i]=0
res[["res"]]=append(res[["res"]],0)
} else {
if (Tre>=Con){
#res[j,i]=1-Pvalue
res[["res"]]=append(res[["res"]],1-Pvalue)
} else {
#res[j,i]=Pvalue-1
res[["res"]]=append(res[["res"]],Pvalue-1)
}
}
}
}
return(res)
}



TtestAndLogRatiosStatCompare2 <- function(df,funcL,Fac,DFcompare,ColNorm=T,Test="t.test",no_cores=no_cores){
df[,1:length(Fac)]=do.call(data.frame,lapply(df[,1:length(Fac)], function(x) replace(x, is.infinite(x),NA)))
df[is.na(df)]=max(df[,1:length(Fac)],na.rm =T)
df[,1:length(Fac)]=log2(df[,1:length(Fac)]+1)
if (ColNorm==T){
colSumL=colSums(df[,1:length(Fac)])
MaxColSum=max(colSumL)
colSumL=colSumL/MaxColSum
}
pro=df$pro
if (stringr::str_count(pro, "\\|")[1]>=2){
pro=lapply(stringr::str_split(pro,"\\|"),'[[',2)}
rownames(df)=pro
print("Row names assigned")
if (ColNorm==T){
df[,1:length(Fac)]=sweep(df[,1:length(Fac)],MARGIN=2,colSumL,"/")
}
res5=matrix(1,nrow=length(funcL),ncol=nrow(DFcompare))
# compare over all categories
if (no_cores==-1){
resT=lapply(funcL,TtestAndLogRatioForOneCategory,df=df,Fac=Fac,DFcompare=DFcompare,Test=Test)
}
if (no_cores>-1){
e=new.env()
e$funcL=funcL
e$df=df
e$Fac=Fac
e$DFcompare=DFcompare
e$Test=Test
e$t.testPvalue=t.testPvalue
e$wilcox.testPvalue=wilcox.testPvalue
if (no_cores==0){
no_cores <- parallel::detectCores()-1
}
# Initiate cluster
cl <- parallel::makeCluster(no_cores)
parallel::clusterEvalQ(cl, library(stats))
parallel::clusterExport(cl,varlist=c("funcL","df","Fac","DFcompare",
"Test","t.testPvalue","wilcox.testPvalue"),envir =e) 
resT=parallel::parLapply(cl,funcL,TtestAndLogRatioForOneCategory,df=df,Fac=Fac,DFcompare=DFcompare,Test=Test)
parallel::stopCluster(cl)
}
res=lapply(resT,'[[',"res")
res=as.data.frame(do.call(rbind, res))
res2=lapply(resT,'[[',"res2");res2=as.data.frame(do.call(rbind, res2))
#print(lapply(resT,'[[',"res3"))
res3=lapply(resT,'[[',"res3");res3=as.data.frame(do.call(rbind, res3))
res4=lapply(resT,'[[',"res4");res4=as.data.frame(do.call(rbind, res4))
#
# end over categories
res=as.data.frame(res)
lev=c()
for (i in 1:nrow(DFcompare)){
if (gregexpr(",",DFcompare[i,1])[[1]][1]==-1){
lev=append(lev,paste(DFcompare[i,2],DFcompare[i,1],sep=" vs "))} else {
lev=append(lev,paste(unlist(strsplit(DFcompare[i,2],","))[1],
unlist(strsplit(DFcompare[i,1],","))[1],sep=" vs "))
}
}
names(res)=lev
rownames(res)=names(funcL) # funcDF[,1]
# print(res2)
res2=as.data.frame(res2)
names(res2)=lev
rownames(res2)=names(funcL) # funcDF[,1]
#
res3=as.data.frame(res3)
res4=as.data.frame(res4)
rownames(res3)=names(funcL) # funcDF[,1]
rownames(res4)=names(funcL) # funcDF[,1]
names(res3)=lev
names(res4)=lev
# max of res3 and res4
for (i in 1:ncol(res3)){
for (j in 1:nrow(res3)){
res5[j,i]=max(res3[j,i],res4[j,i])
}
}
res5=as.data.frame(res5)
names(res5)=lev
rownames(res5)=names(funcL) # funcDF[,1]
#
res=list(res,res2,res3,res4,res5)
#
names(res)=c("P value","log ratios","Counts1","Counts2","MaxCounts")
return(res)
}


filterUpDownPvalue <- function(df){
dFrame=TRUE
if (class(df)=="list"){
dFrame=FALSE
dfA=df
df=df[[1]]
}
for (i in 1:ncol(df)){
posi=df[,i]>=0
for (j in 1:nrow(df)){
if (df[j,i]>=0){
df[j,i]=1-df[j,i]
} else {
df[j,i]=1+df[j,i]
}
}
df[,i]=stats::p.adjust(df[,i],"fdr")
for (j in 1:nrow(df)){
if (posi[j]==T){
df[j,i]=1-df[j,i]
} else {
df[j,i]=df[j,i]-1
}
}
}
#
sel=c()
for (i in 1:nrow(df)){
if (dFrame==TRUE){
tes=any(as.numeric(df[i,])<(-0.95)) | any(as.numeric(df[i,])>0.95)
}
if (dFrame==FALSE){
tes=(any(as.numeric(df[i,])<(-0.95)) & any(as.numeric(dfA[[2]][i,])<=-1)) | (any(as.numeric(df[i,])>0.95) & any(as.numeric(dfA[[2]][i,])>=1)) # any(as.numeric(dfA[[2]][i,])<=-1) | any(as.numeric(dfA[[2]][i,])>=1)
}
sel=append(sel,tes)
}
if (dFrame==TRUE){
res=df[sel,]
}
if (dFrame==FALSE){
res=list()
res[[length(res)+1]]=df[sel,]
res[[length(res)+1]]=dfA[[2]][sel,]
res[[length(res)+1]]=dfA[[3]][sel,]
res[[length(res)+1]]=dfA[[4]][sel,]
res[[length(res)+1]]=dfA[[5]][sel,]
}
names(res)=c("P values","log ratios","Counts1","Counts2","Max Counts")
return(res)
}

filterDFL <- function(dfL,idxdfL,threshold){
df=dfL[[idxdfL]]
sel=c()
for (i in 1:nrow(df)){
if (max(as.numeric(df[i,]))>=threshold){sel=append(sel,TRUE)} else {sel=append(sel,FALSE)}
}
res=dfL
for (i in 1:length(dfL)){
res[[i]]=dfL[[i]][sel,,drop=F]
}
return(res)
}

colorCodeValuesInDFlist <- function(dfL,idx){
colL=gplots::greenred(5)
res=matrix(colL[3],nrow=nrow(dfL[[idx]]),ncol=ncol(dfL[[idx]]))
df=dfL[[idx]]
for (i in 1:nrow(df)){
for (j in 1:ncol(df)){
if (df[i,j]>=1){res[i,j]=colL[5]}
if (df[i,j]<1 & df[i,j]>=0.4){res[i,j]=colL[4]}
if (df[i,j]<0.4 & df[i,j]>=(-0.4)){res[i,j]=colL[3]}
if (df[i,j]<(-0.4) & df[i,j]>=(-1)){res[i,j]=colL[2]}
if (df[i,j]<=(-1)){res[i,j]=colL[1]}
}
}
res=as.data.frame(res)
names(res)=names(df)
rownames(res)=rownames(df)
dfL[[length(dfL)+1]]=res
names(dfL)[length(dfL)]="color code"
res=dfL
return(res)
}

AddEnrichmentSignificanceTodfLresult <- function(dfL,dfEnrichment){
res=matrix(0,nrow=nrow(dfL[[1]]),ncol=ncol(dfL[[1]]))
for (i in 1:nrow(dfL[[1]])){
idx=which(rownames(dfL[[2]])[i]==rownames(dfEnrichment))
res[i,]=as.numeric(dfEnrichment[idx,])
}
# create df
res=as.data.frame(res)
rownames(res)=rownames(dfL[[1]])
names(res)=names(dfL[[1]])
dfL[[length(dfL)+1]]=res
names(dfL)[length(dfL)]="Significance of enrichment"
res=dfL
return(res)
}

CombineMaxCountWithEnrcihmentSignificance <- function(dfL,ThresholdCount=2){
res=dfL[["Max Counts"]]
dfS=dfL[["Significance of enrichment"]] # now add significance as *
for (i in 1:nrow(res)){
for (j in 1:ncol(res)){
if (dfS[i,j]<0.05 & dfL[["Max Counts"]][i,j]>ThresholdCount){res[i,j]=paste(res[i,j],"*",sep="")}
}
}
dfL[[length(dfL)+1]]=res # add to dfL
names(dfL)[length(dfL)]="Significance of enrichment combined with max count"
res=dfL
return(res)
}


#' This function performs complete functional regulation analysis
#' @param dfPro data frame with quantitative values
#' @param func data frame defining which gene ontology to use "BP","CC","MF"
#' @param Fac factor describing the sample groups
#' @param dfComp df containing the comparisons to perform
#' @param NbackGround integer number of total proteins
#' @param DataExtract string which P value correction to use
#' @param minCounts integer minimum number of matching genes for functional category
#' @param Test "t.test" or "wilcox.test"
#' @param no_cores =-1 (no parelle execution) =0 (number of availble cores -1) >0 (use number of cores)
#' @keywords heatmap
#' @examples
#' library(CoFRA)
#' data(iBAQ)
#' Fac=factor(c("MCCTT","MCCTT","MCCTT","MCCT","MCCT","MCCT","MC","MC","MC","MCT","MCT","MCT",
#' "MTT","MTT","MTT","MT","MT","MT","sN","sN","sN","sNT","sNT","sNT","iN","iN","iN","iNT","iNT","iNT"))
#' dfComp=data.frame(Con=c("MCCT","MT","MC","iN","sN","AllC,MCCT,MT,MC,iN,sN"),Tre=c("MCCTT","MTT",
#' "MCT","iNT","sNT","AllT,MCCTT,MTT,MCT,iNT,sNT"))
#' Func=CoFRA::getFunctionalCategories("CC")
#' head(str(Func))
#' CC1=CoFRA::completeFunctionalRegulationAnalysis(iBAQ,Func[100:200],Fac,dfComp,NbackGround=142140) 
#' @export
completeFunctionalRegulationAnalysis <- function(dfPro,func,Fac,dfComp,NbackGround=length(unique(unlist(func))),
DataExtract="FDR",minCounts=10,Test="t.test",no_cores=-1){
if (is.matrix(dfPro)==T){dfPro=as.data.frame(dfPro);dfPro$pro=rownames(dfPro)}
if (is.data.frame(dfPro)==F | base::missing(dfPro)){stop("dfPro is expected to be data frame")}
if (sum(names(dfPro)=="pro")!=1){stop("dfPro needs a column named 'pro' containing UniProt FASTA headers or UniProt accession numbers")}
if (is.list(func)==F | base::missing(func)){stop("func is expected to be list")}
if (is.factor(Fac)==F | base::missing(Fac)){stop("Fac is expected to be factor")}
if (is.data.frame(dfComp)==F | base::missing(dfComp)){stop("dfComp is expected to be data frame")}
if (is.numeric(NbackGround)==F){stop("NbackGround is expected to be numeric")}
if (is.character(DataExtract)==F){stop("DataExtract is expected to be character")}
if (is.character(Test)==F){stop("Test is expected to be character")}
if (is.numeric(minCounts)==F){stop("minCounts is expected to be numeric")}
pro=dfPro$pro
if (stringr::str_count(pro, "\\|")[1]>=2){
pro=lapply(stringr::str_split(pro,"\\|"),'[[',2)}
dfPro$pro=pro
# check mapping
print(paste(sum(dfPro$pro %in% unique(unlist(func)))/nrow(dfPro)*100,"% of entities could be mapped"))
#
funcU=func
dfComp[,1]=as.character(dfComp[,1])
dfComp[,2]=as.character(dfComp[,2])
#
EF=EnrichmentAnalysisFromDFcompleteAnnotation(dfPro,funcU,Fac,dfComp,NbackGround=NbackGround,no_cores=no_cores)
EF=MergeDFlist(EF,"Cat",DataExtract)
#
Q=TtestAndLogRatiosStatCompare2(dfPro,funcU,Fac,dfComp,ColNorm=T,Test=Test,no_cores=no_cores)
Q=filterUpDownPvalue(Q)
Q=filterDFL(Q,5,minCounts) # matrix 5 for filtering
#
Q=colorCodeValuesInDFlist(Q,2)
Q=AddEnrichmentSignificanceTodfLresult(Q,EF)
Q=CombineMaxCountWithEnrcihmentSignificance(Q)
#
res=Q
res[[length(res)+1]]=EF
names(res)[length(res)]="Complete enrichment"
class(res)="CompleteEnrichment"
return(res)
}


# the heatmap.3 function was extented from "source_url("https://raw.githubusercontent.com/obigriffith/biostar-tutorials/master/Heatmaps/heatmap.3.R")"
# no license was found for the original heatmap.3 function

heatmap.3 <- function(x,
                      Rowv = TRUE, Colv = if (symm) "Rowv" else TRUE,
                      distfun = stats::dist,
                      hclustfun = stats::hclust,
                      dendrogram = c("both","row", "column", "none"),
                      symm = FALSE,
                      scale = c("none","row", "column"),
                      na.rm = TRUE,
                      revC = identical(Colv,"Rowv"),
                      add.expr,
                      breaks,
                      symbreaks = max(x < 0, na.rm = TRUE) || scale != "none",
                      col = "heat.colors",
                      colsep,
                      rowsep,
                      sepcolor = "white",
                      sepwidth = c(0.05, 0.05),
                      cellnote,
                      notecex = 1,
                      notecol = "cyan",
                      na.color = graphics::par("bg"),
                      trace = c("none", "column","row", "both"),
                      tracecol = "cyan",
                      hline = stats::median(breaks),
                      vline = stats::median(breaks),
                      linecol = tracecol,
                      margins = c(5,5),
                      ColSideColors,
                      RowSideColors,
                      ColSideCex=1,
                      side.height.fraction=0.3,
                      cexRow = 0.2 + 1/log10(nr),
                      cexCol = 0.2 + 1/log10(nc),
                      labRow = NULL,
                      labCol = NULL,
                      key = TRUE,
                      keysize = 1.5,
                      density.info = c("none", "histogram", "density"),
                      denscol = tracecol,
                      symkey = max(x < 0, na.rm = TRUE) || symbreaks,
                      densadj = 0.25,
                      main = NULL,
                      xlab = NULL,
                      ylab = NULL,
                      lmat = NULL,
                      lhei = NULL,
                      lwid = NULL,
                      ColSideColorsSize = 1,
                      RowSideColorsSize = 1,
                      KeyValueName="Value",
                      barTitle="",...){
grid::gpar(lheight=0.8) 
graphics::par(lheight=0.8) 
    invalid <- function (x) {
      if (missing(x) || is.null(x) || length(x) == 0)
          return(TRUE)
      if (is.list(x))
          return(all(sapply(x, invalid)))
      else if (is.vector(x))
          return(all(is.na(x)))
      else return(FALSE)
    }
 
    x <- as.matrix(x)
    scale01 <- function(x, low = min(x), high = max(x)) {
        x <- (x - low)/(high - low)
        x
    }
    retval <- list()
    scale <- if (symm && missing(scale))
        "none"
    else match.arg(scale)
    dendrogram <- match.arg(dendrogram)
    trace <- match.arg(trace)
    density.info <- match.arg(density.info)
    if (length(col) == 1 && is.character(col))
        col <- get(col, mode = "function")
    if (!missing(breaks) && (scale != "none"))
        warning("Using scale=\"row\" or scale=\"column\" when breaks are",
            "specified can produce unpredictable results.", "Please consider using only one or the other.")
    if (is.null(Rowv) || is.na(Rowv))
        Rowv <- FALSE
    if (is.null(Colv) || is.na(Colv))
        Colv <- FALSE
    else if (Colv == "Rowv" && !isTRUE(Rowv))
        Colv <- FALSE
    if (length(di <- dim(x)) != 2 || !is.numeric(x))
        stop("`x' must be a numeric matrix")
    nr <- di[1]
    nc <- di[2]
    if (nr <= 1 || nc <= 1)
        stop("`x' must have at least 2 rows and 2 columns")
    if (!is.numeric(margins) || length(margins) != 2)
        stop("`margins' must be a numeric vector of length 2")
    if (missing(cellnote))
        cellnote <- matrix("", ncol = ncol(x), nrow = nrow(x))
    if (!inherits(Rowv, "dendrogram")) {
        if (((!isTRUE(Rowv)) || (is.null(Rowv))) && (dendrogram %in%
            c("both", "row"))) {
            if (is.logical(Colv) && (Colv))
                dendrogram <- "column"
            else dedrogram <- "none"
            warning("Discrepancy: Rowv is FALSE, while dendrogram is `",
                dendrogram, "'. Omitting row dendogram.")
        }
    }
    if (!inherits(Colv, "dendrogram")) {
        if (((!isTRUE(Colv)) || (is.null(Colv))) && (dendrogram %in%
            c("both", "column"))) {
            if (is.logical(Rowv) && (Rowv))
                dendrogram <- "row"
            else dendrogram <- "none"
            warning("Discrepancy: Colv is FALSE, while dendrogram is `",
                dendrogram, "'. Omitting column dendogram.")
        }
    }
    if (inherits(Rowv, "dendrogram")) {
        ddr <- Rowv
        rowInd <- stats::order.dendrogram(ddr)
    }
    else if (is.integer(Rowv)) {
        hcr <- hclustfun(distfun(x))
        ddr <- stats::as.dendrogram(hcr)
        ddr <- stats::reorder(ddr, Rowv)
        rowInd <- stats::order.dendrogram(ddr)
        if (nr != length(rowInd))
            stop("row dendrogram ordering gave index of wrong length")
    }
    else if (isTRUE(Rowv)) {
        Rowv <- rowMeans(x, na.rm = na.rm)
        hcr <- hclustfun(distfun(x))
        ddr <- stats::as.dendrogram(hcr)
        ddr <- stats::reorder(ddr, Rowv)
        rowInd <- stats::order.dendrogram(ddr)
        if (nr != length(rowInd))
            stop("row dendrogram ordering gave index of wrong length")
    }
    else {
        rowInd <- nr:1
    }
    if (inherits(Colv, "dendrogram")) {
        ddc <- Colv
        colInd <- stats::order.dendrogram(ddc)
    }
    else if (identical(Colv, "Rowv")) {
        if (nr != nc)
            stop("Colv = \"Rowv\" but nrow(x) != ncol(x)")
        if (exists("ddr")) {
            ddc <- ddr
            colInd <- stats::order.dendrogram(ddc)
        }
        else colInd <- rowInd
    }
    else if (is.integer(Colv)) {
        hcc <- hclustfun(distfun(if (symm)
            x
        else t(x)))
        ddc <- stats::as.dendrogram(hcc)
        ddc <- stats::reorder(ddc, Colv)
        colInd <- stats::order.dendrogram(ddc)
        if (nc != length(colInd))
            stop("column dendrogram ordering gave index of wrong length")
    }
    else if (isTRUE(Colv)) {
        Colv <- colMeans(x, na.rm = na.rm)
        hcc <- hclustfun(distfun(if (symm)
            x
        else t(x)))
        ddc <- stats::as.dendrogram(hcc)
        ddc <- stats::reorder(ddc, Colv)
        colInd <- stats::order.dendrogram(ddc)
        if (nc != length(colInd))
            stop("column dendrogram ordering gave index of wrong length")
    }
    else {
        colInd <- 1:nc
    }
    retval$rowInd <- rowInd
    retval$colInd <- colInd
    retval$call <- match.call()
    x <- x[rowInd, colInd]
    x.unscaled <- x
    cellnote <- cellnote[rowInd, colInd]
    if (is.null(labRow))
        labRow <- if (is.null(rownames(x)))
            (1:nr)[rowInd]
        else rownames(x)
    else labRow <- labRow[rowInd]
    if (is.null(labCol))
        labCol <- if (is.null(colnames(x)))
            (1:nc)[colInd]
        else colnames(x)
    else labCol <- labCol[colInd]
    if (scale == "row") {
        retval$rowMeans <- rm <- rowMeans(x, na.rm = na.rm)
        x <- sweep(x, 1, rm)
        retval$rowSDs <- sx <- apply(x, 1, stats::sd, na.rm = na.rm)
        x <- sweep(x, 1, sx, "/")
    }
    else if (scale == "column") {
        retval$colMeans <- rm <- colMeans(x, na.rm = na.rm)
        x <- sweep(x, 2, rm)
        retval$colSDs <- sx <- apply(x, 2, stats::sd, na.rm = na.rm)
        x <- sweep(x, 2, sx, "/")
    }
    if (missing(breaks) || is.null(breaks) || length(breaks) < 1) {
        if (missing(col) || is.function(col))
            breaks <- 16
        else breaks <- length(col) + 1
    }
    if (length(breaks) == 1) {
        if (!symbreaks)
            breaks <- seq(min(x, na.rm = na.rm), max(x, na.rm = na.rm),
                length = breaks)
        else {
            extreme <- max(abs(x), na.rm = TRUE)
            breaks <- seq(-extreme, extreme, length = breaks)
        }
    }
    nbr <- length(breaks)
    ncol <- length(breaks) - 1
    if (class(col) == "function")
        col <- col(ncol)
    min.breaks <- min(breaks)
    max.breaks <- max(breaks)
    x[x < min.breaks] <- min.breaks
    x[x > max.breaks] <- max.breaks
    if (missing(lhei) || is.null(lhei))
        lhei <- c(keysize, 4)
    if (missing(lwid) || is.null(lwid))
        lwid <- c(keysize, 4)
    if (missing(lmat) || is.null(lmat)) {
        lmat <- rbind(4:3, 2:1)
 
        if (!missing(ColSideColors)) {
           #if (!is.matrix(ColSideColors))
           #stop("'ColSideColors' must be a matrix")
            if (!is.character(ColSideColors) || nrow(ColSideColors) != nc)
                stop("'ColSideColors' must be a matrix of nrow(x) rows")
            lmat <- rbind(lmat[1, ] + 1, c(NA, 1), lmat[2, ] + 1)
            #lhei <- c(lhei[1], 0.2, lhei[2])
             lhei=c(lhei[1], side.height.fraction*ColSideColorsSize/2, lhei[2])
        }
 
        if (!missing(RowSideColors)) {
            #if (!is.matrix(RowSideColors))
            #stop("'RowSideColors' must be a matrix")
            if (!is.character(RowSideColors) || ncol(RowSideColors) != nr)
                stop("'RowSideColors' must be a matrix of ncol(x) columns")
            lmat <- cbind(lmat[, 1] + 1, c(rep(NA, nrow(lmat) - 1), 1), lmat[,2] + 1)
            #lwid <- c(lwid[1], 0.2, lwid[2])
            lwid <- c(lwid[1], side.height.fraction*RowSideColorsSize/2, lwid[2])
        }
        lmat[is.na(lmat)] <- 0
    }
 
    if (length(lhei) != nrow(lmat))
        stop("lhei must have length = nrow(lmat) = ", nrow(lmat))
    if (length(lwid) != ncol(lmat))
        stop("lwid must have length = ncol(lmat) =", ncol(lmat))
    op <- graphics::par(no.readonly = TRUE)
    on.exit(graphics::par(op))
 
    graphics::layout(lmat, widths = lwid, heights = lhei, respect = FALSE)
 
    if (!missing(RowSideColors)) {
        if (!is.matrix(RowSideColors)){
                graphics::par(mar = c(margins[1], 0, 0, 0.5))
                graphics::image(rbind(1:nr), col = RowSideColors[rowInd], axes = FALSE)
        } else {
            graphics::par(mar = c(margins[1], 0, 0, 0.5))
            rsc = t(RowSideColors[,rowInd, drop=F])
            rsc.colors = matrix()
            rsc.names = names(table(rsc))
            rsc.i = 1
            for (rsc.name in rsc.names) {
                rsc.colors[rsc.i] = rsc.name
                rsc[rsc == rsc.name] = rsc.i
                rsc.i = rsc.i + 1
            }
            rsc = matrix(as.numeric(rsc), nrow = dim(rsc)[1])
            graphics::image(t(rsc), col = as.vector(rsc.colors), axes = FALSE)
            if (length(rownames(RowSideColors)) > 0) {
                graphics::axis(1, 0:(dim(rsc)[2] - 1)/max(1,(dim(rsc)[2] - 1)), rownames(RowSideColors), las = 2, tick = FALSE)
            }
        }
    }
 
    if (!missing(ColSideColors)) {
        ColSideColors=ColSideColors[,rowInd] # roreder rows to equal row order in lower heatmap (only use this if data related)
        if (!is.matrix(ColSideColors)){
            graphics::par(mar = c(0.5, 0, 0, margins[2]))
            graphics::image(cbind(1:nc), col = ColSideColors[colInd], axes = FALSE)
        } else {
            graphics::par(mar = c(0.5, 0, 0, margins[2]))
            csc = ColSideColors[colInd, , drop=F]
            csc.colors = matrix()
            csc.names = names(table(csc))
            csc.i = 1
            for (csc.name in csc.names) {
                csc.colors[csc.i] = csc.name
                csc[csc == csc.name] = csc.i
                csc.i = csc.i + 1
            }
            csc = matrix(as.numeric(csc), nrow = dim(csc)[1])
            graphics::image(csc, col = as.vector(csc.colors), axes = FALSE)
            if (length(colnames(ColSideColors)) > 0) {
                graphics::axis(2, 0:(dim(csc)[2] - 1)/max(1,(dim(csc)[2] - 1)), colnames(ColSideColors), las = 2, tick = FALSE,cex.axis =ColSideCex)
            }
        }
    }
 
    graphics::par(mar = c(margins[1], 0, 0, margins[2]))
    x <- t(x)
    cellnote <- t(cellnote)
    if (revC) {
        iy <- nr:1
        if (exists("ddr"))
            ddr <- rev(ddr)
        x <- x[, iy]
        cellnote <- cellnote[, iy]
    }
    else iy <- 1:nr
    graphics::image(1:nc, 1:nr, x, xlim = 0.5 + c(0, nc), ylim = 0.5 + c(0, nr), axes = FALSE, xlab = "", ylab = "", col = col, breaks = breaks, ...)
    retval$carpet <- x
    if (exists("ddr"))
        retval$rowDendrogram <- ddr
    if (exists("ddc"))
        retval$colDendrogram <- ddc
    retval$breaks <- breaks
    retval$col <- col
    if (!invalid(na.color) & any(is.na(x))) { # load library(gplots)
        mmat <- ifelse(is.na(x), 1, NA)
        graphics::image(1:nc, 1:nr, mmat, axes = FALSE, xlab = "", ylab = "",
            col = na.color, add = TRUE)
    }
    graphics::axis(1, 1:nc, labels = labCol, las = 2, line = -0.5, tick = 0,
        cex.axis = cexCol)
    if (!is.null(xlab))
        graphics::mtext(xlab, side = 1, line = margins[1] - 1.25)
    graphics::axis(4, iy, labels = labRow, las = 2, line = -0.5, tick = 0,
        cex.axis = cexRow)
    if (!is.null(ylab))
        graphics::mtext(ylab, side = 4, line = margins[2] - 1.25)
    if (!missing(add.expr))
        eval(substitute(add.expr))
    if (!missing(colsep))
        for (csep in colsep) graphics::rect(xleft = csep + 0.5, ybottom = rep(0, length(csep)), xright = csep + 0.5 + sepwidth[1], ytop = rep(ncol(x) + 1, csep), lty = 1, lwd = 1, col = sepcolor, border = sepcolor)
    if (!missing(rowsep))
        for (rsep in rowsep) graphics::rect(xleft = 0, ybottom = (ncol(x) + 1 - rsep) - 0.5, xright = nrow(x) + 1, ytop = (ncol(x) + 1 - rsep) - 0.5 - sepwidth[2], lty = 1, lwd = 1, col = sepcolor, border = sepcolor)
    min.scale <- min(breaks)
    max.scale <- max(breaks)
    x.scaled <- scale01(t(x), min.scale, max.scale)
    if (trace %in% c("both", "column")) {
        retval$vline <- vline
        vline.vals <- scale01(vline, min.scale, max.scale)
        for (i in colInd) {
            if (!is.null(vline)) {
                graphics::abline(v = i - 0.5 + vline.vals, col = linecol,
                  lty = 2)
            }
            xv <- rep(i, nrow(x.scaled)) + x.scaled[, i] - 0.5
            xv <- c(xv[1], xv)
            yv <- 1:length(xv) - 0.5
            graphics::lines(x = xv, y = yv, lwd = 1, col = tracecol, type = "s")
        }
    }
    if (trace %in% c("both", "row")) {
        retval$hline <- hline
        hline.vals <- scale01(hline, min.scale, max.scale)
        for (i in rowInd) {
            if (!is.null(hline)) {
                graphics::abline(h = i + hline, col = linecol, lty = 2)
            }
            yv <- rep(i, ncol(x.scaled)) + x.scaled[i, ] - 0.5
            yv <- rev(c(yv[1], yv))
            xv <- length(yv):1 - 0.5
            graphics::lines(x = xv, y = yv, lwd = 1, col = tracecol, type = "s")
        }
    }
    if (!missing(cellnote))
        graphics::text(x = c(row(cellnote)), y = c(col(cellnote)), labels = c(cellnote),
            col = notecol, cex = notecex)
    graphics::par(mar = c(margins[1], 0, 0, 0))
    if (dendrogram %in% c("both", "row")) {
        graphics::plot(ddr, horiz = TRUE, axes = FALSE, yaxs = "i", leaflab = "none")
    }
    else graphics::plot.new()
    graphics::par(mar = c(0, 0, if (!is.null(main)) 5 else 0, margins[2]))
    if (dendrogram %in% c("both", "column")) {
        graphics::plot(ddc, axes = FALSE, xaxs = "i", leaflab = "none")
    }
    else graphics::plot.new()
    if (!is.null(main))
        graphics::title(main, cex.main = 1.5 * op[["cex.main"]])
    if (key) {
        graphics::par(mar = c(5, 4, 2, 1), cex = 0.75)
        tmpbreaks <- breaks
        if (symkey) {
            max.raw <- max(abs(c(x, breaks)), na.rm = TRUE)
            min.raw <- -max.raw
            tmpbreaks[1] <- -max(abs(x), na.rm = TRUE)
            tmpbreaks[length(tmpbreaks)] <- max(abs(x), na.rm = TRUE)
        }
        else {
            min.raw <- min(x, na.rm = TRUE)
            max.raw <- max(x, na.rm = TRUE)
        }
 
        z <- seq(min.raw, max.raw, length = length(col))
        graphics::image(z = matrix(z, ncol = 1), col = col, breaks = tmpbreaks,
            xaxt = "n", yaxt = "n")
        graphics::par(usr = c(0, 1, 0, 1))
        lv <- pretty(breaks)
        xv <- scale01(as.numeric(lv), min.raw, max.raw)
        graphics::axis(1, at = xv, labels = lv)
        if (scale == "row")
            graphics::mtext(side = 1, "Row Z-Score", line = 2)
        else if (scale == "column")
            graphics::mtext(side = 1, "Column Z-Score", line = 2)
        else graphics::mtext(side = 1, KeyValueName, line = 2)
        if (density.info == "density") {
            dens <- stats::density(x, adjust = densadj, na.rm = TRUE)
            omit <- dens$x < min(breaks) | dens$x > max(breaks)
            dens$x <- dens$x[-omit]
            dens$y <- dens$y[-omit]
            dens$x <- scale01(dens$x, min.raw, max.raw)
            graphics::lines(dens$x, dens$y/max(dens$y) * 0.95, col = denscol,
                lwd = 1)
            graphics::axis(2, at = pretty(dens$y)/max(dens$y) * 0.95, pretty(dens$y))
            graphics::title("Color Key\nand Density Plot")
            graphics::par(cex = 0.5)
            graphics::mtext(side = 2, "Density", line = 2)
        }
        else if (density.info == "histogram") {
            h <- graphics::hist(x, plot = FALSE, breaks = breaks)
            hx <- scale01(breaks, min.raw, max.raw)
            hy <- c(h$counts, h$counts[length(h$counts)])
            graphics::lines(hx, hy/max(hy) * 0.95, lwd = 1, type = "s",
                col = denscol)
            graphics::axis(2, at = pretty(hy)/max(hy) * 0.95, pretty(hy))
            graphics::title("Color Key\nand Histogram")
            graphics::par(cex = 0.5)
            graphics::mtext(side = 2, "Count", line = 2)
        }
        else {
        if (class(barTitle)=="character"){graphics::title(barTitle)} else {graphics::title("Color Key")}
        }
    }
    else graphics::plot.new()
    retval$colorTable <- data.frame(low = retval$breaks[-length(retval$breaks)],
        high = retval$breaks[-1], color = retval$col)
    invisible(retval)
}


multiHeatMapRowColAnnoAsMatrix <- function(mat,title="Title",hclustfun=function(c){stats::hclust(c,method="average")},
distfun=function(c){stats::dist(c,method="euclidian")},
rlabL=F,clabL=F,labCol=F,labRow=F,KeyValueName="Prob. Response",LowerMargin=25,RightMargin=5,barTitle="",
KeySize=0.9,RowSideColorsSize=0.5,ColSideColorsSize=6,UseBreaks=F,cexFontCol=1,cexRow=1,cellnote="",notecex=1,ColSideCex=1){
# breaks for the core of the distribution
if (UseBreaks==T){
breaks=seq(-1, 1, by=0.2)
#now add outliers
breaks=append(breaks, 1)
breaks=append(breaks, -1, 0)
#create colour panel with length(breaks)-1 colours
mycol <- gplots::colorpanel(n=length(breaks)-1,low=gplots::greenred(5)[1],mid=gplots::greenred(5)[3],high=gplots::greenred(5)[5])
} else {
mycol=gplots::greenred(50)
}
#
if (labRow==T){
labRow=rownames(mat)
}
if (labCol==T){
labCol=colnames(mat)
}
#
graphics::plot.new()
main_title=title
graphics::par(cex.main=1)
if (UseBreaks==T){
heatmap.3(mat, hclustfun=hclustfun, distfun=distfun, na.rm = TRUE, scale="none", dendrogram="both", margins=c(LowerMargin,RightMargin),
Rowv=TRUE, Colv=TRUE, ColSideColors=clabL, RowSideColors=rlabL, symbreaks=FALSE, key=TRUE, symkey=FALSE,
density.info="none", trace="none", main=main_title, labCol=labCol, labRow=labRow, cexRow=cexRow, col=mycol,breaks=breaks,
ColSideColorsSize=ColSideColorsSize, RowSideColorsSize=RowSideColorsSize,keysize=KeySize, KeyValueName=KeyValueName,barTitle=barTitle)
} else {
if (cellnote[1]!=""){
heatmap.3(mat, hclustfun=hclustfun, distfun=distfun, na.rm = TRUE, scale="none", dendrogram="both", margins=c(LowerMargin,RightMargin),
Rowv=TRUE, Colv=TRUE, ColSideColors=clabL, symbreaks=FALSE, key=TRUE, symkey=FALSE,
density.info="none", trace="none", main=main_title, labCol=labCol, labRow=labRow, cexRow=cexRow,cexCol=cexFontCol, col=mycol,
ColSideColorsSize=ColSideColorsSize, RowSideColorsSize=RowSideColorsSize,keysize=KeySize,KeyValueName=KeyValueName,barTitle=barTitle,
cellnote=cellnote,notecex=notecex,notecol="white",ColSideCex=ColSideCex)
} else {
heatmap.3(mat, hclustfun=hclustfun, distfun=distfun, na.rm = TRUE, scale="none", dendrogram="both", margins=c(LowerMargin,RightMargin),
Rowv=TRUE, Colv=TRUE, ColSideColors=clabL, symbreaks=FALSE, key=TRUE, symkey=FALSE,
density.info="none", trace="none", main=main_title, labCol=labCol, labRow=labRow, cexRow=cexRow,cexCol=cexFontCol, col=mycol,
ColSideColorsSize=ColSideColorsSize, RowSideColorsSize=RowSideColorsSize,keysize=KeySize,KeyValueName=KeyValueName,barTitle=barTitle)
} # RowSideColors=rlabL taken out
}
return(TRUE)
}


#' This function plot a heatmap to summarize the results from complete functional enrichment analysis
#' @param Eres object from complete functional enrichment analysis
#' @param title string
#' @keywords heatmap
#' library(CoFRA)
#' data(iBAQ)
#' Fac=factor(c("MCCTT","MCCTT","MCCTT","MCCT","MCCT","MCCT","MC","MC","MC","MCT","MCT","MCT","MTT","MTT",
#' "MTT","MT","MT","MT","sN","sN","sN","sNT","sNT","sNT","iN","iN","iN","iNT","iNT","iNT"))
#' dfComp=data.frame(Con=c("MCCT","MT","MC","iN","sN","AllC,MCCT,MT,MC,iN,sN"),Tre=c("MCCTT","MTT",
#' "MCT","iNT","sNT","AllT,MCCTT,MTT,MCT,iNT,sNT"))
#' Func=CoFRA::getFunctionalCategories("CC")
#' head(str(Func))
#' CC1=CoFRA::completeFunctionalRegulationAnalysis(iBAQ,Func[100:200],Fac,dfComp,NbackGround=142140)
#' CoFRA::HeatMapEnrichment(CC1,"CC") # note this fails inside R studio because of the way the graphic device is setup use below to write pdf to file if using Rstudio
#' getwd() # check that the following commands don't overwrite any files
#' pdf("CCxxxTest.pdf")
#' CoFRA::HeatMapEnrichment(CC1,"CC")
#' dev.off()
#' @export
HeatMapEnrichment <- function(Eres, title = "") {
if (class(Eres)!="CompleteEnrichment") {
stop("Eres is expected to be CompleteEnrichment object calculated by completeFunctionalRegulationAnalysis method")
}
if (base::is.character(title)==F) {
stop("Character expected for title")
}
cMat = matrix(c("blue", "green", "blue", "red", "red", "black"), 
nrow = 1, ncol = 6)  # not used in final implmentation
# 
multiHeatMapRowColAnnoAsMatrix(t(as.matrix(Eres[[1]])), clabL = as.matrix(Eres[[6]][, 
]), rlabL = cMat, title = title, labCol = T, labRow = T, 
KeyValueName = "P value and log ratio", LowerMargin = 30, 
RightMargin = 7, KeySize = 1, ColSideColorsSize = 7, 
cexFontCol = 1, cellnote = t(as.matrix(Eres[[8]])))
return(TRUE)
}


#' This function plot a heatmap to summarize the results from complete functional enrichment analysis
#' @param x object from complete functional enrichment analysis
#' @param ... list of additional arguments
#' @keywords heatmap
#' library(CoFRA)
#' data(iBAQ)
#' Fac=factor(c("MCCTT","MCCTT","MCCTT","MCCT","MCCT","MCCT","MC","MC","MC","MCT","MCT","MCT","MTT","MTT",
#' "MTT","MT","MT","MT","sN","sN","sN","sNT","sNT","sNT","iN","iN","iN","iNT","iNT","iNT"))
#' dfComp=data.frame(Con=c("MCCT","MT","MC","iN","sN","AllC,MCCT,MT,MC,iN,sN"),Tre=c("MCCTT","MTT",
#' "MCT","iNT","sNT","AllT,MCCTT,MTT,MCT,iNT,sNT"))
#' Func=CoFRA::getFunctionalCategories("CC")
#' head(str(Func))
#' CC1=CoFRA::completeFunctionalRegulationAnalysis(iBAQ,Func[100:200],Fac,dfComp,NbackGround=142140)
#' CoFRA::HeatMapEnrichment(CC1,"CC") # note this fails inside R studio because of the way the graphic device is setup use below to write pdf to file if using Rstudio
#' getwd() # check that the following commands don't overwrite any files
#' pdf("CCxxxTest.pdf")
#' CoFRA::HeatMapEnrichment(CC1,"CC")
#' dev.off()
#' @export
plot.CompleteEnrichment <- function(x, ...) {
HeatMapEnrichment(x)
}

#' This function summarize and print the results from complete functional enrichment analysis
#' @param object object from complete functional enrichment analysis
#' @param ... list of additional arguments
#' @keywords summary
#' library(CoFRA)
#' data(iBAQ)
#' Fac=factor(c("MCCTT","MCCTT","MCCTT","MCCT","MCCT","MCCT","MC","MC","MC","MCT","MCT","MCT","MTT","MTT",
#' "MTT","MT","MT","MT","sN","sN","sN","sNT","sNT","sNT","iN","iN","iN","iNT","iNT","iNT"))
#' dfComp=data.frame(Con=c("MCCT","MT","MC","iN","sN","AllC,MCCT,MT,MC,iN,sN"),Tre=c("MCCTT","MTT",
#' "MCT","iNT","sNT","AllT,MCCTT,MTT,MCT,iNT,sNT"))
#' Func=CoFRA::getFunctionalCategories("CC")
#' head(str(Func))
#' CC1=CoFRA::completeFunctionalRegulationAnalysis(iBAQ,Func[100:200],Fac,dfComp,NbackGround=142140)
#' summary.CompleteEnrichment(CC1)
#' @export
summary.CompleteEnrichment <- function(object, ...){
Eres=object
tes=Eres[["P values"]]
tes2=paste(lapply(tes,function(x){sum(x>0.95)})," out of ",nrow(tes))
print("Number of significant up-regulated enties")
print(paste(names(lapply(tes,function(x){sum(x>0.95)})),": ",tes2))
tes2=paste(lapply(tes,function(x){sum(x< -0.95)})," out of ",nrow(tes))
print("Number of significant down-regulated enties")
print(paste(names(lapply(tes,function(x){sum(x< -0.95)})),": ",tes2))
# Number of print significant enriched entities
tes=Eres[["Significance of enrichment"]]
tes2=paste(lapply(tes,function(x){sum(x<0.01)})," out of ",nrow(tes))
print("Number of significant enriched entities")
print(paste(names(lapply(tes,function(x){sum(x< 0.01)})),": ",tes2))
# number of enriched and regulated entities
tes1=Eres[["P values"]]
tes11=lapply(tes1,function(x){x>0.95 | x< -0.95})
tes2=Eres[["Significance of enrichment"]]
tes21=lapply(tes2,function(x){x<0.01})
for (i in 1:length(tes21)){
print(names(tes21[i]))
for (j in 1:length(tes21[[i]])){
if (tes21[[i]][j]==T & tes11[[i]][j]==T){print(paste(rownames(tes1)[j],Eres[["Max Counts"]][j,i],Eres[["log ratios"]][j,i]))}
}
}
}
