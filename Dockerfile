# Use an official Python runtime as a parent image
#FROM python:3.8-slim
FROM ubuntu:22.04

# Set environment variables
ENV VERSION=17.0.20240313
ENV ODOO_HOME=/opt/soc/SoC-odoo-community-$VERSION
ENV CONFIG_HOME=/etc/soc/SoC-odoo-community-$VERSION/conf
ARG GROUP_ID=1001
ARG USER_ID=1001
# Create application and config directories
RUN mkdir -p $ODOO_HOME
RUN mkdir -p $CONFIG_HOME

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    libxml2-dev \
    libxslt1-dev \
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
    acl \
    python3-setuptools \
    python3-cffi \
    golang \
    python3-psycopg2 \
    fontconfig \
    libxext6 \
    libxrender1 \
    xfonts-75dpi \
    xfonts-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Manually install libssl1.1 from a specific source
RUN wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
    && apt-get install -y ./libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
    && rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb

RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.focal_amd64.deb \
    && apt-get install -y ./wkhtmltox_0.12.5-1.focal_amd64.deb \
    && rm wkhtmltox_0.12.5-1.focal_amd64.deb

# Copy application code and configuration files
COPY /SoC-odoo-community-$VERSION $ODOO_HOME
COPY /odoo.conf $CONFIG_HOME
# Copy entrypoint script and Odoo configuration file
COPY /entrypoint.sh /

# Make wkhtmltopdf and wkhtmltoimage accessible system-wide
RUN ln -s /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf \
    && ln -s /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage


RUN groupadd -g ${GROUP_ID} odoo
RUN useradd -u ${USER_ID} -g odoo -m -s /bin/bash odoo

#RUN useradd -ms /bin/bash odoo
RUN chown -R odoo $CONFIG_HOME
# Set the working directory
WORKDIR $ODOO_HOME
USER odoo
# Install Python dependencies
RUN pip3 install --user -r /opt/soc/SoC-odoo-community-$VERSION/requirements.txt 
USER root
# Expose Odoo service port
EXPOSE 8069 8072

# Set the default config file
ENV ODOO_RC=/etc/soc/SoC-odoo-community-$VERSION/conf/odoo.conf
RUN chmod +x /entrypoint.sh
#RUN /bin/bash -c '/entrypoint.sh'
ENTRYPOINT ["/entrypoint.sh"]
RUN chown -R odoo:odoo /home/odoo
USER odoo
#CMD ["-c","/etc/ofoo/conf/ofoo-17.1.0-horizon-alpha.conf"]
