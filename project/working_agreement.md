# Working Agreement

The conventions every step followed, and the Definition of Done used to close each issue.

## Definition of Done

A step is done when:

1. **Committed and pushed** on a feature branch
2. **Tests pass:** `dbt build` is green, including downstream models
3. **Merged:** pull request merged into `main` after the CI check passes
4. **Documented:** model and column descriptions updated; README updated where the step produced a decision, number, or data quality fix worth showing
5. **Tracked:** issue closed and card moved to Done on the project board
6. **Shared:** a short build-in-public post summarizing what was built and learned

## Conventions

**Branches:** `feature/<area>-<change>`, e.g. `feature/marts-fct-orders`, `feature/fct-orders-clustering`

**Commits:** `<model or area>: <change>`, e.g. `stg_orders: parse dates`, `fct_orders: cluster by product_name, region`

**Pull requests:** one per step; `Closes #<issue>` in the description so the issue closes on merge

**Step size:** about one sitting (60 minutes or less), each ending in a commit

**Workflow for each step:** Explore → Decide → Build → Test
- **Explore:** profile the data before modeling; decision-driving queries are saved in `analyses/`
- **Decide:** record choices before writing the model
- **Build:** staging cleans, marts answer business questions
- **Test:** row counts, null checks, and reconciliation on every aggregate

## Data rules

- Raw tables are never edited; fixes happen in staging
- Questionable rows are flagged, not deleted
- Unknown values stay null rather than being guessed
- Revenue excludes $0 and missing-price orders and keeps refunds (gross revenue)
- Known data gaps in staging warn rather than fail the build
