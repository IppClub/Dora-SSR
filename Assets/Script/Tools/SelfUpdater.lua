-- [ts]: SelfUpdater.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 21
local Director = ____Dora.Director -- 21
local ____View = require("Tools.SelfUpdater.View") -- 22
local createUpdaterPanel = ____View.createUpdaterPanel -- 22
createUpdaterPanel():addTo(Director.entry) -- 25
return ____exports -- 25
