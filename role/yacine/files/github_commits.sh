#!/bin/bash

WEBHOOK_URL="{{ github_commits_iacine_webhook_url }}"
DATE=$(date +%d-%m-%Y)

cd /root/github_commits

if [ $((RANDOM % 10 + 1)) -le 3 ]; then
    commits_number=0
else
    commits_number=$(( (RANDOM % 6) + 1 ))
fi

if [ "$commits_number" -gt 0 ]; then
    for commit in $(seq 1 "$commits_number"); do
        git commit --allow-empty -m "[$commit/$commits_number] $DATE"
    done
    git push
    discord_message="$commits_number commits created today."
else
    discord_message="No commits created today."
fi

send_discord_alert() {
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"$discord_message\"}" \
         "$WEBHOOK_URL"
}

send_discord_alert
