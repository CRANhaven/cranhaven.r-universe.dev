
#' build an DNAbin with ape.
#'
#' Switches the dashes in the seq - to n
#'
#' @keywords internal
individual_DNAbin = function(dna_string){
	return(ape::as.DNAbin(strsplit(gsub('-', 'n', as.character(tolower(dna_string))),"")))
}

#' build an AAbin with ape.
#'
#' @keywords internal
individual_AAbin = function(aa_string){
	return(ape::as.AAbin(strsplit(as.character(aa_string),"")))
}


#' Check for a large number of leading inserted bases.
#'
#' If this is the case, TRUE is returned and the PHMM
#' should be run a second time on the truncated data.
#' @keywords internal
leading_ins = function(seq_path){
	#iterate along the sequence, if we hit 5 insertions
	#before 5 matches then there is a problem
	matches = 0
	ins = 0
	for(x in seq_path){
		if (x == 1){
			matches = matches + 1
		} else if (x == 2){
			ins = ins + 1
		}

		if (matches == 5){
			return(FALSE)
		}
		if (ins == 5){
			return(TRUE)
		}
	}
}

#' Check sequence for an early large string of deletions.
#' If it exists then return the starting index by which to slice the path and the string.
#' @keywords internal
ins_front_trim = function(path_out, search_scope = 15){
	if(sum(path_out[1:search_scope] == 2)>2){
		run_pos = min(which(path_out == 2))
		for(i in run_pos:length(path_out)){
			if(path_out[i] != 2){
				return(i)
			}
		}
	}
	return(0)
}


#' Take an input sequence and get it into the reading frame.
#'
#' Uses the path of the ntPHMM to locate the first contiguous
#' set of 5 matching base pairs (5 sequential 1s) for both the
#' front and the back of the sequence. Sequence information outside of this
#' first set of matches is trimmed (low probability of being true barcode sequence).
#' @keywords internal
set_frame = function(org_seq, path_out){
	org_seq_vec = strsplit(tolower(org_seq), split='')[[1]]

  #special processing for front of sequence, look for large runs of twos, if
	#so begin processing at the point in the path where the twos end, also account for
	#any matches (skipped & deleted from seq) and inserts (added as buffer for proper
	#folmer alignment) at the front of the sequence.
	adj_for_dels = ins_front_trim(path_out)

	add_org_drop = 0
	org_buff = 0

	#If there are a large number (>2) of deletes in the first 15bp
	#then adjust the sequence so the end of the delete run is the starting point
	if(adj_for_dels != 0){
		#this line accounts for 1s and twos in the leading drop section, need to trim those out of original seq as well
	  add_org_drop = sum(path_out[1:(adj_for_dels-1)] == 2) + sum(path_out[1:(adj_for_dels-1)] == 1)
    org_buff = sum(path_out[1:(adj_for_dels-1)] == 0)

	  org_seq_vec = org_seq_vec[add_org_drop:length(org_seq_vec)]

		path_out = path_out[adj_for_dels:length(path_out)]
	}

	#account for any 0s in the leading part of the sequence that was processed separately
	front = c()
  if (org_buff > 0){
    for(i in 1:org_buff){
      front = c(front, "-")
    }
  }

	org_seq_start = 1
	org_seq_end = length(org_seq_vec)

	for( i in 1:length(path_out) ){
		#0 = D
		if( path_out[i] == 0 ){
			#there was a bp missing in the original seq
			#add a placeholder to the new seq, don't advance on original pointer
			front = c(front, '-')
		#2 = I
		}else if( path_out[i] == 2 ){
			#there was an extra bp at the front of the sequence
			#not represented in the PHMMs, skip this bp in the original seq
			org_seq_start = org_seq_start + 1
		#for the first match seen, check to make sure it isn't a single match
		#or codon of dangling matches in a sea of inserts or deletes
		}else if( path_out[i] == 1 ){
			if (2 %in% path_out[(i+1):(i+4)] ){
				org_seq_start = org_seq_start + 1
			}else if (0 %in% path_out[(i+1):(i+4)] ){
			  org_seq_start = org_seq_start + 1
			  front = c(front, '-')
			}else{
				break
			}
		}
	}

	for( i in length(path_out):1 ){
		#0 = D
		if( path_out[i] == 0 ){
			#there was a bp missing at the back of the original seq
			#just continue to the next position
			next
		#2 = I
		}else if( path_out[i] == 2 ){
			#there is an extra base pair at the end of the original sequence
			#not represented in the PHMMs, remove this trailing end of the original sequence
			org_seq_end = org_seq_end - 1
		}else if ( path_out[i] == 1){
			#in either of these instances we want to trim the last bp, as its
			#dangling in a sea of inserts or deletes and likely a random profile match
			if (2 %in% path_out[(i-4):(i-1)]){
				org_seq_end = org_seq_end - 1
			}else if (0 %in% path_out[(i-4):(i-1)]){
			  	org_seq_end = org_seq_end - 1
			}else{
				break
			}
		}
	}

	if(length(org_seq_vec[org_seq_start:org_seq_end]) < length(org_seq_vec)){
	  trimmed_rep = TRUE
	}else{
	  trimmed_rep = FALSE
	}
	#returns the framed sequence, along with the position in the input sequence where folmer match begins
	#and the position in the folmer region where the folmer match begins
	return(list( framed = paste(c(front,org_seq_vec[org_seq_start:org_seq_end]),collapse= ""),
	             raw_start = add_org_drop+1,
	             folmer_start = (length(front)+1),
	             trimmed = trimmed_rep))
}

