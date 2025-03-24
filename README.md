# vGriz Web Projects

A private repository for developing and deploying multiple web properties:
- [vgriz.com](https://vgriz.com)
- [regulogix.com](https://regulogix.com)
- [familycabin.io](https://familycabin.io)

## Overview

This repository contains the source code and deployment configurations for multiple web properties owned and managed by vGriz. The repository is structured to support efficient development, testing, and deployment workflows for each website.

## Projects

### vgriz.com
Personal website and portfolio.

### regulogix.com
Regulatory compliance platform.

### familycabin.io
Family management and vacation property platform.

## Development

### Prerequisites
- Node.js (version TBD)
- npm or yarn
- Additional dependencies as specified in each project directory

### Local Development
```bash
# Instructions for local development will be added as projects evolve
```

## Deployment

All three websites are deployed on a single Ubuntu 24.02 server using Nginx as a reverse proxy/load balancer. The infrastructure setup is designed to efficiently route traffic to the appropriate website based on the domain name.

### Infrastructure

The infrastructure configuration is located in the `infrastructure/` directory and includes:

- **Nginx Configuration**: Reverse proxy setup that routes traffic to the appropriate website based on domain name
- **Systemd Service Files**: For managing website services
- **Docker Setup**: Alternative containerized deployment option

### Deployment and Maintenance Scripts

Deployment and maintenance scripts are located in the `shared/scripts/` directory:

- **deploy.sh**: Script for deploying updates to one or all websites
- **maintenance.sh**: Script for performing maintenance tasks like backups and monitoring

For detailed deployment instructions, see:
- `infrastructure/SETUP.md` - Traditional server setup guide
- `infrastructure/DOCKER_SETUP.md` - Docker-based deployment guide

## Project Structure

```
/
├── vgriz/           # vgriz.com website files
│   ├── public/      # Static files for the website
│   ├── package.json # Node.js package configuration
│   └── server.js    # Express server for the website
├── regulogix/       # regulogix.com website files
│   ├── public/      # Static files for the website
│   ├── package.json # Node.js package configuration
│   └── server.js    # Express server for the website
├── familycabin/     # familycabin.io website files
│   ├── public/      # Static files for the website
│   ├── package.json # Node.js package configuration
│   └── server.js    # Express server for the website
├── shared/          # Shared components and utilities
│   ├── images/      # Shared images used across all sites
│   ├── styles.css   # Shared CSS styles
│   └── scripts/     # Shared scripts for deployment and maintenance
└── infrastructure/  # Deployment and infrastructure configuration
    ├── nginx/       # Nginx configuration files
    ├── systemd/     # Systemd service files
    ├── SETUP.md     # Traditional deployment guide
    └── DOCKER_SETUP.md # Docker deployment guide
```

## Contact

For questions or access requests, contact vGriz.

## License

This is a private repository. All rights reserved.

---

Last updated: March 23, 2025
