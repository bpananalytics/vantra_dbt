with orders as (
  select user_id, order_id, usd_price, purchase_date
  from {{ ref('fct_orders') }}
  where is_missing_price is false
    and is_zero_price is false
    and purchase_date is not null
  group by 1, 2, 3, 4
),

orders_total as (
  select sum(usd_price) as revenue from orders
),

mart_total as (
  select sum(revenue) as revenue from {{ ref('fct_segment_revenue_share') }}
)

select
  o.revenue as fct_orders_revenue,
  m.revenue as segment_mart_revenue,
  o.revenue - m.revenue as difference
from orders_total as o
cross join mart_total as m