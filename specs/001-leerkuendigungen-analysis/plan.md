# Implementation Plan: Reproducible Analysis of Zurich Leerkündigungen (OGD)

**Branch**: `001-leerkuendigungen-analysis` | **Date**: 2026-02-02 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/001-leerkuendigungen-analysis/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Create a reproducible analysis of Zurich Leerkündigungen (eviction notices due to building refurbishment) using the official OGD dataset. The analysis must execute end-to-end with a single action, downloading data at runtime, performing exploratory analysis, answering 5 core analytical questions, and producing visualizations. Implementation uses R for statistical analysis, Docker for containerization, and GitHub Actions for automated execution. All findings remain descriptive (no causal claims), with transparent methodology and explicit documentation of all definitions and mappings.

## Technical Context

**Language/Version**: R 4.3+  
**Primary Dependencies**: 
- `tidyverse` (data manipulation and visualization)
- `readr` (CSV reading)
- `ggplot2` (visualization, included in tidyverse)
- `dplyr` (data manipulation, included in tidyverse)
- `knitr` / `rmarkdown` (report generation)

**Storage**: CSV file downloaded at runtime (no persistent storage)  
**Testing**: `testthat` for unit tests, manual validation of outputs  
**Target Platform**: 
- Docker container (primary execution environment)
- GitHub Actions (CI/CD automated execution)
- Local R environment (development)

**Project Type**: Single analytical script/notebook  
**Performance Goals**: Complete analysis in under 5 minutes on standard hardware  
**Constraints**: 
- Must download data at runtime (no bundled data)
- Single dataset only (no external joins)
- Results must be human-readable
- No causal inference permitted

**Scale/Scope**: 
- Single CSV dataset (~10-20 years of data)
- 5 core analytical questions
- 3-5 visualizations
- 1 statistical test

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ I. Single Dataset Rule (NON-NEGOTIABLE)
**Status**: PASS  
**Verification**: Implementation will use only BAU505OD5052.csv from official URL. No external data sources planned.

### ✅ II. Runtime Data Retrieval
**Status**: PASS  
**Verification**: R script will download dataset using `readr::read_csv()` or `download.file()` from official URL at execution time. No cached or bundled data files.

### ✅ III. Descriptive Analysis Only
**Status**: PASS  
**Verification**: Analysis design focuses on descriptive statistics, group comparisons, and temporal patterns. No regression models, causal inference, or predictive modeling planned. All findings will be framed as observations, not causal explanations.

### ✅ IV. Transparent Methodology
**Status**: PASS  
**Verification**: R Markdown document will explicitly document:
- Aggregation measure (affected persons count)
- Within/Outside city mapping with exact category assignments
- Treatment of "Unknown" categories
- Field name mappings from dataset to conceptual model
All definitions will appear in dedicated "Methodology" section before analysis.

### ✅ V. Self-Contained Execution
**Status**: PASS  
**Verification**: 
- Docker: `docker run` command executes complete analysis
- GitHub Actions: Single workflow file triggers full analysis
- Local: `Rscript analysis.R` or `rmarkdown::render()` runs end-to-end
- All R dependencies declared in `renv.lock` or `DESCRIPTION` file
- Output: HTML report with embedded visualizations

**Overall Gate Status**: ✅ PASS - All constitutional requirements satisfied by design

## Project Structure

### Documentation (this feature)

```text
specs/001-leerkuendigungen-analysis/
├── plan.md              # This file (/speckit.plan command output)
├── spec.md              # Feature specification
├── research.md          # Phase 0 output (R ecosystem, Docker, GitHub Actions best practices)
├── data-model.md        # Phase 1 output (dataset schema, entity definitions)
├── quickstart.md        # Phase 1 output (how to run analysis locally, Docker, CI)
├── contracts/           # Phase 1 output (dataset schema, output format specifications)
│   └── dataset-schema.md
└── checklists/
    └── requirements.md  # Quality checklist
```

### Source Code (repository root)

```text
# Single analytical project structure
analysis/
├── leerkuendigungen_analysis.Rmd   # Main R Markdown analysis document
├── scripts/
│   ├── 01_load.R                   # Data loading and validation
│   ├── 02_explore.R                # Exploratory analysis functions
│   ├── 03_analyze.R                # Core analysis functions (Q1-Q5)
│   ├── 04_visualize.R              # Visualization functions
│   └── utils.R                     # Helper functions (field mapping, definitions)
└── tests/
    └── testthat/
        ├── test_load.R             # Test data loading and validation
        ├── test_definitions.R      # Test field mappings and groupings
        └── test_analysis.R         # Test analysis functions

output/
└── leerkuendigungen_report.html    # Generated report (gitignored)

docker/
├── Dockerfile                      # R + dependencies container
└── docker-compose.yml              # Optional: orchestration

.github/
└── workflows/
    └── run-analysis.yml            # GitHub Actions workflow

renv/                               # R dependency management (renv)
├── activate.R
└── renv.lock

README.md                           # Project overview and quickstart
.gitignore                          # Ignore output/, renv/library/
```

**Structure Decision**: Single analytical project structure chosen because:
- Analysis is self-contained (no frontend/backend split)
- R Markdown provides integrated analysis + documentation
- Modular scripts enable testing and reusability
- Docker containerizes entire R environment
- GitHub Actions automates execution and artifact generation

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations detected. All constitutional requirements are satisfied by the proposed design.

---

## Phase 0: Research & Technology Decisions

**Status**: Ready to execute

### Research Tasks

1. **R Best Practices for Reproducible Analysis**
   - Research: `renv` vs `packrat` for dependency management
   - Research: R Markdown vs Quarto for report generation
   - Research: Best practices for downloading data at runtime in R
   - Decision needed: How to structure modular R code for testability

2. **Docker for R Analytics**
   - Research: Official R Docker images (rocker project)
   - Research: How to install R packages in Docker efficiently
   - Research: Volume mounting for output artifacts
   - Decision needed: Base image selection (rocker/tidyverse vs rocker/r-ver)

3. **GitHub Actions for R**
   - Research: r-lib/actions for R-specific CI/CD
   - Research: Artifact upload for generated reports
   - Research: Caching strategies for R packages
   - Decision needed: Workflow trigger strategy (manual, on-push, scheduled)

4. **Statistical Testing in R**
   - Research: Chi-square test implementation (`chisq.test()`)
   - Research: Effect size calculation (Cramér's V)
   - Research: Conservative interpretation guidelines
   - Decision needed: Handling small cell counts in contingency tables

5. **Data Validation Strategies**
   - Research: Assertive programming in R (`stopifnot`, `assertthat`)
   - Research: Field existence validation
   - Research: Data type validation
   - Decision needed: Fail-fast vs warning-based validation

**Output**: `research.md` with decisions, rationale, and alternatives for each area

---

## Phase 1: Design & Contracts

**Status**: Pending Phase 0 completion

### Deliverables

1. **data-model.md**: Dataset schema and entity definitions
   - Document actual CSV column names from BAU505OD5052.csv
   - Map to conceptual fields (Year, Age Group, New Residence, Count)
   - Define derived entities (Within/Outside City binary)
   - Document validation rules

2. **contracts/dataset-schema.md**: Formal dataset contract
   - Expected columns and data types
   - Valid category values for Age Group and New Residence
   - Constraints (non-negative counts, valid years)
   - Handling of missing/unknown values

3. **quickstart.md**: Execution instructions
   - Local execution: Install R, restore dependencies, run analysis
   - Docker execution: Build image, run container, extract output
   - GitHub Actions: Trigger workflow, download artifacts
   - Troubleshooting common issues

4. **Agent context update**: Run `.specify/scripts/bash/update-agent-context.sh roo`
   - Add R, tidyverse, Docker, GitHub Actions to technology context
   - Preserve manual additions

**Output**: Complete design artifacts ready for implementation

---

## Phase 2: Task Breakdown

**Status**: Not started (requires `/speckit.tasks` command)

This phase will generate `tasks.md` with:
- Granular implementation tasks
- Dependencies between tasks
- Acceptance criteria per task
- Estimated complexity

**Note**: Phase 2 is executed via `/speckit.tasks` command, not by `/speckit.plan`.
