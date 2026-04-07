#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(stringr)
})

assert_true <- function(condition, message) {
  if (!isTRUE(condition)) {
    stop(message, call. = FALSE)
  }
}

assert_equal <- function(actual, expected, message) {
  if (!identical(actual, expected)) {
    stop(paste0(message, " | expected=", expected, " actual=", actual), call. = FALSE)
  }
}

pass <- function(message) {
  cat(paste0("[PASS] ", message, "\n"))
}

load_app_helpers <- function() {
  sys.source("app.R", envir = .GlobalEnv)

  required_symbols <- c(
    "normalize_species_name",
    "find_first_col",
    "categorize_observation_records",
    "summarize_observation_sources",
    "extract_single_numeric_value",
    "prepare_trait_visual_data",
    "sample_occurrence_rows",
    "prepare_occurrences",
    "summarize_coordinate_quality",
    "summarize_range_object",
    "read_downloaded_range_sf",
    "build_reconciliation_table",
    "resolve_filter_profile",
    "is_bien_connection_error",
    "is_bien_timeout_error",
    "format_occurrence_source_mix"
  )

  missing <- required_symbols[!vapply(required_symbols, exists, logical(1), inherits = TRUE)]
  assert_true(length(missing) == 0, paste0("Expected helper(s) missing after sourcing app.R: ", paste(missing, collapse = ", ")))
}

test_helper_functions <- function() {
  assert_equal(normalize_species_name("pinus   PONDEROSA"), "Pinus ponderosa", "normalize_species_name case normalization failed")
  pass("normalize_species_name works for common case normalization")

  df_col <- data.frame(Observation_Type = c("specimen"), stringsAsFactors = FALSE)
  assert_equal(find_first_col(df_col, c("observation_type")), "Observation_Type", "find_first_col case-insensitive lookup failed")
  pass("find_first_col resolves case-insensitive column names")

  parsed <- extract_single_numeric_value(c("12.5", "12-16", "2012/2013", "abc", "5e-2"))
  assert_true(isTRUE(all.equal(parsed[1], 12.5)), "extract_single_numeric_value failed for single numeric string")
  assert_true(is.na(parsed[2]), "extract_single_numeric_value should reject ranges")
  assert_true(is.na(parsed[3]), "extract_single_numeric_value should reject date-like values")
  assert_true(is.na(parsed[4]), "extract_single_numeric_value should reject non-numeric values")
  assert_true(isTRUE(all.equal(parsed[5], 0.05)), "extract_single_numeric_value failed for scientific notation")
  pass("extract_single_numeric_value correctly handles numeric and ambiguous values")

  cfg_default <- resolve_filter_profile(list(use_default_bien_filter_profile = TRUE))
  assert_true(isTRUE(cfg_default$use_default_profile), "resolve_filter_profile default profile flag incorrect")
  assert_true(isTRUE(cfg_default$natives_only), "resolve_filter_profile default natives_only incorrect")

  cfg_custom <- resolve_filter_profile(list(
    use_default_bien_filter_profile = FALSE,
    use_introduced_filter = FALSE,
    use_cultivated_filter = FALSE,
    only_geovalid = FALSE,
    only_plot_observations = TRUE,
    exclude_human_observation_records = TRUE
  ))
  assert_true(!isTRUE(cfg_custom$use_default_profile), "resolve_filter_profile custom profile flag incorrect")
  assert_true(!isTRUE(cfg_custom$use_introduced_filter), "resolve_filter_profile custom introduced filter incorrect")
  assert_true(isTRUE(cfg_custom$only_plot_observations), "resolve_filter_profile custom plot-only flag incorrect")
  pass("resolve_filter_profile returns expected default and custom configurations")

  assert_true(is_bien_connection_error(c("Error connecting to the BIEN database")), "is_bien_connection_error failed")
  assert_true(is_bien_timeout_error(c("elapsed time limit reached")), "is_bien_timeout_error failed")
  pass("BIEN error classifiers detect connection and timeout messages")

  mix <- tibble(
    source_group = c("Specimens", "iNaturalist", "Plots", "Traits", "Other"),
    n_records = c(50, 20, 15, 10, 5)
  )
  mix_txt <- format_occurrence_source_mix(mix, expected_total = 100)
  assert_true(grepl("Specimens", mix_txt, fixed = TRUE), "format_occurrence_source_mix missing Specimens label")
  assert_true(grepl("iNaturalist", mix_txt, fixed = TRUE), "format_occurrence_source_mix missing iNaturalist label")
  pass("format_occurrence_source_mix renders fixed-order source summaries")
}

test_species_snapshots <- function() {
  baseline_path <- file.path("tests", "baselines", "species_snapshot_baseline.csv")
  assert_true(file.exists(baseline_path), paste0("Baseline file not found: ", baseline_path))
  baseline <- read.csv(baseline_path, stringsAsFactors = FALSE)

  required_cols <- c(
    "data_tier", "species_key", "species_name", "occurrence_rows", "trait_rows", "range_rows",
    "map_cap_test", "min_mappable_points", "min_observation_categories"
  )
  missing_cols <- required_cols[!required_cols %in% names(baseline)]
  assert_true(length(missing_cols) == 0, paste0("Baseline columns missing: ", paste(missing_cols, collapse = ", ")))
  pass("Baseline manifest schema is valid")

  for (i in seq_len(nrow(baseline))) {
    row <- baseline[i, , drop = FALSE]
    key <- row$species_key[[1]]
    species_name <- row$species_name[[1]]

    occ_file <- file.path("sample_data", paste0(key, "_occurrences.csv"))
    trait_file <- file.path("sample_data", paste0(key, "_traits.csv"))
    range_file <- file.path("sample_data", paste0(key, "_ranges.csv"))

    assert_true(file.exists(occ_file), paste0("Missing occurrence snapshot: ", occ_file))
    assert_true(file.exists(trait_file), paste0("Missing trait snapshot: ", trait_file))
    assert_true(file.exists(range_file), paste0("Missing range snapshot: ", range_file))

    occ <- read.csv(occ_file, stringsAsFactors = FALSE)
    traits <- read.csv(trait_file, stringsAsFactors = FALSE)
    ranges <- read.csv(range_file, stringsAsFactors = FALSE)

    assert_equal(nrow(occ), as.integer(row$occurrence_rows[[1]]), paste0(species_name, " occurrence row count mismatch"))
    assert_equal(nrow(traits), as.integer(row$trait_rows[[1]]), paste0(species_name, " trait row count mismatch"))
    assert_equal(nrow(ranges), as.integer(row$range_rows[[1]]), paste0(species_name, " range row count mismatch"))
    pass(paste0(species_name, " snapshot row counts match baseline"))

    occ_cat <- categorize_observation_records(occ)
    assert_true("observation_category" %in% names(occ_cat), paste0(species_name, " missing observation_category after categorization"))
    n_categories <- length(unique(na.omit(occ_cat$observation_category)))
    assert_true(n_categories >= as.integer(row$min_observation_categories[[1]]), paste0(species_name, " has too few observation categories: ", n_categories))

    source_summary <- summarize_observation_sources(occ_cat)
    assert_true(is.data.frame(source_summary) && nrow(source_summary) > 0, paste0(species_name, " source summary is empty"))
    assert_equal(sum(source_summary$n_records), nrow(occ), paste0(species_name, " source summary total mismatch"))

    map_cap <- as.integer(row$map_cap_test[[1]])
    occ_prepared <- prepare_occurrences(occ_cat, map_point_cap = map_cap, sample_method = "datasource")
    mapped_n <- if (is.null(occ_prepared$data)) 0L else as.integer(nrow(occ_prepared$data))

    assert_equal(as.integer(occ_prepared$qa$total), nrow(occ), paste0(species_name, " QA total mismatch"))
    assert_true(mapped_n >= as.integer(row$min_mappable_points[[1]]), paste0(species_name, " mapped points below baseline threshold"))
    assert_true(mapped_n <= map_cap, paste0(species_name, " mapped points exceed map cap"))
    qa_text <- summarize_coordinate_quality(occ_prepared)
    assert_true(grepl("valid coordinates", qa_text, fixed = TRUE), paste0(species_name, " coordinate QA text missing expected phrase"))

    popup_text <- make_popup_text(occ_cat[1, , drop = FALSE])
    assert_true(is.character(popup_text) && nchar(popup_text[[1]]) > 0, paste0(species_name, " popup text generation failed"))

    reconciliation <- build_reconciliation_table(species_name, occ_cat, traits, character(), ranges)
    assert_true(is.data.frame(reconciliation) && nrow(reconciliation) >= 1, paste0(species_name, " reconciliation table empty"))
    assert_true("matched_status" %in% names(reconciliation), paste0(species_name, " reconciliation missing matched_status"))

    if (nrow(traits) > 0) {
      trait_vis <- prepare_trait_visual_data(traits)
      assert_true(!is.null(trait_vis), paste0(species_name, " trait visual data unexpectedly NULL"))
      assert_true(is.data.frame(trait_vis$summary) && nrow(trait_vis$summary) > 0, paste0(species_name, " trait summary empty"))
    }

    range_summary <- summarize_range_object(ranges)
    assert_true(range_summary$kind %in% c("table", "empty"), paste0(species_name, " range summary kind unexpected: ", range_summary$kind))

    pass(paste0(species_name, " feature pipeline checks passed"))
  }

  tier_levels <- c("low", "medium", "high")
  baseline$data_tier <- factor(baseline$data_tier, levels = tier_levels)
  baseline <- baseline[order(baseline$data_tier), , drop = FALSE]

  assert_true(all(diff(as.integer(baseline$occurrence_rows)) > 0), "Occurrence rows are not strictly increasing across low/medium/high tiers")
  assert_true(all(diff(as.integer(baseline$trait_rows)) > 0), "Trait rows are not strictly increasing across low/medium/high tiers")
  pass("Low/medium/high baseline tiers have strictly increasing data volume")
}

test_range_shapefile_loading <- function() {
  shp_cases <- list(
    list(species = "Abies bracteata", shp = "Abies_bracteata_76.shp"),
    list(species = "Pinus ponderosa", shp = "Pinus_ponderosa_69330.shp"),
    list(species = "Populus tremuloides", shp = "Populus_tremuloides_72873.shp")
  )

  for (case in shp_cases) {
    if (!file.exists(case$shp)) {
      stop(paste0("Expected downloaded range shapefile not found: ", case$shp), call. = FALSE)
    }

    sf_obj <- read_downloaded_range_sf(".", case$species)
    assert_true(!is.null(sf_obj) && inherits(sf_obj, "sf") && nrow(sf_obj) > 0, paste0("Failed to load range shapefile for ", case$species))
  }

  pass("Downloaded range shapefile loading works for all baseline species")
}

test_sampling_behavior <- function() {
  set.seed(42)
  toy <- data.frame(
    datasource = rep(c("A", "B", "C"), each = 40),
    observation_type = rep(c("plot", "specimen"), 60),
    observation_category = rep(c("Plot / survey", "Specimen / herbarium", "Other / unknown"), each = 40),
    latitude = seq_len(120) / 10,
    longitude = seq_len(120) / 10,
    stringsAsFactors = FALSE
  )

  draw_a <- sample_occurrence_rows(toy, target_n = 60, sample_method = "datasource")
  draw_b <- sample_occurrence_rows(toy, target_n = 60, sample_method = "observation_category")
  draw_c <- sample_occurrence_rows(toy, target_n = 60, sample_method = "head")

  assert_equal(nrow(draw_a), 60L, "datasource sampling did not return requested row count")
  assert_equal(nrow(draw_b), 60L, "observation_category sampling did not return requested row count")
  assert_equal(nrow(draw_c), 60L, "head sampling did not return requested row count")

  assert_true(length(unique(draw_a$datasource)) > 1, "datasource-balanced sample lost source diversity")
  assert_true(length(unique(draw_b$observation_category)) > 1, "category-balanced sample lost category diversity")
  pass("Sampling modes enforce map cap while preserving multi-group coverage")
}

main <- function() {
  cat("========================================\n")
  cat("BIEN APP REGRESSION TEST SUITE\n")
  cat("========================================\n")

  load_app_helpers()
  pass("app.R sourced and helper symbols loaded")

  test_helper_functions()
  test_sampling_behavior()
  test_species_snapshots()
  test_range_shapefile_loading()

  cat("\nAll regression tests passed.\n")
}

tryCatch(
  {
    main()
    quit(status = 0)
  },
  error = function(e) {
    cat("\n[FAIL]", conditionMessage(e), "\n")
    quit(status = 1)
  }
)