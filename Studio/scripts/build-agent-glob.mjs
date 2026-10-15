import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

// Optional Emscripten build: reuse the engine's matcher, including tiny-regex semantics.
const root = new URL('../../', import.meta.url);
const source = await readFile(new URL('Source/Basic/Content.cpp', root), 'utf8');
function between(start, end) {
  const a = source.indexOf(start), b = source.indexOf(end, a);
  if (a < 0 || b < 0) throw new Error(`Upstream glob extraction changed: ${start}`);
  return source.slice(a, b);
}
const output = new URL('../packages/agent-contracts/dist/glob/', import.meta.url);
await mkdir(output, { recursive: true });
const cpp = `#include <string>
#include <vector>
#include <cctype>
#define TINY_REGEX_IMPLEMENTATION
#include "tiny_regex.h"
#include "Slice.h"
using Slice = silly::slice::Slice;
using String = Slice;
namespace Path {
static std::string getFilename(const std::string& path) {
  auto at = path.find_last_of('/');
  return at == std::string::npos ? path : path.substr(at + 1);
}
}
${between('static std::string normalizeGlobPattern(', 'static std::unordered_map<std::string, int> normalizeExtensionLevels(')}
${between('static bool matchGlobRules(', 'static std::list<std::string> filterFilesByExtensionLevels(')}
static std::vector<std::string> patterns;
static std::vector<GlobRule> rules;
extern "C" {
void glob_reset() { patterns.clear(); rules.clear(); }
void glob_add(const char* pattern) { patterns.emplace_back(pattern); }
void glob_compile() { rules = compileGlobRules(patterns); }
int glob_match(const char* path) { return matchGlobRules(rules, path); }
int glob_skip_directory(const char* path) { return shouldSkipDirectoryByNegatedRules(rules, path); }
}
`;
await writeFile(new URL('matcher.cpp', output), cpp);
execFileSync(process.env.STUDIO_EMXX || 'em++', [fileURLToPath(new URL('matcher.cpp', output)),
  '-I' + fileURLToPath(new URL('Source/3rdParty/tiny-regex-c', root)),
  '-I' + fileURLToPath(new URL('Source/3rdParty/silly', root)),
  '-std=c++20', '-O2', '--no-entry', '-sMODULARIZE=1', '-sEXPORT_ES6=1', '-sSINGLE_FILE=1',
  '-sENVIRONMENT=web,node', '-sFILESYSTEM=0', '-sALLOW_MEMORY_GROWTH=1',
  '-sEXPORTED_FUNCTIONS=["_glob_reset","_glob_add","_glob_compile","_glob_match","_glob_skip_directory"]',
  '-sEXPORTED_RUNTIME_METHODS=["cwrap"]', '-o', fileURLToPath(new URL('matcher.mjs', output)),
], { stdio: 'inherit' });
