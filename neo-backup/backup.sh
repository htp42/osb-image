#!/bin/sh
set -e

# Timestamp
DATE=$(date +"%Y-%m-%d_%H-%M")

# Directory to store dump
DUMP_DIR="/backup/neo4j-backup-$DATE"
mkdir -p "$DUMP_DIR"

echo "Running backup at $DATE..."

# Dump the database into the directory
neo4j-admin database dump mdrdb --to-path="$DUMP_DIR"

# Find the dump file created by neo4j-admin
DUMP_FILE=$(find "$DUMP_DIR" -type f -name "*.dump" | head -n 1)

echo "Uploading $DUMP_FILE to S3 bucket: $S3_BUCKET ..."
aws s3 cp "$DUMP_FILE" "s3://$S3_BUCKET/neo4j/$DATE.dump"

# Remove local dump directory
rm -rf "$DUMP_DIR"

# Optional: keep only last 3 backups in S3
FILES=$(aws s3api list-objects-v2 \
    --bucket "$S3_BUCKET" \
    --prefix "neo4j/" \
    --query "sort_by(Contents,&LastModified)[].Key" \
    --output text)

COUNT=$(echo "$FILES" | wc -w)

if [ "$COUNT" -gt 3 ]; then
    NUM_DELETE=$((COUNT - 3))
    echo "$FILES" | awk -v n="$NUM_DELETE" '{for(i=1;i<=n;i++){print $i}}' \
    | while read key; do
        echo "Deleting old backup: $key"
        aws s3 rm "s3://$S3_BUCKET/$key"
    done
fi

echo "Backup completed at $DATE."
