# Plot the per-dataset partition as stacked bars

One horizontal stacked bar per dataset, largest datasets on top, showing
how the four-state partition differs across publishers. Rows sitting
almost entirely in one colour are datasets in a pure regime.

## Usage

``` r
# S3 method for class 'ingrain_datasets'
autoplot(object, max_datasets = 25, ...)
```

## Arguments

- object:

  An `ingrain_datasets` object from
  [`by_dataset()`](https://kristianmiok.github.io/ingrain/reference/by_dataset.md).

- max_datasets:

  Show at most this many datasets, taken from the top of the
  (size-sorted) table.

- ...:

  Ignored.

## Value

A ggplot object.

## Examples

``` r
autoplot(by_dataset(ingrain(crayfish, grain = 1000)))
```
