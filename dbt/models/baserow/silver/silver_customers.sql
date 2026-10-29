{{ config(materialized='table', engine='MergeTree()', order_by='customer_code') }}

with parsed as (
    select
        JSONExtractString(payload, 'customer_code') as customer_code,
        trim(JSONExtractString(payload, 'full_name')) as full_name,
        lower(trim(JSONExtractString(payload, 'email'))) as email,
        trim(JSONExtractString(payload, 'country')) as country_raw,
        toDateOrNull(JSONExtractString(payload, 'signup_date')) as signup_date,
        toUInt8(lower(trim(JSONExtractString(payload, 'is_active'))) = 'true') as is_active
    from {{ source('baserow_raw', 'bronze_baserow_rows') }}
    where table_name = 'customers'
)

select
    customer_code,
    full_name,
    email,
    if(country_raw = '', 'Unknown', country_raw) as country,
    signup_date,
    is_active
from parsed
order by email, customer_code
limit 1 by email