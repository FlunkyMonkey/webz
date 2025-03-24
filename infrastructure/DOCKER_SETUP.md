# Docker Deployment Guide for vGriz Web Projects

This guide outlines how to deploy all three vGriz websites (vgriz.com, regulogix.com, and familycabin.io) using Docker and Docker Compose on a single Ubuntu 24.02 server.

## Prerequisites

- Ubuntu 24.02 LTS
- Docker and Docker Compose installed
- Domain names with DNS configured to point to your server

## Installation Steps

### 1. Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Install Docker and Docker Compose

```bash
# Install Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add your user to the docker group
sudo usermod -aG docker $USER
```

### 3. Configure Firewall

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

### 4. Clone the Repository

```bash
git clone https://github.com/yourusername/webz.git /var/www/webz
cd /var/www/webz
```

### 5. Prepare Nginx Configuration

Create the necessary directories for Nginx configuration:

```bash
mkdir -p infrastructure/nginx/conf.d
mkdir -p infrastructure/nginx/sites-enabled
mkdir -p infrastructure/certbot/conf
mkdir -p infrastructure/certbot/www
```

Create symbolic links for the Nginx site configurations:

```bash
cd /var/www/webz/infrastructure/nginx/sites-enabled
ln -s ../sites-available/vgriz.com.conf .
ln -s ../sites-available/regulogix.com.conf .
ln -s ../sites-available/familycabin.io.conf .
```

### 6. Create Dockerfiles for Each Website

Create a Dockerfile in each website directory:

For vgriz.com:
```bash
cat > /var/www/webz/vgriz/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 3001
CMD ["npm", "start"]
EOF
```

For regulogix.com:
```bash
cat > /var/www/webz/regulogix/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 3002
CMD ["npm", "start"]
EOF
```

For familycabin.io:
```bash
cat > /var/www/webz/familycabin/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 3003
CMD ["npm", "start"]
EOF
```

### 7. Initial SSL Setup

Before starting the containers, run this script to set up initial SSL certificates:

```bash
cat > /var/www/webz/infrastructure/init-letsencrypt.sh << 'EOF'
#!/bin/bash

domains=(vgriz.com www.vgriz.com regulogix.com www.regulogix.com familycabin.io www.familycabin.io)
email="your-email@example.com" # Change to your email
staging=0 # Set to 1 if you're testing your setup

data_path="./certbot"
rsa_key_size=4096
compose_file="docker-compose.yml"

if [ -d "$data_path/conf/live" ]; then
  read -p "Existing certificates found. Continue and replace them? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

mkdir -p "$data_path/conf/live"

echo "### Creating dummy certificates..."
for domain in "${domains[@]}"; do
  domain_path="$data_path/conf/live/$domain"
  mkdir -p "$domain_path"
  
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1 \
    -keyout "$domain_path/privkey.pem" \
    -out "$domain_path/fullchain.pem" \
    -subj "/CN=localhost"
done

echo "### Starting nginx..."
docker-compose up -d nginx

echo "### Requesting Let's Encrypt certificates..."
for domain in "${domains[@]}"; do
  echo "Getting certificate for $domain..."
  
  docker-compose run --rm --entrypoint "\
    certbot certonly --webroot -w /var/www/certbot \
      --email $email \
      -d $domain \
      --rsa-key-size $rsa_key_size \
      --agree-tos \
      --force-renewal \
      --non-interactive \
      $([ $staging -eq 1 ] && echo '--staging')" certbot
done

echo "### Reloading nginx..."
docker-compose exec nginx nginx -s reload
EOF

chmod +x /var/www/webz/infrastructure/init-letsencrypt.sh
cd /var/www/webz/infrastructure
./init-letsencrypt.sh
```

### 8. Start the Docker Containers

```bash
cd /var/www/webz/infrastructure
docker-compose up -d
```

### 9. Verify the Setup

Check if all containers are running:

```bash
docker-compose ps
```

Verify that all websites are accessible:
- https://vgriz.com
- https://regulogix.com
- https://familycabin.io

## Maintenance

### Updating the Websites

To update a specific website:

```bash
cd /var/www/webz
git pull

# Option 1: Using the deployment script
./shared/scripts/deploy.sh vgriz  # or regulogix or familycabin or all

# Option 2: Manually rebuilding with Docker Compose
cd infrastructure
docker-compose build vgriz  # or regulogix or familycabin
docker-compose up -d
```

### Viewing Logs

```bash
# View logs for all services
docker-compose logs

# View logs for a specific service
docker-compose logs nginx
docker-compose logs vgriz
```

### Restarting Services

```bash
# Restart all services
docker-compose restart

# Restart a specific service
docker-compose restart nginx
docker-compose restart vgriz
```

### Stopping All Services

```bash
docker-compose down
```

### Maintenance Tasks

You can use the maintenance script for common tasks:

```bash
cd /var/www/webz
./shared/scripts/maintenance.sh backup   # Create backups
./shared/scripts/maintenance.sh monitor  # Check system status
./shared/scripts/maintenance.sh cleanup  # Clean up old logs and backups
```

## Backup Strategy

Create a backup script:

```bash
cat > /var/www/webz/infrastructure/docker-backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/var/backups/webz-docker"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
WEBZ_DIR="/var/www/webz"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup Docker Compose configuration
tar -czf "$BACKUP_DIR/docker-config-$TIMESTAMP.tar.gz" -C "$WEBZ_DIR/infrastructure" .

# Backup SSL certificates
tar -czf "$BACKUP_DIR/ssl-certs-$TIMESTAMP.tar.gz" -C "$WEBZ_DIR/infrastructure" certbot

# Backup website code
tar -czf "$BACKUP_DIR/website-code-$TIMESTAMP.tar.gz" -C "$WEBZ_DIR" vgriz regulogix familycabin

echo "Backup completed: $BACKUP_DIR"
EOF

chmod +x /var/www/webz/infrastructure/docker-backup.sh
```

## Troubleshooting

### SSL Certificate Issues

If SSL certificates are not renewing properly:

```bash
docker-compose run --rm certbot certonly --webroot -w /var/www/certbot -d yourdomain.com
docker-compose exec nginx nginx -s reload
```

### Container Not Starting

Check the logs for the specific container:

```bash
docker-compose logs [container_name]
```

### Nginx Configuration Errors

Test the Nginx configuration:

```bash
docker-compose exec nginx nginx -t
``` 
