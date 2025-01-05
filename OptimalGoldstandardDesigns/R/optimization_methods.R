#' Calculate optimal design parameters for a two-stage gold-standard design
#'
#' @param cT2 (numeric) allocation ratio nT2 / nT1. Parameter to be optimized if left unspecified.
#' @param cP1 (numeric) allocation ratio nP1 / nT1. Parameter to be optimized if left unspecified.
#' @param cP2 (numeric) allocation ratio nP2 / nT1. Parameter to be optimized if left unspecified.
#' @param cC1 (numeric) allocation ratio nC1 / nT1. Parameter to be optimized if left unspecified.
#' @param cC2 (numeric) allocation ratio nC2 / nT1. Parameter to be optimized if left unspecified.
#' @param bTP1f (numeric) first stage futility boundary for the T vs. P testing problem. Parameter to be optimized if left unspecified.
#' @param bTP1e (numeric) first stage critical value for the T vs. P testing problem. Parameter to be optimized if left unspecified.
#' @param bTC1f (numeric) first stage futility boundary for the T vs. C testing problem. Parameter to be optimized if left unspecified.
#' @param bTC1e (numeric) first stage critical value for the T vs. C testing problem. Parameter to be optimized if left unspecified.
#' @template alpha
#' @template beta
#' @template alternative_TP
#' @template alternative_TC
#' @template Delta
#' @template varT
#' @template varP
#' @template varC
#' @param binding_futility (logical) controls if futility boundaries are binding.
#' @param always_both_futility_tests (logical) if true, both futility tests are performed after the first stage. If false,
#' a 'completely sequential' testing procedure is employed (see Appendix of \insertCite{meis2023optimization}{OptimalGoldstandardDesigns}).
#' @template round_n
#' @template lambda
#' @template kappa
#' @template eta
#' @template objective
#' @template inner_tol_objective
#' @template mvnorm_algorithm
#' @template nloptr_x0
#' @template nloptr_lb
#' @template nloptr_ub
#' @template nloptr_opts
#' @template print_progress
#' @param ... additional arguments passed along.
#'
#' @return Design object (a list) with optimized design parameters.
#' @export
#' @importFrom nloptr nloptr
#' @importFrom mvtnorm Miwa
#' @details
#' This function calculates optimal design parameters for a two-stage three-arm gold-standard
#' non-inferiority trial. Run \code{vignette("Introduction", package = "OptimalGoldstandardDesigns")}
#' to see some examples related to the associated paper \insertCite{meis2023optimization}{OptimalGoldstandardDesigns}.
#'
#' Parameters which can be optimized are the allocation ratios for all groups and stages and the
#' futility and efficacy boundaries of the first stage. The allocation ratios are
#' cT2 = nT2 / nT1, cP1 = nP1 / nT1,
#' cP2 = nP2 / nT1, cC1 = nC1 / nT1 and cC2 = nC2 / nT1. Here, nT1 denotes the sample size
#' of the treatment group in the first stage, nP2 the sample size of the placebo group in the
#' second stage, etc. The first stage efficacy boundaries are bTP1e for the treatment vs
#' placebo testing problem, and bTC1e for the treatment vs control non-inferiority testing
#' problem. The futility boundaries are denoted by bTP1f and bTC1f.
#'
#' If these parameters are left unspecified or set to NULL, they will be included into the
#' optimization process, otherwise they will be considered boundary constraints.
#' You may also supply quoted expressions as arguments for these
#' parameters to solve a constrained optimization problem. For example, you can supply
#' \code{cT2 = 1, cP2 = quote(cP1), cC2 = quote(cC1)} to ensure that the first and second
#' stage allocation ratios are equal.
#'
#'
#' The design is optimized with respect to the objective criterion given by the parameter
#' \code{objective}. The default objective function is described in the
#' Subsection *Optimizing group sequential gold-standard designs* in Section 2
#' of \insertCite{meis2023optimization}{OptimalGoldstandardDesigns}. Additionally,
#' this objective includes a term to penalize the maximum sample size of a trial,
#' which can be controlled by the parameter `eta` (default is `eta=0`).
#'
#' Designs are calculated to fulfill the following constraints: the family-wise type I error
#' rate is controlled at \code{alpha} under any combination of the two null hypotheses
#' \code{muT - muP = 0} and \code{muT - muC + Delta = 0}.
#' The power to reject both hypothesis given both alternative
#' hypotheses \code{muT - muP = alternative_TP} and \code{muT - muC + Delta = alternative_TC + Delta}
#' is at least \code{1 - beta}. Variances are assumed to be given by \code{varT, varP} and \code{varC}.
#'
#' If \code{binding_futility} is \code{TRUE}, type I error recycling is used.
#' If \code{always_both_futility_tests} is \code{TRUE}, it is assumed that futility tests for both
#' hypotheses are performed at interim, regardless of whether the treatment vs placebo null hypothesis
#' was successfully rejected. If \code{always_both_futility_tests} is \code{FALSE}, the futility
#' test for the treatment vs. control testing problem only needs to be done if the null for the
#' treatment vs. placebo testing problem was rejected in the first stage.
#'
#'
#'
#' @examples
#' # Should take about 15 seconds.
#' \donttest{
#' optimize_design_twostage(
#'   cT2 = 1,
#'   cP2 = quote(cP1),
#'   cC2 = quote(cC1),
#'   bTP1f = -Inf,
#'   bTC1f = -Inf,
#'   beta = 0.2,
#'   alternative_TP = 0.4,
#'   alternative_TC = 0,
#'   Delta = 0.2,
#'   binding_futility = TRUE,
#'   lambda = .9,
#'   kappa = 1,
#'   nloptr_opts = list(algorithm = "NLOPT_LN_SBPLX", ftol_rel = 1e-01)
#' )
#' }
#' @references
#' \insertAllCited{}
#'
optimize_design_twostage <-
  function(cT2   = NULL,
           cP1   = NULL,
           cP2   = NULL,
           cC1   = NULL,
           cC2   = NULL,
           bTP1f = NULL,
           bTP1e = NULL,
           bTC1f = NULL,
           bTC1e = NULL,
           alpha = .025,
           beta = .2,
           alternative_TP = .4,
           alternative_TC = 0,
           Delta = .2,
           varT = 1,
           varP = 1,
           varC = 1,
           binding_futility = FALSE,
           always_both_futility_tests = TRUE,
           round_n = TRUE,
           lambda = 1,
           kappa = 0,
           eta = 0,
           objective = quote(
             sqrt(lambda) ^ 2 * ASN[["H11"]] +
               (1 - sqrt(lambda)) * sqrt(lambda) * ASN[["H10"]] +
               (1 - sqrt(lambda)) * sqrt(lambda) * ASN[["H01"]] +
               (1 - sqrt(lambda)) ^ 2 * ASN[["H00"]] +
               kappa *
               (
                 sqrt(lambda) ^ 2 * ASNP[["H11"]] +
                   (1 - sqrt(lambda)) * sqrt(lambda) * ASNP[["H10"]] +
                   (1 - sqrt(lambda)) * sqrt(lambda) * ASNP[["H01"]] +
                   (1 - sqrt(lambda)) ^ 2 * ASNP[["H00"]] +
                   eta * cumn[[2]][["P"]]
               ) +
               eta * (cumn[[2]][["T"]] + cumn[[2]][["P"]] + cumn[[2]][["C"]])
             ),
           inner_tol_objective = .Machine$double.eps^0.25,
           mvnorm_algorithm = mvtnorm::Miwa(steps = 128, checkCorr = FALSE, maxval = 1e3), # maxsteps = 4097
           nloptr_x0 = NULL,
           nloptr_lb = NULL,
           nloptr_ub = NULL,
           nloptr_opts = list(
             algorithm = "NLOPT_LN_SBPLX",
             ftol_rel = 1e-4,
             xtol_abs = 1e-3,
             xtol_rel = 1e-2,
             maxeval = 1000,
             print_level = 0
           ),
           print_progress = TRUE,
           ...) {
    arguments <- c(as.list(environment()))
    quoted_arguments <- arguments[sapply(arguments, function(x)is.call(x)||is.symbol(x))]
    quoted_arguments <- quoted_arguments[names(quoted_arguments)!= "objective"]

    for (n in names(quoted_arguments)){
     if (!grepl("<-", deparse(quoted_arguments[[n]]))){
       quoted_arguments[[n]] <- parse(text=paste0(n, " <- ", deparse(quoted_arguments[[n]]), collapse = ""))
     }
    }

    determine_x0 <- missing(nloptr_x0)
    determine_lb <- missing(nloptr_lb)
    determine_ub <- missing(nloptr_ub)

    if (determine_x0){
      nloptr_x0 <- list()
    }
    if (determine_lb){
      nloptr_lb <- list()
    }
    if (determine_ub){
      nloptr_ub <- list()
    }
    quotes <- list()
    quote_idx <- 1L
    if (missing(cT2) || is.null(cT2)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- 1
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- 1 / 20
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- 20
      quotes[[quote_idx]] <- quote(cT2 <- x[i])
      quote_idx <- quote_idx + 1L
    }
    if (missing(cP1)|| is.null(cP1)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- .25
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- .25 / 20
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- .25 * 20
      quotes[[quote_idx]] <- quote(cP1 <- x[i])
      quote_idx <- quote_idx + 1L
    }
    if (missing(cP2) || is.null(cP2)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- .25
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- .25 / 20
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- .25 * 20
      quotes[[quote_idx]] <- quote(cP2 <- x[i])
      quote_idx <- quote_idx + 1L
    }
    if (missing(cC1)|| is.null(cC1)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- 1
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- 1 / 20
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- 20
      quotes[[quote_idx]] <- quote(cC1 <- x[i])
      quote_idx <- quote_idx + 1L
    }
    if (missing(cC2) || is.null(cC2)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- 1
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- 1 / 20
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- 20
      quotes[[quote_idx]] <- quote(cC2 <- x[i])
      quote_idx <- quote_idx + 1L
    }
    if (missing(bTP1e) || is.null(bTP1e)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- 2.105099
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- qnorm(1-alpha)
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- qnorm(.Machine$double.eps, lower.tail = FALSE)
      quotes[[quote_idx]] <- quote(bTP1e <- x[i])
      quote_idx <- quote_idx + 1L
    }
    if (missing(bTP1f) || is.null(bTP1f)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- 0
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- qnorm(.Machine$double.eps, lower.tail = TRUE)
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- qnorm(1-alpha)
      quotes[[quote_idx]] <- quote(bTP1f <- x[i])
      quote_idx <- quote_idx + 1L
    }
    if (missing(bTC1e) || is.null(bTC1e)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- 2.270933
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- qnorm(1-alpha)
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- qnorm(.Machine$double.eps, lower.tail = FALSE)
      quotes[[quote_idx]] <- quote(bTC1e <- x[i])
      quote_idx <- quote_idx + 1L
    }
    if (missing(bTC1f) || is.null(bTC1f)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- 0
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- qnorm(.Machine$double.eps, lower.tail = TRUE)
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- qnorm(1-alpha)
      quotes[[quote_idx]] <- quote(bTC1f <- x[i])
      quote_idx <- quote_idx + 1L
    }
    D_half2<- list(
      type_I_error = alpha,
      type_II_error = beta,
      mu = list("H0" = list("TP" = 0, "TC" = 0), "H1" = list("TP" = alternative_TP, "TC" = alternative_TC + Delta)),
      var = list("T" = varT, "P" = varP, "C" = varC),
      binding_futility = binding_futility,
      always_both_futility_tests = always_both_futility_tests,
      round_n = FALSE,
      lambda = lambda,
      kappa = kappa,
      eta = eta,
      objective = objective,
      inner_tol_objective = inner_tol_objective,
      mvnorm_algorithm = mvnorm_algorithm,
      return_everything = FALSE,
      ...
    )

    nloptr_maxeval <- if(!is.null(nloptr_opts$maxeval)) nloptr_opts$maxeval else 100
    iter <- 0

    opt_fun <- function(x){
      for (i in seq_along(x)){
        eval(quotes[[i]])
      }
      for (i in seq_along(quoted_arguments)){
        eval(quoted_arguments[[i]])
      }
      D <-
        append(list(stagec = list(
          list("T" = 1, "P" = cP1, "C" = cC1),
          list("T" = cT2, "P" = cP2, "C" = cC2)
        ),
        b = list(
          list(
            "TP" = list("efficacy" = bTP1e, "futility" = bTP1f),
            "TC" = list("efficacy" = bTC1e, "futility" = bTC1f)
          ),
          list(
            "TP" = list("efficacy" = NA_real_),
            "TC" = list("efficacy" = NA_real_)
          )
        )),
        D_half2)

      ret <- objective_twostage(D)
      if (print_progress){
        iter <<- iter + 1
        iterstring <- padd_whitespace(paste0("iteration: ", iter, "/", nloptr_maxeval))
        exprstring <- character(length = length(x))
        for (i in seq_along(x)){
          exprstring[i] <- deparse(do.call(substitute, list(quotes[[i]], list(i=i))))
        }
        exprstring <- padd_whitespace(paste0("  ",paste0(exprstring, collapse = " "), "", collapse=""))
        xstring <- padd_whitespace(paste0("    x = c(", paste0(format(x, trim=TRUE), collapse = ", "), ")", collapse = ""))
        fstring <- padd_whitespace(paste0("     f(x) = ", format(ret)))
        cat("\r", iterstring, exprstring, xstring,  fstring)
      }
      return(ret)
    }

    nloptr_x0 <- unlist(nloptr_x0)
    nloptr_lb <- unlist(nloptr_lb)
    nloptr_ub <- unlist(nloptr_ub)
    opt <- nloptr(
      x0 = nloptr_x0,
      eval_f = opt_fun,
      lb = nloptr_lb,
      ub = nloptr_ub,
      opts = nloptr_opts)

    if(print_progress)
      cat("\n", "Optimization finished. Calculating final design with greater accuracy...\n")

    x <- opt$solution
    for (i in seq_along(x)){
      eval(quotes[[i]])
    }
    for (i in seq_along(quoted_arguments)){
      eval(quoted_arguments[[i]])
    }

    D_half2$round_n <- round_n
    D_half2$return_everything <- TRUE
    D <-
      append(list(stagec = list(
        list("T" = 1, "P" = cP1, "C" = cC1),
        list("T" = cT2, "P" = cP2, "C" = cC2)
      ),
      b = list(
        list(
          "TP" = list("efficacy" = bTP1e, "futility" = bTP1f),
          "TC" = list("efficacy" = bTC1e, "futility" = bTC1f)
        ),
        list(
          "TP" = list("efficacy" = NA_real_),
          "TC" = list("efficacy" = NA_real_)
        )
      )),
      D_half2)

    # Increase accuracy for final design
    original_inner_tol_objective <- inner_tol_objective
    original_mvnorm_algorithm <- mvnorm_algorithm
    D$inner_tol_objective <- min(1e-9, inner_tol_objective)
    D$mvnorm_algorithm <- Miwa(steps = 4097, checkCorr = FALSE, maxval = 1000)

    opt_design <- objective_twostage(D)
    opt_design$nloptr_optim <- opt
    opt_design$x_end <- x
    opt_design$inner_tol_objective <- original_inner_tol_objective
    D$mvnorm_algorithm <- original_mvnorm_algorithm

    for (n in names(arguments)){
      if (!(n %in% names(opt_design))){
        opt_design[[n]] <- eval(parse(text = n))
      }
    }

    class(opt_design) <- c("TwoStageGoldStandardDesign", class(opt_design))
    return(opt_design)
  }

#' Calculate optimal design parameters for a single-stage gold-standard design
#'
#' @param cP1 (numeric) allocation ratio nP1 / nT1. Parameter to be optimized if left unspecified.
#' @param cC1 (numeric) allocation ratio nC1 / nT1. Parameter to be optimized if left unspecified.
#' @template alpha
#' @template beta
#' @template alternative_TP
#' @template alternative_TC
#' @template Delta
#' @template varT
#' @template varP
#' @template varC
#' @template round_n
#' @template kappa
#' @template objective
#' @template inner_tol_objective
#' @template mvnorm_algorithm
#' @template nloptr_x0
#' @template nloptr_lb
#' @template nloptr_ub
#' @template nloptr_opts
#' @template print_progress
#' @param ... additional arguments passed along.
#'
#' @return Design object (a list) with optimized design parameters.
#' @export
#' @importFrom nloptr nloptr
#' @details
#' This function calculates optimal design parameters for a two-stage three-arm gold-standard
#' non-inferiority trial. Run \code{vignette("Introduction", package = "OptimalGoldstandardDesigns")}
#' to see some examples related to the associated paper \insertCite{meis2023optimization}{OptimalGoldstandardDesigns}.
#'
#'
#' Parameters which can be optimized are the allocation ratios for all groups and stages and the
#' futility and efficacy boundaries of the first stage. The allocation ratios are
#' cT2 = nT2 / nT1, cP1 = nP1 / nT1,
#' cP2 = nP2 / nT1, cC1 = nC1 / nT1 and cC2 = nC2 / nT1. Here, nT1 denotes the sample size
#' of the treatment group in the first stage, nP2 the sample size of the placebo group in the
#' second stage, etc. The first stage efficacy boundaries are bTP1e for the treatment vs
#' placebo testing problem, and bTC1e for the treatment vs control non-inferiority testing
#' problem. The futility boundaries are denoted by bTP1f and bTC1f.
#'
#' If these parameters are left unspecified or set to NULL, they will be included into the
#' optimization process, otherwise they will be considered boundary constraints.
#' You may also supply quoted expressions as arguments for these
#' parameters to solve a constrained optimization problem. For example, you can supply
#' \code{cT2 = 1, cP2 = quote(cP1), cC2 = quote(cC1)} to ensure that the first and second
#' stage allocation ratios are equal.
#'
#'
#' The design is optimized with respect to the objective criterion given by the parameter
#' \code{objective}. By default, this is the overall sample size plus an optional
#' penalty for the placebo group sample size, controlled by the parameter `kappa`.
#'
#' Designs are calculated to fulfill the following constraints: the family-wise type I error
#' rate is controlled at \code{alpha} under any combination of the two null hypotheses
#' \code{muT - muP = 0} and \code{muT - muC + Delta = 0}.
#' The power to reject both hypothesis given both alternative
#' hypotheses \code{muT - muP = alternative_TP} and \code{muT - muC + Delta = alternative_TC + Delta}
#' is at least \code{1 - beta}. Variances are assumed to be given by \code{varT, varP} and \code{varC}.
#'
#' If \code{binding_futility} is \code{TRUE}, type I error recycling is used.
#' If \code{always_both_futility_tests} is \code{TRUE}, it is assumed that futility tests for both
#' hypotheses are performed at interim, regardless of whether the treatment vs placebo null hypothesis
#' was successfully rejected. If \code{always_both_futility_tests} is \code{FALSE}, the futility
#' test for the treatment vs. control testing problem only needs to be done if the null for the
#' treatment vs. placebo testing problem was rejected in the first stage.
#'
#'
#'
#' @examples
#' # Should take about 2 second with the chosen accuracy
#' optimize_design_onestage(
#'   alpha = .025,
#'   beta = .2,
#'   alternative_TP = .4,
#'   alternative_TC = 0,
#'   Delta = .2,
#'   mvnorm_algorithm = mvtnorm::Miwa(steps = 512, checkCorr = FALSE, maxval = 1000),
#'   nloptr_opts = list(algorithm = "NLOPT_LN_SBPLX", ftol_rel = 1e-03, xtol_abs = 1e-08,
#'                      xtol_rel = 1e-07, maxeval = 1000, print_level = 0)
#' )
#'
#' @references
#' \insertAllCited{}
#'
optimize_design_onestage <-
  function(cP1   = NULL,
           cC1   = NULL,
           alpha = .025,
           beta  = .2,
           alternative_TP = .4,
           alternative_TC = 0,
           Delta = .2,
           varT = 1,
           varP = 1,
           varC = 1,
           round_n = TRUE,
           kappa = 0,
           objective = quote(
             sum(unlist(n)) +
               kappa * n[[1]][["P"]]
           ),
           inner_tol_objective = 1e-7,
           mvnorm_algorithm = mvtnorm::Miwa(steps = 4097, checkCorr = FALSE, maxval = 1e3), # maxsteps = 4097
           nloptr_x0 = NULL,
           nloptr_lb = NULL,
           nloptr_ub = NULL,
           nloptr_opts = list(
             algorithm = "NLOPT_LN_SBPLX",
             ftol_rel = 1e-9,
             xtol_abs = 1e-8,
             xtol_rel = 1e-7,
             maxeval = 1000,
             print_level = 0
           ),
           print_progress = TRUE,
           ...) {
    arguments <- c(as.list(environment()))
    quoted_arguments <- arguments[sapply(arguments, function(x)is.call(x)||is.symbol(x))]
    quoted_arguments <- quoted_arguments[names(quoted_arguments)!= "objective"]

    for (n in names(quoted_arguments)){
      if (!grepl("<-", deparse(quoted_arguments[[n]]))){
        quoted_arguments[[n]] <- parse(text=paste0(n, " <- ", deparse(quoted_arguments[[n]]), collapse = ""))
      }
    }

    determine_x0 <- missing(nloptr_x0)
    determine_lb <- missing(nloptr_lb)
    determine_ub <- missing(nloptr_ub)

    if (determine_x0){
      nloptr_x0 <- list()
    }
    if (determine_lb){
      nloptr_lb <- list()
    }
    if (determine_ub){
      nloptr_ub <- list()
    }
    quotes <- list()
    quote_idx <- 1L
    if (missing(cP1) || is.null(cP1)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- .25
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- .25 / 20
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- .25 * 20
      quotes[[quote_idx]] <- quote(cP1 <- x[i])
      quote_idx <- quote_idx + 1L
    }
    if (missing(cC1) || is.null(cC1)){
      if (determine_x0)
        nloptr_x0[[quote_idx]] <- 1
      if (determine_lb)
        nloptr_lb[[quote_idx]] <- 1 / 20
      if (determine_ub)
        nloptr_ub[[quote_idx]] <- 20
      quotes[[quote_idx]] <- quote(cC1 <- x[i])
      quote_idx <- quote_idx + 1L
    }
    D_half2<- list(
      b = list(list("TP" = list("efficacy" = qnorm(1-alpha)), "TC" = list("efficacy" = qnorm(1-alpha)))),
      type_I_error = alpha,
      type_II_error = beta,
      mu = list("H0" = list("TP" = 0, "TC" = 0), "H1" = list("TP" = alternative_TP, "TC" = alternative_TC + Delta)),
      var = list("T" = varT, "P" = varP, "C" = varC),
      round_n = FALSE,
      kappa = kappa,
      objective = objective,
      inner_tol_objective = inner_tol_objective,
      mvnorm_algorithm = mvnorm_algorithm,
      return_everything = FALSE,
      ...
    )

    nloptr_maxeval <- if(!is.null(nloptr_opts$maxeval)) nloptr_opts$maxeval else 100
    iter <- 0

    opt_fun <- function(x){
      for (i in seq_along(x)){
        eval(quotes[[i]])
      }
      for (i in seq_along(quoted_arguments)){
        eval(quoted_arguments[[i]])
      }
      D <-
        append(list(stagec = list(
          list("T" = 1, "P" = cP1, "C" = cC1)
        )),
        D_half2)


      ret <- objective_onestage(D)
      if (print_progress){
        iter <<- iter + 1
        iterstring <- padd_whitespace(paste0("iteration: ", iter, "/", nloptr_maxeval))
        exprstring <- character(length = length(x))
        for (i in seq_along(x)){
          exprstring[i] <- deparse(do.call(substitute, list(quotes[[i]], list(i=i))))
        }
        exprstring <- padd_whitespace(paste0("  ",paste0(exprstring, collapse = " "), "", collapse=""))
        xstring <- padd_whitespace(paste0("    x = c(", paste0(format(x, trim = TRUE), collapse = ", "), ")", collapse = ""))
        fstring <- padd_whitespace(paste0("     f(x) = ", format(ret)))
        cat("\r", iterstring, exprstring, xstring,  fstring)
      }
      return(ret)
    }

    nloptr_x0 <- unlist(nloptr_x0)
    nloptr_lb <- unlist(nloptr_lb)
    nloptr_ub <- unlist(nloptr_ub)
    opt <- nloptr(
      x0 = nloptr_x0,
      eval_f = opt_fun,
      lb = nloptr_lb,
      ub = nloptr_ub,
      opts = nloptr_opts)

    if(print_progress)
      cat("\n", "Optimization finished. Calculating final design with greater accuracy...\n")

    x <- opt$solution
    for (i in seq_along(x)){
      eval(quotes[[i]])
    }
    for (i in seq_along(quoted_arguments)){
      eval(quoted_arguments[[i]])
    }

    D_half2$round_n <- round_n
    D_half2$return_everything <- TRUE
    D <-
      append(list(stagec = list(
        list("T" = 1, "P" = cP1, "C" = cC1)
      )),
      D_half2)

    original_inner_tol_objective <- inner_tol_objective
    original_mvnorm_algorithm <- mvnorm_algorithm
    D$inner_tol_objective <- min(1e-9, inner_tol_objective)
    D$mvnorm_algorithm <- Miwa(steps = 4097, checkCorr = FALSE, maxval = 1000)

    opt_design <- objective_onestage(D)
    opt_design$nloptr_optim <- opt
    opt_design$x_end <- x
    opt_design$inner_tol_objective <- original_inner_tol_objective
    D$mvnorm_algorithm <- original_mvnorm_algorithm

    for (n in names(arguments)){
      if (!(n %in% names(opt_design))){
        opt_design[[n]] <- eval(parse(text = n))
      }
    }

    class(opt_design) <- c("OneStageGoldStandardDesign", class(opt_design))
    return(opt_design)
  }
