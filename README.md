# Crypto Medallion Pipeline

An end-to-end data engineering project that ingests public cryptocurrency market data through near-real-time and batch pipelines, stores it in ClickHouse, and transforms it using a Medallion Architecture.

## Architecture

- **Apache NiFi:** Near-real-time ingestion from the Binance public WebSocket market-data stream.
- **Apache Airflow:** Orchestrates historical batch ingestion.
- **dbt:** Builds and tests silver and gold transformation models.
- **ClickHouse:** Stores bronze, silver, and gold analytical tables.
- **Docker Compose:** Provides a reproducible local environment.

## Data Scope

- Market: BTC/USDT
- Interval: 1-minute candles
- Batch history: Approximately 30 days
- Streaming: Continuously receive updates and persist finalized candles.

## Medallion Layers

- **Bronze:** Ingested market data and source metadata.
- **Silver:** Validated, typed, and deduplicated candles.
- **Gold:** Daily price summaries, trading volume, and price-change metrics.

## Project Structure

- `nifi/`: NiFi flow configuration.
- `airflow/dags/`: Airflow orchestration.
- `dbt/`: SQL transformation project.
- `clickhouse/init/`: ClickHouse initialization scripts.
- `scripts/`: Supporting scripts.
- `docs/`: Architecture and implementation documentation.

## Status

Project setup and implementation in progress.
