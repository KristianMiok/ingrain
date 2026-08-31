# Plot an ingrain profile as stacked shares across grains

The signature figure of the package: shares of the four states as a
function of analysis grain, on a log axis. The `unreported` band is flat
by construction – the portion of the data no resolution can touch. If
the profile carries a `mark`, a reference line is drawn at that grain
and the exact shares there appear in the subtitle.

## Usage

``` r
# S3 method for class 'ingrain_profile'
autoplot(object, ...)
```

## Arguments

- object:

  An `ingrain_profile` object from
  [`ingrain_profile()`](https://kristianmiok.github.io/ingrain/reference/ingrain_profile.md).

- ...:

  Ignored.

## Value

A ggplot object.

## Examples

``` r
autoplot(ingrain_profile(crayfish, mark = 1000))
```
