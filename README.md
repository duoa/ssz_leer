# Zürich Leerkündigungen Analysis

Reproducible analysis of Zürich "Leerkündigungen" using Open Government Data.

## Overview

This project provides a self-contained, reproducible analysis of Leerkündigungen in Zürich.
Important Note: The directories `specs/`, `.specify/`, and `.roo/` are development-only and are not required to run the project and not part of the analysis deliverable.

## Quick Start

### Option 1: Local R Environment

```bash
# Clone and checkout feature branch
git clone <repository-url>
cd leer
git checkout main

# Restore R dependencies
R -e "renv::restore()"

# Run analysis
Rscript -e "rmarkdown::render('analysis/leerkuendigungen_analysis.Rmd', output_dir='output')"

# View results
open output/leerkuendigungen_analysis.html
```

### Option 2: Docker

```bash
# Build image:  
# docker build --platform=linux/amd64 -t leerkuendigungen-analysis -f docker/Dockerfile . for linux apple silicon build
# docker build --platform=linux/amd64 -t leerkuendigungen-analysis -f docker/Dockerfile . probably for windows linux docker containers
docker build -t leerkuendigungen-analysis -f docker/Dockerfile .

# Run analysis
docker run --rm -v $(pwd)/output:/analysis/output leerkuendigungen-analysis

# View results
open output/leerkuendigungen_analysis.html
```

### Option 3: GitHub Actions

1. Go to **Actions** tab on GitHub
2. Select **"Bitte generiere Analysebericht"** workflow
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
│   ├── 03_analyze.R                   # Core analysis func
│   ├── 04_visualize.R                 # Visualizations
│   └── utils.R                        # Helpers
├── tests/
│   └── testthat/                      # Unit tests (stub)
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
└── task_definition.md                 # Original definition for specify
```

## Requirements

- **R**: Version 4.5 or higher
- **Docker**: Version 20.10+ (for containerized execution)

## Documentation

### Development Workflow

This project was partly built using [GitHub Spec-Kit](https://github.com/github/spec-kit), a structured approach to software development, combined with the Roo AI agent for implementation.

**Workflow Steps:**
The following commands we're run using `task_definition.md`:

1. **`/speckit.specify`** - Created the initial feature specification ([`spec.md`](specs/001-leerkuendigungen-analysis/spec.md)) defining user stories, acceptance criteria, and what the analysis should accomplish. This is done by using the users specifications. This file is non-technical and agnostic to technical details, allowing for migration to other programming languages.

2. **`/speckit.plan`** - Generated an implementation plan ([`plan.md`](specs/001-leerkuendigungen-analysis/plan.md)) outlining technical decisions, dependencies, and architecture

3. **`speckit.research`** - Produced research documentation ([`research.md`](specs/001-leerkuendigungen-analysis/research.md)) exploring the dataset structure and analytical approach

4. **`speckit.data-model`** - Defined the data model ([`data-model.md`](specs/001-leerkuendigungen-analysis/data-model.md)) documenting field mappings and data transformations

5. **`speckit.tasks`** - Created a detailed task list ([`tasks.md`](specs/001-leerkuendigungen-analysis/tasks.md)) breaking down the implementation into concrete steps

6. **`/speckit.implement`** - The Roo AI agent executed the tasks, creating R scripts, Docker configuration, and documentation.

This workflow ensures clear documentation at every stage, making the project maintainable and reproducible.

### Project Documentation
These files are for develop, can be changed and must not be reviewed.
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

This analysis uses Open Government Data from the City of Zurich.

## Contact

For issues or questions, please open an issue in the repository.
