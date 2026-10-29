{{ config(materialized='table', engine='MergeTree()', order_by='order_code') }}

with parsed as (
    select
        JSONExtractString(payload, 'order_code') as order_code,
        JSONExtractString(payload, 'customer_code') as customer_code,
        JSONExtractString(payload, 'product_code') as product_code,
        toInt32OrNull(JSONExtractString(payload, 'quantity')) as quantity,
        toDateOrNull(JSONExtractString(payload, 'order_date')) as order_date,
        concat(
            upper(substring(trim(JSONExtractString(payload, 'status')), 1, 1)),
            lower(substring(trim(JSONExtractString(payload, 'status')), 2))
        ) as status,
        coalesce(toFloat64OrNull(JSONExtractString(payload, 'discount_pct')), 0) as discount_pct
    from {{ source('baserow_raw', 'bronze_baserow_rows') }}
    where table_name = 'orders'
)

select
    o.order_code as order_code,
    if(m.canonical_customer_code = '', o.customer_code, m.canonical_customer_code) as customer_code,
    o.product_code as product_code,
    assumeNotNull(o.quantity) as quantity,
    assumeNotNull(o.order_date) as order_date,
    o.status as status,
    o.discount_pct as discount_pct
from parsed o
left join {{ ref('silver_customer_code_map') }} m on o.customer_code = m.customer_code
where o.quantity > 0
  and o.order_date is not null
order by o.order_code
limit 1 by o.order_code