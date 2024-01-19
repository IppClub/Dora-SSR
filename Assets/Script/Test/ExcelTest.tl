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
world:gslot("AppSizeChanged", function()
	world.camera.zoom = View.size.width / DesignWidth
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
terrain:addChild(Rectangle{
	y = -500,
	width = 2500,
	height = 10,
	fillColor = fillColor,
	borderColor = borderColor,
	fillOrder = 1,
	lineOrder = 2
})
terrain:addChild(Rectangle{
	x = 1250,
	y = 0,
	width = 10,
	height = 1000,
	fillColor = fillColor,
	borderColor = borderColor,
	fillOrder = 1,
	lineOrder = 2
})
terrain:addChild(Rectangle{
	x = -1250,
	y = 0,
	width = 10,
	height = 1000,
	fillColor = fillColor,
	borderColor = borderColor,
	fillOrder = 1,
	lineOrder = 2
})
world:addChild(terrain)

local once <const> = require("once")
local loop <const> = require("loop")
local sleep <const> = require("sleep")
local type Routine = require("Routine")
local UnitAction <const> = Platformer.UnitAction
local type UnitType = Platformer.Unit.Type

UnitAction:add("idle", {
	priority = 1,
	reaction = 2.0,
	recovery = 0.2,
	available = function(self: UnitType): boolean
		return self.onSurface
	end,
	create = function(self: UnitType): (
			function(owner: UnitType, action: UnitAction.Type, deltaTime: number): (boolean)
			| Routine.Job
		)
		local playable = self.playable
		playable.speed = 1.0
		playable:play("idle", true)
		local playIdleSpecial = loop(function(): boolean
				sleep(3)
				sleep(playable:play("idle1"))
				playable:play("idle", true)
		end)
		self.data.playIdleSpecial = playIdleSpecial
		return function(owner: UnitType): boolean
			coroutine.resume(playIdleSpecial)
			return not owner.onSurface
		end
	end
})

UnitAction:add("move", {
	priority = 1,
	reaction = 2.0,
	recovery = 0.2,
	available = function(self: UnitType): boolean
		return self.onSurface
	end,
	create = function(self: UnitType): (
			function(owner: UnitType, action: UnitAction.Type, deltaTime: number): (boolean)
			| Routine.Job
		)
		local playable = self.playable
		playable.speed = 1
		playable:play("fmove", true)
		return function(self: UnitType, action: UnitAction.Type): boolean
			local elapsedTime = action.elapsedTime
			local recovery = action.recovery * 2
			local move = self.unitDef.move as number
			local moveSpeed: number = 1.0
			if elapsedTime < recovery then
				moveSpeed = math.min(elapsedTime / recovery, 1.0)
			end
			self.velocityX = moveSpeed * (self.faceRight and move or -move)
			return not self.onSurface
		end
	end
})

UnitAction:add("jump", {
	priority = 3,
	reaction = 2.0,
	recovery = 0.1,
	queued = true,
	available = function(self: UnitType): boolean
		return self.onSurface
	end,
	create = function(self: UnitType): (
			function(owner: UnitType, action: UnitAction.Type, deltaTime: number): (boolean)
			| Routine.Job
		)
		local jump = self.unitDef.jump as number
		self.velocityY = jump
		return once(function()
			local playable = self.playable
			playable.speed = 1
			sleep(playable:play("jump", false))
		end)
	end
})

UnitAction:add("fallOff", {
	priority = 2,
	reaction = -1,
	recovery = 0.3,
	available = function(self: UnitType): boolean
		return not self.onSurface
	end,
	create = function(self: UnitType): (
			function(owner: UnitType, action: UnitAction.Type, deltaTime: number): (boolean)
			| Routine.Job
		)
		if self.playable.current ~= "jumping" then
			local playable = self.playable
			playable.speed = 1
			playable:play("jumping", true)
		end
		return loop(function(self: UnitType): boolean
			if self.onSurface then
					local playable = self.playable
					playable.speed = 1
					sleep(playable:play("landing", false))
					return true
				else
					return false
				end
		end)
	end
})

local Decision <const> = Platformer.Decision
local Sel <const> = Decision.Sel
local Seq <const> = Decision.Seq
local Con <const> = Decision.Con
local Act <const> = Decision.Act

Data.store["AI:playerControl"] = Sel {
	Seq {
		Con("fmove key down", function(self: UnitType): boolean
			return not (self.entity.keyLeft and self.entity.keyRight) and
			(
				(self.entity.keyLeft and self.faceRight) or
				(self.entity.keyRight and not self.faceRight)
			)
		end),
		Act("turn")
	},
	Seq {
		Con("is falling", function(self: UnitType): boolean
			return not self.onSurface
		end),
		Act("fallOff")
	},
	Seq {
		Con("jump key down", function(self: UnitType): boolean
			return self.entity.keyJump as boolean
		end),
		Act("jump")
	},
	Seq {
		Con("fmove key down", function(self: UnitType): boolean
			return (self.entity.keyLeft or self.entity.keyRight) as boolean
		end),
		Act("move")
	},
	Act("idle")
}

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
unitDef.actions = Array {
	"idle",
	"turn",
	"move",
	"jump",
	"fallOff",
	"cancel"
}

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
local type Entity = require("Entity")

Observer("Add", {"player"}):watch(function(self: Entity.Type)
	local unit = Unit(unitDef, world, self, Vec2(300, -350))
	unit.order = PlayerLayer
	unit.group = PlayerGroup
	unit.playable.position = Vec2(0, -150)
	unit.playable:play("idle", true)
	world:addChild(unit)
	world.camera.followTarget = unit
end)

Observer("Add", {"x", "icon"}):watch(function(self: Entity.Type, x: number, icon: string)
	local sprite = Sprite(icon)
	if sprite is nil then
		return
	end

	sprite:schedule(loop(function(): boolean
		sleep(sprite:runAction(Spawn(
			AngleY(5, 0, 360),
			Sequence(
				Y(2.5, 0, 40, Ease.OutQuad),
				Y(2.5, 40, 0, Ease.InQuad)
			)
		)))
	end))

	local bodyDef = BodyDef()
	bodyDef.type = "Dynamic"
	bodyDef.linearAcceleration = Vec2(0, -10)
	bodyDef:attachPolygon(sprite.width * 0.5, sprite.height)
	bodyDef:attachPolygonSensor(0, sprite.width, sprite.height)

	local body = Body(bodyDef, world, Vec2(x, 0))
	body.order = ItemLayer
	body.group = ItemGroup
	body:addChild(sprite)

	body:slot("BodyEnter", function(item: Body.Type)
		if tolua.type(item) == "Platformer::Unit" then
			self.picked = true
			body.group = Data.groupHide
			body:schedule(once(function()
				sleep(sprite:runAction(Spawn(
					Scale(0.2, 1, 1.3, Ease.OutBack),
					Opacity(0.2, 1, 0)
				)))
				self.body = nil
			end))
		end
	end)

	world:addChild(body)
	self.body = body
end)

Observer("Remove", {"body"}):watch(function(self: Entity.Type)
	(self.oldValues.body as Body.Type):removeFromParent()
end)

local Content <const> = require("Content")
local Group <const> = require("Group")
local Utils <const> = require("Utils")
local Struct <const> = Utils.Struct

local record ItemEntity
	name: string
	no: number
	x: number
	icon: string
	num: number
	desc: string
	item: boolean
end

local function loadExcel()
	local xlsx = Content:loadExcel("Data/items.xlsx", {"items"})
	if not xlsx is nil then
		local its = xlsx["items"]
		local names = its[2] as {string}
		table.remove(names, 1)
		if not Struct:has("Item") then
			Struct.Item(names)
		end
		Group{"item"}:each(function(e: Entity.Type): boolean
			e:destroy()
		end)
		for i = 3, #its do
			local st = Struct:load(its[i])
			local item <total>: ItemEntity = {
				name = st.Name as string,
				no = st.No as number,
				x = st.X as number,
				num = st.Num as number,
				icon = st.Icon as string,
				desc = st.Desc as string,
				item = true
			}
			Entity(item)
		end
	end
end

local ImGui <const> = require("ImGui")
local AlignNode <const> = require("UI.Control.Basic.AlignNode")
local CircleButton <const> = require("UI.Control.Basic.CircleButton")
local Menu <const> = require("Menu")
local Keyboard <const> = require("Keyboard")

local keyboardEnabled = true

local playerGroup = Group{"player"}
local function updatePlayerControl(key: string, flag: boolean, vpad: boolean)
	if keyboardEnabled and vpad then
		keyboardEnabled = false
	end
	playerGroup:each(function(self: Entity.Type): boolean
		self[key] = flag
	end)
end

local uiScale = App.devicePixelRatio
local alignNode = AlignNode {
	isRoot = true,
	inUI = true
}
Director.ui:addChild(alignNode)

local leftAlign = AlignNode {
	hAlign = "Left",
	vAlign = "Bottom"
}
alignNode:addChild(leftAlign)

local leftMenu = Menu()
leftAlign:addChild(leftMenu)

local leftButton = CircleButton {
	text = "左(a)",
	x = 20 * uiScale,
	y = 60 * uiScale,
	radius = 30 * uiScale,
	fontSize = math.floor(18 * uiScale)
}
leftButton.anchor = Vec2.zero
leftButton:slot("TapBegan", function()
	updatePlayerControl("keyLeft", true, true)
end)
leftButton:slot("TapEnded", function()
	updatePlayerControl("keyLeft", false, true)
end)
leftMenu:addChild(leftButton)

local rightButton = CircleButton {
	text = "右(d)",
	x = 90 * uiScale,
	y = 60 * uiScale,
	radius = 30 * uiScale,
	fontSize = math.floor(18 * uiScale)
}
rightButton.anchor = Vec2.zero
rightButton:slot("TapBegan", function()
	updatePlayerControl("keyRight", true, true)
end)
rightButton:slot("TapEnded", function()
	updatePlayerControl("keyRight", false, true)
end)
leftMenu:addChild(rightButton)

local rightAlign = AlignNode {
	hAlign = "Right",
	vAlign = "Bottom"
}
alignNode:addChild(rightAlign)

local rightMenu = Menu()
rightAlign:addChild(rightMenu)

local jumpButton = CircleButton {
	text = "跳(j)",
	x = -80 * uiScale,
	y = 60 * uiScale,
	radius = 30 * uiScale,
	fontSize = math.floor(18 * uiScale)
}
jumpButton.anchor = Vec2.zero
jumpButton:slot("TapBegan", function()
	updatePlayerControl("keyJump", true, true)
end)
jumpButton:slot("TapEnded", function()
	updatePlayerControl("keyJump", false, true)
end)
rightMenu:addChild(jumpButton)

alignNode:alignLayout()

alignNode:schedule(function(): boolean
	local keyA = Keyboard:isKeyPressed "A"
	local keyD = Keyboard:isKeyPressed "D"
	local keyJ = Keyboard:isKeyPressed "J"
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

local pickedItemGroup = Group{"picked"}
local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove"
}
Director.ui:schedule(function(): boolean
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
		ImGui.Text("背包")
		ImGui.Separator()
		ImGui.Columns(3, false)
		pickedItemGroup:each(function(e: Entity.Type): boolean
			local item = e as ItemEntity
			if item.num > 0 then
				if ImGui.ImageButton("item" .. tostring(item.no), item.icon, Vec2(50, 50)) then
					item.num = item.num - 1
					local sprite = Sprite(item.icon)
					if sprite is nil then
						return
					end
					sprite.scaleX = 0.5
					sprite.scaleY = 0.5
					sprite:perform(Spawn(
						Opacity(1, 1, 0),
						Y(1, 150, 250)
					))
					local player = playerGroup:find(function(): boolean return true end)
					local unit = player.unit as UnitType
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

Entity {player = true}
loadExcel()
