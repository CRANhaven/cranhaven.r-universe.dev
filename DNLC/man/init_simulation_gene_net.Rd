\name{init_simulation_gene_net}
\alias{init_simulation_gene_net}

\title{
Create a random network for simulation
}
\description{
  This function will create a network for DNLC.
  This function will change correlation of chosen genes and its one hop neighbor between treatment groups to simulate LMI changes.
}
\usage{
init_simulation_gene_net(base_correlation = 0.4, 
    change_correlation = 0.8, sample_size = 100, num_gene = 5000, change_gene_num=5)
}

\arguments{
  \item{base_correlation}{
  base correlation of network
}
  \item{change_correlation}{
  change correlation for selected genes
}
  \item{sample_size}{
  multi size of patient data
}
  \item{num_gene}{
  gene number in the network
}
  \item{change_gene_num}{
  number of genes around which the correlation structure is to be changed
}
}

\value{
  \item{lmi_matrix}{matrix of local moran's I data}
  \item{patient_matrix }{matrix of patient data}
  \item{neigh_list}{id of changed gene.}
  \item{gene_graph }{igraph object of gene network}
  \item{gene_expr}{gene expression data matirx}
}

\examples{
\dontrun{
simulation <- init_simulation_gene_net()
t_data = DNLC_statistics(simulation$gene_graph, simulation$gene_expr,
  simulation$patient_matrix, lmi_data = simulation$lmi_matrix)
fdr_result <- gene_fdrtest(t_data)
sig_genes <- significant_genes(fdr_obj = fdr_result, thres = 0.2)}
}

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }
