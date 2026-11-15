with source as (
select 
    CAST(user_id AS STRING) AS user_id,
    CAST(order_id AS STRING) AS order_id,
    CAST(purchase_ts AS STRING) AS purchase_ts,
    CAST(ship_ts AS STRING) AS ship_ts,
    CAST(delivery_ts AS STRING) AS delivery_ts,
    CAST(refund_ts AS STRING) AS refund_ts,
    CAST(product_name AS STRING) AS product_name,
    CAST(product_id AS STRING) AS product_id,
    CAST(usd_price AS STRING) AS usd_price,
    CAST(local_price AS STRING) AS local_price,
    CAST(currency AS STRING) AS currency,
    CAST(purchase_platform AS STRING) AS purchase_platform,
    CAST(marketing_channel AS STRING) AS marketing_channel,
    CAST(account_creation_method AS STRING) AS account_creation_method,
    CAST(country_code AS STRING) AS country_code,
    CAST(loyalty_program AS STRING) AS loyalty_program,
    CAST(created_on AS STRING) AS created_on
from {{ source('core', 'main') }}),

deduplicated as (select distinct * from source), /*This removes duplications by filtering distinct values*/

parsed as (select *,
case 
    when purchase_ts like "%.%" then DATE_ADD(DATE '1899-12-30', INTERVAL (safe_cast(split(purchase_ts,'.')[safe_offset(0)] as int64)) day)
    when purchase_ts like '%:%' then safe.parse_date('%m/%d/%Y',split(purchase_ts,' ')[safe_offset(0)])
  else
    safe.parse_date('%m/%d/%Y',purchase_ts)
  end as purchase_date from deduplicated)
    
select * from parsed