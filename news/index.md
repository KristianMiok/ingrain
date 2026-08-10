# Changelog

## ingrain 0.1.0.9000

- The bundled `crayfish` sample is registered as GBIF derived dataset
  <doi:10.15468/dd.d9xgfc>, crediting all 246 contributing datasets;
  per-dataset counts in `data-raw/crayfish_derived_dataset_counts.csv`.

## ingrain 0.1.0

First complete release.

- [`ingrain()`](https://kristianmiok.github.io/ingrain/reference/ingrain.md):
  four-state resolution-relative partition of occurrence records (inert
  / marginal / actionable / unreported), boundary-exact to the
  cumulative-threshold construction used in the analysis pipeline, with
  [`print()`](https://rdrr.io/r/base/print.html) and
  [`summary()`](https://rdrr.io/r/base/summary.html) methods.
- [`ingrain_profile()`](https://kristianmiok.github.io/ingrain/reference/ingrain_profile.md):
  the partition across a sweep of analysis grains, with an optional
  marked grain, sharing one internal classifier with
  [`ingrain()`](https://kristianmiok.github.io/ingrain/reference/ingrain.md)
  so the two views cannot diverge.
- [`by_dataset()`](https://kristianmiok.github.io/ingrain/reference/by_dataset.md):
  the partition per publishing dataset, with a diagnostic share of
  GBIF-documented geocoder default radii.
- [`ingrain_u()`](https://kristianmiok.github.io/ingrain/reference/ingrain_u.md):
  uncertainty coefficient (Theil’s U) of the state given the dataset,
  with a label-permutation null; collapses exactly to the binary
  estimator used in the analyses behind the package.
- Vignette “From a GBIF download to a defensible dataset”: the full
  audit workflow, with guidance per state.
- Bundled `crayfish` demonstration sample: 5,000 CC0/CC-BY records drawn
  with a fixed seed from GBIF occurrence download 10.15468/dl.99ezk2,
  frozen by regression tests.
- Visual identity: partition-bar, profile and per-dataset
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  methods,
  [`theme_ingrain()`](https://kristianmiok.github.io/ingrain/reference/theme_ingrain.md),
  the colour-vision-safe
  [`ingrain_palette()`](https://kristianmiok.github.io/ingrain/reference/ingrain_palette.md),
  hex logo, and the pkgdown site at
  <https://kristianmiok.github.io/ingrain>.
