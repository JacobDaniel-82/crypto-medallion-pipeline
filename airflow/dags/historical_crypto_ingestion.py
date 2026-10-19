
from datetime import timedelta

import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="historical_crypto_ingestion",
    description="Load historical Binance market candles into ClickHouse Bronze",
    start_date=pendulum.datetime(2026, 10, 19, tz="UTC"),
    schedule=None,
    catchup=False,
    default_args={
        "owner": "data-engineering",
        "retries": 2,
        "retry_delay": timedelta(minutes=5),
    },
    tags=["crypto", "batch", "bronze"],
) as dag:

    load_historical_candles = BashOperator(
        task_id="load_historical_candles",
        bash_command="python /opt/airflow/scripts/load_historical_candles.py",
    )
