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

#include "3rdParty/Love/src/common/Object.h"
#include "3rdParty/Love/src/common/math.h"
#include "3rdParty/Love/src/common/pixelformat.h"

#include <array>
#include <cstddef>
#include <cstdint>
#include <deque>
#include <functional>
#include <limits>
#include <map>
#include <memory>
#include <optional>
#include <span>
#include <string>
#include <string_view>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

struct lua_State;

namespace love::image
{
class ImageData;
}

namespace love::graphics
{
class Drawable;
}

namespace Dora::Love
{

class DoraLoveFilesystem;
class DoraLoveChannel;
class DoraLoveLuaThread;
class DoraLoveThreadModule;
class DoraLoveSystem;
class DoraLoveTimer;
class DoraLoveEvent;

struct ThreadContext;
struct ThreadWorker;
struct ThreadChannel;

class GraphicsBackend
{
public:
	using ImageHandle = std::uint64_t;
	using CanvasHandle = std::uint64_t;
	using FontHandle = std::uint64_t;
	using ShaderHandle = std::uint64_t;
	enum class ShaderUniformType
	{
		Float,
		Matrix,
		Int,
		UInt,
		Bool,
		Sampler
	};
	enum class TextureType
	{
		Texture2D,
		Array,
		Cube,
		Volume,
	};
	struct ShaderUniformInfo
	{
		ShaderUniformType type = ShaderUniformType::Float;
		TextureType textureType = TextureType::Texture2D;
		int components = 1;
		int count = 1;
	};
	struct MeshVertex
	{
		float x = 0.0f;
		float y = 0.0f;
		float z = 0.0f;
		float w = 1.0f;
		float u = 0.0f;
		float v = 0.0f;
		float red = 1.0f;
		float green = 1.0f;
		float blue = 1.0f;
		float alpha = 1.0f;
		float textureLayer = std::numeric_limits<float>::quiet_NaN();
	};
	struct MeshAttributeData
	{
		std::string name;
		int components = 0;
		std::vector<float> values;
		bool perInstance = false;
	};
	struct MeshBuffer
	{
		std::vector<MeshVertex> vertices;
		std::vector<MeshAttributeData> attributes;
		std::vector<std::uint32_t> indices;
		std::uint64_t revision = 0;
		// Renderer-owned persistent buffers. Kept opaque here so the Love runtime
		// does not depend on bgfx types; the active graphics backend owns the deleter.
		mutable std::shared_ptr<void> gpuBuffer;
	};
	enum class TextureFilter
	{
		Linear,
		Nearest,
		Anisotropic,
	};
	enum class TextureWrap
	{
		Repeat,
		MirroredRepeat,
		Clamp,
		ClampZero,
	};
	enum class LineStyle
	{
		Rough,
		Smooth,
	};
	enum class LineJoin
	{
		None,
		Miter,
		Bevel,
	};
	struct Transform2D
	{
		float a = 1.0f;
		float b = 0.0f;
		float c = 0.0f;
		float d = 1.0f;
		float tx = 0.0f;
		float ty = 0.0f;
		float pixelScale = 1.0f;
	};
	struct ShaderTexture
	{
		ImageHandle image = 0;
		CanvasHandle canvas = 0;
		TextureFilter filter = TextureFilter::Linear;
		TextureWrap wrapU = TextureWrap::Clamp;
		TextureWrap wrapV = TextureWrap::Clamp;
		TextureWrap wrapW = TextureWrap::Clamp;
	};
	struct ImageFontGlyph
	{
		std::uint32_t codepoint = 0;
		int x = 0;
		int width = 0;
		int advance = 0;
	};
	struct BMFontPage
	{
		int width = 0;
		int height = 0;
		std::span<const std::uint8_t> rgba8;
	};
	struct BMFontGlyph
	{
		std::uint32_t codepoint = 0;
		int page = 0;
		int x = 0;
		int y = 0;
		int width = 0;
		int height = 0;
		int advance = 0;
		int bearingX = 0;
		int bearingY = 0;
	};
	struct CanvasSettings
	{
		std::string_view format = "rgba8";
		TextureType type = TextureType::Texture2D;
		int slices = 1;
		std::string_view mipmapMode = "none";
		float dpiScale = 1.0f;
		int msaa = 0;
		bool readable = true;
	};
	struct CanvasTarget
	{
		CanvasHandle canvas = 0;
		int slice = 0;
		int mipmap = 0;
		auto operator<=>(const CanvasTarget &) const = default;
	};
	struct SystemLimits
	{
		double pointSize = 255.0;
		double textureSize = 16384.0;
		double volumeTextureSize = 16384.0;
		double cubeTextureSize = 16384.0;
		double textureLayers = 2048.0;
		double multiCanvas = 8.0;
		double canvasMSAA = 4.0;
		double anisotropy = 16.0;
	};
	struct Stats
	{
		std::uint64_t drawCalls = 0;
		std::uint64_t drawCallsBatched = 0;
		std::uint64_t canvasSwitches = 0;
		std::uint64_t shaderSwitches = 0;
		std::uint64_t canvases = 0;
		std::uint64_t images = 0;
		std::uint64_t fonts = 0;
		std::uint64_t textureMemory = 0;
	};
	struct Capabilities
	{
		bool multiCanvasFormats = false;
		bool clampZero = false;
		bool lighten = false;
		bool fullNPOT = false;
		bool pixelShaderHighp = false;
		bool shaderDerivatives = false;
		bool glsl3 = false;
		bool instancing = false;
	};
	struct TextureTypes
	{
		bool texture2D = false;
		bool array = false;
		bool cube = false;
		bool volume = false;
	};
	struct RendererInfo
	{
		std::string name;
		std::string version;
		std::string vendor;
		std::string device;
	};
	struct ClearColor
	{
		bool enabled = true;
		float red = 0.0f;
		float green = 0.0f;
		float blue = 0.0f;
		float alpha = 0.0f;
	};
	struct ClearRequest
	{
		std::vector<ClearColor> colors = {ClearColor{}};
		bool colorsPerAttachment = false;
		bool clearStencil = true;
		int stencil = 0;
		bool clearDepth = true;
		float depth = 1.0f;
	};
	struct ImageLevel
	{
		int width = 0;
		int height = 0;
		int slices = 1;
		std::vector<std::uint8_t> rgba8;
	};
	struct CompressedImageLevel
	{
		int width = 0;
		int height = 0;
		int slices = 1;
		std::vector<std::uint8_t> bytes;
	};
	virtual ~GraphicsBackend() = default;
	virtual void beginFrame() = 0;
	virtual bool clear(const ClearRequest &request, std::string &error) = 0;
	virtual bool rectangle(bool fill, float x, float y, float width, float height,
		float lineWidth, LineStyle lineStyle, LineJoin lineJoin,
		float red, float green, float blue, float alpha, std::string &error) = 0;
	virtual bool circle(bool fill, float x, float y, float radius,
		float lineWidth, LineStyle lineStyle, LineJoin lineJoin,
		float red, float green, float blue, float alpha, std::string &error) = 0;
	virtual bool line(const std::vector<float> &points, const Transform2D &transform, float lineWidth,
		LineStyle lineStyle, LineJoin lineJoin,
		float red, float green, float blue, float alpha, std::string &error) = 0;
	virtual bool polygon(bool fill, const std::vector<float> &points, const Transform2D &transform,
		float lineWidth,
		LineStyle lineStyle, LineJoin lineJoin,
		float red, float green, float blue, float alpha, std::string &error) = 0;
	virtual bool points(const std::vector<float> &points, float pointSize,
		float red, float green, float blue, float alpha, std::string &error) = 0;
	virtual ImageHandle newImage(const std::string &filename, std::string &error) = 0;
	virtual ImageHandle newImage(TextureType type, int width, int height, int slices,
		std::span<const std::uint8_t> rgba8, std::string &error)
	{
		(void)type; (void)width; (void)height; (void)slices; (void)rgba8;
		error = "non-2D Love Images are unavailable in this graphics backend";
		return 0;
	}
	virtual ImageHandle newImage(TextureType type, std::span<const ImageLevel> levels,
		std::string &error)
	{
		if (levels.size() != 1)
		{
			error = "Love Image mipmap chains are unavailable in this graphics backend";
			return 0;
		}
		const auto &level = levels.front();
		return newImage(type, level.width, level.height, level.slices, level.rgba8, error);
	}
	virtual ImageHandle newCompressedImage(std::string_view format, int width, int height,
		int mipmapCount, std::span<const std::uint8_t> data, std::string &error)
	{
		(void)format; (void)width; (void)height; (void)mipmapCount; (void)data;
		error = "compressed Love Images are unavailable in this graphics backend";
		return 0;
	}
	virtual ImageHandle newCompressedImage(TextureType type, std::string_view format,
		std::span<const CompressedImageLevel> levels, std::string &error)
	{
		if (type != TextureType::Texture2D || levels.empty())
		{
			error = "layered compressed Love Images are unavailable in this graphics backend";
			return 0;
		}
		std::vector<std::uint8_t> bytes;
		for (const auto &level : levels)
			bytes.insert(bytes.end(), level.bytes.begin(), level.bytes.end());
		return newCompressedImage(format, levels.front().width, levels.front().height,
			static_cast<int>(levels.size()), bytes, error);
	}
	virtual void releaseImage(ImageHandle image) = 0;
	virtual bool updateImage(ImageHandle image, int width, int height,
		std::span<const std::uint8_t> rgba8, std::string &error)
	{
		(void)image; (void)width; (void)height; (void)rgba8;
		error = "dynamic Love Image updates are unavailable in this graphics backend";
		return false;
	}
	virtual bool replaceImagePixels(ImageHandle image, int slice, int mipmap,
		int x, int y, int width, int height,
		std::span<const std::uint8_t> rgba8, std::string &error)
	{
		(void)image; (void)slice; (void)mipmap; (void)x; (void)y;
		(void)width; (void)height; (void)rgba8;
		error = "Love Image pixel replacement is unavailable in this graphics backend";
		return false;
	}
	virtual int getImageWidth(ImageHandle image) const = 0;
	virtual int getImageHeight(ImageHandle image) const = 0;
	virtual TextureType getImageTextureType(ImageHandle image) const
	{
		(void)image;
		return TextureType::Texture2D;
	}
	virtual int getImageSliceCount(ImageHandle image) const
	{
		(void)image;
		return 1;
	}
	virtual void drawImage(ImageHandle image,
		float sourceX, float sourceY, float sourceWidth, float sourceHeight,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha,
		TextureFilter filter, TextureWrap wrapU, TextureWrap wrapV) = 0;
	virtual bool drawImageLayer(ImageHandle image, int layer,
		float sourceX, float sourceY, float sourceWidth, float sourceHeight,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha,
		TextureFilter filter, TextureWrap wrapU, TextureWrap wrapV, std::string &error)
	{
		(void)image; (void)layer; (void)sourceX; (void)sourceY; (void)sourceWidth; (void)sourceHeight;
		(void)a; (void)b; (void)c; (void)d; (void)tx; (void)ty; (void)originX; (void)originY;
		(void)red; (void)green; (void)blue; (void)alpha; (void)filter; (void)wrapU; (void)wrapV;
		error = "ArrayImage layer drawing is unavailable in this graphics backend";
		return false;
	}
	virtual CanvasHandle newCanvas(int width, int height, const CanvasSettings &settings,
		std::string &error) = 0;
	virtual bool isCanvasFormatSupported(std::string_view format, bool readable) const = 0;
	virtual void releaseCanvas(CanvasHandle canvas) = 0;
	virtual int getCanvasWidth(CanvasHandle canvas) const = 0;
	virtual int getCanvasHeight(CanvasHandle canvas) const = 0;
	virtual bool readCanvas(CanvasHandle canvas, int slice, int mipmap,
		int x, int y, int width, int height,
		std::vector<std::uint8_t> &pixels, std::string &error) = 0;
	virtual bool generateCanvasMipmaps(CanvasHandle canvas, std::string &error)
	{
		(void)canvas;
		error = "Canvas mipmap generation is unavailable in this graphics backend";
		return false;
	}
	virtual bool setCanvases(std::span<const CanvasHandle> canvases,
		CanvasHandle depthStencil, bool depth, bool stencil, std::string &error) = 0;
	virtual bool setCanvasTargets(std::span<const CanvasTarget> canvases,
		const CanvasTarget *depthStencil, bool depth, bool stencil, std::string &error)
	{
		std::vector<CanvasHandle> handles;
		handles.reserve(canvases.size());
		for (const auto &target : canvases)
		{
			if (target.slice != 0 || target.mipmap != 0)
			{
				error = "layered or mipmapped Canvas targets are unavailable in this graphics backend";
				return false;
			}
			handles.push_back(target.canvas);
		}
		if (depthStencil && (depthStencil->slice != 0 || depthStencil->mipmap != 0))
		{
			error = "layered or mipmapped depth Canvas targets are unavailable in this graphics backend";
			return false;
		}
		return setCanvases(handles, depthStencil ? depthStencil->canvas : 0,
			depth, stencil, error);
	}
	virtual void drawCanvas(CanvasHandle canvas,
		float sourceX, float sourceY, float sourceWidth, float sourceHeight,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha,
		TextureFilter filter, TextureWrap wrapU, TextureWrap wrapV) = 0;
	virtual bool drawCanvasLayer(CanvasHandle canvas, int layer,
		float sourceX, float sourceY, float sourceWidth, float sourceHeight,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha,
		TextureFilter filter, TextureWrap wrapU, TextureWrap wrapV, std::string &error)
	{
		(void)canvas; (void)layer; (void)sourceX; (void)sourceY; (void)sourceWidth; (void)sourceHeight;
		(void)a; (void)b; (void)c; (void)d; (void)tx; (void)ty; (void)originX; (void)originY;
		(void)red; (void)green; (void)blue; (void)alpha; (void)filter; (void)wrapU; (void)wrapV;
		error = "Array Canvas layer drawing is unavailable in this graphics backend";
		return false;
	}
	virtual bool drawMesh(std::span<const MeshVertex> vertices,
		std::span<const MeshAttributeData> attributes, std::span<const std::uint32_t> indices,
		std::string_view drawMode, ImageHandle image, CanvasHandle canvas, float pointSize,
		TextureFilter filter, TextureWrap wrapU, TextureWrap wrapV, std::string &error,
		int instanceCount = 1) = 0;
	virtual bool drawMeshBuffer(const std::shared_ptr<const MeshBuffer> &buffer,
		std::string_view drawMode, ImageHandle image, CanvasHandle canvas, float pointSize,
		TextureFilter filter, TextureWrap wrapU, TextureWrap wrapV,
		const Transform2D &transform, const std::array<float, 4> &color,
		std::string &error, int instanceCount = 1)
	{
		if (!buffer)
		{
			error = "Love Mesh buffer is unavailable";
			return false;
		}
		std::vector<MeshVertex> transformed(buffer->vertices);
		for (auto &vertex : transformed)
		{
			const float x = vertex.x;
			const float y = vertex.y;
			vertex.x = transform.a * x + transform.c * y + transform.tx;
			vertex.y = transform.b * x + transform.d * y + transform.ty;
			vertex.red *= color[0];
			vertex.green *= color[1];
			vertex.blue *= color[2];
			vertex.alpha *= color[3];
		}
		return drawMesh(transformed, buffer->attributes, buffer->indices, drawMode,
			image, canvas, pointSize, filter, wrapU, wrapV, error, instanceCount);
	}
	virtual ShaderHandle newShader(std::string_view vertexSource, std::string_view pixelSource,
		std::string &warnings, std::string &error)
	{
		(void)vertexSource; (void)pixelSource; warnings.clear();
		error = "Love Shader compilation is unavailable in this graphics backend";
		return 0;
	}
	virtual bool validateShader(std::string_view vertexSource, std::string_view pixelSource,
		std::string &error)
	{
		std::string warnings;
		const auto shader = newShader(vertexSource, pixelSource, warnings, error);
		if (shader == 0) return false;
		releaseShader(shader);
		return true;
	}
	virtual void releaseShader(ShaderHandle shader) { (void)shader; }
	virtual bool hasShaderUniform(ShaderHandle shader, std::string_view name) const
	{
		(void)shader; (void)name; return false;
	}
	virtual bool getShaderUniformInfo(ShaderHandle shader, std::string_view name,
		ShaderUniformInfo &info) const
	{
		(void)shader; (void)name; (void)info; return false;
	}
	virtual bool sendShaderFloats(ShaderHandle shader, std::string_view name,
		std::span<const float> values, bool colors, std::string &error)
	{
		(void)shader; (void)name; (void)values; (void)colors;
		error = "Love Shader uniforms are unavailable in this graphics backend";
		return false;
	}
	virtual bool sendShaderTextures(ShaderHandle shader, std::string_view name,
		std::span<const ShaderTexture> textures, std::string &error)
	{
		(void)shader; (void)name; (void)textures;
		error = "Love Shader texture uniforms are unavailable in this graphics backend";
		return false;
	}
	virtual bool setShader(ShaderHandle shader, std::string &error)
	{
		if (shader == 0) { error.clear(); return true; }
		error = "Love Shaders are unavailable in this graphics backend";
		return false;
	}
	virtual bool validateShaderDraw(std::string &error,
		TextureType mainTextureType = TextureType::Texture2D) const
	{
		(void)mainTextureType;
		error.clear();
		return true;
	}
	virtual bool supportsMeshInstancing(ShaderHandle shader,
		std::size_t perInstanceAttributeCount) const
	{
		(void)shader; (void)perInstanceAttributeCount;
		return false;
	}
	virtual bool requiresMeshInstancing(ShaderHandle shader) const
	{
		(void)shader;
		return false;
	}
	virtual bool requiresMeshVertexID(ShaderHandle shader) const
	{
		(void)shader;
		return false;
	}
	virtual FontHandle newFont(const std::string &filename, int size, std::string &error) = 0;
	virtual FontHandle newFont(std::span<const std::uint8_t> bytes, int size,
		float dpiScale, std::string &error)
	{
		(void)bytes; (void)dpiScale;
		return newFont({}, size, error);
	}
	virtual FontHandle newImageFont(int width, int height, std::span<const std::uint8_t> rgba8,
		std::span<const ImageFontGlyph> glyphs, float dpiScale, TextureFilter filter,
		std::string &error)
	{
		(void)width; (void)height; (void)rgba8; (void)glyphs; (void)dpiScale; (void)filter;
		error = "Love ImageFonts are unavailable in this graphics backend";
		return 0;
	}
	virtual FontHandle newBMFont(std::span<const BMFontPage> pages,
		std::span<const BMFontGlyph> glyphs, int lineHeight, int baseline, float dpiScale,
		TextureFilter filter, std::string &error)
	{
		(void)pages; (void)glyphs; (void)lineHeight; (void)baseline; (void)dpiScale; (void)filter;
		error = "Love BMFonts are unavailable in this graphics backend";
		return 0;
	}
	virtual void releaseFont(FontHandle font) = 0;
	virtual float getFontWidth(FontHandle font, std::string_view text) const = 0;
	virtual float getFontGlyphSpacing(FontHandle font, std::uint32_t codepoint) const = 0;
	virtual float getFontHeight(FontHandle font) const = 0;
	virtual float getFontBaseline(FontHandle font) const = 0;
	virtual float getFontAscent(FontHandle font) const = 0;
	virtual float getFontDescent(FontHandle font) const = 0;
	virtual bool hasFontGlyph(FontHandle font, std::uint32_t codepoint) const = 0;
	virtual float getFontKerning(FontHandle font, std::uint32_t left,
		std::uint32_t right) const = 0;
	virtual bool setFontFallbacks(FontHandle font, std::span<const FontHandle> fallbacks,
		std::string &error) = 0;
	virtual void setFontLineHeight(FontHandle font, float lineHeight) = 0;
	virtual float getFontLineHeight(FontHandle font) const = 0;
	virtual float getFontWrap(FontHandle font, std::string_view text, float limit,
		std::vector<std::string> &lines) const = 0;
	virtual void drawText(FontHandle font, std::string_view text, float wrapLimit, std::string_view align,
		float a, float b, float c, float d, float tx, float ty, float originX, float originY,
		float red, float green, float blue, float alpha) = 0;
	virtual bool setBlendMode(std::string_view mode, std::string_view alphaMode, std::string &error) = 0;
	virtual void setScissor(bool enabled, float x, float y, float width, float height) = 0;
	virtual void setColorMask(bool red, bool green, bool blue, bool alpha) = 0;
	virtual void setDepthMode(std::string_view compare, bool write) = 0;
	virtual void setMeshCullMode(std::string_view mode, std::string_view winding) = 0;
	virtual void setWireframe(bool enabled) = 0;
	virtual bool clearStencil(int value, std::string &error) = 0;
	virtual bool beginStencilWrite(std::string_view action, int value, std::string &error) = 0;
	virtual void endStencilWrite() = 0;
	virtual void setStencilTest(std::string_view compare, int value) = 0;
	virtual bool setStencilMode(std::string_view mode, int value, std::string &error) = 0;
	virtual bool setMode(int width, int height, std::string &error) = 0;
	virtual bool hasWindowFocus() const { return true; }
	virtual bool hasWindowMouseFocus() const { return hasWindowFocus(); }
	virtual bool isWindowVisible() const { return true; }
	virtual void endFrame() = 0;
	virtual int getPixelWidth() const = 0;
	virtual int getPixelHeight() const = 0;
	virtual Capabilities getCapabilities() const { return {}; }
	virtual TextureTypes getTextureTypes() const { return {}; }
	virtual bool isImageFormatSupported(std::string_view format) const
	{
		(void)format;
		return false;
	}
	virtual RendererInfo getRendererInfo() const { return {}; }
	virtual SystemLimits getSystemLimits() const { return {}; }
	virtual Stats getStats() const = 0;
	virtual bool requestScreenshot(std::uint64_t requestId, std::string &error) = 0;
};

class FilesystemBackend
{
public:
	virtual ~FilesystemBackend() = default;
	virtual bool exist(const std::string &path) const = 0;
	virtual bool isFolder(const std::string &path) const = 0;
	virtual bool load(const std::string &path, std::string &data, std::string &error) const = 0;
	virtual bool save(const std::string &path, std::string_view data, std::string &error) = 0;
	virtual bool createFolder(const std::string &path, std::string &error) = 0;
	virtual bool remove(const std::string &path, std::string &error) = 0;
	virtual std::optional<std::uint64_t> getFileSize(const std::string &path) const = 0;
	virtual std::vector<std::string> getDirectoryItems(const std::string &path) const = 0;
	virtual std::string getExecutablePath() const = 0;
	virtual bool mountArchive(std::string_view archiveName, std::string_view data,
		std::string &mountedRoot, std::string &error) = 0;
	virtual void unmountArchive(const std::string &mountedRoot) = 0;
};

class ImageBackend
{
public:
	struct CompressedImageLevel
	{
		int width = 0;
		int height = 0;
		std::vector<std::uint8_t> bytes;
	};
	struct CompressedImage
	{
		std::string format;
		std::vector<CompressedImageLevel> levels;
	};
	virtual ~ImageBackend() = default;
	virtual bool decodeImage(std::string_view encoded, int &width, int &height,
		std::vector<std::uint8_t> &rgba8, std::string &error) = 0;
	virtual bool decodeCompressedImage(std::string_view encoded, CompressedImage &image,
		std::string &error) = 0;
	virtual bool encodeImage(std::string_view format, int width, int height,
		std::span<const std::uint8_t> rgba8, std::vector<std::uint8_t> &encoded,
		std::string &error) = 0;
};

class SoundBackend
{
public:
	virtual ~SoundBackend() = default;
	virtual bool decodeSound(std::string_view encoded, int &sampleRate, int &channels,
		std::vector<float> &samples, std::string &error) = 0;
};

class AudioBackend
{
public:
	using SourceHandle = std::uint64_t;
	using RecordingHandle = std::uint64_t;
	struct FilterSettings
	{
		std::string type;
		std::map<std::string, float> parameters;
	};
	struct EffectSettings
	{
		std::string type;
		std::map<std::string, float> parameters;
	};
	virtual ~AudioBackend() = default;
	virtual SourceHandle newSource(const std::string &filename, std::string_view sourceType,
		std::string &error) = 0;
	virtual SourceHandle newSourceFromSoundData(std::string_view pcm, int sampleRate,
		int bitDepth, int channels, std::string &error) = 0;
	virtual SourceHandle newQueueableSource(int sampleRate, int bitDepth,
		int channels, int buffers, std::string &error) = 0;
	virtual SourceHandle cloneSource(SourceHandle source, std::string &error) = 0;
	virtual bool queueSource(SourceHandle source, std::string_view pcm, int sampleRate,
		int bitDepth, int channels, std::string &error) = 0;
	virtual int getSourceFreeBufferCount(SourceHandle source) const = 0;
	virtual void releaseSource(SourceHandle source) = 0;
	virtual bool playSource(SourceHandle source) = 0;
	virtual void pauseSource(SourceHandle source, bool paused) = 0;
	virtual void stopSource(SourceHandle source) = 0;
	virtual bool isSourcePlaying(SourceHandle source) const = 0;
	virtual bool isSourcePaused(SourceHandle source) const = 0;
	virtual void setSourceLooping(SourceHandle source, bool looping) = 0;
	virtual bool isSourceLooping(SourceHandle source) const = 0;
	virtual void setSourceVolume(SourceHandle source, float volume) = 0;
	virtual float getSourceVolume(SourceHandle source) const = 0;
	virtual void setSourcePitch(SourceHandle source, float pitch) = 0;
	virtual float getSourcePitch(SourceHandle source) const = 0;
	virtual void seekSource(SourceHandle source, double seconds) = 0;
	virtual double tellSource(SourceHandle source) const = 0;
	virtual double getSourceDuration(SourceHandle source) const = 0;
	virtual double getSourceSampleRate(SourceHandle source) const = 0;
	virtual double getSourceSampleCount(SourceHandle source) const = 0;
	virtual int getSourceChannelCount(SourceHandle source) const = 0;
	virtual void setSourcePosition(SourceHandle source, float x, float y, float z) = 0;
	virtual void getSourcePosition(SourceHandle source, float &x, float &y, float &z) const = 0;
	virtual void setSourceVelocity(SourceHandle source, float x, float y, float z) = 0;
	virtual void getSourceVelocity(SourceHandle source, float &x, float &y, float &z) const = 0;
	virtual void setSourceDirection(SourceHandle source, float x, float y, float z) = 0;
	virtual void getSourceDirection(SourceHandle source, float &x, float &y, float &z) const = 0;
	virtual void setSourceCone(SourceHandle source, float innerAngle, float outerAngle,
		float outerVolume, float outerHighGain) = 0;
	virtual void getSourceCone(SourceHandle source, float &innerAngle, float &outerAngle,
		float &outerVolume, float &outerHighGain) const = 0;
	virtual void setSourceAirAbsorption(SourceHandle source, float factor) = 0;
	virtual float getSourceAirAbsorption(SourceHandle source) const = 0;
	virtual void setSourceVolumeLimits(SourceHandle source, float minVolume, float maxVolume) = 0;
	virtual void getSourceVolumeLimits(SourceHandle source, float &minVolume, float &maxVolume) const = 0;
	virtual void setSourceRelative(SourceHandle source, bool relative) = 0;
	virtual bool isSourceRelative(SourceHandle source) const = 0;
	virtual void setSourceAttenuationDistances(SourceHandle source,
		float referenceDistance, float maxDistance) = 0;
	virtual void getSourceAttenuationDistances(SourceHandle source,
		float &referenceDistance, float &maxDistance) const = 0;
	virtual void setSourceRolloff(SourceHandle source, float rolloff) = 0;
	virtual float getSourceRolloff(SourceHandle source) const = 0;
	virtual void setInstanceVolume(float volume) = 0;
	virtual bool setMixWithSystem(bool mix) = 0;
	virtual void setListenerPosition(float x, float y, float z) = 0;
	virtual void getListenerPosition(float &x, float &y, float &z) const = 0;
	virtual void setListenerOrientation(float forwardX, float forwardY, float forwardZ,
		float upX, float upY, float upZ) = 0;
	virtual void getListenerOrientation(float &forwardX, float &forwardY, float &forwardZ,
		float &upX, float &upY, float &upZ) const = 0;
	virtual void setListenerVelocity(float x, float y, float z) = 0;
	virtual void getListenerVelocity(float &x, float &y, float &z) const = 0;
	virtual void setDopplerScale(float scale) = 0;
	virtual float getDopplerScale() const = 0;
	virtual void setDistanceModel(std::string_view model) = 0;
	virtual std::string getDistanceModel() const = 0;
	virtual bool isEffectsSupported() const = 0;
	virtual int getMaxSceneEffects() const = 0;
	virtual int getMaxSourceEffects() const = 0;
	virtual bool setEffect(std::string_view name, const EffectSettings *effect,
		std::string &error) = 0;
	virtual bool setSourceFilter(SourceHandle source, const FilterSettings *filter,
		std::string &error) = 0;
	virtual bool setSourceEffect(SourceHandle source, std::string_view name,
		const FilterSettings *filter, bool enabled, std::string &error) = 0;
	virtual std::vector<std::string> getRecordingDeviceNames() const = 0;
	virtual RecordingHandle startRecording(std::string_view deviceName, int maxSamples,
		int sampleRate, int bitDepth, int channels, std::string &error) = 0;
	virtual void stopRecording(RecordingHandle recording) = 0;
	virtual int getRecordingSampleCount(RecordingHandle recording) const = 0;
	virtual bool getRecordingData(RecordingHandle recording,
		std::vector<std::uint8_t> &pcm, std::string &error) = 0;
};

class KeyboardBackend
{
public:
	virtual ~KeyboardBackend() = default;
	virtual void setTextInput(bool enabled, bool hasRectangle,
		float x, float y, float width, float height) = 0;
	virtual std::string getScancodeFromKey(std::string_view key) const
	{
		(void)key;
		return "unknown";
	}
	virtual std::string getKeyFromScancode(std::string_view scancode) const
	{
		(void)scancode;
		return "unknown";
	}
	virtual bool hasScreenKeyboard() const { return false; }
};

class MouseBackend
{
public:
	using CursorHandle = std::uint64_t;
	virtual ~MouseBackend() = default;
	virtual void setMousePosition(float x, float y) { (void)x; (void)y; }
	virtual void setMouseVisible(bool visible) { (void)visible; }
	virtual void setMouseGrabbed(bool grabbed) { (void)grabbed; }
	virtual bool setMouseRelativeMode(bool relative) { (void)relative; return false; }
	virtual CursorHandle createImageCursor(int width, int height,
		std::span<const std::uint8_t> rgba8, int hotX, int hotY, std::string &error)
	{
		(void)width; (void)height; (void)rgba8; (void)hotX; (void)hotY;
		error = "mouse cursor images are not supported";
		return 0;
	}
	virtual CursorHandle createSystemCursor(std::string_view type, std::string &error)
	{
		(void)type; error = "system cursors are not supported"; return 0;
	}
	virtual void releaseCursor(CursorHandle handle) { (void)handle; }
	virtual void setMouseCursor(CursorHandle handle) { (void)handle; }
	virtual bool isMouseCursorSupported() const { return false; }
};

class JoystickBackend
{
public:
	struct GamepadMapping
	{
		std::string inputType;
		int index = -1;
		std::string hat;
	};
	struct DeviceInfo
	{
		std::string guid;
		int instanceId = -1;
		int vendorId = 0;
		int productId = 0;
		int productVersion = 0;
		int axisCount = 6;
		int buttonCount = 15;
		int hatCount = 0;
		bool vibrationSupported = false;
	};
	virtual ~JoystickBackend() = default;
	virtual DeviceInfo getJoystickInfo(int id) const = 0;
	virtual float getJoystickAxis(int id, int axis) const = 0;
	virtual int getJoystickHat(int id, int hat) const = 0;
	virtual bool isJoystickButtonDown(int id, int button) const = 0;
	virtual bool setJoystickVibration(int id, float left, float right, double duration) = 0;
	virtual bool setGamepadMapping(std::string_view guid, std::string_view gamepadInput,
		std::string_view inputType, int index, std::string_view hat, std::string &error) = 0;
	virtual bool loadGamepadMappings(std::string_view mappings, std::string &error) = 0;
	virtual std::string saveGamepadMappings() const = 0;
	virtual std::string getGamepadMappingString(std::string_view guid) const = 0;
	virtual std::optional<GamepadMapping> getJoystickGamepadMapping(int id,
		std::string_view gamepadInput) const = 0;
	virtual std::string getJoystickGamepadMappingString(int id) const = 0;
};

class SystemBackend
{
public:
	enum class PowerState
	{
		Unknown,
		Battery,
		NoBattery,
		Charging,
		Charged,
	};
	struct PowerInfo
	{
		PowerState state = PowerState::Unknown;
		int percent = -1;
		int seconds = -1;
	};
	virtual ~SystemBackend() = default;
	virtual std::string getOS() const = 0;
	virtual int getProcessorCount() const = 0;
	virtual bool setClipboardText(std::string_view text, std::string &error) = 0;
	virtual bool getClipboardText(std::string &text, std::string &error) const = 0;
	virtual PowerInfo getPowerInfo() const = 0;
	virtual bool openURL(std::string_view url, std::string &error) = 0;
	virtual void vibrate(double seconds) = 0;
	virtual bool hasBackgroundMusic() const = 0;
};

class PhysicsBackend
{
public:
	using WorldHandle = std::uint64_t;
	using ShapeHandle = std::uint64_t;
	using BodyHandle = std::uint64_t;
	using FixtureHandle = std::uint64_t;
	using JointHandle = std::uint64_t;
	using ContactHandle = std::uint64_t;
	enum class ContactPhase
	{
		Begin,
		End,
		PreSolve,
		PostSolve,
	};
	struct ContactEvent
	{
		ContactPhase phase = ContactPhase::Begin;
		ContactHandle contact = 0;
		FixtureHandle fixtureA = 0;
		FixtureHandle fixtureB = 0;
		std::vector<float> impulses;
		int childA = 0;
		int childB = 0;
	};
	using ContactCallback = std::function<bool(const ContactEvent &, std::string &)>;
	struct RayHit
	{
		FixtureHandle fixture = 0;
		float x = 0.0f;
		float y = 0.0f;
		float normalX = 0.0f;
		float normalY = 0.0f;
		float fraction = 0.0f;
	};
	virtual ~PhysicsBackend() = default;
	virtual void setMeter(float meter) = 0;
	virtual WorldHandle newWorld(float gravityX, float gravityY, bool sleep,
		std::string &error) = 0;
	virtual void releaseWorld(WorldHandle world) = 0;
	virtual bool isWorldValid(WorldHandle world) const = 0;
	virtual bool updateWorld(WorldHandle world, float deltaTime, int velocityIterations,
		int positionIterations, std::string &error) = 0;
	virtual bool setWorldGravity(WorldHandle world, float x, float y, std::string &error) = 0;
	virtual bool getWorldGravity(WorldHandle world, float &x, float &y, std::string &error) const = 0;
	virtual bool setWorldSleepingAllowed(WorldHandle world, bool value, std::string &error) = 0;
	virtual bool isWorldSleepingAllowed(WorldHandle world, bool &value, std::string &error) const = 0;
	virtual bool queryWorld(WorldHandle world, float x1, float y1, float x2, float y2,
		std::vector<FixtureHandle> &fixtures, std::string &error) const = 0;
	virtual bool raycastWorld(WorldHandle world, float x1, float y1, float x2, float y2,
		std::vector<RayHit> &hits, std::string &error) const = 0;
	virtual bool setWorldContactCallback(WorldHandle world, ContactCallback callback,
		std::string &error) = 0;
	virtual bool isContactValid(ContactHandle contact) const = 0;
	virtual bool getContactPositions(ContactHandle contact, std::vector<float> &positions,
		std::string &error) const = 0;
	virtual bool getContactNormal(ContactHandle contact, float &x, float &y,
		std::string &error) const = 0;
	virtual bool getContactFriction(ContactHandle contact, float &friction,
		std::string &error) const = 0;
	virtual bool setContactFriction(ContactHandle contact, float friction,
		std::string &error) = 0;
	virtual bool resetContactFriction(ContactHandle contact, std::string &error) = 0;
	virtual bool getContactRestitution(ContactHandle contact, float &restitution,
		std::string &error) const = 0;
	virtual bool setContactRestitution(ContactHandle contact, float restitution,
		std::string &error) = 0;
	virtual bool resetContactRestitution(ContactHandle contact, std::string &error) = 0;
	virtual bool isContactEnabled(ContactHandle contact, bool &enabled,
		std::string &error) const = 0;
	virtual bool setContactEnabled(ContactHandle contact, bool enabled,
		std::string &error) = 0;
	virtual bool isContactTouching(ContactHandle contact, bool &touching,
		std::string &error) const = 0;
	virtual bool getContactTangentSpeed(ContactHandle contact, float &speed,
		std::string &error) const = 0;
	virtual bool setContactTangentSpeed(ContactHandle contact, float speed,
		std::string &error) = 0;
	virtual ShapeHandle newCircleShape(float x, float y, float radius, std::string &error) = 0;
	virtual ShapeHandle newRectangleShape(float x, float y, float width, float height,
		float angle, std::string &error) = 0;
	virtual ShapeHandle newPolygonShape(std::vector<float> &points,
		std::string &error) = 0;
	virtual ShapeHandle newEdgeShape(float x1, float y1, float x2, float y2,
		std::string &error) = 0;
	virtual ShapeHandle newChainShape(bool loop, const std::vector<float> &points,
		std::string &error) = 0;
	virtual bool setShapePreviousVertex(ShapeHandle shape, bool hasVertex,
		float x, float y, std::string &error) = 0;
	virtual bool setShapeNextVertex(ShapeHandle shape, bool hasVertex,
		float x, float y, std::string &error) = 0;
	virtual bool setCircleShape(ShapeHandle shape, float x, float y, float radius,
		std::string &error) = 0;
	virtual bool getShapeChildCount(ShapeHandle shape, int &count, std::string &error) const = 0;
	virtual bool testShapePoint(ShapeHandle shape, float x, float y, float angle,
		float px, float py, bool &value, std::string &error) const = 0;
	virtual bool rayCastShape(ShapeHandle shape, float x1, float y1, float x2, float y2,
		float maxFraction, float x, float y, float angle, std::uint16_t childIndex,
		bool &hit, float &normalX, float &normalY, float &fraction,
		std::string &error) const = 0;
	virtual bool getShapeBoundingBox(ShapeHandle shape, float x, float y, float angle,
		std::uint16_t childIndex, float &x1, float &y1, float &x2, float &y2,
		std::string &error) const = 0;
	virtual bool getShapeMassData(ShapeHandle shape, float density, float &x, float &y,
		float &mass, float &inertia, std::string &error) const = 0;
	virtual void releaseShape(ShapeHandle shape) = 0;
	virtual BodyHandle newBody(WorldHandle world, float x, float y, std::string_view type,
		std::string &error) = 0;
	virtual void releaseBody(BodyHandle body) = 0;
	virtual bool isBodyValid(BodyHandle body) const = 0;
	virtual bool getBodyPosition(BodyHandle body, float &x, float &y, std::string &error) const = 0;
	virtual bool setBodyPosition(BodyHandle body, float x, float y, std::string &error) = 0;
	virtual bool getBodyAngle(BodyHandle body, float &angle, std::string &error) const = 0;
	virtual bool setBodyAngle(BodyHandle body, float angle, std::string &error) = 0;
	virtual bool getBodyLinearVelocity(BodyHandle body, float &x, float &y, std::string &error) const = 0;
	virtual bool setBodyLinearVelocity(BodyHandle body, float x, float y, std::string &error) = 0;
	virtual bool getBodyAngularVelocity(BodyHandle body, float &value, std::string &error) const = 0;
	virtual bool setBodyAngularVelocity(BodyHandle body, float value, std::string &error) = 0;
	virtual bool getBodyLinearDamping(BodyHandle body, float &value, std::string &error) const = 0;
	virtual bool setBodyLinearDamping(BodyHandle body, float value, std::string &error) = 0;
	virtual bool getBodyAngularDamping(BodyHandle body, float &value, std::string &error) const = 0;
	virtual bool setBodyAngularDamping(BodyHandle body, float value, std::string &error) = 0;
	virtual bool getBodyMass(BodyHandle body, float &value, std::string &error) const = 0;
	virtual bool getBodyInertia(BodyHandle body, float &value, std::string &error) const = 0;
	virtual bool getBodyMassData(BodyHandle body, float &x, float &y,
		float &mass, float &inertia, std::string &error) const = 0;
	virtual bool setBodyMassData(BodyHandle body, float x, float y,
		float mass, float inertia, std::string &error) = 0;
	virtual bool resetBodyMassData(BodyHandle body, std::string &error) = 0;
	virtual bool setBodyMass(BodyHandle body, float mass, std::string &error) = 0;
	virtual bool setBodyInertia(BodyHandle body, float inertia, std::string &error) = 0;
	virtual bool getBodyGravityScale(BodyHandle body, float &value, std::string &error) const = 0;
	virtual bool setBodyGravityScale(BodyHandle body, float value, std::string &error) = 0;
	virtual bool getBodyCenter(BodyHandle body, bool world, float &x, float &y,
		std::string &error) const = 0;
	virtual bool isBodyFixedRotation(BodyHandle body, bool &value, std::string &error) const = 0;
	virtual bool setBodyFixedRotation(BodyHandle body, bool value, std::string &error) = 0;
	virtual bool isBodyAwake(BodyHandle body, bool &value, std::string &error) const = 0;
	virtual bool setBodyAwake(BodyHandle body, bool value, std::string &error) = 0;
	virtual bool isBodySleepingAllowed(BodyHandle body, bool &value, std::string &error) const = 0;
	virtual bool setBodySleepingAllowed(BodyHandle body, bool value, std::string &error) = 0;
	virtual bool isBodyActive(BodyHandle body, bool &value, std::string &error) const = 0;
	virtual bool setBodyActive(BodyHandle body, bool value, std::string &error) = 0;
	virtual bool isBodyBullet(BodyHandle body, bool &value, std::string &error) const = 0;
	virtual bool setBodyBullet(BodyHandle body, bool value, std::string &error) = 0;
	virtual bool setBodyType(BodyHandle body, std::string_view type, std::string &error) = 0;
	virtual bool transformBodyPoint(BodyHandle body, bool toWorld, bool vector,
		float x, float y, float &outX, float &outY, std::string &error) const = 0;
	virtual bool getBodyPointVelocity(BodyHandle body, bool local,
		float x, float y, float &outX, float &outY, std::string &error) const = 0;
	virtual bool applyBodyLinearImpulse(BodyHandle body, float impulseX, float impulseY,
		float pointX, float pointY, std::string &error) = 0;
	virtual bool applyBodyAngularImpulse(BodyHandle body, float impulse, std::string &error) = 0;
	virtual bool applyBodyForce(BodyHandle body, float forceX, float forceY,
		float pointX, float pointY, std::string &error) = 0;
	virtual bool applyBodyTorque(BodyHandle body, float torque, std::string &error) = 0;
	virtual FixtureHandle newFixture(BodyHandle body, ShapeHandle shape, float density,
		std::string &error) = 0;
	virtual bool getFixtureDistance(FixtureHandle fixtureA, FixtureHandle fixtureB,
		float &distance, float &pointAX, float &pointAY,
		float &pointBX, float &pointBY, std::string &error) const = 0;
	virtual void releaseFixture(FixtureHandle fixture) = 0;
	virtual bool isFixtureValid(FixtureHandle fixture) const = 0;
	virtual bool setFixtureFriction(FixtureHandle fixture, float friction, std::string &error) = 0;
	virtual bool setFixtureRestitution(FixtureHandle fixture, float restitution, std::string &error) = 0;
	virtual bool setFixtureSensor(FixtureHandle fixture, bool sensor, std::string &error) = 0;
	virtual bool setFixtureDensity(FixtureHandle fixture, float density, std::string &error) = 0;
	virtual bool testFixturePoint(FixtureHandle fixture, float x, float y,
		bool &value, std::string &error) const = 0;
	virtual bool rayCastFixture(FixtureHandle fixture, float x1, float y1,
		float x2, float y2, float maxFraction, std::uint16_t childIndex,
		bool &hit, float &normalX, float &normalY, float &fraction,
		std::string &error) const = 0;
	virtual bool getFixtureFilterData(FixtureHandle fixture, std::uint16_t &categoryBits,
		std::uint16_t &maskBits, std::int16_t &groupIndex, std::string &error) const = 0;
	virtual bool setFixtureFilterData(FixtureHandle fixture, std::uint16_t categoryBits,
		std::uint16_t maskBits, std::int16_t groupIndex, std::string &error) = 0;
	virtual bool getFixtureBoundingBox(FixtureHandle fixture, std::uint16_t childIndex,
		float &x1, float &y1, float &x2, float &y2, std::string &error) const = 0;
	virtual bool getFixtureMassData(FixtureHandle fixture, float &x, float &y,
		float &mass, float &inertia, std::string &error) const = 0;
	virtual JointHandle newDistanceJoint(BodyHandle bodyA, BodyHandle bodyB,
		float x1, float y1, float x2, float y2, bool collideConnected,
		std::string &error) = 0;
	virtual void releaseJoint(JointHandle joint) = 0;
	virtual bool isJointValid(JointHandle joint) const = 0;
	virtual bool getJointAnchors(JointHandle joint, float &x1, float &y1,
		float &x2, float &y2, std::string &error) const = 0;
	virtual bool getJointReactionForce(JointHandle joint, float inverseDeltaTime,
		float &x, float &y, std::string &error) const = 0;
	virtual bool getJointReactionTorque(JointHandle joint, float inverseDeltaTime,
		float &value, std::string &error) const = 0;
	virtual bool getJointCollideConnected(JointHandle joint, bool &value,
		std::string &error) const = 0;
	virtual bool getDistanceJointLength(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setDistanceJointLength(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getDistanceJointFrequency(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setDistanceJointFrequency(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getDistanceJointDampingRatio(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setDistanceJointDampingRatio(JointHandle joint, float value,
		std::string &error) = 0;
	virtual JointHandle newRevoluteJoint(BodyHandle bodyA, BodyHandle bodyB,
		float x1, float y1, float x2, float y2, bool collideConnected,
		bool hasReferenceAngle, float referenceAngle, std::string &error) = 0;
	virtual bool getRevoluteJointAngle(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool getRevoluteJointSpeed(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool isRevoluteJointMotorEnabled(JointHandle joint, bool &value,
		std::string &error) const = 0;
	virtual bool setRevoluteJointMotorEnabled(JointHandle joint, bool value,
		std::string &error) = 0;
	virtual bool getRevoluteJointMaxMotorTorque(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setRevoluteJointMaxMotorTorque(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getRevoluteJointMotorSpeed(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setRevoluteJointMotorSpeed(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getRevoluteJointMotorTorque(JointHandle joint, float inverseDeltaTime,
		float &value, std::string &error) const = 0;
	virtual bool areRevoluteJointLimitsEnabled(JointHandle joint, bool &value,
		std::string &error) const = 0;
	virtual bool setRevoluteJointLimitsEnabled(JointHandle joint, bool value,
		std::string &error) = 0;
	virtual bool getRevoluteJointLimits(JointHandle joint, float &lower, float &upper,
		std::string &error) const = 0;
	virtual bool setRevoluteJointLimits(JointHandle joint, float lower, float upper,
		std::string &error) = 0;
	virtual bool getRevoluteJointReferenceAngle(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual JointHandle newPrismaticJoint(BodyHandle bodyA, BodyHandle bodyB,
		float x1, float y1, float x2, float y2, float axisX, float axisY,
		bool collideConnected, bool hasReferenceAngle, float referenceAngle,
		std::string &error) = 0;
	virtual bool getPrismaticJointTranslation(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool getPrismaticJointSpeed(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool isPrismaticJointMotorEnabled(JointHandle joint, bool &value,
		std::string &error) const = 0;
	virtual bool setPrismaticJointMotorEnabled(JointHandle joint, bool value,
		std::string &error) = 0;
	virtual bool getPrismaticJointMaxMotorForce(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setPrismaticJointMaxMotorForce(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getPrismaticJointMotorSpeed(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setPrismaticJointMotorSpeed(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getPrismaticJointMotorForce(JointHandle joint, float inverseDeltaTime,
		float &value, std::string &error) const = 0;
	virtual bool arePrismaticJointLimitsEnabled(JointHandle joint, bool &value,
		std::string &error) const = 0;
	virtual bool setPrismaticJointLimitsEnabled(JointHandle joint, bool value,
		std::string &error) = 0;
	virtual bool getPrismaticJointLimits(JointHandle joint, float &lower, float &upper,
		std::string &error) const = 0;
	virtual bool setPrismaticJointLimits(JointHandle joint, float lower, float upper,
		std::string &error) = 0;
	virtual bool getPrismaticJointAxis(JointHandle joint, float &x, float &y,
		std::string &error) const = 0;
	virtual bool getPrismaticJointReferenceAngle(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual JointHandle newWeldJoint(BodyHandle bodyA, BodyHandle bodyB,
		float x1, float y1, float x2, float y2, bool collideConnected,
		bool hasReferenceAngle, float referenceAngle, std::string &error) = 0;
	virtual bool getWeldJointFrequency(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setWeldJointFrequency(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getWeldJointDampingRatio(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setWeldJointDampingRatio(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getWeldJointReferenceAngle(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual JointHandle newFrictionJoint(BodyHandle bodyA, BodyHandle bodyB,
		float x1, float y1, float x2, float y2, bool collideConnected,
		std::string &error) = 0;
	virtual bool getFrictionJointMaxForce(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setFrictionJointMaxForce(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getFrictionJointMaxTorque(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setFrictionJointMaxTorque(JointHandle joint, float value,
		std::string &error) = 0;
	virtual JointHandle newRopeJoint(BodyHandle bodyA, BodyHandle bodyB,
		float x1, float y1, float x2, float y2, float maxLength,
		bool collideConnected, std::string &error) = 0;
	virtual bool getRopeJointMaxLength(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setRopeJointMaxLength(JointHandle joint, float value,
		std::string &error) = 0;
	virtual JointHandle newPulleyJoint(BodyHandle bodyA, BodyHandle bodyB,
		float groundX1, float groundY1, float groundX2, float groundY2,
		float x1, float y1, float x2, float y2, float ratio,
		bool collideConnected, std::string &error) = 0;
	virtual bool getPulleyJointGroundAnchors(JointHandle joint, float &x1, float &y1,
		float &x2, float &y2, std::string &error) const = 0;
	virtual bool getPulleyJointLengthA(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool getPulleyJointLengthB(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool getPulleyJointRatio(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual JointHandle newWheelJoint(BodyHandle bodyA, BodyHandle bodyB,
		float x1, float y1, float x2, float y2, float axisX, float axisY,
		bool collideConnected, std::string &error) = 0;
	virtual bool getWheelJointTranslation(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool getWheelJointSpeed(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool isWheelJointMotorEnabled(JointHandle joint, bool &value,
		std::string &error) const = 0;
	virtual bool setWheelJointMotorEnabled(JointHandle joint, bool value,
		std::string &error) = 0;
	virtual bool getWheelJointMotorSpeed(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setWheelJointMotorSpeed(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getWheelJointMaxMotorTorque(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setWheelJointMaxMotorTorque(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getWheelJointMotorTorque(JointHandle joint, float inverseDeltaTime,
		float &value, std::string &error) const = 0;
	virtual bool getWheelJointSpringFrequency(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setWheelJointSpringFrequency(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getWheelJointSpringDampingRatio(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setWheelJointSpringDampingRatio(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getWheelJointAxis(JointHandle joint, float &x, float &y,
		std::string &error) const = 0;
	virtual JointHandle newMouseJoint(BodyHandle body, float x, float y,
		std::string &error) = 0;
	virtual bool getMouseJointTarget(JointHandle joint, float &x, float &y,
		std::string &error) const = 0;
	virtual bool setMouseJointTarget(JointHandle joint, float x, float y,
		std::string &error) = 0;
	virtual bool getMouseJointMaxForce(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setMouseJointMaxForce(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getMouseJointFrequency(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setMouseJointFrequency(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getMouseJointDampingRatio(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setMouseJointDampingRatio(JointHandle joint, float value,
		std::string &error) = 0;
	virtual JointHandle newMotorJoint(BodyHandle bodyA, BodyHandle bodyB,
		float correctionFactor, bool collideConnected, std::string &error) = 0;
	virtual bool getMotorJointLinearOffset(JointHandle joint, float &x, float &y,
		std::string &error) const = 0;
	virtual bool setMotorJointLinearOffset(JointHandle joint, float x, float y,
		std::string &error) = 0;
	virtual bool getMotorJointAngularOffset(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setMotorJointAngularOffset(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getMotorJointMaxForce(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setMotorJointMaxForce(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getMotorJointMaxTorque(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setMotorJointMaxTorque(JointHandle joint, float value,
		std::string &error) = 0;
	virtual bool getMotorJointCorrectionFactor(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setMotorJointCorrectionFactor(JointHandle joint, float value,
		std::string &error) = 0;
	virtual JointHandle newGearJoint(JointHandle jointA, JointHandle jointB,
		float ratio, bool collideConnected, std::string &error) = 0;
	virtual bool getGearJointRatio(JointHandle joint, float &value,
		std::string &error) const = 0;
	virtual bool setGearJointRatio(JointHandle joint, float value,
		std::string &error) = 0;
};

class LoveRuntime final
{
	friend class DoraLoveFilesystem;
	friend class DoraLoveSound;
	friend class DoraLoveFont;
	friend class DoraLoveGraphics;
	friend class DoraLoveChannel;
	friend class DoraLoveLuaThread;
	friend class DoraLoveThreadModule;
	friend class DoraLoveSystem;
	friend class DoraLoveTimer;
	friend class DoraLoveEvent;
	friend class DoraLoveWindow;
	friend class DoraLoveKeyboard;
	friend class DoraLoveMouse;
	friend class DoraLoveTouch;
	friend class DoraLoveJoystick;
	friend class DoraLoveJoystickModule;
public:
	enum class Status
	{
		Closed,
		Ready,
		Running,
		RestartRequested,
		Faulted,
		Stopped,
	};

	LoveRuntime() = default;
	~LoveRuntime();

	LoveRuntime(const LoveRuntime &) = delete;
	LoveRuntime &operator=(const LoveRuntime &) = delete;

	bool open(std::string &error);
	void close();
	bool setPreloadModule(std::string_view name, std::string_view code, std::string &error);
	void setDefaultFontData(std::string data) { _defaultFontData = std::move(data); }

	bool setSourceRoot(std::string_view sourceRoot, std::string &error);
	bool setSaveBaseRoot(std::string_view saveBaseRoot, std::string &error);
	bool resolveReadPath(std::string_view filename, std::string &resolvedPath, std::string &error) const;
	bool execute(std::string_view code, std::string_view chunkName, std::string &error);
	bool configure(std::string &error);
	bool start(std::string &error);
	bool boot(std::string_view code, std::string_view chunkName, std::string &error);
	bool update(double deltaTime, std::string &error);
	bool draw(std::string &error);
	bool stop(std::string &error);
	bool restart(std::string &error);
	void setGraphicsBackend(GraphicsBackend *backend) noexcept { _graphicsBackend = backend; }
	GraphicsBackend *getGraphicsBackend() const noexcept { return _graphicsBackend; }
	::love::image::ImageData *readCanvasImageData(
		GraphicsBackend::CanvasHandle handle, ::love::PixelFormat format,
		int slice, int mipmap, const ::love::Rect &rect);
	bool isMouseVisibleRequested() const noexcept { return _mouseVisible; }
	bool isMouseGrabbedRequested() const noexcept { return _mouseGrabbed; }
	bool isMouseRelativeModeRequested() const noexcept { return _mouseRelativeMode; }
	MouseBackend::CursorHandle getMouseCursorRequested() const noexcept { return _mouseCursor; }
	GraphicsBackend::TextureFilter getGraphicsDefaultFilter() const noexcept { return _graphicsDefaultFilter; }
	float getGraphicsDefaultAnisotropy() const noexcept { return _graphicsDefaultAnisotropy; }
	std::optional<GraphicsBackend::TextureFilter> getGraphicsDefaultMipmapFilter() const noexcept { return _graphicsDefaultMipmapFilter; }
	float getGraphicsDefaultMipmapSharpness() const noexcept { return _graphicsDefaultMipmapSharpness; }
	void setImageBackend(ImageBackend *backend) noexcept { _imageBackend = backend; }
	ImageBackend *getImageBackend() const noexcept { return _imageBackend; }
	void setSoundBackend(SoundBackend *backend) noexcept { _soundBackend = backend; }
	void setFilesystemBackend(FilesystemBackend *backend) noexcept { _filesystemBackend = backend; }
	void setAudioBackend(AudioBackend *backend) noexcept { _audioBackend = backend; }
	void setKeyboardBackend(KeyboardBackend *backend) noexcept { _keyboardBackend = backend; }
	void setMouseBackend(MouseBackend *backend) noexcept { _mouseBackend = backend; }
	void setJoystickBackend(JoystickBackend *backend) noexcept { _joystickBackend = backend; }
	void setSystemBackend(SystemBackend *backend) noexcept { _systemBackend = backend; }
	void setPhysicsBackend(PhysicsBackend *backend) noexcept { _physicsBackend = backend; }
	PhysicsBackend *getPhysicsBackend() const noexcept { return _physicsBackend; }
	int pushPhysicsBodyFixtures(PhysicsBackend::BodyHandle body, lua_State *state) const;
	int pushPhysicsBodyJoints(PhysicsBackend::BodyHandle body, lua_State *state) const;
	int pushPhysicsBodyContacts(PhysicsBackend::BodyHandle body, lua_State *state) const;
	bool arePhysicsBodiesTouching(PhysicsBackend::BodyHandle first,
		PhysicsBackend::BodyHandle second) const;
	void trackPhysicsBodyObject(PhysicsBackend::BodyHandle handle, ::love::Object *body);
	void untrackPhysicsBodyObject(PhysicsBackend::BodyHandle handle);
	int callPhysicsWorldCallbacks(::love::Object *world, lua_State *state, bool set);
	int callPhysicsWorldQuery(::love::Object *world, lua_State *state, bool raycast);
	void destroyPhysicsWorldObject(lua_State *state);
	void destroyPhysicsFixtureObject(::love::Object *fixture);
	void destroyPhysicsJointObject(::love::Object *joint);
	void translatePhysicsWorldOrigin(PhysicsBackend::WorldHandle world, float x, float y);
	int countPhysicsWorldBodies(PhysicsBackend::WorldHandle world) const;
	int countPhysicsWorldJoints(PhysicsBackend::WorldHandle world) const;
	int countPhysicsWorldContacts(PhysicsBackend::WorldHandle world) const;
	int pushPhysicsWorldBodies(PhysicsBackend::WorldHandle world, lua_State *state) const;
	int pushPhysicsWorldJoints(PhysicsBackend::WorldHandle world, lua_State *state) const;
	int pushPhysicsWorldContacts(PhysicsBackend::WorldHandle world, lua_State *state) const;
	void cleanupInvalidPhysicsFixtures(lua_State *state);
	void cleanupInvalidPhysicsJoints();
	void cleanupInvalidPhysicsBodies();
	FilesystemBackend *getFilesystemBackend() const noexcept { return _filesystemBackend; }
	AudioBackend *getAudioBackend() const noexcept { return _audioBackend; }
	void copyAudioSourceSettings(AudioBackend::SourceHandle source,
		AudioBackend::SourceHandle destination);
	bool setAudioSourceFilter(AudioBackend::SourceHandle source,
		const AudioBackend::FilterSettings *filter, std::string &error);
	bool getAudioSourceFilter(AudioBackend::SourceHandle source,
		AudioBackend::FilterSettings &filter) const;
	bool setAudioSourceEffect(AudioBackend::SourceHandle source, std::string_view name,
		const AudioBackend::FilterSettings *filter, bool enabled, std::string &error);
	bool getAudioSourceEffect(AudioBackend::SourceHandle source, std::string_view name,
		std::optional<AudioBackend::FilterSettings> &filter) const;
	void getAudioSourceEffects(AudioBackend::SourceHandle source,
		std::vector<std::string> &effects) const;
	void queueKeyPressed(std::string key, std::string scancode, bool repeat = false);
	void queueKeyReleased(std::string key, std::string scancode);
	void queueTextInput(std::string text);
	void queueTextEdited(std::string text, int start, int length);
	void queueMousePressed(float x, float y, int button, bool touch = false, int presses = 1);
	void queueMouseReleased(float x, float y, int button, bool touch = false, int presses = 1);
	void queueMouseMoved(float x, float y, float deltaX, float deltaY, bool touch = false);
	void queueWheelMoved(float x, float y);
	void queueTouchPressed(std::uintptr_t id, float x, float y, float deltaX, float deltaY, float pressure = 1.0f);
	void queueTouchReleased(std::uintptr_t id, float x, float y, float deltaX, float deltaY, float pressure = 1.0f);
	void queueTouchMoved(std::uintptr_t id, float x, float y, float deltaX, float deltaY, float pressure = 1.0f);
	void addJoystick(int id, std::string name, bool notify = false);
	void removeJoystick(int id, bool notify = true);
	void queueJoystickPressed(int id, int button);
	void queueJoystickReleased(int id, int button);
	void queueJoystickAxis(int id, int axis, float value);
	void queueJoystickHat(int id, int hat, std::string direction);
	void queueGamepadPressed(int id, std::string button);
	void queueGamepadReleased(int id, std::string button);
	void queueGamepadAxis(int id, std::string axis, float value);
	bool completeScreenshot(std::uint64_t requestId, int width, int height,
		std::vector<std::uint8_t> rgba8, std::string &error);

	lua_State *getState() const noexcept { return _state; }
	Status getStatus() const noexcept { return _status; }
	const std::string &getLastError() const noexcept { return _lastError; }
	std::size_t getAllocationBytes() const noexcept { return _allocationBytes; }
	std::size_t getPeakAllocationBytes() const noexcept { return _peakAllocationBytes; }
	int getConfiguredWidth() const noexcept { return _configuredWidth; }
	int getConfiguredHeight() const noexcept { return _configuredHeight; }
	const std::string &getConfigurationWarnings() const noexcept { return _configurationWarnings; }
	const std::string &getSourceRoot() const noexcept { return _sourceRoot; }
	const std::string &getSaveRoot() const noexcept { return _saveRoot; }
	const std::string &getIdentity() const noexcept { return _identity; }
	void releaseLoveImage(GraphicsBackend::ImageHandle handle) noexcept;
	void retainLoveImageHandle(GraphicsBackend::ImageHandle handle) noexcept;
	void forgetLoveImageHandle(GraphicsBackend::ImageHandle handle) noexcept;
	void retainLoveCanvasHandle(GraphicsBackend::CanvasHandle handle) noexcept;
	void releaseLoveCanvas(GraphicsBackend::CanvasHandle handle) noexcept;
	void forgetLoveCanvasHandle(GraphicsBackend::CanvasHandle handle) noexcept;
	void retainLoveFontHandle(GraphicsBackend::FontHandle handle) noexcept;
	void releaseLoveFont(GraphicsBackend::FontHandle handle) noexcept;
	void forgetLoveFontHandle(GraphicsBackend::FontHandle handle) noexcept;
	void retainLoveShaderHandle(GraphicsBackend::ShaderHandle handle) noexcept;
	void releaseLoveShader(GraphicsBackend::ShaderHandle handle) noexcept;
	void forgetLoveShaderHandle(GraphicsBackend::ShaderHandle handle) noexcept;
	void retainLoveAudioSourceHandle(AudioBackend::SourceHandle handle) noexcept;
	void releaseLoveAudioSource(AudioBackend::SourceHandle handle) noexcept;
	void forgetLoveAudioSourceHandle(AudioBackend::SourceHandle handle) noexcept;
	void retainLoveCursorHandle(MouseBackend::CursorHandle handle) noexcept;
	void releaseLoveCursor(MouseBackend::CursorHandle handle) noexcept;
	void forgetLoveCursorHandle(MouseBackend::CursorHandle handle) noexcept;
	void retainLoveRecordingHandle(AudioBackend::RecordingHandle handle) noexcept;
	void stopLoveRecording(AudioBackend::RecordingHandle handle) noexcept;
	void forgetLoveRecordingHandle(AudioBackend::RecordingHandle handle) noexcept;
	void retainLovePhysicsWorldHandle(PhysicsBackend::WorldHandle handle) noexcept;
	void releaseLovePhysicsWorld(PhysicsBackend::WorldHandle handle) noexcept;
	void forgetLovePhysicsWorldHandle(PhysicsBackend::WorldHandle handle) noexcept;
	void retainLovePhysicsBodyHandle(PhysicsBackend::BodyHandle handle) noexcept;
	void releaseLovePhysicsBody(PhysicsBackend::BodyHandle handle) noexcept;
	void forgetLovePhysicsBodyHandle(PhysicsBackend::BodyHandle handle) noexcept;
	void retainLovePhysicsShapeHandle(PhysicsBackend::ShapeHandle handle) noexcept;
	void releaseLovePhysicsShape(PhysicsBackend::ShapeHandle handle) noexcept;
	void forgetLovePhysicsShapeHandle(PhysicsBackend::ShapeHandle handle) noexcept;
	void retainLovePhysicsFixtureHandle(PhysicsBackend::FixtureHandle handle) noexcept;
	void releaseLovePhysicsFixture(PhysicsBackend::FixtureHandle handle) noexcept;
	void forgetLovePhysicsFixtureHandle(PhysicsBackend::FixtureHandle handle) noexcept;
	void retainLovePhysicsJointHandle(PhysicsBackend::JointHandle handle) noexcept;
	void releaseLovePhysicsJoint(PhysicsBackend::JointHandle handle) noexcept;
	void forgetLovePhysicsJointHandle(PhysicsBackend::JointHandle handle) noexcept;

private:
	static void *luaAllocator(void *userdata, void *pointer, std::size_t oldSize, std::size_t newSize);
	static int openLoveModule(lua_State *state);
	static int openLoveGraphicsModule(lua_State *state);
	static int openLoveImageModule(lua_State *state);
	static int openLoveFontModule(lua_State *state);
	static int openLoveSoundModule(lua_State *state);
	static int openLoveMathModule(lua_State *state);
	static int openLoveDataModule(lua_State *state);
	static int openLoveWindowModule(lua_State *state);
	static int openLoveEventModule(lua_State *state);
	static int openLoveFilesystemModule(lua_State *state);
	static int openLoveKeyboardModule(lua_State *state);
	static int openLoveMouseModule(lua_State *state);
	static int openLoveTouchModule(lua_State *state);
	static int openLoveJoystickModule(lua_State *state);
	static int openLoveTimerModule(lua_State *state);
	static int openLoveAudioModule(lua_State *state);
	static int openLoveVideoModule(lua_State *state);
	static int openLoveSystemModule(lua_State *state);
	static int openLoveThreadModule(lua_State *state);
	static int openLovePhysicsModule(lua_State *state);
	static int sourceModuleSearcher(lua_State *state);
	static int loveRun(lua_State *state);
	static int loveGetVersion(lua_State *state);
	static int loveHandler(lua_State *state);
	int pushGraphicsState(lua_State *state, bool saveAll);
	int popGraphicsState(lua_State *state);
	int graphicsDrawCommand(lua_State *state, ::love::graphics::Drawable *drawable,
		const GraphicsBackend::Transform2D *transformOverride,
		int instanceCountOverride = 1, bool instancedOverride = false);
	static int videoNewVideoStream(lua_State *state);
	static int canvasRenderTo(lua_State *state);
	static int filesystemSetIdentity(lua_State *state);
	static int filesystemSetRequirePath(lua_State *state);
	static int filesystemLoad(lua_State *state);
	static int audioNewSource(lua_State *state);
	static int audioNewQueueableSource(lua_State *state);
	static int audioPlay(lua_State *state);
	static int audioPause(lua_State *state);
	static int audioStop(lua_State *state);
	static int audioGetActiveSourceCount(lua_State *state);
	static int audioSetVolume(lua_State *state);
	static int audioGetVolume(lua_State *state);
	static int audioSetMixWithSystem(lua_State *state);
	static int audioSetPosition(lua_State *state);
	static int audioGetPosition(lua_State *state);
	static int audioSetOrientation(lua_State *state);
	static int audioGetOrientation(lua_State *state);
	static int audioSetVelocity(lua_State *state);
	static int audioGetVelocity(lua_State *state);
	static int audioSetDopplerScale(lua_State *state);
	static int audioGetDopplerScale(lua_State *state);
	static int audioSetDistanceModel(lua_State *state);
	static int audioGetDistanceModel(lua_State *state);
	static int audioSetEffect(lua_State *state);
	static int audioGetEffect(lua_State *state);
	static int audioGetActiveEffects(lua_State *state);
	static int audioGetMaxSceneEffects(lua_State *state);
	static int audioGetMaxSourceEffects(lua_State *state);
	static int audioGetRecordingDevices(lua_State *state);
	static int audioIsEffectsSupported(lua_State *state);
	static int recordingDeviceEqual(lua_State *state);
	static int recordingDeviceStart(lua_State *state);
	static int recordingDeviceStop(lua_State *state);
	static int recordingDeviceGetData(lua_State *state);
	static int recordingDeviceGetSampleCount(lua_State *state);
	static int recordingDeviceGetSampleRate(lua_State *state);
	static int recordingDeviceGetBitDepth(lua_State *state);
	static int recordingDeviceGetChannelCount(lua_State *state);
	static int recordingDeviceGetName(lua_State *state);
	static int recordingDeviceIsRecording(lua_State *state);
	static int audioSourceEqual(lua_State *state);
	static int physicsSetMeter(lua_State *state);
	static int physicsGetMeter(lua_State *state);
	static int physicsGetDistance(lua_State *state);
	static int physicsNewWorld(lua_State *state);
	static int physicsNewBody(lua_State *state);
	static int physicsNewFixture(lua_State *state);
	static int physicsNewCircleShape(lua_State *state);
	static int physicsNewRectangleShape(lua_State *state);
	static int physicsNewPolygonShape(lua_State *state);
	static int physicsNewEdgeShape(lua_State *state);
	static int physicsNewChainShape(lua_State *state);
	static int physicsNewDistanceJoint(lua_State *state);
	static int physicsNewRevoluteJoint(lua_State *state);
	static int physicsNewPrismaticJoint(lua_State *state);
	static int physicsNewWeldJoint(lua_State *state);
	static int physicsNewFrictionJoint(lua_State *state);
	static int physicsNewRopeJoint(lua_State *state);
	static int physicsNewPulleyJoint(lua_State *state);
	static int physicsNewWheelJoint(lua_State *state);
	static int physicsNewMouseJoint(lua_State *state);
	static int physicsNewMotorJoint(lua_State *state);
	static int physicsNewGearJoint(lua_State *state);
	static int physicsWorldDestroy(lua_State *state);
	static int physicsWorldIsDestroyed(lua_State *state);
	static int physicsWorldUpdate(lua_State *state);
	static int physicsWorldSetGravity(lua_State *state);
	static int physicsWorldGetGravity(lua_State *state);
	static int physicsWorldSetSleepingAllowed(lua_State *state);
	static int physicsWorldIsSleepingAllowed(lua_State *state);
	static int physicsWorldQueryBoundingBox(lua_State *state);
	static int physicsWorldRayCast(lua_State *state);
	static int physicsWorldSetCallbacks(lua_State *state);
	static int physicsWorldGetCallbacks(lua_State *state);
	static int physicsWorldGetBodies(lua_State *state);
	static int traceback(lua_State *state);
	void registerLoveModule();
	void resetGraphicsTransform() noexcept;
	void multiplyGraphicsTransform(float a, float b, float c, float d, float tx, float ty) noexcept;
	std::vector<float> transformGraphicsPoints(const std::vector<float> &points) const;
	bool isGraphicsTransformIdentity() const noexcept;
	void registerImageType();
	void registerCanvasType();
	void registerCompressedImageDataType();
	void registerQuadType();
	void registerMeshType();
	void registerSpriteBatchType();
	void registerParticleSystemType();
	void registerTextType();
	void registerShaderType();
	void registerFontType();
	void registerAudioSourceType();
	void registerVideoTypes();
	void registerRecordingDeviceType();
	void registerThreadTypes();
	void registerPhysicsTypes();
	void drainThreadFilesystemRequests();
	void drainThreadErrors();
	void pushJoystick(int id);
	GraphicsBackend::FontHandle ensureDefaultFont(std::string &error);
	bool callLoveCallback(const char *name, int argumentCount, int resultCount, std::string &error);
	static int runtimePrint(lua_State *state);
	bool dispatchQueuedEvents(std::string &error);
	bool setIdentity(std::string_view identity, std::string &error);
	bool installPreloadModule(std::string_view name, std::string_view code, std::string &error);
	std::string prepareGeneratedChunk(std::string_view code, std::string_view chunkName);
	std::string rewriteGeneratedError(std::string message) const;
	void rewriteGeneratedErrorOnStack(lua_State *state) const;
	bool refreshSaveRoot(std::string &error);
	void clearMountedArchives();
	bool fail(std::string message, std::string &error);

	lua_State *_state = nullptr;
	Status _status = Status::Closed;
	std::string _lastError;
	std::string _bootCode;
	std::string _bootChunkName;
	std::string _sourceRoot;
	std::string _saveBaseRoot;
	std::string _saveRoot;
	std::string _identity;
	std::vector<std::string> _requirePath;
	std::unordered_map<std::string, std::string> _preloadModules;
	std::string _defaultFontData;
	struct GeneratedLineMap
	{
		std::string source;
		std::vector<int> lines;
	};
	std::unordered_map<std::string, GeneratedLineMap> _generatedLineMaps;
	struct MountedArchive
	{
		std::string archiveName;
		std::string mountpoint;
		std::string root;
		const void *dataIdentity = nullptr;
		int dataReference = -2; // LUA_NOREF without exposing Lua headers here.
		::love::StrongRef<::love::Object> dataObject;
	};
	std::vector<MountedArchive> _mountedArchives;
	int _configuredWidth = 800;
	int _configuredHeight = 600;
	std::string _configurationWarnings;
	bool _windowResizable = false;
	std::string _windowTitle = "Untitled";
	int _windowVSync = 1;
	bool _windowDisplaySleepEnabled = false;
	GraphicsBackend *_graphicsBackend = nullptr;
	ImageBackend *_imageBackend = nullptr;
	SoundBackend *_soundBackend = nullptr;
	FilesystemBackend *_filesystemBackend = nullptr;
	AudioBackend *_audioBackend = nullptr;
	float _audioVolume = 1.0f;
	std::map<std::string, AudioBackend::EffectSettings> _audioEffects;
	std::unordered_map<AudioBackend::SourceHandle, AudioBackend::FilterSettings> _audioSourceFilters;
	std::unordered_map<AudioBackend::SourceHandle,
		std::map<std::string, std::optional<AudioBackend::FilterSettings>>> _audioSourceEffects;
	KeyboardBackend *_keyboardBackend = nullptr;
	MouseBackend *_mouseBackend = nullptr;
	JoystickBackend *_joystickBackend = nullptr;
	SystemBackend *_systemBackend = nullptr;
	std::shared_ptr<ThreadContext> _threadContext;
	std::vector<std::shared_ptr<ThreadWorker>> _threadWorkers;
	bool _ownsThreadContext = false;
	PhysicsBackend *_physicsBackend = nullptr;
	float _physicsMeter = 30.0f;
	std::unordered_map<PhysicsBackend::FixtureHandle, int> _physicsFixtureReferences;
	std::unordered_map<PhysicsBackend::BodyHandle, ::love::StrongRef<::love::Object>> _physicsBodyObjects;
	std::unordered_map<PhysicsBackend::FixtureHandle, ::love::StrongRef<::love::Object>> _physicsFixtureObjects;
	std::unordered_map<PhysicsBackend::JointHandle, ::love::StrongRef<::love::Object>> _physicsJointObjects;
	struct PhysicsWorldCallbacks
	{
		int begin = -2;
		int end = -2;
		int preSolve = -2;
		int postSolve = -2;
	};
	std::unordered_map<PhysicsBackend::WorldHandle, PhysicsWorldCallbacks> _physicsWorldCallbacks;
	std::unordered_map<PhysicsBackend::ContactHandle, int> _physicsContactReferences;
	std::unordered_map<PhysicsBackend::ContactHandle, ::love::StrongRef<::love::Object>> _physicsContactObjects;
	bool _textInputEnabled = true;
	float _graphicsColor[4] = {1.0f, 1.0f, 1.0f, 1.0f};
	float _graphicsBackgroundColor[4] = {0.0f, 0.0f, 0.0f, 1.0f};
	GraphicsBackend::TextureFilter _graphicsDefaultFilter = GraphicsBackend::TextureFilter::Linear;
	float _graphicsDefaultAnisotropy = 1.0f;
	std::optional<GraphicsBackend::TextureFilter> _graphicsDefaultMipmapFilter;
	float _graphicsDefaultMipmapSharpness = 0.0f;
	float _graphicsLineWidth = 1.0f;
	GraphicsBackend::LineStyle _graphicsLineStyle = GraphicsBackend::LineStyle::Smooth;
	GraphicsBackend::LineJoin _graphicsLineJoin = GraphicsBackend::LineJoin::Miter;
	float _graphicsPointSize = 1.0f;
	bool _graphicsFrameActive = false;
	bool _graphicsLoadCallbackActive = false;
	using GraphicsTransform = GraphicsBackend::Transform2D;
	struct GraphicsState
	{
		GraphicsTransform transform;
		float color[4] = {1.0f, 1.0f, 1.0f, 1.0f};
		float backgroundColor[4] = {0.0f, 0.0f, 0.0f, 1.0f};
		GraphicsBackend::TextureFilter defaultFilter = GraphicsBackend::TextureFilter::Linear;
		float defaultAnisotropy = 1.0f;
		float lineWidth = 1.0f;
		GraphicsBackend::LineStyle lineStyle = GraphicsBackend::LineStyle::Smooth;
		GraphicsBackend::LineJoin lineJoin = GraphicsBackend::LineJoin::Miter;
		float pointSize = 1.0f;
		std::string blendMode = "alpha";
		std::string blendAlphaMode = "alphamultiply";
		bool scissorEnabled = false;
		float scissor[4] = {0.0f, 0.0f, 0.0f, 0.0f};
		bool colorMask[4] = {true, true, true, true};
		std::string depthCompare = "always";
		bool depthWrite = false;
		std::string meshCullMode = "none";
		std::string frontFaceWinding = "ccw";
		bool wireframe = false;
		std::vector<GraphicsBackend::CanvasHandle> canvases;
		std::vector<GraphicsBackend::CanvasTarget> canvasTargets;
		std::vector<int> canvasReferences;
		std::vector<::love::StrongRef<::love::Object>> canvasObjects;
		GraphicsBackend::CanvasHandle canvasDepthStencil = 0;
		GraphicsBackend::CanvasTarget canvasDepthStencilTarget;
		int canvasDepthStencilReference = -2;
		::love::StrongRef<::love::Object> canvasDepthStencilObject;
		bool canvasDepth = false;
		bool canvasStencil = false;
		bool stencilTestEnabled = false;
		std::string stencilCompare = "always";
		int stencilValue = 0;
		std::string stencilMode = "off";
		GraphicsBackend::ShaderHandle shader = 0;
		::love::StrongRef<::love::Object> shaderObject;
		GraphicsBackend::FontHandle font = 0;
		::love::StrongRef<::love::Object> fontObject;
		bool all = false;
	};
	GraphicsTransform _graphicsTransform;
	std::string _graphicsBlendMode = "alpha";
	std::string _graphicsBlendAlphaMode = "alphamultiply";
	bool _graphicsScissorEnabled = false;
	float _graphicsScissor[4] = {0.0f, 0.0f, 0.0f, 0.0f};
	bool _graphicsColorMask[4] = {true, true, true, true};
	std::string _graphicsDepthCompare = "always";
	bool _graphicsDepthWrite = false;
	std::string _graphicsMeshCullMode = "none";
	std::string _graphicsFrontFaceWinding = "ccw";
	bool _graphicsWireframe = false;
	bool _graphicsStencilTestEnabled = false;
	std::string _graphicsStencilCompare = "always";
	int _graphicsStencilValue = 0;
	std::string _graphicsStencilMode = "off";
	bool _graphicsStencilWriting = false;
	std::vector<GraphicsState> _graphicsStateStack;
	std::vector<GraphicsBackend::CanvasHandle> _graphicsCanvases;
	std::vector<GraphicsBackend::CanvasTarget> _graphicsCanvasTargets;
	std::vector<int> _graphicsCanvasReferences;
	std::vector<::love::StrongRef<::love::Object>> _graphicsCanvasObjects;
	GraphicsBackend::CanvasHandle _graphicsCanvasDepthStencil = 0;
	GraphicsBackend::CanvasTarget _graphicsCanvasDepthStencilTarget;
	int _graphicsCanvasDepthStencilReference = -2;
	::love::StrongRef<::love::Object> _graphicsCanvasDepthStencilObject;
	bool _graphicsCanvasDepth = false;
	bool _graphicsCanvasStencil = false;
	GraphicsBackend::ShaderHandle _graphicsShader = 0;
	::love::StrongRef<::love::Object> _graphicsShaderObject;
	::love::StrongRef<::love::Object> _graphicsFontObject;
	struct ScreenshotRequest
	{
		std::string filename;
		std::string format = "png";
		int callbackReference = -2;
		::love::StrongRef<::love::Object> channel;
	};
	std::unordered_map<std::uint64_t, ScreenshotRequest> _screenshotRequests;
	std::uint64_t _nextScreenshotRequest = 1;
	enum class QueuedEventType
	{
		KeyPressed,
		KeyReleased,
		TextInput,
		TextEdited,
		MousePressed,
		MouseReleased,
		MouseMoved,
		WheelMoved,
		TouchPressed,
		TouchReleased,
		TouchMoved,
		JoystickAdded,
		JoystickRemoved,
		JoystickPressed,
		JoystickReleased,
		JoystickAxis,
		JoystickHat,
		GamepadPressed,
		GamepadReleased,
		GamepadAxis,
		Custom,
		Quit,
	};
	struct QueuedEvent
	{
		QueuedEventType type;
		std::string first;
		std::string second;
		float x = 0.0f;
		float y = 0.0f;
		float deltaX = 0.0f;
		float deltaY = 0.0f;
		int button = 0;
		int presses = 0;
		bool flag = false;
		std::uintptr_t touchId = 0;
		float pressure = 1.0f;
		int controllerId = -1;
		int registryReference = -2;
	};
	struct TouchState
	{
		float x = 0.0f;
		float y = 0.0f;
		float pressure = 1.0f;
	};
	std::deque<QueuedEvent> _eventQueue;
	std::unordered_set<std::string> _pressedKeys;
	std::unordered_set<std::string> _pressedScancodes;
	bool _keyRepeatEnabled = false;
	std::unordered_set<int> _pressedMouseButtons;
	std::unordered_map<std::uintptr_t, TouchState> _touches;
	struct JoystickState
	{
		std::string name;
		JoystickBackend::DeviceInfo info;
		bool connected = true;
		std::unordered_set<std::string> buttons;
		std::unordered_map<std::string, float> axes;
		float vibrationLeft = 0.0f;
		float vibrationRight = 0.0f;
		double vibrationEndTime = 0.0;
		::love::StrongRef<::love::Object> object;
	};
	std::map<int, JoystickState> _joysticks;
	int pushQueuedEventArguments(QueuedEvent &event, const char *&name);
	int pollQueuedEvent(lua_State *state);
	void releaseQueuedEvent(QueuedEvent &event) noexcept;
	void clearQueuedEvents() noexcept;
	std::unordered_set<GraphicsBackend::FontHandle> _fontHandles;
	std::unordered_set<GraphicsBackend::ImageHandle> _imageHandles;
	std::unordered_set<GraphicsBackend::CanvasHandle> _canvasHandles;
	std::unordered_set<GraphicsBackend::ShaderHandle> _shaderHandles;
	std::unordered_set<AudioBackend::SourceHandle> _audioHandles;
	std::unordered_set<AudioBackend::RecordingHandle> _recordingHandles;
	std::unordered_set<PhysicsBackend::WorldHandle> _physicsWorldHandles;
	std::unordered_set<PhysicsBackend::BodyHandle> _physicsBodyHandles;
	std::unordered_set<PhysicsBackend::ShapeHandle> _physicsShapeHandles;
	std::unordered_set<PhysicsBackend::FixtureHandle> _physicsFixtureHandles;
	std::unordered_set<PhysicsBackend::JointHandle> _physicsJointHandles;
	GraphicsBackend::FontHandle _currentFont = 0;
	float _mouseX = 0.0f;
	float _mouseY = 0.0f;
	bool _mouseVisible = true;
	bool _mouseGrabbed = false;
	bool _mouseRelativeMode = false;
	MouseBackend::CursorHandle _mouseCursor = 0;
	std::unordered_set<MouseBackend::CursorHandle> _mouseCursorHandles;
	double _timerOrigin = 0.0;
	double _timerDelta = 0.0;
	double _timerAverageDelta = 0.0;
	double _timerWindow = 0.0;
	int _timerFrames = 0;
	int _timerFPS = 0;
	std::size_t _allocationBytes = 0;
	std::size_t _peakAllocationBytes = 0;
};

} // namespace Dora::Love
