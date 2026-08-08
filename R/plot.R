utils::globalVariables(c("state", "share", "lab", "mid"))

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
      panel.grid.minor   = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      legend.position    = "bottom",
      legend.title       = ggplot2::element_blank(),
      plot.title         = ggplot2::element_text(face = "bold"),
      plot.subtitle      = ggplot2::element_text(colour = "grey35"),
      plot.caption       = ggplot2::element_text(colour = "grey45"),
      axis.title.y       = ggplot2::element_blank(),
      axis.text.y        = ggplot2::element_blank()
    )
}

#' @importFrom ggplot2 autoplot
#' @export
ggplot2::autoplot

#' Plot an ingrain audit as a single partition bar
#'
#' Draws the four-state partition as one horizontal stacked bar, ordered
#' inert, marginal, actionable, unreported from left to right, with the
#' exact shares in the subtitle and in-bar labels on segments wide
#' enough to carry them.
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
    ggplot2::scale_fill_manual(values = ingrain_palette(), drop = FALSE) +
    ggplot2::scale_x_continuous(
      limits = c(0, 1),
      labels = function(v) paste0(round(100 * v), "%"),
      expand = ggplot2::expansion(mult = c(0, 0.01))) +
    ggplot2::labs(
      title = sprintf("ingrain audit at a %s m grain",
                      format(grain, big.mark = ",")),
      subtitle = paste(paste(s$state, s$lab), collapse = "   \u00b7   "),
      x = NULL,
      caption = sprintf("n = %s records",
                        format(nrow(object), big.mark = ","))) +
    theme_ingrain()
}

#' @export
plot.ingrain_audit <- function(x, ...) {
  print(autoplot(x, ...))
  invisible(x)
}
