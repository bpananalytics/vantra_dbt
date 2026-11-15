# Vantra dbt Pipeline

📊 **Business analysis:** Findings and recommendations built on these models → [**View the Vantra analysis**](https://github.com/bpananalytics/elist_analysis)

An analytics engineering pipeline built with **dbt** and **BigQuery**, transforming raw e-commerce order data into clean, tested, analysis-ready tables.

## Business Question

Which brands, regions, and customer segments drive revenue for Vantra Electronics, and how did that change after the 2020 peak?

## Data

- **Orders:** ~108,000 orders from an online electronics retailer, 2019–2022
- **Country lookup:** country code → sales region mapping

## Pipeline

    core (raw)  →  staging  →  analysis

| Layer | Models | Purpose |
|---|---|---|
| Raw | `core.main`, `core.country` | Untouched uploads |
| Staging | `stg_orders`, `stg_countries` | Clean and standardize each source |

## Data Quality Issues Handled

- **Duplicates:** 96 exact duplicate rows removed
- **Mixed date formats:** `purchase_ts` contained `m/d/yyyy`, `m/d/yyyy h:mm`, and Excel serial numbers; all parsed to `DATE`
- **Product names:** 9 variants standardized to 8 products
- **Prices:** converted to `NUMERIC`; 158 $0 orders and 33 missing prices flagged
- **Corrupted IDs:** ~770 order IDs and ~600 user IDs were converted to scientific notation by Excel; unrecoverable, documented

## Testing

dbt tests check for nulls and accepted values. Known data gaps are set to warn rather than fail.

## Key Decisions

- Flagged questionable rows instead of deleting them
- Documented unrecoverable IDs rather than imputing them
- Used `NUMERIC` for prices to avoid float rounding

## Tools

dbt Cloud · BigQuery · GitHub
