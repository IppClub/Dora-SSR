-- [ts]: materials-lighting.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Camera3D = ____Dora.Camera3D -- 1
local Color = ____Dora.Color -- 1
local Color3 = ____Dora.Color3 -- 1
local DirectionalLight3D = ____Dora.DirectionalLight3D -- 1
local Director = ____Dora.Director -- 1
local Model3D = ____Dora.Model3D -- 1
local Vec3 = ____Dora.Vec3 -- 1
local view = Director.entry -- 3
view:setEnvironmentMap("") -- 4
view:setEnvironmentIntensity(0.22, 0.18, 1) -- 5
local camera = Camera3D() -- 7
camera:lookAt( -- 8
	Vec3(4.8, 3.7, 6.5), -- 8
	Vec3(0, 0.25, 0) -- 8
) -- 8
Director:pushCamera(camera) -- 9
local ground = Model3D("Assets/Model/Ground.gltf") -- 11
ground.position = Vec3(0, -0.72, 0) -- 12
view:addChild(ground) -- 13
local duck = Model3D("Assets/Model/Duck.glb") -- 15
duck.position = Vec3(0, -0.7, 0) -- 16
duck.scale = Vec3(0.8, 0.8, 0.8) -- 17
view:addChild(duck) -- 18
local light = DirectionalLight3D() -- 20
light.color = Color3(16773336) -- 21
light.intensity = 4.5 -- 22
light.angleX = -48 -- 23
light.angleY = -35 -- 24
light.castShadow = true -- 25
light.shadowBias = 0.004 -- 26
light.shadowNormalBias = 0.02 -- 27
light.shadowSoftness = 1 -- 28
view.shadowMapSize = 1024 -- 29
view:addChild(light) -- 30
local material = duck:getMaterial(0) -- 32
if material then -- 32
	material.baseColor = Color(4288403455) -- 34
	material.metallic = 0.15 -- 35
	material.roughness = 0.42 -- 36
end -- 36
return ____exports -- 36