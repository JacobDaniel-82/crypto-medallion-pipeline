from datetime import timedelta

import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator

DBT = "/home/airflow/dbt_venv/bin/dbt"
DBT_ARGS = (
    "--profiles-dir /opt/airflow/dbt --project-dir /opt/airflow/dbt "
    "--target-path /tmp/dbt_target_baserow --log-path /tmp/dbt_logs_baserow"
)

with DAG(
    dag_id="baserow_medallion_pipeline",
    description="Daily: load Baserow tables into Bronze, then build and test Silver and Gold with dbt",
    start_date=pendulum.datetime(2026, 10, 19, tz="UTC"),
    schedule="0 3 * * *",
    catchup=False,
    max_active_runs=1,
    default_args={
        "owner": "data-engineering",
        "retries": 2,
        "retry_delay": timedelta(minutes=5),
    },
    tags=["baserow", "batch", "dbt", "medallion"],
) as dag:

    load_baserow_bronze = BashOperator(
        task_id="load_baserow_bronze",
        bash_command="python /opt/airflow/scripts/load_baserow_tables.py",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"{DBT} run {DBT_ARGS} --select path:models/baserow",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"{DBT} test {DBT_ARGS} --select path:models/baserow path:tests/baserow",
    )
    max_active_runs=1,
    load_baserow_bronze >> dbt_run >> dbt_test