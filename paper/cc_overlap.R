## ingrain paper, Section 3.4
## Overlap between the four-state audit and coordinate-cleaning flags.
## Pre-registered kill criterion: if CoordinateCleaner flags more than 50% of
## the actionable records, the orthogonality claim fails and 3.4 is dropped.

suppressPackageStartupMessages(library(CoordinateCleaner))

outdir <- path.expand("~/ingrain_paper")
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

## ---- load the bundled sample -------------------------------------------

d <- NULL
if (requireNamespace("ingrain", quietly = TRUE)) {
  items <- data(package = "ingrain")$results[, "Item"]
  items <- sub("\\s.*$", "", items)
  if (length(items)) {
    e <- new.env()
    utils::data(list = items[1], package = "ingrain", envir = e)
    d <- as.data.frame(get(items[1], envir = e))
    cat("loaded from installed package: ", items[1], "\n", sep = "")
  }
}
if (is.null(d)) {
  rda <- list.files(".", pattern = "\\.(rda|RData)$", recursive = TRUE,
                    full.names = TRUE)
  rda <- grep("/data/", rda, value = TRUE)
  if (!length(rda)) stop("ingrain not installed and no data/*.rda found under ", getwd())
  e <- new.env(); load(rda[1], envir = e)
  d <- as.data.frame(get(ls(e)[1], envir = e))
  cat("loaded from file: ", rda[1], "\n", sep = "")
}

cat("n = ", nrow(d), "\n", sep = "")
cat("columns: ", paste(names(d), collapse = ", "), "\n\n", sep = "")

## ---- locate the columns we need ----------------------------------------

pick <- function(cands, pattern, what) {
  hit <- cands[cands %in% names(d)]
  if (length(hit)) return(hit[1])
  hit <- grep(pattern, names(d), ignore.case = TRUE, value = TRUE)
  if (length(hit)) return(hit[1])
  stop("could not find a ", what, " column")
}

unc_col <- pick("coordinateUncertaintyInMeters", "uncertain", "radius")
lon_col <- pick(c("decimalLongitude", "lon", "longitude"), "^lon|longitude", "longitude")
lat_col <- pick(c("decimalLatitude", "lat", "latitude"), "^lat|latitude", "latitude")
sp_col  <- pick(c("species", "scientificName", "acceptedScientificName"),
                "species|scientificname", "species")
cat("using: radius = ", unc_col, " | lon = ", lon_col,
    " | lat = ", lat_col, " | species = ", sp_col, "\n\n", sep = "")

## ---- four-state partition, computed from the definitions ----------------

R <- 1000
r <- d[[unc_col]]
d$state <- ifelse(is.na(r), "unreported",
           ifelse(r <= R / 2, "inert",
           ifelse(r <= 3 * R, "marginal", "actionable")))
d$state <- factor(d$state, levels = c("inert", "marginal", "actionable", "unreported"))
print(table(d$state))

expected <- c(inert = 2652L, marginal = 126L, actionable = 772L, unreported = 1450L)
observed <- as.integer(table(d$state))
if (identical(observed, unname(expected))) {
  cat("\npartition matches the manuscript\n\n")
} else {
  cat("\nWARNING: partition differs from the manuscript\n")
  cat("expected: ", paste(expected, collapse = " / "), "\n", sep = "")
  cat("observed: ", paste(observed, collapse = " / "), "\n\n", sep = "")
}

## ---- CoordinateCleaner --------------------------------------------------

tests_full <- c("capitals", "centroids", "equal", "gbif",
                "institutions", "outliers", "seas", "zeros")
run_cc <- function(tests) {
  clean_coordinates(x = d, lon = lon_col, lat = lat_col, species = sp_col,
                    tests = tests, value = "spatialvalid", verbose = FALSE)
}
cc <- tryCatch(run_cc(tests_full), error = function(err) {
  cat("full test set failed (", conditionMessage(err),
      "); retrying without 'seas' and 'outliers'\n", sep = "")
  run_cc(setdiff(tests_full, c("seas", "outliers")))
})

flag_cols <- setdiff(grep("^\\.", names(cc), value = TRUE), ".summary")
d$cc_flag <- !cc$.summary

cat("CoordinateCleaner flags (any test): ", sum(d$cc_flag), " of ", nrow(d), "\n\n", sep = "")
cat("Counts by state:\n")
print(table(state = d$state, cc_flag = d$cc_flag))
cat("\nFlag rate by state (%):\n")
print(round(100 * prop.table(table(d$state, d$cc_flag), 1), 1))
cat("\nPer-test flag counts by state:\n")
per_test <- sapply(flag_cols, function(cn) tapply(!cc[[cn]], d$state, sum))
print(t(per_test))

act_rate <- mean(d$cc_flag[d$state == "actionable"])
cat(sprintf("\nActionable records flagged by CC: %.1f%%   (kill criterion: > 50%%)\n",
            100 * act_rate))
cat(if (act_rate > 0.5) "KILL CRITERION TRIGGERED: drop Section 3.4\n"
    else "orthogonality claim survives\n")

## ---- bdc precision test (optional) --------------------------------------

if (requireNamespace("bdc", quietly = TRUE)) {
  bp <- try(bdc::bdc_coordinates_precision(data = d, lon = lon_col,
                                           lat = lat_col, ndec = 2), silent = TRUE)
  if (!inherits(bp, "try-error")) {
    d$bdc_lowprec <- !bp$.rou
    cat("\nbdc_coordinates_precision (fewer than 2 decimals), by state:\n")
    print(table(state = d$state, low_precision = d$bdc_lowprec))
  } else {
    cat("\nbdc precision test errored, skipping\n")
  }
} else {
  cat("\nbdc not loadable (duckdb missing?), skipping precision test\n")
}

saveRDS(d, file.path(outdir, "cc_overlap.rds"))
cat("\nsaved ", file.path(outdir, "cc_overlap.rds"), "\n", sep = "")
