## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(ondisc)

## -----------------------------------------------------------------------------
raw_data_dir <- system.file("extdata", package = "ondisc")
list.files(raw_data_dir)

## -----------------------------------------------------------------------------
mtx_fp <- paste0(raw_data_dir, "/gene_expression.mtx")
barcodes_fp <- paste0(raw_data_dir, "/cell_barcodes.tsv")
features_fp <- paste0(raw_data_dir, "/genes.tsv")

## -----------------------------------------------------------------------------
temp_dir <- tempdir()
exp_mat_list <- create_ondisc_matrix_from_mtx(mtx_fp = mtx_fp,
                                              barcodes_fp = barcodes_fp,
                                              features_fp = features_fp,
                                              on_disk_dir = temp_dir)

## -----------------------------------------------------------------------------
expression_mat <- exp_mat_list$ondisc_matrix
head(expression_mat)
cell_covariates <- exp_mat_list$cell_covariates
head(cell_covariates)
feature_covariates <- exp_mat_list$feature_covariates
head(feature_covariates)

## -----------------------------------------------------------------------------
"ondisc_matrix_1.h5" %in% list.files(temp_dir)

## -----------------------------------------------------------------------------
feature_ids <- get_feature_ids(expression_mat)
feature_names <- get_feature_names(expression_mat)
cell_barcodes <- get_cell_barcodes(expression_mat)

head(feature_ids)
head(feature_names)
head(cell_barcodes)

## -----------------------------------------------------------------------------
dim(expression_mat)
nrow(expression_mat)
ncol(expression_mat)

## -----------------------------------------------------------------------------
# numeric vector examples
# keep genes 100-110
x <- expression_mat[100:110,]
# keep all cells except 10 and 20
x <- expression_mat[,-c(10,20)]
# keep genes 50-100 and 200-250 and cells 300-500
x <- expression_mat[c(50:100, 200:250), 300:500]

# character vector examples
# keep genes ENSG00000107581, ENSG00000286857, and ENSG00000266371
x <- expression_mat[c("ENSG00000107581", "ENSG00000286857", "ENSG00000266371"),]
# keep cells CGTTGGGCATGGCTGC-1 and GTAACCAGTACAGTTC-1 
x <- expression_mat[,c("CGTTGGGCATGGCTGC-1", "GTAACCAGTACAGTTC-1")]

# logical vector example
# keep all genes except ENSG00000237832 and ENSG00000229637
x <- expression_mat[!(get_feature_ids(expression_mat) 
                 %in% c("ENSG00000237832", "ENSG00000229637")),]

## -----------------------------------------------------------------------------
expression_mat

## -----------------------------------------------------------------------------
# numeric vector examples
# pull gene 6
m <- expression_mat[[6,]]
# pull cells 200 - 250
m <- expression_mat[[,200:250]]
# pull genes 50 - 100 and cells 200 - 250
m <- expression_mat[[50:100, 200:250]]

# character vector examples
# pull genes ENSG00000107581 and ENSG00000286857
m <- expression_mat[[c("ENSG00000107581", "ENSG00000286857"),]]
# pull cells CGTTGGGCATGGCTGC-1 and GTAACCAGTACAGTTC-1
m <- expression_mat[[,c("CGTTGGGCATGGCTGC-1", "GTAACCAGTACAGTTC-1")]]

# logical vector examples
# subset the matrix, keeping genes ENSG00000107581, ENSG00000286857, and ENSG00000266371
x <- expression_mat[c("ENSG00000107581", "ENSG00000286857", "ENSG00000266371"),]
# pull all genes except ENSG00000107581
m <- x[[get_feature_ids(x) != "ENSG00000107581",]]

## -----------------------------------------------------------------------------
saveRDS(object = expression_mat, file = paste0(temp_dir, "/expression_matrix.rds"))
rm(expression_mat)

## -----------------------------------------------------------------------------
expression_mat <- readRDS(paste0(temp_dir, "/expression_matrix.rds"))

## -----------------------------------------------------------------------------
h5_file <- paste0(temp_dir, "/ondisc_matrix_1.h5")
expression_mat <- ondisc_matrix(h5_file)

