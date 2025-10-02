#!/command/with-contenv bash
set -e

cd /gameservers/$BIPOPS_GAMESERVER/

# Create custom configs from game's .bip-ops.yaml
yq -r '.configs // {} | to_entries[] | "\(.key)\t\(.value)"' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml" | while IFS=$'\t' read -r file out; do
  out_dir=$(dirname $out)
  mkdir -p $out_dir
  chown -R bipops:bipops $out_dir
  s6-setuidgid bipops gomplate --file $file --out $out
done

# Build the Backup configuration
export BIPOPS_BACKUP_DIRECTORY=$(yq -r '.backupdir' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml")
mkdir -p $BIPOPS_BACKUP_DIRECTORY
chown -R bipops:bipops $BIPOPS_BACKUP_DIRECTORY
gomplate --file /etc/s6-overlay/s6-rc.d/configure-game/configure.d/rsnapshot.conf --out /etc/rsnapshot.conf

# Validate backup configuration
rsnapshot configtest >/dev/null
