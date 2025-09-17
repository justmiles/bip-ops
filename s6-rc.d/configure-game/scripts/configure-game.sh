#!/command/with-contenv bash

set -e
cd /gameservers/$BIPOPS_GAMESERVER/
yq -r '.configs // {} | to_entries[] | "\(.key)\t\(.value)"' "/gameservers/$BIPOPS_GAMESERVER/.bip-ops.yaml" | while IFS=$'\t' read -r file out; do
  out_dir=$(dirname $out)
  mkdir -p $out_dir
  chown -R bipops:bipops $out_dir
  s6-setuidgid bipops gomplate --file $file --out $out
done
