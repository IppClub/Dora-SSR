#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
prepare_display_env() {
	local xwayland_args
	local xauth

	if [ -z "${XDG_RUNTIME_DIR:-}" ] && [ -d "/run/user/$(id -u)" ]; then
		export XDG_RUNTIME_DIR="/run/user/$(id -u)"
	fi

	xwayland_args="$(ps -u "$(id -un)" -o args= 2>/dev/null | grep -m 1 'Xwayland :' || true)"
	if [ -n "$xwayland_args" ]; then
		if [ -z "${DISPLAY:-}" ]; then
			export DISPLAY="$(printf '%s\n' "$xwayland_args" | sed -n 's/.*Xwayland \(:[0-9][^ ]*\).*/\1/p')"
			[ -n "${DISPLAY:-}" ] && echo "Using Xwayland display: $DISPLAY"
		fi
		if [ -z "${XAUTHORITY:-}" ]; then
			xauth="$(printf '%s\n' "$xwayland_args" | sed -n 's/.* -auth \([^ ]*\).*/\1/p')"
			if [ -n "$xauth" ] && [ -r "$xauth" ]; then
				export XAUTHORITY="$xauth"
				echo "Using Xauthority: $XAUTHORITY"
			fi
		fi
	fi
}

prepare_display_env
exec "$SCRIPT_DIR/build_native.sh" linux run "$@"
