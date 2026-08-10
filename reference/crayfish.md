# Crayfish occurrence records from GBIF (demonstration sample)

A fixed random sample of 5,000 crayfish occurrence records (families
Astacidae, Cambaridae, Cambaroididae and Parastacidae) drawn from a GBIF
occurrence download of 507,980 records, for use in examples, tests and
vignettes. To permit redistribution, the sample is drawn only from
records published under CC0 1.0 or CC BY 4.0; CC BY-NC records are
excluded. This is a demonstration dataset: do not use it for ecological
inference.

## Usage

``` r
crayfish
```

## Format

A data frame with 5,000 rows and 10 variables:

- gbifID:

  character; GBIF record identifier – each record is inspectable at
  `https://gbif.org/occurrence/<gbifID>`

- species:

  character; interpreted species name

- countryCode:

  character; ISO 3166-1 alpha-2 country code

- decimalLatitude,decimalLongitude:

  numeric; WGS84 coordinates

- coordinateUncertaintyInMeters:

  numeric; reported positional uncertainty radius in metres, `NA` where
  unreported

- year:

  integer; year of the collecting or observation event

- basisOfRecord:

  character; Darwin Core basis of record

- datasetKey:

  character; UUID of the publishing dataset

- license:

  character; record licence (`"CC0_1_0"` or `"CC_BY_4_0"`)

## Source

GBIF.org (03 August 2026) GBIF Occurrence Download
[doi:10.15468/dl.99ezk2](https://doi.org/10.15468/dl.99ezk2) .
Per-record publishers are identified by `datasetKey`; the download DOI
resolves to the full list of contributing datasets and their citations.

## Details

Record licences are assigned by the publishing dataset, so the licence
filter used to build this sample is, in effect, a publisher filter.
Because the partition of records across states is itself a publisher
property, shares computed on this sample differ from shares computed on
the unfiltered download (the sample has, for instance, a higher inert
share at a 1 km grain). The bundled data exist to demonstrate the
package mechanics on real records, not to reproduce any published
quantity.
