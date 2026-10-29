{{ config(materialized='table', engine='MergeTree()', order_by='customer_code') }}

select
    customer_code,
    any(country) as customer_country,
    count() as orders_total,
    countIf(counts_as_revenue = 1) as orders_completed,
    sumIf(quantity, counts_as_revenue = 1) as units_bought,
    round(sumIf(net_amount, counts_as_revenue = 1), 2) as lifetime_net_revenue,
    round(lifetime_net_revenue / nullIf(orders_completed, 0), 2) as avg_order_value,
    min(order_date) as first_order_date,
    max(order_date) as last_order_date
from {{ ref('gold_order_facts') }}
group by customer_code