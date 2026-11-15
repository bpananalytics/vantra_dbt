# Vantra dbt Project

An analytics engineering pipeline built with **dbt** and **BigQuery**, transforming raw e-commerce order data into clean, tested, analysis-ready tables.

## Business question
[The question this pipeline answers — e.g. "Which regions and products had the highest refund rates, and how did that change from 2019 to 2022?"]

## Data
- **Orders:** ~108,000 orders from an online electronics retailer, 2019–2022
- **Country lookup:** country code → sales region mapping

## Pipeline

    core (raw)  →  staging  →  marts  →  analysis

| Layer | Models | Purpose |
|---|---|---|
| Raw | `core.main`, `core.country` | Untouched uploads |
| Staging | `stg_orders`, `stg_countries` | Clean and standardize each source |
| Marts | [`fct_orders`, `dim_customers`, `dim_products`] | Business-ready tables |

## Data quality issues handled
- **Duplicates:** 96 exact duplicate rows removed
- **Mixed date formats:** `purchase_ts` contained `m/d/yyyy`, `m/d/yyyy h:mm`, and Excel serial numbers; all parsed to DATE
- **Product names:** 9 variants standardized to 8 products
- **Prices:** converted to NUMERIC; 158 $0 orders and 33 missing prices flagged
- **Corrupted IDs:** ~770 order IDs and ~600 user IDs were converted to scientific notation by Excel; unrecoverable, documented
- [Country lookup issues — after seed step]

## Testing
dbt tests check for nulls, accepted values, and [relationships]. Known data gaps are set to warn rather than fail.

## Key decisions
- Flagged questionable rows instead of deleting them
- Used NUMERIC for prices to avoid float rounding
- [Add as you go]

## Findings
[Results of the business question — add after the marts are built]

## Tools
dbt Cloud · BigQuery · GitHub
