# EU Gender Pay Gap Analysis
### A Complete Data Analytics Portfolio Project

**Author:** Yaw Assensoh
**Data Source:** Eurostat 2024
**Scope:** All 27 EU Member States | 2002–2024
**Tools:** Python · PostgreSQL · Excel · Tableau

---

## What This Project Is About

The gender pay gap — the difference between what men and women earn
on average is one of the most widely discussed but least deeply
analysed topics in economics and policy.

This project goes beyond the headline number. Using official Eurostat
data covering all 27 EU member states from 2002 to 2024, it builds
a complete picture of the pay gap from three angles: which countries
are most and least equal, which industries drive the gap, and how
the gap changes across a woman's working lifetime.

The project then uses statistical testing and regression modelling
to separate genuine findings from noise — and to estimate how much
of the gap remains unexplained even after controlling for where
people work and how old they are.

**Key finding:** The EU gender pay gap is real, shrinking slowly,
and significantly driven by the finance sector and the motherhood
penalty. Even after controlling for sector, age, and region, a
meaningful unexplained gap remains across the EU.

---

## Live Dashboard

> 🔗 **[View the Interactive Tableau Dashboard](#)**
> *(Link will be updated after Tableau Public deployment)*

---

## Project Structure

```
eu-gender-pay-gap-analysis/
│
├── data/
│   ├── raw/                    # Original Eurostat downloads (not tracked)
│   └── clean/                  # Cleaned, structured CSVs ready for analysis
│       ├── gpg_main.csv        # Headline GPG by country & year
│       ├── gpg_sector.csv      # GPG by 18 industry sectors
│       ├── gpg_age.csv         # GPG by 6 age groups
│       └── v_gpg_summary.csv   # Combined summary view (for Tableau)
│
├── notebooks/                  # Python Jupyter notebooks (full analysis)
│   ├── 01_data_audit.ipynb
│   ├── 02_eda.ipynb
│   ├── 03_trends.ipynb
│   ├── 04_sector_analysis.ipynb
│   ├── 05_age_analysis.ipynb
│   ├── 06_statistical_tests.ipynb
│   └── 07_regression.ipynb
│
├── sql/                        # PostgreSQL schema and analysis queries
│   ├── eu_gpg_queries.sql
│   └── images/            # Query result screenshots from pgAdmin
│
├── excel/
│   └── EU_GPG_Analysis.xlsx    # Excel workbook with PivotTables and charts
│
├── reports/
│   ├── data_quality_report.csv
│   ├── statistical_test_results.csv
│   └── figures/                # All charts exported from Python notebooks
│
├── dashboard/                  # Tableau workbook files
│
├── requirements.txt            # Python dependencies
└── README.md
```

---

## Data Sources

All data is sourced from **Eurostat** — the official statistical
office of the European Union. Every dataset is publicly available
and free to download.

| Dataset | Eurostat Code | What it contains |
|---|---|---|
| Main GPG | `sdg_05_20` | Unadjusted pay gap % by country, 2002–2024 |
| GPG by sector | `earn_gr_gpgr2` | Pay gap across 18 NACE industry sectors |
| GPG by age | `earn_gr_gpgr2ag` | Pay gap across 6 age groups |

**Note on the EU average:** All EU averages in this project are
unweighted  each country counts equally regardless of population
size. Eurostat's published weighted average (11.1%) gives larger
economies more influence. Both are valid; the choice depends on
the analytical question.

---

## Tools & Technologies

| Tool | Phase | Purpose |
|---|---|---|
| **Python** | Cleaning, Analysis, Modelling | pandas, matplotlib, seaborn, scipy, statsmodels |
| **PostgreSQL** | Database Analysis | Multi-table queries, window functions, CTEs |
| **Excel** | Spreadsheet Analysis | PivotTables, conditional formatting, charts |
| **Tableau Public** | Dashboard | Interactive live visualisation |
| **VS Code + Jupyter** | Development | Notebook authoring environment |
| **GitHub** | Version Control | Full project history and reproducibility |

---

## Notebooks Guide

Each notebook follows a narrative structure markdown explanations
before every analysis step and plain English insight after every
chart. Non-technical readers can follow the entire analysis by
reading only the markdown cells.

| Notebook | What it does |
|---|---|
| `01_data_audit` | Audits data quality missing values, flags, coverage |
| `02_eda` | Explores distributions, outliers, and regional patterns |
| `03_trends` | Analyses how the gap has changed since 2006 |
| `04_sector_analysis` | Deep dives into industry-level patterns |
| `05_age_analysis` | Quantifies the motherhood penalty across all EU countries |
| `06_statistical_tests` | Tests whether findings are statistically significant |
| `07_regression` | Builds an OLS model to estimate the adjusted pay gap |

---

## SQL Analysis

The `sql/` folder contains a fully commented PostgreSQL script with
7 business questions answered using structured queries:

1. Country rankings 2024 — who has the highest and lowest gap?
2. EU average trend — is progress real or noise?
3. Regional comparison — which EU region is most unequal?
4. Sector analysis — which industries pay women least fairly?
5. Finance vs Public Admin — how large is the contrast?
6. Age effect — does the gap grow as workers get older?
7. Most improved — which countries have made most progress since 2010?

---

## Key Findings

### 1. The gap is shrinking — but slowly
The EU average pay gap fell from approximately 17% in 2006 to
10.5% in 2024. Linear regression confirms this trend is
statistically significant. At the current rate, the EU would
not reach pay equality until the second half of this century.

### 2. Finance & insurance is the worst sector — by a large margin
The finance sector gap is more than double the EU average in most
countries. An independent t-test confirms this difference is
statistically significant. Public administration — with its
transparent pay scales — consistently has the smallest gap.

### 3. The motherhood penalty is real and universal
The pay gap nearly doubles between the Under 25 and 35–44 age
groups. A paired t-test across all 27 EU countries confirms
this jump is statistically significant. The penalty is universal
 every EU region shows the same upward pattern — though the
size varies by country.

### 4. A significant gap remains unexplained
OLS regression controlling for sector, age group, and EU region
leaves a meaningful unexplained residual for most countries.
This unexplained portion the adjusted gap cannot be
attributed to structural differences in where people work
or how old they are.

### 5. Estonia and Luxembourg are structural outliers
Estonia (18.8%) has the highest gap in the EU, driven by
strong occupational segregation between high-paying male-dominated
sectors and lower-paying female-dominated sectors. Luxembourg
(−0.8%) is the only EU country where women earn more than men
on average explained by its specific economic composition
as a financial centre rather than exceptional equality policy.

---

## How to Reproduce This Project

 https://github.com/Yaw-Assensoh/Eu-gender-pay-gap-analysis.git


###  Download raw data
Download the three datasets from Eurostat and place them in `data/raw/`:
- `sdg_05_20` → [Main GPG](https://ec.europa.eu/eurostat/databrowser/product/view/SDG_05_20)
- `earn_gr_gpgr2` → [GPG by sector](https://ec.europa.eu/eurostat/databrowser/product/view/earn_gr_gpgr2)
- `earn_gr_gpgr2ag` → [GPG by age](https://ec.europa.eu/eurostat/databrowser/product/view/earn_gr_gpgr2ag)

---

## Portfolio & Contact

**Portfolio:** [yaw-assensoh.github.io](https://yaw-assensoh.github.io/portfolio/index.html#home)
**GitHub:** [github.com/Yaw-Assensoh](https://github.com/Yaw-Assensoh)

---

*Data last updated by Eurostat: February/March 2026*
*Project completed: May 2026*
