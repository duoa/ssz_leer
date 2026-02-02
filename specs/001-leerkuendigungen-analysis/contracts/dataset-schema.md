# Dataset Contract: BAU505OD5052.csv

**Feature**: 001-leerkuendigungen-analysis  
**Date**: 2026-02-02  
**Status**: Formal Contract

## Overview

This document defines the formal contract for the Zurich Leerkündigungen dataset (BAU505OD5052.csv). The analysis implementation must validate against this contract at runtime and fail immediately if expectations are not met.

---

## Dataset Metadata

**Dataset ID**: BAU505OD5052  
**Source**: City of Zurich Open Government Data Portal  
**URL**: `https://data.stadt-zuerich.ch/dataset/bau_umbau_leerkuendigung_wohnortsgebiete_ag_personen_od5052/download/BAU505OD5052.csv`  
**Format**: CSV (UTF-8 encoding expected)  
**Update Frequency**: Annual (typically)  
**License**: Open Government Data (OGD) - freely usable with attribution

---

## Required Columns

The dataset MUST contain the following columns (exact names may vary, but conceptual fields must be mappable):

### 1. Year Column

**Expected Name**: `StichtagDatJahr` (or similar: `Jahr`, `Year`, `Stichtag`)  
**Data Type**: Integer  
**Description**: Reference year (end of refurbishment year)  
**Constraints**:
- NOT NULL
- Range: 2000 ≤ value ≤ current year
- Must have at least 3 distinct years for temporal analysis

**Validation**:
```r
stopifnot("Year column missing or invalid" = 
  exists("year_col") && 
  is.numeric(df[[year_col]]) &&
  all(df[[year_col]] >= 2000) &&
  all(df[[year_col]] <= as.integer(format(Sys.Date(), "%Y"))) &&
  length(unique(df[[year_col]])) >= 3
)
```

### 2. Age Group Column

**Expected Name**: `AltersgruppeSort` (or similar: `Altersgruppe`, `AgeGroup`)  
**Data Type**: String/Factor  
**Description**: Age group in 20-year bands  
**Constraints**:
- NOT NULL
- Must have at least 3 distinct categories
- Expected format: "X-Y Jahre" or "X+ Jahre"

**Expected Values** (exact labels to be confirmed at runtime):
- `0-19 Jahre` or equivalent
- `20-39 Jahre` or equivalent
- `40-59 Jahre` or equivalent
- `60+ Jahre` or `60-79 Jahre` or equivalent

**Validation**:
```r
stopifnot("Age group column missing or invalid" = 
  exists("age_col") && 
  !any(is.na(df[[age_col]])) &&
  length(unique(df[[age_col]])) >= 3
)
```

### 3. New Residence Column

**Expected Name**: `WohnortNachLeerKuendigungLang` (or similar: `Wohnort`, `NewResidence`)  
**Data Type**: String/Factor  
**Description**: New residence location after Leerkündigung  
**Constraints**:
- NOT NULL (but "Unbekannt"/"Unknown" is a valid category)
- Must have at least 2 distinct categories
- Must include categories mappable to "within city" and "outside city"

**Expected Values** (exact labels to be confirmed at runtime):
- `Gleiches Stadtquartier` (Same city quarter) - WITHIN CITY
- `Anderes Stadtquartier` (Different city quarter) - WITHIN CITY
- `Ausserhalb Stadt Zürich` (Outside Zurich city) - OUTSIDE CITY
- `Unbekannt` (Unknown) - SPECIAL HANDLING
- Other categories possible (e.g., specific regions outside Zurich)

**Validation**:
```r
stopifnot("New residence column missing or invalid" = 
  exists("residence_col") && 
  !any(is.na(df[[residence_col]])) &&
  length(unique(df[[residence_col]])) >= 2
)
```

### 4. Count Column

**Expected Name**: `AnzPersonWir` (or similar: `Anzahl`, `Count`, `AnzPerson`)  
**Data Type**: Integer  
**Description**: Number of affected persons (aggregate count)  
**Constraints**:
- NOT NULL
- Range: value ≥ 0
- Sum across all rows must be > 0 (non-empty dataset)

**Validation**:
```r
stopifnot("Count column missing or invalid" = 
  exists("count_col") && 
  is.numeric(df[[count_col]]) &&
  all(df[[count_col]] >= 0) &&
  sum(df[[count_col]]) > 0
)
```

---

## Optional Columns

The following columns MAY be present but are NOT required for the analysis:

### 5. Building Category (Optional)

**Expected Name**: `GebKatLang` (or similar)  
**Data Type**: String/Factor  
**Description**: Building category (e.g., residential, mixed-use)  
**Usage**: Not used in core analysis (Q1-Q5), but may be explored if present

### 6. Leerkündigung Category (Optional)

**Expected Name**: `LeerKuendigungKatLang` (or similar)  
**Data Type**: String/Factor  
**Description**: Type of Leerkündigung related to refurbishment  
**Usage**: Not used in core analysis (Q1-Q5), but may be explored if present

---

## Data Quality Expectations

### Completeness

- **No missing values** in required columns (Year, Age Group, New Residence, Count)
- **Unknown category** ("Unbekannt") is acceptable for New Residence, but must be reported explicitly
- **Minimum rows**: At least 10 rows (arbitrary threshold for meaningful analysis)

**Validation**:
```r
stopifnot("Dataset too small" = nrow(df) >= 10)
```

### Consistency

- **Age group bands**: Should be consistent width (20 years) if possible
- **Year continuity**: Gaps in years are acceptable but should be documented
- **Category stability**: Residence categories should be consistent across years (if not, document changes)

### Integrity

- **Non-negative counts**: All counts must be ≥ 0
- **Reasonable totals**: Total affected persons should be in reasonable range (e.g., 100-10,000 per year)
- **No duplicates**: Each combination of (Year, Age Group, New Residence) should appear at most once

**Validation**:
```r
# Check for duplicates
duplicates <- df %>%
  group_by(year, age_group, new_residence) %>%
  filter(n() > 1)

stopifnot("Duplicate rows detected" = nrow(duplicates) == 0)
```

---

## Within/Outside City Mapping Contract

The analysis MUST define a binary grouping of residence categories:

### Within Zurich City

**Definition**: Residence categories indicating the person remains within Zurich city limits.

**Expected Categories**:
- `Gleiches Stadtquartier` (Same city quarter)
- `Anderes Stadtquartier` (Different city quarter)

**Mapping Rule**:
```r
WITHIN_CITY_CATEGORIES <- c(
  "Gleiches Stadtquartier",
  "Anderes Stadtquartier"
)

df$within_city <- df$new_residence %in% WITHIN_CITY_CATEGORIES
```

### Outside Zurich City

**Definition**: All residence categories NOT in the "Within Zurich City" set, excluding "Unknown".

**Expected Categories**:
- `Ausserhalb Stadt Zürich` (Outside Zurich city)
- Any other specific regions outside Zurich

**Mapping Rule**:
```r
# Exclude Unknown for Within/Outside analysis
df_known <- df %>% filter(!grepl("Unbekannt|Unknown", new_residence, ignore.case = TRUE))

df_known$outside_city <- !df_known$within_city
```

### Unknown Handling

**Definition**: Residence category where new location is not known.

**Expected Category**: `Unbekannt` (or `Unknown`)

**Handling Rule**:
- Report explicitly (not silently removed)
- Analyze distribution across age groups (Q5)
- Exclude from Within/Outside binary analysis to avoid bias

---

## Output Contract

The analysis MUST produce the following outputs:

### 1. Exploration Summary

**Format**: Text section in HTML report  
**Required Content**:
- Time range (earliest and latest year)
- Total affected count across all years
- List of all age group categories
- List of all new residence categories
- Whether "Unknown" category exists and its overall share
- Any obvious anomalies (missing years, unexpected empty categories)

### 2. Analysis Answers (Q1-Q5)

**Format**: Text sections with embedded tables/statistics in HTML report  
**Required Content**:
- **Q1**: Total affected count by year, peak year(s), temporal pattern description
- **Q2**: Residence composition by year, identification of at least one deviant year
- **Q3**: Within-city shares by age group, quantified strongest contrast
- **Q4**: Same-quarter shares by age group (if applicable), quantified contrasts
- **Q5**: Unknown distribution by age group (if applicable), quantified differences

### 3. Visualizations

**Format**: Embedded plots in HTML report  
**Required Plots**:
- Line/bar chart: Total affected count over time (Q1)
- Stacked area/bar chart: Residence composition over time (Q2)
- Bar/point chart: Within-city share by age group (Q3)

**Quality Requirements**:
- Clear axis labels (English or German with translation)
- Legible font sizes
- Color-blind friendly palette
- Titles describing what is shown

### 4. Statistical Test Results

**Format**: Text section with statistics in HTML report  
**Required Content**:
- Chi-square test statistic and p-value
- Cramér's V effect size
- Conservative interpretation (no overclaiming)
- Acknowledgment of limitations

---

## Error Handling Contract

The analysis MUST fail immediately (not proceed) if:

1. **Dataset cannot be downloaded** from official URL
   - Error message: "Failed to download dataset from [URL]. Check network connection and URL validity."

2. **Required columns are missing**
   - Error message: "Required column(s) missing: [list]. Expected columns: [list]."

3. **Data types are incorrect**
   - Error message: "Column [name] has incorrect type. Expected [type], got [type]."

4. **Constraints are violated**
   - Error message: "Data constraint violated: [specific constraint]. Details: [details]."

5. **Insufficient data for analysis**
   - Error message: "Insufficient data: [specific issue]. Minimum requirements: [requirements]."

**Implementation**:
```r
# Use stopifnot() for fail-fast validation
# Provide clear, actionable error messages
# Log validation steps for debugging
```

---

## Versioning and Changes

**Contract Version**: 1.0.0  
**Last Updated**: 2026-02-02

### Change Log

- **1.0.0** (2026-02-02): Initial contract definition

### Future Considerations

- If dataset schema changes (column names, categories), update contract and document mapping
- If new categories are added, update Within/Outside mapping and document rationale
- If data quality issues are discovered, add specific validation rules

---

## Summary

This contract defines:
- **Required columns**: Year, Age Group, New Residence, Count with specific constraints
- **Optional columns**: Building Category, Leerkündigung Category
- **Data quality expectations**: Completeness, consistency, integrity
- **Mapping rules**: Within/Outside city binary grouping, Unknown handling
- **Output requirements**: Exploration summary, analysis answers, visualizations, statistical tests
- **Error handling**: Fail-fast validation with clear error messages

The analysis implementation MUST validate against this contract at runtime and fail immediately if expectations are not met, ensuring reproducibility and preventing misleading results from malformed data.
