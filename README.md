# EU Gender Pay Gap Analysis

**Is the EU gender pay gap closing, and where does it stay large?**

Eurostat data for 27 EU countries, 2006 to 2024. Python, PostgreSQL, Excel and an interactive dashboard.

**Live dashboard:** [open it here](https://yaw-assensoh.github.io/eu-gender-pay-gap-analysis/dashboard/eu-gender-pay-gap-dashboard.html) (file: `dashboard/eu-gender-pay-gap-dashboard.html`)
**Case study:** [portfolio write-up](https://yaw-assensoh.github.io/portfolio/projects/eu-gender-pay-gap.html)
**Author:** Yaw Assensoh Opoku, Hamburg

---

## My view

Stop watching the EU average. At 10.5% it reads as one problem. It is two: countries run from -0.8% (Luxembourg) to 18.8% (Estonia), and finance sits at 24.1% while every other sector averages 9.8%. I would start with finance. I would not use this data to explain the age pattern, and I dropped the regression as evidence (see Limitations).

## Key findings

| # | Finding | Evidence |
|---|---|---|
| 1 | **The gap is closing at 0.33 points a year.** The EU average fell from 16.1% (2006) to 10.5% (2024). The pace was 0.25 points a year through 2015 and 0.45 after. At 0.45, zero is 23 years away. | Linear regression, R² 0.92, p < 0.001 |
| 2 | **Country gaps span almost 20 points, and region does not explain them.** 15 of 27 countries sit above the average. Estonia and Poland (4.0%) are both Eastern European. The Netherlands cut its gap most since 2006 (-12.4 points). | ANOVA by region, p = 0.27 |
| 3 | **Finance and insurance averages 24.1%.** All other sectors combined average 9.8%, a difference of 14.3 points. | Independent t-test, p < 0.0001 |
| 4 | **The gap nearly triples from under 25 (3.9%) to 35-44 (11.2%).** Each country is compared with itself. After 45 the regions split: Eastern Europe falls back while Southern and Western Europe keep rising. The data cannot say why. | Paired t-test, p < 0.001, 27 countries |

## Data

All data comes from [Eurostat](https://ec.europa.eu/eurostat).

| Dataset | Code | Contents |
|---|---|---|
| Headline gap | [`sdg_05_20`](https://ec.europa.eu/eurostat/databrowser/product/view/SDG_05_20) | Unadjusted gap (%) by country and year |
| By sector | [`earn_gr_gpgr2`](https://ec.europa.eu/eurostat/databrowser/product/view/earn_gr_gpgr2) | 18 industry sectors |
| By age | [`earn_gr_gpgr2ag`](https://ec.europa.eu/eurostat/databrowser/product/view/earn_gr_gpgr2ag) | 6 age groups |

The gap is the difference between men's and women's average gross hourly earnings, as a percentage of men's earnings. EU averages here are unweighted: each country counts once. Eurostat's weighted EU figure for 2024 is 11.1%, against 10.5% here.

## Method

1. **Clean (Python):** keep the 27 EU countries, remove aggregate sector rows that double-count, decode quality flags, add an `eu_region` column. Notebook `00` rebuilds the clean files from the raw downloads.
2. **Query (PostgreSQL):** seven business questions with window functions, CTEs and `CASE` logic.
3. **Analyse (Python):** seven notebooks cover the audit, exploration, trends, sectors, age, statistical tests and a regression.
4. **Communicate:** an Excel workbook and the interactive dashboard.

## Repository

```
data/raw/        original Eurostat downloads (download these first)
data/clean/      gpg_main.csv, gpg_sector.csv, gpg_age.csv
notebooks/       eu_gpg_00 to eu_gpg_07
sql/             eu_gpg_queries.sql and result screenshots
excel/           EU_GPG_Analysis.xlsx
dashboard/       eu-gender-pay-gap-dashboard.html
reports/         figures and test results
```

| Notebook | Purpose |
|---|---|
| `00_clean_data` | Raw Eurostat files to clean tables |
| `01_data_audit` | Missing values, flags, coverage |
| `02_eda` | Distributions and regional patterns |
| `03_trends` | Change over time and pace of progress |
| `04_sector_analysis` | Industry gaps |
| `05_age_analysis` | Gap by age group |
| `06_statistical_tests` | Regression, ANOVA, t-tests |
| `07_regression` | OLS model, and why it is not used as evidence |

## Limitations

- **Country averages, not individual records.** The data cannot measure an adjusted gap.
- **The regression is not evidence.** It uses 15 predictors for 25 countries, and its sector and age gaps are parts of the overall gap, so it fits almost perfectly and shows nothing. Region alone gives R² 0.15 (p = 0.27).
- **Association only.** The age and sector patterns are statistically significant. The data has no parenthood or working-hours variables, so it cannot give a cause.
- **Small groups.** Each region has 6 to 8 countries, which limits regional tests.
- **Missing years.** Gaps are left blank, never estimated. Sector and age series start in 2007.
- **The t-test is generous.** It treats each country-sector value as independent, though the same countries appear in every sector. The 14.3-point difference is large enough that the result holds.