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

#include "Const/Header.h"

#include "Node/Surface3D.h"

#include "Node/ClipNode.h"
#include "Node/DrawNode.h"
#include "Node/EffekNode.h"
#include "Node/Sprite.h"
#include "Node/View3D.h"
#include "Render/Camera.h"
#include "Render/Camera3D.h"
#include "Render/RenderTarget.h"
#include "Render/Renderer.h"
#include "Test/Test.h"

NS_DORA_BEGIN

class Surface3D::TransformProxy : public Node {
public:
	void setWorld(const Matrix& world) { _world = world; }
	virtual const Matrix& getWorld() override { return _world; }
	CREATE_FUNC_NOT_NULL(TransformProxy);

private:
	TransformProxy()
		: Node(false)
		, _world(Matrix::Indentity) { }
	Matrix _world;
	DORA_TYPE_OVERRIDE(TransformProxy);
};

Surface3D::Surface3D(Node* content, const Size& size, const Size& pixelSize)
	: Node3D(false)
	, _content(content)
	, _size(size)
	, _pixelSize(pixelSize)
	, _billboard(Billboard::None)
	, _usingTexture(false)
	, _renderMatrix(Matrix::Indentity) { }

Surface3D::~Surface3D() { }

Surface3D* Surface3D::create(Node* content, const Size& size, const Size& pixelSize) {
	if (!content || content->getParent()) return nullptr;
	auto surface = Own<Surface3D>(new Surface3D(content, size, pixelSize));
	if (surface->init()) return surface.release();
	return nullptr;
}

bool Surface3D::init() {
	if (!Node3D::init()) return false;
	_proxy = TransformProxy::create();
	_contentRoot = Node::create(false);
	_contentRoot->setAsManaged();
	_contentRoot->addChild(_content);
	_contentRoot->onEnter();
	return true;
}

void Surface3D::setContent(Node* content) {
	if (_content == content) return;
	AssertIf(content && content->getParent(), "Surface3D content already has a parent.");
	if (_contentRoot && _content) _contentRoot->removeChild(_content, true);
	_content = content;
	if (_contentRoot && _content) _contentRoot->addChild(_content);
	_renderTarget = nullptr;
	_surface = nullptr;
}

Node* Surface3D::getContent() const noexcept {
	return _content;
}

const Size& Surface3D::getSize() const noexcept {
	return _size;
}

void Surface3D::setSize(const Size& size) {
	_size = size;
}

const Size& Surface3D::getPixelSize() const noexcept {
	return _pixelSize;
}

void Surface3D::setPixelSize(const Size& size) {
	_pixelSize = size;
	_renderTarget = nullptr;
	_surface = nullptr;
}

Billboard Surface3D::getBillboard() const noexcept {
	return _billboard;
}

void Surface3D::setBillboard(Billboard billboard) {
	AssertIf(billboard > Billboard::YAxis, "Invalid Surface3D billboard value {}.", s_cast<int>(billboard));
	_billboard = billboard;
}

bool Surface3D::isUsingTexture() const noexcept {
	return _usingTexture;
}

Size Surface3D::getSourceSize() const {
	if (_content && _content->getSize() != Size::zero) return _content->getSize();
	if (_pixelSize != Size::zero) return _pixelSize;
	return {1.0f, 1.0f};
}

bool Surface3D::requiresTexture() const {
	if (!_content) return false;
	if (_content->hasGrabber()) return true;
	if (DoraIs<View3D>(_content.get()) || DoraIs<EffekNode>(_content.get()) || DoraIs<ClipNode>(_content.get())) return true;
	if (!DoraIs<Sprite>(_content.get()) && !DoraIs<DrawNode>(_content.get()) && _content->hasChildren() == false) return true;
	bool result = false;
	_content->traverseAll([&](Node* node) {
		// These nodes allocate their own pass or expect a standalone framebuffer.
		if (node->hasGrabber() || DoraIs<View3D>(node) || DoraIs<EffekNode>(node) || DoraIs<ClipNode>(node)) {
			result = true;
			return true;
		}
		// Direct mode is intentionally conservative. A plain container plus
		// sprites and DrawNodes shares the 3D depth buffer safely.
		if (node != _content && !DoraIs<Sprite>(node) && !DoraIs<DrawNode>(node)) {
			result = true;
			return true;
		}
		return false;
	});
	return result;
}

void Surface3D::updateRenderMatrix(Camera& camera) {
	_renderMatrix = getWorldMatrix();
	if (_billboard == Billboard::None) return;
	Vec3 position{_renderMatrix.m[12], _renderMatrix.m[13], _renderMatrix.m[14]};
	Vec3 toCamera = Vec3::from(bx::sub(camera.getPosition(), position));
	if (bx::length(toCamera) <= FLT_EPSILON) return;
	toCamera = Vec3::from(bx::normalize(toCamera));
	Vec3 up = _billboard == Billboard::YAxis ? Vec3{0.0f, 1.0f, 0.0f} : camera.getUp();
	if (_billboard == Billboard::YAxis) {
		toCamera.y = 0.0f;
		if (bx::length(toCamera) <= FLT_EPSILON) return;
		toCamera = Vec3::from(bx::normalize(toCamera));
	}
	Vec3 right = Vec3::from(bx::cross(up, toCamera));
	if (bx::length(right) <= FLT_EPSILON) return;
	right = Vec3::from(bx::normalize(right));
	up = Vec3::from(bx::normalize(bx::cross(toCamera, right)));
	float sx = bx::length(bx::Vec3{_renderMatrix.m[0], _renderMatrix.m[1], _renderMatrix.m[2]});
	float sy = bx::length(bx::Vec3{_renderMatrix.m[4], _renderMatrix.m[5], _renderMatrix.m[6]});
	float sz = bx::length(bx::Vec3{_renderMatrix.m[8], _renderMatrix.m[9], _renderMatrix.m[10]});
	_renderMatrix = Matrix::Indentity;
	_renderMatrix.m[0] = right.x * sx;
	_renderMatrix.m[1] = right.y * sx;
	_renderMatrix.m[2] = right.z * sx;
	_renderMatrix.m[4] = up.x * sy;
	_renderMatrix.m[5] = up.y * sy;
	_renderMatrix.m[6] = up.z * sy;
	_renderMatrix.m[8] = toCamera.x * sz;
	_renderMatrix.m[9] = toCamera.y * sz;
	_renderMatrix.m[10] = toCamera.z * sz;
	_renderMatrix.m[12] = position.x;
	_renderMatrix.m[13] = position.y;
	_renderMatrix.m[14] = position.z;
}

void Surface3D::resizeRenderTarget() {
	Size pixels = _pixelSize == Size::zero ? getSourceSize() : _pixelSize;
	uint16_t width = s_cast<uint16_t>(std::clamp(std::round(pixels.width), 1.0f, 4096.0f));
	uint16_t height = s_cast<uint16_t>(std::clamp(std::round(pixels.height), 1.0f, 4096.0f));
	if (_renderTarget && _renderTarget->getWidth() == width && _renderTarget->getHeight() == height) return;
	_renderTarget = RenderTarget::create(width, height);
	_surface = _renderTarget ? Sprite::create(_renderTarget->getTexture()) : nullptr;
	if (_surface) {
		// This sprite is submitted explicitly by Surface3D. Keep it out of the
		// Director's unmanaged-node adoption pass, which would otherwise attach
		// it to the regular 2D scene on the next frame.
		_surface->setAsManaged();
		_surface->setSize({s_cast<float>(width), s_cast<float>(height)});
	}
}

void Surface3D::renderDirect(Node* target) {
	if (!target || !_proxy) return;
	Size source = target == _surface.get() ? _surface->getSize() : getSourceSize();
	Matrix scale;
	// The 2D scene faces the 3D camera from the opposite side of its local XY
	// plane. Reverse X once at the shared projection boundary so direct and
	// render-target backends keep the same readable left-to-right orientation.
	bx::mtxScale(scale.m, -_size.width / source.width, _size.height / source.height, 1.0f);
	Matrix world;
	Matrix::mulMtx(world, _renderMatrix, scale);
	_proxy->setWorld(world);
	Node* transformTarget = target->getTransformTarget();
	target->setTransformTarget(_proxy);
	target->markDirty();
	SharedRendererManager.flush();
	// Surface3D is a transparent compositing layer: test against the shared 3D
	// depth buffer without modifying it. View3D orders surfaces back-to-front.
	SharedRendererManager.pushState(BGFX_STATE_DEPTH_TEST_LEQUAL, [&]() {
		target->visitInner();
		SharedRendererManager.flush();
	});
	target->setTransformTarget(transformTarget);
}

void Surface3D::prepareTexture() {
	resizeRenderTarget();
	if (!_renderTarget || !_surface || !_content) return;
	Size source = getSourceSize();
	_contentRoot->setPosition({
		s_cast<float>(_renderTarget->getWidth()) * 0.5f,
		s_cast<float>(_renderTarget->getHeight()) * 0.5f});
	_contentRoot->setScaleX(s_cast<float>(_renderTarget->getWidth()) / source.width);
	_contentRoot->setScaleY(s_cast<float>(_renderTarget->getHeight()) / source.height);
	_renderTarget->renderWithClear(_contentRoot, Color(0x00000000), 1.0f, 0);
	_contentRoot->setPosition(Vec2::zero);
	_contentRoot->setScaleX(1.0f);
	_contentRoot->setScaleY(1.0f);
}

void Surface3D::renderTexture() {
	if (!_surface) return;
	renderDirect(_surface);
}

void Surface3D::prepare(Camera& camera) {
	if (!isVisible() || !_content) return;
	updateRenderMatrix(camera);
	_usingTexture = requiresTexture();
	if (_usingTexture) prepareTexture();
}

void Surface3D::renderPrepared() {
	if (!isVisible() || !_content) return;
	if (_usingTexture) renderTexture();
	else {
		_contentRoot->markDirty();
		renderDirect(_contentRoot);
	}
}

void Surface3D::render(Camera& camera) {
	prepare(camera);
	renderPrepared();
}

void Surface3D::cleanup() {
	if (_contentRoot) _contentRoot->cleanup();
	_surface = nullptr;
	_renderTarget = nullptr;
	_proxy = nullptr;
	_contentRoot = nullptr;
	_content = nullptr;
	Node3D::cleanup();
}

NS_DORA_END

#if DORA_TEST
using namespace Dora;

// This runs inside the initialized engine through Application.runTest(). It
// exercises the adaptive decision on the same subtree while it changes at
// runtime, including the ClipNode and grabber paths that must be isolated.
DORA_TEST_ENTRY(Surface3DCpp) {
	auto content = Node::create();
	content->setSize({64.0f, 64.0f});
	auto draw = DrawNode::create();
	draw->drawDot({32.0f, 32.0f}, 16.0f, Color(0xffffffff));
	content->addChild(draw);
	auto surface = Surface3D::create(content, {2.0f, 2.0f}, {64.0f, 64.0f});
	auto camera = Camera3D::create("Surface3DTest"sv);
	if (!surface || !camera) return false;

	surface->render(*camera);
	if (surface->isUsingTexture()) return false;

	auto stencil = DrawNode::create();
	stencil->drawDot({32.0f, 32.0f}, 16.0f, Color(0xffffffff));
	auto clip = ClipNode::create(stencil);
	content->addChild(clip);
	surface->render(*camera);
	if (!surface->isUsingTexture()) return false;

	content->removeChild(clip, true);
	surface->render(*camera);
	if (surface->isUsingTexture()) return false;

	content->grab(true);
	surface->render(*camera);
	if (!surface->isUsingTexture()) return false;

	// Both billboard paths must remain valid with a dynamically selected
	// render target and a non-origin transform.
	surface->setPosition(1.0f, 2.0f, 3.0f);
	surface->setBillboard(Billboard::Screen);
	surface->render(*camera);
	surface->setBillboard(Billboard::YAxis);
	surface->render(*camera);
	return true;
}
#endif // DORA_TEST
