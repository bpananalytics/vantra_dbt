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
  
select count(user_id) as total_customers,
  count(case when order_count = 1 then 1 end) as one_time_customer,
    round((count(case when order_count = 1 then 1 end)/count(user_id)),2) as one_time_shopper_percentage,
  count(case when order_count > 1 and last_purchase_date >= "2022-01-01" then 1 end) as loyal,
  count(case when order_count > 1 and last_purchase_date < "2022-01-01" then 1 end) as at_risk,
  count(case when order_count = 1 and last_purchase_date >= "2022-01-01" then 1 end) as new_customer,
  count(case when order_count = 1 and last_purchase_date < "2022-01-01" then 1 end) as lapsed
from cte_2 