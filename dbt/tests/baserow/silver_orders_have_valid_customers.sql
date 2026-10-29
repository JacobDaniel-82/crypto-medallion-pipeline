select order_code
from {{ ref('silver_orders') }}
where customer_code not in (select customer_code from {{ ref('silver_customers') }})