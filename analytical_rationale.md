# Analytical Rationale

The analysis was designed to move gradually from simple operational understanding into deeper analytical insights. The sequence followed this flow:

- **Data cleaning and validation**  
  Ensured the datasets were reliable and consistent before analysis began.

- **Operational analysis**  
  Explored participation trends, engagement activity, completion outcomes, and regional distribution to understand overall programme performance.

- **At-risk analysis**  
  Identified fellows showing signs of disengagement and compared them against non at-risk fellows.

- **Statistical testing and correlation analysis**  
  Tested whether some of the observed patterns were statistically meaningful rather than random variation.

This structure helped the analysis tell a clear and logical story that both technical and non-technical audiences could follow easily.

---

## Why Certain Analytical Cuts Were Chosen

Geopolitical zones were used more heavily than individual states because they created cleaner and more balanced regional comparisons. State-level analysis introduced too many smaller categories, which made patterns harder to interpret clearly.

Monthly participation trends were also used instead of weekly trends because monthly summaries produced smoother and more meaningful operational patterns. Weekly analysis was explored initially, but the fluctuations created too much noise for publication-ready reporting.

Completion rates were prioritized over raw completion counts because rates allow fairer comparisons across groups of different sizes. For example:

- Larger regions naturally record more completions
- Raw counts alone can therefore be misleading
- Completion rates provide a better measure of relative performance

The at-risk analysis was also limited to fellows who had spent enough time in the programme to allow for fair evaluation. This prevented newly onboarded fellows from being incorrectly classified as disengaged too early.

---

## Alternative Approaches Considered

Several alternative approaches were explored during the project but were not fully implemented.

A predictive machine learning model for identifying at-risk fellows was considered, but the available variables and dataset size were not strong enough to support a reliable production-quality model.

A more detailed state-level statistical analysis was also considered, but smaller subgroup sizes would likely have reduced the reliability and interpretability of the findings.

From a technical architecture perspective, the current workflow used SQLite because it was lightweight, portable, and easier to implement within the project timeline. However, the intended long-term direction is to transition the workflow into a more scalable analytics pipeline using:

- BigQuery as the cloud data warehouse
- Power BI for interactive dashboarding and reporting
- Automated data refresh workflows
- More scalable and production-style analytics infrastructure

This would allow the project to evolve beyond notebook-based analysis into a more interactive business intelligence environment with stronger reporting and monitoring capabilities.
