#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="your-project-id"
DATASET_ID="retail_inventory"
BUCKET="your-gcs-bucket"
TABLE_NAME="inventory_bronze"
GCS_URI="gs://${BUCKET}/raw/inventory.csv"

# Load the raw Kaggle CSV into BigQuery as bronze, preserving original values as STRING.
bq load \
  --project_id="${PROJECT_ID}" \
  --source_format=CSV \
  --skip_leading_rows=1 \
  --field_delimiter=',' \
  --quote='"' \
  --null_marker='' \
  --replace \
  --allow_quoted_newlines \
  --autodetect=false \
  --schema='date:STRING,store:STRING,product:STRING,category:STRING,region:STRING,inventory_level:STRING,units_sold:STRING,units_ordered:STRING,demand_forecast:STRING,price:STRING,discount:STRING,promotions:STRING' \
  "${PROJECT_ID}:${DATASET_ID}.${TABLE_NAME}" \
  "${GCS_URI}"

printf "Loaded %s to %s.%s\n" "${GCS_URI}" "${DATASET_ID}" "${TABLE_NAME}"
