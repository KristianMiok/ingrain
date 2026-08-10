# Partition of occurrence records across a sweep of analysis grains

Computes the four-state partition of
[`ingrain()`](https://kristianmiok.github.io/ingrain/reference/ingrain.md)
at every grain in a sweep, showing how the split between `inert`,
`marginal`, `actionable` and `unreported` records shifts with the
resolution of the intended analysis. The `unreported` share is constant
across the sweep: it is the portion of the data that no choice of
resolution can touch.

## Usage

``` r
ingrain_profile(
  occ,
  grains = 10^seq(1, 5, length.out = 61),
  mark = NULL,
  uncertainty = "coordinateUncertaintyInMeters"
)
```

## Arguments

- occ:

  A data.frame of occurrence records, e.g. a GBIF download.

- grains:

  Numeric vector of at least two candidate grains (raster cell edge
  lengths, in metres). Defaults to 61 log-spaced values from 10 m to 100
  km.

- mark:

  Optional single grain (metres) to highlight: it is added to the sweep
  and
  [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  draws a reference line there, with the exact shares at that grain in
  the subtitle.

- uncertainty:

  Name of the column holding the positional uncertainty radius in
  metres.

## Value

A data.frame with columns `grain`, `state`, `n` and `share`, of class
`"ingrain_profile"`, with the record count and any `mark` stored as
attributes.

## See also

[`ingrain()`](https://kristianmiok.github.io/ingrain/reference/ingrain.md)
for the audit at a single grain.

## Examples

``` r
p <- ingrain_profile(crayfish, mark = 1000)
p
#> -- ingrain profile -- 5,000 records, 61 grains from 10 m to 100 km --
#>   at 1 km: inert 53.0% | marginal 2.5% | actionable 15.4% | unreported 29.0%
autoplot(p)
```
