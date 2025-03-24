#!/bin/bash
# Maintenance script for vGriz Web Projects
# Usage: ./maintenance.sh [backup|monitor|cleanup]

set -e

# Configuration
REPO_DIR="/var/www/webz"
BACKUP_DIR="/var/backups/webz"
LOG_FILE="/var/log/webz-maintenance.log"
RETENTION_DAYS=30

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Create log file if it doesn't exist
touch "$LOG_FILE"

# Function to create backups
backup() {
    log "Starting backup process..."
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Create timestamp for backup
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    
    # Backup website files
    log "Backing up website files..."
    tar -czf "$BACKUP_DIR/webz_files_$TIMESTAMP.tar.gz" -C "$(dirname $REPO_DIR)" "$(basename $REPO_DIR)"
    
    # Backup Nginx configuration
    log "Backing up Nginx configuration..."
    sudo tar -czf "$BACKUP_DIR/nginx_config_$TIMESTAMP.tar.gz" -C "/etc" "nginx"
    
    # Backup SSL certificates
    log "Backing up SSL certificates..."
    sudo tar -czf "$BACKUP_DIR/letsencrypt_$TIMESTAMP.tar.gz" -C "/etc" "letsencrypt"
    
    # Set proper permissions
    sudo chown $(whoami) "$BACKUP_DIR"/*.tar.gz
    
    log "Backup completed: $BACKUP_DIR/webz_files_$TIMESTAMP.tar.gz"
}

# Function to monitor system
monitor() {
    log "Starting system monitoring..."
    
    # Check disk space
    log "Disk space usage:"
    df -h | grep -v "tmpfs" | tee -a "$LOG_FILE"
    
    # Check memory usage
    log "Memory usage:"
    free -h | tee -a "$LOG_FILE"
    
    # Check CPU load
    log "CPU load:"
    uptime | tee -a "$LOG_FILE"
    
    # Check Nginx status
    log "Nginx status:"
    sudo systemctl status nginx | head -n 3 | tee -a "$LOG_FILE"
    
    # Check website services
    for service in vgriz regulogix familycabin; do
        log "$service service status:"
        sudo systemctl status $service.service | head -n 3 | tee -a "$LOG_FILE"
    done
    
    # Check for failed systemd services
    log "Failed systemd services:"
    sudo systemctl --failed | tee -a "$LOG_FILE"
    
    log "Monitoring completed."
}

# Function to clean up old backups and logs
cleanup() {
    log "Starting cleanup process..."
    
    # Remove backups older than retention period
    log "Removing backups older than $RETENTION_DAYS days..."
    find "$BACKUP_DIR" -name "*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete
    
    # Clean up log files
    log "Cleaning up log files..."
    sudo find /var/log -name "*.gz" -type f -mtime +$RETENTION_DAYS -delete
    
    # Clean up Nginx logs
    log "Cleaning up Nginx logs..."
    sudo find /var/log/nginx -name "*.gz" -type f -mtime +$RETENTION_DAYS -delete
    
    log "Cleanup completed."
}

# Main logic
case "$1" in
    backup)
        backup
        ;;
    monitor)
        monitor
        ;;
    cleanup)
        cleanup
        ;;
    *)
        echo "Usage: ./maintenance.sh [backup|monitor|cleanup]"
        exit 1
        ;;
esac

log "Maintenance script completed successfully."
