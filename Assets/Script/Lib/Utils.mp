_ENV = Dorothy!
import insert,remove,concat,sort from table
import floor,ceil from math
import type,tostring,setmetatable,table,rawset,rawget from _G

StructUpdated = =>
	update = rawget @,"__update"
	if not update
		rawset @,"__update",thread ->
			notify = rawget @,"__notify"
			notify "Updated"
			rawset @,"__update",nil
StructToString = =>
	structDef = getmetatable @
	content = {}
	ordered = true
	count = if #structDef == 0 then #@ else #structDef+1
	for i = 1,count
		value = @[i]
		if value == nil
			ordered = false
			continue
		else
			value = (type(value) == 'string' and "\"#{value}\"" or tostring value)
			if ordered
				insert content,value
			else
				insert content,"[#{i}]=#{value}"
	"{"..(concat content,',').."}"
StructDefMeta = {
	set:(index,item)=>
		index += 1
		if 1 <= index and index <= #@
			@[index] = item
			notify = rawget @,"__notify"
			if notify
				notify "Changed",index-1,item
				StructUpdated @
		else
			error "Access index out of range."
	get:(index)=>
		if 1 <= index and index < #@
			@[index+1]
		else
			nil
	insert:(argA,argB)=>
		local item
		local index
		if argB
			item = argB
			index = argA+1
			if index > #@
				index = #@+1
			elseif index < 1
				index = 1
		else
			item = argA
			index = #@+1
		insert @,index,item
		notify = rawget @,"__notify"
		if notify
			notify "Added",index-1,item
			StructUpdated @
		item
	removefor:(arg)=>
		local item,index
		for i = 2,#@
			if @[i] == arg
				item = arg
				index = i
				remove @,index
				break
		if index
			notify = rawget @,"__notify"
			if notify
				notify "Removed",index-1,item
				StructUpdated @
		item
	remove:(index)=>
		length = #@
		item = if index
			if 0 < index and index < length
				index += 1
				remove @,index
			else
				nil
		else
			if length > 1
				index = length
				remove @,index
			else
				nil
		if item
			notify = rawget @,"__notify"
			if notify
				notify "Removed",index-1,item
				StructUpdated @
		item
	clear:=>
		notify = rawget @,"__notify"
		for index = #@,2,-1
			item = remove @
			if notify
				notify "Removed",index-1,item
				StructUpdated @
	copy:(other)=>
		notify = rawget @,"__notify"
		for index = 2,#other
			item = other[index]
			rawset @,index,item
			if notify
				notify "Added",index-1,item
				StructUpdated @
	each:(handler)=>
		for index = 2,#@
			if true == handler @[index],index-1
				break
	eachPair:(handler)=>
		for i,v in ipairs getmetatable @
			if true == handler v,@[i+1]
				break
	contains:(item)=>
		for index = 2,#@
			if item == @[index]
				return true
		false
	sort:(comparer)=>
		sort @,comparer
	__call:(data)=>
		item = {@__name}
		if data
			for k,v in pairs data
				key = @[k]
				if key
					item[key] = v
				elseif type(k) == "number"
					item[k+1] = v
				else
					error "Initialize to an invalid field named \"#{k}\" for \"#{@}\"."
		setmetatable item,@
		item
	__tostring:=>
		content = {}
		for k,v in pairs @
			if "number" == type v
				content[v-1] = k
		if #content > 1
			concat {"Struct.",@__name,"{\"",concat(content,"\",\""),"\"}"}
		else
			"Struct.#{ @__name }()"
}
StructDefs = {}
StructHelper = {
	__call:(...)=>
		structName = @path..@name
		local tupleDef
		tupleDef = setmetatable {
			__name:structName
			__index:(key)=>
				item = tupleDef[key]
				if item
					rawget @,item
				elseif key == "count"
					#@-1
				else
					StructDefMeta[key]
			__newindex:(key,value)=>
				index = tupleDef[key]
				if index
					rawset @,index,value
					notify = rawget @,"__notify"
					if notify
						notify "Modified",key,value
						StructUpdated @
				elseif "number" == type key
					rawset @,key,value
				elseif key ~= "__notify"
					error "Access invalid key \"#{ key }\" for #{ tupleDef }"
				elseif value
					rawset @,"__notify",value
					if #tupleDef == 0
						for i = 2,#@
							value "Added",i-1,@[i]
					else
						for key in *tupleDef
							value "Modified",key,@[key]
					StructUpdated @
			__tostring:StructToString
		},StructDefMeta
		count = select "#",...
		if count > 0
			if "table" == type select(1,...)
				for i,name in ipairs select(1,...)
					tupleDef[i] = name
					tupleDef[name] = i+1
			else
				for i = 1,count
					name = select i,...
					tupleDef[i] = name
					tupleDef[name] = i+1
		StructDefs[structName] = tupleDef
		tupleDef
	__index:(key)=>
		@path ..= @name
		@path ..= "."
		@name = key
		@
	__tostring:=>
		content = {}
		path = @path..@name.."."
		i = 1
		for k,v in pairs StructDefs
			if k\find path,1,true
				content[i] = tostring v
				i += 1
		concat content,"\n"
}
setmetatable StructHelper,StructHelper
local Struct
StructLoad = (data)->
	if "table" == type data
		setmetatable data,Struct[data[1]]
		for item in *data
			StructLoad item
export Struct = setmetatable {
	load:(arg)=>
		data = switch type arg
			when "string"
				if arg\sub(1,6) ~= "return"
					arg = "return "..arg
				(load arg)!
			when "table"
				arg
		StructLoad data
		data
	loadfile:(filename)=>
		Struct\load Content\load filename
	clear:=>
		StructDefs = {}
},{
	__index:(name)=>
		def = StructDefs[name]
		if not def
			StructHelper.name = name
			StructHelper.path = ""
			def = StructHelper
		def
	__tostring:=>
		concat [tostring v for _,v in pairs StructDefs], "\n"
}

export Set = (list)-> {item,true for item in *list}

export CompareTable = (olds,news)->
	itemsToDel = {}
	itemSet = Set news
	for item in *olds
		if not itemSet[item]
			insert itemsToDel,item
	itemsToAdd = {}
	itemSet = Set olds
	for item in *news
		if not itemSet[item]
			insert itemsToAdd,item
	return itemsToAdd,itemsToDel

export Round = (val)->
	if type(val) == "number"
		val > 0 and floor(val+0.5) or ceil(val-0.5)
	else
		Vec2 val.x > 0 and floor(val.x+0.5) or ceil(val.x-0.5),
			val.y > 0 and floor(val.y+0.5) or ceil(val.y-0.5)

export IsValidPath = (filename)-> not filename\match "[\\/|:*?<>\"]"
