#' Crayfish occurrence records from GBIF (demonstration sample)
#'
#' A fixed random sample of 5,000 crayfish occurrence records (families
#' Astacidae, Cambaridae, Cambaroididae and Parastacidae) drawn from a
#' GBIF occurrence download of 507,980 records, for use in examples,
#' tests and vignettes. To permit redistribution, the sample is drawn
#' only from records published under CC0 1.0 or CC BY 4.0; CC BY-NC
#' records are excluded. This is a demonstration dataset: do not use it
#' for ecological inference.
#'
#' @format A data frame with 5,000 rows and 10 variables:
#' \describe{
#'   \item{gbifID}{character; GBIF record identifier -- each record is
#'     inspectable at `https://gbif.org/occurrence/<gbifID>`}
#'   \item{species}{character; interpreted species name}
#'   \item{countryCode}{character; ISO 3166-1 alpha-2 country code}
#'   \item{decimalLatitude,decimalLongitude}{numeric; WGS84 coordinates}
#'   \item{coordinateUncertaintyInMeters}{numeric; reported positional
#'     uncertainty radius in metres, `NA` where unreported}
#'   \item{year}{integer; year of the collecting or observation event}
#'   \item{basisOfRecord}{character; Darwin Core basis of record}
#'   \item{datasetKey}{character; UUID of the publishing dataset}
#'   \item{license}{character; record licence (`"CC0_1_0"` or
#'     `"CC_BY_4_0"`)}
#' }
#' @source GBIF.org (03 August 2026) GBIF Occurrence Download
#'   \doi{10.15468/dl.99ezk2}. Per-record publishers are identified by
#'   `datasetKey`; the download DOI resolves to the full list of
#'   contributing datasets and their citations.
"crayfish"
