// Yue's generated trailing line numbers are metadata, not Lua code. Scan Lua
// literals/comments so numeric text inside strings or long comments is preserved.
export function stripGeneratedLineComments(source) {
  let result = '', cursor = 0;
  for (let i = 0; i < source.length;) {
    const quote = source[i];
    if (quote === '"' || quote === "'") {
      i++;
      while (i < source.length) {
        if (source[i] === '\\') i += 2;
        else if (source[i++] === quote) break;
      }
      continue;
    }
    const comment = source.startsWith('--', i);
    const bracketStart = i + (comment ? 2 : 0);
    const bracket = source[bracketStart] === '[' && source.slice(bracketStart).match(/^\[(=*)\[/);
    if (bracket) {
      const end = source.indexOf(`]${bracket[1]}]`, i + (comment ? 2 : 0) + bracket[0].length);
      i = end < 0 ? source.length : end + bracket[1].length + 2;
      continue;
    }
    if (comment) {
      let end = source.indexOf('\n', i);
      if (end < 0) end = source.length;
      const lineStart = source.lastIndexOf('\n', i - 1) + 1;
      if (source.slice(lineStart, i).trim() && /^--[ \t]+\d+[ \t]*\r?$/.test(source.slice(i, end))) {
        result += source.slice(cursor, i).replace(/[ \t]+$/, '');
        cursor = source[end - 1] === '\r' ? end - 1 : end;
      }
      i = end;
      continue;
    }
    i++;
  }
  return result + source.slice(cursor);
}

export function buildLuaCheckSource(webServer, utils) {
  webServer = stripGeneratedLineComments(webServer);
  const ticStart = utils.indexOf('local tic80APIs');
  const ticEnd = utils.indexOf('_module_0["CheckTIC80Code"]', ticStart);
  if (ticStart < 0 || ticEnd < 0) throw new Error('Original TIC80 detector changed');
  const ticDetector = utils.slice(ticStart, ticEnd);
  const substitutions = webServer.split('\n').map(line => line.trim()).filter(line => line.startsWith('content = content:gsub(') && line.includes('tic80'));
  if (!substitutions.length || new Set(substitutions).size !== 1) throw new Error('Original TIC80 substitutions require review');
  function extract(start, end) {
    const a = webServer.indexOf(start), b = webServer.indexOf(end, a);
    if (a < 0 || b < 0) throw new Error(`Original Lua check shape changed: ${start}`);
    return webServer.slice(a, b);
  }
  return `local teal = {checkAsync = studio_teal.dora_check}\n` +
    ticDetector + '\n' +
    extract('local disabledCheckForLua = {', 'local yueCheck\n') +
    extract('local luaCheck\nluaCheck = function(', 'local luaCheckWithLineInfo\n') +
    `\nfunction studio_lua_check(content, filename)
      if CheckTIC80Code(content) then
        ${substitutions[0]}
      end
      local result = luaCheck(filename, content); return result.success, result.info
    end
    function studio_tl_compile(content, filename)
      local isTIC80 = not not CheckTIC80Code(content)
      if isTIC80 then
        ${substitutions[0]}
      end
      local codes, err = studio_teal.dora_to_lua(content, filename, "")
      if codes and isTIC80 then codes = codes:gsub('^require%("tic80"%)', '-- tic80') end
      return codes, err, isTIC80
    end\n`;
}
