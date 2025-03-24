#!/bin/bash
# Deployment script for vGriz Web Projects
# Usage: ./deploy.sh [vgriz|regulogix|familycabin|all]

set -e

# Configuration
REPO_DIR="/var/www/webz"
LOG_FILE="/var/log/webz-deploy.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to deploy a specific site
deploy_site() {
    site=$1
    log "Deploying $site..."
    
    # Navigate to site directory
    cd "$REPO_DIR/$site"
    
    # Pull latest changes
    log "Pulling latest changes for $site..."
    git pull
    
    # Install dependencies
    log "Installing dependencies for $site..."
    npm install
    
    # Build the site
    log "Building $site..."
    npm run build
    
    # Restart the service
    log "Restarting $site service..."
    sudo systemctl restart "$site.service"
    
    log "$site deployment completed successfully."
}

# Create log file if it doesn't exist
touch "$LOG_FILE"

# Main deployment logic
if [ "$1" = "vgriz" ] || [ "$1" = "all" ]; then
    deploy_site "vgriz"
fi

if [ "$1" = "regulogix" ] || [ "$1" = "all" ]; then
    deploy_site "regulogix"
fi

if [ "$1" = "familycabin" ] || [ "$1" = "all" ]; then
    deploy_site "familycabin"
fi

# If no valid argument is provided
if [ "$1" != "vgriz" ] && [ "$1" != "regulogix" ] && [ "$1" != "familycabin" ] && [ "$1" != "all" ]; then
    echo "Usage: ./deploy.sh [vgriz|regulogix|familycabin|all]"
    exit 1
fi

log "All deployments completed successfully."
