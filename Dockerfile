# Use Ubuntu 22.04 as the base image
FROM ubuntu:jammy
MAINTAINER Onnet Solutions

# Set environment variables
ENV VERSION=17.0.20240313.001
ENV ODOO_HOME=/opt/soc/SoC-odoo-community-$VERSION
ENV CONFIG_HOME=/etc/soc/SoC-odoo-community-$VERSION/conf
ENV ODOO_RC=$CONFIG_HOME/odoo.conf

# Arguments for user and group IDs
ARG USER_ID=1001
ARG GROUP_ID=1001

# Create application and config directories
RUN mkdir -p $ODOO_HOME $CONFIG_HOME

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libsasl2-dev \
    libldap2-dev \
    libjpeg-dev \
    libpq-dev \
    libffi-dev \
    libjpeg8-dev \
    liblcms2-dev \
    libblas-dev \
    libatlas-base-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libxcb1-dev \
    wget \
    vim \
    nano \
    acl \
    python3-dev \
    libxml2-dev \ 
    libxslt1-dev \
    libssl-dev \ 
    python3-setuptools \
    python3-cffi \
    golang \
    python3-psycopg2 \
    python3-pip \
    fontconfig \
    libxext6 \
    libxrender1 \
    xfonts-75dpi \
    xfonts-base \
    npm \
    nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss
RUN npm install -g rtlcss

# Manually install libssl1.1
RUN wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
    && apt-get install -y ./libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
    && rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# Install wkhtmltopdf
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.focal_amd64.deb \
    && apt-get install -y ./wkhtmltox_0.12.5-1.focal_amd64.deb \
    && rm wkhtmltox_0.12.5-1.focal_amd64.deb

# Copy application code and configuration files
COPY src $ODOO_HOME
COPY odoo.conf $CONFIG_HOME
COPY entrypoint.sh /

# Make wkhtmltopdf accessible system-wide
RUN ln -s /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf \
    && ln -s /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage

# Create Odoo user and group
RUN groupadd -g ${GROUP_ID} odoo \
    && useradd -u ${USER_ID} -g odoo -m -s /bin/bash odoo

# Set ownership for the Odoo user
RUN chown -R odoo:odoo $CONFIG_HOME

# Switch to Odoo's working directory and user
WORKDIR $ODOO_HOME
USER odoo

# Install Python dependencies
RUN pip3 install --user -r $ODOO_HOME/requirements.txt

# Expose Odoo service ports
EXPOSE 8069 8072

# Set permissions for the entrypoint script and switch to root temporarily
USER root
RUN chmod +x /entrypoint.sh
RUN chown -R odoo:odoo /home/odoo

# Define the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Switch back to the Odoo user
USER odoo

