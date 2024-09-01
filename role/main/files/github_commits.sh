#!/bin/bash

WEBHOOK_URL="{{ github_commits_khaddict_webhook_url }}"
DATE=$(date +%d-%m-%Y)

cd /root/github_commits

if [ $((RANDOM % 10)) -lt 7 ]; then
    commits_number=0
else
    commits_number=$(( (RANDOM % 5) + 1 ))
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
