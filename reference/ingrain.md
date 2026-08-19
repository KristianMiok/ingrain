# Classify occurrence records by positional uncertainty relative to an analysis grain

`ingrain()` partitions occurrence records into four states relative to a
chosen analysis grain \\R\\ (the cell edge length of the intended
raster, in metres), based on the reported positional uncertainty radius
\\r\\:

## Usage

``` r
ingrain(occ, grain, uncertainty = "coordinateUncertaintyInMeters")
```

## Arguments

- occ:

  A data.frame of occurrence records, e.g. a GBIF download.

- grain:

  Numeric scalar. Cell edge length of the intended analysis raster, in
  metres.

- uncertainty:

  Name of the column holding the positional uncertainty radius in
  metres. Defaults to the Darwin Core term
  `"coordinateUncertaintyInMeters"`.

## Value

`occ` with an added factor column `.state` (levels `"inert"`,
`"marginal"`, `"actionable"`, `"unreported"`), returned with class
`"ingrain_audit"`. The grain and the name of the uncertainty column are
stored as attributes. [`print()`](https://rdrr.io/r/base/print.html)
shows the four-state summary rather than the full data; use
[`summary()`](https://rdrr.io/r/base/summary.html) for the counts as a
data.frame.

## Details

- `"inert"` – \\r \le R/2\\. The uncertainty disc's diameter does not
  exceed one cell edge, so an uncertainty-aware correction cannot
  meaningfully act: the covariate is effectively constant over the
  region the record could occupy.

- `"marginal"` – \\R/2 \< r \le 3R\\. The boundary band, where whether
  the positional error matters depends on where the record falls
  relative to cell boundaries and on local covariate variation.

- `"actionable"` – \\r \> 3R\\. The uncertainty region spans many cells;
  corrections (threshold filtering, near-geographic and
  near-environmental point methods, change of support) have room to act,
  and the choice among them has consequences.

- `"unreported"` – \\r\\ is `NA`. No correction can act, and the radius
  cannot be recovered from the coordinates themselves.

Boundary handling is inclusive from below and mirrors, bit for bit, the
cumulative-threshold construction used to compute the published
partition (counts of records with \\r \le u\\ at \\u = R/2\\ and \\u =
3R\\, then differences): a radius exactly at \\R/2\\ is `inert`, and
exactly at \\3R\\ is `marginal`. `NaN` counts as `NA`.

The `"inert"` state operationalises an observation made in passing by
Hefley et al. (2017): a change-of-support correction cannot act where
the covariate is constant within a raster cell.

Negative or infinite radii raise an error; such values are data defects
and should be screened upstream (e.g. with CoordinateCleaner or bdc).
`ingrain()` deliberately performs no cleaning: it classifies what a
correction or filter could do to your data at your resolution.

## References

Hefley, T.J., Brost, B.M. & Hooten, M.B. (2017) Bias correction of
bounded location errors in presence-only data. *Methods in Ecology and
Evolution*, 8, 1566–1573.
[doi:10.1111/2041-210X.12793](https://doi.org/10.1111/2041-210X.12793)

## See also

[`ingrain_profile()`](https://anonymous.github.io/ingrain/reference/ingrain_profile.md)
for the partition across a sweep of grains.

## Examples

``` r
a <- ingrain(crayfish, grain = 1000)
a
#> -- ingrain audit -- 5,000 records, grain 1,000 m --
#>   inert        53.0%  (n = 2,652)
#>   marginal      2.5%  (n = 126)
#>   actionable   15.4%  (n = 772)
#>   unreported   29.0%  (n = 1,450)
summary(a)
#>        state    n  share
#> 1      inert 2652 0.5304
#> 2   marginal  126 0.0252
#> 3 actionable  772 0.1544
#> 4 unreported 1450 0.2900
```
