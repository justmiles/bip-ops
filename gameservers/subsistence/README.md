## Example

```
docker run --rm -it --name bip-ops \
  -e GAMESERVER=subsistence \
  -e SUBSISTENCE_SERVER_NAME="BipOps Subsistence Server" \
  -e SUBSISTENCE_PASSWORD=brapples \
  -e SUBSISTENCE_HUNTERS_ENABLED=false \
  -e SUBSISTENCE_PROFILE_ID=2 \
  -p 7756:7756 \
  -p 7777:7777/udp \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -v $PWD/games/subsistencev2:/game \
  -v $PWD/games/subsistencev2-backups:/backups \
  justmiles/bip-ops
```
