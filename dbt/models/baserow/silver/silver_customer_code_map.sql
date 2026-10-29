{{ config(materialized='table', engine='MergeTree()', order_by='customer_code') }}

with parsed as (
    select
        JSONExtractString(payload, 'customer_code') as customer_code,
        lower(trim(JSONExtractString(payload, 'email'))) as email
    from {{ source('baserow_raw', 'bronze_baserow_rows') }}
    where table_name = 'customers'
)

select
    customer_code,
    min(customer_code) over (partition by email) as canonical_customer_code
from parsed