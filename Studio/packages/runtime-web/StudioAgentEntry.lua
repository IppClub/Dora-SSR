-- Dedicated Studio Agent WASM host only. The native Script.Dev.Entry starts
-- games in the IDE engine; never load that UI/runtime into this privileged host.
-- Non-rendering execute_command Lua code still uses the original Agent sandbox.
local exports = {}
function exports.getCurrentEntryStatus()
  return {success = true, running = false, runId = 0}
end
function exports.allClear()
  -- There is no game runtime in the trusted Agent host to clear.
end
function exports.stop()
  return false
end
function exports.enterEntryAsync()
  return false, "Studio Agent game entry requires the isolated browser Player"
end
return exports
