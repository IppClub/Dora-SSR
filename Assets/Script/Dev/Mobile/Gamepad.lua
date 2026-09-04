-- Shared controller navigation for the Go shell. Game nodes keep their own input.
local D = require("Dora")
local App, Node, Vec2, Color, DrawNode = D.App, D.Node, D.Vec2, D.Color, D.DrawNode
local exports = {}
local screens = {}
local claimedFrame = -1
local claimedButton = ""
local targets = {
	["mobile-feed-play"] = true, ["mobile-feed-remix"] = true,
	["mobile-feed-create"] = true,
	["mobile-project-index-back"] = true,
	["mobile-project-create-input"] = true, ["mobile-project-create-cancel"] = true,
	["mobile-project-create-submit"] = true,
	["remix-back"] = true, ["remix-model-config"] = true,
	["remix-mode-plan"] = true, ["remix-mode-code"] = true,
	["remix-input"] = true, ["remix-question-input"] = true,
	["remix-question-back"] = true, ["remix-question-submit"] = true,
	["remix-send"] = true, ["remix-stop"] = true, ["remix-play"] = true,
	["remix-action-continue"] = true, ["remix-action-start-development"] = true,
	["remix-latest"] = true,
}
local function visible(node)
	if not node.parent then return false end
	while node do
		if not node.visible then return false end
		node = node.parent
	end
	return true
end
function exports.findGamepadNode(host, tag)
	if host.tag == tag then return host end
	local found
	host:eachChild(function(child)
		found = exports.findGamepadNode(child, tag)
		return found ~= nil
	end)
	return found
end
function exports.selectGamepadNode(host, tag)
	for i = #screens, 1, -1 do
		local state = screens[i]
		if state.select and (state.host == host or exports.findGamepadNode(state.host, tag)) then
			state.select(tag)
			return true
		end
	end
	return false
end
local function collect(host)
	local result = {}
	local sheet = exports.findGamepadNode(host, "mobile-project-create-sheet")
	local function visit(node)
		if not node.visible then return end
		local tag = node.tag
		if node.touchEnabled and node.width > 0 and node.height > 0 and
			(targets[tag] or tag:match("^mobile%-project%-index%-entry%-%d+$") or
			tag:match("^remix%-question%-.+%-option%-") or
			(tag:match("^mobile%-llm%-") and not tag:match("backdrop$"))) then
			local center = node:convertToWorldSpace(Vec2(node.width / 2, node.height / 2))
			-- Do not focus transcript actions outside their scrolling viewport.
			local parent, inside = node.parent, true
			while parent and parent ~= host do
				if parent.tag == "remix-transcript" then
					local p = parent:convertToNodeSpace(center)
					inside = p.y >= 0 and p.y <= parent.height
					break
				end
				parent = parent.parent
			end
			if inside then result[#result + 1] = node end
		end
		node:eachChild(function(child) visit(child); return false end)
	end
	visit(sheet or host)
	return result
end
function exports.attachGamepad(host, options)
	local control = Node()
	control.tag = "mobile-gamepad"
	control.order = 20000
	control.renderGroup = true
	control:addTo(D.Director.systemUI)
	local ring = DrawNode()
	ring.renderOrder = 20000
	ring:addTo(control)
	local state = {host = host, control = control}
	screens[#screens + 1] = state
	local selectedTag = options.initialTag
	local selectedByScope = {}
	local scope = host.tag
	local active, background = false, false
	local controllerId = 0
	local axisX, axisY, scrollY, held, repeatTime = 0, 0, 0, nil, 0
	local function ownsInput()
		if background or D.HttpServer.wsConnectionCount > 0 or not visible(host) then return false end
		for i = #screens, 1, -1 do
			if visible(screens[i].host) then
				return screens[i] == state
			end
		end
		return false
	end
	local function selection()
		local nextScope = host.tag
		for _, tag in ipairs({"mobile-project-create-sheet", "mobile-llm-detail-key", "mobile-llm-detail-delete", "mobile-llm-detail", "mobile-llm-list", "remix-questionnaire"}) do
			local container = exports.findGamepadNode(host, tag)
			if container and (tag ~= "mobile-llm-detail-delete" or not container.touchEnabled) then nextScope = tag; break end
		end
		if nextScope ~= scope then
			selectedByScope[scope] = selectedTag
			scope = nextScope
			selectedTag = selectedByScope[scope] or options.initialTag
		end
		local items = collect(host)
		for _, item in ipairs(items) do if item.tag == selectedTag then return item, items end end
		local first = items[1]
		-- A card transition can briefly have no interactive controls. Keep the
		-- remembered tag until the rebuilt page supplies its buttons again.
		if first then selectedTag = first.tag end
		return first, items
	end
	local function draw()
		ring:clear()
		ring.tag = ""
		if not active or not ownsInput() then return end
		local item = selection()
		if not item then return end
		ring.tag = "mobile-gamepad-focus:" .. item.tag
		local corners = {}
		local radius = math.min(17, item.height / 2, item.width / 2)
		for i, center in ipairs({Vec2(item.width + 3 - radius, item.height + 3 - radius),
			Vec2(-3 + radius, item.height + 3 - radius), Vec2(-3 + radius, -3 + radius),
			Vec2(item.width + 3 - radius, -3 + radius)}) do
			for step = 0, 6 do
				local angle = ((i - 1) * 90 + step * 15) * math.pi / 180
				local p = center + Vec2(math.cos(angle) * radius, math.sin(angle) * radius)
				corners[#corners + 1] = control:convertToNodeSpace(item:convertToWorldSpace(p))
			end
		end
		ring:drawPolygon(corners, Color(0x00000000), 2, Color(0xffffcc33))
	end
	state.select = function(tag) selectedTag = tag; draw() end
	local function move(button)
		local current, items = selection()
		if not current then return end
		local origin = current:convertToWorldSpace(Vec2(current.width / 2, current.height / 2))
		local best, score
		for _, item in ipairs(items) do
			if item ~= current then
				local p = item:convertToWorldSpace(Vec2(item.width / 2, item.height / 2)) - origin
				local horizontal = button == "dpleft" or button == "dpright"
				local forward = horizontal and p.x or p.y
				if button == "dpleft" or button == "dpdown" then forward = -forward end
				local across = math.abs(horizontal and p.y or p.x)
				local candidate = forward + across * 3
				if forward > 1 and (not score or candidate < score) then best, score = item, candidate end
			end
		end
		if best then selectedTag = best.tag end
	end
	local function dispatch(button)
		if not ownsInput() then return end
		if options.isEnabled and not options.isEnabled() then return end
		-- A confirmation may synchronously create another screen. Never dispatch
		-- that same native event to the newly registered screen as well.
		if claimedFrame == App.frame and claimedButton == button then return end
		claimedFrame, claimedButton = App.frame, button
		if not active then active = true; if options.onActive then options.onActive() end end
		if options.onButton and options.onButton(button, controllerId) then draw(); return end
		if button == "b" then options.onBack()
		elseif button == "a" then
			local target = selection()
			if target then
				if options.onActivate then options.onActivate(target)
				elseif target.tag == "mobile-llm-key" or target.tag:match("input$") then target:emit("GamepadActivate")
				else target:emit("Tapped") end
			end
		elseif button:match("^dp") then move(button) end
		draw()
	end
	control:onButtonDown(function(id, button)
		if not ownsInput() then return end
		controllerId = id
		if button:match("^dp") then held, repeatTime = button, 0.38 end
		dispatch(button)
	end)
	control:onButtonUp(function(id, button) if id == controllerId and held == button then held = nil end end)
	control:slot("ControllerRemoved", function(id)
		if id == controllerId then held, axisX, axisY, scrollY = nil, 0, 0, 0 end
	end)
	control:onAxis(function(id, axis, value)
		if not ownsInput() then return end
		controllerId = id
		if axis == "righty" then scrollY = math.abs(value) > 0.25 and value or 0; return end
		if axis == "leftx" then axisX = value elseif axis == "lefty" then axisY = value else return end
		local nextButton
		if math.max(math.abs(axisX), math.abs(axisY)) >= 0.55 then
			if math.abs(axisX) > math.abs(axisY) then nextButton = axisX > 0 and "dpright" or "dpleft"
			else nextButton = axisY > 0 and "dpdown" or "dpup" end
		end
		if held ~= nextButton then
			held, repeatTime = nextButton, 0.38
			if nextButton then dispatch(nextButton) end
		end
	end)
	control:schedule(function(dt)
		if not host.parent then control:removeFromParent(true); return true end
		if not ownsInput() then
			held, axisX, axisY, scrollY = nil, 0, 0, 0
			ring:clear()
			return false
		end
		if held then
			repeatTime = repeatTime - dt
			if repeatTime <= 0 then repeatTime = 0.13; dispatch(held) end
		end
		if scrollY ~= 0 and options.onScroll then options.onScroll(scrollY * dt * 480) end
		draw()
		return false
	end)
	control:onAppEvent(function(event)
		if event == "WillEnterBackground" or event == "DidEnterBackground" then background = true; held = nil; scrollY = 0
		elseif event == "DidEnterForeground" then background = false end
	end)
	host:onCleanup(function() control:removeFromParent(true) end)
	control:onCleanup(function()
		for i = #screens, 1, -1 do if screens[i] == state then table.remove(screens, i); break end end
	end)
end
return exports
