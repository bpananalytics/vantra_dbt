{{ config(
    cluster_by=['product_name', 'region']
) }}

{#
  Date partitioning disabled: the BigQuery sandbox expires partitions
  60 days after their date value, which would empty this table.
  Enable in production (with billing):
  partition_by={'field': 'purchase_date', 'data_type': 'date', 'granularity': 'month'}
#}

select o.order_id, o.user_id, o.brand, o.purchase_date, o.ship_date, o.delivery_date, o.refund_date, o.account_created_date, o.product_name, o.usd_price, o.local_price, o.currency, o.purchase_platform, o.marketing_channel, o.account_creation_method, o.country_code, o.is_zero_price, o.is_missing_price, o.is_refunded, o.is_loyalty_member,
o.is_ship_before_purchase, k.region
from {{ref("stg_orders")}} as o
left join {{ref("dim_countries")}} as k
on k.country_code = o.country_code