/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Playable.h"

#include "Node/DragonBone.h"
#include "Node/Model.h"
#include "Node/Spine.h"

NS_DORA_BEGIN

Playable::Playable()
	: _fliped(false)
	, _speed(1.0f)
	, _recoveryTime(0.0f) { }

void Playable::setFliped(bool var) {
	_fliped = var;
}

bool Playable::isFliped() const noexcept {
	return _fliped;
}

void Playable::setSpeed(float var) {
	_speed = var;
}

float Playable::getSpeed() const noexcept {
	return _speed;
}

void Playable::setRecovery(float var) {
	_recoveryTime = var;
}

float Playable::getRecovery() const noexcept {
	return _recoveryTime;
}

void Playable::setLook(String var) {
	_lookName = var.toString();
}

const std::string& Playable::getLook() const noexcept {
	return _lookName;
}

Playable* Playable::create(String filename) {
	if (filename.empty()) {
		Error("playable str must not be empty");
		return nullptr;
	}
	auto tokens = filename.split(":"_slice);
	if (tokens.size() != 2) {
		Error("playable str must be of format [label]:[filename], got \"{}\"", filename.toString());
		return nullptr;
	}
	switch (Switch::hash(tokens.front())) {
		case "model"_hash: return Model::create(tokens.back());
		case "spine"_hash: return Spine::create(tokens.back());
		case "bone"_hash: return DragonBone::create(tokens.back());
		default:
			Error("playable str flag must be of \"model\", \"spine\" and \"bone\", got \"{}\"", tokens.front().toString());
			return nullptr;
	}
}

NS_DORA_END
