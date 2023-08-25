#!/bin/sh

set -eu

# Set environment variables for Telegram token and chat ID
export TELEGRAM_TOKEN="${{ secrets.TELEGRAM_TOKEN }}"
export TELEGRAM_CHAT_ID="${{ secrets.TELEGRAM_CHAT_ID }}"

# Set GITHUB environment variable to true
export GITHUB="true"

[ -n "$*" ] && export TELEGRAM_MESSAGE="$*"

# Run the drone-telegram command
/bin/drone-telegram
