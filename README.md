# Olist Brazilian E-Commerce — End-to-End SQL Analysis

## Overview
Production-grade SQL analysis of 100K+ real orders from Olist, Brazil's largest e-commerce marketplace.
Built entirely in BigQuery GoogleSQL across 2 phases — a full data cleaning pipeline and 14 analytical
queries spanning 5 business modules — structured as a real stakeholder deliverable, not a tutorial exercise.

**Engine:** BigQuery GoogleSQL
**Dataset:** [Olist E-Commerce Public Dataset — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
**Project:** `som3a-366421.olist`
**Analysis Window:** January 2017 – August 2018
**Author:** Ismaeel Abdulla · [LinkedIn](https://linkedin.com/in/ismaeel-ghayaty-121125160/) · [GitHub](https://github.com/Ismaeel-Abdulla)

---

## Repository Structure

```
olist-ecommerce-sql-analysis/
│
├── README.md
│
├── sql/
│   ├── 01_cleaning.sql        ← Full cleaning pipeline (8 tables)
│   └── 02_analysis.sql        ← 14 queries across 5 modules
│
└── results/
    ├── module1_business_overview/
    │   ├── q1_yoy_revenue.csv
    │   └── q2_payment_methods.csv
    ├── module2_logistics/
    │   ├── q3_ontime_delivery.csv
    │   ├── q4_delay_by_state.csv
    │   └── q5_delivery_vs_review.csv
    ├── module3_customer_behavior/
    │   ├── q6_retention.csv
    │   ├── q7_installments.csv
    │   └── q8_acquisition.csv
    ├── module4_product_category/
    │   ├── q9_category_revenue.csv
    │   ├── q10_price_tiers.csv
    │   └── q11_complaint_concentration.csv
    └── module5_seller_geographic/
        ├── q12_top_sellers.csv
        ├── q13_composite_score.csv
        └── q14_freight_burden.csv
```

---

## Data Ingestion

Raw CSVs were pulled directly from Kaggle into BigQuery using a
Jupyter notebook running inside the Kaggle environment.

**Approach:**
- GCP Service Account JSON key stored securely as a Kaggle Secret
- `google-cloud-bigquery` Python client used to authenticate and load
- All 8 CSV files looped and loaded into `som3a-366421.olist` as raw tables
- No manual downloads — fully automated ingestion from source to warehouse

This approach keeps the pipeline reproducible — anyone with a GCP
service account can re-run the notebook and recreate the raw tables
from scratch in minutes.

---

## Phase 1 — Data Cleaning

All 8 raw Kaggle CSVs were loaded into BigQuery and materialized into cleaned tables before any analysis ran.
Materialized tables were chosen deliberately — cleaning logic executes once, results are cached, and every
downstream analysis query reads from a pre-computed clean state with zero reprocessing overhead.

### Tables Cleaned

| Table | Key Cleaning Operations |
|-------|------------------------|
| `customers_cleaned` | Deduplication on `customer_id` · TRIM + LOWER city · UPPER state · ZIP cast to STRING |
| `orders_cleaned` | Deduplication on `order_id` · SAFE_CAST all 5 timestamp columns · LOWER order_status |
| `order_items_cleaned` | Composite key dedup on `(order_id, order_item_id)` · SAFE_CAST price and freight |
| `order_payments_cleaned` | Composite key dedup on `(order_id, payment_sequential)` · LOWER payment_type |
| `order_reviews_cleaned` | Latest review per order via `ORDER BY review_answer_timestamp DESC` · NULLIF blank comments |
| `products_cleaned` | Dedup on `product_id` · SAFE_CAST all 7 physical dimension columns |
| `product_category_name_translation_cleaned` | Dedup on Portuguese category name · TRIM both columns |
| `sellers_cleaned` | Dedup on `seller_id` · REGEXP accent stripping via `NORMALIZE + NFD` · ZIP cast to STRING |
| `geolocation_cleaned` | 1:1 ZIP code enforcement · SAFE_CAST lat/lng · Full accent stripping |

### Cleaning Decisions Worth Noting

**Deduplication strategy:** Every table uses `ROW_NUMBER() OVER(PARTITION BY primary_key)` — for reviews
specifically, the partition orders by `review_answer_timestamp DESC` to keep the most recent submission
per order rather than an arbitrary first row.

**SAFE_CAST over CAST:** All numeric and timestamp conversions use `SAFE_CAST` which returns NULL on
failure instead of crashing the pipeline. This prevents a single malformed row from breaking the entire
cleaning job.

**Blank string normalization:** Review comment columns use `NULLIF(TRIM(col), '')` to convert empty
strings into true database NULLs — critical for accurate NULL checks downstream.

**ZIP code as STRING:** Both customers and sellers ZIP codes are cast to STRING to preserve any leading
zeros that would be silently dropped by an integer cast.

**Accent stripping on city names:** Seller and geolocation city names use
`REGEXP_REPLACE(NORMALIZE(LOWER(TRIM(col)), NFD), r"[\pM]", "")` to strip diacritical marks —
ensuring "São Paulo" and "sao paulo" join correctly without case or accent mismatches.

**2016 data excluded from analysis:** The dataset contains sparse 2016 rows (as few as 1–4 orders per
month) from the platform's pre-launch pilot period. These were excluded via the
`BETWEEN '2017-01-01' AND '2018-08-31'` filter applied consistently across all 14 analysis queries.
January 2017 is the first month with statistically meaningful order volume (752 new customers).

---

## Phase 2 — Analysis

14 queries across 5 modules. Every query follows the same structure:
numbered header → purpose line → inline logic comments → results-grounded recommendation.

### Module 1 — Business Overview

| # | Query | Business Question |
|---|-------|------------------|
| Q1 | YoY Revenue Growth | Is revenue growing year over year and is the growth rate sustainable? |
| Q2 | Payment Methods & Revenue Share | How do customers pay and what drives installment dependency? |

**Key findings:**
- November 2017 — R$1.17M, the highest revenue month in the dataset, Black Friday driven
- YoY growth decelerated from 704.8% (Jan 2018) to 50.6% (Aug 2018) — hypergrowth phase ending
- Credit card dominates at 78.5% of GMV · Boleto accounts for 18% as full upfront cash payments

---

### Module 2 — Logistics & Delivery

| # | Query | Business Question |
|---|-------|------------------|
| Q3 | On-Time Delivery Performance | What is the platform-wide fulfillment reliability baseline? |
| Q4 | Delivery Delay by State | Which Brazilian states have the worst regional logistics failures? |
| Q5 | Delivery Speed vs Review Score | Does slower delivery directly damage customer satisfaction? |

**Key findings:**
- 91.9% on-time rate platform-wide — but late orders miss by 8.9 days on average, not 1–2
- AP (Amapá): 48.3 avg delay days — catastrophically late when it misses, 6+ weeks behind
- AL: 24.0% late order rate — highest in the country — combined with 24 avg total delivery days
- Slow deliveries (20+ days) carry 38.3% bad review rate — 4x higher than Express (≤5 days)
- 20 days is the confirmed customer tolerance breaking point — bad reviews spike 258% past it

---

### Module 3 — Customer Behavior

| # | Query | Business Question |
|---|-------|------------------|
| Q6 | Customer Retention Rate | What share of customers return for a second purchase? |
| Q7 | Credit & Installment Behavior | Do high-value orders depend more heavily on installment credit? |
| Q8 | Customer Acquisition Trend | How fast is the customer base growing month by month? |

**Key findings:**
- 3.04% repeat purchase rate across 94,707 customers — 91,832 bought once and never returned
- Every 1% improvement in repeat rate adds ~R$151K revenue without acquiring a single new customer
- Installments scale linearly with order value: 2.3 avg months under R$100, 7.4 months at R$600+
- Platform grew from 752 new customers (Jan 2017) to 6,209 (Aug 2018) — 825% in 20 months
- 2018 acquisition plateaued at ~6,500/month — organic growth ceiling reached

---

### Module 4 — Product & Category

| # | Query | Business Question |
|---|-------|------------------|
| Q9  | Category Revenue vs Satisfaction | Which categories lead on both revenue and customer satisfaction? |
| Q10 | Price Tier Distribution | Where does catalog revenue and volume actually concentrate by price? |
| Q11 | Category Complaint Concentration | Which categories have the highest structural bad review rates? |

**Key findings:**
- health_beauty leads on both revenue (R$1.25M) and satisfaction (4.15) — the platform's anchor category
- cool_stuff: R$164 avg price + 4.16 satisfaction (highest in top 10) but only 3,609 orders — undermarketed
- Mid tier (R$50–149): 45% of items and 35% of GMV — volume and value anchor simultaneously
- Luxury tier (R$400+): 4% of items but 25% of GMV — R$811 revenue per item average
- fashion_male_clothing: 24.77% bad order rate — highest on the platform
- office_furniture: 22.43% bad order rate across 1,257 orders — 282 absolute bad reviews

---

### Module 5 — Seller & Geographic Performance

| # | Query | Business Question |
|---|-------|------------------|
| Q12 | Top 20 Sellers SLA Matrix | Who are the top revenue sellers and how fast do they fulfill? |
| Q13 | Seller Composite Performance Score | Which sellers rank highest across revenue, speed, and satisfaction combined? |
| Q14 | Freight Burden by State | Which states pay the most in shipping relative to what they buy? |

**Key findings:**
- Top composite sellers all ship in under 1.3 days — speed is the dominant composite rank driver
- Seller 7c67e1448b: R$237K GMV but 11.7 avg days to ship and 3.35 review — critical SLA failure
- SP: 13.8% freight burden (lowest) vs RR: 27.8% (highest) — a 2x geographic pricing disparity
- MA: second highest freight burden (26.2%) AND second worst late order rate (19.6%) — double failure state
- PB: highest avg item price (R$191) yet still absorbs 22.3% freight burden

---

## SQL Techniques Used

- **Window functions** — `LAG`, `NTILE`, `SUM OVER`, `ROW_NUMBER`, `RANK`
- **CTEs** — used only where logic requires sequential steps or multiple references
- **Conditional aggregation** — `COUNTIF`, `CASE WHEN` inside `COUNT DISTINCT`
- **Multi-table JOINs** — up to 5 tables with explicit `ON` and full column aliases throughout
- **Date functions** — `DATE_DIFF`, `DATE_TRUNC`, `SAFE_CAST` on timestamps
- **Deduplication** — `QUALIFY ROW_NUMBER()` pattern across all 8 cleaned tables
- **Ratio calculations** — `NULLIF` for division-safe percentage calculations
- **Text normalization** — `REGEXP_REPLACE + NORMALIZE + NFD` for accent stripping

---

## Key Findings Summary

| Metric | Value |
|--------|-------|
| Total delivered orders (2017–2018) | 96,203 |
| On-time delivery rate | 91.9% |
| Avg delivery days (platform-wide) | 12.1 days |
| Avg delay on late orders | 8.9 days |
| Repeat purchase rate | 3.04% |
| Total unique customers | 94,707 |
| Peak acquisition month | Nov 2017 — 7,190 new customers |
| Highest revenue month | Nov 2017 — R$1.17M |
| Top revenue category | health_beauty — R$1.25M |
| Highest bad review rate (category) | fashion_male_clothing — 24.77% |
| Worst delivery state | AP — 48.3 avg delay days |
| Highest freight burden state | RR — 27.8% of item price |
| Credit card revenue share | 78.5% of total GMV |
