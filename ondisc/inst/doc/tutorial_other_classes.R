## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(ondisc)

## -----------------------------------------------------------------------------
# Set paths to the .mtx and .tsv files
raw_data_dir <- system.file("extdata", package = "ondisc")
mtx_fp <- paste0(raw_data_dir, "/gene_expression.mtx")
barcodes_fp <- paste0(raw_data_dir, "/cell_barcodes.tsv")
features_fp <- paste0(raw_data_dir, "/genes.tsv")

# Specify directory in which to store the .h5 file
temp_dir <- tempdir()

# Initialize metadata_ondisc_matrix
expressions <- create_ondisc_matrix_from_mtx(mtx_fp = mtx_fp,
                                              barcodes_fp = barcodes_fp,
                                              features_fp = features_fp,
                                              on_disk_dir = temp_dir,
                                              return_metadata_ondisc_matrix = TRUE)

## -----------------------------------------------------------------------------
# Print the variable
expressions

## -----------------------------------------------------------------------------
# Set paths to the perturbation .mtx and .tsv files
mtx_fp <- paste0(raw_data_dir, "/perturbation.mtx")
barcodes_fp <- paste0(raw_data_dir, "/cell_barcodes.tsv")
features_fp <- paste0(raw_data_dir, "/guides.tsv")

# Initialize metadata_ondisc_matrix
perturbations <- create_ondisc_matrix_from_mtx(mtx_fp = mtx_fp,
                                               barcodes_fp = barcodes_fp,
                                               features_fp = features_fp,
                                               on_disk_dir = temp_dir,
                                               return_metadata_ondisc_matrix = TRUE)

## -----------------------------------------------------------------------------
# These matrices have different columns
head(expressions@cell_covariates)
head(perturbations@cell_covariates)

## -----------------------------------------------------------------------------
modality_list <- list(expressions = expressions, perturbations = perturbations)
crispr_experiment <- multimodal_ondisc_matrix(modality_list)

## -----------------------------------------------------------------------------
# print variable
crispr_experiment

# show the global covariate matrix
head(crispr_experiment@global_cell_covariates)

## ----classes, echo=FALSE, fig.cap="**Figure**: Classes provided by the package. a) `ondisc_matrix`, b) `metadata_ondisc_matrix`, c) `multimodal_ondisc_matrix` ", out.width = '55%'----
knitr::include_graphics("classes_cropped.jpg")

## -----------------------------------------------------------------------------
# metadata_ondisc_matrix
cell_barcodes <- get_cell_barcodes(expressions)
feature_ids <- get_feature_ids(expressions)
feature_names <- get_feature_names(expressions)

# multimodal_ondisc_matrix
cell_barcodes <- get_cell_barcodes(crispr_experiment)
feature_ids <- get_feature_ids(crispr_experiment)

## -----------------------------------------------------------------------------
# metadata_ondisc_matrix
dim(expressions)
nrow(expressions)
ncol(expressions)

# multimodal_ondisc_matrix
dim(crispr_experiment)
nrow(crispr_experiment)
ncol(crispr_experiment)

## -----------------------------------------------------------------------------
# metadata_ondisc_matrix
# keep cells 100 - 150
expressions_sub <- expressions[,100:150]
# keep genes ENSG00000188305, ENSG00000257284, ENSG00000251655
expressions_sub <- expressions[c("ENSG00000188305", "ENSG00000257284", "ENSG00000251655"),]

# multimodal_ondisc_matrix
# keep all cells except 1 - 100
crispr_experiment_sub <- crispr_experiment[,-c(1:100)]

## -----------------------------------------------------------------------------
expressions
crispr_experiment

