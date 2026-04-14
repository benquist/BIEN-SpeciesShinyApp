# BIEN Shiny App Chat Provenance Log

Tracks prompts that created or changed work under this project folder.

## Entries

1. Date: 2026-03-30
Prompt: Lets create a new project in a new folder called BIEN Shiny App. Use the BIEN R Package for biendata.org. I would like to make a shiny app where we a user can query for a given species and the shiny app then plots the observation points on a map. THe map can be scaled at different geographic scales. Suggest some important ways that one can explore the species level data for each species. You can query species for traits, and geographic ranges too. The shiny app will allow the user to explore species-level observation data
Source session: current workspace session
Outcome: Created a new BIEN-based Shiny app project with species query, occurrence mapping, trait exploration, range query display, and project documentation.

2. Date: 2026-04-01
Prompt: For the Overview tab, move the occurrence map and the summary statistics onto separate tabs, with the occurrence map first on the tab bar and the statistics after it.
Source session: current workspace session
Outcome: Updated the Shiny UI so the first tab now leads with the occurrence map and the summary statistics appear in their own separate tab.

3. Date: 2026-04-01
Prompt: Speed up slow BIEN species queries, explain to users why some species take longer, and rewrite the native/introduced, cultivated, and geovalid toggles so it is clear which occurrence records are being shown or hidden.
Source session: current workspace session
Outcome: Updated the app with clearer filter labels, more explicit progress/wait messaging, query timing reporting, session caching for repeated searches, and a slower optional range lookup that is now off by default.

4. Date: 2026-04-01
Prompt: Do a second-pass speed optimization focused on lazy-loading BIEN trait and range data only when those tabs are opened.
Source session: current workspace session
Outcome: Refactored the app so the first query now loads occurrences and summary counts first, while the Traits and Range tabs fetch their BIEN data on demand and reuse cached results afterward.

5. Date: 2026-04-01
Prompt: The Shiny app is hung up and frozen.
Source session: current workspace session
Outcome: Removed the count-only BIEN summary queries from the first-load critical path and moved them to on-demand loading in the Summary Statistics tab so the app stays responsive sooner.

6. Date: 2026-04-01
Prompt: Push the new BIEN app details to GitHub, make sure the README is detailed, and add a summarized statement of what records the user is looking at based on the selected filters, including the default biodiversity-oriented setting.
Source session: current workspace session
Outcome: Added a plain-language filter summary panel to the app sidebar, documented the default conservative ecological filter profile and on-demand loading behavior in the README, and prepared the BIEN app updates for GitHub publication.

7. Date: 2026-04-01
Prompt: The app froze again, especially around Summary Statistics.
Source session: current workspace session
Outcome: Changed the BIEN count-only total and source-fraction fetch to a manual button-triggered action in the Summary Statistics tab so opening the tab no longer blocks the whole app.

8. Date: 2026-04-01
Prompt: Make sure the code is commented, README files are updated and useful, clarify that users must click Query BIEN again after changing filters, and push the latest BIEN app updates to GitHub.
Source session: current workspace session
Outcome: Added clearer inline comments to the Shiny app code, expanded the BIEN app README and workspace README, added an explicit re-query notice for filter changes, and prepared the latest app polish updates for publication.

9. Date: 2026-04-01
Prompt: Investigate why some species such as `Juniperus communis` and `Pinus ponderosa` appear overly dominated by plot/FIA records in the returned occurrence sample, and fix the sampling bias if possible.
Source session: current workspace session
Outcome: Verified that the old BIEN occurrence fetch was pulling the first backend rows without randomized ordering, then updated the app to use a randomized occurrence query and exclude trait-linked rows from the main occurrence map/table so the sample better reflects the full BIEN matching pool.

10. Date: 2026-04-01
Prompt: Add balanced occurrence-display sampling by datasource or observation type, then investigate why `Juniperus communis` returned no observations during live app testing.
Source session: current workspace session
Outcome: Added stratified display-sampling controls for occurrence maps/tables, confirmed that the live failure was caused by BIEN public database connection-slot exhaustion rather than a true species-level absence, and updated the app to show a clear backend-capacity warning with retry guidance.

11. Date: 2026-04-01
Prompt: Clarify whether the BIEN app changes were being pushed to the wrong repository and separate the mixed repo setup if needed.
Source session: current workspace session
Outcome: Verified that the BIEN app folder was still nested under the `biodiversity-agents-lab` monorepo, then synced the current app files into the dedicated `BIEN-SpeciesShinyApp` repository so future BIEN app work can be maintained separately.

12. Date: 2026-04-01
Prompt: Confirm whether BIEN is truly down versus an app issue, then add a retry mechanism when connection-capacity errors occur.
Source session: current workspace session
Outcome: Confirmed the BIEN public database connection-slot error with direct BIEN package calls outside the app UI, then added a `Retry BIEN connection (with backoff)` button and exponential-backoff retries in the occurrence query path, plus README guidance for using this retry workflow.

13. Date: 2026-04-09
Prompt: On the shiny app, for the Settings Filters toggle, the information symbol is not working on hover or click; add pertinent information for each toggle.
Source session: current workspace session
Outcome: Updated filter/help labels to use initialized Bootstrap tooltips and added client-side tooltip initialization so each info icon now shows its explanatory text on hover, focus, or click.

14. Date: 2026-04-09
Prompt: Yes (apply the offered wording improvements for settings tooltip text).
Source session: current workspace session
Outcome: Revised Settings/Filters tooltip copy to be more ecologically explicit, including clearer native/introduced, cultivated, plot-only, geovalid, and human-observation guidance.

15. Date: 2026-04-09
Prompt: Just checked the shiny app and it did not work; please check.
Source session: current workspace session
Outcome: Added cross-framework tooltip compatibility (Bootstrap data attributes plus framework-independent JavaScript fallback tooltip behavior) so Settings info icons work on hover/focus/click even when Bootstrap tooltip plugins are unavailable or version-mismatched, then redeployed to shinyapps.io and confirmed the app is running.

16. Date: 2026-04-09
Prompt: Looks like the shiny app is frozen.
Source session: current workspace session
Outcome: Diagnosed timeout logs tied to sequential BIEN COUNT prechecks in the random-species workflow, changed Lucky selection to an instant curated pick with no blocking BIEN precheck queries, and redeployed to shinyapps.io.

17. Date: 2026-04-09
Prompt: Tooltip hover info now shows two popups (white and black), and the black one does not disappear on mouse leave.
Source session: current workspace session
Outcome: Removed Bootstrap/native tooltip attributes and Bootstrap tooltip initialization from settings info icons so only one custom tooltip system renders and dismisses cleanly.

18. Date: 2026-04-09
Prompt: For the BIEN shiny app species external links, add a link to the species iNaturalist page in addition to other sites.
Source session: current workspace session
Outcome: Added an iNaturalist external-link card to the Species External Links panel, using the current species name to generate an iNaturalist taxon search URL while preserving the existing Wikipedia, POWO, Missouri Botanical Garden, and World Flora Online links.

19. Date: 2026-04-09
Prompt: Add AsianPlant.net to Species External Links, but only show the link when the queried species occurs on that site.
Source session: current workspace session
Outcome: Added a cached AsianPlant species-index lookup from asianplant.net/Species.htm and rendered an AsianPlant external-link card only when an exact binomial match exists for the current species.

## Update Rule
Append a new entry whenever prompts lead to created/modified app code, BIEN query logic, or documentation under BIEN Shiny App/.

20. Date: 2026-04-09
Prompt: Add more species to the random species select list (Capparis micracantha, Clappertonia ficifolia, Dacryodes costata, Ilex cymosa, Lasianthus attenuatus, Ochrosia elliptica, Popowia pisocarpa, Quassia indica, Aquilegia coerulea).
Source session: current workspace session
Outcome: Appended nine new species to the curated random-species starter pool used by the random species button.

21. Date: 2026-04-12
Prompt: Update the Overview/About Occurrence Map copy to mention toggling geo-validated and native/non-native records.
Source session: current workspace session
Outcome: Replaced the Occurrence Map card description text with the requested wording focused on species-level records and filter toggles.

22. Date: 2026-04-13
Prompt: We have an error message in the Temporal Distribution tab: "Temporal stats - An error has occurred. Check your logs or contact the app author for clarification." Why is this? Can you fix it?
Source session: current workspace session
Outcome: Fixed a NULL-reference error in the `output$temporal_stats <- renderUI({...})` handler that occurred when bien_results() returned NULL (e.g., before any species query). Added `req(bien_results())` to gracefully prevent rendering until valid results are available, matching the pattern used in other reactive handlers in the app.

23. Date: 2026-04-13
Prompt: I dont think the error is fixed. We are still seeing it
Source session: current workspace session
Outcome: Diagnosed the remaining Temporal stats runtime error from shinyapps logs (unsupported `sprintf("%,d")` format in `output$temporal_stats`). Replaced it with a safe thousands-separated label via `format(..., big.mark = ",")`, then redeployed the app.

24. Date: 2026-04-14
Prompt: For the BIEN shiny app, timeouts/blank maps still happen for species like Capparis micracantha and Ochrosia elliptica under Conservative default profile; make it clear when effective query settings are auto-relaxed.
Source session: current workspace session
Outcome: Added explicit "Requested vs effective BIEN profile" messaging in query summary and adjusted Lucky-mode query planning to keep fallback strategies enabled (`max_plans = 3`, shorter per-plan timeout) so strict timeouts can still auto-relax and recover mappable records in the same query run.

25. Date: 2026-04-14
Prompt: Annona montana still loads slowly then returns a blank map; auto-run one relaxed fallback pass on timeout or zero mappable points, and notify users when effective settings are auto-relaxed.
Source session: current workspace session
Outcome: Added automatic strict-to-relaxed-geo fallback trigger when strict run yields zero mappable coordinates or timeout indications, while preserving the visible conservative toggle as requested. Added explicit warning notifications describing that conservative remained selected but effective query settings were auto-relaxed to recover records/map points.
