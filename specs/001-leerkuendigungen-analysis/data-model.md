# Data Model: Zurich Leerkündigungen Analysis

**Feature**: 001-leerkuendigungen-analysis  
**Date**: 2026-02-02  
**Status**: Complete

## Overview

This document defines the data model for the Zurich Leerkündigungen analysis, including the source dataset schema, conceptual entities, field mappings, and validation rules.

---

## Source Dataset Schema

**Dataset**: BAU505OD5052.csv  
**Source**: City of Zurich Open Government Data Portal  
**URL**: `https://data.stadt-zuerich.ch/dataset/bau_umbau_leerkuendigung_wohnortsgebiete_ag_personen_od5052/download/BAU505OD5052.csv`

### Expected Columns

Based on Zurich OGD naming conventions for building/refurbishment datasets:

| Column Name (German) | Data Type | Description | Constraints |
|---------------------|-----------|-------------|-------------|
| `StichtagDatJahr` | Integer | Reference year (end of refurbishment year) | >= 2000, <= current year |
| `AltersgruppeSort` | String/Factor | Age group in 20-year bands | Non-empty, categorical |
| `WohnortNachLeerKuendigungLang` | String/Factor | New residence after Leerkündigung | Non-empty, categorical |
| `AnzPersonWir` | Integer | Count of affected persons | >= 0 |
| `GebKatLang` (optional) | String/Factor | Building category | May be present |
| `LeerKuendigungKatLang` (optional) | String/Factor | Leerkündigung category | May be present |

**Note**: Actual column names will be validated at runtime. If names differ, explicit mapping will be documented in analysis output.

### Expected Categories

#### Age Groups (AltersgruppeSort)
Expected values (exact labels to be confirmed at runtime):
- `0-19 Jahre` or similar
- `20-39 Jahre` or similar
- `40-59 Jahre` or similar
- `60+ Jahre` or similar

**Validation**: Must have at least 3 distinct age groups.

#### New Residence (WohnortNachLeerKuendigungLang)
Expected values (exact labels to be confirmed at runtime):
- `Gleiches Stadtquartier` (Same city quarter)
- `Anderes Stadtquartier` (Different city quarter)
- `Ausserhalb Stadt Zürich` (Outside Zurich city)
- `Unbekannt` (Unknown) - may or may not be present
- Other categories possible (e.g., specific regions)

**Validation**: Must have at least 2 distinct residence categories.

---

## Conceptual Entities

### 1. Affected Person (Aggregate)

**Description**: An individual who received a Leerkündigung (eviction notice due to building refurbishment). Represented as aggregate counts, not individual records.

**Attributes**:
- **Year**: Reference year when Leerkündigung occurred
- **Age Group**: Categorical classification (20-year bands)
- **New Residence**: Where the person lives after Leerkündigung
- **Count**: Number of persons in this combination of year/age/residence

**Relationships**:
- Grouped by Year (temporal analysis)
- Grouped by Age Group (demographic analysis)
- Grouped by New Residence (outcome analysis)

**Constraints**:
- Count must be non-negative integer
- Each record represents aggregate, not individual person
- No person-level attributes (privacy protection)

### 2. Year

**Description**: Reference year (end of refurbishment year) for temporal analysis.

**Attributes**:
- **Value**: Integer year (e.g., 2015, 2016, ...)
- **Total Affected**: Sum of all counts for this year
- **Composition**: Distribution of residence outcomes for this year

**Validation**:
- Must be reasonable range (e.g., 2000-2025)
- Should have multiple years for temporal analysis (minimum 3)

### 3. Age Group

**Description**: Categorical classification of affected persons in 20-year bands.

**Attributes**:
- **Label**: String representation (e.g., "20-39 Jahre")
- **Sort Order**: Numeric order for consistent visualization
- **Within City Share**: Percentage remaining within Zurich city

**Validation**:
- Must be non-empty
- Should have consistent band width (20 years)
- Must have at least 3 groups for meaningful comparison

### 4. New Residence Category

**Description**: Categorical label indicating where affected persons live after Leerkündigung.

**Attributes**:
- **Label**: String representation (e.g., "Gleiches Stadtquartier")
- **Within City Flag**: Boolean indicating if category is within Zurich city
- **Count**: Total affected persons in this category across all years/ages

**Validation**:
- Must be non-empty
- Must map to Within/Outside city binary

### 5. Within/Outside City Binary (Derived)

**Description**: Derived binary grouping for simplified analysis.

**Definition**:
- **Within Zurich City**: "Gleiches Stadtquartier" + "Anderes Stadtquartier"
- **Outside Zurich City**: All other categories (excluding "Unknown" if analyzed separately)

**Attributes**:
- **Within City**: Boolean flag
- **Share**: Percentage of affected persons remaining within city

**Rationale**: Simplifies age-group comparison by reducing dimensionality while preserving key policy-relevant distinction.

---

## Field Mappings

### Dataset → Conceptual Model

| Conceptual Field | Dataset Column | Mapping Logic |
|-----------------|----------------|---------------|
| `year` | `StichtagDatJahr` | Direct mapping (integer) |
| `age_group` | `AltersgruppeSort` | Direct mapping (factor) |
| `new_residence` | `WohnortNachLeerKuendigungLang` | Direct mapping (factor) |
| `count` | `AnzPersonWir` | Direct mapping (integer) |
| `within_city` | Derived | `new_residence %in% c("Gleiches Stadtquartier", "Anderes Stadtquartier")` |

### Within/Outside City Mapping

**Within City Categories**:
```r
WITHIN_CITY_CATEGORIES <- c(
  "Gleiches Stadtquartier",
  "Anderes Stadtquartier"
)
```

**Outside City Categories**:
- All categories NOT in `WITHIN_CITY_CATEGORIES`
- Excludes "Unbekannt" (Unknown) if analyzed separately

**Unknown Handling**:
- If "Unbekannt" category exists, it is reported separately
- Not included in Within/Outside binary for primary analysis
- Distribution across age groups analyzed in Q5

---

## Validation Rules

### Data Loading Validation

```r
# 1. Required columns exist
required_cols <- c("StichtagDatJahr", "AltersgruppeSort", 
                   "WohnortNachLeerKuendigungLang", "AnzPersonWir")
stopifnot("Required columns missing" = all(required_cols %in% colnames(df)))

# 2. Data types are correct
stopifnot("Year must be numeric" = is.numeric(df$StichtagDatJahr))
stopifnot("Count must be numeric" = is.numeric(df$AnzPersonWir))

# 3. Counts are non-negative
stopifnot("Counts must be non-negative" = all(df$AnzPersonWir >= 0))

# 4. Years are in reasonable range
stopifnot("Years out of range" = all(df$StichtagDatJahr >= 2000 & 
                                      df$StichtagDatJahr <= as.integer(format(Sys.Date(), "%Y"))))

# 5. Sufficient categories
stopifnot("Insufficient age groups" = length(unique(df$AltersgruppeSort)) >= 3)
stopifnot("Insufficient residence categories" = length(unique(df$WohnortNachLeerKuendigungLang)) >= 2)

# 6. Sufficient temporal coverage
stopifnot("Insufficient years" = length(unique(df$StichtagDatJahr)) >= 3)
```

### Analysis Validation

```r
# 1. Within city mapping produces valid binary
stopifnot("Within city mapping failed" = all(df$within_city %in% c(TRUE, FALSE)))

# 2. Total counts match
total_original <- sum(df$AnzPersonWir)
total_mapped <- sum(df$count)
stopifnot("Count mismatch after mapping" = total_original == total_mapped)

# 3. No missing values in key fields (after mapping)
stopifnot("Missing years" = !any(is.na(df$year)))
stopifnot("Missing age groups" = !any(is.na(df$age_group)))
stopifnot("Missing counts" = !any(is.na(df$count)))
```

---

## Data Transformations

### 1. Field Renaming

```r
df <- df %>%
  rename(
    year = StichtagDatJahr,
    age_group = AltersgruppeSort,
    new_residence = WohnortNachLeerKuendigungLang,
    count = AnzPersonWir
  )
```

### 2. Within/Outside City Derivation

```r
df <- df %>%
  mutate(
    within_city = new_residence %in% WITHIN_CITY_CATEGORIES
  )
```

### 3. Unknown Separation (if exists)

```r
# Check if Unknown category exists
has_unknown <- any(grepl("Unbekannt|Unknown", df$new_residence, ignore.case = TRUE))

if (has_unknown) {
  # Create separate flag for Unknown
  df <- df %>%
    mutate(
      is_unknown = grepl("Unbekannt|Unknown", new_residence, ignore.case = TRUE)
    )
  
  # For Within/Outside analysis, exclude Unknown
  df_known <- df %>% filter(!is_unknown)
} else {
  df_known <- df
}
```

---

## Aggregation Patterns

### Temporal Aggregation (Q1)

```r
# Total affected count by year
temporal_summary <- df %>%
  group_by(year) %>%
  summarise(
    total_affected = sum(count),
    .groups = "drop"
  )
```

### Composition Aggregation (Q2)

```r
# Residence composition by year
composition_summary <- df %>%
  group_by(year, new_residence) %>%
  summarise(
    count = sum(count),
    .groups = "drop"
  ) %>%
  group_by(year) %>%
  mutate(
    share = count / sum(count)
  )
```

### Age Group Aggregation (Q3)

```r
# Within city share by age group
age_summary <- df_known %>%
  group_by(age_group, within_city) %>%
  summarise(
    count = sum(count),
    .groups = "drop"
  ) %>%
  group_by(age_group) %>%
  mutate(
    share = count / sum(count)
  ) %>%
  filter(within_city == TRUE)
```

---

## Data Quality Considerations

### Potential Issues

1. **Missing Years**: Gaps in time series (e.g., no data for certain years)
   - **Handling**: Document in exploration phase, do not interpolate

2. **Unknown Category**: High proportion of "Unbekannt" in certain years
   - **Handling**: Report explicitly, analyze distribution across age groups (Q5)

3. **Small Counts**: Some age group × residence combinations may have very small counts
   - **Handling**: Report as-is, note in statistical test interpretation (chi-square assumptions)

4. **Category Label Changes**: Residence categories may change over time
   - **Handling**: Document any inconsistencies, map to consistent labels if possible

5. **Aggregation Level**: Data is already aggregated (no individual records)
   - **Implication**: Cannot perform person-level analysis, only aggregate patterns

---

## Summary

This data model defines:
- **Source schema**: Expected columns and data types from BAU505OD5052.csv
- **Conceptual entities**: Affected Person, Year, Age Group, New Residence, Within/Outside City
- **Field mappings**: Dataset columns → conceptual fields with explicit logic
- **Validation rules**: Fail-fast checks for data quality and completeness
- **Transformations**: Renaming, derivation, and aggregation patterns
- **Quality considerations**: Potential issues and handling strategies

All mappings and definitions will be explicitly documented in the analysis output to ensure transparency and reproducibility (Constitution Principle IV).
