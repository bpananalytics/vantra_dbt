# Risk Register

Risks identified during the project and how each was handled. **Likelihood** and **Impact** are rated Low / Medium / High.

| # | Risk | Likelihood | Impact | Response | Status |
|---|---|---|---|---|---|
| 1 | **Data quality:** mixed date formats, duplicates, Excel-corrupted IDs, and inconsistent product names produce wrong numbers downstream | High | High | Profile before modeling; fix in staging; test keys, accepted values, and relationships on every build | Closed |
| 2 | **Unmappable locations:** orders with geolocation codes (`EU`, `AP`, `A1`) or no country can't be assigned a region | Medium | Low | Leave unmapped and document; ~0.15% of orders, excluded only from regional views | Accepted |
| 3 | **Refund data gap:** refunds stop being recorded after Aug 2021 | Confirmed | Medium | Limit refund analysis and model training to orders before the cutoff; documented in both repos | Mitigated |
| 4 | **Biased loyalty comparison:** members skew toward newer customers | Confirmed | High | Compare within first-purchase-year cohorts; test each year separately | Mitigated |
| 5 | **Revenue mismatch** between models as tables are aggregated | Medium | High | One agreed revenue rule (#33); reconciliation check shows revenue matches to the cent across marts | Closed |
| 6 | **Silent schema changes** break downstream models or dashboards | Low | Medium | Model contract on `fct_orders`; CI runs `dbt build` on every pull request | Closed |
| 7 | **BigQuery sandbox expiry:** raw tables expire Jan 13, 2027 | Certain | Medium | Original CSVs kept locally for re-upload; docs site, notebooks, and dashboard don't depend on live tables | Accepted |
| 8 | **Sandbox partition expiry:** date-partitioned tables would expire immediately | Certain if partitioned | High | Clustering only; partition config left commented out with the reason | Avoided |
| 9 | **dbt Cloud trial ends** before the docs site is published | Medium | Medium | Docs site generated and published early (Nov 18); dbt Core as fallback | Closed |
| 10 | **Scope creep:** new analysis ideas expand v2 past its target | High | Medium | Each addition logged in the decision log; ML forecast cut; RFM reduced; findings issue folded | Mitigated |
| 11 | **Dashboard tool friction:** Looker Studio setup stalled | Occurred | Low | Switched to Tableau Public | Closed |
| 12 | **Pace:** long working days risk burnout and mistakes | Medium | Medium | Steps sized to about one sitting, each ending in a commit; breaks logged | Monitored |
