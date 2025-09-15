#!/command/with-contenv bash

set -ex

if [  -f "/gameservers/$GAMESERVER/.gomplate.yaml" ]; then
  cd /gameservers/$GAMESERVER/
  gomplate --verbose --config .gomplate.yaml
fi

set +x