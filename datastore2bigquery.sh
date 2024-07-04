#!/bin/bash
set -euo pipefail

echo "This script exports multiple Datastore kinds to Cloud Storage, imports them into BigQuery, and then deletes the Cloud Storage files."

PROJECT=big-query-testing-410610
BQDATASET=dataflow
GCS_BASE_PATH=gs://datastore-to-bigquery-exporting
EXPORT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

KINDS=("Ticket" "Cabinet");

KINDS_EXPORT="";

for KIND in "${KINDS[@]}"; do
    KINDS_EXPORT="$KINDS_EXPORT$KIND";
    if [ "$KIND" != "${KINDS[@]: -1}" ]; then
        KINDS_EXPORT="$KINDS_EXPORT,";
    fi
done

GCSPATH="$GCS_BASE_PATH/datastore-bigquery-export-$EXPORT_TIMESTAMP"

echo -e "Starting datastore export $KINDS_EXPORT..."
gcloud datastore export --kinds=$KINDS_EXPORT --project="$PROJECT" "$GCSPATH"

echo -e "Creating BigQuery dataset if not exists..."
bq mk -f "$PROJECT:$BQDATASET";

for KIND in "${KINDS[@]}"; do
  echo -e "Loading export for kind: $KIND into BigQuery..."
  bq load --project_id="$PROJECT" --source_format=DATASTORE_BACKUP --replace=true "$PROJECT:$BQDATASET.$KIND" "$GCSPATH/all_namespaces/kind_$KIND/all_namespaces_kind_$KIND.export_metadata"
done

echo -e "Deleting backup files from Cloud Storage..."
gsutil -m rm -r "$GCS_BASE_PATH/datastore-bigquery-export-$EXPORT_TIMESTAMP"

echo -e "\nDone"
