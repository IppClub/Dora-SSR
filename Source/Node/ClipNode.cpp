/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/ClipNode.h"

#include "Basic/Application.h"
#include "Cache/ShaderCache.h"
#include "Effect/Effect.h"
#include "Node/Sprite.h"
#include "Render/Renderer.h"
#include "Render/View.h"

NS_DORA_BEGIN

int ClipNode::_layer = -1;

ClipNode::ClipNode(Node* stencil)
	: _alphaThreshold(1.0f)
	, _stencil(stencil) {
	if (stencil && !stencil->getParent()) {
		stencil->setAsManaged();
	}
}

ClipNode::~ClipNode() { }

void ClipNode::setStencil(Node* var) {
	if (_stencil) {
		_stencil->onExit();
	}
	_stencil = var;
	if (_stencil) {
		if (!_stencil->getParent()) {
			_stencil->setAsManaged();
		}
		_stencil->setTransformTarget(this);
		setupAlphaTest();
		if (isRunning()) {
			_stencil->onEnter();
		}
	}
}

Node* ClipNode::getStencil() const noexcept {
	return _stencil;
}

void ClipNode::setAlphaThreshold(float var) {
	_alphaThreshold = var;
	setupAlphaTest();
}

float ClipNode::getAlphaThreshold() const noexcept {
	return _alphaThreshold;
}

void ClipNode::setInverted(bool var) {
	_flags.set(ClipNode::Inverted, var);
}

bool ClipNode::isInverted() const noexcept {
	return _flags.isOn(ClipNode::Inverted);
}

bool ClipNode::init() {
	if (!Node::init()) return false;
	if (_stencil) {
		_stencil->setTransformTarget(this);
	}
	return true;
}

void ClipNode::onEnter() {
	Node::onEnter();
	if (_stencil) {
		_stencil->onEnter();
	}
}

void ClipNode::onExit() {
	Node::onExit();
	if (_stencil) {
		_stencil->onExit();
	}
}

void ClipNode::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Node::cleanup();
		if (_stencil) {
			if (!_stencil->getParent()) {
				_stencil->cleanup();
			}
			_stencil = nullptr;
		}
	}
}

void ClipNode::drawFullScreenStencil(uint8_t maskLayer, bool value) {
	SharedRendererManager.flush();
	bgfx::TransientVertexBuffer vertexBuffer;
	bgfx::TransientIndexBuffer indexBuffer;
	if (bgfx::allocTransientBuffers(&vertexBuffer, PosColorVertex::ms_layout, 4, &indexBuffer, 6)) {
		Size viewSize = SharedView.getSize();
		float width = viewSize.width;
		float height = viewSize.height;
		Vec4 pos[4] = {
			{0, height, 0, 1},
			{width, height, 0, 1},
			{0, 0, 0, 1},
			{width, 0, 0, 1}};
		PosColorVertex* vertices = r_cast<PosColorVertex*>(vertexBuffer.data);
		Matrix ortho;
		bx::mtxOrtho(ortho.m, 0, width, 0, height, 0, 1000.0f, 0, bgfx::getCaps()->homogeneousDepth);
		for (int i = 0; i < 4; i++) {
			Matrix::mulVec4(&vertices[i].x, ortho, pos[i]);
		}
		const uint16_t indices[] = {0, 1, 2, 1, 3, 2};
		std::memcpy(indexBuffer.data, indices, sizeof(indices[0]) * 6);
		uint32_t func = BGFX_STENCIL_TEST_NEVER | BGFX_STENCIL_FUNC_REF(maskLayer) | BGFX_STENCIL_FUNC_RMASK(maskLayer);
		uint32_t fail = value ? BGFX_STENCIL_OP_FAIL_S_REPLACE : BGFX_STENCIL_OP_FAIL_S_ZERO;
		uint32_t op = fail | BGFX_STENCIL_OP_FAIL_Z_KEEP | BGFX_STENCIL_OP_PASS_Z_KEEP;
		uint32_t stencil = func | op;
		bgfx::setStencil(stencil);
		bgfx::setVertexBuffer(0, &vertexBuffer);
		bgfx::setIndexBuffer(&indexBuffer);
		bgfx::setState(BGFX_STATE_NONE);
		bgfx::ViewId viewId = SharedView.getId();
		bgfx::submit(viewId, SharedLineRenderer.getDefaultPass()->apply());
	}
}

void ClipNode::drawStencil(uint8_t maskLayer, bool value) {
	uint32_t func = BGFX_STENCIL_TEST_NEVER | BGFX_STENCIL_FUNC_REF(maskLayer) | BGFX_STENCIL_FUNC_RMASK(maskLayer);
	uint32_t fail = value ? BGFX_STENCIL_OP_FAIL_S_REPLACE : BGFX_STENCIL_OP_FAIL_S_ZERO;
	uint32_t op = fail | BGFX_STENCIL_OP_FAIL_Z_KEEP | BGFX_STENCIL_OP_PASS_Z_KEEP;
	SharedRendererManager.pushStencilState(func | op, [&]() {
		_stencil->visit();
		SharedRendererManager.flush();
	});
}

void ClipNode::setupAlphaTest() {
	if (_stencil) {
		bool setup = _alphaThreshold < 1.0f;
		SpriteEffect* effect = setup ? SharedSpriteRenderer.getAlphaTestEffect() : SharedSpriteRenderer.getDefaultEffect();
		_stencil->traverseAll([effect, this](Node* node) {
			if (Sprite* sprite = DoraAs<Sprite>(node)) {
				sprite->setEffect(effect);
				sprite->setAlphaRef(_alphaThreshold);
			}
			return false;
		});
	}
}

void ClipNode::visit() {
	if (!_stencil || !_stencil->isVisible()) {
		if (_flags.isOn(ClipNode::Inverted)) {
			Node::visit();
		}
		return;
	}
	if (_layer + 1 == 8) {
		static bool once = true;
		if (once) {
			once = false;
			Warn("nesting more than {} stencils is not supported. Everything will be drawn without stencil for this node and its childs.", 8);
		}
		Node::visit();
		return;
	}
	_layer++;
	uint32_t maskLayer = 1 << _layer;
	uint32_t maskLayerLess = maskLayer - 1;
	uint32_t maskLayerLessEqual = maskLayer | maskLayerLess;
	SharedRendererManager.flush();
	if (isInverted()) {
		drawFullScreenStencil(maskLayer, true);
	}
	drawStencil(maskLayer, !isInverted());
	uint32_t func = BGFX_STENCIL_TEST_EQUAL | BGFX_STENCIL_FUNC_REF(maskLayerLessEqual) | BGFX_STENCIL_FUNC_RMASK(maskLayerLessEqual);
	uint32_t op = BGFX_STENCIL_OP_FAIL_S_KEEP | BGFX_STENCIL_OP_FAIL_Z_KEEP | BGFX_STENCIL_OP_PASS_Z_KEEP;
	SharedRendererManager.pushStencilState(func | op, [&]() {
		Node::visit();
		SharedRendererManager.flush();
	});
	if (isInverted()) {
		drawFullScreenStencil(maskLayer, false);
	} else {
		drawStencil(maskLayer, false);
	}
	_layer--;
}

NS_DORA_END
