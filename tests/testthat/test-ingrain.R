test_that("three states classify correctly, boundary is strict", {
  occ <- data.frame(
    coordinateUncertaintyInMeters = c(10, 999, 1000, 1001, NA, 0)
  )
  a <- ingrain(occ, grain = 1000)
  expect_s3_class(a, "ingrain_audit")
  expect_equal(
    as.character(a$.state),
    c("inert", "inert", "usable", "usable", "unreported", "inert")
  )
  expect_identical(attr(a, "grain"), 1000)
})

test_that("summary counts every record and shares sum to one", {
  occ <- data.frame(coordinateUncertaintyInMeters = c(1, 5000, NA, NA, 2))
  s <- summary(ingrain(occ, grain = 100))
  expect_equal(sum(s$n), nrow(occ))
  expect_equal(sum(s$share), 1)
  expect_equal(s$n, c(2L, 1L, 2L))
})

test_that("NaN is unreported; negative and infinite radii error", {
  a <- ingrain(data.frame(coordinateUncertaintyInMeters = NaN), grain = 1000)
  expect_equal(as.character(a$.state), "unreported")
  expect_error(
    ingrain(data.frame(coordinateUncertaintyInMeters = -1), grain = 1000),
    "negative or infinite"
  )
  expect_error(
    ingrain(data.frame(coordinateUncertaintyInMeters = Inf), grain = 1000),
    "negative or infinite"
  )
})

test_that("input validation catches bad grain, missing column, collisions", {
  occ <- data.frame(coordinateUncertaintyInMeters = 1:3)
  expect_error(ingrain(occ, grain = 0), "positive")
  expect_error(ingrain(occ, grain = c(100, 1000)), "single")
  expect_error(ingrain(occ, grain = 100, uncertainty = "nope"), "not found")
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
