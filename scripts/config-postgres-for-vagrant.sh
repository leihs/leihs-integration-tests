# run with `vagrant ssh -- sudo sh < ././scripts/config-postgres-for-vagrant.sh`

# from https://github.com/jackdb/pg-app-dev-vm/blob/f31fc94556bfdcc6aab97f1918fd95fdc6064a8a/Vagrant-setup/bootstrap.sh#L72-L82

export PG_VERSION=9.6
export PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
export PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
export PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

# Edit postgresql.conf to change listen address to '*':
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# Append to pg_hba.conf to add password auth:
echo "host    all             all             all                     md5" >> "$PG_HBA"

# Explicitly set default client_encoding
echo "client_encoding = utf8" >> "$PG_CONF"

# Restart so that all new config is loaded:
service postgresql restart

echo OK
