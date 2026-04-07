#!/usr/bin/env Rscript

species_cfg <- data.frame(
  data_tier = c("low", "medium", "high"),
  species_key = c("abies_bracteata", "pinus_ponderosa", "populus_tremuloides"),
  species_name = c("Abies bracteata", "Pinus ponderosa", "Populus tremuloides"),
  stringsAsFactors = FALSE
)

read_n <- function(path) {
  if (!file.exists(path)) {
    return(NA_integer_)
  }
  df <- tryCatch(read.csv(path, stringsAsFactors = FALSE), error = function(e) data.frame())
  as.integer(nrow(df))
}

baseline <- species_cfg
baseline$occurrence_rows <- vapply(
  baseline$species_key,
  function(key) read_n(file.path("sample_data", paste0(key, "_occurrences.csv"))),
  integer(1)
)
baseline$trait_rows <- vapply(
  baseline$species_key,
  function(key) read_n(file.path("sample_data", paste0(key, "_traits.csv"))),
  integer(1)
)
baseline$range_rows <- vapply(
  baseline$species_key,
  function(key) read_n(file.path("sample_data", paste0(key, "_ranges.csv"))),
  integer(1)
)

baseline$map_cap_test <- ifelse(
  baseline$occurrence_rows <= 200,
  pmax(50L, baseline$occurrence_rows - 10L),
  800L
)
baseline$min_mappable_points <- ifelse(
  baseline$occurrence_rows <= 200,
  pmax(20L, floor(baseline$occurrence_rows * 0.65)),
  700L
)
baseline$min_observation_categories <- 1L
baseline$min_observation_categories[baseline$data_tier == "low"] <- 2L

out_path <- file.path("tests", "baselines", "species_snapshot_baseline.csv")
write.csv(baseline, out_path, row.names = FALSE)
cat("Baseline manifest written to:", out_path, "\n")
print(baseline)