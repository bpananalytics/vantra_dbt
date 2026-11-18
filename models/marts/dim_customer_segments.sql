with cte as (select user_id, order_id, usd_price, purchase_date
from {{ ref('fct_orders') }}
  where is_missing_price is FALSE
    and is_zero_price is FALSE
    and purchase_date is not null
group by 1, 2,3,4),

cte_2 as (
  select user_id, count(distinct(order_id)) as order_count, 
    sum(usd_price) as total_spent,
    max(purchase_date) as last_purchase_date
  from cte
  group by user_id)
  
select *,
  case when order_count > 1 and last_purchase_date >= "2022-01-01" then 'loyal'
    when order_count > 1 and last_purchase_date < "2022-01-01" then   'at_risk'
    when order_count = 1 and last_purchase_date >= "2022-01-01" then  'new_customer'
    when order_count = 1 and last_purchase_date < "2022-01-01" then  'lapsed'
  end as segment
from cte_2 