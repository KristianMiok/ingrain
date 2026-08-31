# Plot an ingrain audit as a single partition bar

Draws the four-state partition as one horizontal stacked bar, ordered
inert, marginal, actionable, unreported from left to right. The legend
carries the exact share of every state; segments wide enough to hold a
label repeat theirs in the bar.

## Usage

``` r
# S3 method for class 'ingrain_audit'
autoplot(object, ...)
```

## Arguments

- object:

  An `ingrain_audit` object from
  [`ingrain()`](https://kristianmiok.github.io/ingrain/reference/ingrain.md).

- ...:

  Ignored.

## Value

A ggplot object.

## Examples

``` r
a <- ingrain(crayfish, grain = 1000)
autoplot(a)
```
