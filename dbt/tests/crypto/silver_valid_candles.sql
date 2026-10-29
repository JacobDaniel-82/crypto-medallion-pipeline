select *
from {{ ref('silver_market_candles') }}
where high_price < low_price
   or open_price <= 0
   or close_price <= 0
   or volume < 0