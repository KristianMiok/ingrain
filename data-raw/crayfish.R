# Builds the bundled `crayfish` sample from GBIF download 10.15468/dl.99ezk2
# (03 August 2026; 507,980 records, 1,178 datasets). CC BY-NC records are
# excluded from redistribution; the sample is drawn from the CC0 + CC BY
# pool only. Run manually from the package root; never at build time.

zip_path <- path.expand(
  "~/Desktop/Papers/gbif-coordinate-uncertainty/0022943-260721160103020.zip")
entry <- "0022943-260721160103020.csv"
stopifnot(file.exists(zip_path))
if (!requireNamespace("data.table", quietly = TRUE))
  install.packages("data.table", repos = "https://cloud.r-project.org")

cols <- c("gbifID", "species", "countryCode", "decimalLatitude",
          "decimalLongitude", "coordinateUncertaintyInMeters", "year",
          "basisOfRecord", "datasetKey", "license")

full <- data.table::fread(
  cmd = sprintf("unzip -p '%s' '%s'", zip_path, entry),
  sep = "\t", quote = "", na.strings = "", select = cols,
  colClasses = list(character = c("gbifID", "datasetKey")),
  showProgress = FALSE)

stopifnot(nrow(full) == 507980L)

pool <- full[full$license %in% c("CC0_1_0", "CC_BY_4_0"), ]
cat(sprintf("pool %d of %d records (%.1f%%), %d datasets\n",
            nrow(pool), nrow(full), 100 * nrow(pool) / nrow(full),
            length(unique(pool$datasetKey))))

set.seed(20260808)
crayfish <- as.data.frame(pool[sample(nrow(pool), 5000L), ])
crayfish <- crayfish[order(crayfish$gbifID), ]
rownames(crayfish) <- NULL

usethis::use_data(crayfish, overwrite = TRUE, compress = "xz")

devtools::load_all(quiet = TRUE)
a <- ingrain(crayfish, grain = 1000)
print(a)
tab <- table(a$.state)
cat(sprintf("PIN states grain1000: %s\n",
            paste(names(tab), as.vector(tab), sep = "=", collapse = " | ")))
cat(sprintf("PIN unreported: %d | datasets: %d\n",
            sum(is.na(crayfish$coordinateUncertaintyInMeters)),
            length(unique(crayfish$datasetKey))))
print(table(crayfish$license))
