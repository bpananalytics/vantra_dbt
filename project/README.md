# Vantra: Project Management

How the Vantra project was planned, tracked, and delivered. Work was tracked for the pipeline creation on the [**Vantra project board**](https://github.com/users/bpananalytics/projects/1/views/1); these documents record the plan, the decisions behind it, and what was learned.

## At a glance

| | |
|---|---|
| **Goal** | Rebuild a messy e-commerce dataset into a tested dbt + BigQuery pipeline, then use it to answer which regions and customer segments drive revenue |
| **Timeline** | Fri Nov 13 – Wed Nov 18, 2026 (6 days) |
| **Effort** | ~28 hours (estimated from session and commit timestamps) |
| **Delivered** | 7 dbt models, 17 merged pull requests, 2 Python notebooks, 1 Tableau dashboard, a public dbt docs site |
| **Schedule** | v1 finished 3 days ahead of its target; v2 finished 3 days ahead of its revised target (Nov 21) |
| **Scope changes** | 6 items cut or folded, 2 added, each logged with a reason |

## Documents

| Document | What it covers |
|---|---|
| [Roadmap and iterations](roadmap.md) | Planned vs. actual timeline for each iteration, with an iteration review for each |
| [Decision log](decision_log.md) | Key technical, analytical, and scope decisions, with the reasoning and alternatives considered |
| [Risk register](risk_register.md) | Risks identified during the project, how each was handled, and what is still open |
| [Working agreement](working_agreement.md) | Conventions and the Definition of Done every step had to meet |
| [Retrospective](retrospective.md) | What went well, what didn't, and what I'd do differently |

## Deliverables

- **Pipeline:** [vantra_dbt](https://github.com/bpananalytics/vantra_dbt) · [dbt docs site](https://bpananalytics.github.io/vantra_dbt/)
- **Analysis:** [Vantra_Electronics_Analysis](https://github.com/bpananalytics/Vantra_Electronics_Analysis) (loyalty test and refund-risk notebooks)
- **Dashboard:** [Tableau Public](https://public.tableau.com/app/profile/brian.pan7659/viz/Vantra_Dashboard/Dashboard1)
