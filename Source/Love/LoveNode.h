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

#include "Love/LovePhysicsFilter.h"
#include "Love/LoveRuntime.h"
#include "Node/Sprite.h"
#include "Render/Renderer.h"

#include <memory>
#include <unordered_map>
#include <unordered_set>

NS_DORA_BEGIN

class DrawNode;
class AudioBus;
class AudioFile;
class AudioSource;
class Font;
class Label;
class Node;
class RenderTarget;
class Shader;
class SpriteEffect;
class Texture2D;
class PhysicsWorld;
class Body;
class FixtureDef;
class Joint;
struct LoveRecordingResource;

class LoveNode : public Sprite, private Love::GraphicsBackend, private Love::FilesystemBackend,
	private Love::ImageBackend,
	private Love::SoundBackend,
	private Love::AudioBackend, private Love::KeyboardBackend, private Love::MouseBackend,
	private Love::JoystickBackend,
	private Love::SystemBackend,
	private Love::PhysicsBackend
{
public:
	virtual ~LoveNode() override;
	virtual bool init() override;
	virtual void cleanup() override;
	virtual bool update(double deltaTime) override;
	virtual void render() override;

	bool restart();
	String getBootFile() const noexcept { return _bootFile; }
	String getSourceRoot() const noexcept { return _sourceRoot; }
	String getLastError() const noexcept;
	bool isRunning() const noexcept;

	CREATE_FUNC_NULLABLE(LoveNode);

protected:
	explicit LoveNode(String bootFile);

private:
	bool restartInstance(bool manageUpdateSchedule);
	bool loadBoot();
	bool extractLovePackage(std::string &mainFile, std::string &error);
	void clearLovePackage();
	bool setupSurface(int width, int height);
	void setupInputHandlers();
	void closeStoppedInstance();
	void clearInstanceResources();
	void focusInput();
	void releaseInputFocus();
	void applyMouseSettings();
	void resetHostMouseSettings();
	void handleKeyboardEvent(Event *event);
	void handlePointerEvent(Event *event);
	void handleControllerEvent(Event *event);
	bool reportError(String phase, const std::string &error);
	virtual void beginFrame() override;
	virtual bool clear(const Love::GraphicsBackend::ClearRequest &request,
		std::string &error) override;
	virtual bool rectangle(bool fill, float x, float y, float width, float height,
		float lineWidth, Love::GraphicsBackend::LineStyle lineStyle,
		Love::GraphicsBackend::LineJoin lineJoin, float red, float green, float blue,
		float alpha, std::string &error) override;
	virtual bool circle(bool fill, float x, float y, float radius,
		float lineWidth, Love::GraphicsBackend::LineStyle lineStyle,
		Love::GraphicsBackend::LineJoin lineJoin, float red, float green, float blue,
		float alpha, std::string &error) override;
	virtual bool line(const std::vector<float> &points,
		const Love::GraphicsBackend::Transform2D &transform, float lineWidth,
		Love::GraphicsBackend::LineStyle lineStyle, Love::GraphicsBackend::LineJoin lineJoin,
		float red, float green, float blue, float alpha, std::string &error) override;
	virtual bool polygon(bool fill, const std::vector<float> &points,
		const Love::GraphicsBackend::Transform2D &transform, float lineWidth,
		Love::GraphicsBackend::LineStyle lineStyle, Love::GraphicsBackend::LineJoin lineJoin,
		float red, float green, float blue, float alpha, std::string &error) override;
	virtual bool points(const std::vector<float> &points, float pointSize,
		float red, float green, float blue, float alpha, std::string &error) override;
	virtual Love::GraphicsBackend::ImageHandle newImage(const std::string &filename, std::string &error) override;
	virtual Love::GraphicsBackend::ImageHandle newImage(Love::GraphicsBackend::TextureType type,
		int width, int height, int slices, std::span<const std::uint8_t> rgba8,
		std::string &error) override;
	virtual Love::GraphicsBackend::ImageHandle newImage(Love::GraphicsBackend::TextureType type,
		std::span<const Love::GraphicsBackend::ImageLevel> levels, std::string &error) override;
	virtual Love::GraphicsBackend::ImageHandle newCompressedImage(std::string_view format,
		int width, int height, int mipmapCount, std::span<const std::uint8_t> data,
		std::string &error) override;
	virtual Love::GraphicsBackend::ImageHandle newCompressedImage(
		Love::GraphicsBackend::TextureType type, std::string_view format,
		std::span<const Love::GraphicsBackend::CompressedImageLevel> levels,
		std::string &error) override;
	virtual void releaseImage(Love::GraphicsBackend::ImageHandle image) override;
	virtual bool updateImage(Love::GraphicsBackend::ImageHandle image, int width, int height,
		std::span<const std::uint8_t> rgba8, std::string &error) override;
	virtual bool replaceImagePixels(Love::GraphicsBackend::ImageHandle image, int slice, int mipmap,
		int x, int y, int width, int height,
		std::span<const std::uint8_t> rgba8, std::string &error) override;
	virtual int getImageWidth(Love::GraphicsBackend::ImageHandle image) const override;
	virtual int getImageHeight(Love::GraphicsBackend::ImageHandle image) const override;
	virtual Love::GraphicsBackend::TextureType getImageTextureType(
		Love::GraphicsBackend::ImageHandle image) const override;
	virtual int getImageSliceCount(Love::GraphicsBackend::ImageHandle image) const override;
	virtual void drawImage(Love::GraphicsBackend::ImageHandle image,
		float sourceX, float sourceY, float sourceWidth, float sourceHeight,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha,
		Love::GraphicsBackend::TextureFilter filter,
		Love::GraphicsBackend::TextureWrap wrapU,
		Love::GraphicsBackend::TextureWrap wrapV) override;
	virtual bool drawImageLayer(Love::GraphicsBackend::ImageHandle image, int layer,
		float sourceX, float sourceY, float sourceWidth, float sourceHeight,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha,
		Love::GraphicsBackend::TextureFilter filter,
		Love::GraphicsBackend::TextureWrap wrapU,
		Love::GraphicsBackend::TextureWrap wrapV, std::string &error) override;
	virtual Love::GraphicsBackend::CanvasHandle newCanvas(int width, int height,
		const Love::GraphicsBackend::CanvasSettings &settings, std::string &error) override;
	virtual bool isCanvasFormatSupported(std::string_view format, bool readable) const override;
	virtual void releaseCanvas(Love::GraphicsBackend::CanvasHandle canvas) override;
	virtual int getCanvasWidth(Love::GraphicsBackend::CanvasHandle canvas) const override;
	virtual int getCanvasHeight(Love::GraphicsBackend::CanvasHandle canvas) const override;
	virtual bool readCanvas(Love::GraphicsBackend::CanvasHandle canvas, int slice, int mipmap,
		int x, int y,
		int width, int height, std::vector<std::uint8_t> &pixels, std::string &error) override;
	virtual bool generateCanvasMipmaps(Love::GraphicsBackend::CanvasHandle canvas,
		std::string &error) override;
	virtual bool setCanvases(std::span<const Love::GraphicsBackend::CanvasHandle> canvases,
		Love::GraphicsBackend::CanvasHandle depthStencil, bool depth, bool stencil,
		std::string &error) override;
	virtual bool setCanvasTargets(std::span<const Love::GraphicsBackend::CanvasTarget> canvases,
		const Love::GraphicsBackend::CanvasTarget *depthStencil, bool depth, bool stencil,
		std::string &error) override;
	virtual void drawCanvas(Love::GraphicsBackend::CanvasHandle canvas,
		float sourceX, float sourceY, float sourceWidth, float sourceHeight,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha,
		Love::GraphicsBackend::TextureFilter filter,
		Love::GraphicsBackend::TextureWrap wrapU,
		Love::GraphicsBackend::TextureWrap wrapV) override;
	virtual bool drawCanvasLayer(Love::GraphicsBackend::CanvasHandle canvas, int layer,
		float sourceX, float sourceY, float sourceWidth, float sourceHeight,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha,
		Love::GraphicsBackend::TextureFilter filter,
		Love::GraphicsBackend::TextureWrap wrapU,
		Love::GraphicsBackend::TextureWrap wrapV, std::string &error) override;
	virtual bool drawMesh(std::span<const Love::GraphicsBackend::MeshVertex> vertices,
		std::span<const Love::GraphicsBackend::MeshAttributeData> attributes,
		std::span<const std::uint32_t> indices, std::string_view drawMode,
		Love::GraphicsBackend::ImageHandle image, Love::GraphicsBackend::CanvasHandle canvas,
		float pointSize, Love::GraphicsBackend::TextureFilter filter,
		Love::GraphicsBackend::TextureWrap wrapU, Love::GraphicsBackend::TextureWrap wrapV,
		std::string &error, int instanceCount = 1) override;
	virtual Love::GraphicsBackend::ShaderHandle newShader(std::string_view vertexSource,
		std::string_view pixelSource, std::string &warnings, std::string &error) override;
	virtual void releaseShader(Love::GraphicsBackend::ShaderHandle shader) override;
	virtual bool hasShaderUniform(Love::GraphicsBackend::ShaderHandle shader,
		std::string_view name) const override;
	virtual bool getShaderUniformInfo(Love::GraphicsBackend::ShaderHandle shader,
		std::string_view name, Love::GraphicsBackend::ShaderUniformInfo &info) const override;
	virtual bool sendShaderFloats(Love::GraphicsBackend::ShaderHandle shader,
		std::string_view name, std::span<const float> values, bool colors,
		std::string &error) override;
	virtual bool sendShaderTextures(Love::GraphicsBackend::ShaderHandle shader,
		std::string_view name, std::span<const Love::GraphicsBackend::ShaderTexture> textures,
		std::string &error) override;
	virtual bool setShader(Love::GraphicsBackend::ShaderHandle shader, std::string &error) override;
	virtual bool validateShaderDraw(std::string &error,
		Love::GraphicsBackend::TextureType mainTextureType
			= Love::GraphicsBackend::TextureType::Texture2D) const override;
	virtual bool supportsMeshInstancing(Love::GraphicsBackend::ShaderHandle shader,
		std::size_t perInstanceAttributeCount) const override;
	virtual bool requiresMeshInstancing(
		Love::GraphicsBackend::ShaderHandle shader) const override;
	virtual bool requiresMeshVertexID(
		Love::GraphicsBackend::ShaderHandle shader) const override;
	virtual Love::GraphicsBackend::FontHandle newFont(const std::string &filename, int size, std::string &error) override;
	virtual Love::GraphicsBackend::FontHandle newImageFont(int width, int height,
		std::span<const std::uint8_t> rgba8,
		std::span<const Love::GraphicsBackend::ImageFontGlyph> glyphs, float dpiScale,
		Love::GraphicsBackend::TextureFilter filter, std::string &error) override;
	virtual Love::GraphicsBackend::FontHandle newBMFont(
		std::span<const Love::GraphicsBackend::BMFontPage> pages,
		std::span<const Love::GraphicsBackend::BMFontGlyph> glyphs, int lineHeight,
		int baseline, float dpiScale, Love::GraphicsBackend::TextureFilter filter,
		std::string &error) override;
	virtual void releaseFont(Love::GraphicsBackend::FontHandle font) override;
	virtual float getFontWidth(Love::GraphicsBackend::FontHandle font, std::string_view text) const override;
	virtual float getFontHeight(Love::GraphicsBackend::FontHandle font) const override;
	virtual float getFontBaseline(Love::GraphicsBackend::FontHandle font) const override;
	virtual float getFontAscent(Love::GraphicsBackend::FontHandle font) const override;
	virtual float getFontDescent(Love::GraphicsBackend::FontHandle font) const override;
	virtual bool hasFontGlyph(Love::GraphicsBackend::FontHandle font, std::uint32_t codepoint) const override;
	virtual float getFontKerning(Love::GraphicsBackend::FontHandle font, std::uint32_t left,
		std::uint32_t right) const override;
	virtual bool setFontFallbacks(Love::GraphicsBackend::FontHandle font,
		std::span<const Love::GraphicsBackend::FontHandle> fallbacks, std::string &error) override;
	virtual void setFontLineHeight(Love::GraphicsBackend::FontHandle font, float lineHeight) override;
	virtual float getFontLineHeight(Love::GraphicsBackend::FontHandle font) const override;
	virtual float getFontWrap(Love::GraphicsBackend::FontHandle font, std::string_view text, float limit,
		std::vector<std::string> &lines) const override;
	virtual void drawText(Love::GraphicsBackend::FontHandle font, std::string_view text,
		float wrapLimit, std::string_view align,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha) override;
	virtual bool setBlendMode(std::string_view mode, std::string_view alphaMode, std::string &error) override;
	virtual void setScissor(bool enabled, float x, float y, float width, float height) override;
	virtual void setColorMask(bool red, bool green, bool blue, bool alpha) override;
	virtual void setDepthMode(std::string_view compare, bool write) override;
	virtual void setMeshCullMode(std::string_view mode, std::string_view winding) override;
	virtual void setWireframe(bool enabled) override;
	virtual bool clearStencil(int value, std::string &error) override;
	virtual bool beginStencilWrite(std::string_view action, int value, std::string &error) override;
	virtual void endStencilWrite() override;
	virtual void setStencilTest(std::string_view compare, int value) override;
	virtual bool setMode(int width, int height, std::string &error) override;
	virtual bool hasWindowFocus() const override;
	virtual bool hasWindowMouseFocus() const override;
	virtual bool isWindowVisible() const override;
	virtual void endFrame() override;
	virtual int getPixelWidth() const override;
	virtual int getPixelHeight() const override;
	virtual Love::GraphicsBackend::Capabilities getCapabilities() const override;
	virtual Love::GraphicsBackend::TextureTypes getTextureTypes() const override;
	virtual bool isImageFormatSupported(std::string_view format) const override;
	virtual Love::GraphicsBackend::RendererInfo getRendererInfo() const override;
	virtual Love::GraphicsBackend::SystemLimits getSystemLimits() const override;
	virtual Love::GraphicsBackend::Stats getStats() const override;
	virtual bool requestScreenshot(std::uint64_t requestId, std::string &error) override;
	virtual bool exist(const std::string &path) const override;
	virtual bool isFolder(const std::string &path) const override;
	virtual bool load(const std::string &path, std::string &data, std::string &error) const override;
	virtual bool save(const std::string &path, std::string_view data, std::string &error) override;
	virtual bool createFolder(const std::string &path, std::string &error) override;
	virtual bool remove(const std::string &path, std::string &error) override;
	virtual std::optional<std::uint64_t> getFileSize(const std::string &path) const override;
	virtual std::vector<std::string> getDirectoryItems(const std::string &path) const override;
	virtual std::string getExecutablePath() const override;
	virtual bool mountArchive(std::string_view archiveName, std::string_view data,
		std::string &mountedRoot, std::string &error) override;
	virtual void unmountArchive(const std::string &mountedRoot) override;
	virtual bool decodeImage(std::string_view encoded, int &width, int &height,
		std::vector<std::uint8_t> &rgba8, std::string &error) override;
	virtual bool decodeCompressedImage(std::string_view encoded,
		Love::ImageBackend::CompressedImage &image, std::string &error) override;
	virtual bool encodeImage(std::string_view format, int width, int height,
		std::span<const std::uint8_t> rgba8, std::vector<std::uint8_t> &encoded,
		std::string &error) override;
	virtual bool decodeSound(std::string_view encoded, int &sampleRate, int &channels,
		std::vector<float> &samples, std::string &error) override;
	virtual Love::AudioBackend::SourceHandle newSource(const std::string &filename,
		std::string_view sourceType, std::string &error) override;
	virtual Love::AudioBackend::SourceHandle newSourceFromSoundData(std::string_view pcm,
		int sampleRate, int bitDepth, int channels, std::string &error) override;
	virtual Love::AudioBackend::SourceHandle newQueueableSource(int sampleRate, int bitDepth,
		int channels, int buffers, std::string &error) override;
	virtual Love::AudioBackend::SourceHandle cloneSource(
		Love::AudioBackend::SourceHandle source, std::string &error) override;
	virtual bool queueSource(Love::AudioBackend::SourceHandle source, std::string_view pcm,
		int sampleRate, int bitDepth, int channels, std::string &error) override;
	virtual int getSourceFreeBufferCount(
		Love::AudioBackend::SourceHandle source) const override;
	virtual void releaseSource(Love::AudioBackend::SourceHandle source) override;
	virtual bool playSource(Love::AudioBackend::SourceHandle source) override;
	virtual void pauseSource(Love::AudioBackend::SourceHandle source, bool paused) override;
	virtual void stopSource(Love::AudioBackend::SourceHandle source) override;
	virtual bool isSourcePlaying(Love::AudioBackend::SourceHandle source) const override;
	virtual bool isSourcePaused(Love::AudioBackend::SourceHandle source) const override;
	virtual void setSourceLooping(Love::AudioBackend::SourceHandle source, bool looping) override;
	virtual bool isSourceLooping(Love::AudioBackend::SourceHandle source) const override;
	virtual void setSourceVolume(Love::AudioBackend::SourceHandle source, float volume) override;
	virtual float getSourceVolume(Love::AudioBackend::SourceHandle source) const override;
	virtual void setSourcePitch(Love::AudioBackend::SourceHandle source, float pitch) override;
	virtual float getSourcePitch(Love::AudioBackend::SourceHandle source) const override;
	virtual void seekSource(Love::AudioBackend::SourceHandle source, double seconds) override;
	virtual double tellSource(Love::AudioBackend::SourceHandle source) const override;
	virtual double getSourceDuration(Love::AudioBackend::SourceHandle source) const override;
	virtual double getSourceSampleRate(Love::AudioBackend::SourceHandle source) const override;
	virtual double getSourceSampleCount(Love::AudioBackend::SourceHandle source) const override;
	virtual int getSourceChannelCount(Love::AudioBackend::SourceHandle source) const override;
	virtual void setSourcePosition(Love::AudioBackend::SourceHandle source,
		float x, float y, float z) override;
	virtual void getSourcePosition(Love::AudioBackend::SourceHandle source,
		float &x, float &y, float &z) const override;
	virtual void setSourceVelocity(Love::AudioBackend::SourceHandle source,
		float x, float y, float z) override;
	virtual void getSourceVelocity(Love::AudioBackend::SourceHandle source,
		float &x, float &y, float &z) const override;
	virtual void setSourceDirection(Love::AudioBackend::SourceHandle source,
		float x, float y, float z) override;
	virtual void getSourceDirection(Love::AudioBackend::SourceHandle source,
		float &x, float &y, float &z) const override;
	virtual void setSourceCone(Love::AudioBackend::SourceHandle source,
		float innerAngle, float outerAngle, float outerVolume, float outerHighGain) override;
	virtual void getSourceCone(Love::AudioBackend::SourceHandle source,
		float &innerAngle, float &outerAngle, float &outerVolume,
		float &outerHighGain) const override;
	virtual void setSourceAirAbsorption(Love::AudioBackend::SourceHandle source,
		float factor) override;
	virtual float getSourceAirAbsorption(Love::AudioBackend::SourceHandle source) const override;
	virtual void setSourceVolumeLimits(Love::AudioBackend::SourceHandle source,
		float minVolume, float maxVolume) override;
	virtual void getSourceVolumeLimits(Love::AudioBackend::SourceHandle source,
		float &minVolume, float &maxVolume) const override;
	virtual void setSourceRelative(Love::AudioBackend::SourceHandle source, bool relative) override;
	virtual bool isSourceRelative(Love::AudioBackend::SourceHandle source) const override;
	virtual void setSourceAttenuationDistances(Love::AudioBackend::SourceHandle source,
		float referenceDistance, float maxDistance) override;
	virtual void getSourceAttenuationDistances(Love::AudioBackend::SourceHandle source,
		float &referenceDistance, float &maxDistance) const override;
	virtual void setSourceRolloff(Love::AudioBackend::SourceHandle source, float rolloff) override;
	virtual float getSourceRolloff(Love::AudioBackend::SourceHandle source) const override;
	virtual void setInstanceVolume(float volume) override;
	virtual bool setMixWithSystem(bool mix) override;
	virtual void setListenerPosition(float x, float y, float z) override;
	virtual void getListenerPosition(float &x, float &y, float &z) const override;
	virtual void setListenerOrientation(float forwardX, float forwardY, float forwardZ,
		float upX, float upY, float upZ) override;
	virtual void getListenerOrientation(float &forwardX, float &forwardY, float &forwardZ,
		float &upX, float &upY, float &upZ) const override;
	virtual void setListenerVelocity(float x, float y, float z) override;
	virtual void getListenerVelocity(float &x, float &y, float &z) const override;
	virtual void setDopplerScale(float scale) override;
	virtual float getDopplerScale() const override;
	virtual void setDistanceModel(std::string_view model) override;
	virtual std::string getDistanceModel() const override;
	virtual bool isEffectsSupported() const override;
	virtual int getMaxSceneEffects() const override;
	virtual int getMaxSourceEffects() const override;
	virtual bool setEffect(std::string_view name,
		const Love::AudioBackend::EffectSettings *effect, std::string &error) override;
	virtual bool setSourceFilter(Love::AudioBackend::SourceHandle source,
		const Love::AudioBackend::FilterSettings *filter, std::string &error) override;
	virtual bool setSourceEffect(Love::AudioBackend::SourceHandle source, std::string_view name,
		const Love::AudioBackend::FilterSettings *filter, bool enabled, std::string &error) override;
	virtual std::vector<std::string> getRecordingDeviceNames() const override;
	virtual Love::AudioBackend::RecordingHandle startRecording(std::string_view deviceName,
		int maxSamples, int sampleRate, int bitDepth, int channels, std::string &error) override;
	virtual void stopRecording(Love::AudioBackend::RecordingHandle recording) override;
	virtual int getRecordingSampleCount(
		Love::AudioBackend::RecordingHandle recording) const override;
	virtual bool getRecordingData(Love::AudioBackend::RecordingHandle recording,
		std::vector<std::uint8_t> &pcm, std::string &error) override;
	virtual void setTextInput(bool enabled, bool hasRectangle,
		float x, float y, float width, float height) override;
	virtual std::string getScancodeFromKey(std::string_view key) const override;
	virtual std::string getKeyFromScancode(std::string_view scancode) const override;
	virtual bool hasScreenKeyboard() const override;
	virtual void setMousePosition(float x, float y) override;
	virtual void setMouseVisible(bool visible) override;
	virtual void setMouseGrabbed(bool grabbed) override;
	virtual bool setMouseRelativeMode(bool relative) override;
	virtual Love::MouseBackend::CursorHandle createImageCursor(int width, int height,
		std::span<const std::uint8_t> rgba8, int hotX, int hotY, std::string &error) override;
	virtual Love::MouseBackend::CursorHandle createSystemCursor(
		std::string_view type, std::string &error) override;
	virtual void releaseCursor(Love::MouseBackend::CursorHandle handle) override;
	virtual void setMouseCursor(Love::MouseBackend::CursorHandle handle) override;
	virtual bool isMouseCursorSupported() const override;
	virtual Love::JoystickBackend::DeviceInfo getJoystickInfo(int id) const override;
	virtual float getJoystickAxis(int id, int axis) const override;
	virtual int getJoystickHat(int id, int hat) const override;
	virtual bool isJoystickButtonDown(int id, int button) const override;
	virtual bool setJoystickVibration(int id, float left, float right, double duration) override;
	virtual bool setGamepadMapping(std::string_view guid, std::string_view gamepadInput,
		std::string_view inputType, int index, std::string_view hat, std::string &error) override;
	virtual bool loadGamepadMappings(std::string_view mappings, std::string &error) override;
	virtual std::string saveGamepadMappings() const override;
	virtual std::string getGamepadMappingString(std::string_view guid) const override;
	virtual std::optional<Love::JoystickBackend::GamepadMapping> getJoystickGamepadMapping(int id,
		std::string_view gamepadInput) const override;
	virtual std::string getJoystickGamepadMappingString(int id) const override;
	virtual std::string getOS() const override;
	virtual int getProcessorCount() const override;
	virtual bool setClipboardText(std::string_view text, std::string &error) override;
	virtual bool getClipboardText(std::string &text, std::string &error) const override;
	virtual Love::SystemBackend::PowerInfo getPowerInfo() const override;
	virtual bool openURL(std::string_view url, std::string &error) override;
	virtual void vibrate(double seconds) override;
	virtual bool hasBackgroundMusic() const override;
	virtual void setMeter(float meter) override;
	virtual Love::PhysicsBackend::WorldHandle newWorld(float gravityX, float gravityY,
		bool sleep, std::string &error) override;
	virtual void releaseWorld(Love::PhysicsBackend::WorldHandle world) override;
	virtual bool isWorldValid(Love::PhysicsBackend::WorldHandle world) const override;
	virtual bool updateWorld(Love::PhysicsBackend::WorldHandle world, float deltaTime,
		int velocityIterations, int positionIterations, std::string &error) override;
	virtual bool setWorldGravity(Love::PhysicsBackend::WorldHandle world,
		float x, float y, std::string &error) override;
	virtual bool getWorldGravity(Love::PhysicsBackend::WorldHandle world,
		float &x, float &y, std::string &error) const override;
	virtual bool setWorldSleepingAllowed(Love::PhysicsBackend::WorldHandle world,
		bool value, std::string &error) override;
	virtual bool isWorldSleepingAllowed(Love::PhysicsBackend::WorldHandle world,
		bool &value, std::string &error) const override;
	virtual bool queryWorld(Love::PhysicsBackend::WorldHandle world,
		float x1, float y1, float x2, float y2,
		std::vector<Love::PhysicsBackend::FixtureHandle> &fixtures,
		std::string &error) const override;
	virtual bool raycastWorld(Love::PhysicsBackend::WorldHandle world,
		float x1, float y1, float x2, float y2,
		std::vector<Love::PhysicsBackend::RayHit> &hits,
		std::string &error) const override;
	virtual bool setWorldContactCallback(Love::PhysicsBackend::WorldHandle world,
		Love::PhysicsBackend::ContactCallback callback, std::string &error) override;
	virtual bool isContactValid(Love::PhysicsBackend::ContactHandle contact) const override;
	virtual bool getContactPositions(Love::PhysicsBackend::ContactHandle contact,
		std::vector<float> &positions, std::string &error) const override;
	virtual bool getContactNormal(Love::PhysicsBackend::ContactHandle contact,
		float &x, float &y, std::string &error) const override;
	virtual bool getContactFriction(Love::PhysicsBackend::ContactHandle contact,
		float &friction, std::string &error) const override;
	virtual bool setContactFriction(Love::PhysicsBackend::ContactHandle contact,
		float friction, std::string &error) override;
	virtual bool resetContactFriction(Love::PhysicsBackend::ContactHandle contact,
		std::string &error) override;
	virtual bool getContactRestitution(Love::PhysicsBackend::ContactHandle contact,
		float &restitution, std::string &error) const override;
	virtual bool setContactRestitution(Love::PhysicsBackend::ContactHandle contact,
		float restitution, std::string &error) override;
	virtual bool resetContactRestitution(Love::PhysicsBackend::ContactHandle contact,
		std::string &error) override;
	virtual bool isContactEnabled(Love::PhysicsBackend::ContactHandle contact,
		bool &enabled, std::string &error) const override;
	virtual bool setContactEnabled(Love::PhysicsBackend::ContactHandle contact,
		bool enabled, std::string &error) override;
	virtual bool isContactTouching(Love::PhysicsBackend::ContactHandle contact,
		bool &touching, std::string &error) const override;
	virtual bool getContactTangentSpeed(Love::PhysicsBackend::ContactHandle contact,
		float &speed, std::string &error) const override;
	virtual bool setContactTangentSpeed(Love::PhysicsBackend::ContactHandle contact,
		float speed, std::string &error) override;
	virtual Love::PhysicsBackend::ShapeHandle newCircleShape(float x, float y,
		float radius, std::string &error) override;
	virtual Love::PhysicsBackend::ShapeHandle newRectangleShape(float x, float y,
		float width, float height, float angle, std::string &error) override;
	virtual Love::PhysicsBackend::ShapeHandle newPolygonShape(std::vector<float> &points,
		std::string &error) override;
	virtual Love::PhysicsBackend::ShapeHandle newEdgeShape(float x1, float y1, float x2, float y2,
		std::string &error) override;
	virtual Love::PhysicsBackend::ShapeHandle newChainShape(bool loop,
		const std::vector<float> &points, std::string &error) override;
	virtual bool setShapePreviousVertex(Love::PhysicsBackend::ShapeHandle shape,
		bool hasVertex, float x, float y, std::string &error) override;
	virtual bool setShapeNextVertex(Love::PhysicsBackend::ShapeHandle shape,
		bool hasVertex, float x, float y, std::string &error) override;
	virtual void releaseShape(Love::PhysicsBackend::ShapeHandle shape) override;
	virtual Love::PhysicsBackend::BodyHandle newBody(Love::PhysicsBackend::WorldHandle world,
		float x, float y, std::string_view type, std::string &error) override;
	virtual void releaseBody(Love::PhysicsBackend::BodyHandle body) override;
	virtual bool isBodyValid(Love::PhysicsBackend::BodyHandle body) const override;
	virtual bool getBodyPosition(Love::PhysicsBackend::BodyHandle body,
		float &x, float &y, std::string &error) const override;
	virtual bool setBodyPosition(Love::PhysicsBackend::BodyHandle body,
		float x, float y, std::string &error) override;
	virtual bool getBodyAngle(Love::PhysicsBackend::BodyHandle body,
		float &angle, std::string &error) const override;
	virtual bool setBodyAngle(Love::PhysicsBackend::BodyHandle body,
		float angle, std::string &error) override;
	virtual bool getBodyLinearVelocity(Love::PhysicsBackend::BodyHandle body,
		float &x, float &y, std::string &error) const override;
	virtual bool setBodyLinearVelocity(Love::PhysicsBackend::BodyHandle body,
		float x, float y, std::string &error) override;
	virtual bool getBodyAngularVelocity(Love::PhysicsBackend::BodyHandle body,
		float &value, std::string &error) const override;
	virtual bool setBodyAngularVelocity(Love::PhysicsBackend::BodyHandle body,
		float value, std::string &error) override;
	virtual bool getBodyLinearDamping(Love::PhysicsBackend::BodyHandle body,
		float &value, std::string &error) const override;
	virtual bool setBodyLinearDamping(Love::PhysicsBackend::BodyHandle body,
		float value, std::string &error) override;
	virtual bool getBodyAngularDamping(Love::PhysicsBackend::BodyHandle body,
		float &value, std::string &error) const override;
	virtual bool setBodyAngularDamping(Love::PhysicsBackend::BodyHandle body,
		float value, std::string &error) override;
	virtual bool getBodyMass(Love::PhysicsBackend::BodyHandle body,
		float &value, std::string &error) const override;
	virtual bool getBodyInertia(Love::PhysicsBackend::BodyHandle body,
		float &value, std::string &error) const override;
	virtual bool getBodyMassData(Love::PhysicsBackend::BodyHandle body,
		float &x, float &y, float &mass, float &inertia, std::string &error) const override;
	virtual bool setBodyMassData(Love::PhysicsBackend::BodyHandle body,
		float x, float y, float mass, float inertia, std::string &error) override;
	virtual bool resetBodyMassData(Love::PhysicsBackend::BodyHandle body,
		std::string &error) override;
	virtual bool setBodyMass(Love::PhysicsBackend::BodyHandle body,
		float mass, std::string &error) override;
	virtual bool setBodyInertia(Love::PhysicsBackend::BodyHandle body,
		float inertia, std::string &error) override;
	virtual bool getBodyGravityScale(Love::PhysicsBackend::BodyHandle body,
		float &value, std::string &error) const override;
	virtual bool setBodyGravityScale(Love::PhysicsBackend::BodyHandle body,
		float value, std::string &error) override;
	virtual bool getBodyCenter(Love::PhysicsBackend::BodyHandle body, bool world,
		float &x, float &y, std::string &error) const override;
	virtual bool isBodyFixedRotation(Love::PhysicsBackend::BodyHandle body,
		bool &value, std::string &error) const override;
	virtual bool setBodyFixedRotation(Love::PhysicsBackend::BodyHandle body,
		bool value, std::string &error) override;
	virtual bool isBodyAwake(Love::PhysicsBackend::BodyHandle body,
		bool &value, std::string &error) const override;
	virtual bool setBodyAwake(Love::PhysicsBackend::BodyHandle body,
		bool value, std::string &error) override;
	virtual bool isBodySleepingAllowed(Love::PhysicsBackend::BodyHandle body,
		bool &value, std::string &error) const override;
	virtual bool setBodySleepingAllowed(Love::PhysicsBackend::BodyHandle body,
		bool value, std::string &error) override;
	virtual bool isBodyActive(Love::PhysicsBackend::BodyHandle body,
		bool &value, std::string &error) const override;
	virtual bool setBodyActive(Love::PhysicsBackend::BodyHandle body,
		bool value, std::string &error) override;
	virtual bool isBodyBullet(Love::PhysicsBackend::BodyHandle body,
		bool &value, std::string &error) const override;
	virtual bool setBodyBullet(Love::PhysicsBackend::BodyHandle body,
		bool value, std::string &error) override;
	virtual bool setBodyType(Love::PhysicsBackend::BodyHandle body,
		std::string_view type, std::string &error) override;
	virtual bool transformBodyPoint(Love::PhysicsBackend::BodyHandle body,
		bool toWorld, bool vector, float x, float y, float &outX, float &outY,
		std::string &error) const override;
	virtual bool getBodyPointVelocity(Love::PhysicsBackend::BodyHandle body,
		bool local, float x, float y, float &outX, float &outY,
		std::string &error) const override;
	virtual bool applyBodyLinearImpulse(Love::PhysicsBackend::BodyHandle body,
		float impulseX, float impulseY, float pointX, float pointY, std::string &error) override;
	virtual bool applyBodyAngularImpulse(Love::PhysicsBackend::BodyHandle body,
		float impulse, std::string &error) override;
	virtual bool applyBodyForce(Love::PhysicsBackend::BodyHandle body,
		float forceX, float forceY, float pointX, float pointY, std::string &error) override;
	virtual bool applyBodyTorque(Love::PhysicsBackend::BodyHandle body,
		float torque, std::string &error) override;
	virtual Love::PhysicsBackend::FixtureHandle newFixture(Love::PhysicsBackend::BodyHandle body,
		Love::PhysicsBackend::ShapeHandle shape, float density, std::string &error) override;
	virtual void releaseFixture(Love::PhysicsBackend::FixtureHandle fixture) override;
	virtual bool isFixtureValid(Love::PhysicsBackend::FixtureHandle fixture) const override;
	virtual bool setFixtureFriction(Love::PhysicsBackend::FixtureHandle fixture,
		float friction, std::string &error) override;
	virtual bool setFixtureRestitution(Love::PhysicsBackend::FixtureHandle fixture,
		float restitution, std::string &error) override;
	virtual bool setFixtureSensor(Love::PhysicsBackend::FixtureHandle fixture,
		bool sensor, std::string &error) override;
	virtual bool setFixtureDensity(Love::PhysicsBackend::FixtureHandle fixture,
		float density, std::string &error) override;
	virtual bool testFixturePoint(Love::PhysicsBackend::FixtureHandle fixture,
		float x, float y, bool &value, std::string &error) const override;
	virtual bool rayCastFixture(Love::PhysicsBackend::FixtureHandle fixture,
		float x1, float y1, float x2, float y2, float maxFraction,
		std::uint16_t childIndex, bool &hit, float &normalX, float &normalY,
		float &fraction, std::string &error) const override;
	virtual bool getFixtureFilterData(Love::PhysicsBackend::FixtureHandle fixture,
		std::uint16_t &categoryBits, std::uint16_t &maskBits,
		std::int16_t &groupIndex, std::string &error) const override;
	virtual bool setFixtureFilterData(Love::PhysicsBackend::FixtureHandle fixture,
		std::uint16_t categoryBits, std::uint16_t maskBits,
		std::int16_t groupIndex, std::string &error) override;
	virtual bool getFixtureBoundingBox(Love::PhysicsBackend::FixtureHandle fixture,
		std::uint16_t childIndex, float &x1, float &y1, float &x2, float &y2,
		std::string &error) const override;
	virtual bool getFixtureMassData(Love::PhysicsBackend::FixtureHandle fixture,
		float &x, float &y, float &mass, float &inertia,
		std::string &error) const override;
	virtual Love::PhysicsBackend::JointHandle newDistanceJoint(
		Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
		float x1, float y1, float x2, float y2, bool collideConnected,
		std::string &error) override;
	virtual void releaseJoint(Love::PhysicsBackend::JointHandle joint) override;
	virtual bool isJointValid(Love::PhysicsBackend::JointHandle joint) const override;
	virtual bool getJointAnchors(Love::PhysicsBackend::JointHandle joint,
		float &x1, float &y1, float &x2, float &y2, std::string &error) const override;
	virtual bool getJointReactionForce(Love::PhysicsBackend::JointHandle joint,
		float inverseDeltaTime, float &x, float &y, std::string &error) const override;
	virtual bool getJointReactionTorque(Love::PhysicsBackend::JointHandle joint,
		float inverseDeltaTime, float &value, std::string &error) const override;
	virtual bool getJointCollideConnected(Love::PhysicsBackend::JointHandle joint,
		bool &value, std::string &error) const override;
	virtual bool getDistanceJointLength(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setDistanceJointLength(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getDistanceJointFrequency(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setDistanceJointFrequency(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getDistanceJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setDistanceJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual Love::PhysicsBackend::JointHandle newRevoluteJoint(
		Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
		float x1, float y1, float x2, float y2, bool collideConnected,
		bool hasReferenceAngle, float referenceAngle, std::string &error) override;
	virtual bool getRevoluteJointAngle(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool getRevoluteJointSpeed(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool isRevoluteJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
		bool &value, std::string &error) const override;
	virtual bool setRevoluteJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
		bool value, std::string &error) override;
	virtual bool getRevoluteJointMaxMotorTorque(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setRevoluteJointMaxMotorTorque(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getRevoluteJointMotorSpeed(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setRevoluteJointMotorSpeed(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getRevoluteJointMotorTorque(Love::PhysicsBackend::JointHandle joint,
		float inverseDeltaTime, float &value, std::string &error) const override;
	virtual bool areRevoluteJointLimitsEnabled(Love::PhysicsBackend::JointHandle joint,
		bool &value, std::string &error) const override;
	virtual bool setRevoluteJointLimitsEnabled(Love::PhysicsBackend::JointHandle joint,
		bool value, std::string &error) override;
	virtual bool getRevoluteJointLimits(Love::PhysicsBackend::JointHandle joint,
		float &lower, float &upper, std::string &error) const override;
	virtual bool setRevoluteJointLimits(Love::PhysicsBackend::JointHandle joint,
		float lower, float upper, std::string &error) override;
	virtual bool getRevoluteJointReferenceAngle(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual Love::PhysicsBackend::JointHandle newPrismaticJoint(
		Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
		float x1, float y1, float x2, float y2, float axisX, float axisY,
		bool collideConnected, bool hasReferenceAngle, float referenceAngle,
		std::string &error) override;
	virtual bool getPrismaticJointTranslation(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool getPrismaticJointSpeed(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool isPrismaticJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
		bool &value, std::string &error) const override;
	virtual bool setPrismaticJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
		bool value, std::string &error) override;
	virtual bool getPrismaticJointMaxMotorForce(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setPrismaticJointMaxMotorForce(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getPrismaticJointMotorSpeed(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setPrismaticJointMotorSpeed(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getPrismaticJointMotorForce(Love::PhysicsBackend::JointHandle joint,
		float inverseDeltaTime, float &value, std::string &error) const override;
	virtual bool arePrismaticJointLimitsEnabled(Love::PhysicsBackend::JointHandle joint,
		bool &value, std::string &error) const override;
	virtual bool setPrismaticJointLimitsEnabled(Love::PhysicsBackend::JointHandle joint,
		bool value, std::string &error) override;
	virtual bool getPrismaticJointLimits(Love::PhysicsBackend::JointHandle joint,
		float &lower, float &upper, std::string &error) const override;
	virtual bool setPrismaticJointLimits(Love::PhysicsBackend::JointHandle joint,
		float lower, float upper, std::string &error) override;
	virtual bool getPrismaticJointAxis(Love::PhysicsBackend::JointHandle joint,
		float &x, float &y, std::string &error) const override;
	virtual bool getPrismaticJointReferenceAngle(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual Love::PhysicsBackend::JointHandle newWeldJoint(
		Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
		float x1, float y1, float x2, float y2, bool collideConnected,
		bool hasReferenceAngle, float referenceAngle, std::string &error) override;
	virtual bool getWeldJointFrequency(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setWeldJointFrequency(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getWeldJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setWeldJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getWeldJointReferenceAngle(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual Love::PhysicsBackend::JointHandle newFrictionJoint(
		Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
		float x1, float y1, float x2, float y2, bool collideConnected,
		std::string &error) override;
	virtual bool getFrictionJointMaxForce(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setFrictionJointMaxForce(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getFrictionJointMaxTorque(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setFrictionJointMaxTorque(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual Love::PhysicsBackend::JointHandle newRopeJoint(
		Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
		float x1, float y1, float x2, float y2, float maxLength,
		bool collideConnected, std::string &error) override;
	virtual bool getRopeJointMaxLength(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setRopeJointMaxLength(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual Love::PhysicsBackend::JointHandle newPulleyJoint(
		Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
		float groundX1, float groundY1, float groundX2, float groundY2,
		float x1, float y1, float x2, float y2, float ratio,
		bool collideConnected, std::string &error) override;
	virtual bool getPulleyJointGroundAnchors(Love::PhysicsBackend::JointHandle joint,
		float &x1, float &y1, float &x2, float &y2, std::string &error) const override;
	virtual bool getPulleyJointLengthA(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool getPulleyJointLengthB(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool getPulleyJointRatio(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual Love::PhysicsBackend::JointHandle newWheelJoint(
		Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
		float x1, float y1, float x2, float y2, float axisX, float axisY,
		bool collideConnected, std::string &error) override;
	virtual bool getWheelJointTranslation(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool getWheelJointSpeed(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool isWheelJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
		bool &value, std::string &error) const override;
	virtual bool setWheelJointMotorEnabled(Love::PhysicsBackend::JointHandle joint,
		bool value, std::string &error) override;
	virtual bool getWheelJointMotorSpeed(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setWheelJointMotorSpeed(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getWheelJointMaxMotorTorque(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setWheelJointMaxMotorTorque(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getWheelJointMotorTorque(Love::PhysicsBackend::JointHandle joint,
		float inverseDeltaTime, float &value, std::string &error) const override;
	virtual bool getWheelJointSpringFrequency(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setWheelJointSpringFrequency(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getWheelJointSpringDampingRatio(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setWheelJointSpringDampingRatio(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getWheelJointAxis(Love::PhysicsBackend::JointHandle joint,
		float &x, float &y, std::string &error) const override;
	virtual Love::PhysicsBackend::JointHandle newMouseJoint(
		Love::PhysicsBackend::BodyHandle body, float x, float y,
		std::string &error) override;
	virtual bool getMouseJointTarget(Love::PhysicsBackend::JointHandle joint,
		float &x, float &y, std::string &error) const override;
	virtual bool setMouseJointTarget(Love::PhysicsBackend::JointHandle joint,
		float x, float y, std::string &error) override;
	virtual bool getMouseJointMaxForce(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setMouseJointMaxForce(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getMouseJointFrequency(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setMouseJointFrequency(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getMouseJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setMouseJointDampingRatio(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual Love::PhysicsBackend::JointHandle newMotorJoint(
		Love::PhysicsBackend::BodyHandle bodyA, Love::PhysicsBackend::BodyHandle bodyB,
		float correctionFactor, bool collideConnected, std::string &error) override;
	virtual bool getMotorJointLinearOffset(Love::PhysicsBackend::JointHandle joint,
		float &x, float &y, std::string &error) const override;
	virtual bool setMotorJointLinearOffset(Love::PhysicsBackend::JointHandle joint,
		float x, float y, std::string &error) override;
	virtual bool getMotorJointAngularOffset(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setMotorJointAngularOffset(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getMotorJointMaxForce(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setMotorJointMaxForce(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getMotorJointMaxTorque(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setMotorJointMaxTorque(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual bool getMotorJointCorrectionFactor(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setMotorJointCorrectionFactor(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	virtual Love::PhysicsBackend::JointHandle newGearJoint(
		Love::PhysicsBackend::JointHandle jointA, Love::PhysicsBackend::JointHandle jointB,
		float ratio, bool collideConnected, std::string &error) override;
	virtual bool getGearJointRatio(Love::PhysicsBackend::JointHandle joint,
		float &value, std::string &error) const override;
	virtual bool setGearJointRatio(Love::PhysicsBackend::JointHandle joint,
		float value, std::string &error) override;
	DrawNode *ensureDrawNode(std::size_t requiredVertices = 0);
	std::optional<RendererManager::ScissorState> getCommandScissor() const;
	void beginCommandSegment();
	void beginRenderPass(uint16_t clearFlags, Color clearColor, uint8_t stencil = 0,
		float depth = 1.0f);
	void markRenderCommand();
	void markSpriteRenderCommand(Texture2D *texture,
		Love::GraphicsBackend::TextureFilter filter,
		Love::GraphicsBackend::TextureWrap wrapU,
		Love::GraphicsBackend::TextureWrap wrapV);
	int getActivePixelHeight() const;
	RenderTarget* getActiveRenderTarget() const;
	void drawTexture(Texture2D *texture,
		float sourceX, float sourceY, float sourceWidth, float sourceHeight,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha,
		Love::GraphicsBackend::TextureFilter filter,
		Love::GraphicsBackend::TextureWrap wrapU,
		Love::GraphicsBackend::TextureWrap wrapV);
	Texture2D* ensureWhiteTexture(std::string &error);
	Love::GraphicsBackend::ShaderHandle ensureArrayTextureShader(std::string &error);
	bool drawShaderPrimitive(std::span<const Vec2> vertices, bool fill, bool closed,
		float lineWidth, Color color, std::string &error);
	bool drawPolyline(std::span<const Vec2> vertices, bool closed, float lineWidth,
		Love::GraphicsBackend::LineStyle lineStyle, Love::GraphicsBackend::LineJoin lineJoin,
		const Love::GraphicsBackend::Transform2D &transform, Color color, std::string &error);
	bool drawShaderPoints(std::span<const Vec2> points, float pointSize,
		Color color, std::string &error);

	std::string _bootFile;
	std::string _sourceRoot;
	std::string _lastError;
	std::string _packageRoot;
	std::unordered_set<std::string> _mountedArchiveRoots;
	Own<Love::LoveRuntime> _runtime;
	Ref<RenderTarget> _renderTarget;
	Ref<Node> _frameRoot;
	Ref<Node> _commandRoot;
	Ref<DrawNode> _drawNode;
	struct ImageResource
	{
		Ref<Texture2D> texture;
		Love::GraphicsBackend::TextureType type = Love::GraphicsBackend::TextureType::Texture2D;
		int slices = 1;
		std::vector<Ref<Texture2D>> layerTextures;
		std::shared_ptr<std::vector<std::uint8_t>> sharedFilePixels;
		bool copyOnWrite = false;
	};
	std::unordered_map<Love::GraphicsBackend::ImageHandle, ImageResource> _images;
	struct CachedFileImage
	{
		Ref<Texture2D> texture;
		std::shared_ptr<std::vector<std::uint8_t>> pixels;
	};
	std::unordered_map<std::string, CachedFileImage> _fileImages;
	Ref<Texture2D> _whiteTexture;
	Love::GraphicsBackend::ShaderHandle _arrayTextureShader = 0;
	struct ShaderUniform
	{
		std::string gpuName;
		Love::GraphicsBackend::ShaderUniformType type = Love::GraphicsBackend::ShaderUniformType::Float;
		Love::GraphicsBackend::TextureType textureType = Love::GraphicsBackend::TextureType::Texture2D;
		int components = 4;
		int count = 1;
		int samplerSlot = 0;
		std::vector<Vec4> vectorValues;
		std::vector<Matrix> matrixValues;
		std::vector<float> initialValues;
		bool hasInitialValue = false;
	};
	struct ShaderResource
	{
		struct Attribute
		{
			bgfx::Attrib::Enum semantic = bgfx::Attrib::TexCoord1;
			int components = 4;
			int selectorIndex = -1;
		};
		Ref<Shader> vertex;
		Ref<Shader> fragment;
		Ref<SpriteEffect> effect;
		Ref<Shader> instancedVertex;
		Ref<SpriteEffect> instancedEffect;
		std::unordered_map<std::string, ShaderUniform> uniforms;
		std::unordered_map<std::string, Attribute> attributes;
		std::unordered_map<std::string, Attribute> instancedAttributes;
		bool usesInstanceID = false;
		bool usesVertexID = false;
		bool hasMainTexture = false;
		Love::GraphicsBackend::TextureType mainTextureType
			= Love::GraphicsBackend::TextureType::Texture2D;
		bgfx::Attrib::Enum mainTextureLayerSemantic = bgfx::Attrib::Count;
		bgfx::Attrib::Enum vertexIDSemantic = bgfx::Attrib::Count;
		bgfx::Attrib::Enum instancedVertexIDSemantic = bgfx::Attrib::Count;
		std::unordered_map<std::string, Love::GraphicsBackend::CanvasHandle> samplerCanvases;
		int colorOutputs = 1;
	};
	void clearShaderSamplerBindings(ShaderResource &shader);
	std::unordered_map<Love::GraphicsBackend::ShaderHandle, ShaderResource> _shaders;
	std::vector<ShaderResource> _retiredShaders;
	Love::GraphicsBackend::ShaderHandle _activeShader = 0;
	struct CanvasResource
	{
		Ref<RenderTarget> target;
		Ref<Texture2D> texture;
		int msaa = 0;
		bool readable = true;
		bool depthStencil = false;
		std::string format = "rgba8";
		Love::GraphicsBackend::TextureType type = Love::GraphicsBackend::TextureType::Texture2D;
		int slices = 1;
		int mipmapCount = 1;
		std::string mipmapMode = "none";
		std::map<std::pair<int, int>, Ref<RenderTarget>> targets;
		Ref<RenderTarget> mipmapTarget;
	};
	struct RenderPass
	{
		Ref<RenderTarget> target;
		Ref<Node> root;
		Color clearColor;
		uint16_t clearFlags = 0;
		uint8_t stencil = 0;
		float depth = 1.0f;
		bool hasCommands = false;
	};
	std::unordered_map<Love::GraphicsBackend::CanvasHandle, CanvasResource> _canvases;
	std::map<std::vector<Love::GraphicsBackend::CanvasTarget>, Ref<RenderTarget>> _canvasTargets;
	std::vector<RenderPass> _renderPasses;
	std::unordered_set<Love::GraphicsBackend::CanvasHandle> _pendingCanvasMipmaps;
	std::vector<Love::GraphicsBackend::CanvasHandle> _activeCanvases;
	std::vector<Love::GraphicsBackend::CanvasTarget> _activeCanvasTargets;
	Love::GraphicsBackend::CanvasHandle _activeCanvasDepthStencil = 0;
	Love::GraphicsBackend::CanvasHandle _activeCanvas = 0;
	Ref<RenderTarget> _activeCanvasTarget;
	bool _activeCanvasDepth = false;
	bool _activeCanvasStencil = false;
	bool _stencilWriting = false;
	std::string _stencilAction = "replace";
	int _stencilWriteValue = 1;
	std::string _stencilCompare = "always";
	int _stencilTestValue = 0;
	bool _graphicsFrameActive = false;
	Love::GraphicsBackend::Stats _graphicsStats;
	Texture2D *_spriteBatchTexture = nullptr;
	Node *_spriteBatchCommandRoot = nullptr;
	Love::GraphicsBackend::TextureFilter _spriteBatchFilter = Love::GraphicsBackend::TextureFilter::Linear;
	Love::GraphicsBackend::TextureWrap _spriteBatchWrapU = Love::GraphicsBackend::TextureWrap::Clamp;
	Love::GraphicsBackend::TextureWrap _spriteBatchWrapV = Love::GraphicsBackend::TextureWrap::Clamp;
	std::string _spriteBatchBlendMode;
	std::string _spriteBatchBlendAlphaMode;
	std::vector<std::uint64_t> _pendingScreenshotRequests;
	std::uint64_t _runtimeGeneration = 0;
	struct FontResource
	{
		struct ImageGlyph
		{
			int page = 0;
			int x = 0;
			int y = 0;
			int width = 0;
			int height = 0;
			int advance = 0;
			int bearingX = 0;
			int bearingY = 0;
		};
		std::string filename;
		int size = 12;
		Ref<Font> font;
		std::vector<Ref<Texture2D>> imageTextures;
		std::unordered_map<std::uint32_t, ImageGlyph> imageGlyphs;
		float dpiScale = 1.0f;
		int baseline = 0;
		Love::GraphicsBackend::TextureFilter imageFilter = Love::GraphicsBackend::TextureFilter::Linear;
		std::vector<Love::GraphicsBackend::FontHandle> fallbacks;
		float lineHeight = 1.0f;
	};
	std::unordered_map<Love::GraphicsBackend::FontHandle, FontResource> _fonts;
	struct AudioResource
	{
		Ref<AudioSource> node;
		Ref<AudioFile> file;
		Ref<AudioBus> effectsBus;
		bool queueable = false;
		double position = 0.0;
		std::array<float, 3> spatialPosition{0.0f, 0.0f, 0.0f};
		std::array<float, 3> velocity{0.0f, 0.0f, 0.0f};
		std::array<float, 3> direction{0.0f, 0.0f, 0.0f};
		float coneInnerAngle = 6.28318530717958647692f;
		float coneOuterAngle = 6.28318530717958647692f;
		float coneOuterVolume = 0.0f;
		float coneOuterHighGain = 1.0f;
		float airAbsorptionFactor = 0.0f;
		float minVolume = 0.0f;
		float maxVolume = 1.0f;
		bool relative = false;
		float referenceDistance = 1.0f;
		float maxDistance = 1000000.0f;
		float rolloff = 1.0f;
		std::optional<Love::AudioBackend::FilterSettings> filter;
		std::map<std::string, std::optional<Love::AudioBackend::FilterSettings>> effects;
	};
	bool refreshAudioFilters(AudioResource &resource, std::string &error);
	std::unordered_map<Love::AudioBackend::SourceHandle, AudioResource> _audioSources;
	std::unordered_map<Love::AudioBackend::RecordingHandle,
		std::unique_ptr<LoveRecordingResource>> _audioRecordings;
	std::map<std::string, Love::AudioBackend::EffectSettings> _audioEffects;
	Ref<AudioBus> _audioBus;
	struct PhysicsWorldResource
	{
		Ref<PhysicsWorld> world;
		float gravityX = 0.0f;
		float gravityY = 0.0f;
		bool sleep = true;
		Love::PhysicsBackend::ContactCallback contactCallback;
		std::string contactError;
		std::unordered_map<std::uint16_t, Love::PhysicsBackend::ContactHandle> contacts;
	};
	struct PhysicsShapeResource { Ref<FixtureDef> fixture; std::string type; };
	struct PhysicsBodyResource
	{
		Ref<Body> body;
		Love::PhysicsBackend::WorldHandle world = 0;
		float gravityScale = 1.0f;
	};
	struct PhysicsFixtureResource
	{
		Love::PhysicsBackend::WorldHandle world = 0;
		Love::PhysicsBackend::BodyHandle body = 0;
		std::uint16_t shape = 0;
		Love::PhysicsFilter filter;
	};
	struct PhysicsJointResource
	{
		Ref<Joint> joint;
		Love::PhysicsBackend::WorldHandle world = 0;
		Love::PhysicsBackend::BodyHandle bodyA = 0;
		Love::PhysicsBackend::BodyHandle bodyB = 0;
		Love::PhysicsBackend::JointHandle sourceJointA = 0;
		Love::PhysicsBackend::JointHandle sourceJointB = 0;
	};
	struct PhysicsContactResource
	{
		Love::PhysicsBackend::WorldHandle world = 0;
		std::uint16_t contact = 0;
	};
	std::unordered_map<Love::PhysicsBackend::WorldHandle, PhysicsWorldResource> _physicsWorlds;
	std::unordered_map<Love::PhysicsBackend::ShapeHandle, PhysicsShapeResource> _physicsShapes;
	std::unordered_map<Love::PhysicsBackend::BodyHandle, PhysicsBodyResource> _physicsBodies;
	std::unordered_map<Love::PhysicsBackend::FixtureHandle, PhysicsFixtureResource> _physicsFixtures;
	std::unordered_map<Love::PhysicsBackend::JointHandle, PhysicsJointResource> _physicsJoints;
	std::unordered_map<Love::PhysicsBackend::ContactHandle, PhysicsContactResource> _physicsContacts;
	std::unordered_set<Love::PhysicsBackend::WorldHandle> _pendingPhysicsWorldDestroy;
	std::unordered_set<Love::PhysicsBackend::BodyHandle> _pendingPhysicsBodyDestroy;
	std::unordered_set<Love::PhysicsBackend::FixtureHandle> _pendingPhysicsFixtureDestroy;
	std::unordered_set<Love::PhysicsBackend::JointHandle> _pendingPhysicsJointDestroy;
	float _physicsMeter = 30.0f;
	std::unordered_set<std::string> _hostPressedKeys;
	std::unordered_map<int, std::unordered_set<std::string>> _hostPressedControllerButtons;
	std::unordered_map<int, std::unordered_set<std::string>> _hostActiveControllerAxes;
	std::unordered_map<int, std::unordered_set<int>> _hostPressedJoystickButtons;
	std::unordered_map<int, std::unordered_set<int>> _hostActiveJoystickAxes;
	std::unordered_map<int, std::unordered_set<int>> _hostActiveJoystickHats;
	std::unordered_map<Love::MouseBackend::CursorHandle, void *> _mouseCursors;
	bool _textInputRequested = true;
	bool _screenKeyboardRequested = false;
	bool _hasTextInputRectangle = false;
	Rect _textInputRectangle;
	Love::GraphicsBackend::ImageHandle _nextImageHandle = 1;
	Love::GraphicsBackend::CanvasHandle _nextCanvasHandle = 1;
	Love::GraphicsBackend::FontHandle _nextFontHandle = 1;
	Love::GraphicsBackend::ShaderHandle _nextShaderHandle = 1;
	Love::AudioBackend::SourceHandle _nextAudioSourceHandle = 1;
	Love::AudioBackend::RecordingHandle _nextAudioRecordingHandle = 1;
	Love::MouseBackend::CursorHandle _nextMouseCursorHandle = 1;
	Love::PhysicsBackend::WorldHandle _nextPhysicsWorldHandle = 1;
	Love::PhysicsBackend::ShapeHandle _nextPhysicsShapeHandle = 1;
	Love::PhysicsBackend::BodyHandle _nextPhysicsBodyHandle = 1;
	Love::PhysicsBackend::FixtureHandle _nextPhysicsFixtureHandle = 1;
	Love::PhysicsBackend::JointHandle _nextPhysicsJointHandle = 1;
	Love::PhysicsBackend::ContactHandle _nextPhysicsContactHandle = 1;
	Color _clearColor = Color(0x000000ff);
	std::string _blendMode = "alpha";
	std::string _blendAlphaMode = "alphamultiply";
	bool _scissorEnabled = false;
	Rect _scissor;
	bool _colorMask[4] = {true, true, true, true};
	std::string _depthCompare = "always";
	bool _depthWrite = false;
	std::string _meshCullMode = "none";
	std::string _frontFaceWinding = "ccw";
	bool _wireframe = false;

	DORA_TYPE_OVERRIDE(LoveNode);
};

NS_DORA_END
