#!/command/with-contenv bash
set -e

cd /gameservers/$BIPOPS_GAMESERVER/

# Create custom configs from game's .bip-ops.yaml
# Paths are quoted throughout: Windows/Wine games save under AppData dirs whose
# company/product names contain spaces (e.g. "Channel 3 Entertainment"), and an
# unquoted expansion would mkdir the wrong dirs and break rsnapshot configtest.
yq -r '.configs // {} | to_entries[] | "\(.key)\t\(.value)"' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml" | while IFS=$'\t' read -r file out; do
  out_dir=$(dirname "$out")
  mkdir -p "$out_dir"
  chown -R bipops:bipops "$out_dir"
  s6-setuidgid bipops gomplate --file "$file" --out "$out"
done

# Build the Backup configuration
export BIPOPS_BACKUP_DIRECTORY=$(yq -r '.backupdir' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml")
mkdir -p "$BIPOPS_BACKUP_DIRECTORY"
chown -R bipops:bipops "$BIPOPS_BACKUP_DIRECTORY"
gomplate --file /etc/s6-overlay/s6-rc.d/configure-game/conf.d/rsnapshot.conf --out /etc/rsnapshot.conf

# Validate backup configuration
rsnapshot configtest >/dev/null
