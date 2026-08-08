ingrain_radii <- function(occ, uncertainty) {
  if (!is.data.frame(occ))
    stop("`occ` must be a data.frame.", call. = FALSE)
  if (!is.character(uncertainty) || length(uncertainty) != 1L)
    stop("`uncertainty` must be a single column name.", call. = FALSE)
  if (!uncertainty %in% names(occ))
    stop(sprintf("Column `%s` not found in `occ`.", uncertainty),
         call. = FALSE)
  r <- occ[[uncertainty]]
  if (!is.numeric(r))
    stop(sprintf("Column `%s` must be numeric (metres).", uncertainty),
         call. = FALSE)
  bad <- !is.na(r) & (r < 0 | is.infinite(r))
  if (any(bad))
    stop(sprintf(paste0(
      "%d record(s) have negative or infinite uncertainty radii; ",
      "screen these upstream (e.g. CoordinateCleaner, bdc)."), sum(bad)),
      call. = FALSE)
  r
}

ingrain_states <- function(r, grain) {
  s <- cut(r, breaks = c(-Inf, grain / 2, 3 * grain, Inf),
           labels = c("inert", "marginal", "actionable"), right = TRUE)
  s <- as.character(s)
  s[is.na(r)] <- "unreported"
  factor(s, levels = c("inert", "marginal", "actionable", "unreported"))
}

check_grain_scalar <- function(grain) {
  if (!is.numeric(grain) || length(grain) != 1L ||
      !is.finite(grain) || grain <= 0)
    stop("`grain` must be a single positive number (metres).", call. = FALSE)
}

#' Classify occurrence records by positional uncertainty relative to an
#' analysis grain
#'
#' `ingrain()` partitions occurrence records into four states relative to a
#' chosen analysis grain \eqn{R} (the cell edge length of the intended
#' raster, in metres), based on the reported positional uncertainty radius
#' \eqn{r}:
#'
#' * `"inert"` -- \eqn{r \le R/2}. The uncertainty disc's diameter does not
#'   exceed one cell edge, so an uncertainty-aware correction cannot
#'   meaningfully act: the covariate is effectively constant over the region
#'   the record could occupy.
#' * `"marginal"` -- \eqn{R/2 < r \le 3R}. The boundary band, where whether
#'   the positional error matters depends on where the record falls relative
#'   to cell boundaries and on local covariate variation.
#' * `"actionable"` -- \eqn{r > 3R}. The uncertainty region spans many
#'   cells; corrections (threshold filtering, near-geographic and
#'   near-environmental point methods, change of support) have room to act,
#'   and the choice among them has consequences.
#' * `"unreported"` -- \eqn{r} is `NA`. No correction can act, and the
#'   radius cannot be recovered from the coordinates themselves.
#'
#' @param occ A data.frame of occurrence records, e.g. a GBIF download.
#' @param grain Numeric scalar. Cell edge length of the intended analysis
#'   raster, in metres.
#' @param uncertainty Name of the column holding the positional uncertainty
#'   radius in metres. Defaults to the Darwin Core term
#'   `"coordinateUncertaintyInMeters"`.
#'
#' @details
#' Boundary handling is inclusive from below and mirrors, bit for bit, the
#' cumulative-threshold construction used to compute the published
#' partition (counts of records with \eqn{r \le u} at \eqn{u = R/2} and
#' \eqn{u = 3R}, then differences): a radius exactly at \eqn{R/2} is
#' `inert`, and exactly at \eqn{3R} is `marginal`. `NaN` counts as `NA`.
#'
#' The `"inert"` state operationalises an observation made in passing by
#' Hefley et al. (2017): a change-of-support correction cannot act where
#' the covariate is constant within a raster cell.
#'
#' Negative or infinite radii raise an error; such values are data defects
#' and should be screened upstream (e.g. with CoordinateCleaner or bdc).
#' `ingrain()` deliberately performs no cleaning: it classifies what a
#' correction or filter could do to your data at your resolution.
#'
#' @return `occ` with an added factor column `.state` (levels `"inert"`,
#'   `"marginal"`, `"actionable"`, `"unreported"`), returned with class
#'   `"ingrain_audit"`. The grain and the name of the uncertainty column
#'   are stored as attributes. `print()` shows the four-state summary
#'   rather than the full data; use `summary()` for the counts as a
#'   data.frame.
#'
#' @references
#' Hefley, T.J., Brost, B.M. & Hooten, M.B. (2017) Bias correction of
#' bounded location errors in presence-only data.
#' *Methods in Ecology and Evolution*, 8, 1566--1573.
#' \doi{10.1111/2041-210X.12793}
#'
#' @examples
#' a <- ingrain(crayfish, grain = 1000)
#' a
#' summary(a)
#' @seealso [ingrain_profile()] for the partition across a sweep of grains.
#' @export
ingrain <- function(occ, grain,
                    uncertainty = "coordinateUncertaintyInMeters") {
  check_grain_scalar(grain)
  if (is.data.frame(occ) && ".state" %in% names(occ))
    stop("`occ` already has a `.state` column; rename it before auditing.",
         call. = FALSE)
  r <- ingrain_radii(occ, uncertainty)
  occ$.state <- ingrain_states(r, grain)
  attr(occ, "grain") <- grain
  attr(occ, "uncertainty_col") <- uncertainty
  class(occ) <- c("ingrain_audit", class(occ))
  occ
}

#' @export
print.ingrain_audit <- function(x, ...) {
  grain <- attr(x, "grain")
  grain_lab <- if (is.null(grain)) "unknown" else
    paste0(format(grain, big.mark = ","), " m")
  cat(sprintf("-- ingrain audit -- %s records, grain %s --\n",
              format(nrow(x), big.mark = ","), grain_lab))
  s <- summary(x)
  for (i in seq_len(nrow(s))) {
    cat(sprintf("  %-10s %6.1f%%  (n = %s)\n",
                as.character(s$state[i]), 100 * s$share[i],
                format(s$n[i], big.mark = ",")))
  }
  invisible(x)
}

#' @export
summary.ingrain_audit <- function(object, ...) {
  n <- as.vector(table(object$.state))
  data.frame(
    state = factor(levels(object$.state),
                   levels = levels(object$.state)),
    n = n,
    share = if (nrow(object) > 0) n / nrow(object)
            else rep(NA_real_, nlevels(object$.state))
  )
}
