/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#pragma once

#include "Node/Node3D.h"

NS_DORA_BEGIN

class Node;
class Sprite;
class RenderTarget;
class Camera;

enum struct Billboard {
	None,
	Screen,
	YAxis,
};

/** A 2D node subtree displayed in a 3D scene.
 *
 * The backend is deliberately not exposed as a script property. Each frame
 * Surface3D inspects its current subtree: simple Sprite/DrawNode trees render
 * directly in a depth-preserving view after View3D; anything requiring an
 * isolated render pass is rasterized to a RenderTarget first and then
 * projected as a plane in that Surface3D view.
 */
class Surface3D : public Node3D {
public:
	PROPERTY(Node*, Content);
	PROPERTY_CREF(Size, Size);
	PROPERTY_CREF(Size, PixelSize);
	PROPERTY(Billboard, Billboard);
	PROPERTY_READONLY_BOOL(UsingTexture);

	static Surface3D* create(Node* content, const Size& size, const Size& pixelSize = Size::zero);
	virtual bool init() override;
	virtual void cleanup() override;
	virtual ~Surface3D();

	/** Prepares the adaptive backend and records any isolated render-target pass. */
	void prepare(Camera& camera);

	/** Submits the prepared plane in View3D's depth-preserving Surface3D view. */
	void renderPrepared();

	/** Convenience entry point used by native tests. */
	void render(Camera& camera);

protected:
	Surface3D(Node* content, const Size& size, const Size& pixelSize);

private:
	class TransformProxy;
	bool requiresTexture() const;
	Size getSourceSize() const;
	void updateRenderMatrix(Camera& camera);
	void renderDirect(Node* target);
	void prepareTexture();
	void renderTexture();
	void resizeRenderTarget();

	Ref<Node> _content;
	Ref<Node> _contentRoot;
	Ref<TransformProxy> _proxy;
	Ref<RenderTarget> _renderTarget;
	Ref<Sprite> _surface;
	Size _size;
	Size _pixelSize;
	Billboard _billboard;
	bool _usingTexture;
	Matrix _renderMatrix;
	DORA_TYPE_OVERRIDE(Surface3D);
};

NS_DORA_END
