utils::globalVariables(c("state", "share", "lab", "mid", "grain"))

fmt_metres <- function(x) {
  ifelse(x >= 1000,
         paste0(format(x / 1000, trim = TRUE, drop0trailing = TRUE), " km"),
         paste0(format(x, trim = TRUE, drop0trailing = TRUE), " m"))
}

#' ingrain state palette
#'
#' The colour palette used for the four record states throughout the
#' package: Okabe-Ito colours, safe for colour-vision deficiency.
#'
#' @return Named character vector of hex colours for `"inert"`,
#'   `"marginal"`, `"actionable"` and `"unreported"`.
#' @examples
#' ingrain_palette()
#' @export
ingrain_palette <- function() {
  c(inert      = "#56B4E9",
    marginal   = "#E69F00",
    actionable = "#D55E00",
    unreported = "#999999")
}

#' Minimal theme for ingrain figures
#'
#' @param base_size Base font size in points.
#' @return A ggplot2 theme object.
#' @examples
#' a <- ingrain(crayfish, grain = 1000)
#' autoplot(a) + theme_ingrain(base_size = 11)
#' @export
theme_ingrain <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      legend.position  = "bottom",
      legend.title     = ggplot2::element_blank(),
      plot.title       = ggplot2::element_text(face = "bold"),
      plot.subtitle    = ggplot2::element_text(colour = "grey35"),
      plot.caption     = ggplot2::element_text(colour = "grey45"),
      plot.margin      = ggplot2::margin(8, 14, 6, 12)
    )
}

#' @importFrom ggplot2 autoplot
#' @export
ggplot2::autoplot

#' Plot an ingrain audit as a single partition bar
#'
#' Draws the four-state partition as one horizontal stacked bar, ordered
#' inert, marginal, actionable, unreported from left to right. The legend
#' carries the exact share of every state; segments wide enough to hold a
#' label repeat theirs in the bar.
#'
#' @param object An `ingrain_audit` object from [ingrain()].
#' @param ... Ignored.
#' @return A ggplot object.
#' @examples
#' a <- ingrain(crayfish, grain = 1000)
#' autoplot(a)
#' @export
autoplot.ingrain_audit <- function(object, ...) {
  s <- summary(object)
  s$share[is.na(s$share)] <- 0
  s$lab <- sprintf("%.1f%%", 100 * s$share)
  s$mid <- cumsum(s$share) - s$share / 2
  grain <- attr(object, "grain")

  ggplot2::ggplot(s, ggplot2::aes(x = share, y = "records", fill = state)) +
    ggplot2::geom_col(position = ggplot2::position_stack(reverse = TRUE),
                      width = 0.55) +
    ggplot2::geom_text(
      data = s[s$share >= 0.06, , drop = FALSE],
      ggplot2::aes(x = mid, label = lab),
      colour = "white", fontface = "bold", size = 3.4) +
    ggplot2::scale_fill_manual(
      values = ingrain_palette(), drop = FALSE,
      labels = sprintf("%s  %s", as.character(s$state), s$lab)) +
    ggplot2::scale_x_continuous(
      limits = c(0, 1),
      labels = function(v) paste0(round(100 * v), "%"),
      expand = ggplot2::expansion(mult = c(0, 0.01))) +
    ggplot2::labs(
      title = sprintf("ingrain audit at a %s grain", fmt_metres(grain)),
      x = NULL, y = NULL,
      caption = sprintf("n = %s records",
                        format(nrow(object), big.mark = ","))) +
    theme_ingrain() +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(),
                   axis.text.y = ggplot2::element_blank())
}

#' @export
plot.ingrain_audit <- function(x, ...) {
  print(autoplot(x, ...))
  invisible(x)
}

#' Plot an ingrain profile as stacked shares across grains
#'
#' The signature figure of the package: shares of the four states as a
#' function of analysis grain, on a log axis. The `unreported` band is
#' flat by construction -- the portion of the data no resolution can
#' touch. If the profile carries a `mark`, a reference line is drawn at
#' that grain and the exact shares there appear in the subtitle.
#'
#' @param object An `ingrain_profile` object from [ingrain_profile()].
#' @param ... Ignored.
#' @return A ggplot object.
#' @examples
#' autoplot(ingrain_profile(crayfish, mark = 1000))
#' @export
autoplot.ingrain_profile <- function(object, ...) {
  mark <- attr(object, "mark")
  subtitle <- NULL
  if (!is.null(mark)) {
    at <- object[object$grain == mark, ]
    subtitle <- sprintf("at %s: %s", fmt_metres(mark),
                        paste(sprintf("%s %.1f%%", at$state, 100 * at$share),
                              collapse = "  \u00b7  "))
  }
  brk <- c(10, 100, 1000, 10000, 100000)
  brk <- brk[brk >= min(object$grain) & brk <= max(object$grain)]

  p <- ggplot2::ggplot(object,
                       ggplot2::aes(x = grain, y = share, fill = state)) +
    ggplot2::geom_area(position = ggplot2::position_stack(reverse = TRUE),
                       colour = "white", linewidth = 0.25) +
    ggplot2::scale_fill_manual(values = ingrain_palette(), drop = FALSE) +
    ggplot2::scale_x_log10(breaks = brk, labels = fmt_metres,
                           expand = c(0, 0)) +
    ggplot2::scale_y_continuous(
      labels = function(v) paste0(round(100 * v), "%"),
      expand = c(0, 0)) +
    ggplot2::labs(
      title = "ingrain profile: the partition across analysis grains",
      subtitle = subtitle,
      x = "analysis grain (cell edge, log scale)", y = NULL,
      caption = sprintf("n = %s records",
                        format(attr(object, "n"), big.mark = ","))) +
    theme_ingrain()
  if (!is.null(mark))
    p <- p + ggplot2::geom_vline(xintercept = mark, linetype = 2,
                                 colour = "grey15", linewidth = 0.4)
  p
}

#' @export
plot.ingrain_profile <- function(x, ...) {
  print(autoplot(x, ...))
  invisible(x)
}
