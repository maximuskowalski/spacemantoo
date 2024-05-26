#!/bin/bash

# example spacemantoo storage monitor cron entry
# */5 * * * * "/opt/scripts/max/spacemantoo/spacemantoo.sh"


# Configuration file path
CONFIG_FILE="$(dirname "$0")/spaceman.cfg"

# Function to send a Discord embed notification
send_notification() {
    local message_type=$1
    local free_space
    free_space=$(get_disk_space)

    local embed_color="65280" # Green color for non-alerts
    local title=""
    local description=""
    local alert_prefix=""

    if [[ "$message_type" == "alert" ]]; then
        embed_color="15158332" # Red color for alerts
        alert_prefix="@everyone\n"
        title="Low Disk Space Alert"
        description="Warning: Low disk space on $SERVER_NAME ($DIRECTORY_PATH). Available space: $free_space."
    else
        title="Disk Space Daily Update"
        description="Available space on $SERVER_NAME ($DIRECTORY_PATH):"
    fi

    # JSON payload for Discord Embed
    json_payload=$(cat <<EOF
{
    "content": "${alert_prefix}",
    "embeds": [{
        "title": "$title",
        "description": "$description",
        "color": $embed_color,
        "fields": [
            {"name": "Server", "value": "$SERVER_NAME", "inline": true},
            {"name": "Path", "value": "$DIRECTORY_PATH", "inline": true},
            {"name": "Free Space", "value": "$free_space", "inline": false}
        ],
        "footer": {"text": "kowalski spacemantoo monitor"}
    }]
}
EOF
)

    # Send the notification using curl
    curl -H "Content-Type: application/json" -d "$json_payload" "$WEBHOOK_URL"
}

# Function to get disk space in GB or TB
get_disk_space() {
    local available_space_gb
    # Fetch disk space safely, handle potential errors
    available_space_gb=$(df -BG "$DIRECTORY_PATH" 2>/dev/null | awk 'NR==2{print $4}' | sed 's/G//')
    if [ -z "$available_space_gb" ]; then
        echo "Error: Failed to get disk space for $DIRECTORY_PATH" >&2
        exit 1
    fi

    # Convert GB to TB if necessary
    if [[ "$available_space_gb" -ge 1024 ]]; then
        local available_space_tb=$((available_space_gb / 1024))
        echo "${available_space_tb}TB"
    else
        echo "${available_space_gb}GB"
    fi
}

# Function to check if daily notification has been sent
check_daily_notification() {
    local log_file
    log_file="$(dirname "$0")/daily_notification.log"
    local today
    today=$(date +%Y-%m-%d)

    # Ensure log file exists
    touch "$log_file"

    # Check if today's date is already logged
    if grep -q "$today" "$log_file"; then
        return 0 # Notification already sent
    else
        echo "$today" >> "$log_file"
        return 1 # Notification not sent
    fi
}

# Main script logic
main() {
    # Check if config file exists and source it
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    else
        echo "Configuration file not found." >&2
        exit 1
    fi

    # Validate MIN_SPACE_GB is a positive integer
    if ! [[ "$MIN_SPACE_GB" =~ ^[0-9]+$ ]]; then
        echo "Invalid configuration: MIN_SPACE_GB must be a positive integer." >&2
        exit 1
    fi

    # Get available disk space and convert it to GB for comparison
    available_space=$(get_disk_space)
    local available_space_in_gb=$(echo "$available_space" | grep -o -E '[0-9]+')
    local available_space_unit=$(echo "$available_space" | grep -o -E 'TB|GB')

    if [[ "$available_space_unit" == "TB" ]]; then
        available_space_in_gb=$((available_space_in_gb * 1024)) # Convert TB to GB
    fi

    # Check if space is below the minimum threshold
    if [[ "$available_space_in_gb" -lt "$MIN_SPACE_GB" ]]; then
        send_notification "alert"
    elif ! check_daily_notification; then
        send_notification "daily"
    fi
}

# Execute the main function
main
