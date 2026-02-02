# Zurich Leerkündigungen Analysis Constitution

<!--
Sync Impact Report:
- Version change: [initial] → 1.0.0
- Initial constitution creation
- Principles defined: 5 core principles aligned with reproducible OGD analysis requirements
- Templates: ⚠ pending validation against new principles
- Follow-up: Validate plan-template.md, spec-template.md, tasks-template.md for alignment
-->

## Core Principles

### I. Single Dataset Rule (NON-NEGOTIABLE)
The analysis MUST use only the official Zurich OGD dataset (BAU505OD5052.csv).

**Rationale**: Ensures reproducibility and prevents hidden dependencies. No external joins, enrichments, or secondary datasets are permitted.

### II. Runtime Data Retrieval
The dataset MUST be downloaded from the official URL during execution, not bundled or cached.

**URL**: `https://data.stadt-zuerich.ch/dataset/bau_umbau_leerkuendigung_wohnortsgebiete_ag_personen_od5052/download/BAU505OD5052.csv`

**Rationale**: Guarantees analysis runs against current official data and remains verifiable.

### III. Descriptive Analysis Only
All findings MUST remain descriptive. No causal claims are permitted.

**Rationale**: The dataset structure does not support causal inference. Anomalies must be framed as data-quality or reporting considerations, not causal mechanisms.

### IV. Transparent Methodology
All aggregations, groupings, and definitions MUST be explicitly documented.

**Required documentation**:
- Aggregation measure definition (affected persons count)
- "Within Zurich City" vs "Outside Zurich City" mapping
- Treatment of "Unknown" categories
- Field name mappings if dataset labels differ from conceptual fields

**Rationale**: Ensures analysis is defensible and reproducible by others.

### V. Self-Contained Execution
The complete analysis MUST execute end-to-end in a clean environment with a single action.

**Requirements**:
- No manual data preparation steps
- No external configuration files required
- Results produced in human-readable form
- All dependencies explicitly declared

**Rationale**: Enables verification and reduces execution friction.

## Required Workflow

The analysis MUST follow this sequence:

1. **Load**: Download dataset from official URL, validate required fields exist
2. **Explore**: Document time range, totals, categories, anomalies
3. **Analyze**: Answer core questions (Q1-Q5 from specification)
4. **Visualize**: Produce clear visuals for temporal patterns, composition, and age-group relationships

## Quality Standards

### Statistical Relevance
Include one simple statistical check (e.g., chi-square test for age group vs residence outcome association).

Report interpretable effect size. Interpret conservatively.

### Required Outputs
- Total affected count over time
- Residence composition over time
- Age group vs residence outcome relationship
- At least one surprising/non-obvious pattern identified

## Governance

This constitution defines the non-negotiable requirements for the Zurich Leerkündigungen analysis.

**Amendment procedure**: Changes require documentation of rationale and impact on existing analysis code.

**Compliance**: All analysis code must verify adherence to Single Dataset Rule and Descriptive Analysis Only principles before execution.

**Version**: 1.0.0 | **Ratified**: 2026-02-02 | **Last Amended**: 2026-02-02
