select d.total as daily_total, c.total as customer_total
from (select sum(net_revenue) as total from {{ ref('gold_daily_sales') }}) d
cross join (select sum(lifetime_net_revenue) as total from {{ ref('gold_customer_summary') }}) c
where abs(d.total - c.total) > 5