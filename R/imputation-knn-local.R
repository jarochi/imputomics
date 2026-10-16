# Adapted from Jeffrey Wong's imputation 2.0.3 (GPL), R/kNN.R and R/utils.R.
# https://github.com/jeffwong/imputation
# Commit: c1cc5e4db150dc5fe4fa069be0670284143a105f
# Troyanskaya et al. (2001), https://doi.org/10.1093/bioinformatics/17.6.520
# See inst/NOTICE for attribution and intentional differences from upstream.

#' @keywords internal
#' @noRd
wong_knn_impute <- function(x, k, x.dist = NULL, impute.fn = NULL, verbose = TRUE) {
  if (!is.matrix(x) || !is.numeric(x) || any(dim(x) == 0L) ||
      any(!is.finite(x[!is.na(x)])))
    stop("x must be a nonempty numeric matrix with finite observed values")
  missing <- is.na(x)
  if (!any(missing)) return(list(x = x, missing.matrix = missing))
  if (length(k) != 1L || !is.finite(k) || k != floor(k) || k < 1 || k >= nrow(x))
    stop("k must be a positive integer less than the number of rows in x")
  if (!is.null(impute.fn) && !is.function(impute.fn)) stop("impute.fn must be a function")
  if (is.null(x.dist)) x.dist <- stats::dist(x)
  distances <- as.matrix(x.dist)
  if (!is.numeric(distances) || !identical(dim(distances), c(nrow(x), nrow(x))) ||
      any(distances < 0, na.rm = TRUE))
    stop("x.dist must be a dist object or a square nonnegative distance matrix matching x")
  if (is.null(impute.fn)) impute.fn <- function(values, distances, k) {
    nearest <- order(distances)[seq_len(k)]
    maximum <- max(distances)
    weights <- if (maximum == 0) rep(1, k) else 1 - distances[nearest] / maximum
    if (sum(weights) == 0) weights[] <- 1
    stats::weighted.mean(values[nearest], weights)
  }
  result <- x
  for (i in which(rowSums(missing) > 0)) {
    if (verbose) message("Imputing row ", i)
    for (j in which(missing[i, ])) {
      donors <- which(!missing[, j] & is.finite(distances[i, ]))
      if (!length(donors)) {
        result[i, j] <- 0
      } else {
        value <- impute.fn(x[donors, j], distances[i, donors], min(k, length(donors)))
        if (!is.numeric(value) || length(value) != 1L)
          stop("impute.fn must return a single numeric value")
        result[i, j] <- if (is.finite(value)) value else 0
      }
    }
  }
  list(x = result, missing.matrix = missing)
}
