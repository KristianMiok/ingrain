#' Partition of occurrence records across a sweep of analysis grains
#'
#' Computes the four-state partition of [ingrain()] at every grain in a
#' sweep, showing how the split between `inert`, `marginal`, `actionable`
#' and `unreported` records shifts with the resolution of the intended
#' analysis. The `unreported` share is constant across the sweep: it is
#' the portion of the data that no choice of resolution can touch.
#'
#' @param occ A data.frame of occurrence records, e.g. a GBIF download.
#' @param grains Numeric vector of at least two candidate grains (raster
#'   cell edge lengths, in metres). Defaults to 61 log-spaced values from
#'   10 m to 100 km.
#' @param mark Optional single grain (metres) to highlight: it is added
#'   to the sweep and [autoplot()] draws a reference line there, with the
#'   exact shares at that grain in the subtitle.
#' @param uncertainty Name of the column holding the positional
#'   uncertainty radius in metres.
#'
#' @return A data.frame with columns `grain`, `state`, `n` and `share`,
#'   of class `"ingrain_profile"`, with the record count and any `mark`
#'   stored as attributes.
#' @examples
#' p <- ingrain_profile(crayfish, mark = 1000)
#' p
#' autoplot(p)
#' @seealso [ingrain()] for the audit at a single grain.
#' @export
ingrain_profile <- function(occ,
                            grains = 10^seq(1, 5, length.out = 61),
                            mark = NULL,
                            uncertainty = "coordinateUncertaintyInMeters") {
  if (!is.numeric(grains) || length(grains) < 2L ||
      any(!is.finite(grains)) || any(grains <= 0))
    stop("`grains` must be at least two positive, finite numbers (metres).",
         call. = FALSE)
  if (!is.null(mark)) {
    check_grain_scalar(mark)
    grains <- c(grains, mark)
  }
  grains <- sort(unique(grains))
  r <- ingrain_radii(occ, uncertainty)

  states <- c("inert", "marginal", "actionable", "unreported")
  out <- do.call(rbind, lapply(grains, function(g) {
    tab <- table(ingrain_states(r, g))
    data.frame(grain = g, state = states, n = as.vector(tab),
               share = as.vector(tab) / max(length(r), 1L))
  }))
  out$state <- factor(out$state, levels = states)
  attr(out, "n") <- length(r)
  attr(out, "mark") <- mark
  attr(out, "uncertainty_col") <- uncertainty
  class(out) <- c("ingrain_profile", class(out))
  out
}

#' @export
print.ingrain_profile <- function(x, ...) {
  g <- unique(x$grain)
  cat(sprintf(
    "-- ingrain profile -- %s records, %d grains from %s to %s --\n",
    format(attr(x, "n"), big.mark = ","), length(g),
    fmt_metres(min(g)), fmt_metres(max(g))))
  mark <- attr(x, "mark")
  if (!is.null(mark)) {
    at <- x[x$grain == mark, ]
    cat(sprintf("  at %s: %s\n", fmt_metres(mark),
                paste(sprintf("%s %.1f%%", at$state, 100 * at$share),
                      collapse = " | ")))
  }
  invisible(x)
}
