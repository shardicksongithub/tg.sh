#!/bin/bash

# Set Telegram Bot token and chat ID
BOT_TOKEN="7665225508:AAGDkIRB7TaXBNmVWLBYe_9gEQiJUC8mFmM"
CHAT_ID="@moned_channel"

# Directory for QR codes
QR_CODE_DIR="/root/wireguard_clients"
mkdir -p "$QR_CODE_DIR"  # Ensure directory exists

# Function to create a customer
create_customer() {
    local customer_name=$1
    local qr_file="$QR_CODE_DIR/${customer_name}.qr.png"
    local config_file="/etc/wireguard/clients/${customer_name}.conf"

    # Generate the client using WireGuard installation script
    bash wireguard-install.sh <<EOF
2
$customer_name
EOF

    # Generate QR code for the config
    if [ -f "$config_file" ]; then
        qrencode -o "$qr_file" < "$config_file"
        echo "QR Code for $customer_name created: $qr_file"
        send_to_telegram "$qr_file" "$customer_name"
    else
        echo "Error: Config file for $customer_name not found!"
    fi
}

# Function to send QR code to Telegram
send_to_telegram() {
    local file_path=$1
    local customer_name=$2

    if [ -f "$file_path" ]; then
        echo "Sending QR code for $customer_name to Telegram..."
        curl -F chat_id="$CHAT_ID" \
             -F photo=@"$file_path" \
             "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto"
    else
        echo "Error: QR Code file not found for $customer_name"
    fi
}

# Create 5 customers with timestamps
for i in {1..5}; do
    timestamp=$(date +"%Y%m%d_%H%M%S")
    customer_name="Customer${i}_${timestamp}"
    create_customer "$customer_name"
done

echo "All QR codes have been sent to Telegram."
