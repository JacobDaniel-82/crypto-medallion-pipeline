select s.n as silver_orders, f.n as fact_orders
from (select count() as n from {{ ref('silver_orders') }}) s
cross join (select count() as n from {{ ref('gold_order_facts') }}) f
where s.n != f.n