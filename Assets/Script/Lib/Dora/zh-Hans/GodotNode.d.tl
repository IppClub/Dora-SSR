local Sprite = require("Sprite").Type
local Size = require("Size").Type

-- 将 Godot 项目离屏画面显示为 Dora Sprite，启动异步完成。
local record GodotNode
    embed Sprite
    readonly projectPath: string
    readonly sceneFile: string
    readonly lastError: string
    readonly running: boolean
    readonly paused: boolean
    readonly viewportSize: Size
    pause: function(self: GodotNode)
    resume: function(self: GodotNode)
    restart: function(self: GodotNode, sceneFile?: string): boolean
    resizeViewport: function(self: GodotNode, width: integer, height: integer): boolean
    sendPointer: function(self: GodotNode, x: number, y: number, button: integer, pressed: boolean)
    sendPointerMove: function(self: GodotNode, x: number, y: number)
    sendKey: function(self: GodotNode, name: string, pressed: boolean)
    sendText: function(self: GodotNode, text: string)
end
local record GodotNodeClass
    getUnsupportedReason: function(): string
    type Type = GodotNode
    metamethod __call: function(self: GodotNodeClass, projectPath: string, sceneFile?: string, width?: integer, height?: integer, buffers?: integer): GodotNode | nil
end
local godotNodeClass: GodotNodeClass
return godotNodeClass
