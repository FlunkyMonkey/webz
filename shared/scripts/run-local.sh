#!/bin/bash
# Local development script for vGriz Web Projects
# Usage: ./run-local.sh [vgriz|regulogix|familycabin|all]

set -e

# Configuration
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_FILE="${REPO_DIR}/local-dev.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to install dependencies for a site
install_deps() {
    site=$1
    log "Installing dependencies for $site..."
    cd "$REPO_DIR/$site"
    npm install
}

# Function to start a site in development mode
start_site() {
    site=$1
    port=$2
    log "Starting $site on port $port..."
    cd "$REPO_DIR/$site"
    PORT=$port npm run dev &
    echo $! > "$REPO_DIR/$site/dev.pid"
    log "$site started with PID $(cat "$REPO_DIR/$site/dev.pid")"
}

# Function to stop a running site
stop_site() {
    site=$1
    if [ -f "$REPO_DIR/$site/dev.pid" ]; then
        pid=$(cat "$REPO_DIR/$site/dev.pid")
        log "Stopping $site (PID: $pid)..."
        kill $pid 2>/dev/null || true
        rm "$REPO_DIR/$site/dev.pid"
    else
        log "$site is not running."
    fi
}

# Create log file if it doesn't exist
touch "$LOG_FILE"

# Stop any running sites first
if [ "$1" = "stop" ]; then
    log "Stopping all running sites..."
    stop_site "vgriz"
    stop_site "regulogix"
    stop_site "familycabin"
    log "All sites stopped."
    exit 0
fi

# Main logic
if [ "$1" = "vgriz" ] || [ "$1" = "all" ]; then
    install_deps "vgriz"
    stop_site "vgriz"
    start_site "vgriz" 3001
fi

if [ "$1" = "regulogix" ] || [ "$1" = "all" ]; then
    install_deps "regulogix"
    stop_site "regulogix"
    start_site "regulogix" 3002
fi

if [ "$1" = "familycabin" ] || [ "$1" = "all" ]; then
    install_deps "familycabin"
    stop_site "familycabin"
    start_site "familycabin" 3003
fi

# If no valid argument is provided
if [ "$1" != "vgriz" ] && [ "$1" != "regulogix" ] && [ "$1" != "familycabin" ] && [ "$1" != "all" ] && [ "$1" != "stop" ]; then
    echo "Usage: ./run-local.sh [vgriz|regulogix|familycabin|all|stop]"
    exit 1
fi

if [ "$1" != "stop" ]; then
    log "Local development servers started."
    echo ""
    echo "Sites are now available at:"
    [ "$1" = "vgriz" ] || [ "$1" = "all" ] && echo "- vGriz: http://localhost:3001"
    [ "$1" = "regulogix" ] || [ "$1" = "all" ] && echo "- Regulogix: http://localhost:3002"
    [ "$1" = "familycabin" ] || [ "$1" = "all" ] && echo "- Family Cabin: http://localhost:3003"
    echo ""
    echo "To stop the servers, run: ./run-local.sh stop"
fi
