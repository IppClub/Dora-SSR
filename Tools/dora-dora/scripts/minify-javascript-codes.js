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
const buildDir = path.resolve(repoRoot, "build");
const typescriptPath = path.join(buildDir, "typescript.js");
const monacoWorkDir = path.join(buildDir, "monacoeditorwork");

function minifyFile(filePath) {
  const source = fs.readFileSync(filePath, "utf8");
  const result = esbuild.transformSync(source, {
    minify: true,
    legalComments: "none",
    target: "es2017",
  });
  fs.writeFileSync(filePath, result.code, "utf8");
  console.log(`Minified ${filePath}`);
}

if (!fs.existsSync(typescriptPath)) {
  console.error(`Missing build output at ${typescriptPath}. Run \`yarn build\` first.`);
  process.exit(1);
}

minifyFile(typescriptPath);

if (!fs.existsSync(monacoWorkDir)) {
  console.warn(`Missing build output at ${monacoWorkDir}. Skipping Monaco worker minify.`);
  process.exit(0);
}

function collectJsFiles(dir, acc) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      collectJsFiles(fullPath, acc);
    } else if (entry.isFile() && fullPath.endsWith(".js")) {
      acc.push(fullPath);
    }
  }
}

const monacoJsFiles = [];
collectJsFiles(monacoWorkDir, monacoJsFiles);

if (monacoJsFiles.length === 0) {
  console.warn(`No .js files found under ${monacoWorkDir}.`);
  process.exit(0);
}

for (const filePath of monacoJsFiles) {
  minifyFile(filePath);
}
