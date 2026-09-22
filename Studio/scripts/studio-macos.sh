#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STUDIO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$STUDIO_DIR/.." && pwd)"
DEV_DIR="$STUDIO_DIR/.runtime/dev-server"
PACKAGE_DIR="$STUDIO_DIR/build/packages"

usage() {
	cat <<'EOF'
Usage:
  ./scripts/studio-macos.sh dev <start|stop|restart|rebuild|status|logs>
  ./scripts/studio-macos.sh package <amd64|arm64|aarch64|all> <public-host>

Examples:
  ./scripts/studio-macos.sh dev start
  ./scripts/studio-macos.sh dev rebuild
  ./scripts/studio-macos.sh package amd64 studio.example.com
  ./scripts/studio-macos.sh package all studio.example.com

Package origins default to:
  https://<public-host>:8899  Studio Web/API
  https://<public-host>:8900  isolated Agent Host
  https://<public-host>:8901  isolated game Player

Override them with STUDIO_PACKAGE_PUBLIC_ORIGIN,
STUDIO_PACKAGE_AGENT_HOST_ORIGIN and STUDIO_PACKAGE_RUNTIME_ORIGIN.
Set STUDIO_PACKAGE_REBUILD_ENGINES=1 to rebuild the two Web engines even when
validated local artifacts already exist.
EOF
}

die() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
info() { printf '[INFO] %s\n' "$*"; }
require() { command -v "$1" >/dev/null 2>&1 || die "Required command is unavailable: $1"; }

running() {
	local file=$1 pid
	[[ -f "$file" ]] || return 1
	pid="$(sed -n '1p' "$file")"
	[[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null
}

stop_pid() {
	local file=$1 label=$2 pid attempt
	if ! running "$file"; then
		rm -f "$file"
		return
	fi
	pid="$(sed -n '1p' "$file")"
	kill -TERM "$pid"
	attempt=0
	while [[ $attempt -lt 100 ]]; do
		kill -0 "$pid" 2>/dev/null || break
		sleep 0.1
		attempt=$((attempt + 1))
	done
	if kill -0 "$pid" 2>/dev/null; then
		info "$label did not stop after 10 seconds; terminating it."
		kill -KILL "$pid"
	fi
	rm -f "$file"
}

prepare_dev_config() {
	require openssl
	mkdir -p "$DEV_DIR"
	if [[ ! -s "$DEV_DIR/tls.key" || ! -s "$DEV_DIR/tls.crt" ]]; then
		openssl req -x509 -newkey rsa:2048 -nodes -days 30 \
			-keyout "$DEV_DIR/tls.key" -out "$DEV_DIR/tls.crt" \
			-subj '/CN=127.0.0.1' -addext 'subjectAltName=IP:127.0.0.1,DNS:localhost' >/dev/null 2>&1
		chmod 0600 "$DEV_DIR/tls.key"
	fi
	if [[ ! -s "$DEV_DIR/secret.base64" ]]; then
		openssl rand -base64 32 | tr -d '\n' > "$DEV_DIR/secret.base64"
		chmod 0600 "$DEV_DIR/secret.base64"
	fi
	if [[ ! -f "$DEV_DIR/studio.env" ]]; then
		printf '%s\n' \
			"STUDIO_API_HOST=127.0.0.1" \
			"STUDIO_API_PORT=8899" \
			"STUDIO_PUBLIC_ORIGIN=https://127.0.0.1:8898" \
			"STUDIO_DB_PATH=$DEV_DIR/studio.db" \
			"STUDIO_TLS_CERT=$DEV_DIR/tls.crt" \
			"STUDIO_TLS_KEY=$DEV_DIR/tls.key" > "$DEV_DIR/studio.env"
		chmod 0600 "$DEV_DIR/studio.env"
	fi
}

load_dev_config() {
	local runtime_dir
	prepare_dev_config
	set -a
	# This user-owned file allows local endpoint and port overrides.
	# shellcheck source=/dev/null
	source "$DEV_DIR/studio.env"
	STUDIO_SECRET_KEY="$(sed -n '1p' "$DEV_DIR/secret.base64")"
	STUDIO_API_URL="https://${STUDIO_API_HOST:-127.0.0.1}:${STUDIO_API_PORT:-8899}"
	if [[ -d "$ROOT_DIR/result/dora-studio-agent-engine" && -d "$STUDIO_DIR/dist/agent-host" ]]; then
		STUDIO_AGENT_HOST_ORIGIN="${STUDIO_AGENT_HOST_ORIGIN:-https://127.0.0.1:8900}"
		STUDIO_AGENT_ENGINE_DIR="${STUDIO_AGENT_ENGINE_DIR:-$ROOT_DIR/result/dora-studio-agent-engine}"
		STUDIO_AGENT_SUPPORT_DIR="${STUDIO_AGENT_SUPPORT_DIR:-$STUDIO_DIR/dist/agent-host}"
		VITE_STUDIO_AGENT_HOST_ORIGIN="$STUDIO_AGENT_HOST_ORIGIN"
	fi
	runtime_dir="${STUDIO_RUNTIME_DIR:-$ROOT_DIR/build/studio-runtime}"
	if [[ -d "$runtime_dir" ]]; then
		STUDIO_RUNTIME_DIR="$runtime_dir"
		VITE_DORA_RUNTIME_URL="${VITE_DORA_RUNTIME_URL:-https://127.0.0.1:8901/index.html}"
		VITE_DORA_ENGINE_BUILD="${VITE_DORA_ENGINE_BUILD:-$(node -e 'const f=JSON.parse(require("node:fs").readFileSync(process.argv[1],"utf8"));process.stdout.write(f.engineBuild||"")' "$STUDIO_RUNTIME_DIR/studio-runtime.json")}"
	fi
	STUDIO_AGENT_HOST_ORIGIN="${STUDIO_AGENT_HOST_ORIGIN:-}"
	STUDIO_AGENT_ENGINE_DIR="${STUDIO_AGENT_ENGINE_DIR:-}"
	STUDIO_AGENT_SUPPORT_DIR="${STUDIO_AGENT_SUPPORT_DIR:-}"
	STUDIO_RUNTIME_DIR="${STUDIO_RUNTIME_DIR:-}"
	VITE_STUDIO_AGENT_HOST_ORIGIN="${VITE_STUDIO_AGENT_HOST_ORIGIN:-}"
	VITE_DORA_RUNTIME_URL="${VITE_DORA_RUNTIME_URL:-}"
	VITE_DORA_ENGINE_BUILD="${VITE_DORA_ENGINE_BUILD:-}"
	export STUDIO_SECRET_KEY STUDIO_API_URL STUDIO_AGENT_HOST_ORIGIN STUDIO_AGENT_ENGINE_DIR STUDIO_AGENT_SUPPORT_DIR STUDIO_RUNTIME_DIR VITE_STUDIO_AGENT_HOST_ORIGIN VITE_DORA_RUNTIME_URL VITE_DORA_ENGINE_BUILD
	set +a
}

dev_start() {
	require go
	require pnpm
	if running "$DEV_DIR/server.pid" || running "$DEV_DIR/web.pid"; then
		die 'A local Studio development service is already running. Use dev status or dev restart.'
	fi
	# Local development must never silently reuse an incompatible Web engine.
	# Allow toolchain drift here for convenience; release packages remain strict.
	DORA_WEB_ALLOW_TOOLCHAIN_DRIFT="${DORA_WEB_ALLOW_TOOLCHAIN_DRIFT:-1}" prepare_engines
	load_dev_config
	info 'Building Studio workspace and Agent support files...'
	(cd "$STUDIO_DIR" && pnpm -r build && pnpm build:agent-host && go build -trimpath -o "$DEV_DIR/dora-studio-server" ./cmd/studio-server)
	(
		cd "$STUDIO_DIR"
		nohup "$DEV_DIR/dora-studio-server" </dev/null > "$DEV_DIR/server.log" 2>&1 &
		printf '%s\n' "$!" > "$DEV_DIR/server.pid"
	)
	(
		cd "$STUDIO_DIR/apps/web"
		nohup node node_modules/vite/bin/vite.js --host 127.0.0.1 </dev/null > "$DEV_DIR/web.log" 2>&1 &
		printf '%s\n' "$!" > "$DEV_DIR/web.pid"
	)
	sleep 2
	if ! running "$DEV_DIR/server.pid" || ! running "$DEV_DIR/web.pid"; then
		dev_stop || true
		tail -n 80 "$DEV_DIR/server.log" "$DEV_DIR/web.log" >&2 || true
		die 'Local Studio failed to start.'
	fi
	info 'Studio development server: https://127.0.0.1:8898/'
	info "Logs: $DEV_DIR/server.log and $DEV_DIR/web.log"
	info 'The generated certificate is self-signed; trust it only for local development.'
}

dev_stop() {
	stop_pid "$DEV_DIR/web.pid" 'Vite development server'
	stop_pid "$DEV_DIR/server.pid" 'Studio Go server'
	info 'Studio development services are stopped.'
}

dev_status() {
	local failed=0
	if running "$DEV_DIR/server.pid"; then info "Go server is running (PID $(sed -n '1p' "$DEV_DIR/server.pid"))."; else info 'Go server is stopped.'; failed=1; fi
	if running "$DEV_DIR/web.pid"; then info "Vite server is running (PID $(sed -n '1p' "$DEV_DIR/web.pid"))."; else info 'Vite server is stopped.'; failed=1; fi
	return "$failed"
}

dev_logs() {
	mkdir -p "$DEV_DIR"
	touch "$DEV_DIR/server.log" "$DEV_DIR/web.log"
	tail -n 100 -f "$DEV_DIR/server.log" "$DEV_DIR/web.log"
}

valid_runtime() {
	local directory=$1
	[[ -s "$directory/studio-runtime.json" && -s "$directory/dora-web-features.json" && -s "$directory/index.html" \
		&& -s "$directory/dora-player-runtime.js" && -s "$directory/dora-player-runtime.wasm" && -s "$directory/dora-player-runtime.data" ]] || return 1
	node -e 'const f=JSON.parse(require("node:fs").readFileSync(process.argv[1],"utf8"));if(f.profile!=="dora-preset"||!f.engineBuild)process.exit(1)' "$directory/studio-runtime.json"
	node -e 'const f=JSON.parse(require("node:fs").readFileSync(process.argv[1],"utf8"));if(f.activeProfile!=="dora-preset"||f.studioAgentHost!==false||f.modules?.threads!==true||f.modules?.crossOriginIsolationRequired!==true||f.modules?.musicGenerator!==true||f.modules?.rustBridge!==true)process.exit(1)' "$directory/dora-web-features.json"
	node -e 'const b=require("node:fs").readFileSync(process.argv[1]);if(!b.includes(Buffer.from("Audio.renderMusicAsync should be run in a thread")))process.exit(1)' "$directory/dora-player-runtime.wasm"
	node -e 'const s=require("node:fs").readFileSync(process.argv[1],"utf8"),m=s.match(/\/builtin\/Font\/sarasa-mono-sc-regular\.ttf.{0,64}?start:(\d+),end:(\d+)/s);if(s.includes("Streaming is only supported when FETCH_STREAMING is enabled")||!m||Number(m[2])-Number(m[1])<1_000_000)process.exit(1)' "$directory/dora-player-runtime.js"
}

valid_agent_engine() {
	local directory=$1
	[[ -s "$directory/dora-web-features.json" && -s "$directory/dora-player-runtime.js" && -s "$directory/dora-player-runtime.wasm" ]] || return 1
	node -e 'const f=JSON.parse(require("node:fs").readFileSync(process.argv[1],"utf8"));if(f.studioAgentHost!==true||f.activeProfile!=="dora-preset"||f.modules?.musicGenerator!==true||f.modules?.rustBridge!==true)process.exit(1)' "$directory/dora-web-features.json"
	node -e 'const b=require("node:fs").readFileSync(process.argv[1]);if(!b.includes(Buffer.from("Audio.renderMusicAsync should be run in a thread")))process.exit(1)' "$directory/dora-player-runtime.wasm"
	node -e 'const s=require("node:fs").readFileSync(process.argv[1],"utf8");if(s.includes("Streaming is only supported when FETCH_STREAMING is enabled"))process.exit(1)' "$directory/dora-player-runtime.js"
}

prepare_engines() {
	local agent_engine runtime source_player temporary
	agent_engine="${STUDIO_PACKAGE_AGENT_ENGINE_DIR:-$ROOT_DIR/result/dora-studio-agent-engine}"
	runtime="${STUDIO_PACKAGE_RUNTIME_DIR:-$ROOT_DIR/build/studio-runtime}"
	if [[ "${STUDIO_PACKAGE_REBUILD_ENGINES:-0}" == 1 ]] || ! valid_agent_engine "$agent_engine"; then
		info 'Building the dedicated Studio Agent Web engine...'
		(cd "$ROOT_DIR" && bash Tools/build-scripts/build_studio_agent_host.sh)
		agent_engine="$ROOT_DIR/result/dora-studio-agent-engine"
	fi
	if [[ "${STUDIO_PACKAGE_REBUILD_ENGINES:-0}" == 1 ]] || ! valid_runtime "$runtime"; then
		info 'Building the isolated pthread Studio Player with Agent music generation...'
		temporary="$(mktemp -d "$ROOT_DIR/build/studio-package-runtime.XXXXXX")"
		trap 'rm -rf -- "$temporary"' RETURN
		source_player="$temporary/player"
		(
			cd "$ROOT_DIR"
			DORA_WEB_BUILD_DIR="$ROOT_DIR/build/studio-runtime-engine" \
			DORA_WEB_PACKAGE_DIR="$temporary/probe" \
			DORA_WEB_PLAYER_PACKAGE_DIR="$source_player" \
			DORA_WEB_BUILTIN_FONT="$ROOT_DIR/Assets/Font/sarasa-mono-sc-regular.ttf" \
			DORA_WEB_BUILD_ENGINE=1 DORA_WEB_LINK_PLAYER=1 DORA_WEB_PTHREADS=1 \
			DORA_WEB_BUILD_LOVE_PROBE=0 DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER=0 \
			DORA_WEB_PROFILE=dora-preset DORA_WEB_FEATURE_YUE=OFF DORA_WEB_FEATURE_MUSIC=ON \
			DORA_WEB_FEATURE_PHYSICS_2D=ON DORA_WEB_FEATURE_ENTITY=ON DORA_WEB_FEATURE_PLATFORMER=ON \
			DORA_WEB_FEATURE_BUILTIN_LIBS=ON DORA_WEB_FEATURE_ML=ON DORA_WEB_FEATURE_LOVE=ON DORA_WEB_FEATURE_MODEL_3D=ON \
			bash Tools/build-scripts/build_web.sh
		)
		(cd "$STUDIO_DIR" && STUDIO_RUNTIME_DIR="$source_player" node apps/web/scripts/prepare-runtime.mjs)
		runtime="$ROOT_DIR/build/studio-runtime"
		rm -rf -- "$temporary"
		trap - RETURN
	fi
	valid_agent_engine "$agent_engine" || die 'Dedicated Agent engine is incomplete.'
	valid_runtime "$runtime" || die 'Studio game Player is incomplete.'
	STUDIO_PACKAGE_AGENT_ENGINE_DIR="$agent_engine"
	STUDIO_PACKAGE_RUNTIME_DIR="$runtime"
	export STUDIO_PACKAGE_AGENT_ENGINE_DIR STUDIO_PACKAGE_RUNTIME_DIR
}

package_one() {
	local arch=$1 revision short_version name stage output
	mkdir -p "$STUDIO_DIR/build"
	revision="$(git -C "$ROOT_DIR" rev-parse HEAD)"
	short_version="$STUDIO_PACKAGE_VERSION"
	name="dora-studio-${short_version}-linux-${arch}"
	stage="$(mktemp -d "$STUDIO_DIR/build/.package.XXXXXX")/$name"
	mkdir -p "$stage/bin" "$stage/deployment"
	info "Cross-compiling pure Go server for linux/$arch..."
	(cd "$STUDIO_DIR" && CGO_ENABLED=0 GOOS=linux GOARCH="$arch" go build -trimpath -ldflags='-s -w' -o "$stage/bin/dora-studio-server" ./cmd/studio-server)
	go version -m "$stage/bin/dora-studio-server" | grep -q 'GOOS=linux' || die 'Cross-compiled server is not a Linux binary.'
	go version -m "$stage/bin/dora-studio-server" | grep -q 'CGO_ENABLED=0' || die 'Cross-compiled server unexpectedly enables CGO.'
	cp -R "$STUDIO_DIR/apps/web/dist" "$stage/web"
	cp -R "$STUDIO_DIR/dist/agent-host" "$stage/agent-support"
	cp -R "$STUDIO_PACKAGE_AGENT_ENGINE_DIR" "$stage/agent-engine"
	cp -R "$STUDIO_PACKAGE_RUNTIME_DIR" "$stage/runtime"
	cp "$STUDIO_DIR/deployment/dora-studio.service" "$STUDIO_DIR/deployment/README.md" "$stage/deployment/"
	sed -e "s|__STUDIO_PUBLIC_ORIGIN__|$STUDIO_PACKAGE_PUBLIC_ORIGIN|" \
		-e "s|__STUDIO_AGENT_HOST_ORIGIN__|$STUDIO_PACKAGE_AGENT_HOST_ORIGIN|" \
		"$STUDIO_DIR/deployment/studio.env.example" > "$stage/deployment/studio.env.example"
	cp "$STUDIO_DIR/scripts/studio-linux.sh" "$stage/studio-linux.sh"
	cp "$STUDIO_DIR/scripts/studio-linux.sh" "$stage/bin/dora-studio-ops"
	chmod 0755 "$stage/bin/dora-studio-server" "$stage/bin/dora-studio-ops" "$stage/studio-linux.sh"
	printf 'VERSION=%s\nARCH=%s\nREVISION=%s\n' "$short_version" "$arch" "$revision" > "$stage/manifest.env"
	output="$PACKAGE_DIR/$name.tar.gz"
	mkdir -p "$PACKAGE_DIR"
	COPYFILE_DISABLE=1 tar -C "$(dirname "$stage")" -czf "$output" "$name"
	(cd "$PACKAGE_DIR" && shasum -a 256 "$(basename "$output")" > "$(basename "$output").sha256")
	rm -rf -- "$(dirname "$stage")"
	info "Package created: $output"
}

package_all() {
	local requested=$1 host=$2 public_origin agent_origin runtime_origin version_label engine_build
	require go; require node; require pnpm; require tar; require shasum
	[[ "$host" =~ ^[A-Za-z0-9.-]+$ ]] || die 'public-host must be a hostname or IP address without a scheme or port.'
	public_origin="${STUDIO_PACKAGE_PUBLIC_ORIGIN:-https://$host:8899}"
	agent_origin="${STUDIO_PACKAGE_AGENT_HOST_ORIGIN:-https://$host:8900}"
	runtime_origin="${STUDIO_PACKAGE_RUNTIME_ORIGIN:-https://$host:8901}"
	STUDIO_PACKAGE_PUBLIC_ORIGIN="$public_origin"
	STUDIO_PACKAGE_AGENT_HOST_ORIGIN="$agent_origin"
	STUDIO_PACKAGE_RUNTIME_ORIGIN="$runtime_origin"
	version_label="$(git -C "$ROOT_DIR" describe --tags --always | tr '/ ' '--')-$(git -C "$ROOT_DIR" rev-parse --short=12 HEAD)-$(date -u +%Y%m%dT%H%M%SZ)"
	STUDIO_PACKAGE_VERSION="${STUDIO_PACKAGE_VERSION:-$version_label}"
	[[ "$STUDIO_PACKAGE_VERSION" =~ ^[A-Za-z0-9._-]+$ ]] || die 'STUDIO_PACKAGE_VERSION contains unsupported characters.'
	export STUDIO_PACKAGE_PUBLIC_ORIGIN STUDIO_PACKAGE_AGENT_HOST_ORIGIN STUDIO_PACKAGE_RUNTIME_ORIGIN STUDIO_PACKAGE_VERSION
	for origin in "$public_origin" "$agent_origin" "$runtime_origin"; do
		node -e 'const s=process.argv[1],u=new URL(s);if(u.protocol!=="https:"||u.origin!==s||/[|\r\n]/.test(s))process.exit(1)' "$origin" || die "Invalid exact HTTPS origin: $origin"
	done
	prepare_engines
	engine_build="$(node -e 'const f=JSON.parse(require("node:fs").readFileSync(process.argv[1],"utf8"));if(!f.engineBuild)process.exit(1);process.stdout.write(f.engineBuild)' "$STUDIO_PACKAGE_RUNTIME_DIR/studio-runtime.json")"
	info 'Building Studio Web application and trusted Agent support...'
	(
		cd "$STUDIO_DIR"
		VITE_STUDIO_AGENT_HOST_ORIGIN="$agent_origin" VITE_DORA_RUNTIME_URL="$runtime_origin/index.html" VITE_DORA_ENGINE_BUILD="$engine_build" pnpm -r build
		pnpm build:agent-host
		go test ./...
	)
	case "$requested" in
		amd64) package_one amd64 ;;
		arm64|aarch64) package_one arm64 ;;
		all) package_one amd64; package_one arm64 ;;
		*) die "Unsupported target architecture: $requested" ;;
	esac
}

case ${1:-} in
	dev)
		case ${2:-} in
			start) dev_start ;;
			stop) dev_stop ;;
			restart) dev_stop; dev_start ;;
			rebuild) dev_stop; STUDIO_PACKAGE_REBUILD_ENGINES=1 dev_start ;;
			status) dev_status ;;
			logs) dev_logs ;;
			*) usage >&2; exit 2 ;;
		esac
		;;
	package)
		[[ $# -eq 3 ]] || { usage >&2; exit 2; }
		package_all "${2:-}" "${3:-}"
		;;
	-h|--help|help|'') usage ;;
	*) usage >&2; exit 2 ;;
esac
