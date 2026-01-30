const fs = require("fs");
const path = require("path");

const repoRoot = process.cwd();
const sourcePath = path.resolve(
  repoRoot,
  "node_modules",
  "typescript",
  "lib",
  "typescript.js"
);
const destPath = path.resolve(repoRoot, "public", "typescript.js");

if (!fs.existsSync(sourcePath)) {
  console.error(`Missing TypeScript runtime at ${sourcePath}`);
  process.exit(1);
}

fs.mkdirSync(path.dirname(destPath), { recursive: true });
fs.copyFileSync(sourcePath, destPath);

console.log(`Copied ${sourcePath} -> ${destPath}`);
