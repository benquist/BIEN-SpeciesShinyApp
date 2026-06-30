#!/usr/bin/env Rscript
# test_species_profiles.R
# Directly tests BIEN SQL query semantics for each species × profile combination
# without sourcing the Shiny app. Reproduces the exact SQL filters used by each
# profile in app.R.
#
# Usage: Rscript /path/to/BIEN-SpeciesShinyApp/test_species_profiles.R

suppressPackageStartupMessages(library(BIEN))

# ── Minimal query helpers (mirrors app.R logic exactly) ─────────────────────
sql_quote_literal <- function(x) paste0("'", gsub("'", "''", x), "'")

natives_clause <- function(mode) {
  switch(mode,
    native_or_unknown = "AND (is_introduced=0 OR is_introduced IS NULL) ",
    native_only       = "AND is_introduced=0 ",
    all_records       = ""
  )
}

cultivated_clause <- function(mode) {
  # Matches BIEN:::.cultivated_check() output exactly.
  # Columns: is_cultivated_observation, is_location_cultivated
  switch(mode,
    wild_only          = "AND (is_cultivated_observation = 0 OR is_cultivated_observation IS NULL) AND is_location_cultivated IS NULL ",
    include_cultivated = "AND is_cultivated_observation = 1 ",
    any                = ""
  )
}

geovalid_clause <- function(on) if (on) "AND is_geovalid = 1 " else ""

count_mappable <- function(df) {
  if (!is.data.frame(df) || nrow(df) == 0) return(0L)
  lat <- suppressWarnings(as.numeric(df$latitude))
  lon <- suppressWarnings(as.numeric(df$longitude))
  sum(!is.na(lat) & !is.na(lon) & lat >= -90 & lat <= 90 & lon >= -180 & lon <= 180)
}

run_query <- function(species, native_mode, cult_mode, geovalid = TRUE,
                      limit = 1000, timeout_sec = 30) {
  q <- paste(
    "SELECT scrubbed_species_binomial,",
    "COALESCE(CASE WHEN latitude BETWEEN -90 AND 90 THEN latitude ELSE NULL END,",
    "         ST_Y(geom::geometry)) AS latitude,",
    "COALESCE(CASE WHEN longitude BETWEEN -180 AND 180 THEN longitude ELSE NULL END,",
    "         ST_X(geom::geometry)) AS longitude",
    "FROM view_full_occurrence_individual",
    "WHERE scrubbed_species_binomial IN (", sql_quote_literal(species), ")",
    natives_clause(native_mode),
    cultivated_clause(cult_mode),
    geovalid_clause(geovalid),
    "AND higher_plant_group NOT IN ('Algae','Bacteria','Fungi')",
    "AND scrubbed_species_binomial IS NOT NULL",
    if (limit <= 500) paste("LIMIT", limit, ";")
    else paste("ORDER BY random() LIMIT", limit, ";")
  )

  res <- tryCatch(
    withCallingHandlers(
      {
        r <- NULL
        setTimeLimit(elapsed = timeout_sec, transient = TRUE)
        on.exit(setTimeLimit(elapsed = Inf, transient = TRUE), add = TRUE)
        r <- BIEN:::.BIEN_sql(q, fetch.query = FALSE)
        r
      },
      error = function(e) e
    ),
    error = function(e) e
  )
  res
}

cat("BIEN connection confirmed.\n\n")

# ── Species pool ─────────────────────────────────────────────────────────────
test_species <- c(
  "Chimarrhis hookeri",
  "Cedrela angustifolia",
  "Hevea brasiliensis",
  "Clusia alata",
  "Annona montana",
  "Bunchosia armeniaca",
  "Guatteria excelsa",
  "Miconia calophylla",
  "Ficus pallida",
  "Capparis micracantha",
  "Clappertonia ficifolia",
  "Dacryodes costata",
  "Ilex cymosa",
  "Lasianthus attenuatus",
  "Ochrosia elliptica",
  "Popowia pisocarpa",
  "Quassia indica",
  "Aquilegia coerulea",
  # Extra known-tricky species from code comments
  "Solidago canadensis",
  "Eucalyptus globulus",
  "Tamarix ramosissima",
  "Pouteria reticulata",
  "Markhamia lutea"
)

# ── Profile configurations ────────────────────────────────────────────────────
# Each profile: label, native_mode, cult_mode, geovalid, limit
profiles <- list(
  list(label = "Standard",           native = "native_or_unknown", cult = "wild_only",          geo = TRUE,  limit = 1000),
  list(label = "Strict",             native = "native_only",       cult = "wild_only",          geo = TRUE,  limit = 500),
  list(label = "Custom-All-Wild",    native = "all_records",       cult = "wild_only",          geo = TRUE,  limit = 1000),
  list(label = "Custom-All-Any",     native = "all_records",       cult = "any",                geo = TRUE,  limit = 1000),
  list(label = "Custom-Native-Wild", native = "native_or_unknown", cult = "wild_only",          geo = TRUE,  limit = 1000)
)

# ── Run tests ─────────────────────────────────────────────────────────────────
results <- list()
cat(sprintf("%-25s | %-20s | %6s | %8s | %s\n",
            "Species", "Profile", "Rows", "Mappable", "Status"))
cat(strrep("-", 85), "\n")

for (sp in test_species) {
  for (prof in profiles) {
    res    <- run_query(sp, prof$native, prof$cult, prof$geo, prof$limit, timeout_sec = 35)
    is_err <- inherits(res, "error") || inherits(res, "simpleError")
    n_rows <- if (is_err || !is.data.frame(res)) 0L else nrow(res)
    n_map  <- if (is_err || !is.data.frame(res)) 0L else count_mappable(res)
    err_msg <- if (is_err) conditionMessage(res) else ""

    flag <- if (is_err)        paste("ERROR:", substr(err_msg, 1, 40))
            else if (n_rows == 0) "*** EMPTY ***"
            else if (n_map  == 0) "  (rows but no coords)"
            else ""

    cat(sprintf("%-25s | %-20s | %6d | %8d | %s\n",
                substr(sp, 1, 25), prof$label, n_rows, n_map, flag))

    results[[length(results) + 1]] <- data.frame(
      species = sp, profile = prof$label,
      rows = n_rows, mappable = n_map,
      error = err_msg, stringsAsFactors = FALSE
    )
  }
  cat(strrep("-", 85), "\n")
}

# ── Summary ───────────────────────────────────────────────────────────────────
all_results <- do.call(rbind, results)
empties  <- all_results[all_results$rows == 0 & nchar(all_results$error) == 0, ]
errors   <- all_results[nchar(all_results$error) > 0, ]
no_coord <- all_results[all_results$rows > 0 & all_results$mappable == 0, ]

cat("\n=== SUMMARY ===\n")
cat(sprintf("Total tests:           %d\n", nrow(all_results)))
cat(sprintf("Errors (DB/timeout):   %d\n", nrow(errors)))
cat(sprintf("Empty (0 rows, no err):%d\n", nrow(empties)))
cat(sprintf("Rows but no map coords:%d\n", nrow(no_coord)))

if (nrow(errors) > 0) {
  cat("\nErrors:\n"); print(errors[, c("species","profile","error")])
}
if (nrow(empties) > 0) {
  cat("\nEmpty results (expected for strict Old World species):\n")
  print(empties[, c("species","profile")])
}
if (nrow(no_coord) > 0) {
  cat("\nRows but no mappable coordinates:\n")
  print(no_coord[, c("species","profile","rows")])
}

out_path <- file.path(dirname(normalizePath("~")),
                      "VSCode/BIEN-SpeciesShinyApp/test_species_profiles_results.csv")
write.csv(all_results, out_path, row.names = FALSE)
cat("\nFull results written to:", out_path, "\n")
