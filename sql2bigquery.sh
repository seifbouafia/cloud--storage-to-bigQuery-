#!/bin/bash

# 1. Set environment variables (replace with your credentials)
export SQLSERVER_HOST="127.0.0.1"
export SQLSERVER_USER="root@localhost"
export SQLSERVER_PASSWORD="NULL"
export SQLSERVER_DATABASE="asterisk"
export SQLSERVER_TABLE="cdr"
export GOOGLE_CLOUD_PROJECT="big-query-testing-410610"
export BIGQUERY_DATASET="dataflow"
export BIGQUERY_TABLE="cdr"

# 2. Retrieve table schema from SQL Server (optional, if needed for BigQuery schema creation)
# ...

# 3. Export data from SQL Server to CSV
sqlcmd -S "${SQLSERVER_HOST}" -U "${SQLSERVER_USER}" -d "${SQLSERVER_DATABASE}" -Q "SELECT * FROM ${SQLSERVER_TABLE}" -o "/tmp/my-data.csv"

# 4. Load CSV data into BigQuery
bq load --source_format=CSV --table "${BIGQUERY_DATASET}.${BIGQUERY_TABLE}" --write_disposition=WRITE_TRUNCATE /tmp/my-data.csv

# 5. Error handling and logging
if [[ $? -ne 0 ]]; then
  echo "Error loading data into BigQuery"
  exit 1
fi

echo "Data loaded successfully"
