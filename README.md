# Vantra dbt Pipeline

📊 **Business analysis:** Findings and recommendations → [**View the Vantra analysis**](https://github.com/bpananalytics/Vantra_Electronics_Analysis)

📋 **Roadmap and sprint tracking:** Follow my progress → [**Vantra project board**](https://github.com/users/bpananalytics/projects/1/views/1)

An analytics engineering pipeline re-built using **dbt** and **BigQuery**, transforming raw e-commerce order data into clean, tested, analysis-ready tables.

## Business Question

Which brands, regions, and customer segments drive revenue for Vantra Electronics, and how did that change after the 2020 peak?

## Data

- **Orders:** ~108,000 orders from an online electronics retailer, 2019–2022
- **Country lookup:** country code → sales region mapping (countries are identified by code only; no country names in the source)

## Pipeline

    core (raw)  →  staging  →  marts  →  analysis

![dbt lineage graph](lineage.png)

| Layer | Models | Purpose |
|---|---|---|
| Raw | `core.main`, `core.country` | Untouched uploads |
| Staging | `stg_orders`, `stg_countries` | Clean and standardize each source |
| Marts | `dim_countries`, `fct_orders` | Business-ready tables for reporting |

Every model, column, and source is documented in dbt, and the lineage graph above is generated from the code itself.


### Marts

- **`dim_countries`**: one row per country code, mapped to a sales region (APAC, EMEA, LATAM, NA).
- **`fct_orders`**: one row per order and refund date, enriched with region from `dim_countries`. Intentionally wide (BigQuery is columnar, so wide tables are cheap to query); countries are split into their own dimension because region mapping needed its own cleanup and tests.

## Data Quality Issues Handled

**Staging**
- **Duplicates:** 96 exact duplicate rows removed
- **Mixed date formats:** `purchase_ts` contained `m/d/yyyy`, `m/d/yyyy h:mm`, and Excel serial numbers; all parsed to `DATE`
- **Product names:** 9 variants standardized to 8 products
- **Prices:** converted to `NUMERIC`; 158 $0 orders and 33 missing prices flagged
- **Corrupted IDs:** ~770 order IDs and ~600 user IDs were converted to scientific notation by Excel; unrecoverable, documented
- **Country lookup:** header row loaded as data removed; conflicting US duplicate resolved (placeholder 'x' dropped); 'North America' standardized to NA; missing regions filled for Benin (EMEA) and Bermuda (LATAM)

**Marts**
- **Order grain:** 5 order IDs appear twice, differing only by refund date. Uniqueness is tested on `order_id` + `refund_date` rather than guessing which row is correct.
- **Non-country location codes:** a relationships test caught 22 orders coded `EU`, `AP`, or `A1`. These are IP-geolocation codes ("Europe," "Asia/Pacific," "anonymous proxy"), not countries. They are left without a region rather than assumed, and excluded from the relationships test.
- **Missing country codes:** 140 orders have no country code and no region.
- **Impact:** together, orders without a region are ~0.15% of all orders; they are kept in `fct_orders` (left join) so no orders are dropped.

## Testing

dbt tests run on every build:
- **Not null and uniqueness** on keys (`country_code` in `dim_countries`; `order_id` + `refund_date` combination in `fct_orders` via `dbt_utils`)
- **Accepted values** on region (APAC, EMEA, LATAM, NA)
- **Referential integrity:** every order's country code must exist in `dim_countries` (geolocation pseudo-codes excluded and documented)
- **Model contract** on `fct_orders`: column names and data types are enforced, so the table can't change shape silently
- **Unit test** on `stg_orders` date parsing: fake rows cover all three source formats (m/d/yyyy, m/d/yyyy h:mm, Excel serial) plus junk values

Known data gaps in staging are set to warn rather than fail.

**CI:** a dbt Cloud CI job was configured to run `dbt build` on every pull request into `main`, so no change merges without passing all tests ([see PR #27](https://github.com/bpananalytics/vantra_dbt/pull/27)).

## Key Decisions

- Flagged questionable rows instead of deleting them
- Documented unrecoverable IDs rather than imputing them
- Left unmappable locations without a region instead of inferring one
- Used a left join in `fct_orders` so every order is kept, even without a matching country
- Used `NUMERIC` for prices to avoid float rounding
- Documented data quirks (corrupted IDs, null reasons, non-country codes) in column descriptions, not just in code comments
- Fixed load issues in staging, leaving raw tables untouched

## Tools

dbt Cloud · BigQuery · dbt_utils · GitHub
