# Infrastructure Setup Guide for vGriz Web Projects

This guide outlines the setup process for hosting all three vGriz websites (vgriz.com, regulogix.com, and familycabin.io) on a single Ubuntu 24.02 server using Nginx as a reverse proxy/load balancer.

## System Requirements

- Ubuntu 24.02 LTS
- 4GB RAM minimum (8GB recommended)
- 2 CPU cores minimum
- 20GB storage minimum
- Public IP address
- Domain names with DNS configured to point to your server

## Installation Steps

### 1. Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Install Required Packages

```bash
sudo apt install -y nginx certbot python3-certbot-nginx ufw
```

### 3. Configure Firewall

```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw enable
```

### 4. Install Website Dependencies

Depending on your chosen technology stack, install the necessary dependencies. This guide assumes Node.js for all sites, but you can adapt as needed.

```bash
# Install Node.js and npm
sudo apt install -y nodejs npm

# Install PM2 for process management
sudo npm install -g pm2
```

### 5. Deploy Website Code

Clone the repository and set up each website:

```bash
# Clone the repository
git clone https://github.com/yourusername/webz.git /var/www/webz

# Set up each website (example for Node.js applications)
cd /var/www/webz/vgriz
npm install
npm run build

cd /var/www/webz/regulogix
npm install
npm run build

cd /var/www/webz/familycabin
npm install
npm run build
```

### 6. Configure Nginx

Copy the Nginx configuration files from this directory to the server:

```bash
sudo cp /var/www/webz/infrastructure/nginx/sites-available/* /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/vgriz.com.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/regulogix.com.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/familycabin.io.conf /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
```

### 7. Set Up SSL Certificates

```bash
sudo certbot --nginx -d vgriz.com -d www.vgriz.com
sudo certbot --nginx -d regulogix.com -d www.regulogix.com
sudo certbot --nginx -d familycabin.io -d www.familycabin.io
```

### 8. Start Website Services

Use the provided systemd service files to manage the website services:

```bash
sudo cp /var/www/webz/infrastructure/systemd/* /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable vgriz.service regulogix.service familycabin.service
sudo systemctl start vgriz.service regulogix.service familycabin.service
```

### 9. Test the Setup

Verify that all websites are accessible:
- https://vgriz.com
- https://regulogix.com
- https://familycabin.io

## Maintenance

### Restarting Services

```bash
sudo systemctl restart vgriz.service
sudo systemctl restart regulogix.service
sudo systemctl restart familycabin.service
```

### Updating Nginx Configuration

```bash
sudo nginx -t  # Test configuration
sudo systemctl reload nginx  # Apply changes
```

### SSL Certificate Renewal

Certbot creates a timer that will automatically renew certificates. You can manually trigger renewal with:

```bash
sudo certbot renew
```

## Monitoring

Set up basic monitoring using PM2:

```bash
pm2 monit
```

For more advanced monitoring, consider setting up Prometheus and Grafana.

## Backup Strategy

1. Database backups (if applicable):
   ```bash
   # Example for PostgreSQL
   pg_dump -U username database_name > backup.sql
   ```

2. File backups:
   ```bash
   # Example using rsync
   rsync -avz /var/www/webz /path/to/backup/location
   ```

3. Consider setting up automated backups using cron jobs.

## Troubleshooting

- Check Nginx logs: `/var/log/nginx/error.log`
- Check application logs: `pm2 logs`
- Verify Nginx configuration: `sudo nginx -t`
- Check service status: `sudo systemctl status vgriz.service`
