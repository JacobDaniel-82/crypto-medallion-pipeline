# Crypto Medallion Pipeline — Architecture

## Project Overview
A data engineering pipeline that ingests historical and near-real-time
cryptocurrency market data from Binance into ClickHouse.

## Technology Stack
- Python: API extraction and ingestion logic
- Apache Airflow: Batch workflow orchestration and retries
- Apache NiFi: Planned near-real-time ingestion
- ClickHouse: Analytical database and warehouse
- dbt: Planned SQL transformations and data quality tests
- Docker Compose: Local service orchestration
- GitHub Actions: Planned CI/CD

## Data Source
- Exchange: Binance public market data API
- Symbol: BTCUSDT
- Interval: 1 minute
- Historical window: Approximately 30 days

## Architecture

Binance REST API -> Python ingestion -> ClickHouse Bronze

Binance live market feed -> NiFi -> ClickHouse Bronze

ClickHouse Bronze -> dbt Silver -> dbt Gold

Airflow orchestrates batch ingestion and, eventually,
scheduled dbt transformations.

## Medallion Layers
- Bronze: Ingested market candles and source metadata.
- Silver: Validated, typed, and deduplicated market candles.
- Gold: Daily opening/closing prices, highs/lows, trading volume,
  and daily price changes.

## Current Implementation Status
- ClickHouse container and Bronze table created.
- Historical Binance ingestion script implemented.
- 43,201 historical candle records loaded and verified.
- No duplicate candle keys found in the initial batch.
- Airflow configured with PostgreSQL metadata storage.
- Historical ingestion DAG created and discovered by Airflow.
- Airflow-to-ClickHouse connectivity verified.
- Historical DAG rerun tested without increasing the batch row count.

## Remaining Work
- Implement and test NiFi near-real-time ingestion.
- Build dbt Silver and Gold models.
- Add data quality tests.
- Validate the complete pipeline end to end.
- Add CI/CD checks and finalize project documentation.

## Local Services
- ClickHouse HTTP: http://localhost:8123
- Airflow UI: http://localhost:8082

Configuration secrets belong in `.env`, which must not be committed.
Use `.env.example` as the configuration template.
