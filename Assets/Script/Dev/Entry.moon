Dorothy builtin.ImGui
import Set,Path from require "Utils"

debug.traceback = (err)->
	with require "StackTracePlus"
		.dump_locals = false
		.simplified = true
		return .stacktrace err, 1

LoadFontTTF "Font/sarasa-mono-sc-regular.ttf", 20, "Chinese"

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
	'_G'
	'_VERSION'
	'assert'
	'collectgarbage'
	'coroutine'
	'debug'
	'dofile'
	'error'
	'getfenv'
	'getmetatable'
	'ipairs'
	'load'
	'loadfile'
	'loadstring'
	'module'
	'next'
	'package'
	'pairs'
	'pcall'
	'print'
	'rawequal'
	'rawget'
	'rawlen'
	'rawset'
	'require'
	'select'
	'setfenv'
	'setmetatable'
	'string'
	'table'
	'tonumber'
	'tostring'
	'type'
	'unpack'
	'xpcall'
	"nil"
	"true"
	"false"
	'math'

	"Dorothy"
	"builtin"
}

LintMoonGlobals = (moonCodes,globals,entry)->
	requireModules = {}
	withImGui = false
	withPlatformer = false
	importCodes = table.concat (
		for importLine in moonCodes\gmatch "Dorothy%s*%(?([^%)!\r\n]*)%s*[%)!]?"
			continue if importLine == ""
			importLine
		), ","
	importItems = if importCodes
		for item in importCodes\gmatch "%s*([^,\n\r]+)%s*"
			getImport = loadstring "return #{item}"
			importItem = if getImport then getImport! else nil
			continue if not importItem or "table" ~= type importItem
			{importItem, item}
	else {}
	importSet = {}
	for var in *globals
		{name,line,col} = var
		if not allowedUseOfGlobals[name]
			if builtin[name]
				table.insert requireModules, "local #{name} = require(\"#{name}\") -- 1"
			else
				findModule = false
				for i,importItem in ipairs importItems
					if importItem[1][name] ~= nil
						moduleName = "_module_#{i-1}"
						if not importSet[importItem[1]]
							importSet[importItem[1]] = true
							table.insert requireModules, "local #{moduleName} = #{importItem[2]} -- 1"
						table.insert requireModules, "local #{name} = #{moduleName}.#{name} -- 1"
						findModule = true
						break
				if not findModule
					countLine = 1
					code = nil
					for lineCode in moonCodes\gmatch "[^\n]*\n"
						if countLine == line
							code = lineCode
							break
						countLine += 1
					error "Used invalid global value \"#{name}\"\nin \"#{entry}\", at line #{line}, col #{col}.\n#{code\gsub("\t"," ")..string.rep(" ",col-1).."^"}"
	table.concat requireModules, "\n"

totalFiles = 0
totalMoonTime = 0
totalXmlTime = 0
totalMinifyTime = 0
compile = (dir,minify)->
	{:ParseLua} = require "luaminify.ParseLua"
	FormatMini = require "luaminify.FormatMini"
	pathLen = #Content.assetPath
	files = Path.getAllFiles dir, {"moon","xml"}
	for file in *files
		path = Path.getPath file
		name = Path.getName file
		isXml = "xml" == Path.getExtension file
		sourceCodes = Content\loadAsync "#{dir}/#{file}"
		startTime = App.eclapsedTime
		codes,err = nil,nil
		requires = ""
		if isXml
			codes,err = xmltolua sourceCodes
			totalXmlTime += App.eclapsedTime - startTime
		else
			codes,err,globals = moontolua sourceCodes, lint_global:true
			requires = LintMoonGlobals(sourceCodes,globals,file) unless isXml
			requires ..= "\n" unless requires == ""
			totalMoonTime += App.eclapsedTime - startTime
		startTime = App.eclapsedTime
		if not codes
			print "Compile errors in #{file}."
			print err
			return false
		else
			codes = "-- [moon]: #{file}\n"..requires..codes\gsub "Dorothy%([^%)]*%)[^\r\n]*[\r\n]*","" unless isXml
			if minify
				st, ast = ParseLua codes
				if not st
					print "Compile errors in #{file}."
					print ast
					return false
				codes = FormatMini ast
			totalMinifyTime += App.eclapsedTime - startTime
			filePath = Content.writablePath..path
			Content\mkdir filePath
			filename = "#{filePath}#{name}.lua"
			Content\saveAsync filename,codes
			print "#{isXml and "Xml" or "Moon"} compiled: #{path}#{name}.#{isXml and "xml" or "moon"}"
			totalFiles += 1
	if minify
		files = Path.getAllFiles dir, "lua"
		for file in *files
			path = Path.getPath file
			name = Path.getName file
			sourceCodes = Content\loadAsync "#{dir}/#{file}"
			startTime = App.eclapsedTime
			st, ast = ParseLua sourceCodes
			if not st
				print ast
				return false
			codes = FormatMini ast
			totalMinifyTime += App.eclapsedTime - startTime
			filePath = Content.writablePath..path
			Content\mkdir filePath
			filename = "#{filePath}#{name}.lua"
			Content\saveAsync filename,codes
			print "Lua minified: #{path}#{name}.lua"
			totalFiles += 1
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
		xpcall (-> compile Content.assetPath\sub(1,-2),minify),(msg)->
			msg = debug.traceback msg
			print msg
			building = false
		print string.format "Compile #{minify and 'and minify ' or ''}done. %d files in total.\nCompile time, Moon %.3fs, Xml %.3fs#{minify and ', Minify %.3fs' or ''}.\n",totalFiles,totalMoonTime,totalXmlTime,totalMinifyTime
		building = false

doClean = ->
	return if building
	targetDir = "#{Content.writablePath}Script/"
	if Content\exist targetDir
		Path.removeFolder targetDir
		print "Cleaned: #{targetDir}"
	else
		print "Nothing to clean."

isInEntry = true
currentEntryName = nil

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
	Platformer.Data\clear!
	Platformer.UnitAction\clear!
	currentEntryName = nil
	isInEntry = true
	Audio\stopStream 0.2

games = [Path.getName item for item in *Path.getFolders Content.assetPath.."Script/Game", {"xml","lua","moon"}]
table.sort games
examples = [Path.getName item for item in *Path.getAllFiles Content.assetPath.."Script/Example", {"xml","lua","moon"}]
table.sort examples
tests = [Path.getName item for item in *Path.getAllFiles Content.assetPath.."Script/Test", {"xml","lua","moon"}]
table.sort tests
allNames = for game in *games do "Game/#{game}/init"
for example in *examples do table.insert allNames,"Example/#{example}"
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

showEntry = false

thread ->
	{:width,:height} = App.visualSize
	scale = App.deviceRatio*0.7*math.min(width,height)/760
	if false
		with Sprite GetDorothySSRHappyWhite scale
			\addTo Director.entry
			sleep 1.0
			\removeFromParent!
	showEntry = true
	Director.clearColor = Color 0xff1a1a1a

showStats = false
showLog = true
showFooter = true
scaleContent = false
footerFocus = false
screenScale = 2 -- App.deviceRatio
threadLoop ->
	return unless showEntry
	left = Keyboard\isKeyDown "Left"
	right = Keyboard\isKeyDown "Right"
	App\shutdown! if Keyboard\isKeyDown "Escape"
	{:width,:height} = App.visualSize
	SetNextWindowSize Vec2(190,50)
	SetNextWindowPos Vec2(width-190,height-50)
	if width >= 600
		if not footerFocus
			footerFocus = true
			SetNextWindowFocus!
		PushStyleColor "WindowBg", Color(0x0), ->
			Begin "Show", "NoTitleBar|NoResize|NoMove|NoCollapse|NoSavedSettings", ->
				Columns 2,false
				if showFooter
					changed, scaleContent = Checkbox string.format("%.1fx",screenScale), scaleContent
					View.scale = scaleContent and screenScale or 1 if changed
				else
					Dummy Vec2 10,30
				SameLine!
				NextColumn!
				_, showFooter = Checkbox "Footer", showFooter
	elseif footerFocus
		footerFocus = false
	return unless showFooter
	SetNextWindowSize Vec2(width,60)
	SetNextWindowPos Vec2(0,height-60)
	Begin "Footer", "NoTitleBar|NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings", ->
		Separator!
		_, showStats = Checkbox "Stats", showStats
		SameLine!
		_, showLog = Checkbox "Log", showLog
		SameLine!
		if isInEntry
			OpenPopup "build" if Button "Build", Vec2(70,30)
			BeginPopup "build", ->
				doCompile false if Selectable "Compile"
				Separator!
				doCompile true if Selectable "Minify"
				Separator!
				doClean! if Selectable "Clean"
		else
			SameLine!
			allClear! if Button "Home", Vec2(70,30)
			currentIndex = 1
			for i,name in ipairs allNames
				if currentEntryName == name
					currentIndex = i
			SameLine!
			if currentIndex > 1
				if Button("Prev", Vec2(70,30)) or left
					allClear!
					isInEntry = false
					thread -> enterDemoEntry allNames[currentIndex-1]
			else Dummy Vec2 70,30
			SameLine!
			if currentIndex < #allNames
				if Button("Next", Vec2(70,30)) or right
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

threadLoop ->
	return unless showEntry
	return unless isInEntry
	{:width,:height} = App.visualSize
	SetNextWindowPos Vec2.zero
	SetNextWindowSize Vec2(width,53)
	PushStyleColor "TitleBgActive", Color(0xcc000000), ->
		Begin "Dorothy Dev", "NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings", ->
			Separator!
	SetNextWindowPos Vec2(0,53)
	SetNextWindowSize Vec2(width,height-107)
	PushStyleColor "WindowBg",Color(0x0), ->
		Begin "Content", "NoTitleBar|NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings", ->
			TextColored Color(0xff00ffff), "Game Demos"
			Columns math.max(math.floor(width/200),1), false
			for game in *games
				if Button game, Vec2(-1,40)
					enterDemoEntry "Game/#{game}/init"
				NextColumn!
			Columns 1, false
			TextColored Color(0xff00ffff), "Examples"
			Columns math.max(math.floor(width/200),1), false
			for example in *examples
				if Button example, Vec2(-1,40)
					enterDemoEntry "Example/#{example}"
				NextColumn!
			Columns 1, false
			TextColored Color(0xff00ffff), "Tests"
			Columns math.max(math.floor(width/200),1), false
			for test in *tests
				if Button test, Vec2(-1,40)
					enterDemoEntry "Test/#{test}"
				NextColumn!
