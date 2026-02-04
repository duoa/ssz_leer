# Dockerfile for Zürich Leerkündigungen Analysis
FROM rocker/tidyverse:4.3

WORKDIR /analysis

# System dependencies (match GitHub Actions + ragg/webp needs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    pandoc \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    zlib1g-dev \
    libwebp-dev \
    libx11-dev \
 && rm -rf /var/lib/apt/lists/*

# renv config (avoid sandbox warnings inside containers)
ENV RENV_CONFIG_SANDBOX_ENABLED=FALSE

# Copy renv files first for better caching
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Restore R dependencies using renv (single source of truth)
RUN R -e "if (!requireNamespace('renv', quietly=TRUE)) install.packages('renv', repos='https://cloud.r-project.org'); renv::restore(prompt=FALSE)"

# Copy project files
COPY scripts/ scripts/
COPY analysis/ analysis/
COPY README.md README.md

# Create output directory
RUN mkdir -p output

# Run analysis by default
CMD ["Rscript", "-e", "rmarkdown::render('analysis/leerkuendigungen_analysis.Rmd', output_dir='output')"]
