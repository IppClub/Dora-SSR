#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

export DORA_WEB_STUDIO_AGENT_HOST=1
export DORA_WEB_BUILD_ENGINE=1
export DORA_WEB_LINK_PLAYER=1
export DORA_WEB_BUILD_LOVE_PROBE=0
export DORA_WEB_BUILD_LOVE_PTHREAD_PLAYER=0
export DORA_WEB_PTHREADS=0
export DORA_WEB_PROFILE=dora-preset
export DORA_WEB_BUILD_DIR="$ROOT_DIR/build/studio-agent-host"
export DORA_WEB_PACKAGE_DIR="$ROOT_DIR/result/dora-studio-agent-build-probe"
export DORA_WEB_PLAYER_PACKAGE_DIR="$ROOT_DIR/result/dora-studio-agent-engine"

"$SCRIPT_DIR/build_web.sh"

node - "$DORA_WEB_PLAYER_PACKAGE_DIR" <<'NODE'
const {readFileSync,statSync}=require('node:fs');
const {join}=require('node:path');
const directory=process.argv[2];
const features=JSON.parse(readFileSync(join(directory,'dora-web-features.json'),'utf8'));
if(features.studioAgentHost!==true || features.activeProfile!=='dora-preset')throw new Error('Dedicated Studio Agent engine feature manifest is invalid');
for(const file of ['dora-player-runtime.js','dora-player-runtime.wasm','dora-player-runtime.data'])if(statSync(join(directory,file)).size===0)throw new Error(`Missing dedicated Agent engine asset: ${file}`);
if(!readFileSync(join(directory,'dora-player-runtime.js'),'utf8').includes('_dora_web_agent_request'))throw new Error('Dedicated Agent snapshot callback was not exported');
process.stdout.write(`Validated dedicated Studio Agent engine: ${directory}\n`);
NODE
