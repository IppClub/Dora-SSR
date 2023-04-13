local Platformer <const> = require("Platformer")
local ImGui <const> = require("ImGui")
local Rectangle <const> = require("UI.View.Shape.Rectangle")
local Utils <const> = require("Utils")
local Vec2 <const> = require("Vec2")
local Rect <const> = require("Rect")
local BodyDef <const> = require("BodyDef")
local Body <const> = require("Body")
local Director <const> = require("Director")
local Dictionary <const> = require("Dictionary")
local Size <const> = require("Size")
local Array <const> = require("Array")
local AlignNode <const> = require("UI.Control.Basic.AlignNode")
local CircleButton <const> = require("UI.Control.Basic.CircleButton")
local App <const> = require("App")
local Group <const> = require("Group")
local Menu <const> = require("Menu")
local Keyboard <const> = require("Keyboard")
local Content <const> = require("Content")
local Color <const> = require("Color")

local Struct <const> = Utils.Struct
local Decision <const> = Platformer.Decision
local Sel <const> = Decision.Sel
local Seq <const> = Decision.Seq
local Con <const> = Decision.Con
local Act <const> = Decision.Act
local Reject <const> = Decision.Reject
local Data <const> = Platformer.Data

local PlayerGroup = 1
local TerrainLayer = 0

local themeColor = App.themeColor
local fillColor = Color(themeColor:toColor3(), 0x66):toARGB()
local borderColor = themeColor:toARGB()

local world = Platformer.PlatformWorld()
world.camera.boundary = Rect(-1250, -500, 2500, 1000)
world.camera.followRatio = Vec2(0.01, 0.01)

local terrainDef = BodyDef()
terrainDef.type = "Static"
terrainDef:attachPolygon(Vec2(0, -500), 2500, 10, 0, 1, 1, 0)
terrainDef:attachPolygon(Vec2(0, 500), 2500, 10, 0, 1, 1, 0)
terrainDef:attachPolygon(Vec2(1250, 0), 10, 1000, 0, 1, 1, 0)
terrainDef:attachPolygon(Vec2(-1250, 0), 10, 1000, 0, 1, 1, 0)

local body = Body(terrainDef, world, Vec2.zero)
body.order = TerrainLayer
body.group = Data.groupTerrain
body:addChild(Rectangle{
	y = -500,
	width = 2500,
	height = 10,
	fillColor = fillColor,
	borderColor = borderColor,
	fillOrder = 1,
	lineOrder = 2
})
body:addChild(Rectangle{
	x = 1250,
	y = 0,
	width = 10,
	height = 1000,
	fillColor = fillColor,
	borderColor = borderColor,
	fillOrder = 1,
	lineOrder = 2
})
body:addChild(Rectangle{
	x = -1250,
	y = 0,
	width = 10,
	height = 1000,
	fillColor = fillColor,
	borderColor = borderColor,
	fillOrder = 1,
	lineOrder = 2
})
world:addChild(body)
Director.entry:addChild(world)

local Unit = Platformer.Unit
local UnitAction = Platformer.UnitAction
local type Routine = require("Routine")
local sleep = require("sleep")

UnitAction:add("idle", {
	priority = 1,
	reaction = 2.0,
	recovery = 0.2,
	available = function(self: Unit.Type): boolean
		return self.onSurface
	end,
	create = function(self: Unit.Type): (
			function(owner: Unit.Type, action: UnitAction.Type, deltaTime: number): (boolean)
			| Routine.Job
		)
		local playable = self.playable
		playable.speed = 1.0
		playable:play("idle", true)
		local playIdleSpecial = coroutine.create(function()
			while true do
				sleep(3)
				sleep(playable:play("idle1"))
				playable:play("idle", true)
			end
		end)
		self.data.playIdleSpecial = playIdleSpecial
		return function(self: Unit.Type): boolean
			coroutine.resume(playIdleSpecial)
			return not self.onSurface
		end
	end
})

UnitAction:add("fmove", {
	priority = 1,
	reaction = 2.0,
	recovery = 0.2,
	available = function(self: Unit.Type): boolean
		return self.onSurface
	end,
	create = function(self: Unit.Type): (
			function(owner: Unit.Type, action: UnitAction.Type, deltaTime: number): (boolean)
			| Routine.Job
		)
		local playable = self.playable
		playable.speed = 1
		playable:play("fmove", true)
		return function(self: Unit.Type, action: UnitAction.Type): boolean
			local eclapsedTime = action.eclapsedTime
			local recovery = action.recovery
			local move = self.unitDef.move as number
			local moveSpeed: number = 1.0
			if eclapsedTime < recovery then
				moveSpeed = math.min(eclapsedTime / recovery, 1.0)
			end
			self.velocityX = moveSpeed * (self.faceRight and move or -move)
			return not self.onSurface
		end
	end
})

Data.store["AI_PlayerControl"] = Sel {
	Seq {
		Sel {
			Seq {
				Con("fmove key down", function(self: Unit.Type): boolean
					return not (self.entity.keyLeft and self.entity.keyRight) and
					(
						(self.entity.keyLeft and self.faceRight) or
						(self.entity.keyRight and not self.faceRight)
					)
				end),
				Act("turn")
			}
		},
		Reject()
	},
	Seq {
		Con("fmove key down", function(self: Unit.Type): boolean
			return self.entity.keyLeft as boolean or self.entity.keyRight as boolean
		end),
		Act("fmove")
	},
	Act("idle")
}

local unitDef = Dictionary()
unitDef.linearAcceleration = Vec2(0, -15)
unitDef.bodyType = "Dynamic"
unitDef.scale = 1.0
unitDef.density = 1.0
unitDef.friction = 1.0
unitDef.restitution = 0.0
unitDef.playable = "spine:Spine/moling"
unitDef.defaultFaceRight = true
unitDef.size = Size(100, 300)
unitDef.sensity = 0
unitDef.move = 300
unitDef.jump = 1200
unitDef.detectDistance = 350
unitDef.hp = 5.0
unitDef.tag = "player"
unitDef.decisionTree = "AI_PlayerControl"
unitDef.usePreciseHit = false
unitDef.actions = Array {
	"idle",
	"turn",
	"fmove",
	"cancel"
}

local Entity = require("Entity")
Entity { player = true }
local entity = Group{"player"}:find(function(): boolean return true end)
local unit = Unit(unitDef, world, entity, Vec2(300, -350))
unit.group = PlayerGroup
unit.playable.position = Vec2(0, -150)
unit.playable:play("idle", true)
world:addChild(unit)
world.camera.followTarget = unit
world.camera.followRatio = Vec2(0.02, 0.02)

world:setShouldContact(PlayerGroup, PlayerGroup, true)

local keyboardEnabled = true

local playerGroup = Group {"player"}
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

alignNode:schedule(function(): boolean
	local keyA = Keyboard:isKeyPressed "A"
	local keyD = Keyboard:isKeyPressed "D"
	if keyD or keyD then
		keyboardEnabled = true
	end
	if not keyboardEnabled then
		return false
	end
	updatePlayerControl("keyLeft", keyA, false)
	updatePlayerControl("keyRight", keyD, false)
	return false
end)
--world.showDebug = true
local Observer = require("Observer")
local Sprite = require("Sprite")
local Spawn = require("Spawn")
local AngleY = require("AngleY")
local Sequence = require("Sequence")
local Y = require("Y")
local Scale = require("Scale")
local Opacity = require("Opacity")
local Ease = require("Ease")
local Event = require("Event")
local tolua = require("tolua")
local record PackItem
	no: number
	icon: string
	name: string
	num: number
	desc: string
end

local backpack: {PackItem} = {}
Observer("Add", {"x","icon","no","name","num","desc"}):watch(function(self: Entity.Type, x: number, icon: string, no: number, name: string, num: number, desc: string)
	local sprite = Sprite(icon);
	local bodyDef = BodyDef()
	bodyDef.type = "Dynamic"
	bodyDef.linearAcceleration = Vec2(0, -10)
	bodyDef:attachPolygon(sprite.width * 0.5, sprite.height)
	bodyDef:attachPolygonSensor(0, sprite.width, sprite.height)
	local b = Body(bodyDef, world, Vec2(x, 0))
	b:slot("BodyEnter", function(item: Body.Type)
		if tolua.type(item) == "Platformer::Unit" then
			table.insert(backpack, {no = no, icon = icon, name = name, num = num, desc = desc})
			b.group = Data.groupHide
			sprite:runAction(Sequence(
				Spawn(
					Scale(0.2, 1, 1.3, Ease.OutBack),
					Opacity(0.2, 1, 0)
				),
				Event("End")
			))
			sprite:slot("End", function()
				self:destroy()
			end)
		end
	end)
	b.group = PlayerGroup
	b:addChild(sprite)
	local action = Sequence(
		Spawn(
			AngleY(5, 0, 360),
			Sequence(
				Y(2.5, 0, 40, Ease.OutQuad),
				Y(2.5, 40, 0, Ease.InQuad))
			),
		Event("Stop")
	)
	sprite:runAction(action)
	sprite:slot("Stop", function()
		sprite:runAction(action)
	end)
	world:addChild(b)
	self.body = b
end)

Observer("Remove", {"body"}):watch(function(self: Entity.Type)
	(self.oldValues.body as Body.Type):removeFromParent()
end)

local function loadExcel()
	local xlsx = Content:loadExcel("Data/items.xlsx", {"items"})
	if not xlsx is nil then
		local its = xlsx["items"]
		local names = its[2]
		table.remove(names, 1)
		if not Struct:has("Item") then
			Struct.Item(names as {string})
		end
		table.remove(its, 1)
		table.remove(its, 1)
		Group{"item"}:each(function(e: Entity.Type): boolean
			e:destroy()
			return false
		end)
		for i = 1, #its do
			local st = Struct:load(its[i])
			Entity {
				name = st.Name as string,
				x = st.X as number,
				no = st.No as number,
				num = st.Num as number,
				icon = st.Icon as string,
				desc = st.Desc as string,
				item = true
			}
		end
	end
end

loadExcel()

local windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove"
}
world:schedule(function(): boolean
	local size = App.visualSize
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(size.width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(100, 300), "FirstUseEver")
	ImGui.Begin("BackPack", windowFlags, function()
		if ImGui.Button("重新加载Excel") then
			backpack = {}
			loadExcel()
		end
		ImGui.Separator()
		ImGui.Dummy(Vec2(100, 10))
		ImGui.Text("背包")
		ImGui.Separator()
		ImGui.Columns(3, false)
		for i = 1, #backpack do
			local item = backpack[i]
			if item.num > 0 then
				ImGui.ImageButton("item" .. tostring(item.no), item.icon, Vec2(50, 50))
				if ImGui.IsItemHovered() then
					if ImGui.IsItemClicked() then
						item.num = item.num - 1
						local sprite = Sprite(item.icon)
						sprite.scaleX = 0.5
						sprite.scaleY = 0.5
						sprite:perform(Spawn(
							Opacity(1, 1, 0),
							Y(1, 150, 250)
						))
						unit:addChild(sprite)
					end
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
		end
	end)
	return false
end)