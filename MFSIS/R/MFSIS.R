#' Model-free feature screening procedures
#'
#' Through this function, we provide a unified framework
#' to carry out model-free screening procedures including
#' SIS (Fan and Lv (2008) <doi:10.1111/j.1467-9868.2008.00674.x>),
#' SIRS(Zhu et al. (2011)<doi:10.1198/jasa.2011.tm10563>),
#'  DC-SIS (Li et al. (2012) <doi:10.1080/01621459.2012.695654>),
#' MDC-SIS(Shao and Zhang (2014) <doi:10.1080/01621459.2014.887012>),
#' Bcor-SIS (Pan et al. (2019) <doi:10.1080/01621459.2018.1462709>),
#'  PC-Screen (Liu et al. (2020) <doi:10.1080/01621459.2020.1783274>),
#' WLS (Zhong et al.(2021) <doi:10.1080/01621459.2021.1918554>),
#' Kfilter (Mai and Zou (2015) <doi:10.1214/14-AOS1303>),
#' MVSIS (Cui et al. (2015) <doi:10.1080/01621459.2014.920256>),
#' PSIS (Pan et al. (2016) <doi:10.1080/01621459.2014.998760>),
#'  CAS (Xie et al. (2020) <doi:101080/0162145920191573734>),
#' CI-SIS (Cheng and Wang. (2022) <doi:10.1016/j.cmpb.2022.107269>)
#' and CSIS.
#'
#' @param X The design matrix of dimensions n * p. Each row is an observation vector.
#' @param Y The response vector of dimension n * 1.
#' @param nsis Number of predictors recruited by the screening method. The default is n/log(n).
#' @param method The method that you choose to perform screening procedure.
#' method=c("SIS", "SIRS", "DCSIS", "MDCSIS", "CSIS", "PCSIS", "BcorSIS", "WLS", "MVSIS", "Kfilter","PSIS","CAS","CISIS").
#' If you want to know more information about this method, please use command "help(method)" for detail information.
#'
#' @return the labels of first nsis largest active set of all predictors
#' @export
#' @author Xuewei Cheng \email{xwcheng@hunnu.edu.cn}
#' @examples
#'
#' n <- 100
#' p <- 200
#' rho <- 0.5
#' data <- GendataLM(n, p, rho, error = "gaussian")
#' data <- cbind(data[[1]], data[[2]])
#' colnames(data)[1:ncol(data)] <- c(paste0("X", 1:(ncol(data) - 1)), "Y")
#' data <- as.matrix(data)
#' X <- data[, 1:(ncol(data) - 1)]
#' Y <- data[, ncol(data)]
#' A <- MFSIS(X, Y, n / log(n), method = "CSIS")
#' A
#'
MFSIS <- function(X, Y, nsis = (dim(X)[1]) / log(dim(X)[1]), method = c("SIS", "SIRS", "DCSIS", "MDCSIS", "CSIS", "PCSIS", "BcorSIS", "WLS", "MVSIS", "Kfilter")) {
  if (method == "SIS") { ## NO.1
    A <- SIS(X, Y, nsis)
  } else if (method == "SIRS") { ## NO.2
    A <- SIRS(X, Y, nsis)
  } else if (method == "DCSIS") { ## NO.3
    A <- DCSIS(X, Y, nsis)
  } else if (method == "MDCSIS") { ## NO.4
    A <- MDCSIS(X, Y, nsis)
  } else if (method == "CSIS") { ## NO.5
    A <- CSIS(X, Y, nsis)
  } else if (method == "BcorSIS") { ## NO.6
    A <- BcorSIS(X, Y, nsis)
  } else if (method == "WLS") { ## NO.7
    A <- WLS(X, Y, nsis)
  } else if (method == "MVSIS") { ## NO.8
    A <- MVSIS(X, Y, nsis)
  } else if (method == "PCSIS") { ## NO.9
    A <- PCSIS(X, Y, nsis)
  } else if (method == "Kfilter") { ## NO.10
    A <- Kfilter(X, Y, nsis)
  } else if (method == "PSIS") { ## NO.11
    A <- PSIS(X, Y, nsis)
  } else if (method == "CAS") { ## NO.12
    A <- CAS(X, Y, nsis)
  } else if (method == "CISIS") { ## NO.13
    A <- CISIS(X, Y, nsis)
  } else {
    stop("The author has not implemented this method yet. Please email the author!")
  }
}
