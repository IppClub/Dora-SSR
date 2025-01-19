local Size = require("Size").Type
local Vec2 = require("Vec2").Type
local Color = require("Color").Type

-- 管理应用程序信息的单例类。
local record App
	userdata

	-- 引擎运行到当前时间经过的帧数。
	const frame: integer

	-- 渲染主帧的缓冲纹理的大小。
	const bufferSize: Size

	-- 屏幕的逻辑视觉大小。
	-- 视觉大小仅在应用程序窗口大小更改时更改。
	const visualSize: Size

	-- 设备显示的像素密度比。
	-- 等于渲染缓冲纹理的像素大小除以应用程序窗口的大小。
	const devicePixelRatio: number

	-- 游戏引擎运行的平台类型。
	enum Platform
		"Windows"
		"Android"
		"macOS"
		"iOS"
		"Linux"
		"Unknown"
	end

	-- 游戏引擎当前运行的平台。
	const platform: Platform

	-- 游戏引擎的版本字符串。
	-- 格式为“v0.0.0.0”。
	const version: string

	-- 游戏引擎的第三方依赖库的版本信息。
	const deps: string

	-- 自从上一帧游戏更新以来间隔的时间（以秒为单位）。
	const deltaTime: number

	-- 从当前游戏帧开始到本次API调用经过的时间（以秒为单位）。
	const elapsedTime: number

	-- 游戏引擎直到上一帧结束为止，已经运行的总时间（以秒为单位）。
	-- 在同一个游戏帧中多次调用时得到的是一个常数。
	const totalTime: number

	-- 直到调用该API为止，游戏引擎已经运行的总时间（以秒为单位）。
	-- 在同一个游戏帧中多次调用时得到一个递增的数字。
	const runningTime: number

	-- 基于Mersenne Twister算法生成的随机数。
	-- 由同一种子生成的随机数在每个平台上会保持一致。
	const rand: integer

	-- 游戏引擎可以运行的最大有效帧率。
	-- 最大有效帧率是通过设备屏幕的最大刷新率推断出来的。
	const maxFPS: integer

	-- 游戏引擎是否运行在调试模式下。
	const debugging: boolean

	-- 引擎内置的C++测试的测试名称（用于辅助引擎本身开发）。
	const testNames: {string}

	-- 当前系统的语言环境字符串，格式例如：`zh-Hans`，`en`.
	locale: string

	-- Dora SSR的主题颜色。
	themeColor: Color

	-- Dora SSR的随机数种子。
	seed: integer

	-- 游戏引擎应该运行的目标帧率。
	-- 仅在`fpsLimited`设置为true时有效。
	targetFPS: integer

	-- 游戏引擎是否自动限制帧率。
	-- 将`fpsLimited`设置为true，会使引擎通过执行一个忙等待的死循环以获取更加精准的机器时间，并计算切换到下一帧的时间点。
	-- 这是在PC机Windows系统上的通常做法，以提升CPU占用率来提升游戏的性能。但这也会导致额外的芯片热量产生和电力消耗。
	fpsLimited: boolean

	-- 游戏引擎当前是否处于闲置状态。
	-- 将`idled`设置为true，将使游戏逻辑线程使用`sleep`系统调用来等待进入下一个游戏帧的时间点。
	-- 由于操作系统定时器存在一定程度的误差，可能导致游戏引擎睡眠过头而错过几个游戏帧。
	-- 闲置状态可以减少额外的CPU占用。
	idled: boolean

	-- 游戏引擎是否运行在全屏模式下。
	-- 在Android和iOS平台上无法设置此属性。
	fullScreen: boolean

	-- 游戏引擎是否运行在窗口置顶模式下。
	-- 在Android和iOS平台上无法设置此属性。
	alwayOnTop: boolean

	-- 应用程序窗口大小。
	-- 由于显示设备的DPI不同，可能会与实际的可视大小有差异。
	-- 在Android和iOS平台上无法设置此属性。
	winSize: Size

	-- 应用程序窗口位置。
	-- 在Android和iOS平台上无法设置此属性。
	winPosition: Vec2

	-- 运行特定的包含在引擎中的C++测试函数。
	-- @param name (string) 要运行的测试的名称。
	-- @return (boolean) 测试是否成功运行。
	runTest: function(self: App, name: string): boolean

	-- 在系统默认的浏览器中打开指定的URL地址。
	-- @param url (string) 要打开的URL地址。
	openURL: function(self: App, url: string)

	-- 用于自更新游戏引擎。
	-- @param path (string) 新版本引擎文件的路径。
	install: function(self: App, path: string)

	-- 保存所有引擎日志到指定的文件路径为单个文件。
	-- @param path (string) 要保存日志文件的路径。
	-- @return (boolean) 日志文件是否保存成功。
	saveLog: function(self: App, path: string): boolean

	-- 打开一个文件对话框。仅在Windows、macOS和Linux平台上有效。
	-- @param folderOnly (boolean) 是否仅允许选择文件夹。
	-- @param callback (function) 当文件对话框关闭时调用的回调函数。回调函数应接受一个字符串参数，该参数为选中的文件或文件夹的路径。如果用户取消对话框，则返回空字符串。
	openFileDialog: function(self: App, folderOnly: boolean, callback: function(path: string))

	-- 关闭游戏引擎。
	-- 该函数在Android和iOS平台不会生效，以遵循移动平台上应用程序规范。
	shutdown: function(self: App)
end

-- 全局事件的定义。
-- 这只是一个事件定义的展示，包含所有全局事件名称和回调函数的定义。
-- @usage
-- -- 可以使用如下示例代码注册这些事件：
-- local node = Node():addTo(Director.entry)
-- node:gslot("AppEvent", function(eventType: string)
-- 	print("接收到系统事件：" .. eventType)
-- end)
local record __GSLOT__

	-- 应用收到系统事件时触发。事件类型可以是 "Quit"、"LowMemory"、"WillEnterBackground"、"DidEnterBackground"、"WillEnterForeground"、"DidEnterForeground"。
	["AppEvent"]: function(eventType: string)

	-- 应用设置发生变化时触发。设置名称可以是 "Locale"、"Theme"、"FullScreen"、"Position"、"Size"。
	["AppChange"]: function(settingName: string)

	-- 当一个客户端和应用建立 Websocket 连接时并收发到事件时触发。事件类型可以是 "Open"、"Close"、"Send"、"Receive"。
	["AppWS"]: function(eventType: string, msg: string)
end

local app: App
return app
