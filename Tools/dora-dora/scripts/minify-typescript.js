const fs = require("fs");
const path = require("path");

let esbuild;
try {
  esbuild = require("esbuild");
} catch (error) {
  console.error("Missing esbuild. Please install it (e.g. `yarn add -D esbuild`).");
  process.exit(1);
}

const repoRoot = process.cwd();
const buildPath = path.resolve(repoRoot, "build", "typescript.js");

if (!fs.existsSync(buildPath)) {
  console.error(`Missing build output at ${buildPath}. Run \`yarn build\` first.`);
  process.exit(1);
}

const source = fs.readFileSync(buildPath, "utf8");
const result = esbuild.transformSync(source, {
  minify: true,
  legalComments: "none",
  target: "es2017",
});

fs.writeFileSync(buildPath, result.code, "utf8");
console.log(`Minified ${buildPath}`);
