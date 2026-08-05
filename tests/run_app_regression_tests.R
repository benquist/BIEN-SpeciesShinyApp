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

extract_source_between <- function(source, start_marker, end_marker) {
  start <- regexpr(start_marker, source, fixed = TRUE)[[1]]
  assert_true(start > 0, paste("Missing source marker:", start_marker))
  remainder <- substring(source, start)
  relative_end <- regexpr(end_marker, remainder, fixed = TRUE)[[1]]
  assert_true(relative_end > 0, paste("Missing source marker:", end_marker))
  substring(remainder, 1, relative_end - 1)
}

load_app_helpers <- function() {
  sys.source("app.R", envir = .GlobalEnv)

  required_symbols <- c(
    "normalize_species_name",
    "load_species_suggestions_by_prefix",
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
    "taxon_names_differ",
    "taxon_confirmation_key",
    "summarize_evidence_quality",
    "build_reconciliation_table",
    "resolve_filter_profile",
    "classify_occurrence_result",
    "safe_bien_retry",
    "is_bien_connection_error",
    "is_bien_timeout_error",
    "format_occurrence_source_mix"
  )

  missing <- required_symbols[!vapply(required_symbols, exists, logical(1), inherits = TRUE)]
  assert_true(length(missing) == 0, paste0("Expected helper(s) missing after sourcing app.R: ", paste(missing, collapse = ", ")))
}

test_helper_functions <- function() {
  assert_equal(normalize_species_name("pinus   PONDEROSA"), "Pinus ponderosa", "normalize_species_name case normalization failed")
  assert_equal(normalize_species_name("Populus_tremuloides"), "Populus tremuloides", "normalize_species_name underscore normalization failed")
  assert_equal(normalize_species_name(NA_character_), "", "normalize_species_name must not convert missing values to the literal string NA")
  pass("normalize_species_name works for common case normalization")

  assert_true(!taxon_names_differ("pinus_ponderosa", "Pinus ponderosa"), "Formatting-only taxon differences must not require confirmation")
  assert_true(taxon_names_differ("Pinus ponderosa", "Pinus jeffreyi"), "Substantive taxon differences must require confirmation")
  assert_true(!taxon_names_differ("Pinus ponderosa", NA_character_), "Missing returned names must not require confirmation")
  assert_true(is.na(taxon_confirmation_key("query-1", "Pinus ponderosa", "Pinus ponderosa")), "Exact taxon matches must not create confirmation keys")
  assert_equal(
    taxon_confirmation_key("query-1", "Pinus ponderosa", "Pinus jeffreyi"),
    "query-1||Pinus ponderosa||Pinus jeffreyi",
    "Taxon confirmation key must identify the query and both names"
  )
  assert_true(
    !identical(
      taxon_confirmation_key("query-1||run=1", "Pinus ponderosa", "Pinus jeffreyi"),
      taxon_confirmation_key("query-1||run=2", "Pinus ponderosa", "Pinus jeffreyi")
    ),
    "Taxon confirmation must reset for each query execution"
  )
  pass("Taxon mismatch confirmation distinguishes substantive name changes")

  reconciliation_occ <- data.frame(scrubbed_species_binomial = "Pinus ponderosa", stringsAsFactors = FALSE)
  reconciliation <- build_reconciliation_table("Pinus ponderosa", reconciliation_occ, NULL, character(), NULL)
  assert_equal(reconciliation$matched_name[[1]], "Pinus ponderosa", "Reconciliation must retain the BIEN-returned name")
  assert_true(is.na(reconciliation$accepted_name[[1]]), "A BIEN-returned name must not be asserted as an accepted name")
  assert_true(is.na(reconciliation$matched_backbone[[1]]), "The BIEN package must not be asserted as a taxonomy backbone")
  assert_true(!is.na(reconciliation$bien_package_version[[1]]), "Reconciliation must report the BIEN package version separately")
  pass("Taxonomic reconciliation avoids unsupported acceptance and backbone claims")

  evidence_occ <- data.frame(
    latitude = c(10, 10, NA),
    longitude = c(20, 20, NA),
    observation_type = c("specimen", "specimen", "plot"),
    is_introduced = c(0, NA, 1),
    is_cultivated_observation = c(0, NA, 1),
    is_geovalid = c(1, NA, 0),
    date_collected = c("2020-01-01", "", NA),
    stringsAsFactors = FALSE
  )
  evidence_prepared <- prepare_occurrences(evidence_occ, map_point_cap = 1, sample_method = "head")
  evidence <- summarize_evidence_quality(list(
    species = "Pinus ponderosa",
    submitted_name = "Pinus ponderosa",
    occurrences = evidence_occ,
    occurrences_prepared = evidence_prepared,
    occurrences_returned = 5L,
    occ_strategy = "fallback_relaxed_native",
    data_profile = "standard",
    map_point_cap = 1L
  ), "Pinus ponderosa")
  assert_equal(evidence$fetched_n, 5L, "Evidence summary fetched count incorrect")
  assert_equal(evidence$retained_n, 3L, "Evidence summary retained count incorrect")
  assert_equal(evidence$coordinate_rows_collapsed, 1L, "Evidence summary map-collapse count incorrect")
  assert_equal(evidence$introduced_unknown_n, 1L, "Evidence summary establishment unknown count incorrect")
  assert_equal(evidence$dated_n, 1L, "Evidence summary date completeness incorrect")
  assert_true(isTRUE(evidence$fallback_active), "Evidence summary must expose active fallback")
  no_coord_evidence <- summarize_evidence_quality(list(
    species = "Pinus ponderosa",
    occurrences = data.frame(value = 1:2),
    occurrences_prepared = prepare_occurrences(data.frame(value = 1:2), map_point_cap = 10),
    occurrences_returned = 2L,
    occ_strategy = "strict",
    data_profile = "standard",
    map_point_cap = 10L
  ), "Pinus ponderosa")
  assert_equal(no_coord_evidence$mapped_n, 0L, "Evidence summary must not count rows without coordinate columns as mapped")
  pass("Evidence quality summary reports row stages, caps, unknowns, and dates")

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

  cfg_standard <- resolve_filter_profile(list(data_profile = "standard"))
  assert_equal(cfg_standard$profile, "standard", "resolve_filter_profile Standard identity incorrect")
  assert_true(isTRUE(cfg_standard$allow_fallback), "resolve_filter_profile Standard fallback flag incorrect")
  assert_true(isTRUE(cfg_standard$natives_only), "resolve_filter_profile Standard natives_only incorrect")

  cfg_strict <- resolve_filter_profile(list(data_profile = "strict"))
  assert_equal(cfg_strict$profile, "strict", "resolve_filter_profile Strict identity incorrect")
  assert_true(!isTRUE(cfg_strict$allow_fallback), "resolve_filter_profile Strict must not widen")
  assert_true(isTRUE(cfg_strict$strict_native_no_unknown), "resolve_filter_profile Strict native status incorrect")
  assert_true(isTRUE(cfg_strict$strict_wild_no_unknown), "resolve_filter_profile Strict cultivation status incorrect")

  cfg_custom <- resolve_filter_profile(list(
    data_profile = "custom",
    origin_radio = "all",
    cultivation_radio = "any",
    only_geovalid = FALSE,
    only_plot_observations = TRUE,
    exclude_human_observation_records = TRUE
  ))
  assert_equal(cfg_custom$profile, "custom", "resolve_filter_profile Custom identity incorrect")
  assert_true(!isTRUE(cfg_custom$allow_fallback), "resolve_filter_profile Custom must not widen")
  assert_true(!isTRUE(cfg_custom$use_introduced_filter), "resolve_filter_profile custom introduced filter incorrect")
  assert_true(isTRUE(cfg_custom$only_plot_observations), "resolve_filter_profile custom plot-only flag incorrect")
  pass("resolve_filter_profile returns exact Standard, Strict, and Custom configurations")

  assert_equal(classify_occurrence_result("backend_timeout_error", "standard", 0, 0), "timeout", "timeout classification failed")
  assert_equal(classify_occurrence_result("backend_connection_error", "standard", 0, 0), "backend_error", "backend-error classification failed")
  assert_equal(classify_occurrence_result("backend_query_error", "standard", 0, 0), "backend_error", "indeterminate backend classification failed")
  assert_equal(classify_occurrence_result("strict_no_unknown", "strict", 25, 0), "no_coordinates", "no-coordinate classification failed")
  assert_equal(classify_occurrence_result("no_bien_records", "strict", 0, 0), "filtered_empty", "Strict empty classification failed")
  assert_equal(classify_occurrence_result("no_bien_records", "standard", 0, 0), "no_records", "Standard empty classification failed")
  assert_equal(classify_occurrence_result("fallback_relaxed_native", "standard", 50, 50), "success_fallback", "fallback success classification failed")
  assert_equal(classify_occurrence_result("strict", "standard", 50, 50), "success", "success classification failed")
  pass("Occurrence query outcomes distinguish failures, empty states, and successful fallback")

  null_response <- safe_bien_retry(function() NULL, attempts = 1)
  assert_true(inherits(null_response$result, "error"), "NULL BIEN responses must be treated as backend errors")
  assert_equal(null_response$status, "error", "NULL BIEN response status must be error")

  app_source <- paste(readLines("app.R", warn = FALSE), collapse = "\n")
  occurrence_script_source <- extract_source_between(app_source, "build_occurrence_repro_script <- function", "build_trait_repro_script <- function")
  plot_script_source <- extract_source_between(app_source, "build_plot_repro_script <- function", "observeEvent(input$run_query")
  for (script_source in list(occurrence_script_source, plot_script_source)) {
    assert_true(grepl("zero_result_native_widened = FALSE", script_source, fixed = TRUE), "Each reproduction script must disable native-only after zero-result widening")
    assert_true(grepl("# Strict cultivation filter: retain observations explicitly marked non-cultivated", script_source, fixed = TRUE), "Each reproduction script must apply Strict cultivation post-filtering")
  }
  assert_true(grepl(",is_cultivated_observation,is_cultivated_in_region,is_location_cultivated", app_source, fixed = TRUE), "Occurrence SQL must return BIEN cultivation fields")
  assert_true(grepl("if (length(found) > 0) assign(cache_key, found, envir = species_prefix_cache)", app_source, fixed = TRUE), "Autocomplete must cache only successful nonempty lookups")
  prohibited_claims <- c(
    "BIEN covers the Western Hemisphere only",
    "known area and sampling effort",
    "download the full dataset",
    "Downloads all occurrence records",
    "making them suitable for community analyses",
    "BIEN: Botanical Information and Ecology Network",
    "post-QA",
    "Removed by QA",
    "Observation records after QA"
  )
  for (claim in prohibited_claims) {
    assert_true(!grepl(claim, app_source, fixed = TRUE), paste("Unsupported or inaccurate claim remains:", claim))
  }
  assert_true(grepl('tabPanel(\n          "Plot evidence"', app_source, fixed = TRUE), "Plot evidence tab label is missing")
  assert_true(grepl("Comprehensive coordinate, taxonomic, sampling-bias, and source-record QA is not performed", app_source, fixed = TRUE), "Evidence panel must distinguish comprehensive QA from app map preparation")
  confirmation_guards <- gregexpr("require_confirmed_taxon()", app_source, fixed = TRUE)[[1]]
  assert_true(confirmation_guards[[1]] > 0 && length(confirmation_guards) >= 7, "Every download path must require taxon confirmation")
  trait_script_handlers <- gregexpr("output$download_trait_repro_script <- downloadHandler", app_source, fixed = TRUE)[[1]]
  assert_true(trait_script_handlers[[1]] > 0 && length(trait_script_handlers) == 1, "Trait reproduction download handler must be defined exactly once")
  assert_true(grepl("_plot_evidence_dataset.csv", app_source, fixed = TRUE), "Plot-evidence CSV filename is missing")
  pass("Backend NULL handling and reproduction-script filter contracts are guarded")

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