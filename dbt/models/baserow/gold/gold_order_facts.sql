{{ config(materialized='table', engine='MergeTree()', order_by='(order_date, order_code)') }}

select
    o.order_code as order_code,
    o.order_date as order_date,
    o.customer_code as customer_code,
    c.country as country,
    o.product_code as product_code,
    p.product_name as product_name,
    p.category as category,
    o.status as status,
    o.quantity as quantity,
    p.unit_price as unit_price,
    o.discount_pct as discount_pct,
    round(o.quantity * p.unit_price, 2) as gross_amount,
    round(o.quantity * p.unit_price * (1 - o.discount_pct / 100), 2) as net_amount,
    toUInt8(o.status in ('Delivered', 'Shipped')) as counts_as_revenue
from {{ ref('silver_orders') }} o
inner join {{ ref('silver_customers') }} c on o.customer_code = c.customer_code
inner join {{ ref('silver_products') }} p on o.product_code = p.product_code