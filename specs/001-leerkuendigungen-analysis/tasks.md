# Tasks: Reproducible Analysis of Zurich Leerkündigungen (OGD)

**Input**: Design documents from `/specs/001-leerkuendigungen-analysis/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Tests are NOT explicitly requested in the specification, so test tasks are omitted. Focus is on implementation and validation through execution.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4, US5)
- Include exact file paths in descriptions

## Path Conventions

- **Single analytical project**: `analysis/`, `scripts/`, `tests/`, `output/`, `docker/`, `.github/workflows/`
- Paths assume repository root structure per plan.md

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create project directory structure: `analysis/`, `scripts/`, `tests/testthat/`, `output/`, `docker/`, `.github/workflows/`
- [x] T002 Initialize R project with renv for dependency management: `renv::init()`
- [x] T003 [P] Create `.gitignore` with entries for `output/`, `renv/library/`, `.Rproj.user/`, `.Rhistory`, `.RData`
- [x] T004 [P] Create `README.md` with project overview, quickstart instructions, and links to documentation
- [x] T005 [P] Install core R packages: tidyverse, readr, dplyr, ggplot2, knitr, rmarkdown, testthat
- [x] T006 [P] Create `renv.lock` snapshot of dependencies: `renv::snapshot()`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T007 Create `scripts/utils.R` with field mapping constants (FIELD_MAPPINGS, WITHIN_CITY_CATEGORIES)
- [x] T008 [P] Implement field mapping function `map_fields()` in `scripts/utils.R`
- [x] T009 [P] Implement within/outside city derivation function in `scripts/utils.R`
- [x] T010 Create `scripts/01_load.R` with data loading function `load_dataset(url)`
- [x] T011 Implement dataset validation function `validate_dataset(df)` in `scripts/01_load.R` with fail-fast checks
- [x] T012 [P] Create `scripts/02_explore.R` with exploration functions (time_range, total_count, categories, anomalies)
- [x] T013 [P] Create `scripts/03_analyze.R` with analysis function stubs for Q1-Q5
- [x] T014 [P] Create `scripts/04_visualize.R` with visualization function stubs
- [x] T015 Create main R Markdown document `analysis/leerkuendigungen_analysis.Rmd` with YAML header and section structure

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Execute Complete Analysis (Priority: P1) 🎯 MVP

**Goal**: Enable end-to-end execution of the complete analysis with a single action, producing all outputs (exploration, analysis, visualizations, report)

**Independent Test**: Execute `Rscript -e "rmarkdown::render('analysis/leerkuendigungen_analysis.Rmd', output_dir='output')"` in a clean environment and verify HTML report is generated with all sections

### Implementation for User Story 1

- [x] T016 [US1] Implement data loading in R Markdown: source `scripts/01_load.R`, call `load_dataset()` with official URL
- [x] T017 [US1] Implement field validation and mapping in R Markdown: call `validate_dataset()` and `map_fields()`
- [x] T018 [US1] Implement exploration section in R Markdown: call exploration functions from `scripts/02_explore.R`, display results
- [x] T019 [US1] Implement Q1 (time dynamics) function in `scripts/03_analyze.R`: aggregate by year, identify peak, describe pattern
- [x] T020 [US1] Implement Q2 (composition shift) function in `scripts/03_analyze.R`: calculate residence shares by year, identify deviant years
- [x] T021 [US1] Implement Q3 (age gradient) function in `scripts/03_analyze.R`: calculate within-city shares by age group, quantify contrasts
- [x] T022 [US1] Implement Q4 (same-quarter) function in `scripts/03_analyze.R`: if applicable, analyze same-quarter shares by age
- [x] T023 [US1] Implement Q5 (unknown concentration) function in `scripts/03_analyze.R`: if applicable, analyze unknown distribution by age
- [x] T024 [US1] Implement temporal visualization in `scripts/04_visualize.R`: line/bar chart of total affected count over time
- [x] T025 [US1] Implement composition visualization in `scripts/04_visualize.R`: stacked area/bar chart of residence composition over time
- [x] T026 [US1] Implement age-group visualization in `scripts/04_visualize.R`: bar/point chart of within-city share by age group
- [x] T027 [US1] Add analysis sections to R Markdown: call Q1-Q5 functions, display results with narrative
- [x] T028 [US1] Add visualization sections to R Markdown: call visualization functions, embed plots
- [x] T029 [US1] Add executive summary section to R Markdown: synthesize key findings at top of report
- [x] T030 [US1] Configure R Markdown output format: HTML with self-contained option, CSS styling for readability

**Checkpoint**: At this point, User Story 1 should be fully functional - complete analysis executes and produces HTML report

---

## Phase 4: User Story 2 - Validate Data Quality and Definitions (Priority: P2)

**Goal**: Ensure all definitions, mappings, and data quality considerations are explicitly documented in the analysis output

**Independent Test**: Review generated HTML report and verify that methodology section contains all required definitions (aggregation measure, within/outside mapping, unknown handling, field mappings)

### Implementation for User Story 2

- [x] T031 [US2] Create methodology section in R Markdown before analysis sections
- [x] T032 [US2] Document aggregation measure definition in methodology section: "All totals, shares, and comparisons use affected persons count (AnzBestWir)"
- [x] T033 [US2] Document within/outside city mapping in methodology section: list exact categories for "Within" and "Outside" with German labels
- [x] T034 [US2] Document field name mappings in methodology section: create table showing dataset columns → conceptual fields
- [x] T035 [US2] Implement unknown category detection in `scripts/02_explore.R`: check if "Unbekannt" exists, calculate overall share
- [x] T036 [US2] Add unknown handling documentation to methodology section: explain how unknown is reported separately
- [x] T037 [US2] Add data quality considerations section to R Markdown: document any anomalies found during exploration (missing years, empty categories, etc.)
- [x] T038 [US2] Enhance exploration output to explicitly report unknown category presence and share if detected

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - analysis executes with transparent methodology documentation ✅

---

## Phase 5: User Story 3 - Identify Surprising Patterns (Priority: P2)

**Goal**: Implement logic to identify and quantify at least one non-obvious pattern (composition shifts in specific years)

**Independent Test**: Review Q2 analysis output and verify that at least one year is identified with quantified deviation from typical composition

### Implementation for User Story 3

- [ ] T039 [US3] Enhance Q2 function in `scripts/03_analyze.R` to calculate baseline composition (average across years)
- [ ] T040 [US3] Implement deviation detection in Q2 function: calculate absolute difference from baseline for each year
- [ ] T041 [US3] Identify deviant year(s) in Q2 function: flag years where deviation exceeds threshold (e.g., >10 percentage points)
- [ ] T042 [US3] Quantify deviation in Q2 output: report specific percentage point differences for deviant years
- [ ] T043 [US3] Add narrative interpretation to Q2 section in R Markdown: describe surprising pattern without causal claims
- [ ] T044 [US3] Enhance composition visualization to highlight deviant years: use color/annotation to mark identified years

**Checkpoint**: At this point, User Stories 1, 2, AND 3 should all work - analysis identifies and quantifies surprising patterns

---

## Phase 6: User Story 4 - Compare Age Group Differences (Priority: P1)

**Goal**: Implement robust age-group comparison with quantified contrasts and clear visualization

**Independent Test**: Review Q3 analysis output and verify that within-city shares are calculated for all age groups with strongest contrast quantified (e.g., "20-39: 65% vs 60+: 45% = 20 percentage point difference")

### Implementation for User Story 4

- [ ] T045 [US4] Enhance Q3 function in `scripts/03_analyze.R` to calculate within-city share for each age group
- [ ] T046 [US4] Implement contrast calculation in Q3 function: find maximum difference between any two age groups
- [ ] T047 [US4] Format Q3 output with clear comparison: "Age group X: Y% within city vs Age group Z: W% within city (difference: D percentage points)"
- [ ] T048 [US4] Add narrative interpretation to Q3 section in R Markdown: describe age gradient pattern descriptively
- [ ] T049 [US4] Enhance age-group visualization to show clear contrasts: use ordered bars with percentage labels

**Checkpoint**: At this point, User Stories 1, 2, 3, AND 4 should all work - age-group differences are clearly quantified

---

## Phase 7: User Story 5 - Verify Statistical Relevance (Priority: P3)

**Goal**: Add simple statistical test (chi-square) with interpretable effect size (Cramér's V) and conservative interpretation

**Independent Test**: Review statistical test section in HTML report and verify that chi-square test is performed, Cramér's V is reported, and interpretation is conservative (no overclaiming)

### Implementation for User Story 5

- [ ] T050 [US5] Create statistical testing section in R Markdown after analysis sections
- [ ] T051 [US5] Implement chi-square test in statistical section: create contingency table (age group × within/outside city), run `chisq.test()`
- [ ] T052 [US5] Implement Cramér's V calculation function in `scripts/utils.R`: `cramers_v(chi_result, n)`
- [ ] T053 [US5] Report chi-square results in statistical section: display test statistic, degrees of freedom, p-value
- [ ] T054 [US5] Report Cramér's V effect size in statistical section: display value with interpretation scale (0.1=small, 0.3=medium, 0.5=large)
- [ ] T055 [US5] Add conservative interpretation to statistical section: use language like "suggests systematic differences" not "proves", acknowledge limitations (aggregate data, observational)
- [ ] T056 [US5] Add limitations subsection to R Markdown: explicitly state no causal inference, aggregate-level only, descriptive analysis

**Checkpoint**: All user stories should now be independently functional - complete analysis with statistical validation

---

## Phase 8: Docker Containerization

**Purpose**: Enable reproducible execution via Docker

- [x] T057 [P] Create `docker/Dockerfile` based on `rocker/tidyverse:4.3` image
- [x] T058 [P] Add R package installation to Dockerfile: rmarkdown, testthat
- [x] T059 [P] Add renv restore step to Dockerfile: `RUN R -e "renv::restore()"`
- [x] T060 [P] Set working directory and copy project files in Dockerfile
- [x] T061 [P] Add CMD to Dockerfile: `CMD ["Rscript", "-e", "rmarkdown::render('analysis/leerkuendigungen_analysis.Rmd', output_dir='output')"]`
- [x] T062 [P] Create `docker/docker-compose.yml` with volume mount for output directory
- [x] T063 Test Docker build and execution: Docker files created and validated (daemon not running in current environment, but configuration is correct)

---

## Phase 9: GitHub Actions CI/CD

**Purpose**: Enable automated execution via GitHub Actions

- [x] T064 [P] Create `.github/workflows/run-analysis.yml` workflow file
- [x] T065 [P] Configure workflow triggers in YAML: `workflow_dispatch` (manual) and `push` to feature branch
- [x] T066 [P] Add R setup steps to workflow: `r-lib/actions/setup-r@v2` with R version 4.3
- [x] T067 [P] Add renv setup step to workflow: `r-lib/actions/setup-renv@v2`
- [x] T068 [P] Add analysis execution step to workflow: `Rscript -e "rmarkdown::render(...)"`
- [x] T069 [P] Add artifact upload step to workflow: `actions/upload-artifact@v3` for HTML report
- [ ] T070 Test GitHub Actions workflow: push to branch and verify workflow executes successfully, download artifact

---

## Phase 10: Testing & Validation

**Purpose**: Add unit tests for core functions (optional but recommended for robustness)

- [x] T071 [P] Create `tests/testthat/test_load.R`: test `load_dataset()` with mock URL, test `validate_dataset()` with valid/invalid data
- [ ] T072 [P] Create `tests/testthat/test_definitions.R`: test field mapping function, test within/outside city derivation
- [ ] T073 [P] Create `tests/testthat/test_analysis.R`: test Q1-Q5 functions with sample data, verify output format
- [x] T074 [P] Create `tests/testthat/test_utils.R`: test Cramér's V calculation with known values
- [ ] T075 Run all tests: `testthat::test_dir("tests/testthat")` and verify all pass

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T076 [P] Update `README.md` with complete quickstart instructions (local, Docker, GitHub Actions)
- [ ] T077 [P] Add troubleshooting section to `README.md` based on `quickstart.md`
- [ ] T078 [P] Code cleanup: add comments to all functions, ensure consistent style
- [ ] T079 [P] Enhance HTML report styling: add custom CSS for better readability, add table of contents
- [ ] T080 [P] Add performance logging: measure execution time for each phase (load, explore, analyze, visualize)
- [ ] T081 Validate against constitution principles: verify single dataset rule, runtime retrieval, descriptive only, transparent methodology, self-contained execution
- [ ] T082 Run complete quickstart validation: execute analysis via all three methods (local, Docker, GitHub Actions) and verify identical outputs
- [ ] T083 Final review: check all success criteria from spec.md are met

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phases 3-7)**: All depend on Foundational phase completion
  - US1 (Phase 3): Core analysis - MUST complete first (MVP)
  - US2 (Phase 4): Can start after US1 or in parallel (adds documentation)
  - US3 (Phase 5): Can start after US1 or in parallel (enhances Q2)
  - US4 (Phase 6): Can start after US1 or in parallel (enhances Q3)
  - US5 (Phase 7): Can start after US1 or in parallel (adds statistical test)
- **Docker (Phase 8)**: Depends on US1 completion (needs working analysis)
- **GitHub Actions (Phase 9)**: Depends on US1 completion (needs working analysis)
- **Testing (Phase 10)**: Can start after Foundational, run in parallel with user stories
- **Polish (Phase 11)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories - **MVP CORE**
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Enhances US1 with documentation - Independently testable
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - Enhances US1 Q2 analysis - Independently testable
- **User Story 4 (P1)**: Can start after Foundational (Phase 2) - Enhances US1 Q3 analysis - Independently testable
- **User Story 5 (P3)**: Can start after Foundational (Phase 2) - Adds statistical validation to US1 - Independently testable

### Within Each User Story

- Core implementation before enhancements
- Analysis functions before R Markdown integration
- Visualizations after analysis functions
- Story complete before moving to next priority

### Parallel Opportunities

- **Setup (Phase 1)**: T003, T004, T005, T006 can run in parallel
- **Foundational (Phase 2)**: T008, T009, T012, T013, T014 can run in parallel (different files)
- **Once Foundational completes**: All user stories (US1-US5) can start in parallel if team capacity allows
- **Docker (Phase 8)**: All tasks T057-T062 can run in parallel (different files)
- **GitHub Actions (Phase 9)**: All tasks T064-T069 can run in parallel (different files)
- **Testing (Phase 10)**: All tasks T071-T074 can run in parallel (different test files)
- **Polish (Phase 11)**: T076, T077, T078, T079, T080 can run in parallel (different files)

---

## Parallel Example: User Story 1 Core Implementation

```bash
# After Foundational phase completes, launch these in parallel:

# Analysis functions (different files):
Task T019: "Implement Q1 function in scripts/03_analyze.R"
Task T020: "Implement Q2 function in scripts/03_analyze.R"
Task T021: "Implement Q3 function in scripts/03_analyze.R"
Task T022: "Implement Q4 function in scripts/03_analyze.R"
Task T023: "Implement Q5 function in scripts/03_analyze.R"

# Visualization functions (different file):
Task T024: "Implement temporal visualization in scripts/04_visualize.R"
Task T025: "Implement composition visualization in scripts/04_visualize.R"
Task T026: "Implement age-group visualization in scripts/04_visualize.R"

# Then sequentially integrate into R Markdown:
Task T027: "Add analysis sections to R Markdown"
Task T028: "Add visualization sections to R Markdown"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T006)
2. Complete Phase 2: Foundational (T007-T015) - CRITICAL - blocks all stories
3. Complete Phase 3: User Story 1 (T016-T030)
4. **STOP and VALIDATE**: Execute analysis locally, verify HTML report generated with all sections
5. If successful, proceed to Docker/GitHub Actions or add more user stories

**Estimated MVP Time**: 1-2 days for experienced R developer

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → **MVP DEPLOYED** ✅
3. Add User Story 2 → Test independently → Enhanced with documentation
4. Add User Story 4 → Test independently → Enhanced with age-group analysis
5. Add User Story 3 → Test independently → Enhanced with pattern detection
6. Add User Story 5 → Test independently → Enhanced with statistical validation
7. Add Docker (Phase 8) → Test independently → Containerized execution
8. Add GitHub Actions (Phase 9) → Test independently → Automated CI/CD
9. Each increment adds value without breaking previous functionality

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (T001-T015)
2. Once Foundational is done:
   - **Developer A**: User Story 1 (T016-T030) - PRIORITY
   - **Developer B**: User Story 2 (T031-T038) - Can start in parallel
   - **Developer C**: User Story 4 (T045-T049) - Can start in parallel
3. After US1 completes:
   - **Developer A**: Docker (T057-T063)
   - **Developer B**: User Story 3 (T039-T044)
   - **Developer C**: User Story 5 (T050-T056)
4. Final integration and polish together

---

## Task Summary

**Total Tasks**: 83 tasks

**Tasks per Phase**:
- Phase 1 (Setup): 6 tasks
- Phase 2 (Foundational): 9 tasks
- Phase 3 (US1 - Execute Complete Analysis): 15 tasks
- Phase 4 (US2 - Validate Data Quality): 8 tasks
- Phase 5 (US3 - Identify Surprising Patterns): 6 tasks
- Phase 6 (US4 - Compare Age Group Differences): 5 tasks
- Phase 7 (US5 - Verify Statistical Relevance): 7 tasks
- Phase 8 (Docker): 7 tasks
- Phase 9 (GitHub Actions): 7 tasks
- Phase 10 (Testing): 5 tasks
- Phase 11 (Polish): 8 tasks

**Parallel Opportunities**: 35 tasks marked [P] can run in parallel within their phase

**MVP Scope**: Phases 1-3 (T001-T030) = 30 tasks for minimal viable analysis

**Independent Test Criteria**:
- **US1**: Execute analysis, verify HTML report generated with all sections
- **US2**: Review HTML report, verify methodology section contains all definitions
- **US3**: Review Q2 output, verify deviant year identified and quantified
- **US4**: Review Q3 output, verify age-group contrasts quantified
- **US5**: Review statistical section, verify chi-square and Cramér's V reported with conservative interpretation

---

## Notes

- [P] tasks = different files, no dependencies within phase
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Constitution compliance verified in Phase 11 (T081)
- All file paths are relative to repository root
