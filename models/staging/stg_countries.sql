-- ============================================================
-- 1. SOURCE: rename columns and drop the header row
--    core.country was loaded without header detection, so
--    columns arrived as string_field_0 / string_field_1 and
--    the CSV header row was loaded as a data row.
--    Keeping only 2-character codes removes that header row.
--    Raw table left untouched; fix handled here so reloads of
--    the 60-day sandbox table don't depend on load settings.
-- ============================================================

with source1 as (
    select string_field_0 as country_code, string_field_1 as region
    from {{ source('core', 'country') }}
    where char_length(string_field_0) = 2 
    ),

-- ============================================================
-- 2. CORRECTIONS: fix region values (one CASE, order matters)
--    - US appeared twice: 'North America' and placeholder 'x'.
--      'x' is nulled first (removed in step 3), so the US row
--      is not double-counted when joined to orders.
--    - 'North America' standardized to 'NA' to match other
--      region codes.
--    - BM (Bermuda) and BJ (Benin) had null regions; filled
--      manually: BM -> LATAM, BJ -> EMEA.
-- ============================================================

corrections as (select * except(region), 
    case when region = 'x' then null  
         when region = 'North America' then 'NA'  
         when country_code = 'BM' then 'LATAM'  
         when country_code = 'BJ' then 'EMEA' 
    else region end as region
from source1)

-- ============================================================
-- 3. FINAL: drop rows nulled out in step 2 (the US 'x' row).
--    Note: this filter would also drop any future null region,
--    which is acceptable here because the data is static.
-- ============================================================

select * from corrections
where region is not null



