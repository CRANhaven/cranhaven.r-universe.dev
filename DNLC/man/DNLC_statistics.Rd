\name{DNLC_statistics}
\alias{DNLC_statistics}

\title{
  calculate t statistics for gene graph using DNLC method.
}
\description{
  a function to calculate t statistics for genes in the graph.
}
\usage{
DNLC_statistics(gene_graph, gene_expr = "x", clinic_data = "y", 
    confounder_matrix = NULL, lmi_data = NULL)
}

\arguments{
  \item{gene_graph}{  
  graph of gene
}
  \item{gene_expr}{
  expr of gene
}
  \item{clinic_data}{
  patient data
}
  \item{confounder_matrix}{
  other message describe clinic message
}
  \item{lmi_data}{
  lmi data for each gene.
}
}
\details{
	This function first calculates the matrix of local moran's I, and then conducts testing for the association of each gene's local moran's I with the clinical outcome variable. Clinical confounder variables such as age, gender etc can be included. 
}
\value{
\item{all_gene_id}{gene ids in graph}
\item{t_data}{t-data for each gene}

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
