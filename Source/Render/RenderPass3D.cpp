/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Render/RenderPass3D.h"

#include "Node/Visual3D.h"

#ifndef DORA_NO_RUST
extern "C" {
int32_t dora_3d_render_with_view(uint16_t view_id);
int32_t dora_3d_queue_visual(void* visual_handle, const float* world_matrix, uint16_t view_id);
}
#endif // DORA_NO_RUST

NS_DORA_BEGIN

void RenderPass3D::reset() {
	_opaqueItems.clear();
	_transparentItems.clear();
	_debugItems.clear();
}

void RenderPass3D::collect(const RenderItem3D& item) {
	if (item.transparent) {
		_transparentItems.push_back(item);
	} else {
		_opaqueItems.push_back(item);
	}
}

void RenderPass3D::sort() {
	std::sort(_opaqueItems.begin(), _opaqueItems.end(), [](const RenderItem3D& a, const RenderItem3D& b) {
		return a.sortKey < b.sortKey;
	});
	std::sort(_transparentItems.begin(), _transparentItems.end(), [](const RenderItem3D& a, const RenderItem3D& b) {
		return a.distanceToCamera > b.distanceToCamera;
	});
}

void RenderPass3D::submit(bgfx::ViewId viewId) {
	bgfx::touch(viewId);
#ifndef DORA_NO_RUST
	auto queueItem = [viewId](const RenderItem3D& item) {
		return item.visual
			&& item.visual->getRustVisual()
			&& dora_3d_queue_visual(item.visual->getRustVisual(), item.world.m, viewId) != 0;
	};
	bool queued = false;
	for (const auto& item : _opaqueItems) {
		queued = queueItem(item) || queued;
	}
	for (const auto& item : _transparentItems) {
		queued = queueItem(item) || queued;
	}
	for (const auto& item : _debugItems) {
		queued = queueItem(item) || queued;
	}
	if (queued) {
		dora_3d_render_with_view(viewId);
	}
#endif // DORA_NO_RUST
}

NS_DORA_END
