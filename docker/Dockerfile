# Dockerfile for Zurich Leerkündigungen Analysis
# Based on rocker/tidyverse for pre-installed R + tidyverse packages

FROM rocker/tidyverse:4.3

# Set working directory
WORKDIR /analysis

# Install additional R packages
RUN R -e "install.packages(c('rmarkdown', 'testthat'), repos='https://cloud.r-project.org/')"

# Copy renv files first for better caching
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Restore R dependencies using renv
RUN R -e "renv::restore()"

# Copy project files
COPY scripts/ scripts/
COPY analysis/ analysis/
COPY README.md README.md

# Create output directory
RUN mkdir -p output

# Set environment variable to avoid renv warnings
ENV RENV_CONFIG_SANDBOX_ENABLED=FALSE

# Run analysis by default
CMD ["Rscript", "-e", "rmarkdown::render('analysis/leerkuendigungen_analysis.Rmd', output_dir='output')"]
