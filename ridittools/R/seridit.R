seridit <-
function(v, ref) {
  N <- sum(ref)
  n <- sum(v)
  term1 <- (n + 1) / N
  term2 <- 1 / (N * (N + n - 1))
  term3 <- sum((ref + v) ^ 3) / (N * (N + n) * (N + n - 1))
  (1 / (2 * sqrt(3 * n))) * sqrt(1 + term1 + term2 - term3)
}
