/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_LUA_OLUAHELPER_H__
#define __DOROTHY_LUA_OLUAHELPER_H__

NS_DOROTHY_BEGIN

extern int g_luaType;

template <class T>
int oLuaType()
{
	static int type = g_luaType++;
	return type;
}

#define LUA_TYPE(type) \
public: virtual int getLuaType() const \
{ \
	return oLuaType<type>(); \
}

template <class OutT, class InT>
OutT* oLuaCast(InT* obj)
{
	return (obj && obj->getLuaType() == oLuaType<OutT>()) ? (OutT*)obj : nullptr;
}

NS_DOROTHY_END

#endif // __DOROTHY_LUA_OLUAHELPER_H__
