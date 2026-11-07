#!/usr/bin/env bash
# verify-gameserver.sh - readiness gate for a bip-ops game server.
#
# Boots the bipops image with BIPOPS_GAMESERVER=<name> and waits for the server
# to come up and bind a listening socket. This only proves the server starts,
# downloads, and binds a port - it does NOT play the game (that needs a real
# client login), which is out of scope for an automated gate.
#
#   PASS (exit 0): a listening socket appeared while the container stayed up.
#   FAIL (exit 1): the container exited, or the timeout elapsed with no socket.
#                  The game and init log tails are printed for troubleshooting.
#
# Usage:
#   scripts/verify-gameserver.sh <gameserver> [options]
#
# Options:
#   --port N          Require this specific UDP/TCP port to be listening.
#                     Without it, any listening port >= 1024 counts (noisier).
#   --image IMG       Image to boot (default: justmiles/bipops:latest).
#   --timeout SEC     Max seconds to wait (default: 1200 - SteamCMD can be slow).
#   --runtime CMD     Container runtime: docker or podman (default: docker).
#   --volume NAME     Reuse a named volume for /game (skips re-download on reruns).
#                     Without it, an ephemeral volume is created and removed.
#   --env K=V         Extra environment variable for the container (repeatable).
#   --keep            Do not remove the container/volume on exit (for debugging).
#   -h, --help        Show this help.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

game=""
port=""
image="justmiles/bipops:latest"
timeout=1200
runtime="docker"
volume=""
keep=false
env_args=()

die() {
	echo "error: $*" >&2
	exit 2
}

usage() {
	sed -n '2,38p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
	exit "${1:-0}"
}

while [ $# -gt 0 ]; do
	case "$1" in
	--port)
		port="${2:-}"
		shift 2
		;;
	--image)
		image="${2:-}"
		shift 2
		;;
	--timeout)
		timeout="${2:-}"
		shift 2
		;;
	--runtime)
		runtime="${2:-}"
		shift 2
		;;
	--volume)
		volume="${2:-}"
		shift 2
		;;
	--env)
		env_args+=(-e "${2:-}")
		shift 2
		;;
	--keep)
		keep=true
		shift
		;;
	-h | --help) usage 0 ;;
	-*) die "unknown option: $1" ;;
	*)
		[ -z "$game" ] || die "unexpected argument: $1"
		game="$1"
		shift
		;;
	esac
done

[ -n "$game" ] || usage 1
command -v "$runtime" >/dev/null 2>&1 || die "runtime not found: $runtime"
[ -f "$REPO_ROOT/gameservers/$game/.bip-ops.yaml" ] ||
	die "no such game server: gameservers/$game/.bip-ops.yaml not found"

# Informational: display name and whether it needs X (from the game's config).
display="$game"
usex="unknown"
if command -v yq >/dev/null 2>&1; then
	display="$(yq -r '.game // "'"$game"'"' "$REPO_ROOT/gameservers/$game/.bip-ops.yaml")"
	usex="$(yq -r '.usex // "false"' "$REPO_ROOT/gameservers/$game/.bip-ops.yaml")"
fi

# Unique names so parallel runs do not collide.
suffix="$$"
cname="bipops-verify-${game}-${suffix}"
owns_volume=false
if [ -z "$volume" ]; then
	volume="bipops-verify-${game}-${suffix}"
	owns_volume=true
fi

cleanup() {
	if [ "$keep" = true ]; then
		echo "--keep set: leaving container '$cname' and volume '$volume' in place."
		return
	fi
	"$runtime" rm -f "$cname" >/dev/null 2>&1 || true
	if [ "$owns_volume" = true ]; then
		"$runtime" volume rm "$volume" >/dev/null 2>&1 || true
	fi
}
trap cleanup EXIT

# Listening ports inside the container, read tool-free from /proc/net.
# TCP LISTEN sockets have st==0A; bound (unconnected) UDP sockets have st==07.
# Port is the hex suffix of the local_address column; convert to decimal.
listening_ports() {
	local tcp udp hexes h
	tcp="$("$runtime" exec "$cname" sh -c 'cat /proc/net/tcp /proc/net/tcp6 2>/dev/null' 2>/dev/null || true)"
	udp="$("$runtime" exec "$cname" sh -c 'cat /proc/net/udp /proc/net/udp6 2>/dev/null' 2>/dev/null || true)"
	hexes="$(
		{
			printf '%s\n' "$tcp" | awk '$4=="0A"{split($2,a,":"); print a[2]}'
			printf '%s\n' "$udp" | awk '$4=="07"{split($2,a,":"); print a[2]}'
		} | sort -u
	)"
	for h in $hexes; do
		[ -n "$h" ] && printf '%d\n' "0x$h"
	done | sort -un
}

dump_logs() {
	echo "----- init log (last 40 lines) -----"
	"$runtime" exec "$cname" sh -c 'tail -n 40 /var/log/init/* 2>/dev/null' 2>/dev/null ||
		echo "(init log unavailable)"
	echo "----- game log (last 60 lines) -----"
	"$runtime" exec "$cname" sh -c 'tail -n 60 /var/log/gameserver/* 2>/dev/null' 2>/dev/null ||
		echo "(game log unavailable - container may have exited)"
	echo "----- container logs (last 40 lines) -----"
	"$runtime" logs --tail 40 "$cname" 2>&1 || true
}

echo "Verifying '$display' ($game)"
echo "  image:   $image"
echo "  usex:    $usex"
echo "  timeout: ${timeout}s"
[ -n "$port" ] && echo "  port:    $port (required)" || echo "  port:    any >= 1024"
echo "  volume:  $volume$([ "$owns_volume" = true ] && echo ' (ephemeral)')"
echo

"$runtime" rm -f "$cname" >/dev/null 2>&1 || true
"$runtime" run -d --name "$cname" \
	-e BIPOPS_GAMESERVER="$game" \
	"${env_args[@]}" \
	-v "$volume:/game" \
	"$image" >/dev/null

echo "Container started; waiting for a listening socket..."
deadline=$(($(date +%s) + timeout))
last_note=0
while :; do
	now="$(date +%s)"
	if [ "$now" -ge "$deadline" ]; then
		echo
		echo "FAIL: timed out after ${timeout}s with no listening socket."
		dump_logs
		exit 1
	fi

	state="$("$runtime" inspect -f '{{.State.Status}}' "$cname" 2>/dev/null || echo missing)"
	if [ "$state" != "running" ]; then
		code="$("$runtime" inspect -f '{{.State.ExitCode}}' "$cname" 2>/dev/null || echo '?')"
		echo
		echo "FAIL: container is '$state' (exit code $code) before binding a port."
		dump_logs
		exit 1
	fi

	ports="$(listening_ports || true)"
	if [ -n "$port" ]; then
		if printf '%s\n' "$ports" | grep -qx "$port"; then
			echo
			echo "PASS: '$game' is listening on port $port."
			echo "Listening ports: $(printf '%s' "$ports" | tr '\n' ' ')"
			exit 0
		fi
	else
		hi="$(printf '%s\n' "$ports" | awk '$1>=1024' | head -1 || true)"
		if [ -n "$hi" ]; then
			echo
			echo "PASS: '$game' bound a listening socket."
			echo "Listening ports: $(printf '%s' "$ports" | tr '\n' ' ')"
			exit 0
		fi
	fi

	# Progress heartbeat every ~30s.
	if [ $((now - last_note)) -ge 30 ]; then
		echo "  ...still waiting (${port:+port $port, }$((deadline - now))s left)"
		last_note="$now"
	fi
	sleep 5
done
