const fs = require("fs");
const path = require("path");

const doraDoraDir = process.cwd();
const buildDir = path.join(doraDoraDir, "build");
const assetsWwwDir = path.resolve(doraDoraDir, "..", "..", "Assets", "www");
const assetsWwwGitkeep = path.join(assetsWwwDir, ".gitkeep");

if (!fs.existsSync(buildDir)) {
  console.error(`Missing build output at ${buildDir}. Run \`pnpm build\` first.`);
  process.exit(1);
}

fs.rmSync(assetsWwwDir, { recursive: true, force: true });
fs.cpSync(buildDir, assetsWwwDir, { recursive: true });
fs.writeFileSync(assetsWwwGitkeep, "");

console.log(`Copied build output to ${assetsWwwDir}`);
