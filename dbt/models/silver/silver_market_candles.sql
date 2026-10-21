{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(symbol, `interval`, open_time)'
) }}

select
    symbol,
    `interval`,
    open_time,
    close_time,
    open_price,
    high_price,
    low_price,
    close_price,
    volume,
    number_of_trades,
    source,
    ingested_at
from {{ source('bronze', 'bronze_market_candles') }}
where is_final = 1
  and open_price > 0
  and close_price > 0
  and high_price >= low_price
  and volume >= 0
order by symbol, `interval`, open_time, ingested_at desc
limit 1 by symbol, `interval`, open_time