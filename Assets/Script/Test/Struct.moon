import "Utils" as {:Struct}

-- 定义Struct
Unit = Struct.Unit "name", "group", "tag", "actions"
Action = Struct.Action "name", "id"
Array = Struct.Array!

-- 创建实例
unit = Unit {
	name: "abc"
	group: 123
	tag: "tagX"
	actions: Array {
		Action name:"walk", id:"a1"
		Action name:"run", id:"a2"
		Action name:"sleep", id:"a3"
	}
}

-- 监听属性变化
unit.__notify = (event, key, value)->
	switch event
		when "Modified"
			print "Value of name \"#{key}\" changed to #{value}."
		when "Updated"
			print "Values updated."

-- 监听列表变化
unit.actions.__notify = (event, index, item)->
	switch event
		when "Added"
			print "Add item #{item} at index #{index}."
		when "Removed"
			print "Remove item #{item} at index #{index}."
		when "Changed"
			print "Change item to #{item} at index #{index}."
		when "Updated"
			print "Items updated."

unit.name = "pig"
unit.actions\insert Action name:"idle", id:"a4"
unit.actions\remove 1

print Struct

-- 清除当前所有的Struct定义
Struct\clear!
