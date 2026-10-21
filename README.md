# Crypto Medallion Pipeline

An end-to-end data engineering project that ingests public cryptocurrency market data through near-real-time and batch pipelines, stores it in ClickHouse, and transforms it using a Medallion Architecture (bronze, silver, gold).

## Architecture

- **Apache NiFi:** Near-real-time ingestion. Polls the Binance public klines REST API every 60 seconds, splits the response into individual candles, and inserts only closed candles into ClickHouse bronze. The forming candle is dropped so partial data never lands.
- **Apache Airflow:** Orchestrates historical batch ingestion (`historical_crypto_ingestion` DAG).
- **dbt:** Builds and tests silver and gold transformation models (ELT inside ClickHouse).
- **ClickHouse:** Stores bronze, silver, and gold analytical tables.
- **Docker Compose:** Provides a reproducible local environment.
Binance REST API (history) -> Airflow + Python -> ClickHouse bronze
Binance REST API (live) -> NiFi -> ClickHouse bronze
ClickHouse bronze -> dbt -> silver -> dbt -> gold


## Data Scope

- Market: BTC/USDT
- Interval: 1-minute candles
- Batch history: approximately 30 days
- Live: one poll per minute; closed candles only

## Medallion Layers

- **Bronze** (`bronze_market_candles`): Raw candles from both sources, append-only. Rows carry a `source` tag (`batch` or `nifi`) and an `ingested_at` timestamp. Overlapping live polls and batch/live overlap can create duplicate candles here by design.
- **Silver** (`silver_market_candles`): Closed candles with sanity checks applied (positive prices, high >= low, non-negative volume), deduplicated to one row per `(symbol, interval, open_time)`, keeping the most recently ingested copy.
- **Gold** (planned): Daily price summaries, trading volume, and price-change metrics.

## Project Structure

- `nifi/flows/`: Exported NiFi flow definition (`Binance_Live_Market_Ingestion.json`).
- `airflow/dags/`: Airflow orchestration.
- `dbt/`: dbt project (`models/sources.yml`, `models/silver/`).
- `scripts/`: Supporting scripts (historical candle loader).
- `docs/`: Architecture and implementation documentation.

## Running Locally

1. Copy `.env.example` to `.env` and set the passwords. NiFi requires a password of at least 12 characters.
2. Start the services: `docker compose up -d`
3. Import `nifi/flows/Binance_Live_Market_Ingestion.json` into NiFi (https://localhost:8443/nifi), set the ClickHouse password on the final InvokeHTTP processor, and start the process group.
4. Trigger the `historical_crypto_ingestion` DAG in Airflow (http://localhost:8082).
5. Build silver with dbt (from the `dbt/` folder, with `CLICKHOUSE_PASSWORD` set as an environment variable): `dbt run --profiles-dir .`

## Status

- Bronze batch ingestion (Airflow): done
- Bronze live ingestion (NiFi): done
- Silver model (dbt): done
- In progress: gold models, dbt tests and docs, dbt scheduled through Airflow, CI/CD