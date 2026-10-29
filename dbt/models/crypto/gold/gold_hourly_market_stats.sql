{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(symbol, `interval`, hour_start)'
) }}

select
    symbol,
    `interval`,
    toStartOfHour(open_time) as hour_start,
    argMin(open_price, open_time) as hour_open,
    max(high_price) as hour_high,
    min(low_price) as hour_low,
    argMax(close_price, open_time) as hour_close,
    sum(volume) as total_volume,
    sum(number_of_trades) as total_trades,
    count() as candle_count,
    candle_count = 60 as is_complete_hour
from {{ ref('silver_market_candles') }}
group by symbol, `interval`, hour_start