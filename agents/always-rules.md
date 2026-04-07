# Always Rules Registry

This file tracks persistent user instructions that must be enforced on every prompt.

## Active rules

| Rule ID | Recorded | Rule | Required checks / commands | Status |
|---|---|---|---|---|
| A001 | 2026-04-06 | For each prompt that changes app code/UI, run full validation before handoff. | `Rscript -e "parse(file='app.R')"`; `Rscript tests/run_app_regression_tests.R`; Shiny startup smoke check (`shiny::runApp(...)` then stop). | active |
| A002 | 2026-04-06 | Screenshots for manuscript must always use the current local app version, not a stale deployed copy. | Run screenshot capture against `http://127.0.0.1:8787`; enforce layout guard in `manuscript/capture_figures.py` (must include `Observations` and must not expose legacy `Summary Statistics` tab). | active |
| A003 | 2026-04-06 | New user instructions explicitly flagged with “always” must be recorded and enforced for future prompts. | Parse latest prompt for `always` intent; append/update rule here; include compliance check in final handoff. | active |

## Change log
- 2026-04-06: Initialized registry with current persistent workflow rules.
