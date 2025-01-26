require(igraph)
require(spdep)
require(fdrtool)
require(GOstats)
require(locfdr)
require(mvtnorm)
require(caTools)

gene_fdrtest <- function(gene.data){
  name <- gene.data$gene_id_all
  coef_val <- gene.data$t_data
  z.cent <- coef_val - median(coef_val)
  fdr_result <- data.frame(fdr = locfdr::locfdr(z.cent, nulltype = 0, plot = 4)$fdr, name)
  return(fdr_result)
}

cal_lmi_data <- function(gene_expr, gene_graph){
  n_hop_matrix<-function(gene_graph, hop_n){
    dis_mat <- igraph::shortest.paths(gene_graph)
    dis_mat[dis_mat >hop_n] <- 0
    dis_mat[dis_mat == hop_n] <- 0.5
    return(dis_mat)
  }
  dis_mat <- n_hop_matrix(gene_graph, hop_n = 2)
  listw_obj <- spdep::mat2listw(dis_mat, style = 'W')
  gene_expr<-t(apply(gene_expr, 1, function(gene_expr)(gene_expr-min(gene_expr))/(max(gene_expr)-min(gene_expr))))
  lmi_data <- double()
  for (i in seq(1,ncol(gene_expr),1)){
    lmi<-spdep::localmoran(gene_expr[,i],listw = listw_obj)
    lmi_data <- cbind(lmi_data,lmi[,1])
  }
  return(lmi_data)
}

significant_genes <- function(fdr_obj, thres){
  sel.entrez <- fdr_obj$name[which(fdr_obj$fdr<thres)]
  return(sel.entrez)
}

DNLC_statistics <- function(gene_graph, gene_expr='x', clinic_data='y', confounder_matrix = NULL ,lmi_data = NULL)
{
  if(is.null(confounder_matrix))
    confounder_matrix <- rep(1, length(clinic_data))
  if(is.null(lmi_data))
  {
    lmi_data = cal_lmi_data(gene_expr, gene_graph)
  }
  gene_ids <- igraph::V(gene_graph)$name
  if(is.null(gene_ids))
    gene_ids = seq(1,nrow(gene_expr))
  ans = double()
  for (i in seq(1,nrow(gene_expr),1))
  {
    ans <- cbind(ans, summary(lm(clinic_data~lmi_data[i,]+confounder_matrix))$coef[2,3])
  }
  return(list(gene_id_all=gene_ids, t_data=ans) )
}


init_simulation_gene_net <- function( base_correlation = 0.4, change_correlation = 0.8, sample_size = 100, num_gene = 5000, change_gene_num=5)
{
  n_hop_matrix<-function(gene_graph, hop_n){
    dis_mat <- igraph::shortest.paths(gene_graph)
    dis_mat[dis_mat >hop_n] <- 0
    dis_mat[dis_mat == hop_n] <- 0.5
    return(dis_mat)
  }
  netdensity = 1
  gene_graph <- igraph::barabasi.game(num_gene, m = netdensity)
  deg_data <- igraph::degree(gene_graph)

  simu_sel_gene_list = numeric()
  neigh_list_3 <- numeric()
  simu_gene_num = change_gene_num
  times = 100
  while(length(simu_sel_gene_list) < simu_gene_num)
  {
    sel_gene <-  sample(which(deg_data<= 10 &deg_data >= 5), 1)
    if(sel_gene %in% neigh_list_3)
    {
      times = times - 1
      if(times<0)
      {
        return(NULL)
      }
      next()
    }
    simu_sel_gene_list <- c(simu_sel_gene_list, sel_gene)
    neigh_list_3 <- c(neigh_list_3, unlist(igraph::neighborhood(gene_graph, order = 3, nodes = sel_gene, mode = 'all')) )
  }

  neigh_list <- numeric()
  for(sel_gene in simu_sel_gene_list)
  {
    neigh_list <- c(neigh_list, unlist(igraph::neighborhood(gene_graph, order = 1, nodes = sel_gene, mode = 'all')) )
  }
  gene_code_list <- rnorm(num_gene, mean = 0, sd = 0)
  for(gid in neigh_list)
  {
    gene_code_list[gid] <- 1
  }
  for(gid in simu_sel_gene_list){
    gene_code_list[gid] <- 2
  }

  s <- igraph::shortest.paths(gene_graph)
  s1 <- base_correlation^(s)
  x <- t(mvtnorm::rmvnorm(n = sample_size, mean = rep(0,num_gene), sigma = s1, method = "chol"))
  x <- t(apply(x, 1, function(x)(x-min(x))/(max(x)-min(x))))
  y <- c(rnorm(sample_size, mean = 0, sd = 0 ), rnorm(sample_size, mean = 1, sd = 0))

  dis_mat <- n_hop_matrix(gene_graph = gene_graph, hop_n = 2)
  listw_obj <- spdep::mat2listw(dis_mat, style = 'W')
  origin_lmi_data <- double()

  for (i in seq(1, ncol(x), 1)){
    lmi <- spdep::localmoran(x[,i],listw = listw_obj)
    origin_lmi_data <- cbind(origin_lmi_data, lmi[,1])
  }

  for (i in neigh_list){
    for (j in neigh_list){
      s1[i,j] <- change_correlation^s[i,j]
    }
  }

  x1 = x
  x <- t(mvtnorm::rmvnorm(n = sample_size, mean = rep(0,num_gene), sigma = s1, method = "chol"))
  x <- t(apply(x, 1, function(x)(x-min(x))/(max(x)-min(x))))
  y <- c(rnorm(sample_size, mean = 0, sd = 0), rnorm(sample_size, mean = 1, sd = 0))

  lmi_data <- double()
  for (i in seq(1,ncol(x),1)){
    lmi <- spdep::localmoran(x[,i], listw = listw_obj)
    lmi_data <- cbind(lmi_data,lmi[,1])
  }

  lmi_matrix <- cbind(lmi_data, origin_lmi_data)
  return(list(gene_graph = gene_graph, lmi_matrix = lmi_matrix, patient_matrix = y, neigh_list=neigh_list, gene_expr = cbind(x,x1)))
}



