
local Platformer <const> = require("Platformer")
local Data <const> = Platformer.Data

local Rectangle <const> = require("UI.View.Shape.Rectangle")
local Vec2 <const> = require("Vec2")
local Rect <const> = require("Rect")
local BodyDef <const> = require("BodyDef")
local Body <const> = require("Body")
local Director <const> = require("Director")
local App <const> = require("App")
local Color <const> = require("Color")
local View <const> = require("View")


local TerrainLayer = 0
local PlayerLayer = 1
local ItemLayer = 2

local PlayerGroup = Data.groupFirstPlayer
local ItemGroup = Data.groupFirstPlayer + 1
local TerrainGroup = Data.groupTerrain

Data:setShouldContact(PlayerGroup, ItemGroup, true)

local themeColor = App.themeColor
local fillColor = Color(themeColor:toColor3(), 0x66):toARGB()
local borderColor = themeColor:toARGB()
local DesignWidth <const> = 1500

local world = Platformer.PlatformWorld()
world.camera.boundary = Rect(-1250, -500, 2500, 1000)
world.camera.followRatio = Vec2(0.02, 0.02)
world.camera.zoom = View.size.width / DesignWidth
world:onAppChange(function(settingName)
	if settingName == "Size" then
		world.camera.zoom = View.size.width / DesignWidth
	end
end)

local terrainDef = BodyDef()
terrainDef.type = "Static"
terrainDef:attachPolygon(Vec2(0, -500), 2500, 10, 0, 1, 1, 0)
terrainDef:attachPolygon(Vec2(0, 500), 2500, 10, 0, 1, 1, 0)
terrainDef:attachPolygon(Vec2(1250, 0), 10, 1000, 0, 1, 1, 0)
terrainDef:attachPolygon(Vec2(-1250, 0), 10, 1000, 0, 1, 1, 0)

local terrain = Body(terrainDef, world, Vec2.zero)
terrain.order = TerrainLayer
terrain.group = TerrainGroup
terrain:addChild(Rectangle({
	y = -500,
	width = 2500,
	height = 10,
	fillColor = fillColor,
	borderColor = borderColor,
	fillOrder = 1,
	lineOrder = 2,
}))
terrain:addChild(Rectangle({
	x = 1250,
	y = 0,
	width = 10,
	height = 1000,
	fillColor = fillColor,
	borderColor = borderColor,
	fillOrder = 1,
	lineOrder = 2,
}))
terrain:addChild(Rectangle({
	x = -1250,
	y = 0,
	width = 10,
	height = 1000,
	fillColor = fillColor,
	borderColor = borderColor,
	fillOrder = 1,
	lineOrder = 2,
}))
world:addChild(terrain)

local once <const> = require("once")
local loop <const> = require("loop")
local sleep <const> = require("sleep")

local UnitAction <const> = Platformer.UnitAction


UnitAction:add("idle", {
	priority = 1,
	reaction = 2.0,
	recovery = 0.2,
	available = function(self)
		return self.onSurface
	end,
	create = function(self)



		local playable = self.playable
		playable.speed = 1.0
		playable:play("idle", true)
		local playIdleSpecial = loop(function()
			sleep(3)
			sleep(playable:play("idle1"))
			playable:play("idle", true)
		end)
		self.data.playIdleSpecial = playIdleSpecial
		return function(owner)
			coroutine.resume(playIdleSpecial)
			return not owner.onSurface
		end
	end,
})

UnitAction:add("move", {
	priority = 1,
	reaction = 2.0,
	recovery = 0.2,
	available = function(self)
		return self.onSurface
	end,
	create = function(self)



		local playable = self.playable
		playable.speed = 1
		playable:play("fmove", true)
		return function(self, action)
			local elapsedTime = action.elapsedTime
			local recovery = action.recovery * 2
			local move = self.unitDef.move
			local moveSpeed = 1.0
			if elapsedTime < recovery then
				moveSpeed = math.min(elapsedTime / recovery, 1.0)
			end
			self.velocityX = moveSpeed * (self.faceRight and move or -move)
			return not self.onSurface
		end
	end,
})

UnitAction:add("jump", {
	priority = 3,
	reaction = 2.0,
	recovery = 0.1,
	queued = true,
	available = function(self)
		return self.onSurface
	end,
	create = function(self)



		local jump = self.unitDef.jump
		self.velocityY = jump
		return once(function()
			local playable = self.playable
			playable.speed = 1
			sleep(playable:play("jump", false))
		end)
	end,
})

UnitAction:add("fallOff", {
	priority = 2,
	reaction = -1,
	recovery = 0.3,
	available = function(self)
		return not self.onSurface
	end,
	create = function(self)



		if self.playable.current ~= "jumping" then
			local playable = self.playable
			playable.speed = 1
			playable:play("jumping", true)
		end
		return loop(function(self)
			if self.onSurface then
				local playable = self.playable
				playable.speed = 1
				sleep(playable:play("landing", false))
				return true
			else
				return false
			end
		end)
	end,
})

local Decision <const> = Platformer.Decision
local Sel <const> = Decision.Sel
local Seq <const> = Decision.Seq
local Con <const> = Decision.Con
local Act <const> = Decision.Act

Data.store["AI:playerControl"] = Sel({
	Seq({
		Con("fmove key down", function(self)
			return not (self.entity.keyLeft and self.entity.keyRight) and
			(
			(self.entity.keyLeft and self.faceRight) or
			(self.entity.keyRight and not self.faceRight))

		end),
		Act("turn"),
	}),
	Seq({
		Con("is falling", function(self)
			return not self.onSurface
		end),
		Act("fallOff"),
	}),
	Seq({
		Con("jump key down", function(self)
			return self.entity.keyJump
		end),
		Act("jump"),
	}),
	Seq({
		Con("fmove key down", function(self)
			return (self.entity.keyLeft or self.entity.keyRight)
		end),
		Act("move"),
	}),
	Act("idle"),
})

local Dictionary <const> = require("Dictionary")
local Size <const> = require("Size")
local Array <const> = require("Array")

local unitDef = Dictionary()
unitDef.linearAcceleration = Vec2(0, -15)
unitDef.bodyType = "Dynamic"
unitDef.scale = 1.0
unitDef.density = 1.0
unitDef.friction = 1.0
unitDef.restitution = 0.0
unitDef.playable = "spine:Spine/moling"
unitDef.defaultFaceRight = true
unitDef.size = Size(60, 300)
unitDef.sensity = 0
unitDef.move = 300
unitDef.jump = 1000
unitDef.detectDistance = 350
unitDef.hp = 5.0
unitDef.tag = "player"
unitDef.decisionTree = "AI:playerControl"
unitDef.usePreciseHit = false
unitDef.actions = Array({
	"idle",
	"turn",
	"move",
	"jump",
	"fallOff",
	"cancel",
})

local Observer <const> = require("Observer")
local Sprite <const> = require("Sprite")
local Spawn <const> = require("Spawn")
local AngleY <const> = require("AngleY")
local Sequence <const> = require("Sequence")
local Y <const> = require("Y")
local Scale <const> = require("Scale")
local Opacity <const> = require("Opacity")
local Ease <const> = require("Ease")
local tolua <const> = require("tolua")
local Unit <const> = Platformer.Unit
local Entity = require("Entity")

Observer("Add", { "player" }):watch(function(self)
	local unit = Unit(unitDef, world, self, Vec2(300, -350))
	unit.order = PlayerLayer
	unit.group = PlayerGroup
	unit.playable.position = Vec2(0, -150)
	unit.playable:play("idle", true)
	world:addChild(unit)
	world.camera.followTarget = unit
end)

Observer("Add", { "x", "icon" }):watch(function(self, x, icon)
	local sprite = Sprite(icon)
	if sprite == nil then
		return
	end

	sprite:runAction(Spawn(
	AngleY(5, 0, 360),
	Sequence(
	Y(2.5, 0, 40, Ease.OutQuad),
	Y(2.5, 40, 0, Ease.InQuad))),

	true)

	local bodyDef = BodyDef()
	bodyDef.type = "Dynamic"
	bodyDef.linearAcceleration = Vec2(0, -10)
	bodyDef:attachPolygon(sprite.width * 0.5, sprite.height)
	bodyDef:attachPolygonSensor(0, sprite.width, sprite.height)

	local body = Body(bodyDef, world, Vec2(x, 0))
	body.order = ItemLayer
	body.group = ItemGroup
	body:addChild(sprite)

	body:onBodyEnter(function(item)
		if tolua.type(item) == "Platformer::Unit" then
			self.picked = true
			body.group = Data.groupHide
			body:schedule(once(function()
				sleep(sprite:runAction(Spawn(
				Scale(0.2, 1, 1.3, Ease.OutBack),
				Opacity(0.2, 1, 0))))

				self.body = nil
			end))
		end
	end)

	world:addChild(body)
	self.body = body
end)

Observer("Remove", { "body" }):watch(function(self)
	(self.oldValues.body):removeFromParent()
end)

local Content <const> = require("Content")
local Group <const> = require("Group")
local Utils <const> = require("Utils")
local Struct <const> = Utils.Struct











local function loadExcel()
	local xlsx = Content:loadExcel("Data/items.xlsx", { "items" })
	if xlsx == nil then
		return
	end
	local its = xlsx["items"]
	local names = its[2]
	table.remove(names, 1)
	if not Struct:has("Item") then
		Struct.Item(names)
	end
	Group({ "item" }):each(function(e)
		e:destroy()
	end)
	for i = 3, #its do
		local st = Struct:load(its[i])
		local item <const> = {
			name = st.Name,
			no = st.No,
			x = st.X,
			num = st.Num,
			icon = st.Icon,
			desc = st.Desc,
			item = true,
		}
		Entity(item)
	end
end

local ImGui <const> = require("ImGui")
local CircleButton <const> = require("UI.Control.Basic.CircleButton")
local AlignNode <const> = require("AlignNode")
local Menu <const> = require("Menu")
local Keyboard <const> = require("Keyboard")


local keyboardEnabled = true

local playerGroup = Group({ "player" })
local function updatePlayerControl(key, flag, vpad)
	if keyboardEnabled and vpad then
		keyboardEnabled = false
	end
	playerGroup:each(function(self)
		self[key] = flag
	end)
end

local ui = AlignNode(true)
ui:css('flex-direction: column-reverse')
ui:onButtonDown(function(controllerId, buttonName)
	if controllerId ~= 0 then return end
	if buttonName == "dpleft" then
		updatePlayerControl("keyLeft", true, true)
	elseif buttonName == "dpright" then
		updatePlayerControl("keyRight", true, true)
	elseif buttonName == "b" then
		updatePlayerControl("keyJump", true, true)
	end
end)
ui:onButtonUp(function(controllerId, buttonName)
	if controllerId ~= 0 then return end
	if buttonName == "dpleft" then
		updatePlayerControl("keyLeft", false, true)
	elseif buttonName == "dpright" then
		updatePlayerControl("keyRight", false, true)
	elseif buttonName == "b" then
		updatePlayerControl("keyJump", false, true)
	end
end)
ui:addTo(Director.ui)

local bottomAlign = AlignNode()
bottomAlign:css([[
	height: 60;
	justify-content: space-between;
	margin: 0, 20, 40;
	flex-direction: row
]]);
bottomAlign:addTo(ui)

local leftAlign = AlignNode()
leftAlign:css('width: 130; height: 60')
leftAlign:addTo(bottomAlign)

local leftMenu = Menu()
leftMenu.size = Size(250, 120)
leftMenu.anchor = Vec2.zero
leftMenu.scaleX = 0.5
leftMenu.scaleY = 0.5
leftMenu:addTo(leftAlign)

local leftButton = CircleButton({
	text = "左(a)",
	radius = 60,
	fontSize = 36,
})
leftButton.anchor = Vec2.zero
leftButton:onTapBegan(function()
	updatePlayerControl("keyLeft", true, true)
end)
leftButton:onTapEnded(function()
	updatePlayerControl("keyLeft", false, true)
end)
leftButton:addTo(leftMenu)

local rightButton = CircleButton({
	text = "右(d)",
	x = 130,
	radius = 60,
	fontSize = 36,
})
rightButton.anchor = Vec2.zero
rightButton:onTapBegan(function()
	updatePlayerControl("keyRight", true, true)
end)
rightButton:onTapEnded(function()
	updatePlayerControl("keyRight", false, true)
end)
rightButton:addTo(leftMenu)

local rightAlign = AlignNode()
rightAlign:css('width: 60; height: 60')
rightAlign:addTo(bottomAlign)

local rightMenu = Menu()
rightMenu.size = Size(120, 120)
rightMenu.anchor = Vec2.zero
rightMenu.scaleX = 0.5
rightMenu.scaleY = 0.5
rightMenu:addTo(rightAlign)

local jumpButton = CircleButton({
	text = "跳(j)",
	radius = 60,
	fontSize = 36,
})
jumpButton.anchor = Vec2.zero
jumpButton:onTapBegan(function()
	updatePlayerControl("keyJump", true, true)
end)
jumpButton:onTapEnded(function()
	updatePlayerControl("keyJump", false, true)
end)
jumpButton:addTo(rightMenu)

ui:schedule(function()
	local keyA = Keyboard:isKeyPressed("A")
	local keyD = Keyboard:isKeyPressed("D")
	local keyJ = Keyboard:isKeyPressed("J")
	if keyD or keyD or keyJ then
		keyboardEnabled = true
	end
	if not keyboardEnabled then
		return false
	end
	updatePlayerControl("keyLeft", keyA, false)
	updatePlayerControl("keyRight", keyD, false)
	updatePlayerControl("keyJump", keyJ, false)
	return false
end)

local pickedItemGroup = Group({ "picked" })
local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove",
}
Director.ui:schedule(function()
	local size = App.visualSize
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(size.width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(100, 300), "FirstUseEver")
	ImGui.Begin("BackPack", windowFlags, function()
		if ImGui.Button("重新加载Excel") then
			loadExcel()
		end
		ImGui.Separator()
		ImGui.Dummy(Vec2(100, 10))
		ImGui.Text("背包 (Teal)")
		ImGui.Separator()
		ImGui.Columns(3, false)
		pickedItemGroup:each(function(e)
			local item = e
			if item.num > 0 then
				if ImGui.ImageButton("item" .. tostring(item.no), item.icon, Vec2(50, 50)) then
					item.num = item.num - 1
					local sprite = Sprite(item.icon)
					if sprite == nil then
						return
					end
					sprite.scaleX = 0.5
					sprite.scaleY = 0.5
					sprite:perform(Spawn(
					Opacity(1, 1, 0),
					Y(1, 150, 250)))

					local player = playerGroup:find(function() return true end)
					local unit = player.unit
					unit:addChild(sprite)
				end
				if ImGui.IsItemHovered() then
					ImGui.BeginTooltip(function()
						ImGui.Text(item.name)
						ImGui.TextColored(themeColor, "数量：")
						ImGui.SameLine()
						ImGui.Text(tostring(item.num))
						ImGui.TextColored(themeColor, "描述：")
						ImGui.SameLine()
						ImGui.Text(tostring(item.desc))
					end)
				end
				ImGui.NextColumn()
			end
		end)
	end)
	return false
end)

Entity({ player = true })
loadExcel()