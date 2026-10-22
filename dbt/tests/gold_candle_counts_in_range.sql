select 'daily' as grain, trade_date as period
from {{ ref('gold_daily_price_summary') }}
where candle_count > 1440

union all

select 'hourly' as grain, toDate(hour_start) as period
from {{ ref('gold_hourly_market_stats') }}
where candle_count > 60