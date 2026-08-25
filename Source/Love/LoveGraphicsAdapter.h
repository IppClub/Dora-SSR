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

#include "3rdParty/Love/src/common/Module.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Canvas.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsDraw.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsDisplayState.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsCapabilities.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsInfo.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsImageConstructor.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsFontState.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsFontConstructor.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsPrimitives.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsPrint.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsState.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsShaderConstructor.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsShaderState.h"
#include "3rdParty/Love/src/modules/graphics/wrap_GraphicsScreenshot.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Mesh.h"
#include "3rdParty/Love/src/modules/graphics/wrap_ParticleSystem.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Shader.h"
#include "3rdParty/Love/src/modules/graphics/wrap_SpriteBatch.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Text.h"
#include "3rdParty/Love/src/modules/graphics/wrap_Video.h"

namespace Dora::Love
{

class LoveRuntime;

/**
 * State-local Love Graphics module boundary for the embedded Dora renderer.
 *
 * This object intentionally owns no window, swapchain, present loop, or native
 * Love renderer. Upstream Lua wrappers resolve it through the owning Lua
 * state's REGISTRY_MODULES; backend commands remain implemented by LoveRuntime
 * and its injected GraphicsBackend.
 */
class DoraLoveGraphics final : public ::love::Module,
	public ::love::graphics::GraphicsDrawCommand,
	public ::love::graphics::GraphicsCanvasCommand,
	public ::love::graphics::GraphicsDisplayStateCommand,
	public ::love::graphics::GraphicsCapabilitiesCommand,
	public ::love::graphics::GraphicsInfoCommand,
	public ::love::graphics::GraphicsImageConstructorCommand,
	public ::love::graphics::GraphicsFontConstructorCommand,
	public ::love::graphics::GraphicsFontStateCommand,
	public ::love::graphics::GraphicsPrimitivesCommand,
	public ::love::graphics::GraphicsPrintCommand,
	public ::love::graphics::GraphicsStateCommand,
	public ::love::graphics::GraphicsShaderConstructorCommand,
	public ::love::graphics::GraphicsShaderStateCommand,
	public ::love::graphics::GraphicsScreenshotCommand,
	public ::love::graphics::GraphicsMeshCommand,
	public ::love::graphics::GraphicsSpriteBatchCommand,
	public ::love::graphics::GraphicsParticleSystemCommand,
	public ::love::graphics::GraphicsTextCommand,
	public ::love::graphics::GraphicsVideoCommand
{
public:
	static ::love::Type type;

	explicit DoraLoveGraphics(LoveRuntime *runtime) : _runtime(runtime) { }
	ModuleType getModuleType() const override { return M_GRAPHICS; }
	const char *getName() const override { return "love.graphics"; }
	LoveRuntime *getRuntime() const noexcept { return _runtime; }
	int getWidth() const override;
	int getHeight() const override;
	int getPixelWidth() const override;
	int getPixelHeight() const override;
	double getDPIScale() const override { return 1.0; }
	bool isActive() const override;
	bool isCreated() const override;
	bool isGammaCorrect() const override { return false; }
	BoolFields getSupported() const override;
	BoolFields getTextureTypes() const override;
	BoolFields getImageFormats() const override;
	BoolFields getCanvasFormats(bool readable) const override;
	RendererInfo getRendererInfo() const override;
	NumberFields getSystemLimits() const override;
	Stats getStats() const override;
	::love::graphics::Image *newImage(::love::graphics::Image::Slices &slices,
		const ::love::graphics::Image::Settings &settings) override;
	::love::graphics::Font *newDefaultFont(int size) override;
	::love::graphics::Font *newFont(::love::font::Rasterizer *rasterizer) override;
	void setFont(::love::graphics::Font *font) override;
	::love::graphics::Font *getFont() override;
	void setShader(::love::graphics::Shader *shader) override;
	::love::graphics::Shader *getShader() const override;
	::love::graphics::Shader *newShader(const std::string &vertexSource,
		const std::string &pixelSource) override;
	bool validateShader(bool gles, const std::string &vertexSource,
		const std::string &pixelSource, std::string &error) override;
	void captureScreenshot(lua_State *state,
		::love::graphics::GraphicsScreenshotRequest request) override;
	void points(const std::vector<::love::Vector2> &positions,
		const std::vector<::love::Colorf> &colors) override;
	void polyline(const std::vector<::love::Vector2> &vertices) override;
	void rectangle(DrawMode mode, float x, float y, float width, float height,
		float radiusX, float radiusY, int points) override;
	void circle(DrawMode mode, float x, float y, float radius, int points) override;
	void ellipse(DrawMode mode, float x, float y, float radiusX, float radiusY,
		int points) override;
	void arc(DrawMode drawMode, ArcMode arcMode, float x, float y, float radius,
		float angle1, float angle2, int points) override;
	void polygon(DrawMode mode, const std::vector<::love::Vector2> &vertices) override;
	void print(const std::vector<::love::graphics::Font::ColoredString> &text,
		::love::graphics::Font *font, const ::love::Matrix4 &transform) override;
	void printf(const std::vector<::love::graphics::Font::ColoredString> &text,
		::love::graphics::Font *font, float wrap,
		::love::graphics::Font::AlignMode align, const ::love::Matrix4 &transform) override;
	void draw(lua_State *state, ::love::graphics::Drawable *drawable,
		::love::graphics::Texture *texture, ::love::graphics::Quad *quad,
		const ::love::Matrix4 &transform) override;
	void drawLayer(lua_State *state, ::love::graphics::Texture *texture, int layer,
		::love::graphics::Quad *quad, const ::love::Matrix4 &transform) override;
	void drawInstanced(lua_State *state, ::love::graphics::Mesh *mesh,
		int instanceCount, const ::love::Matrix4 &transform) override;
	::love::graphics::Mesh *newMesh(const std::vector<::love::graphics::Vertex> &vertices,
		::love::graphics::PrimitiveType drawmode,
		::love::graphics::vertex::Usage usage) override;
	::love::graphics::Mesh *newMesh(int vertexcount,
		::love::graphics::PrimitiveType drawmode,
		::love::graphics::vertex::Usage usage) override;
	::love::graphics::Mesh *newMesh(
		const std::vector<::love::graphics::Mesh::AttribFormat> &vertexformat,
		int vertexcount, ::love::graphics::PrimitiveType drawmode,
		::love::graphics::vertex::Usage usage) override;
	::love::graphics::Mesh *newMesh(
		const std::vector<::love::graphics::Mesh::AttribFormat> &vertexformat,
		const void *data, size_t datasize, ::love::graphics::PrimitiveType drawmode,
		::love::graphics::vertex::Usage usage) override;
	::love::graphics::SpriteBatch *newSpriteBatch(::love::graphics::Texture *texture,
		int size, ::love::graphics::vertex::Usage usage) override;
	::love::graphics::ParticleSystem *newParticleSystem(
		::love::graphics::Texture *texture, int size) override;
	::love::graphics::Text *newText(::love::graphics::Font *font,
		const std::vector<::love::graphics::Font::ColoredString> &text) override;
	::love::graphics::Video *newVideo(::love::video::VideoStream *stream,
		float dpiScale) override;
	::love::graphics::Canvas *newCanvas(
		const ::love::graphics::Canvas::Settings &settings) override;
	void renderTo(lua_State *state, ::love::graphics::Canvas *canvas, int slice,
		int functionIndex) override;
	void stopStencilWrite() override;
	void setCanvas(lua_State *state, const GraphicsCanvasCommand::RenderTargets &targets) override;
	GraphicsCanvasCommand::RenderTargets getCanvas() const override;
	void clear(::love::Optional<::love::Colorf> color, ::love::OptionalInt stencil,
		::love::OptionalDouble depth) override;
	void clear(const std::vector<::love::Optional<::love::Colorf>> &colors,
		::love::OptionalInt stencil, ::love::OptionalDouble depth) override;
	void discard(const std::vector<bool> &colorBuffers,
		bool depthStencil) override;
	void reset(lua_State *state) override;
	void present(lua_State *state) override;
	void flushBatch() override;
	size_t getStackDepth() const override;
	void push(lua_State *state, StackType type) override;
	void pop(lua_State *state) override;
	void rotate(float angle) override;
	void scale(float x, float y) override;
	void translate(float x, float y) override;
	void shear(float x, float y) override;
	void origin() override;
	void applyTransform(::love::math::Transform *transform) override;
	void replaceTransform(::love::math::Transform *transform) override;
	::love::Vector2 transformPoint(::love::Vector2 point) const override;
	::love::Vector2 inverseTransformPoint(::love::Vector2 point) const override;
	void setColor(::love::Colorf color) override;
	::love::Colorf getColor() const override;
	void setBackgroundColor(::love::Colorf color) override;
	::love::Colorf getBackgroundColor() const override;
	void setLineWidth(float width) override;
	float getLineWidth() const override;
	void setLineStyle(LineStyle style) override;
	LineStyle getLineStyle() const override;
	void setLineJoin(LineJoin join) override;
	LineJoin getLineJoin() const override;
	void setPointSize(float size) override;
	float getPointSize() const override;
	void setColorMask(ColorMask mask) override;
	ColorMask getColorMask() const override;
	void setWireframe(bool enabled) override;
	bool isWireframe() const override;
	void setScissor() override;
	void setScissor(::love::Rect rect) override;
	void intersectScissor(::love::Rect rect) override;
	bool getScissor(::love::Rect &rect) const override;
	bool setDefaultFilter(Filter filter, std::string &error) override;
	Filter getDefaultFilter() const override;
	bool setDefaultMipmapFilter(FilterMode filter, float sharpness,
		std::string &error) override;
	void getDefaultMipmapFilter(FilterMode &filter, float &sharpness) const override;
	bool setBlendMode(BlendMode mode, BlendAlpha alphaMode,
		std::string &error) override;
	BlendMode getBlendMode(BlendAlpha &alphaMode) const override;
	void setDepthMode(CompareMode compare, bool write) override;
	CompareMode getDepthMode(bool &write) const override;
	void setMeshCullMode(CullMode mode) override;
	CullMode getMeshCullMode() const override;
	void setFrontFaceWinding(Winding winding) override;
	Winding getFrontFaceWinding() const override;
	void setStencilTest(CompareMode compare, int value) override;
	CompareMode getStencilTest(int &value) const override;
	bool beginStencilWrite(StencilAction action, int value,
		bool shouldClear, int clearValue, std::string &error) override;
	void endStencilWrite() override;

private:
	LoveRuntime *_runtime = nullptr;
};

} // namespace Dora::Love
