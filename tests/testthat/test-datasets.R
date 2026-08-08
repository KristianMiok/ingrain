test_that("by_dataset aggregates states and flags default radii correctly", {
  occ <- data.frame(
    coordinateUncertaintyInMeters = c(10, 5000, NA, 400, 301, 9999),
    datasetKey = c("A", "A", "A", "B", "B", "B"))
  bd <- by_dataset(ingrain(occ, grain = 1000))
  expect_s3_class(bd, "ingrain_datasets")
  expect_identical(bd$dataset, c("A", "B"))
  states <- c("inert", "marginal", "actionable", "unreported")
  expect_true(all(abs(rowSums(bd[, states]) - 1) < 1e-12))
  expect_equal(bd$inert, c(1/3, 2/3))
  expect_equal(bd$actionable, c(1/3, 1/3))
  expect_equal(bd$unreported, c(1/3, 0))
  expect_equal(bd$default_radius, c(0, 2/3))
  expect_identical(nrow(by_dataset(ingrain(occ, grain = 1000), min_n = 4)),
                   0L)
})

test_that("four-state U reduces exactly to the binary analysis estimator", {
  H8 <- function(p) {
    p <- pmin(pmax(p, 0), 1)
    ifelse(p == 0 | p == 1, 0, -(p * log2(p) + (1 - p) * log2(1 - p)))
  }
  uc8 <- function(n, k) {
    N <- sum(n); p <- sum(k) / N
    hy <- H8(p)
    if (hy <= 0) return(NA_real_)
    1 - sum((n / N) * H8(k / n)) / hy
  }
  set.seed(7)
  n <- sample(5:200, 40, replace = TRUE)
  k <- rbinom(40, n, stats::runif(40))
  groups <- rep(seq_along(n), n)
  states <- unlist(mapply(function(ni, ki)
    c(rep("a", ki), rep("b", ni - ki)), n, k, SIMPLIFY = FALSE))
  expect_equal(ingrain:::uncertainty_coefficient(groups, factor(states)),
               uc8(n, k))
  flipped <- factor(ifelse(states == "a", "b", "a"))
  expect_equal(ingrain:::uncertainty_coefficient(groups, factor(states)),
               ingrain:::uncertainty_coefficient(groups, flipped))
})

test_that("ingrain_u returns a coherent object and respects seed and B", {
  a <- ingrain(crayfish, grain = 1000)
  u1 <- ingrain_u(a, B = 25, seed = 11)
  u2 <- ingrain_u(a, B = 25, seed = 11)
  expect_identical(u1$null, u2$null)
  expect_identical(length(u1$null), 25L)
  expect_true(u1$u >= 0 && u1$u <= 1)
  expect_true(all(u1$null >= 0 & u1$null <= 1))
  u0 <- ingrain_u(a, B = 0)
  expect_identical(u0$B, 0L)
  expect_true(is.na(u0$u_null) && is.na(u0$excess) && is.na(u0$p))
  expect_error(ingrain_u(a, min_n = 1e6), "No records left")
})

test_that("per-dataset autoplot returns a ggplot", {
  bd <- by_dataset(ingrain(crayfish, grain = 1000))
  expect_s3_class(ggplot2::autoplot(bd, max_datasets = 10), "ggplot")
})
