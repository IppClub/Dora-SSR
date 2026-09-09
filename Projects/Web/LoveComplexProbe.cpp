/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#include "Const/Header.h"

#include "Audio/Audio.h"
#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Love/LoveNode.h"
#include "Input/TouchDispather.h"

#include "soloud.h"

#include "lua.h"
#include "lauxlib.h"

#include <emscripten/emscripten.h>

#include <string>

namespace
{
Dora::Ref<Dora::LoveNode> probeNode;
std::string probeError;
int probeState = 0;
std::uint32_t baselineAudioFiles = 0;
unsigned int baselineVoices = 0;
int hostPointerPresses = 0;
int hostPointerButton = -1;
int hostPointerFromMouse = -1;
float hostPointerX = -1.0f;
float hostPointerY = -1.0f;
std::string probeGameState = R"({"available":false})";

constexpr const char *GameStateProbe = R"lua(
local G = rawget(_G, "G")
local function escape(value)
  value = tostring(value or "")
  return value:gsub('[%z\1-\31\\"]', function(c)
    local map = {['\\']='\\\\', ['"']='\\"', ['\n']='\\n', ['\r']='\\r', ['\t']='\\t'}
    return map[c] or string.format('\\u%04x', string.byte(c))
  end)
end
local function quote(value) return '"' .. escape(value) .. '"' end
local loveOS = love and love.system and love.system.getOS and love.system.getOS() or ''
if not G then return '{"available":false,"loveOS":' .. quote(loveOS) .. '}' end
local function nameOf(values, target)
  if type(values) ~= "table" then return "" end
  for name, value in pairs(values) do
    if value == target then return name end
  end
  return ""
end
local function targetSummary(target)
  if type(target) ~= "table" then return "" end
  local config = type(target.config) == "table" and target.config or {}
  return tostring(config.id or config.button or target.ID or "")
end
local controller = G.CONTROLLER
local function controllerTarget(field)
  local slot = type(controller) == "table" and controller[field] or nil
  return targetSummary(type(slot) == "table" and slot.target or nil)
end
local function controllerTargetObject(field)
  local slot = type(controller) == "table" and controller[field] or nil
  return type(slot) == "table" and type(slot.target) == "table" and slot.target or nil
end
local function sequenceLength(value)
  if type(value) ~= 'table' then return -1 end
  return tonumber(value.length) or #value
end
local queueCount = 0
if G.E_MANAGER and type(G.E_MANAGER.queues) == 'table' then
  for _, queue in pairs(G.E_MANAGER.queues) do queueCount = queueCount + sequenceLength(queue) end
end
local profileValue = G.SETTINGS and G.SETTINGS.profile or 1
local profile = tonumber(profileValue) or 1
local profilePath = tostring(profileValue)
local savePresent = false
local profilePresent = false
local filesystem = love and love.filesystem or nil
local saveItems = {}
local profileItems = {}
local saveIdentity = ''
local saveDirectory = ''
if filesystem and filesystem.getInfo then
  savePresent = filesystem.getInfo(profilePath .. '/save.jkr') and true or false
  profilePresent = filesystem.getInfo(profilePath .. '/profile.jkr') and true or false
  saveItems = filesystem.getDirectoryItems('') or {}
  profileItems = filesystem.getDirectoryItems(profilePath) or {}
  saveIdentity = filesystem.getIdentity and filesystem.getIdentity() or ''
  saveDirectory = filesystem.getSaveDirectory and filesystem.getSaveDirectory() or ''
end
local saveThread = G.SAVE_MANAGER and G.SAVE_MANAGER.thread or nil
local saveThreadRunning = saveThread and saveThread.isRunning and saveThread:isRunning() or false
local saveThreadError = saveThread and saveThread.getError and saveThread:getError() or ''
local forceSaveError = rawget(_G, 'DORA_WEB_PROBE_FORCE_SAVE_ERROR') or ''
local saveChannel = G.SAVE_MANAGER and G.SAVE_MANAGER.channel or nil
local saveChannelCount = saveChannel and saveChannel.getCount and saveChannel:getCount() or -1
local round = G.GAME and G.GAME.current_round or nil
local activeTouches = love and love.touch and love.touch.getTouches and #love.touch.getTouches() or -1
local function targetRatio(target, axis)
  if target and type(target.put_focused_cursor) == 'function' then
    local ok, x, y = pcall(target.put_focused_cursor, target)
    local extent = axis == 'x' and love.graphics.getWidth() or love.graphics.getHeight()
    local value = axis == 'x' and x or y
    if ok and type(value) == 'number' and extent > 0 then return value / extent end
  end
  local transform = target and (target.T or target.VT) or nil
  if not transform then return -1 end
  local value = (tonumber(transform[axis]) or 0) + 0.5 * (tonumber(transform[axis == 'x' and 'w' or 'h']) or 0)
  local scale = (tonumber(G.TILESCALE) or 1) * (tonumber(G.TILESIZE) or 1)
  local extent = axis == 'x' and love.graphics.getWidth() or love.graphics.getHeight()
  return extent > 0 and value * scale / extent or -1
end
local function stringList(values)
  local result = {}
  for _, value in ipairs(values) do result[#result + 1] = quote(value) end
  return '[' .. table.concat(result, ',') .. ']'
end
local function buttonRatio(id, axis)
  local button = G.buttons and G.buttons.get_UIE_by_ID and G.buttons:get_UIE_by_ID(id) or nil
  if not button and G.I and type(G.I.UIBOX) == 'table' then
    for _, box in ipairs(G.I.UIBOX) do
      if box and type(box.get_UIE_by_ID) == 'function' then
        button = box:get_UIE_by_ID(id)
        if button then break end
      end
    end
  end
  return targetRatio(button, axis)
end
local function handCardRatios()
  local result = {}
  local scale = (tonumber(G.TILESCALE) or 1) * (tonumber(G.TILESIZE) or 1)
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  if G.hand and type(G.hand.cards) == 'table' then
    for _, card in ipairs(G.hand.cards) do
      local transform = card and (card.VT or card.T) or nil
      if transform and width > 0 and height > 0 then
        local x = ((tonumber(transform.x) or 0) + 0.5 * (tonumber(transform.w) or 0)) * scale / width
        local y = ((tonumber(transform.y) or 0) + 0.5 * (tonumber(transform.h) or 0)) * scale / height
        result[#result + 1] = '[' .. tostring(x) .. ',' .. tostring(y) .. ']'
      end
    end
  end
  return '[' .. table.concat(result, ',') .. ']'
end
local function handCardDetails()
  local result, selected = {}, {}
  if G.hand and type(G.hand.highlighted) == 'table' then
    for _, card in ipairs(G.hand.highlighted) do selected[card] = true end
  end
  local scale = (tonumber(G.TILESCALE) or 1) * (tonumber(G.TILESIZE) or 1)
  local width, height = love.graphics.getWidth(), love.graphics.getHeight()
  if G.hand and type(G.hand.cards) == 'table' then
    for index, card in ipairs(G.hand.cards) do
      local transform = card and (card.VT or card.T) or nil
      if transform and width > 0 and height > 0 then
        local x = ((tonumber(transform.x) or 0) + 0.5 * (tonumber(transform.w) or 0)) * scale / width
        local y = ((tonumber(transform.y) or 0) + 0.5 * (tonumber(transform.h) or 0)) * scale / height
        result[#result + 1] = table.concat({
          '{"index":', tostring(index),
          ',"target":', quote(card.ID or ''),
          ',"rank":', tostring(card.base and tonumber(card.base.id) or -1),
          ',"suit":', quote(card.base and card.base.suit or ''),
          ',"x":', tostring(x), ',"y":', tostring(y),
          ',"selected":', selected[card] and 'true' or 'false', '}'
        })
      end
    end
  end
  return '[' .. table.concat(result, ',') .. ']'
end
return table.concat({
  '{"available":true',
  ',"loveOS":', quote(loveOS),
  ',"stage":', quote(nameOf(G.STAGES, G.STAGE)),
  ',"stageValue":', tostring(tonumber(G.STAGE) or -1),
  ',"state":', quote(nameOf(G.STATES, G.STATE)),
  ',"stateValue":', tostring(tonumber(G.STATE) or -1),
  ',"paused":', G.SETTINGS and G.SETTINGS.paused and 'true' or 'false',
  ',"mainMenu":', G.MAIN_MENU_UI and 'true' or 'false',
  ',"overlayMenu":', G.OVERLAY_MENU and 'true' or 'false',
  ',"overlayTutorial":', G.OVERLAY_TUTORIAL and 'true' or 'false',
  ',"hand":', G.hand and 'true' or 'false',
  ',"blindSelect":', G.blind_select and 'true' or 'false',
  ',"shop":', G.shop and 'true' or 'false',
  ',"screenwipe":', G.screenwipe and 'true' or 'false',
  ',"locksFrame":', controller and controller.locks and controller.locks.frame and 'true' or 'false',
  ',"lCursorQueued":', controller and controller.L_cursor_queue and 'true' or 'false',
  ',"hid":', quote(controller and controller.HID and controller.HID.last_type or ''),
  ',"activeTouches":', tostring(activeTouches),
  ',"playButtonXRatio":', tostring(buttonRatio('play_button', 'x')),
  ',"playButtonYRatio":', tostring(buttonRatio('play_button', 'y')),
  ',"discardButtonXRatio":', tostring(buttonRatio('discard_button', 'x')),
  ',"discardButtonYRatio":', tostring(buttonRatio('discard_button', 'y')),
  ',"cashOutButtonXRatio":', tostring(buttonRatio('cash_out_button', 'x')),
  ',"cashOutButtonYRatio":', tostring(buttonRatio('cash_out_button', 'y')),
  ',"tutorialNextButtonXRatio":', tostring(buttonRatio('tut_next', 'x')),
  ',"tutorialNextButtonYRatio":', tostring(buttonRatio('tut_next', 'y')),
  ',"tutorialSkipButtonXRatio":', tostring(buttonRatio('skip_tutorial_section', 'x')),
  ',"tutorialSkipButtonYRatio":', tostring(buttonRatio('skip_tutorial_section', 'y')),
  ',"handCardRatios":', handCardRatios(),
  ',"handCardDetails":', handCardDetails(),
  ',"hoverTarget":', quote(controllerTarget('hovering')),
  ',"hoverIsCard":', controllerTargetObject('hovering') and controllerTargetObject('hovering').base and 'true' or 'false',
  ',"focusTarget":', quote(controllerTarget('focused')),
  ',"focusXRatio":', tostring(targetRatio(controllerTargetObject('focused'), 'x')),
  ',"focusYRatio":', tostring(targetRatio(controllerTargetObject('focused'), 'y')),
  ',"downTarget":', quote(controllerTarget('cursor_down')),
  ',"clickedTarget":', quote(controllerTarget('clicked')),
  ',"cursorX":', tostring(controller and controller.cursor_down and controller.cursor_down.T and controller.cursor_down.T.x or -1),
  ',"cursorY":', tostring(controller and controller.cursor_down and controller.cursor_down.T and controller.cursor_down.T.y or -1),
  ',"timerReal":', tostring(G.TIMERS and G.TIMERS.REAL or -1),
  ',"timerTotal":', tostring(G.TIMERS and G.TIMERS.TOTAL or -1),
  ',"eventQueueCount":', tostring(queueCount),
  ',"deckCards":', tostring(G.deck and sequenceLength(G.deck.cards) or -1),
  ',"handCards":', tostring(G.hand and sequenceLength(G.hand.cards) or -1),
  ',"highlightedCards":', tostring(G.hand and sequenceLength(G.hand.highlighted) or -1),
  ',"handsLeft":', tostring(round and tonumber(round.hands_left) or -1),
  ',"discardsLeft":', tostring(round and tonumber(round.discards_left) or -1),
  ',"chips":', tostring(round and tonumber(round.chips) or -1),
  ',"dollars":', tostring(G.GAME and tonumber(G.GAME.dollars) or -1),
  ',"profile":', tostring(profile),
  ',"profilePath":', quote(profilePath),
  ',"savePresent":', savePresent and 'true' or 'false',
  ',"profilePresent":', profilePresent and 'true' or 'false',
  ',"saveItems":', stringList(saveItems),
  ',"profileItems":', stringList(profileItems),
  ',"saveIdentity":', quote(saveIdentity),
  ',"saveDirectory":', quote(saveDirectory),
  ',"saveThreadRunning":', saveThreadRunning and 'true' or 'false',
  ',"saveThreadError":', quote(saveThreadError or ''),
  ',"forceSaveError":', quote(forceSaveError),
  ',"saveChannelCount":', tostring(saveChannelCount),
  ',"saveRunQueued":', G.FILE_HANDLER and G.FILE_HANDLER.run and 'true' or 'false',
  ',"saveUpdateQueued":', G.FILE_HANDLER and G.FILE_HANDLER.update_queued and 'true' or 'false',
  ',"stageObjectCount":', tostring(G.STAGE_OBJECTS and sequenceLength(G.STAGE_OBJECTS[G.STAGE]) or -1),
  '}'
})
)lua";

void refreshGameState()
{
	probeGameState = R"({"available":false})";
	if (!probeNode) return;
	auto *state = probeNode->getProbeLuaState();
	if (!state) return;
	const int base = lua_gettop(state);
	if (luaL_loadbufferx(state, GameStateProbe, std::char_traits<char>::length(GameStateProbe),
		"@dora-web-love-complex-probe.lua", nullptr) != LUA_OK)
	{
		probeGameState = R"({"available":false,"error":"probe-load-failed"})";
		lua_settop(state, base);
		return;
	}
	if (lua_pcall(state, 0, 1, 0) != LUA_OK)
	{
		probeGameState = R"({"available":false,"error":"probe-run-failed"})";
		lua_settop(state, base);
		return;
	}
	std::size_t length = 0;
	if (const char *value = lua_tolstring(state, -1, &length))
		probeGameState.assign(value, length);
	lua_settop(state, base);
}

unsigned int voiceCount()
{
	auto *soloud = SharedAudio.getSoLoud();
	return soloud ? soloud->getVoiceCount() : 0;
}

void finishReleaseAfterFrames(int remaining)
{
	SharedDirector.getSystemScheduler()->schedule([remaining](double) mutable {
		if (remaining-- > 0) return false;
		if (probeNode && (probeNode->hasProbeGraphicsResources()
			|| probeNode->hasProbeAudioResources()))
		{
			probeError = "Love Web complex-project resources survived node cleanup";
			probeState = -1;
			return true;
		}
		probeNode = nullptr;
		if (Dora::AudioFile::getCount() != baselineAudioFiles)
		{
			probeError = "Love Web complex-project AudioFile objects survived cleanup";
			probeState = -1;
			return true;
		}
		if (voiceCount() != baselineVoices)
		{
			probeError = "Love Web complex-project SoLoud voices survived cleanup";
			probeState = -1;
			return true;
		}
		probeState = 2;
		return true;
	});
}
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_start()
{
	if (probeNode) return 1;
	probeError.clear();
	probeState = 0;
	baselineAudioFiles = Dora::AudioFile::getCount();
	baselineVoices = voiceCount();
	hostPointerPresses = 0;
	hostPointerButton = -1;
	hostPointerFromMouse = -1;
	hostPointerX = -1.0f;
	hostPointerY = -1.0f;
	SharedApplication.invokeInLogic([]() {
		auto *node = Dora::LoveNode::createProbe("/love-complex/main.lua"_slice, probeError);
		if (!node)
		{
			if (probeError.empty()) probeError = "failed to create the Love Web complex project";
			probeState = -1;
			return;
		}
		probeNode = node;
		node->slot("TapBegan"_slice, [](Dora::Event *event) {
			++hostPointerPresses;
			Dora::Touch *touch = nullptr;
			if (event->get(touch) && touch)
			{
				hostPointerButton = touch->getMouseButton();
				hostPointerFromMouse = touch->isFromMouse() ? 1 : 0;
				hostPointerX = touch->getLocation().x;
				hostPointerY = touch->getLocation().y;
			}
		});
		SharedDirector.getUI()->removeAllChildren(true);
		SharedDirector.getUI()->addChild(node);
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_status()
{
	if (!probeNode) return probeState;
	if (probeState == 3) return probeState;
	const auto error = probeNode->getLastError().toString();
	if (!error.empty())
	{
		probeError = error;
		probeState = -1;
	}
	else if (probeState == 0 && probeNode->isRunning())
		probeState = 1;
	return probeState;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_release()
{
	if (!probeNode || probeState == 2 || probeState == 3)
	{
		probeError = "Love Web complex project is not running";
		return 0;
	}
	probeState = 3;
	SharedApplication.invokeInLogic([]() {
		probeNode->removeFromParent(true);
		finishReleaseAfterFrames(2);
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE double dora_web_love_complex_probe_frame()
{
	return static_cast<double>(SharedApplication.getFrame());
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_has_graphics()
{
	return probeNode && probeNode->hasProbeGraphicsResources() ? 1 : 0;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_is_updating()
{
	return probeNode && probeNode->isProbeUpdating() ? 1 : 0;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_runtime_status()
{
	return probeNode ? probeNode->getProbeRuntimeStatus() : -1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_audio_sources()
{
	return probeNode ? static_cast<int>(probeNode->getProbeAudioSourceCount()) : 0;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_audio_file_delta()
{
	return static_cast<int>(Dora::AudioFile::getCount()) - static_cast<int>(baselineAudioFiles);
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_voice_delta()
{
	return static_cast<int>(voiceCount()) - static_cast<int>(baselineVoices);
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_pointer_presses()
{
	return hostPointerPresses;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_pointer_button()
{
	return hostPointerButton;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_pointer_from_mouse()
{
	return hostPointerFromMouse;
}

extern "C" EMSCRIPTEN_KEEPALIVE double dora_web_love_complex_probe_pointer_x()
{
	return hostPointerX;
}

extern "C" EMSCRIPTEN_KEEPALIVE double dora_web_love_complex_probe_pointer_y()
{
	return hostPointerY;
}

extern "C" EMSCRIPTEN_KEEPALIVE const char *dora_web_love_complex_probe_game_state()
{
	refreshGameState();
	return probeGameState.c_str();
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_skip_tutorial()
{
	if (!probeNode) return 0;
	SharedApplication.invokeInLogic([]() {
		if (!probeNode) return;
		auto *state = probeNode->getProbeLuaState();
		if (!state) return;
		const int base = lua_gettop(state);
		constexpr const char *script = R"lua(
local G = rawget(_G, 'G')
if G and G.OVERLAY_TUTORIAL and G.FUNCS and type(G.FUNCS.skip_tutorial_section) == 'function' then
  G.FUNCS.skip_tutorial_section({})
end
)lua";
		if (luaL_loadbufferx(state, script, std::char_traits<char>::length(script),
			"@dora-web-love-complex-skip-tutorial.lua", nullptr) == LUA_OK)
			lua_pcall(state, 0, 0, 0);
		lua_settop(state, base);
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_complex_probe_force_save()
{
	if (!probeNode) return 0;
	SharedApplication.invokeInLogic([]() {
		if (!probeNode) return;
		auto *state = probeNode->getProbeLuaState();
		if (!state) return;
		const int base = lua_gettop(state);
		constexpr const char *script = R"lua(
local ok, err = pcall(function()
  local G = rawget(_G, 'G')
  local saveRun = rawget(_G, 'save_run')
  if G and type(saveRun) == 'function' then
    saveRun()
    G.FILE_HANDLER = G.FILE_HANDLER or {}
    G.FILE_HANDLER.force = true
    if G.SAVE_MANAGER and G.SAVE_MANAGER.channel and G.ARGS and G.ARGS.save_run then
      G.SAVE_MANAGER.channel:push({
        type = 'save_run',
        save_table = G.ARGS.save_run,
        profile_num = G.SETTINGS and G.SETTINGS.profile or 1
      })
    end
  end
end)
DORA_WEB_PROBE_FORCE_SAVE_ERROR = ok and '' or tostring(err)
)lua";
		if (luaL_loadbufferx(state, script, std::char_traits<char>::length(script),
			"@dora-web-love-complex-force-save.lua", nullptr) == LUA_OK)
			lua_pcall(state, 0, 0, 0);
		lua_settop(state, base);
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE const char *dora_web_love_complex_probe_error()
{
	return probeError.c_str();
}
