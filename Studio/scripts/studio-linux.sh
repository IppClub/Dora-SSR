#!/usr/bin/env bash

set -euo pipefail

SERVICE_NAME=dora-studio
SERVICE_USER=dora-studio
INSTALL_ROOT=/opt/dora-studio
CONFIG_ROOT=/etc/dora-studio
DATA_ROOT=/var/lib/dora-studio
ENV_FILE="$CONFIG_ROOT/studio.env"
UNIT_FILE=/etc/systemd/system/dora-studio.service
SOURCE_PATH=${BASH_SOURCE[0]}
while [[ -L "$SOURCE_PATH" ]]; do
	SOURCE_DIR="$(cd "$(dirname "$SOURCE_PATH")" && pwd)"
	SOURCE_PATH="$(readlink "$SOURCE_PATH")"
	[[ "$SOURCE_PATH" == /* ]] || SOURCE_PATH="$SOURCE_DIR/$SOURCE_PATH"
done
SCRIPT_DIR="$(cd "$(dirname "$SOURCE_PATH")" && pwd)"
PACKAGE_ROOT="$SCRIPT_DIR"
if [[ ! -f "$PACKAGE_ROOT/manifest.env" && -f "$SCRIPT_DIR/../manifest.env" ]]; then
	PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

usage() {
	cat <<'EOF'
Usage: sudo ./studio-linux.sh <command>

Commands:
  install    Install this extracted package and register the systemd service
  check      Validate architecture, configuration, assets and file permissions
  start      Enable and start the service
  stop       Stop the service
  restart    Restart the service
  status     Show service status
  logs       Follow service logs
  enable     Enable service startup at boot
  disable    Disable service startup at boot
  uninstall  Stop/disable the service; preserve configuration and database
EOF
}

die() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
info() { printf '[INFO] %s\n' "$*"; }
require_root() { [[ ${EUID:-$(id -u)} -eq 0 ]] || die 'This command must run as root.'; }
require_systemd() { command -v systemctl >/dev/null 2>&1 || die 'systemd is required.'; }

manifest_value() {
	local key=$1 value
	[[ -f "$PACKAGE_ROOT/manifest.env" ]] || die "Package manifest is missing: $PACKAGE_ROOT/manifest.env"
	value="$(sed -n "s/^${key}=//p" "$PACKAGE_ROOT/manifest.env")"
	[[ -n "$value" && "$value" =~ ^[A-Za-z0-9._-]+$ ]] || die "Invalid package manifest value: $key"
	printf '%s' "$value"
}

machine_arch() {
	case "$(uname -m)" in
		x86_64|amd64) printf amd64 ;;
		aarch64|arm64) printf arm64 ;;
		*) die "Unsupported Linux architecture: $(uname -m)" ;;
	esac
}

check_package() {
	local expected actual
	expected="$(manifest_value ARCH)"
	actual="$(machine_arch)"
	[[ "$expected" == "$actual" ]] || die "Package architecture is $expected, host architecture is $actual."
	for path in bin/dora-studio-server web/index.html agent-support/manifest.json agent-engine/dora-web-features.json runtime/studio-runtime.json deployment/dora-studio.service deployment/studio.env.example; do
		[[ -f "$PACKAGE_ROOT/$path" ]] || die "Package file is missing: $path"
	done
	[[ -x "$PACKAGE_ROOT/bin/dora-studio-server" ]] || die 'Server binary is not executable.'
}

install_package() {
	require_root
	require_systemd
	check_package
	local version arch release stage generated
	version="$(manifest_value VERSION)"
	arch="$(manifest_value ARCH)"
	release="$INSTALL_ROOT/releases/$version-$arch"
	mkdir -p "$INSTALL_ROOT/releases" "$CONFIG_ROOT/tls" "$DATA_ROOT"
	if ! id "$SERVICE_USER" >/dev/null 2>&1; then
		useradd --system --home-dir "$DATA_ROOT" --shell /usr/sbin/nologin "$SERVICE_USER"
	fi
	if [[ ! -d "$release" ]]; then
		stage="$(mktemp -d "$INSTALL_ROOT/releases/.stage.XXXXXX")"
		trap 'rm -rf -- "$stage"' RETURN
		cp -a "$PACKAGE_ROOT/bin" "$PACKAGE_ROOT/web" "$PACKAGE_ROOT/agent-support" "$PACKAGE_ROOT/agent-engine" "$PACKAGE_ROOT/runtime" "$PACKAGE_ROOT/deployment" "$PACKAGE_ROOT/manifest.env" "$stage/"
		chmod 0755 "$stage/bin/dora-studio-server"
		mv "$stage" "$release"
		trap - RETURN
	elif ! cmp -s "$PACKAGE_ROOT/manifest.env" "$release/manifest.env"; then
		die "Release directory already exists with different contents: $release"
	fi
	ln -sfn "$release" "$INSTALL_ROOT/current.new"
	mv -Tf "$INSTALL_ROOT/current.new" "$INSTALL_ROOT/current"
	if [[ ! -f "$ENV_FILE" ]]; then
		cp "$PACKAGE_ROOT/deployment/studio.env.example" "$ENV_FILE"
		generated="$(openssl rand -base64 32 | tr -d '\n')"
		[[ -n "$generated" ]] || die 'Failed to generate STUDIO_SECRET_KEY.'
		sed -i "s|__GENERATE_ON_INSTALL__|$generated|" "$ENV_FILE"
		chmod 0600 "$ENV_FILE"
		info "Created $ENV_FILE; configure TLS files before starting."
	else
		info "Preserved existing $ENV_FILE."
	fi
	install -m 0644 "$PACKAGE_ROOT/deployment/dora-studio.service" "$UNIT_FILE"
	ln -sfn "$INSTALL_ROOT/current/bin/dora-studio-ops" /usr/local/sbin/dora-studio
	chown -R "$SERVICE_USER:$SERVICE_USER" "$DATA_ROOT"
	chown root:"$SERVICE_USER" "$CONFIG_ROOT" "$CONFIG_ROOT/tls"
	chmod 0750 "$CONFIG_ROOT" "$CONFIG_ROOT/tls" "$DATA_ROOT"
	systemctl daemon-reload
	info "Installed Dora Studio $version for $arch. Run '$0 check', then '$0 start'."
}

check_installation() {
	require_root
	require_systemd
	check_package
	[[ -L "$INSTALL_ROOT/current" ]] || die 'Dora Studio is not installed.'
	[[ -f "$ENV_FILE" ]] || die "Configuration is missing: $ENV_FILE"
	if grep -Eq '__[A-Z0-9_]+__|^STUDIO_SECRET_KEY=$' "$ENV_FILE"; then
		die "$ENV_FILE still contains an unset placeholder."
	fi
	set -a
	# The root-owned file is deliberately shell-compatible as well as systemd-compatible.
	# shellcheck source=/dev/null
	source "$ENV_FILE"
	set +a
	for name in STUDIO_WEB_DIR STUDIO_AGENT_SUPPORT_DIR STUDIO_AGENT_ENGINE_DIR STUDIO_RUNTIME_DIR STUDIO_DB_PATH STUDIO_SECRET_KEY STUDIO_TLS_CERT STUDIO_TLS_KEY STUDIO_PUBLIC_ORIGIN STUDIO_AGENT_HOST_ORIGIN; do
		[[ -n "${!name:-}" ]] || die "$name is not configured."
	done
	[[ "$STUDIO_PUBLIC_ORIGIN" == https://* && "$STUDIO_AGENT_HOST_ORIGIN" == https://* ]] || die 'Public origins must use HTTPS.'
	[[ -f "$STUDIO_WEB_DIR/index.html" && -f "$STUDIO_AGENT_SUPPORT_DIR/manifest.json" && -f "$STUDIO_AGENT_ENGINE_DIR/dora-web-features.json" && -f "$STUDIO_RUNTIME_DIR/studio-runtime.json" ]] || die 'Installed static assets are incomplete.'
	[[ -r "$STUDIO_TLS_CERT" && -r "$STUDIO_TLS_KEY" ]] || die 'TLS certificate or key is missing.'
	runuser -u "$SERVICE_USER" -- test -r "$STUDIO_TLS_CERT" || die 'Service account cannot read STUDIO_TLS_CERT.'
	runuser -u "$SERVICE_USER" -- test -r "$STUDIO_TLS_KEY" || die 'Service account cannot read STUDIO_TLS_KEY.'
	runuser -u "$SERVICE_USER" -- test -w "$(dirname "$STUDIO_DB_PATH")" || die 'Service account cannot write the database directory.'
	systemd-analyze verify "$UNIT_FILE" >/dev/null
	info 'Configuration, assets, permissions and systemd unit are valid.'
}

command=${1:-}
case "$command" in
	install) install_package ;;
	check) check_installation ;;
	start) require_root; check_installation; systemctl enable --now "$SERVICE_NAME" ;;
	stop) require_root; require_systemd; systemctl stop "$SERVICE_NAME" ;;
	restart) require_root; check_installation; systemctl restart "$SERVICE_NAME" ;;
	status) require_systemd; systemctl status "$SERVICE_NAME" --no-pager ;;
	logs) require_systemd; journalctl -u "$SERVICE_NAME" -n 200 -f ;;
	enable) require_root; require_systemd; systemctl enable "$SERVICE_NAME" ;;
	disable) require_root; require_systemd; systemctl disable "$SERVICE_NAME" ;;
	uninstall)
		require_root; require_systemd
		systemctl disable --now "$SERVICE_NAME" 2>/dev/null || true
		rm -f "$UNIT_FILE" "$INSTALL_ROOT/current" /usr/local/sbin/dora-studio
		systemctl daemon-reload
		info "Service removed. Releases, $ENV_FILE and $DATA_ROOT were preserved."
		;;
	-h|--help|help|'') usage ;;
	*) usage >&2; exit 2 ;;
esac
