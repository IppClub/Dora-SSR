Dorothy builtin.ImGui
import Set,Path from require "Utils"
LintGlobal = require "LintGlobal"
moonscript = require "moonscript"

LoadFontTTF "Font/DroidSansFallback.ttf", 20--, "Chinese"

moduleCache = {}
oldRequire = _G.require
newRequire = (path)->
	loaded = package.loaded[path]
	if not loaded
		table.insert moduleCache,path
		return oldRequire path
	loaded
_G.require = newRequire
builtin.require = newRequire

allowedUseOfGlobals = Set {
}

LintMoonGlobals = (moonCodes,entry)->
	globals,err = LintGlobal moonCodes
	if not globals
		error "Compile failed in #{entry}\n#{err}"
	requireModules = {}
	withImGui = false
	withPlatformer = false
	for name,_ in pairs globals
		if not allowedUseOfGlobals[name]
			if builtin[name]
				table.insert requireModules, "local #{name} = require(\"#{name}\")"
			else if builtin.Platformer[name]
				if not withPlatformer
					withPlatformer = true
					table.insert requireModules, "local Platformer = require(\"Platformer\")" if withPlatformer
				table.insert requireModules, "local #{name} = Platformer.#{name}"
			else if builtin.ImGui[name]
				if not withImGui
					withImGui = true
					table.insert requireModules, "local ImGui = require(\"ImGui\")" if withImGui
				table.insert requireModules, "local #{name} = ImGui.#{name}"
			else
				error "Used invalid global value \"#{name}\" in #{entry}."
	table.concat requireModules, "\n"

totalFiles = 0
totalMoonTime = 0
totalXmlTime = 0
totalMinifyTime = 0
compile = (dir,clean,minify)->
	{:ParseLua} = require "luaminify.ParseLua"
	FormatMini = require "luaminify.FormatMini"
	files = Path.getAllFiles dir, {"moon","xml"}
	for file in *files
		path = Path.getPath file
		name = Path.getName file
		isXml = "xml" == Path.getExtension file
		compileFunc = isXml and xmltolua or moonscript.to_lua
		requires = nil
		if not clean
			sourceCodes = Content\loadAsync "#{dir}/#{file}"
			requires = LintMoonGlobals sourceCodes, file unless isXml
			startTime = Application.eclapsedTime
			codes,err = compileFunc sourceCodes
			if isXml
				totalXmlTime += Application.eclapsedTime - startTime
			else
				totalMoonTime += Application.eclapsedTime - startTime
			startTime = Application.eclapsedTime
			if not codes
				print "Compile errors in #{file}."
				print err
				return false
			else
				codes = requires..codes\gsub "Dorothy%([^%)]*%)","" unless isXml
				if minify
					st, ast = ParseLua codes
					if not st
						print ast
						return false
					codes = FormatMini ast
				totalMinifyTime += Application.eclapsedTime - startTime
				filePath = Content.writablePath..path
				Content\mkdir filePath
				filename = "#{filePath}#{name}.lua"
				Content\saveAsync filename,codes
				print "#{isXml and "Xml" or "Moon"} compiled: #{path}#{name}.#{isXml and "xml" or "moon"}"
				totalFiles += 1
		else
			filePath = Content.writablePath..path
			Content\mkdir filePath
			filename = "#{filePath}#{name}.lua"
			if Content\exist filename
				print "#{isXml and "Xml" or "Moon"} cleaned: #{path}#{name}.lua"
				Content\remove filename
	if clean or minify
		files = Path.getAllFiles dir, "lua"
		for file in *files
			path = Path.getPath file
			name = Path.getName file
			if not clean
				sourceCodes = Content\loadAsync "#{dir}/#{file}"
				startTime = Application.eclapsedTime
				st, ast = ParseLua sourceCodes
				if not st
					print ast
					return false
				codes = FormatMini ast
				totalMinifyTime += Application.eclapsedTime - startTime
				filePath = Content.writablePath..path
				Content\mkdir filePath
				filename = "#{filePath}#{name}.lua"
				Content\saveAsync filename,codes
				print "Lua minified: #{path}#{name}.lua"
				totalFiles += 1
			else
				filePath = Content.writablePath..path
				Content\mkdir filePath
				filename = "#{filePath}#{name}.lua"
				if Content\exist filename
					print "Lua cleaned: #{path}#{name}.lua"
					Content\remove filename
	return true

building = false

doCompile = (minify)->
	return if building
	building = true
	totalFiles = 0
	totalMoonTime = 0
	totalXmlTime = 0
	totalMinifyTime = 0
	thread ->
		print "Output path: #{Content.writablePath}"
		if Application.platform == "iOS"
			compile Content.assetPath\sub(1,-2),false,minify
		else
			xpcall (-> compile Content.assetPath\sub(1,-2),false,minify),(msg)->
				msg = debug.traceback msg
				print msg
				building = false
		print string.format "Compile #{minify and 'and minify ' or ''}done. %d files in total.\nCompile time, Moon %.3fs, Xml %.3fs#{minify and ', Minify %.3fs' or ''}.\n",totalFiles,totalMoonTime,totalXmlTime,totalMinifyTime
		building = false

doClean = ->
	return if building
	building = true
	thread ->
		print "Clean path: #{Content.writablePath}"
		compile Content.assetPath\sub(1,-2),true
		print "Clean done.\n"
		building = false

isInEntry = true

allClear = ->
	for module in *moduleCache
		package.loaded[module] = nil
	moduleCache = {}
	with Director.ui
		\removeAllChildren!
		.userData = nil
	with Director.entry
		\removeAllChildren!
		.userData = nil
	with Director.postNode
		\removeAllChildren!
		.userData = nil
	Director\popCamera!
	Cache\unload!
	Entity\clear!
	currentEntryName = nil
	isInEntry = true

examples = [Path.getName item for item in *Path.getAllFiles Content.assetPath.."Script/Example", {"xml","lua","moon"}]
table.sort examples
tests = [Path.getName item for item in *Path.getAllFiles Content.assetPath.."Script/Test", {"xml","lua","moon"}]
table.sort tests
currentEntryName = nil
allNames = for example in *examples do "Example/#{example}"
for test in *tests do table.insert allNames,"Test/#{test}"

enterDemoEntry = (name)->
	isInEntry = false
	xpcall (->
		result = require name
		if "function" == type result
			result = result!
			Director.entry\addChild if tolua.cast result, "Node"
				result
			else
				Node!
		else
			Director.entry\addChild Node!
		currentEntryName = name
	),(msg)->
		msg = debug.traceback msg
		print msg
		allClear!

showStats = true
showLog = true
showFooter = true
scaleContent = false
screenScale = Application.size.width/Application.designSize.width
threadLoop ->
	Application\shutdown! if Keyboard\isKeyDown "Escape"
	{:width,:height} = Application.designSize
	SetNextWindowSize Vec2(190,50)
	SetNextWindowPos Vec2(width-190,height-50)
	PushStyleColor "WindowBg", Color(0x0)
	if Begin "Show", "NoTitleBar|NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings"
		Columns 2,false
		Dummy Vec2 10,30
		SameLine!
		if showFooter
			changed, scaleContent = Checkbox string.format("%.1fx",screenScale), scaleContent
			View.scale = scaleContent and screenScale or 1 if changed
		NextColumn!
		_, showFooter = Checkbox "Footer", showFooter
	End!
	PopStyleColor!
	return unless showFooter
	SetNextWindowSize Vec2(width,60)
	SetNextWindowPos Vec2(0,height-60)
	if Begin "Footer", "NoTitleBar|NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings"
		Separator!
		_, showStats = Checkbox "Stats", showStats
		SameLine!
		_, showLog = Checkbox "Log", showLog
		SameLine!
		if isInEntry and Button "Build", Vec2(70,30)
			OpenPopup "build"
		if isInEntry and BeginPopup "build"
			doCompile false if Selectable "Compile"
			Separator!
			doCompile true if Selectable "Minify"
			Separator!
			doClean! if Selectable "Clean"
			EndPopup!
		if not isInEntry
			SameLine!
			allClear! if Button "Home", Vec2(70,30)
			currentIndex = 1
			for i,name in ipairs allNames
				if currentEntryName == name
					currentIndex = i
			SameLine!
			if currentIndex > 1
				if Button "Prev", Vec2(70,30)
					allClear!
					isInEntry = false
					thread -> enterDemoEntry allNames[currentIndex-1]
			else Dummy Vec2 70,30
			SameLine!
			if currentIndex < #allNames
				if Button "Next", Vec2(70,30)
					allClear!
					isInEntry = false
					thread -> enterDemoEntry allNames[currentIndex+1]
			else Dummy Vec2 70,30
		if showStats
			SetNextWindowPos Vec2(0,height-65-296), "FirstUseEver"
			ShowStats!
		if showLog
			SetNextWindowPos Vec2(width-400,height-65-300), "FirstUseEver"
			ShowLog!
	End!

threadLoop ->
	return unless isInEntry
	{:width,:height} = Application.designSize
	SetNextWindowPos Vec2.zero
	SetNextWindowSize Vec2(width,53)
	PushStyleColor "TitleBgActive", Color(0xcc000000)
	if Begin "Dorothy Dev", "NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings"
		Separator!
	End!
	PopStyleColor!
	SetNextWindowPos Vec2(0,53)
	SetNextWindowSize Vec2(width,height-107)
	PushStyleColor "WindowBg",Color(0x0)
	if Begin "Content", "NoTitleBar|NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings"
		TextColored Color(0xff00ffff), "Examples"
		Columns math.floor(width/200), false
		for example in *examples
			if Button example, Vec2(-1,40)
				enterDemoEntry "Example/#{example}"
			NextColumn!
		Columns 1, false
		TextColored Color(0xff00ffff), "Tests"
		Columns math.floor(width/200), false
		for test in *tests
			if Button test, Vec2(-1,40)
				enterDemoEntry "Test/#{test}"
			NextColumn!
	End!
	PopStyleColor!
