#!/usr/bin/env bash
set -euo pipefail

SRC="/opt/local/pbs_backups"
DST="/opt/remote/pbs_backups"
REMOTE="shadowDrive:pbs_backups"

rm -rf "$DST"
mkdir -p "$DST"
cp -a "$SRC"/. "$DST"/

/usr/bin/rclone sync "$DST" "$REMOTE" --checkers 8 --transfers 4 --bwlimit=10M --progress
