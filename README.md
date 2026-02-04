# Zurich Leerkündigungen Analysis

Reproducible analysis of Zurich "Leerkündigungen" (eviction notices due to building refurbishment) using Open Government Data.

## Overview

This project provides a self-contained, reproducible analysis of Leerkündigungen in Zurich, focusing on:

- **Clear group differences**: Age group patterns in residence outcomes
- **Surprising patterns**: Temporal composition shifts
- **Transparent methodology**: Explicit definitions and mappings
- **Statistical validation**: Chi-square test with effect size

## Quick Start

### Option 1: Local R Environment

```bash
# Clone and checkout feature branch
git clone <repository-url>
cd leer
git checkout 001-leerkuendigungen-analysis

# Restore R dependencies
R -e "renv::restore()"

# Run analysis
Rscript -e "rmarkdown::render('analysis/leerkuendigungen_analysis.Rmd', output_dir='output')"

# View results
open output/leerkuendigungen_report.html
```

### Option 2: Docker

```bash
# Build image:  docker build --platform=linux/amd64 -t leerkuendigungen-analysis -f docker/Dockerfile . for linux build
docker build -t leerkuendigungen-analysis -f docker/Dockerfile .



# Run analysis
docker run --rm -v $(pwd)/output:/analysis/output leerkuendigungen-analysis

# View results
open output/leerkuendigungen_report.html
```

### Option 3: GitHub Actions

1. Go to **Actions** tab on GitHub
2. Select **"Run Leerkuendigungen Analysis"** workflow
3. Click **"Run workflow"**
4. Download artifact when complete

## Project Structure

```
leer/
├── analysis/
│   └── leerkuendigungen_analysis.Rmd  # Main analysis document
├── scripts/
│   ├── 01_load.R                      # Data loading and validation
│   ├── 02_explore.R                   # Exploratory analysis
│   ├── 03_analyze.R                   # Core analysis (Q1-Q5)
│   ├── 04_visualize.R                 # Visualizations
│   └── utils.R                        # Helper functions
├── tests/
│   └── testthat/                      # Unit tests
├── output/
│   └── leerkuendigungen_report.html   # Generated report
├── docker/
│   ├── Dockerfile                     # Container definition
│   └── docker-compose.yml             # Orchestration
├── .github/
│   └── workflows/
│       └── run-analysis.yml           # CI/CD workflow
├── renv/                              # R dependency management
├── renv.lock                          # Locked dependencies
└── README.md                          # This file
```

## Requirements

- **R**: Version 4.3 or higher
- **Docker**: Version 20.10+ (for containerized execution)
- **Internet connection**: Required to download dataset at runtime

## Key Features

- **Single dataset**: Uses only official Zurich OGD data (BAU505OD5052.csv)
- **Runtime retrieval**: Downloads data during execution (no bundled data)
- **Descriptive analysis**: No causal claims, only patterns and associations
- **Transparent**: All definitions and mappings explicitly documented
- **Reproducible**: Self-contained execution in clean environment

## Documentation

- **Specification**: [`specs/001-leerkuendigungen-analysis/spec.md`](specs/001-leerkuendigungen-analysis/spec.md)
- **Implementation Plan**: [`specs/001-leerkuendigungen-analysis/plan.md`](specs/001-leerkuendigungen-analysis/plan.md)
- **Data Model**: [`specs/001-leerkuendigungen-analysis/data-model.md`](specs/001-leerkuendigungen-analysis/data-model.md)
- **Quickstart Guide**: [`specs/001-leerkuendigungen-analysis/quickstart.md`](specs/001-leerkuendigungen-analysis/quickstart.md)
- **Tasks**: [`specs/001-leerkuendigungen-analysis/tasks.md`](specs/001-leerkuendigungen-analysis/tasks.md)

## Troubleshooting

### Dataset Download Fails

Check internet connection and verify URL is accessible:
```bash
curl -I https://data.stadt-zuerich.ch/dataset/bau_umbau_leerkuendigung_wohnortsgebiete_ag_personen_od5052/download/BAU505OD5052.csv
```

### Package Installation Issues

Update R to latest version and try:
```r
renv::restore(rebuild = TRUE)
```

### Docker Build Fails

Clear Docker cache and rebuild:
```bash
docker system prune -a
docker build --no-cache -t leerkuendigungen-analysis -f docker/Dockerfile .
```

## License

This analysis uses Open Government Data from the City of Zurich, freely usable with attribution.

## Contact

For issues or questions, please open an issue in the repository.
