\name{cal_lmi_data}
\alias{cal_lmi_data}

\title{
Calculate local moran's I matrix for a network and a gene expression matrix
}
\description{
\code{cal_lmi_data()} will calculate the local moran's I data for a input igraph object and gene expression data matrix.
}
\usage{
  cal_lmi_data(gene_expr, gene_graph)
}

\arguments{
  \item{gene_expr}{
  Expression for genes. Each row is a gene, and each column is a sample. 
}
  \item{gene_graph}{
  The graph of gene network.
}
}
\details{
  \code{cal_lmi_data()} will calculate the local moran's I matrix for a input igraph object and gene expression data matrix. The function will return a matrix in the same dimension of the input gene expression matrix. Every gene x's lmi data takes a row. 
}
\value{
  A table of local moran's I data. 
  Row name is gene id. 
  Each row stands for the local moran's I data of gene x.
  Each column stands for a sample.
}
\examples{
\dontrun{
simulation <- init_simulation_gene_net()
lmi_data = cal_lmi_data( simulation$gene_expr, simulation$gene_graph)
t_data = DNLC_statistics(simulation$gene_graph, simulation$gene_expr,
  simulation$patient_matrix, lmi_data = lmi_data)
fdr_result <- gene_fdrtest(t_data)
sig_genes <- significant_genes(fdr_obj = fdr_result, thres = 0.2)}
}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }