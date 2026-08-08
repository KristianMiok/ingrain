test_that("bundled crayfish sample is frozen: shape, licences, identifiers", {
  expect_identical(dim(crayfish), c(5000L, 10L))
  expect_identical(
    names(crayfish),
    c("gbifID", "species", "countryCode", "decimalLatitude",
      "decimalLongitude", "coordinateUncertaintyInMeters", "year",
      "basisOfRecord", "datasetKey", "license"))
  expect_identical(anyDuplicated(crayfish$gbifID), 0L)
  expect_true(all(crayfish$license %in% c("CC0_1_0", "CC_BY_4_0")))
  expect_identical(length(unique(crayfish$datasetKey)), 246L)
  r <- crayfish$coordinateUncertaintyInMeters
  expect_true(all(is.na(r) | (is.finite(r) & r >= 0)))
})

test_that("frozen partition of the sample at a 1 km grain", {
  a <- ingrain(crayfish, grain = 1000)
  expect_identical(as.vector(table(a$.state)),
                   c(2652L, 126L, 772L, 1450L))
  expect_identical(sum(is.na(crayfish$coordinateUncertaintyInMeters)), 1450L)
})

test_that("autoplot and plot methods return usable objects", {
  a <- ingrain(crayfish, grain = 1000)
  p <- autoplot(a)
  expect_s3_class(p, "ggplot")
  expect_invisible(plot(a))
})
