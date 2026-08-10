# Partition of an ingrain audit by publishing dataset

Aggregates the four-state partition of
[`ingrain()`](https://kristianmiok.github.io/ingrain/reference/ingrain.md)
per dataset, returning one row per dataset with its record count and the
share of records in each state. The column `default_radius` reports the
share of records whose radius is one of the four GBIF-documented
geocoder default values (301, 999, 3036, 9999 m); these records keep
their ordinary state in the partition, and the column exists as a
diagnostic.

## Usage

``` r
by_dataset(object, dataset = "datasetKey", min_n = 1L)
```

## Arguments

- object:

  An `ingrain_audit` object from
  [`ingrain()`](https://kristianmiok.github.io/ingrain/reference/ingrain.md).

- dataset:

  Name of the column identifying the publishing dataset. Defaults to the
  Darwin Core term `"datasetKey"`.

- min_n:

  Drop datasets with fewer than `min_n` records. Defaults to 1 (keep
  all); shares of very small datasets are unstable.

## Value

A data.frame of class `"ingrain_datasets"`, sorted by record count, with
columns `dataset`, `n`, `inert`, `marginal`, `actionable`, `unreported`
and `default_radius`. The grain, the total record and dataset counts and
`min_n` are stored as attributes.

## See also

[`ingrain_u()`](https://kristianmiok.github.io/ingrain/reference/ingrain_u.md)
for how much the dataset determines the state.

## Examples

``` r
a <- ingrain(crayfish, grain = 1000)
by_dataset(a)
#> -- ingrain datasets -- 246 of 246 datasets (min_n = 1), grain 1 km --
#> dataset               n   inert  marginal  actionable  unreported
#> 724ec4af-c...     1,410   85.5%      0.0%       14.5%        0.0%
#> 821cc27a-e...       248    0.0%      0.0%        0.0%      100.0%
#> 0b5f972e-0...       239  100.0%      0.0%        0.0%        0.0%
#> 1ad3c2b1-0...       202    0.0%      0.0%        0.0%      100.0%
#> 10e5d19e-4...       194    0.0%      0.0%        0.0%      100.0%
#> 9e932f70-0...       188  100.0%      0.0%        0.0%        0.0%
#> 96cdea48-b...       187    0.0%      0.0%        0.0%      100.0%
#> d6cc311c-c...       126    0.0%      0.0%        0.0%      100.0%
#> db1abc39-7...       121   96.7%      3.3%        0.0%        0.0%
#> 37beb6ea-e...       116   95.7%      4.3%        0.0%        0.0%
#>   ... and 236 more datasets
```
