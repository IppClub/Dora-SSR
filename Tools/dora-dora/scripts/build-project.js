const path = require("path");
const { spawnSync } = require("child_process");

const doraDoraDir = process.cwd();

function getPnpmCommand() {
  return process.platform === "win32" ? "pnpm.cmd" : "pnpm";
}

function mergeNodeOptions(extraOption) {
  const current = process.env.NODE_OPTIONS || "";
  if (!extraOption) return current;
  if (current.includes(extraOption)) return current;
  return current ? `${current} ${extraOption}` : extraOption;
}

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: doraDoraDir,
    stdio: "inherit",
    shell: false,
    env: options.env || process.env,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status || 1);
}

const pnpmCmd = getPnpmCommand();
const buildEnv = { ...process.env };

// Apply a higher memory setting in a cross-platform way.
buildEnv.NODE_OPTIONS = mergeNodeOptions("--max-old-space-size=8192");

run(pnpmCmd, ["build-yarn-editor"]);
run(pnpmCmd, ["exec", "vite", "build"], { env: buildEnv });
run(process.execPath, [path.join("scripts", "minify-javascript-codes.js")]);
run(process.execPath, [path.join("scripts", "sync-build-to-assets.js")]);
