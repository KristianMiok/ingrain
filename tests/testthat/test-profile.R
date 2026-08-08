test_that("profile shares sum to one at every grain; unreported is flat", {
  p <- ingrain_profile(crayfish, grains = 10^seq(1, 5, length.out = 21))
  tot <- tapply(p$share, p$grain, sum)
  expect_true(all(abs(tot - 1) < 1e-12))
  unrep <- p$share[p$state == "unreported"]
  expect_true(all(unrep == unrep[1]))
  expect_identical(sum(p$n[p$state == "unreported"] / length(unique(p$grain))),
                   1450)
})

test_that("profile is bit-for-bit with ingrain() at matching grains", {
  gs <- c(100, 1000, 25000)
  p <- ingrain_profile(crayfish, grains = gs)
  for (g in gs) {
    a <- table(ingrain(crayfish, grain = g)$.state)
    expect_identical(p$n[p$grain == g], as.vector(a))
  }
})

test_that("inert grows and actionable shrinks with coarser grain", {
  p <- ingrain_profile(crayfish, grains = 10^seq(1, 5, length.out = 21))
  inert <- p$share[p$state == "inert"][order(unique(p$grain))]
  act   <- p$share[p$state == "actionable"][order(unique(p$grain))]
  expect_true(all(diff(inert) >= 0))
  expect_true(all(diff(act) <= 0))
})

test_that("mark joins the sweep and is stored; bad inputs error", {
  p <- ingrain_profile(crayfish, grains = c(100, 10000), mark = 777)
  expect_identical(attr(p, "mark"), 777)
  expect_true(777 %in% p$grain)
  expect_error(ingrain_profile(crayfish, grains = 100), "at least two")
  expect_error(ingrain_profile(crayfish, grains = c(-1, 100)), "positive")
})
