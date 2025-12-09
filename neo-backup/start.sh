#!/bin/sh

echo "Setting up cron job to run at 18:00 UTC daily..."

echo "00 18 * * * /backup/backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/neo4j-backup

chmod 0644 /etc/cron.d/neo4j-backup
touch /var/log/cron.log

echo "Cron job added. Starting cron..."
cron -f

