/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#define NS_DOROTHY_PLATFORMER_BEGIN namespace Dorothy { namespace Platformer {
#define NS_DOROTHY_PLATFORMER_END }}

NS_DOROTHY_PLATFORMER_BEGIN

enum struct AttackType
{
	Melee = 0,
	Range = 1
};

enum struct AttackTarget
{
	Single = 0,
	Multi = 1
};

enum struct Relation
{
	Unknown = 0,
	Friend = 1<<0,
	Neutral = 1<<1,
	Enemy = 1<<2,
	Any = Friend|Neutral|Enemy
};

/*
Target Allow
	Relation
		Unkown 0
		Friend 1<<0
		Neutral 1<<1
		Enemy 1<<2
	Group
		SharedData.getTerrainGroup() 1<<3
*/
class TargetAllow
{
public:
	TargetAllow();
	void setTerrainAllowed(bool var);
	bool isTerrainAllowed() const;
	void allow(Relation flag, bool allow);
	bool isAllow(Relation flag);
protected:
	Uint32 _flag;
};

NS_DOROTHY_PLATFORMER_END
