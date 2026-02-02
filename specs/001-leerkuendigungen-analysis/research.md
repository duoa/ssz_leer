# Research: Reproducible Analysis of Zurich Leerkündigungen (OGD)

**Feature**: 001-leerkuendigungen-analysis  
**Date**: 2026-02-02  
**Status**: Complete

## Overview

This document consolidates research findings for implementing a reproducible R-based analysis of Zurich Leerkündigungen data, containerized with Docker and automated via GitHub Actions.

---

## 1. R Best Practices for Reproducible Analysis

### Decision: Use `renv` for Dependency Management

**Rationale**:
- `renv` is the modern successor to `packrat`, actively maintained by RStudio/Posit
- Creates project-local R libraries, ensuring isolation
- `renv.lock` file captures exact package versions for reproducibility
- Faster and more reliable than `packrat`
- Better integration with Docker and CI/CD

**Alternatives Considered**:
- **packrat**: Older, less maintained, slower performance
- **Manual package installation**: Not reproducible, version drift issues
- **conda**: Adds Python dependency, overkill for R-only project

**Implementation**:
```r
# Initialize renv in project
renv::init()

# Restore dependencies from lockfile
renv::restore()

# Update lockfile after adding packages
renv::snapshot()
```

### Decision: Use R Markdown for Report Generation

**Rationale**:
- Mature, stable, widely adopted in R community
- Integrates code, analysis, and narrative in single document
- Outputs to HTML with embedded visualizations (self-contained)
- Excellent support for reproducible research
- Works seamlessly with `knitr` and `ggplot2`

**Alternatives Considered**:
- **Quarto**: Newer, more features, but adds complexity; R Markdown sufficient for this scope
- **Jupyter Notebooks**: Requires Python, less R-native
- **Plain R scripts**: No integrated documentation/narrative

**Implementation**:
```r
# Render R Markdown to HTML
rmarkdown::render("analysis/leerkuendigungen_analysis.Rmd",
                  output_file = "output/leerkuendigungen_report.html")
```

### Decision: Download Data at Runtime Using `readr::read_csv()`

**Rationale**:
- `readr::read_csv()` can read directly from URLs
- Handles CSV parsing robustly (better than base R `read.csv`)
- Part of tidyverse, already a dependency
- Automatic type inference with clear error messages

**Alternatives Considered**:
- **download.file() + read.csv()**: Two-step process, less elegant
- **curl package**: Adds dependency, unnecessary for simple HTTP GET
- **httr package**: Overkill for direct CSV download

**Implementation**:
```r
library(readr)

# Download and read CSV in one step
data_url <- "https://data.stadt-zuerich.ch/dataset/bau_umbau_leerkuendigung_wohnortsgebiete_ag_personen_od5052/download/BAU505OD5052.csv"
df <- read_csv(data_url, show_col_types = FALSE)
```

### Decision: Modular R Code Structure with Sourced Scripts

**Rationale**:
- Separate concerns: load, explore, analyze, visualize
- Enables unit testing with `testthat`
- Improves maintainability and readability
- R Markdown can source scripts via `source()` or code chunks

**Structure**:
```
scripts/
├── 01_load.R       # Data loading, validation, field mapping
├── 02_explore.R    # Exploratory functions (time range, totals, categories)
├── 03_analyze.R    # Core analysis functions (Q1-Q5)
├── 04_visualize.R  # Visualization functions
└── utils.R         # Helper functions (definitions, mappings)
```

**Implementation in R Markdown**:
```r
# Source all scripts
source("scripts/utils.R")
source("scripts/01_load.R")
source("scripts/02_explore.R")
source("scripts/03_analyze.R")
source("scripts/04_visualize.R")
```

---

## 2. Docker for R Analytics

### Decision: Use `rocker/tidyverse` as Base Image

**Rationale**:
- Official R Docker images maintained by Rocker Project
- `rocker/tidyverse` includes R + tidyverse packages pre-installed
- Reduces build time (tidyverse compilation is slow)
- Includes system dependencies for common R packages
- Based on Debian, stable and well-documented

**Alternatives Considered**:
- **rocker/r-ver**: Minimal R only, requires manual tidyverse installation (slower builds)
- **rocker/rstudio**: Includes RStudio Server, unnecessary for automated analysis
- **ubuntu + manual R install**: Reinventing the wheel, maintenance burden

**Dockerfile Structure**:
```dockerfile
FROM rocker/tidyverse:4.3

# Install additional R packages
RUN R -e "install.packages(c('rmarkdown', 'testthat'), repos='https://cloud.r-project.org/')"

# Copy project files
WORKDIR /analysis
COPY . /analysis

# Restore renv dependencies
RUN R -e "renv::restore()"

# Run analysis
CMD ["Rscript", "-e", "rmarkdown::render('analysis/leerkuendigungen_analysis.Rmd', output_dir='output')"]
```

### Decision: Volume Mount for Output Artifacts

**Rationale**:
- Generated HTML report needs to be accessible outside container
- Volume mounting avoids copying files from container
- Enables local development workflow

**Implementation**:
```bash
docker run -v $(pwd)/output:/analysis/output leerkuendigungen-analysis
```

### Decision: Multi-Stage Build Not Needed

**Rationale**:
- Analysis is not a compiled application
- R scripts and dependencies needed at runtime
- Image size optimization less critical for analytical workloads
- Simplicity preferred for reproducibility

---

## 3. GitHub Actions for R

### Decision: Use `r-lib/actions` for R-Specific CI/CD

**Rationale**:
- Official R community GitHub Actions maintained by r-lib
- Provides `setup-r`, `setup-renv`, `setup-pandoc` actions
- Handles R version management and caching
- Well-documented and widely adopted

**Alternatives Considered**:
- **Manual R installation**: Reinventing the wheel, slower
- **Docker-based workflow**: Possible but slower than native Actions
- **Custom actions**: Unnecessary, r-lib/actions covers needs

**Workflow Structure**:
```yaml
name: Run Leerkuendigungen Analysis

on:
  workflow_dispatch:  # Manual trigger
  push:
    branches: [001-leerkuendigungen-analysis]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.3'
      - uses: r-lib/actions/setup-renv@v2
      - name: Render analysis
        run: Rscript -e "rmarkdown::render('analysis/leerkuendigungen_analysis.Rmd', output_dir='output')"
      - uses: actions/upload-artifact@v3
        with:
          name: analysis-report
          path: output/leerkuendigungen_report.html
```

### Decision: Manual Trigger + Push-Based Execution

**Rationale**:
- `workflow_dispatch` enables on-demand execution (useful for demos)
- Push to feature branch enables automated validation during development
- No scheduled runs needed (data doesn't update frequently)

### Decision: Artifact Upload for Generated Reports

**Rationale**:
- GitHub Actions artifacts persist for 90 days (default)
- Enables downloading HTML report without cloning repo
- Useful for sharing results with non-technical stakeholders

---

## 4. Statistical Testing in R

### Decision: Use `chisq.test()` for Association Testing

**Rationale**:
- Built-in R function, no additional dependencies
- Standard chi-square test of independence for categorical variables
- Returns p-value and test statistic
- Appropriate for testing age group vs residence outcome association

**Implementation**:
```r
# Create contingency table
contingency_table <- table(df$age_group, df$within_city)

# Perform chi-square test
chi_result <- chisq.test(contingency_table)

# Extract p-value and statistic
p_value <- chi_result$p.value
chi_statistic <- chi_result$statistic
```

### Decision: Calculate Cramér's V for Effect Size

**Rationale**:
- Cramér's V is interpretable effect size for chi-square tests
- Ranges from 0 (no association) to 1 (perfect association)
- Standard interpretation: 0.1 (small), 0.3 (medium), 0.5 (large)
- Not built-in, but simple to calculate

**Implementation**:
```r
# Calculate Cramér's V
cramers_v <- function(chi_result, n) {
  chi_stat <- chi_result$statistic
  df <- min(nrow(contingency_table) - 1, ncol(contingency_table) - 1)
  sqrt(chi_stat / (n * df))
}

v <- cramers_v(chi_result, nrow(df))
```

**Alternatives Considered**:
- **Odds ratios**: Less interpretable for multi-category variables
- **Cohen's w**: Similar to Cramér's V, less commonly reported
- **vcd package**: Adds dependency, manual calculation sufficient

### Decision: Conservative Interpretation Guidelines

**Rationale**:
- Avoid overclaiming statistical significance
- Large sample sizes can yield significant p-values for trivial effects
- Focus on effect size, not just p-value

**Interpretation Framework**:
- Report both p-value and Cramér's V
- Use language like "suggests systematic differences" not "proves"
- Acknowledge limitations (aggregate data, observational)
- Frame as descriptive pattern, not causal relationship

---

## 5. Data Validation Strategies

### Decision: Fail-Fast Validation with `stopifnot()`

**Rationale**:
- Analysis should fail immediately if data doesn't meet expectations
- Prevents misleading results from malformed data
- `stopifnot()` is built-in, clear error messages
- Aligns with "validate required fields exist" requirement

**Implementation**:
```r
# Validate required columns exist
required_cols <- c("StichtagDatJahr", "AltersgruppeSort", "WohnortNachLeerKuendigungLang", "AnzPersonWir")
stopifnot("Required columns missing" = all(required_cols %in% colnames(df)))

# Validate data types
stopifnot("Year must be numeric" = is.numeric(df$StichtagDatJahr))
stopifnot("Count must be numeric" = is.numeric(df$AnzPersonWir))

# Validate non-negative counts
stopifnot("Counts must be non-negative" = all(df$AnzPersonWir >= 0))
```

**Alternatives Considered**:
- **assertthat package**: Adds dependency, `stopifnot()` sufficient
- **Warning-based validation**: Allows analysis to proceed with bad data (risky)
- **tryCatch error handling**: More complex, unnecessary for validation

### Decision: Document Field Mappings Explicitly

**Rationale**:
- Dataset uses German column names
- Conceptual model uses English names
- Mapping must be transparent (Constitution Principle IV)

**Implementation in utils.R**:
```r
# Field name mappings (dataset -> conceptual)
FIELD_MAPPINGS <- list(
  year = "StichtagDatJahr",
  age_group = "AltersgruppeSort",
  new_residence = "WohnortNachLeerKuendigungLang",
  count = "AnzPersonWir"
)

# Within/Outside city mapping
WITHIN_CITY_CATEGORIES <- c(
  "Gleiches Stadtquartier",
  "Anderes Stadtquartier"
)

# Function to apply mappings
map_fields <- function(df) {
  df %>%
    rename(
      year = !!FIELD_MAPPINGS$year,
      age_group = !!FIELD_MAPPINGS$age_group,
      new_residence = !!FIELD_MAPPINGS$new_residence,
      count = !!FIELD_MAPPINGS$count
    ) %>%
    mutate(
      within_city = new_residence %in% WITHIN_CITY_CATEGORIES
    )
}
```

---

## Summary of Key Decisions

| Area | Decision | Rationale |
|------|----------|-----------|
| Dependency Management | `renv` | Modern, fast, Docker-friendly |
| Report Format | R Markdown → HTML | Mature, integrated, self-contained |
| Data Loading | `readr::read_csv(url)` | Direct URL reading, robust parsing |
| Code Structure | Modular scripts sourced by Rmd | Testable, maintainable |
| Docker Base Image | `rocker/tidyverse:4.3` | Pre-installed tidyverse, fast builds |
| CI/CD | GitHub Actions + r-lib/actions | Official R support, caching |
| Statistical Test | `chisq.test()` + Cramér's V | Standard, interpretable, built-in |
| Validation | Fail-fast with `stopifnot()` | Immediate error detection |
| Field Mapping | Explicit constants in utils.R | Transparent, documented |

---

## Next Steps

Phase 1 deliverables:
1. **data-model.md**: Document actual dataset schema and entity definitions
2. **contracts/dataset-schema.md**: Formal dataset contract
3. **quickstart.md**: Execution instructions for local, Docker, and GitHub Actions
4. **Update agent context**: Add R, tidyverse, Docker, GitHub Actions to Roo context
