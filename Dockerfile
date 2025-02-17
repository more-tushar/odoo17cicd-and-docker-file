# FROM python:3.10
FROM python:3.10-bullseye

# Set environment variables
ENV ODOO_VERSION=17 \
    ODOO_USER=odoo \
    ODOO_HOME=/odoo \
    ODOO_CONF=/etc/odoo/odoo.conf \
    ODOO_CUSTOM_ADDONS=/mnt/extra-addons

# Install required system dependencies
RUN apt-get update && apt-get install -y wget \
    xfonts-75dpi xfonts-base fontconfig \
    python3-dev libpq-dev libxml2-dev libxslt1-dev \
    libldap2-dev libsasl2-dev libjpeg-dev libffi-dev \
    build-essential python3-pip python3-setuptools python3-wheel cython3 \
    python3-gevent libssl1.1 \
    && wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb \
    && apt-get install -y ./wkhtmltox_0.12.6-1.buster_amd64.deb \
    && rm -rf wkhtmltox_0.12.6-1.buster_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

# Create the odoo user
RUN useradd -m -d /var/lib/odoo -U -r -s /bin/bash odoo

# Set permissions for the odoo user
RUN mkdir -p /var/lib/odoo/.local/share/Odoo/filestore/prod-odoo \
    && chown -R odoo:odoo /var/lib/odoo/.local/share/Odoo/filestore


RUN pip install --no-cache-dir pyjwt
# Upgrade pip, setuptools, and wheel
RUN pip install --upgrade pip setuptools wheel Cython \
    && pip install "gevent==22.10.2"

WORKDIR /odoo
COPY . /odoo

RUN pip install --no-cache-dir -r requirements.txt


RUN mkdir -p /etc/odoo

# Create odoo.conf file
RUN echo "[options] \n\
db_host = postgres-db \n\
db_port = 5432 \n\
db_user = odoo \n\
db_password = odoo \n\
db_name = prod-odoo \n\
addons_path = odoo/addons \n\ 
session_gc = 3600 \n\
session_cookie_lifetime = 86400 \n\   
proxy_mode = True \n\  
db_maxconn = 64 \n\
admin_passwd = odoo123" > $ODOO_CONF

EXPOSE 8069 8072

CMD ["python", "-m", "odoo" , "--config=/etc/odoo/odoo.conf"]
