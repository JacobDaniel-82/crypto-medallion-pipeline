{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(symbol, `interval`, trade_date)'
) }}

select
    symbol,
    `interval`,
    toDate(open_time) as trade_date,
    argMin(open_price, open_time) as day_open,
    max(high_price) as day_high,
    min(low_price) as day_low,
    argMax(close_price, open_time) as day_close,
    sum(volume) as total_volume,
    sum(number_of_trades) as total_trades,
    count() as candle_count,
    day_close - day_open as price_change,
    round((day_close - day_open) / day_open * 100, 4) as price_change_pct,
    candle_count = 1440 as is_complete_day
from {{ ref('silver_market_candles') }}
group by symbol, `interval`, trade_date