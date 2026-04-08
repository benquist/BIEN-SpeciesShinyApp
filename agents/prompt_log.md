# Prompt Log

- Date: 2026-04-06
- Prompt summary: User requested replacing reporting-rule style guidance with exact reproducible code for downloaded app dataset, with plain-language summary embedded in code file.
- Requested outcomes: Add app feature to export exact dataset and matching reproducible R code, and align manuscript section accordingly.
- Result: Added CSV + reproducible script download actions in BIEN Query Code tab, replaced code panel output with exact dataset-reproduction script generator, and replaced manuscript reporting-checklist section with reproducible code export section.
- Files changed: app.R; manuscript/bien_species_shinyapp_overview.tex; agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-06
- Prompt summary: User requested word-count expansion (excluding references), two writing agents (accuracy + concise/plain/no-jargon), and app-use steps as a list.
- Requested outcomes: Add detail to manuscript body, convert usage steps from subsections to list format, create two writing-agent docs.
- Result: Replaced step subsections with an ordered list plus practical guidance paragraphs; added `agents/accuracy-writer-agent.md` and `agents/plain-concise-writer-agent.md`.
- Files changed: manuscript/bien_species_shinyapp_overview.tex; agents/accuracy-writer-agent.md; agents/plain-concise-writer-agent.md; agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-06
- Prompt summary: User requested option #2 for a documented agent/persona that always adds a weird, funny, non-abusive signoff and addresses user as Brian.
- Requested outcomes: Add documented agent behavior file in repo and begin using it in responses.
- Result: Added `agents/funny-signoff-agent.md` with explicit non-abusive rules, signoff pool, and output template.
- Files changed: agents/funny-signoff-agent.md; agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: Re-run mandatory final pre-return checks now after post-lucky query-hang fix.
- Requested outcomes: Verify prompt log, Rmd/package applicability, and git push status in both repos.
- Files changed: BIEN-SpeciesShinyApp/agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: Diagnose why I'm Feeling Lucky appears to query default poppy species instead of selected random species.
- Requested outcomes: Read-only trace observeEvent feeling_lucky_species, updateTextInput species update path, and bien_results dependencies; return root cause and concrete patch.
- Files changed: None (read-only diagnosis)
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: Run mandatory final pre-return checks for this turn after deep-dive lucky query hang fix.
- Requested outcomes: Verify prompt log, Rmd compile applicability, package build applicability, and git push status; return PASS/BLOCKED with concise evidence.
- Files changed: BIEN-SpeciesShinyApp/agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: User asked if latest changes were uploaded to shinyapps.
- Requested outcomes: Confirm live deployment status and app reachability.
- Result: Verified shinyapps endpoint is live (HTTP 200) and repo is synced.
- Files changed: agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: User reported slow Lupinus response with incorrect fallback note '(none)' and broken mapped fraction text.
- Requested outcomes: Fix incorrect fallback notice logic and mapped fraction display issue.
- Result: Fallback notice now only appears for true fallback strategies; mapped fraction notices now guard against NA/NaN values.
- Files changed: app.R; rsconnect/shinyapps.io/benquist/bien-species-shinyapp.dcf; agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: Mandatory final pre-return checks after Lupinus summary bug fix deployment.
- Requested outcomes: Verify prompt log, Rmd/package applicability, and git push status for commit 45bb808.
- Files changed: agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: User asked whether the newest fix is deployed.
- Requested outcomes: Confirm shinyapps deployment status and repo sync.
- Result: Verified live endpoint returns HTTP 200 and repo is synced to origin/main.
- Files changed: agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: Mandatory final pre-return checks after deployment-status verification.
- Requested outcomes: Verify prompt log, Rmd/package applicability, and git push status for BIEN repo.
- Files changed: agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: User requested Lucky-picked species to query all BIEN records instead of plot-only.
- Requested outcomes: Ensure Lucky disables plot-only filtering so random species query behaves like normal BIEN query scope.
- Result: Lucky now forces only_plot_observations = FALSE before query; code pushed. shinyapps deploy currently blocked by transient HTTP 409 task lock.
- Files changed: app.R; rsconnect/shinyapps.io/benquist/bien-species-shinyapp.dcf; agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: Mandatory final pre-return checks for Lucky all-categories query change.
- Requested outcomes: Verify prompt log, Rmd compile applicability, package build applicability, and git push status.
- Context/result: Implemented Lucky plot-filter reset change at commit 2a80413; shinyapps deploy currently blocked by transient HTTP 409 task lock.
- Files changed: agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: User reported Juniperus virginiana causes app freeze/hang and requested diagnosis.
- Requested outcomes: Diagnose likely root cause and harden query path to avoid freeze.
- Result: Added strict total query budget and fail-fast break on timeout/pending-row backend errors; verified Juniperus now exits with backend_timeout_error instead of hanging; deployed successfully.
- Files changed: app.R; rsconnect/shinyapps.io/benquist/bien-species-shinyapp.dcf; agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: Mandatory final pre-return checks after Juniperus freeze diagnosis and fix.
- Requested outcomes: Verify prompt log, Rmd/package applicability, and git push status for current BIEN head.
- Files changed: agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: Re-run mandatory final pre-return checks now.
- Requested outcomes: Verify prompt log, Rmd compile applicability, package build applicability, and git push status for Juniperus fix context (head e828096).
- Files changed: agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: Re-run mandatory final pre-return checks for Juniperus fix context at head 68a72a3.
- Requested outcomes: Verify prompt log, Rmd compile applicability, package build applicability, and git push status; return PASS/BLOCKED with concise evidence.
- Files changed: agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: User selected option 1 to commit and push pending BIEN repo files.
- Requested outcomes: Commit and push agents/agent_chat_provenance_log.txt, agents/prompt_log.md, and rsconnect metadata updates.
- Result: Committed and pushed at b4f8354; repo synced with origin/main.
- Files changed: agents/agent_chat_provenance_log.txt; agents/prompt_log.md; rsconnect/shinyapps.io/benquist/bien-species-shinyapp.dcf
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: User reported app spins on reopen after closing during a long run.
- Requested outcomes: Diagnose startup/reopen freeze and restore responsiveness.
- Result: Identified BIEN SQL error on missing basisofrecord column from source-mix query; removed that column from BIEN-side SQL and redeployed. App now returns HTTP 200 with fast start-transfer.
- Files changed: app.R; rsconnect/shinyapps.io/benquist/bien-species-shinyapp.dcf; agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-04
- Prompt summary: Run mandatory final pre-return checks for reopen-spin fix context after basisofrecord SQL correction and redeploy.
- Requested outcomes: Verify prompt log, Rmd compile applicability, package build applicability, and git push status; return PASS/BLOCKED with concise evidence.
- Files changed: agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-06
- Prompt summary: User reported 'I'm Feeling Lucky' button is not working correctly.
- Requested outcomes: Fix the Lucky button so it works with current timeout settings.
- Root cause: Lucky button was setting query_timeout to 10-15 seconds (old hardcoded values), but recent timeout fix updated defaults to 150s/min 45s, breaking Lucky mode.
- Fix: Updated Lucky button to set query_timeout = 75 seconds. Parse check PASS. Deployed to shinyapps.io commit 74c0d08. App HTTP 200 confirmed.
- Files changed: app.R; rsconnect/shinyapps.io/benquist/bien-species-shinyapp.dcf; agents/prompt_log.md
- Completed by: GitHub Copilot

- Date: 2026-04-08
- Prompt summary: User asked to check collaborator GitHub update, rebuild/launch the new app, and preserve the latest temporal-distribution build.
- Requested outcomes: (1) Fetch and inspect collaborator update; (2) rebuild and launch updated Shiny app; (3) preserve existing temporal distribution tab and latest behavior.
- Result: Fetched origin/main and fast-forwarded to collaborator commit 43c6f17. Created safety backups before pull (tag: backup-temporal-build-2026-04-08, branch: backup/temporal-build-2026-04-08) and stashed untracked local diagnostics. Verified collaborator update removed temporal tab, then restored temporal feature in updated codebase (added ggplot2 dependency, temporal helper functions, Temporal Distribution tab UI, server outputs). Synced root app and package app (app.R and inst/app/app.R), rebuilt package via R CMD INSTALL, and launched via BIENSpeciesShinyApp::runApp() on localhost with HTTP 200.
