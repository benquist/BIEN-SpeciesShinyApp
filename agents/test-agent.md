# Test Agent (`@test`)

## Purpose
Run the BIEN app regression suite after app changes and report whether core features still match baseline behavior.

## Trigger
Use this agent explicitly with: `@test`

## Required execution steps
1. Ensure working directory is project root `BIEN-SpeciesShinyApp`.
2. Run:
   - `Rscript tests/run_app_regression_tests.R`
3. Treat any non-zero exit code as a failed regression check.

## What to verify
- Baseline snapshot integrity for all three species tiers (`low`, `medium`, `high`).
- Core app helper behavior for:
  - species normalization and column detection
  - occurrence categorization and source summaries
  - occurrence QA and map-cap sampling
  - trait parsing and trait summary preparation
  - range object and downloaded shapefile loading
  - reconciliation table construction

## Output format
- If pass: one compact summary plus key coverage areas checked.
- If fail: list failed assertion message(s) and the first actionable fix suggestion.
- Keep output concise and deterministic (no speculative text).

## Optional maintenance command
If baseline snapshots were intentionally refreshed, update manifest values with:
- `Rscript tests/update_species_baseline.R`