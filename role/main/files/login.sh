#!/bin/bash

WEBHOOK_URL="{{ login_webhook_url }}"

send_discord_alert() {
    local message="$1"
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"$message\"}" \
         $WEBHOOK_URL
}

tail -Fn0 /var/log/auth.log | while read line; do
    if echo "$line" | grep "Accepted" | grep "ssh"; then
        username=$(echo "$line" | grep -oP '(?<=for )[^ ]+')
        ip_address=$(echo "$line" | grep -oP '(?<=from )[^ ]+')
        message="L'utilisateur $username s'est connecté au serveur depuis $ip_address"
        send_discord_alert "$message"
    fi
done
