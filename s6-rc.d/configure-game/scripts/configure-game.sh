#!/command/with-contenv bash

set -e
cd /gameservers/$GAMESERVER/
yq -r '.configs // {} | to_entries[] | "\(.key)\t\(.value)"' "/gameservers/$GAMESERVER/.bip-ops.yaml" | while IFS=$'\t' read -r file out; do
  out_dir=$(dirname $out)
  mkdir -p $out_dir
  gomplate --file $file --out $out
done
