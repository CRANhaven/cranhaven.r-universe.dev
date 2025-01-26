\name{IsoWrapper}
\alias{IsoWrapper}
\title{
IsoWrapper 
}

\description{
A wrapper function for IsotopeR. Used to call the gui.
}

\usage{
IsoWrapper(Mixtures="Necessary File", Sources="Necessary File", 
  Concentrations="Optional File", Discrimination.Error="Optional File", 
  Measurement.Error="Optional File", output.name="SampleOutput.Rdata", mcmc.chains=3,
  mcmc.burn=1000, mcmc.chainLength=1000, mcmc.thin=1, plot.observations=TRUE,
  plot.mixing.estimates=TRUE, plot.dietary.source.contributions=TRUE, color.plots=TRUE,
  run.parallel=TRUE)
}
\arguments{
  \item{Mixtures}{
Isotopic mixture data. The first n columns in this data input file are the isotope values associated with each individual (i.e., consumer), where n is the number of isotopes used in the analysis. The last two columns designate the group and individual assignments. If there is no group structure, then column n+1 will contain a "1" for all individuals. If designating multiple groups, the group identity will be determined by the variable in the column. Individuals in the first group should be designated as "1", the second group as "2" etc. The last column identifies each individual. If you have repeated measures for an individual then individuals with repeated measures will have the same number (e.g., 1, 1, 1, 2, 2, 2...). 
}
  \item{Sources}{
Source istope values. Each source is a sample of a consumer's dietary items (may be a sample of the same species or aggregate of species). The first n columns in this data input file are the isotope values associated with each sampled dietary item, where n is the number of isotopes used in the analysis. Isotope values need to be in the same order as the mixture data file (e.g., column 1 in Mixtures and Sources contain delta-13C values). The next column (i.e., n+1) identifies the source to which the sampled dietary item belongs. All entries for samples belonging to the first source should be denoted with integer "1", the second source as "2", etc. The last column identifies which species or taxon (i.e., sub-source) the sampled dietary item belongs within each source. This feature assigns equal weight to each sub-source.
}
  \item{Concentrations}{
The concentration-dependence data. The first n columns in this data input file are the concentration data for each sample, where n is the number of elemental concentrations used in the analysis (e.g., [C], [N]). Columns with elemental concentrations need to match Sources and Mixtures (e.g., column 1 in SourceCD and Sources files contain [C] and delta-13C values, respectively). Column n+1 identifies the source in which the set of concentrations belong. All concentrations belonging to the first source should be denoted with integer "1", the second source as "2", etc. The last column links sampled dietary item concentrations to each sub-source. This feature assigns equal weight to each sub-source's elemental concentrations.
}
\item{Discrimination.Error}{Discrimination error data. This data input file contains the standard deviations associated with estimated discrimination factors measured in a controlled diet study. The first n columns in the data file are the standard deviations associated with each controlled diet isotope. The last column gives the source identification of the discrimination factors.
}
  \item{Measurement.Error}{Data on measurement error associated with mass spectrometry. This data input file contains all isotopic measurements for standards. Isotope values need to be in the same order as other data files (e.g., column 1 in MeasurementError, Mixtures, and Sources files contain delta-13C values).
}
  
\item{output.name}{
The name of the .Rdata image file to write the JAGS output to. Will also output a .csv file with the same name containing parameter estimates from the model estimates.
}
  \item{mcmc.chains}{
The number of independent markov chains to be run.
}
  \item{mcmc.burn}{
The length of the chain discarded at the beginning of the run.
}
  \item{mcmc.chainLength}{
The total number of iterations run per chain (includes burnin).
}
  \item{run.parallel}{
	  This boolean flag determines whether the mcmc chains should be run in parallel (TRUE) or not (FALSE). Parallel chains requires that mcmc.chains is greater than 1 and that the machine running the mcmc has multiple cores. Note that the Deviance Information Criterion (DIC) cannot be reported when chains are run in parallel.
  }
  \item{mcmc.thin}{
Thinning rate. Reduces the sample size to every nth iteration.
}
  \item{plot.observations}{
This will make a plot of the mixing space, meaning the estimated sources and source concentrations, along with the mixture observations. If measurement error data is provided, the estimated 95 percent CI's will be displayed.
}
  \item{plot.mixing.estimates}{
This will make a plot of the mixing space, meaning the estimated sources and source concentrations, along with the estimate mixture values along with their estimated 95 percent CI's will be displayed.
}
  \item{plot.dietary.source.contributions}{
Plots the smoothed histograms of the population level diet estimates (black) along with individual level estimates (blue).
}
  \item{color.plots}{
This boolean flag defines whether plots should be made in color (TRUE), or grayscale (FALSE).
}
}
\author{Jake Ferguson}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
