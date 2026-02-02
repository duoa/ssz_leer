# Feature Specification: Reproducible Analysis of Zurich Leerkündigungen (OGD)

**Feature Branch**: `001-leerkuendigungen-analysis`  
**Created**: 2026-02-02  
**Status**: Draft  
**Input**: User description: "Reproducible Analysis of Zurich 'Leerkündigungen' (OGD)"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Execute Complete Analysis (Priority: P1)

A researcher needs to run the complete Leerkündigungen analysis from start to finish in a clean environment with a single action, obtaining all results including data exploration, analysis findings, and visualizations.

**Why this priority**: This is the core deliverable requirement - a self-contained, reproducible analysis that demonstrates technical competency and analytical thinking.

**Independent Test**: Can be fully tested by executing the analysis in a fresh environment (no pre-installed data or configuration) and verifying that all outputs (exploration summary, analysis answers, visualizations) are produced successfully.

**Acceptance Scenarios**:

1. **Given** a clean environment with no pre-existing data, **When** the analysis is executed with a single command/action, **Then** the dataset is downloaded from the official Zurich OGD portal
2. **Given** the dataset has been downloaded, **When** the analysis proceeds, **Then** exploration results document time range, total affected count, category distributions, and any anomalies
3. **Given** exploration is complete, **When** analysis questions are processed, **Then** all five core questions (Q1-Q5) are answered with quantitative findings
4. **Given** analysis is complete, **When** visualization is generated, **Then** clear visuals show temporal patterns, composition shifts, and age-group relationships
5. **Given** the full analysis has run, **When** results are presented, **Then** they are in human-readable form with key findings clearly stated

---

### User Story 2 - Validate Data Quality and Definitions (Priority: P2)

A reviewer needs to understand exactly how the analysis defines its measures and groupings, and verify that data quality issues (like "Unknown" categories) are handled transparently.

**Why this priority**: Transparency and defensibility are critical for reproducible research; without clear definitions, results cannot be validated or trusted.

**Independent Test**: Can be tested by reviewing the analysis output documentation and verifying that all required definitions (aggregation measure, within/outside city mapping, unknown handling) are explicitly stated and applied consistently.

**Acceptance Scenarios**:

1. **Given** the analysis output, **When** reviewing definitions, **Then** the aggregation measure (affected persons count) is explicitly documented
2. **Given** the analysis uses residence categories, **When** reviewing groupings, **Then** the "Within Zurich City" vs "Outside Zurich City" mapping is clearly documented with exact category assignments
3. **Given** an "Unknown" category exists in the data, **When** the analysis processes it, **Then** it is reported explicitly (not silently removed) with distribution across age groups quantified
4. **Given** dataset field names differ from conceptual names, **When** the analysis maps them, **Then** the mapping is explicitly documented

---

### User Story 3 - Identify Surprising Patterns (Priority: P2)

An analyst needs to discover at least one non-obvious pattern in the data that emerges from the dataset alone, demonstrating analytical depth beyond basic descriptive statistics.

**Why this priority**: This distinguishes a thoughtful analysis from a mechanical report; it shows the ability to extract insights and identify anomalies.

**Independent Test**: Can be tested by reviewing the analysis findings and verifying that at least one pattern is identified that would not be immediately obvious from raw data inspection (e.g., composition shifts in specific years, unexpected age-group concentrations).

**Acceptance Scenarios**:

1. **Given** the temporal analysis (Q2), **When** examining residence composition over time, **Then** at least one year is identified where the distribution deviates clearly from typical years
2. **Given** the surprising pattern is identified, **When** it is reported, **Then** the deviation is quantified (not just qualitatively described)
3. **Given** the pattern is reported, **When** interpreting it, **Then** no causal claims are made (framed as descriptive observation only)

---

### User Story 4 - Compare Age Group Differences (Priority: P1)

 how different age groups are affected by Leerkündigungen, specifically whether younger vs older residents have different likelihoods of remaining in Zurich city vs moving outside.

**Why this priority**: This is a core analytical requirement that addresses clear group differences, which is central to the assignment objective.

**Independent Test**: Can be tested by verifying that the analysis compares within-city shares across all age groups and quantifies the strongest contrast with specific percentages or ratios.

**Acceptance Scenarios**:

1. **Given** the dataset contains age group and new residence data, **When** analyzing group differences (Q3), **Then** within-city shares are calculated for each age group
2. **Given** within-city shares are calculated, **When** comparing across age groups, **Then** the strongest contrast is identified and quantified (e.g., "20-39 age group: 65% within city vs 60+ age group: 45% within city")
3. **Given** age-group differences are found, **When** statistical relevance is assessed, **Then** a simple statistical test (e.g., chi-square) confirms the association is systematic, not random

---

### User Story 5 - Verify Statistical Relevance (Priority: P3)

A methodologist needs to confirm that observed differences (especially age-group patterns) are systematic rather than random noise, using a simple and interpretable statistical check.

**Why this priority**: Adds rigor to the analysis without overcomplicating it; ensures findings are defensible but remains secondary to the descriptive analysis itself.

**Independent Test**: Can be tested by verifying that one statistical test is performed (testing association between age group and residence outcome), an interpretable effect size is reported, and the interpretation is conservative (no overclaiming).

**Acceptance Scenarios**:

1. **Given** age group and residence outcome data, **When** testing for association, **Then** a simple statistical test (e.g., chi-square test) is performed
2. **Given** the test is performed, **When** reporting results, **Then** an interpretable effect size (e.g., Cramér's V, percentage point differences) is included
3. **Given** results are reported, **When** interpreting them, **Then** the interpretation is conservative and acknowledges limitations (e.g., "suggests systematic differences" not "proves causation")

---

### Edge Cases

- What happens when the official dataset URL is temporarily unavailable or returns an error?
- How does the analysis handle missing years or unexpected gaps in the time series?
- What if required fields (Year, Age Group, New Residence, Count) are missing or renamed in the dataset?
- How does the analysis handle empty categories (e.g., an age group with zero affected persons in certain years)?
- What if the "Unknown" category represents a large majority of cases in certain years?
- How does the analysis handle potential data quality issues like negative counts or impossible age groups?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST download the dataset from the official Zurich OGD URL (`https://data.stadt-zuerich.ch/dataset/bau_umbau_leerkuendigung_wohnortsgebiete_ag_personen_od5052/download/BAU505OD5052.csv`) at runtime, not use pre-bundled or cached data
- **FR-002**: System MUST validate that required conceptual fields (Year, New Residence, Age Group, Count measure) exist in the downloaded dataset before proceeding
- **FR-003**: System MUST use only the single official dataset with no external joins, enrichments, or secondary datasets
- **FR-004**: System MUST document the time range (earliest and latest year) and total affected count across all years during exploration
- **FR-005**: System MUST identify and document all categories present in the dataset (new residence categories, age groups)
- **FR-006**: System MUST explicitly define and document the aggregation measure used for all totals, shares, and comparisons
- **FR-007**: System MUST explicitly define and document the binary grouping of "Within Zurich City" (same city quarter + different city quarter) vs "Outside Zurich City" (all remaining categories)
- **FR-008**: System MUST map dataset field names to conceptual field names explicitly if they differ
- **FR-009**: System MUST report the "Unknown" new residence category explicitly if it exists, including its overall share and distribution across age groups
- **FR-010**: System MUST answer Q1 (time dynamics): quantify how total affected count changes over time, identify peak year(s), describe temporal pattern
- **FR-011**: System MUST answer Q2 (composition shift): determine if residence outcome distribution is stable or shifts over time, identify at least one year with clear deviation
- **FR-012**: System MUST answer Q3 (age gradient): compare within-city shares across age groups and quantify the strongest contrast
- **FR-013**: System MUST answer Q4 (same-quarter dependence): if "same city quarter" category exists, compare its share across age groups and highlight contrasts
- **FR-014**: System MUST answer Q5 (unknown concentration): if "Unknown" category exists, quantify differences across age groups and discuss plausible non-causal reasons
- **FR-015**: System MUST produce visualizations showing: (a) total affected count over time, (b) residence composition over time, (c) relationship between age group and residence outcomes
- **FR-016**: System MUST perform one simple statistical test (e.g., chi-square) to test association between age group and new residence outcome
- **FR-017**: System MUST report an interpretable effect size for the statistical test and interpret conservatively
- **FR-018**: System MUST produce results in human-readable form (not just raw data or code output)
- **FR-019**: System MUST execute the complete analysis end-to-end with a single action in a clean environment
- **FR-020**: System MUST NOT make causal claims; all findings must remain descriptive
- **FR-021**: System MUST frame any anomalies (e.g., high "Unknown" rates) as data-quality or reporting considerations, not causal mechanisms

### Key Entities *(include if feature involves data)*

- **Affected Person**: An individual who received a Leerkündigung (eviction notice due to building refurbishment). Represented by a count measure in the dataset (aggregate level, not individual records).
- **Year**: The reference year (end of refurbishment year) when the Leerkündigung occurred. Used for temporal analysis.
- **Age Group**: Categorical classification of affected persons in 20-year bands (e.g., 0-19, 20-39, 40-59, 60+). Used for group comparison analysis.
- **New Residence After Leerkündigung**: Categorical label indicating where affected persons live after receiving the Leerkündigung (e.g., same city quarter, different city quarter, outside Zurich, unknown). Primary outcome variable.
- **Within/Outside City Binary**: Derived grouping that combines "same city quarter" and "different city quarter" into "Within Zurich City", with all other categories as "Outside Zurich City".

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Analysis executes successfully from start to finish in a clean environment with a single command/action, producing all required outputs
- **SC-002**: Dataset is retrieved from the official Zurich OGD URL during execution (verified by checking that no pre-bundled data files exist)
- **SC-003**: All five core analysis questions (Q1-Q5) are answered with quantitative findings (not just qualitative descriptions)
- **SC-004**: At least one surprising/non-obvious pattern is identified and quantified (e.g., "2018 showed 15 percentage point increase in outside-city moves compared to 2015-2017 average")
- **SC-005**: Age-group differences in within-city vs outside-city outcomes are quantified with specific percentages or ratios (e.g., "20-39 age group: 65% within city vs 60+ age group: 45% within city")
- **SC-006**: All required definitions (aggregation measure, within/outside city mapping, unknown handling) are explicitly documented in the output
- **SC-007**: If "Unknown" category exists, its distribution across age groups is quantified and reported
- **SC-008**: Visualizations clearly communicate temporal patterns, composition shifts, and age-group relationships (verified by visual inspection for clarity)
- **SC-009**: One statistical test is performed with interpretable effect size reported
- **SC-010**: No causal claims are made in the analysis output (verified by text review)
- **SC-011**: Results are presented in human-readable form suitable for a non-technical reviewer
- **SC-012**: Analysis completes within reasonable time (under 5 minutes on standard hardware)
