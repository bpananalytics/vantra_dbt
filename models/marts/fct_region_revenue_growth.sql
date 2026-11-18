with cte_1 as (select order_id, user_id, brand, purchase_date, ship_date, delivery_date, refund_date, account_created_date, product_name, usd_price, local_price, currency, purchase_platform, marketing_channel, account_creation_method, country_code, is_zero_price, is_missing_price, is_refunded, is_loyalty_member, is_ship_before_purchase, region
 from {{ref("fct_orders")}}),

cte_2 as (select region, FORMAT_DATE('%Y-Q%Q', purchase_date) as quarter, 
    sum(usd_price) as revenue,
    from cte_1
    where is_zero_price is False  
        and is_missing_price is False 
        and region is not null
        and purchase_date is not null
    group by 1,2)

select *,
  safe_divide(revenue,lag(revenue,1) over(partition by region order by quarter)) - 1 as growth_rate
from cte_2