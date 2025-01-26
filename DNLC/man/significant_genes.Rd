\name{significant_genes}
\alias{significant_genes}

\title{
Selecting significant genes according to fdr result
}
\description{
  Choose the significant genes according to fdr result
}
\usage{
significant_genes(fdr_obj, thres)
}

\arguments{
  \item{fdr_obj}{
  fdr result come from function gene_fdrtest
}
  \item{thres}{
  threshold to identify significant genes
}
}

\value{
  ID of significant genes
}

\examples{
\dontrun{
simulation <- init_simulation_gene_net()
t_data = DNLC_statistics(simulation$gene_graph, simulation$gene_expr,
  simulation$patient_matrix, lmi_data = simulation$lmi_matrix)
fdr_result <- gene_fdrtest(t_data)
sig_genes <- significant_genes(fdr_obj = fdr_result, thres = 0.2)
}

}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }
