#!/usr/bin/env bash
set -euo pipefail

SRC="/opt/local/pbs_backups"
DST="shadowDrive:pbs_backups"

/usr/bin/rclone sync "$SRC" "$DST" --checkers 8 --transfers 4 --bwlimit=10M --progress
