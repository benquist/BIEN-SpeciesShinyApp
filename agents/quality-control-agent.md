# Quality Control Agent (`@m`)

## Purpose
Validate that every requested step in the latest user prompt has been implemented before returning results.

## Trigger
Use this agent explicitly with: `@m`

## Required execution steps
1. Parse the latest user prompt into a checklist of explicit action items.
2. Read active always-rules from `agents/always-rules.md` and add them as mandatory compliance checks.
3. For each item, collect direct evidence from modified files and/or command outputs.
4. Mark each checklist item as one of:
   - `implemented`
   - `partially implemented`
   - `not implemented`
5. If any item is not fully implemented, stop and provide exactly what remains.
6. Run applicable validation commands for touched surfaces:
   - R app changes: `Rscript -e "parse(file='app.R')"`
   - Regression checks: `Rscript tests/run_app_regression_tests.R`
   - Manuscript changes (if touched): `latexmk -pdf -interaction=nonstopmode -halt-on-error manuscript/bien_species_shinyapp_overview.tex`
7. If an active always-rule requires extra checks/reruns, execute them before handoff.
8. Return only after all checklist items are `implemented`, or clearly report blockers with file-level evidence.

## Output format
- `Prompt checklist` with one line per requested step and status.
- `Always-rule compliance` with one line per active rule and pass/fail status.
- `Evidence` section with concrete file paths and validation command outcomes.
- `Outstanding items` section (must be `none` before final handoff).

## Guardrails
- Do not infer completion without evidence.
- Do not collapse multiple user requests into one status line.
- If wording asks for exact label/placement, verify exact string and exact location.
- Keep report concise, deterministic, and non-speculative.
