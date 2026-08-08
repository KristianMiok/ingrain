# ingrain

[![R-CMD-check](https://github.com/KristianMiok/ingrain/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/KristianMiok/ingrain/actions/workflows/R-CMD-check.yaml)

Which of your occurrence records can a positional-uncertainty correction
actually touch -- at *your* analysis resolution?

Filters and corrections for coordinate uncertainty act only on some
records, and which ones depends on the grain of the intended analysis.
`ingrain` classifies every record in an occurrence table into four
states relative to a chosen raster cell edge length *R*, before any
model is fitted:

* **inert** (*r* ≤ *R*/2) -- the uncertainty disc fits within a cell;
  corrections cannot act.
* **marginal** (*R*/2 < *r* ≤ 3*R*) -- the boundary band.
* **actionable** (*r* > 3*R*) -- corrections have room to act, and the
  choice among them has consequences.
* **unreported** (*r* is `NA`) -- no correction can act, and the radius
  cannot be recovered from the coordinates.

`ingrain` audits; it deliberately does not clean. Run it after standard
coordinate cleaning (e.g. CoordinateCleaner, bdc) and before modelling.

## Installation

```r
# install.packages("remotes")
remotes::install_github("KristianMiok/ingrain")
```

## Quick start

```r
library(ingrain)

a <- ingrain(crayfish, grain = 1000)
a
autoplot(a)
```

![](man/figures/README-bar.png)

```r
p <- ingrain_profile(crayfish, mark = 1000)
autoplot(p)
```

![](man/figures/README-profile.png)

The grey band is flat by construction: it is the share of the data that
no choice of resolution can touch. The steps in the coloured bands are
real, not artefacts -- reported radii cluster at publisher conventions
(301 m, 1 km, 5 km, ...), and the classification thresholds cross those
mass points as the grain sweeps.

## Bundled data

`crayfish` is a fixed random sample of 5,000 crayfish occurrence
records, drawn from the 507,980-record GBIF occurrence download
[doi:10.15468/dl.99ezk2](https://doi.org/10.15468/dl.99ezk2) and
restricted to CC0/CC BY records to permit redistribution. It exists to
demonstrate the package mechanics; do not use it for ecological
inference.

## Status

Under active development towards a software paper; the API may change
until v0.1.0.
