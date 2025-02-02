#' Run the entire coi5p pipeline for an input sequence.
#'
#' This function will take a raw DNA sequence string and run each of the coi5p methods in turn
#' (coi5p, frame, translate, indel_check). Note that if you are not interested in all components
#' of the output (i.e. only want sequences set in frame reading  or translated), then the
#' coi5p analysis functions can be called individually to avoid unnecessary computation.
#'
#'
#' @param x A nucleotide string.
#' Valid characters within the nucleotide string are: 'a', 't', 'g', 'c', '-', and 'n'.
#' The nucleotide string can be input as upper case, but will be automatically converted to lower case.
#' @param ... Additional arguments to be passed between methods.
#' @param name An optional character string. Identifier for the sequence.
#' @param trans_table The translation table to use for translating from nucleotides to amino acids.
#' Default is 0, which indicates that censored translation should be performed. If the taxonomy
#' of the sample is known, use the function which_trans_table() to determine the translation table to use.
#' @param frame_offset The offset to the reading frame to be applied for translation. By default the offset
#' is zero, so the first character in the framed sequence is considered the first nucleotide of the first codon.
#' Passing frame_offset = 1 would make the second character in the framed sequence the first nucleotide of
#' the first codon.
#' @param indel_threshold The log likelihood threshold used to assess whether or not sequences
#' are likely to contain an indel. Default is -358.88. Values lower than this will be classified
#' as likely to contain an indel and values higher will be classified as not likely to contain an indel.
#' For recommendations on selecting a indel_threshold value, consult: Nugent et al. 2019 (doi: https://doi.org/10.1101/2019.12.12.865014).
#' @param triple_translate Optional argument indicating if the translation of sequences should be tested in all three forward
#' reading frames. The reading frame with the most likely amino acid PHMM score is returned.
#' This will decrease the rate of sequencing framing errors, at the cost of increased processing time.
#' Note this argument will overrule any passed frame_offset value (all options tried). Default is False.
#' @param nt_PHMM The profile hidden Markov model against which the raw sequence should be compared in the framing step.
#' Default is the full COI-5P nucleotide PHMM (nt_coi_PHMM).
#' @param aa_PHMM The profile hidden Markov model against which the translated amino acid sequence should be compared
#' in the indel_check step. Default is the full COI-5P amino acid PHMM (aa_coi_PHMM).
#'
#' @return An object of class \code{"coi5p"}
#' @examples
#' dat = coi5p_pipe(example_nt_string)
#' #full coi5p object can then be printed
#' dat
#' #components of output coi5p object can be called individually:
#' dat$raw    #raw input sequence
#' dat$name   #name that was passed
#' dat$framed #sequence in common reading frame
#' dat$aaSeq  #sequence translated to amino acids (censored)
#' dat$indel_likely #whether an insertion or deletion likely exists in the sequence
#' dat$stop_codons #whether or not there are stop codons in the amino acid sequence
#' dat = coi5p_pipe(example_nt_string , trans_table = 5)
#' dat$aaSeq #sequence translated to amino acids using designated translation table
#' @seealso \code{\link{coi5p}}
#' @seealso \code{\link{frame}}
#' @seealso \code{\link{translate}}
#' @seealso \code{\link{indel_check}}
#' @seealso \code{\link{which_trans_table}}
#' @seealso \code{\link{subsetPHMM}}
#'
#' @name coi5p_pipe
#' @export
coi5p_pipe = function(x, ... ,
                      name = character(),
                      trans_table = 0,
                      frame_offset = 0,
                      triple_translate = FALSE,
                      nt_PHMM = coil::nt_coi_PHMM,
                      aa_PHMM = coil::aa_coi_PHMM,
                      indel_threshold = -358.88){
  dat = coi5p(x, name=name)
  dat = frame(dat , nt_PHMM = nt_PHMM)
  if(triple_translate == TRUE){
    #first reading frame
    d0 = translate(dat, trans_table = trans_table, frame_offset = 0)
    d0 = indel_check(d0, indel_threshold=indel_threshold, aa_PHMM = aa_PHMM)
    #second reading frame
    d1 = translate(dat, trans_table = trans_table, frame_offset = 1)
    d1 = indel_check(d1, indel_threshold=indel_threshold, aa_PHMM = aa_PHMM)
    #third reading frame
    d2 = translate(dat, trans_table = trans_table, frame_offset = 2)
    d2 = indel_check(d2, indel_threshold=indel_threshold, aa_PHMM = aa_PHMM)
    #compare the three, get the best aa score
    scores = c(d0$aaScore,
               d1$aaScore,
               d2$aaScore)
    best_frame = which.max(scores)
    coi_objs = list(d0, d1, d2)
    out = coi_objs[[best_frame]]
    return(out)

  }

  dat = translate(dat, trans_table = trans_table, frame_offset = frame_offset)
  dat = indel_check(dat, indel_threshold=indel_threshold, aa_PHMM = aa_PHMM)
  return(dat)
}


#' Flatten a list of coi5p output objects into a dataframe.
#'
#' This helper function is designed to act upon a list of coi5p objects and extract the object components
#' that the user requires.
#' @param x A list of coi5p objects.
#' @param keep_cols The name of a coi5p object component, or a vector of components that should be turned into
#' dataframe columns. Available components are: name, raw, framed, aaSeq, aaScore, indel_likely, stop_codons.
#' @return A dataframe with the coi5p object information flattened into columns.
#' @examples
#' #create a list of coi5p objects
#' coi_output = lapply(example_barcode_data$sequence, function(x){
#'     coi5p_pipe(x)
#'   })
#' #flatten the list into a dataframe
#' coi_df = flatten_coi5p(coi_output)
#' #extract only a single column
#' coi_framed = flatten_coi5p(coi_output, keep_cols = "framed")
#' #or subset multiple columns
#' coi_framed = flatten_coi5p(coi_output, keep_cols = c("framed", "aaSeq"))
#' @seealso \code{\link{coi5p_pipe}}
#' @name flatten_coi5p
#' @export
flatten_coi5p = function(x, keep_cols = "all"){
  if(length(keep_cols) == 1 && keep_cols == "all"){
    vals = names(x[[1]])
    vals = vals[vals != "data"]
  } else{
    vals = keep_cols
  }

  data_list = list()
  for(v in vals){
    if(v == "data"){
      stop("flatten_coi5p is not designed to return the data component of the coi5p object, it is for internal use only.")
    }
    if(!v %in% names(x[[1]])){
      stop(paste("The coi5p objects you are flattening do not contain the column:", v))
    }
    if(v == "name"){
      id_col = sapply(x, function(i) i[["name"]])
      for(i in 1:length(id_col)){
        if(length(id_col[[i]]) == 0){
          id_col[[i]] = NA
        }
        data_list[[v]] = unlist(id_col)
      }
    }else{
      data_list[[v]] = sapply(x, function(i) i[[v]])
    }
  }
  return(as.data.frame(data_list, stringsAsFactors = FALSE))
}
