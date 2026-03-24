const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const doraDoraDir = process.cwd();
const toolsDir = path.resolve(doraDoraDir, "..");
const yarnEditorDir = path.join(toolsDir, "YarnEditor");
const yarnEditorDistDir = path.join(yarnEditorDir, "dist");
const yarnEditorNodeModulesDir = path.join(yarnEditorDir, "node_modules");
const publicYarnEditorDir = path.join(doraDoraDir, "public", "yarn-editor");
const publicYarnEditorGitkeep = path.join(publicYarnEditorDir, ".gitkeep");

function getPnpmCommand() {
  return process.platform === "win32" ? "pnpm.cmd" : "pnpm";
}

function getYarnEditorBuildScript() {
  if (process.platform === "win32") return "build-win";
  if (process.platform === "linux") return "build-linux";
  return "build";
}

function run(command, args, cwd) {
  const result = spawnSync(command, args, {
    cwd,
    stdio: "inherit",
    shell: true,
  });
  if (result.error) {
    throw result.error;
  }
  if (result.status !== 0) {
    process.exit(result.status || 1);
  }
}

if (!fs.existsSync(path.join(yarnEditorDir, "package.json"))) {
  console.error(`Missing YarnEditor project at ${yarnEditorDir}`);
  process.exit(1);
}

const pnpmCmd = getPnpmCommand();
const buildScript = getYarnEditorBuildScript();
const forceInstall = process.env.FORCE_YARN_EDITOR_INSTALL === "1";

if (forceInstall || !fs.existsSync(yarnEditorNodeModulesDir)) {
  console.log(
    forceInstall
      ? "Installing YarnEditor dependencies (forced)..."
      : "YarnEditor dependencies not found, installing..."
  );
  run(pnpmCmd, ["install"], yarnEditorDir);
}

console.log(`Building YarnEditor with \`${buildScript}\`...`);
run(pnpmCmd, ["run", buildScript], yarnEditorDir);

if (!fs.existsSync(yarnEditorDistDir)) {
  console.error(`Missing YarnEditor build output at ${yarnEditorDistDir}`);
  process.exit(1);
}

fs.rmSync(publicYarnEditorDir, { recursive: true, force: true });
fs.cpSync(yarnEditorDistDir, publicYarnEditorDir, { recursive: true });
fs.writeFileSync(publicYarnEditorGitkeep, "");
console.log(`Copied YarnEditor dist to ${publicYarnEditorDir}`);
