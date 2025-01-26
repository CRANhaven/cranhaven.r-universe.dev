
getNet <- function(){

if(!exists("LncPathEnvir")) LncPathEnvir <- initializeLncPathEnvir();

NetLncPath <- get("NetLncPath", envir = LncPathEnvir);
return(NetLncPath);

}



