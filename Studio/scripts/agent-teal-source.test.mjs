import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { test } from 'node:test';
import { buildLuaCheckSource, stripGeneratedLineComments } from './agent-teal-source.mjs';

const root = new URL('../../', import.meta.url);
const webServer = readFileSync(new URL('Assets/Script/Dev/WebServer.lua', root), 'utf8');
const utils = readFileSync(new URL('Assets/Script/Lib/Utils.lua', root), 'utf8');
const substitution = 'content = content:gsub("^%-%-[ \\t]*tic80[ \\t]*", "require(\\"tic80\\")")';
const detector = 'local tic80APIs = {}\nlocal CheckTIC80Code = function(content) return content:match("^%-%- tic80") end\n_module_0["CheckTIC80Code"] = CheckTIC80Code\n';
const fixture = `local disabledCheckForLua = { "unknown" }\nlocal yueCheck\nyueCheck = function(content)\n${substitution}\nend\nlocal luaCheck\nluaCheck = function(file, content)\nreturn {success = true, info = content}\nend\nlocal luaCheckWithLineInfo\n${substitution}\n`;
const annotated = fixture.split('\n').map((line, i) => line ? `${line} -- ${i + 1}` : line).join('\n');

function runLua(source) {
  const result = spawnSync(process.env.DORA_LUA || 'lua', ['-e', 'assert(load(io.read("*a")))()'], { input: source, encoding: 'utf8' });
  assert.ifError(result.error);
  assert.equal(result.status, 0, result.stderr);
}

test('only generated numeric short comments are removed; Lua literals and other comments survive', () => {
  const literals = String.raw`local a = "escaped \" -- 123"
local b = 'escaped \' -- 456'
local c = [=[long
-- 789
]=]
--[==[long comment
-- 101
]==]
local d = 4 -- explanation -- 202
-- keep this comment
-- 303
`;
  assert.equal(stripGeneratedLineComments(literals), literals);
  assert.equal(stripGeneratedLineComments('local x = "-- 123" -- 42\r\nreturn x -- 51'), 'local x = "-- 123"\r\nreturn x');
});

for (const [name, source] of [['plain', fixture], ['annotated', annotated]]) {
  test(`${name} input extracts all three declaration boundaries and embeds valid substitutions`, () => {
    const lua = buildLuaCheckSource(source, detector);
    assert.ok(lua.includes('local disabledCheckForLua'));
    assert.ok(lua.includes('local luaCheck\nluaCheck = function('));
    assert.ok(!lua.includes('local yueCheck'));
    assert.ok(!lua.includes('local luaCheckWithLineInfo'));
    runLua(`studio_teal = {dora_to_lua = function(content) return content end}
${lua}
local ok, content = studio_lua_check('-- tic80 print(1)', 'test.lua')
assert(ok and content == 'require("tic80")print(1)')
local codes, err, tic80 = studio_tl_compile('-- tic80 print(1)', 'test.tl')
assert(codes == '-- tic80print(1)' and err == nil and tic80)
local plain, _, plainTic80 = studio_tl_compile('print(1)', 'test.tl')
assert(plain == 'print(1)' and not plainTic80)
`);
  });
  test(`${name} input still rejects a semantic substitution change`, () => {
    const changed = source.replace('require(\\"tic80\\")', 'require(\\"tic80.changed\\")');
    assert.throws(() => buildLuaCheckSource(changed, detector), /substitutions require review/);
  });
}

test('missing declarations or detector still fail closed', () => {
  for (const boundary of ['local yueCheck\n', 'local luaCheck\n', 'local luaCheckWithLineInfo\n']) {
    assert.throws(() => buildLuaCheckSource(fixture.replace(boundary, ''), detector), /Lua check shape changed/);
  }
  assert.throws(() => buildLuaCheckSource(fixture, ''), /TIC80 detector changed/);
  assert.throws(() => buildLuaCheckSource(fixture.replaceAll(substitution, ''), detector), /substitutions require review/);
});

test('current generated WebServer and equivalent plain input produce the same loadable Lua', () => {
  const lua = buildLuaCheckSource(webServer, utils);
  assert.equal(lua, buildLuaCheckSource(stripGeneratedLineComments(webServer), utils));
  runLua(`studio_teal = {}\n${lua}`);
});

test('ordinary trailing comments remain safe when substitutions are embedded', () => {
  const lua = buildLuaCheckSource(fixture.replaceAll(substitution, `${substitution} -- keep explanation`), detector);
  assert.ok(lua.includes('-- keep explanation'));
  runLua(`studio_teal = {}\n${lua}`);
});
