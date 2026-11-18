select segment, 
  sum(total_spent) as revenue, 
  count(user_id) as customer_count, 
  sum(total_spent)/count(user_id)  as avg_spend,
  count(user_id)/  sum(count(user_id)) over () as pct_of_customers,
  sum(total_spent)/ sum(sum(total_spent)) over () as pct_of_revenue,
  safe_divide(sum(total_spent)/ sum(sum(total_spent)) over (), count(user_id)/sum(count(user_id)) over ()) as revenue_index
from {{ ref('dim_customer_segments') }}
group by segment