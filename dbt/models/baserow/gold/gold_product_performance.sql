{{ config(materialized='table', engine='MergeTree()', order_by='product_code') }}

select
    product_code,
    product_name,
    category,
    count() as orders_total,
    sumIf(quantity, counts_as_revenue = 1) as units_sold,
    round(sumIf(net_amount, counts_as_revenue = 1), 2) as net_revenue,
    countIf(status = 'Returned') as orders_returned,
    round(countIf(status = 'Returned') / count() * 100, 2) as return_rate_pct,
    round(avg(discount_pct), 2) as avg_discount_pct
from {{ ref('gold_order_facts') }}
group by product_code, product_name, category