local licenseText = [[/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */]]
local lulpeg = require("lulpeg")
lulpeg:global(_G)
local nonObjectTypes = { }
local cppTypes = {
	i32 = "int32_t",
	i64 = "int64_t",
	f32 = "float",
	f64 = "double"
}
local callbackDefs = {
	string = "String"
}
local interfaces = {
	Object = true,
	Node = true,
	Joint = true,
	Camera = true,
	Playable = true,
	PhysicsWorld = true,
	Body = true
}
local inheritances = {
	IPlayable = {
		"INode"
	},
	IPhysicsWorld = {
		"INode"
	},
	IBody = {
		"INode"
	},
	ISprite = {
		"INode"
	}
}
local basicTypes = {
	bool = {
		"i32",
		function(name)
			return tostring(name) .. " != 0"
		end,
		function(name)
			return tostring(name) .. " ? 1 : 0"
		end,
		"bool",
		"bool",
		function(name)
			return "if " .. tostring(name) .. " { 1 } else { 0 }"
		end,
		function(name)
			return tostring(name) .. " != 0"
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_bool().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_bool(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return tostring(name) .. " != 0"
			end,
			convertTo = function(name)
				return "ToDoraBool(" .. tostring(name) .. ")"
			end,
			argType = "bool",
			returnType = "bool",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopBool()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	uint8_t = {
		"i32",
		function(name)
			return "s_cast<uint8_t>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"i32",
		"i32",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_i32().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_i32(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "i32",
			returnType = "i32",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopI32()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	uint16_t = {
		"i32",
		function(name)
			return "s_cast<uint16_t>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"i32",
		"i32",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_i32().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_i32(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "i32",
			returnType = "i32",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopI32()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	uint32_t = {
		"i32",
		function(name)
			return "s_cast<uint32_t>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"i32",
		"i32",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_i32().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_i32(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "i32",
			returnType = "i32",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopI32()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	int32_t = {
		"i32",
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"i32",
		"i32",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_i32().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_i32(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "i32",
			returnType = "i32",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopI32()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	int = {
		"i32",
		function(name)
			return "s_cast<int>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"i32",
		"i32",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_i32().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_i32(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "i32",
			returnType = "i32",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopI32()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	uint64_t = {
		"i64",
		function(name)
			return "s_cast<uint64_t>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int64_t>(" .. tostring(name) .. ")"
		end,
		"i64",
		"i64",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_i64().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_i64(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "i64",
			returnType = "i64",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopI64()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	int64_t = {
		"i64",
		function(name)
			return "s_cast<int64_t>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int64_t>(" .. tostring(name) .. ")"
		end,
		"i64",
		"i64",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_i64().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_i64(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "i64",
			returnType = "i64",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopI64()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	size_t = {
		"i64",
		function(name)
			return "s_cast<int64_t>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int64_t>(" .. tostring(name) .. ")"
		end,
		"i64",
		"i64",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_i64().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_i64(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "i64",
			returnType = "i64",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopI64()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	float = {
		"f32",
		function(name)
			return "s_cast<float>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"f32",
		"f32",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_f32().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_f32(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "f32",
			returnType = "f32",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopF32()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	double = {
		"f64",
		function(name)
			return "s_cast<double>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<double>(" .. tostring(name) .. ")"
		end,
		"f64",
		"f64",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_f64().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_f64(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "f64",
			returnType = "f64",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopF64()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	string = {
		"i64",
		function(name)
			return "*Str_From(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Str_Retain(" .. tostring(name) .. ")"
		end,
		"&str",
		"String",
		function(name)
			return "crate::dora::from_string(" .. tostring(name) .. ")"
		end,
		function(name)
			return "crate::dora::to_string(" .. tostring(name) .. ")"
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_str().unwrap().as_str()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_str(" .. tostring(name) .. ".as_str());"
		end,
		{
			convertFrom = function(name)
				return "FromDoraString(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return "ToDoraString(" .. tostring(name) .. ")"
			end,
			argType = "string",
			returnType = "string",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopStr()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	Vec2 = {
		"i64",
		function(name)
			return "Vec2_From(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Vec2_Retain(" .. tostring(name) .. ")"
		end,
		"&crate::dora::Vec2",
		"crate::dora::Vec2",
		function(name)
			return tostring(name) .. ".into_i64()"
		end,
		function(name)
			return "crate::dora::Vec2::from(" .. tostring(name) .. ")"
		end,
		function(fnArgId)
			return "&stack" .. tostring(fnArgId) .. ".pop_vec2().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_vec2(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return "Vec2FromValue(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "Vec2",
			returnType = "Vec2",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopVec2()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	Size = {
		"i64",
		function(name)
			return "Size_From(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Size_Retain(" .. tostring(name) .. ")"
		end,
		"&crate::dora::Size",
		"crate::dora::Size",
		function(name)
			return tostring(name) .. ".into_i64()"
		end,
		function(name)
			return "crate::dora::Size::from(" .. tostring(name) .. ")"
		end,
		function(fnArgId)
			return "&stack" .. tostring(fnArgId) .. ".pop_size().unwrap()"
		end,
		function(name, fnArgId)
			return "stack" .. tostring(fnArgId) .. ".push_size(" .. tostring(name) .. ");"
		end,
		{
			convertFrom = function(name)
				return "SizeFromValue(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "Size",
			returnType = "Size",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopSize()"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ")"
			end
		}
	},
	Color = {
		"i32",
		function(name)
			return "Color(s_cast<uint32_t>(" .. tostring(name) .. "))"
		end,
		function(name)
			return tostring(name) .. ".toARGB()"
		end,
		"&crate::dora::Color",
		"crate::dora::Color",
		function(name)
			return tostring(name) .. ".to_argb() as i32"
		end,
		function(name)
			return "crate::dora::Color::from(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "NewColor(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToARGB()"
			end,
			argType = "Color",
			returnType = "Color",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	Color3 = {
		"i32",
		function(name)
			return "Color3(s_cast<uint32_t>(" .. tostring(name) .. "))"
		end,
		function(name)
			return tostring(name) .. ".toRGB()"
		end,
		"&crate::dora::Color3",
		"crate::dora::Color3",
		function(name)
			return tostring(name) .. ".to_rgb() as i32"
		end,
		function(name)
			return "crate::dora::Color3::from(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "NewColor3(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToRGB()"
			end,
			argType = "Color3",
			returnType = "Color3",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	Rect = {
		"i64",
		function(name)
			return "*r_cast<Rect*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(new Rect{" .. tostring(name) .. "})"
		end,
		"&crate::dora::Rect",
		"crate::dora::Rect",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::Rect::from(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*RectFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "Rect",
			returnType = "Rect",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	OptString = {
		"i64",
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		"Option<String>",
		"String",
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_str()"
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function()
				return error("unsupported")
			end,
			convertTo = function()
				return error("unsupported")
			end,
			argType = "*string",
			returnType = "*string",
			creturn = function(name, fnArgId)
				return tostring(name) .. ": *string = nil\n		" .. tostring(name) .. "_, " .. tostring(name) .. "_ok := stack" .. tostring(fnArgId) .. ".PopStr()\n		if " .. tostring(name) .. "_ok {\n			" .. tostring(name) .. " = &" .. tostring(name) .. "_\n		}"
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	NVGpaint = {
		"i64",
		function(name)
			return "*r_cast<NVGpaint*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(new NVGpaint{" .. tostring(name) .. "})"
		end,
		"&crate::dora::VGPaint",
		"crate::dora::VGPaint",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::VGPaint::from(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*VGPaintFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "VGPaint",
			returnType = "VGPaint",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	DBParams = {
		"i64",
		function(name)
			return "*r_cast<DBParams*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(new DBParams{})"
		end,
		"crate::dora::DBParams",
		"crate::dora::DBParams",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::DBParams::from(" .. tostring(name) .. ")"
		end,
		function(fnArgId)
			return "crate::dora::DBParams::from(stack" .. tostring(fnArgId) .. ".pop_i64().unwrap())"
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*DBParamsFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "DBParams",
			returnType = "DBParams",
			creturn = function(name, fnArgId)
				return tostring(name) .. "_raw, _ := stack" .. tostring(fnArgId) .. ".PopI64()\n\t\t" .. tostring(name) .. " := *DBParamsFrom(" .. tostring(name) .. "_raw)"
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	DBRecord = {
		"i64",
		function(name)
			return "*r_cast<DBRecord*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(new DBRecord{" .. tostring(name) .. "})"
		end,
		"crate::dora::DBRecord",
		"crate::dora::DBRecord",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::DBRecord::from(" .. tostring(name) .. ")"
		end,
		function(fnArgId)
			return "crate::dora::DBRecord::from(stack" .. tostring(fnArgId) .. ".pop_i64().unwrap())"
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*DBRecordFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "DBRecord",
			returnType = "DBRecord",
			creturn = function(name, fnArgId)
				return tostring(name) .. "_raw, _ := stack" .. tostring(fnArgId) .. ".PopI64()\n\t\t" .. tostring(name) .. " := *DBRecordFrom(" .. tostring(name) .. "_raw)"
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	DBQuery = {
		"i64",
		function(name)
			return "*r_cast<DBQuery*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(new DBQuery{})"
		end,
		"crate::dora::DBQuery",
		"crate::dora::DBQuery",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::DBQuery::from(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*DBQueryFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "DBQuery",
			returnType = "DBQuery",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	WorkBook = {
		"i64",
		function(name)
			return "*r_cast<WorkBook*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(new WorkBook{" .. tostring(name) .. "})"
		end,
		"crate::dora::WorkBook",
		"crate::dora::WorkBook",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::WorkBook::from(" .. tostring(name) .. ")"
		end,
		function(fnArgId)
			return "crate::dora::WorkBook::from(stack" .. tostring(fnArgId) .. ".pop_i64().unwrap())"
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*WorkBookFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "WorkBook",
			returnType = "WorkBook"
		}
	},
	WorkSheet = {
		"i64",
		function(name)
			return "*r_cast<WorkSheet*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(new WorkSheet{" .. tostring(name) .. "})"
		end,
		"crate::dora::WorkSheet",
		"crate::dora::WorkSheet",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::WorkSheet::from(" .. tostring(name) .. ")"
		end,
		function(fnArgId)
			return "crate::dora::WorkSheet::from(stack" .. tostring(fnArgId) .. ".pop_i64().unwrap())"
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*WorkSheetFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "WorkSheet",
			returnType = "WorkSheet"
		}
	},
	VecStr = {
		"i64",
		function(name)
			return "Vec_FromStr(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Vec_To(" .. tostring(name) .. ")"
		end,
		"&Vec<&str>",
		"Vec<String>",
		function(name)
			return "crate::dora::Vector::from_str(" .. tostring(name) .. ")"
		end,
		function(name)
			return "crate::dora::Vector::to_str(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "FromDoraStrBuf(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return "ToDoraStrBuf(" .. tostring(name) .. ")"
			end,
			argType = "*[]string",
			returnType = "*[]string",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	VecVec2 = {
		"i64",
		function(name)
			return "Vec_FromVec2(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Vec_To(" .. tostring(name) .. ")"
		end,
		"&Vec<crate::dora::Vec2>",
		"Vec<crate::dora::Vec2>",
		function(name)
			return "crate::dora::Vector::from_vec2(" .. tostring(name) .. ")"
		end,
		function(name)
			return "crate::dora::Vector::to_vec2(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "FromDoraVec2Buf(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return "ToDoraVec2Buf(" .. tostring(name) .. ")"
			end,
			argType = "*[]Vec2",
			returnType = "*[]Vec2",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	VecUint32 = {
		"i64",
		function(name)
			return "Vec_FromUint32(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Vec_To(" .. tostring(name) .. ")"
		end,
		"&Vec<i32>",
		"Vec<i32>",
		function(name)
			return "crate::dora::Vector::from_num(" .. tostring(name) .. ")"
		end,
		function(name)
			return "crate::dora::Vector::to_num(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "FromDoraI32Buf(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return "ToDoraI32Buf(" .. tostring(name) .. ")"
			end,
			argType = "*[]i32",
			returnType = "*[]i32",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	VecFloat = {
		"i64",
		function(name)
			return "Vec_FromFloat(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Vec_To(" .. tostring(name) .. ")"
		end,
		"&Vec<f32>",
		"Vec<f32>",
		function(name)
			return "crate::dora::Vector::from_num(" .. tostring(name) .. ")"
		end,
		function(name)
			return "crate::dora::Vector::to_num(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "FromDoraF32Buf(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return "ToDoraF32Buf(" .. tostring(name) .. ")"
			end,
			argType = "*[]f32",
			returnType = "*[]f32",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	VertexColor = {
		"i64",
		function(name)
			return "*r_cast<VertexColor*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(new VertexColor{" .. tostring(name) .. "})"
		end,
		"&crate::dora::VertexColor",
		"crate::dora::VertexColor",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::VertexColor::from(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*VertexColor(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "VertexColor",
			returnType = "VertexColor",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	VecVertexColor = {
		"i64",
		function(name)
			return "Vec_FromVertexColor(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Vec_To(" .. tostring(name) .. ")"
		end,
		"&Vec<crate::dora::VertexColor>",
		"Vec<crate::dora::VertexColor>",
		function(name)
			return "crate::dora::Vector::from_vertex_color(" .. tostring(name) .. ")"
		end,
		function(name)
			return "crate::dora::Vector::to_vertex_color(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "FromDoraVertexColorBuf(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return "ToDoraVertexColorBuf(" .. tostring(name) .. ")"
			end,
			argType = "*[]VertexColor",
			returnType = "*[]VertexColor",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	ActionDef = {
		"i64",
		function(name)
			return "std::move(*r_cast<ActionDef*>(" .. tostring(name) .. "))"
		end,
		function(name)
			return "r_cast<int64_t>(new ActionDef{" .. tostring(name) .. "})"
		end,
		"crate::dora::ActionDef",
		"crate::dora::ActionDef",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::ActionDef::from(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*ActionDefFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "ActionDef",
			returnType = "ActionDef",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	VecActionDef = {
		"i64",
		function(name)
			return "Vec_FromActionDef(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Vec_To(" .. tostring(name) .. ")"
		end,
		"&Vec<crate::dora::ActionDef>",
		"Vec<crate::dora::ActionDef>",
		function(name)
			return "crate::dora::Vector::from_action_def(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function()
				return error("unsupported")
			end,
			convertTo = function(name)
				return "ToDoraActionDefBuf(" .. tostring(name) .. ")"
			end,
			argType = "*[]ActionDef",
			returnType = "*[]ActionDef",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	VecBTree = {
		"i64",
		function(name)
			return "Vec_FromBtree(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Vec_To(" .. tostring(name) .. ")"
		end,
		"&Vec<crate::dora::platformer::behavior::Tree>",
		"Vec<crate::dora::platformer::behavior::Tree>",
		function(name)
			return "crate::dora::Vector::from_btree(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function()
				return error("unsupported")
			end,
			convertTo = function(name)
				return "ToDoraPlatformerBehaviorTreeBuf(" .. tostring(name) .. ")"
			end,
			argType = "*[]PlatformerBehaviorTree",
			returnType = "*[]PlatformerBehaviorTree",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	VecDTree = {
		"i64",
		function(name)
			return "Vec_FromDtree(" .. tostring(name) .. ")"
		end,
		function(name)
			return "Vec_To(" .. tostring(name) .. ")"
		end,
		"&Vec<crate::dora::platformer::decision::Tree>",
		"Vec<crate::dora::platformer::decision::Tree>",
		function(name)
			return "crate::dora::Vector::from_dtree(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function()
				return error("unsupported")
			end,
			convertTo = function(name)
				return "ToDoraPlatformerDecisionTreeBuf(" .. tostring(name) .. ")"
			end,
			argType = "*[]PlatformerDecisionTree",
			returnType = "*[]PlatformerDecisionTree",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	BlendFunc = {
		"i64",
		function(name)
			return "BlendFunc(s_cast<uint64_t>(" .. tostring(name) .. "))"
		end,
		function(name)
			return "s_cast<int64_t>(" .. tostring(name) .. ".toValue())"
		end,
		"crate::dora::BlendFunc",
		"crate::dora::BlendFunc",
		function(name)
			return tostring(name) .. ".to_value()"
		end,
		function(name)
			return "crate::dora::BlendFunc::from(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "BlendFuncFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "BlendFunc",
			returnType = "BlendFunc",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	MLQState = {
		"i64",
		function(name)
			return "s_cast<MLQState>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int64_t>(" .. tostring(name) .. ")"
		end,
		"u64",
		"u64",
		function(name)
			return tostring(name) .. " as i64"
		end,
		function(name)
			return tostring(name) .. " as u64"
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_i64().unwrap() as u64"
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "i64",
			returnType = "i64",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopI64()"
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	MLQAction = {
		"i32",
		function(name)
			return "s_cast<MLQAction>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"u32",
		"u32",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return tostring(name) .. " as u32"
		end,
		function(fnArgId)
			return "stack" .. tostring(fnArgId) .. ".pop_i32().unwrap() as u32"
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return name
			end,
			convertTo = function(name)
				return name
			end,
			argType = "i32",
			returnType = "i32",
			creturn = function(name, fnArgId)
				return tostring(name) .. ", _ := stack" .. tostring(fnArgId) .. ".PopI32()"
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	EntityEvent = {
		"i32",
		function(name)
			return "s_cast<int>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"crate::dora::EntityEvent",
		"crate::dora::EntityEvent",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "EntityEvent{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "EntityEvent",
			returnType = "EntityEvent",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	TextureWrap = {
		"i32",
		function(name)
			return "s_cast<TextureWrap>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"crate::dora::TextureWrap",
		"crate::dora::TextureWrap",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "TextureWrap{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "TextureWrap",
			returnType = "TextureWrap",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	TextureFilter = {
		"i32",
		function(name)
			return "s_cast<TextureFilter>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"crate::dora::TextureFilter",
		"crate::dora::TextureFilter",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "TextureFilter{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "TextureFilter",
			returnType = "TextureFilter",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	ComputeAccess = {
		"i32",
		function(name)
			return "s_cast<ComputeAccess>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"crate::dora::ComputeAccess",
		"crate::dora::ComputeAccess",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "ComputeAccess{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "ComputeAccess",
			returnType = "ComputeAccess",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	EaseType = {
		"i32",
		function(name)
			return "s_cast<Ease::Enum>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"crate::dora::EaseType",
		"crate::dora::EaseType",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "EaseType{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "EaseType",
			returnType = "EaseType",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	Property = {
		"i32",
		function(name)
			return "s_cast<Property::Enum>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"crate::dora::Property",
		"crate::dora::Property",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "Property{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "Property",
			returnType = "Property",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	TextAlign = {
		"i32",
		function(name)
			return "s_cast<TextAlign>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"crate::dora::TextAlign",
		"crate::dora::TextAlign",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "TextAlign{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "TextAlign",
			returnType = "TextAlign",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	BodyType = {
		"i32",
		function(name)
			return name
		end,
		function(name)
			return name
		end,
		"crate::dora::BodyType",
		"crate::dora::BodyType",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "BodyType{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "BodyType",
			returnType = "BodyType",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	ShaderStage = {
		"i32",
		function(name)
			return "s_cast<ShaderStage>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"crate::dora::ShaderStage",
		"crate::dora::ShaderStage",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "ShaderStage{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "ShaderStage",
			returnType = "ShaderStage",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	["Platformer::Relation"] = {
		"i32",
		function(name)
			return "s_cast<Platformer::Relation>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"crate::dora::platformer::Relation",
		"crate::dora::platformer::Relation",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "PlatformerRelation{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "PlatformerRelation",
			returnType = "PlatformerRelation",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	["Platformer::Behavior::Blackboard"] = {
		"i64",
		function(name)
			return "*r_cast<Platformer::Behavior::Blackboard*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(" .. tostring(name) .. ")"
		end,
		"&crate::dora::platformer::behavior::Blackboard",
		"crate::dora::platformer::behavior::Blackboard",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::platformer::behavior::Blackboard::from(" .. tostring(name) .. ")"
		end,
		function(fnArgId)
			return "&crate::dora::platformer::behavior::Blackboard::from(stack" .. tostring(fnArgId) .. ".pop_i64().unwrap()).unwrap()"
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*PlatformerBehaviorBlackboardFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "PlatformerBehaviorBlackboard",
			returnType = "PlatformerBehaviorBlackboard",
			creturn = function(name, fnArgId)
				return tostring(name) .. "_raw, _ := stack" .. tostring(fnArgId) .. ".PopI64()\n\t\t" .. tostring(name) .. " := *PlatformerBehaviorBlackboardFrom(" .. tostring(name) .. "_raw)"
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	["Platformer::UnitAction"] = {
		"i64",
		function(name)
			return "*r_cast<Platformer::UnitAction*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(" .. tostring(name) .. ")"
		end,
		"&crate::dora::platformer::UnitAction",
		"crate::dora::platformer::UnitAction",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name, isOptional)
			return "crate::dora::platformer::UnitAction::from(" .. tostring(name) .. ")" .. tostring(isOptional and '' or '.unwrap()')
		end,
		function(fnArgId)
			return "&crate::dora::platformer::UnitAction::from(stack" .. tostring(fnArgId) .. ".pop_i64().unwrap()).unwrap()"
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name, isOptional)
				return tostring(isOptional and '' or '*') .. "PlatformerUnitActionFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "PlatformerUnitAction",
			returnType = "PlatformerUnitAction",
			creturn = function(name, fnArgId)
				return tostring(name) .. "_raw, _ := stack" .. tostring(fnArgId) .. ".PopI64()\n\t\t" .. tostring(name) .. " := *PlatformerUnitActionFrom(" .. tostring(name) .. "_raw)"
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	["Platformer::TargetAllow"] = {
		"i64",
		function(name)
			return "*r_cast<Platformer::TargetAllow*>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "r_cast<int64_t>(new Platformer::TargetAllow{" .. tostring(name) .. "})"
		end,
		"&crate::dora::platformer::TargetAllow",
		"crate::dora::platformer::TargetAllow",
		function(name)
			return tostring(name) .. ".raw()"
		end,
		function(name)
			return "crate::dora::platformer::TargetAllow::from(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "*PlatformerTargetAllowFrom(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = "PlatformerTargetAllow",
			returnType = "PlatformerTargetAllow",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	["AttenuationModel"] = {
		"i32",
		function(name)
			return "s_cast<AudioSource::AttenuationModel>(" .. tostring(name) .. ")"
		end,
		function(name)
			return "s_cast<int32_t>(" .. tostring(name) .. ")"
		end,
		"crate::dora::AttenuationModel",
		"crate::dora::AttenuationModel",
		function(name)
			return tostring(name) .. " as i32"
		end,
		function(name)
			return "core::mem::transmute(" .. tostring(name) .. ")"
		end,
		function()
			return error("unsupported")
		end,
		function()
			return error("unsupported")
		end,
		{
			convertFrom = function(name)
				return "AttenuationModel{value: " .. tostring(name) .. "}"
			end,
			convertTo = function(name)
				return tostring(name) .. ".ToValue()"
			end,
			argType = "AttenuationModel",
			returnType = "AttenuationModel",
			creturn = function()
				return error("unsupported")
			end,
			cpass = function()
				return error("unsupported")
			end
		}
	},
	void = { }
}
local _anon_func_0 = function(name)
	local _accum_0 = { }
	local _len_0 = 1
	for sub in (name:sub(1, 1):lower() .. name:sub(2)):gsub("%d", "_%1"):gsub("%u", "_%1"):gsub("(%d)_", "%1"):gmatch("[^_]*") do
		_accum_0[_len_0] = sub:lower()
		_len_0 = _len_0 + 1
	end
	return _accum_0
end
local toSnakeCase
toSnakeCase = function(name)
	local snakeName = table.concat(_anon_func_0(name), "_")
	if snakeName:match("_80node$") then
		snakeName = snakeName:gsub("_80node$", "80_node")
	end
	return snakeName
end
local snakeToPascal
snakeToPascal = function(snakeStr)
	local prefix
	if "_" == snakeStr:sub(1, 1) then
		prefix = "_"
	else
		prefix = ""
	end
	local pascalName = prefix .. snakeStr:gsub("_([%a%d])", function(letter)
		return letter:upper()
	end):gsub("^%l", function(first)
		return first:upper()
	end)
	return pascalName:gsub("3d", "3D"):gsub("Ui", "UI")
end
local WaTypeIndex <const> = 10
local getWaType
getWaType = function(dataType, waName)
	if dataType == "void" then
		return nil
	end
	local t
	do
		local _obj_0 = basicTypes[dataType]
		if _obj_0 ~= nil then
			t = _obj_0[WaTypeIndex]
		end
	end
	if not waName then
		if "*" == dataType:sub(-1) then
			waName = dataType:match("[^ \t*]+")
		end
	end
	if waName then
		waName = snakeToPascal(waName:gsub("::", "_"))
	elseif not t then
		print("missing type def:", dataType)
	end
	if t == nil then
		t = {
			convertFrom = function(name)
				return "*" .. tostring(waName) .. "From(" .. tostring(name) .. ")"
			end,
			convertTo = function(name)
				return tostring(name) .. ".GetRaw()"
			end,
			argType = waName,
			returnType = waName and tostring(waName) or "",
			creturn = function(name, fnArgId)
				return tostring(name) .. "_obj := stack" .. tostring(fnArgId) .. ".PopObject()\n		ObjectRetain(" .. tostring(name) .. "_obj.GetRaw())\n		" .. tostring(name) .. " := *" .. tostring(waName) .. "From(" .. tostring(name) .. "_obj.GetRaw())"
			end,
			cpass = function(name, fnArgId)
				return "stack" .. tostring(fnArgId) .. ".Push(" .. tostring(name) .. ".Object)"
			end
		}
	end
	return t
end
local lastPos = 1
local Newline = Cmt(P("\r") ^ -1 * P("\n"), function(str, pos)
	lastPos = pos
	return true
end)
local White = (S(" \t") + Newline) ^ 0
local AlphaNum = R("az", "AZ", "09", "__")
local Indent = R("az", "AZ", "__") * AlphaNum ^ 0
local Name = C(R("az", "AZ", "__") * (AlphaNum + ":") ^ 0)
local ClassName = C((Indent * White * P("::") * White) ^ 0 * Indent)
local ClassLabel = C(P("singleton")) + (C(P("interface")) ^ -1 * White * C(P("object"))) + C(P("value")) + P("")
local FieldLabel = C(P("static")) ^ -1 * White * C(P("optional")) ^ -1 * White * C(P("readonly")) ^ -1 * White * C(P("common") + P("boolean")) ^ -1
local MethodLabel = C(P("static")) ^ -1 * White * C(P("outside")) ^ -1 * White * C(P("optional")) ^ -1
local FuncLabel = C(P("def_true") + P("def_false") + P("")) ^ -1
local Type = C((Indent * White * P("::") * White) ^ 0 * Indent * (White * P("*")) ^ -1)
local Doc = C(P("///") * (-Newline * P(1)) ^ 0)
local Docs = White * Ct((Doc * White) ^ 0)
local mark
mark = function(name)
	return function(...)
		return {
			name,
			...
		}
	end
end
local Param = P({
	"Param",
	Param = V("Func") * White * Name / mark("callback") + Type * White * Name / mark("variable"),
	Func = Ct(P("function<") * White * FuncLabel * White * Type * White * Ct(P("(") * White * (V("Param") * (White * P(",") * White * V("Param")) ^ 0 * White) ^ -1 * P(")") * White * P(">")))
})
local Method = Docs * Ct(White * MethodLabel) * White * Type * White * (C(P("operator==")) + Name) * White * (P("@") * White * Name + Cc(false)) * White * Ct(P("(") * White * (Param * (White * P(",") * White * Param) ^ 0 * White) ^ -1 * P(")")) * White * C(P("const")) ^ -1 * White * P(";") / mark("method")
local Field = Docs * Ct(White * FieldLabel) * White * Type * White * Name * White * (P("@") * White * Name + Cc(false)) * White * P(";") / mark("field")
local Class = White * Ct(Docs * Ct(White * ClassLabel) * White * (P("class") + P("struct")) * White * Ct(Name * White * (P("@") * White * Name + Cc(false)) * White * (P(":") * White * (P("public")) ^ -1 * White * ClassName * White + Cc(false))) * P("{") * Ct((White * (Method + Field)) ^ 0 * White * P("}") * White * P(";")))
local ModStart = White * P("namespace") * White * Name * White * P("{")
local ModStop = White * P("}") * Cc(false)
local File = Ct((ModStart + Class + ModStop) ^ 1 * White * -1)
local codes = ""
do
	local _with_0 = io.open("Dora.h", "r")
	codes = _with_0:read("*a")
	_with_0:close()
end
local result = match(File, codes)
if not result then
	if lastPos > #codes then
		lastPos = #codes - 1
	end
	local line = 1
	local begin = 0
	for i = 1, #codes do
		if i > lastPos then
			break
		end
		if codes:sub(i, i) == '\n' then
			line = line + 1
			begin = i
		end
	end
	local following = codes:sub(begin + 1)
	local lineStr = following:match("(.-)\n") or following:match(".*$")
	print(tostring(line) .. ": syntax error:")
	return print(lineStr)
else
	local cppBinding = { }
	local cppLink = { }
	local rustExtern = { }
	local rustBinding = { }
	local waExtern = { }
	local waBinding = { }
	local nameMap = { }
	local getObjectType
	getObjectType = function(dataType, rustName, isCreate, isOptional)
		if isCreate then
			return {
				"i64",
				function(name)
					return "r_cast<" .. tostring(dataType) .. "*>(" .. tostring(name) .. ")"
				end,
				function(name)
					return nonObjectTypes[rustName] and "r_cast<int64_t>(" .. tostring(name) .. ")" or "Object_From(" .. tostring(name) .. ")"
				end,
				"&" .. tostring(rustName),
				isOptional and "Option<" .. tostring(rustName) .. ">" or rustName,
				function(name)
					return tostring(name) .. ".raw()"
				end,
				function(name)
					return isOptional and tostring(rustName) .. "::from(" .. tostring(name) .. ")" or tostring(rustName) .. " { raw: " .. tostring(name) .. " }"
				end,
				function()
					return error("unsupported")
				end,
				function()
					return error("unsupported")
				end
			}
		elseif isOptional then
			return {
				"i64",
				function(name)
					return "r_cast<" .. tostring(dataType) .. "*>(" .. tostring(name) .. ")"
				end,
				function(name)
					return nonObjectTypes[rustName] and "r_cast<int64_t>(" .. tostring(name) .. ")" or "Object_From(" .. tostring(name) .. ")"
				end,
				interfaces[rustName] and "&dyn crate::dora::I" .. tostring(rustName) or "&crate::dora::" .. tostring(rustName),
				"Option<crate::dora::" .. tostring(rustName) .. ">",
				function(name)
					return tostring(name) .. ".raw()"
				end,
				function(name)
					return "crate::dora::" .. tostring(rustName) .. "::from(" .. tostring(name) .. ")"
				end,
				function(fnArgId)
					return "&stack" .. tostring(fnArgId) .. ".pop_cast::<crate::dora::" .. tostring(rustName) .. ">()"
				end,
				function(name, fnArgId)
					return "stack" .. tostring(fnArgId) .. ".push_object(&" .. tostring(name) .. ");"
				end
			}
		else
			return {
				"i64",
				function(name)
					return "r_cast<" .. tostring(dataType) .. "*>(" .. tostring(name) .. ")"
				end,
				function(name)
					return nonObjectTypes[rustName] and "r_cast<int64_t>(" .. tostring(name) .. ")" or "Object_From(" .. tostring(name) .. ")"
				end,
				interfaces[rustName] and "&dyn crate::dora::I" .. tostring(rustName) or "&crate::dora::" .. tostring(rustName),
				"crate::dora::" .. tostring(rustName),
				function(name)
					return tostring(name) .. ".raw()"
				end,
				function(name)
					return "crate::dora::" .. tostring(rustName) .. "::from(" .. tostring(name) .. ").unwrap()"
				end,
				function(fnArgId)
					return "&stack" .. tostring(fnArgId) .. ".pop_cast::<crate::dora::" .. tostring(rustName) .. ">().unwrap()"
				end,
				function(name, fnArgId)
					return "stack" .. tostring(fnArgId) .. ".push_object(&" .. tostring(name) .. ");"
				end
			}
		end
	end
	local moduleScopes = { }
	for _index_0 = 1, #result do
		local cls = result[_index_0]
		if "string" == type(cls) then
			moduleScopes[#moduleScopes + 1] = cls
			goto _continue_0
		elseif not cls then
			table.remove(moduleScopes, #moduleScopes)
			goto _continue_0
		end
		local clsNames = cls[3]
		local clsName, clsNewName = clsNames[1], clsNames[2]
		clsNewName = clsNewName or clsName
		if #moduleScopes > 0 then
			local moduleScope = table.concat(moduleScopes, "::")
			local rustModuleScope = table.concat((function()
				local _accum_0 = { }
				local _len_0 = 1
				for _index_1 = 1, #moduleScopes do
					local mod = moduleScopes[_index_1]
					_accum_0[_len_0] = toSnakeCase(mod)
					_len_0 = _len_0 + 1
				end
				return _accum_0
			end)(), "::")
			nameMap[moduleScope .. "::" .. clsName] = rustModuleScope .. "::" .. clsNewName
		else
			nameMap[clsName] = clsNewName
		end
		::_continue_0::
	end
	moduleScopes = { }
	local clsCount = 0
	local funcCount = 0
	for _index_0 = 1, #result do
		local cls = result[_index_0]
		local waRuntime = false
		if "string" == type(cls) then
			moduleScopes[#moduleScopes + 1] = cls
			goto _continue_1
		elseif not cls then
			table.remove(moduleScopes, #moduleScopes)
			goto _continue_1
		end
		clsCount = clsCount + 1
		local namespace
		if #moduleScopes > 0 then
			namespace = table.concat((function()
				local _accum_0 = { }
				local _len_0 = 1
				for _index_1 = 1, #moduleScopes do
					local mod = moduleScopes[_index_1]
					_accum_0[_len_0] = toSnakeCase(mod)
					_len_0 = _len_0 + 1
				end
				return _accum_0
			end)(), "_") .. "_"
		else
			namespace = ""
		end
		local cppNamespace
		if #moduleScopes > 0 then
			cppNamespace = table.concat(moduleScopes, "::") .. "::"
		else
			cppNamespace = ""
		end
		local clsDocs, clsLabels, clsNames, clsBody = cls[1], cls[2], cls[3], cls[4]
		local clsName, clsNewName, clsParent = clsNames[1], clsNames[2], clsNames[3]
		if clsParent then
			clsParent = nameMap[clsParent] or clsParent
		end
		clsNewName = clsNewName or clsName
		local waNewName <const> = (cppNamespace .. clsNewName):gsub("::", "")
		local isSingleton = false
		local isObject = false
		local isValue = false
		local isTrait = false
		local singletonName = nil
		for _index_1 = 1, #clsLabels do
			local label = clsLabels[_index_1]
			if "singleton" == label then
				isSingleton = true
				singletonName = "Shared" .. tostring(clsName)
			elseif "object" == label then
				isObject = true
			elseif "value" == label then
				isValue = true
			elseif "interface" == label then
				isTrait = true
			end
		end
		local moduleName = toSnakeCase(clsNewName):gsub("_(%l)_", "%1"):gsub("_(%l)$", "%1")
		local clsNameL = clsName:lower()
		local clsNewNameL = clsNewName:lower()
		local cppModuleName = clsName
		clsName = cppNamespace .. clsName
		rustBinding[#rustBinding + 1] = "use crate::dora::IObject;"
		local objectUsed = #rustBinding
		if isObject then
			objectUsed = nil
			cppBinding[#cppBinding + 1] = "DORA_EXPORT int32_t " .. tostring(namespace) .. tostring(clsNewNameL) .. "_type() {\n	return DoraType<" .. tostring(clsName) .. ">();\n}"
		end
		if clsParent then
			rustBinding[#rustBinding + 1] = "use crate::dora::" .. tostring(clsParent) .. ";"
			rustBinding[#rustBinding + 1] = "impl " .. tostring(clsParent) .. " for " .. tostring(clsNewName) .. " { }"
		elseif isObject then
			clsParent = "IObject"
		end
		if clsParent then
			local inherits = inheritances[clsParent]
			if inherits then
				for _index_1 = 1, #inherits do
					local inherit = inherits[_index_1]
					rustBinding[#rustBinding + 1] = "use crate::dora::" .. tostring(inherit) .. ";"
					rustBinding[#rustBinding + 1] = "impl " .. tostring(inherit) .. " for " .. tostring(clsNewName) .. " { }"
				end
			end
		end
		cppLink[#cppLink + 1] = "static void link" .. tostring(table.concat(moduleScopes)) .. tostring(cppModuleName) .. "(wasm3::module3& mod) {"
		if #clsDocs > 0 then
			rustBinding[#rustBinding + 1] = table.concat(clsDocs, '\n')
		end
		if isTrait then
			if isObject then
				rustBinding[#rustBinding + 1] = "pub struct " .. tostring(clsNewName) .. " { raw: i64 }\ncrate::dora_object!(" .. tostring(clsNewName) .. ");\nimpl I" .. tostring(clsNewName) .. " for " .. tostring(clsNewName) .. " { }"
				cppLink[#cppLink + 1] = "\tmod.link_optional(\"*\", \"" .. tostring(namespace) .. tostring(clsNewNameL) .. "_type\", " .. tostring(namespace) .. tostring(clsNewNameL) .. "_type);"
			end
			rustBinding[#rustBinding + 1] = "pub trait I" .. tostring(clsNewName) .. tostring(clsParent and ': ' .. clsParent or '') .. " {"
		else
			rustBinding[#rustBinding + 1] = "pub struct " .. tostring(clsNewName) .. " { " .. tostring(isSingleton and '' or 'raw: i64 ') .. "}"
		end
		if isValue then
			rustBinding[#rustBinding + 1] = "impl Drop for " .. tostring(clsNewName) .. " {\n	fn drop(&mut self) { unsafe { " .. tostring(namespace) .. tostring(clsNewNameL) .. "_release(self.raw); } }\n}"
		end
		if isObject and not isTrait then
			rustBinding[#rustBinding + 1] = "crate::dora_object!(" .. tostring(clsNewName) .. ");"
			cppLink[#cppLink + 1] = "\tmod.link_optional(\"*\", \"" .. tostring(namespace) .. tostring(clsNewNameL) .. "_type\", " .. tostring(namespace) .. tostring(clsNewNameL) .. "_type);"
		end
		if not isTrait then
			rustBinding[#rustBinding + 1] = "impl " .. tostring(clsNewName) .. " {"
		end
		if isObject then
			waRuntime = true
			waBinding[#waBinding + 1] = "type " .. tostring(waNewName) .. " :struct { " .. tostring(clsParent:sub(2)) .. " }\nfunc " .. tostring(waNewName) .. "From(raw: i64) => *" .. tostring(waNewName) .. " {\n	if raw == 0 {\n		return nil\n	}\n	object := " .. tostring(waNewName) .. "{}\n	object.raw = &raw\n	runtime.SetFinalizer(object.raw, ObjectFinalizer)\n	result := &object\n	return result\n}\nfunc " .. tostring(waNewName) .. ".GetTypeId() => i32 {\n	return " .. tostring(namespace) .. tostring(clsNewNameL) .. "_type()\n}\nfunc ObjectAs" .. tostring(waNewName) .. "(object: Object) => *" .. tostring(waNewName) .. " {\n	if object.GetTypeId() == " .. tostring(namespace) .. tostring(clsNewNameL) .. "_type() {\n		ObjectRetain(object.GetRaw())\n		return " .. tostring(waNewName) .. "From(object.GetRaw())\n	}\n	return nil\n}"
		else
			if isStatic or isSingleton then
				waBinding[#waBinding + 1] = "type _" .. tostring(waNewName) .. " :struct { }\nglobal " .. tostring(waNewName) .. " = _" .. tostring(waNewName) .. "{}"
			else
				local finalizer = toSnakeCase(tostring(waNewName) .. "Finalizer")
				local finalizerWrapper
				if isValue then
					finalizerWrapper = "func " .. tostring(finalizer) .. "(ptr: u32) {\n	" .. tostring(namespace) .. tostring(clsNewNameL) .. "_release(GetPtr(ptr))\n}\n"
				else
					finalizerWrapper = ""
				end
				waRuntime = isValue
				local finalizerCall
				if isValue then
					finalizerCall = "	runtime.SetFinalizer(item.raw, " .. tostring(finalizer) .. ")\n"
				else
					finalizerCall = ""
				end
				waBinding[#waBinding + 1] = "type " .. tostring(waNewName) .. " :struct { raw: *i64 }\nfunc " .. tostring(waNewName) .. ".GetRaw() => i64 {\n	return *this.raw\n}\n" .. tostring(finalizerWrapper) .. "func " .. tostring(waNewName) .. "From(raw: i64) => *" .. tostring(waNewName) .. " {\n	if raw == 0 {\n		return nil\n	}\n	item := " .. tostring(waNewName) .. "{}\n	item.raw = &raw\n" .. tostring(finalizerCall) .. "	result := &item\n	return result\n}"
			end
		end
		rustExtern[#rustExtern + 1] = "extern \"C\" {"
		if isObject then
			rustExtern[#rustExtern + 1] = "\tfn " .. tostring(namespace) .. tostring(clsNewNameL) .. "_type() -> i32;"
			waExtern[#waExtern + 1] = "#wa:import dora " .. tostring(namespace) .. tostring(clsNewNameL) .. "_type"
			waExtern[#waExtern + 1] = "func " .. tostring(namespace) .. tostring(clsNewNameL) .. "_type() => i32"
			rustBinding[#rustBinding + 1] = "\tpub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {\n		(unsafe { " .. tostring(namespace) .. tostring(clsNewNameL) .. "_type() }, |raw: i64| -> Option<Box<dyn IObject>> {\n			match raw {\n				0 => None,\n				_ => Some(Box::new(" .. tostring(clsNewName) .. " { raw: raw }))\n			}\n		})\n	}"
		end
		if isValue then
			cppBinding[#cppBinding + 1] = "DORA_EXPORT void " .. tostring(namespace) .. tostring(clsNewNameL) .. "_release(int64_t raw) {\n	delete r_cast<" .. tostring(clsName) .. "*>(raw);\n}"
			rustExtern[#rustExtern + 1] = "\tfn " .. tostring(namespace) .. tostring(clsNewNameL) .. "_release(raw: i64);"
			waExtern[#waExtern + 1] = "#wa:import dora " .. tostring(namespace) .. tostring(clsNewNameL) .. "_release"
			waExtern[#waExtern + 1] = "func " .. tostring(namespace) .. tostring(clsNewNameL) .. "_release(raw: i64)"
			rustBinding[#rustBinding + 1] = "\tpub(crate) fn raw(&self) -> i64 {\n		self.raw\n	}\n	pub(crate) fn from(raw: i64) -> " .. tostring(clsNewName) .. " {\n		" .. tostring(clsNewName) .. " { raw: raw }\n	}"
			cppLink[#cppLink + 1] = "\tmod.link_optional(\"*\", \"" .. tostring(namespace) .. tostring(clsNewNameL) .. "_release\", " .. tostring(namespace) .. tostring(clsNewNameL) .. "_release);"
		end
		if #clsLabels == 0 then
			rustBinding[#rustBinding + 1] = "\tpub(crate) fn from(raw: i64) -> Option<" .. tostring(clsNewName) .. "> {\n		match raw {\n			0 => None,\n			_ => Some(" .. tostring(clsNewName) .. " { raw: raw })\n		}\n	}\n	pub(crate) fn raw(&self) -> i64 { self.raw }"
		end
		for _index_1 = 1, #clsBody do
			local clsItem = clsBody[_index_1]
			local pub = isTrait and "" or "pub "
			local itemType = clsItem[1]
			if "field" == itemType then
				local docs, labels, dataType, name, newName
				docs, labels, dataType, name, newName = clsItem[2], clsItem[3], clsItem[4], clsItem[5], clsItem[6]
				local funcName = name:sub(1, 1):lower() .. name:sub(2)
				funcName = table.concat((function()
					local _accum_0 = { }
					local _len_0 = 1
					for sub in funcName:gsub("%u", "_%1"):gmatch("[^_]*") do
						_accum_0[_len_0] = sub:lower()
						_len_0 = _len_0 + 1
					end
					return _accum_0
				end)(), "_")
				local funcNewName = newName or name
				funcNewName = funcNewName:sub(1, 1):lower() .. funcNewName:sub(2)
				funcNewName = table.concat((function()
					local _accum_0 = { }
					local _len_0 = 1
					for sub in funcNewName:gsub("%u", "_%1"):gmatch("[^_]*") do
						_accum_0[_len_0] = sub:lower()
						_len_0 = _len_0 + 1
					end
					return _accum_0
				end)(), "_")
				local isReadonly = false
				local isStatic = false
				local isOptional = false
				local fieldType = "primitive"
				for _index_2 = 1, #labels do
					local label = labels[_index_2]
					if "readonly" == label then
						isReadonly = true
					elseif "common" == label or "boolean" == label then
						fieldType = label
					elseif "static" == label then
						isStatic = true
					elseif "optional" == label then
						isOptional = true
					end
				end
				funcCount = funcCount + (function()
					if isReadonly then
						return 1
					else
						return 2
					end
				end)()
				if isStatic then
					if funcNewName:sub(1, 1) == "_" then
						pub = "pub(crate) "
					else
						pub = "pub "
					end
				elseif pub:sub(1, 3) == "pub" then
					if funcNewName:sub(1, 1) == "_" then
						pub = "pub(crate) "
					end
				end
				local rustType = basicTypes[dataType]
				local waName = nil
				if rustType == nil and "*" == dataType:sub(-1) then
					local dataTypeName = dataType:match("[^ \t*]+")
					local rustName = nameMap[dataTypeName] or dataTypeName
					waName = rustName
					rustType = getObjectType(dataTypeName, rustName, false, isOptional)
					if not isReadonly and not interfaces[rustName] then
						objectUsed = nil
					end
				end
				if rustType then
					local rt, cast, castFrom, rtTypeIn, rtTypeOut, rtCast, rtCastFrom = rustType[1], rustType[2], rustType[3], rustType[4], rustType[5], rustType[6], rustType[7]
					local cppType = cppTypes[rt]
					if not isReadonly then
						local docText
						if #docs > 0 then
							local text = table.concat(docs, '\n\t')
							docText = '\t' .. text:sub(1, 4) .. 'Sets' .. text:sub(4) .. '\n'
						else
							docText = ''
						end
						local setFunc
						if "primitive" == fieldType then
							setFunc = tostring(name) .. " = " .. tostring(cast('val'))
						elseif "common" == fieldType or "boolean" == fieldType then
							if dataType == cppType then
								setFunc = "set" .. tostring(name:sub(1, 1):upper()) .. tostring(name:sub(2)) .. "(val)"
							else
								setFunc = "set" .. tostring(name:sub(1, 1):upper()) .. tostring(name:sub(2)) .. "(" .. tostring(cast('val')) .. ")"
							end
						end
						local cppSetterName = tostring(namespace) .. tostring(clsNameL) .. "_set_" .. tostring(funcNewName)
						local rustSetterName = "set_" .. tostring(funcNewName)
						local waSetterName = snakeToPascal(rustSetterName)
						cppLink[#cppLink + 1] = "\tmod.link_optional(\"*\", \"" .. tostring(cppSetterName) .. "\", " .. tostring(cppSetterName) .. ");"
						if isSingleton then
							local callFunc = isStatic and tostring(clsName) .. "::" .. tostring(setFunc) .. ";" or tostring(singletonName) .. "." .. tostring(setFunc) .. ";"
							cppBinding[#cppBinding + 1] = "DORA_EXPORT void " .. tostring(cppSetterName) .. "(" .. tostring(cppType) .. " val) {\n\t" .. tostring(callFunc) .. "\n}"
						else
							local callFunc = isStatic and tostring(clsName) .. "::" .. tostring(setFunc) or "r_cast<" .. tostring(clsName) .. "*>(self)->" .. tostring(setFunc)
							local slf = isStatic and "" or "int64_t self, "
							cppBinding[#cppBinding + 1] = "DORA_EXPORT void " .. tostring(cppSetterName) .. "(" .. tostring(slf) .. tostring(cppType) .. " val) {\n\t" .. tostring(callFunc) .. ";\n}"
						end
						if isSingleton then
							rustExtern[#rustExtern + 1] = "\tfn " .. tostring(cppSetterName) .. "(val: " .. tostring(rt) .. ");"
						else
							local slf = isStatic and "" or "slf: i64, "
							rustExtern[#rustExtern + 1] = "\tfn " .. tostring(cppSetterName) .. "(" .. tostring(slf) .. "val: " .. tostring(rt) .. ");"
						end
						if isSingleton then
							waExtern[#waExtern + 1] = "#wa:import dora " .. tostring(cppSetterName) .. "\nfunc " .. tostring(cppSetterName) .. "(val: " .. tostring(rt) .. ")"
						else
							local slf = isStatic and "" or "slf: i64, "
							waExtern[#waExtern + 1] = "#wa:import dora " .. tostring(cppSetterName) .. "\nfunc " .. tostring(cppSetterName) .. "(" .. tostring(slf) .. "val: " .. tostring(rt) .. ");"
						end
						if isSingleton then
							rustBinding[#rustBinding + 1] = tostring(docText) .. "\t" .. tostring(pub) .. "fn " .. tostring(rustSetterName) .. "(val: " .. tostring(rtTypeIn or rt) .. ") {\n\t\tunsafe { " .. tostring(cppSetterName) .. "(" .. tostring(rtCast and rtCast('val') or 'val') .. ") };\n\t}"
						else
							local slfDecl = isStatic and "" or "&mut self, "
							local slf = isStatic and "" or "self.raw(), "
							rustBinding[#rustBinding + 1] = tostring(docText) .. "\t" .. tostring(pub) .. "fn " .. tostring(rustSetterName) .. "(" .. tostring(slfDecl) .. "val: " .. tostring(rtTypeIn or rt) .. ") {\n\t\tunsafe { " .. tostring(cppSetterName) .. "(" .. tostring(slf) .. tostring(rtCast and rtCast('val') or 'val') .. ") };\n\t}"
						end
						local waType = getWaType(dataType, waName)
						local waDocText
						if #docs > 0 then
							local text = table.concat(docs, '\n')
							waDocText = text:sub(1, 4) .. 'Sets' .. text:sub(4) .. '\n'
						else
							waDocText = ''
						end
						if isSingleton then
							waBinding[#waBinding + 1] = tostring(waDocText) .. "func _" .. tostring(waNewName) .. "." .. tostring(waSetterName) .. "(val: " .. tostring(waType.argType) .. ") {\n\t" .. tostring(cppSetterName) .. "(" .. tostring(waType.convertTo('val')) .. ")\n}"
						elseif isStatic then
							waBinding[#waBinding + 1] = tostring(waDocText) .. "func " .. tostring(waNewName) .. tostring(waSetterName) .. "(val: " .. tostring(waType.argType) .. ") {\n\t" .. tostring(cppSetterName) .. "(" .. tostring(waType.convertTo('val')) .. ")\n}"
						else
							waBinding[#waBinding + 1] = tostring(waDocText) .. "func " .. tostring(waNewName) .. "." .. tostring(waSetterName) .. "(val: " .. tostring(waType.argType) .. ") {\n\t" .. tostring(cppSetterName) .. "(*this.raw, " .. tostring(waType.convertTo('val')) .. ")\n}"
						end
					end
					local docText
					if #docs > 0 then
						local text = table.concat(docs, '\n\t')
						docText = '\t' .. text:sub(1, 4) .. 'Gets' .. text:sub(4) .. '\n'
					else
						docText = ''
					end
					local getFunc, prefix
					if "primitive" == fieldType then
						getFunc, prefix = tostring(name), "get"
					elseif "common" == fieldType then
						getFunc, prefix = "get" .. tostring(name:sub(1, 1):upper()) .. tostring(name:sub(2)) .. "()", "get"
					elseif "boolean" == fieldType then
						getFunc, prefix = "is" .. tostring(name:sub(1, 1):upper()) .. tostring(name:sub(2)) .. "()", "is"
					end
					if dataType == cppType then
						castFrom = function(name)
							return name
						end
					end
					local cppGetterName = tostring(namespace) .. tostring(clsNameL) .. "_" .. tostring(prefix) .. "_" .. tostring(funcNewName)
					local rustGetterName = tostring(prefix) .. "_" .. tostring(funcNewName)
					local waGetterName = snakeToPascal(rustGetterName)
					cppLink[#cppLink + 1] = "\tmod.link_optional(\"*\", \"" .. tostring(cppGetterName) .. "\", " .. tostring(cppGetterName) .. ");"
					if isSingleton then
						local callFunc = isStatic and tostring(clsName) .. "::" .. tostring(getFunc) or tostring(singletonName) .. "." .. tostring(getFunc)
						local item = castFrom(tostring(callFunc))
						cppBinding[#cppBinding + 1] = "DORA_EXPORT " .. tostring(cppType) .. " " .. tostring(cppGetterName) .. "() {\n\treturn " .. tostring(item) .. ";\n}"
					else
						local callFunc = isStatic and tostring(clsName) .. "::" .. tostring(getFunc) or "r_cast<" .. tostring(clsName) .. "*>(self)->" .. tostring(getFunc)
						local item = castFrom(callFunc)
						local slf = isStatic and "" or "int64_t self"
						cppBinding[#cppBinding + 1] = "DORA_EXPORT " .. tostring(cppType) .. " " .. tostring(cppGetterName) .. "(" .. tostring(slf) .. ") {\n\treturn " .. tostring(item) .. ";\n}"
					end
					if isSingleton then
						rustExtern[#rustExtern + 1] = "\tfn " .. tostring(cppGetterName) .. "() -> " .. tostring(rt) .. ";"
					else
						local slf = isStatic and "" or "slf: i64"
						rustExtern[#rustExtern + 1] = "\tfn " .. tostring(cppGetterName) .. "(" .. tostring(slf) .. ") -> " .. tostring(rt) .. ";"
					end
					if isSingleton then
						waExtern[#waExtern + 1] = "#wa:import dora " .. tostring(cppGetterName) .. "\nfunc " .. tostring(cppGetterName) .. "() => " .. tostring(rt)
					else
						local slf = isStatic and "" or "slf: i64"
						waExtern[#waExtern + 1] = "#wa:import dora " .. tostring(cppGetterName) .. "\nfunc " .. tostring(cppGetterName) .. "(" .. tostring(slf) .. ") => " .. tostring(rt)
					end
					if isSingleton then
						local item = tostring(cppGetterName) .. "()"
						rustBinding[#rustBinding + 1] = tostring(docText) .. "\t" .. tostring(pub) .. "fn " .. tostring(rustGetterName) .. "() -> " .. tostring(rtTypeOut or rt) .. " {\n\t\treturn unsafe { " .. tostring(rtCastFrom and rtCastFrom(item) or item) .. " };\n\t}"
					else
						local slfDecl = isStatic and "" or "&self"
						local slf = isStatic and "" or "self.raw()"
						local item = tostring(cppGetterName) .. "(" .. tostring(slf) .. ")"
						rustBinding[#rustBinding + 1] = tostring(docText) .. "\t" .. tostring(pub) .. "fn " .. tostring(rustGetterName) .. "(" .. tostring(slfDecl) .. ") -> " .. tostring(rtTypeOut or rt) .. " {\n\t\treturn unsafe { " .. tostring(rtCastFrom and rtCastFrom(item) or item) .. " };\n\t}"
					end
					local waType = assert(getWaType(dataType, waName))
					local waReturnType = isOptional and "*" .. tostring(waType.returnType) or waType.returnType
					local waReturn
					waReturn = function(item)
						if isOptional then
							return "	ptr_ := " .. tostring(item) .. "\n	if ptr_ == 0 {\n		return nil\n	}\n	obj_ := " .. tostring(waType.convertFrom('ptr_')) .. "\n	return &obj_"
						else
							return "\treturn " .. tostring(waType.convertFrom(item))
						end
					end
					local waDocText
					if #docs > 0 then
						local text = table.concat(docs, '\n')
						waDocText = text:sub(1, 4) .. 'Gets' .. text:sub(4) .. '\n'
					else
						waDocText = ''
					end
					if isSingleton then
						local item = tostring(cppGetterName) .. "()"
						waBinding[#waBinding + 1] = tostring(waDocText) .. "func _" .. tostring(waNewName) .. "." .. tostring(waGetterName) .. "() => " .. tostring(waReturnType) .. " {\n" .. tostring(waReturn(item)) .. "\n}"
					elseif isStatic then
						local item = tostring(cppGetterName) .. "()"
						waBinding[#waBinding + 1] = tostring(waDocText) .. "func " .. tostring(waNewName) .. tostring(waGetterName) .. "() => " .. tostring(waReturnType) .. " {\n" .. tostring(waReturn(item)) .. "\n}"
					else
						local item = tostring(cppGetterName) .. "(*this.raw)"
						waBinding[#waBinding + 1] = tostring(waDocText) .. "func " .. tostring(waNewName) .. "." .. tostring(waGetterName) .. "() => " .. tostring(waReturnType) .. " {\n" .. tostring(waReturn(item)) .. "\n}"
					end
				else
					error("\"" .. tostring(dataType) .. "\" is not supported.")
				end
			elseif "method" == itemType then
				funcCount = funcCount + 1
				local docs, labels, dataType, name, newName, args, constFlag
				docs, labels, dataType, name, newName, args, constFlag = clsItem[2], clsItem[3], clsItem[4], clsItem[5], clsItem[6], clsItem[7], clsItem[8]
				local funcNewName = newName or name
				local funcName = name:sub(1, 1):lower() .. name:sub(2)
				funcName = table.concat((function()
					local _accum_0 = { }
					local _len_0 = 1
					for sub in funcName:gsub("%u", "_%1"):gmatch("[^_]*") do
						_accum_0[_len_0] = sub:lower()
						_len_0 = _len_0 + 1
					end
					return _accum_0
				end)(), "_")
				local isCreate = false
				if "create" == funcNewName:sub(1, 6) then
					isCreate = true
					if #funcNewName > 6 then
						funcNewName = "with" .. funcNewName:sub(7)
					else
						funcNewName = "new"
					end
					pub = "pub "
				end
				funcNewName = funcNewName:sub(1, 1):lower() .. funcNewName:sub(2)
				funcNewName = table.concat((function()
					local _accum_0 = { }
					local _len_0 = 1
					for sub in funcNewName:gsub("%u", "_%1"):gmatch("[^_]*") do
						_accum_0[_len_0] = sub:lower()
						_len_0 = _len_0 + 1
					end
					return _accum_0
				end)(), "_")
				local isStatic = false
				local isOutside = false
				local isOptional = false
				local isConst = constFlag == "const"
				for _index_2 = 1, #labels do
					local label = labels[_index_2]
					if "outside" == label then
						isOutside = true
					elseif "static" == label then
						isStatic = true
					elseif "optional" == label then
						isOptional = true
					end
				end
				if isStatic then
					if funcNewName:sub(1, 1) == "_" then
						pub = "pub(crate) "
					else
						pub = "pub "
					end
				elseif pub:sub(1, 3) == "pub" then
					if funcNewName:sub(1, 1) == "_" then
						pub = "pub(crate) "
					end
				end
				local rustType = basicTypes[dataType]
				local waName = nil
				if rustType == nil and "*" == dataType:sub(-1) then
					local dataTypeName = dataType:match("[^ \t*]+")
					local rustName
					if isCreate then
						waName = (cppNamespace .. clsNewName):gsub("::", "")
						rustName = clsNewName
					else
						waName = nameMap[dataTypeName] or dataTypeName
						rustName = waName
					end
					rustType = getObjectType(dataTypeName, rustName, isCreate, isOptional)
				end
				if rustType then
					local rt, cast, castFrom, rtTypeOut, rtCastFrom = rustType[1], rustType[2], rustType[3], rustType[5], rustType[7]
					if isOptional and not rtTypeOut:match("^Option<") then
						rtTypeOut = "Option<" .. tostring(rtTypeOut) .. ">"
					end
					local cppType
					do
						local _exp_0 = cppTypes[rt]
						if _exp_0 ~= nil then
							cppType = _exp_0
						else
							cppType = "void"
						end
					end
					local funcArgCount = -1
					local argItems
					do
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #args do
							local arg = args[_index_2]
							local argKind, argType, argName = arg[1], arg[2], arg[3]
							argName = toSnakeCase(argName)
							if "variable" == argKind then
								local rustTypeA = basicTypes[argType]
								if rustTypeA == nil and "*" == argType:sub(-1) then
									local argTypeName = argType:match("[^ \t*]+")
									local rustArgName = nameMap[argTypeName] or argTypeName
									rustTypeA = getObjectType(argTypeName, rustArgName)
									if not interfaces[rustArgName] then
										objectUsed = nil
									end
								end
								if rustTypeA then
									local rtA, castA, rtTypeInA, rtCastA = rustTypeA[1], rustTypeA[2], rustTypeA[4], rustTypeA[6]
									local cppTypeA = cppTypes[rtA]
									_accum_0[_len_0] = {
										tostring(cppTypeA) .. " " .. tostring(argName),
										(argType == cppTypeA and argName or castA(argName)),
										tostring(argName) .. ": " .. tostring(rtA),
										tostring(argName) .. ": " .. tostring(rtTypeInA or rtA),
										tostring(rtCastA and rtCastA(argName) or argName)
									}
									_len_0 = _len_0 + 1
								else
									_accum_0[_len_0] = error("\"" .. tostring(argType) .. "\" is not supported.")
									_len_0 = _len_0 + 1
								end
							elseif "callback" == argKind then
								funcArgCount = funcArgCount + 1
								local fnArgId = tostring(funcArgCount)
								local func, fname = arg[2], arg[3]
								fname = toSnakeCase(fname)
								local flabel, freturnType, fargs = func[1], func[2], func[3]
								local items
								do
									local _accum_1 = { }
									local _len_1 = 1
									for _index_3 = 1, #fargs do
										local farg = fargs[_index_3]
										local fargKind, fargType, fargName = farg[1], farg[2], farg[3]
										if fargKind ~= "variable" then
											error("\"" .. tostring(fargKind) .. "\" is not supported in function argument.")
										end
										local frustType = basicTypes[fargType]
										if frustType == nil and "*" == fargType:sub(-1) then
											local fargTypeName = fargType:match("[^ \t*]+")
											local frustName = nameMap[fargTypeName] or fargTypeName
											frustType = getObjectType(fargTypeName, frustName)
										end
										if frustType then
											local frt, _2, _3, frtTypeIn, _5, _6, _7, fpopArg = frustType[1], frustType[2], frustType[3], frustType[4], frustType[5], frustType[6], frustType[7], frustType[8]
											local fcppType = callbackDefs[fargType] or fargType
											local _exp_0 = fargType:match("[^ \t*]+")
											if "Event" == _exp_0 then
												_accum_1[_len_1] = {
													"Event* " .. tostring(fargName),
													"\t\t" .. tostring(fargName) .. "->pushArgsToWasm(args" .. tostring(fnArgId) .. ");",
													"&mut crate::dora::CallStack",
													"&mut stack" .. tostring(fnArgId)
												}
												_len_1 = _len_1 + 1
											elseif "Platformer::Behavior::Blackboard" == _exp_0 or "Platformer::UnitAction" == _exp_0 then
												_accum_1[_len_1] = {
													tostring(fcppType) .. "* " .. tostring(fargName),
													"\t\targs" .. tostring(fnArgId) .. "->push(r_cast<int64_t>(" .. tostring(fargName) .. "));",
													frtTypeIn,
													fpopArg(fnArgId)
												}
												_len_1 = _len_1 + 1
											elseif "DBRecord" == _exp_0 then
												_accum_1[_len_1] = {
													tostring(fcppType) .. "& " .. tostring(fargName),
													"\t\targs" .. tostring(fnArgId) .. "->push(r_cast<int64_t>(new DBRecord{std::move(" .. tostring(fargName) .. ")}));",
													frtTypeIn,
													fpopArg(fnArgId)
												}
												_len_1 = _len_1 + 1
											elseif "MLQState" == _exp_0 or "MLQAction" == _exp_0 then
												_accum_1[_len_1] = {
													tostring(fcppType) .. " " .. tostring(fargName),
													"\t\targs" .. tostring(fnArgId) .. "->push(s_cast<int64_t>(" .. tostring(fargName) .. "));",
													frtTypeIn,
													fpopArg(fnArgId)
												}
												_len_1 = _len_1 + 1
											elseif nil == _exp_0 then
												_accum_1[_len_1] = error("\"" .. tostring(fargType) .. "\" is not supported.")
												_len_1 = _len_1 + 1
											else
												_accum_1[_len_1] = {
													tostring(fcppType) .. " " .. tostring(fargName),
													"\t\targs" .. tostring(fnArgId) .. "->push(" .. tostring(fargName) .. ");",
													frtTypeIn,
													fpopArg(fnArgId)
												}
												_len_1 = _len_1 + 1
											end
										end
									end
									items = _accum_1
								end
								local argPassed = #items > 0
								local cppArgDef = table.concat((function()
									local _accum_1 = { }
									local _len_1 = 1
									for _index_3 = 1, #items do
										local item = items[_index_3]
										_accum_1[_len_1] = item[1]
										_len_1 = _len_1 + 1
									end
									return _accum_1
								end)(), ", ")
								local cppArgPass = table.concat((function()
									local _accum_1 = { }
									local _len_1 = 1
									for _index_3 = 1, #items do
										local item = items[_index_3]
										_accum_1[_len_1] = item[2]
										_len_1 = _len_1 + 1
									end
									return _accum_1
								end)(), "\n")
								if cppArgPass ~= "" then
									cppArgPass = tostring(cppArgPass) .. "\n"
								end
								local callbackType = "dyn FnMut(" .. tostring(table.concat((function()
									local _accum_1 = { }
									local _len_1 = 1
									for _index_3 = 1, #items do
										local item = items[_index_3]
										_accum_1[_len_1] = item[3]
										_len_1 = _len_1 + 1
									end
									return _accum_1
								end)(), ', ')) .. ")"
								local callback = tostring(fname) .. "(" .. tostring(table.concat((function()
									local _accum_1 = { }
									local _len_1 = 1
									for _index_3 = 1, #items do
										local item = items[_index_3]
										_accum_1[_len_1] = item[4]
										_len_1 = _len_1 + 1
									end
									return _accum_1
								end)(), ', ')) .. ")"
								local callbackReturn = ""
								local frRetType = basicTypes[freturnType]
								if frRetType == nil and "*" == freturnType:sub(-1) then
									freturnType = freturnType:sub(1, -2)
									local frustName = nameMap[freturnType] or freturnType
									frRetType = getObjectType(freturnType, frustName)
								end
								if frRetType then
									local frt, _2, _3, _4, frtTypeOut, _6, _7, _8, frPush = frRetType[1], frRetType[2], frRetType[3], frRetType[4], frRetType[5], frRetType[6], frRetType[7], frRetType[8], frRetType[9]
									if frtTypeOut then
										callbackType = "Box<" .. tostring(callbackType) .. " -> " .. tostring(frtTypeOut) .. ">"
									else
										callbackType = "Box<" .. tostring(callbackType) .. ">"
									end
									local frCppType = cppTypes[frt]
									if frCppType then
										if "Node" == freturnType then
											callbackReturn = "\t\treturn args" .. tostring(fnArgId) .. "->empty() ? Node::create() : s_cast<Node*>(std::get<Object*>(args" .. tostring(fnArgId) .. "->pop()));\n"
										elseif "string" == freturnType then
											callbackReturn = "\t\treturn args" .. tostring(fnArgId) .. "->empty() ? \"\"s : std::get<std::string>(args" .. tostring(fnArgId) .. "->pop());\n"
										elseif "Platformer::WasmActionUpdate" == freturnType then
											local defItem = "Platformer::WasmActionUpdate::create([](Platformer::Unit*, Platformer::UnitAction*, float) { return true; })"
											callbackReturn = "\t\treturn args" .. tostring(fnArgId) .. "->empty()? " .. tostring(defItem) .. " : s_cast<Platformer::WasmActionUpdate*>(std::get<Object*>(args" .. tostring(fnArgId) .. "->pop()));\n"
										elseif "bool" == freturnType then
											if "def_true" == flabel then
												callbackReturn = "\t\treturn args" .. tostring(fnArgId) .. "->pop_bool_or(true);\n"
											elseif "def_false" == flabel then
												callbackReturn = "\t\treturn args" .. tostring(fnArgId) .. "->pop_bool_or(false);\n"
											else
												print("missing [def_true|def_false] for callback return in " .. tostring(funcNewName))
												callbackReturn = "\t\treturn args" .. tostring(fnArgId) .. "->pop_bool_or(false);\n"
											end
										else
											print("callback return type \"" .. tostring(freturnType) .. "\" not handled in " .. tostring(funcNewName))
											callbackReturn = "\t\treturn std::get<" .. tostring(freturnType) .. ">(args" .. tostring(fnArgId) .. "->pop());\n"
										end
										callback = "let result = " .. tostring(callback) .. ";\n\t\t\t" .. tostring(frPush('result', fnArgId))
										argPassed = true
									end
								end
								_accum_0[_len_0] = {
									"int32_t func" .. tostring(fnArgId) .. tostring(argPassed and ', int64_t stack' .. fnArgId or ''),
									"[func" .. tostring(fnArgId) .. ", " .. tostring(argPassed and 'args' .. fnArgId .. ', ' or '') .. "deref" .. tostring(fnArgId) .. "](" .. tostring(cppArgDef) .. ") {\n" .. tostring(argPassed and '\t\targs' .. fnArgId .. '->clear();\n' .. cppArgPass or '') .. "\t\tSharedWasmRuntime.invoke(func" .. tostring(fnArgId) .. ");\n" .. tostring(callbackReturn) .. "	}",
									"func" .. tostring(fnArgId) .. ": i32" .. tostring(argPassed and ', stack' .. fnArgId .. ': i64' or ''),
									"mut " .. tostring(fname) .. ": " .. tostring(callbackType),
									"func_id" .. tostring(fnArgId) .. tostring(argPassed and ', stack_raw' .. fnArgId or ''),
									"\n	std::shared_ptr<void> deref" .. tostring(fnArgId) .. "(nullptr, [func" .. tostring(fnArgId) .. "](auto) {\n		SharedWasmRuntime.deref(func" .. tostring(fnArgId) .. ");\n	});" .. tostring(argPassed and '\n\tauto args' .. fnArgId .. ' = r_cast<CallStack*>(stack' .. fnArgId .. ');' or ''),
									(argPassed and "\t\tlet mut stack" .. tostring(fnArgId) .. " = crate::dora::CallStack::new();\n		let stack_raw" .. tostring(fnArgId) .. " = stack" .. tostring(fnArgId) .. ".raw();\n" or '') .. "\t\tlet func_id" .. tostring(fnArgId) .. " = crate::dora::push_function(Box::new(move || {\n			" .. tostring(callback) .. "\n		}));\n"
								}
								_len_0 = _len_0 + 1
							end
						end
						argItems = _accum_0
					end
					local argDefs = table.concat((function()
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #argItems do
							local item = argItems[_index_2]
							_accum_0[_len_0] = item[1]
							_len_0 = _len_0 + 1
						end
						return _accum_0
					end)(), ", ")
					local argPass = table.concat((function()
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #argItems do
							local item = argItems[_index_2]
							_accum_0[_len_0] = item[2]
							_len_0 = _len_0 + 1
						end
						return _accum_0
					end)(), ", ")
					local argRtDefs = table.concat((function()
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #argItems do
							local item = argItems[_index_2]
							_accum_0[_len_0] = item[3]
							_len_0 = _len_0 + 1
						end
						return _accum_0
					end)(), ", ")
					local argRtInDefs = table.concat((function()
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #argItems do
							local item = argItems[_index_2]
							_accum_0[_len_0] = item[4]
							_len_0 = _len_0 + 1
						end
						return _accum_0
					end)(), ", ")
					local argRtPass = table.concat((function()
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #argItems do
							local item = argItems[_index_2]
							_accum_0[_len_0] = item[5]
							_len_0 = _len_0 + 1
						end
						return _accum_0
					end)(), ", ")
					local argPrepare = table.concat((function()
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #argItems do
							local item = argItems[_index_2]
							if (item[6] ~= nil) then
								_accum_0[_len_0] = item[6]
								_len_0 = _len_0 + 1
							end
						end
						return _accum_0
					end)())
					local argRtPrepare = table.concat((function()
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #argItems do
							local item = argItems[_index_2]
							if (item[7] ~= nil) then
								_accum_0[_len_0] = item[7]
								_len_0 = _len_0 + 1
							end
						end
						return _accum_0
					end)())
					if dataType == cppType then
						castFrom = function(name)
							return name
						end
					end
					local prefix
					if cppType == "void" then
						prefix = ""
					else
						prefix = "return "
					end
					local cppFuncName = tostring(namespace) .. tostring(clsNameL) .. "_" .. tostring(funcNewName)
					local rustFuncName = funcNewName
					local waFuncName = snakeToPascal(rustFuncName)
					cppLink[#cppLink + 1] = "\tmod.link_optional(\"*\", \"" .. tostring(cppFuncName) .. "\", " .. tostring(cppFuncName) .. ");"
					if isSingleton then
						local callFunc = isStatic and tostring(clsName) .. "::" .. tostring(name) .. "(" .. tostring(argPass) .. ")" or tostring(singletonName) .. "." .. tostring(name) .. "(" .. tostring(argPass) .. ")"
						callFunc = isOutside and tostring(name) .. "(" .. tostring(argPass) .. ")" or callFunc
						local item = castFrom(callFunc)
						cppBinding[#cppBinding + 1] = "DORA_EXPORT " .. tostring(cppType) .. " " .. tostring(cppFuncName) .. "(" .. tostring(argDefs) .. ") {" .. tostring(argPrepare) .. "\n\t" .. tostring(prefix) .. tostring(item) .. ";\n}"
					else
						local slf = isStatic and "" or "int64_t self"
						if slf ~= "" then
							argDefs = slf .. (argDefs ~= "" and ", " or "") .. argDefs
						end
						local callFunc
						if isOutside then
							if isStatic then
								callFunc = tostring(name) .. "(" .. tostring(argPass) .. ")"
							else
								callFunc = tostring(name) .. "(r_cast<" .. tostring(clsName) .. "*>(self)" .. tostring(argPass == '' and '' or ', ' .. argPass) .. ")"
							end
						else
							if isStatic then
								callFunc = tostring(clsName) .. "::" .. tostring(name) .. "(" .. tostring(argPass) .. ")"
							else
								callFunc = "r_cast<" .. tostring(clsName) .. "*>(self)->" .. tostring(name) .. "(" .. tostring(argPass) .. ")"
							end
						end
						if isCreate then
							callFunc = isValue and argPass or callFunc
						end
						local item = castFrom(callFunc)
						cppBinding[#cppBinding + 1] = "DORA_EXPORT " .. tostring(cppType) .. " " .. tostring(cppFuncName) .. "(" .. tostring(argDefs) .. ") {" .. tostring(argPrepare) .. "\n\t" .. tostring(prefix) .. tostring(item) .. ";\n}"
					end
					if isSingleton then
						rustExtern[#rustExtern + 1] = "\tfn " .. tostring(cppFuncName) .. "(" .. tostring(argRtDefs) .. ")" .. tostring(rt and ' -> ' .. rt or '') .. ";"
					else
						local slf = isStatic and "" or "slf: i64"
						if slf ~= "" then
							argRtDefs = slf .. (argRtDefs ~= "" and ", " or "") .. argRtDefs
						end
						rustExtern[#rustExtern + 1] = "\tfn " .. tostring(cppFuncName) .. "(" .. tostring(argRtDefs) .. ")" .. tostring(rt and ' -> ' .. rt or '') .. ";"
					end
					if isSingleton then
						waExtern[#waExtern + 1] = "#wa:import dora " .. tostring(cppFuncName) .. "\nfunc " .. tostring(cppFuncName) .. "(" .. tostring(argRtDefs) .. ")" .. tostring(rt and ' => ' .. rt or '')
					else
						local slf = isStatic and "" or "slf: i64"
						waExtern[#waExtern + 1] = "#wa:import dora " .. tostring(cppFuncName) .. "\nfunc " .. tostring(cppFuncName) .. "(" .. tostring(argRtDefs) .. ")" .. tostring(rt and ' => ' .. rt or '')
					end
					if isSingleton then
						local rtOut = rtTypeOut or rt
						local item = tostring(cppFuncName) .. "(" .. tostring(argRtPass) .. ")"
						local docText
						if #docs > 0 then
							docText = '\t' .. table.concat(docs, '\n\t') .. '\n'
						else
							docText = ''
						end
						rustBinding[#rustBinding + 1] = tostring(docText) .. "\t" .. tostring(pub) .. "fn " .. tostring(rustFuncName) .. "(" .. tostring(argRtInDefs) .. ")" .. tostring(rtOut and ' -> ' .. rtOut or '') .. " {\n" .. tostring(argRtPrepare) .. "\t\tunsafe { " .. tostring(prefix) .. tostring(rtCastFrom and rtCastFrom(item, isOptional) or item) .. "; }\n\t}"
					else
						local rtOut = rtTypeOut or rt
						local slfParam = isConst and "&self" or "&mut self"
						local slfDecl = isStatic and "" or slfParam
						if slfDecl ~= "" then
							argRtInDefs = slfDecl .. (argRtInDefs ~= "" and ", " or "") .. argRtInDefs
						end
						local slf = isStatic and "" or "self.raw()"
						if slf ~= "" then
							argRtPass = slf .. (argRtPass ~= "" and ", " or "") .. argRtPass
						end
						local item = tostring(cppFuncName) .. "(" .. tostring(argRtPass) .. ")"
						if funcNewName == "equals" then
							local docText
							if #docs > 0 then
								docText = '\t' .. table.concat(docs, '\n\t')
							else
								docText = ''
							end
							table.insert(rustBinding, objectUsed and objectUsed + 1 or 2, "impl PartialEq for Rect {\n" .. tostring(docText) .. "\n	fn eq(&self, other: &Self) -> bool {\n" .. tostring(argRtPrepare) .. "\t\tunsafe { " .. tostring(prefix) .. tostring(rtCastFrom and rtCastFrom(item, isOptional) or item) .. " }\n\t}\n}")
							rustBinding[#rustBinding + 1] = nil
						else
							local docText
							if #docs > 0 then
								docText = '\t' .. table.concat(docs, '\n\t') .. '\n'
							else
								docText = ''
							end
							rustBinding[#rustBinding + 1] = tostring(docText) .. "\t" .. tostring(pub) .. "fn " .. tostring(rustFuncName) .. "(" .. tostring(argRtInDefs) .. ")" .. tostring(rtOut and ' -> ' .. rtOut or '') .. " {\n" .. tostring(argRtPrepare) .. "\t\tunsafe { " .. tostring(prefix) .. tostring(rtCastFrom and rtCastFrom(item, isOptional) or item) .. "; }\n\t}"
						end
					end
					local waType = getWaType(dataType, waName)
					local waReturnType
					if waType then
						waReturnType = isOptional and " => *" .. tostring(waType.returnType) or (function()
							return waType.returnType == "" and "" or " => " .. tostring(waType.returnType)
						end)()
					else
						waReturnType = ""
					end
					local waReturn
					waReturn = function(item)
						if waReturnType == "" then
							return item
						end
						if isOptional then
							return "ptr_ := " .. tostring(item) .. "\n	if ptr_ == 0 {\n		return nil\n	}\n	obj_ := " .. tostring(waType.convertFrom('ptr_')) .. "\n	return &obj_"
						else
							return "return " .. tostring(waType.convertFrom(item))
						end
					end
					local prepareArgs = { }
					funcArgCount = -1
					do
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #args do
							local arg = args[_index_2]
							local argKind, argType, argName = arg[1], arg[2], arg[3]
							argName = toSnakeCase(argName)
							if "variable" == argKind then
								local fargTypeName = argType:match("[^ \t*]+")
								fargTypeName = nameMap[fargTypeName] or fargTypeName
								local wType = getWaType(argType, fargTypeName)
								_accum_0[_len_0] = {
									argName = argName,
									argType = wType.argType,
									converted = wType.convertTo(argName)
								}
								_len_0 = _len_0 + 1
							elseif "callback" == argKind then
								local callbackName = nil
								local callbackType = nil
								local callbackConverted = nil
								funcArgCount = funcArgCount + 1
								local fnArgId = tostring(funcArgCount)
								local func, fname = arg[2], arg[3]
								fname = toSnakeCase(fname)
								local flabel, freturnType, fargs = func[1], func[2], func[3]
								local freturnTypeName = freturnType:match("[^ \t*]+")
								local freturnName = nameMap[freturnTypeName] or freturnTypeName
								local rtpObj = getWaType(freturnType, freturnName)
								local rtp = freturnType == "void" and "" or " => " .. tostring(rtpObj.returnType)
								callbackConverted = "func_id" .. tostring(funcArgCount)
								if #fargs > 0 or rtp ~= "" then
									callbackConverted = callbackConverted .. ", *stack" .. tostring(funcArgCount) .. ".raw"
								end
								local argTypeStrs = { }
								local popArgs = { }
								local popArgNames = { }
								for _index_3 = 1, #fargs do
									local farg = fargs[_index_3]
									local fargType, fargName = farg[2], farg[3]
									local fargTypeName = fargType:match("[^ \t*]+")
									local atp
									if "Event" == fargTypeName then
										atp = {
											convertFrom = function()
												return error("unsupported")
											end,
											convertTo = function()
												return error("unsupported")
											end,
											argType = "CallStack",
											returnType = "CallStack",
											creturn = function(name, fnArgId)
												return tostring(name) .. " := stack" .. tostring(fnArgId)
											end,
											cpass = function()
												return error("unsupported")
											end
										}
									elseif nil == fargTypeName then
										atp = error("\"" .. tostring(fargType) .. "\" is not supported.")
									else
										atp = getWaType(fargType, nameMap[fargTypeName] or fargTypeName)
									end
									argTypeStrs[#argTypeStrs + 1] = tostring(toSnakeCase(fargName)) .. ": " .. tostring(atp.argType)
									if atp.creturn == nil then
										print(fargType)
									else
										popArgs[#popArgs + 1] = "\t\t" .. tostring(atp.creturn(fargName, fnArgId))
									end
									popArgNames[#popArgNames + 1] = fargName
								end
								local popArgStr = table.concat(popArgs, "\n")
								popArgStr = popArgStr == "" and "" or tostring(popArgStr) .. "\n"
								local callFunc
								if rtp == "" then
									callFunc = tostring(fname) .. "(" .. tostring(table.concat(popArgNames, ', ')) .. ")"
								else
									callFunc = "result_ := " .. tostring(fname) .. "(" .. tostring(table.concat(popArgNames, ', ')) .. ")\n\t\t" .. tostring(rtpObj.cpass('result_', fnArgId))
								end
								if #fargs > 0 or rtp ~= "" then
									prepareArgs[#prepareArgs + 1] = "	stack" .. tostring(funcArgCount) .. " := NewCallStack()"
								end
								prepareArgs[#prepareArgs + 1] = "	func_id" .. tostring(funcArgCount) .. " := PushFunction(func() {\n" .. tostring(popArgStr) .. "		" .. tostring(callFunc) .. "\n	})"
								callbackName = fname
								callbackType = "func(" .. tostring(table.concat(argTypeStrs, ', ')) .. ")" .. tostring(rtp)
								_accum_0[_len_0] = {
									argName = callbackName,
									argType = callbackType,
									converted = callbackConverted
								}
								_len_0 = _len_0 + 1
							else
								_accum_0[_len_0] = error("unknown method argument kind")
								_len_0 = _len_0 + 1
							end
						end
						argItems = _accum_0
					end
					local argsList = table.concat((function()
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #argItems do
							local item = argItems[_index_2]
							_accum_0[_len_0] = tostring(item.argName) .. ": " .. tostring(item.argType)
							_len_0 = _len_0 + 1
						end
						return _accum_0
					end)(), ", ")
					local argsConverted = table.concat((function()
						local _accum_0 = { }
						local _len_0 = 1
						for _index_2 = 1, #argItems do
							local item = argItems[_index_2]
							_accum_0[_len_0] = tostring(item.converted)
							_len_0 = _len_0 + 1
						end
						return _accum_0
					end)(), ", ")
					local prepareStr = table.concat(prepareArgs, "\n")
					prepareStr = prepareStr == "" and "" or tostring(prepareStr) .. "\n"
					local waDocText
					if #docs > 0 then
						waDocText = table.concat(docs, '\n') .. '\n'
					else
						waDocText = ''
					end
					if isSingleton then
						local item = tostring(cppFuncName) .. "(" .. tostring(argsConverted) .. ")"
						waBinding[#waBinding + 1] = "func _" .. tostring(waNewName) .. "." .. tostring(waFuncName) .. "(" .. tostring(argsList) .. ")" .. tostring(waReturnType) .. " {\n" .. tostring(prepareStr) .. "	" .. tostring(waReturn(item)) .. "\n}"
					elseif isCreate then
						local dealOptional = isOptional and "if raw == 0 {\n\t\treturn nil\n\t}\n\tobject := " .. tostring(waNewName) .. "{}" or "object := " .. tostring(waNewName) .. "{}"
						if funcNewName == "new" then
							waFuncName = ""
						else
							waFuncName = snakeToPascal(funcNewName)
						end
						if isObject then
							waRuntime = true
							waBinding[#waBinding + 1] = tostring(waDocText) .. "func New" .. tostring(waNewName) .. tostring(waFuncName) .. "(" .. tostring(argsList) .. ")" .. tostring(waReturnType) .. " {\n" .. tostring(prepareStr) .. "	raw := " .. tostring(cppFuncName) .. "(" .. tostring(argsConverted) .. ")\n	" .. tostring(dealOptional) .. "\n	object.raw = &raw\n	runtime.SetFinalizer(object.raw, ObjectFinalizer)\n	return " .. tostring(isOptional and '&object' or 'object') .. "\n}"
						elseif isValue then
							waRuntime = true
							local finalizer = toSnakeCase(tostring(waNewName) .. "Finalizer")
							waBinding[#waBinding + 1] = tostring(waDocText) .. "func New" .. tostring(waNewName) .. tostring(waFuncName) .. "(" .. tostring(argsList) .. ")" .. tostring(waReturnType) .. " {\n" .. tostring(prepareStr) .. "	raw := " .. tostring(cppFuncName) .. "(" .. tostring(argsConverted) .. ")\n	" .. tostring(dealOptional) .. "\n	object.raw = &raw\n	runtime.SetFinalizer(object.raw, " .. tostring(finalizer) .. ")\n	return " .. tostring(isOptional and '&object' or 'object') .. "\n}"
						end
					elseif isStatic then
						local item = tostring(cppFuncName) .. "(" .. tostring(argsConverted) .. ")"
						waBinding[#waBinding + 1] = tostring(waDocText) .. "func " .. tostring(waNewName) .. tostring(waFuncName) .. "(" .. tostring(argsList) .. ")" .. tostring(waReturnType) .. " {\n" .. tostring(prepareStr) .. "	" .. tostring(waReturn(item)) .. "\n}"
					else
						local item = tostring(cppFuncName) .. "(*this.raw" .. tostring(argsConverted == "" and "" or ", " .. argsConverted) .. ")"
						waBinding[#waBinding + 1] = tostring(waDocText) .. "func " .. tostring(waNewName) .. "." .. tostring(waFuncName) .. "(" .. tostring(argsList) .. ")" .. tostring(waReturnType) .. " {\n" .. tostring(prepareStr) .. "	" .. tostring(waReturn(item)) .. "\n}"
					end
				else
					error("\"" .. tostring(dataType) .. "\" is not supported.")
				end
			end
		end
		if objectUsed then
			table.remove(rustBinding, objectUsed)
		end
		rustExtern[#rustExtern + 1] = "}"
		if isTrait then
			local isStaticFunc
			isStaticFunc = function(item)
				return item:match("fn ") and not item:match("&self") and not item:match("&mut self")
			end
			local createFuncs
			do
				local _accum_0 = { }
				local _len_0 = 1
				for _index_1 = 1, #rustBinding do
					local item = rustBinding[_index_1]
					if isStaticFunc(item) then
						_accum_0[_len_0] = item
						_len_0 = _len_0 + 1
					end
				end
				createFuncs = _accum_0
			end
			do
				local _accum_0 = { }
				local _len_0 = 1
				for _index_1 = 1, #rustBinding do
					local item = rustBinding[_index_1]
					if not isStaticFunc(item) then
						_accum_0[_len_0] = item
						_len_0 = _len_0 + 1
					end
				end
				rustBinding = _accum_0
			end
			if #createFuncs > 0 then
				rustBinding[#rustBinding + 1] = "}"
				rustBinding[#rustBinding + 1] = "impl " .. tostring(clsNewName) .. " {"
				for _index_1 = 1, #createFuncs do
					local func = createFuncs[_index_1]
					rustBinding[#rustBinding + 1] = func
				end
			end
		end
		rustBinding[#rustBinding + 1] = "}"
		cppLink[#cppLink + 1] = "}"
		local moduleScope = table.concat(moduleScopes, "/")
		local _f1
		do
			local _with_0 = io.open("../../Source/Wasm/Dora/" .. tostring(moduleScope ~= '' and moduleScope .. "/" .. cppModuleName or cppModuleName) .. "Wasm.hpp", "w")
			_with_0:write(licenseText)
			_with_0:write("\n\n")
			_with_0:write("extern \"C\" {\n")
			_with_0:write("using namespace Dora;\n")
			_with_0:write(table.concat(cppBinding, "\n"))
			_with_0:write("\n} // extern \"C\"\n")
			_with_0:write("\n")
			_with_0:write(table.concat(cppLink, "\n"))
			_f1 = _with_0
		end
		local _close_0 <close> = _f1
		moduleScope = table.concat((function()
			local _accum_0 = { }
			local _len_0 = 1
			for _index_1 = 1, #moduleScopes do
				local mod = moduleScopes[_index_1]
				_accum_0[_len_0] = toSnakeCase(mod)
				_len_0 = _len_0 + 1
			end
			return _accum_0
		end)(), "/")
		local _f2
		do
			local _with_0 = io.open("../dora-rust/dora/src/dora/" .. tostring(moduleScope ~= '' and moduleScope .. "/" .. moduleName or moduleName) .. ".rs", "w")
			_with_0:write(licenseText)
			_with_0:write("\n\n")
			_with_0:write(table.concat(rustExtern, "\n"))
			_with_0:write("\n")
			_with_0:write(table.concat(rustBinding, "\n"))
			_f2 = _with_0
		end
		local _close_1 <close> = _f2
		moduleScope = table.concat((function()
			local _accum_0 = { }
			local _len_0 = 1
			for _index_1 = 1, #moduleScopes do
				local mod = moduleScopes[_index_1]
				_accum_0[_len_0] = toSnakeCase(mod)
				_len_0 = _len_0 + 1
			end
			return _accum_0
		end)(), "_")
		local waFile = "../dora-wa/vendor/dora/" .. tostring(moduleScope ~= '' and moduleScope .. "_" .. moduleName or moduleName) .. ".wa"
		local _f3
		do
			local _with_0 = io.open(waFile, "w")
			_with_0:write(licenseText)
			_with_0:write("\n\n")
			if waRuntime then
				_with_0:write("import \"runtime\"\n")
			end
			_with_0:write(table.concat(waExtern, "\n"))
			_with_0:write("\n")
			_with_0:write(table.concat(waBinding, "\n"))
			_f3 = _with_0
		end
		local _close_2 <close> = _f3
		local _f4
		do
			local _with_0 = io.popen("wa fmt " .. tostring(waFile))
			_with_0:read("*a")
			_f4 = _with_0
		end
		local _close_3 <close> = _f4
		rustExtern = { }
		rustBinding = { }
		waExtern = { }
		waBinding = { }
		cppBinding = { }
		cppLink = { }
		::_continue_1::
	end
	return print(tostring(clsCount) .. " classes, " .. tostring(funcCount) .. " functions Done!")
end
