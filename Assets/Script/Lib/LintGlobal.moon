import insert from table
import Set from require "moonscript.data"
import Block from require "moonscript.compile"
parse = require "moonscript.parse"

default_whitelist = Set {
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

class LinterBlock extends Block
	new: (whitelist_globals=default_whitelist, ...) =>
		super ...
		@globals = {}
		vc = @value_compilers
		@value_compilers = setmetatable {
			ref: (block, val) ->
				name = val[2]
				unless block\has_name(name) or whitelist_globals[name] or name\match "%."
					insert @globals,name
				vc.ref block, val
		}, __index: vc

	block: (...) =>
		with super ...
			.block = @block
			.value_compilers = @value_compilers

LintMoonGlobals = (codes)->
	tree,err = parse.string codes
	return nil,err unless tree
	scope = LinterBlock!
	scope\stms tree
	Set scope.globals

LintMoonGlobals
