## ingrain paper: Figures 1 and 2 for the Ecography Software Note.
## Run from the repository root:  Rscript paper/figures.R
## Output: paper/figures/Figure1.png|pdf, Figure2.png|pdf
## Double-column width (1961 px at 300 dpi), sans-serif, panels (a) and (b).
## Before plotting, the script recomputes every headline number in the text.

if (!dir.exists("paper")) stop("run this from the repository root")

suppressPackageStartupMessages({
  library(ingrain)
  library(ggplot2)
  library(patchwork)
})

outdir <- file.path("paper", "figures")
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
W <- 1961 / 300

cat("ingrain ", as.character(packageVersion("ingrain")),
    " | ggplot2 ", as.character(packageVersion("ggplot2")),
    " | patchwork ", as.character(packageVersion("patchwork")), "\n\n", sep = "")
if (packageVersion("ingrain") != "1.0.0")
  stop("installed ingrain is not 1.0.0: run R CMD INSTALL . from the repo root first")

## ---- palette and theme --------------------------------------------------

state_names <- c("inert", "marginal", "actionable", "unreported")
okabe <- c(inert = "#0072B2", marginal = "#E69F00",
           actionable = "#D55E00", unreported = "#999999")
pal <- tryCatch({
  p <- ingrain:::ingrain_palette()
  if (!is.null(names(p)) && all(state_names %in% names(p))) {
    p[state_names]
  } else if (length(p) >= 4) {
    setNames(unname(p[1:4]), state_names)
  } else okabe
}, error = function(e) okabe)
cat("palette used:\n"); print(pal)

th <- tryCatch(ingrain:::theme_ingrain(), error = function(e) theme_minimal()) +
  theme(text = element_text(family = "sans", size = 9))

sz <- theme(text = element_text(family = "sans", size = 9),
            axis.title = element_text(size = 9),
            axis.text = element_text(size = 8),
            strip.text = element_text(size = 8),
            legend.text = element_text(size = 8),
            legend.title = element_text(size = 9),
            legend.key.size = unit(0.35, "cm"),
            plot.tag = element_text(face = "bold", size = 10))

call_method <- function(fun, obj, extra = list()) {
  f <- get(fun, envir = asNamespace("ingrain"))
  keep <- extra[names(extra) %in% names(formals(f))]
  do.call(f, c(list(obj), keep))
}
cat("\nautoplot.ingrain_profile args: ",
    paste(names(formals(ingrain:::autoplot.ingrain_profile)), collapse = ", "), "\n", sep = "")
cat("autoplot.ingrain_datasets args: ",
    paste(names(formals(ingrain:::autoplot.ingrain_datasets)), collapse = ", "), "\n\n", sep = "")

## ---- controls: recompute the numbers reported in the text ----------------

a <- ingrain(crayfish, grain = 1000)
st <- if (!is.null(a$.state)) a$.state else a$state
st <- factor(as.character(st), levels = state_names)
cat("1-km partition (text: 2652 / 126 / 772 / 1450):\n"); print(table(st))

r <- a$coordinateUncertaintyInMeters
keep <- is.na(r) | r < 1000
cat("\nstandard filter at 1 km (text: keeps 4149, 0 of 772 actionable): kept ", sum(keep), "\n", sep = "")
print(table(state = st, kept = keep))

dk <- as.character(a$datasetKey)
tab <- table(dk, st)
n_ds <- rowSums(tab)
big <- n_ds >= 10
share_max <- apply(tab[big, , drop = FALSE], 1, max) / n_ds[big]
cat("\ndatasets: ", nrow(tab), " total, ", sum(big), " with >= 10 records, ",
    sum(share_max >= 0.9), " of those with >= 90% in one state (text: 246, 59, 44)\n", sep = "")

H <- function(x) {
  p <- as.numeric(table(x)); p <- p[p > 0] / sum(p); -sum(p * log2(p))
}
Hc <- function(s, d) {
  tb <- table(d, s); nd <- rowSums(tb)
  hrow <- apply(tb, 1, function(z) { z <- z[z > 0] / sum(z); -sum(z * log2(z)) })
  sum(nd / sum(nd) * hrow)
}
Ufun <- function(s, d) (H(s) - Hc(s, d)) / H(s)
U_obs <- Ufun(st, dk)

u <- ingrain_u(a, B = 200, seed = 1)
cat("\npackage ingrain_u():\n"); print(u)
uu <- unclass(u)
null_vec <- NULL
if (is.list(uu)) {
  lens <- vapply(uu, function(z) if (is.numeric(z)) length(z) else 0L, integer(1))
  if (any(lens == 200)) null_vec <- uu[[which(lens == 200)[1]]]
}
if (is.null(null_vec)) {
  set.seed(1)
  null_vec <- replicate(200, Ufun(st, sample(dk)))
  cat("null vector not found in the ingrain_u object; using own permutation null\n")
}
p_val <- (1 + sum(null_vec >= U_obs)) / (1 + length(null_vec))
cat(sprintf("\nU observed (independent computation): %.3f   (text: 0.797)\n", U_obs))
cat(sprintf("null: mean %.3f, SD %.3f, p = %.3f   (text: 0.059, 0.003, 0.005)\n\n",
            mean(null_vec), sd(null_vec), p_val))

## ---- Figure 1a: one record, three grains ---------------------------------

r0 <- 700; cx <- 1000; cy <- 1000; win <- 2000
grains <- c(2000, 1000, 200)
lab <- c("R = 2 km, r/R = 0.35\ninert",
         "R = 1 km, r/R = 0.70\nmarginal",
         "R = 200 m, r/R = 3.5\nactionable")
st_a <- c("inert", "marginal", "actionable")
panel_of <- function(R) factor(match(R, grains), levels = 1:3, labels = lab)

cells <- do.call(rbind, lapply(seq_along(grains), function(k) {
  R <- grains[k]
  g <- expand.grid(i = seq(0, win / R - 1), j = seq(0, win / R - 1))
  x0 <- g$i * R; y0 <- g$j * R
  nx <- pmin(pmax(cx, x0), x0 + R); ny <- pmin(pmax(cy, y0), y0 + R)
  hit <- (nx - cx)^2 + (ny - cy)^2 < r0^2
  data.frame(R = R, xmin = x0, xmax = x0 + R, ymin = y0, ymax = y0 + R,
             fillc = ifelse(hit, st_a[k], NA))
}))
cells$panel <- panel_of(cells$R)

ang <- seq(0, 2 * pi, length.out = 181)
disc <- do.call(rbind, lapply(seq_along(grains), function(k) {
  data.frame(R = grains[k], x = cx + r0 * cos(ang), y = cy + r0 * sin(ang), state = st_a[k])
}))
disc$panel <- panel_of(disc$R)

p1a <- ggplot() +
  geom_rect(data = cells,
            aes(xmin = xmin / 1000, xmax = xmax / 1000, ymin = ymin / 1000, ymax = ymax / 1000,
                fill = fillc),
            colour = "grey55", linewidth = 0.25, alpha = 0.25, show.legend = FALSE) +
  geom_polygon(data = disc, aes(x / 1000, y / 1000, fill = state),
               alpha = 0.55, colour = "black", linewidth = 0.4, show.legend = FALSE) +
  annotate("point", x = cx / 1000, y = cy / 1000, size = 0.8) +
  facet_wrap(~ panel, nrow = 1) +
  scale_fill_manual(values = pal, na.value = "white") +
  scale_x_continuous(breaks = c(0, 1, 2)) +
  scale_y_continuous(breaks = c(0, 1, 2)) +
  coord_equal(expand = FALSE) +
  labs(x = "km", y = "km") +
  th + theme(panel.grid = element_blank(), panel.spacing = unit(1.2, "lines"))

## ---- Figure 1b: grain profile ------------------------------------------------

prof <- ingrain_profile(crayfish, mark = 1000)
p1b <- call_method("autoplot.ingrain_profile", prof) +
  labs(title = NULL, subtitle = NULL, caption = NULL, y = "Share of records")

fig1 <- (p1a / p1b) + plot_layout(heights = c(1, 1.4)) +
  plot_annotation(tag_levels = "a", tag_prefix = "(", tag_suffix = ")") & sz
ggsave(file.path(outdir, "Figure1.png"), fig1, width = W, height = 6.4,
       units = "in", dpi = 300, bg = "white")
ggsave(file.path(outdir, "Figure1.pdf"), fig1, width = W, height = 6.4, units = "in")

## ---- Figure 2a: publishing datasets ---------------------------------------

ds <- by_dataset(a)
p2a <- call_method("autoplot.ingrain_datasets", ds,
                   list(top = 25, n = 25, top_n = 25, n_top = 25,
                        max_n = 25, max_datasets = 25)) +
  labs(title = NULL, subtitle = NULL, caption = NULL)

## ---- Figure 2b: Theil's U against the permutation null ----------------------

p2b <- ggplot(data.frame(u = null_vec), aes(u)) +
  geom_histogram(binwidth = 0.002, fill = "grey60", colour = NA) +
  geom_vline(xintercept = U_obs, linetype = "dashed", linewidth = 0.5,
             colour = pal[["actionable"]]) +
  annotate("text", x = U_obs, y = Inf, vjust = 1.5, hjust = 1.05, size = 3,
           label = sprintf("observed U = %.3f", U_obs)) +
  annotate("text", x = mean(null_vec), y = Inf, vjust = 1.3, hjust = -0.1, size = 3,
           label = sprintf("permutation null (B = 200)\nmean %.3f, SD %.3f",
                           mean(null_vec), sd(null_vec))) +
  scale_x_continuous(breaks = seq(0, 0.8, 0.2)) +
  coord_cartesian(xlim = c(0, 0.85)) +
  labs(x = "U(state | dataset)", y = "Permutations") +
  th

fig2 <- (p2a / p2b) + plot_layout(heights = c(2.3, 1)) +
  plot_annotation(tag_levels = "a", tag_prefix = "(", tag_suffix = ")") & sz
ggsave(file.path(outdir, "Figure2.png"), fig2, width = W, height = 7.6,
       units = "in", dpi = 300, bg = "white")
ggsave(file.path(outdir, "Figure2.pdf"), fig2, width = W, height = 7.6, units = "in")

cat("written:\n"); print(list.files(outdir, full.names = TRUE))
