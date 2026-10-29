{{ config(materialized='table', engine='MergeTree()', order_by='order_date') }}

select
    order_date,
    count() as orders_total,
    countIf(status = 'Cancelled') as orders_cancelled,
    countIf(status = 'Returned') as orders_returned,
    sumIf(quantity, counts_as_revenue = 1) as units_sold,
    round(sumIf(gross_amount, counts_as_revenue = 1), 2) as gross_revenue,
    round(sumIf(net_amount, counts_as_revenue = 1), 2) as net_revenue,
    round(net_revenue / nullIf(countIf(counts_as_revenue = 1), 0), 2) as avg_order_value
from {{ ref('gold_order_facts') }}
group by order_date