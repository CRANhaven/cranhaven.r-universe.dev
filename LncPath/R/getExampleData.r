

getExampleData<-function(ExampleData){

if(!exists("LncPathEnvir")) LncPathEnvir <- initializeLncPathEnvir();

if (ExampleData == "SigLncs"){
SigLncs<-get("SigLncs",envir=LncPathEnvir)
return(SigLncs)
}

if(ExampleData == "ExampleNet"){
ExampleNet<-get("ExampleNet", envir = LncPathEnvir)
return(ExampleNet)
}

if(ExampleData=="Labels"){
Labels<-get("Labels",envir=LncPathEnvir)
return(Labels)
}

if (ExampleData=="Profile"){
Profile<-get("Profile",envir=LncPathEnvir)
return(Profile)
}

if (ExampleData=="Result"){
Result<-get("Result",envir=LncPathEnvir)
return(Result)
}

if (ExampleData=="Table"){
Table<-get("Table",envir=LncPathEnvir)
return(Table)
}

}
