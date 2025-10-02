#!/command/with-contenv bash
set -e

# Set bipops UID/GID
[ ! -z "${BIPOPS_UID}" ] && usermod -u $BIPOPS_UID bipops > /dev/null
[ ! -z "${BIPOPS_GID}" ] && groupmod -g $BIPOPS_GID bipops > /dev/null

mkdir -p /game /backups /config

chown -R bipops:bipops /game /backups /config /gameservers