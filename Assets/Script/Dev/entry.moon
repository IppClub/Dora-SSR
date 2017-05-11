Dorothy builtin.ImGui
import Set,Path from require "Utils"
LintGlobal = require "LintGlobal"
moonscript = require "moonscript"
AlignNode = require "UI.Control.Basic.AlignNode"

Content\setSearchPaths {
	Content.writablePath.."Script"
	Content.writablePath.."Script/Lib"
	"Script"
	"Script/Lib"
}

LoadFontTTF "Font/fangzhen16.ttf", 16, "Chinese"

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
	for name,_ in pairs globals
		if not allowedUseOfGlobals[name]
			if builtin[name]
				table.insert requireModules, "local #{name} = require(\"#{name}\")"
			else if builtin.ImGui[name]
				withImGui = true
				table.insert requireModules, "local #{name} = ImGui.#{name}"
			else
				error "Used invalid global value \"#{name}\" in #{entry}."
	table.insert requireModules,1,"local ImGui = require(\"ImGui\")" if withImGui
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
			sourceCodes = Content\loadAsync file
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
				filePath = "#{Content.writablePath}Script/#{path}"
				Content\mkdir filePath
				filename = "#{filePath}#{name}.lua"
				Content\saveAsync filename,codes
				print "#{isXml and "Xml" or "Moon"} compiled: #{path}#{name}.#{isXml and "xml" or "moon"}"
				totalFiles += 1
		else
			filePath = "#{Content.writablePath}Script/#{path}"
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
				sourceCodes = Content\loadAsync file
				startTime = Application.eclapsedTime
				st, ast = ParseLua sourceCodes
				if not st
					print ast
					return false
				codes = FormatMini ast
				totalMinifyTime += Application.eclapsedTime - startTime
				filePath = "#{Content.writablePath}Script/#{path}"
				Content\mkdir filePath
				filename = "#{filePath}#{name}.lua"
				Content\saveAsync filename,codes
				print "Lua minified: #{path}#{name}.lua"
				totalFiles += 1
			else
				filePath = "#{Content.writablePath}Script/#{path}"
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
		print "Output path: #{Content.writablePath}Script"
		xpcall (-> compile "#{Content.assetPath}Script",false,minify),(msg)->
			msg = debug.traceback(msg)
			print msg
			building = false
		print string.format "Compile #{minify and 'and minify ' or ''}done. %d files in total.\nCompile time, Moon %.3fs, Xml %.3fs#{minify and ', Minify %.3fs' or ''}.\n",totalFiles,totalMoonTime,totalXmlTime,totalMinifyTime
		building = false

doClean = ->
	return if building
	building = true
	thread ->
		print "Clean path: #{Content.writablePath}Script"
		compile "#{Content.assetPath}Script",true
		print "Clean done.\n"
		building = false

isInEntry = true

Director.ui = with AlignNode true
	showStats = true
	showLog = true
	showFooter = true
	\schedule ->
		{:width,:height} = Application.size
		SetNextWindowSize Vec2(100,45)
		SetNextWindowPos Vec2(width-100,height-45)
		PushStyleColor "WindowBg", Color(0x0)
		if Begin "Show", "NoTitleBar|NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings"
			_, showFooter = Checkbox "Footer", showFooter
		End!
		PopStyleColor!
		return unless showFooter
		SetNextWindowSize Vec2(width,55)
		SetNextWindowPos Vec2(0,height-55)
		if Begin "Footer", "NoTitleBar|NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings"
			Separator!
			_, showStats = Checkbox "Stats", showStats
			SameLine!
			_, showLog = Checkbox "Log", showLog
			SameLine!
			if Button "Build", Vec2(80,25)
				OpenPopup "build"
			if BeginPopup "build"
				doCompile false if Selectable "Compile"
				Separator!
				doCompile true if Selectable "Minify"
				Separator!
				doClean! if Selectable "Clean"
				EndPopup!
			SameLine!
			if not isInEntry
				SameLine!
				if Button "Back To Entry", Vec2(150,25)
					Director\popToRootEntry!
					isInEntry = true
					for module in *moduleCache
						package.loaded[module] = nil
					moduleCache = {}
					Cache\unload!
			if showStats
				SetNextWindowPos Vec2(0,height-65-296), "FirstUseEver"
				ShowStats!
			if showLog
				SetNextWindowPos Vec2(width-400,height-65-300), "FirstUseEver"
				ShowLog!
		End!

Director\pushEntry with Node!
	examples = [Path.getName item for item in *Content\getFiles Content.assetPath.."Script/Example"]
	\schedule ->
		{:width,:height} = Application.size
		SetNextWindowPos Vec2.zero
		SetNextWindowSize Vec2(width,48)
		PushStyleColor "TitleBgActive", Color(0xcc000000)
		if Begin "Dorothy Dev", "NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings"
			Separator!
		End!
		PopStyleColor!
		SetNextWindowPos Vec2(0,48)
		SetNextWindowSize Vec2(width,height-107)
		PushStyleColor "WindowBg",Color(0x0)
		if Begin "Content", "NoTitleBar|NoResize|NoMove|NoCollapse|NoBringToFrontOnFocus|NoSavedSettings"
			TextColored Color(0xff00ffff), "Examples"
			Columns 5, false
			for example in *examples
				if Button example, Vec2(-1,40)
					isInEntry = false
					xpcall (->
						result = require "Example/#{example}"
						result! if "function" == type result
					),(msg)->
						msg = debug.traceback(msg)
						print msg
						isInEntry = true
						for module in *moduleCache
							package.loaded[module] = nil
						moduleCache = {}
						Cache\unload!
						Director.ui\removeAllChildren!
				NextColumn!
		End!
		PopStyleColor!
