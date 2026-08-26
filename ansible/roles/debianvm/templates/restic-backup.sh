#!/usr/bin/env bash
set -euo pipefail

export RESTIC_PASSWORD="{{ lookup('ansible.builtin.env', 'RESTIC_PASSWORD') }}"
export RESTIC_REPOSITORY="s3:s3.amazonaws.com/weastie-selfhosted-backups"

BACKUP_PATH="/data"
LOG_FILE="/var/log/restic-backup.log"

# Send all output (stdout + stderr) to log file
exec >>"$LOG_FILE" 2>&1

echo "=== Backup started at $(date) ==="

# Check if the repository is already initialized
if restic cat config >/dev/null 2>&1; then
  echo "Repository already initialized. Skipping init."
else
  echo "Initializing new Restic repository..."
  restic init
fi

# 2. Run the incremental backup
restic backup "$BACKUP_PATH" \
  --tag cron \
  --exclude-caches

# 3. Apply retention policy (Prune old snapshots)
# Keeps 7 daily, 4 weekly, and 12 monthly snapshots automatically
restic forget \
  --keep-daily 7 \
  --keep-weekly 3 \
  --keep-monthly 3 \
  --prune

echo "=== Backup completed at $(date) ==="
