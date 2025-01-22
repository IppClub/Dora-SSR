/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Render/View.h"

#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Effect/Effect.h"
#include "Event/Event.h"
#include "Node/EffekNode.h"

NS_DORA_BEGIN

View::View()
	: _id(-1)
	, _nearPlaneDistance(0.1f)
	, _farPlaneDistance(10000.0f)
	, _fieldOfView(45.0f)
	,
#if BX_PLATFORM_WINDOWS
	_flag(BGFX_RESET_HIDPI)
	,
#else // BX_PLATFORM_WINDOWS
	_flag(BGFX_RESET_HIDPI | BGFX_RESET_VSYNC)
	,
#endif // BX_PLATFORM_WINDOWS
	_size(SharedApplication.getBufferSize())
	, _scale(1.0f)
	, _projection(Matrix::Indentity) {
	pushInsertionMode(false);
}

void View::pushInsertionMode(bool inserting) {
	_insertionModes.push({inserting, _orders.begin(), _orders.end()});
}

void View::popInsertionMode() {
	_insertionModes.pop();
}

bgfx::ViewId View::getId() const {
	AssertIf(_views.empty(), "invalid view id.");
	return _views.top().first;
}

const std::string& View::getName() const {
	AssertIf(_views.empty(), "invalid view id.");
	return _views.top().second;
}

void View::clear() {
	_id = -1;
	if (!_views.empty()) {
		decltype(_views) dummy;
		_views.swap(dummy);
	}
	_orders.clear();
}

void View::pushInner(String viewName) {
	AssertIf(_id > MaxViews - 1, "running views exceeded max view number {}.", s_cast<int>(MaxViews));
	bgfx::ViewId viewId = s_cast<bgfx::ViewId>(++_id);
	bgfx::resetView(viewId);
	std::string name = viewName.toString();
	if (!name.empty()) {
		bgfx::setViewName(viewId, name.c_str());
	}
	bgfx::setViewRect(viewId, 0, 0, bgfx::BackbufferRatio::Equal);
	bgfx::setViewMode(viewId, bgfx::ViewMode::Sequential);
	bgfx::touch(viewId);
	_views.push(std::make_pair(viewId, name));
}

void View::pushFront(String viewName) {
	pushInner(viewName);
	auto id = getId();
	auto& mode = _insertionModes.top();
	if (mode.inserting && !_orders.empty()) {
		mode.front = ++_orders.insert(mode.front, id);
	} else
		_orders.push_front(id);
	pushInsertionMode(false);
}

void View::pushBack(String viewName) {
	pushInner(viewName);
	auto id = getId();
	auto& mode = _insertionModes.top();
	if (mode.inserting && !_orders.empty()) {
		mode.back = _orders.insert(mode.back, id);
	} else
		_orders.push_back(id);
	pushInsertionMode(false);
}

void View::pop() {
	AssertIf(_views.empty(), "already pop to the last view, no more views to pop.");
	_views.pop();
	popInsertionMode();
}

Size View::getSize() const noexcept {
	return _size;
}

void View::setScale(float var) {
	_scale = var;
	Size bufferSize = SharedApplication.getBufferSize();
	_size = {
		// Metal Complained about non-integer size
		std::floor(bufferSize.width / _scale),
		std::floor(bufferSize.height / _scale)};
	View::updateProjection();
	Event::send("AppChange"_slice, "Size"s);
}

float View::getScale() const noexcept {
	return _scale;
}

void View::setVSync(bool var) {
	if (var != isVSync()) {
		if (var) {
			_flag |= BGFX_RESET_VSYNC;
		} else {
			_flag &= ~BGFX_RESET_VSYNC;
		}
		Size bufferSize = SharedApplication.getBufferSize();
		bgfx::reset(
			s_cast<uint32_t>(bufferSize.width),
			s_cast<uint32_t>(bufferSize.height),
			_flag);
	}
}

bool View::isVSync() const noexcept {
	return (_flag & BGFX_RESET_VSYNC) != 0;
}

bool View::isPostProcessNeeded() const noexcept {
	return _scale != 1.0f || _effect != nullptr || EffekNode::getRunningNodes() > 0;
}

float View::getStandardDistance() const noexcept {
	return _size.height * 0.5f / std::tan(bx::toRad(_fieldOfView) * 0.5f);
}

float View::getAspectRatio() const noexcept {
	return _size.width / _size.height;
}

void View::setNearPlaneDistance(float var) {
	_nearPlaneDistance = var;
	updateProjection();
}

float View::getNearPlaneDistance() const noexcept {
	return _nearPlaneDistance;
}

void View::setFarPlaneDistance(float var) {
	_farPlaneDistance = var;
	updateProjection();
}

float View::getFarPlaneDistance() const noexcept {
	return _farPlaneDistance;
}

void View::setFieldOfView(float var) {
	_fieldOfView = var;
	updateProjection();
}

float View::getFieldOfView() const noexcept {
	return _fieldOfView;
}

void View::updateProjection() {
	bx::mtxProj(
		_projection.m,
		_fieldOfView,
		getAspectRatio(),
		_nearPlaneDistance,
		_farPlaneDistance,
		bgfx::getCaps()->homogeneousDepth);
	SharedDirector.markDirty();
}

const Matrix& View::getProjection() const noexcept {
	return _projection;
}

void View::setPostEffect(SpriteEffect* var) {
	_effect = var;
}

SpriteEffect* View::getPostEffect() const noexcept {
	return _effect;
}

void View::reset() {
	Size bufferSize = SharedApplication.getBufferSize();
	bgfx::reset(
		s_cast<uint32_t>(bufferSize.width),
		s_cast<uint32_t>(bufferSize.height),
		_flag);
	_size = {
		std::floor(bufferSize.width / _scale),
		std::floor(bufferSize.height / _scale)};
	updateProjection();
}

std::pair<bgfx::ViewId*, uint16_t> View::getOrders() {
	int index = 0;
	for (auto order : _orders) {
		_idOrders[index] = s_cast<bgfx::ViewId>(order);
		index++;
	}
	while (index < MaxViews) {
		_idOrders[index] = index;
		index++;
	}
	return {_idOrders, s_cast<uint16_t>(MaxViews)};
}

NS_DORA_END
