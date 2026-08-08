test_that("frozen dataset-level quantities on the bundled sample", {
  a <- ingrain(crayfish, grain = 1000)
  bd <- by_dataset(a)
  expect_identical(nrow(bd), 246L)
  expect_identical(sum(bd$n), 5000L)
  expect_equal(ingrain_u(a, B = 0)$u, 0.796878063386, tolerance = 1e-10)
})

