# BIEN Species App — UI Design Specification
**Date:** 2025-07-30  
**Authors:** design-atelier agent + ecology-user agent (synthesized)  
**Based on:** Multi-round scientific review (ecology-user, biodiversity-science-guard, coder, telford-statistical-ecology, biodiversity-informatics-audit)  
**Status:** Ready for implementation

---

## Overview

This specification defines all user-facing text, visual component design, and Shiny/bslib implementation structure for the BIEN Species Shiny App UI redesign. All text has been validated against MEE 2026 (doi:10.1111/2041-210x.70274) flag semantics. All component specs are achievable with Bootstrap 5 (bslib), Shiny, and htmltools — no additional JS frameworks required.

---

## 1. CSS Token System

Add to the existing `tags$style()` block in `ui`:

```css
:root {
  /* Existing tokens (preserve) */
  --bien-blue:       #2f79b7;
  --bien-blue-deep:  #1f5b8f;
  --bien-green:      #74b64a;
  --bien-green-deep: #4e8c2c;

  /* Disclosure semantic tokens (new) */
  --disc-green:        #15803d;
  --disc-green-bg:     #f0fdf4;
  --disc-green-border: #86efac;

  --disc-amber:        #b45309;
  --disc-amber-bg:     #fffbeb;
  --disc-amber-border: #fcd34d;

  --disc-orange:       #c2410c;
  --disc-orange-bg:    #fff7ed;
  --disc-orange-border: #fb923c;

  --disc-red:          #be123c;
  --disc-red-bg:       #fff1f2;
  --disc-red-border:   #fda4af;

  --disc-gray:         #6b7280;
  --disc-gray-bg:      #f9fafb;
  --disc-gray-border:  #d1d5db;
}
```

---

## 2. Color Semantic Roles

| Semantic | Token | Use |
|---|---|---|
| Confirmed native / geovalid / strict pass | `--disc-green` | Map points, chip, profile badge |
| Caution / fallback / NSR-unevaluated | `--disc-amber` | Fallback banner, profile limitation pills |
| Degraded / centroid-heavy | `--disc-orange` | Tier 3–4 banner, high centroid chip |
| Confirmed introduced / problem | `--disc-red` | Map points, introduced count in banner |
| Unknown / NULL / unassessed | `--disc-gray` | Map points, NULL legend entries |

### Map Point Color Roles

| `is_introduced` value | Hex | Map marker |
|---|---|---|
| `0` (NSR-confirmed non-introduced) | `#22c55e` | Green |
| `NULL` (NSR-unevaluated) | `#94a3b8` | Gray |
| `1` (confirmed introduced) | `#f43f5e` | Red |

---

## 3. Typography Hierarchy

| Role | Size | Weight | Color |
|---|---|---|---|
| Profile name badge | 0.82em | 700 | Token foreground |
| Profile description | 0.84em | 400 | `#374151` |
| Limitation caveat | 0.76em | 400 | `#6b7280` |
| Banner headline | 0.9em | 600 | Token foreground |
| Banner body | 0.82em | 400 | `#374151` |
| Quality chip label | 0.78em | 500 | `#888` |
| Quality chip value | 0.78em | 700 | Token foreground |
| SDM section heading | 0.87em | 600 | `#374151` |

---

## 4. Component CSS (add to `tags$style()`)

```css
/* === Profile selector cards === */
.profile-card {
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 10px 14px;
  margin-bottom: 6px;
  cursor: pointer;
  transition: border-color 0.1s;
}
.profile-card.selected-standard { border-color: var(--bien-blue); background: #f0f7ff; }
.profile-card.selected-strict   { border-color: var(--disc-green); background: #f0fdf4; }
.profile-card.selected-custom   { border-color: #7c3aed; background: #faf5ff; }
.profile-badge {
  display: inline-block;
  font-size: 0.80em;
  font-weight: 700;
  letter-spacing: 0.05em;
  padding: 1px 7px;
  border-radius: 10px;
  margin-right: 6px;
  vertical-align: middle;
}
.badge-standard { background: #dbeafe; color: #1d4ed8; }
.badge-strict   { background: #dcfce7; color: #15803d; }
.badge-custom   { background: #ede9fe; color: #6d28d9; }
.badge-indicator {
  display: inline-block;
  font-size: 0.72em;
  font-weight: 600;
  padding: 1px 6px;
  border-radius: 8px;
  margin-left: 4px;
  vertical-align: middle;
}
.ind-fallback { background: #fef9c3; color: #854d0e; border: 1px solid #fde047; }
.ind-nocap    { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }
.profile-desc { font-size: 0.84em; color: #374151; margin: 4px 0 0 0; }
.profile-caveat { font-size: 0.76em; color: #6b7280; margin-top: 2px; display: block; }
.profile-limits details { margin-top: 4px; }
.profile-limits summary {
  font-size: 0.76em;
  color: #9ca3af;
  cursor: pointer;
  list-style: none;
}
.profile-limits summary::-webkit-details-marker { display: none; }
.profile-limits summary::before { content: '▸ '; font-size: 0.9em; }
.profile-limits[open] summary::before { content: '▾ '; }
.profile-limits-body { font-size: 0.76em; color: #6b7280; padding: 4px 0 2px 10px; line-height: 1.6; }

/* === Fallback banner === */
.fb-banner {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  border-radius: 0 4px 4px 0;
  padding: 10px 16px;
  margin-bottom: 12px;
  border-left-width: 4px;
  border-left-style: solid;
}
.fb-banner-amber {
  background: var(--disc-amber-bg);
  border: 1px solid var(--disc-amber-border);
  border-left: 4px solid var(--disc-amber);
}
.fb-banner-orange {
  background: var(--disc-orange-bg);
  border: 1px solid var(--disc-orange-border);
  border-left: 4px solid var(--disc-orange);
}
.fb-banner-icon { font-size: 1.1em; flex-shrink: 0; margin-top: 1px; }
.fb-banner-headline { font-size: 0.87em; font-weight: 600; color: var(--disc-amber); margin: 0 0 2px 0; }
.fb-banner-orange .fb-banner-headline { color: var(--disc-orange); }
.fb-banner-body { font-size: 0.82em; color: #374151; margin: 0; line-height: 1.55; }
.fb-banner-introduced { display: inline; font-weight: 700; color: var(--disc-red); }

/* === Quality chip color variants === */
.qa-chip.qa-green  { background: var(--disc-green-bg);  border-color: var(--disc-green-border); }
.qa-chip.qa-green  .qa-value { color: var(--disc-green); }
.qa-chip.qa-amber  { background: var(--disc-amber-bg);  border-color: var(--disc-amber-border); }
.qa-chip.qa-amber  .qa-value { color: var(--disc-amber); }
.qa-chip.qa-orange { background: var(--disc-orange-bg); border-color: var(--disc-orange-border); }
.qa-chip.qa-orange .qa-value { color: var(--disc-orange); }
.qa-chip.qa-red    { background: var(--disc-red-bg);    border-color: var(--disc-red-border); }
.qa-chip.qa-red    .qa-value { color: var(--disc-red); }
.qa-chip.qa-gray   { background: var(--disc-gray-bg);   border-color: var(--disc-gray-border); }
.qa-chip.qa-gray   .qa-value { color: var(--disc-gray); }

/* === Flag composition bar === */
.flag-comp-bar-wrap { margin: 6px 0 2px 0; }
.flag-comp-bar {
  display: flex;
  height: 10px;
  border-radius: 5px;
  overflow: hidden;
  width: 100%;
  margin-bottom: 4px;
}
.flag-comp-bar-seg { transition: width 0.2s; }
.flag-comp-legend { display: flex; flex-wrap: wrap; gap: 8px; font-size: 0.76em; color: #374151; }
.flag-comp-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 3px;
  vertical-align: middle;
}

/* === Strict mode empty state === */
.strict-empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
  text-align: center;
  color: #374151;
}
.strict-empty-icon { font-size: 2.4em; margin-bottom: 12px; color: #9ca3af; }
.strict-empty-headline { font-size: 1.1em; font-weight: 700; color: #111827; margin-bottom: 8px; }
.strict-empty-body { font-size: 0.87em; color: #6b7280; max-width: 420px; line-height: 1.6; }
.strict-empty-oldworld {
  margin-top: 16px;
  background: var(--disc-amber-bg);
  border: 1px solid var(--disc-amber-border);
  border-radius: 6px;
  padding: 10px 16px;
  font-size: 0.84em;
  color: var(--disc-amber);
  max-width: 420px;
}
.strict-empty-actions { margin-top: 20px; display: flex; gap: 10px; }

/* === SDM guidance panel === */
.sdm-guidance-panel {
  border: 1px solid var(--disc-amber-border);
  border-radius: 6px;
  margin-bottom: 18px;
  overflow: hidden;
}
.sdm-guidance-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  background: var(--disc-amber-bg);
  cursor: pointer;
  font-size: 0.87em;
  font-weight: 600;
  color: var(--disc-amber);
  list-style: none;
}
.sdm-guidance-header::-webkit-details-marker { display: none; }
.sdm-guidance-body { padding: 12px 16px; background: #fff; font-size: 0.83em; color: #374151; line-height: 1.65; }
.sdm-note-row {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 5px 0;
  border-bottom: 1px solid #f3f4f6;
}
.sdm-note-row:last-child { border-bottom: none; }
.sdm-note-icon { flex-shrink: 0; font-size: 1em; margin-top: 1px; }
.sdm-note-text { flex: 1; }
.sdm-note-value { font-weight: 600; color: #111827; }
```

---

## 5. Element Specifications

### 5.1 Profile Selector Cards

**Replace:** `radioButtons("data_profile", ...)` in `sidebarPanel`  
**With:** Custom HTML cards backed by a hidden radio input, synced via JavaScript

**Card anatomy:**
```
┌─ [radio] ─────────────────────────────────────────────┐
│  ● STANDARD  [Auto-fallback enabled]                   │
│  Confirmed non-introduced or NSR-unevaluated records;  │
│  cultivation-unassessed records included; geovalid.    │
│  Filters auto-relax if no results found.               │
│  ▸ Limitations  (collapsed by default)                 │
└────────────────────────────────────────────────────────┘
```

#### Exact Text

**Standard:**
- Badge: `STANDARD`
- Indicator pill: `Auto-fallback enabled`
- Short description: *"Confirmed non-introduced or NSR-unevaluated records; cultivation-unassessed records included; geovalid. Filters auto-relax if no results found."*
- Limitations (expandable, bullet list):
  1. *"NSR-unevaluated ≠ confirmed native. Records where introduced status is NULL have not been assessed by the BIEN Native Species Resolver (NSR); they are not confirmed non-introduced and may represent introduced populations."*
  2. *"Cultivation-unassessed records are included. The default filter passes is_cultivated IS NULL — these are not confirmed wild occurrences. Botanical garden material may be present."*
  3. *"Filters auto-relax via a fallback ladder. If no records are found, the app progressively drops the introduced-status filter, then the geovalid requirement, then the coordinate-precision requirement. An amber banner appears when fallback occurs."*
  4. *"BIEN covers the Western Hemisphere only. For Old World species, Standard may return only the invaded Americas range."*

**Strict:**
- Badge: `STRICT`
- Indicator pill: `500-record cap · No fallback`
- Short description: *"NSR-confirmed non-introduced; confirmed wild; geovalid. 500-record cap. No filter relaxation. Empty result is a valid outcome."*
- Limitations (expandable, bullet list):
  1. *"500-record cap in natural table order. Strict returns at most 500 records in database ingestion order — not spatially random. Apply spatial thinning before SDM use."*
  2. *"Centroid status is not fully resolved. is_centroid IS NULL records pass Strict. These may include county- or polygon-center coordinates with 10–100 km positional uncertainty."*
  3. *"Old World taxa will often return zero records. BIEN NSR coverage is primarily for the Western Hemisphere. Zero records in Strict does not mean the species is absent from BIEN."*
  4. *"Reproducibility requires recording the database version. Re-running later may return different records. Record version with BIEN_metadata_database_version() in R."*

**Custom:**
- Badge: `CUSTOM`
- Indicator pill: `Manual filter controls`
- Short description: *"Set your own introduced-status, cultivation-status, and coordinate-precision filters manually."*
- Caveat: *"Custom mode does not enforce any minimum data quality thresholds. Fallback does not occur — if your filter combination returns no records, the query returns empty without a warning banner."*

---

### 5.2 Filter Control Labels

#### Native/Introduced Filter

| Option | Label | Sub-label |
|---|---|---|
| `is_introduced = 0 OR NULL` | **Non-introduced or NSR-unevaluated** | Includes confirmed non-introduced and records not yet assessed by BIEN NSR |
| `is_introduced = 0` | **NSR-confirmed non-introduced only** | Restricts to records BIEN NSR has explicitly confirmed are not introduced |

**Tooltip (?):**  
*"The BIEN Native Species Resolver (NSR) cross-references each occurrence record against regional checklists to classify it as introduced (is_introduced = 1) or non-introduced (is_introduced = 0); records not yet assessed are coded NULL. A NULL value does not mean confirmed native — it means NSR has not yet evaluated that record; include NULL records to maximize sample size, or select 'NSR-confirmed only' for a more conservative dataset."*

#### Cultivation Filter

| Option | Label | Sub-label |
|---|---|---|
| `is_cultivated = 0 OR NULL` *(default)* | **Wild or cultivation-unassessed** | Excludes confirmed cultivated records; includes records where cultivated status has not been evaluated |
| Include cultivated | **Include confirmed cultivated records** | Adds records flagged is_cultivated = 1 (e.g., botanical garden collections) |

**Tooltip (?):**  
*"The BIEN database flags confirmed cultivated records (is_cultivated = 1), but many records have not been evaluated for cultivated status (is_cultivated IS NULL). The default filter passes these unevaluated records alongside confirmed wild records — they are not confirmed wild, only unassessed. If your analysis strictly requires wild occurrences, use the Strict profile, which requires is_cultivated = 0."*

#### Centroid / Precision Filter

**Label:** Coordinate precision — centroid records

**Tooltip:**  
*"Records flagged is_centroid = 1 represent political unit centroids (county, municipality, or grid cell centers) rather than precise locality coordinates; positional uncertainty is typically 10–100 km. Records where centroid status is NULL (unassessed) are passed by Standard and Strict modes — they have not been confirmed as non-centroid and may include undocumented centroids. For fine-resolution modeling, download and filter by is_centroid manually."*

#### Geovalid Filter

**Label:** Geovalid coordinates only

**Tooltip:**  
*"Geovalid records have coordinates that (1) fall within the known political boundary of the reported country or state, (2) pass basic range checks, and (3) are not placed in the ocean for terrestrial taxa. Uncheck this only if you need records with uncertain geographic provenance and understand that coordinate–country mismatches will be present."*

---

### 5.3 Fallback Banner

**Placement:** `uiOutput("fallback_banner_ui")` inserted before `tabsetPanel()` in `mainPanel()`. Persistent — no auto-dismiss.

#### Tier 1 — Native filter relaxed

**Header (amber):** `⚠ FALLBACK ACTIVE · Tier 1: introduced-status filter relaxed`

**Body:**  
*"No records were found when restricting to non-introduced or NSR-unevaluated records. The app has automatically dropped the introduced-status requirement; results now include all records regardless of BIEN NSR classification — including occurrences confirmed as introduced (is_introduced = 1). These may represent an invasive or cultivated-escape range rather than a native range, and are not appropriate for native-range SDMs without further filtering. Before analysis, inspect the is_introduced column in your download to understand what proportion of records are confirmed non-introduced, NSR-unevaluated, or confirmed introduced."*

**Action link:** `What does including introduced records mean for species distribution models? ▸`

#### Tier 2 — Native + geovalid relaxed

**Header (amber):** `⚠ FALLBACK ACTIVE · Tier 2: introduced-status filter and geovalid requirement relaxed`

**Body:**  
*"No records were found after relaxing the introduced-status filter alone. The app has additionally dropped the geovalid requirement; results may now include records with coordinate–country boundary mismatches or ocean-flagged coordinates for terrestrial taxa. Records may include confirmed-invasive occurrences and have reduced geographic precision. Inspect both the is_introduced and is_geovalid columns in your download before proceeding."*

#### Tier 3–4 — All filters relaxed, centroids included

**Header (orange):** `🟠 FALLBACK ACTIVE · Tier 3–4: filters maximally relaxed — centroid and low-precision records included`

**Body:**  
*"No records were found at higher filter levels. All filters have been dropped: the introduced-status filter, geovalid requirement, and coordinate-precision requirement. Results may now include county-centroid or political-unit-centroid records with positional uncertainty of approximately 10–100 km. These records are generally not suitable for fine-resolution SDMs or precise range mapping without additional filtering. Review the is_centroid, is_geovalid, and is_introduced columns in your download carefully."*

---

### 5.4 Map Legend: `is_introduced` Color Coding

Three legend rows (replace existing legend):

| `is_introduced` | Color | Legend label | Tooltip |
|---|---|---|---|
| `0` | Green `#22c55e` | NSR-confirmed non-introduced | Confirmed non-introduced |
| `NULL` | Gray `#94a3b8` | NSR-unevaluated (status unknown) | BIEN NSR has not assessed whether this record is native or introduced. This is the most common value in BIEN. It does not mean confirmed native. |
| `1` | Red `#f43f5e` | NSR-confirmed introduced | Confirmed introduced |

**Caption below map:**  
*"Gray (NSR-unevaluated) ≠ confirmed native. See Statistics tab for composition breakdown."*

---

### 5.5 Statistics Tab — Flag Composition Section

**Section header:** `Flag Composition (n = [N] returned records)`

Three stacked-bar rows, each with colored dot legend:

#### Establishment status (is_introduced)

Sub-header: `ESTABLISHMENT STATUS (is_introduced)`

| Value | Label | Color |
|---|---|---|
| `0` | NSR-confirmed non-introduced | Green `#22c55e` |
| `NULL` | NSR-unevaluated (not assessed) | Gray `#94a3b8` |
| `1` | NSR-confirmed introduced | Red `#f43f5e` |

#### Cultivation status (is_cultivated)

Sub-header: `CULTIVATION STATUS (is_cultivated)`

| Value | Label | Color |
|---|---|---|
| `0` | Confirmed wild | Green `#15803d` |
| `NULL` | Cultivation-unassessed | Gray `#94a3b8` |
| `1` | Confirmed cultivated | Orange `#c2410c` |

#### Geospatial validity (is_geovalid)

Sub-header: `GEOSPATIAL VALIDITY (is_geovalid)`

| Value | Label | Color |
|---|---|---|
| `1` | Geovalid | Blue `#2f79b7` |
| `NULL` | Geovalid-unevaluated | Gray `#94a3b8` |
| `0` | Geoinvalid | Red `#be123c` |

**Note below section:**  
*"'NSR-unevaluated' records have not been assessed by the BIEN Native Species Resolver and are not confirmed native; see Maitner et al. (2018, Ecography) for NSR methodology and Enquist et al. (2026, MEE, doi:10.1111/2041-210x.70274) for flag semantics."*

---

### 5.6 Download Tab — SDM & Reproducibility Notes Panel

**Placement:** First element in Download `tabPanel`, before `downloadButton()`.  
**Design:** `<details>` + `<summary>` (Shiny `tags$details` / `tags$summary`), styled `.sdm-guidance-panel`, expanded by default for new queries.

**Summary text:** `⚠ SDM & Reproducibility Notes — expand before downloading`

#### Row 1: Spatial autocorrelation
**Icon:** 🧭  
**Text:** *"Occurrence records from BIEN are spatially autocorrelated and do not constitute independent observations for model training or evaluation. Apply spatial thinning or — preferably — block-based spatial cross-validation before fitting any SDM. Recommended: Valavi et al. (2019, Methods in Ecology and Evolution) for the blockCV R package; Roberts et al. (2017, Ecography) for spatial and environmental blocking strategies. Block size should match the spatial autocorrelation range of your response variable."*

#### Row 2: Post-thinning sample size
**Icon:** 📍  
**Text:** *"Estimated post-thinning independent records: ~**[N]** at 5 km · ~**[M]** at 10 km (spatial thinning estimates; use spThin or CoordinateCleaner). SDM practitioners generally require ≥ 30 spatially independent training points. With fewer than 30 thinned records, interpret SDM outputs with caution and consider simpler model architectures (e.g., BIOCLIM, Maxent with strong regularization)."*

#### Row 3: Temporal bias
**Icon:** 📅  
**Text (template):** *"Records span **[YEAR_MIN]–[YEAR_MAX]** (median **[YEAR_MED]**). **[X]%** pre-1970. Contemporary climate layers (WorldClim v2.1, CHELSA v2.1) represent the 1970–2000 climate normal. For SDMs calibrated to contemporary climate, mixing pre- and post-1970 records may introduce climate–niche mismatch. Consider filtering to post-1970 records and reporting this decision in your methods."*

#### Row 4: Presence-only data
**Icon:** 🗺️  
**Text:** *"BIEN occurrence data are presence-only. SDMs requiring background or pseudo-absence points (Maxent, BRT, GLM with absences) should use target-group background sampling — selecting background points from the same data sources and time periods as the presences — to reduce sampling-bias confounds in niche estimates. Presence-absence modeling requires independent survey data not available through this app."*

#### Row 5: Reproducibility
**Icon:** 🔁  
**Text:** *"The BIEN database is periodically re-ingested; re-running the same query later may return different records or flag values — this is expected. For reproducible publications, record the BIEN database version using BIEN_metadata_database_version() in R and report it alongside the query date."*

#### Row 6: Record cap caution (conditional — display only when query was capped)
**Icon:** ⚠️  
**Text:** *"This query was capped at **[N]** records; the full BIEN record count for this taxon may be substantially larger. Do not interpret the downloaded record count as the total BIEN sample size for this species, and note that the cap may undersample particular geographic regions."*

---

### 5.7 Strict Mode Empty State

**Trigger:** `is_strict && n_valid_coords == 0`  
**Placement:** Replaces map content area entirely. Use `uiOutput("map_or_empty_state_ui")`.

**Icon:** 🔬 (gray, 2.4em)

**Heading:** `No NSR-Confirmed Records Found`

**Body:**  
*"Strict mode requires records that BIEN NSR has explicitly confirmed as non-introduced (is_introduced = 0) and confirmed as wild (is_cultivated = 0), with valid georeferences in the Western Hemisphere. For many species — including those with sparse BIEN representation, recently described taxa, and species whose native ranges lie outside the Americas — no records in the current BIEN database meet all three criteria simultaneously. An empty Strict result is a valid, informative outcome: it tells you the quality threshold could not be met for this species, not that the species is absent from BIEN."*

**Old World heuristic block** (amber card, show when >80% of Standard records have `is_introduced = 1`):  
*"Most Standard-mode records for this species are flagged as NSR-confirmed introduced (is_introduced = 1), which strongly suggests this species' native range is outside the Western Hemisphere. BIEN NSR coverage and occurrence data are designed for the Americas; for Old World taxa, Strict mode will typically return zero records because BIEN has not assessed sufficient non-introduced occurrences. Standard records for this species likely characterize its invasive Americas range. Using them as a native-range training dataset for SDMs without explicit justification and disclosure would be scientifically misleading."*

**Suggested next steps (3 bullets):**
1. *"Switch to **Standard** mode to see NSR-unevaluated and confirmed non-introduced records together. Review the is_introduced column in your download to understand the composition of the returned dataset before proceeding."*
2. *"For this species' native-range occurrences outside the Americas, consult **GBIF** (gbif.org), which has global coverage. Apply your own geographic and status filters appropriate to your analysis goals."*
3. *"If you must proceed with BIEN data despite the absence of Strict records, document this limitation explicitly in your methods, quantify the proportion of confirmed-introduced records, and consider whether the invasive range is scientifically appropriate for your specific question."*

---

### 5.8 Data Quality Chip Tooltips

#### Fallback tier chip (e.g., "Tier 2 fallback active")
*"The app could not find records under your original filter settings and automatically relaxed them. **Tier 1** = introduced-status filter dropped (confirmed-invasive records may be included). **Tier 2** = introduced-status + geovalid filters dropped (geographic precision is also reduced). **Tier 3–4** = all filters dropped, including centroid exclusion (county-level coordinates may be present). Higher tiers indicate progressively less certain data provenance. Check the amber banner for details and review flag columns in your download before analysis."*

#### Centroid-unassessed % chip
*"[X]% of records have not been assessed for centroid status (is_centroid IS NULL). Centroid records represent political unit centers — county seats, municipality centroids, grid cell centers — with positional uncertainty of roughly 10–100 km. Unassessed records may include undocumented centroids. For SDMs at resolutions finer than approximately 10 km, consider filtering to is_centroid = 0 records after downloading."*

#### Pre-1970 record % chip
*"[X]% of records were collected before 1970. Contemporary climate layers (WorldClim, CHELSA) represent the 1970–2000 normal period. Pre-1970 records reflect vegetation, land use, and climate conditions that may differ substantially from modern baselines; including them in SDMs calibrated to contemporary climate can produce biased niche estimates. For contemporary SDM applications, consider filtering to post-1970 records and reporting this decision in your methods."*

#### Cultivation-unassessed % chip
*"[X]% of records have not been evaluated for cultivated status (is_cultivated IS NULL). If the dataset includes botanical garden collections, urban plantings, or horticultural escapes that have not been flagged, these may inflate apparent range in human-modified landscapes and bias niche models toward disturbed or urban environments. For analyses that strictly require wild occurrences, use the Strict profile and report the proportion of cultivation-unassessed records if using Standard mode."*

---

## 6. Terminology Consistency Guide

| Use | Avoid |
|---|---|
| NSR-unevaluated | "unknown status," "missing," "null" |
| Confirmed non-introduced | "native" (unless explicitly NSR-confirmed) |
| NSR-confirmed introduced | "alien," "exotic" (use "introduced") |
| Cultivation-unassessed | "unknown cultivated status," "possibly cultivated" |
| BIEN Native Species Resolver (NSR) | Spell out on first use; "NSR" thereafter |
| Caution | "error," "problem," "warning" (for data quality notes) |
| Records that may include… | "bad data," "dirty data" |

---

## 7. Implementation Wave Order

These UI changes map to the issue registry wave plan:

| Wave | UI changes included |
|---|---|
| Wave 1 (R-side only) | Flag composition section (Stats tab), Quality chips, SDM guidance panel text stubs |
| Wave 2 (SQL SELECT additions) | Map point `is_introduced` color (requires `is_introduced` in SELECT), legend, banner introduced count |
| Wave 3 (Filter logic) | Cultivation filter label update (default `strict_wild_no_unknown=TRUE`), centroid tooltip |
| Wave 4 (Design) | Profile selector card redesign, fallback banner (persistent), empty state, chip colors |

---

## 8. References

- Enquist et al. 2026. MEE. doi:10.1111/2041-210x.70274 — BIEN flag semantics (Fig. 4)
- Maitner et al. 2018. *Ecography* — BIEN NSR methodology
- Valavi et al. 2019. *Methods in Ecology and Evolution* — blockCV spatial cross-validation
- Roberts et al. 2017. *Ecography* — spatial and environmental blocking for SDMs
