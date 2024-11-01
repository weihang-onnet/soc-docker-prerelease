#!/bin/bash

set -e

# Read the password from the file if PASSWORD_FILE is set
if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# Set the default values for database connection parameters
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}
: ${MASTER_PASSWORD:=${MASTER_ENV_POSTGRES_PASSWORD:=${MASTER_PASSWORD:='odoo'}}}
#: ${DB_NAME:=${DB_NAME:='odoo'}}
: ${ODOO_DATA_DIR:=${ODOO_DATA_DIR:='/home/odoo/.local/share/Odoo'}}
# Function to check and update the config file
function update_config() {
    param="$1"
    value="$2"
    # Escape special characters in the value for sed
    escaped_value=$(printf '%s\n' "$value" | sed 's/[&/\]/\\&/g')
    # Check if the parameter is commented or not present
    if grep -q -E "^\s*[;#]?\s*${param}\s*=" "$ODOO_RC" ; then
        # Uncomment and update the parameter
        sed -i "s|^\s*[;#]\?\s*${param}\s*=.*|${param} = ${escaped_value}|" "$ODOO_RC"
    else        
        # Append the parameter if it's not found
        echo "${param} = ${escaped_value}" >> "$ODOO_RC"
    fi
}
# Update the configuration file with the database parameters
update_config "db_host" "$HOST"
update_config "db_port" "$PORT"
update_config "db_user" "$USER"
update_config "db_password" "$PASSWORD"
update_config "admin_passwd" "$MASTER_PASSWORD"
update_config "data_dir" "$ODOO_DATA_DIR"
mkdir -p $ODOO_DATA_DIR
#chown -R odoo:odoo $ODOO_DATA_DIR
exec $ODOO_HOME/odoo-bin -c $ODOO_RC "$@"
