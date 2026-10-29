select order_code
from {{ ref('silver_orders') }}
where product_code not in (select product_code from {{ ref('silver_products') }})