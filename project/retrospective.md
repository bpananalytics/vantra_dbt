# Retrospective

A look back at Vantra after v1 and v2, written before the final showcase pieces (videos and case study).

## Summary

In six days I rebuilt a messy e-commerce dataset, previously cleaned by hand in Excel, into a tested dbt + BigQuery pipeline: 7 models, 17 merged pull requests, a CI check on every pull request, and a public docs site. I then used the marts to answer the business question with three new marts, two notebooks, and a dashboard. Both iterations finished ahead of their targets.

## What went well

- **Profiling before modeling.** Every major decision came from looking at the data first: dropping `product_id`, reducing RFM to a 2×2 after finding 80% of customers ordered once, and catching the refund-recording gap before it biased the model.
- **Tests caught real problems.** A relationships test surfaced 22 orders with geolocation codes instead of countries; a row-count check caught null purchase dates forming their own "null quarter" in the growth mart.
- **The pipeline paid off downstream.** Because the marts were clean, tested, and reconciled to the cent, the dashboard took well under an hour.
- **Willing to report unwelcome results.** The loyalty test reversed my own earlier finding, and the refund model turned out useful only in aggregate. Both are documented as they are.
- **Scope was controlled, not just added to.** Six items were cut or folded and two were added, each with a logged reason.

## What didn't go well

- **Early estimates were off.** v1's target was a timebox, not an estimate, so it was far too generous. v2's estimate (8–11.5 hours) was closer, landing at roughly 12.
- **Setup work drained momentum.** CI configuration and the docs site were mostly following setup steps rather than building, and felt slower than writing SQL.
- **v1 left data quality debt.** Not every issue was cleaned in v1, so v2 had to start with a readiness check.
- **New territory was hard.** YAML syntax, window functions, statistical testing, and the classifier each took several attempts. The machine learning work in particular didn't fully click.
- **Long days.** Several sessions ran late; the steady pace that worked best was steps sized to about an hour, each ending in a commit.

## Lessons

1. **Profile first, then model.** The data decides the scope, not the plan.
2. **Check row counts and nulls on every aggregate.** The two biggest bugs were found this way, not by eye.
3. **Know the platform's limits.** The BigQuery sandbox expires date partitions by their date value, which would have emptied a historical table.
4. **Accuracy can lie.** With rare events like refunds, a model that never flags anything scores 92%; measure what the business actually needs.
5. **A metric isn't the whole story.** Loyalty members refund more and repeat less, but a membership program also drives awareness and engagement that these numbers don't capture.
6. **Building the pipeline and analyzing the data are different jobs.** Once the tables were trustworthy, time went to new questions rather than re-answering old ones.

## What I'd do differently

- Estimate first, then set target dates from the estimate.
- Finish all data cleaning in the first iteration instead of carrying debt forward.
- Check platform limits (sandbox expiry, trial length) on day one.
- Keep a sharper line between "nice to have" and "needed for the business question" when adding scope.
