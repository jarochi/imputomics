# Local Lee-Seung KL-divergence NMF (https://doi.org/10.1038/44565).
# mNMF weighting adapted from Jingjing Xu et al. (2021):
# https://doi.org/10.3390/molecules26195787
# https://github.com/freeoliver-jing/NMF

#' @keywords internal
#' @noRd
nmf <- function(x, rank, max_iter = 1000L, tol = 1e-6) {
  if (!is.matrix(x) || !is.numeric(x) || any(!is.finite(x)) ||
      any(x < 0) || any(dim(x) == 0L))
    stop("x must be a nonempty finite nonnegative numeric matrix")
  if (length(rank) != 1L || !is.finite(rank) || rank != floor(rank) ||
      rank < 1L || rank > min(dim(x)))
    stop("rank must be an integer between 1 and min(dim(x))")
  if (length(max_iter) != 1L || !is.finite(max_iter) ||
      max_iter < 1L || max_iter != floor(max_iter))
    stop("max_iter must be a positive integer")
  if (length(tol) != 1L || !is.finite(tol) || tol < 0)
    stop("tol must be finite and nonnegative")
  eps <- .Machine$double.eps
  scale <- max(x)
  if (scale == 0) return(list(W = matrix(0, nrow(x), rank),
                             H = matrix(0, rank, ncol(x)),
                             objective = 0, iterations = 0L))
  target <- x / scale
  W <- matrix(stats::runif(nrow(x) * rank, 0.1, 1), nrow(x), rank)
  H <- matrix(stats::runif(rank * ncol(x), 0.1, 1), rank, ncol(x))
  previous <- Inf
  positive <- target > 0
  for (iteration in seq_len(max_iter)) {
    ratio <- target / pmax(W %*% H, eps)
    H <- H * sweep(crossprod(W, ratio), 1L, pmax(colSums(W), eps), "/")
    ratio <- target / pmax(W %*% H, eps)
    W <- W * sweep(ratio %*% t(H), 2L, pmax(rowSums(H), eps), "/")
    norms <- pmax(colSums(W), eps)
    W <- sweep(W, 2L, norms, "/")
    H <- sweep(H, 1L, norms, "*")
    fitted <- pmax(W %*% H, eps)
    objective <- sum(fitted - target) +
      sum(target[positive] * log(target[positive] / fitted[positive]))
    if (is.finite(previous) &&
        abs(previous - objective) <= tol * max(1, abs(previous))) break
    previous <- objective
  }
  list(W = W, H = H * scale, objective = objective * scale,
       iterations = iteration)
}

#' @keywords internal
#' @noRd
nmf_method <- function(IMPdata, k, type) {
  type <- match.arg(type, c("mean", "median", "zero"))
  V <- as.matrix(IMPdata)
  missing <- is.na(V)
  if (!is.numeric(V) || any(!is.finite(V[!missing])) || any(V[!missing] < 1))
    stop("Observed mNMF values must be finite and at least one")
  if (type == "zero") {
    # Zero in log space corresponds to one in the original intensity space.
    V[missing] <- 1
  } else {
    fill <- if (type == "mean") rowMeans(V, na.rm = TRUE) else
      apply(V, 1L, stats::median, na.rm = TRUE)
    if (any(!is.finite(fill))) stop("Cannot pre-impute an entirely missing feature")
    V[missing] <- matrix(fill, nrow(V), ncol(V))[missing]
  }
  fit <- nmf(log10(V), k)
  reconstructed <- 10^(fit$W %*% fit$H)
  dimnames(reconstructed) <- dimnames(V)
  out <- as.matrix(IMPdata)
  out[missing] <- reconstructed[missing]
  structure(list(FIT = reconstructed, OUT = out), class = "Imputation")
}

#' @keywords internal
#' @noRd
nmf_opt <- function(IMP, kgroup, initialType) {
  IMP <- as.matrix(IMP)
  if (!is.numeric(kgroup) || !length(kgroup) || any(!is.finite(kgroup)) ||
      any(kgroup != floor(kgroup)) || any(kgroup < 1 | kgroup > min(dim(IMP))))
    stop("kgroup must contain integer ranks between 1 and min(dim(IMP))")
  initialType <- match.arg(initialType, c("mean", "median", "zero"))
  observed <- !is.na(IMP)
  if (!any(observed)) stop("mNMF requires observed values")
  if (!is.numeric(IMP) || any(!is.finite(IMP[observed])) || any(IMP[observed] < 1))
    stop("Observed mNMF values must be finite and at least one")
  if (all(observed)) return(IMP)
  weighted <- matrix(0, nrow(IMP), ncol(IMP), dimnames = dimnames(IMP))
  total <- 0
  for (k in unique(kgroup)) {
    fit <- nmf_method(IMP, k, initialType)
    error <- mean(abs(fit$FIT[observed] - IMP[observed])) / max(IMP[observed])
    weight <- exp(-2 * error)
    weighted <- weighted + weight * fit$OUT
    total <- total + weight
  }
  if (!is.finite(total) || total == 0) stop("mNMF reconstruction weights vanished")
  result <- weighted / total
  result[observed] <- IMP[observed]
  result
}
