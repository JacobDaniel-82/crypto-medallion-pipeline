select symbol, `interval`, open_time, count() as n
from {{ ref('silver_market_candles') }}
group by symbol, `interval`, open_time
having n > 1