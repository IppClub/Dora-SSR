-- Serial project player. Native unload acknowledgements are the only boundary
-- between projects; readiness is observed on the logic scheduler.
local D = require("Dora")
local Player = {}
Player.__index = Player
local function notify(callback, ...)
    if not callback then return end
    local ok, err = pcall(callback, ...)
    if not ok then print("GodotPlayer callback: " .. tostring(err)) end
end
function Player:_finish(request, ok, game, message)
    if self._active ~= request then return end
    self._active, self._watch = nil, nil
    self.state = self._fault and "faulted" or (self.current and "running" or "idle")
    self._dispatching = true
    notify(request.callback, ok, game, message or "")
    self._dispatching = false
end
function Player:_unload(done)
    local game = self.current
    if not game then done(true, ""); return end
    self.state = "unloading"
    game:unloadAsync(function(ok, message)
        self.current = nil
        if not ok then self._fault = message ~= "" and message or "Project unload failed" end
        done(ok, message)
    end)
end
function Player:_start(request)
    self._active = request
    if request.kind == "close" then
        self:_unload(function(ok, message)
            self.state, self._active = "closed", nil
            self._control:removeFromParent()
            self._dispatching = true
            local callbacks = self._closeCallbacks
            self._closeCallbacks = {}
            for _, callback in ipairs(callbacks) do notify(callback, ok and not self._fault, self._fault or message or "") end
            self._dispatching = false
        end)
        return
    end
    if self._fault then self:_finish(request, false, nil, self._fault); return end
    self:_unload(function(ok, message)
        if not ok then self:_finish(request, false, nil, message); return end
        if request.kind == "unload" then self:_finish(request, true, nil, ""); return end
        local options = request.options
        self.state = "loading"
        local created, game = pcall(D.GodotNode, request.project, options.scene, options.width, options.height, options.buffers)
        if not created or not game then
            self:_finish(request, false, nil, created and "Cannot create GodotNode" or tostring(game))
            return
        end
        self.current = game
        game:addTo(self.parent)
        self._watch = {request = request, game = game, elapsed = 0}
    end)
end
function Player:_pump()
    if self._pumping or self._dispatching or self.state == "closed" then return end
    self._pumping = true
    while not self._active and #self._queue > 0 and self.state ~= "closed" do
        local request = table.remove(self._queue, 1)
        self.pending = #self._queue
        self:_start(request)
    end
    self._pumping = false
end
function Player:_step(dt)
    local watch = self._watch
    if watch then
        watch.elapsed = watch.elapsed + dt
        local message = watch.game.lastError
        if message ~= "" or watch.elapsed >= watch.request.options.timeout then
            self._watch = nil
            if message == "" then message = "Godot project startup timed out" end
            self:_unload(function(ok, unloadError)
                self:_finish(watch.request, false, nil, ok and message or unloadError)
            end)
        elseif watch.game.running then
            self:_finish(watch.request, true, watch.game, "")
        end
    end
    self:_pump()
    return self.state == "closed"
end
function Player:_enqueue(request)
    if self._closing or self.state == "closed" then return nil, "GodotPlayer is closing or closed" end
    self._next = self._next + 1
    request.id = self._next
    self._queue[#self._queue + 1] = request
    self.pending = #self._queue
    return request.id
end
function Player:switchAsync(project, options, callback)
    options = options or {}
    assert(type(project) == "string" and project ~= "", "project path required")
    assert(type(options) == "table", "options table required")
    local config = {scene = options.scene or "", width = options.width or 640,
        height = options.height or 360, buffers = options.buffers or 3, timeout = options.timeout or 60}
    for _, key in ipairs({"width", "height"}) do
        assert(type(config[key]) == "number" and config[key] >= 1 and config[key] <= 8192 and config[key] % 1 == 0, "invalid " .. key)
    end
    assert(config.buffers == 2 or config.buffers == 3 or config.buffers == 4, "buffers must be 2/3/4")
    assert(type(config.scene) == "string", "scene must be a string")
    assert(type(config.timeout) == "number" and config.timeout > 0 and config.timeout < math.huge, "invalid timeout")
    return self:_enqueue({kind = "switch", project = project, options = config, callback = callback})
end
function Player:unloadAsync(callback)
    return self:_enqueue({kind = "unload", callback = callback})
end
function Player:closeAsync(callback)
    if self.state == "closed" then
        -- Keep cached close callbacks asynchronous, like native unloadAsync.
        local node = D.Node():addTo(D.Director.ui)
        node:schedule(function() notify(callback, not self._fault, self._fault or ""); node:removeFromParent(); return true end)
        return
    end
    if callback then self._closeCallbacks[#self._closeCallbacks + 1] = callback end
    if self._closing then return end
    self._closing = true
    self._queue[#self._queue + 1] = {kind = "close"}
    self.pending = #self._queue
end
return setmetatable(Player, {__call = function(_, parent)
    local self = setmetatable({parent = parent or D.Director.ui, current = nil, state = "idle", pending = 0,
        _queue = {}, _next = 0, _closeCallbacks = {}}, Player)
    self._control = D.Node():addTo(D.Director.ui)
    self._control:schedule(function(dt) return self:_step(dt) end)
    return self
end})
