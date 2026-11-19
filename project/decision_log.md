# Decision Log

Key decisions made during the project, with the reasoning and the alternatives considered. Scope changes are marked **[Scope]**.

| # | Date | Decision | Why | Alternatives considered |
|---|---|---|---|---|
| 1 | Nov 14 | Use dbt Cloud + BigQuery sandbox | Free, no infrastructure to manage, and the standard analytics engineering stack | dbt Core locally; Excel cleaning as before |
| 2 | Nov 15 | Fix load issues in staging, never in raw | Keeps raw data as the untouched source of truth; a corrected re-upload would add dependency issues | Re-upload cleaned CSVs |
| 3 | Nov 15 | Flag questionable rows instead of deleting them | Other teams may need records that one analysis excludes | Delete bad rows in staging |
| 4 | Nov 16 | Map Bermuda to LATAM and Benin to EMEA; leave `EU`/`AP`/`A1` geolocation codes unmapped | Bermuda and Benin have defensible regions; geolocation codes aren't countries, and assigning them would be making up data | Map EU→EMEA, AP→APAC |
| 5 | Nov 16 | Keep `fct_orders` intentionally wide at one row per order + refund date, with countries split into `dim_countries` | BigQuery is columnar, so wide tables are cheap; keeping refund grain lets Finance choose revenue or net views | Collapse duplicate orders; full star schema |
| 6 | Nov 16 | **[Scope]** Cut the scheduled nightly job (#19) | Data is static, so a schedule would rebuild identical tables | Keep for demonstration |
| 7 | Nov 16 | **[Scope]** Add a v2 readiness check (#33) | v1 left some data quality issues unresolved; analysis needed one agreed revenue definition first | Clean issues ad hoc during analysis |
| 8 | Nov 16 | Revenue rule: exclude $0 and missing-price orders, keep refunds (gross revenue) | One definition for every downstream number; refunds still matter to other departments | Net revenue; include $0 orders |
| 9 | Nov 17 | Drop `product_id` in favor of `product_name` | 58 IDs across 8 products, not tied to price, currency, or channel, so they explained nothing | Keep both keys |
| 10 | Nov 17 | Quarterly growth by region, using `LAG` per region | Quarters show seasonality and behavior shifts; Finance can roll up to years | Year-over-year growth |
| 11 | Nov 17 | **[Scope]** Replace full RFM with a 2×2 segmentation (repeat vs. one-time × bought in 2022 vs. before) | Profiling showed 80% of customers ordered once, so frequency and spend tiers added little signal | Full RFM scoring |
| 12 | Nov 17 | Reframe #30 from segment growth over time to revenue share by segment | Segment growth would be circular, since segments are defined by recency | Segment revenue trend |
| 13 | Nov 17 | **[Scope]** Add a refund-risk classifier (#21) as an extension of the loyalty notebook | Refunds were the one unexplored part of the data | Stop after the loyalty test |
| 14 | Nov 18 | Build staging as views and marts as tables | Staging is intermediate; marts are what dashboards and analysis read | All tables |
| 15 | Nov 18 | Compare loyalty members and non-members within first-purchase-year cohorts | Members skew newer, and newer customers have had less time to return; pooled comparison was biased | Pooled comparison |
| 16 | Nov 18 | Train the refund model only on orders through Jul 14, 2021 | Refunds stop being recorded after Aug 7, 2021; later orders would look falsely "not refunded" | Train on all orders |
| 17 | Nov 18 | Drop purchase year and brand as refund-model features | Year can't generalize to future orders; brand is already contained in product | Use all available columns |
| 18 | Nov 18 | Judge the refund model on precision of the riskiest 5%, not accuracy | Refunds are ~8% of orders, so accuracy rewards a model that never flags anything; inventory planning needs trustworthy flags | Accuracy; recall |
| 19 | Nov 18 | **[Scope]** Cluster `fct_orders` by product and region; leave date partitioning out | The BigQuery sandbox expires partitions 60 days after their date value, which would empty a 2019–2022 table; billing would be required | Enable billing and partition by date |
| 20 | Nov 18 | Stay on the free BigQuery sandbox; keep original CSVs locally instead of in the repo | No ongoing cost; raw tables can be re-uploaded if they expire | Enable billing; commit raw CSVs |
| 21 | Nov 18 | **[Scope]** Cut the BigQuery ML forecast (#22) | v2 kept to one ML deliverable (the refund model); forecasting a declining static series added little | Build the forecast |
| 22 | Nov 18 | **[Scope]** Fold README findings (#32) into the dashboard issue (#31) | Most README updates were completed along the way; a separate findings page would duplicate the README and dashboard | Separate `v2_findings.md` page |
| 23 | Nov 18 | Tableau Public for the dashboard | Free public hosting and a shareable link; Looker Studio setup stalled earlier | Looker Studio |
| 24 | Nov 18 | Keep the dashboard to four pieces | Four views answered the business question; more would add decoration, not insight | Larger multi-page dashboard |
