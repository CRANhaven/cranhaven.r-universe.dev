# SlaPMEG
This package is designed to perform a Shared latent Process Mixed Effects analysis with Globaltest.

Here is a list of functions:\
\
`slapmeg` fits slapmeg for a single feature-set\
`multslapmeg` fits slapmeg simultaneously for several feature-sets\
`pairslapmeg`  fits slapmeg based on a computationally efficient approach\
`plotslapmeg`  Plots the estimated random effects within the pathway \
`print.slapmeg`  Prints the slapmeg model and results with details\
`summary.slapmeg` Prints the slapmeg model and results \
`simslapmeg` Generates joint lingitudinal observations

## Usage
For details explanations and example usage check the help files within package, but here are some tips.
* The data need to be in the conventional genomics format, so columns indicate variables and features, whereas rows indicate subjects and repeated measurements.
* The formula must be supplied as a `formula object`.
* There is a function to simulate longitudinal observations, so you can give it a try if you do not have a real dataset.
* It is possible to use predefined pathways such as GO, KEGG, Wikipathways, and etc. as long as they are put into a list format, you can take a look at examples of creating such lists in the "Creating the Pathlists" section of [rSEA package](https://github.com/mitra-ep/rSEA) manual.
* If the feature-set has more than 10 features, the `slapmeg function` will automatically switch to the pairslapmeg which is computationally more efficient. 
* If you had convergance issues with smaller feature-sets, try the `pairslapmeg function`.
* The `plotslapmeg function` will give an insight on the source of differential expression.
