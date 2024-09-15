#!/bin/bash

REPO_URL="https://api.github.com/repos/khaddict/homelab/activity"
GITHUB_TOKEN="{{ github_pull_token }}"
REPO_DIR="/srv/salt"
FILE_PATH="/root/github_pull/github_pull.txt"
WEBHOOK_URL="{{ pull_webhook_url }}"

send_discord_alert() {
    local message="$1"
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"$message\"}" \
         $WEBHOOK_URL
}

response=$(curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "$REPO_URL")

after=$(echo "$response" | jq -r .[0].after)
activity_type=$(echo "$response" | jq -r .[0].activity_type)

if [ -f "$FILE_PATH" ]; then
    previous=$(cat "$FILE_PATH")
else
    previous=""
fi

if [ "$after" != "$previous" ]; then
    echo "Change detected: $activity_type"

    case "$activity_type" in
        "push")
            echo "Executing git pull"
            ssh saltmaster "cd \"$REPO_DIR\" && git pull"
            send_discord_alert "A new push was detected and changes have been pulled in the repository."
            ;;
        "force_push")
            echo "Executing git pull --rebase"
            ssh saltmaster "cd \"$REPO_DIR\" && git pull --rebase"
            send_discord_alert "A force push was detected and changes have been rebased in the repository."
            ;;
        *)
            echo "Unsupported activity type: $activity_type"
            send_discord_alert "An unsupported activity type ($activity_type) was detected in the repository."
            ;;
    esac

    echo "$after" > "$FILE_PATH"
else
    echo "No update needed."
fi
