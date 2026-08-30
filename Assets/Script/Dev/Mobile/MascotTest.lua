-- [tsx]: MascotTest.tsx
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Content = ____Dora.Content -- 1
local Director = ____Dora.Director -- 1
local Size = ____Dora.Size -- 1
local Vec2 = ____Dora.Vec2 -- 1
local sleep = ____Dora.sleep -- 1
local thread = ____Dora.thread -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Mascot = require("Dev.Mobile.Mascot") -- 3
local DoraMascot = ____Mascot.DoraMascot -- 3
local ____MascotModel = require("Dev.Mobile.MascotModel") -- 4
local MASCOT_CELL_SIZE = ____MascotModel.MASCOT_CELL_SIZE -- 4
local MASCOT_PIVOT_Y = ____MascotModel.MASCOT_PIVOT_Y -- 4
local mascotAnimationTime = ____MascotModel.mascotAnimationTime -- 4
local mascotFrameAt = ____MascotModel.mascotFrameAt -- 4
local mascotFramePivotX = ____MascotModel.mascotFramePivotX -- 4
local mascotLayout = ____MascotModel.mascotLayout -- 4
local function expect(condition, message) -- 6
	if not condition then -- 6
		error( -- 6
			__TS__New(Error, message), -- 6
			0 -- 6
		) -- 6
	end -- 6
end -- 6
local function find(root, tag) -- 7
	if root.tag == tag then -- 7
		return root -- 8
	end -- 8
	local found -- 9
	root:eachChild(function(child) -- 10
		found = find(child, tag) -- 10
		return found ~= nil -- 10
	end) -- 10
	return found -- 11
end -- 7
thread(function() -- 14
	local host -- 15
	local previousSize = App.winSize -- 16
	local hidden = {} -- 17
	do -- 17
		local function ____catch(____error) -- 17
			Content:save( -- 66
				"/tmp/dora-mascot-anchor-runtime.result", -- 66
				"failed: " .. tostring(____error) -- 66
			) -- 66
		end -- 66
		local ____try, ____hasReturned = pcall(function() -- 66
			for ____, size in ipairs({42, 48, 52, 64}) do -- 19
				local layout = mascotLayout(size) -- 20
				expect( -- 21
					math.abs(layout.width - size) < 0.0001, -- 21
					"Requested display size changed" -- 21
				) -- 21
				expect( -- 22
					math.abs(layout.scale * MASCOT_CELL_SIZE - size) < 0.0001, -- 22
					"Wrong display scale" -- 22
				) -- 22
			end -- 22
			expect( -- 24
				mascotFrameAt(0, 0.2) == 0 and mascotFrameAt(0.41, 0.2) == 2 and mascotFrameAt(0.81, 0.2) == 0, -- 24
				"Frame timing mismatch" -- 24
			) -- 24
			expect( -- 25
				mascotFrameAt( -- 25
					mascotAnimationTime(0.6, 0.1, true), -- 25
					0.2 -- 25
				) == 0, -- 25
				"Reduced motion must reset to first frame" -- 25
			) -- 25
			expect(not App.reducedMotion, "Animation playback not_run: system reduced motion enabled") -- 26
			Director.systemUI:eachChild(function(node) -- 27
				if node.visible then -- 27
					hidden[#hidden + 1] = node -- 27
					node.visible = false -- 27
				end -- 27
				return false -- 27
			end) -- 27
			App.winSize = Size(780, 480) -- 28
			sleep(0.3) -- 29
			local states = { -- 30
				"idle", -- 30
				"waiting", -- 30
				"thinking", -- 30
				"working", -- 30
				"success", -- 30
				"failed" -- 30
			} -- 30
			host = toNode(React.createElement( -- 31
				"node", -- 31
				{tag = "mascot-test", scaleX = App.devicePixelRatio, scaleY = App.devicePixelRatio}, -- 31
				React.createElement( -- 31
					"draw-node", -- 31
					nil, -- 31
					React.createElement("rect-shape", {width = 780, height = 480, fillColor = 4280560440}) -- 31
				), -- 31
				__TS__ArrayMap( -- 33
					states, -- 33
					function(____, state, i) return React.createElement( -- 33
						"node", -- 33
						{ -- 33
							x = -300 + i % 3 * 300, -- 33
							y = 120 - math.floor(i / 3) * 240 -- 33
						}, -- 33
						React.createElement(DoraMascot, {state = state, x = 0, y = 0, size = 96}), -- 33
						React.createElement("label", {y = -80, fontName = "sarasa-mono-sc-regular", fontSize = 16, text = state}) -- 33
					) end -- 33
				) -- 33
			)) -- 33
			if not host then -- 33
				error( -- 38
					__TS__New(Error, "Missing test host"), -- 38
					0 -- 38
				) -- 38
			end -- 38
			host:addTo(Director.systemUI) -- 39
			local sprites = __TS__ArrayMap( -- 40
				states, -- 40
				function(____, state) return find( -- 40
					find(host, "mascot-" .. state), -- 40
					"mascot-sprite" -- 40
				) end -- 40
			) -- 40
			for ____, filter in ipairs({"None", "Point", "Anisotropic"}) do -- 41
				sprites[1].filter = filter -- 42
				expect(sprites[1].filter == filter, "Sprite filter read-back mismatch") -- 43
			end -- 43
			sprites[1].filter = "Point" -- 45
			local pivots = __TS__ArrayMap( -- 46
				sprites, -- 46
				function(____, sprite, i) return sprite:convertToWorldSpace(Vec2( -- 46
					mascotFramePivotX(i, 0), -- 46
					MASCOT_CELL_SIZE - MASCOT_PIVOT_Y -- 46
				)) end -- 46
			) -- 46
			local observed = {} -- 47
			do -- 47
				local tick = 0 -- 48
				while tick < 20 do -- 48
					sleep(0.1) -- 49
					__TS__ArrayForEach( -- 50
						sprites, -- 50
						function(____, sprite, i) -- 50
							expect(sprite.filter == "Point", "Sprite filter changed") -- 51
							expect(sprite.width == MASCOT_CELL_SIZE and sprite.height == MASCOT_CELL_SIZE, "Wrong quad size") -- 52
							expect(sprite.textureRect.y == i * MASCOT_CELL_SIZE, "Wrong state row") -- 53
							expect(sprite.textureRect.width == MASCOT_CELL_SIZE and sprite.textureRect.height == MASCOT_CELL_SIZE, "Wrong frame crop") -- 54
							local frame = math.floor(sprite.textureRect.x / MASCOT_CELL_SIZE) -- 55
							local pivotX = mascotFramePivotX(i, frame) -- 56
							expect( -- 57
								math.abs(sprite.anchor.x - pivotX / MASCOT_CELL_SIZE) < 0.0001, -- 57
								"Wrong frame anchor" -- 57
							) -- 57
							local p = sprite:convertToWorldSpace(Vec2(pivotX, MASCOT_CELL_SIZE - MASCOT_PIVOT_Y)) -- 58
							expect( -- 59
								math.abs(p.x - pivots[i + 1].x) < 0.001 and math.abs(p.y - pivots[i + 1].y) < 0.001, -- 59
								"Animated foot pivot moved" -- 59
							) -- 59
							observed[(tostring(i) .. ":") .. tostring(math.floor(sprite.textureRect.x / MASCOT_CELL_SIZE))] = true -- 60
						end -- 50
					) -- 50
					if tick % 2 == 0 then -- 50
						App:saveScreenshot("/tmp/dora-mascot-anchor-runtime-" .. tostring(tick)) -- 62
					end -- 62
					tick = tick + 1 -- 48
				end -- 48
			end -- 48
			do -- 48
				local row = 0 -- 64
				while row < 6 do -- 64
					do -- 64
						local frame = 0 -- 64
						while frame < 4 do -- 64
							expect( -- 64
								observed[(tostring(row) .. ":") .. tostring(frame)] == true, -- 64
								(("Frame not observed: " .. tostring(row)) .. ":") .. tostring(frame) -- 64
							) -- 64
							frame = frame + 1 -- 64
						end -- 64
					end -- 64
					row = row + 1 -- 64
				end -- 64
			end -- 64
			Content:save("/tmp/dora-mascot-anchor-runtime.result", "passed sizes=4 frames=24 pivotDrift<0.001 pointFilter=1 filterReadBack=3 quadCrop=1 reducedMotionModel=1\n") -- 65
		end) -- 65
		if not ____try then -- 65
			____catch(____hasReturned) -- 65
		end -- 65
	end -- 65
	if host ~= nil then -- 65
		host:removeFromParent(true) -- 67
	end -- 67
	App.winSize = previousSize -- 68
	sleep(0.3) -- 69
	__TS__ArrayForEach( -- 70
		hidden, -- 70
		function(____, node) -- 70
			node.visible = true -- 70
		end -- 70
	) -- 70
end) -- 14
return ____exports -- 14