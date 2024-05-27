-- [yue]: Script/Test/Text.yue
local View = Dora.View -- 1
local math = _G.math -- 1
local App = Dora.App -- 1
local AlignNode = Dora.AlignNode -- 1
local tostring = _G.tostring -- 1
local Vec2 = Dora.Vec2 -- 1
local Size = Dora.Size -- 1
local Label = Dora.Label -- 1
local LineRect = require("UI.View.Shape.LineRect") -- 2
local ScrollArea = require("UI.Control.Basic.ScrollArea") -- 3
local viewWidth, viewHeight -- 5
do -- 5
	local _obj_0 = View.size -- 5
	viewWidth, viewHeight = _obj_0.width, _obj_0.height -- 5
end -- 5
local width, height = viewWidth - 200, viewHeight - 20 -- 7
local fontSize = math.floor(20 * App.devicePixelRatio) -- 9
local root = AlignNode() -- 11
do -- 12
	local _obj_0 = View.size -- 12
	width, height = _obj_0.width, _obj_0.height -- 12
end -- 12
root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 13
root:gslot("AppSizeChanged", function() -- 14
	do -- 15
		local _obj_0 = View.size -- 15
		width, height = _obj_0.width, _obj_0.height -- 15
	end -- 15
	return root:css("width: " .. tostring(width) .. "; height: " .. tostring(height)) -- 16
end) -- 14
root:addChild((function() -- 17
	local _with_0 = ScrollArea({ -- 18
		width = width, -- 18
		height = height, -- 19
		paddingX = 0, -- 20
		paddingY = 50, -- 21
		viewWidth = height, -- 22
		viewHeight = height -- 23
	}) -- 17
	_with_0.border = LineRect({ -- 25
		width = width, -- 25
		height = height, -- 25
		color = 0xffffffff -- 25
	}) -- 25
	_with_0.area:addChild(_with_0.border) -- 26
	root:slot("AlignLayout", function(w, h) -- 27
		_with_0.position = Vec2(w / 2, h / 2) -- 28
		w = w - 200 -- 29
		h = h - 20 -- 30
		_with_0.view.children.first.textWidth = w - fontSize -- 31
		_with_0:adjustSizeWithAlign("Auto", 10, Size(w, h)) -- 32
		_with_0.area:removeChild(_with_0.border) -- 33
		_with_0.border = LineRect({ -- 34
			width = w, -- 34
			height = h, -- 34
			color = 0xffffffff -- 34
		}) -- 34
		return _with_0.area:addChild(_with_0.border) -- 35
	end) -- 27
	_with_0.view:addChild((function() -- 36
		local _with_1 = Label("sarasa-mono-sc-regular", fontSize) -- 36
		_with_1.alignment = "Left" -- 37
		_with_1.textWidth = width - fontSize -- 38
		_with_1.text = [[# 贡献指南

&emsp;&emsp;非常感谢您对Dora SSR的兴趣和支持！我们欢迎任何人为这个项目做出贡献。以下是一些建议和指南，以帮助您开始参与项目的贡献。

<br>

## 报告问题

&emsp;&emsp;如果您在使用Dora SSR时发现了问题，请在GitHub仓库中提交一个Issue。在提交Issue之前，请确保：

1. 查看已有的Issue，避免重复报告。

2. 详细描述问题，包括预期行为和实际发生的行为。

3. 如果可能，请提供一个简单的重现问题的示例代码。

<br>

## 功能建议

&emsp;&emsp;我们非常欢迎您对Dora SSR提出新功能的建议。在提交功能建议之前，请确保：

1. 您的建议与Dora SSR的目标和愿景保持一致。

2. 提供足够的细节，以便我们理解您的需求和建议的实现方式。

<br>

## 代码贡献

&emsp;&emsp;如果您想要为Dora SSR贡献代码，请遵循以下步骤：

1. **Fork 项目**：

   Fork 项目仓库。

2. **创建分支**：

   在本地创建一个新的分支，以便进行更改。

3. **从源代码构建**：

   通过参考[从源代码构建的文档](https://dora-ssr.net/zh-Hans/docs/tutorial/dev-configuration)，熟悉项目从源代码编译的过程。

4. **进行编码**：

   编写代码并确保代码符合项目的编码规范。

   **编码风格指南：**

   - 我们希望遵循同一种编码书写的风格，以保持项目的一致性和可读性。我们的风格定义在位于[此处](Tools/Format/.clang-format)的 clang-format 配置文件中。
   - 提交代码之前，请确保对代码运行 clang-format 对代码做格式化的处理。

5. **提交和推送**：

   提交更改并将它们推送到您的 fork 仓库。

6. **提交 Pull Request**：

   创建一个 Pull Request，详细描述你的更改及其理由。

<br>

## 贡献文档

&emsp;&emsp;文档对于开源项目的成功至关重要。如果您发现了文档中的错误，或者您认为可以改进文档，请提交Issue或Pull Request。

<br>

## 社区支持

&emsp;&emsp;您可以通过回答问题、提供教程和示例项目等方式为社区提供支持。如果您有任何可以帮助其他开发者的资源，请分享在社区相关的论坛和聊天室中。

<br>

------

&emsp;&emsp;希望这个贡献指南能帮助您开始参与Dora SSR项目。再次感谢您的支持，期待您的贡献！]] -- 39
		return _with_1 -- 36
	end)()) -- 36
	_with_0:adjustSizeWithAlign() -- 117
	return _with_0 -- 17
end)()) -- 17
return root -- 11
