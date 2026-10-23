# Crypto Medallion Pipeline — Architecture

## Project Overview
A data engineering pipeline that ingests historical and near-real-time
cryptocurrency market data from Binance into ClickHouse and transforms it
through a Medallion Architecture (bronze, silver, gold).

## Technology Stack
- Python: API extraction and ingestion logic
- Apache Airflow: Batch workflow orchestration, retries and scheduled dbt runs
- Apache NiFi: Near-real-time ingestion
- ClickHouse: Analytical database and warehouse
- dbt: SQL transformations (ELT) and data quality tests
- Docker Compose: Local service orchestration
- GitHub Actions: Continuous integration

## Data Source
- Exchange: Binance public market data API (klines endpoint)
- Symbol: BTCUSDT
- Interval: 1 minute
- Historical window: Rolling 30 days

## Architecture

```
Binance REST API (history) -> Airflow + Python -> ClickHouse bronze
Binance REST API (live)    -> NiFi              -> ClickHouse bronze
ClickHouse bronze -> dbt -> silver -> dbt -> gold
```

Airflow runs the daily `crypto_medallion_pipeline` DAG:

```
load_bronze_batch -> dbt_run -> dbt_test
```

## Live Ingestion (NiFi)

```
InvokeHTTP (Binance, every 60s) -> SplitJson -> InvokeHTTP (ClickHouse)
```

- The Binance request asks for the 3 most recent candles. The last one is always still forming, so SplitJson uses `$[:-1]` to drop it.
- Each remaining candle is a single JSON array, which ClickHouse reads directly as `JSONCompactEachRow`.
- The final InvokeHTTP sends an `INSERT ... SELECT ... FROM input(...)` query. ClickHouse converts millisecond timestamps to `DateTime64`, casts price strings to floats, and tags the rows `source = 'nifi'`.
- Failure and retry relationships end in a funnel so any rejected FlowFile stays visible in a queue.
- The flow definition is exported to `nifi/flows/`.

## Medallion Layers
- Bronze: `bronze_market_candles`. Raw candles from batch and live sources, append-only, with a `source` tag and `ingested_at`. Duplicates across polls and sources are allowed here by design.
- Silver: `silver_market_candles`. Closed candles that pass sanity checks, deduplicated to one row per (symbol, interval, open_time), keeping the most recently ingested copy.
- Gold:
  - `gold_daily_price_summary`: daily OHLC, volume, trades, price change, complete-day flag.
  - `gold_hourly_market_stats`: hourly OHLC, volume, trades, complete-hour flag.
  - `gold_daily_volatility`: daily range percent, 7-day average range, volume versus 7-day average.

## Data Quality
13 dbt tests: not-null checks, a uniqueness check on the daily volatility key, no duplicate candles in silver, valid price and volume values in silver, and sanity limits on candle counts per day and per hour in gold.

## Handling Gaps
The live flow only collects while running. The daily batch reload replaces its own `batch` rows and leaves `nifi` rows alone. Silver removes any overlap, so downtime gaps are healed without creating duplicates.

## CI/CD
- CI: GitHub Actions starts a temporary ClickHouse, creates the bronze table from `clickhouse/init/`, loads synthetic duplicated candles, then runs `dbt run` and `dbt test` on every push and pull request.
- CD: Not implemented. The stack runs locally, so there is no deployment target. With one, a deploy job would run after CI passes on `main`.

## Current Implementation Status
- ClickHouse container and bronze table created, DDL stored in `clickhouse/init/`.
- Historical Binance ingestion script implemented and verified.
- NiFi live ingestion implemented and verified.
- dbt silver and gold models built, 13 tests passing.
- dbt installed in the Airflow image and scheduled daily through `crypto_medallion_pipeline`.
- GitHub Actions CI passing.

## Remaining Work
- Continuous deployment, if a deployment environment becomes available.

## Local Services
- ClickHouse HTTP: http://localhost:8123
- Airflow UI: http://localhost:8082
- NiFi UI: https://localhost:8443/nifi

Configuration secrets belong in `.env`, which must not be committed.
Use `.env.example` as the configuration template.