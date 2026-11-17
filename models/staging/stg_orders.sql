-- ============================================================
-- 1. SOURCE: rename and cast all columns to STRING
--    Raw data from core.main. Everything starts as text so
--    no values are lost before deliberate conversion below.
-- ============================================================
with source as (
    select
        cast(user_id as string)                 as user_id,
        cast(order_id as string)                as order_id,
        cast(purchase_ts as string)             as purchase_ts,
        cast(ship_ts as string)                 as ship_ts,
        cast(delivery_ts as string)             as delivery_ts,
        cast(refund_ts as string)               as refund_ts,
        cast(product_name as string)            as product_name,
        cast(product_id as string)              as product_id,
        cast(usd_price as string)               as usd_price,
        cast(local_price as string)             as local_price,
        cast(currency as string)                as currency,
        cast(purchase_platform as string)       as purchase_platform,
        cast(marketing_channel as string)       as marketing_channel,
        cast(account_creation_method as string) as account_creation_method,
        cast(country_code as string)            as country_code,
        cast(loyalty_program as string)         as loyalty_program,
        cast(created_on as string)              as created_on
    from {{ source('core', 'main') }}
),

-- ============================================================
-- 2. DEDUPLICATED: remove exact duplicate rows
--    96 rows were exact copies (108,127 -> 108,031).
--    5 order_id pairs remain that differ only in refund date;
--    all have Excel-corrupted IDs (see user_id / order_id
--    descriptions in _staging.yml).
-- ============================================================
deduplicated as (
    select distinct * from source
),

-- ============================================================
-- 3. PARSED: convert text dates to DATE
--    purchase_ts had 3 formats: m/d/yyyy, m/d/yyyy h:mm (14 rows),
--    and Excel serials (13 rows, all 2019-06-14 ~2 PM).
--    3 values become null on purpose: 1 blank, 1 whitespace, 1 '/N'.
--    ship/delivery/refund/created were loaded as DATE by BigQuery,
--    so they are cast back from text.
-- ============================================================
parsed as (
    select
        *,
        case
            when purchase_ts like '%.%'
                then date_add(date '1899-12-30', interval (safe_cast(split(purchase_ts, '.')[safe_offset(0)] as int64)) day)
            when purchase_ts like '%:%'
                then safe.parse_date('%m/%d/%Y', split(purchase_ts, ' ')[safe_offset(0)])
            else safe.parse_date('%m/%d/%Y', purchase_ts)
        end as purchase_date,

        -- already loaded as DATE in core.main; source cast them to text, so cast back
        safe_cast(ship_ts as date)     as ship_date,
        safe_cast(delivery_ts as date) as delivery_date,
        safe_cast(refund_ts as date)   as refund_date,
        safe_cast(created_on as date)  as account_created_date
    from deduplicated
),

-- ============================================================
-- 4. STD_PRODUCT: standardize product names (9 variants -> 8)
--    Merged '27in"" 4k gaming monitor' into one monitor name.
--    initcap() applied for consistent casing; brand styling
--    (e.g. iPhone, ThinkPad) intentionally not preserved.
-- ============================================================
std_product as (
    select
        * except (product_name),
        case
            when product_name like '%monitor%' then '27in 4K Gaming Monitor'
            else initcap(product_name)
        end as product_name
    from parsed
),

-- ============================================================
-- 5. PRICED: convert usd_price and local_price to NUMERIC
--    NUMERIC (not FLOAT) keeps exact cents for revenue math.
--    33 prices are null and stay null (unknown, not zero).
-- ============================================================
priced as (
    select
        * except (usd_price, local_price),
        safe_cast(usd_price as numeric)   as usd_price,
        safe_cast(local_price as numeric) as local_price
    from std_product
),

-- ============================================================
-- 6. FLAGGED: boolean flags for price, refund, loyalty and
--    date-quality checks. Flags mark rows; nothing is removed.
-- ============================================================
flagged as (
    select
        *,
        case when usd_price = 0 then true else false end              as is_zero_price,
        case when usd_price is null then true else false end          as is_missing_price,
        case when refund_date is not null then true else false end    as is_refunded,
        case when loyalty_program = '1' then true else false end      as is_loyalty_member,
        case when ship_date < purchase_date then true else false end  as is_ship_before_purchase
    from priced
),

-- ============================================================
-- 7. BRANDED: derive brand from the standardized product name
--    (runs after STD_PRODUCT so title-cased names match).
--    The monitor has no brand in its name -> 'Generic'.
-- ============================================================
branded as (
    select
        *,
        case
            when product_name like 'Apple%'    then 'Apple'
            when product_name like 'Macbook%'  then 'Apple'
            when product_name like 'Samsung%'  then 'Samsung'
            when product_name like 'Thinkpad%' then 'Lenovo'
            when product_name like 'Bose%'     then 'Bose'
            else 'Generic'
        end as brand
    from flagged
),

-- ============================================================
-- 8. CHANNELED: standardize marketing_channel
--    82 'unknown' values set to null, so null = channel not
--    recorded (1,469 rows total).
-- ============================================================
channeled as (
    select
        * except (marketing_channel),
        case
            when marketing_channel = 'unknown' then null
            else marketing_channel
        end as marketing_channel
    from branded
)

-- ============================================================
-- FINAL: drop raw text columns and product_id
--    (product_id is not a product key: 58 IDs across 8 products,
--    not tied to price, currency or channel).
-- ============================================================
select
    * except (purchase_ts, ship_ts, delivery_ts, refund_ts, created_on, loyalty_program, product_id)
from channeled

