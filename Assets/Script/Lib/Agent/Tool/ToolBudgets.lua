-- [ts]: ToolBudgets.ts
local ____exports = {} -- 1
____exports.PREVIEW_GAME_TIMEOUT_SECONDS = 40 -- 5
____exports.PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS = ____exports.PREVIEW_GAME_TIMEOUT_SECONDS / 2 -- 6
____exports.ANALYZE_IMAGE_TIMEOUT_SECONDS = 65 -- 7
____exports.ANALYZE_IMAGE_HTTP_TIMEOUT_SECONDS = ____exports.ANALYZE_IMAGE_TIMEOUT_SECONDS - 5 -- 9
return ____exports -- 9