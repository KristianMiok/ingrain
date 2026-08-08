test_that("four states classify correctly; boundaries are inclusive from below", {
  occ <- data.frame(coordinateUncertaintyInMeters =
    c(0, 499, 500, 500.0001, 501, 2999, 3000, 3000.5, 3001, NA, NaN))
  a <- ingrain(occ, grain = 1000)
  expect_s3_class(a, "ingrain_audit")
  expect_equal(
    as.character(a$.state),
    c("inert", "inert", "inert", "marginal", "marginal", "marginal",
      "marginal", "actionable", "actionable", "unreported", "unreported")
  )
  expect_identical(attr(a, "grain"), 1000)
})

test_that("classifier is bit-for-bit with the cumulative-threshold construction", {
  set.seed(42)
  r <- c(sample(0:10000, 500, replace = TRUE), rep(NA_real_, 60))
  occ <- data.frame(coordinateUncertaintyInMeters = as.numeric(r))
  grain <- 1000
  a <- ingrain(occ, grain = grain)
  cum <- function(u) sum(!is.na(r) & r <= u)
  n_rep <- sum(!is.na(r))
  expect_equal(
    as.vector(table(a$.state)),
    c(cum(grain / 2),
      cum(3 * grain) - cum(grain / 2),
      n_rep - cum(3 * grain),
      sum(is.na(r)))
  )
})

test_that("summary counts every record and shares sum to one", {
  occ <- data.frame(coordinateUncertaintyInMeters = c(1, 600, 5000, NA, 400))
  s <- summary(ingrain(occ, grain = 1000))
  expect_equal(sum(s$n), nrow(occ))
  expect_equal(sum(s$share), 1)
  expect_equal(s$n, c(2L, 1L, 1L, 1L))
})

test_that("input validation catches bad radii, bad grain, missing column, collisions", {
  occ <- data.frame(coordinateUncertaintyInMeters = 1:3)
  expect_error(ingrain(occ, grain = 0), "positive")
  expect_error(ingrain(occ, grain = c(100, 1000)), "single")
  expect_error(ingrain(occ, grain = 100, uncertainty = "nope"), "not found")
  expect_error(
    ingrain(data.frame(coordinateUncertaintyInMeters = -1), grain = 1000),
    "negative or infinite"
  )
  expect_error(
    ingrain(data.frame(coordinateUncertaintyInMeters = Inf), grain = 1000),
    "negative or infinite"
  )
  expect_error(
    ingrain(data.frame(coordinateUncertaintyInMeters = 1, .state = "x"),
            grain = 100),
    ".state"
  )
  expect_error(
    ingrain(data.frame(coordinateUncertaintyInMeters = "a"), grain = 100),
    "numeric"
  )
})
