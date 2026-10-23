from datetime import timedelta

import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator

DBT = "/home/airflow/dbt_venv/bin/dbt"
DBT_ARGS = "--profiles-dir /opt/airflow/dbt --project-dir /opt/airflow/dbt --target-path /tmp/dbt_target --log-path /tmp/dbt_logs"

with DAG(
    dag_id="crypto_medallion_pipeline",
    description="Daily: reload batch candles into Bronze, then build and test Silver and Gold with dbt",
    start_date=pendulum.datetime(2026, 10, 19, tz="UTC"),
    schedule="0 2 * * *",
    catchup=False,
    default_args={
        "owner": "data-engineering",
        "retries": 2,
        "retry_delay": timedelta(minutes=5),
    },
    tags=["crypto", "batch", "dbt", "medallion"],
) as dag:

    load_bronze_batch = BashOperator(
        task_id="load_bronze_batch",
        bash_command="python /opt/airflow/scripts/load_historical_candles.py",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"{DBT} run {DBT_ARGS}",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"{DBT} test {DBT_ARGS}",
    )

    load_bronze_batch >> dbt_run >> dbt_test