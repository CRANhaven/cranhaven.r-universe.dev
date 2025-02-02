#' @name gl.run.EMIBD9
#' @title Run program EMIBD9
#' @description
#' Run program EMIBD9
#' @param x Name of the genlight object containing the SNP data [required].
#' @param outfile A string, giving the path and name of the output file
#' [default "EMIBD9_Res.ibd9"].
#' @param outpath Path where to save the output file. Use outpath=getwd() or
#' outpath='.' when calling this function to direct output files to your working 
#' or current directory [default tempdir(), mandated by CRAN].
#' @param emibd9.path Path to the folder emidb files.
#'  Please note there are 2 different executables depending on your OS:
#'  EM_IBD_P.exe (=Windows) EM_IBD_P (=Mac, Linux). 
#'  You only need to pointto the folder (the function will recognise which OS you
#'  are running) [default getwd()].
#' @param Inbreed A Boolean, taking values 0 or 1 to indicate inbreeding is not
#'  and is allowed in estimating IBD coefficients [default 1].
#' @param ISeed An integer used to seed the random number generator [default 42].
#' @param plot.out A boolean that indicates whether to plot the results [default TRUE].
#' @param plot.dir Directory to save the plot RDS files [default as specified 
#' by the global working directory or tempdir()]
#' @param plot.file Name for the RDS binary file to save (base name only, exclude extension) [default NULL]
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#' progress log; 3, progress and results summary; 5, full report
#'  [default NULL, unless specified using gl.set.verbosity]
#' @details
#' Download the program from here:
#'
#' https://www.zsl.org/about-zsl/resources/software/emibd9
#'
#' For Windows, Mac and Linux install the program then point to the folder where you find:
#' EM_IBD_P.exe (=Windows) and EM_IBD_P (=Mac, Linux). If running really slow you may 
#' want to create the files using the function and then run in parallel using the
#' documentation provided by the authors [you need to have mpiexec installed].
#' 
#'
#' @return A matrix with pairwise relatedness
#' @author Custodian: Luis Mijangos -- Post to
#' \url{https://groups.google.com/d/forum/dartr}
#' @examples
#' \dontrun{
#' #To run this function needs EMIBD9 installed in your computer
#' t1 <- gl.filter.allna(platypus.gl)
#' res_rel <- gl.run.EMIBD9(t1)
#' }
#'
#' @references
#' \itemize{
#' \item Wang, J. (2022). A joint likelihood estimator of relatedness and allele
#'  frequencies from a small sample of individuals. Methods in Ecology and
#'  Evolution, 13(11), 2443-2462.
#' }
#' @importFrom stringr str_split
#' @export

gl.run.EMIBD9 <- function(x,
                          outfile = "EMIBD9_Res.ibd9",
                          outpath = tempdir(),
                          emibd9.path = getwd(),
                          Inbreed = TRUE,
                          ISeed = 42,
                          plot.out = TRUE,
                          plot.dir=NULL,
                          plot.file = NULL,
                          verbose = NULL) {
  
  
  # SET VERBOSITY
  verbose <- gl.check.verbosity(verbose)
  
  # SET WORKING DIRECTORY
  plot.dir <- gl.check.wd(plot.dir, verbose = 0)
  
  # FLAG SCRIPT START
  funname <- match.call()[[1]]
  utils.flag.start(
    func = funname,
    build = "Jody",
    verbose = verbose
  )
  
  # CHECK DATATYPE
  datatype <- utils.check.datatype(x, verbose = verbose)
 
  #check if embid9 is available
  
  os <- Sys.info()["sysname"]
  
  if (Sys.info()["sysname"] == "Windows") {
    prog <- c("EM_IBD_P.exe", "impi.dll", "libiomp5md.dll")
    cmd <- "EM_IBD_P.exe INP:MyData.par"
  }
  
  if (Sys.info()["sysname"] == "Linux") {
    prog <- "EM_IBD_P"
    cmd <- "./EM_IBD_P INP:MyData.par"
  }
  
  if (Sys.info()["sysname"] == "Darwin") {
    prog <- "EM_IBD_P"
    cmd <- "./EM_IBD_P INP:MyData.par"
  }
  
  # check if file program can be found
  if (all(file.exists(file.path(emibd9.path, prog)))) {
    file.copy(file.path(emibd9.path, prog),
              to = tempdir(),
              overwrite = TRUE
    )
    if (verbose > 0) cat(report("Found necessary files to run EMIBD9."))
  } else {
    message(
      error(
        "  Cannot find",
        prog,
        "in the specified folder given by emibd9.path:",
        emibd9.path,
        "\n"
      )
    )
    stop()
  }
  
  
  rundir <- tempdir()
  
   
  
  # individual IDs must have a maximal length of 20 characters. The IDs must NOT
  # contain blank space and other illegal characters (such as /), and must be
  # unique among all sampled individuals (i.e. NO duplications). Any string longer
  # than 20 characters for individual ID will be truncated to have 20 characters.

  
  
  x2 <- x  #copy to work only on the copied data set
  hold_names <- indNames(x)
  indNames(x2) <- 1:nInd(x2)
  

  
  NumIndiv <- nInd(x2)
  NumLoci <- nLoc(x2)
  DataForm <- 2
  if (Inbreed) Inbreed <- 1 else Inbreed <- 0
  # Inbreed <- Inbreed
  GtypeFile <- "EMIBD9_Gen.dat"
  OutFileName <-  outfile
  # ISeed <- ISeed
  RndDelta0 <- 1
  EM_Method <- 1
  OutAlleleFre <- 0

  param <- paste(NumIndiv,
    NumLoci,
    DataForm,
    Inbreed,
    GtypeFile,
    OutFileName,
    ISeed,
    RndDelta0,
    EM_Method,
    OutAlleleFre,
    sep = "\n"
  )

  write.table(param,
    quote = FALSE,
    row.names = FALSE,
    col.names = FALSE,
    file = file.path(rundir, "MyData.par")
  )

  IndivID <- paste(indNames(x2))

  gl_mat <- as.matrix(x2)
  gl_mat[is.na(gl_mat)] <- 3

  tmp <- cbind(apply(gl_mat, 1, function(y) {
    Reduce(paste0, y)
  }))

  tmp <- rbind(paste(indNames(x2), collapse = " "), tmp)

  write.table(tmp,
    file = file.path(rundir, "EMIBD9_Gen.dat"),
    quote = FALSE,
    row.names = FALSE,
    col.names = FALSE
  )
  


  
  # run EMIBD9
  # change into tempdir (run it there)
  old.path <- getwd()
  on.exit(setwd(old.path))
  setwd(rundir)
  system(cmd)
  
  ### get output  
  
 
  
  
  x_lines <- readLines("EMIBD9_Res.ibd9")
  strt <- which(grepl("^IBD", x_lines)) + 2
  stp <- which(grepl("Indiv genotypes", x_lines)) - 4
  linez_headings <- x_lines[strt]
  linez_data <- x_lines[(strt + 1):stp]
  tmp_headings <- unlist(stringr::str_split(linez_headings, " "))
  tmp_data <- stringr::str_split(linez_data, " ")
  #Raw data 
  tmp_data_raw_1 <- lapply(tmp_data, "[", c(2:22))
  tmp_data_raw_2 <- do.call("rbind", tmp_data_raw_1)
  tmp_data_raw_3 <- as.data.frame(tmp_data_raw_2)
  tmp_data_raw_3$V3 <- lapply(tmp_data_raw_3$V3, as.numeric)
  colnames(tmp_data_raw_3) <- tmp_headings[2:22]
  
  df <- data.frame(ind1=tmp_data_raw_3$Indiv1, ind2=tmp_data_raw_3$Indiv2,rel= tmp_data_raw_3$`r(1,2)`)
  df<- apply(df, 2, as.numeric)
  #Relatedness
  res <- matrix(NA, nrow = nInd(x), ncol = nInd(x))
  
  for (i in 1:nrow(df)) {
    res[df[i, 1], df[i, 2]] <- df[i, 3]
  }

 
 

  colnames(res) <- indNames(x)
  rownames(res) <- indNames(x)


 
  
  #return to old path
  setwd(old.path)
  
  #compile the two dataframes into on list for output
  if (verbose>0)
  {
  cat(
    report(
      "Returning a list containing the input gl object, a square matrix  of pairwise kinship, and the raw EMIBD9 results table as follows:\n",
      "          $rel -- a square matrix of relatedness \n",
      "          $raw -- raw EMIBD9 results table \n")
  )
  }

  # PRINTING OUTPUTS
  p1 <- gl.plot.heatmap(res) 
    if (plot.out) print(p1)

  # Optionally save the plot ---------------------
  if(!is.null(plot.file)){
    tmp <- utils.plot.save(p1,
                           dir=plot.dir,
                           file=plot.file,
                           verbose=verbose)
  }
  
  #Make a list
  results <-
    list(
      rel = res,
      raw = tmp_data_raw_3
    )
  
  return(results)
}
