# Minimal theme for ingrain figures

Minimal theme for ingrain figures

## Usage

``` r
theme_ingrain(base_size = 12)
```

## Arguments

- base_size:

  Base font size in points.

## Value

A ggplot2 theme object.

## Examples

``` r
a <- ingrain(crayfish, grain = 1000)
autoplot(a) + theme_ingrain(base_size = 11)
```
