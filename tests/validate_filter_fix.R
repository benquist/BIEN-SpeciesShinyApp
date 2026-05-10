# Validation harness for the 2026-05-10 filter fix (Issue 14).
# Runs four canonical species through the three filter modes and reports:
#   - row counts
#   - unique countries returned
#   - bien_query_strategy values present in result
#   - sanity check vs POWO native distribution
#
# Usage:
#   Rscript tests/validate_filter_fix.R 2>&1 | tee tests/validate_filter_fix_log.txt

suppressPackageStartupMessages({
  library(BIEN)
  library(dplyr)
})

app_path <- "/Users/brianjenquist/VSCode/BIEN-SpeciesShinyApp"

# Source helper functions only (avoid running the Shiny UI / server)
src_lines <- readLines(file.path(app_path, "app.R"))
end_helpers <- grep("^# Server logic:", src_lines)[1] - 1L
helpers_path <- tempfile(fileext = ".R")
writeLines(src_lines[seq_len(end_helpers)], helpers_path)

# Many helpers depend on shiny/leaflet/etc.; load minimally.
suppressPackageStartupMessages({
  library(shiny)
  library(stringr)
  library(tidyr)
  library(purrr)
})

# Stub out compact_label etc. only if not present in helper section.
source(helpers_path, local = FALSE, echo = FALSE)

cat("Loaded helpers from app.R lines 1 to", end_helpers, "\n\n")

# Mock input list factory so we can call query_occurrence_with_fallback directly.
make_input <- function(use_default = FALSE,
                      natives_only = TRUE,
                      strict_native_no_unknown = FALSE,
                      include_cultivated = FALSE,
                      only_geovalid = TRUE,
                      use_introduced_filter = TRUE,
                      use_cultivated_filter = TRUE) {
  list(
    use_default_bien_filter_profile = use_default,
    use_introduced_filter = use_introduced_filter,
    natives_only = natives_only,
    strict_native_no_unknown = strict_native_no_unknown,
    use_cultivated_filter = use_cultivated_filter,
    include_cultivated = include_cultivated,
    only_geovalid = only_geovalid,
    exclude_human_observation_records = FALSE,
    only_plot_observations = FALSE
  )
}

run_case <- function(species, label, input_obj) {
  cat(sprintf("\n[%s | %s]\n", species, label))
  t0 <- Sys.time()
  res <- tryCatch(
    query_occurrence_with_fallback(
      species_name = species,
      input = input_obj,
      occ_limit = 1000,
      occ_page_size = 500,
      timeout_sec = 120,
      max_plans = 5,
      per_plan_timeout = 30,
      randomize_order = FALSE
    ),
    error = function(e) list(data = NULL, strategy = paste("ERROR:", conditionMessage(e)), notes = character())
  )
  dt <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  d <- res$data
  n <- if (is.data.frame(d)) nrow(d) else 0
  countries <- if (is.data.frame(d) && "country" %in% names(d)) sort(unique(stats::na.omit(d$country))) else character()
  per_row_strategy <- if (is.data.frame(d) && "bien_query_strategy" %in% names(d)) sort(unique(d$bien_query_strategy)) else "<missing>"
  cat(sprintf("  strategy        : %s\n", res$strategy))
  cat(sprintf("  rows            : %d\n", n))
  cat(sprintf("  per-row col     : %s\n", paste(per_row_strategy, collapse = ", ")))
  cat(sprintf("  unique countries: %s\n", paste(utils::head(countries, 25), collapse = " | ")))
  if (length(countries) > 25) cat(sprintf("                    (+%d more)\n", length(countries) - 25))
  cat(sprintf("  elapsed         : %.1fs\n", dt))
  invisible(list(strategy = res$strategy, n = n, countries = countries, per_row = per_row_strategy))
}

species_list <- list(
  list(name = "Markhamia lutea",      native = "Tropical Africa (POWO)",                  expected_strict = "0 or Africa-only"),
  list(name = "Pinus ponderosa",      native = "Western N America (POWO/USDA)",            expected_strict = "USA, Canada, Mexico"),
  list(name = "Eucalyptus globulus",  native = "Tasmania / SE Australia (POWO)",          expected_strict = "0 or Australia"),
  list(name = "Tamarix ramosissima",  native = "Central Asia native; invasive in N America", expected_strict = "0 or sparse")
)

cat("====== Filter-fix validation (2026-05-10, Issue 14) ======\n")
cat("Three modes per species:\n")
cat("  M1 = strict-only profile (use_default = TRUE)\n")
cat("  M2 = granular defaults (native-or-unknown), use_default = FALSE\n")
cat("  M3 = granular + Strict native (exclude unevaluated), use_default = FALSE\n")

results <- list()
for (s in species_list) {
  cat(sprintf("\n=== %s ===\n  POWO native: %s\n  Strict expectation: %s\n", s$name, s$native, s$expected_strict))
  results[[s$name]] <- list(
    M1 = run_case(s$name, "M1 strict-only profile",            make_input(use_default = TRUE)),
    M2 = run_case(s$name, "M2 granular default (incl IS NULL)", make_input(use_default = FALSE, strict_native_no_unknown = FALSE)),
    M3 = run_case(s$name, "M3 granular + strict native",        make_input(use_default = FALSE, strict_native_no_unknown = TRUE))
  )
}

cat("\n====== Summary ======\n")
for (sp in names(results)) {
  cat(sprintf("\n%s\n", sp))
  for (mode in c("M1", "M2", "M3")) {
    r <- results[[sp]][[mode]]
    cat(sprintf("  %s: strategy=%s, n=%d, countries=%d\n",
                mode, r$strategy, r$n, length(r$countries)))
  }
}
cat("\nDone.\n")
