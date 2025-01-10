#' Plot constructed prediction intervals for \code{('rfpredinterval', 'piall')} objects
#'
#' Plots the 16 constructed PIs obtained with \code{piall()} for a test
#' observation. For each method, the red point presents the point prediction and
#' blue line shows the constructed prediction interval for the test
#' observation. If the true response of the test observation is known, it is
#' demonstrated with a dashed vertical line. Note that we may have multiple
#' prediction intervals with the HDR PI method.
#'
#' @param x An object of class \code{('rfpredinterval', 'piall')}.
#' @param test_id Integer value specifying the test observation to be plotted.
#' The default is 1.
#' @param sort Should the prediction intervals be sorted according to their
#'   lengths in the plot? The default is \code{TRUE}.
#' @param show_response Should the true response value of the test observation
#' (if available) be displayed in the plot?
#' @param ...  Optional arguments to be passed to other methods.
#'
#' @return Invisibly, the prediction intervals and point predictions that were
#' plotted for the test observation.
#'
#' @export
#'
#' @examples
#' \donttest{
#' ## load example data
#' data(BostonHousing, package = "RFpredInterval")
#' set.seed(2345)
#'
#' ## define train/test split
#' testindex <- 1
#' trainindex <- sample(2:nrow(BostonHousing), size = 50, replace = FALSE)
#' traindata <- BostonHousing[trainindex, ]
#' testdata <- BostonHousing[testindex, ]
#'
#' ## build 95% PIs with all 16 methods for the first observation in testdata
#' out <- piall(formula = medv ~ ., traindata = traindata,
#'              testdata = testdata, num.trees = 50)
#'
#' ## plot the constructed PIs for test_id = 1 with all methods
#' plot(out, test_id = 1)
#' }
#'
#'
#' @seealso
#'   \code{\link{piall}}
#'
plot.rfpredinterval <- function(x, test_id = 1, sort = TRUE, show_response = TRUE, ...)
{
  object <- x
  remove(x)
  ## object cannot be missing
  if (missing(object)) {stop("Object is missing.")}
  if (sum(inherits(object, c("rfpredinterval", "piall"), TRUE) == c(1, 2)) != 2) {
    stop("This function only works for objects of class `(rfpredinterval, piall)`.")
  }

  ## only one test observation is allowed
  test_id <- test_id[1]
  ## test_id must be integer from 1 to ntest
  if (test_id < 1 || test_id > length(object$pred_pibf)) {
    stop("test_id must be an integer from 1 to ntest.")
  }

  ## get the PIs for test_id
  pred_names <- grepl("pred",names(object))
  method_names <- names(object)[!pred_names]
  method_names <- method_names[-length(method_names)]
  pi_testid <- c()
  for (m in method_names) {
    if (!grepl("_HDR",m)) {
      pi_testid <- rbind(pi_testid, c(m, m, object[[m]]$lower[test_id], object[[m]]$upper[test_id],
                                      object[[m]]$upper[test_id] - object[[m]]$lower[test_id]))
    } else {
      hdr_pi <- object[[m]][[test_id]]
      colnames(hdr_pi) <- NULL
      pi_testid <- rbind(pi_testid, cbind(rep(m, nrow(hdr_pi)), paste(m,1:nrow(hdr_pi),sep=" "),
                                          hdr_pi, rep(sum(hdr_pi[, 2] - hdr_pi[, 1]), nrow(hdr_pi))))
    }
  }
  out_testid <- data.frame(Method = pi_testid[, 1], Method_sub = pi_testid[, 2],
                           Lower = as.numeric(pi_testid[, 3]), Upper = as.numeric(pi_testid[, 4]),
                           PIlength = as.numeric(pi_testid[, 5]))
  if (sort) {
    out_testid <- out_testid[order(out_testid$PIlength, decreasing = FALSE), ]
  }
  out_testid$Method_id <- as.numeric(factor(out_testid$Method, levels = rev(unique(out_testid$Method)), labels = 1:length(method_names)))

  ## get the test prediction for test_id
  pred_testid <- numeric(nrow(out_testid))
  pred_testid[grepl("PIBF",out_testid$Method)] <- object$pred_pibf[test_id]
  pred_testid[grepl("LS_",out_testid$Method)] <- object$pred_ls[test_id]
  pred_testid[grepl("L1_",out_testid$Method)] <- object$pred_l1[test_id]
  pred_testid[grepl("SPI_",out_testid$Method)] <- object$pred_spi[test_id]
  out_testid$Pred <- pred_testid

  # save par settings
  old.par <- par(no.readonly = TRUE)
  on.exit(par(old.par))
  par(mfrow=c(1,1), mar=c(3,6,2,2), cex.axis=0.75, cex.main=1)

  # draw horizontal error bars representing the PIs
  matplot(out_testid$Pred, out_testid$Method_id,
               xlab = NA, ylab = NA, type = "n",
               xlim = range(c(min(out_testid$Lower), max(out_testid$Upper), object$test_response[test_id])), yaxt = "n",
               panel.first = grid(NULL, NA, lty = 1, col = "grey92"),
               main = paste0("Prediction intervals for test_id = ", test_id))
  suppressWarnings(arrows(out_testid$Lower, out_testid$Method_id, out_testid$Upper, out_testid$Method_id, length = 0.05, angle = 90, code = 3, lwd = 2, col = "#5BB0BA"))
  points(out_testid$Pred, out_testid$Method_id, col = "#C44B4F", pch = 20)
  axis(2, at = out_testid$Method_id, labels = gsub("_","-",out_testid$Method), col.axis = "black", las = 2, tck = 0)

  ## add a vertical line for the true test response
  if (!is.null(object$test_response) & show_response) {
    abline(v = object$test_response[test_id], lty = "dashed", col = "#1C4670")
  }

  ## Return the plot.variable object for reuse
  invisible(out_testid)
}
