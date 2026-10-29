{{ config(materialized='table', engine='MergeTree()', order_by='product_code') }}

select
    JSONExtractString(payload, 'product_code') as product_code,
    trim(JSONExtractString(payload, 'product_name')) as product_name,
    trim(JSONExtractString(payload, 'category')) as category,
    toFloat64OrNull(JSONExtractString(payload, 'unit_price')) as unit_price
from {{ source('baserow_raw', 'bronze_baserow_rows') }}
where table_name = 'products'
  and unit_price > 0
order by product_code
limit 1 by product_code