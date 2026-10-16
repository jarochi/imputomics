test_that("local NMF reconstructs low-rank data and preserves nonnegativity", {
  x <- outer(c(1, 2, 4, 8), c(2, 3, 5))
  set.seed(42)
  fit <- nmf(x, 1)
  expect_equal(fit$W %*% fit$H, x, tolerance = 1e-5)
  expect_true(all(fit$W >= 0) && all(fit$H >= 0))
  expect_lt(abs(fit$objective), 1e-6)
  set.seed(42)
  expect_identical(nmf(x, 1), fit)
  expect_equal(nmf(x * 0, 2)$W %*% nmf(x * 0, 2)$H, x * 0)
  expect_error(nmf(-x, 1), "nonnegative")
  expect_error(nmf(x, 0), "rank")
  expect_error(nmf(x, 1.5), "rank")
  expect_error(nmf(x, 1, max_iter = 0), "max_iter")
})

test_that("mNMF handles all initializations and nonconsecutive ranks", {
  x <- matrix(as.numeric(seq(2, 25)), 4, dimnames = list(letters[1:4], LETTERS[1:6]))
  x[c(2, 8, 17)] <- NA
  for (type in c("mean", "median", "zero")) {
    set.seed(7)
    y <- nmf_opt(x, c(1, 3), type)
    expect_true(all(is.finite(y)))
    expect_identical(y[!is.na(x)], x[!is.na(x)])
    expect_identical(dimnames(y), dimnames(x))
  }
  set.seed(7)
  fits <- lapply(c(1, 3), function(k) nmf_method(x, k, "mean"))
  observed <- !is.na(x)
  weights <- vapply(fits, function(f) exp(-2 * mean(abs(f$FIT[observed] -
    x[observed])) / max(x[observed])), numeric(1))
  expected <- (fits[[1]]$OUT * weights[1] + fits[[2]]$OUT * weights[2]) / sum(weights)
  set.seed(7)
  expect_equal(nmf_opt(x, c(1, 3), "mean"), expected)
  expect_error(nmf_opt(x, c(0, 2), "mean"), "kgroup")
  expect_error(nmf_opt(x, 1, "invalid"), "arg")
  x[1, ] <- NA
  expect_error(nmf_method(x, 1, "mean"), "entirely missing")
})

test_that("bundled Wong kNN matches original for ordinary inputs", {
  upstream <- new.env(parent = globalenv())
  sys.source(test_path("fixtures", "wong-knn.R"), envir = upstream)
  sys.source(test_path("fixtures", "wong-utils.R"), envir = upstream)
  set.seed(71)
  x <- matrix(runif(100), 20, 5)
  x[c(2, 9, 45, 63, 95)] <- NA
  expect_equal(wong_knn_impute(x, 3, verbose = FALSE),
               upstream$kNNImpute(x, 3, verbose = FALSE))
  d <- stats::dist(x)
  expect_equal(wong_knn_impute(x, 3, x.dist = d, verbose = FALSE),
               wong_knn_impute(x, 3, x.dist = as.matrix(d), verbose = FALSE))
})

test_that("Wong kNN handles sparse donors, equal distances, and complete data", {
  x <- rbind(c(1, NA), c(1, 4), c(1, 8))
  result <- wong_knn_impute(x, 2, verbose = FALSE)$x
  expect_equal(result[1, 2], 6)
  expect_identical(result[!is.na(x)], x[!is.na(x)])
  expect_identical(wong_knn_impute(result, 2)$x, result)
  x[3, 2] <- NA
  expect_equal(wong_knn_impute(x, 2, verbose = FALSE)$x[, 2], rep(4, 3))
  x[, 2] <- NA
  expect_equal(wong_knn_impute(x, 2, verbose = FALSE)$x[, 2], rep(0, 3))
  expect_error(wong_knn_impute(x, 3), "k must")
  expect_error(wong_knn_impute(x, 1, x.dist = matrix(1, 2, 2)), "x.dist")
  x <- rbind(c(1, NA), c(2, 4), c(3, 8))
  expect_equal(wong_knn_impute(x, 2, impute.fn = function(values, distances, k)
    mean(values), verbose = FALSE)$x[1, 2], 6)
})

test_that("public wrappers retain data frame shape and names", {
  x <- data.frame(a = c(2, 4, 8), b = c(NA, 8, 16), row.names = c("x", "y", "z"))
  names(x) <- c("feature one", "feature two")
  for (fun in list(impute_imputation_knn, impute_mnmf)) {
    set.seed(123)
    y <- fun(x)
    expect_s3_class(y, "data.frame")
    expect_identical(dimnames(y), dimnames(x))
    expect_true(all(is.finite(as.matrix(y))))
    expect_identical(as.matrix(y)[!is.na(x)], as.matrix(x)[!is.na(x)])
  }
})
test_that("NMF improves the KL objective on a noisy higher-rank matrix", {
  set.seed(9)
  x <- matrix(rexp(60), 10, 6)
  x[c(2, 11)] <- 0
  set.seed(11)
  early <- nmf(x, 2, max_iter = 2, tol = 0)
  set.seed(11)
  late <- nmf(x, 2, max_iter = 500, tol = 0)
  expect_lt(late$objective, early$objective)
  expect_true(all(is.finite(late$W %*% late$H)))
})
