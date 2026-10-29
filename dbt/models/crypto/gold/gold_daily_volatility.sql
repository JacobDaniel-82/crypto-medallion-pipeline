{{ config(
    materialized='table',
    engine='MergeTree()',
    order_by='(symbol, `interval`, trade_date)'
) }}

with daily as (
    select
        symbol,
        `interval`,
        trade_date,
        total_volume,
        round((day_high - day_low) / day_open * 100, 4) as day_range_pct
    from {{ ref('gold_daily_price_summary') }}
    where is_complete_day = 1
)

select
    symbol,
    `interval`,
    trade_date,
    day_range_pct,
    round(avg(day_range_pct) over w, 4) as avg_range_pct_7d,
    round(total_volume / avg(total_volume) over w, 4) as volume_vs_7d_avg
from daily
window w as (
    partition by symbol, `interval`
    order by trade_date
    rows between 6 preceding and current row
)