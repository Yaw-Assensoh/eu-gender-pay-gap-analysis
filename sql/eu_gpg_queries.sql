
-- ============================================================
--  EU GENDER PAY GAP ANALYSIS — PostgreSQL Schema & Queries
--  Author : Yaw Assensoh
--  Data   : Eurostat 2024  (sdg_05_20, earn_gr_gpgr2, earn_gr_gpgr2ag)
--  Scope  : EU-27 member states
-- ============================================================


-- ============================================================
-- SECTION 1: CREATE TABLES
-- ============================================================
-- What this does: defines the structure (columns + data types)
-- of each table before we import the CSV data into it.

CREATE TABLE IF NOT EXISTS gpg_main (
    id          SERIAL PRIMARY KEY,
    country     VARCHAR(60)   NOT NULL,
    year        SMALLINT      NOT NULL,
    gpg_pct     NUMERIC(5,1),          -- pay gap as a percentage, e.g. 15.4
    flag_code   VARCHAR(5),            -- Eurostat quality flag (p, d, b, e, u)
    flag_note   VARCHAR(60),           -- readable version of the flag
    eu_region   VARCHAR(20)            -- Northern / Southern / Eastern / Western
);

CREATE TABLE IF NOT EXISTS gpg_sector (
    id          SERIAL PRIMARY KEY,
    country     VARCHAR(60)   NOT NULL,
    eu_region   VARCHAR(20),
    sector      VARCHAR(60)   NOT NULL,  -- shortened NACE sector name
    year        SMALLINT      NOT NULL,
    gpg_pct     NUMERIC(5,1),
    flag_code   VARCHAR(5),
    flag_note   VARCHAR(60)
);

CREATE TABLE IF NOT EXISTS gpg_age (
    id             SERIAL PRIMARY KEY,
    country        VARCHAR(60)  NOT NULL,
    eu_region      VARCHAR(20),
    age_group      VARCHAR(20)  NOT NULL,  -- e.g. "25-34"
    age_group_sort VARCHAR(15),            -- sort key e.g. "2_25-34"
    year           SMALLINT     NOT NULL,
    gpg_pct        NUMERIC(5,1),
    flag_code      VARCHAR(5),
    flag_note      VARCHAR(60)
);


-- ============================================================
-- SECTION 2: LOAD DATA FROM CSV
-- ============================================================
--  Import/Export tool
--   \copy gpg_main    FROM '/your/path/gpg_main.csv'    CSV HEADER;
--   \copy gpg_sector  FROM '/your/path/gpg_sector.csv'  CSV HEADER;
--   \copy gpg_age     FROM '/your/path/gpg_age.csv'     CSV HEADER;


-- ============================================================
-- SECTION 3: VERIFY THE IMPORT
-- ============================================================
--  check if data looks right before writing analysis queries.

-- How many rows did we load?
SELECT 'gpg_main'   AS table_name, COUNT(*) AS row_count FROM gpg_main
UNION ALL
SELECT 'gpg_sector' AS table_name, COUNT(*) AS row_count FROM gpg_sector
UNION ALL
SELECT 'gpg_age'    AS table_name, COUNT(*) AS row_count FROM gpg_age;
-- Expected: 509 / 7593 / 2371

-- Preview the first 5 rows of each table
SELECT * FROM gpg_main   ORDER BY country, year LIMIT 5;
SELECT * FROM gpg_sector ORDER BY country, sector, year LIMIT 5;
SELECT * FROM gpg_age    ORDER BY country, age_group_sort, year LIMIT 5;


-- ============================================================
-- SECTION 4: QUERY 1 — Country Rankings 2024
-- ============================================================
-- Business question: Which EU countries have the highest and
-- lowest gender pay gap in 2024, and how far are they from
-- the EU average?
--
-- What we use: AVG() window function to calculate the EU average
-- in the same query, ROUND() for clean output, ORDER BY to rank.

SELECT
    country,
    eu_region,
    gpg_pct                                        AS pay_gap_pct,
    ROUND(
        AVG(gpg_pct) OVER ()                       -- EU average across all countries
    , 1)                                           AS eu_avg_pct,
    ROUND(
        gpg_pct - AVG(gpg_pct) OVER ()             -- how far above/below EU avg
    , 1)                                           AS diff_from_eu_avg,
    CASE
        WHEN gpg_pct < 0                           THEN 'Women earn more than men'
        WHEN gpg_pct < AVG(gpg_pct) OVER ()        THEN 'Below EU average (more equal)'
        WHEN gpg_pct < AVG(gpg_pct) OVER () + 5   THEN 'Near EU average'
        ELSE                                            'Above EU average (less equal)'
    END                                            AS gap_category,
    RANK() OVER (ORDER BY gpg_pct DESC)            AS rank_worst
FROM gpg_main
WHERE year = 2024
ORDER BY gpg_pct DESC;


-- ============================================================
-- SECTION 5: QUERY 2 — EU Average Trend Over Time
-- ============================================================
-- Business question: Is the gender pay gap getting better or
-- worse across the EU as a whole over the last 20 years?
--
-- What we use: AVG() with GROUP BY year, LAG() window function
-- to calculate year-on-year change.

SELECT
    year,
    ROUND(AVG(gpg_pct), 1)                              AS eu_avg_gpg,
    ROUND(
        AVG(gpg_pct) - LAG(AVG(gpg_pct)) OVER (ORDER BY year)
    , 2)                                                AS yoy_change,
    CASE
        WHEN AVG(gpg_pct) - LAG(AVG(gpg_pct)) OVER (ORDER BY year) < 0
            THEN 'Improving (gap narrowing)'
        WHEN AVG(gpg_pct) - LAG(AVG(gpg_pct)) OVER (ORDER BY year) > 0
            THEN 'Worsening (gap widening)'
        ELSE 'No change'
    END                                                 AS trend_direction
FROM gpg_main
GROUP BY year
ORDER BY year;


-- ============================================================
-- SECTION 6: QUERY 3 — Which EU Region Has the Worst Gap?
-- ============================================================
-- Business question: Is the pay gap a Northern/Southern/Eastern/
-- Western Europe problem, or is it spread evenly?
--
-- What we use: GROUP BY eu_region, AVG(), COUNT(), JOIN pattern
-- using the same table (self-referencing with subquery).

SELECT
    eu_region,
    ROUND(AVG(gpg_pct), 1)                          AS avg_gap_2024,
    COUNT(DISTINCT country)                         AS country_count,
    MIN(gpg_pct)                                    AS lowest_gap,
    MAX(gpg_pct)                                    AS highest_gap,
    ROUND(MAX(gpg_pct) - MIN(gpg_pct), 1)           AS gap_spread
FROM gpg_main
WHERE year = 2024
GROUP BY eu_region
ORDER BY avg_gap_2024 DESC;


-- ============================================================
-- SECTION 7: QUERY 4 — Sector Analysis (JOIN)
-- ============================================================
-- Business question: Which industries have the worst gender pay
-- gap, and is Finance always the worst sector across all regions?
--
-- What we use: JOIN gpg_sector with gpg_main to compare sector
-- gaps to the country's overall gap. AVG(), RANK() window function.

SELECT
    s.sector,
    ROUND(AVG(s.gpg_pct), 1)                                AS eu_avg_sector_gap,
    RANK() OVER (ORDER BY AVG(s.gpg_pct) DESC)              AS sector_rank,
    COUNT(DISTINCT s.country)                               AS countries_with_data,
    ROUND(MIN(s.gpg_pct), 1)                                AS lowest_country_gap,
    ROUND(MAX(s.gpg_pct), 1)                                AS highest_country_gap
FROM gpg_sector s
WHERE s.year = (SELECT MAX(year) FROM gpg_sector WHERE sector = s.sector
                AND country = s.country)  -- most recent year per country
GROUP BY s.sector
ORDER BY eu_avg_sector_gap DESC;


-- ============================================================
-- SECTION 8: QUERY 5 — Finance vs Public Admin Deep Dive
-- ============================================================
-- Business question: Finance always tops the gap ranking.
-- How does it compare to Public Admin (the most equal sector)
-- across every EU country?
--
-- What we use: conditional aggregation with FILTER, a self-join
-- pattern using CTEs (Common Table Expressions).

WITH finance AS (
    SELECT country, eu_region, ROUND(AVG(gpg_pct), 1) AS finance_gap
    FROM gpg_sector
    WHERE sector = 'Finance & insurance'
    GROUP BY country, eu_region
),
public_admin AS (
    SELECT country, ROUND(AVG(gpg_pct), 1) AS public_gap
    FROM gpg_sector
    WHERE sector = 'Public admin'
    GROUP BY country
)
SELECT
    f.country,
    f.eu_region,
    f.finance_gap,
    p.public_gap,
    ROUND(f.finance_gap - p.public_gap, 1)      AS finance_premium,
    CASE
        WHEN f.finance_gap > 25 THEN 'Very high finance gap'
        WHEN f.finance_gap > 15 THEN 'High finance gap'
        ELSE 'Moderate finance gap'
    END                                          AS finance_category
FROM finance f
LEFT JOIN public_admin p ON f.country = p.country
WHERE f.finance_gap IS NOT NULL
ORDER BY finance_premium DESC NULLS LAST;


-- ============================================================
-- SECTION 9: QUERY 6 — The Age Effect (Motherhood Penalty)
-- ============================================================
-- Business question: Does the gender pay gap grow as workers
-- get older? Does this pattern hold across all EU regions?
--
-- What we use: GROUP BY age_group + eu_region,
-- AVG(), ORDER BY age_group_sort.

SELECT
    a.age_group,
    a.age_group_sort,                               -- used for correct sort order
    ROUND(AVG(a.gpg_pct), 1)                        AS eu_avg_gap,
    ROUND(AVG(CASE WHEN a.eu_region = 'Northern' THEN a.gpg_pct END), 1) AS northern_avg,
    ROUND(AVG(CASE WHEN a.eu_region = 'Southern' THEN a.gpg_pct END), 1) AS southern_avg,
    ROUND(AVG(CASE WHEN a.eu_region = 'Eastern'  THEN a.gpg_pct END), 1) AS eastern_avg,
    ROUND(AVG(CASE WHEN a.eu_region = 'Western'  THEN a.gpg_pct END), 1) AS western_avg
FROM gpg_age a
GROUP BY a.age_group, a.age_group_sort
ORDER BY a.age_group_sort;


-- ============================================================
-- SECTION 10: QUERY 7 — Most Improved Countries (2010 → 2024)
-- ============================================================
-- Business question: Which countries have made the most
-- progress in closing the gap over the last 14 years?
--
-- What we use: Self-join using CTEs to compare 2010 vs 2024
-- values for the same country. COALESCE handles missing years.

WITH gap_2010 AS (
    SELECT country, gpg_pct AS gap_2010
    FROM gpg_main
    WHERE year = 2010
),
gap_2024 AS (
    SELECT country, gpg_pct AS gap_2024
    FROM gpg_main
    WHERE year = 2024
)
SELECT
    g24.country,
    g10.gap_2010,
    g24.gap_2024,
    ROUND(g24.gap_2024 - g10.gap_2010, 1)           AS change_pp,
    ROUND(
        ((g24.gap_2024 - g10.gap_2010) / NULLIF(g10.gap_2010, 0)) * 100
    , 1)                                             AS pct_change,
    CASE
        WHEN (g24.gap_2024 - g10.gap_2010) < -5  THEN 'Major improvement'
        WHEN (g24.gap_2024 - g10.gap_2010) < 0   THEN 'Some improvement'
        WHEN (g24.gap_2024 - g10.gap_2010) = 0   THEN 'No change'
        ELSE 'Gap widened'
    END                                              AS improvement_label
FROM gap_2024 g24
JOIN gap_2010 g10 ON g24.country = g10.country
ORDER BY change_pp ASC;  -- most improved at top


-- ============================================================
-- SECTION 11: SUMMARY VIEW (export this for Tableau)
-- ============================================================
-- This creates a single combined view that Tableau can connect
-- to directly, with all the key fields in one place.

CREATE OR REPLACE VIEW v_gpg_summary AS
SELECT
    m.country,
    m.eu_region,
    m.year,
    m.gpg_pct                                          AS overall_gap,
    ROUND(AVG(m.gpg_pct) OVER (PARTITION BY m.year), 1)  AS eu_avg_that_year,
    ROUND(m.gpg_pct - AVG(m.gpg_pct) OVER (PARTITION BY m.year), 1) AS vs_eu_avg,
    m.flag_code,
    m.flag_note
FROM gpg_main m
ORDER BY m.country, m.year;

-- Preview the view
SELECT * FROM v_gpg_summary WHERE year = 2024 ORDER BY overall_gap DESC;
