reproducible Analysis of Zurich “Leerkündigungen” (OGD)
1. Context and Assignment Requirements

This work package addresses the interview task:

Select one dataset from the City of Zurich Open Government Data portal.

Perform a small analysis that includes load → exploration → analysis → visualization.

Provide a self-contained runnable environment that executes the analysis and provides the results.

This specification defines the required analytical behavior and narrative, independent of the chosen technology stack.

2. Objective

Create a concise, reproducible analysis of Leerkündigungen in Zurich using one single OGD dataset, focusing on:

Clear group differences (especially by age group and new residence after Leerkündigung),

A pattern that emerges from the dataset alone,

A transparent and defensible methodology that stays descriptive (no causal claims).

3. Data Source and Runtime Retrieval
3.1 Official Dataset URL (must be retrieved at runtime)

The analysis must download the dataset from the City of Zurich OGD portal during execution, using:

https://data.stadt-zuerich.ch/dataset/bau_umbau_leerkuendigung_wohnortsgebiete_ag_personen_od5052/download/BAU505OD5052.csv

3.2 Single Dataset Rule

The analysis must use only this dataset.

No external joins, enrichments, or secondary datasets are permitted.

4. Required Fields (Conceptual)

The analysis must rely on these conceptual fields (exact names may vary but must be mapped explicitly):

Year: reference year (end of year of refurbishment year)

New residence after Leerkündigung: categorical label for where affected persons live afterwards

Age group: categorical label in 20-year bands

Count measure: numeric measure representing affected persons (used for aggregation)

Optional dimensions (use if present but do not depend on them):

Building category

Leerkündigung category related to refurbished buildings

5. Definitions (Must Be Stated)
5.1 Aggregation Measure

All totals, shares, and comparisons must be computed using the dataset’s count measure (affected persons).

5.2 “Within Zurich City” vs “Outside Zurich City”

Define a binary grouping of new residence categories:

Within city: “same city quarter” + “different city quarter”

Outside city: all remaining new residence categories

If the dataset uses different labels, the mapping must be clearly documented.

5.3 “Unknown” New Residence

If an “Unknown” category exists:

It must be reported explicitly (not silently removed).

The analysis must check whether it is evenly distributed across age groups or concentrated.

6. Required Workflow: 
6.1 Load

Download the dataset from the official URL at runtime.

Validate that required fields exist and are usable.

6.2 Explore (Sanity Checks)

Document:

time range (earliest/latest year),

total affected count across all years,

which categories exist (new residence, age groups),

whether “Unknown” exists and its overall share,

any obvious anomalies (missing years, unexpected empty categories).

6.3 Analyze (Core Questions)

Using only this dataset, answer:

Q1 — Time

How does the total affected count change over time?

Identify peak year(s) and describe the temporal pattern (stable vs wave-like).

Q2 — Composition shift 

Is the distribution of new residence outcomes stable over time, or does it shift?

Identify at least one year where the composition deviates clearly from typical years.

Q3 — group differences 

Do age groups differ in the likelihood of remaining within Zurich city vs moving outside?

Compare within-city shares across age groups and quantify the strongest contrast.

Q4 — Same-quarter dependence on age (if available)

If “same city quarter” exists:

Compare its share across age groups and highlight strong contrasts.

Q5 — Unknown

If “Unknown” exists:

Quantify differences across age groups and discuss plausible non-causal reasons.

6.4 Visualize

Provide visuals that communicate:

total affected count over time,

residence composition over time,

relationship between age group and residence outcomes (direct or via within/outside split).

Exact chart types are not prescribed; clarity is the requirement.

7. Statistical Relevance 

Include one simple statistical check that supports “differences are systematic”:

Test association between age group and new residence outcome.

Report an interpretable effect size, and interpret conservatively (no overclaiming).

8. Deliverable Behavior 

The deliverable must ensure that:

The full analysis can be executed end-to-end in a clean environment with a single action.

Data retrieval from the official URL occurs during execution.

Results are produced in a human-readable form with the key findings and visuals.

No specific technologies, packaging tools, or file types are mandated here—only the behavior and outcomes.

9. Non-Goals / Guardrails

No causal claims; descriptive results only.

No linkage to other datasets.

No person-level inference; aggregate level only.

If anomalies are found (e.g., “Unknown”), frame them as data-quality or reporting considerations