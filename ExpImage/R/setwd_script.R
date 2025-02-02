#' Definir o diretório do script working directory  (Set the script Directory as working directory).
#'@description Esta funcao define como o endereco da pasta onde esta o scritp atual como o diretorio de trabalho.
#'(This function set the directory of current script as working directory).
#'@usage setwd_script()
#'@return Esta funcao indica o diretorio de trabalho a pasta onde o script esta salvo
#'(This function indicates the working directory as the folder where the script is saved).
#'@export


setwd_script=function(){
  nome=rstudioapi::getSourceEditorContext()$path
  nome2=unlist(strsplit(nome,"/"))
  nome3=paste(nome2[-length(nome2)], sep="/", collapse="/")
  setwd(nome3)
  return(nome3)
}

