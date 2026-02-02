# Quickstart: Zurich Leerkündigungen Analysis

**Feature**: 001-leerkuendigungen-analysis  
**Date**: 2026-02-02  
**Status**: Complete

## Overview

This guide provides step-by-step instructions for running the Zurich Leerkündigungen analysis in three different environments:

1. **Local R Environment** - For development and exploration
2. **Docker Container** - For reproducible execution
3. **GitHub Actions** - For automated CI/CD

---

## Prerequisites

### For Local Execution

- **R**: Version 4.3 or higher ([Download R](https://cran.r-project.org/))
- **RStudio** (optional but recommended): ([Download RStudio](https://posit.co/download/rstudio-desktop/))
- **Internet connection**: Required to download dataset at runtime

### For Docker Execution

- **Docker**: Version 20.10 or higher ([Install Docker](https://docs.docker.com/get-docker/))
- **Internet connection**: Required to download dataset at runtime

### For GitHub Actions

- **GitHub account**: With access to the repository
- **Repository permissions**: Ability to trigger workflows

---

## Option 1: Local R Environment

### Step 1: Clone Repository

```bash
git clone <repository-url>
cd leer
git checkout 001-leerkuendigungen-analysis
```

### Step 2: Install R Dependencies

#### Option A: Using renv (Recommended)

```r
# Open R or RStudio in the project directory
# renv will automatically activate

# Restore dependencies from lockfile
renv::restore()
```

#### Option B: Manual Installation

```r
# Install required packages
install.packages(c(
  "tidyverse",    # Data manipulation and visualization
  "readr",        # CSV reading
  "dplyr",        # Data manipulation
  "ggplot2",      # Visualization
  "knitr",        # Report generation
  "rmarkdown",    # R Markdown rendering
  "testthat"      # Testing
))
```

### Step 3: Run Analysis

#### Option A: Render R Markdown (Recommended)

```r
# In R console or RStudio
rmarkdown::render(
  "analysis/leerkuendigungen_analysis.Rmd",
  output_dir = "output"
)
```

#### Option B: Run from Command Line

```bash
# From project root
Rscript -e "rmarkdown::render('analysis/leerkuendigungen_analysis.Rmd', output_dir='output')"
```

### Step 4: View Results

```bash
# Open generated HTML report
open output/leerkuendigungen_report.html  # macOS
xdg-open output/leerkuendigungen_report.html  # Linux
start output/leerkuendigungen_report.html  # Windows
```

### Step 5: Run Tests (Optional)

```r
# In R console
library(testthat)
test_dir("tests/testthat")
```

---

## Option 2: Docker Container

### Step 1: Clone Repository

```bash
git clone <repository-url>
cd leer
git checkout 001-leerkuendigungen-analysis
```

### Step 2: Build Docker Image

```bash
# From project root
docker build -t leerkuendigungen-analysis -f docker/Dockerfile .
```

**Expected build time**: 5-10 minutes (first build, includes R package installation)

### Step 3: Run Analysis in Container

```bash
# Run analysis and mount output directory
docker run --rm \
  -v $(pwd)/output:/analysis/output \
  leerkuendigungen-analysis
```

**Explanation**:
- `--rm`: Remove container after execution
- `-v $(pwd)/output:/analysis/output`: Mount local output directory to container
- Container will download data, run analysis, and save report to `output/`

### Step 4: View Results

```bash
# Open generated HTML report
open output/leerkuendigungen_report.html  # macOS
xdg-open output/leerkuendigungen_report.html  # Linux
start output/leerkuendigungen_report.html  # Windows
```

### Alternative: Using Docker Compose

```bash
# From project root
docker-compose -f docker/docker-compose.yml up

# View results
open output/leerkuendigungen_report.html
```

---

## Option 3: GitHub Actions

### Step 1: Navigate to Repository on GitHub

```
https://github.com/<your-org>/<your-repo>
```

### Step 2: Trigger Workflow

1. Go to **Actions** tab
2. Select **"Run Leerkuendigungen Analysis"** workflow
3. Click **"Run workflow"** button
4. Select branch: `001-leerkuendigungen-analysis`
5. Click **"Run workflow"** (green button)

### Step 3: Monitor Execution

- Workflow typically completes in 3-5 minutes
- Click on the running workflow to see live logs
- Check for any errors in the logs

### Step 4: Download Results

1. Once workflow completes, scroll to **Artifacts** section
2. Click **"analysis-report"** to download ZIP file
3. Extract ZIP and open `leerkuendigungen_report.html`

### Alternative: Automatic Trigger on Push

The workflow is also configured to run automatically when you push to the `001-leerkuendigungen-analysis` branch:

```bash
# Make changes to analysis
git add analysis/leerkuendigungen_analysis.Rmd
git commit -m "Update analysis"
git push origin 001-leerkuendigungen-analysis

# Workflow will trigger automatically
# Check Actions tab on GitHub for results
```

---

## Expected Output

Regardless of execution method, you should see:

### Console Output

```
Loading dataset from official URL...
✓ Dataset downloaded successfully
✓ Required fields validated
✓ Field mappings applied

Exploration Phase:
- Time range: 2010-2023
- Total affected: 12,345 persons
- Age groups: 4 categories
- Residence categories: 5 categories
- Unknown category: Present (8.2% of total)

Analysis Phase:
✓ Q1: Time dynamics analyzed
✓ Q2: Composition shift identified
✓ Q3: Age gradient quantified
✓ Q4: Same-quarter analysis complete
✓ Q5: Unknown concentration analyzed

Visualization Phase:
✓ Temporal plot generated
✓ Composition plot generated
✓ Age-group comparison plot generated

Statistical Testing:
✓ Chi-square test performed
✓ Effect size calculated

Report generated: output/leerkuendigungen_report.html
```

### HTML Report Contents

1. **Executive Summary**: Key findings at a glance
2. **Methodology**: Explicit definitions and mappings
3. **Exploration Results**: Time range, totals, categories, anomalies
4. **Analysis Answers**:
   - Q1: Time dynamics with peak years
   - Q2: Composition shifts with deviant years
   - Q3: Age gradient with quantified contrasts
   - Q4: Same-quarter dependence (if applicable)
   - Q5: Unknown concentration (if applicable)
5. **Visualizations**: Embedded plots (temporal, composition, age-group)
6. **Statistical Test**: Chi-square results, effect size, interpretation
7. **Limitations**: Data quality considerations, scope boundaries

---

## Troubleshooting

### Issue: Dataset Download Fails

**Symptoms**: Error message "Failed to download dataset from URL"

**Solutions**:
1. Check internet connection
2. Verify URL is accessible: `curl -I https://data.stadt-zuerich.ch/dataset/bau_umbau_leerkuendigung_wohnortsgebiete_ag_personen_od5052/download/BAU505OD5052.csv`
3. Check if Zurich OGD portal is down (try accessing in browser)
4. If behind corporate firewall, configure proxy settings

### Issue: Required Columns Missing

**Symptoms**: Error message "Required column(s) missing: [list]"

**Solutions**:
1. Dataset schema may have changed - check [data-model.md](data-model.md) for expected columns
2. Update field mappings in `scripts/utils.R` if column names changed
3. Report issue to dataset maintainers if schema changed without notice

### Issue: R Package Installation Fails

**Symptoms**: Error during `renv::restore()` or `install.packages()`

**Solutions**:
1. Update R to latest version: `R --version`
2. Check CRAN mirror is accessible: `options(repos = c(CRAN = "https://cloud.r-project.org/"))`
3. Install system dependencies (Linux):
   ```bash
   sudo apt-get install libcurl4-openssl-dev libssl-dev libxml2-dev
   ```
4. Try installing packages individually to identify problematic package

### Issue: Docker Build Fails

**Symptoms**: Error during `docker build`

**Solutions**:
1. Check Docker daemon is running: `docker ps`
2. Increase Docker memory allocation (Docker Desktop settings)
3. Clear Docker cache: `docker system prune -a`
4. Check Dockerfile syntax and base image availability

### Issue: GitHub Actions Workflow Fails

**Symptoms**: Workflow shows red X, error in logs

**Solutions**:
1. Check workflow logs for specific error message
2. Verify branch name is correct: `001-leerkuendigungen-analysis`
3. Check if repository has required permissions (Actions enabled)
4. Re-run workflow (sometimes transient network issues)

### Issue: Output Directory Not Created

**Symptoms**: "Cannot find output/leerkuendigungen_report.html"

**Solutions**:
1. Create output directory manually: `mkdir -p output`
2. Check write permissions: `ls -la output`
3. Verify `output_dir` parameter in `rmarkdown::render()` call

### Issue: Plots Not Rendering in HTML

**Symptoms**: HTML report shows empty plot areas

**Solutions**:
1. Check ggplot2 is installed: `library(ggplot2)`
2. Verify R Markdown chunk options: `{r, fig.width=10, fig.height=6}`
3. Check for errors in visualization functions in `scripts/04_visualize.R`

---

## Performance Expectations

| Environment | Typical Execution Time | Notes |
|-------------|----------------------|-------|
| Local R (first run) | 2-3 minutes | Includes package loading |
| Local R (subsequent) | 1-2 minutes | Packages already loaded |
| Docker (first build) | 8-12 minutes | Includes image build + execution |
| Docker (subsequent) | 1-2 minutes | Image cached, only execution |
| GitHub Actions | 3-5 minutes | Includes environment setup |

**Factors affecting performance**:
- Internet speed (dataset download)
- CPU speed (data processing, visualization)
- Available RAM (large datasets)
- R package cache (first vs subsequent runs)

---

## Next Steps

After successfully running the analysis:

1. **Review Results**: Read the HTML report thoroughly
2. **Validate Findings**: Check if results align with expectations
3. **Iterate**: Modify analysis if needed (update R Markdown, re-run)
4. **Share**: Distribute HTML report to stakeholders
5. **Archive**: Commit final version to repository

---

## Additional Resources

- **Specification**: [spec.md](spec.md) - Feature requirements
- **Data Model**: [data-model.md](data-model.md) - Dataset schema and entities
- **Dataset Contract**: [contracts/dataset-schema.md](contracts/dataset-schema.md) - Formal data contract
- **Research**: [research.md](research.md) - Technology decisions and rationale
- **Implementation Plan**: [plan.md](plan.md) - Technical architecture

---

## Support

For issues or questions:

1. Check this quickstart guide first
2. Review troubleshooting section above
3. Check [data-model.md](data-model.md) for data-related questions
4. Review [research.md](research.md) for technology decisions
5. Open an issue in the repository with:
   - Execution method (local/Docker/GitHub Actions)
   - Error message (full text)
   - R version and package versions (`sessionInfo()`)
   - Steps to reproduce
