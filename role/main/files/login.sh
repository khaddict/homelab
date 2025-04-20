#!/bin/bash

WEBHOOK_URL="{{ login_webhook_url }}"

WHITELISTED_IPS=("192.168.0.20" "192.168.27.65" "192.168.0.46")

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

        if printf "%s\n" "${WHITELISTED_IPS[@]}" | grep -Fxq "$ip_address"; then
            echo "Login from $ip_address ignored (whitelisted)"
            continue
        fi

        message="User $username logged into the server from $ip_address"
        send_discord_alert "$message"
    fi
done
