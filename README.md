[![Build Status](Odoo 17 Production Setup)]

Overview
--------
This project contains the production setup for Odoo 17, including Docker, Jenkins, and configuration files for 
seamless deployment.

Directory Structure
-------------------

├── docker-compose.yml       # Docker Compose file to manage containers  
├── Dockerfile               # Dockerfile for Odoo 17 production image  
├── Dockerfile-postgres      # Dockerfile for PostgreSQL database  
├── Jenkinsfile              # Jenkins pipeline for deployment  
├── odoo/                    # Odoo source code  
├── requirements.txt         # Python dependencies  
├── setup/                   # Setup scripts and configurations  
├── README.md                # This file  

Prerequisites
-------------
1)Before deploying, ensure the following:
2)Docker & Docker Compose are installed
3)Jenkins is configured for deployment
4)Nexus repository is set up for storing images

Troubleshooting
---------------
If errors occur, check the logs:
1)docker logs odoo-prod

Common issues and solutions:
---------------------------------
Network Mismatch: Ensure both containers are connected to the same network.

1)docker inspect postgres-db | grep Network
2)docker inspect odoo-prod | grep Network

If they are different, connect PostgreSQL to the correct network:

docker network connect odoo-network postgres-db
Database Connection Issues: Verify that PostgreSQL is running and accessible.

Jenkins Pipeline
------------------
Modify Jenkinsfile to fit your deployment requirements. Ensure it correctly builds and deploys the images from the Nexus repository.

Docker-Compose
----------------
Update docker-compose.yml to match your configuration:

services:
  odoo-prod:
    image: 3.110.136.88:8085/repository/odoo17-main/odoo17-odoo-prod:latest

  postgres-db:
    image: 3.110.136.88:8085/repository/odoo17-main/postgres:15
	
Modify the image names as per your Nexus repository.
Ensure the correct domain is used in the Nexus repo URL.

Notes
------
Update the Jenkinsfile as per your setup.
Verify network settings to prevent connectivity issues.
Modify Nexus repository details in the Dockerfile if necessary.
