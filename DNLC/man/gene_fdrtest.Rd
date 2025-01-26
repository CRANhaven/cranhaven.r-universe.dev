\name{gene_fdrtest}
\alias{gene_fdrtest}


\title{
  Use local false discovery rate for the detection of genes with significant LMI change
}
\description{
  This function use locfdr function to calculate fdr_result
}
\usage{
  gene_fdrtest(gene.data)
}

\arguments{
  \item{gene.data}{
     gene_id_all: gene id
     t_data: t statistic for each gene
  }
}

\value{
  return fdr_result for t_data
    \item{fdr$name}{all gene id }
    \item{fdr$fdr }{fdr value for gene}

}
\examples{
\dontrun{
simulation <- init_simulation_gene_net()
t_data = DNLC_statistics(simulation$gene_graph, simulation$gene_expr,
  simulation$patient_matrix, lmi_data=simulation$lmi_matrix)
fdr_result <- gene_fdrtest(t_data)
sig_genes <- significant_genes(fdr_obj = fdr_result, thres = 0.2)
}
}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }
