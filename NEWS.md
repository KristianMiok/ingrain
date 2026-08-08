# ingrain 0.0.0.9000

* Core classifier `ingrain()`: four-state resolution-relative partition
  (inert / marginal / actionable / unreported), boundary-exact to the
  cumulative-threshold construction used in the analysis pipeline, with
  `print()` and `summary()` methods.
* `ingrain_profile()`: the partition across a sweep of grains, with an
  optional marked grain, sharing one internal classifier with `ingrain()`
  so the two views cannot diverge.
* `by_dataset()`: the partition per publishing dataset, with a
  diagnostic share of GBIF-documented geocoder default radii.
* `ingrain_u()`: uncertainty coefficient (Theil's U) of the state given
  the dataset, with a label-permutation null; collapses exactly to the
  binary estimator used in the analyses behind the package.
* Vignette "From a GBIF download to a defensible dataset": the full
  audit workflow on the bundled sample, with guidance per state.
* Bundled `crayfish` demonstration sample: 5,000 CC0/CC-BY records drawn
  with a fixed seed from GBIF occurrence download 10.15468/dl.99ezk2,
  frozen by regression tests.
* Visual layer: partition-bar, profile and per-dataset `autoplot()`
  methods, `theme_ingrain()`, and the colour-vision-safe
  `ingrain_palette()`.
