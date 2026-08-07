/**
 * LÖVE 11.5 API summaries are adapted from the official LÖVE Wiki.
 * Copyright © 2006-2010 LÖVE Development Team. Documentation is redistributed
 * under the FreeBSD Documentation License described at https://love2d.org/wiki/License.
 * Each declaration links to its authoritative Wiki page; Dora-specific compatibility
 * notes remain explicitly marked as such.
 */
/////////////////////////////
/// Love 11.5 API（已实现子集）
/////////////////////////////

declare global {
	namespace Love {
	type DrawMode = "fill" | "line";
	type ArcMode = "open" | "closed" | "pie";
	type LineStyle = "rough" | "smooth";
	type LineJoin = "none" | "miter" | "bevel";
	type BlendMode = "alpha" | "add" | "subtract" | "multiply" | "replace" | "screen";
	type BlendAlphaMode = "alphamultiply" | "premultiplied";
	type AlignMode = "left" | "center" | "right" | "justify";
	type FilterMode = "linear" | "nearest";
	type WrapMode = "clamp" | "clampzero" | "repeat" | "mirroredrepeat";
	type TextureType = "2d" | "array" | "cube" | "volume";
	type StencilAction = "replace" | "increment" | "decrement" | "incrementwrap" | "decrementwrap" | "invert";
	type CompareMode = "less" | "lequal" | "equal" | "gequal" | "greater" | "notequal" | "always" | "never";
	type MeshDrawMode = "fan" | "strip" | "triangles" | "points";
	type MeshUsage = "stream" | "dynamic" | "static";
	type VertexDataType = "float" | "byte" | "unorm16";
	type AttributeStep = "pervertex" | "perinstance";
	type IndexDataType = "uint16" | "uint32";
	type MeshCullMode = "none" | "back" | "front";
	type Winding = "cw" | "ccw";
	type ParticleInsertMode = "top" | "bottom" | "random";
	type ParticleAreaSpreadDistribution = "none" | "uniform" | "normal" | "ellipse" | "borderellipse" | "borderrectangle";
	type Color = [number, number, number] | [number, number, number, number];
	type ColoredText = string | (string | Color)[];
	type MeshVertex = number[];
	type MeshVertexFormat = [name: string, type: VertexDataType, components: 1 | 2 | 3 | 4];
	type CanvasFormat = "normal" | "hdr" | "r8" | "rg8" | "rgba8" | "srgba8" | "r16" | "rg16" | "rgba16" | "r16f" | "rg16f" | "rgba16f" | "r32f" | "rg32f" | "rgba32f" | "la8" | "rgba4" | "rgb5a1" | "rgb565" | "rgb10a2" | "rg11b10f" | "stencil8" | "depth16" | "depth24" | "depth32f" | "depth24stencil8" | "depth32fstencil8";
	type ImagePixelFormat = "r8" | "rg8" | "rgba8" | "r16" | "rg16" | "rgba16" | "r16f" | "rg16f" | "rgba16f" | "r32f" | "rg32f" | "rgba32f" | "rgba4" | "rgb5a1" | "rgb565" | "rgb10a2" | "rg11b10f";
	type CompressedPixelFormat = "DXT1" | "DXT3" | "DXT5" | "BC4" | "BC4s" | "BC5" | "BC5s" | "BC6h" | "BC6hs" | "BC7" | "PVR1rgb2" | "PVR1rgb4" | "PVR1rgba2" | "PVR1rgba4" | "ETC1" | "ETC2rgb" | "ETC2rgba" | "ETC2rgba1" | "EACr" | "EACrs" | "EACrg" | "EACrgs" | "ASTC4x4" | "ASTC5x4" | "ASTC5x5" | "ASTC6x5" | "ASTC6x6" | "ASTC8x5" | "ASTC8x6" | "ASTC8x8" | "ASTC10x5" | "ASTC10x6" | "ASTC10x8" | "ASTC10x10" | "ASTC12x10" | "ASTC12x12";
	interface CanvasFormats { [format: string]: boolean; }
	interface ImageFormats { [format: string]: boolean; }
	interface WindowConfig {
		/** 兼容既有 Love TypeScript 定义的别名；Love 11.5 原生字段是 Config.title。 */
		title?: string;
		width: number;
		height: number;
		fullscreen: boolean;
		display: number;
		highdpi: boolean;
		resizable: boolean;
		vsync: -1 | 0 | 1;
	}
	interface Config {
		version: "11.5";
		title: string;
		identity?: string;
		window: WindowConfig;
	}
	/** The superclass of all LÖVE types.
	 * @see https://love2d.org/wiki/Object
	 */
	interface Object {
		/** Gets the type of the object as a string.
		 * @see https://love2d.org/wiki/Object:type
		 */
		type(): string;
		/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 * @see https://love2d.org/wiki/Object:typeOf
		 */
		typeOf(typeName: string): boolean;
		/** Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.
		 * @see https://love2d.org/wiki/Object:release
		 */
		release(): boolean;
	}
		/** Drawable image type.
		 * @see https://love2d.org/wiki/Image
		 */
		interface Image extends Object {
			/** Gets the type of the object as a string.
			 * @see https://love2d.org/wiki/Object:type
			 */
			type(): "Image";
			/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
			 * @see https://love2d.org/wiki/Object:typeOf
			 */
			typeOf(typeName: string): boolean;
			/** Gets the width of the Texture.
			 * @see https://love2d.org/wiki/Texture:getWidth
			 */
			getWidth(): number;
			/** Gets the height of the Texture.
			 * @see https://love2d.org/wiki/Texture:getHeight
			 */
			getHeight(): number;
			/** Gets the width and height of the Texture.
			 * @see https://love2d.org/wiki/Texture:getDimensions
			 */
			getDimensions(): LuaMultiReturn<[number, number]>;
			/** Gets the type of the Texture.
			 * @see https://love2d.org/wiki/Texture:getTextureType
			 */
			getTextureType(): TextureType;
			/** Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.
			 * @see https://love2d.org/wiki/Texture:getDepth
			 */
			getDepth(): number;
			/** Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.
			 * @see https://love2d.org/wiki/Texture:getLayerCount
			 */
			getLayerCount(): number;
			/** Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will return 1.
			 * @see https://love2d.org/wiki/Texture:getMipmapCount
			 */
			getMipmapCount(): number;
			/** Gets the width in pixels of the Texture.
			 * @see https://love2d.org/wiki/Texture:getPixelWidth
			 */
			getPixelWidth(): number;
			/** Gets the height in pixels of the Texture.
			 * @see https://love2d.org/wiki/Texture:getPixelHeight
			 */
			getPixelHeight(): number;
			/** Gets the width and height in pixels of the Texture.
			 * @see https://love2d.org/wiki/Texture:getPixelDimensions
			 */
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			/** Gets the DPI scale factor of the Texture.
			 * @see https://love2d.org/wiki/Texture:getDPIScale
			 */
			getDPIScale(): number;
			/** Sets the filter mode of the Texture.
			 * @see https://love2d.org/wiki/Texture:setFilter
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/** Gets the filter mode of the Texture.
			 * @see https://love2d.org/wiki/Texture:getFilter
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			/** Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
			 * @see https://love2d.org/wiki/Texture:setMipmapFilter
			 */
			setMipmapFilter(filter?: FilterMode, sharpness?: number): void;
			/** Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
			 * @see https://love2d.org/wiki/Texture:getMipmapFilter
			 */
			getMipmapFilter(): LuaMultiReturn<[FilterMode | undefined, number]>;
			/** Sets the wrapping properties of a Texture.
			 * @see https://love2d.org/wiki/Texture:setWrap
			 */
			setWrap(horizontal: WrapMode, vertical?: WrapMode, depth?: WrapMode): boolean;
			/** Gets the wrapping properties of a Texture.
			 * @see https://love2d.org/wiki/Texture:getWrap
			 */
			getWrap(): LuaMultiReturn<[WrapMode, WrapMode, WrapMode]>;
			/** Gets the pixel format of the Texture.
			 * @see https://love2d.org/wiki/Texture:getFormat
			 */
			getFormat(): string;
			/** Gets whether the Texture can be drawn and sent to a Shader.
			 * @see https://love2d.org/wiki/Texture:isReadable
			 */
			isReadable(): boolean;
			/** Gets whether the Image was created from CompressedData.
			 * @see https://love2d.org/wiki/Image:isCompressed
			 */
			isCompressed(): boolean;
			/** Gets whether the Image was created with the linear (non-gamma corrected) flag set to true.
			 * @see https://love2d.org/wiki/Image:isFormatLinear
			 */
			isFormatLinear(): boolean;
			/** Replace the contents of an Image.
			 * @see https://love2d.org/wiki/Image:replacePixels
			 */
			replacePixels(data: ImageData, slice?: number, mipmap?: number, x?: number, y?: number, reloadMipmaps?: boolean): void;
			/** Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.
			 * @see https://love2d.org/wiki/Texture:setDepthSampleMode
			 */
			setDepthSampleMode(compare?: CompareMode): void;
			/** Gets the comparison mode used when sampling from a depth texture in a shader.
			 * @see https://love2d.org/wiki/Texture:getDepthSampleMode
			 */
			getDepthSampleMode(): CompareMode | undefined;
		}
		/** An object which decodes, streams, and controls Videos.
		 * @see https://love2d.org/wiki/VideoStream
		 */
		interface VideoStream extends Object {
			/** Gets the type of the object as a string.
			 * @see https://love2d.org/wiki/Object:type
			 */
			type(): "VideoStream";
			/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
			 * @see https://love2d.org/wiki/Object:typeOf
			 */
			typeOf(typeName: string): boolean;
			/** Plays the VideoStream.
			 * @see https://love2d.org/wiki/VideoStream:play
			 */
			play(): void;
			/** Pauses the VideoStream.
			 * @see https://love2d.org/wiki/VideoStream:pause
			 */
			pause(): void;
			/** Sets the current playback position of the VideoStream.
			 * @see https://love2d.org/wiki/VideoStream:seek
			 */
			seek(seconds: number): void;
			/** Rewinds the VideoStream. Synonym to VideoStream:seek(0).
			 * @see https://love2d.org/wiki/VideoStream:rewind
			 */
			rewind(): void;
			/** Gets the current playback position of the VideoStream.
			 * @see https://love2d.org/wiki/VideoStream:tell
			 */
			tell(): number;
			/** Gets whether the VideoStream is playing.
			 * @see https://love2d.org/wiki/VideoStream:isPlaying
			 */
			isPlaying(): boolean;
			/** Gets the filename of the VideoStream.
			 * @see https://love2d.org/wiki/VideoStream:getFilename
			 */
			getFilename(): string;
			setSync(source?: Source): void;
		}
		/** A drawable video.
		 * @see https://love2d.org/wiki/Video
		 */
		interface Video extends Object {
			/** Gets the type of the object as a string.
			 * @see https://love2d.org/wiki/Object:type
			 */
			type(): "Video";
			/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
			 * @see https://love2d.org/wiki/Object:typeOf
			 */
			typeOf(typeName: string): boolean;
			/** Gets the VideoStream object used for decoding and controlling the video.
			 * @see https://love2d.org/wiki/Video:getStream
			 */
			getStream(): VideoStream;
			/** Gets the audio Source used for playing back the video's audio. May return nil if the video has no audio, or if Video:setSource is called with a nil argument.
			 * @see https://love2d.org/wiki/Video:getSource
			 */
			getSource(): Source | undefined;
			/** Sets the audio Source used for playing back the video's audio. The audio Source also controls playback speed and synchronization.
			 * @see https://love2d.org/wiki/Video:setSource
			 */
			setSource(source?: Source): void;
			/** Gets the width of the Video in pixels.
			 * @see https://love2d.org/wiki/Video:getWidth
			 */
			getWidth(): number;
			/** Gets the height of the Video in pixels.
			 * @see https://love2d.org/wiki/Video:getHeight
			 */
			getHeight(): number;
			/** Gets the width and height of the Video in pixels.
			 * @see https://love2d.org/wiki/Video:getDimensions
			 */
			getDimensions(): LuaMultiReturn<[number, number]>;
			getPixelWidth(): number;
			getPixelHeight(): number;
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			/** Sets the scaling filters used when drawing the Video.
			 * @see https://love2d.org/wiki/Video:setFilter
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/** Gets the scaling filters used when drawing the Video.
			 * @see https://love2d.org/wiki/Video:getFilter
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
		}
		/** This module is responsible for decoding, controlling, and streaming video files.
		 * @see https://love2d.org/wiki/love.video
		 */
		interface VideoModule { newVideoStream(filename: string): VideoStream; }
		/** A Canvas is used for off-screen rendering. Think of it as an invisible screen that you can draw to, but that will not be visible until you draw it to the actual visible screen. It is also known as "render to texture".
		 * @see https://love2d.org/wiki/Canvas
		 */
		interface Canvas extends Object {
			/** Gets the type of the object as a string.
			 * @see https://love2d.org/wiki/Object:type
			 */
			type(): "Canvas";
			/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
			 * @see https://love2d.org/wiki/Object:typeOf
			 */
			typeOf(typeName: string): boolean;
			/** Gets the width of the Texture.
			 * @see https://love2d.org/wiki/Texture:getWidth
			 */
			getWidth(): number;
			/** Gets the height of the Texture.
			 * @see https://love2d.org/wiki/Texture:getHeight
			 */
			getHeight(): number;
			/** Gets the width and height of the Texture.
			 * @see https://love2d.org/wiki/Texture:getDimensions
			 */
			getDimensions(): LuaMultiReturn<[number, number]>;
			/** Gets the width in pixels of the Texture.
			 * @see https://love2d.org/wiki/Texture:getPixelWidth
			 */
			getPixelWidth(): number;
			/** Gets the height in pixels of the Texture.
			 * @see https://love2d.org/wiki/Texture:getPixelHeight
			 */
			getPixelHeight(): number;
			/** Gets the width and height in pixels of the Texture.
			 * @see https://love2d.org/wiki/Texture:getPixelDimensions
			 */
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			/** Gets the DPI scale factor of the Texture.
			 * @see https://love2d.org/wiki/Texture:getDPIScale
			 */
			getDPIScale(): number;
			/** Gets the type of the Texture.
			 * @see https://love2d.org/wiki/Texture:getTextureType
			 */
			getTextureType(): TextureType;
			/** Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.
			 * @see https://love2d.org/wiki/Texture:getDepth
			 */
			getDepth(): number;
			/** Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.
			 * @see https://love2d.org/wiki/Texture:getLayerCount
			 */
			getLayerCount(): number;
			/** Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will return 1.
			 * @see https://love2d.org/wiki/Texture:getMipmapCount
			 */
			getMipmapCount(): number;
			/** Gets the MipmapMode this Canvas was created with.
			 * @see https://love2d.org/wiki/Canvas:getMipmapMode
			 */
			getMipmapMode(): string;
			/** Gets the pixel format of the Texture.
			 * @see https://love2d.org/wiki/Texture:getFormat
			 */
			getFormat(): CanvasFormat;
			/** Gets the number of multisample antialiasing (MSAA) samples used when drawing to the Canvas.
			 * @see https://love2d.org/wiki/Canvas:getMSAA
			 */
			getMSAA(): 0 | 2 | 4 | 8 | 16;
			/** Gets whether the Texture can be drawn and sent to a Shader.
			 * @see https://love2d.org/wiki/Texture:isReadable
			 */
			isReadable(): boolean;
			/** Generates ImageData from the contents of the Canvas.
			 * @see https://love2d.org/wiki/Canvas:newImageData
			 */
			newImageData(slice?: 1, mipmap?: 1, x?: number, y?: number, width?: number, height?: number): ImageData;
			/** Sets the filter mode of the Texture.
			 * @see https://love2d.org/wiki/Texture:setFilter
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/** Gets the filter mode of the Texture.
			 * @see https://love2d.org/wiki/Texture:getFilter
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			/** Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
			 * @see https://love2d.org/wiki/Texture:setMipmapFilter
			 */
			setMipmapFilter(filter?: FilterMode, sharpness?: number): void;
			/** Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
			 * @see https://love2d.org/wiki/Texture:getMipmapFilter
			 */
			getMipmapFilter(): LuaMultiReturn<[FilterMode | undefined, number]>;
			/** Sets the wrapping properties of a Texture.
			 * @see https://love2d.org/wiki/Texture:setWrap
			 */
			setWrap(horizontal: WrapMode, vertical?: WrapMode, depth?: WrapMode): boolean;
			/** Gets the wrapping properties of a Texture.
			 * @see https://love2d.org/wiki/Texture:getWrap
			 */
			getWrap(): LuaMultiReturn<[WrapMode, WrapMode, WrapMode]>;
			/** Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.
			 * @see https://love2d.org/wiki/Texture:setDepthSampleMode
			 */
			setDepthSampleMode(compare?: CompareMode): void;
			/** Gets the comparison mode used when sampling from a depth texture in a shader.
			 * @see https://love2d.org/wiki/Texture:getDepthSampleMode
			 */
			getDepthSampleMode(): CompareMode | undefined;
			/** Generates mipmaps for the Canvas, based on the contents of the highest-resolution mipmap level.
			 * @see https://love2d.org/wiki/Canvas:generateMipmaps
			 */
			generateMipmaps(): void;
			/** Render to the Canvas using a function.
			 * @see https://love2d.org/wiki/Canvas:renderTo
			 */
			renderTo(callback: () => void): void;
		}
		interface CanvasSettings {
			dpiscale?: 1;
			msaa?: 0 | 2 | 4 | 8 | 16;
			format?: CanvasFormat;
			type?: "2d";
			readable?: boolean;
			mipmaps?: "none";
		}
		interface LayeredImageSettings {
			mipmaps?: false;
			linear?: boolean;
			dpiscale?: number;
		}
		interface ImageSettings {
			mipmaps?: false;
			linear?: boolean;
			dpiscale?: number;
		}
		interface CompressedImageSettings {
			mipmaps?: boolean;
			linear?: boolean;
			dpiscale?: number;
		}
		interface GraphicsSystemLimits {
			pointsize: number;
			texturesize: number;
			volumetexturesize: number;
			cubetexturesize: number;
			texturelayers: number;
			multicanvas: number;
			canvasmsaa: number;
			anisotropy: number;
		}
		interface GraphicsStats {
			drawcalls: number;
			drawcallsbatched: number;
			canvasswitches: number;
			shaderswitches: number;
			canvases: number;
			images: number;
			fonts: number;
			texturememory: number;
		}
		interface GraphicsFeatures {
			multicanvasformats: boolean;
			clampzero: boolean;
			lighten: boolean;
			fullnpot: boolean;
			pixelshaderhighp: boolean;
			shaderderivatives: boolean;
			glsl3: boolean;
			instancing: boolean;
		}
		interface TextureTypes {
			"2d": boolean;
			array: boolean;
			cube: boolean;
			volume: boolean;
		}
		interface CanvasSetup {
			[index: number]: Canvas;
			length: number;
			depth?: boolean;
			stencil?: boolean;
			depthstencil?: boolean | Canvas;
		}
		/** Defines the shape of characters that can be drawn onto the screen.
		 * @see https://love2d.org/wiki/Font
		 */
		interface Font extends Object {
			/** Gets the type of the object as a string.
			 * @see https://love2d.org/wiki/Object:type
			 */
			type(): "Font";
			/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
			 * @see https://love2d.org/wiki/Object:typeOf
			 */
			typeOf(type: string): boolean;
			/** Determines the maximum width (accounting for newlines) taken by the given string.
			 * @see https://love2d.org/wiki/Font:getWidth
			 */
			getWidth(text: string): number;
			/** Gets the height of the Font.
			 * @see https://love2d.org/wiki/Font:getHeight
			 */
			getHeight(): number;
			/** Gets the baseline of the Font.
			 * @see https://love2d.org/wiki/Font:getBaseline
			 */
			getBaseline(): number;
			/** Gets the ascent of the Font.
			 * @see https://love2d.org/wiki/Font:getAscent
			 */
			getAscent(): number;
			/** Gets the descent of the Font.
			 * @see https://love2d.org/wiki/Font:getDescent
			 */
			getDescent(): number;
			/** Gets whether the Font can render a character or string.
			 * @see https://love2d.org/wiki/Font:hasGlyphs
			 */
			hasGlyphs(...textOrCodepoints: (string | number)[]): boolean;
			/** Gets the kerning between two characters in the Font.
			 * @see https://love2d.org/wiki/Font:getKerning
			 */
			getKerning(left: string | number, right: string | number): number;
			/** Sets the fallback fonts. When the Font doesn't contain a glyph, it will substitute the glyph from the next subsequent fallback Fonts. This is akin to setting a 'font stack' in Cascading Style Sheets (CSS).
			 * @see https://love2d.org/wiki/Font:setFallbacks
			 */
			setFallbacks(...fallbacks: Font[]): void;
			/** Sets the line height.
			 * @see https://love2d.org/wiki/Font:setLineHeight
			 */
			setLineHeight(height: number): void;
			/** Gets the line height.
			 * @see https://love2d.org/wiki/Font:getLineHeight
			 */
			getLineHeight(): number;
			/** Gets the DPI scale factor of the Font.
			 * @see https://love2d.org/wiki/Font:getDPIScale
			 */
			getDPIScale(): number;
			/** Gets the filter mode for a font.
			 * @see https://love2d.org/wiki/Font:getFilter
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			/** Sets the filter mode for a font.
			 * @see https://love2d.org/wiki/Font:setFilter
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/** Gets formatting information for text, given a wrap limit.
			 * @see https://love2d.org/wiki/Font:getWrap
			 */
			getWrap(text: string, wrapLimit: number): LuaMultiReturn<[number, string[]]>;
		}
		/** Drawable text.
		 * @see https://love2d.org/wiki/Text
		 */
		interface Text extends Object {
			/** Replaces the contents of the Text object with a new unformatted string.
			 * @see https://love2d.org/wiki/Text:set
			 */
			set(text: ColoredText): void;
			/** Replaces the contents of the Text object with a new formatted string.
			 * @see https://love2d.org/wiki/Text:setf
			 */
			setf(text: ColoredText, wrapLimit: number, align: AlignMode): void;
			/** Adds additional colored text to the Text object at the specified position.
			 * @see https://love2d.org/wiki/Text:add
			 */
			add(text: ColoredText, transform: Transform): number;
			add(text: ColoredText, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/** Adds additional formatted / colored text to the Text object at the specified position.
			 * @see https://love2d.org/wiki/Text:addf
			 */
			addf(text: ColoredText, wrapLimit: number, align: AlignMode, transform: Transform): number;
			addf(text: ColoredText, wrapLimit: number, align: AlignMode, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/** Clears the contents of the Text object.
			 * @see https://love2d.org/wiki/Text:clear
			 */
			clear(): void;
			/** Replaces the Font used with the text.
			 * @see https://love2d.org/wiki/Text:setFont
			 */
			setFont(font: Font): void;
			/** Gets the Font used with the Text object.
			 * @see https://love2d.org/wiki/Text:getFont
			 */
			getFont(): Font;
			/** Gets the width of the text in pixels.
			 * @see https://love2d.org/wiki/Text:getWidth
			 */
			getWidth(index?: number): number;
			/** Gets the height of the text in pixels.
			 * @see https://love2d.org/wiki/Text:getHeight
			 */
			getHeight(index?: number): number;
			/** Gets the width and height of the text in pixels.
			 * @see https://love2d.org/wiki/Text:getDimensions
			 */
			getDimensions(index?: number): LuaMultiReturn<[number, number]>;
		}
		/** A quadrilateral (a polygon with four sides and four corners) with texture coordinate information.
		 * @see https://love2d.org/wiki/Quad
		 */
		interface Quad extends Object {
			/** Sets the texture coordinates according to a viewport.
			 * @see https://love2d.org/wiki/Quad:setViewport
			 */
			setViewport(x: number, y: number, width: number, height: number, textureWidth?: number, textureHeight?: number): void;
			/** Gets the current viewport of this Quad.
			 * @see https://love2d.org/wiki/Quad:getViewport
			 */
			getViewport(): LuaMultiReturn<[number, number, number, number]>;
			/** Gets reference texture dimensions initially specified in love.graphics.newQuad.
			 * @see https://love2d.org/wiki/Quad:getTextureDimensions
			 */
			getTextureDimensions(): LuaMultiReturn<[number, number]>;
			setLayer(layer: number): void;
			getLayer(): number;
		}
		/** A 2D polygon mesh used for drawing arbitrary textured shapes.
		 * @see https://love2d.org/wiki/Mesh
		 */
		interface Mesh extends Object {
			/** Replaces a range of vertices in the Mesh with new ones. The total number of vertices in a Mesh cannot be changed after it has been created. This is often more efficient than calling Mesh:setVertex in a loop.
			 * @see https://love2d.org/wiki/Mesh:setVertices
			 */
			setVertices(vertices: MeshVertex[], startVertex?: number, vertexCount?: number): void;
			setVertices(data: Data, startVertex?: number, vertexCount?: number): void;
			/** Sets the properties of a vertex in the Mesh.
			 * @see https://love2d.org/wiki/Mesh:setVertex
			 */
			setVertex(index: number, vertex: MeshVertex): void;
			setVertex(index: number, ...components: number[]): void;
			/** Gets the properties of a vertex in the Mesh.
			 * @see https://love2d.org/wiki/Mesh:getVertex
			 */
			getVertex(index: number): LuaMultiReturn<[number, ...number[]]>;
			/** Sets the properties of a specific attribute within a vertex in the Mesh.
			 * @see https://love2d.org/wiki/Mesh:setVertexAttribute
			 */
			setVertexAttribute(vertexIndex: number, attributeIndex: number, ...components: number[]): void;
			/** Gets the properties of a specific attribute within a vertex in the Mesh.
			 * @see https://love2d.org/wiki/Mesh:getVertexAttribute
			 */
			getVertexAttribute(vertexIndex: number, attributeIndex: number): LuaMultiReturn<[number, ...number[]]>;
			/** Gets the total number of vertices in the Mesh.
			 * @see https://love2d.org/wiki/Mesh:getVertexCount
			 */
			getVertexCount(): number;
			/** Gets the vertex format that the Mesh was created with.
			 * @see https://love2d.org/wiki/Mesh:getVertexFormat
			 */
			getVertexFormat(): MeshVertexFormat[];
			/** Enables or disables a specific vertex attribute in the Mesh. Vertex data from disabled attributes is not used when drawing the Mesh.
			 * @see https://love2d.org/wiki/Mesh:setAttributeEnabled
			 */
			setAttributeEnabled(name: string, enabled: boolean): void;
			/** Gets whether a specific vertex attribute in the Mesh is enabled. Vertex data from disabled attributes is not used when drawing the Mesh.
			 * @see https://love2d.org/wiki/Mesh:isAttributeEnabled
			 */
			isAttributeEnabled(name: string): boolean;
			/** Attaches a vertex attribute from a different Mesh onto this Mesh, for use when drawing. This can be used to share vertex attribute data between several different Meshes.
			 * @see https://love2d.org/wiki/Mesh:attachAttribute
			 */
			attachAttribute(name: string, mesh: Mesh, step?: AttributeStep, attributeName?: string): void;
			/** Removes a previously attached vertex attribute from this Mesh.
			 * @see https://love2d.org/wiki/Mesh:detachAttribute
			 */
			detachAttribute(name: string): boolean;
			/** Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
			 * @see https://love2d.org/wiki/Mesh:setVertexMap
			 */
			setVertexMap(): void;
			setVertexMap(indices: number[]): void;
			setVertexMap(...indices: number[]): void;
			setVertexMap(data: Data, dataType: IndexDataType, indexCount?: number): void;
			/** Gets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
			 * @see https://love2d.org/wiki/Mesh:getVertexMap
			 */
			getVertexMap(): number[] | undefined;
			/** Sets the texture (Image or Canvas) used when drawing the Mesh.
			 * @see https://love2d.org/wiki/Mesh:setTexture
			 */
			setTexture(texture?: Image | Canvas): void;
			/** Gets the texture (Image or Canvas) used when drawing the Mesh.
			 * @see https://love2d.org/wiki/Mesh:getTexture
			 */
			getTexture(): Image | Canvas | undefined;
			/** Sets the mode used when drawing the Mesh.
			 * @see https://love2d.org/wiki/Mesh:setDrawMode
			 */
			setDrawMode(mode: MeshDrawMode): void;
			/** Gets the mode used when drawing the Mesh.
			 * @see https://love2d.org/wiki/Mesh:getDrawMode
			 */
			getDrawMode(): MeshDrawMode;
			/** Restricts the drawn vertices of the Mesh to a subset of the total.
			 * @see https://love2d.org/wiki/Mesh:setDrawRange
			 */
			setDrawRange(): void;
			setDrawRange(start: number, count: number): void;
			/** Gets the range of vertices used when drawing the Mesh.
			 * @see https://love2d.org/wiki/Mesh:getDrawRange
			 */
			getDrawRange(): LuaMultiReturn<[number, number]> | undefined;
			/** Immediately sends all modified vertex data in the Mesh to the graphics card.
			 * @see https://love2d.org/wiki/Mesh:flush
			 */
			flush(): void;
		}
		/** Using a single image, draw any number of identical copies of the image using a single call to love.graphics.draw(). This can be used, for example, to draw repeating copies of a single background image with high performance.
		 * @see https://love2d.org/wiki/SpriteBatch
		 */
		interface SpriteBatch extends Object {
			/** Adds a sprite to the batch. Sprites are drawn in the order they are added.
			 * @see https://love2d.org/wiki/SpriteBatch:add
			 */
			add(x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			add(quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/** Changes a sprite in the batch. This requires the sprite index returned by SpriteBatch:add or SpriteBatch:addLayer.
			 * @see https://love2d.org/wiki/SpriteBatch:set
			 */
			set(index: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			set(index: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			/** Adds a sprite to a batch created with an Array Texture.
			 * @see https://love2d.org/wiki/SpriteBatch:addLayer
			 */
			addLayer(layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			addLayer(layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/** Changes a sprite previously added with add or addLayer, in a batch created with an Array Texture.
			 * @see https://love2d.org/wiki/SpriteBatch:setLayer
			 */
			setLayer(index: number, layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			setLayer(index: number, layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			/** Removes all sprites from the buffer.
			 * @see https://love2d.org/wiki/SpriteBatch:clear
			 */
			clear(): void;
			/** Immediately sends all new and modified sprite data in the batch to the graphics card.
			 * @see https://love2d.org/wiki/SpriteBatch:flush
			 */
			flush(): void;
			/** Sets the texture (Image or Canvas) used for the sprites in the batch, when drawing.
			 * @see https://love2d.org/wiki/SpriteBatch:setTexture
			 */
			setTexture(texture: Image | Canvas): void;
			/** Gets the texture (Image or Canvas) used by the SpriteBatch.
			 * @see https://love2d.org/wiki/SpriteBatch:getTexture
			 */
			getTexture(): Image | Canvas;
			/** Sets the color that will be used for the next add and set operations. Calling the function without arguments will disable all per-sprite colors for the SpriteBatch.
			 * @see https://love2d.org/wiki/SpriteBatch:setColor
			 */
			setColor(): void;
			setColor(red: number, green: number, blue: number, alpha?: number): void;
			setColor(color: Color): void;
			/** Gets the color that will be used for the next add and set operations.
			 * @see https://love2d.org/wiki/SpriteBatch:getColor
			 */
			getColor(): LuaMultiReturn<[number, number, number, number]> | undefined;
			/** Gets the number of sprites currently in the SpriteBatch.
			 * @see https://love2d.org/wiki/SpriteBatch:getCount
			 */
			getCount(): number;
			/** Gets the maximum number of sprites the SpriteBatch can hold.
			 * @see https://love2d.org/wiki/SpriteBatch:getBufferSize
			 */
			getBufferSize(): number;
			/** Attaches a per-vertex attribute from a Mesh onto this SpriteBatch, for use when drawing. This can be combined with a Shader to augment a SpriteBatch with per-vertex or additional per-sprite information instead of just having per-sprite colors.
			 * @see https://love2d.org/wiki/SpriteBatch:attachAttribute
			 */
			attachAttribute(name: string, mesh: Mesh): void;
			/** Restricts the drawn sprites in the SpriteBatch to a subset of the total.
			 * @see https://love2d.org/wiki/SpriteBatch:setDrawRange
			 */
			setDrawRange(): void;
			setDrawRange(start: number, count: number): void;
			getDrawRange(): LuaMultiReturn<[number, number]> | undefined;
		}
		/** A ParticleSystem can be used to create particle effects like fire or smoke.
		 * @see https://love2d.org/wiki/ParticleSystem
		 */
		interface ParticleSystem extends Object {
			/** Creates an identical copy of the ParticleSystem in the stopped state.
			 * @see https://love2d.org/wiki/ParticleSystem:clone
			 */
			clone(): ParticleSystem;
			/** Sets the texture (Image or Canvas) to be used for the particles.
			 * @see https://love2d.org/wiki/ParticleSystem:setTexture
			 */
			setTexture(texture: Image | Canvas): void;
			/** Gets the texture (Image or Canvas) used for the particles.
			 * @see https://love2d.org/wiki/ParticleSystem:getTexture
			 */
			getTexture(): Image | Canvas;
			/** Sets the size of the buffer (the max allowed amount of particles in the system).
			 * @see https://love2d.org/wiki/ParticleSystem:setBufferSize
			 */
			setBufferSize(size: number): void;
			/** Gets the maximum number of particles the ParticleSystem can have at once.
			 * @see https://love2d.org/wiki/ParticleSystem:getBufferSize
			 */
			getBufferSize(): number;
			/** Sets the mode to use when the ParticleSystem adds new particles.
			 * @see https://love2d.org/wiki/ParticleSystem:setInsertMode
			 */
			setInsertMode(mode: ParticleInsertMode): void;
			/** Gets the mode used when the ParticleSystem adds new particles.
			 * @see https://love2d.org/wiki/ParticleSystem:getInsertMode
			 */
			getInsertMode(): ParticleInsertMode;
			/** Sets the amount of particles emitted per second.
			 * @see https://love2d.org/wiki/ParticleSystem:setEmissionRate
			 */
			setEmissionRate(rate: number): void;
			/** Gets the amount of particles emitted per second.
			 * @see https://love2d.org/wiki/ParticleSystem:getEmissionRate
			 */
			getEmissionRate(): number;
			/** Sets how long the particle system should emit particles (if -1 then it emits particles forever).
			 * @see https://love2d.org/wiki/ParticleSystem:setEmitterLifetime
			 */
			setEmitterLifetime(lifetime: number): void;
			/** Gets how long the particle system will emit particles (if -1 then it emits particles forever).
			 * @see https://love2d.org/wiki/ParticleSystem:getEmitterLifetime
			 */
			getEmitterLifetime(): number;
			/** Sets the lifetime of the particles.
			 * @see https://love2d.org/wiki/ParticleSystem:setParticleLifetime
			 */
			setParticleLifetime(minimum: number, maximum?: number): void;
			/** Gets the lifetime of the particles.
			 * @see https://love2d.org/wiki/ParticleSystem:getParticleLifetime
			 */
			getParticleLifetime(): LuaMultiReturn<[number, number]>;
			/** Sets the position of the emitter.
			 * @see https://love2d.org/wiki/ParticleSystem:setPosition
			 */
			setPosition(x: number, y: number): void;
			/** Gets the position of the emitter.
			 * @see https://love2d.org/wiki/ParticleSystem:getPosition
			 */
			getPosition(): LuaMultiReturn<[number, number]>;
			/** Moves the position of the emitter. This results in smoother particle spawning behaviour than if ParticleSystem:setPosition is used every frame.
			 * @see https://love2d.org/wiki/ParticleSystem:moveTo
			 */
			moveTo(x: number, y: number): void;
			/** Sets area-based spawn parameters for the particles. Newly created particles will spawn in an area around the emitter based on the parameters to this function.
			 * @see https://love2d.org/wiki/ParticleSystem:setEmissionArea
			 */
			setEmissionArea(distribution?: ParticleAreaSpreadDistribution, x?: number, y?: number, angle?: number, directionRelativeToCenter?: boolean): void;
			/** Gets the area-based spawn parameters for the particles.
			 * @see https://love2d.org/wiki/ParticleSystem:getEmissionArea
			 */
			getEmissionArea(): LuaMultiReturn<[ParticleAreaSpreadDistribution, number, number, number, boolean]>;
			/** @deprecated Use setEmissionArea. */
			setAreaSpread(distribution?: ParticleAreaSpreadDistribution, x?: number, y?: number): void;
			/** @deprecated Use getEmissionArea. */
			getAreaSpread(): LuaMultiReturn<[ParticleAreaSpreadDistribution, number, number]>;
			/** Sets the direction the particles will be emitted in.
			 * @see https://love2d.org/wiki/ParticleSystem:setDirection
			 */
			setDirection(direction: number): void;
			/** Gets the direction of the particle emitter (in radians).
			 * @see https://love2d.org/wiki/ParticleSystem:getDirection
			 */
			getDirection(): number;
			/** Sets the amount of spread for the system.
			 * @see https://love2d.org/wiki/ParticleSystem:setSpread
			 */
			setSpread(spread: number): void;
			/** Gets the amount of directional spread of the particle emitter (in radians).
			 * @see https://love2d.org/wiki/ParticleSystem:getSpread
			 */
			getSpread(): number;
			/** Sets the speed of the particles.
			 * @see https://love2d.org/wiki/ParticleSystem:setSpeed
			 */
			setSpeed(minimum: number, maximum?: number): void;
			/** Gets the speed of the particles.
			 * @see https://love2d.org/wiki/ParticleSystem:getSpeed
			 */
			getSpeed(): LuaMultiReturn<[number, number]>;
			/** Sets the linear acceleration (acceleration along the x and y axes) for particles.
			 * @see https://love2d.org/wiki/ParticleSystem:setLinearAcceleration
			 */
			setLinearAcceleration(xMinimum: number, yMinimum: number, xMaximum?: number, yMaximum?: number): void;
			/** Gets the linear acceleration (acceleration along the x and y axes) for particles.
			 * @see https://love2d.org/wiki/ParticleSystem:getLinearAcceleration
			 */
			getLinearAcceleration(): LuaMultiReturn<[number, number, number, number]>;
			/** Set the radial acceleration (away from the emitter).
			 * @see https://love2d.org/wiki/ParticleSystem:setRadialAcceleration
			 */
			setRadialAcceleration(minimum: number, maximum?: number): void;
			/** Gets the radial acceleration (away from the emitter).
			 * @see https://love2d.org/wiki/ParticleSystem:getRadialAcceleration
			 */
			getRadialAcceleration(): LuaMultiReturn<[number, number]>;
			/** Sets the tangential acceleration (acceleration perpendicular to the particle's direction).
			 * @see https://love2d.org/wiki/ParticleSystem:setTangentialAcceleration
			 */
			setTangentialAcceleration(minimum: number, maximum?: number): void;
			/** Gets the tangential acceleration (acceleration perpendicular to the particle's direction).
			 * @see https://love2d.org/wiki/ParticleSystem:getTangentialAcceleration
			 */
			getTangentialAcceleration(): LuaMultiReturn<[number, number]>;
			/** Sets the amount of linear damping (constant deceleration) for particles.
			 * @see https://love2d.org/wiki/ParticleSystem:setLinearDamping
			 */
			setLinearDamping(minimum: number, maximum?: number): void;
			/** Gets the amount of linear damping (constant deceleration) for particles.
			 * @see https://love2d.org/wiki/ParticleSystem:getLinearDamping
			 */
			getLinearDamping(): LuaMultiReturn<[number, number]>;
			/** Sets a series of sizes by which to scale a particle sprite. 1.0 is normal size. The particle system will interpolate between each size evenly over the particle's lifetime.
			 * @see https://love2d.org/wiki/ParticleSystem:setSizes
			 */
			setSizes(...sizes: number[]): void;
			/** Gets the series of sizes by which the sprite is scaled. 1.0 is normal size. The particle system will interpolate between each size evenly over the particle's lifetime.
			 * @see https://love2d.org/wiki/ParticleSystem:getSizes
			 */
			getSizes(): LuaMultiReturn<number[]>;
			/** Sets the amount of size variation (0 meaning no variation and 1 meaning full variation between start and end).
			 * @see https://love2d.org/wiki/ParticleSystem:setSizeVariation
			 */
			setSizeVariation(variation: number): void;
			/** Gets the amount of size variation (0 meaning no variation and 1 meaning full variation between start and end).
			 * @see https://love2d.org/wiki/ParticleSystem:getSizeVariation
			 */
			getSizeVariation(): number;
			/** Sets the rotation of the image upon particle creation (in radians).
			 * @see https://love2d.org/wiki/ParticleSystem:setRotation
			 */
			setRotation(minimum: number, maximum?: number): void;
			/** Gets the rotation of the image upon particle creation (in radians).
			 * @see https://love2d.org/wiki/ParticleSystem:getRotation
			 */
			getRotation(): LuaMultiReturn<[number, number]>;
			/** Sets the spin of the sprite.
			 * @see https://love2d.org/wiki/ParticleSystem:setSpin
			 */
			setSpin(start: number, finish?: number): void;
			/** Gets the spin of the sprite.
			 * @see https://love2d.org/wiki/ParticleSystem:getSpin
			 */
			getSpin(): LuaMultiReturn<[number, number]>;
			/** Sets the amount of spin variation (0 meaning no variation and 1 meaning full variation between start and end).
			 * @see https://love2d.org/wiki/ParticleSystem:setSpinVariation
			 */
			setSpinVariation(variation: number): void;
			/** Gets the amount of spin variation (0 meaning no variation and 1 meaning full variation between start and end).
			 * @see https://love2d.org/wiki/ParticleSystem:getSpinVariation
			 */
			getSpinVariation(): number;
			/** Set the offset position which the particle sprite is rotated around.
			 * @see https://love2d.org/wiki/ParticleSystem:setOffset
			 */
			setOffset(x: number, y: number): void;
			/** Gets the particle image's draw offset.
			 * @see https://love2d.org/wiki/ParticleSystem:getOffset
			 */
			getOffset(): LuaMultiReturn<[number, number]>;
			/** Sets a series of colors to apply to the particle sprite. The particle system will interpolate between each color evenly over the particle's lifetime.
			 * @see https://love2d.org/wiki/ParticleSystem:setColors
			 */
			setColors(...colors: (Color | number)[]): void;
			/** Gets the series of colors applied to the particle sprite.
			 * @see https://love2d.org/wiki/ParticleSystem:getColors
			 */
			getColors(): LuaMultiReturn<[number, number, number, number][]>;
			/** Sets a series of Quads to use for the particle sprites. Particles will choose a Quad from the list based on the particle's current lifetime, allowing for the use of animated sprite sheets with ParticleSystems.
			 * @see https://love2d.org/wiki/ParticleSystem:setQuads
			 */
			setQuads(...quads: (Quad | Quad[])[]): void;
			/** Gets the series of Quads used for the particle sprites.
			 * @see https://love2d.org/wiki/ParticleSystem:getQuads
			 */
			getQuads(): Quad[];
			/** Sets whether particle angles and rotations are relative to their velocities. If enabled, particles are aligned to the angle of their velocities and rotate relative to that angle.
			 * @see https://love2d.org/wiki/ParticleSystem:setRelativeRotation
			 */
			setRelativeRotation(enabled: boolean): void;
			/** Gets whether particle angles and rotations are relative to their velocities. If enabled, particles are aligned to the angle of their velocities and rotate relative to that angle.
			 * @see https://love2d.org/wiki/ParticleSystem:hasRelativeRotation
			 */
			hasRelativeRotation(): boolean;
			/** Gets the number of particles that are currently in the system.
			 * @see https://love2d.org/wiki/ParticleSystem:getCount
			 */
			getCount(): number;
			/** Starts the particle emitter.
			 * @see https://love2d.org/wiki/ParticleSystem:start
			 */
			start(): void;
			/** Stops the particle emitter, resetting the lifetime counter.
			 * @see https://love2d.org/wiki/ParticleSystem:stop
			 */
			stop(): void;
			/** Pauses the particle emitter.
			 * @see https://love2d.org/wiki/ParticleSystem:pause
			 */
			pause(): void;
			/** Resets the particle emitter, removing any existing particles and resetting the lifetime counter.
			 * @see https://love2d.org/wiki/ParticleSystem:reset
			 */
			reset(): void;
			/** Emits a burst of particles from the particle emitter.
			 * @see https://love2d.org/wiki/ParticleSystem:emit
			 */
			emit(count: number): void;
			/** Checks whether the particle system is actively emitting particles.
			 * @see https://love2d.org/wiki/ParticleSystem:isActive
			 */
			isActive(): boolean;
			/** Checks whether the particle system is paused.
			 * @see https://love2d.org/wiki/ParticleSystem:isPaused
			 */
			isPaused(): boolean;
			/** Checks whether the particle system is stopped.
			 * @see https://love2d.org/wiki/ParticleSystem:isStopped
			 */
			isStopped(): boolean;
			isEmpty(): boolean;
			isFull(): boolean;
			/** Updates the particle system; moving, creating and killing particles.
			 * @see https://love2d.org/wiki/ParticleSystem:update
			 */
			update(deltaTime: number): void;
		}
		type ShaderSource = string | FileData;
		type ShaderValue = number | boolean | number[] | number[][] | boolean[];
		type MatrixLayout = "row" | "column";
		/** A Shader is used for advanced hardware-accelerated pixel or vertex manipulation. These effects are written in a language based on GLSL (OpenGL Shading Language) with a few things simplified for easier coding.
		 * @see https://love2d.org/wiki/Shader
		 */
		interface Shader extends Object {
			/** Returns any warning and error messages from compiling the shader code. This can be used for debugging your shaders if there's anything the graphics hardware doesn't like.
			 * @see https://love2d.org/wiki/Shader:getWarnings
			 */
			getWarnings(): string;
			/** Gets whether a uniform / extern variable exists in the Shader.
			 * @see https://love2d.org/wiki/Shader:hasUniform
			 */
			hasUniform(name: string): boolean;
			/** Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
			 * @see https://love2d.org/wiki/Shader:send
			 */
			send(name: string, texture: Image | Canvas, ...textures: (Image | Canvas)[]): void;
			send(name: string, matrixLayout: MatrixLayout, ...matrices: (number[] | number[][])[]): void;
			send(name: string, data: Data, offset?: number, size?: number): void;
			send(name: string, matrixLayout: MatrixLayout, data: Data, offset?: number, size?: number): void;
			send(name: string, data: Data, matrixLayout: MatrixLayout, offset?: number, size?: number): void;
			send(name: string, ...values: ShaderValue[]): void;
			/** Sends one or more colors to a special (''extern'' / ''uniform'') vec3 or vec4 variable inside the shader. The color components must be in the range of 1. The colors are gamma-corrected if global gamma-correction is enabled.
			 * @see https://love2d.org/wiki/Shader:sendColor
			 */
			sendColor(name: string, data: Data, offset?: number, size?: number): void;
			sendColor(name: string, ...values: ShaderValue[]): void;
		}

	/** @noSelf */
	/** The primary responsibility for the love.graphics module is the drawing of lines, shapes, text, Images and other Drawable objects onto the screen. Its secondary responsibilities include loading external files (including Images and Fonts) into memory, creating specialized objects (such as ParticleSystems or Canvases) and managing screen geometry.
	 * @see https://love2d.org/wiki/love.graphics
	 */
	interface Graphics {
		/** Clears the screen or active Canvas to the specified color.
		 * @see https://love2d.org/wiki/love.graphics.clear
		 */
		clear(red?: number, green?: number, blue?: number, alpha?: number): void;
		/** Discards (trashes) the contents of the screen or active Canvas. This is a performance optimization function with niche use cases.
		 * @see https://love2d.org/wiki/love.graphics.discard
		 */
		discard(discardColor?: boolean | boolean[], discardDepthStencil?: boolean): void;
		/** Immediately renders any pending automatically batched draws.
		 * @see https://love2d.org/wiki/love.graphics.flushBatch
		 */
		flushBatch(): void;
		/** Sets the background color.
		 * @see https://love2d.org/wiki/love.graphics.setBackgroundColor
		 */
		setBackgroundColor(red: number, green: number, blue: number, alpha?: number): void;
		setBackgroundColor(color: Color): void;
		/** Gets the current background color.
		 * @see https://love2d.org/wiki/love.graphics.getBackgroundColor
		 */
		getBackgroundColor(): LuaMultiReturn<[number, number, number, number]>;
		/** Sets the default scaling filters used with Images, Canvases, and Fonts.
		 * @see https://love2d.org/wiki/love.graphics.setDefaultFilter
		 */
		setDefaultFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
		/** Returns the default scaling filters used with Images, Canvases, and Fonts.
		 * @see https://love2d.org/wiki/love.graphics.getDefaultFilter
		 */
		getDefaultFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
		setDefaultMipmapFilter(filter?: FilterMode, sharpness?: number): void;
		getDefaultMipmapFilter(): LuaMultiReturn<[FilterMode | undefined, number]>;
		/** Sets the color used for drawing.
		 * @see https://love2d.org/wiki/love.graphics.setColor
		 */
		setColor(red: number, green: number, blue: number, alpha?: number): void;
		/** Gets the current color.
		 * @see https://love2d.org/wiki/love.graphics.getColor
		 */
		getColor(): LuaMultiReturn<[number, number, number, number]>;
		/** Sets the line width.
		 * @see https://love2d.org/wiki/love.graphics.setLineWidth
		 */
		setLineWidth(width: number): void;
		/** Gets the current line width.
		 * @see https://love2d.org/wiki/love.graphics.getLineWidth
		 */
		getLineWidth(): number;
		/** Sets the line style.
		 * @see https://love2d.org/wiki/love.graphics.setLineStyle
		 */
		setLineStyle(style: LineStyle): void;
		/** Gets the line style.
		 * @see https://love2d.org/wiki/love.graphics.getLineStyle
		 */
		getLineStyle(): LineStyle;
		/** Sets the line join style. See LineJoin for the possible options.
		 * @see https://love2d.org/wiki/love.graphics.setLineJoin
		 */
		setLineJoin(join: LineJoin): void;
		/** Gets the line join style.
		 * @see https://love2d.org/wiki/love.graphics.getLineJoin
		 */
		getLineJoin(): LineJoin;
		/** Sets whether wireframe lines will be used when drawing.
		 * @see https://love2d.org/wiki/love.graphics.setWireframe
		 */
		setWireframe(enable: boolean): void;
		/** Gets whether wireframe mode is used when drawing.
		 * @see https://love2d.org/wiki/love.graphics.isWireframe
		 */
		isWireframe(): boolean;
		/** Sets the point size.
		 * @see https://love2d.org/wiki/love.graphics.setPointSize
		 */
		setPointSize(size: number): void;
		/** Gets the point size.
		 * @see https://love2d.org/wiki/love.graphics.getPointSize
		 */
		getPointSize(): number;
		/** Gets the width and height in pixels of the window.
		 * @see https://love2d.org/wiki/love.graphics.getDimensions
		 */
		getDimensions(): LuaMultiReturn<[number, number]>;
		/** Gets the width in pixels of the window.
		 * @see https://love2d.org/wiki/love.graphics.getWidth
		 */
		getWidth(): number;
		/** Gets the height in pixels of the window.
		 * @see https://love2d.org/wiki/love.graphics.getHeight
		 */
		getHeight(): number;
		/** Gets the width and height in pixels of the window.
		 * @see https://love2d.org/wiki/love.graphics.getPixelDimensions
		 */
		getPixelDimensions(): LuaMultiReturn<[number, number]>;
		/** Gets the width in pixels of the window.
		 * @see https://love2d.org/wiki/love.graphics.getPixelWidth
		 */
		getPixelWidth(): number;
		/** Gets the height in pixels of the window.
		 * @see https://love2d.org/wiki/love.graphics.getPixelHeight
		 */
		getPixelHeight(): number;
		/** Gets the DPI scale factor of the window.
		 * @see https://love2d.org/wiki/love.graphics.getDPIScale
		 */
		getDPIScale(): number;
		/** Gets the optional graphics features and whether they're supported on the system.
		 * @see https://love2d.org/wiki/love.graphics.getSupported
		 */
		getSupported(target?: any): GraphicsFeatures;
		/** Gets the available texture types, and whether each is supported.
		 * @see https://love2d.org/wiki/love.graphics.getTextureTypes
		 */
		getTextureTypes(target?: any): TextureTypes;
		/** Gets the raw and compressed pixel formats usable for Images, and whether each is supported.
		 * @see https://love2d.org/wiki/love.graphics.getImageFormats
		 */
		getImageFormats(target?: any): ImageFormats;
		/** Gets information about the system's video card and drivers.
		 * @see https://love2d.org/wiki/love.graphics.getRendererInfo
		 */
		getRendererInfo(): LuaMultiReturn<[string, string, string, string]>;
		/** Gets the system-dependent maximum values for love.graphics features.
		 * @see https://love2d.org/wiki/love.graphics.getSystemLimits
		 */
		getSystemLimits(target?: any): GraphicsSystemLimits;
		/** Gets performance-related rendering statistics.
		 * @see https://love2d.org/wiki/love.graphics.getStats
		 */
		getStats(target?: any): GraphicsStats;
		/** Creates a screenshot once the current frame is done (after love.draw has finished).
		 * @see https://love2d.org/wiki/love.graphics.captureScreenshot
		 */
		captureScreenshot(filename: string): void;
		captureScreenshot(callback: (imageData: ImageData) => void): void;
		captureScreenshot(channel: Channel): void;
		/** Draws a rectangle.
		 * @see https://love2d.org/wiki/love.graphics.rectangle
		 */
		rectangle(mode: DrawMode, x: number, y: number, width: number, height: number): void;
		/** Draws a circle.
		 * @see https://love2d.org/wiki/love.graphics.circle
		 */
		circle(mode: DrawMode, x: number, y: number, radius: number): void;
		/** Draws a filled or unfilled arc at position (x, y). The arc is drawn from angle1 to angle2 in radians. The segments parameter determines how many segments are used to draw the arc. The more segments, the smoother the edge.
		 * @see https://love2d.org/wiki/love.graphics.arc
		 */
		arc(mode: DrawMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: number): void;
		arc(mode: DrawMode, arcMode: ArcMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: number): void;
		/** Draws an ellipse.
		 * @see https://love2d.org/wiki/love.graphics.ellipse
		 */
		ellipse(mode: DrawMode, x: number, y: number, radiusX: number, radiusY: number, segments?: number): void;
		/** Draws lines between points.
		 * @see https://love2d.org/wiki/love.graphics.line
		 */
		line(x1: number, y1: number, x2: number, y2: number, ...coordinates: number[]): void;
		/** Draw a polygon.
		 * @see https://love2d.org/wiki/love.graphics.polygon
		 */
		polygon(mode: DrawMode, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, ...coordinates: number[]): void;
		/** Draws one or more points.
		 * @see https://love2d.org/wiki/love.graphics.points
		 */
		points(x1: number, y1: number, ...coordinates: number[]): void;
		/** Displays the results of drawing operations on the screen.
		 * @see https://love2d.org/wiki/love.graphics.present
		 */
		present(): void;
		/** Copies and pushes the current coordinate transformation to the transformation stack.
		 * @see https://love2d.org/wiki/love.graphics.push
		 */
		push(stackType?: "transform" | "all"): void;
		/** Pops the current coordinate transformation from the transformation stack.
		 * @see https://love2d.org/wiki/love.graphics.pop
		 */
		pop(): void;
		/** Gets the current depth of the transform / state stack (the number of pushes without corresponding pops).
		 * @see https://love2d.org/wiki/love.graphics.getStackDepth
		 */
		getStackDepth(): number;
		/** Resets the current coordinate transformation.
		 * @see https://love2d.org/wiki/love.graphics.origin
		 */
		origin(): void;
		/** Translates the coordinate system in two dimensions.
		 * @see https://love2d.org/wiki/love.graphics.translate
		 */
		translate(dx: number, dy: number): void;
		/** Rotates the coordinate system in two dimensions.
		 * @see https://love2d.org/wiki/love.graphics.rotate
		 */
		rotate(angle: number): void;
		/** Scales the coordinate system in two dimensions.
		 * @see https://love2d.org/wiki/love.graphics.scale
		 */
		scale(sx: number, sy?: number): void;
		/** Shears the coordinate system.
		 * @see https://love2d.org/wiki/love.graphics.shear
		 */
		shear(kx: number, ky: number): void;
		/** Applies the given Transform object to the current coordinate transformation.
		 * @see https://love2d.org/wiki/love.graphics.applyTransform
		 */
		applyTransform(transform: Transform): void;
		/** Replaces the current coordinate transformation with the given Transform object.
		 * @see https://love2d.org/wiki/love.graphics.replaceTransform
		 */
		replaceTransform(transform: Transform): void;
		/** Converts the given 2D position from global coordinates into screen-space.
		 * @see https://love2d.org/wiki/love.graphics.transformPoint
		 */
		transformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/** Converts the given 2D position from screen-space into global coordinates.
		 * @see https://love2d.org/wiki/love.graphics.inverseTransformPoint
		 */
		inverseTransformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/** Gets whether the graphics module is able to be used. If it is not active, love.graphics function and method calls will not work correctly and may cause the program to crash. The graphics module is inactive if a window is not open, or if the app is in the background on iOS. Typically the app's execution will be automatically paused by the system, in the latter case.
		 * @see https://love2d.org/wiki/love.graphics.isActive
		 */
		isActive(): boolean;
		isCreated(): boolean;
		/** Gets whether gamma-correct rendering is supported and enabled. It can be enabled by setting t.gammacorrect = true in love.conf.
		 * @see https://love2d.org/wiki/love.graphics.isGammaCorrect
		 */
		isGammaCorrect(): boolean;
		/** Resets the current graphics settings.
		 * @see https://love2d.org/wiki/love.graphics.reset
		 */
		reset(): void;
		/** Sets the blending mode.
		 * @see https://love2d.org/wiki/love.graphics.setBlendMode
		 */
		setBlendMode(mode: BlendMode, alphaMode?: BlendAlphaMode): void;
		/** Gets the blending mode.
		 * @see https://love2d.org/wiki/love.graphics.getBlendMode
		 */
		getBlendMode(): LuaMultiReturn<[BlendMode, BlendAlphaMode]>;
		/** Sets or disables scissor.
		 * @see https://love2d.org/wiki/love.graphics.setScissor
		 */
		setScissor(): void;
		setScissor(x: number, y: number, width: number, height: number): void;
		/** Gets the current scissor box.
		 * @see https://love2d.org/wiki/love.graphics.getScissor
		 */
		getScissor(): LuaMultiReturn<[number, number, number, number]> | undefined;
		/** Sets the scissor to the rectangle created by the intersection of the specified rectangle with the existing scissor. If no scissor is active yet, it behaves like love.graphics.setScissor.
		 * @see https://love2d.org/wiki/love.graphics.intersectScissor
		 */
		intersectScissor(x: number, y: number, width: number, height: number): void;
		/** Sets the color mask. Enables or disables specific color components when rendering and clearing the screen. For example, if '''red''' is set to '''false''', no further changes will be made to the red component of any pixels.
		 * @see https://love2d.org/wiki/love.graphics.setColorMask
		 */
		setColorMask(): void;
		setColorMask(red: boolean, green: boolean, blue: boolean, alpha: boolean): void;
		/** Gets the active color components used when drawing. Normally all 4 components are active unless love.graphics.setColorMask has been used.
		 * @see https://love2d.org/wiki/love.graphics.getColorMask
		 */
		getColorMask(): LuaMultiReturn<[boolean, boolean, boolean, boolean]>;
		/** Configures depth testing and writing to the depth buffer.
		 * @see https://love2d.org/wiki/love.graphics.setDepthMode
		 */
		setDepthMode(): void;
		setDepthMode(compare: CompareMode, write: boolean): void;
		/** Gets the current depth test mode and whether writing to the depth buffer is enabled.
		 * @see https://love2d.org/wiki/love.graphics.getDepthMode
		 */
		getDepthMode(): LuaMultiReturn<[CompareMode, boolean]>;
		/** Sets whether back-facing triangles in a Mesh are culled.
		 * @see https://love2d.org/wiki/love.graphics.setMeshCullMode
		 */
		setMeshCullMode(mode: MeshCullMode): void;
		/** Gets whether back-facing triangles in a Mesh are culled.
		 * @see https://love2d.org/wiki/love.graphics.getMeshCullMode
		 */
		getMeshCullMode(): MeshCullMode;
		/** Sets whether triangles with clockwise- or counterclockwise-ordered vertices are considered front-facing.
		 * @see https://love2d.org/wiki/love.graphics.setFrontFaceWinding
		 */
		setFrontFaceWinding(winding: Winding): void;
		/** Gets whether triangles with clockwise- or counterclockwise-ordered vertices are considered front-facing.
		 * @see https://love2d.org/wiki/love.graphics.getFrontFaceWinding
		 */
		getFrontFaceWinding(): Winding;
		/** Draws geometry as a stencil.
		 * @see https://love2d.org/wiki/love.graphics.stencil
		 */
		stencil(draw: () => void, action?: StencilAction, value?: number, keepValuesOrClearValue?: boolean | number): void;
		/** Configures or disables stencil testing.
		 * @see https://love2d.org/wiki/love.graphics.setStencilTest
		 */
		setStencilTest(): void;
		setStencilTest(compare: CompareMode, value: number): void;
		/** Gets the current stencil test configuration.
		 * @see https://love2d.org/wiki/love.graphics.getStencilTest
		 */
		getStencilTest(): LuaMultiReturn<[CompareMode, number]>;
		/** Creates a new Font from a TrueType Font or BMFont file. Created fonts are not cached, in that calling this function with the same arguments will always create a new Font object.
		 * @see https://love2d.org/wiki/love.graphics.newFont
		 */
		newFont(size?: number): Font;
		newFont(filename: string, size?: number): Font;
		/** Creates and sets a new Font.
		 * @see https://love2d.org/wiki/love.graphics.setNewFont
		 */
		setNewFont(size?: number): Font;
		setNewFont(filename: string, size?: number): Font;
		/** Creates a new specifically formatted image.
		 * @see https://love2d.org/wiki/love.graphics.newImageFont
		 */
		newImageFont(source: string | FileData | ImageData, glyphs: string, extraSpacing?: number, dpiScale?: number): Font;
		newImageFont(rasterizer: Rasterizer): Font;
		/** Creates a new drawable Text object.
		 * @see https://love2d.org/wiki/love.graphics.newText
		 */
		newText(font: Font, text?: ColoredText): Text;
		/** Set an already-loaded Font as the current font or create and load a new one from the file and size.
		 * @see https://love2d.org/wiki/love.graphics.setFont
		 */
		setFont(font: Font): void;
		/** Gets the current Font object.
		 * @see https://love2d.org/wiki/love.graphics.getFont
		 */
		getFont(): Font;
		/** Draws text on screen. If no Font is set, one will be created and set (once) if needed.
		 * @see https://love2d.org/wiki/love.graphics.print
		 */
		print(text: string | number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/** Draws formatted text, with word wrap and alignment.
		 * @see https://love2d.org/wiki/love.graphics.printf
		 */
		printf(text: string | number, x: number, y: number, limit: number, align?: AlignMode, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/** Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally generates or specifies mipmaps for the image.
		 * @see https://love2d.org/wiki/love.graphics.newImage
		 */
		newImage(filename: string, settings?: ImageSettings): Image;
		newImage(data: FileData, settings?: CompressedImageSettings): Image;
		newImage(data: ImageData, settings?: ImageSettings): Image;
		newImage(data: CompressedImageData, settings?: CompressedImageSettings): Image;
		/** Creates a new drawable Video. Currently only Ogg Theora video files are supported.
		 * @see https://love2d.org/wiki/love.graphics.newVideo
		 */
		newVideo(filename: string, settings?: {audio?: boolean; dpiscale?: number}): Video;
		newVideo(stream: VideoStream, settings?: {audio?: boolean; dpiscale?: number}): Video;
		_newVideo(filenameOrStream: string | VideoStream, dpiScale?: number): Video;
		/** Creates a new array Image.
		 * @see https://love2d.org/wiki/love.graphics.newArrayImage
		 */
		newArrayImage(layers: ImageData[], settings?: LayeredImageSettings): Image;
		/** Creates a new cubemap Image.
		 * @see https://love2d.org/wiki/love.graphics.newCubeImage
		 */
		newCubeImage(faces: [ImageData, ImageData, ImageData, ImageData, ImageData, ImageData], settings?: LayeredImageSettings): Image;
		/** Creates a new volume (3D) Image.
		 * @see https://love2d.org/wiki/love.graphics.newVolumeImage
		 */
		newVolumeImage(slices: ImageData[], settings?: LayeredImageSettings): Image;
		/** Creates a new Canvas object for offscreen rendering.
		 * @see https://love2d.org/wiki/love.graphics.newCanvas
		 */
		newCanvas(width?: number, height?: number, settings?: CanvasSettings): Canvas;
		/** Gets the available Canvas formats, and whether each is supported.
		 * @see https://love2d.org/wiki/love.graphics.getCanvasFormats
		 */
		getCanvasFormats(readable?: boolean, formats?: CanvasFormats): CanvasFormats;
		/** Captures drawing operations to a Canvas.
		 * @see https://love2d.org/wiki/love.graphics.setCanvas
		 */
		setCanvas(): void;
		setCanvas(canvas: Canvas, ...canvases: Canvas[]): void;
		setCanvas(canvases: Canvas[]): void;
		setCanvas(setup: CanvasSetup): void;
		/** Gets the current target Canvas.
		 * @see https://love2d.org/wiki/love.graphics.getCanvas
		 */
		getCanvas(): Canvas | LuaMultiReturn<[Canvas, ...Canvas[]]> | CanvasSetup | undefined;
		/** Creates a new Quad.
		 * @see https://love2d.org/wiki/love.graphics.newQuad
		 */
		newQuad(x: number, y: number, width: number, height: number, image: Image | Canvas): Quad;
		newQuad(x: number, y: number, width: number, height: number, textureWidth: number, textureHeight: number): Quad;
		/** Creates a new Mesh.
		 * @see https://love2d.org/wiki/love.graphics.newMesh
		 */
		newMesh(vertices: MeshVertex[] | number, drawMode?: MeshDrawMode, usage?: MeshUsage): Mesh;
		newMesh(format: MeshVertexFormat[], vertices: MeshVertex[] | number | Data, drawMode?: MeshDrawMode, usage?: MeshUsage): Mesh;
		/** Creates a new SpriteBatch object.
		 * @see https://love2d.org/wiki/love.graphics.newSpriteBatch
		 */
		newSpriteBatch(texture: Image | Canvas, size?: number, usage?: MeshUsage): SpriteBatch;
		/** Creates a new ParticleSystem.
		 * @see https://love2d.org/wiki/love.graphics.newParticleSystem
		 */
		newParticleSystem(texture: Image | Canvas, size?: number): ParticleSystem;
		/** Creates a new Shader object for hardware-accelerated vertex and pixel effects. A Shader contains either vertex shader code, pixel shader code, or both.
		 * @see https://love2d.org/wiki/love.graphics.newShader
		 */
		newShader(source: ShaderSource, pixelSource?: ShaderSource): Shader;
		/** Validates shader code. Check if specified shader code does not contain any errors.
		 * @see https://love2d.org/wiki/love.graphics.validateShader
		 */
		validateShader(gles: boolean, source: ShaderSource, pixelSource?: ShaderSource): LuaMultiReturn<[boolean, string?]>;
		/** Sets or resets a Shader as the current pixel effect or vertex shaders. All drawing operations until the next ''love.graphics.setShader'' will be drawn using the Shader object specified.
		 * @see https://love2d.org/wiki/love.graphics.setShader
		 */
		setShader(shader?: Shader): void;
		/** Gets the current Shader. Returns nil if none is set.
		 * @see https://love2d.org/wiki/love.graphics.getShader
		 */
		getShader(): Shader | undefined;
		/** Draws a Drawable object (an Image, Canvas, SpriteBatch, ParticleSystem, Mesh, Text object, or Video) on the screen with optional rotation, scaling and shearing.
		 * @see https://love2d.org/wiki/love.graphics.draw
		 */
		draw(image: Image, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(image: Image, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		/** Draws a layer of an Array Texture.
		 * @see https://love2d.org/wiki/love.graphics.drawLayer
		 */
		drawLayer(image: Image, layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		drawLayer(image: Image, layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(canvas: Canvas, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(canvas: Canvas, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(mesh: Mesh, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/** Draws many instances of a Mesh with a single draw call, using hardware geometry instancing.
		 * @see https://love2d.org/wiki/love.graphics.drawInstanced
		 */
		drawInstanced(mesh: Mesh, instanceCount: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		draw(batch: SpriteBatch, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		draw(particles: ParticleSystem, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		draw(text: Text, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		draw(video: Video, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		}

	interface WindowMode {
		fullscreen: boolean;
		display: number;
		highdpi: boolean;
		resizable: boolean;
	}
	interface WindowModeSettings {
		fullscreen?: boolean;
		display?: number;
		highdpi?: boolean;
		resizable?: boolean;
	}
	interface WindowSize {
		width: number;
		height: number;
	}

	/** @noSelf */
	/** Provides an interface for modifying and retrieving information about the program's window.
	 * @see https://love2d.org/wiki/love.window
	 */
	interface Window {
		/** Gets the width and height of the desktop.
		 * @see https://love2d.org/wiki/love.window.getDesktopDimensions
		 */
		getDesktopDimensions(display?: number): LuaMultiReturn<[number, number]>;
		/** Gets the number of connected monitors.
		 * @see https://love2d.org/wiki/love.window.getDisplayCount
		 */
		getDisplayCount(): number;
		/** Gets the name of a display.
		 * @see https://love2d.org/wiki/love.window.getDisplayName
		 */
		getDisplayName(display: number): string;
		/** Gets current device display orientation.
		 * @see https://love2d.org/wiki/love.window.getDisplayOrientation
		 */
		getDisplayOrientation(display?: number): "unknown" | "landscape" | "portrait" | "landscapeflipped" | "portraitflipped";
		/** Gets a list of supported fullscreen modes.
		 * @see https://love2d.org/wiki/love.window.getFullscreenModes
		 */
		getFullscreenModes(display?: number): WindowSize[];
		/** Enters or exits fullscreen. The display to use when entering fullscreen is chosen based on which display the window is currently in, if multiple monitors are connected.
		 * @see https://love2d.org/wiki/love.window.setFullscreen
		 */
		setFullscreen(fullscreen: boolean, type?: "desktop" | "exclusive"): boolean;
		/** Gets whether the window is fullscreen.
		 * @see https://love2d.org/wiki/love.window.getFullscreen
		 */
		getFullscreen(): LuaMultiReturn<[boolean, "desktop" | "exclusive"]>;
		/** Checks if the window is open.
		 * @see https://love2d.org/wiki/love.window.isOpen
		 */
		isOpen(): boolean;
		/** Gets the window icon.
		 * @see https://love2d.org/wiki/love.window.getIcon
		 */
		getIcon(): ImageData | undefined;
		/** Gets the display mode and properties of the window.
		 * @see https://love2d.org/wiki/love.window.getMode
		 */
		getMode(): LuaMultiReturn<[number, number, WindowMode]>;
		/** Sets the display mode and properties of the window.
		 * @see https://love2d.org/wiki/love.window.setMode
		 */
		setMode(width: number, height: number, settings?: WindowModeSettings): boolean;
		/** Sets the display mode and properties of the window, without modifying unspecified properties.
		 * @see https://love2d.org/wiki/love.window.updateMode
		 */
		updateMode(settings: WindowModeSettings): boolean;
		updateMode(width: number, height: number, settings?: WindowModeSettings): boolean;
		/** Gets the position of the window on the screen.
		 * @see https://love2d.org/wiki/love.window.getPosition
		 */
		getPosition(): LuaMultiReturn<[number, number, number]>;
		/** Gets area inside the window which is known to be unobstructed by a system title bar, the iPhone X notch, etc. Useful for making sure UI elements can be seen by the user.
		 * @see https://love2d.org/wiki/love.window.getSafeArea
		 */
		getSafeArea(): LuaMultiReturn<[number, number, number, number]>;
		/** Sets the window title.
		 * @see https://love2d.org/wiki/love.window.setTitle
		 */
		setTitle(title: string): void;
		/** Gets the window title.
		 * @see https://love2d.org/wiki/love.window.getTitle
		 */
		getTitle(): string;
		/** Sets vertical synchronization mode.
		 * @see https://love2d.org/wiki/love.window.setVSync
		 */
		setVSync(vsync: boolean | number): void;
		/** Gets current vertical synchronization (vsync).
		 * @see https://love2d.org/wiki/love.window.getVSync
		 */
		getVSync(): number;
		/** Sets whether the display is allowed to sleep while the program is running.
		 * @see https://love2d.org/wiki/love.window.setDisplaySleepEnabled
		 */
		setDisplaySleepEnabled(enabled: boolean): void;
		/** Gets whether the display is allowed to sleep while the program is running.
		 * @see https://love2d.org/wiki/love.window.isDisplaySleepEnabled
		 */
		isDisplaySleepEnabled(): boolean;
		/** Checks if the game window has keyboard focus.
		 * @see https://love2d.org/wiki/love.window.hasFocus
		 */
		hasFocus(): boolean;
		/** Checks if the game window has mouse focus.
		 * @see https://love2d.org/wiki/love.window.hasMouseFocus
		 */
		hasMouseFocus(): boolean;
		/** Checks if the game window is visible.
		 * @see https://love2d.org/wiki/love.window.isVisible
		 */
		isVisible(): boolean;
		/** Gets whether the Window is currently maximized.
		 * @see https://love2d.org/wiki/love.window.isMaximized
		 */
		isMaximized(): boolean;
		/** Gets whether the Window is currently minimized.
		 * @see https://love2d.org/wiki/love.window.isMinimized
		 */
		isMinimized(): boolean;
		/** Gets the DPI scale factor associated with the window.
		 * @see https://love2d.org/wiki/love.window.getDPIScale
		 */
		getDPIScale(): number;
		getNativeDPIScale(): number;
		/** Converts a number from density-independent units to pixels.
		 * @see https://love2d.org/wiki/love.window.toPixels
		 */
		toPixels(value: number): number;
		toPixels(x: number, y: number): LuaMultiReturn<[number, number]>;
		/** Converts a number from pixels to density-independent units.
		 * @see https://love2d.org/wiki/love.window.fromPixels
		 */
		fromPixels(value: number): number;
		fromPixels(x: number, y: number): LuaMultiReturn<[number, number]>;
	}

	/** @noSelf */
	/** Manages events, like keypresses.
	 * @see https://love2d.org/wiki/love.event
	 */
	interface Event {
		/** Dora 已统一接管平台事件泵；此调用不会额外读取操作系统队列。 */
		/** Pump events into the event queue.
		 * @see https://love2d.org/wiki/love.event.pump
		 */
		pump(): void;
		/** Returns an iterator for messages in the event queue.
		 * @see https://love2d.org/wiki/love.event.poll
		 */
		poll(): () => LuaMultiReturn<[string, ...unknown[]] | []>;
		/** 嵌入实例队列为空时立即返回，不阻塞 Dora 主线程。 */
		/** Like love.event.poll(), but blocks until there is an event in the queue.
		 * @see https://love2d.org/wiki/love.event.wait
		 */
		wait(): LuaMultiReturn<[string, ...unknown[]] | []>;
		/** Adds an event to the event queue.
		 * @see https://love2d.org/wiki/love.event.push
		 */
		push(name: string, ...args: (boolean | number | string | LuaUserdata | undefined)[]): boolean;
		/** Clears the event queue.
		 * @see https://love2d.org/wiki/love.event.clear
		 */
		clear(): void;
		/** 请求只停止当前嵌入式 Love 实例。 */
		/** Adds the quit event to the queue.
		 * @see https://love2d.org/wiki/love.event.quit
		 */
		quit(exitStatus?: number): true;
		quit(reason: "restart"): true;
	}

	type FileType = "file" | "directory";
	type FileMode = "c" | "r" | "w" | "a";
	type OpenFileMode = "r" | "w" | "a";
	type BufferMode = "none" | "line" | "full";
	/** The superclass of all data.
	 * @see https://love2d.org/wiki/Data
	 */
	interface Data extends Object {
		/** Gets the full Data as a string.
		 * @see https://love2d.org/wiki/Data:getString
		 */
		getString(): string;
		/** Gets the Data's size in bytes.
		 * @see https://love2d.org/wiki/Data:getSize
		 */
		getSize(): number;
		/** Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
		 * @see https://love2d.org/wiki/Data:getPointer
		 */
		getPointer(): LuaUserdata;
		/** Gets an FFI pointer to the Data.
		 * @see https://love2d.org/wiki/Data:getFFIPointer
		 */
		getFFIPointer(): undefined;
	}
	/** Data object containing arbitrary bytes in an contiguous memory.
	 * @see https://love2d.org/wiki/ByteData
	 */
	interface ByteData extends Data { clone(): ByteData; }
	interface DataView extends Data { clone(): DataView; }
	/** Represents byte data compressed using a specific algorithm.
	 * @see https://love2d.org/wiki/CompressedData
	 */
	interface CompressedData extends Data {
		/** Creates a new copy of the Data object.
		 * @see https://love2d.org/wiki/Data:clone
		 */
		clone(): CompressedData;
		/** Gets the compression format of the CompressedData.
		 * @see https://love2d.org/wiki/CompressedData:getFormat
		 */
		getFormat(): "zlib" | "gzip" | "deflate" | "lz4";
	}
	type DataContainer = "data" | "string";
	type EncodeFormat = "hex" | "base64";
	type CompressionFormat = "zlib" | "gzip" | "deflate" | "lz4";
	type HashFunction = "md5" | "sha1" | "sha224" | "sha256" | "sha384" | "sha512";
	/** @noSelf */
	/** Provides functionality for creating and transforming data.
	 * @see https://love2d.org/wiki/love.data
	 */
	interface DataModule {
		/** Creates a new Data object containing arbitrary bytes.
		 * @see https://love2d.org/wiki/love.data.newByteData
		 */
		newByteData(size: number): ByteData;
		newByteData(bytes: string): ByteData;
		newByteData(data: Data, offset?: number, size?: number): ByteData;
		/** Creates a new Data referencing a subsection of an existing Data object.
		 * @see https://love2d.org/wiki/love.data.newDataView
		 */
		newDataView(data: Data, offset: number, size: number): DataView;
		/** Encode Data or a string to a Data or string in one of the EncodeFormats.
		 * @see https://love2d.org/wiki/love.data.encode
		 */
		encode(container: "string", format: EncodeFormat, source: string | Data, lineLength?: number): string;
		encode(container: "data", format: EncodeFormat, source: string | Data, lineLength?: number): ByteData;
		/** Decode Data or a string from any of the EncodeFormats to Data or string.
		 * @see https://love2d.org/wiki/love.data.decode
		 */
		decode(container: "string", format: EncodeFormat, source: string | Data): string;
		decode(container: "data", format: EncodeFormat, source: string | Data): ByteData;
		/** Compresses a string or data using a specific compression algorithm.
		 * @see https://love2d.org/wiki/love.data.compress
		 */
		compress(container: "string", format: CompressionFormat, source: string | Data, level?: number): string;
		compress(container: "data", format: CompressionFormat, source: string | Data, level?: number): CompressedData;
		/** Decompresses a CompressedData or previously compressed string or Data object.
		 * @see https://love2d.org/wiki/love.data.decompress
		 */
		decompress(container: "string", compressed: CompressedData): string;
		decompress(container: "data", compressed: CompressedData): ByteData;
		decompress(container: "string", format: CompressionFormat, source: string | Data): string;
		decompress(container: "data", format: CompressionFormat, source: string | Data): ByteData;
		/** Packs (serializes) simple Lua values.
		 * @see https://love2d.org/wiki/love.data.pack
		 */
		pack(container: "string", format: string, ...values: any[]): string;
		pack(container: "data", format: string, ...values: any[]): ByteData;
		/** Unpacks (deserializes) a byte-string or Data into simple Lua values.
		 * @see https://love2d.org/wiki/love.data.unpack
		 */
		unpack(format: string, source: string | Data, position?: number): LuaMultiReturn<any[]>;
		/** Gets the size in bytes that a given format used with love.data.pack will use.
		 * @see https://love2d.org/wiki/love.data.getPackedSize
		 */
		getPackedSize(format: string): number;
		/** Compute the message digest of a string using a specified hash algorithm.
		 * @see https://love2d.org/wiki/love.data.hash
		 */
		hash(hashFunction: HashFunction, source: string | Data): string;
	}
	/** Data representing the contents of a file.
	 * @see https://love2d.org/wiki/FileData
	 */
	interface FileData extends Data {
		/** Creates a new copy of the Data object.
		 * @see https://love2d.org/wiki/Data:clone
		 */
		clone(): FileData;
		/** Gets the filename of the FileData.
		 * @see https://love2d.org/wiki/FileData:getFilename
		 */
		getFilename(): string;
		/** Gets the extension of the FileData.
		 * @see https://love2d.org/wiki/FileData:getExtension
		 */
		getExtension(): string;
	}
	/** Raw (decoded) image data.
	 * @see https://love2d.org/wiki/ImageData
	 */
	interface ImageData extends Data {
		/** Gets the type of the object as a string.
		 * @see https://love2d.org/wiki/Object:type
		 */
		type(): "ImageData";
		/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 * @see https://love2d.org/wiki/Object:typeOf
		 */
		typeOf(typeName: string): boolean;
		/** Creates a new copy of the Data object.
		 * @see https://love2d.org/wiki/Data:clone
		 */
		clone(): ImageData;
		/** Gets the width of the ImageData in pixels.
		 * @see https://love2d.org/wiki/ImageData:getWidth
		 */
		getWidth(): number;
		/** Gets the height of the ImageData in pixels.
		 * @see https://love2d.org/wiki/ImageData:getHeight
		 */
		getHeight(): number;
		/** Gets the width and height of the ImageData in pixels.
		 * @see https://love2d.org/wiki/ImageData:getDimensions
		 */
		getDimensions(): LuaMultiReturn<[number, number]>;
		/** Gets the pixel format of the ImageData.
		 * @see https://love2d.org/wiki/ImageData:getFormat
		 */
		getFormat(): ImagePixelFormat;
		/** Gets the color of a pixel at a specific position in the image.
		 * @see https://love2d.org/wiki/ImageData:getPixel
		 */
		getPixel(x: number, y: number): LuaMultiReturn<[number, number, number, number]>;
		/** Sets the color of a pixel at a specific position in the image.
		 * @see https://love2d.org/wiki/ImageData:setPixel
		 */
		setPixel(x: number, y: number, red: number, green: number, blue: number, alpha?: number): void;
		/** Transform an image by applying a function to every pixel.
		 * @see https://love2d.org/wiki/ImageData:mapPixel
		 */
		mapPixel(mapper: (x: number, y: number, red: number, green: number, blue: number, alpha: number) => LuaMultiReturn<[number, number, number, number]>, x?: number, y?: number, width?: number, height?: number): void;
		/** Paste into ImageData from another source ImageData.
		 * @see https://love2d.org/wiki/ImageData:paste
		 */
		paste(source: ImageData, destinationX: number, destinationY: number, sourceX?: number, sourceY?: number, sourceWidth?: number, sourceHeight?: number): void;
		/** Encodes the ImageData and optionally writes it to the save directory.
		 * @see https://love2d.org/wiki/ImageData:encode
		 */
		encode(format: "png" | "tga", filename?: string): FileData;
	}
	/** Represents compressed image data designed to stay compressed in RAM.
	 * @see https://love2d.org/wiki/CompressedImageData
	 */
	interface CompressedImageData extends Data {
		/** Gets the type of the object as a string.
		 * @see https://love2d.org/wiki/Object:type
		 */
		type(): "CompressedImageData";
		/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 * @see https://love2d.org/wiki/Object:typeOf
		 */
		typeOf(typeName: string): boolean;
		/** Creates a new copy of the Data object.
		 * @see https://love2d.org/wiki/Data:clone
		 */
		clone(): CompressedImageData;
		/** Gets the width of the CompressedImageData.
		 * @see https://love2d.org/wiki/CompressedImageData:getWidth
		 */
		getWidth(mipmap?: number): number;
		/** Gets the height of the CompressedImageData.
		 * @see https://love2d.org/wiki/CompressedImageData:getHeight
		 */
		getHeight(mipmap?: number): number;
		/** Gets the width and height of the CompressedImageData.
		 * @see https://love2d.org/wiki/CompressedImageData:getDimensions
		 */
		getDimensions(mipmap?: number): LuaMultiReturn<[number, number]>;
		/** Gets the number of mipmap levels in the CompressedImageData. The base mipmap level (original image) is included in the count.
		 * @see https://love2d.org/wiki/CompressedImageData:getMipmapCount
		 */
		getMipmapCount(): number;
		/** Gets the format of the CompressedImageData.
		 * @see https://love2d.org/wiki/CompressedImageData:getFormat
		 */
		getFormat(): CompressedPixelFormat;
	}
	/** @noSelf */
	/** Provides an interface to decode encoded image data.
	 * @see https://love2d.org/wiki/love.image
	 */
	interface ImageModule {
		/** Creates a new ImageData object.
		 * @see https://love2d.org/wiki/love.image.newImageData
		 */
		newImageData(width: number, height: number, format?: ImagePixelFormat, data?: string | FileData): ImageData;
		newImageData(filename: string): ImageData;
		newImageData(data: FileData): ImageData;
		/** Create a new CompressedImageData object from a compressed image file. LÖVE supports several compressed texture formats, enumerated in the CompressedImageFormat page.
		 * @see https://love2d.org/wiki/love.image.newCompressedData
		 */
		newCompressedData(filenameOrData: string | Data): CompressedImageData;
		/** Determines whether a file can be loaded as CompressedImageData.
		 * @see https://love2d.org/wiki/love.image.isCompressed
		 */
		isCompressed(filenameOrData: string | Data): boolean;
	}
	/** A Rasterizer handles font rendering, containing the font data (image or TrueType font) and drawable glyphs.
	 * @see https://love2d.org/wiki/Rasterizer
	 */
	interface Rasterizer extends Object {
		/** Gets the type of the object as a string.
		 * @see https://love2d.org/wiki/Object:type
		 */
		type(): "Rasterizer";
		/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 * @see https://love2d.org/wiki/Object:typeOf
		 */
		typeOf(typeName: string): boolean;
		/** Gets font height.
		 * @see https://love2d.org/wiki/Rasterizer:getHeight
		 */
		getHeight(): number;
		/** Gets font advance.
		 * @see https://love2d.org/wiki/Rasterizer:getAdvance
		 */
		getAdvance(): number;
		/** Gets ascent height.
		 * @see https://love2d.org/wiki/Rasterizer:getAscent
		 */
		getAscent(): number;
		/** Gets descent height.
		 * @see https://love2d.org/wiki/Rasterizer:getDescent
		 */
		getDescent(): number;
		/** Gets line height of a font.
		 * @see https://love2d.org/wiki/Rasterizer:getLineHeight
		 */
		getLineHeight(): number;
		/** Gets glyph data of a specified glyph.
		 * @see https://love2d.org/wiki/Rasterizer:getGlyphData
		 */
		getGlyphData(glyph: string | number): GlyphData;
		/** Gets number of glyphs in font.
		 * @see https://love2d.org/wiki/Rasterizer:getGlyphCount
		 */
		getGlyphCount(): number;
		/** Checks if font contains specified glyphs.
		 * @see https://love2d.org/wiki/Rasterizer:hasGlyphs
		 */
		hasGlyphs(...glyphs: (string | number)[]): boolean;
	}
	/** A GlyphData represents a drawable symbol of a font Rasterizer.
	 * @see https://love2d.org/wiki/GlyphData
	 */
	interface GlyphData extends Data {
		/** Gets the type of the object as a string.
		 * @see https://love2d.org/wiki/Object:type
		 */
		type(): "GlyphData";
		/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 * @see https://love2d.org/wiki/Object:typeOf
		 */
		typeOf(typeName: string): boolean;
		/** Creates a new copy of the Data object.
		 * @see https://love2d.org/wiki/Data:clone
		 */
		clone(): GlyphData;
		/** Gets glyph width.
		 * @see https://love2d.org/wiki/GlyphData:getWidth
		 */
		getWidth(): number;
		/** Gets glyph height.
		 * @see https://love2d.org/wiki/GlyphData:getHeight
		 */
		getHeight(): number;
		/** Gets glyph dimensions.
		 * @see https://love2d.org/wiki/GlyphData:getDimensions
		 */
		getDimensions(): LuaMultiReturn<[number, number]>;
		/** Gets glyph number.
		 * @see https://love2d.org/wiki/GlyphData:getGlyph
		 */
		getGlyph(): number;
		/** Gets glyph string.
		 * @see https://love2d.org/wiki/GlyphData:getGlyphString
		 */
		getGlyphString(): string;
		/** Gets glyph advance.
		 * @see https://love2d.org/wiki/GlyphData:getAdvance
		 */
		getAdvance(): number;
		/** Gets glyph bearing.
		 * @see https://love2d.org/wiki/GlyphData:getBearing
		 */
		getBearing(): LuaMultiReturn<[number, number]>;
		/** Gets glyph bounding box.
		 * @see https://love2d.org/wiki/GlyphData:getBoundingBox
		 */
		getBoundingBox(): LuaMultiReturn<[number, number, number, number]>;
		/** Gets glyph pixel format.
		 * @see https://love2d.org/wiki/GlyphData:getFormat
		 */
		getFormat(): "rgba8";
	}
	/** @noSelf */
	/** Allows you to work with fonts.
	 * @see https://love2d.org/wiki/love.font
	 */
	interface FontModule {
		/** Creates a new Image Rasterizer.
		 * @see https://love2d.org/wiki/love.font.newImageRasterizer
		 */
		newImageRasterizer(imageData: ImageData, glyphs: string, extraSpacing?: number, dpiScale?: number): Rasterizer;
		/** Creates a new BMFont Rasterizer.
		 * @see https://love2d.org/wiki/love.font.newBMFontRasterizer
		 */
		newBMFontRasterizer(filenameOrFileData: string | FileData, images?: ImageData | string | FileData | (ImageData | string | FileData)[], dpiScale?: number): Rasterizer;
		/** Creates a new TrueType Rasterizer.
		 * @see https://love2d.org/wiki/love.font.newTrueTypeRasterizer
		 */
		newTrueTypeRasterizer(size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		newTrueTypeRasterizer(filenameOrData: string | Data, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		/** Creates a new Rasterizer.
		 * @see https://love2d.org/wiki/love.font.newRasterizer
		 */
		newRasterizer(size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		newRasterizer(filenameOrData: string | Data, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		/** Creates a new GlyphData.
		 * @see https://love2d.org/wiki/love.font.newGlyphData
		 */
		newGlyphData(rasterizer: Rasterizer, glyph: string | number): GlyphData;
	}
	/** Contains raw audio samples.
	 * @see https://love2d.org/wiki/SoundData
	 */
	interface SoundData extends Data {
		/** Creates a new copy of the Data object.
		 * @see https://love2d.org/wiki/Data:clone
		 */
		clone(): SoundData;
		/** Returns the number of channels in the SoundData.
		 * @see https://love2d.org/wiki/SoundData:getChannelCount
		 */
		getChannelCount(): number;
		/** Love 对 getChannelCount 的弃用别名。 */
		getChannels(): number;
		/** Returns the number of bits per sample.
		 * @see https://love2d.org/wiki/SoundData:getBitDepth
		 */
		getBitDepth(): 8 | 16;
		/** Returns the sample rate of the SoundData.
		 * @see https://love2d.org/wiki/SoundData:getSampleRate
		 */
		getSampleRate(): number;
		/** Returns the number of samples per channel of the SoundData.
		 * @see https://love2d.org/wiki/SoundData:getSampleCount
		 */
		getSampleCount(): number;
		/** Gets the duration of the sound data.
		 * @see https://love2d.org/wiki/SoundData:getDuration
		 */
		getDuration(): number;
		/** Gets the value of the sample-point at the specified position. For stereo SoundData objects, the data from the left and right channels are interleaved in that order.
		 * @see https://love2d.org/wiki/SoundData:getSample
		 */
		getSample(index: number, channel?: number): number;
		/** Sets the value of the sample-point at the specified position. For stereo SoundData objects, the data from the left and right channels are interleaved in that order.
		 * @see https://love2d.org/wiki/SoundData:setSample
		 */
		setSample(index: number, sample: number): void;
		setSample(index: number, channel: number, sample: number): void;
	}
	/** An object which can gradually decode a sound file.
	 * @see https://love2d.org/wiki/Decoder
	 */
	interface Decoder extends Object {
		/** Creates a new copy of current decoder.
		 * @see https://love2d.org/wiki/Decoder:clone
		 */
		clone(): Decoder;
		/** Returns the number of channels in the stream.
		 * @see https://love2d.org/wiki/Decoder:getChannelCount
		 */
		getChannelCount(): number;
		/** 已弃用的 getChannelCount Love 别名。 */
		getChannels(): number;
		/** Returns the number of bits per sample.
		 * @see https://love2d.org/wiki/Decoder:getBitDepth
		 */
		getBitDepth(): 16;
		/** Returns the sample rate of the Decoder.
		 * @see https://love2d.org/wiki/Decoder:getSampleRate
		 */
		getSampleRate(): number;
		/** Gets the duration of the sound file. It may not always be sample-accurate, and it may return -1 if the duration cannot be determined at all.
		 * @see https://love2d.org/wiki/Decoder:getDuration
		 */
		getDuration(): number;
		/** Decodes the audio and returns a SoundData object containing the decoded audio data.
		 * @see https://love2d.org/wiki/Decoder:decode
		 */
		decode(): SoundData | undefined;
		/** Sets the currently playing position of the Decoder.
		 * @see https://love2d.org/wiki/Decoder:seek
		 */
		seek(offset: number): void;
	}
	/** @noSelf */
	/** This module is responsible for decoding sound files. It can't play the sounds, see love.audio for that.
	 * @see https://love2d.org/wiki/love.sound
	 */
	interface SoundModule {
		/** Attempts to find a decoder for the encoded sound data in the specified file.
		 * @see https://love2d.org/wiki/love.sound.newDecoder
		 */
		newDecoder(filename: string, bufferSize?: number): Decoder;
		newDecoder(data: FileData, bufferSize?: number): Decoder;
		/** Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a custom sample rate, channel and bit depth.
		 * @see https://love2d.org/wiki/love.sound.newSoundData
		 */
		newSoundData(samples: number, sampleRate?: number, bitDepth?: 8 | 16, channels?: number): SoundData;
		newSoundData(filename: string, bufferSize?: number): SoundData;
		newSoundData(data: FileData, bufferSize?: number): SoundData;
		newSoundData(decoder: Decoder): SoundData;
	}
	/** A random number generation object which has its own random state.
	 * @see https://love2d.org/wiki/RandomGenerator
	 */
	interface RandomGenerator extends Object {
		/** Generates a pseudo-random number in a platform independent manner.
		 * @see https://love2d.org/wiki/RandomGenerator:random
		 */
		random(): number;
		random(upper: number): number;
		random(lower: number, upper: number): number;
		/** Get a normally distributed pseudo random number.
		 * @see https://love2d.org/wiki/RandomGenerator:randomNormal
		 */
		randomNormal(standardDeviation?: number, mean?: number): number;
		/** Sets the seed of the random number generator using the specified integer number.
		 * @see https://love2d.org/wiki/RandomGenerator:setSeed
		 */
		setSeed(seed: number): void;
		setSeed(low: number, high: number): void;
		/** Gets the seed of the random number generator object.
		 * @see https://love2d.org/wiki/RandomGenerator:getSeed
		 */
		getSeed(): LuaMultiReturn<[number, number]>;
		/** Sets the current state of the random number generator. The value used as an argument for this function is an opaque string and should only originate from a previous call to RandomGenerator:getState in the same major version of LÖVE.
		 * @see https://love2d.org/wiki/RandomGenerator:setState
		 */
		setState(state: string): void;
		/** Gets the current state of the random number generator. This returns an opaque string which is only useful for later use with RandomGenerator:setState in the same major version of LÖVE.
		 * @see https://love2d.org/wiki/RandomGenerator:getState
		 */
		getState(): string;
	}
	/** Object containing a coordinate system transformation.
	 * @see https://love2d.org/wiki/Transform
	 */
	interface Transform extends Object {
		/** Creates a new copy of this Transform.
		 * @see https://love2d.org/wiki/Transform:clone
		 */
		clone(): Transform;
		/** Creates a new Transform containing the inverse of this Transform.
		 * @see https://love2d.org/wiki/Transform:inverse
		 */
		inverse(): Transform;
		/** Applies the given other Transform object to this one.
		 * @see https://love2d.org/wiki/Transform:apply
		 */
		apply(other: Transform): Transform;
		/** Checks whether the Transform is an affine transformation.
		 * @see https://love2d.org/wiki/Transform:isAffine2DTransform
		 */
		isAffine2DTransform(): boolean;
		/** Applies a translation to the Transform's coordinate system. This method does not reset any previously applied transformations.
		 * @see https://love2d.org/wiki/Transform:translate
		 */
		translate(x: number, y: number): Transform;
		/** Applies a rotation to the Transform's coordinate system. This method does not reset any previously applied transformations.
		 * @see https://love2d.org/wiki/Transform:rotate
		 */
		rotate(angle: number): Transform;
		/** Scales the Transform's coordinate system. This method does not reset any previously applied transformations.
		 * @see https://love2d.org/wiki/Transform:scale
		 */
		scale(x: number, y?: number): Transform;
		/** Applies a shear factor (skew) to the Transform's coordinate system. This method does not reset any previously applied transformations.
		 * @see https://love2d.org/wiki/Transform:shear
		 */
		shear(x: number, y: number): Transform;
		/** Resets the Transform to an identity state. All previously applied transformations are erased.
		 * @see https://love2d.org/wiki/Transform:reset
		 */
		reset(): Transform;
		/** Resets the Transform to the specified transformation parameters.
		 * @see https://love2d.org/wiki/Transform:setTransformation
		 */
		setTransformation(x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): Transform;
		/** Directly sets the Transform's internal 4x4 transformation matrix.
		 * @see https://love2d.org/wiki/Transform:setMatrix
		 */
		setMatrix(layout: "row" | "column", elements: number[] | number[][]): Transform;
		setMatrix(elements: number[] | number[][]): Transform;
		/** Gets the internal 4x4 transformation matrix stored by this Transform. The matrix is returned in row-major order.
		 * @see https://love2d.org/wiki/Transform:getMatrix
		 */
		getMatrix(): LuaMultiReturn<[number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number]>;
		/** Applies the Transform object's transformation to the given 2D position.
		 * @see https://love2d.org/wiki/Transform:transformPoint
		 */
		transformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/** Applies the reverse of the Transform object's transformation to the given 2D position.
		 * @see https://love2d.org/wiki/Transform:inverseTransformPoint
		 */
		inverseTransformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
	}
	/** A Bézier curve object that can evaluate and render Bézier curves of arbitrary degree.
	 * @see https://love2d.org/wiki/BezierCurve
	 */
	interface BezierCurve extends Object {
		/** Get degree of the Bézier curve. The degree is equal to number-of-control-points - 1.
		 * @see https://love2d.org/wiki/BezierCurve:getDegree
		 */
		getDegree(): number;
		/** Get the derivative of the Bézier curve.
		 * @see https://love2d.org/wiki/BezierCurve:getDerivative
		 */
		getDerivative(): BezierCurve;
		/** Get coordinates of the i-th control point. Indices start with 1.
		 * @see https://love2d.org/wiki/BezierCurve:getControlPoint
		 */
		getControlPoint(index: number): LuaMultiReturn<[number, number]>;
		/** Set coordinates of the i-th control point. Indices start with 1.
		 * @see https://love2d.org/wiki/BezierCurve:setControlPoint
		 */
		setControlPoint(index: number, x: number, y: number): void;
		/** Insert control point as the new i-th control point. Existing control points from i onwards are pushed back by 1. Indices start with 1. Negative indices wrap around: -1 is the last control point, -2 the one before the last, etc.
		 * @see https://love2d.org/wiki/BezierCurve:insertControlPoint
		 */
		insertControlPoint(x: number, y: number, index?: number): void;
		/** Removes the specified control point.
		 * @see https://love2d.org/wiki/BezierCurve:removeControlPoint
		 */
		removeControlPoint(index: number): void;
		/** Get the number of control points in the Bézier curve.
		 * @see https://love2d.org/wiki/BezierCurve:getControlPointCount
		 */
		getControlPointCount(): number;
		/** Move the Bézier curve by an offset.
		 * @see https://love2d.org/wiki/BezierCurve:translate
		 */
		translate(x: number, y: number): void;
		/** Rotate the Bézier curve by an angle.
		 * @see https://love2d.org/wiki/BezierCurve:rotate
		 */
		rotate(angle: number, originX?: number, originY?: number): void;
		/** Scale the Bézier curve by a factor.
		 * @see https://love2d.org/wiki/BezierCurve:scale
		 */
		scale(scale: number, originX?: number, originY?: number): void;
		/** Evaluate Bézier curve at parameter t. The parameter must be between 0 and 1 (inclusive).
		 * @see https://love2d.org/wiki/BezierCurve:evaluate
		 */
		evaluate(time: number): LuaMultiReturn<[number, number]>;
		/** Gets a BezierCurve that corresponds to the specified segment of this BezierCurve.
		 * @see https://love2d.org/wiki/BezierCurve:getSegment
		 */
		getSegment(start: number, end: number): BezierCurve;
		/** Get a list of coordinates to be used with love.graphics.line.
		 * @see https://love2d.org/wiki/BezierCurve:render
		 */
		render(accuracy?: number): number[];
		/** Get a list of coordinates on a specific part of the curve, to be used with love.graphics.line.
		 * @see https://love2d.org/wiki/BezierCurve:renderSegment
		 */
		renderSegment(start: number, end: number, accuracy?: number): number[];
	}
	/** @noSelf */
	/** Provides system-independent mathematical functions.
	 * @see https://love2d.org/wiki/love.math
	 */
	interface MathModule {
		/** Creates a new RandomGenerator object which is completely independent of other RandomGenerator objects and random functions.
		 * @see https://love2d.org/wiki/love.math.newRandomGenerator
		 */
		newRandomGenerator(seed?: number): RandomGenerator;
		newRandomGenerator(low: number, high: number): RandomGenerator;
		/** Creates a new Transform object.
		 * @see https://love2d.org/wiki/love.math.newTransform
		 */
		newTransform(x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): Transform;
		/** Creates a new BezierCurve object.
		 * @see https://love2d.org/wiki/love.math.newBezierCurve
		 */
		newBezierCurve(vertices: number[]): BezierCurve;
		newBezierCurve(...coordinates: number[]): BezierCurve;
		/** Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same, given the same arguments.
		 * @see https://love2d.org/wiki/love.math.noise
		 */
		noise(x: number, y?: number, z?: number, w?: number): number;
		/** Deprecated alias of love.data.compress. */
		compress(container: "string", format: CompressionFormat, source: string | Data, level?: number): string;
		compress(container: "data", format: CompressionFormat, source: string | Data, level?: number): CompressedData;
		/** Deprecated alias of love.data.decompress. */
		decompress(container: "string", compressed: CompressedData): string;
		decompress(container: "data", compressed: CompressedData): ByteData;
		/** Generates a pseudo-random number in a platform independent manner. The default love.run seeds this function at startup, so you generally don't need to seed it yourself.
		 * @see https://love2d.org/wiki/love.math.random
		 */
		random(): number;
		random(upper: number): number;
		random(lower: number, upper: number): number;
		/** Get a normally distributed pseudo random number.
		 * @see https://love2d.org/wiki/love.math.randomNormal
		 */
		randomNormal(standardDeviation?: number, mean?: number): number;
		/** Sets the seed of the random number generator using the specified integer number. This is called internally at startup, so you generally don't need to call it yourself.
		 * @see https://love2d.org/wiki/love.math.setRandomSeed
		 */
		setRandomSeed(seed: number): void;
		setRandomSeed(low: number, high: number): void;
		/** Gets the seed of the random number generator.
		 * @see https://love2d.org/wiki/love.math.getRandomSeed
		 */
		getRandomSeed(): LuaMultiReturn<[number, number]>;
		/** Sets the current state of the random number generator. The value used as an argument for this function is an opaque implementation-dependent string and should only originate from a previous call to love.math.getRandomState.
		 * @see https://love2d.org/wiki/love.math.setRandomState
		 */
		setRandomState(state: string): void;
		/** Gets the current state of the random number generator. This returns an opaque implementation-dependent string which is only useful for later use with love.math.setRandomState or RandomGenerator:setState.
		 * @see https://love2d.org/wiki/love.math.getRandomState
		 */
		getRandomState(): string;
		/** Converts a color from 0..1 to 0..255 range.
		 * @see https://love2d.org/wiki/love.math.colorToBytes
		 */
		colorToBytes(red: number, green: number, blue: number, alpha?: number): LuaMultiReturn<[number, number, number, number?]>;
		colorToBytes(color: number[]): LuaMultiReturn<[number, number, number, number?]>;
		/** Converts a color from 0..255 to 0..1 range.
		 * @see https://love2d.org/wiki/love.math.colorFromBytes
		 */
		colorFromBytes(red: number, green: number, blue: number, alpha?: number): LuaMultiReturn<[number, number, number, number?]>;
		colorFromBytes(color: number[]): LuaMultiReturn<[number, number, number, number?]>;
		/** Converts a color from gamma-space (sRGB) to linear-space (RGB). This is useful when doing gamma-correct rendering and you need to do math in linear RGB in the few cases where LÖVE doesn't handle conversions automatically.
		 * @see https://love2d.org/wiki/love.math.gammaToLinear
		 */
		gammaToLinear(red: number, green?: number, blue?: number, alpha?: number): LuaMultiReturn<[number, number?, number?, number?]>;
		gammaToLinear(color: number[]): LuaMultiReturn<[number, number?, number?, number?]>;
		/** Converts a color from linear-space (RGB) to gamma-space (sRGB). This is useful when storing linear RGB color values in an image, because the linear RGB color space has less precision than sRGB for dark colors, which can result in noticeable color banding when drawing.
		 * @see https://love2d.org/wiki/love.math.linearToGamma
		 */
		linearToGamma(red: number, green?: number, blue?: number, alpha?: number): LuaMultiReturn<[number, number?, number?, number?]>;
		linearToGamma(color: number[]): LuaMultiReturn<[number, number?, number?, number?]>;
		/** Checks whether a polygon is convex.
		 * @see https://love2d.org/wiki/love.math.isConvex
		 */
		isConvex(vertices: number[]): boolean;
		isConvex(...coordinates: number[]): boolean;
		/** Decomposes a simple convex or concave polygon into triangles.
		 * @see https://love2d.org/wiki/love.math.triangulate
		 */
		triangulate(vertices: number[]): number[][];
		triangulate(...coordinates: number[]): number[][];
	}
	/** Represents a file on the filesystem. A function that takes a file path can also take a File.
	 * @see https://love2d.org/wiki/File
	 */
	interface File extends Object {
		/** Open the file for write, read or append.
		 * @see https://love2d.org/wiki/File:open
		 */
		open(mode: OpenFileMode): LuaMultiReturn<[true | undefined, string?]>;
		/** Closes a File.
		 * @see https://love2d.org/wiki/File:close
		 */
		close(): boolean;
		/** Gets whether the file is open.
		 * @see https://love2d.org/wiki/File:isOpen
		 */
		isOpen(): boolean;
		/** Returns the file size.
		 * @see https://love2d.org/wiki/File:getSize
		 */
		getSize(): LuaMultiReturn<[number | undefined, string?]>;
		/** Read a number of bytes from a file.
		 * @see https://love2d.org/wiki/File:read
		 */
		read(size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(container: "string", size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(container: "data", size?: number): LuaMultiReturn<[FileData | undefined, number | string]>;
		/** Write data to a file.
		 * @see https://love2d.org/wiki/File:write
		 */
		write(data: string | FileData, size?: number): LuaMultiReturn<[true | undefined, string?]>;
		/** Flushes any buffered written data in the file to the disk.
		 * @see https://love2d.org/wiki/File:flush
		 */
		flush(): LuaMultiReturn<[true | undefined, string?]>;
		/** Gets whether end-of-file has been reached.
		 * @see https://love2d.org/wiki/File:isEOF
		 */
		isEOF(): boolean;
		/** Returns the position in the file.
		 * @see https://love2d.org/wiki/File:tell
		 */
		tell(): LuaMultiReturn<[number | undefined, string?]>;
		/** Seek to a position in a file
		 * @see https://love2d.org/wiki/File:seek
		 */
		seek(position: number): boolean;
		/** Iterate over all the lines in a file.
		 * @see https://love2d.org/wiki/File:lines
		 */
		lines(): () => string | undefined;
		/** Sets the buffer mode for a file opened for writing or appending. Files with buffering enabled will not write data to the disk until the buffer size limit is reached, depending on the buffer mode.
		 * @see https://love2d.org/wiki/File:setBuffer
		 */
		setBuffer(mode: BufferMode, size?: number): boolean;
		/** Gets the buffer mode of a file.
		 * @see https://love2d.org/wiki/File:getBuffer
		 */
		getBuffer(): LuaMultiReturn<[BufferMode, number]>;
		/** Gets the FileMode the file has been opened with.
		 * @see https://love2d.org/wiki/File:getMode
		 */
		getMode(): FileMode;
		/** Gets the filename that the File object was created with. If the file object originated from the love.filedropped callback, the filename will be the full platform-dependent file path.
		 * @see https://love2d.org/wiki/File:getFilename
		 */
		getFilename(): string;
		getExtension(): string;
	}
	interface FileInfo {
		type: FileType;
		size?: number;
		modtime?: number;
	}
	/** @noSelf */
	/** Provides an interface to the user's filesystem.
	 * @see https://love2d.org/wiki/love.filesystem
	 */
	interface Filesystem {
		/** Sets the write directory for your game.
		 * @see https://love2d.org/wiki/love.filesystem.setIdentity
		 */
		setIdentity(identity: string, appendToPath?: boolean): void;
		/** Gets the write directory name for your game.
		 * @see https://love2d.org/wiki/love.filesystem.getIdentity
		 */
		getIdentity(): string;
		/** Returns the full path to the the .love file or directory. If the game is fused to the LÖVE executable, then the executable is returned.
		 * @see https://love2d.org/wiki/love.filesystem.getSource
		 */
		getSource(): string;
		/** Gets the full path to the designated save directory.
		 * @see https://love2d.org/wiki/love.filesystem.getSaveDirectory
		 */
		getSaveDirectory(): string;
		/** Gets the current working directory.
		 * @see https://love2d.org/wiki/love.filesystem.getWorkingDirectory
		 */
		getWorkingDirectory(): string;
		/** Returns the path of the user's directory
		 * @see https://love2d.org/wiki/love.filesystem.getUserDirectory
		 */
		getUserDirectory(): string;
		/** Returns the application data directory (could be the same as getUserDirectory)
		 * @see https://love2d.org/wiki/love.filesystem.getAppdataDirectory
		 */
		getAppdataDirectory(): string;
		/** Returns the full path to the directory containing the .love file. If the game is fused to the LÖVE executable, then the directory containing the executable is returned.
		 * @see https://love2d.org/wiki/love.filesystem.getSourceBaseDirectory
		 */
		getSourceBaseDirectory(): string;
		getExecutablePath(): string;
		/** Gets the platform-specific absolute path of the directory containing a filepath.
		 * @see https://love2d.org/wiki/love.filesystem.getRealDirectory
		 */
		getRealDirectory(filename: string): LuaMultiReturn<[string | undefined, string?]>;
		/** Gets the filesystem paths that will be searched when require is called.
		 * @see https://love2d.org/wiki/love.filesystem.getRequirePath
		 */
		getRequirePath(): string;
		/** Sets the filesystem paths that will be searched when require is called.
		 * @see https://love2d.org/wiki/love.filesystem.setRequirePath
		 */
		setRequirePath(path: string): void;
		/** Mounts a zip file or folder in the game's save directory for reading.
		 * @see https://love2d.org/wiki/love.filesystem.mount
		 */
		mount(archive: string | FileData, mountpoint: string, appendToPath?: boolean): boolean;
		/** Unmounts a zip file or folder previously mounted for reading with love.filesystem.mount.
		 * @see https://love2d.org/wiki/love.filesystem.unmount
		 */
		unmount(archive: string | FileData): boolean;
		/** Gets whether the game is in fused mode or not.
		 * @see https://love2d.org/wiki/love.filesystem.isFused
		 */
		isFused(): false;
		/** Creates a new File object.
		 * @see https://love2d.org/wiki/love.filesystem.newFile
		 */
		newFile(filename: string, mode?: OpenFileMode): File;
		/** Creates a new FileData object from a file on disk, or from a string in memory.
		 * @see https://love2d.org/wiki/love.filesystem.newFileData
		 */
		newFileData(filename: string): FileData;
		newFileData(file: File): FileData;
		newFileData(data: string, filename: string): FileData;
		/** Read the contents of a file.
		 * @see https://love2d.org/wiki/love.filesystem.read
		 */
		read(filename: string, size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(container: "string", filename: string, size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(container: "data", filename: string, size?: number): LuaMultiReturn<[FileData | undefined, number | string]>;
		/** Loads a Lua file (but does not run it).
		 * @see https://love2d.org/wiki/love.filesystem.load
		 */
		load(filename: string): LuaMultiReturn<[((...args: unknown[]) => unknown) | undefined, string?]>;
		/** Iterate over the lines in a file.
		 * @see https://love2d.org/wiki/love.filesystem.lines
		 */
		lines(filename: string): () => string | undefined;
		/** Write data to a file in the save directory. If the file existed already, it will be completely replaced by the new contents.
		 * @see https://love2d.org/wiki/love.filesystem.write
		 */
		write(filename: string, data: string | FileData, size?: number): LuaMultiReturn<[boolean, string?]>;
		/** Append data to an existing file.
		 * @see https://love2d.org/wiki/love.filesystem.append
		 */
		append(filename: string, data: string | FileData, size?: number): LuaMultiReturn<[boolean, string?]>;
		/** Gets information about the specified file or directory.
		 * @see https://love2d.org/wiki/love.filesystem.getInfo
		 */
		getInfo(filename: string, filterType?: FileType): FileInfo | undefined;
		/** @deprecated 请改用 getInfo。 */
		exists(filename: string): boolean;
		/** @deprecated 请改用 getInfo。 */
		isDirectory(filename: string): boolean;
		/** @deprecated 请改用 getInfo。 */
		isFile(filename: string): boolean;
		/** @deprecated 请改用 getInfo。 */
		isSymlink(filename: string): boolean;
		/** @deprecated 请改用 getInfo。 */
		getLastModified(filename: string): LuaMultiReturn<[number | undefined, string?]>;
		/** @deprecated 请改用 getInfo。 */
		getSize(filename: string): LuaMultiReturn<[number | undefined, string?]>;
		/** Recursively creates a directory.
		 * @see https://love2d.org/wiki/love.filesystem.createDirectory
		 */
		createDirectory(name: string): LuaMultiReturn<[boolean, string?]>;
		/** Removes a file or empty directory.
		 * @see https://love2d.org/wiki/love.filesystem.remove
		 */
		remove(name: string): LuaMultiReturn<[boolean, string?]>;
		/** Returns a table with the names of files and subdirectories in the specified path. The table is not sorted in any way; the order is undefined.
		 * @see https://love2d.org/wiki/love.filesystem.getDirectoryItems
		 */
		getDirectoryItems(directory?: string): string[];
	}

	/** @noSelf */
	/** Provides an interface to the user's keyboard.
	 * @see https://love2d.org/wiki/love.keyboard
	 */
	interface Keyboard {
		/** Enables or disables key repeat for love.keypressed. It is disabled by default.
		 * @see https://love2d.org/wiki/love.keyboard.setKeyRepeat
		 */
		setKeyRepeat(enabled: boolean): void;
		/** Gets whether key repeat is enabled.
		 * @see https://love2d.org/wiki/love.keyboard.hasKeyRepeat
		 */
		hasKeyRepeat(): boolean;
		/** Checks whether a certain key is down. Not to be confused with love.keypressed or love.keyreleased.
		 * @see https://love2d.org/wiki/love.keyboard.isDown
		 */
		isDown(...keys: string[]): boolean;
		isDown(keys: string[]): boolean;
		/** Checks whether the specified Scancodes are pressed. Not to be confused with love.keypressed or love.keyreleased.
		 * @see https://love2d.org/wiki/love.keyboard.isScancodeDown
		 */
		isScancodeDown(...scancodes: string[]): boolean;
		isScancodeDown(scancodes: string[]): boolean;
		/** Gets the hardware scancode corresponding to the given key.
		 * @see https://love2d.org/wiki/love.keyboard.getScancodeFromKey
		 */
		getScancodeFromKey(key: string): string;
		/** Gets the key corresponding to the given hardware scancode.
		 * @see https://love2d.org/wiki/love.keyboard.getKeyFromScancode
		 */
		getKeyFromScancode(scancode: string): string;
		/** Enables or disables text input events. It is enabled by default on Windows, Mac, and Linux, and disabled by default on iOS and Android.
		 * @see https://love2d.org/wiki/love.keyboard.setTextInput
		 */
		setTextInput(enabled: boolean): void;
		setTextInput(enabled: boolean, x: number, y: number, width: number, height: number): void;
		/** Gets whether text input events are enabled.
		 * @see https://love2d.org/wiki/love.keyboard.hasTextInput
		 */
		hasTextInput(): boolean;
		/** Gets whether screen keyboard is supported.
		 * @see https://love2d.org/wiki/love.keyboard.hasScreenKeyboard
		 */
		hasScreenKeyboard(): boolean;
	}

	/** @noSelf */
	type SystemCursor = "arrow" | "ibeam" | "wait" | "crosshair" | "waitarrow" | "sizenwse" | "sizenesw" | "sizewe" | "sizens" | "sizeall" | "no" | "hand";
	/** Represents a hardware cursor.
	 * @see https://love2d.org/wiki/Cursor
	 */
	interface Cursor extends Object {
		/** Gets the type of the Cursor.
		 * @see https://love2d.org/wiki/Cursor:getType
		 */
		getType(): "image" | SystemCursor;
		/** Gets the type of the object as a string.
		 * @see https://love2d.org/wiki/Object:type
		 */
		type(): "Cursor";
		/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 * @see https://love2d.org/wiki/Object:typeOf
		 */
		typeOf(typeName: string): boolean;
	}
	/** @noSelf */
	/** Provides an interface to the user's mouse.
	 * @see https://love2d.org/wiki/love.mouse
	 */
	interface Mouse {
		/** Returns the current position of the mouse.
		 * @see https://love2d.org/wiki/love.mouse.getPosition
		 */
		getPosition(): LuaMultiReturn<[number, number]>;
		/** Returns the current x-position of the mouse.
		 * @see https://love2d.org/wiki/love.mouse.getX
		 */
		getX(): number;
		/** Returns the current y-position of the mouse.
		 * @see https://love2d.org/wiki/love.mouse.getY
		 */
		getY(): number;
		/** Sets the current position of the mouse. Non-integer values are floored.
		 * @see https://love2d.org/wiki/love.mouse.setPosition
		 */
		setPosition(x: number, y: number): void;
		/** Sets the current X position of the mouse.
		 * @see https://love2d.org/wiki/love.mouse.setX
		 */
		setX(x: number): void;
		/** Sets the current Y position of the mouse.
		 * @see https://love2d.org/wiki/love.mouse.setY
		 */
		setY(y: number): void;
		/** Checks whether a certain mouse button is down.
		 * @see https://love2d.org/wiki/love.mouse.isDown
		 */
		isDown(...buttons: number[]): boolean;
		isDown(buttons: number[]): boolean;
		/** Sets the current visibility of the cursor.
		 * @see https://love2d.org/wiki/love.mouse.setVisible
		 */
		setVisible(visible: boolean): void;
		/** Checks if the cursor is visible.
		 * @see https://love2d.org/wiki/love.mouse.isVisible
		 */
		isVisible(): boolean;
		/** Grabs the mouse and confines it to the window.
		 * @see https://love2d.org/wiki/love.mouse.setGrabbed
		 */
		setGrabbed(grabbed: boolean): void;
		/** Checks if the mouse is grabbed.
		 * @see https://love2d.org/wiki/love.mouse.isGrabbed
		 */
		isGrabbed(): boolean;
		/** Sets whether relative mode is enabled for the mouse.
		 * @see https://love2d.org/wiki/love.mouse.setRelativeMode
		 */
		setRelativeMode(relative: boolean): boolean;
		/** Gets whether relative mode is enabled for the mouse.
		 * @see https://love2d.org/wiki/love.mouse.getRelativeMode
		 */
		getRelativeMode(): boolean;
		/** Creates a new hardware Cursor object from an image file or ImageData.
		 * @see https://love2d.org/wiki/love.mouse.newCursor
		 */
		newCursor(image: ImageData | FileData | string, hotX?: number, hotY?: number): Cursor;
		/** Gets a Cursor object representing a system-native hardware cursor.
		 * @see https://love2d.org/wiki/love.mouse.getSystemCursor
		 */
		getSystemCursor(type: SystemCursor): Cursor;
		/** Sets the current mouse cursor.
		 * @see https://love2d.org/wiki/love.mouse.setCursor
		 */
		setCursor(cursor?: Cursor): void;
		/** Gets the current Cursor.
		 * @see https://love2d.org/wiki/love.mouse.getCursor
		 */
		getCursor(): Cursor | undefined;
		/** Gets whether cursor functionality is supported.
		 * @see https://love2d.org/wiki/love.mouse.isCursorSupported
		 */
		isCursorSupported(): boolean;
	}
	type TouchID = LuaUserdata;
	/** @noSelf */
	/** Provides an interface to touch-screen presses.
	 * @see https://love2d.org/wiki/love.touch
	 */
	interface Touch {
		/** Gets a list of all active touch-presses.
		 * @see https://love2d.org/wiki/love.touch.getTouches
		 */
		getTouches(): TouchID[];
		/** Gets the current position of the specified touch-press, in pixels.
		 * @see https://love2d.org/wiki/love.touch.getPosition
		 */
		getPosition(id: TouchID): LuaMultiReturn<[number, number]>;
		/** Gets the current pressure of the specified touch-press.
		 * @see https://love2d.org/wiki/love.touch.getPressure
		 */
		getPressure(id: TouchID): number;
	}
	type GamepadButton = "a" | "b" | "x" | "y" | "back" | "guide" | "start" | "leftstick" | "rightstick" | "leftshoulder" | "rightshoulder" | "dpup" | "dpdown" | "dpleft" | "dpright" | "misc1" | "paddle1" | "paddle2" | "paddle3" | "paddle4" | "touchpad";
	type GamepadAxis = "leftx" | "lefty" | "rightx" | "righty" | "triggerleft" | "triggerright";
	type JoystickHat = "c" | "u" | "r" | "d" | "l" | "ru" | "rd" | "lu" | "ld";
	type JoystickInputType = "axis" | "button" | "hat";
	/** Represents a physical joystick.
	 * @see https://love2d.org/wiki/Joystick
	 */
	interface Joystick extends Object {
		/** Gets whether the Joystick is connected.
		 * @see https://love2d.org/wiki/Joystick:isConnected
		 */
		isConnected(): boolean;
		/** Gets the name of the joystick.
		 * @see https://love2d.org/wiki/Joystick:getName
		 */
		getName(): string;
		/** Gets the joystick's unique identifier. The identifier will remain the same for the life of the game, even when the Joystick is disconnected and reconnected, but it '''will''' change when the game is re-launched.
		 * @see https://love2d.org/wiki/Joystick:getID
		 */
		getID(): LuaMultiReturn<[number, number | undefined]>;
		/** Gets a stable GUID unique to the type of the physical joystick which does not change over time. For example, all Sony Dualshock 3 controllers in OS X have the same GUID. The value is platform-dependent.
		 * @see https://love2d.org/wiki/Joystick:getGUID
		 */
		getGUID(): string;
		/** Gets the USB vendor ID, product ID, and product version numbers of joystick which consistent across operating systems.
		 * @see https://love2d.org/wiki/Joystick:getDeviceInfo
		 */
		getDeviceInfo(): LuaMultiReturn<[number, number, number]>;
		/** Gets the number of axes on the joystick.
		 * @see https://love2d.org/wiki/Joystick:getAxisCount
		 */
		getAxisCount(): number;
		/** Gets the number of buttons on the joystick.
		 * @see https://love2d.org/wiki/Joystick:getButtonCount
		 */
		getButtonCount(): number;
		/** Gets the number of hats on the joystick.
		 * @see https://love2d.org/wiki/Joystick:getHatCount
		 */
		getHatCount(): number;
		/** Gets the direction of an axis.
		 * @see https://love2d.org/wiki/Joystick:getAxis
		 */
		getAxis(axis: number): number;
		/** Gets the direction of each axis.
		 * @see https://love2d.org/wiki/Joystick:getAxes
		 */
		getAxes(): LuaMultiReturn<number[]>;
		/** Gets the direction of the Joystick's hat.
		 * @see https://love2d.org/wiki/Joystick:getHat
		 */
		getHat(hat: number): JoystickHat;
		/** Checks if a button on the Joystick is pressed.
		 * @see https://love2d.org/wiki/Joystick:isDown
		 */
		isDown(...buttons: number[]): boolean;
		/** Gets whether the Joystick is recognized as a gamepad. If this is the case, the Joystick's buttons and axes can be used in a standardized manner across different operating systems and joystick models via Joystick:getGamepadAxis, Joystick:isGamepadDown, love.gamepadpressed, and related functions.
		 * @see https://love2d.org/wiki/Joystick:isGamepad
		 */
		isGamepad(): boolean;
		/** Checks if a virtual gamepad button on the Joystick is pressed. If the Joystick is not recognized as a Gamepad or isn't connected, then this function will always return false.
		 * @see https://love2d.org/wiki/Joystick:isGamepadDown
		 */
		isGamepadDown(...buttons: GamepadButton[]): boolean;
		/** Gets the direction of a virtual gamepad axis. If the Joystick isn't recognized as a gamepad or isn't connected, this function will always return 0.
		 * @see https://love2d.org/wiki/Joystick:getGamepadAxis
		 */
		getGamepadAxis(axis: GamepadAxis): number;
		/** Gets the button, axis or hat that a virtual gamepad input is bound to.
		 * @see https://love2d.org/wiki/Joystick:getGamepadMapping
		 */
		getGamepadMapping(input: GamepadAxis | GamepadButton): LuaMultiReturn<[JoystickInputType, number, JoystickHat?]> | undefined;
		/** Gets the full gamepad mapping string of this Joystick, or nil if it's not recognized as a gamepad.
		 * @see https://love2d.org/wiki/Joystick:getGamepadMappingString
		 */
		getGamepadMappingString(): string | undefined;
		/** Gets whether the Joystick supports vibration.
		 * @see https://love2d.org/wiki/Joystick:isVibrationSupported
		 */
		isVibrationSupported(): boolean;
		/** Sets the vibration motor speeds on a Joystick with rumble support. Most common gamepads have this functionality, although not all drivers give proper support. Use Joystick:isVibrationSupported to check.
		 * @see https://love2d.org/wiki/Joystick:setVibration
		 */
		setVibration(): boolean;
		setVibration(left: number, right?: number, duration?: number): boolean;
		/** Gets the current vibration motor strengths on a Joystick with rumble support.
		 * @see https://love2d.org/wiki/Joystick:getVibration
		 */
		getVibration(): LuaMultiReturn<[number, number]>;
		getConnectedIndex(): number | undefined;
	}
	/** @noSelf */
	/** Provides an interface to the user's joystick.
	 * @see https://love2d.org/wiki/love.joystick
	 */
	interface JoystickModule {
		/** Gets a list of connected Joysticks.
		 * @see https://love2d.org/wiki/love.joystick.getJoysticks
		 */
		getJoysticks(): Joystick[];
		/** Gets the number of connected joysticks.
		 * @see https://love2d.org/wiki/love.joystick.getJoystickCount
		 */
		getJoystickCount(): number;
		/** Binds a virtual gamepad input to a button, axis or hat for all Joysticks of a certain type. For example, if this function is used with a GUID returned by a Dualshock 3 controller in OS X, the binding will affect Joystick:getGamepadAxis and Joystick:isGamepadDown for ''all'' Dualshock 3 controllers used with the game when run in OS X.
		 * @see https://love2d.org/wiki/love.joystick.setGamepadMapping
		 */
		setGamepadMapping(guid: string, input: GamepadAxis | GamepadButton, type: "axis" | "button", index: number): boolean;
		setGamepadMapping(guid: string, input: GamepadAxis | GamepadButton, type: "hat", index: number, direction: JoystickHat): boolean;
		/** Loads a gamepad mappings string or file created with love.joystick.saveGamepadMappings.
		 * @see https://love2d.org/wiki/love.joystick.loadGamepadMappings
		 */
		loadGamepadMappings(mappingsOrFilename: string): void;
		/** Saves the virtual gamepad mappings of all recognized as gamepads and have either been recently used or their gamepad bindings have been modified.
		 * @see https://love2d.org/wiki/love.joystick.saveGamepadMappings
		 */
		saveGamepadMappings(filename?: string): string;
		/** Gets the full gamepad mapping string of the Joysticks which have the given GUID, or nil if the GUID isn't recognized as a gamepad.
		 * @see https://love2d.org/wiki/love.joystick.getGamepadMappingString
		 */
		getGamepadMappingString(guid: string): string | undefined;
	}

	/** @noSelf */
	/** Provides an interface to the user's clock.
	 * @see https://love2d.org/wiki/love.timer
	 */
	interface Timer {
		/** Measures the time between two frames.
		 * @see https://love2d.org/wiki/love.timer.step
		 */
		step(): number;
		/** Returns the time between the last two frames.
		 * @see https://love2d.org/wiki/love.timer.getDelta
		 */
		getDelta(): number;
		/** Returns the current frames per second.
		 * @see https://love2d.org/wiki/love.timer.getFPS
		 */
		getFPS(): number;
		/** Returns the average delta time (seconds per frame) over the last second.
		 * @see https://love2d.org/wiki/love.timer.getAverageDelta
		 */
		getAverageDelta(): number;
		/** Pauses the current thread for the specified amount of time.
		 * @see https://love2d.org/wiki/love.timer.sleep
		 */
		sleep(seconds: number): void;
		/** Returns the value of a timer with an unspecified starting time.
		 * @see https://love2d.org/wiki/love.timer.getTime
		 */
		getTime(): number;
	}
	type OS = "OS X" | "Windows" | "Linux" | "Android" | "iOS" | "UWP" | "Unknown";
	type PowerState = "unknown" | "battery" | "nobattery" | "charging" | "charged";
	/** @noSelf */
	/** Provides access to information about the user's system.
	 * @see https://love2d.org/wiki/love.system
	 */
	interface System {
		/** Gets the current operating system. In general, LÖVE abstracts away the need to know the current operating system, but there are a few cases where it can be useful (especially in combination with os.execute.)
		 * @see https://love2d.org/wiki/love.system.getOS
		 */
		getOS(): OS;
		/** Gets the amount of logical processor in the system.
		 * @see https://love2d.org/wiki/love.system.getProcessorCount
		 */
		getProcessorCount(): number;
		/** Puts text in the clipboard.
		 * @see https://love2d.org/wiki/love.system.setClipboardText
		 */
		setClipboardText(text: string): void;
		/** Gets text from the clipboard.
		 * @see https://love2d.org/wiki/love.system.getClipboardText
		 */
		getClipboardText(): string;
		/** Gets information about the system's power supply.
		 * @see https://love2d.org/wiki/love.system.getPowerInfo
		 */
		getPowerInfo(): LuaMultiReturn<[PowerState, number | undefined, number | undefined]>;
		/** 嵌入式 LoveNode 仅允许 http、https 和 mailto scheme。 */
		/** Opens a URL with the user's web or file browser.
		 * @see https://love2d.org/wiki/love.system.openURL
		 */
		openURL(url: string): boolean;
		/** Causes the device to vibrate, if possible. Currently this will only work on Android and iOS devices that have a built-in vibration motor.
		 * @see https://love2d.org/wiki/love.system.vibrate
		 */
		vibrate(seconds?: number): void;
		/** Gets whether another application on the system is playing music in the background.
		 * @see https://love2d.org/wiki/love.system.hasBackgroundMusic
		 */
		hasBackgroundMusic(): boolean;
	}

	type ThreadValue = boolean | number | string | Data | Channel | ThreadValue[] | {[key: string]: ThreadValue} | undefined;
	/** A Thread is a chunk of code that can run in parallel with other threads. Data can be sent between different threads with Channel objects.
	 * @see https://love2d.org/wiki/Thread
	 */
	interface Thread extends Object {
		/** Gets the type of the object as a string.
		 * @see https://love2d.org/wiki/Object:type
		 */
		type(): "Thread";
		/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 * @see https://love2d.org/wiki/Object:typeOf
		 */
		typeOf(typeName: string): boolean;
		/** Starts the thread.
		 * @see https://love2d.org/wiki/Thread:start
		 */
		start(...args: ThreadValue[]): boolean;
		/** Wait for a thread to finish.
		 * @see https://love2d.org/wiki/Thread:wait
		 */
		wait(): void;
		/** Retrieves the error string from the thread if it produced an error.
		 * @see https://love2d.org/wiki/Thread:getError
		 */
		getError(): string | undefined;
		/** Returns whether the thread is currently running.
		 * @see https://love2d.org/wiki/Thread:isRunning
		 */
		isRunning(): boolean;
	}
	/** An object which can be used to send and receive data between different threads.
	 * @see https://love2d.org/wiki/Channel
	 */
	interface Channel extends Object {
		/** Gets the type of the object as a string.
		 * @see https://love2d.org/wiki/Object:type
		 */
		type(): "Channel";
		/** Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 * @see https://love2d.org/wiki/Object:typeOf
		 */
		typeOf(typeName: string): boolean;
		/** Send a message to the thread Channel.
		 * @see https://love2d.org/wiki/Channel:push
		 */
		push(value: ThreadValue): number;
		/** Send a message to the thread Channel and wait for a thread to accept it.
		 * @see https://love2d.org/wiki/Channel:supply
		 */
		supply(value: ThreadValue, timeout?: number): boolean;
		/** Retrieves the value of a Channel message and removes it from the message queue.
		 * @see https://love2d.org/wiki/Channel:pop
		 */
		pop(): ThreadValue;
		/** Retrieves the value of a Channel message and removes it from the message queue.
		 * @see https://love2d.org/wiki/Channel:demand
		 */
		demand(timeout?: number): ThreadValue;
		/** Retrieves the value of a Channel message, but leaves it in the queue.
		 * @see https://love2d.org/wiki/Channel:peek
		 */
		peek(): ThreadValue;
		/** Retrieves the number of messages in the thread Channel queue.
		 * @see https://love2d.org/wiki/Channel:getCount
		 */
		getCount(): number;
		/** Gets whether a pushed value has been popped or otherwise removed from the Channel.
		 * @see https://love2d.org/wiki/Channel:hasRead
		 */
		hasRead(id: number): boolean;
		/** Clears all the messages in the Channel queue.
		 * @see https://love2d.org/wiki/Channel:clear
		 */
		clear(): void;
		/** Executes the specified function atomically with respect to this Channel.
		 * @see https://love2d.org/wiki/Channel:performAtomic
		 */
		performAtomic(callback: (channel: Channel, ...args: any[]) => any, ...args: any[]): any;
	}
	/** @noSelf */
	/** Allows you to work with threads.
	 * @see https://love2d.org/wiki/love.thread
	 */
	interface ThreadModule {
		/** Creates a new Thread from a filename, string or FileData object containing Lua code.
		 * @see https://love2d.org/wiki/love.thread.newThread
		 */
		newThread(codeOrFilename: string | Data | File): Thread;
		/** Create a new unnamed thread channel.
		 * @see https://love2d.org/wiki/love.thread.newChannel
		 */
		newChannel(): Channel;
		/** Creates or retrieves a named thread channel.
		 * @see https://love2d.org/wiki/love.thread.getChannel
		 */
		getChannel(name: string): Channel;
	}

	type SourceType = "static" | "stream" | "queue";
	type TimeUnit = "seconds" | "samples";
	type DistanceModel = "none" | "inverse" | "inverseclamped" | "linear" | "linearclamped" | "exponent" | "exponentclamped";
	type AudioFilterType = "lowpass" | "highpass" | "bandpass";
	interface AudioFilterSettings {
		type: AudioFilterType;
		volume?: number;
		lowgain?: number;
		highgain?: number;
	}
	type AudioEffectType = "reverb" | "chorus" | "distortion" | "echo" | "flanger" | "ringmodulator" | "compressor" | "equalizer";
	interface AudioEffectSettings {
		type: AudioEffectType;
		volume?: number;
		[key: string]: string | number | boolean | undefined;
	}
	/** A Source represents audio you can play back.
	 * @see https://love2d.org/wiki/Source
	 */
	interface Source extends Object {
		/** Creates an identical copy of the Source in the stopped state.
		 * @see https://love2d.org/wiki/Source:clone
		 */
		clone(): Source;
		/** Starts playing the Source.
		 * @see https://love2d.org/wiki/Source:play
		 */
		play(): boolean;
		/** Pauses the Source.
		 * @see https://love2d.org/wiki/Source:pause
		 */
		pause(): void;
		/** Stops a Source.
		 * @see https://love2d.org/wiki/Source:stop
		 */
		stop(): void;
		/** Returns whether the Source is playing.
		 * @see https://love2d.org/wiki/Source:isPlaying
		 */
		isPlaying(): boolean;
		isPaused(): boolean;
		/** Sets whether the Source should loop.
		 * @see https://love2d.org/wiki/Source:setLooping
		 */
		setLooping(looping: boolean): void;
		/** Returns whether the Source will loop.
		 * @see https://love2d.org/wiki/Source:isLooping
		 */
		isLooping(): boolean;
		/** Sets the current volume of the Source.
		 * @see https://love2d.org/wiki/Source:setVolume
		 */
		setVolume(volume: number): void;
		/** Gets the current volume of the Source.
		 * @see https://love2d.org/wiki/Source:getVolume
		 */
		getVolume(): number;
		/** Sets the pitch of the Source.
		 * @see https://love2d.org/wiki/Source:setPitch
		 */
		setPitch(pitch: number): void;
		/** Gets the current pitch of the Source.
		 * @see https://love2d.org/wiki/Source:getPitch
		 */
		getPitch(): number;
		/** Sets the currently playing position of the Source.
		 * @see https://love2d.org/wiki/Source:seek
		 */
		seek(offset: number, unit?: TimeUnit): void;
		/** Gets the currently playing position of the Source.
		 * @see https://love2d.org/wiki/Source:tell
		 */
		tell(unit?: TimeUnit): number;
		/** Gets the duration of the Source. For streaming Sources it may not always be sample-accurate, and may return -1 if the duration cannot be determined at all.
		 * @see https://love2d.org/wiki/Source:getDuration
		 */
		getDuration(unit?: TimeUnit): number;
		/** Gets the number of channels in the Source. Only 1-channel (mono) Sources can use directional and positional effects.
		 * @see https://love2d.org/wiki/Source:getChannelCount
		 */
		getChannelCount(): number;
		/** Love 对 getChannelCount 的弃用别名。 */
		getChannels(): number;
		/** Gets the number of free buffer slots in a queueable Source. If the queueable Source is playing, this value will increase up to the amount the Source was created with. If the queueable Source is stopped, it will process all of its internal buffers first, in which case this function will always return the amount it was created with.
		 * @see https://love2d.org/wiki/Source:getFreeBufferCount
		 */
		getFreeBufferCount(): number;
		/** Queues SoundData for playback in a queueable Source.
		 * @see https://love2d.org/wiki/Source:queue
		 */
		queue(data: SoundData, length?: number): boolean;
		queue(data: SoundData, offset: number, length: number): boolean;
		/** Sets the position of the Source. Please note that this only works for mono (i.e. non-stereo) sound files!
		 * @see https://love2d.org/wiki/Source:setPosition
		 */
		setPosition(x: number, y: number, z?: number): void;
		/** Gets the position of the Source.
		 * @see https://love2d.org/wiki/Source:getPosition
		 */
		getPosition(): LuaMultiReturn<[number, number, number]>;
		/** Sets the velocity of the Source.
		 * @see https://love2d.org/wiki/Source:setVelocity
		 */
		setVelocity(x: number, y: number, z?: number): void;
		/** Gets the velocity of the Source.
		 * @see https://love2d.org/wiki/Source:getVelocity
		 */
		getVelocity(): LuaMultiReturn<[number, number, number]>;
		/** Sets the direction vector of the Source. A zero vector makes the source non-directional.
		 * @see https://love2d.org/wiki/Source:setDirection
		 */
		setDirection(x: number, y: number, z?: number): void;
		/** Gets the direction of the Source.
		 * @see https://love2d.org/wiki/Source:getDirection
		 */
		getDirection(): LuaMultiReturn<[number, number, number]>;
		/** Sets the Source's directional volume cones. Together with Source:setDirection, the cone angles allow for the Source's volume to vary depending on its direction.
		 * @see https://love2d.org/wiki/Source:setCone
		 */
		setCone(innerAngle: number, outerAngle: number, outerVolume?: number, outerHighGain?: number): void;
		/** Gets the Source's directional volume cones. Together with Source:setDirection, the cone angles allow for the Source's volume to vary depending on its direction.
		 * @see https://love2d.org/wiki/Source:getCone
		 */
		getCone(): LuaMultiReturn<[number, number, number, number]>;
		/** Sets the amount of air absorption applied to the Source.
		 * @see https://love2d.org/wiki/Source:setAirAbsorption
		 */
		setAirAbsorption(factor: number): void;
		/** Gets the amount of air absorption applied to the Source.
		 * @see https://love2d.org/wiki/Source:getAirAbsorption
		 */
		getAirAbsorption(): number;
		/** Sets the volume limits of the source. The limits have to be numbers from 0 to 1.
		 * @see https://love2d.org/wiki/Source:setVolumeLimits
		 */
		setVolumeLimits(minVolume: number, maxVolume: number): void;
		/** Returns the volume limits of the source.
		 * @see https://love2d.org/wiki/Source:getVolumeLimits
		 */
		getVolumeLimits(): LuaMultiReturn<[number, number]>;
		/** Sets whether the Source's position, velocity, direction, and cone angles are relative to the listener, or absolute.
		 * @see https://love2d.org/wiki/Source:setRelative
		 */
		setRelative(relative: boolean): void;
		/** Gets whether the Source's position, velocity, direction, and cone angles are relative to the listener.
		 * @see https://love2d.org/wiki/Source:isRelative
		 */
		isRelative(): boolean;
		/** Sets the reference and maximum attenuation distances of the Source. The parameters, combined with the current DistanceModel, affect how the Source's volume attenuates based on distance.
		 * @see https://love2d.org/wiki/Source:setAttenuationDistances
		 */
		setAttenuationDistances(referenceDistance: number, maxDistance: number): void;
		/** Gets the reference and maximum attenuation distances of the Source. The values, combined with the current DistanceModel, affect how the Source's volume attenuates based on distance from the listener.
		 * @see https://love2d.org/wiki/Source:getAttenuationDistances
		 */
		getAttenuationDistances(): LuaMultiReturn<[number, number]>;
		/** Sets the rolloff factor which affects the strength of the used distance attenuation.
		 * @see https://love2d.org/wiki/Source:setRolloff
		 */
		setRolloff(rolloff: number): void;
		/** Returns the rolloff factor of the source.
		 * @see https://love2d.org/wiki/Source:getRolloff
		 */
		getRolloff(): number;
		/** Sets a low-pass, high-pass, or band-pass filter to apply when playing the Source.
		 * @see https://love2d.org/wiki/Source:setFilter
		 */
		setFilter(filter?: AudioFilterSettings): boolean;
		getFilter<T extends AudioFilterSettings>(target?: T): T | AudioFilterSettings | undefined;
		/** Applies an audio effect to the Source.
		 * @see https://love2d.org/wiki/Source:setEffect
		 */
		setEffect(name: string, enabled?: boolean | AudioFilterSettings): boolean;
		/** Gets the filter settings associated to a specific effect.
		 * @see https://love2d.org/wiki/Source:getEffect
		 */
		getEffect(name: string, target?: AudioFilterSettings): LuaMultiReturn<[boolean, AudioFilterSettings?]>;
		/** Gets a list of the Source's active effect names.
		 * @see https://love2d.org/wiki/Source:getActiveEffects
		 */
		getActiveEffects(): string[];
		/** Gets the type of the Source.
		 * @see https://love2d.org/wiki/Source:getType
		 */
		getType(): SourceType;
	}
	/** Represents an audio input device capable of recording sounds.
	 * @see https://love2d.org/wiki/RecordingDevice
	 */
	interface RecordingDevice extends Object {
		/** Begins recording audio using this device.
		 * @see https://love2d.org/wiki/RecordingDevice:start
		 */
		start(samples?: number, sampleRate?: number, bitDepth?: 8 | 16, channels?: 1 | 2): boolean;
		/** 停止录音并返回当前缓冲的采样。 */
		/** Stops recording audio from this device. Any sound data currently in the device's buffer will be returned.
		 * @see https://love2d.org/wiki/RecordingDevice:stop
		 */
		stop(): SoundData | undefined;
		/** 返回并消费当前设备中已缓冲的采样。 */
		/** Gets all recorded audio SoundData stored in the device's internal ring buffer.
		 * @see https://love2d.org/wiki/RecordingDevice:getData
		 */
		getData(): SoundData | undefined;
		/** Gets the number of currently recorded samples.
		 * @see https://love2d.org/wiki/RecordingDevice:getSampleCount
		 */
		getSampleCount(): number;
		/** Gets the number of samples per second currently being recorded.
		 * @see https://love2d.org/wiki/RecordingDevice:getSampleRate
		 */
		getSampleRate(): number;
		/** Gets the number of bits per sample in the data currently being recorded.
		 * @see https://love2d.org/wiki/RecordingDevice:getBitDepth
		 */
		getBitDepth(): 8 | 16;
		/** Gets the number of channels currently being recorded (mono or stereo).
		 * @see https://love2d.org/wiki/RecordingDevice:getChannelCount
		 */
		getChannelCount(): 1 | 2;
		/** Gets the name of the recording device.
		 * @see https://love2d.org/wiki/RecordingDevice:getName
		 */
		getName(): string;
		/** Gets whether the device is currently recording.
		 * @see https://love2d.org/wiki/RecordingDevice:isRecording
		 */
		isRecording(): boolean;
	}
	/** @noSelf */
	/** Provides an interface to create noise with the user's speakers.
	 * @see https://love2d.org/wiki/love.audio
	 */
	interface Audio {
		/** Creates a new Source from a filepath, File, Decoder or SoundData.
		 * @see https://love2d.org/wiki/love.audio.newSource
		 */
		newSource(filename: string, sourceType?: "static" | "stream"): Source;
		newSource(data: SoundData): Source;
		/** Creates a new Source usable for real-time generated sound playback with Source:queue.
		 * @see https://love2d.org/wiki/love.audio.newQueueableSource
		 */
		newQueueableSource(sampleRate: number, bitDepth: 8 | 16,
			channels: 1 | 2, buffers?: number): Source;
		/** Plays the specified Source.
		 * @see https://love2d.org/wiki/love.audio.play
		 */
		play(sources: Source[]): boolean;
		play(...sources: Source[]): boolean;
		/** Pauses specific or all currently played Sources.
		 * @see https://love2d.org/wiki/love.audio.pause
		 */
		pause(): Source[];
		pause(sources: Source[]): void;
		pause(...sources: Source[]): void;
		/** Stops currently played sources.
		 * @see https://love2d.org/wiki/love.audio.stop
		 */
		stop(sources: Source[]): void;
		stop(...sources: Source[]): void;
		/** Gets the current number of simultaneously playing sources.
		 * @see https://love2d.org/wiki/love.audio.getActiveSourceCount
		 */
		getActiveSourceCount(): number;
		/** Love 对 getActiveSourceCount 的弃用别名。 */
		getSourceCount(): number;
		/** Sets the master volume.
		 * @see https://love2d.org/wiki/love.audio.setVolume
		 */
		setVolume(volume: number): void;
		/** Returns the master volume.
		 * @see https://love2d.org/wiki/love.audio.getVolume
		 */
		getVolume(): number;
		/** 设置应用级 iOS 音频会话混音策略。其他平台返回 false。 */
		/** Sets whether the system should mix the audio with the system's audio.
		 * @see https://love2d.org/wiki/love.audio.setMixWithSystem
		 */
		setMixWithSystem(mix: boolean): boolean;
		/** 设置所有 LoveNode 共享的 Dora 应用级听者位置。 */
		/** Sets the position of the listener, which determines how sounds play.
		 * @see https://love2d.org/wiki/love.audio.setPosition
		 */
		setPosition(x: number, y: number, z?: number): void;
		/** Returns the position of the listener. Please note that positional audio only works for mono (i.e. non-stereo) sources.
		 * @see https://love2d.org/wiki/love.audio.getPosition
		 */
		getPosition(): LuaMultiReturn<[number, number, number]>;
		/** 设置 Dora 应用级听者的前向与向上向量。 */
		/** Sets the orientation of the listener.
		 * @see https://love2d.org/wiki/love.audio.setOrientation
		 */
		setOrientation(forwardX: number, forwardY: number, forwardZ: number,
			upX: number, upY: number, upZ: number): void;
		/** Returns the orientation of the listener.
		 * @see https://love2d.org/wiki/love.audio.getOrientation
		 */
		getOrientation(): LuaMultiReturn<[number, number, number, number, number, number]>;
		/** 设置所有 LoveNode 共享的 Dora 应用级听者速度。 */
		/** Sets the velocity of the listener.
		 * @see https://love2d.org/wiki/love.audio.setVelocity
		 */
		setVelocity(x: number, y: number, z?: number): void;
		/** Returns the velocity of the listener.
		 * @see https://love2d.org/wiki/love.audio.getVelocity
		 */
		getVelocity(): LuaMultiReturn<[number, number, number]>;
		/** 设置所有 LoveNode 共享的 Dora 应用级 Doppler 缩放。 */
		/** Sets a global scale factor for velocity-based doppler effects. The default scale value is 1.
		 * @see https://love2d.org/wiki/love.audio.setDopplerScale
		 */
		setDopplerScale(scale: number): void;
		/** Gets the current global scale factor for velocity-based doppler effects.
		 * @see https://love2d.org/wiki/love.audio.getDopplerScale
		 */
		getDopplerScale(): number;
		/** 设置 Dora 应用级共享的距离衰减模型。 */
		/** Sets the distance attenuation model.
		 * @see https://love2d.org/wiki/love.audio.setDistanceModel
		 */
		setDistanceModel(model: DistanceModel): void;
		/** Returns the distance attenuation model.
		 * @see https://love2d.org/wiki/love.audio.getDistanceModel
		 */
		getDistanceModel(): DistanceModel;
		/** Defines an effect that can be applied to a Source.
		 * @see https://love2d.org/wiki/love.audio.setEffect
		 */
		setEffect(name: string, settings?: AudioEffectSettings | false): boolean;
		getEffect<T extends AudioEffectSettings>(name: string, target?: T): T | AudioEffectSettings | undefined;
		/** Gets a list of the names of the currently enabled effects.
		 * @see https://love2d.org/wiki/love.audio.getActiveEffects
		 */
		getActiveEffects(): string[];
		/** Gets the maximum number of active effects supported by the system.
		 * @see https://love2d.org/wiki/love.audio.getMaxSceneEffects
		 */
		getMaxSceneEffects(): number;
		/** Gets the maximum number of active Effects in a single Source object, that the system can support.
		 * @see https://love2d.org/wiki/love.audio.getMaxSourceEffects
		 */
		getMaxSourceEffects(): number;
		/** Gets a list of RecordingDevices on the system.
		 * @see https://love2d.org/wiki/love.audio.getRecordingDevices
		 */
		getRecordingDevices(): RecordingDevice[];
		/** Gets whether audio effects are supported in the system.
		 * @see https://love2d.org/wiki/love.audio.isEffectsSupported
		 */
		isEffectsSupported(): boolean;
	}
	type BodyType = "static" | "dynamic" | "kinematic";
	type ContactCallback = (fixtureA: Fixture, fixtureB: Fixture, contact: Contact) => void;
	type PostSolveCallback = (fixtureA: Fixture, fixtureB: Fixture, contact: Contact,
		...impulses: number[]) => void;
	/** Contacts are objects created to manage collisions in worlds.
	 * @see https://love2d.org/wiki/Contact
	 */
	interface Contact extends Object {
		isValid(): boolean;
		/** Gets the two Fixtures that hold the shapes that are in contact.
		 * @see https://love2d.org/wiki/Contact:getFixtures
		 */
		getFixtures(): LuaMultiReturn<[Fixture, Fixture]>;
		/** Gets the child indices of the shapes of the two colliding fixtures. For ChainShapes, an index of 1 is the first edge in the chain. Used together with Fixture:rayCast or ChainShape:getChildEdge.
		 * @see https://love2d.org/wiki/Contact:getChildren
		 */
		getChildren(): LuaMultiReturn<[number, number]>;
		/** Returns the contact points of the two colliding fixtures. There can be one or two points.
		 * @see https://love2d.org/wiki/Contact:getPositions
		 */
		getPositions(): LuaMultiReturn<number[]>;
		/** Get the normal vector between two shapes that are in contact.
		 * @see https://love2d.org/wiki/Contact:getNormal
		 */
		getNormal(): LuaMultiReturn<[number, number]>;
		/** Get the friction between two shapes that are in contact.
		 * @see https://love2d.org/wiki/Contact:getFriction
		 */
		getFriction(): number;
		/** Sets the contact friction.
		 * @see https://love2d.org/wiki/Contact:setFriction
		 */
		setFriction(friction: number): void;
		/** Resets the contact friction to the mixture value of both fixtures.
		 * @see https://love2d.org/wiki/Contact:resetFriction
		 */
		resetFriction(): void;
		/** Get the restitution between two shapes that are in contact.
		 * @see https://love2d.org/wiki/Contact:getRestitution
		 */
		getRestitution(): number;
		/** Sets the contact restitution.
		 * @see https://love2d.org/wiki/Contact:setRestitution
		 */
		setRestitution(restitution: number): void;
		/** Resets the contact restitution to the mixture value of both fixtures.
		 * @see https://love2d.org/wiki/Contact:resetRestitution
		 */
		resetRestitution(): void;
		/** Returns whether the contact is enabled. The collision will be ignored if a contact gets disabled in the preSolve callback.
		 * @see https://love2d.org/wiki/Contact:isEnabled
		 */
		isEnabled(): boolean;
		/** Enables or disables the contact.
		 * @see https://love2d.org/wiki/Contact:setEnabled
		 */
		setEnabled(enabled: boolean): void;
		/** Returns whether the two colliding fixtures are touching each other.
		 * @see https://love2d.org/wiki/Contact:isTouching
		 */
		isTouching(): boolean;
		getTangentSpeed(): number;
		setTangentSpeed(speed: number): void;
	}
	/** A world is an object that contains all bodies and joints.
	 * @see https://love2d.org/wiki/World
	 */
	interface World extends Object {
		/** Destroys the world, taking all bodies, joints, fixtures and their shapes with it.
		 * @see https://love2d.org/wiki/World:destroy
		 */
		destroy(): void;
		/** Gets whether the World is destroyed. Destroyed worlds cannot be used.
		 * @see https://love2d.org/wiki/World:isDestroyed
		 */
		isDestroyed(): boolean;
		/** Update the state of the world.
		 * @see https://love2d.org/wiki/World:update
		 */
		update(deltaTime: number, velocityIterations?: number, positionIterations?: number): void;
		/** Set the gravity of the world.
		 * @see https://love2d.org/wiki/World:setGravity
		 */
		setGravity(x: number, y: number): void;
		/** Get the gravity of the world.
		 * @see https://love2d.org/wiki/World:getGravity
		 */
		getGravity(): LuaMultiReturn<[number, number]>;
		/** Sets the sleep behaviour of the world.
		 * @see https://love2d.org/wiki/World:setSleepingAllowed
		 */
		setSleepingAllowed(allowed: boolean): void;
		/** Gets the sleep behaviour of the world.
		 * @see https://love2d.org/wiki/World:isSleepingAllowed
		 */
		isSleepingAllowed(): boolean;
		/** Calls a function for each fixture inside the specified area by searching for any overlapping bounding box (Fixture:getBoundingBox).
		 * @see https://love2d.org/wiki/World:queryBoundingBox
		 */
		queryBoundingBox(x1: number, y1: number, x2: number, y2: number,
			callback: (fixture: Fixture) => boolean): void;
		/** Casts a ray and calls a function for each fixtures it intersects.
		 * @see https://love2d.org/wiki/World:rayCast
		 */
		rayCast(x1: number, y1: number, x2: number, y2: number,
			callback: (fixture: Fixture, x: number, y: number,
				normalX: number, normalY: number, fraction: number) => number): void;
		/** Sets functions for the collision callbacks during the world update.
		 * @see https://love2d.org/wiki/World:setCallbacks
		 */
		setCallbacks(beginContact?: ContactCallback, endContact?: ContactCallback,
			preSolve?: ContactCallback, postSolve?: PostSolveCallback): void;
		/** Returns functions for the callbacks during the world update.
		 * @see https://love2d.org/wiki/World:getCallbacks
		 */
		getCallbacks(): LuaMultiReturn<[ContactCallback | undefined, ContactCallback | undefined,
			ContactCallback | undefined, PostSolveCallback | undefined]>;
	}
	/** Bodies are objects with velocity and position.
	 * @see https://love2d.org/wiki/Body
	 */
	interface Body extends Object {
		/** Explicitly destroys the Body and all fixtures and joints attached to it.
		 * @see https://love2d.org/wiki/Body:destroy
		 */
		destroy(): void;
		/** Gets whether the Body is destroyed. Destroyed bodies cannot be used.
		 * @see https://love2d.org/wiki/Body:isDestroyed
		 */
		isDestroyed(): boolean;
		/** Get the position of the body.
		 * @see https://love2d.org/wiki/Body:getPosition
		 */
		getPosition(): LuaMultiReturn<[number, number]>;
		/** Set the position of the body.
		 * @see https://love2d.org/wiki/Body:setPosition
		 */
		setPosition(x: number, y: number): void;
		/** Get the x position of the body in world coordinates.
		 * @see https://love2d.org/wiki/Body:getX
		 */
		getX(): number;
		/** Set the x position of the body.
		 * @see https://love2d.org/wiki/Body:setX
		 */
		setX(x: number): void;
		/** Get the y position of the body in world coordinates.
		 * @see https://love2d.org/wiki/Body:getY
		 */
		getY(): number;
		/** Set the y position of the body.
		 * @see https://love2d.org/wiki/Body:setY
		 */
		setY(y: number): void;
		/** Get the position and angle of the body.
		 * @see https://love2d.org/wiki/Body:getTransform
		 */
		getTransform(): LuaMultiReturn<[number, number, number]>;
		/** Set the position and angle of the body.
		 * @see https://love2d.org/wiki/Body:setTransform
		 */
		setTransform(x: number, y: number, angle: number): void;
		/** Get the angle of the body.
		 * @see https://love2d.org/wiki/Body:getAngle
		 */
		getAngle(): number;
		/** Set the angle of the body.
		 * @see https://love2d.org/wiki/Body:setAngle
		 */
		setAngle(angle: number): void;
		/** Gets the linear velocity of the Body from its center of mass.
		 * @see https://love2d.org/wiki/Body:getLinearVelocity
		 */
		getLinearVelocity(): LuaMultiReturn<[number, number]>;
		/** Sets a new linear velocity for the Body.
		 * @see https://love2d.org/wiki/Body:setLinearVelocity
		 */
		setLinearVelocity(x: number, y: number): void;
		/** Get the angular velocity of the Body.
		 * @see https://love2d.org/wiki/Body:getAngularVelocity
		 */
		getAngularVelocity(): number;
		/** Sets the angular velocity of a Body.
		 * @see https://love2d.org/wiki/Body:setAngularVelocity
		 */
		setAngularVelocity(velocity: number): void;
		/** Gets the linear damping of the Body.
		 * @see https://love2d.org/wiki/Body:getLinearDamping
		 */
		getLinearDamping(): number;
		/** Sets the linear damping of a Body
		 * @see https://love2d.org/wiki/Body:setLinearDamping
		 */
		setLinearDamping(damping: number): void;
		/** Gets the Angular damping of the Body
		 * @see https://love2d.org/wiki/Body:getAngularDamping
		 */
		getAngularDamping(): number;
		/** Sets the angular damping of a Body
		 * @see https://love2d.org/wiki/Body:setAngularDamping
		 */
		setAngularDamping(damping: number): void;
		/** Get the mass of the body.
		 * @see https://love2d.org/wiki/Body:getMass
		 */
		getMass(): number;
		/** Sets a new body mass.
		 * @see https://love2d.org/wiki/Body:setMass
		 */
		setMass(mass: number): void;
		/** Gets the rotational inertia of the body.
		 * @see https://love2d.org/wiki/Body:getInertia
		 */
		getInertia(): number;
		/** Set the inertia of a body.
		 * @see https://love2d.org/wiki/Body:setInertia
		 */
		setInertia(inertia: number): void;
		/** Returns the mass, its center, and the rotational inertia.
		 * @see https://love2d.org/wiki/Body:getMassData
		 */
		getMassData(): LuaMultiReturn<[number, number, number, number]>;
		/** Overrides the calculated mass data.
		 * @see https://love2d.org/wiki/Body:setMassData
		 */
		setMassData(centerX: number, centerY: number, mass: number, inertia: number): void;
		/** Resets the mass of the body by recalculating it from the mass properties of the fixtures.
		 * @see https://love2d.org/wiki/Body:resetMassData
		 */
		resetMassData(): void;
		/** Returns the gravity scale factor.
		 * @see https://love2d.org/wiki/Body:getGravityScale
		 */
		getGravityScale(): number;
		/** Sets a new gravity scale factor for the body.
		 * @see https://love2d.org/wiki/Body:setGravityScale
		 */
		setGravityScale(scale: number): void;
		/** Get the center of mass position in local coordinates.
		 * @see https://love2d.org/wiki/Body:getLocalCenter
		 */
		getLocalCenter(): LuaMultiReturn<[number, number]>;
		/** Get the center of mass position in world coordinates.
		 * @see https://love2d.org/wiki/Body:getWorldCenter
		 */
		getWorldCenter(): LuaMultiReturn<[number, number]>;
		/** Returns whether the body rotation is locked.
		 * @see https://love2d.org/wiki/Body:isFixedRotation
		 */
		isFixedRotation(): boolean;
		/** Set whether a body has fixed rotation.
		 * @see https://love2d.org/wiki/Body:setFixedRotation
		 */
		setFixedRotation(fixed: boolean): void;
		/** Returns the sleep status of the body.
		 * @see https://love2d.org/wiki/Body:isAwake
		 */
		isAwake(): boolean;
		/** Wakes the body up or puts it to sleep.
		 * @see https://love2d.org/wiki/Body:setAwake
		 */
		setAwake(awake: boolean): void;
		/** Returns the sleeping behaviour of the body.
		 * @see https://love2d.org/wiki/Body:isSleepingAllowed
		 */
		isSleepingAllowed(): boolean;
		/** Sets the sleeping behaviour of the body. Should sleeping be allowed, a body at rest will automatically sleep. A sleeping body is not simulated unless it collided with an awake body. Be wary that one can end up with a situation like a floating sleeping body if the floor was removed.
		 * @see https://love2d.org/wiki/Body:setSleepingAllowed
		 */
		setSleepingAllowed(allowed: boolean): void;
		/** Returns whether the body is actively used in the simulation.
		 * @see https://love2d.org/wiki/Body:isActive
		 */
		isActive(): boolean;
		/** Sets whether the body is active in the world.
		 * @see https://love2d.org/wiki/Body:setActive
		 */
		setActive(active: boolean): void;
		/** Get the bullet status of a body.
		 * @see https://love2d.org/wiki/Body:isBullet
		 */
		isBullet(): boolean;
		/** Set the bullet status of a body.
		 * @see https://love2d.org/wiki/Body:setBullet
		 */
		setBullet(bullet: boolean): void;
		/** Applies an impulse to a body.
		 * @see https://love2d.org/wiki/Body:applyLinearImpulse
		 */
		applyLinearImpulse(xImpulse: number, yImpulse: number, pointX?: number, pointY?: number): void;
		/** Applies an angular impulse to a body. This makes a single, instantaneous addition to the body momentum.
		 * @see https://love2d.org/wiki/Body:applyAngularImpulse
		 */
		applyAngularImpulse(impulse: number): void;
		/** Apply force to a Body.
		 * @see https://love2d.org/wiki/Body:applyForce
		 */
		applyForce(xForce: number, yForce: number, pointX?: number, pointY?: number): void;
		/** Apply torque to a body.
		 * @see https://love2d.org/wiki/Body:applyTorque
		 */
		applyTorque(torque: number): void;
		/** Returns the type of the body.
		 * @see https://love2d.org/wiki/Body:getType
		 */
		getType(): BodyType;
		/** Sets a new body type.
		 * @see https://love2d.org/wiki/Body:setType
		 */
		setType(type: BodyType): void;
		/** Transform a point from local coordinates to world coordinates.
		 * @see https://love2d.org/wiki/Body:getWorldPoint
		 */
		getWorldPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/** Transform a vector from local coordinates to world coordinates.
		 * @see https://love2d.org/wiki/Body:getWorldVector
		 */
		getWorldVector(x: number, y: number): LuaMultiReturn<[number, number]>;
		/** Transforms multiple points from local coordinates to world coordinates.
		 * @see https://love2d.org/wiki/Body:getWorldPoints
		 */
		getWorldPoints(x: number, y: number, ...coordinates: number[]): LuaMultiReturn<number[]>;
		/** Transform a point from world coordinates to local coordinates.
		 * @see https://love2d.org/wiki/Body:getLocalPoint
		 */
		getLocalPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/** Transform a vector from world coordinates to local coordinates.
		 * @see https://love2d.org/wiki/Body:getLocalVector
		 */
		getLocalVector(x: number, y: number): LuaMultiReturn<[number, number]>;
		/** Transforms multiple points from world coordinates to local coordinates.
		 * @see https://love2d.org/wiki/Body:getLocalPoints
		 */
		getLocalPoints(x: number, y: number, ...coordinates: number[]): LuaMultiReturn<number[]>;
		/** Get the linear velocity of a point on the body.
		 * @see https://love2d.org/wiki/Body:getLinearVelocityFromWorldPoint
		 */
		getLinearVelocityFromWorldPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/** Get the linear velocity of a point on the body.
		 * @see https://love2d.org/wiki/Body:getLinearVelocityFromLocalPoint
		 */
		getLinearVelocityFromLocalPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
	}
	/** Shapes are solid 2d geometrical objects which handle the mass and collision of a Body in love.physics.
	 * @see https://love2d.org/wiki/Shape
	 */
	interface Shape extends Object { getType(): "circle" | "polygon" | "edge" | "chain"; }
	/** Circle extends Shape and adds a radius and a local position.
	 * @see https://love2d.org/wiki/CircleShape
	 */
	interface CircleShape extends Shape { getRadius(): number; }
	/** A PolygonShape is a convex polygon with up to 8 vertices.
	 * @see https://love2d.org/wiki/PolygonShape
	 */
	interface PolygonShape extends Shape {
		/** Get the local coordinates of the polygon's vertices.
		 * @see https://love2d.org/wiki/PolygonShape:getPoints
		 */
		getPoints(): LuaMultiReturn<number[]>;
		validate(): boolean;
	}
	/** A EdgeShape is a line segment. They can be used to create the boundaries of your terrain. The shape does not have volume and can only collide with PolygonShape and CircleShape.
	 * @see https://love2d.org/wiki/EdgeShape
	 */
	interface EdgeShape extends Shape {
		/** Returns the local coordinates of the edge points.
		 * @see https://love2d.org/wiki/EdgeShape:getPoints
		 */
		getPoints(): LuaMultiReturn<[number, number, number, number]>;
		/** Gets the vertex that establishes a connection to the previous shape.
		 * @see https://love2d.org/wiki/EdgeShape:getPreviousVertex
		 */
		getPreviousVertex(): LuaMultiReturn<[number, number] | []>;
		/** Gets the vertex that establishes a connection to the next shape.
		 * @see https://love2d.org/wiki/EdgeShape:getNextVertex
		 */
		getNextVertex(): LuaMultiReturn<[number, number] | []>;
		/** Sets a vertex that establishes a connection to the previous shape.
		 * @see https://love2d.org/wiki/EdgeShape:setPreviousVertex
		 */
		setPreviousVertex(x?: number, y?: number): void;
		/** Sets a vertex that establishes a connection to the next shape.
		 * @see https://love2d.org/wiki/EdgeShape:setNextVertex
		 */
		setNextVertex(x?: number, y?: number): void;
	}
	/** A ChainShape consists of multiple line segments. It can be used to create the boundaries of your terrain. The shape does not have volume and can only collide with PolygonShape and CircleShape.
	 * @see https://love2d.org/wiki/ChainShape
	 */
	interface ChainShape extends Shape {
		/** Returns all points of the shape.
		 * @see https://love2d.org/wiki/ChainShape:getPoints
		 */
		getPoints(): LuaMultiReturn<number[]>;
		/** Returns the number of vertices the shape has.
		 * @see https://love2d.org/wiki/ChainShape:getVertexCount
		 */
		getVertexCount(): number;
		/** Returns a point of the shape.
		 * @see https://love2d.org/wiki/ChainShape:getPoint
		 */
		getPoint(index: number): LuaMultiReturn<[number, number]>;
		/** Returns a child of the shape as an EdgeShape.
		 * @see https://love2d.org/wiki/ChainShape:getChildEdge
		 */
		getChildEdge(index: number): EdgeShape;
		/** Gets the vertex that establishes a connection to the previous shape.
		 * @see https://love2d.org/wiki/ChainShape:getPreviousVertex
		 */
		getPreviousVertex(): LuaMultiReturn<[number, number] | []>;
		/** Gets the vertex that establishes a connection to the next shape.
		 * @see https://love2d.org/wiki/ChainShape:getNextVertex
		 */
		getNextVertex(): LuaMultiReturn<[number, number] | []>;
		/** Sets a vertex that establishes a connection to the previous shape.
		 * @see https://love2d.org/wiki/ChainShape:setPreviousVertex
		 */
		setPreviousVertex(x?: number, y?: number): void;
		/** Sets a vertex that establishes a connection to the next shape.
		 * @see https://love2d.org/wiki/ChainShape:setNextVertex
		 */
		setNextVertex(x?: number, y?: number): void;
	}
	/** Fixtures attach shapes to bodies.
	 * @see https://love2d.org/wiki/Fixture
	 */
	interface Fixture extends Object {
		/** Destroys the fixture.
		 * @see https://love2d.org/wiki/Fixture:destroy
		 */
		destroy(): void;
		/** Gets whether the Fixture is destroyed. Destroyed fixtures cannot be used.
		 * @see https://love2d.org/wiki/Fixture:isDestroyed
		 */
		isDestroyed(): boolean;
		getType(): "circle" | "polygon" | "edge" | "chain";
		/** Sets the friction of the fixture.
		 * @see https://love2d.org/wiki/Fixture:setFriction
		 */
		setFriction(friction: number): void;
		/** Returns the friction of the fixture.
		 * @see https://love2d.org/wiki/Fixture:getFriction
		 */
		getFriction(): number;
		/** Sets the restitution of the fixture.
		 * @see https://love2d.org/wiki/Fixture:setRestitution
		 */
		setRestitution(restitution: number): void;
		/** Returns the restitution of the fixture.
		 * @see https://love2d.org/wiki/Fixture:getRestitution
		 */
		getRestitution(): number;
		/** Sets the density of the fixture. Call Body:resetMassData if this needs to take effect immediately.
		 * @see https://love2d.org/wiki/Fixture:setDensity
		 */
		setDensity(density: number): void;
		/** Returns the density of the fixture.
		 * @see https://love2d.org/wiki/Fixture:getDensity
		 */
		getDensity(): number;
		/** Sets whether the fixture should act as a sensor.
		 * @see https://love2d.org/wiki/Fixture:setSensor
		 */
		setSensor(sensor: boolean): void;
		/** Returns whether the fixture is a sensor.
		 * @see https://love2d.org/wiki/Fixture:isSensor
		 */
		isSensor(): boolean;
		/** Returns the body to which the fixture is attached.
		 * @see https://love2d.org/wiki/Fixture:getBody
		 */
		getBody(): Body;
		/** Returns the shape of the fixture. This shape is a reference to the actual data used in the simulation. It's possible to change its values between timesteps.
		 * @see https://love2d.org/wiki/Fixture:getShape
		 */
		getShape(): Shape;
		/** Checks if a point is inside the shape of the fixture.
		 * @see https://love2d.org/wiki/Fixture:testPoint
		 */
		testPoint(x: number, y: number): boolean;
		/** Casts a ray against the shape of the fixture and returns the surface normal vector and the line position where the ray hit. If the ray missed the shape, nil will be returned.
		 * @see https://love2d.org/wiki/Fixture:rayCast
		 */
		rayCast(x1: number, y1: number, x2: number, y2: number, maxFraction: number, childIndex?: number): LuaMultiReturn<[number, number, number] | []>;
		/** Sets the filter data of the fixture.
		 * @see https://love2d.org/wiki/Fixture:setFilterData
		 */
		setFilterData(categoryBits: number, maskBits: number, groupIndex: number): void;
		/** Returns the filter data of the fixture.
		 * @see https://love2d.org/wiki/Fixture:getFilterData
		 */
		getFilterData(): LuaMultiReturn<[number, number, number]>;
		/** Sets the categories the fixture belongs to. There can be up to 16 categories represented as a number from 1 to 16.
		 * @see https://love2d.org/wiki/Fixture:setCategory
		 */
		setCategory(categories: number[]): void;
		setCategory(...categories: number[]): void;
		/** Returns the categories the fixture belongs to.
		 * @see https://love2d.org/wiki/Fixture:getCategory
		 */
		getCategory(): LuaMultiReturn<number[]>;
		/** Sets the category mask of the fixture. There can be up to 16 categories represented as a number from 1 to 16.
		 * @see https://love2d.org/wiki/Fixture:setMask
		 */
		setMask(categories: number[]): void;
		setMask(...categories: number[]): void;
		/** Returns which categories this fixture should '''NOT''' collide with.
		 * @see https://love2d.org/wiki/Fixture:getMask
		 */
		getMask(): LuaMultiReturn<number[]>;
		/** Associates a Lua value with the fixture.
		 * @see https://love2d.org/wiki/Fixture:setUserData
		 */
		setUserData(value: unknown): void;
		/** Returns the Lua value associated with this fixture.
		 * @see https://love2d.org/wiki/Fixture:getUserData
		 */
		getUserData(): unknown;
		/** Returns the points of the fixture bounding box. In case the fixture has multiple children a 1-based index can be specified. For example, a fixture will have multiple children with a chain shape.
		 * @see https://love2d.org/wiki/Fixture:getBoundingBox
		 */
		getBoundingBox(childIndex?: number): LuaMultiReturn<[number, number, number, number]>;
		/** Returns the mass, its center and the rotational inertia.
		 * @see https://love2d.org/wiki/Fixture:getMassData
		 */
		getMassData(): LuaMultiReturn<[number, number, number, number]>;
		/** Returns the group the fixture belongs to. Fixtures with the same group will always collide if the group is positive or never collide if it's negative. The group zero means no group.
		 * @see https://love2d.org/wiki/Fixture:getGroupIndex
		 */
		getGroupIndex(): number;
		/** Sets the group the fixture belongs to. Fixtures with the same group will always collide if the group is positive or never collide if it's negative. The group zero means no group.
		 * @see https://love2d.org/wiki/Fixture:setGroupIndex
		 */
		setGroupIndex(index: number): void;
	}
	/** Attach multiple bodies together to interact in unique ways.
	 * @see https://love2d.org/wiki/Joint
	 */
	interface Joint extends Object {
		/** Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.
		 * @see https://love2d.org/wiki/Joint:destroy
		 */
		destroy(): void;
		/** Gets whether the Joint is destroyed. Destroyed joints cannot be used.
		 * @see https://love2d.org/wiki/Joint:isDestroyed
		 */
		isDestroyed(): boolean;
		/** Gets a string representing the type.
		 * @see https://love2d.org/wiki/Joint:getType
		 */
		getType(): "distance" | "revolute" | "prismatic" | "weld" | "friction" | "rope" | "pulley" | "wheel" | "mouse" | "motor" | "gear";
		/** Gets the bodies that the Joint is attached to.
		 * @see https://love2d.org/wiki/Joint:getBodies
		 */
		getBodies(): LuaMultiReturn<[Body, Body]>;
		/** Get the anchor points of the joint.
		 * @see https://love2d.org/wiki/Joint:getAnchors
		 */
		getAnchors(): LuaMultiReturn<[number, number, number, number]>;
		/** Returns the reaction force in newtons on the second body
		 * @see https://love2d.org/wiki/Joint:getReactionForce
		 */
		getReactionForce(inverseDeltaTime: number): LuaMultiReturn<[number, number]>;
		/** Returns the reaction torque on the second body.
		 * @see https://love2d.org/wiki/Joint:getReactionTorque
		 */
		getReactionTorque(inverseDeltaTime: number): number;
		/** Gets whether the connected Bodies collide.
		 * @see https://love2d.org/wiki/Joint:getCollideConnected
		 */
		getCollideConnected(): boolean;
		/** Associates a Lua value with the Joint.
		 * @see https://love2d.org/wiki/Joint:setUserData
		 */
		setUserData(value: unknown): void;
		/** Returns the Lua value associated with this Joint.
		 * @see https://love2d.org/wiki/Joint:getUserData
		 */
		getUserData(): unknown;
	}
	/** Keeps two bodies at the same distance.
	 * @see https://love2d.org/wiki/DistanceJoint
	 */
	interface DistanceJoint extends Joint {
		/** Sets the equilibrium distance between the two Bodies.
		 * @see https://love2d.org/wiki/DistanceJoint:setLength
		 */
		setLength(length: number): void;
		/** Gets the equilibrium distance between the two Bodies.
		 * @see https://love2d.org/wiki/DistanceJoint:getLength
		 */
		getLength(): number;
		/** Sets the response speed.
		 * @see https://love2d.org/wiki/DistanceJoint:setFrequency
		 */
		setFrequency(frequency: number): void;
		/** Gets the response speed.
		 * @see https://love2d.org/wiki/DistanceJoint:getFrequency
		 */
		getFrequency(): number;
		/** Sets the damping ratio.
		 * @see https://love2d.org/wiki/DistanceJoint:setDampingRatio
		 */
		setDampingRatio(ratio: number): void;
		/** Gets the damping ratio.
		 * @see https://love2d.org/wiki/DistanceJoint:getDampingRatio
		 */
		getDampingRatio(): number;
	}
	/** Allow two Bodies to revolve around a shared point.
	 * @see https://love2d.org/wiki/RevoluteJoint
	 */
	interface RevoluteJoint extends Joint {
		/** Get the current joint angle.
		 * @see https://love2d.org/wiki/RevoluteJoint:getJointAngle
		 */
		getJointAngle(): number;
		/** Get the current joint angle speed.
		 * @see https://love2d.org/wiki/RevoluteJoint:getJointSpeed
		 */
		getJointSpeed(): number;
		/** Enables/disables the joint motor.
		 * @see https://love2d.org/wiki/RevoluteJoint:setMotorEnabled
		 */
		setMotorEnabled(enabled: boolean): void;
		/** Checks whether the motor is enabled.
		 * @see https://love2d.org/wiki/RevoluteJoint:isMotorEnabled
		 */
		isMotorEnabled(): boolean;
		/** Set the maximum motor force.
		 * @see https://love2d.org/wiki/RevoluteJoint:setMaxMotorTorque
		 */
		setMaxMotorTorque(torque: number): void;
		/** Gets the maximum motor force.
		 * @see https://love2d.org/wiki/RevoluteJoint:getMaxMotorTorque
		 */
		getMaxMotorTorque(): number;
		/** Sets the motor speed.
		 * @see https://love2d.org/wiki/RevoluteJoint:setMotorSpeed
		 */
		setMotorSpeed(speed: number): void;
		/** Gets the motor speed.
		 * @see https://love2d.org/wiki/RevoluteJoint:getMotorSpeed
		 */
		getMotorSpeed(): number;
		/** Get the current motor force.
		 * @see https://love2d.org/wiki/RevoluteJoint:getMotorTorque
		 */
		getMotorTorque(inverseDeltaTime: number): number;
		/** Enables/disables the joint limit.
		 * @see https://love2d.org/wiki/RevoluteJoint:setLimitsEnabled
		 */
		setLimitsEnabled(enabled: boolean): void;
		/** Checks whether limits are enabled.
		 * @see https://love2d.org/wiki/RevoluteJoint:areLimitsEnabled
		 */
		areLimitsEnabled(): boolean;
		/** @deprecated Use areLimitsEnabled. */
		/** Checks whether limits are enabled.
		 * @see https://love2d.org/wiki/RevoluteJoint:hasLimitsEnabled
		 */
		hasLimitsEnabled(): boolean;
		/** Sets the upper limit.
		 * @see https://love2d.org/wiki/RevoluteJoint:setUpperLimit
		 */
		setUpperLimit(upper: number): void;
		/** Sets the lower limit.
		 * @see https://love2d.org/wiki/RevoluteJoint:setLowerLimit
		 */
		setLowerLimit(lower: number): void;
		/** Sets the limits.
		 * @see https://love2d.org/wiki/RevoluteJoint:setLimits
		 */
		setLimits(lower: number, upper: number): void;
		/** Gets the upper limit.
		 * @see https://love2d.org/wiki/RevoluteJoint:getUpperLimit
		 */
		getUpperLimit(): number;
		/** Gets the lower limit.
		 * @see https://love2d.org/wiki/RevoluteJoint:getLowerLimit
		 */
		getLowerLimit(): number;
		/** Gets the joint limits.
		 * @see https://love2d.org/wiki/RevoluteJoint:getLimits
		 */
		getLimits(): LuaMultiReturn<[number, number]>;
		/** Gets the reference angle.
		 * @see https://love2d.org/wiki/RevoluteJoint:getReferenceAngle
		 */
		getReferenceAngle(): number;
	}
	/** Restricts relative motion between Bodies to one shared axis.
	 * @see https://love2d.org/wiki/PrismaticJoint
	 */
	interface PrismaticJoint extends Joint {
		/** Get the current joint translation.
		 * @see https://love2d.org/wiki/PrismaticJoint:getJointTranslation
		 */
		getJointTranslation(): number;
		/** Get the current joint angle speed.
		 * @see https://love2d.org/wiki/PrismaticJoint:getJointSpeed
		 */
		getJointSpeed(): number;
		/** Enables/disables the joint motor.
		 * @see https://love2d.org/wiki/PrismaticJoint:setMotorEnabled
		 */
		setMotorEnabled(enabled: boolean): void;
		/** Checks whether the motor is enabled.
		 * @see https://love2d.org/wiki/PrismaticJoint:isMotorEnabled
		 */
		isMotorEnabled(): boolean;
		/** Set the maximum motor force.
		 * @see https://love2d.org/wiki/PrismaticJoint:setMaxMotorForce
		 */
		setMaxMotorForce(force: number): void;
		/** Gets the maximum motor force.
		 * @see https://love2d.org/wiki/PrismaticJoint:getMaxMotorForce
		 */
		getMaxMotorForce(): number;
		/** Sets the motor speed.
		 * @see https://love2d.org/wiki/PrismaticJoint:setMotorSpeed
		 */
		setMotorSpeed(speed: number): void;
		/** Gets the motor speed.
		 * @see https://love2d.org/wiki/PrismaticJoint:getMotorSpeed
		 */
		getMotorSpeed(): number;
		/** Returns the current motor force.
		 * @see https://love2d.org/wiki/PrismaticJoint:getMotorForce
		 */
		getMotorForce(inverseDeltaTime: number): number;
		/** Enables/disables the joint limit.
		 * @see https://love2d.org/wiki/PrismaticJoint:setLimitsEnabled
		 */
		setLimitsEnabled(enabled: boolean): void;
		/** Checks whether the limits are enabled.
		 * @see https://love2d.org/wiki/PrismaticJoint:areLimitsEnabled
		 */
		areLimitsEnabled(): boolean;
		/** @deprecated Use areLimitsEnabled. */
		hasLimitsEnabled(): boolean;
		/** Sets the upper limit.
		 * @see https://love2d.org/wiki/PrismaticJoint:setUpperLimit
		 */
		setUpperLimit(upper: number): void;
		/** Sets the lower limit.
		 * @see https://love2d.org/wiki/PrismaticJoint:setLowerLimit
		 */
		setLowerLimit(lower: number): void;
		/** Sets the limits.
		 * @see https://love2d.org/wiki/PrismaticJoint:setLimits
		 */
		setLimits(lower: number, upper: number): void;
		/** Gets the upper limit.
		 * @see https://love2d.org/wiki/PrismaticJoint:getUpperLimit
		 */
		getUpperLimit(): number;
		/** Gets the lower limit.
		 * @see https://love2d.org/wiki/PrismaticJoint:getLowerLimit
		 */
		getLowerLimit(): number;
		/** Gets the joint limits.
		 * @see https://love2d.org/wiki/PrismaticJoint:getLimits
		 */
		getLimits(): LuaMultiReturn<[number, number]>;
		/** Gets the world-space axis vector of the Prismatic Joint.
		 * @see https://love2d.org/wiki/PrismaticJoint:getAxis
		 */
		getAxis(): LuaMultiReturn<[number, number]>;
		/** Gets the reference angle.
		 * @see https://love2d.org/wiki/PrismaticJoint:getReferenceAngle
		 */
		getReferenceAngle(): number;
	}
	/** A WeldJoint essentially glues two bodies together.
	 * @see https://love2d.org/wiki/WeldJoint
	 */
	interface WeldJoint extends Joint {
		/** Sets a new frequency.
		 * @see https://love2d.org/wiki/WeldJoint:setFrequency
		 */
		setFrequency(frequency: number): void;
		/** Returns the frequency.
		 * @see https://love2d.org/wiki/WeldJoint:getFrequency
		 */
		getFrequency(): number;
		/** Sets a new damping ratio.
		 * @see https://love2d.org/wiki/WeldJoint:setDampingRatio
		 */
		setDampingRatio(ratio: number): void;
		/** Returns the damping ratio of the joint.
		 * @see https://love2d.org/wiki/WeldJoint:getDampingRatio
		 */
		getDampingRatio(): number;
		/** Gets the reference angle.
		 * @see https://love2d.org/wiki/WeldJoint:getReferenceAngle
		 */
		getReferenceAngle(): number;
	}
	/** A FrictionJoint applies friction to a body.
	 * @see https://love2d.org/wiki/FrictionJoint
	 */
	interface FrictionJoint extends Joint {
		/** Sets the maximum friction force in Newtons.
		 * @see https://love2d.org/wiki/FrictionJoint:setMaxForce
		 */
		setMaxForce(force: number): void;
		/** Gets the maximum friction force in Newtons.
		 * @see https://love2d.org/wiki/FrictionJoint:getMaxForce
		 */
		getMaxForce(): number;
		/** Sets the maximum friction torque in Newton-meters.
		 * @see https://love2d.org/wiki/FrictionJoint:setMaxTorque
		 */
		setMaxTorque(torque: number): void;
		/** Gets the maximum friction torque in Newton-meters.
		 * @see https://love2d.org/wiki/FrictionJoint:getMaxTorque
		 */
		getMaxTorque(): number;
	}
	/** The RopeJoint enforces a maximum distance between two points on two bodies. It has no other effect.
	 * @see https://love2d.org/wiki/RopeJoint
	 */
	interface RopeJoint extends Joint {
		/** Sets the maximum length of a RopeJoint.
		 * @see https://love2d.org/wiki/RopeJoint:setMaxLength
		 */
		setMaxLength(length: number): void;
		/** Gets the maximum length of a RopeJoint.
		 * @see https://love2d.org/wiki/RopeJoint:getMaxLength
		 */
		getMaxLength(): number;
	}
	/** Allows you to simulate bodies connected through pulleys.
	 * @see https://love2d.org/wiki/PulleyJoint
	 */
	interface PulleyJoint extends Joint {
		/** Get the ground anchor positions in world coordinates.
		 * @see https://love2d.org/wiki/PulleyJoint:getGroundAnchors
		 */
		getGroundAnchors(): LuaMultiReturn<[number, number, number, number]>;
		/** Get the current length of the rope segment attached to the first body.
		 * @see https://love2d.org/wiki/PulleyJoint:getLengthA
		 */
		getLengthA(): number;
		/** Get the current length of the rope segment attached to the second body.
		 * @see https://love2d.org/wiki/PulleyJoint:getLengthB
		 */
		getLengthB(): number;
		/** Get the pulley ratio.
		 * @see https://love2d.org/wiki/PulleyJoint:getRatio
		 */
		getRatio(): number;
	}
	/** Restricts a point on the second body to a line on the first body.
	 * @see https://love2d.org/wiki/WheelJoint
	 */
	interface WheelJoint extends Joint {
		/** Returns the current joint translation.
		 * @see https://love2d.org/wiki/WheelJoint:getJointTranslation
		 */
		getJointTranslation(): number;
		/** Returns the current joint translation speed.
		 * @see https://love2d.org/wiki/WheelJoint:getJointSpeed
		 */
		getJointSpeed(): number;
		/** Starts and stops the joint motor.
		 * @see https://love2d.org/wiki/WheelJoint:setMotorEnabled
		 */
		setMotorEnabled(enabled: boolean): void;
		/** Checks if the joint motor is running.
		 * @see https://love2d.org/wiki/WheelJoint:isMotorEnabled
		 */
		isMotorEnabled(): boolean;
		/** Sets a new speed for the motor.
		 * @see https://love2d.org/wiki/WheelJoint:setMotorSpeed
		 */
		setMotorSpeed(speed: number): void;
		/** Returns the speed of the motor.
		 * @see https://love2d.org/wiki/WheelJoint:getMotorSpeed
		 */
		getMotorSpeed(): number;
		/** Sets a new maximum motor torque.
		 * @see https://love2d.org/wiki/WheelJoint:setMaxMotorTorque
		 */
		setMaxMotorTorque(torque: number): void;
		/** Returns the maximum motor torque.
		 * @see https://love2d.org/wiki/WheelJoint:getMaxMotorTorque
		 */
		getMaxMotorTorque(): number;
		/** Returns the current torque on the motor.
		 * @see https://love2d.org/wiki/WheelJoint:getMotorTorque
		 */
		getMotorTorque(inverseDeltaTime: number): number;
		/** Sets a new spring frequency.
		 * @see https://love2d.org/wiki/WheelJoint:setSpringFrequency
		 */
		setSpringFrequency(frequency: number): void;
		/** Returns the spring frequency.
		 * @see https://love2d.org/wiki/WheelJoint:getSpringFrequency
		 */
		getSpringFrequency(): number;
		/** Sets a new damping ratio.
		 * @see https://love2d.org/wiki/WheelJoint:setSpringDampingRatio
		 */
		setSpringDampingRatio(ratio: number): void;
		/** Returns the damping ratio.
		 * @see https://love2d.org/wiki/WheelJoint:getSpringDampingRatio
		 */
		getSpringDampingRatio(): number;
		/** Gets the world-space axis vector of the Wheel Joint.
		 * @see https://love2d.org/wiki/WheelJoint:getAxis
		 */
		getAxis(): LuaMultiReturn<[number, number]>;
	}
	/** For controlling objects with the mouse.
	 * @see https://love2d.org/wiki/MouseJoint
	 */
	interface MouseJoint extends Joint {
		/** Sets the target point.
		 * @see https://love2d.org/wiki/MouseJoint:setTarget
		 */
		setTarget(x: number, y: number): void;
		/** Gets the target point.
		 * @see https://love2d.org/wiki/MouseJoint:getTarget
		 */
		getTarget(): LuaMultiReturn<[number, number]>;
		/** Sets the highest allowed force.
		 * @see https://love2d.org/wiki/MouseJoint:setMaxForce
		 */
		setMaxForce(force: number): void;
		/** Gets the highest allowed force.
		 * @see https://love2d.org/wiki/MouseJoint:getMaxForce
		 */
		getMaxForce(): number;
		/** Sets a new frequency.
		 * @see https://love2d.org/wiki/MouseJoint:setFrequency
		 */
		setFrequency(frequency: number): void;
		/** Returns the frequency.
		 * @see https://love2d.org/wiki/MouseJoint:getFrequency
		 */
		getFrequency(): number;
		/** Sets a new damping ratio.
		 * @see https://love2d.org/wiki/MouseJoint:setDampingRatio
		 */
		setDampingRatio(ratio: number): void;
		/** Returns the damping ratio.
		 * @see https://love2d.org/wiki/MouseJoint:getDampingRatio
		 */
		getDampingRatio(): number;
	}
	/** Controls the relative motion between two Bodies. Position and rotation offsets can be specified, as well as the maximum motor force and torque that will be applied to reach the target offsets.
	 * @see https://love2d.org/wiki/MotorJoint
	 */
	interface MotorJoint extends Joint {
		/** Sets the target linear offset between the two Bodies the Joint is attached to.
		 * @see https://love2d.org/wiki/MotorJoint:setLinearOffset
		 */
		setLinearOffset(x: number, y: number): void;
		/** Gets the target linear offset between the two Bodies the Joint is attached to.
		 * @see https://love2d.org/wiki/MotorJoint:getLinearOffset
		 */
		getLinearOffset(): LuaMultiReturn<[number, number]>;
		/** Sets the target angluar offset between the two Bodies the Joint is attached to.
		 * @see https://love2d.org/wiki/MotorJoint:setAngularOffset
		 */
		setAngularOffset(angle: number): void;
		/** Gets the target angular offset between the two Bodies the Joint is attached to.
		 * @see https://love2d.org/wiki/MotorJoint:getAngularOffset
		 */
		getAngularOffset(): number;
		setMaxForce(force: number): void;
		getMaxForce(): number;
		setMaxTorque(torque: number): void;
		getMaxTorque(): number;
		setCorrectionFactor(factor: number): void;
		getCorrectionFactor(): number;
	}
	/** Keeps bodies together in such a way that they act like gears.
	 * @see https://love2d.org/wiki/GearJoint
	 */
	interface GearJoint extends Joint {
		/** Set the ratio of a gear joint.
		 * @see https://love2d.org/wiki/GearJoint:setRatio
		 */
		setRatio(ratio: number): void;
		/** Get the ratio of a gear joint.
		 * @see https://love2d.org/wiki/GearJoint:getRatio
		 */
		getRatio(): number;
		/** Get the Joints connected by this GearJoint.
		 * @see https://love2d.org/wiki/GearJoint:getJoints
		 */
		getJoints(): LuaMultiReturn<[RevoluteJoint | PrismaticJoint, RevoluteJoint | PrismaticJoint]>;
	}
	/** @noSelf */
	/** Can simulate 2D rigid body physics in a realistic manner. This module is based on Box2D, and this API corresponds to the Box2D API as closely as possible.
	 * @see https://love2d.org/wiki/love.physics
	 */
	interface Physics {
		/** Sets the pixels to meter scale factor.
		 * @see https://love2d.org/wiki/love.physics.setMeter
		 */
		setMeter(scale: number): void;
		/** Returns the meter scale factor.
		 * @see https://love2d.org/wiki/love.physics.getMeter
		 */
		getMeter(): number;
		/** Creates a new World.
		 * @see https://love2d.org/wiki/love.physics.newWorld
		 */
		newWorld(xGravity?: number, yGravity?: number, sleep?: boolean): World;
		/** Creates a new body.
		 * @see https://love2d.org/wiki/love.physics.newBody
		 */
		newBody(world: World, x?: number, y?: number, type?: BodyType): Body;
		/** Creates and attaches a Fixture to a body.
		 * @see https://love2d.org/wiki/love.physics.newFixture
		 */
		newFixture(body: Body, shape: Shape, density?: number): Fixture;
		/** Creates a new CircleShape.
		 * @see https://love2d.org/wiki/love.physics.newCircleShape
		 */
		newCircleShape(radius: number): CircleShape;
		newCircleShape(x: number, y: number, radius: number): CircleShape;
		/** Shorthand for creating rectangular PolygonShapes.
		 * @see https://love2d.org/wiki/love.physics.newRectangleShape
		 */
		newRectangleShape(width: number, height: number): PolygonShape;
		newRectangleShape(x: number, y: number, width: number, height: number, angle?: number): PolygonShape;
		/** Creates a new PolygonShape.
		 * @see https://love2d.org/wiki/love.physics.newPolygonShape
		 */
		newPolygonShape(points: number[]): PolygonShape;
		newPolygonShape(...points: number[]): PolygonShape;
		/** Creates a new EdgeShape.
		 * @see https://love2d.org/wiki/love.physics.newEdgeShape
		 */
		newEdgeShape(x1: number, y1: number, x2: number, y2: number): EdgeShape;
		/** Creates a new ChainShape.
		 * @see https://love2d.org/wiki/love.physics.newChainShape
		 */
		newChainShape(loop: boolean, points: number[]): ChainShape;
		newChainShape(loop: boolean, ...points: number[]): ChainShape;
		/** Creates a DistanceJoint between two bodies.
		 * @see https://love2d.org/wiki/love.physics.newDistanceJoint
		 */
		newDistanceJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean): DistanceJoint;
		/** Creates a pivot joint between two bodies.
		 * @see https://love2d.org/wiki/love.physics.newRevoluteJoint
		 */
		newRevoluteJoint(body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): RevoluteJoint;
		newRevoluteJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean, referenceAngle?: number): RevoluteJoint;
		/** Creates a PrismaticJoint between two bodies.
		 * @see https://love2d.org/wiki/love.physics.newPrismaticJoint
		 */
		newPrismaticJoint(body1: Body, body2: Body, x: number, y: number, axisX: number, axisY: number, collideConnected?: boolean): PrismaticJoint;
		newPrismaticJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axisX: number, axisY: number, collideConnected?: boolean, referenceAngle?: number): PrismaticJoint;
		/** Creates a constraint joint between two bodies. A WeldJoint essentially glues two bodies together. The constraint is a bit soft, however, due to Box2D's iterative solver.
		 * @see https://love2d.org/wiki/love.physics.newWeldJoint
		 */
		newWeldJoint(body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): WeldJoint;
		newWeldJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean, referenceAngle?: number): WeldJoint;
		/** Create a friction joint between two bodies. A FrictionJoint applies friction to a body.
		 * @see https://love2d.org/wiki/love.physics.newFrictionJoint
		 */
		newFrictionJoint(body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): FrictionJoint;
		newFrictionJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean): FrictionJoint;
		/** Creates a joint between two bodies. Its only function is enforcing a max distance between these bodies.
		 * @see https://love2d.org/wiki/love.physics.newRopeJoint
		 */
		newRopeJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, maxLength: number, collideConnected?: boolean): RopeJoint;
		/** Creates a PulleyJoint to join two bodies to each other and the ground.
		 * @see https://love2d.org/wiki/love.physics.newPulleyJoint
		 */
		newPulleyJoint(body1: Body, body2: Body, groundX1: number, groundY1: number, groundX2: number, groundY2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collideConnected?: boolean): PulleyJoint;
		/** Creates a wheel joint.
		 * @see https://love2d.org/wiki/love.physics.newWheelJoint
		 */
		newWheelJoint(body1: Body, body2: Body, x: number, y: number, axisX: number, axisY: number, collideConnected?: boolean): WheelJoint;
		newWheelJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axisX: number, axisY: number, collideConnected?: boolean): WheelJoint;
		/** Create a joint between a body and the mouse.
		 * @see https://love2d.org/wiki/love.physics.newMouseJoint
		 */
		newMouseJoint(body: Body, x: number, y: number): MouseJoint;
		/** Creates a joint between two bodies which controls the relative motion between them.
		 * @see https://love2d.org/wiki/love.physics.newMotorJoint
		 */
		newMotorJoint(body1: Body, body2: Body, correctionFactor?: number, collideConnected?: boolean): MotorJoint;
		/** Create a GearJoint connecting two Joints.
		 * @see https://love2d.org/wiki/love.physics.newGearJoint
		 */
		newGearJoint(joint1: RevoluteJoint | PrismaticJoint, joint2: RevoluteJoint | PrismaticJoint, ratio?: number, collideConnected?: boolean): GearJoint;
	}

		interface Root {
		readonly _version: "11.5";
		readonly _version_major: 11;
		readonly _version_minor: 5;
		readonly _version_revision: 0;
		readonly graphics: Graphics;
		readonly image: ImageModule;
		readonly font: FontModule;
		readonly sound: SoundModule;
		readonly math: MathModule;
		readonly data: DataModule;
		readonly window: Window;
		readonly event: Event;
		readonly filesystem: Filesystem;
		readonly keyboard: Keyboard;
		readonly mouse: Mouse;
		readonly touch: Touch;
		readonly joystick: JoystickModule;
		readonly timer: Timer;
		readonly system: System;
		readonly thread: ThreadModule;
		readonly audio: Audio;
		readonly video: VideoModule;
		readonly physics: Physics;

		/** If a file called conf.lua is present in your game folder (or .love file), it is run before the LÖVE modules are loaded. You can use this file to overwrite the love.conf function, which is later called by the LÖVE 'boot' script. Using the love.conf function, you can set some configuration options, and change things like the default size of the window, which modules are loaded, and other stuff.
		 * @see https://love2d.org/wiki/love.conf
		 */
		conf?: (this: void, config: Config) => void;
		/** This function is called exactly once at the beginning of the game.
		 * @see https://love2d.org/wiki/love.load
		 */
		load?: (this: void) => void;
		/** Callback function used to update the state of the game every frame.
		 * @see https://love2d.org/wiki/love.update
		 */
		update?: (this: void, deltaTime: number) => void;
		/** Callback function used to draw on the screen every frame.
		 * @see https://love2d.org/wiki/love.draw
		 */
		draw?: (this: void) => void;
		/** 返回 true 可取消 love.event.quit 请求。 */
		/** Callback function triggered when the game is closed.
		 * @see https://love2d.org/wiki/love.quit
		 */
		quit?: (this: void) => boolean | void;
		/** Callback function triggered when a key is pressed.
		 * @see https://love2d.org/wiki/love.keypressed
		 */
		keypressed?: (this: void, key: string, scancode: string, isRepeat: boolean) => void;
		/** Callback function triggered when a keyboard key is released.
		 * @see https://love2d.org/wiki/love.keyreleased
		 */
		keyreleased?: (this: void, key: string, scancode: string) => void;
		/** Called when text has been entered by the user. For example if shift-2 is pressed on an American keyboard layout, the text '@' will be generated.
		 * @see https://love2d.org/wiki/love.textinput
		 */
		textinput?: (this: void, text: string) => void;
		/** Called when the candidate text for an IME (Input Method Editor) has changed.
		 * @see https://love2d.org/wiki/love.textedited
		 */
		textedited?: (this: void, text: string, start: number, length: number) => void;
		/** Callback function triggered when a mouse button is pressed.
		 * @see https://love2d.org/wiki/love.mousepressed
		 */
		mousepressed?: (this: void, x: number, y: number, button: number, isTouch: boolean, presses: number) => void;
		/** Callback function triggered when a mouse button is released.
		 * @see https://love2d.org/wiki/love.mousereleased
		 */
		mousereleased?: (this: void, x: number, y: number, button: number, isTouch: boolean, presses: number) => void;
		/** Callback function triggered when the mouse is moved.
		 * @see https://love2d.org/wiki/love.mousemoved
		 */
		mousemoved?: (this: void, x: number, y: number, deltaX: number, deltaY: number, isTouch: boolean) => void;
		/** Callback function triggered when the mouse wheel is moved.
		 * @see https://love2d.org/wiki/love.wheelmoved
		 */
		wheelmoved?: (this: void, x: number, y: number) => void;
		/** Callback function triggered when the touch screen is touched.
		 * @see https://love2d.org/wiki/love.touchpressed
		 */
		touchpressed?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		/** Callback function triggered when the touch screen stops being touched.
		 * @see https://love2d.org/wiki/love.touchreleased
		 */
		touchreleased?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		/** Callback function triggered when a touch press moves inside the touch screen.
		 * @see https://love2d.org/wiki/love.touchmoved
		 */
		touchmoved?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		/** Callback function triggered when a Thread encounters an error.
		 * @see https://love2d.org/wiki/love.threaderror
		 */
		threaderror?: (this: void, thread: Thread, error: string) => void;
		/** Called when a Joystick is connected.
		 * @see https://love2d.org/wiki/love.joystickadded
		 */
		joystickadded?: (this: void, joystick: Joystick) => void;
		/** Called when a Joystick is disconnected.
		 * @see https://love2d.org/wiki/love.joystickremoved
		 */
		joystickremoved?: (this: void, joystick: Joystick) => void;
		/** Called when a joystick button is pressed.
		 * @see https://love2d.org/wiki/love.joystickpressed
		 */
		joystickpressed?: (this: void, joystick: Joystick, button: number) => void;
		/** Called when a joystick button is released.
		 * @see https://love2d.org/wiki/love.joystickreleased
		 */
		joystickreleased?: (this: void, joystick: Joystick, button: number) => void;
		/** Called when a joystick axis moves.
		 * @see https://love2d.org/wiki/love.joystickaxis
		 */
		joystickaxis?: (this: void, joystick: Joystick, axis: number, value: number) => void;
		/** Called when a joystick hat direction changes.
		 * @see https://love2d.org/wiki/love.joystickhat
		 */
		joystickhat?: (this: void, joystick: Joystick, hat: number, direction: JoystickHat) => void;
		/** Called when a Joystick's virtual gamepad button is pressed.
		 * @see https://love2d.org/wiki/love.gamepadpressed
		 */
		gamepadpressed?: (this: void, joystick: Joystick, button: GamepadButton) => void;
		/** Called when a Joystick's virtual gamepad button is released.
		 * @see https://love2d.org/wiki/love.gamepadreleased
		 */
		gamepadreleased?: (this: void, joystick: Joystick, button: GamepadButton) => void;
		/** Called when a Joystick's virtual gamepad axis is moved.
		 * @see https://love2d.org/wiki/love.gamepadaxis
		 */
		gamepadaxis?: (this: void, joystick: Joystick, axis: GamepadAxis, value: number) => void;

		/** 兼容入口。Dora 始终是唯一的应用主循环所有者。 */
		/** The main function, containing the main loop. A sensible default is used when left out.
		 * @see https://love2d.org/wiki/love.run
		 */
		run(this: void): void;
		}
	}

	const love: Love.Root;
}

declare const loveModule: Love.Root;
export = loveModule;
