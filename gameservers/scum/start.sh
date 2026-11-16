#!/bin/bash
set -e

cd /game

# SCUM ships only a Windows dedicated-server binary, so bip-ops runs it under the
# distro Wine build (the default strategy -- no measured perf problem that would
# justify GE-Proton). The server is a headless UE4 console (-log), so .bip-ops.yaml
# sets usex: false. SCUM provides its own Steamworks redistributable, so none of the
# GE-Proton lsteamclient neutralisation is required here.

export WINEPREFIX="/game/.wine"
export WINEARCH="win64"
export WINEDEBUG="-all"
export SteamAppId=3792580

SERVER_EXE="/game/SCUM/Binaries/Win64/SCUMServer.exe"
CONFIG_DIR="/game/SCUM/Saved/Config/WindowsServer"
SETTINGS_INI="${CONFIG_DIR}/ServerSettings.ini"

# --- Non-destructive ServerSettings.ini overrides ---------------------------
# SCUM generates a ~437-key ServerSettings.ini on first boot and expects to own
# the file. We therefore never template or overwrite the whole thing (doing so on
# every restart would wipe the hundreds of keys we do not manage, plus any manual
# edits). Instead we upsert only the headline keys the operator set via env vars;
# the game backfills every key we leave out with its own defaults on load.
mkdir -p "${CONFIG_DIR}"

apply_setting() {
  # apply_setting <scum.Key> <value> -- no-op when value is empty
  local key="$1" value="$2"
  if [ -z "${value}" ]; then
    return 0
  fi
  touch "${SETTINGS_INI}"
  if grep -q "^${key}=" "${SETTINGS_INI}"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "${SETTINGS_INI}"
  else
    echo "${key}=${value}" >> "${SETTINGS_INI}"
  fi
}

apply_setting "scum.ServerName"        "${SCUM_SERVER_NAME}"
apply_setting "scum.ServerDescription" "${SCUM_SERVER_DESCRIPTION}"
apply_setting "scum.ServerPassword"    "${SCUM_SERVER_PASSWORD}"
apply_setting "scum.MaxPlayers"        "${SCUM_MAX_PLAYERS}"
apply_setting "scum.MaxPing"           "${SCUM_MAX_PING}"
apply_setting "scum.WelcomeMessage"    "${SCUM_WELCOME_MESSAGE}"

# --- Launch -----------------------------------------------------------------
# SCUM binds PORT, PORT+1 and PORT+2 (clients connect to PORT+2, the Steam query
# port). Expose the whole 7777-7779/udp range when mapping ports.
PORT="${SCUM_PORT:-7777}"
MAXPLAYERS="${SCUM_MAX_PLAYERS:-64}"

ARGS=( -log -port="${PORT}" -MaxPlayers="${MAXPLAYERS}" )
# Escape hatch for arbitrary extra flags (e.g. BattlEye toggles).
if [ -n "${SCUM_EXTRA_ARGS}" ]; then
  ARGS+=( ${SCUM_EXTRA_ARGS} )
fi

set -x
exec wine "${SERVER_EXE}" "${ARGS[@]}"
