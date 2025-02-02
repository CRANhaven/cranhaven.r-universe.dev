# PlasmaMutationDetector2
# release 1.1.10: First public release
# release 1.1.11: name change and clean print()


# #' @importFrom GenomicRanges GRanges
#' @importClassesFrom S4Vectors FilterRules
#' @importClassesFrom SummarizedExperiment RangedSummarizedExperiment
#' @importMethodsFrom SummarizedExperiment rowRanges
#' @import GenomicRanges
#' @import VariantAnnotation
#' @importFrom Rsamtools PileupParam BamFile scanBam pileup filterBam ScanBamParam scanBamWhat
#' @import ggplot2
#' @import grid
#' @importFrom graphics abline plot points text
#' @importFrom stats dnorm integrate median pbinom quantile binom.test na.omit
#' @importFrom utils data download.file read.delim read.table write.table unzip
#' @importFrom grDevices dev.off
#'
#' @encoding{utf-8}
#'

# # Bioconductor packages installation:
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("GenomicRanges") # was: biocLite("GenomicRanges")
# BiocManager::install("VariantAnnotation") # was: biocLite("VariantAnnotation")
# BiocManager::install("Rsamtools") # was: biocLite('Rsamtools')
# BiocManager::install("rtracklayer") # was: biocLite('rtracklayer')
# BiocManager::install("SummarizedExperiment") # was: biocLite("SummarizedExperiment")
#
# # R packages installation:
# install.packages(c('robustbase','ggplot2','grid'))

# R packages
require(robustbase)
require(ggplot2)
require(grid)
require(GenomicRanges)
require(VariantAnnotation)
require(Rsamtools)
require(rtracklayer)

##################### UTILITY FUNCTIONS #####################

c2n = function(x) as.numeric(as.character(x))

sbscore = function(refplus, refmin, altplus, altmin) {
  if (is.na(altplus) | is.na(altmin)) return(NA)
  if (altplus==0 & altmin==0) return(0)

  rmM = function(x,y) pmin(x,y)/pmax(x,y)

  SB = rep(NA,length(refplus))
  ind = which(!is.na(altplus) & !is.na(altmin))
  z = (refplus[ind]*altmin[ind])/(refmin[ind]*altplus[ind])
  strandbias = log( rmM(refplus[ind],refmin[ind])/rmM(altplus[ind],altmin[ind]) * (z+1/z) )
  if (length(strandbias)==0) return(NA) #To avoid error message when strandbias is empty, Added by ON 21.04.20
  SB[ind] = strandbias;
  return(SB);
}

pvalue = function(E,N=NULL,E0=NULL,N0=NULL,with.info=FALSE,use.int=TRUE) {
  # return the pvalue
  if (is.null(N)) {N=E[2]; E0=E[3]; N0=E[4]; E=E[1]}
  if (E0==0) E0=1/sqrt(N0) # provides an upper bound for the p-value by assuming control error rate equals 1/N0^(3/2)
  p0.hat = E0/N0
  sigma0.hat = sqrt(p0.hat*(1-p0.hat)/N0)
  if (with.info) {
    print(paste0('p0.hat=',p0.hat,' --- p.hat=',E/N))
    print(sigma0.hat)
  }
  psi = function(y) pbinom(E,N,pmax(pmin(p0.hat-sigma0.hat*y,1),0),lower.tail=F)*dnorm(y)
  if (use.int) p.val = integrate(psi,lower=-30,upper=30,subdivisions=10000L)$value else p.val = binom.test(E,N,p0.hat,'great')$p.value
  p.val
}


minus.logit = function(P) {
  sapply(P,function(x) {if ((!is.nan(x))&(x<1)) return(-log(x/(1-x))) else return(-Inf)})
}

find.outliers = function(P,chr.pos,thr.R=6.5,thr.P=0.000001,with.info=FALSE) {

  P[which(P==1)]=0.9999999999 ### just to have finite values
  names(P) = chr.pos
  ind.null = (P==0)
  P.null = P[which(ind.null)]
  P = P[which(!ind.null)]
  nP = length(P)
  L.tri = sort(minus.logit(P))
  dL = diff(L.tri);
  L.right = L.tri[-1];
  L.left = L.tri[-nP];
  sL.sqrt = sign(L.left)*(abs(L.left))^0.5 # to take the square root without changing the sign
  Ratio = dL/sL.sqrt

  # outliers = c(which( (Ratio>thr.R) & (L.right>minus.logit(thr.P))),P.null)
  outliers = c(which(Ratio>thr.R),P.null)

  ind = names(outliers)

  if (with.info) { ### just for debugging purpose. Not used.
    plot(L.tri[-1][L.left>0],Ratio[L.left>0],col=1)
    abline(v=minus.logit(thr.P),col='red'); abline(h=thr.R,col='green'); abline(h=6,col='cyan'); abline(h=7,col='violet');
    # if (length(outliers)>0) outliers = which(L.right>=min(L.right[min(outliers)]))
    if (length(outliers)>0) points(L.right[outliers],Ratio[outliers],col='red',pch='x')
    if (length(outliers)>0) text(L.right[outliers],Ratio[outliers],labels=ind,cex=0.6,pos=2,col=1)
    if (length(outliers)>0) print(sort(P,decreasing=T)[outliers+1])
  }

  ind
}

UpperPart = function(values,q,do.boolean.only=FALSE) {
  # Find the locations inside a set of values higher than an upper quantile of these values
  # Return the indices of the highest values, larger than the given quantile
  ind = (values > quantile(values,q,na.rm=TRUE))
  if (do.boolean.only) return(ind)
  noisy = which(ind)
  noisy
}

pileupFreq = function(pileupres) {
  nucleotides = levels(pileupres$nucleotide)

  res = split(pileupres, pileupres$seqnames)
  res = lapply(res, function (x) split(x, x$pos))
  res = lapply(res, function (positionsplit) {
    nuctab = lapply(positionsplit, function(each) {
      chr = as.character(unique(each$seqnames))
      pos = as.character(unique(each$pos))
      tablecounts = sapply(nucleotides, function (n)
        sum(each$count[each$nucleotide == n]))
      tablecountsplus = sapply(nucleotides, function (n)
        sum(each$count[each$nucleotide == n & each$strand=="+"]))
      tablecountsminus = sapply(nucleotides, function (n)
        sum(each$count[each$nucleotide == n & each$strand=="-"]))
      strandbias = sapply(nucleotides, function (n)
        max(0,each$count[each$strand=="+" & each$nucleotide == n])/
          (max(0,each$count[each$strand=="+" & each$nucleotide == n]) + max(0,each$count[each$strand=="-" & each$nucleotide == n]))
      )
      c(chr,pos, tablecounts, tablecountsplus, tablecountsminus, strandbias)
    })
    nuctab = data.frame(do.call("rbind", nuctab),stringsAsFactors=F)
    rownames(nuctab) = NULL
    nuctab
  })
  res = data.frame(do.call("rbind", res),stringsAsFactors=F)
  rownames(res) = NULL
  colnames(res) = c("seqnames","start",levels(pileupres$nucleotide),
                    paste0(levels(pileupres$nucleotide),"_plus"),
                    paste0(levels(pileupres$nucleotide),"_minus"),
                    paste0(levels(pileupres$nucleotide),"_SB"))
  res[,3:ncol(res)] = apply(res[,3:ncol(res)], 2, as.numeric)
  res
}

my.read = function(name,the.cols) read.table(name,header=TRUE,sep='')[,the.cols]

### Functions to compute upper rate of errors
# Massart'90 upper bound
upper_rate_massart = function(E0,N0,alpha){
  p.hat = max(E0,1/log(N0))/N0
  l.alpha = log(1/alpha)
  epsilon = 3*(l.alpha*(1-2*p.hat)+sqrt(l.alpha^2+18*N0*(1-p.hat)*p.hat))/(2*l.alpha+9*N0) # bound of Massart'90
  p.hat+epsilon
}

# # beta upper bound
# upper_rate_beta = function(E0,N0,alpha) {
#   E0 = max(E0,1)
#   return(qbeta(1-alpha,E0,N0-E0+1))
# }
#
# # Fisher upper bound
# upper_rate_Fisher = function(E0,N0,alpha) {
#   E0 = max(E0,1)
#   return((1+(N0-E0+1)/E0/qf(1-alpha,2*E0,2*(N0-E0+1)))^(-1))
# }
#
# # exact bionamial upper bound
# upper_rate_binom = function(E0,N0,alpha) {
#   p0 = max(E0,1/log(N0))/N0
#   return(qbinom(1-alpha,N0,p0)/N0)
# }

upper_rate = upper_rate_massart

############ END OF UTILITY FUNCTIONS ##################


############ DOCUMENTED FUNCTIONS ######################

#' function PrepareLibrary
#'
#' Define the Genomic Ranges and Genomic Positions covered by the AmpliSeq™ Panel to include in the study and define SNP positions to exclude from the study.
#' Trimming amplicon ends is performed if specified. This function is mostly useful if you want to add some SNP positions which are not existing in the
#' positions_ranges.rda file provided within the package. It is provided to be able to reconstruct \code{positions_ranges.rda} data.
#'
#' @param info.dir, char, name of the folder containing the library information files (default 'Info/')
#' @param bed.filename, char, name of a BED table (tab-delimited) describing the Panel (with first 3 columns: "chr" (ex:chr1), "start position" (ex:115252190), "end position" (ex:115252305), i.e. the Ion AmpliSeq™ Colon and Lung Cancer Research Panel v2 (default 'lungcolonV2.bed.txt' as provided in the inst/extdata/Info folder of the package).
#' @param snp.filename, char, name of the vcf file describing known SNP positions, obtained from ftp://ftp.broadinstitute.org/pub/ExAC_release/release0.3/ExAC.r0.3.sites.vep.vcf.gz (default 'ExAC.r0.3.sites.vep.vcf.gz'). It requires a corresponding TBI file to be in the same folder (obtained from ftp://ftp.broadinstitute.org/pub/ExAC_release/release0.3/ExAC.r0.3.sites.vep.vcf.gz.tbi)
#' @param snp.extra, a vector of char, a vector of extra known snp positions manually curated (ex:"chrN:XXXXXXXXX")
#' @param output.name, char, filename to save \code{pos_ind} and \code{pos_snp} (default 'positions_ranges.rda')
#' @param output.dir, char, directory where to save \code{pos_ind} and \code{pos_snp} (default \code{info.dir})
#' @author N. Pécuchet, P. Laurent-Puig, O. Nordgård and Y. Rozenholc
#' @seealso positions_ranges,
#' @references \emph{Analysis of base-position error rate of next-generation sequencing to detect tumor mutations in circulating DNA} N. Pécuchet, Y. Rozenholc, E. Zonta, D. Pietraz, A. Didelot, P. Combe, L. Gibault, J-B. Bachet, V. Taly, E. Fabre, H. Blons, P. Laurent-Puig in \emph{Clinical Chemistry}
#' @references \emph{Novel hybridization- and tag-based error-corrected method for sensitive ctDNA mutation detection using ion semiconductor sequencing} Kjersti Tjensvoll, Morten Lapin, Bjørnar Gilje, Herish Garresori, Satu Oltedal, Rakel Brendsdal Forthun, Anders Molven, Yves Rozenholc and Oddmund Nordgård  in \emph{Scientific Reports}
#'
#' @return Save the following variables in a .rda file defined by \code{output.name} in the folder defined by \code{output.dir}:
#' \itemize{
#' \item \code{pos_ranges}, a GRanges descriptor of amplicon positions
#' \item \code{pos_ind}, a vector of char "chrN:XXXXXXXXX", defining ALL index positions
#' \item \code{pos_snp}, a vector of char "chrN:XXXXXXXXX", defining SNP positions
#' }
#'
#' @export PrepareLibrary
#'
#' @examples
#'    bad.pos = "chr7:15478"
#'    PrepareLibrary(info.dir='./',snp.extra=bad.pos,output.dir=paste0(tempdir(),'/'))
#'
#'
PrepareLibrary = function(info.dir='Info/',
                          bed.filename='PACT-ACT_iDES_1_Regions.bed', # amplicon positions
                          snp.filename='ExAC.r1.sites.vep.vcf.gz', # known snp
                          snp.extra=NULL, # extra snp
                          output.name='positions_ranges.rda',
                          output.dir=info.dir) {

  IRanges = NULL

  # Find SNP
  snp.file = paste0(info.dir,snp.filename)
  tbi.file = paste0(snp.file,'.tbi')
  if (!file.exists(snp.file) | !file.exists(tbi.file)) {
    message(paste0('File ',snp.file,' or ',tbi.file,' do not exist in ',info.dir,' ...'))
    message(paste0('... Please download them if needed.'))
    # DEFAULT : use provided file positions_ranges.rda
    message('Use positions_ranges.rda available in the package')
    data(positions_ranges,envir = environment())
  }

  if (file.exists(snp.file) & file.exists(tbi.file)) {
    # Read bed file
    bed.file = paste0(info.dir,bed.filename)
    if (!file.exists(bed.file)) stop(paste0(bed.file,' not found in ',info.dir))

    bed = read.delim(bed.file, header=FALSE) # original amplicons
    # Build index of all positions
    pos_ind = NULL
    for(i in 1:nrow(bed)) pos_ind = c(pos_ind,paste0(bed[i,1],':',bed[i,2]:bed[i,3]))

    # original positions for each amplicons
    pos_ranges = GRanges(bed[,1], IRanges(bed[,2], bed[,3]))

    # Build our snp selection
    vcf = readVcf(snp.file, "hg19", param=ScanVcfParam(which=GRanges(gsub('chr','',bed[,1]), IRanges(bed[,2], bed[,3]))))
    snp = cbind(info(vcf),as.data.frame(rowRanges(vcf))) # extract vcf information
    snp$AF = sapply(snp$AF, max) # consider only max allele frequency
    snp = snp[which(snp$AF>1e-4),] # only "real" snp with Allele Frequency >1e-4
    pos_snp = paste0('chr',snp$seqnames,':',snp$start) # build snp positions
  }

  pos_snp = c(pos_snp,snp.extra) # add the SNP positions you want

  output.name = paste0(output.dir,output.name)
  message(output.name)
  save(pos_ranges,pos_ind,pos_snp,file=output.name)
  message('File saved in ...')
  return(output.name)
}


#' function MAF_from_BAM
#'
#' Read BAM files  and create MAF file. BAMfiles are stored in a sub-folder '/rBAM'.
#' MAF files are intermediate files stored in a sub-folder '/BER'.
#' MAF files contain the raw counts of A,T,C,G, insertion, deletion, insertion>2bp, deletion >2bp for strand plus and stand minus.
#' Note : we strongly recommand to externally recalibrate BAM files using tools like GATK.
#'
#' @param study.dir, char, name of the folder containing the rBAM directory  (default 'Plasma/'). The typical folder hierarchy will consist of 'Plasma/rBAM'
#' @param input.filenames, a vector of char (default NULL), the names of the BAM files to process. If NULL all BAM files in the rBAM folder will be processed
#' @param bai.ext, char, filename extension of the bai files (default '.bai')
#' @param pos_ranges.file, char, name of the Rdata file containing the three variables \code{pos_ind}, \code{pos_snp} and \code{pos_ranges} as build by the function \code{PrepareLibrary}. Default NULL, use the position_ranges.rda provided, used for our analysis.
#' @param force, boolean, (default FALSE) if TRUE force all computations to all files including already processed ones
#' @param output.dir, char, name of the folder to save results  (default \code{study.dir})
#' @param n.trim, integer, number of base positions trimmed at the ends of each amplicon (default 8)
#' @author N. Pécuchet, P. Laurent-Puig, O. Nordgård and Y. Rozenholc
#' @references \emph{Analysis of base-position error rate of next-generation sequencing to detect tumor mutations in circulating DNA} N. Pécuchet, Y. Rozenholc, E. Zonta, D. Pietraz, A. Didelot, P. Combe, L. Gibault, J-B. Bachet, V. Taly, E. Fabre, H. Blons, P. Laurent-Puig in \emph{Clinical Chemistry}
#' @references \emph{Novel hybridization- and tag-based error-corrected method for sensitive ctDNA mutation detection using ion semiconductor sequencing} Kjersti Tjensvoll, Morten Lapin, Bjørnar Gilje, Herish Garresori, Satu Oltedal, Rakel Brendsdal Forthun, Anders Molven, Yves Rozenholc and Oddmund Nordgård  in \emph{Scientific Reports}
#'
#' @return the path/names of the MAF files
#'
#' @export MAF_from_BAM
#'
#' @examples
#'   \dontrun{
#'      ctrl.dir = system.file("extdata", "4test_only/ctrl/",
#'        package = "PlasmaMutationDetector2")
#'      if (substr(ctrl.dir,nchar(ctrl.dir),nchar(ctrl.dir))!='/')
#'        ctrl.dir = paste0(ctrl.dir,'/') # TO RUN UNDER WINDOWS
#'      MAF_from_BAM(ctrl.dir,force=TRUE,output.dir=paste0(tempdir(),'/'))
#'    }
#'
MAF_from_BAM = function(study.dir='Plasma/',input.filenames=NULL,bai.ext='.bai',
                        pos_ranges.file=NULL,force=FALSE,output.dir=study.dir,n.trim=8) {

  pos_ind = pos_snp = pos_ranges = NULL

  if (is.null(pos_ranges.file)) {
    data(positions_ranges,envir=environment())
  } else {
    if (!file.exists(pos_ranges.file)) stop(paste('STOP :::',pos_ranges.file,' does not exist'))
    load(pos_ranges.file)
  }

  ######## Input/Output folders
  bam.dir = paste0(study.dir,'rBAM/')        # Folder for BAM files and BAI index files
  ber.dir = paste0(study.dir,'BER/')         # Default folder for BER files
  ber.outdir = paste0(output.dir,'BER/')     # Folder to save Background Error Rate files extracted from BAM files
  if (!dir.exists(ber.outdir)) dir.create(ber.outdir)

  ######## pileup parameters
  pileup.param = PileupParam(max_depth=100000, min_base_quality=20, min_mapq=5, min_nucleotide_depth=1,
                             min_minor_allele_depth=0, # min_base_quality=20, min_mapq=5
                             distinguish_strands=TRUE, distinguish_nucleotides=TRUE, ignore_query_Ns=TRUE,
                             include_deletions=TRUE,
                             include_insertions=TRUE)

  ######## Samples to process
  if (is.null(input.filenames)) {
    message(paste0("Looking for bam and bai in ",bam.dir,' ...'))
    input.filenames = dir(bam.dir, pattern="*.bam$") # list all BAM files in bam.dir
  }

  bam.files = paste0(bam.dir,input.filenames) # build bam.files as paste0(study.dir,'rBAM/',input.filenames[i])

  if (length(bam.files)==0) stop(paste('STOP ::: no bam file found ... NOTE: bam files need to be in a subdirectory called rBAM'))

  ber.files = rep(NA,length(bam.files))

  for( g in 1:length(bam.files)) {

    bam.name = bam.files[g]
    bai.name = gsub('.bam$',bai.ext,bam.name)
    ber.name = gsub(bam.dir,ber.dir,gsub('.bam$','_MAF.txt',bam.name),fixed=TRUE) # local BER
    berzip.name = paste0(ber.name,'.zip') # local zip BER
    ber.outname = gsub(bam.dir,ber.outdir,gsub('.bam$','_MAF.txt',bam.name),fixed=TRUE) # BER to create
    berzip.outname = paste0(ber.outname,'.zip') # BER to create in zip version

    ber.files[g] = ber.outname

    if (!force & file.exists(ber.name)) {
      ber.files[g] = ber.name
      next()
    }
    if (!force & file.exists(ber.outname)) {
      ber.files[g] = ber.outname
      next()
    }

    if (!force & file.exists(berzip.name)) {
      ber.files[g] = unzip(zipfile=berzip.name,exdir=ber.outdir)
      # write.table(readLines(unz(berzip.name,rev(strsplit(ber.name,'/')[[1]])[1])),file=ber.outname,sep=' ',row.names=FALSE,col.names=FALSE,quote=FALSE)
      next()
    }
    if (!force & file.exists(berzip.outname)) {
      ber.files[g] = unzip(zipfile=berzip.outname,exdir=ber.outdir)
      # write.table(readLines(unz(berzip.outname,rev(strsplit(ber.name,'/')[[1]])[1])),file=ber.outname,sep=' ',row.names=FALSE,col.names=FALSE,quote=FALSE)
      next()
    }

    message(paste0('Processing MAF from file ',bam.name))

    ### Load BAM and BAI files
    if (!file.exists(bam.name)) stop(paste('STOP :::',bam.name,'not found ... NOTE : bam files need to be in a subdirectory called rBAM'))
    if (!file.exists(bai.name)) {
      bai.sndname = paste0(bam.name,'.bai')
      if (!file.exists(bai.sndname)) stop(paste('STOP :::',bai.name,' and ',bai.sndname,'not found ... NOTE : bai files need to be in a subdirectory called rBAM'))
      bai.name = bai.sndname
    }

    bf = BamFile(bam.name, index=bai.name)

    ### Import, count, index, filter, sort, and merge BAM

    ft = scanBam(bf, scanBamParam=ScanBamParam(which=pos_ranges, what=scanBamWhat()), pileupParam=pileup.param)

    ### Count SNV from the BAM file
    res = pileup(bf, scanBamParam=ScanBamParam(which=pos_ranges, what=scanBamWhat()), pileupParam=pileup.param)


    ## Extract begin/end of each amplicon
    ampl.pos = t(sapply(levels(res$which_label),function(ampl) as.numeric(unlist(strsplit(strsplit(ampl,':')[[1]][2],'-'))),USE.NAMES=F))
    ampl.pos = data.frame(begin=ampl.pos[,1],end=ampl.pos[,2])

    #### USE res$which_label to find the amplicon
    ## Split reads by amplicon
    res.by.ampl = split(res,res$which_label)
    size.by.ampl = t(sapply(res.by.ampl,dim))

    ## Trim 8 bases at each end of the amplicon
    for (i in 1:length(res.by.ampl)) {
      if (size.by.ampl[i,1]==0) {
        message(paste('WARNING: no capture on amplicon',row.names(size.by.ampl)[i]))
        next()
      }
      res.by.ampl[[i]] = subset(res.by.ampl[[i]],((ampl.pos$begin[i]+n.trim)<=pos)&(pos<=(ampl.pos$end[i]-n.trim)))
      if (dim(res.by.ampl[[i]])[1]==0) message(paste('WARNING: after trimming no more bases on amplicon',row.names(size.by.ampl)[i]))
    }

    ## remove amplicon without lecture after trimming
    size.by.ampl = t(sapply(res.by.ampl,dim))
    res.by.ampl = res.by.ampl[size.by.ampl[,1]>0]

    ## Call function pileupFreq to get a data.frame of counts per trimmed amplicon
    freq.by.ampl = lapply(res.by.ampl,pileupFreq)

    ## Pull amplicon together
    freq = freq.by.ampl[[1]]
    n.cols = dim(freq)[2]
    for (i in 2:length(freq.by.ampl)) {
      in.already = which((freq.by.ampl[[i]]$seqnames %in% freq$seqnames)&(freq.by.ampl[[i]]$start %in% freq$start))
      if (length(in.already)>0) {
        for (j in in.already) {
          j.freq = which((freq$seqnames==freq.by.ampl[[i]]$seqnames[j]) & (freq$start==freq.by.ampl[[i]]$start[j]))
          freq[j.freq,3:n.cols] = freq[j.freq,3:n.cols] + freq.by.ampl[[i]][j,3:n.cols]
        }
        freq.by.ampl[[i]] = freq.by.ampl[[i]][-in.already,]
      }
      freq = rbind(freq,freq.by.ampl[[i]])
    }

    freq$chrpos = NULL
    freq$chrpos = paste(freq[,1],freq[,2], sep=":") # positions existing in the BAM file
    select = freq[which(freq$chrpos %in% pos_ind),] # extract positions of interest

    ### Compute coverture; major coverture, major frequency, background frequency, second major coverture
    select[,'cov']=select[,3]+select[,4]+select[,5]+select[,6]
    select[,'maj']=apply(select[,3:6],1,max)
    select[,'fmaj']=select$maj/select$cov
    select[,'bruitdefond']=1-select$fmaj
    select[,'MA'] = apply(select[,3:6],1,sort)[3,]

    ### Select and count reads with DELETIONS >2bd nucleotides
    dels = grep("[D]", ft[[1]][["cigar"]], invert=FALSE)  # index reads carrying deletions
    numdel = regmatches(as.character(ft[[1]]$cigar[dels]), gregexpr('([0-9]+)D',ft[[1]]$cigar[dels])) # get number of deleted bp
    numdel.max = sapply(lapply(numdel,function(x) as.numeric(gsub('D','',x)) ),max) # for reads with multiple deletions, get the maximum number of deleted bp
    selection = dels[which(as.numeric(numdel.max)>2)] # index reads carrying deletions > 2 bp
    subft = sapply(ft[[1]],function(x) x[selection] ) # generate filter for temporary BAMfile export that contain reads with deletion >2bp only

    ### Select read ids with deletion >2bp
    filter = S4Vectors::FilterRules(list(KeepQname = function(ft) ft$qname %in% subft$qname))
    ### Build a temporary BAM file with selected reads
    dest = filterBam(bam.name, tempfile(),index=bai.name, filter=filter, param=ScanBamParam(what="qname"))
    ### Import this temporary BAM file
    # import the temporary BAMfiles that contain reads with deletion >2bp only
    gal = rtracklayer::import(dest,format='bam', param=ScanBamParam(what=(c("qname", "seq", "qual"))) )

    ### Select read ids with long deletions, skip the deletions < 3bp that could co-occur in the same read by replacing CIGAR D by CIGAR N
    if (length(gal@cigar)>0) {  # Added by Oddmund, to avoid indexing empty file
      for (z in 1:length(gal@cigar)) {
        mm = regmatches(gal@cigar[z], gregexpr('[0-9]+[A-Z]',gal@cigar[z]))
        ind = grep('D',mm[[1]])                                                       # YVES 5/09/2016
        if (length(ind)>0) {                                                          # YVES 5/09/2016
          jnd = which(as.numeric(gsub('D','',mm[[1]][ind]))<3)                        # YVES 5/09/2016
          if (length(jnd)>0) mm[[1]][ind[jnd]] = gsub('D','N',mm[[1]][ind[jnd]])      # YVES 5/09/2016
        }                                                                             # YVES 5/09/2016
        # mm[[1]][which(as.numeric(as.character(gsub("D", "", mm[[1]]))) < 3)]=gsub("D", "N", mm[[1]][which(as.numeric(as.character(gsub("D", "", mm[[1]]))) < 3)])
        gal@cigar[z] = paste(mm[[1]], collapse="")
      }
    }
    else ind = integer(0) # Y : ind with length 0

    ### Build a temporary BAM file with selected reads
    dest = rtracklayer::export(gal, BamFile(tempfile())) # export the temporary BAMfile cleared of any deletions < 3bp
    ### Import this temporary BAM file
    res = pileup(dest, scanBamParam=ScanBamParam(which=pos_ranges, what=scanBamWhat()), pileupParam=pileup.param)

    ### Build a data.frame of long deletion counts
    if (nrow(res)>0) {
      freq = pileupFreq(res)	# read the cleared temporary BAMfile

      contig = freq[which(freq[,'-'] > 0),c(1:9,17,25,33)] # create dataframe for long deletions
      contig$posid = numeric(nrow(contig)) # add a new variable to define starting point of deletion and take care of emptyness

      if (nrow(contig)>0) { # find large deletions (>2bp) and assign
        loc = dloc = 1
        while(loc<nrow(contig)) {
          while ((loc+dloc<=nrow(contig)) & (as.numeric(contig$start[loc])+dloc==as.numeric(contig$start[loc+dloc])) &
                 (abs(mean(contig[loc+(0:(dloc-1)),'-'])-contig[loc+dloc,'-'])/mean(contig[loc+(0:(dloc-1)),'-']) < 0.2)) dloc = dloc+1
          dloc = dloc-1 # now dloc is the number of bases with same deletion as loc
          if (dloc>1) { # found large deletion (>2bp)
            contig$posid[loc+(0:dloc)] = loc
            loc = loc+dloc+1
          } else loc = loc+1 # deletion too small
          dloc = 1 # go to next deletion, restart deletion length
        }
      }

      ### remove positions with inconsistent deletions (<2bp or different frequency)
      contig = contig[!is.na(contig$posid),]
      contig$chrpos = character(nrow(contig)) # add a new variable to define starting point of deletion and take care of emptyness
      if (nrow(contig)>0) contig$chrpos=paste0(contig$seqnames,":",contig$start)

      # YVES 08/11/2017 : # A warning to prevent the false duplication of deletions
      if (any(duplicated(contig$chrpos)))
        cat(' !!!!!!! warning  !!!!! duplicates in deletion for sample',bam.files[g],'\n')

    } else { # end of (nrow(res)>0) ... force creation of contig # YVES 17/03/2020 ... version 1.1.6
      contig = as.data.frame(matrix(nrow=0,ncol=14))
      colnames(contig)=c("seqnames","start","A","C","G","T","N","=","-","-_plus","-_minus","-_SB","posid","chrpos")
    }

    ### Select and count reads with INSERTIONS >2bp nucleotides
    ins = grep("[I]", ft[[1]][["cigar"]], invert=FALSE) # index reads carrying insertions
    numins = regmatches(as.character(ft[[1]]$cigar[ins]), gregexpr('([0-9]+)I',ft[[1]]$cigar[ins])) # get number of inserted bp
    numins2 = sapply(sapply(numins,function(x){gsub('I','',x)}),max) # for reads with multiple insertions, get the maximum number of inserted bp
    selection=ins[which(as.numeric(numins2)>2)] # index reads carrying deletions > 2bp
    subft = sapply(ft[[1]],function(x) x[selection])

    ### Select read ids with insertion >2bp only
    filter = S4Vectors::FilterRules(list(KeepQname = function(ft) ft$qname %in% subft$qname))
    ### Build a temporary BAM file with selected reads
    dest = filterBam(bam.name, tempfile(),index=bai.name, filter=filter, param=ScanBamParam(what="qname"))
    ### Import this temporary BAM file
    gal = rtracklayer::import(dest,format='bam', param=ScanBamParam(what=(c("qname", "seq", "qual"))) ) # import the temporary BAMfile that contain reads with insertion >2bp only

    # For reads with long insertions, skip the insertions < 3bp that could co-occur in the same read by replacing CIGAR I by CIGAR S(hort)
    if (length(gal@cigar)>0) {   #O Just do this if we have any reads in the gal temp bam file
      for (z in 1:length(gal@cigar)){ # gal@cigar[z] is something like xxMxxIxxDxxY
        mm = regmatches(gal@cigar[z], gregexpr('[0-9]+[A-Z]',gal@cigar[z])) # split sequence into subsequences made of numbers-letter xxM xxI xxD xxY
        ind = grep('I',mm[[1]])       # find subsequences with 'I' that is insertions: YVES 5/09/2016
        if (length(ind)>0) {          # YVES 5/09/2016
          jnd = which(as.numeric(gsub('I','',mm[[1]][ind]))<3)                    # if xx<3 change 'I' to 'S'(hort) : YVES 5/09/2016
          if (length(jnd)>0) mm[[1]][ind[jnd]] = gsub('I','S',mm[[1]][ind[jnd]])  # if xx<3 change 'I' to 'S'(hort) : YVES 5/09/2016
        }                             # YVES 5/09/2016
        # mm[[1]][which(as.numeric(as.character(gsub("I", "", mm[[1]]))) < 3)]=gsub("I", "S", mm[[1]][which(as.numeric(as.character(gsub("I", "", mm[[1]]))) < 3)])
        gal@cigar[z] = paste(mm[[1]], collapse="") # correct gal@cigar[z] with corrected subsequences collapse in one long sequence
      }
      #} #Paranthesis moved as potential bug fix 17.04.2020, by ON

      ### Build a temporary BAM file with selected reads

      dest = rtracklayer::export(gal, BamFile(tempfile())) # export the temporary longins BAMfile cleared of any insertsions < 3bp
      ### Import this temporary BAM file
      #read temp BAM file
      res = pileup(dest, scanBamParam=ScanBamParam(which=pos_ranges, what=scanBamWhat()), pileupParam=pileup.param)

      # extract counts ... could it create pb if res empty ???
      freq = pileupFreq(res)		# read the cleared temporary BAMfile
      ind = which(freq[,'+'] > 0)
    } # Paranthesis moved here as bugfix 17.04.20, by ON

    if (length(ind)>0) {
      incontig = freq[ind,c(1:8,10,18,26,34)] # create dataframe for long insertions
      incontig$chrpos = paste0(incontig$seqnames,":",incontig$start)
    } else {
      incontig = as.data.frame(matrix(nrow=0,ncol=13))
      colnames(incontig)=c("seqnames","start","A","C","G","T","N","=","+","+_plus","+_minus","+_SB","chrpos")
    }
    unlink(dest)

    ##### Merge dataframes for SNV, DELETIONS>2bp and INSERTIONS>2bp
    mergeindels = merge(contig[,c(9:14)], incontig[,9:13], by='chrpos', all=TRUE)
    colnames(mergeindels) = c('chrpos','longdel','longdel_plus','longdel_minus','longdel_SB','posid','longins','longins_plus','longins_minus','longins_SB')
    select = merge(select, mergeindels, by='chrpos', all=TRUE)
    select[is.na(select$longdel),'longdel'] = 0
    select[is.na(select$longins),'longins'] = 0
    select[,'longINDEL'] = apply(select[,c('longdel','longins')],1,max)

    #### Remove trimmed positions which have been added when checking for INDEL
    select = select[!is.na(select$start),]

    ### save ber.file
    write.table(select[!duplicated(select$chrpos),], file=ber.outname, row.names=FALSE, col.names=TRUE) ####  save temporary files
  }

  return(ber.files)

}


#' function BuildCtrlErrorRate
#'
#' Compute the SNV Position-Error Rates and INDEL Position-Error Rates from control samples (available in the control directory \code{ctrl.dir}).
#' This function requires MAF files, that will be automatically generated if not present in the specified control folder.
#' SNV PER is computed as the sum in control samples of SNV background counts / sum in control samples of depths where SNV background counts = depth - major allele count.
#' INDEL PER is computed as sum in control samples of INDEL background counts / sum in control samples of depths where INDEL background counts = sum of insertion and deletion counts.
#'
#' @param ctrl.dir, char, foldername containing the control files (default 'Plasma ctrl/'). The typical folder hierarchy will consist of 'Plasma ctrl/rBAM'
#' @param bai.ext, char, filename extension of the bai files (default '.bai')
#' @param pos_ranges.file, char, name of the Rdata file containing the three variables \code{pos_ind}, \code{pos_snp} and \code{pos_ranges} as build by the function \code{PrepareLibrary}. Default NULL, use the position_ranges.rda provided, used for our analysis.
#' @param hotspot.file, char, name of the text file containing a list of the genomic positions of the hotspots (default NULL, read the provide hotspot.txt, see \code{hotspot})
#' @param cov.min, integer, minimal coverture to take into account a position (default 5000)
#' @param force, boolean, (default FALSE) if TRUE force all computations to all files including already processed ones
#' @param output.dir, char, name of the folder to save results (default \code{ctrl.dir}).
#' @param n.trim, integer, number of base positions trimmed at the ends of each amplicon (default 8)
#' @author N. Pécuchet, P. Laurent-Puig, O. Nordgård and Y. Rozenholc
#' @references \emph{Analysis of base-position error rate of next-generation sequencing to detect tumor mutations in circulating DNA} N. Pécuchet, Y. Rozenholc, E. Zonta, D. Pietraz, A. Didelot, P. Combe, L. Gibault, J-B. Bachet, V. Taly, E. Fabre, H. Blons and P. Laurent-Puig in \emph{Clinical Chemistry}
#' @references \emph{Novel hybridization- and tag-based error-corrected method for sensitive ctDNA mutation detection using ion semiconductor sequencing} Kjersti Tjensvoll, Morten Lapin, Bjørnar Gilje, Herish Garresori, Satu Oltedal, Rakel Brendsdal Forthun, Anders Molven, Yves Rozenholc and Oddmund Nordgård  in \emph{Scientific Reports}
#'
#' @return the number of processed files
#'
#' @export BuildCtrlErrorRate
#'
#' @examples
#' \dontrun{
#'    ctrl.dir = system.file("extdata", "4test_only/ctrl/", package = "PlasmaMutationDetector2")
#'    if (substr(ctrl.dir,nchar(ctrl.dir),nchar(ctrl.dir))!='/')
#'      ctrl.dir = paste0(ctrl.dir,'/') # TO RUN UNDER WINDOWS
#'    BuildCtrlErrorRate(ctrl.dir,output.dir=paste0(tempdir(),'/'))
#'    }
#'
BuildCtrlErrorRate = function(ctrl.dir='Plasma ctrl/',bai.ext='.bai',pos_ranges.file=NULL,hotspot.file=NULL,
                              cov.min=5000,force=FALSE,output.dir=ctrl.dir,n.trim=0) {


  ### read position informations
  pos_snp = pos_ind = NULL
  if (is.null(pos_ranges.file)) {
    data(positions_ranges,envir=environment())
  } else {
    if (!file.exists(pos_ranges.file)) stop(paste('STOP :::',pos_ranges.file,'does not exist'))
    load(pos_ranges.file)
  }

  ### read hotspot positions
  hotspot = NULL
  if (is.null(hotspot.file)) {
    data(hotspot,envir=environment())
  } else {
    if (!file.exists(hotspot.file)) stop(paste('STOP :::',hotspot.file,'does not exist'))
    hotspot = read.delim(hotspot.file, header=TRUE) # YVES 27/11/2017 FALSE -> TRUE
    if (!any(colnames(hotspot)=='chrpos')) stop(paste('STOP :::',hotspot.file,'has to contain a variable named chrpos (defined on first line)'))
  }

  ### extract counts from all BAM files found in ctrl.dir
  ctrl.files =  MAF_from_BAM(study.dir=ctrl.dir,input.filenames=NULL,bai.ext=bai.ext,pos_ranges.file=pos_ranges.file,force=force,output.dir=output.dir,n.trim=n.trim)

  message(ctrl.files)

  if (length(ctrl.files)>1) ind.g = 2:length(ctrl.files) else ind.g = 1 # just for testing purpose with one bam

  the.cols = c('chrpos','cov','maj','A','T','G','C','longINDEL','longdel','longins',"A_minus","T_minus","G_minus","C_minus","A_plus","T_plus","G_plus","C_plus") # columns of interest

  ### Assemble background errors from control samples
  background_error_rate = my.read(ctrl.files[1], the.cols)

  ### utility function :
  # extract main variant = genome ref
  ATGC.ind = which(colnames(background_error_rate) %in% c('A','T','G','C')) # index of A, T, G, C
  ATGC = colnames(background_error_rate)[ATGC.ind]

  getrefbase = function(x) { ATGC[which(as.numeric(x[ATGC.ind])==as.numeric(x['maj']))[1]]
  }  #New function to simply code reading, plus bugfix (as.numeric), 17.04.2020, by ON

  fct.MAJ = function(X) {
    data.frame(chrpos=as.character(X$chrpos),REF=apply(X,1,getrefbase))
  }

  MAJ = fct.MAJ(background_error_rate) # find main variant

  for (g in ind.g) { # for all controls
    Y = my.read(ctrl.files[g], the.cols)
    MAJ = merge(MAJ,fct.MAJ(Y),by='chrpos',all=TRUE,suffixes=c('',as.character(g))) # cat the main variants
    if (sum(is.na(MAJ[g]))>0){message(paste0("Error file: ",   ctrl.files[g]))}

    # add missing lines from Y to background_error_rate ->>> potentially, introduces NA's on Y's lines
    background_error_rate = merge(background_error_rate,subset(Y,select='chrpos'),by='chrpos',all=TRUE,suffixes=c('','.1'))[,the.cols]
    # add missing lines from background_error_rate to Y ->>> potentially, introduces NA's on background_error_rate's lines

    Y = merge(subset(background_error_rate,select='chrpos'),Y,by='chrpos',all=TRUE,suffixes=c('.1',''))[,the.cols]
    for (j in the.cols[-1]) { # for all columns of interest
      background_error_rate[is.na(background_error_rate[,j]),j] = 0 # replace NA's by 0 in background_error_rate
      Y[is.na(Y[,j]),j] = 0 # replace NA's by 0 in Y
      background_error_rate[,j] = background_error_rate[,j] + Y[,j] # sum background_error_rate and Y
    }
  }


  # keep positions in genomic ranges which are not SNP
  ok = (background_error_rate$chrpos %in% pos_ind) # positions defined genomic ranges
  not.ok = (background_error_rate$chrpos %in% pos_snp) # SNP positions

  ### Version keeping SNP : 03/12/2019
  MAJ = MAJ[ok,]
  background_error_rate = background_error_rate[ok,]
  background_error_rate$is.snp = not.ok
  # ### Version without SNP : before version 1.0.6
  # MAJ = MAJ[ok & !not.ok,]
  # background_error_rate = background_error_rate[ok & !not.ok,]

  # add E0 (all snv errors)
  background_error_rate$E0 = background_error_rate$cov-background_error_rate$maj

  # keep positions with enough coverture
  if (cov.min>0) {
    cov.ok = (background_error_rate$cov >= cov.min)
    MAJ = MAJ[cov.ok,]
    background_error_rate = background_error_rate[cov.ok,]
  }


  # Specify which are the hotspot positions
  background_error_rate$hotspot = (background_error_rate$chrpos %in% hotspot$chrpos)


  # get the reference at each position
  # REF = apply(MAJ,1,function(x) names(which.max(table(as.character(x[-1])))))

  # get at each position, the main variant(s) among the controls
  REF = apply(MAJ,1,function(x) paste(unique(as.character(x[-1])),collapse='-'))
  background_error_rate$REF = MAJ$TheREF = REF
  ind.new.snp = which(nchar(REF)>1) # find positions with more than one variant -> new snp
  if (length(ind.new.snp)>0) {
    #Start new code 08.05.20, O.N.
    ind.notreallynewsnp = which(background_error_rate$hotspot==TRUE & nchar(REF)>1)
    ind.new.snp = ind.new.snp[!ind.new.snp %in% ind.notreallynewsnp] #Dont make new SNP if position is already a known hotspot. We trust SNP databasee most, then hotspot, then new SNPs.
    background_error_rate$REF[ind.notreallynewsnp] = apply(MAJ[ind.notreallynewsnp,],1,function(x) names(which.max(table(x[-1])))) #In these cases we use the majority reference as reference base.
    #Stop New code added by O.N. 08.05.20, because we would like to keep hotspot positions

    background_error_rate$is.snp[ind.new.snp] = TRUE

    message('*** WARNING *** Look at MAF.txt, new SNP found at position(s):')
    message(as.character(MAJ[ind.new.snp,1]))
  }
  write.table(MAJ, file='MAJ.txt', row.names=FALSE, col.names=TRUE) # just for controling that ref position is OK
  # if (any(apply(cbind(REF,MAJ[,-1]),1,function(pos) any(pos[1]!=pos[-1])))) {
  #   print('PROBLEM WITH THE REF IN CONTROLS ... check file MAJ.txt')
  # }

  # For each position, compute error rate per base (A,T,G,C), for all non reference bases (snv), for longins (ins), longdel (del), for longINDEL (indel)
  all.error.rates = data.frame(t(apply(background_error_rate,1,function(pos) {
    N0 = c2n(pos['cov'])
    error.rates = unlist(sapply(c('E0','A','T','G','C','longINDEL','longins','longdel'),function(base) {
      if (base==pos['REF'] | (as.logical(pos['is.snp']) & is.na(charmatch('long',base)))) return(NA)
      max(c2n(pos[base]),1/log(N0))/N0 # if for the considered base no error are observed in controls, consider a base rate of order 1/(log(cov)*cov) that is lower than 1/cov
    }))
  })))
  names(all.error.rates) = paste0(c('E0','A','T','G','C','longINDEL','longins','longdel'),'.rate')

  ref.SB = data.frame(t(apply(background_error_rate,1,function(pos) {
    plus = c2n(pos[paste0(pos['REF'],'_plus')])
    minus = c2n(pos[paste0(pos['REF'],'_minus')])
    return(c(plus/(minus+plus),plus,minus))
  })))
  names(ref.SB) = c('REF_SB','REF_plus','REF_minus')

  background_error_rate = cbind(background_error_rate[,c('chrpos','hotspot','is.snp','cov','maj','E0','A','T','G','C','longINDEL','longins','longdel','REF')],ref.SB,all.error.rates)

  # Save Background error file...
  background_error_file = paste0(output.dir,"background_error_rate.txt")
  message('Background error rate saved in ...')
  message(paste0('... ',background_error_file))
  write.table(background_error_rate, file=background_error_file, row.names=FALSE, col.names=TRUE)

  return(length(ctrl.files))
}


#' function LoadBackgroundErrorRate
#'
#' This function will load the background error rates created from the controls using the function BuildCtrlErrorRate
#'
#' @param pos_ranges.file, char, name of the Rdata file containing the three variables \code{pos_ind}, \code{pos_snp}, \code{pos_ranges} as build by the function \code{PrepareLibrary}. Default NULL, use the position_ranges.rda provides that we used for our analysis.
#' @param ber.ctrl.file, char, pathname of the file providing the background error rates obtained from the controls (default NULL use the provided background error rates obtained from our 29 controls). See \code{background_error_rate.txt} data and \code{BuildCtrlErrorRate} function.
#' @author N. Pécuchet, P. Laurent-Puig, O. Nordgård and Y. Rozenholc
#' @references \emph{Analysis of base-position error rate of next-generation sequencing to detect tumor mutations in circulating DNA} N. Pécuchet, Y. Rozenholc, E. Zonta, D. Pietraz, A. Didelot, P. Combe, L. Gibault, J-B. Bachet, V. Taly, E. Fabre, H. Blons and P. Laurent-Puig in \emph{Clinical Chemistry}
#' @references \emph{Novel hybridization- and tag-based error-corrected method for sensitive ctDNA mutation detection using ion semiconductor sequencing} Kjersti Tjensvoll, Morten Lapin, Bjørnar Gilje, Herish Garresori, Satu Oltedal, Rakel Brendsdal Forthun, Anders Molven, Yves Rozenholc and Oddmund Nordgård  in \emph{Scientific Reports}
#'
#' @return the adapted background error rate
#'
#' @export LoadBackgroundErrorRate
#'
LoadBackgroundErrorRate = function(pos_ranges.file,ber.ctrl.file) {
  ### read background error rate
  background_error_rate = NULL
  chrpos = NULL
  if (is.null(ber.ctrl.file)) {
    data('background_error_rate',envir=environment()) # load default background error rate obtained from the 29 controls
  } else {
    if (!file.exists(ber.ctrl.file)) stop(paste('STOP:::File',ber.ctrl.file,'does not exist'))
    background_error_rate = read.table(ber.ctrl.file, header=T, sep=" ")
  }

  ### read position informations
  pos_ranges = pos_snp = pos_ind = NULL
  if (is.null(pos_ranges.file)) {
    data(positions_ranges,envir=environment())
  } else {
    if (!file.exists(pos_ranges.file)) stop(paste('STOP :::',pos_ranges.file,' does not exist'))
    load(pos_ranges.file)
  }

  background_error_rate = subset(background_error_rate,chrpos %in% pos_ind)
  background_error_rate
}


#' function DetectPlasmaMutation
#'
#' This is the main function of the package that calls mutations by comparing at each genomic position the SNV or INDEL frequencies computed in one tested sample to
#' the SNV or INDEL Position-Error Rates computed from several control samples by a binomial test. An outlier detection is performed among all intra-sample p-values
#' to call a mutation.
#' For users wishing to develop their own analysis for other sequencing panel, it requires recalibrated BAM files control samples to be processed to compute the
#' Position-Error Rates stored in a file specified in \code{ber.ctrl.file}.
#'
#' @param patient.dir, char, foldername containing the rBAM folder of the patients. The typical folder hierarchy will consist of 'Plasma/rBAM'
#' @param patient.name, char, filename of the patient .bam file(s) (default NULL read all patients in folder \code{patient.dir})
#' @param pos_ranges.file, char, name of the Rdata file containing the three variables \code{pos_ind}, \code{pos_snp}, \code{pos_ranges} as build by the function \code{PrepareLibrary}. Default NULL, use the position_ranges.rda provides that we used for our analysis.
#' @param ber.ctrl.file, char, pathname of the file providing the background error rates obtained from the controls (default NULL use the provided background error rates obtained from our 29 controls). See \code{background_error_rate.txt} data and \code{BuildCtrlErrorRate} function.
#' @param bai.ext, char, filename extension of the bai files (default '.bai')
#' @param alpha, num, global false positive rate = global test level (default 0.05)
#' @param n.trim, integer, number of base positions trimmed at the ends of each amplicon (default 0)
#' @param force, boolean, (default FALSE) if TRUE force all computations to all files including already processed ones
#' @param show.more, boolean, (default FALSE show only detected positions) if TRUE additional annotations on result plots are given for non-significant mutations
#' @param qcutoff.snv, numeric, proportion of kept base positions ranged by increasing percentile SNV PER in control samples (default 1)
#' @param qcutoff.indel, numeric, proportion of kept base positions ranged by increasing percentile INDEL PER in control samples (default 1)
#' @param cutoff.sb.hotspot, numeric, exclude hotspot positions without Symmetric Odds Ratio test < cutoff (default 1)
#' @param cutoff.sb.nonhotspot, numeric, exclude non-hotspot positions without Symmetric Odds Ratio test < cutoff (default cutoff.sb.hotspot)
#' @param cutoff.sb.indel, numeric, exclude indel positions without Symmetric Odds Ratio test < cutoff (default cutoff.sb.hotspot)
#' @param cutoff.sb.ref, numeric, exclude ref positions without Symmetric Odds Ratio test < cutoff (default cutoff = 0.9)
#' @param hotspot.indel, char, a vector containing the known positions of hotspot deletion/insertion defined as chrX:start:end (default 'chr7:55227950:55249171')
#' @param output.dir, char, name of the folder to save results  (default \code{patient.dir}).
#' @author N. Pécuchet, P. Laurent-Puig, O. Nordgård and Y. Rozenholc
#' @references \emph{Analysis of base-position error rate of next-generation sequencing to detect tumor mutations in circulating DNA} N. Pécuchet, Y. Rozenholc, E. Zonta, D. Pietraz, A. Didelot, P. Combe, L. Gibault, J-B. Bachet, V. Taly, E. Fabre, H. Blons and P. Laurent-Puig in \emph{Clinical Chemistry}
#' @references \emph{Novel hybridization- and tag-based error-corrected method for sensitive ctDNA mutation detection using ion semiconductor sequencing} Kjersti Tjensvoll, Morten Lapin, Bjørnar Gilje, Herish Garresori, Satu Oltedal, Rakel Brendsdal Forthun, Anders Molven, Yves Rozenholc and Oddmund Nordgård  in \emph{Scientific Reports}
#'
#' @return the number of processed patients
#'
#' @export DetectPlasmaMutation
#'
#' @examples
#'      patient.dir=system.file("extdata","4test_only/case/",package="PlasmaMutationDetector2")
#'      if (substr(patient.dir,nchar(patient.dir),nchar(patient.dir))!='/')
#'        patient.dir = paste0(patient.dir,'/') # TO RUN UNDER WINDOWS
#'      DetectPlasmaMutation(patient.dir,output.dir=paste0(tempdir(),'/'))
#'
#'
DetectPlasmaMutation = function(patient.dir='./',patient.name=NULL,pos_ranges.file=NULL,ber.ctrl.file=NULL,bai.ext='.bai',
                                alpha=0.05,n.trim=0,force=FALSE,show.more=FALSE,
                                qcutoff.snv=1,qcutoff.indel=1,
                                cutoff.sb.hotspot=Inf,cutoff.sb.nonhotspot=cutoff.sb.hotspot,
                                cutoff.sb.indel=cutoff.sb.hotspot,
                                cutoff.sb.ref=0.9,
                                hotspot.indel='chr7:55227950:55249171',
                                output.dir=patient.dir) {

  ### read and adapt background error rate
  background_error_rate = LoadBackgroundErrorRate(pos_ranges.file,ber.ctrl.file)
  # Remove the next line in the future version when background_error_rate is well built
  if (!any(names(background_error_rate)=='is.snp')) background_error_rate$is.snp = FALSE # just for compatibility with version previous 1.0.6
  background_error_rate$REF = as.character(background_error_rate$REF)

  ### Identify the so-called noisy SNV and INDEL genomic positions having background error rate higher than an upper quantile.
  ### Quantiles are defined by the cut-off qcutoff.snv and qcutoff.indel
  background_error_rate$noisy.snv = UpperPart(background_error_rate$E0.rate,qcutoff.snv,do.boolean.only=T)
  background_error_rate$noisy.indel = UpperPart(background_error_rate$longINDEL.rate,qcutoff.indel,do.boolean.only=T)

  ### extract counts from BAM files
  patient.files = MAF_from_BAM(study.dir=patient.dir,input.filenames=patient.name,bai.ext=bai.ext,
                               pos_ranges.file=pos_ranges.file,force=force,output.dir=output.dir,n.trim=n.trim)

  ### directory for the results
  patient.results = paste0(output.dir,'Results/')
  if (!dir.exists(patient.results)) dir.create(patient.results)

  for (i in 1:length(patient.files)) {

    message(paste('Detecting mutations from', patient.files[i]))

    patient.name = rev(strsplit(patient.files[i],'/')[[1]])[1]
    patient.pdf = gsub('_MAF.txt$','.pdf',paste0(patient.results,patient.name))
    patient.hit = gsub('_MAF.txt$','_infos.txt',paste0(patient.results,patient.name))
    patient.mut = gsub('_MAF.txt$','_MUT.txt',paste0(patient.results,patient.name))

    if ((!force & file.exists(patient.hit)) && (file.size(patient.hit)>0)) next() # already processed go to next

    ### Load patient file
    sample = read.table(patient.files[i], header=T, sep="") ### read sample counts
    sample = sample[which(!is.na(sample$MA)),] ### remove positions which haven't been read
    sample$E0 = sample$cov-sample$maj
    depth = mean(sample$cov,na.rm=T)
    names(sample)[-1] = paste0('x',names(sample))[-1] ### add a 'x' in front of column names of patient

    ### merge control and sample counts
    samplenoise = merge(sample, background_error_rate, by="chrpos", all=FALSE)
    nsize = dim(samplenoise)[1]
    noisy.snv = samplenoise$chrpos[samplenoise$noisy.snv]
    noisy.indel = samplenoise$chrpos[samplenoise$noisy.indel]

    snv.ok = !samplenoise$noisy.snv
    n.snv.hotspot = sum(samplenoise$hotspot[snv.ok],na.rm=TRUE) # add na.rm=T to take into account that snv.ok==NA is possible
    n.snv.nonhotspot = sum(!samplenoise$hotspot[snv.ok],na.rm=TRUE) # add na.rm=T to take into account that snv.ok==NA is possible
    indel.ok = !samplenoise$noisy.indel
    n.indel.hotspot = sum(samplenoise$hotspot[indel.ok])
    n.indel.nonhotspot = sum(!samplenoise$hotspot[indel.ok])


    ### compute upper bound rate for each rate for the non-noisy positions
    all.upr_rate = data.frame(t(apply(
      subset(samplenoise,select=c('cov','REF','hotspot','E0','A','T','G','C','longINDEL','longins','longdel','is.snp')),1,
      function(pos) {
        N0 = c2n(pos['cov'])
        # Apply Bonferroni correction
        if (eval(parse(text=pos['hotspot']))) { # HOTSPOT
          alpha_cor.snv=(alpha/2)/n.snv.hotspot
          alpha_cor.indel=(alpha/2)/n.indel.hotspot
        } else { # NON HOTSPOT
          alpha_cor.snv=(alpha/2)/n.snv.nonhotspot
          alpha_cor.indel=(alpha/2)/n.indel.nonhotspot
        }
        # compute upr_rates
        upr_rate = sapply(c('E0','A','T','G','C','longINDEL','longins','longdel'), function(base) {
          if (base==pos['REF'] | (as.logical(pos['is.snp']) & is.na(charmatch('long',base)))) return(NA)
          if (is.na(charmatch('long',base))) { # SNV
            alpha_corrected = alpha_cor.snv
            if (base!='E0') alpha_corrected = alpha_corrected/3
          } else { # INDEL
            alpha_corrected = alpha_cor.indel
            if (base!='longINDEL') alpha_corrected = alpha_corrected/2
          }
          upr = upper_rate(c2n(pos[base]),N0,alpha_corrected)
        })
        c(upr_rate,alpha_cor.snv,alpha_cor.indel)
      })))
    names(all.upr_rate) = c(paste0(c('E0','A','T','G','C','longINDEL','longins','longdel'),'.up_rate'),'alpha_cor.snv','alpha_cor.indel')
    samplenoise = cbind(samplenoise,all.upr_rate)

    ### Compute p-values by for all chrpos and all types
    all.p_value = data.frame(t(apply(samplenoise,1,function(pos) {
      xN0 = c2n(pos['xcov'])
      p_value = sapply(c('E0','A','T','G','C','longINDEL','longins','longdel'), function(base){
        if (base==pos['REF'] | (as.logical(pos['is.snp']) & is.na(charmatch('long',base)))) return(Inf)
        if (is.na(charmatch('long',base))) { # SNV
          upr_rate = c2n(pos[paste0(base,'.up_rate')])
        } else { # INDEL
          upr_rate = c2n(pos[paste0(base,'.up_rate')])
        }
        p.val = pbinom(c2n(pos[paste0('x',base)]),xN0,upr_rate,lower.tail=FALSE)
        # p.val = prop.test(c(c2n(pos[base]),c2n(pos[paste0('x',base)])),c(c2n(pos['cov']),c2n(pos['xcov'])))$p.value
      })
    })))
    names(all.p_value) = paste0(c('E0','A','T','G','C','longINDEL','longins','longdel'),'.pval')

    samplenoise = cbind(samplenoise,all.p_value)

    ### define mutations from corrected pvalues
    mutations = data.frame(t(simplify2array(apply(samplenoise,1,function(pos){
      # first, test for SNV
      mut.snv = mut.indel = base.snv = base.indel = ''; type = '-'; freq = 0; what = '-'; pval.snv = pval.indel = Inf
      if (!eval(parse(text=pos['is.snp'])) &
          !eval(parse(text=pos['noisy.snv']))) { # TRUE if the position is neither a snp nor noisy
        all.pval.snv = c2n(pos[paste0(c('A','T','G','C'),'.pval')])
        ind = which.min(all.pval.snv)
        base.snv = c('A','T','G','C')[ind]
        pval.snv.direct = 3*all.pval.snv[ind]
        pval.snv.all = c2n(pos['E0.pval'])
        pval.snv = min(pval.snv.direct,pval.snv.all)

        if (pval.snv<c2n(pos['alpha_cor.snv'])) { # snv is detected
          type = 'SNV'
          # code for the mutation : 1 for all, 2 for a direct finding, 3 if both are detected
          mut.snv = (pval.snv.all<c2n(pos['alpha_cor.snv']))+2*(pval.snv.direct<c2n(pos['alpha_cor.snv']))
        }
        # Bonferroni correction :
        pval.snv = min(1,pval.snv*ifelse(eval(parse(text=pos['hotspot'])),n.snv.hotspot,n.snv.nonhotspot))
      }



      # second, test for INDEL
      if (!eval(parse(text=pos['noisy.indel']))) {
        all.pval.indel = c2n(pos[paste0(c('longins','longdel'),'.pval')])
        ind = which.min(all.pval.indel)
        base.indel = c('longins','longdel')[ind]
        pval.indel.direct = 2*all.pval.indel[ind]
        pval.indel.all = c2n(pos['longINDEL.pval'])
        pval.indel = min(pval.indel.direct,pval.indel.all)

        if (pval.snv == Inf) pval.snv = 1;  #Added by ON 21.04.2020, to avoid unwanted what=indels.

        if (pval.indel<c2n(pos['alpha_cor.indel'])) {  # indel detected
          type = toupper(sub('long','',base.indel)) # turn into INS or DEL
          # code for the mutation : -1 for all, -2 for a direct finding, -3 if both are detected
          mut.indel = -(pval.indel.all<c2n(pos['alpha_cor.indel']))-2*(pval.indel.direct<c2n(pos['alpha_cor.indel']))
        }
        pval.indel = min(1,pval.indel*ifelse(eval(parse(text=pos['hotspot'])),n.indel.hotspot,n.indel.nonhotspot))
      }

      # minimum of Bonferroni corrected pvalue for snv and indel
      pval.cor = min(pval.snv,pval.indel)


      # what is the mutation and mut is the code (1/2/3)
      if (is.finite(pval.cor)) { # at least one p-value has been computed.
        if (pval.indel<pval.snv) {
          what = base.indel
          mut = mut.indel


        } else {
          what = base.snv
          mut = mut.snv
        }
      } else mut = ''


      if (nchar(mut)>0) { # something has been detected
        freq = c2n(pos[paste0('x',what)])/c2n(pos['xcov'])
      }

      # RETURN :
      c(type=type,mut=mut,what=what,freq=freq,pval.cor=pval.cor)
    }))),stringsAsFactors=F)

    samplenoise = cbind(samplenoise,mutations)

    samplenoise$Bonferroni = (nchar(samplenoise$mut)>0) # TRUE if position mutated, FALSE otherwise
    ind.bonf = which(samplenoise$Bonferroni) # mutated positions
    n.bonf = length(ind.bonf) # number of mutations

    if (n.bonf==0) {
      message('no mutation discovered')
      write.table('no mutation discovered', file=patient.hit, quote=FALSE, sep="\t", row.names=FALSE, col.names=FALSE)
      pdf(patient.pdf); dev.off()
    } else message(paste(n.bonf, 'positions detected as mutated'))

    message('------------------------')

    ### compute reference strand bias for the sample
    # First define the function that determines REF_SB in each line
    computeSB = function(pos){
      plus = c2n(pos[paste0('x',pos['REF'],'_plus')])
      minus = c2n(pos[paste0('x',pos['REF'],'_minus')])
      return(plus/(minus+plus))
    }

    samplenoise$SB.ref = apply(samplenoise,1,computeSB)


    ### compute strand bias score
    sb.info = data.frame(t(sapply(1:dim(samplenoise)[1], function(i) {
      what = samplenoise$what[i]
      if (what=='-') return(c(NA,NA,NA))
      what_plus = samplenoise[i,paste0('x',what,'_plus')]
      what_minus = samplenoise[i,paste0('x',what,'_minus')]
      if (is.null(what_plus) | is.null(what_minus)) return(c(NA,NA,NA)) #In case what is

      SBscore = sbscore(samplenoise[i,paste0('x',samplenoise$REF[i],'_plus')],
                        samplenoise[i,paste0('x',samplenoise$REF[i],'_minus')],what_plus,what_minus)  # Simplification by ON and modification to use sample ref count
      c(what_plus,what_minus,SBscore)
    })))

    names(sb.info) = c('what_plus','what_minus','SBscore')
    samplenoise = cbind(samplenoise,sb.info)


    ### Correction for graphical outputs
    ### Correct the insertions
    samplenoise$what[which(samplenoise$type=='INS')] = '>2N'

    ### CORRECT DELETIONS ---- length and strand biais
    ### Need to gather consecutive deletions>2bp (sharing the same check number) into one unique large deletion table
    ind.deletion = which(samplenoise$type=='DEL')

    if (length(ind.deletion)>0) {
      deletion = samplenoise[ind.deletion,] # extract the deletions (ON comm.)
      contigue = unique(na.omit(deletion$xposid))
      for (z in contigue) {
        ind = which(deletion$xposid==z)
        if (length(ind)>2) {
          deletion[ind,'REF'] = paste(deletion[ind,'REF'],collapse='')
          deletion[ind,'what'] =  paste0('L=-',diff(range(deletion[ind,'xstart'])) + 1) # gives the number of deleted bp
          deletion[ind,'pval.cor'] = min(deletion[ind,'pval.cor']) # retains the most significant p-value (p.INDEL) on the large deletion
          deletion[ind,'SBscore'] = min(deletion[ind,'SBscore']) # retains the lowest Symmetric Odds Ratio Test on the large deletion
        } else deletion[ind,'Bonferroni'] = FALSE # deletion is <3bp and not taken into account
      }
    }
    ind.bonf = which(samplenoise$Bonferroni)
    n.bonf = length(ind.bonf)

    write.table(samplenoise, file=patient.hit, quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)

    # REMOVE the duplication to build MUT file
    if (length(ind.deletion)>0) samplenoise = rbind(samplenoise[-ind.deletion,], deletion[!duplicated(deletion$xposid),])

    # Find the indexes of the mutations (comment added by ON)
    ind.mut = samplenoise$Bonferroni
    ind.mut = ind.mut & (
      (samplenoise$type=='SNV' & (    #If we have an SNV
        ((1-cutoff.sb.ref) < samplenoise$SB.ref & samplenoise$SB.ref < cutoff.sb.ref) & ## Added by ON, require SB.ref to be within limits
          ((samplenoise$hotspot & samplenoise$SBscore<=cutoff.sb.hotspot) |
             (!samplenoise$hotspot & samplenoise$SBscore<=cutoff.sb.nonhotspot)
          )) #Require SBscore to be within limits
      ) |
        (samplenoise$type!='SNV' & samplenoise$SBscore<=cutoff.sb.indel)
    )
    mutations = samplenoise[which(ind.mut),]

    mutations = mutations[,c('chrpos','mut','is.snp','REF','what','freq','hotspot','noisy.snv','noisy.indel','xcov',
                             'REF_plus','REF_minus','what_plus','what_minus','SB.ref','SBscore','pval.cor')]
    colnames(mutations) = c('Genomic-pos','Mutation-type','is.snp','Base-ref','Base-mut','Allelic-freq','hotspot','noisy.snv','noisy.indel','xcov',
                            'ref +','ref -','mut +','mut -','SB.REF','SBscore','pval.cor')  # Modified by ON

    write.table(mutations, file=patient.mut, quote=FALSE, sep="\t", row.names=FALSE, col.names=TRUE)

    ### For plotting purpose: all possible mutation types are added for legend consistency
    rownames(samplenoise) = 1:nrow(samplenoise)

    ### Plot generation using ggplot2
    grob = grobTree(textGrob(paste0("Mean Depth of Coverage: ", floor(depth),"x"),
                             x=0.45,  y=0.97, hjust=0, gp=gpar(col="red", fontsize=9, fontface="italic")))

    samplenoise$outlier = 'no'
    samplenoise$outlier[which(samplenoise$Bonferroni)] = 'Bonferroni'
    sample4plot = samplenoise
    sample4plot = sample4plot[order(sample4plot$hotspot),]
    tmp = sample4plot$hotspot
    sample4plot$hotspot[which(tmp)] = 'Hotspot'
    sample4plot$hotspot[which(!tmp)] = 'Non-hotspot'


    y.lim = range(sample4plot$SBscore,finite=TRUE)
    sample4plot$SBscore[sample4plot$SBscore==Inf] = y.lim[2]+1

    ### For plotting purpose: make type and outlier as.factor with ordered levels
    sample4plot[nrow(sample4plot)+1,c('hotspot','outlier','type')]=c('Hotspot','no','INS')
    sample4plot[nrow(sample4plot)+1,c('hotspot','outlier','type')]=c('Hotspot','no','DEL')
    sample4plot[nrow(sample4plot)+1,c('hotspot','outlier','type')]=c('Non-hotspot','Bonferroni','SNV')

    sample4plot$type = factor(sample4plot$type, levels = c('SNV','INS','DEL','-')) # YVES 5/09/2016
    sample4plot$outlier = factor(sample4plot$outlier, levels = c('no','Bonferroni')) # YVES 5/09/2016

    ind = rev(gregexpr('/',patient.name)[[1]])[1]
    freq4plot = substr(paste(sample4plot$freq), 0, 6) # keep 3 decimal for the frequency of the mutation
    pdf = ggplot(sample4plot, aes(sapply(sample4plot$pval.cor, function(x) -log10(max(1e-100,c2n(x)))), sample4plot$SBscore)) +
      geom_hline(yintercept=y.lim[2]+1,colour='red') + geom_text(x=0,y=y.lim[2]+1,label='Inf ',colour='red',hjust='right',vjust='top') +
      geom_point(aes(colour=sample4plot$hotspot, size=sample4plot$outlier, shape=sample4plot$type), na.rm=T) +
      geom_text(aes(label=ifelse((sample4plot$outlier!='no'),
                                 paste0(as.character(sample4plot$chrpos),".",sample4plot$REF,">",sample4plot$what, " AF ", freq4plot),
                                 '')),hjust=0, vjust=0.5, angle=45, size=2.5, na.rm=T)  +
      ylab("SBscore") + xlab(paste0("-log(corrected p-value)")) + theme_set(theme_bw(base_size = 10)) +
      labs(title = paste(n.bonf,"Detection(s)", "\n", substr(patient.name, ind+1, ind+26))) +
      scale_x_continuous(limits=c(0, 120) ) + annotation_custom(grob) + scale_shape_manual(name="Class", values = c(16,25,17,4)) +
      scale_colour_brewer(name="Hotspot", palette="Set1") + scale_size_manual(name="Detect", values=c(1,4)) +
      scale_y_continuous(limits=c(y.lim[1], y.lim[2]+2))

    # Export results plot and table
    ggsave(pdf, filename=patient.pdf, width = 10, height = 10)

  } # end of loop over patients

  length(patient.files)

}


#' The package provide the SNV and INDEL PERs computed for the Ion AmpliSeq™ Colon and Lung Cancer Panel v2 from 29 controls in a table available in the data file \code{background_error_rate.txt}.
#'
#' This table contains 9 variables for each genomic position
#' \itemize{
#'   \item \code{chrpos}, char, of the form chrN:XXXXXXXXX defining genomic position
#'   \item \code{N0}, integer, the coverture in the controls
#'   \item \code{E0}, integer, the number of errors in the controls
#'   \item \code{p.sain}, numeric,  the ratio E0/N0
#'   \item \code{up.sain}, numeric, the 95th quantile of the Binomial with parameter N0 and E0/N0
#'   \item \code{E0indel}, integer, the amount of indel
#'   \item \code{indel.p.sain}, numeric, the ration E0indel/N0
#'   \item \code{indel.up.sain}, numeric, the 95th quantile of the Binomial with parameter N0 and E0indel/N0
#'   \item \code{hotspot}, char, either 'Non-hotspot' or 'Hotspot' depending if the genomic position is known as hotspot or not.
#' }
#
#' @docType data
#' @usage data(background_error_rate)
#' @name background_error_rate
#' @aliases background_error_rate.txt
#' @author N. Pécuchet, P. Laurent-Puig, O. Nordgård and Y. Rozenholc
#' @keywords data
#' @seealso \code{BuildCtrlErrorRate}
#' @references \emph{Analysis of base-position error rate of next-generation sequencing to detect tumor mutations in circulating DNA} N. Pécuchet, Y. Rozenholc, E. Zonta, D. Pietraz, A. Didelot, P. Combe, L. Gibault, J-B. Bachet, V. Taly, E. Fabre, H. Blons, P. Laurent-Puig in \emph{Clinical Chemistry}
#' @references \emph{Novel hybridization- and tag-based error-corrected method for sensitive ctDNA mutation detection using ion semiconductor sequencing} Kjersti Tjensvoll, Morten Lapin, Bjørnar Gilje, Herish Garresori, Satu Oltedal, Rakel Brendsdal Forthun, Anders Molven, Yves Rozenholc and Oddmund Nordgård  in \emph{Scientific Reports}
NULL

#' The package provide the positions and ranges computed for the Ion AmpliSeq™ Colon and Lung Cancer Panel v2 as a Rdata file \code{positions_ranges.rda}.
#'
#' This file contains 4 variables
#' \itemize{
#'   \item \code{pos_ind}, vector of chars, of the form chrN:XXXXXXXXX defining genomic positions of the Ion AmpliSeq™ Colon and Lung Cancer Panel v2
#'   \item \code{pos_snp}, vector of chars, of the form chrN:XXXXXXXXX defining the known snp genomic positions
#'   \item \code{pos_ranges}, GRanges object, describing the 92 amplicons of the Ion AmpliSeq™ Colon and Lung Cancer Panel v2
#' }
#
#' @docType data
#' @usage data(positions_ranges)
#' @name positions_ranges
#' @aliases positions_ranges.rda pos_ind pos_snp pos_ranges
#' @author N. Pécuchet, P. Laurent-Puig, O. Nordgård and Y. Rozenholc
#' @keywords data
#' @seealso \code{Prepare_Library}
#' @references \emph{Analysis of base-position error rate of next-generation sequencing to detect tumor mutations in circulating DNA} N. Pécuchet, Y. Rozenholc, E. Zonta, D. Pietraz, A. Didelot, P. Combe, L. Gibault, J-B. Bachet, V. Taly, E. Fabre, H. Blons, P. Laurent-Puig in \emph{Clinical Chemistry}
#' @references \emph{Novel hybridization- and tag-based error-corrected method for sensitive ctDNA mutation detection using ion semiconductor sequencing} Kjersti Tjensvoll, Morten Lapin, Bjørnar Gilje, Herish Garresori, Satu Oltedal, Rakel Brendsdal Forthun, Anders Molven, Yves Rozenholc and Oddmund Nordgård  in \emph{Scientific Reports}
NULL

#' The package provide a list of known hotspot positions located on the amplicons of the Ion AmpliSeq™ Colon and Lung Cancer Panel v2 as a txt file \code{hotspot.txt} which contains a vector/variable ---named chrpos (first row)--- of chars, of the form chrN:XXXXXXXXX defining genomic positions.
#'
#
#' @docType data
#' @usage data(hotspot)
#' @name hotspot
#' @aliases hotspot.txt
#' @author N. Pécuchet, P. Laurent-Puig, O. Nordgård and Y. Rozenholc
#' @keywords data
#' @references \emph{Analysis of base-position error rate of next-generation sequencing to detect tumor mutations in circulating DNA} N. Pécuchet, Y. Rozenholc, E. Zonta, D. Pietraz, A. Didelot, P. Combe, L. Gibault, J-B. Bachet, V. Taly, E. Fabre, H. Blons, P. Laurent-Puig in \emph{Clinical Chemistry}
#' @references \emph{Novel hybridization- and tag-based error-corrected method for sensitive ctDNA mutation detection using ion semiconductor sequencing} Kjersti Tjensvoll, Morten Lapin, Bjørnar Gilje, Herish Garresori, Satu Oltedal, Rakel Brendsdal Forthun, Anders Molven, Yves Rozenholc and Oddmund Nordgård  in \emph{Scientific Reports}
NULL

FilterVariants = function(study.dir='.',input.filenames=NULL,cutoff.P=0.05){
  if (is.null(input.filenames)) {
    message(paste0("Looking for MUT.txt files in ",study.dir,' ...'))
    input.filenames = dir(study.dir, pattern="*_MUT.txt") # list all BAM files in bam.dir
  }
  for (file in input.filenames){
    data = read.table(paste0(study.dir,"/",file),sep='\t',header=TRUE)
    message(file)
    filtereddata = data[data$pval.cor<cutoff.P,]  #Keep only variants with P value lower than cutoff
    write.table(x=filtereddata,file=paste0(study.dir,"/",file),sep='\t',row.names=FALSE)

  }
}


