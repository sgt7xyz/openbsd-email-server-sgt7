#!/usr/bin/env zsh

services=("smtpd" "dovecot" "rspamd")

# Function to stop a service
stop_service() {
  doas rcctl stop $1
}

# Function to start a service
start_service() {
  doas rcctl start $1
}

# Loop over the services and stop each one
for service in "${services[@]}"; do
  stop_service $service
done

# Loop over the services and start each one
for service in "${services[@]}"; do
  start_service $service
done