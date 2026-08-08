# ingrain 0.0.0.9000

* Core classifier `ingrain()`: four-state resolution-relative partition
  (inert / marginal / actionable / unreported), boundary-exact to the
  cumulative-threshold construction used in the analysis pipeline, with
  `print()` and `summary()` methods.
* Bundled `crayfish` demonstration sample: 5,000 CC0/CC-BY records drawn
  with a fixed seed from GBIF occurrence download 10.15468/dl.99ezk2,
  frozen by regression tests.
* First visual layer: `autoplot()` and `plot()` partition bar,
  `theme_ingrain()`, and the colour-vision-safe `ingrain_palette()`.
