#' calc_exact_power.R
#'
#' For detection boundary type tests, find the power given the rejection region bounds and
#' specification of alternative. Do not use for sets larger than 5 elements, will be too slow.
#'
#' @param bounds A d=J*1 vector of bounds on the magnitudes of the test statistics, where
#' the first element is the bound for |Z|_(1) and the last element is the bound for |Z|_(J).
#' @param sig_mat The covariance matrix of the test statistics under the alternative (assume multivariate normal).
#' @param muVec The mean vector of the test statistics under the alternative (assume multivariate normal).
#'
#' @return A list with the elements:
#' \item{power}{Power under the given alternative.}
#' \item{errsum}{Largest possible error from integration.}
#' \item{naSum}{Number of NAs in calculating all integrals.}
#' \item{sumOverA}{Matrix with power, errsum, naSum for each partition of the rejection region.}
#'
#' @export
#' @examples
#' \donttest{
#' myCov <- matrix(data=0.3, nrow=5, ncol=5)
#' diag(myCov) <- 1
#' myBounds <- set_GBJ_bounds(alpha = 0.01, J=5, sig_vec = myCov[lower.tri(myCov)])
#' calc_exact_power(bounds = myBounds, sig_mat = myCov, muVec = c(1, 0, 0, 0, 0))
#'}
calc_exact_power <- function(bounds, sig_mat, muVec) {

  # create Delta_p_part, just the bottom (non-identity) portion.
  # this is for transforming the distribution so that bounds are in terms of constants.
  p <- nrow(sig_mat)
  Delta_p_part <- c()
  for(i in 1:(p-1)) {
    new_row <- c(rep(0, i-1), -1, 1, rep(0, p-1-i))
    Delta_p_part <- rbind(Delta_p_part, new_row)
  }

  # permutation of order
  class_A <- combinat::permn(1:p)			# a list of vectors
  # all possible +/- options
  class_S <- expand.grid(rep(list(0:1), p))			# a matrix

  # final integration bounds
  lower_bounds <- c(0, rep(0, (p-1)), rep(0, (p-1)))
  upper_bounds <- c(bounds, rep(Inf, (p-1)))

  # apply this function over matrix holding all the S options
  calc_over_s <- function(s, p, sig_mat_a, mu_a, Delta_p_part) {

    # multiply variance matrix columns by -1
    negIdx <- which(s <= 0)
    sig_mat_a_s <- sig_mat_a
    sig_mat_a_s[negIdx, ] <- -1 * sig_mat_a_s[negIdx, ]
    sig_mat_a_s[, negIdx] <- -1 * sig_mat_a_s[, negIdx]
    # negate the mean vector
    mu_a_s <- mu_a
    mu_a_s[negIdx] <- -1 * mu_a_s[negIdx]

    # build Delta_p %*% sig_mat_a_s %*% Delta_p in pieces
    botLeft <- Delta_p_part %*% sig_mat_a_s
    topRight <- sig_mat_a_s %*% t(Delta_p_part)
    botRight <- botLeft %*% t(Delta_p_part)
    T_var_matrix <- matrix(data = NA, nrow=2*p - 1, ncol = 2*p - 1)
    T_var_matrix[1:p, 1:p] <- sig_mat_a_s
    T_var_matrix[1:p, (p+1):(2*p - 1)] <- topRight
    T_var_matrix[(p+1):(2*p - 1), 1:p] <- botLeft
    T_var_matrix[(p+1):(2*p - 1), (p+1):(2*p - 1)] <- botRight
    # build new mean vector
    T_mu_bot <- Delta_p_part %*% mu_a_s
    T_mu <- c(mu_a_s, T_mu_bot)

    # calculate the multiple integral, a multivariate normal cdf
    integral_result <- mvtnorm::pmvnorm(lower=lower_bounds, upper=upper_bounds, mean=T_mu, sigma=T_var_matrix)

    return(c(integral_result[1], attributes(integral_result)$err))
  }

  # lapply this function over list of permutations a
  calc_over_a <- function(a, p, Delta_p_part, muVec, sig_mat, sMat) {
    # reorder mean and variance
    mu_a <- muVec[a]
    sig_mat_temp <- sig_mat[a, ]
    sig_mat_a <- sig_mat_temp[, a]

    # calculate over all +/- options
    sRes <- apply(sMat, 1, calc_over_s, p = p, sig_mat_a = sig_mat_a, mu_a = mu_a, Delta_p_part = Delta_p_part)

    # summarize
    numNA <- length(which(is.na(sRes[1, ])))
    sumOverS <- sum(sRes[1, which(!is.na(sRes[1, ]))])
    errSum <- sum(sRes[2, which(!is.na(sRes[1, ]))])

    # return
    return(c(sumOverS, errSum, numNA))
  }

  # sum over a
  sumOverA <- sapply(class_A, calc_over_a, p=p, Delta_p_part = Delta_p_part, muVec = muVec,
                     sig_mat = sig_mat, sMat = class_S)

  # The p-value is 1-minus the probability that we stay within the bounds
  power <- 1 - sum(sumOverA[1, ])
  errsum <- sum(sumOverA[2, ])
  naSum <- sum(sumOverA[3, ])

  # return
  return(list(power=power, errsum=errsum, sumOverA = sumOverA, naSum = naSum))
}
