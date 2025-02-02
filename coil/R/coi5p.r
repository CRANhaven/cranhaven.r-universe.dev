########################
# coi5p - Initialization of the class

#' Build a new coi5p class instance.
#'
#' @keywords internal
new_coi5p = function(x = character(), name = character()){
  stopifnot(is.character(x))
  stopifnot(is.character(name))
  if(length(x) == 0){
    stop("Must pass a DNA sequence.")
  }
  structure(list(name = name, raw = tolower(x)) , class = "coi5p")
}

#' Validate the new coi5p class instance.
#'
#' @keywords internal
validate_coi5p = function(new_instance){
  # take a new instance and run validation checks on the sequence
  # make sure the sequence has only ATGCN
  # make sure the sequence has length greater than zero
  allowed = c("a", "c", "g", "n", "t", "-")
  for(c in sort(unique(strsplit(new_instance$raw, "")[[1]]))){
    if(!c %in% allowed){
      stop(paste("Unallowed character in DNA string:", c,
                 "\nValid characters are: a t g c - n"))
    }
  }
  if(grepl("-", new_instance$raw) & grepl("n", new_instance$raw)){
    warning("Two styles of placeholders used! Both 'n' and '-' in input. '-' have been converted to 'n'.")
  }
  new_instance
}


#' Build a coi5p object from a DNA sequence string.
#'
#' @param x A nucleotide string.
#' Valid characters within the nucleotide string are: "a", "t", "g", "c", "-" and "n".
#' coil treats both '-' and 'n' characters as placeholder nucleotides when comparing to the PHMM.
#' The nucleotide string can be input as upper case, but will be automatically converted to lower case.
#' @param name An optional character string that serves as the identifier for the sequence.
#'
#' @return An object of class \code{"coi5p"}
#' @examples
#' #build an unnamed coi5p object
#' dat = coi5p(example_nt_string)
#' #build a named coi5p sequence
#' dat = coi5p(example_nt_string, name = "example_seq1")
#' #available components in the coi5p object:
#' dat$raw
#' dat$name
#' @name coi5p
#' @export
coi5p = function(x = character(), name = character()){
  validate_coi5p(new_coi5p(tolower(x), name))
}



###########################
# coi5p - Generics and methods

#' Take a coi5p sequence and place it in reading frame.
#'
#' @param x A coi5p class object.
#' @param ... Additional arguments to be passed between methods.
#' @param nt_PHMM The profile hidden Markov model against which the raw sequence should be compared. Default is the
#' full COI-5P nucleotide PHMM (nt_coi_PHMM).
#'
#' @return An object of class \code{"coi5p"}
#' @seealso \code{\link{coi5p}}
#' @seealso \code{\link{subsetPHMM}}
#' @details
#' This function compares the raw sequence against the nucleotide PHMM using the Viterbi algorithm (for details see Durbin et al.
#' 1998, ISBN: 9780521629713). The path of hidden states produced by the comparison is used to establish the reading frame of the
#' sequence. If leading insert states are present, the front of the sequence is trimmed to the first continuous set of match states
#' and the sequence is re-compared to the nucleotide PHMM. This is done because spurious or outlier matches early in the sequence
#' can lead to incorrect establishment of the reading frame. Realigning only the truncated version of the sequence to the PHMM
#' improves correct reading frame establishment, although this can also result in the loss of a few bp of true barcode sequence
#' on the peripherals of the sequence.
#' @examples
#' #previously run function:
#' dat = coi5p(example_nt_string)
#'
#' dat = frame(dat)
#'
#' #additional components in output coi5p object:
#' dat$framed
#' @export
#' @name frame
frame = function(x, ...){
  UseMethod("frame")
}

####
#' @rdname frame
#' @export
frame.coi5p = function(x, ..., nt_PHMM = nt_coi_PHMM ){
  #input is a coi5p object.
  #set the reading frame and store the framed string in $framed

  ntBin = individual_DNAbin(x$raw)
  ntPHMMout = aphid::Viterbi(nt_PHMM, ntBin, odds = FALSE)
  if(leading_ins(ntPHMMout[['path']])){
    frame_out = set_frame(x$raw, ntPHMMout[['path']])
    trim_temp  = frame_out$framed
    #record if trimming occurred
    x$was_trimmed = frame_out$trimmed
    #save the amount trimmed from the raw
    x$data$raw_int_trim = frame_out$raw_start
    x$data$raw_int_pad = frame_out$folmer_start

    ntBin = individual_DNAbin(trim_temp)
    ntPHMMout = aphid::Viterbi(nt_PHMM, ntBin, odds = FALSE)
  }else{
    trim_temp = x$raw
  }
  x$data$ntPath = ntPHMMout[['path']]
  frame_out_final = set_frame(trim_temp, x$data$ntPath)
  x$framed = frame_out_final$framed

  if(!is.null(x$data$raw_int_trim)){
    #original adjustments added to final adjustment if a double pass was conducted
    #do the math to get the full amount trimmed
    x$data$raw_start = (x$data$raw_int_trim - 1 - x$data$raw_int_pad + frame_out_final$raw_start)
    #folmer start is just the final pad
    x$data$folmer_start = frame_out_final$folmer_start
    #remove the intermediate structures to avoid confusion
    x$data$raw_int_trim = NULL
    x$data$raw_int_pad = NULL
    if(x$was_trimmed == TRUE || frame_out_final$trimmed == TRUE){
      x$was_trimmed = TRUE
    }else{
      x$was_trimmed = FALSE
    }
  }else{
    x$data$raw_start = frame_out_final$raw_start
    x$data$folmer_start = frame_out_final$folmer_start
    x$was_trimmed  = frame_out_final$trimmed
  }
  #generate the alignment report string
  x$align_report = paste0("Base pair ", x$data$raw_start,
                          " of the raw sequence is base pair ",
                          x$data$folmer_start, " of the COI-5P region.")

  return(x)
}

#' Translate a coi5p sequence.
#'
#' @param x A coi5p class object for which frame() has been run.
#' @param ... Additional arguments to be passed between methods.
#' @param trans_table The translation table to use for translating from nucleotides to amino acids.
#' Default is 0, which indicates that censored translation should be performed. If the taxonomy
#' of the sample is known, use the function which_trans_table() to determine the translation table to use.
#' @param frame_offset The offset to the reading frame to be applied for translation. By default the offset
#' is zero, so the first character in the framed sequence is considered the first nucleotide of the first codon.
#' Passing frame_offset = 1 would offset the sequence by one and therefore make the second character in the
#' framed sequence the first nucleotide of the first codon.
#'
#' @return An object of class \code{"coi5p"}
#' @seealso \code{\link{coi5p}}
#' @seealso \code{\link{frame}}
#' @seealso \code{\link{which_trans_table}}
#' @details
#' The translate function allows for the translation of framed sequences from nucleotides to amino acids, both
#' in instances when the correct genetic code corresponding to a sequence is known, and in instances when taxonomic
#' information is unavailable or unreliable.
#' @examples
#' #previously run functions:
#' dat = coi5p(example_nt_string )
#' dat = frame(dat)
#' #translate when the translation table is not known:
#' dat = translate(dat)
#' #translate when the translation table is known:
#' dat = translate(dat, trans_table = 5)
#' #additional components in output coi5p object:
#' dat$aaSeq
#'@name translate
translate = function(x, ...){
  UseMethod("translate")
}

####
#' @rdname translate
#' @export
translate.coi5p = function(x, ..., trans_table = 0, frame_offset = 0){
  if(is.null(x$framed)){
    stop("translate function only accepts framed coi5p objects. See function: frame.")
  }

  if(trans_table == 0){
    x$aaSeq = censored_translation(x$framed, reading_frame = (frame_offset+1))
  }else{
    #split the DNA string into a vector, all characters to lower case
    dna_list = strsplit(gsub('-', 'n', as.character(tolower(x$framed))),"")
    dna_vec = dna_list[[1]]
    #translate using the designated numcode, returns a vector of AAs
    aa_vec = seqinr::translate(dna_vec, frame = frame_offset, numcode=trans_table, ambiguous= TRUE, NAstring = '-')

    x$aaSeq = paste(aa_vec, collapse= "")
  }
  return(x)
}


#' Check if a coi5p sequence likely contains an error.
#'
#' @param x A coi5p class object for which frame() and translate() have been run.
#' @param ... Additional arguments to be passed between methods.
#' @param indel_threshold The log likelihood threshold used to assess whether or not sequences
#' are likely to contain an indel. Default is -358.88. Values lower than this will be classified
#' as likely to contain an indel and values higher will be classified as not likely to contain an indel.
#' @param aa_PHMM The profile hidden Markov model against which the translated amino acid sequence should be compared.
#' Default is the full COI-5P amino acid PHMM (aa_coi_PHMM).
#'
#' @return An object of class \code{"coi5p"}
#' @seealso \code{\link{coi5p}}
#' @seealso \code{\link{frame}}
#' @seealso \code{\link{translate}}
#' @seealso \code{\link{subsetPHMM}}
#' @details
#' The indel check function analyzes the framed and translated DNA sequences in two ways in order to
#' allow users to make an informed decision about whether or not a DNA sequence contains a frameshift error.
#' This test is designed to detect insertion or deletion errors resulting from technical errors in DNA sequencing,
#' but can in some instances identify biological contaminants (i.e. if the contaminant sequence uses a different
#' genetic code than the target, or if the contaminants are things such as pseudogenes that possess sequences that
#' are highly divergent from animal COI-5P sequences).
#'
#' The two tests performed are: (1) a query for stop codons in the amino acid sequence and (2) an evaluation of the
#' log likelihood value resulting from the comparison of the framed coi5p amino acid sequence against the COI-5P
#' amino acid PHMM. The default likelihood value for identifying a sequence is likely erroneous is -358.88. Sequences with
#' likelihood values lower than this will receive an indel_likely value of TRUE. The threshold of -358.88 was experimentally
#' determined to be the optimal likelihood threshold for separating of full-length sequences with and without errors when
#' the censored translation option is used. Sequences will have higher likelihood values when a specific genetic code is used.
#' Sequences will have lower likelihood values when they are not complete barcode sequences (i.e. <500bp in length). For these
#' reasons the likelihood threshold is not a specific value but a parameter that can be altered based on the type of translation
#' and length of the sequences. Below are experimentally determined suggested values for different size and translation table
#' combinations.
#'
#' Short barcode sequences, known genetic code: indel_threshold = -354.44
#'
#' Short barcode sequences, unknown genetic code: indel_threshold = -440.24
#'
#' Full length barcode sequences, known genetic code: indel_threshold = -246.20
#'
#' Full length barcode sequences, unknown genetic code: indel_threshold = -358.88
#'
#' Source: Nugent et al. 2019 (doi: https://doi.org/10.1101/2019.12.12.865014).
#' @examples
#' #previously run functions:
#' dat = coi5p(example_nt_string)
#' dat = frame(dat)
#' dat = translate(dat)
#' #current function
#' dat = indel_check(dat)
#' #with custom indel threshold
#' dat = indel_check(dat, indel_threshold = -400)
#' #additional components in output coi5p object:
#' dat$stop_codons #Boolean - Indicates if there are stop codons in the amino acid sequence.
#' dat$indel_likely #Boolean - Indicates if the likelihood score below the specified indel_threshold.
#' dat$aaScore #view the amino acid log likelihood score
#' @name indel_check
indel_check = function(x, ...){
  UseMethod("indel_check")
}

####
#' @rdname indel_check
#' @export
indel_check.coi5p = function(x, ..., indel_threshold = -358.88, aa_PHMM = aa_coi_PHMM){
  if(is.null(x$framed)|is.null(x$aaSeq) ){
    stop("indel_check function only accepts framed and translated coi5p objects. See functions: frame, translate.")
  }

  aaBin = individual_AAbin(x$aaSeq)
  aaPHMMout = aphid::Viterbi(aa_PHMM, aaBin, odds = FALSE)
  x$aaScore = aaPHMMout[['score']]
  x$data$aaPath = aaPHMMout[['path']]

  if(x$aaScore > indel_threshold){
    x$indel_likely = FALSE
  }else{
    x$indel_likely = TRUE
  }

  if(grepl('\\*', x$aaSeq)){
    x$stop_codons = TRUE
  }else{
    x$stop_codons = FALSE
  }
  return(x)
}
