# EU Gender Pay Gap Analysis

**Where is the gender pay gap largest across the EU, is it closing, and what is it associated with?**

An end-to-end analytics project using official Eurostat data for all 27 EU member states (2006–2024), built with Python, PostgreSQL, Excel and an interactive dashboard.

**Author:** Yaw Assensoh · **Portfolio:** [yaw-assensoh.github.io](https://yaw-assensoh.github.io/portfolio/index.html#home)

---

## Interactive dashboard

**[Open the dashboard](https://github.com/Yaw-Assensoh/eu-gender-pay-gap-analysis/tree/main?tab=readme-ov-file)** — a year slider (2006–2024) updates the KPIs, country map, ranking, trend, sector chart and age chart together. Works on desktop and mobile.

---

## Business question

The headline EU pay gap hides large differences between countries, industries and age groups. This project asks:

1. Is the gap closing, and how fast?
2. Which countries and industries have the largest gaps?
3. How does the gap change with age?
4. Does region explain differences between countries?

---

## Key findings

| # | Finding | Evidence |
|---|---|---|
| 1 | **The gap is closing at about 0.33 percentage points a year.** The EU average fell from 16.1% (2006) to 10.5% (2024). The pace was faster after 2015 (−0.45 pp/yr) than in 2006–2015 (−0.25 pp/yr). At a straight-line pace it would reach zero around 2056; real progress rarely follows a straight line. | Linear regression, p < 0.001, R² = 0.92 |
| 2 | **Country differences are large.** 15 of 27 countries are above the EU average in 2024. Estonia is highest (18.8%), Luxembourg lowest (−0.8%). Estonia and Poland (4.0%) are both Eastern European, so region alone does not explain the gap. The largest improvement since 2006 is the Netherlands (−12.4 pp). | Descriptive analysis |
| 3 | **Finance & insurance has the highest sector-level gap.** It averages 24.1% across countries, against 9.8% for all other sectors combined. | Independent t-test, p < 0.0001 |
| 4 | **The gap is larger for workers aged 35–44 than for under-25s.** Comparing each country with itself, it rises from 3.9% to 11.2% (latest year per country, 27 countries). This is an association with age; the analysis does not identify its cause. | Paired t-test, p < 0.001 |
| 5 | **The regression cannot tell us how much of the gap is unexplained.** The full model (sector gaps, age gaps, region) reaches R² = 0.99 on 25 countries, but it uses 15 predictors for 25 observations, and sector and age gaps are components of the overall gap, so a near-perfect fit is expected and says little. Region alone explains little (R² = 0.15, p = 0.27). | OLS regression (Notebook 07) |

---

## Data

All data comes from [Eurostat](https://ec.europa.eu/eurostat), the EU's statistical office.

| Dataset | Eurostat code | Contents |
|---|---|---|
| Headline gap | [`sdg_05_20`](https://ec.europa.eu/eurostat/databrowser/product/view/SDG_05_20) | Unadjusted gender pay gap (%) by country and year |
| By sector | [`earn_gr_gpgr2`](https://ec.europa.eu/eurostat/databrowser/product/view/earn_gr_gpgr2) | Gap across 18 NACE industry sectors |
| By age | [`earn_gr_gpgr2ag`](https://ec.europa.eu/eurostat/databrowser/product/view/earn_gr_gpgr2ag) | Gap across 6 age groups |

The gender pay gap is the difference between men's and women's average gross hourly earnings, as a percentage of men's earnings.

**Averaging note:** EU averages here are *unweighted* — each country counts equally. Eurostat's published EU figure is weighted by workforce size (11.1% for 2024, against 10.5% here). Both are valid; equal weighting suits country-level comparison.

---

## Methodology

1. **Clean (Python/pandas):** kept EU-27 countries only, removed aggregate sector rows that double-count, decoded Eurostat quality flags, and added an `eu_region` column (Northern / Southern / Eastern / Western).
2. **Query (PostgreSQL):** loaded the clean tables and answered seven business questions using window functions, CTEs and `CASE` logic.
3. **Explore and test (Python):** seven notebooks cover data audit, EDA, trends, sector and age analysis, statistical tests and a regression model.
4. **Communicate:** an Excel workbook for non-technical readers and the interactive dashboard.

Each notebook explains every step in plain language before the code and states the finding after each chart.

---

## Repository structure

```
eu-gender-pay-gap-analysis/
├── data/clean/             gpg_main.csv · gpg_sector.csv · gpg_age.csv
├── data/raw/               original Eurostat downloads (add these first)
├── notebooks/              eu_gpg_00 … eu_gpg_07 (.ipynb)
├── sql/                    eu_gpg_queries.sql · images/ (query screenshots)
├── excel/                  EU_GPG_Analysis.xlsx
├── dashboard/              eu-gender-pay-gap-dashboard.html
├── reports/                data_quality_report.csv · statistical_test_results.csv · figures/
├── requirements.txt
└── README.md
```

| Notebook | Purpose |
|---|---|
| `00_clean_data` | Raw Eurostat files → clean tables |
| `01_data_audit` | Missing values, quality flags, coverage |
| `02_eda` | Distributions, outliers, regional patterns |
| `03_trends` | Change over time and rate of progress |
| `04_sector_analysis` | Industry-level gaps |
| `05_age_analysis` | Gap by age group |
| `06_statistical_tests` | Regression, ANOVA, t-tests |
| `07_regression` | OLS model with sector, age and region |

---

## Limitations

- **Aggregate data.** Eurostat publishes country-level averages here, not individual records. The regression therefore describes differences between countries, not between individual workers.
- **Small sample for group comparisons.** With 27 countries (6–8 per region), regional tests have limited statistical power. The ANOVA result should be read with that in mind.
- **Association, not causation.** The age and sector patterns are statistically significant associations. The data cannot show why they occur.
- **Missing years.** Some countries lack data for some years; these are left blank, not estimated. Sector and age series start in 2007.
- **Regression is descriptive only.** With 27 countries and predictors that overlap with the outcome, the OLS model is overfitted and should not be read as measuring an "adjusted" gap.
- **Unadjusted gap.** The headline gap does not control for hours, occupation or experience.

## Future work

- Use Eurostat's Structure of Earnings Survey microdata to calculate an individual-level adjusted gap controlling for occupation, education and contract type.
- Test whether national pay-transparency laws changed the trend, once post-2026 data is available.