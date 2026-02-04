#!/usr/bin/env bash
# SIGWINCH monitor for jaillm
# Polls terminal size and signals script processes when it changes.
# This runs outside the jail to maintain terminal access.

set -euo pipefail

parent_pid="${1:?Usage: winch-monitor.sh <parent_pid>}"

# Explicitly attach to tty
exec 0</dev/tty

# Wait for jail to start
sleep 0.5

last_size=$(stty size 2>/dev/null || echo "")

while kill -0 "$parent_pid" 2>/dev/null; do
    sleep 0.1
    size=$(stty size </dev/tty 2>/dev/null || echo "")
    if [[ -n "$size" && "$size" != "$last_size" ]]; then
        last_size="$size"
        # Signal all script processes
        pkill -WINCH script 2>/dev/null || true
    fi
done
