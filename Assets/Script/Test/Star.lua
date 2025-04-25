local _ENV = setmetatable({}, {__index = _G})
local nvg <const> = require("nvg")
local Node <const> = require("Node")
local Angle <const> = require("Angle")
local Ease <const> = require("Ease")
local drawStar
-- 描述该功能...
drawStar = function(centerX, centerY, radius)
  local a = 36
  local c = 72
  local f = math.sin(math.rad(a)) * math.tan(math.rad(c)) + math.cos(math.rad(a))
  local ro = radius
  local r = (ro * 1.5) / f
  nvg.BeginPath()
  i_inc = 1
  if (10 + 1) > (0) then
    i_inc = -i_inc
  end
  for i = 10 + 1, 0, i_inc do
    local angle = i * a
    local cr = i % 2 == 1 and r or ro
    local x = centerX + cr * math.sin(math.rad(angle))
    local y = centerY + cr * math.cos(math.rad(angle))
    if i == 10 then
      nvg.MoveTo(x, y)
    else
      nvg.LineTo(x, y)
    end
  end
  nvg.ClosePath()
  nvg.FillColor(0xffd700 | math.floor(1 * 255 + 0.5) << 24)
  nvg.Fill()
  nvg.StrokeColor(0xff8c00 | math.floor(1 * 255 + 0.5) << 24)
  nvg.StrokeWidth(10)
  nvg.Stroke()
end



-- @preview-project on nolog clear
local star = Node()
star:onUpdate(function()
  nvg.ApplyTransform(star)
  drawStar(0, 0, 100)
end)
star:perform(Angle(5, 0, 360, Ease.OutInExpo), true)
