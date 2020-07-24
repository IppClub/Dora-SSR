/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Playable.h"
#include "Node/Model.h"
#include "Node/Spine.h"

NS_DOROTHY_BEGIN

Playable::Playable():
_faceRight(true),
_speed(1.0f),
_recoveryTime(0.0f)
{ }

void Playable::setFaceRight(bool var)
{
	_faceRight = var;
}

bool Playable::isFaceRight() const
{
	return _faceRight;
}

void Playable::setSpeed(float var)
{
	_speed = var;
}

float Playable::getSpeed() const
{
	return _speed;
}

void Playable::setRecovery(float var)
{
	_recoveryTime = var;
}

float Playable::getRecovery() const
{
	return _recoveryTime;
}

void Playable::setLook(String var)
{
	_lookName = var;
}

const string& Playable::getLook() const
{
	return _lookName;
}

Playable* Playable::create(String filename)
{
	if (filename.empty()) return Model::none();
	auto items = filename.split("|"_slice);
	BLOCK_START
	BREAK_IF(items.size() != 2);
	BREAK_IF(Path::getExt(items.front()) != "skel"_slice);
	BREAK_IF(Path::getExt(items.back()) != "atlas"_slice);
	return Spine::create(items.front(), items.back());
	BLOCK_END
	return Model::create(filename);
}

NS_DOROTHY_END
