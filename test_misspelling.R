#!/usr/bin/env Rscript
# Test script for typo-suggestion feature

library(BIEN)
library(stringr)
library(dplyr)

# Load helper functions
source("app.R")

cat("========================================\n")
cat("TYPO-SUGGESTION FEATURE TEST\n")
cat("========================================\n\n")

# Test case 1: Pinus pinderosa → Pinus ponderosa
cat("Test 1: 'Pinus pinderosa' (misspelled)\n")
cat("Expected: Suggestion for 'Pinus ponderosa'\n")
result1 <- find_best_species_spelling("Pinus pinderosa", timeout_sec = 20)
cat("Status:", result1$status, "\n")
if (result1$status == "suggested") {
  cat("✓ Suggested name: ", result1$suggested_name, "\n")
  cat("  Confidence: ", result1$confidence, "\n")
  cat("  Edit distance: ", result1$edit_distance, "\n")
} else {
  cat("Result details:", paste(names(result1), result1, sep="=", collapse="; "), "\n")
}

cat("\n---\n\n")

# Test case 2: Bistorta vivipera → Bistorta vivipara
cat("Test 2: 'Bistorta vivipera' (misspelled)\n")
cat("Expected: Suggestion for 'Bistorta vivipara'\n")
result2 <- find_best_species_spelling("Bistorta vivipera", timeout_sec = 20)
cat("Status:", result2$status, "\n")
if (result2$status == "suggested") {
  cat("✓ Suggested name: ", result2$suggested_name, "\n")
  cat("  Confidence: ", result2$confidence, "\n")
  cat("  Edit distance: ", result2$edit_distance, "\n")
} else {
  cat("Result details:", paste(names(result2), result2, sep="=", collapse="; "), "\n")
}

cat("\n---\n\n")

# Test case 3: Exact match (no suggestion needed)
cat("Test 3: 'Pinus ponderosa' (correct spelling)\n")
cat("Expected: exact_match_found (no suggestion)\n")
result3 <- find_best_species_spelling("Pinus ponderosa", timeout_sec = 20)
cat("Status:", result3$status, "\n")
if (result3$status == "exact_match_found") {
  cat("✓ Exact taxon exists in BIEN; no spelling correction offered\n")
} else if (!is.null(result3$suggested_name)) {
  cat("Suggested name: ", result3$suggested_name, "\n")
} else {
  cat("(No suggestion, as expected)\n")
}

cat("\n========================================\n")
cat("TEST COMPLETE\n")
cat("========================================\n")
