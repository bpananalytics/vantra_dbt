-- ============================================================
-- 1. SOURCE: rename and cast all columns to STRING
--    Raw data from core.main. Everything starts as text so
--    no values are lost before deliberate conversion below.
-- ============================================================

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

-- ============================================================
-- 2. DEDUPLICATED: remove exact duplicate rows
--    96 rows were exact copies (108,127 -> 108,031).
--    5 order_id pairs remain that differ only in refund date;
--    all have Excel-corrupted IDs (see note in section 6).
-- ============================================================
deduplicated as (select distinct * from source),  


-- ============================================================
-- 3. PARSED: convert text dates to DATE
--    purchase_ts had 3 formats: m/d/yyyy, m/d/yyyy h:mm (14 rows),
--    and Excel serials (13 rows, all 2019-06-14 ~2 PM).
--    3 values become null on purpose: 1 blank, 1 whitespace, 1 '/N'.
--    ship/delivery/refund/created were loaded as DATE by BigQuery,
--    so they are cast back from text.
-- ============================================================
parsed as (select *,
case 
    when purchase_ts like "%.%" then DATE_ADD(DATE '1899-12-30', INTERVAL (safe_cast(split(purchase_ts,'.')[safe_offset(0)] as int64)) day)
    when purchase_ts like '%:%' then safe.parse_date('%m/%d/%Y',split(purchase_ts,' ')[safe_offset(0)])
  else
    safe.parse_date('%m/%d/%Y',purchase_ts)
  end as purchase_date,

/* these four were already loaded as DATE in core.main; source casts them to 'YYYY-MM-DD' text, so cast back */
safe_cast(ship_ts as date)     as ship_date,
safe_cast(delivery_ts as date) as delivery_date,
safe_cast(refund_ts as date)   as refund_date,
safe_cast(created_on as date)  as account_created_date
from deduplicated),

-- ============================================================
-- 4. STD_PRODUCT: standardize product names (9 variants -> 8)
--    Merged '27in"" 4k gaming monitor' into one monitor name.
--    initcap() applied for consistent casing; brand styling
--    (e.g. iPhone, ThinkPad) intentionally not preserved.
-- ============================================================

std_product as (select * except (product_name),
    case when product_name like ('%monitor%') then '27in 4K Gaming Monitor'
    else initcap(product_name)
    end as product_name 
from parsed),

-- ============================================================
-- 5. PRICED: convert usd_price and local_price to NUMERIC
--    NUMERIC (not FLOAT) keeps exact cents for revenue math.
--    33 prices are null and stay null (unknown, not zero).
-- ============================================================

priced as (
    select * except(usd_price, local_price), 
    safe_cast(usd_price as numeric) as usd_price ,
    safe_cast(local_price as numeric) as local_price
from std_product),

flagged as (select *,
  case when usd_price = 0  then TRUE
  else false  
  end as is_zero_price,

  case when usd_price is null then TRUE
  else false
  end as is_missing_price,

  case when refund_date is not null then TRUE
  else FALSE
  end as is_refunded,

  case when loyalty_program='1' then true 
  else false
  end as is_loyalty_member
  
from priced)


select * except(purchase_ts, ship_ts, delivery_ts, refund_ts, created_on, loyalty_program) from flagged

