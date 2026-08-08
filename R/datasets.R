entropy_bits <- function(p) {
  p <- p[p > 0]
  -sum(p * log2(p))
}

uncertainty_coefficient <- function(groups, states) {
  N <- length(states)
  tab <- table(groups, states)
  ng <- rowSums(tab)
  hy <- entropy_bits(colSums(tab) / N)
  if (hy <= 0) return(NA_real_)
  hrow <- apply(tab, 1, function(k) entropy_bits(k / sum(k)))
  1 - sum((ng / N) * hrow) / hy
}

#' Partition of an ingrain audit by publishing dataset
#'
#' Aggregates the four-state partition of [ingrain()] per dataset,
#' returning one row per dataset with its record count and the share of
#' records in each state. The column `default_radius` reports the share
#' of records whose radius is one of the four GBIF-documented geocoder
#' default values (301, 999, 3036, 9999 m); these records keep their
#' ordinary state in the partition, and the column exists as a
#' diagnostic.
#'
#' @param object An `ingrain_audit` object from [ingrain()].
#' @param dataset Name of the column identifying the publishing dataset.
#'   Defaults to the Darwin Core term `"datasetKey"`.
#' @param min_n Drop datasets with fewer than `min_n` records. Defaults
#'   to 1 (keep all); shares of very small datasets are unstable.
#'
#' @return A data.frame of class `"ingrain_datasets"`, sorted by record
#'   count, with columns `dataset`, `n`, `inert`, `marginal`,
#'   `actionable`, `unreported` and `default_radius`. The grain, the
#'   total record and dataset counts and `min_n` are stored as
#'   attributes.
#' @examples
#' a <- ingrain(crayfish, grain = 1000)
#' by_dataset(a)
#' @seealso [ingrain_u()] for how much the dataset determines the state.
#' @export
by_dataset <- function(object, dataset = "datasetKey", min_n = 1L) {
  if (!inherits(object, "ingrain_audit"))
    stop("`object` must come from ingrain().", call. = FALSE)
  if (!is.character(dataset) || length(dataset) != 1L)
    stop("`dataset` must be a single column name.", call. = FALSE)
  if (!dataset %in% names(object))
    stop(sprintf("Column `%s` not found in `object`.", dataset),
         call. = FALSE)
  if (!is.numeric(min_n) || length(min_n) != 1L ||
      !is.finite(min_n) || min_n < 1)
    stop("`min_n` must be a single number >= 1.", call. = FALSE)

  ds <- as.character(object[[dataset]])
  ds[is.na(ds)] <- "(missing)"
  ucol <- attr(object, "uncertainty_col")
  r <- if (!is.null(ucol) && ucol %in% names(object)) object[[ucol]]
       else rep(NA_real_, nrow(object))
  is_def <- !is.na(r) & r %in% c(301, 999, 3036, 9999)

  tab <- table(ds, object$.state)
  n <- as.integer(rowSums(tab))
  def_share <- as.vector(tapply(is_def, ds, mean)[rownames(tab)])
  out <- data.frame(
    dataset        = rownames(tab),
    n              = n,
    inert          = as.vector(tab[, "inert"]) / n,
    marginal       = as.vector(tab[, "marginal"]) / n,
    actionable     = as.vector(tab[, "actionable"]) / n,
    unreported     = as.vector(tab[, "unreported"]) / n,
    default_radius = def_share,
    stringsAsFactors = FALSE
  )
  out <- out[out$n >= min_n, , drop = FALSE]
  out <- out[order(-out$n, out$dataset), , drop = FALSE]
  rownames(out) <- NULL
  attr(out, "grain") <- attr(object, "grain")
  attr(out, "n_records") <- length(ds)
  attr(out, "n_datasets_total") <- nrow(tab)
  attr(out, "min_n") <- min_n
  class(out) <- c("ingrain_datasets", class(out))
  out
}

#' @export
print.ingrain_datasets <- function(x, top = 10, ...) {
  cat(sprintf(
    "-- ingrain datasets -- %s of %s datasets (min_n = %s), grain %s --\n",
    format(nrow(x), big.mark = ","),
    format(attr(x, "n_datasets_total"), big.mark = ","),
    format(attr(x, "min_n")), fmt_metres(attr(x, "grain"))))
  k <- min(top, nrow(x))
  if (k > 0) {
    cat(sprintf("%-13s %9s %7s %9s %11s %11s\n",
                "dataset", "n", "inert", "marginal", "actionable",
                "unreported"))
    for (i in seq_len(k)) {
      cat(sprintf("%-13s %9s %6.1f%% %8.1f%% %10.1f%% %10.1f%%\n",
                  paste0(substr(x$dataset[i], 1, 10), "..."),
                  format(x$n[i], big.mark = ","),
                  100 * x$inert[i], 100 * x$marginal[i],
                  100 * x$actionable[i], 100 * x$unreported[i]))
    }
    if (nrow(x) > k)
      cat(sprintf("  ... and %d more datasets\n", nrow(x) - k))
  }
  invisible(x)
}

#' How much does the dataset determine the state of a record?
#'
#' Computes the uncertainty coefficient (Theil's U) of the four-state
#' partition given the publishing dataset,
#' \deqn{U = 1 - H(state | dataset) / H(state),}
#' with plug-in entropies in bits: `U = 0` means the dataset tells you
#' nothing about a record's state, `U = 1` that it determines it
#' completely. Because a plug-in U is inflated by having many groups, it
#' is compared against a permutation null in which state labels are
#' reshuffled across records, holding dataset sizes and the overall
#' state counts fixed; the quantity to interpret is the excess of U over
#' the null mean. With states collapsed to two classes this estimator
#' and its null reduce exactly to the binary uncertainty-coefficient
#' construction used in the analyses behind the package; there, the two
#' classes were `actionable` versus all other states pooled, computed
#' over datasets with at least 500 records.
#'
#' @param object An `ingrain_audit` object from [ingrain()].
#' @param dataset Name of the column identifying the publishing dataset.
#' @param B Number of permutations for the null. `B = 0` skips the null
#'   and returns only `u`.
#' @param seed Optional integer seed for the permutation null; the
#'   caller's random-number state is restored afterwards.
#' @param min_n Drop datasets with fewer than `min_n` records (their
#'   records are excluded from the computation entirely).
#'
#' @return An object of class `"ingrain_u"`: a list with elements `u`,
#'   `null` (vector of length `B`), `u_null` (null mean), `sd_null`,
#'   `excess`, `p` (permutation p-value), `B`, `n_records`,
#'   `n_datasets`.
#' @examples
#' a <- ingrain(crayfish, grain = 1000)
#' ingrain_u(a, B = 50, seed = 1)
#' @export
ingrain_u <- function(object, dataset = "datasetKey", B = 200,
                      seed = NULL, min_n = 1L) {
  if (!inherits(object, "ingrain_audit"))
    stop("`object` must come from ingrain().", call. = FALSE)
  if (!is.character(dataset) || length(dataset) != 1L ||
      !dataset %in% names(object))
    stop("`dataset` must name a column of `object`.", call. = FALSE)
  if (!is.numeric(B) || length(B) != 1L || !is.finite(B) || B < 0)
    stop("`B` must be a single number >= 0.", call. = FALSE)
  if (!is.numeric(min_n) || length(min_n) != 1L ||
      !is.finite(min_n) || min_n < 1)
    stop("`min_n` must be a single number >= 1.", call. = FALSE)
  B <- as.integer(B)

  ds <- as.character(object[[dataset]])
  ds[is.na(ds)] <- "(missing)"
  st <- object$.state
  sizes <- table(ds)
  keep <- ds %in% names(sizes)[sizes >= min_n]
  ds <- ds[keep]; st <- st[keep]
  if (length(st) == 0)
    stop("No records left after `min_n` filtering.", call. = FALSE)

  u <- uncertainty_coefficient(ds, st)

  nul <- numeric(0)
  if (B > 0) {
    if (!is.null(seed)) {
      old_seed <- if (exists(".Random.seed", envir = globalenv(),
                            inherits = FALSE))
        get(".Random.seed", envir = globalenv(), inherits = FALSE)
      else NULL
      if (!is.null(old_seed))
        on.exit(assign(".Random.seed", old_seed, envir = globalenv()),
                add = TRUE)
      set.seed(seed)
    }
    nul <- vapply(seq_len(B), function(b)
      uncertainty_coefficient(ds, sample(st)), numeric(1))
  }

  out <- list(
    u = u,
    null = nul,
    u_null = if (B > 0) mean(nul) else NA_real_,
    sd_null = if (B > 0) stats::sd(nul) else NA_real_,
    excess = if (B > 0) u - mean(nul) else NA_real_,
    p = if (B > 0) (1 + sum(nul >= u)) / (B + 1) else NA_real_,
    B = B,
    n_records = length(st),
    n_datasets = length(unique(ds))
  )
  class(out) <- "ingrain_u"
  out
}

#' @export
print.ingrain_u <- function(x, ...) {
  cat("-- ingrain U -- how much the dataset determines the state --\n")
  cat(sprintf("  U = %.3f   (0 = dataset tells you nothing, 1 = everything)\n",
              x$u))
  if (x$B > 0) {
    cat(sprintf("  permutation null (B = %d): mean %.3f (sd %.3f)\n",
                x$B, x$u_null, x$sd_null))
    cat(sprintf("  excess over null = %.3f   p = %.4f\n", x$excess, x$p))
  } else {
    cat("  null not computed (B = 0)\n")
  }
  cat(sprintf("  %s records across %s datasets\n",
              format(x$n_records, big.mark = ","),
              format(x$n_datasets, big.mark = ",")))
  invisible(x)
}
