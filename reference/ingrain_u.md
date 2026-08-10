# How much does the dataset determine the state of a record?

Computes the uncertainty coefficient (Theil's U) of the four-state
partition given the publishing dataset, \$\$U = 1 - H(state \| dataset)
/ H(state),\$\$ with plug-in entropies in bits: `U = 0` means the
dataset tells you nothing about a record's state, `U = 1` that it
determines it completely. Because a plug-in U is inflated by having many
groups, it is compared against a permutation null in which state labels
are reshuffled across records, holding dataset sizes and the overall
state counts fixed; the quantity to interpret is the excess of U over
the null mean. With states collapsed to two classes this estimator and
its null reduce exactly to the binary uncertainty-coefficient
construction used in the analyses behind the package; there, the two
classes were `actionable` versus all other states pooled, computed over
datasets with at least 500 records.

## Usage

``` r
ingrain_u(object, dataset = "datasetKey", B = 200, seed = NULL, min_n = 1L)
```

## Arguments

- object:

  An `ingrain_audit` object from
  [`ingrain()`](https://kristianmiok.github.io/ingrain/reference/ingrain.md).

- dataset:

  Name of the column identifying the publishing dataset.

- B:

  Number of permutations for the null. `B = 0` skips the null and
  returns only `u`.

- seed:

  Optional integer seed for the permutation null; the caller's
  random-number state is restored afterwards.

- min_n:

  Drop datasets with fewer than `min_n` records (their records are
  excluded from the computation entirely).

## Value

An object of class `"ingrain_u"`: a list with elements `u`, `null`
(vector of length `B`), `u_null` (null mean), `sd_null`, `excess`, `p`
(permutation p-value), `B`, `n_records`, `n_datasets`.

## Examples

``` r
a <- ingrain(crayfish, grain = 1000)
ingrain_u(a, B = 50, seed = 1)
#> -- ingrain U -- how much the dataset determines the state --
#>   U = 0.797   (0 = dataset tells you nothing, 1 = everything)
#>   permutation null (B = 50): mean 0.059 (sd 0.002)
#>   excess over null = 0.738   p = 0.0196
#>   5,000 records across 246 datasets
```
