/**
 * LÖVE 11.5 API documentation, including parameter and return value descriptions,
 * is adapted from the official LÖVE Wiki.
 * Copyright © 2006-2010 LÖVE Development Team. Documentation is redistributed
 * under the FreeBSD Documentation License.
 * Dora-specific compatibility notes remain explicitly marked as such.
 */
/////////////////////////////
/// Love 11.5 API (implemented subset)
/////////////////////////////

declare global {
	namespace Love {
	type DrawMode = "fill" | "line";
	type ArcMode = "open" | "closed" | "pie";
	type LineStyle = "rough" | "smooth";
	type LineJoin = "none" | "miter" | "bevel";
	type BlendMode = "alpha" | "add" | "subtract" | "multiply" | "replace" | "screen" | "premultiplied";
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
		/** Compatibility alias used by existing Love TypeScript definitions; Love 11.5 uses Config.title. */
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
	 */
	interface Object {
		/**
		 * Gets the type of the object as a string.
		 *
		 * @returns type — The type as a string.
		 */
		type(): string;
		/**
		 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 *
		 * @param typeName The name of the type to check for.
		 *
		 * @returns b — True if the object is of the specified type, false otherwise.
		 */
		typeOf(typeName: string): boolean;
		/**
		 * Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other LÖVE object or thread.
		 *
		 * This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
		 *
		 * @returns success — True if the object was released by this call, false if it had been previously released.
		 */
		release(): boolean;
	}
		/** Drawable image type.
		 */
		interface Image extends Object {
			/**
			 * Gets the type of the object as a string.
			 *
			 * @returns type — The type as a string.
			 */
			type(): "Image";
			/**
			 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
			 *
			 * @param typeName The name of the type to check for.
			 *
			 * @returns b — True if the object is of the specified type, false otherwise.
			 */
			typeOf(typeName: string): boolean;
			/**
			 * Gets the width of the Texture.
			 *
			 * @returns width — The width of the Texture.
			 */
			getWidth(): number;
			/**
			 * Gets the height of the Texture.
			 *
			 * @returns height — The height of the Texture.
			 */
			getHeight(): number;
			/**
			 * Gets the width and height of the Texture.
			 *
			 * @returns width — The width of the Texture.
			 * @returns height — The height of the Texture.
			 */
			getDimensions(): LuaMultiReturn<[number, number]>;
			/**
			 * Gets the type of the Texture.
			 *
			 * @returns texturetype — The type of the Texture.
			 */
			getTextureType(): TextureType;
			/**
			 * Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.
			 *
			 * @returns depth — The depth of the volume Texture.
			 */
			getDepth(): number;
			/**
			 * Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.
			 *
			 * @returns layers — The number of layers in the Array Texture.
			 */
			getLayerCount(): number;
			/**
			 * Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will return 1.
			 *
			 * @returns mipmaps — The number of mipmaps in the Texture.
			 */
			getMipmapCount(): number;
			/**
			 * Gets the width in pixels of the Texture.
			 *
			 * DPI scale factor, rather than pixels. Use getWidth for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelWidth only when dealing specifically with pixels, for example when using Canvas:newImageData.
			 *
			 * @returns pixelwidth — The width of the Texture, in pixels.
			 */
			getPixelWidth(): number;
			/**
			 * Gets the height in pixels of the Texture.
			 *
			 * DPI scale factor, rather than pixels. Use getHeight for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelHeight only when dealing specifically with pixels, for example when using Canvas:newImageData.
			 *
			 * @returns pixelheight — The height of the Texture, in pixels.
			 */
			getPixelHeight(): number;
			/**
			 * Gets the width and height in pixels of the Texture.
			 *
			 * Texture:getDimensions gets the dimensions of the texture in units scaled by the texture's DPI scale factor, rather than pixels. Use getDimensions for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelDimensions only when dealing specifically with pixels, for example when using Canvas:newImageData.
			 *
			 * @returns pixelwidth — The width of the Texture, in pixels.
			 * @returns pixelheight — The height of the Texture, in pixels.
			 */
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			/**
			 * Gets the DPI scale factor of the Texture.
			 *
			 * The DPI scale factor represents relative pixel density. A DPI scale factor of 2 means the texture has twice the pixel density in each dimension (4 times as many pixels in the same area) compared to a texture with a DPI scale factor of 1.
			 *
			 * For example, a texture with pixel dimensions of 100x100 with a DPI scale factor of 2 will be drawn as if it was 50x50. This is useful with high-dpi / retina displays to easily allow swapping out higher or lower pixel density Images and Canvases without needing any extra manual scaling logic.
			 *
			 * @returns dpiscale — The DPI scale factor of the Texture.
			 */
			getDPIScale(): number;
			/**
			 * Sets the filter mode of the Texture.
			 *
			 * @param min Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).
			 * @param mag Filter mode to use when magnifying the texture (rendering it at a larger size on-screen than its size in pixels). (Default: min.)
			 * @param anisotropy Maximum amount of anisotropic filtering to use. (Default: 1.)
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/**
			 * Gets the filter mode of the Texture.
			 *
			 * @returns min — Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).
			 * @returns mag — Filter mode to use when magnifying the texture (rendering it at a smaller size on-screen than its size in pixels).
			 * @returns anisotropy — Maximum amount of anisotropic filtering used.
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			/**
			 * Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
			 *
			 * Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.
			 *
			 * In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.
			 *
			 * Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.
			 *
			 */
			setMipmapFilter(): void;
/**
 * Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
 *
 * Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.
 *
 * In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.
 *
 * Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.
 *

 * @param filter The filter mode to use in between mipmap levels. 'nearest' will often give better performance.
 * @param sharpness A positive sharpness value makes the texture use a more detailed mipmap level when drawing, at the expense of performance. A negative value does the reverse. (Default: 0.)
 */
			setMipmapFilter(filter: FilterMode, sharpness?: number): void;
			/**
			 * Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
			 *
			 * @returns mode — The filter mode used in between mipmap levels. nil if mipmap filtering is not enabled.
			 * @returns sharpness — Value used to determine whether the image should use more or less detailed mipmap levels than normal when drawing.
			 */
			getMipmapFilter(): LuaMultiReturn<[FilterMode | undefined, number]>;
			/**
			 * Sets the wrapping properties of a Texture.
			 *
			 * This function sets the way a Texture is repeated when it is drawn with a Quad that is larger than the texture's extent, or when a custom Shader is used which uses texture coordinates outside of [0, 1]. A texture may be clamped or set to repeat in both horizontal and vertical directions.
			 *
			 * Clamped textures appear only once (with the edges of the texture stretching to fill the extent of the Quad), whereas repeated ones repeat as many times as there is room in the Quad.
			 *
			 * @param horizontal Horizontal wrapping mode of the texture.
			 * @param vertical Vertical wrapping mode of the texture. (Default: horiz.)
			 * @param depth Wrapping mode for the z-axis of a Volume texture. (Default: horiz.)
			 */
			setWrap(horizontal: WrapMode, vertical?: WrapMode, depth?: WrapMode): boolean;
			/**
			 * Gets the wrapping properties of a Texture.
			 *
			 * This function returns the currently set horizontal and vertical wrapping modes for the texture.
			 *
			 * @returns horiz — Horizontal wrapping mode of the texture.
			 * @returns vert — Vertical wrapping mode of the texture.
			 * @returns depth — Wrapping mode for the z-axis of a Volume texture.
			 */
			getWrap(): LuaMultiReturn<[WrapMode, WrapMode, WrapMode]>;
			/**
			 * Gets the pixel format of the Texture.
			 *
			 * @returns format — The pixel format the Texture was created with.
			 */
			getFormat(): string;
			/**
			 * Gets whether the Texture can be drawn and sent to a Shader.
			 *
			 * Canvases created with stencil and/or depth PixelFormats are not readable by default, unless readable=true is specified in the settings table passed into love.graphics.newCanvas.
			 *
			 * Non-readable Canvases can still be rendered to.
			 *
			 * @returns readable — Whether the Texture is readable.
			 */
			isReadable(): boolean;
			/**
			 * Gets whether the Image was created from CompressedData.
			 *
			 * Compressed images take up less space in VRAM, and drawing a compressed image will generally be more efficient than drawing one created from raw pixel data.
			 *
			 * @returns compressed — Whether the Image is stored as a compressed texture on the GPU.
			 */
			isCompressed(): boolean;
			/**
			 * Gets whether the Image was created with the linear (non-gamma corrected) flag set to true.
			 *
			 * This method always returns false when gamma-correct rendering is not enabled.
			 *
			 * @returns linear — Whether the Image's internal pixel format is linear (not gamma corrected), when gamma-correct rendering is enabled.
			 */
			isFormatLinear(): boolean;
			/**
			 * Replace the contents of an Image.
			 *
			 * @param data The new ImageData to replace the contents with.
			 * @param slice Which cubemap face, array index, or volume layer to replace, if applicable. (Default: 1.)
			 * @param mipmap The mimap level to replace, if the Image has mipmaps. (Default: 1.)
			 * @param x The x-offset in pixels from the top-left of the image to replace. The given ImageData's width plus this value must not be greater than the pixel width of the Image's specified mipmap level. (Default: 0.)
			 * @param y The y-offset in pixels from the top-left of the image to replace. The given ImageData's height plus this value must not be greater than the pixel height of the Image's specified mipmap level. (Default: 0.)
			 * @param reloadMipmaps Whether to generate new mipmaps after replacing the Image's pixels. True by default if the Image was created with automatically generated mipmaps, false by default otherwise. (Default: false.)
			 */
			replacePixels(data: ImageData, slice?: number, mipmap?: number, x?: number, y?: number, reloadMipmaps?: boolean): void;
			/**
			 * Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.
			 *
			 * When using a depth texture with a comparison mode set in a shader, it must be declared as a sampler2DShadow and used in a GLSL 3 Shader. The result of accessing the texture in the shader will return a float between 0 and 1, proportional to the number of samples (up to 4 samples will be used if bilinear filtering is enabled) that passed the test set by the comparison operation.
			 *
			 * Depth texture comparison can only be used with readable depth-formatted Canvases.
			 *
			 * @param compare The comparison mode used when sampling from this texture in a shader.
			 */
			setDepthSampleMode(compare?: CompareMode): void;
			/**
			 * Gets the comparison mode used when sampling from a depth texture in a shader.
			 *
			 * Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.
			 *
			 * @returns compare — The comparison mode used when sampling from this texture in a shader, or nil if setDepthSampleMode has not been called on this Texture. (Default: nil.)
			 */
			getDepthSampleMode(): CompareMode | undefined;
		}
		/** An object which decodes, streams, and controls Videos.
		 */
		interface VideoStream extends Object {
			/**
			 * Gets the type of the object as a string.
			 *
			 * @returns type — The type as a string.
			 */
			type(): "VideoStream";
			/**
			 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
			 *
			 * @param typeName The name of the type to check for.
			 *
			 * @returns b — True if the object is of the specified type, false otherwise.
			 */
			typeOf(typeName: string): boolean;
			/**
			 * Plays the VideoStream.
			 */
			play(): void;
			/**
			 * Pauses the VideoStream.
			 */
			pause(): void;
			/**
			 * Sets the current playback position of the VideoStream.
			 *
			 * @param seconds The time in seconds since the beginning of the VideoStream.
			 */
			seek(seconds: number): void;
			/**
			 * Rewinds the VideoStream. Synonym to VideoStream:seek(0).
			 */
			rewind(): void;
			/**
			 * Gets the current playback position of the VideoStream.
			 *
			 * @returns seconds — The number of seconds sionce the beginning of the VideoStream.
			 */
			tell(): number;
			/**
			 * Gets whether the VideoStream is playing.
			 *
			 * @returns playing — Whether the VideoStream is playing.
			 */
			isPlaying(): boolean;
			/**
			 * Gets the filename of the VideoStream.
			 *
			 * @returns filename — The filename of the VideoStream
			 */
			getFilename(): string;
			setSync(source?: Source): void;
		}
		/** A drawable video.
		 */
		interface Video extends Object {
			/**
			 * Gets the type of the object as a string.
			 *
			 * @returns type — The type as a string.
			 */
			type(): "Video";
			/**
			 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
			 *
			 * @param typeName The name of the type to check for.
			 *
			 * @returns b — True if the object is of the specified type, false otherwise.
			 */
			typeOf(typeName: string): boolean;
			/**
			 * Gets the VideoStream object used for decoding and controlling the video.
			 *
			 * @returns stream — The VideoStream used for decoding and controlling the video.
			 */
			getStream(): VideoStream;
			/**
			 * Gets the audio Source used for playing back the video's audio. May return nil if the video has no audio, or if Video:setSource is called with a nil argument.
			 *
			 * @returns source — The audio Source used for audio playback, or nil if the video has no audio.
			 */
			getSource(): Source | undefined;
			/**
			 * Sets the audio Source used for playing back the video's audio. The audio Source also controls playback speed and synchronization.
			 *
			 * @param source The audio Source used for audio playback, or nil to disable audio synchronization. (Default: nil.)
			 */
			setSource(source?: Source): void;
			/**
			 * Gets the width of the Video in pixels.
			 *
			 * @returns width — The width of the Video.
			 */
			getWidth(): number;
			/**
			 * Gets the height of the Video in pixels.
			 *
			 * @returns height — The height of the Video.
			 */
			getHeight(): number;
			/**
			 * Gets the width and height of the Video in pixels.
			 *
			 * @returns width — The width of the Video.
			 * @returns height — The height of the Video.
			 */
			getDimensions(): LuaMultiReturn<[number, number]>;
			getPixelWidth(): number;
			getPixelHeight(): number;
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			/**
			 * Sets the scaling filters used when drawing the Video.
			 *
			 * @param min The filter mode used when scaling the Video down.
			 * @param mag The filter mode used when scaling the Video up.
			 * @param anisotropy Maximum amount of anisotropic filtering used. (Default: 1.)
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/**
			 * Gets the scaling filters used when drawing the Video.
			 *
			 * @returns min — The filter mode used when scaling the Video down.
			 * @returns mag — The filter mode used when scaling the Video up.
			 * @returns anisotropy — Maximum amount of anisotropic filtering used.
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
		}
		/** This module is responsible for decoding, controlling, and streaming video files.
		 */
		interface VideoModule { newVideoStream(filename: string): VideoStream; }
		/** A Canvas is used for off-screen rendering. Think of it as an invisible screen that you can draw to, but that will not be visible until you draw it to the actual visible screen. It is also known as "render to texture".
		 */
		interface Canvas extends Object {
			/**
			 * Gets the type of the object as a string.
			 *
			 * @returns type — The type as a string.
			 */
			type(): "Canvas";
			/**
			 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
			 *
			 * @param typeName The name of the type to check for.
			 *
			 * @returns b — True if the object is of the specified type, false otherwise.
			 */
			typeOf(typeName: string): boolean;
			/**
			 * Gets the width of the Texture.
			 *
			 * @returns width — The width of the Texture.
			 */
			getWidth(): number;
			/**
			 * Gets the height of the Texture.
			 *
			 * @returns height — The height of the Texture.
			 */
			getHeight(): number;
			/**
			 * Gets the width and height of the Texture.
			 *
			 * @returns width — The width of the Texture.
			 * @returns height — The height of the Texture.
			 */
			getDimensions(): LuaMultiReturn<[number, number]>;
			/**
			 * Gets the width in pixels of the Texture.
			 *
			 * DPI scale factor, rather than pixels. Use getWidth for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelWidth only when dealing specifically with pixels, for example when using Canvas:newImageData.
			 *
			 * @returns pixelwidth — The width of the Texture, in pixels.
			 */
			getPixelWidth(): number;
			/**
			 * Gets the height in pixels of the Texture.
			 *
			 * DPI scale factor, rather than pixels. Use getHeight for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelHeight only when dealing specifically with pixels, for example when using Canvas:newImageData.
			 *
			 * @returns pixelheight — The height of the Texture, in pixels.
			 */
			getPixelHeight(): number;
			/**
			 * Gets the width and height in pixels of the Texture.
			 *
			 * Texture:getDimensions gets the dimensions of the texture in units scaled by the texture's DPI scale factor, rather than pixels. Use getDimensions for calculations related to drawing the texture (calculating an origin offset, for example), and getPixelDimensions only when dealing specifically with pixels, for example when using Canvas:newImageData.
			 *
			 * @returns pixelwidth — The width of the Texture, in pixels.
			 * @returns pixelheight — The height of the Texture, in pixels.
			 */
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			/**
			 * Gets the DPI scale factor of the Texture.
			 *
			 * The DPI scale factor represents relative pixel density. A DPI scale factor of 2 means the texture has twice the pixel density in each dimension (4 times as many pixels in the same area) compared to a texture with a DPI scale factor of 1.
			 *
			 * For example, a texture with pixel dimensions of 100x100 with a DPI scale factor of 2 will be drawn as if it was 50x50. This is useful with high-dpi / retina displays to easily allow swapping out higher or lower pixel density Images and Canvases without needing any extra manual scaling logic.
			 *
			 * @returns dpiscale — The DPI scale factor of the Texture.
			 */
			getDPIScale(): number;
			/**
			 * Gets the type of the Texture.
			 *
			 * @returns texturetype — The type of the Texture.
			 */
			getTextureType(): TextureType;
			/**
			 * Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.
			 *
			 * @returns depth — The depth of the volume Texture.
			 */
			getDepth(): number;
			/**
			 * Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.
			 *
			 * @returns layers — The number of layers in the Array Texture.
			 */
			getLayerCount(): number;
			/**
			 * Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will return 1.
			 *
			 * @returns mipmaps — The number of mipmaps in the Texture.
			 */
			getMipmapCount(): number;
			/**
			 * Gets the MipmapMode this Canvas was created with.
			 *
			 * @returns mode — The mipmap mode this Canvas was created with.
			 */
			getMipmapMode(): string;
			/**
			 * Gets the pixel format of the Texture.
			 *
			 * @returns format — The pixel format the Texture was created with.
			 */
			getFormat(): CanvasFormat;
			/**
			 * Gets the number of multisample antialiasing (MSAA) samples used when drawing to the Canvas.
			 *
			 * This may be different than the number used as an argument to love.graphics.newCanvas if the system running LÖVE doesn't support that number.
			 *
			 * @returns samples — The number of multisample antialiasing samples used by the canvas when drawing to it.
			 */
			getMSAA(): 0 | 2 | 4 | 8 | 16;
			/**
			 * Gets whether the Texture can be drawn and sent to a Shader.
			 *
			 * Canvases created with stencil and/or depth PixelFormats are not readable by default, unless readable=true is specified in the settings table passed into love.graphics.newCanvas.
			 *
			 * Non-readable Canvases can still be rendered to.
			 *
			 * @returns readable — Whether the Texture is readable.
			 */
			isReadable(): boolean;
			/**
			 * Generates ImageData from the contents of the Canvas.
			 *
			 * @param slice The cubemap face index, array index, or depth layer for cubemap, array, or volume type Canvases, respectively. This argument is ignored for regular 2D canvases.
			 * @param mipmap The mipmap index to use, for Canvases with mipmaps. (Default: 1.)
			 * @param x The x-axis of the top-left corner (in pixels) of the area within the Canvas to capture.
			 * @param y The y-axis of the top-left corner (in pixels) of the area within the Canvas to capture.
			 * @param width The width in pixels of the area within the Canvas to capture.
			 * @param height The height in pixels of the area within the Canvas to capture.
			 *
			 * @returns data — The new ImageData made from the Canvas' contents.
			 */
			newImageData(slice?: 1, mipmap?: 1, x?: number, y?: number, width?: number, height?: number): ImageData;
			/**
			 * Sets the filter mode of the Texture.
			 *
			 * @param min Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).
			 * @param mag Filter mode to use when magnifying the texture (rendering it at a larger size on-screen than its size in pixels). (Default: min.)
			 * @param anisotropy Maximum amount of anisotropic filtering to use. (Default: 1.)
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/**
			 * Gets the filter mode of the Texture.
			 *
			 * @returns min — Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).
			 * @returns mag — Filter mode to use when magnifying the texture (rendering it at a smaller size on-screen than its size in pixels).
			 * @returns anisotropy — Maximum amount of anisotropic filtering used.
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			/**
			 * Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
			 *
			 * Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.
			 *
			 * In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.
			 *
			 * Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.
			 *
			 */
			setMipmapFilter(): void;
/**
 * Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
 *
 * Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.
 *
 * In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.
 *
 * Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.
 *

 * @param filter The filter mode to use in between mipmap levels. 'nearest' will often give better performance.
 * @param sharpness A positive sharpness value makes the texture use a more detailed mipmap level when drawing, at the expense of performance. A negative value does the reverse. (Default: 0.)
 */
			setMipmapFilter(filter: FilterMode, sharpness?: number): void;
			/**
			 * Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
			 *
			 * @returns mode — The filter mode used in between mipmap levels. nil if mipmap filtering is not enabled.
			 * @returns sharpness — Value used to determine whether the image should use more or less detailed mipmap levels than normal when drawing.
			 */
			getMipmapFilter(): LuaMultiReturn<[FilterMode | undefined, number]>;
			/**
			 * Sets the wrapping properties of a Texture.
			 *
			 * This function sets the way a Texture is repeated when it is drawn with a Quad that is larger than the texture's extent, or when a custom Shader is used which uses texture coordinates outside of [0, 1]. A texture may be clamped or set to repeat in both horizontal and vertical directions.
			 *
			 * Clamped textures appear only once (with the edges of the texture stretching to fill the extent of the Quad), whereas repeated ones repeat as many times as there is room in the Quad.
			 *
			 * @param horizontal Horizontal wrapping mode of the texture.
			 * @param vertical Vertical wrapping mode of the texture. (Default: horiz.)
			 * @param depth Wrapping mode for the z-axis of a Volume texture. (Default: horiz.)
			 */
			setWrap(horizontal: WrapMode, vertical?: WrapMode, depth?: WrapMode): boolean;
			/**
			 * Gets the wrapping properties of a Texture.
			 *
			 * This function returns the currently set horizontal and vertical wrapping modes for the texture.
			 *
			 * @returns horiz — Horizontal wrapping mode of the texture.
			 * @returns vert — Vertical wrapping mode of the texture.
			 * @returns depth — Wrapping mode for the z-axis of a Volume texture.
			 */
			getWrap(): LuaMultiReturn<[WrapMode, WrapMode, WrapMode]>;
			/**
			 * Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.
			 *
			 * When using a depth texture with a comparison mode set in a shader, it must be declared as a sampler2DShadow and used in a GLSL 3 Shader. The result of accessing the texture in the shader will return a float between 0 and 1, proportional to the number of samples (up to 4 samples will be used if bilinear filtering is enabled) that passed the test set by the comparison operation.
			 *
			 * Depth texture comparison can only be used with readable depth-formatted Canvases.
			 *
			 * @param compare The comparison mode used when sampling from this texture in a shader.
			 */
			setDepthSampleMode(compare?: CompareMode): void;
			/**
			 * Gets the comparison mode used when sampling from a depth texture in a shader.
			 *
			 * Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.
			 *
			 * @returns compare — The comparison mode used when sampling from this texture in a shader, or nil if setDepthSampleMode has not been called on this Texture. (Default: nil.)
			 */
			getDepthSampleMode(): CompareMode | undefined;
			/**
			 * Generates mipmaps for the Canvas, based on the contents of the highest-resolution mipmap level.
			 *
			 * The Canvas must be created with mipmaps set to a MipmapMode other than 'none' for this function to work. It should only be called while the Canvas is not the active render target.
			 *
			 * If the mipmap mode is set to 'auto', this function is automatically called inside love.graphics.setCanvas when switching from this Canvas to another Canvas or to the main screen.
			 */
			generateMipmaps(): void;
			/**
			 * Render to the Canvas using a function.
			 *
			 * This is a shortcut to love.graphics.setCanvas:
			 *
			 * canvas:renderTo( func )
			 *
			 * is the same as
			 *
			 * love.graphics.setCanvas( canvas )
			 *
			 * func()
			 *
			 * love.graphics.setCanvas()
			 *
			 * @param callback A function performing drawing operations.
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
		 */
		interface Font extends Object {
			/**
			 * Gets the type of the object as a string.
			 *
			 * @returns type — The type as a string.
			 */
			type(): "Font";
			/**
			 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
			 *
			 * @param type The name of the type to check for.
			 *
			 * @returns b — True if the object is of the specified type, false otherwise.
			 */
			typeOf(type: string): boolean;
			/**
			 * Determines the maximum width (accounting for newlines) taken by the given string.
			 *
			 * @param text A string.
			 *
			 * @returns width — The width of the text.
			 */
			getWidth(text: string): number;
			/**
			 * Gets the height of the Font.
			 *
			 * The height of the font is the size including any spacing; the height which it will need.
			 *
			 * @returns height — The height of the Font in pixels.
			 */
			getHeight(): number;
			/**
			 * Gets the baseline of the Font.
			 *
			 * Most scripts share the notion of a baseline: an imaginary horizontal line on which characters rest. In some scripts, parts of glyphs lie below the baseline.
			 *
			 * @returns baseline — The baseline of the Font in pixels.
			 */
			getBaseline(): number;
			/**
			 * Gets the ascent of the Font.
			 *
			 * The ascent spans the distance between the baseline and the top of the glyph that reaches farthest from the baseline.
			 *
			 * @returns ascent — The ascent of the Font in pixels.
			 */
			getAscent(): number;
			/**
			 * Gets the descent of the Font.
			 *
			 * The descent spans the distance between the baseline and the lowest descending glyph in a typeface.
			 *
			 * @returns descent — The descent of the Font in pixels.
			 */
			getDescent(): number;
			/**
			 * Gets whether the Font can render a character or string.
			 *
			 * @param textOrCodepoints A UTF-8 encoded unicode string.
			 *
			 * @returns hasglyph — Whether the font can render all the UTF-8 characters in the string. Depending on the overload: Whether the font can render all the glyphs represented by the characters. Depending on the overload: Whether the font can render all the glyphs represented by the codepoint numbers.
			 */
			hasGlyphs(...textOrCodepoints: (string | number)[]): boolean;
			/**
			 * Gets the kerning between two characters in the Font.
			 *
			 * Kerning is normally handled automatically in love.graphics.print, Text objects, Font:getWidth, Font:getWrap, etc. This function is useful when stitching text together manually.
			 *
			 * @param left The left character. Depending on the overload: The unicode number for the left glyph.
			 * @param right The right character. Depending on the overload: The unicode number for the right glyph.
			 *
			 * @returns kerning — The kerning amount to add to the spacing between the two characters. May be negative.
			 */
			getKerning(left: string | number, right: string | number): number;
			/**
			 * Sets the fallback fonts. When the Font doesn't contain a glyph, it will substitute the glyph from the next subsequent fallback Fonts. This is akin to setting a 'font stack' in Cascading Style Sheets (CSS).
			 *
			 * Overload details:
			 * 1. If this is called it should be before love.graphics.print, Font:getWrap, and other Font methods which use glyph positioning information are called. Every fallback Font must be created from the same file type as the primary Font. For example, a Font created from a .ttf file can only use fallback Fonts that were created from .ttf files.
			 *
			 * @param fallbacks The first fallback Font to use.
			 */
			setFallbacks(...fallbacks: Font[]): void;
			/**
			 * Sets the line height.
			 *
			 * When rendering the font in lines the actual height will be determined by the line height multiplied by the height of the font. The default is 1.0.
			 *
			 * @param height The new line height.
			 */
			setLineHeight(height: number): void;
			/**
			 * Gets the line height.
			 *
			 * This will be the value previously set by Font:setLineHeight, or 1.0 by default.
			 *
			 * @returns height — The current line height.
			 */
			getLineHeight(): number;
			/**
			 * Gets the DPI scale factor of the Font.
			 *
			 * The DPI scale factor represents relative pixel density. A DPI scale factor of 2 means the font's glyphs have twice the pixel density in each dimension (4 times as many pixels in the same area) compared to a font with a DPI scale factor of 1.
			 *
			 * The font size of TrueType fonts is scaled internally by the font's specified DPI scale factor. By default, LÖVE uses the screen's DPI scale factor when creating TrueType fonts.
			 *
			 * @returns dpiscale — The DPI scale factor of the Font.
			 */
			getDPIScale(): number;
			/**
			 * Gets the filter mode for a font.
			 *
			 * @returns min — Filter mode used when minifying the font.
			 * @returns mag — Filter mode used when magnifying the font.
			 * @returns anisotropy — Maximum amount of anisotropic filtering used.
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			/**
			 * Sets the filter mode for a font.
			 *
			 * @param min How to scale a font down.
			 * @param mag How to scale a font up.
			 * @param anisotropy Maximum amount of anisotropic filtering used. (Default: 1.)
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/**
			 * Gets formatting information for text, given a wrap limit.
			 *
			 * This function accounts for newlines correctly (i.e. '\n').
			 *
			 * @param text The text that will be wrapped.
			 * @param wrapLimit The maximum width in pixels of each line that ''text'' is allowed before wrapping.
			 *
			 * @returns width — The maximum width of the wrapped text.
			 * @returns wrappedtext — A sequence containing each line of text that was wrapped.
			 */
			getWrap(text: string, wrapLimit: number): LuaMultiReturn<[number, string[]]>;
		}
		/** Drawable text.
		 */
		interface Text extends Object {
			/**
			 * Replaces the contents of the Text object with a new unformatted string.
			 *

			 * @param text The new string of text to use.
			 */
			set(text: string): void;
/**
 * Replaces the contents of the Text object with a new unformatted string.
 *

 * @param text A table containing colors and strings to use as the new text, in the form of {color1, string1, color2, string2, ...}.
 */
			set(text: (string | Color)[]): void;
			/**
			 * Replaces the contents of the Text object with a new formatted string.
			 *

			 * @param text The new string of text to use.
			 * @param wrapLimit The maximum width in pixels of the text before it gets automatically wrapped to a new line.
			 * @param align The alignment of the text.
			 */
			setf(text: string, wrapLimit: number, align: AlignMode): void;
/**
 * Replaces the contents of the Text object with a new formatted string.
 *

 * @param text A table containing colors and strings to use as the new text, in the form of {color1, string1, color2, string2, ...}.
 * @param wrapLimit The maximum width in pixels of the text before it gets automatically wrapped to a new line.
 * @param align The alignment of the text.
 */
			setf(text: (string | Color)[], wrapLimit: number, align: AlignMode): void;
			/**
			 * Adds additional colored text to the Text object at the specified position.
			 *

			 * @param text The text to add to the object.
			 * @param transform The position of the new text on the x-axis. (Default: 0.)
			 * @returns index — An index number that can be used with Text:getWidth or Text:getHeight.
			 */
			add(text: ColoredText, transform: Transform): number;
			/**
			 * Adds additional colored text to the Text object at the specified position.
			 *

			 * @param text A table containing colors and strings to add to the object, in the form of {color1, string1, color2, string2, ...}.
			 * @param x The position of the new text on the x-axis. (Default: 0.)
			 * @param y The position of the new text on the y-axis. (Default: 0.)
			 * @param angle The orientation of the new text in radians. (Default: 0.)
			 * @param scaleX Scale factor on the x-axis. (Default: 1.)
			 * @param scaleY Scale factor on the y-axis. (Default: sx.)
			 * @param originX Origin offset on the x-axis. (Default: 0.)
			 * @param originY Origin offset on the y-axis. (Default: 0.)
			 * @param shearX Shearing / skew factor on the x-axis. (Default: 0.)
			 * @param shearY Shearing / skew factor on the y-axis. (Default: 0.)
			 * @returns index — An index number that can be used with Text:getWidth or Text:getHeight.
			 */
			add(text: ColoredText, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/**
			 * Adds additional formatted / colored text to the Text object at the specified position.
			 *
			 * The word wrap limit is applied before any scaling, rotation, and other coordinate transformations. Therefore the amount of text per line stays constant given the same wrap limit, even if the scale arguments change.
			 *

			 * @param text The text to add to the object.
			 * @param wrapLimit The maximum width in pixels of the text before it gets automatically wrapped to a new line.
			 * @param align The alignment of the text.
			 * @param transform The position of the new text (x-axis).
			 * @returns index — An index number that can be used with Text:getWidth or Text:getHeight.
			 */
			addf(text: ColoredText, wrapLimit: number, align: AlignMode, transform: Transform): number;
			/**
			 * Adds additional formatted / colored text to the Text object at the specified position.
			 *
			 * The word wrap limit is applied before any scaling, rotation, and other coordinate transformations. Therefore the amount of text per line stays constant given the same wrap limit, even if the scale arguments change.
			 *

			 * @param text A table containing colors and strings to add to the object, in the form of {color1, string1, color2, string2, ...}.
			 * @param wrapLimit The maximum width in pixels of the text before it gets automatically wrapped to a new line.
			 * @param align The alignment of the text.
			 * @param x The position of the new text (x-axis).
			 * @param y The position of the new text (y-axis).
			 * @param angle Orientation (radians). (Default: 0.)
			 * @param scaleX Scale factor (x-axis). (Default: 1.)
			 * @param scaleY Scale factor (y-axis). (Default: sx.)
			 * @param originX Origin offset (x-axis). (Default: 0.)
			 * @param originY Origin offset (y-axis). (Default: 0.)
			 * @param shearX Shearing / skew factor (x-axis). (Default: 0.)
			 * @param shearY Shearing / skew factor (y-axis). (Default: 0.)
			 * @returns index — An index number that can be used with Text:getWidth or Text:getHeight.
			 */
			addf(text: ColoredText, wrapLimit: number, align: AlignMode, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/**
			 * Clears the contents of the Text object.
			 */
			clear(): void;
			/**
			 * Replaces the Font used with the text.
			 *
			 * @param font The new font to use with this Text object.
			 */
			setFont(font: Font): void;
			/**
			 * Gets the Font used with the Text object.
			 *
			 * @returns font — The font used with this Text object.
			 */
			getFont(): Font;
			/**
			 * Gets the width of the text in pixels.
			 *

			 * @returns width — The width of the text. If multiple sub-strings have been added with Text:add, the width of the last sub-string is returned.
			 */
			getWidth(): number;
/**
 * Gets the width of the text in pixels.
 *

 * @param index An index number returned by Text:add or Text:addf.
 * @returns The width of the sub-string (before scaling and other transformations).
 */
			getWidth(index: number): number;
			/**
			 * Gets the height of the text in pixels.
			 *

			 * @returns height  — The height of the text. If multiple sub-strings have been added with Text:add, the height of the last sub-string is returned.
			 * @returns height — The height of the sub-string (before scaling and other transformations).
			 */
			getHeight(): number;
/**
 * Gets the height of the text in pixels.
 *

 * @param index An index number returned by Text:add or Text:addf.
 * @returns height  — The height of the text. If multiple sub-strings have been added with Text:add, the height of the last sub-string is returned.
 * @returns height — The height of the sub-string (before scaling and other transformations).
 */
			getHeight(index: number): number;
			/**
			 * Gets the width and height of the text in pixels.
			 *

			 * @returns width — The width of the text. If multiple sub-strings have been added with Text:add, the width of the last sub-string is returned.
			 * @returns height — The height of the text. If multiple sub-strings have been added with Text:add, the height of the last sub-string is returned.
			 */
			getDimensions(): LuaMultiReturn<[number, number]>;
/**
 * Gets the width and height of the text in pixels.
 *

 * @param index An index number returned by Text:add or Text:addf.
 * @returns The width of the sub-string (before scaling and other transformations).
 * @returns The height of the sub-string (before scaling and other transformations).
 */
			getDimensions(index: number): LuaMultiReturn<[number, number]>;
		}
		/** A quadrilateral (a polygon with four sides and four corners) with texture coordinate information.
		 */
		interface Quad extends Object {
			/**
			 * Sets the texture coordinates according to a viewport.
			 *
			 * @param x The top-left corner along the x-axis.
			 * @param y The top-left corner along the y-axis.
			 * @param width The width of the viewport.
			 * @param height The height of the viewport.
			 * @param textureWidth Optional new reference width, the width of the Texture. Must be greater than 0 if set. (Default: nil.)
			 * @param textureHeight Optional new reference height, the height of the Texture. Must be greater than 0 if set. (Default: nil.)
			 */
			setViewport(x: number, y: number, width: number, height: number, textureWidth?: number, textureHeight?: number): void;
			/**
			 * Gets the current viewport of this Quad.
			 *
			 * @returns x — The top-left corner along the x-axis.
			 * @returns y — The top-left corner along the y-axis.
			 * @returns w — The width of the viewport.
			 * @returns h — The height of the viewport.
			 */
			getViewport(): LuaMultiReturn<[number, number, number, number]>;
			/**
			 * Gets reference texture dimensions initially specified in love.graphics.newQuad.
			 *
			 * @returns sw — The Texture width used by the Quad.
			 * @returns sh — The Texture height used by the Quad.
			 */
			getTextureDimensions(): LuaMultiReturn<[number, number]>;
			setLayer(layer: number): void;
			getLayer(): number;
		}
		/** A 2D polygon mesh used for drawing arbitrary textured shapes.
		 */
		interface Mesh extends Object {
			/**
			 * Replaces a range of vertices in the Mesh with new ones. The total number of vertices in a Mesh cannot be changed after it has been created. This is often more efficient than calling Mesh:setVertex in a loop.
			 *

			 * @param vertices The table filled with vertex information tables for each vertex, in the form of {vertex, ...} where each vertex is a table in the form of {attributecomponent, ...}.
			 * @param startVertex The index of the first vertex to replace. (Default: 1.)
			 * @param vertexCount Amount of vertices to replace. (Default: all.)
			 */
			setVertices(vertices: MeshVertex[], startVertex?: number, vertexCount?: number): void;
			/**
			 * Replaces a range of vertices in the Mesh with new ones. The total number of vertices in a Mesh cannot be changed after it has been created. This is often more efficient than calling Mesh:setVertex in a loop.
			 *

			 * @param data A Data object to copy from. The contents of the Data must match the layout of this Mesh's vertex format.
			 * @param startVertex The index of the first vertex to replace. (Default: 1.)
			 * @param vertexCount Amount of vertices to replace. (Default: all.)
			 */
			setVertices(data: Data, startVertex?: number, vertexCount?: number): void;
			/**
			 * Sets the properties of a vertex in the Mesh.
			 *
			 * In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
			 *

			 * @param index The index of the the vertex you want to modify (one-based).
			 * @param vertex A table with vertex information, in the form of {attributecomponent, ...}.
			 */
			setVertex(index: number, vertex: MeshVertex): void;
			/**
			 * Sets the properties of a vertex in the Mesh.
			 *
			 * In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
			 *

			 * @param index The index of the the vertex you want to modify (one-based).
			 * @param components A table with vertex information.
			 */
			setVertex(index: number, ...components: number[]): void;
			/**
			 * Gets the properties of a vertex in the Mesh.
			 *
			 * In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
			 *
			 * Overload details:
			 * 1. The values are returned in the same order as the vertex attributes in the Mesh's vertex format. A standard Mesh that wasn't created with a custom vertex format will return two position numbers, two texture coordinate numbers, and four color components: x, y, u, v, r, g, b, a.
			 * 2. Gets the vertex components of a Mesh that wasn't created with a custom vertex format.
			 *
			 * @param index The one-based index of the vertex you want to retrieve the information for. Depending on the overload: The index of the vertex you want to retrieve the information for.
			 *
			 * @returns attributecomponent — The first component of the first vertex attribute in the specified vertex.
			 * @returns ... — Additional components of all vertex attributes in the specified vertex.
			 * @returns x — The position of the vertex on the x-axis.
			 * @returns y — The position of the vertex on the y-axis.
			 * @returns u — The horizontal component of the texture coordinate.
			 * @returns v — The vertical component of the texture coordinate.
			 * @returns r — The red component of the vertex's color.
			 * @returns g — The green component of the vertex's color.
			 * @returns b — The blue component of the vertex's color.
			 * @returns a — The alpha component of the vertex's color.
			 */
			getVertex(index: number): LuaMultiReturn<[number, ...number[]]>;
			/**
			 * Sets the properties of a specific attribute within a vertex in the Mesh.
			 *
			 * Meshes without a custom vertex format specified in love.graphics.newMesh have position as their first attribute, texture coordinates as their second attribute, and color as their third attribute.
			 *
			 * Overload details:
			 * 1. Attribute components which exist within the attribute but are not specified as arguments default to 0 for attributes with the float data type, and 255 for the byte data type.
			 *
			 * @param vertexIndex The index of the the vertex to be modified (one-based).
			 * @param attributeIndex The index of the attribute within the vertex to be modified (one-based).
			 * @param components The new value for the first component of the attribute.
			 */
			setVertexAttribute(vertexIndex: number, attributeIndex: number, ...components: number[]): void;
			/**
			 * Gets the properties of a specific attribute within a vertex in the Mesh.
			 *
			 * Meshes without a custom vertex format specified in love.graphics.newMesh have position as their first attribute, texture coordinates as their second attribute, and color as their third attribute.
			 *
			 * @param vertexIndex The index of the the vertex you want to retrieve the attribute for (one-based).
			 * @param attributeIndex The index of the attribute within the vertex to be retrieved (one-based).
			 *
			 * @returns value1 — The value of the first component of the attribute.
			 * @returns value2 — The value of the second component of the attribute.
			 * @returns ... — Any additional vertex attribute components.
			 */
			getVertexAttribute(vertexIndex: number, attributeIndex: number): LuaMultiReturn<[number, ...number[]]>;
			/**
			 * Gets the total number of vertices in the Mesh.
			 *
			 * @returns count — The total number of vertices in the mesh.
			 */
			getVertexCount(): number;
			/**
			 * Gets the vertex format that the Mesh was created with.
			 *
			 * Overload details:
			 * 1. If a Mesh wasn't created with a custom vertex format, it will have the following vertex format: defaultformat = {  {'VertexPosition', 'float', 2}, -- The x,y position of each vertex.  {'VertexTexCoord', 'float', 2}, -- The u,v texture coordinates of each vertex.  {'VertexColor', 'byte', 4} -- The r,g,b,a color of each vertex. }
			 *
			 * @returns format — The vertex format of the Mesh, which is a table containing tables for each vertex attribute the Mesh was created with, in the form of {attribute, ...}.
			 * @returns format.attribute — A table containing the attribute's name, it's data type, and the number of components in the attribute, in the form of {name, datatype, components}.
			 * @returns format.... — Additional vertex attributes in the Mesh.
			 */
			getVertexFormat(): MeshVertexFormat[];
			/**
			 * Enables or disables a specific vertex attribute in the Mesh. Vertex data from disabled attributes is not used when drawing the Mesh.
			 *
			 * Overload details:
			 * 1. If a Mesh wasn't created with a custom vertex format, it will have 3 vertex attributes named VertexPosition, VertexTexCoord, and VertexColor. Otherwise the attribute name must either match one of the vertex attributes specified in the vertex format when creating the Mesh, or must match a vertex attribute from another Mesh attached to this Mesh via Mesh:attachAttribute.
			 *
			 * @param name The name of the vertex attribute to enable or disable.
			 * @param enabled Whether the vertex attribute is used when drawing this Mesh.
			 */
			setAttributeEnabled(name: string, enabled: boolean): void;
			/**
			 * Gets whether a specific vertex attribute in the Mesh is enabled. Vertex data from disabled attributes is not used when drawing the Mesh.
			 *
			 * Overload details:
			 * 1. If a Mesh wasn't created with a custom vertex format, it will have 3 vertex attributes named VertexPosition, VertexTexCoord, and VertexColor. Otherwise the attribute name must either match one of the vertex attributes specified in the vertex format when creating the Mesh, or must match a vertex attribute from another Mesh attached to this Mesh via Mesh:attachAttribute.
			 *
			 * @param name The name of the vertex attribute to be checked.
			 *
			 * @returns enabled — Whether the vertex attribute is used when drawing this Mesh.
			 */
			isAttributeEnabled(name: string): boolean;
			/**
			 * Attaches a vertex attribute from a different Mesh onto this Mesh, for use when drawing. This can be used to share vertex attribute data between several different Meshes.
			 *
			 * Overload details:
			 * 1. If a Mesh wasn't created with a custom vertex format, it will have 3 vertex attributes named VertexPosition, VertexTexCoord, and VertexColor. Custom named attributes can be accessed in a vertex shader by declaring them as attribute vec4 MyCustomAttributeName; at the top-level of the vertex shader code. The name must match what was specified in the Mesh's vertex format and in the name argument of Mesh:attachAttribute.
			 *
			 * @param name The name of the vertex attribute to attach.
			 * @param mesh The Mesh to get the vertex attribute from.
			 * @param step Whether the attribute will be per-vertex or per-instance when the mesh is drawn. (Default: 'pervertex'.)
			 * @param attributeName The name of the attribute to use in shader code. Defaults to the name of the attribute in the given mesh. Can be used to use a different name for this attribute when rendering. (Default: name.)
			 */
			attachAttribute(name: string, mesh: Mesh, step?: AttributeStep, attributeName?: string): void;
			/**
			 * Removes a previously attached vertex attribute from this Mesh.
			 *
			 * @param name The name of the attached vertex attribute to detach.
			 *
			 * @returns success — Whether the attribute was successfully detached.
			 */
			detachAttribute(name: string): boolean;
			/**
			 * Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
			 *
			 * The vertex map allows you to re-order or reuse vertices when drawing without changing the actual vertex parameters or duplicating vertices. It is especially useful when combined with different Mesh Draw Modes.
			 *
			 */
			setVertexMap(): void;
			/**
			 * Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
			 *
			 * The vertex map allows you to re-order or reuse vertices when drawing without changing the actual vertex parameters or duplicating vertices. It is especially useful when combined with different Mesh Draw Modes.
			 *

			 * @param indices A table containing a list of vertex indices to use when drawing. Values must be in the range of Mesh:getVertexCount().
			 */
			setVertexMap(indices: number[]): void;
			/**
			 * Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
			 *
			 * The vertex map allows you to re-order or reuse vertices when drawing without changing the actual vertex parameters or duplicating vertices. It is especially useful when combined with different Mesh Draw Modes.
			 *

			 * @param indices A table containing a list of vertex indices to use when drawing. Values must be in the range of Mesh:getVertexCount().
			 */
			setVertexMap(...indices: number[]): void;
			/**
			 * Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
			 *
			 * The vertex map allows you to re-order or reuse vertices when drawing without changing the actual vertex parameters or duplicating vertices. It is especially useful when combined with different Mesh Draw Modes.
			 *

			 * @param data Array of vertex indices to use when drawing. Values must be in the range of Mesh:getVertexCount()-1
			 * @param dataType Datatype of the vertex indices array above.
			 * @param indexCount The index of the third vertex to use when drawing.
			 */
			setVertexMap(data: Data, dataType: IndexDataType, indexCount?: number): void;
			/**
			 * Gets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
			 *
			 * If no vertex map has been set previously via Mesh:setVertexMap, then this function will return nil in LÖVE 0.10.0+, or an empty table in 0.9.2 and older.
			 *
			 * @returns map — A table containing the list of vertex indices used when drawing.
			 */
			getVertexMap(): number[] | undefined;
			/**
			 * Sets the texture (Image or Canvas) used when drawing the Mesh.
			 *
			 */
			setTexture(): void;
/**
 * Sets the texture (Image or Canvas) used when drawing the Mesh.
 *

 * @param texture The Image or Canvas to texture the Mesh with when drawing.
 */
			setTexture(texture: Image | Canvas): void;
			/**
			 * Gets the texture (Image or Canvas) used when drawing the Mesh.
			 *
			 * @returns texture — The Image or Canvas to texture the Mesh with when drawing, or nil if none is set.
			 */
			getTexture(): Image | Canvas | undefined;
			/**
			 * Sets the mode used when drawing the Mesh.
			 *
			 * @param mode The mode to use when drawing the Mesh.
			 */
			setDrawMode(mode: MeshDrawMode): void;
			/**
			 * Gets the mode used when drawing the Mesh.
			 *
			 * @returns mode — The mode used when drawing the Mesh.
			 */
			getDrawMode(): MeshDrawMode;
			/**
			 * Restricts the drawn vertices of the Mesh to a subset of the total.
			 *
			 */
			setDrawRange(): void;
			/**
			 * Restricts the drawn vertices of the Mesh to a subset of the total.
			 *

			 * @param start The index of the first vertex to use when drawing, or the index of the first value in the vertex map to use if one is set for this Mesh.
			 * @param count The number of vertices to use when drawing, or number of values in the vertex map to use if one is set for this Mesh.
			 */
			setDrawRange(start: number, count: number): void;
			/**
			 * Gets the range of vertices used when drawing the Mesh.
			 *
			 * Overload details:
			 * 1. If the Mesh's draw range has not been set previously with Mesh:setDrawRange, this function will return nil.
			 *
			 * @returns min — The index of the first vertex used when drawing, or the index of the first value in the vertex map used if one is set for this Mesh.
			 * @returns max — The index of the last vertex used when drawing, or the index of the last value in the vertex map used if one is set for this Mesh.
			 */
			getDrawRange(): LuaMultiReturn<[number, number]> | undefined;
			/**
			 * Immediately sends all modified vertex data in the Mesh to the graphics card.
			 *
			 * Normally it isn't necessary to call this method as love.graphics.draw(mesh, ...) will do it automatically if needed, but explicitly using **Mesh:flush** gives more control over when the work happens.
			 *
			 * If this method is used, it generally shouldn't be called more than once (at most) between love.graphics.draw(mesh, ...) calls.
			 */
			flush(): void;
		}
		/** Using a single image, draw any number of identical copies of the image using a single call to love.graphics.draw(). This can be used, for example, to draw repeating copies of a single background image with high performance.
		 */
		interface SpriteBatch extends Object {
			/**
			 * Adds a sprite to the batch. Sprites are drawn in the order they are added.
			 *

			 * @param x The position to draw the object (x-axis).
			 * @param y The position to draw the object (y-axis).
			 * @param angle Orientation (radians). (Default: 0.)
			 * @param scaleX Scale factor (x-axis). (Default: 1.)
			 * @param scaleY Scale factor (y-axis). (Default: sx.)
			 * @param originX Origin offset (x-axis). (Default: 0.)
			 * @param originY Origin offset (y-axis). (Default: 0.)
			 * @param shearX Shear factor (x-axis). (Default: 0.)
			 * @param shearY Shear factor (y-axis). (Default: 0.)
			 * @returns id — An identifier for the added sprite.
			 */
			add(x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/**
			 * Adds a sprite to the batch. Sprites are drawn in the order they are added.
			 *

			 * @param quad The Quad to add.
			 * @param x The position to draw the object (x-axis).
			 * @param y The position to draw the object (y-axis).
			 * @param angle Orientation (radians). (Default: 0.)
			 * @param scaleX Scale factor (x-axis). (Default: 1.)
			 * @param scaleY Scale factor (y-axis). (Default: sx.)
			 * @param originX Origin offset (x-axis). (Default: 0.)
			 * @param originY Origin offset (y-axis). (Default: 0.)
			 * @param shearX Shear factor (x-axis). (Default: 0.)
			 * @param shearY Shear factor (y-axis). (Default: 0.)
			 * @returns id — An identifier for the added sprite.
			 */
			add(quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/**
			 * Changes a sprite in the batch. This requires the sprite index returned by SpriteBatch:add or SpriteBatch:addLayer.
			 *

			 * @param index The index of the sprite that will be changed.
			 * @param x The position to draw the object (x-axis).
			 * @param y The position to draw the object (y-axis).
			 * @param angle Orientation (radians). (Default: 0.)
			 * @param scaleX Scale factor (x-axis). (Default: 1.)
			 * @param scaleY Scale factor (y-axis). (Default: sx.)
			 * @param originX Origin offset (x-axis). (Default: 0.)
			 * @param originY Origin offset (y-axis). (Default: 0.)
			 * @param shearX Shear factor (x-axis). (Default: 0.)
			 * @param shearY Shear factor (y-axis). (Default: 0.)
			 */
			set(index: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			/**
			 * Changes a sprite in the batch. This requires the sprite index returned by SpriteBatch:add or SpriteBatch:addLayer.
			 *

			 * @param index The index of the sprite that will be changed.
			 * @param quad The Quad used on the image of the batch.
			 * @param x The position to draw the object (x-axis).
			 * @param y The position to draw the object (y-axis).
			 * @param angle Orientation (radians). (Default: 0.)
			 * @param scaleX Scale factor (x-axis). (Default: 1.)
			 * @param scaleY Scale factor (y-axis). (Default: sx.)
			 * @param originX Origin offset (x-axis). (Default: 0.)
			 * @param originY Origin offset (y-axis). (Default: 0.)
			 * @param shearX Shear factor (x-axis). (Default: 0.)
			 * @param shearY Shear factor (y-axis). (Default: 0.)
			 */
			set(index: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			/**
			 * Adds a sprite to a batch created with an Array Texture.
			 *

			 * @param layer The index of the layer to use for this sprite.
			 * @param x The position to draw the sprite (x-axis). (Default: 0.)
			 * @param y The position to draw the sprite (y-axis). (Default: 0.)
			 * @param angle Orientation (radians). (Default: 0.)
			 * @param scaleX Scale factor (x-axis). (Default: 1.)
			 * @param scaleY Scale factor (y-axis). (Default: sx.)
			 * @param originX Origin offset (x-axis). (Default: 0.)
			 * @param originY Origin offset (y-axis). (Default: 0.)
			 * @param shearX Shearing factor (x-axis). (Default: 0.)
			 * @param shearY Shearing factor (y-axis). (Default: 0.)
			 * @returns spriteindex — The index of the added sprite, for use with SpriteBatch:set or SpriteBatch:setLayer.
			 */
			addLayer(layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/**
			 * Adds a sprite to a batch created with an Array Texture.
			 *

			 * @param layer The index of the layer to use for this sprite.
			 * @param quad The subsection of the texture's layer to use when drawing the sprite.
			 * @param x The position to draw the sprite (x-axis). (Default: 0.)
			 * @param y The position to draw the sprite (y-axis). (Default: 0.)
			 * @param angle Orientation (radians). (Default: 0.)
			 * @param scaleX Scale factor (x-axis). (Default: 1.)
			 * @param scaleY Scale factor (y-axis). (Default: sx.)
			 * @param originX Origin offset (x-axis). (Default: 0.)
			 * @param originY Origin offset (y-axis). (Default: 0.)
			 * @param shearX Shearing factor (x-axis). (Default: 0.)
			 * @param shearY Shearing factor (y-axis). (Default: 0.)
			 * @returns spriteindex — The index of the added sprite, for use with SpriteBatch:set or SpriteBatch:setLayer.
			 */
			addLayer(layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/**
			 * Changes a sprite previously added with add or addLayer, in a batch created with an Array Texture.
			 *

			 * @param index The index of the existing sprite to replace.
			 * @param layer The index of the layer in the Array Texture to use for this sprite.
			 * @param x The position to draw the sprite (x-axis). (Default: 0.)
			 * @param y The position to draw the sprite (y-axis). (Default: 0.)
			 * @param angle Orientation (radians). (Default: 0.)
			 * @param scaleX Scale factor (x-axis). (Default: 1.)
			 * @param scaleY Scale factor (y-axis). (Default: sx.)
			 * @param originX Origin offset (x-axis). (Default: 0.)
			 * @param originY Origin offset (y-axis). (Default: 0.)
			 * @param shearX Shearing factor (x-axis). (Default: 0.)
			 * @param shearY Shearing factor (y-axis). (Default: 0.)
			 */
			setLayer(index: number, layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			/**
			 * Changes a sprite previously added with add or addLayer, in a batch created with an Array Texture.
			 *

			 * @param index The index of the existing sprite to replace.
			 * @param layer The index of the layer to use for this sprite.
			 * @param quad The subsection of the texture's layer to use when drawing the sprite.
			 * @param x The position to draw the sprite (x-axis). (Default: 0.)
			 * @param y The position to draw the sprite (y-axis). (Default: 0.)
			 * @param angle Orientation (radians). (Default: 0.)
			 * @param scaleX Scale factor (x-axis). (Default: 1.)
			 * @param scaleY Scale factor (y-axis). (Default: sx.)
			 * @param originX Origin offset (x-axis). (Default: 0.)
			 * @param originY Origin offset (y-axis). (Default: 0.)
			 * @param shearX Shearing factor (x-axis). (Default: 0.)
			 * @param shearY Shearing factor (y-axis). (Default: 0.)
			 */
			setLayer(index: number, layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			/**
			 * Removes all sprites from the buffer.
			 */
			clear(): void;
			/**
			 * Immediately sends all new and modified sprite data in the batch to the graphics card.
			 *
			 * Normally it isn't necessary to call this method as love.graphics.draw(spritebatch, ...) will do it automatically if needed, but explicitly using SpriteBatch:flush gives more control over when the work happens.
			 *
			 * If this method is used, it generally shouldn't be called more than once (at most) between love.graphics.draw(spritebatch, ...) calls.
			 */
			flush(): void;
			/**
			 * Sets the texture (Image or Canvas) used for the sprites in the batch, when drawing.
			 *
			 * @param texture The new Image or Canvas to use for the sprites in the batch.
			 */
			setTexture(texture: Image | Canvas): void;
			/**
			 * Gets the texture (Image or Canvas) used by the SpriteBatch.
			 *
			 * @returns texture — The Image or Canvas used by the SpriteBatch.
			 */
			getTexture(): Image | Canvas;
			/**
			 * Sets the color that will be used for the next add and set operations. Calling the function without arguments will disable all per-sprite colors for the SpriteBatch.
			 *
			 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
			 *
			 * In version 0.9.2 and older, the global color set with love.graphics.setColor will not work on the SpriteBatch if any of the sprites has its own color.
			 *
			 */
			setColor(): void;
			/**
			 * Sets the color that will be used for the next add and set operations. Calling the function without arguments will disable all per-sprite colors for the SpriteBatch.
			 *
			 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
			 *
			 * In version 0.9.2 and older, the global color set with love.graphics.setColor will not work on the SpriteBatch if any of the sprites has its own color.
			 *

			 * @param red The amount of red.
			 * @param green The amount of green.
			 * @param blue The amount of blue.
			 * @param alpha The amount of alpha. (Default: 1.)
			 */
			setColor(red: number, green: number, blue: number, alpha?: number): void;
			/**
			 * Sets the color that will be used for the next add and set operations. Calling the function without arguments will disable all per-sprite colors for the SpriteBatch.
			 *
			 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
			 *
			 * In version 0.9.2 and older, the global color set with love.graphics.setColor will not work on the SpriteBatch if any of the sprites has its own color.
			 *

			 * @param color The amount of red.
			 */
			setColor(color: Color): void;
			/**
			 * Gets the color that will be used for the next add and set operations.
			 *
			 * If no color has been set with SpriteBatch:setColor or the current SpriteBatch color has been cleared, this method will return nil.
			 *
			 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
			 *
			 * @returns r — The red component (0-1).
			 * @returns g — The green component (0-1).
			 * @returns b — The blue component (0-1).
			 * @returns a — The alpha component (0-1).
			 */
			getColor(): LuaMultiReturn<[number, number, number, number]> | undefined;
			/**
			 * Gets the number of sprites currently in the SpriteBatch.
			 *
			 * @returns count — The number of sprites currently in the batch.
			 */
			getCount(): number;
			/**
			 * Gets the maximum number of sprites the SpriteBatch can hold.
			 *
			 * @returns size — The maximum number of sprites the batch can hold.
			 */
			getBufferSize(): number;
			/**
			 * Attaches a per-vertex attribute from a Mesh onto this SpriteBatch, for use when drawing. This can be combined with a Shader to augment a SpriteBatch with per-vertex or additional per-sprite information instead of just having per-sprite colors.
			 *
			 * Each sprite in a SpriteBatch has 4 vertices in the following order: top-left, bottom-left, top-right, bottom-right. The index returned by SpriteBatch:add (and used by SpriteBatch:set) can used to determine the first vertex of a specific sprite with the formula 1 + 4 * ( id - 1 ).
			 *
			 * Overload details:
			 * 1. If a created with a custom vertex format, it will have 3 vertex attributes named VertexPosition, VertexTexCoord, and VertexColor. If vertex attributes with those names are attached to the SpriteBatch, it will override the SpriteBatch's sprite positions, texture coordinates, and sprite colors, respectively. Custom named attributes can be accessed in a vertex shader by declaring them as attribute vec4 MyCustomAttributeName; at the top-level of the vertex shader code. The name must match what was specified in the Mesh's vertex format and in the name argument of SpriteBatch:attachAttribute. A Mesh must have at least 4 * SpriteBatch:getBufferSize vertices in order to be attachable to a SpriteBatch.
			 *
			 * @param name The name of the vertex attribute to attach.
			 * @param mesh The Mesh to get the vertex attribute from.
			 */
			attachAttribute(name: string, mesh: Mesh): void;
			/**
			 * Restricts the drawn sprites in the SpriteBatch to a subset of the total.
			 *
			 */
			setDrawRange(): void;
			/**
			 * Restricts the drawn sprites in the SpriteBatch to a subset of the total.
			 *

			 * @param start The index of the first sprite to draw. Index 1 corresponds to the first sprite added with SpriteBatch:add.
			 * @param count The number of sprites to draw.
			 */
			setDrawRange(start: number, count: number): void;
			getDrawRange(): LuaMultiReturn<[number, number]> | undefined;
		}
		/** A ParticleSystem can be used to create particle effects like fire or smoke.
		 */
		interface ParticleSystem extends Object {
			/**
			 * Creates an identical copy of the ParticleSystem in the stopped state.
			 *
			 * Overload details:
			 * 1. Cloned ParticleSystem inherit all the set-able state of the original ParticleSystem, but they are initialized stopped.
			 *
			 * @returns particlesystem — The new identical copy of this ParticleSystem.
			 */
			clone(): ParticleSystem;
			/**
			 * Sets the texture (Image or Canvas) to be used for the particles.
			 *
			 * @param texture An Image or Canvas to use for the particles.
			 */
			setTexture(texture: Image | Canvas): void;
			/**
			 * Gets the texture (Image or Canvas) used for the particles.
			 *
			 * @returns texture — The Image or Canvas used for the particles.
			 */
			getTexture(): Image | Canvas;
			/**
			 * Sets the size of the buffer (the max allowed amount of particles in the system).
			 *
			 * @param size The buffer size.
			 */
			setBufferSize(size: number): void;
			/**
			 * Gets the maximum number of particles the ParticleSystem can have at once.
			 *
			 * @returns size — The maximum number of particles.
			 */
			getBufferSize(): number;
			/**
			 * Sets the mode to use when the ParticleSystem adds new particles.
			 *
			 * @param mode The mode to use when the ParticleSystem adds new particles.
			 */
			setInsertMode(mode: ParticleInsertMode): void;
			/**
			 * Gets the mode used when the ParticleSystem adds new particles.
			 *
			 * @returns mode — The mode used when the ParticleSystem adds new particles.
			 */
			getInsertMode(): ParticleInsertMode;
			/**
			 * Sets the amount of particles emitted per second.
			 *
			 * @param rate The amount of particles per second.
			 */
			setEmissionRate(rate: number): void;
			/**
			 * Gets the amount of particles emitted per second.
			 *
			 * @returns rate — The amount of particles per second.
			 */
			getEmissionRate(): number;
			/**
			 * Sets how long the particle system should emit particles (if -1 then it emits particles forever).
			 *
			 * @param lifetime The lifetime of the emitter (in seconds).
			 */
			setEmitterLifetime(lifetime: number): void;
			/**
			 * Gets how long the particle system will emit particles (if -1 then it emits particles forever).
			 *
			 * @returns life — The lifetime of the emitter (in seconds).
			 */
			getEmitterLifetime(): number;
			/**
			 * Sets the lifetime of the particles.
			 *
			 * @param minimum The minimum life of the particles (in seconds).
			 * @param maximum The maximum life of the particles (in seconds). (Default: min.)
			 */
			setParticleLifetime(minimum: number, maximum?: number): void;
			/**
			 * Gets the lifetime of the particles.
			 *
			 * @returns min — The minimum life of the particles (in seconds).
			 * @returns max — The maximum life of the particles (in seconds).
			 */
			getParticleLifetime(): LuaMultiReturn<[number, number]>;
			/**
			 * Sets the position of the emitter.
			 *
			 * @param x Position along x-axis.
			 * @param y Position along y-axis.
			 */
			setPosition(x: number, y: number): void;
			/**
			 * Gets the position of the emitter.
			 *
			 * @returns x — Position along x-axis.
			 * @returns y — Position along y-axis.
			 */
			getPosition(): LuaMultiReturn<[number, number]>;
			/**
			 * Moves the position of the emitter. This results in smoother particle spawning behaviour than if ParticleSystem:setPosition is used every frame.
			 *
			 * @param x Position along x-axis.
			 * @param y Position along y-axis.
			 */
			moveTo(x: number, y: number): void;
			/**
			 * Sets area-based spawn parameters for the particles. Newly created particles will spawn in an area around the emitter based on the parameters to this function.
			 *
			 * @param distribution The type of distribution for new particles.
			 * @param x The maximum spawn distance from the emitter along the x-axis for uniform distribution, or the standard deviation along the x-axis for normal distribution.
			 * @param y The maximum spawn distance from the emitter along the y-axis for uniform distribution, or the standard deviation along the y-axis for normal distribution.
			 * @param angle The angle in radians of the emission area. (Default: 0.)
			 * @param directionRelativeToCenter True if newly spawned particles will be oriented relative to the center of the emission area, false otherwise. (Default: false.)
			 */
			setEmissionArea(distribution?: ParticleAreaSpreadDistribution, x?: number, y?: number, angle?: number, directionRelativeToCenter?: boolean): void;
			/**
			 * Gets the area-based spawn parameters for the particles.
			 *
			 * @returns distribution — The type of distribution for new particles.
			 * @returns dx — The maximum spawn distance from the emitter along the x-axis for uniform distribution, or the standard deviation along the x-axis for normal distribution.
			 * @returns dy — The maximum spawn distance from the emitter along the y-axis for uniform distribution, or the standard deviation along the y-axis for normal distribution.
			 * @returns angle — The angle in radians of the emission area.
			 * @returns directionRelativeToCenter — True if newly spawned particles will be oriented relative to the center of the emission area, false otherwise.
			 */
			getEmissionArea(): LuaMultiReturn<[ParticleAreaSpreadDistribution, number, number, number, boolean]>;
			/** @deprecated Use setEmissionArea. */
			setAreaSpread(distribution?: ParticleAreaSpreadDistribution, x?: number, y?: number): void;
			/** @deprecated Use getEmissionArea. */
			getAreaSpread(): LuaMultiReturn<[ParticleAreaSpreadDistribution, number, number]>;
			/**
			 * Sets the direction the particles will be emitted in.
			 *
			 * @param direction The direction of the particles (in radians).
			 */
			setDirection(direction: number): void;
			/**
			 * Gets the direction of the particle emitter (in radians).
			 *
			 * @returns direction — The direction of the emitter (radians).
			 */
			getDirection(): number;
			/**
			 * Sets the amount of spread for the system.
			 *
			 * @param spread The amount of spread (radians).
			 */
			setSpread(spread: number): void;
			/**
			 * Gets the amount of directional spread of the particle emitter (in radians).
			 *
			 * @returns spread — The spread of the emitter (radians).
			 */
			getSpread(): number;
			/**
			 * Sets the speed of the particles.
			 *
			 * @param minimum The minimum linear speed of the particles.
			 * @param maximum The maximum linear speed of the particles. (Default: min.)
			 */
			setSpeed(minimum: number, maximum?: number): void;
			/**
			 * Gets the speed of the particles.
			 *
			 * @returns min — The minimum linear speed of the particles.
			 * @returns max — The maximum linear speed of the particles.
			 */
			getSpeed(): LuaMultiReturn<[number, number]>;
			/**
			 * Sets the linear acceleration (acceleration along the x and y axes) for particles.
			 *
			 * Every particle created will accelerate along the x and y axes between xmin,ymin and xmax,ymax.
			 *
			 * @param xMinimum The minimum acceleration along the x axis.
			 * @param yMinimum The minimum acceleration along the y axis.
			 * @param xMaximum The maximum acceleration along the x axis. (Default: xmin.)
			 * @param yMaximum The maximum acceleration along the y axis. (Default: ymin.)
			 */
			setLinearAcceleration(xMinimum: number, yMinimum: number, xMaximum?: number, yMaximum?: number): void;
			/**
			 * Gets the linear acceleration (acceleration along the x and y axes) for particles.
			 *
			 * Every particle created will accelerate along the x and y axes between xmin,ymin and xmax,ymax.
			 *
			 * @returns xmin — The minimum acceleration along the x axis.
			 * @returns ymin — The minimum acceleration along the y axis.
			 * @returns xmax — The maximum acceleration along the x axis.
			 * @returns ymax — The maximum acceleration along the y axis.
			 */
			getLinearAcceleration(): LuaMultiReturn<[number, number, number, number]>;
			/**
			 * Set the radial acceleration (away from the emitter).
			 *
			 * @param minimum The minimum acceleration.
			 * @param maximum The maximum acceleration. (Default: min.)
			 */
			setRadialAcceleration(minimum: number, maximum?: number): void;
			/**
			 * Gets the radial acceleration (away from the emitter).
			 *
			 * @returns min — The minimum acceleration.
			 * @returns max — The maximum acceleration.
			 */
			getRadialAcceleration(): LuaMultiReturn<[number, number]>;
			/**
			 * Sets the tangential acceleration (acceleration perpendicular to the particle's direction).
			 *
			 * @param minimum The minimum acceleration.
			 * @param maximum The maximum acceleration. (Default: min.)
			 */
			setTangentialAcceleration(minimum: number, maximum?: number): void;
			/**
			 * Gets the tangential acceleration (acceleration perpendicular to the particle's direction).
			 *
			 * @returns min — The minimum acceleration.
			 * @returns max — The maximum acceleration.
			 */
			getTangentialAcceleration(): LuaMultiReturn<[number, number]>;
			/**
			 * Sets the amount of linear damping (constant deceleration) for particles.
			 *
			 * @param minimum The minimum amount of linear damping applied to particles.
			 * @param maximum The maximum amount of linear damping applied to particles. (Default: min.)
			 */
			setLinearDamping(minimum: number, maximum?: number): void;
			/**
			 * Gets the amount of linear damping (constant deceleration) for particles.
			 *
			 * @returns min — The minimum amount of linear damping applied to particles.
			 * @returns max — The maximum amount of linear damping applied to particles.
			 */
			getLinearDamping(): LuaMultiReturn<[number, number]>;
			/**
			 * Sets a series of sizes by which to scale a particle sprite. 1.0 is normal size. The particle system will interpolate between each size evenly over the particle's lifetime.
			 *
			 * At least one size must be specified. A maximum of eight may be used.
			 *
			 * @param sizes The first size.
			 */
			setSizes(...sizes: number[]): void;
			/**
			 * Gets the series of sizes by which the sprite is scaled. 1.0 is normal size. The particle system will interpolate between each size evenly over the particle's lifetime.
			 *
			 * @returns size1 — The first size.
			 * @returns size2 — The second size.
			 * @returns size8 — The eighth size.
			 */
			getSizes(): LuaMultiReturn<number[]>;
			/**
			 * Sets the amount of size variation (0 meaning no variation and 1 meaning full variation between start and end).
			 *
			 * @param variation The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).
			 */
			setSizeVariation(variation: number): void;
			/**
			 * Gets the amount of size variation (0 meaning no variation and 1 meaning full variation between start and end).
			 *
			 * @returns variation — The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).
			 */
			getSizeVariation(): number;
			/**
			 * Sets the rotation of the image upon particle creation (in radians).
			 *
			 * @param minimum The minimum initial angle (radians).
			 * @param maximum The maximum initial angle (radians). (Default: min.)
			 */
			setRotation(minimum: number, maximum?: number): void;
			/**
			 * Gets the rotation of the image upon particle creation (in radians).
			 *
			 * @returns min — The minimum initial angle (radians).
			 * @returns max — The maximum initial angle (radians).
			 */
			getRotation(): LuaMultiReturn<[number, number]>;
			/**
			 * Sets the spin of the sprite.
			 *
			 * @param start The minimum spin (radians per second).
			 * @param finish The maximum spin (radians per second). (Default: min.)
			 */
			setSpin(start: number, finish?: number): void;
			/**
			 * Gets the spin of the sprite.
			 *
			 * @returns min — The minimum spin (radians per second).
			 * @returns max — The maximum spin (radians per second).
			 * @returns variation — The degree of variation (0 meaning no variation and 1 meaning full variation between start and end).
			 */
			getSpin(): LuaMultiReturn<[number, number]>;
			/**
			 * Sets the amount of spin variation (0 meaning no variation and 1 meaning full variation between start and end).
			 *
			 * @param variation The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).
			 */
			setSpinVariation(variation: number): void;
			/**
			 * Gets the amount of spin variation (0 meaning no variation and 1 meaning full variation between start and end).
			 *
			 * @returns variation — The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).
			 */
			getSpinVariation(): number;
			/**
			 * Set the offset position which the particle sprite is rotated around.
			 *
			 * If this function is not used, the particles rotate around their center.
			 *
			 * @param x The x coordinate of the rotation offset.
			 * @param y The y coordinate of the rotation offset.
			 */
			setOffset(x: number, y: number): void;
			/**
			 * Gets the particle image's draw offset.
			 *
			 * @returns ox — The x coordinate of the particle image's draw offset.
			 * @returns oy — The y coordinate of the particle image's draw offset.
			 */
			getOffset(): LuaMultiReturn<[number, number]>;
			/**
			 * Sets a series of colors to apply to the particle sprite. The particle system will interpolate between each color evenly over the particle's lifetime.
			 *
			 * Arguments can be passed in groups of four, representing the components of the desired RGBA value, or as tables of RGBA component values, with a default alpha value of 1 if only three values are given. At least one color must be specified. A maximum of eight may be used.
			 *
			 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
			 *
			 * @param colors First color, a numerical indexed table with the red, green, blue and alpha values as numbers (0-1). The alpha is optional and defaults to 1 if it is left out.
			 */
			setColors(...colors: (Color | number)[]): void;
			/**
			 * Gets the series of colors applied to the particle sprite.
			 *
			 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
			 *
			 * @returns r1 — First color, red component (0-1).
			 * @returns g1 — First color, green component (0-1).
			 * @returns b1 — First color, blue component (0-1).
			 * @returns a1 — First color, alpha component (0-1).
			 * @returns r2 — Second color, red component (0-1).
			 * @returns g2 — Second color, green component (0-1).
			 * @returns b2 — Second color, blue component (0-1).
			 * @returns a2 — Second color, alpha component (0-1).
			 * @returns r8 — Eighth color, red component (0-1).
			 * @returns g8 — Eighth color, green component (0-1).
			 * @returns b8 — Eighth color, blue component (0-1).
			 * @returns a8 — Eighth color, alpha component (0-1).
			 */
			getColors(): LuaMultiReturn<[number, number, number, number][]>;
			/**
			 * Sets a series of Quads to use for the particle sprites. Particles will choose a Quad from the list based on the particle's current lifetime, allowing for the use of animated sprite sheets with ParticleSystems.
			 *
			 * @param quads A table containing the Quads to use.
			 */
			setQuads(...quads: (Quad | Quad[])[]): void;
			/**
			 * Gets the series of Quads used for the particle sprites.
			 *
			 * @returns quads — A table containing the Quads used.
			 */
			getQuads(): Quad[];
			/**
			 * Sets whether particle angles and rotations are relative to their velocities. If enabled, particles are aligned to the angle of their velocities and rotate relative to that angle.
			 *
			 * @param enabled True to enable relative particle rotation, false to disable it.
			 */
			setRelativeRotation(enabled: boolean): void;
			/**
			 * Gets whether particle angles and rotations are relative to their velocities. If enabled, particles are aligned to the angle of their velocities and rotate relative to that angle.
			 *
			 * @returns enable — True if relative particle rotation is enabled, false if it's disabled.
			 */
			hasRelativeRotation(): boolean;
			/**
			 * Gets the number of particles that are currently in the system.
			 *
			 * @returns count — The current number of live particles.
			 */
			getCount(): number;
			/**
			 * Starts the particle emitter.
			 */
			start(): void;
			/**
			 * Stops the particle emitter, resetting the lifetime counter.
			 */
			stop(): void;
			/**
			 * Pauses the particle emitter.
			 */
			pause(): void;
			/**
			 * Resets the particle emitter, removing any existing particles and resetting the lifetime counter.
			 */
			reset(): void;
			/**
			 * Emits a burst of particles from the particle emitter.
			 *
			 * @param count The amount of particles to emit. The number of emitted particles will be truncated if the particle system's max buffer size is reached.
			 */
			emit(count: number): void;
			/**
			 * Checks whether the particle system is actively emitting particles.
			 *
			 * @returns active — True if system is active, false otherwise.
			 */
			isActive(): boolean;
			/**
			 * Checks whether the particle system is paused.
			 *
			 * @returns paused — True if system is paused, false otherwise.
			 */
			isPaused(): boolean;
			/**
			 * Checks whether the particle system is stopped.
			 *
			 * @returns stopped — True if system is stopped, false otherwise.
			 */
			isStopped(): boolean;
			isEmpty(): boolean;
			isFull(): boolean;
			/**
			 * Updates the particle system; moving, creating and killing particles.
			 *
			 * @param deltaTime The time (seconds) since last frame.
			 */
			update(deltaTime: number): void;
		}
		type ShaderSource = string | FileData;
		type ShaderValue = number | boolean | number[] | number[][] | boolean[];
		type MatrixLayout = "row" | "column";
		/** A Shader is used for advanced hardware-accelerated pixel or vertex manipulation. These effects are written in a language based on GLSL (OpenGL Shading Language) with a few things simplified for easier coding.
		 */
		interface Shader extends Object {
			/**
			 * Gets whether an extern variable exists in the Shader.
			 *
			 * @deprecated Compatibility alias for hasUniform used by LÖVE versions before 0.10.
			 */
			getExternVariable(name: string): boolean;
			/**
			 * Returns any warning and error messages from compiling the shader code. This can be used for debugging your shaders if there's anything the graphics hardware doesn't like.
			 *
			 * @returns warnings — Warning and error messages (if any).
			 */
			getWarnings(): string;
			/**
			 * Gets whether a uniform / extern variable exists in the Shader.
			 *
			 * If a graphics driver's shader compiler determines that a uniform / extern variable doesn't affect the final output of the shader, it may optimize the variable out. This function will return false in that case.
			 *
			 * @param name The name of the uniform variable.
			 *
			 * @returns hasuniform — Whether the uniform exists in the shader and affects its final output.
			 */
			hasUniform(name: string): boolean;
			/**
			 * Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
			 *
			 * uniform float time; // 'float' is the typical number type used in GLSL shaders.
			 *
			 * uniform float varsvec2 light_pos;
			 *
			 * uniform vec4 colors[4;
			 *
			 * The corresponding send calls would be
			 *
			 * shader:send('time', t)
			 *
			 * shader:send('vars',a,b)
			 *
			 * shader:send('light_pos', {light_x, light_y})
			 *
			 * shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
			 *
			 * Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
			 *

			 * @param name Name of the number to send to the shader.
			 * @param texture Texture (Image or Canvas) to send to the uniform variable.
			 * @param textures Additional numbers to send if the uniform variable is an array.
			 */
			send(name: string, texture: Image | Canvas, ...textures: (Image | Canvas)[]): void;
			/**
			 * Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
			 *
			 * uniform float time; // 'float' is the typical number type used in GLSL shaders.
			 *
			 * uniform float varsvec2 light_pos;
			 *
			 * uniform vec4 colors[4;
			 *
			 * The corresponding send calls would be
			 *
			 * shader:send('time', t)
			 *
			 * shader:send('vars',a,b)
			 *
			 * shader:send('light_pos', {light_x, light_y})
			 *
			 * shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
			 *
			 * Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
			 *

			 * @param name Name of the vector to send to the shader.
			 * @param matrixLayout The layout (row- or column-major) of the matrix in memory.
			 * @param matrices Additional vectors to send if the uniform variable is an array. All vectors need to be of the same size (e.g. only vec3's).
			 */
			send(name: string, matrixLayout: MatrixLayout, ...matrices: (number[] | number[][])[]): void;
			/**
			 * Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
			 *
			 * uniform float time; // 'float' is the typical number type used in GLSL shaders.
			 *
			 * uniform float varsvec2 light_pos;
			 *
			 * uniform vec4 colors[4;
			 *
			 * The corresponding send calls would be
			 *
			 * shader:send('time', t)
			 *
			 * shader:send('vars',a,b)
			 *
			 * shader:send('light_pos', {light_x, light_y})
			 *
			 * shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
			 *
			 * Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
			 *

			 * @param name Name of the matrix to send to the shader.
			 * @param data Data object containing the values to send.
			 * @param offset Offset in bytes from the start of the Data object. (Default: 0.)
			 * @param size Size in bytes of the data to send. If nil, as many bytes as the specified uniform uses will be copied. (Default: all.)
			 */
			send(name: string, data: Data, offset?: number, size?: number): void;
			/**
			 * Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
			 *
			 * uniform float time; // 'float' is the typical number type used in GLSL shaders.
			 *
			 * uniform float varsvec2 light_pos;
			 *
			 * uniform vec4 colors[4;
			 *
			 * The corresponding send calls would be
			 *
			 * shader:send('time', t)
			 *
			 * shader:send('vars',a,b)
			 *
			 * shader:send('light_pos', {light_x, light_y})
			 *
			 * shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
			 *
			 * Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
			 *

			 * @param name Name of the Texture to send to the shader.
			 * @param matrixLayout The layout (row- or column-major) of the matrix in memory.
			 * @param data Data object containing the values to send.
			 * @param offset Offset in bytes from the start of the Data object. (Default: 0.)
			 * @param size Size in bytes of the data to send. If nil, as many bytes as the specified uniform uses will be copied. (Default: all.)
			 */
			send(name: string, matrixLayout: MatrixLayout, data: Data, offset?: number, size?: number): void;
			/**
			 * Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
			 *
			 * uniform float time; // 'float' is the typical number type used in GLSL shaders.
			 *
			 * uniform float varsvec2 light_pos;
			 *
			 * uniform vec4 colors[4;
			 *
			 * The corresponding send calls would be
			 *
			 * shader:send('time', t)
			 *
			 * shader:send('vars',a,b)
			 *
			 * shader:send('light_pos', {light_x, light_y})
			 *
			 * shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
			 *
			 * Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
			 *

			 * @param name Name of the boolean to send to the shader.
			 * @param data Data object containing the values to send.
			 * @param matrixLayout The layout (row- or column-major) of the matrix in memory.
			 * @param offset Offset in bytes from the start of the Data object. (Default: 0.)
			 * @param size Size in bytes of the data to send. If nil, as many bytes as the specified uniform uses will be copied. (Default: all.)
			 */
			send(name: string, data: Data, matrixLayout: MatrixLayout, offset?: number, size?: number): void;
			/**
			 * Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
			 *
			 * uniform float time; // 'float' is the typical number type used in GLSL shaders.
			 *
			 * uniform float varsvec2 light_pos;
			 *
			 * uniform vec4 colors[4;
			 *
			 * The corresponding send calls would be
			 *
			 * shader:send('time', t)
			 *
			 * shader:send('vars',a,b)
			 *
			 * shader:send('light_pos', {light_x, light_y})
			 *
			 * shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
			 *
			 * Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
			 *

			 * @param name Name of the uniform to send to the shader.
			 * @param values Texture (Image or Canvas) to send to the uniform variable.
			 */
			send(name: string, ...values: ShaderValue[]): void;
			/**
			 * Sends one or more colors to a special (''extern'' / ''uniform'') vec3 or vec4 variable inside the shader. The color components must be in the range of 1. The colors are gamma-corrected if global gamma-correction is enabled.
			 *
			 * Extern variables must be marked using the ''extern'' keyword, e.g.
			 *
			 * extern vec4 Color;
			 *
			 * The corresponding sendColor call would be
			 *
			 * shader:sendColor('Color', {r, g, b, a})
			 *
			 * Extern variables can be accessed in both the Vertex and Pixel stages of a shader, as long as the variable is declared in each.
			 *
			 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
			 *

			 * @param name The name of the color extern variable to send to in the shader.
			 * @param data A table with red, green, blue, and optional alpha color components in the range of 1 to send to the extern as a vector.
			 * @param offset Additional colors to send in case the extern is an array. All colors need to be of the same size (e.g. only vec3's).
			 * @param size The number of bytes to read from the Data object.
			 */
			sendColor(name: string, data: Data, offset?: number, size?: number): void;
			/**
			 * Sends one or more colors to a special (''extern'' / ''uniform'') vec3 or vec4 variable inside the shader. The color components must be in the range of 1. The colors are gamma-corrected if global gamma-correction is enabled.
			 *
			 * Extern variables must be marked using the ''extern'' keyword, e.g.
			 *
			 * extern vec4 Color;
			 *
			 * The corresponding sendColor call would be
			 *
			 * shader:sendColor('Color', {r, g, b, a})
			 *
			 * Extern variables can be accessed in both the Vertex and Pixel stages of a shader, as long as the variable is declared in each.
			 *
			 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
			 *

			 * @param name The name of the color extern variable to send to in the shader.
			 * @param values A table with red, green, blue, and optional alpha color components in the range of 1 to send to the extern as a vector.
			 */
			sendColor(name: string, ...values: ShaderValue[]): void;
		}

	/** @noSelf */
	/** The primary responsibility for the love.graphics module is the drawing of lines, shapes, text, Images and other Drawable objects onto the screen. Its secondary responsibilities include loading external files (including Images and Fonts) into memory, creating specialized objects (such as ParticleSystems or Canvases) and managing screen geometry.
	 */
	interface Graphics {
		/**
		 * Clears the screen or active Canvas to the specified color.
		 *
		 * This function is called automatically before love.draw in the default love.run function. See the example in love.run for a typical use of this function.
		 *
		 * Note that the scissor area bounds the cleared region.
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *
		 * In versions prior to background color instead.
		 *
		 */
		clear(this: void): void;
/**
 * Clears the screen or active Canvas to the specified color.
 *
 * This function is called automatically before love.draw in the default love.run function. See the example in love.run for a typical use of this function.
 *
 * Note that the scissor area bounds the cleared region.
 *
 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
 *
 * In versions prior to background color instead.
 *

 * @param red A table in the form of {r, g, b, a} containing the color to clear the first active Canvas to.
 * @param green Additional tables for each active Canvas.
 * @param blue Whether to clear the active stencil buffer, if present. It can also be an integer between 0 and 255 to clear the stencil buffer to a specific value. (Default: true.)
 * @param alpha Whether to clear the active depth buffer, if present. It can also be a number between 0 and 1 to clear the depth buffer to a specific value. (Default: true.)
 */
		clear(this: void, red: number, green: number, blue: number, alpha?: number): void;
		/**
		 * Discards (trashes) the contents of the screen or active Canvas. This is a performance optimization function with niche use cases.
		 *
		 * If the active Canvas has just been changed and the 'replace' BlendMode is about to be used to draw something which covers the entire screen, calling love.graphics.discard rather than calling love.graphics.clear or doing nothing may improve performance on mobile devices.
		 *
		 * On some desktop systems this function may do nothing.
		 *
		 * @param discardColor Whether to discard the texture(s) of the active Canvas(es) (the contents of the screen if no Canvas is active.) (Default: true.)
		 * @param discardDepthStencil Whether to discard the contents of the stencil buffer of the screen / active Canvas. (Default: true.)
		 */
		discard(this: void, discardColor?: boolean | boolean[], discardDepthStencil?: boolean): void;
		/**
		 * Immediately renders any pending automatically batched draws.
		 *
		 * LÖVE will call this function internally as needed when most state is changed, so it is not necessary to manually call it.
		 *
		 * The current batch will be automatically flushed by love.graphics state changes (except for the transform stack and the current color), as well as Shader:send and methods on Textures which change their state. Using a different Image in consecutive love.graphics.draw calls will also flush the current batch.
		 *
		 * SpriteBatches, ParticleSystems, Meshes, and Text objects do their own batching and do not affect automatic batching of other draws, aside from flushing the current batch when they're drawn.
		 */
		flushBatch(this: void): void;
		/**
		 * Sets the background color.
		 *

		 * @param red The red component (0-1).
		 * @param green The green component (0-1).
		 * @param blue The blue component (0-1).
		 * @param alpha The alpha component (0-1). (Default: 1.)
		 */
		setBackgroundColor(this: void, red: number, green: number, blue: number, alpha?: number): void;
		/**
		 * Sets the background color.
		 *

		 * @param color A numerical indexed table with the red, green, blue and alpha values as numbers. The alpha is optional and defaults to 1 if it is left out.
		 */
		setBackgroundColor(this: void, color: Color): void;
		/**
		 * Gets the current background color.
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *
		 * @returns r — The red component (0-1).
		 * @returns g — The green component (0-1).
		 * @returns b — The blue component (0-1).
		 * @returns a — The alpha component (0-1).
		 */
		getBackgroundColor(this: void): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Sets the default scaling filters used with Images, Canvases, and Fonts.
		 *
		 * Overload details:
		 * 1. This function does not apply retroactively to loaded images.
		 *
		 * @param min Filter mode used when scaling the image down.
		 * @param mag Filter mode used when scaling the image up. (Default: min.)
		 * @param anisotropy Maximum amount of Anisotropic Filtering used. (Default: 1.)
		 */
		setDefaultFilter(this: void, min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
		/**
		 * Returns the default scaling filters used with Images, Canvases, and Fonts.
		 *
		 * @returns min — Filter mode used when scaling the image down.
		 * @returns mag — Filter mode used when scaling the image up.
		 * @returns anisotropy — Maximum amount of Anisotropic Filtering used.
		 */
		getDefaultFilter(this: void): LuaMultiReturn<[FilterMode, FilterMode, number]>;
		setDefaultMipmapFilter(this: void, filter?: FilterMode, sharpness?: number): void;
		getDefaultMipmapFilter(this: void): LuaMultiReturn<[FilterMode | undefined, number]>;
		/**
		 * Sets the color used for drawing.
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *
		 * @param red The amount of red.
		 * @param green The amount of green.
		 * @param blue The amount of blue.
		 * @param alpha The amount of alpha. The alpha value will be applied to all subsequent draw operations, even the drawing of an image. (Default: 1.)
		 */
		setColor(this: void, red: number, green: number, blue: number, alpha?: number): void;
		/**
		 * Gets the current color.
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *
		 * @returns r — The red component (0-1).
		 * @returns g — The green component (0-1).
		 * @returns b — The blue component (0-1).
		 * @returns a — The alpha component (0-1).
		 */
		getColor(this: void): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Sets the line width.
		 *
		 * @param width The width of the line.
		 */
		setLineWidth(this: void, width: number): void;
		/**
		 * Gets the current line width.
		 *
		 * Overload details:
		 * 1. This function does not work in 0.8.0, but has been fixed in version 0.9.0. Use the following snippet to circumvent this in 0.8.0; love.graphics._getLineWidth = love.graphics.getLineWidth love.graphics._setLineWidth = love.graphics.setLineWidth function love.graphics.getLineWidth() return love.graphics.varlinewidth or 1 end function love.graphics.setLineWidth(w) love.graphics.varlinewidth = w; return love.graphics._setLineWidth(w) end
		 *
		 * @returns width — The current line width.
		 */
		getLineWidth(this: void): number;
		/**
		 * Sets the line style.
		 *
		 * @param style The LineStyle to use. Line styles include smooth and rough.
		 */
		setLineStyle(this: void, style: LineStyle): void;
		/**
		 * Gets the line style.
		 *
		 * @returns style — The current line style.
		 */
		getLineStyle(this: void): LineStyle;
		/**
		 * Sets the line join style. See LineJoin for the possible options.
		 *
		 * @param join The LineJoin to use.
		 */
		setLineJoin(this: void, join: LineJoin): void;
		/**
		 * Gets the line join style.
		 *
		 * @returns join — The LineJoin style.
		 */
		getLineJoin(this: void): LineJoin;
		/**
		 * Sets whether wireframe lines will be used when drawing.
		 *
		 * @param enable True to enable wireframe mode when drawing, false to disable it.
		 */
		setWireframe(this: void, enable: boolean): void;
		/**
		 * Gets whether wireframe mode is used when drawing.
		 *
		 * @returns wireframe — True if wireframe lines are used when drawing, false if it's not.
		 */
		isWireframe(this: void): boolean;
		/**
		 * Sets the point size.
		 *
		 * @param size The new point size.
		 */
		setPointSize(this: void, size: number): void;
		/**
		 * Gets the point size.
		 *
		 * @returns size — The current point size.
		 */
		getPointSize(this: void): number;
		/**
		 * Gets the width and height in pixels of the window.
		 *
		 * @returns width — The width of the window.
		 * @returns height — The height of the window.
		 */
		getDimensions(this: void): LuaMultiReturn<[number, number]>;
		/**
		 * Gets the width in pixels of the window.
		 *
		 * @returns width — The width of the window.
		 */
		getWidth(this: void): number;
		/**
		 * Gets the height in pixels of the window.
		 *
		 * @returns height — The height of the window.
		 */
		getHeight(this: void): number;
		/**
		 * Gets the width and height in pixels of the window.
		 *
		 * love.graphics.getDimensions gets the dimensions of the window in units scaled by the screen's DPI scale factor, rather than pixels. Use getDimensions for calculations related to drawing to the screen and using the graphics coordinate system (calculating the center of the screen, for example), and getPixelDimensions only when dealing specifically with underlying pixels (pixel-related calculations in a pixel Shader, for example).
		 *
		 * @returns pixelwidth — The width of the window in pixels.
		 * @returns pixelheight — The height of the window in pixels.
		 */
		getPixelDimensions(this: void): LuaMultiReturn<[number, number]>;
		/**
		 * Gets the width in pixels of the window.
		 *
		 * The graphics coordinate system and DPI scale factor, rather than raw pixels. Use getWidth for calculations related to drawing to the screen and using the coordinate system (calculating the center of the screen, for example), and getPixelWidth only when dealing specifically with underlying pixels (pixel-related calculations in a pixel Shader, for example).
		 *
		 * @returns pixelwidth — The width of the window in pixels.
		 */
		getPixelWidth(this: void): number;
		/**
		 * Gets the height in pixels of the window.
		 *
		 * The graphics coordinate system and DPI scale factor, rather than raw pixels. Use getHeight for calculations related to drawing to the screen and using the coordinate system (calculating the center of the screen, for example), and getPixelHeight only when dealing specifically with underlying pixels (pixel-related calculations in a pixel Shader, for example).
		 *
		 * @returns pixelheight — The height of the window in pixels.
		 */
		getPixelHeight(this: void): number;
		/**
		 * Gets the DPI scale factor of the window.
		 *
		 * The DPI scale factor represents relative pixel density. The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.graphics.getDPIScale() would return 2 in that case.
		 *
		 * The love.window.fromPixels and love.window.toPixels functions can also be used to convert between units.
		 *
		 * The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
		 *
		 * Overload details:
		 * 1. The units of love.graphics.getWidth, love.graphics.getHeight, love.mouse.getPosition, mouse events, love.touch.getPosition, and touch events are always in DPI-scaled units rather than pixels. In LÖVE 0.10 and older they were in pixels.
		 *
		 * @returns scale — The pixel scale factor associated with the window.
		 */
		getDPIScale(this: void): number;
		/**
		 * Gets the optional graphics features and whether they're supported on the system.
		 *
		 * Some older or low-end systems don't always support all graphics features.
		 *
		 * @returns features — A table containing GraphicsFeature keys, and boolean values indicating whether each feature is supported.
		 */
		getSupported(this: void, target?: any): GraphicsFeatures;
		/**
		 * Gets the available texture types, and whether each is supported.
		 *
		 * @returns texturetypes — A table containing TextureTypes as keys, and a boolean indicating whether the type is supported as values. Not all systems support all types.
		 */
		getTextureTypes(this: void, target?: any): TextureTypes;
		/**
		 * Gets the raw and compressed pixel formats usable for Images, and whether each is supported.
		 *
		 * @returns formats — A table containing PixelFormats as keys, and a boolean indicating whether the format is supported as values. Not all systems support all formats.
		 */
		getImageFormats(this: void, target?: any): ImageFormats;
		/**
		 * Gets information about the system's video card and drivers.
		 *
		 * @returns name — The name of the renderer, e.g. 'OpenGL' or 'OpenGL ES'.
		 * @returns version — The version of the renderer with some extra driver-dependent version info, e.g. '2.1 INTEL-8.10.44'.
		 * @returns vendor — The name of the graphics card vendor, e.g. 'Intel Inc'.
		 * @returns device — The name of the graphics card, e.g. 'Intel HD Graphics 3000 OpenGL Engine'.
		 */
		getRendererInfo(this: void): LuaMultiReturn<[string, string, string, string]>;
		/**
		 * Gets the system-dependent maximum values for love.graphics features.
		 *
		 * @returns limits — A table containing GraphicsLimit keys, and number values.
		 */
		getSystemLimits(this: void, target?: any): GraphicsSystemLimits;
		/**
		 * Gets performance-related rendering statistics.
		 *

		 * @returns stats — A table with the following fields:
		 * @returns stats.drawcalls — The number of draw calls made so far during the current frame.
		 * @returns stats.canvasswitches — The number of times the active Canvas has been switched so far during the current frame.
		 * @returns stats.texturememory — The estimated total size in bytes of video memory used by all loaded Images, Canvases, and Fonts.
		 * @returns stats.images — The number of Image objects currently loaded.
		 * @returns stats.canvases — The number of Canvas objects currently loaded.
		 * @returns stats.fonts — The number of Font objects currently loaded.
		 * @returns stats.shaderswitches — The number of times the active Shader has been changed so far during the current frame.
		 * @returns stats.drawcallsbatched — The number of draw calls that were saved by LÖVE's automatic batching, since the start of the frame.
		 */
		getStats(this: void): GraphicsStats;
/**
 * Gets performance-related rendering statistics.
 *

 * @param target A table which will be filled in with the stat fields below.
 * @returns The table that was passed in above, now containing the following fields:
 * @returns stats.drawcalls — The number of draw calls made so far during the current frame.
 * @returns stats.canvasswitches — The number of times the active Canvas has been switched so far during the current frame.
 * @returns stats.texturememory — The estimated total size in bytes of video memory used by all loaded Images, Canvases, and Fonts.
 * @returns stats.images — The number of Image objects currently loaded.
 * @returns stats.canvases — The number of Canvas objects currently loaded.
 * @returns stats.fonts — The number of Font objects currently loaded.
 * @returns stats.shaderswitches — The number of times the active Shader has been changed so far during the current frame.
 * @returns stats.drawcallsbatched — The number of draw calls that were saved by LÖVE's automatic batching, since the start of the frame.
 */
		getStats(this: void, target: any): GraphicsStats;
		/**
		 * Creates a screenshot once the current frame is done (after love.draw has finished).
		 *
		 * Since this function enqueues a screenshot capture rather than executing it immediately, it can be called from an input callback or love.update and it will still capture all of what's drawn to the screen in that frame.
		 *

		 * @param filename The filename to save the screenshot to. The encoded image type is determined based on the extension of the filename, and must be one of the ImageFormats.
		 */
		captureScreenshot(this: void, filename: string): void;
		/**
		 * Creates a screenshot once the current frame is done (after love.draw has finished).
		 *
		 * Since this function enqueues a screenshot capture rather than executing it immediately, it can be called from an input callback or love.update and it will still capture all of what's drawn to the screen in that frame.
		 *

		 * @param callback Function which gets called once the screenshot has been captured. An ImageData is passed into the function as its only argument.
		 */
		captureScreenshot(this: void, callback: (imageData: ImageData) => void): void;
		/**
		 * Creates a screenshot once the current frame is done (after love.draw has finished).
		 *
		 * Since this function enqueues a screenshot capture rather than executing it immediately, it can be called from an input callback or love.update and it will still capture all of what's drawn to the screen in that frame.
		 *

		 * @param channel The Channel to push the generated ImageData to.
		 */
		captureScreenshot(this: void, channel: Channel): void;
		/**
		 * Draws a rectangle.
		 *
		 * Overload details:
		 * 1. Draws a rectangle with rounded corners.
		 *
		 * @param mode How to draw the rectangle.
		 * @param x The position of top-left corner along the x-axis.
		 * @param y The position of top-left corner along the y-axis.
		 * @param width Width of the rectangle.
		 * @param height Height of the rectangle.
		 */
		rectangle(this: void, mode: DrawMode, x: number, y: number, width: number, height: number): void;
		/**
		 * Draws a circle.
		 *
		 * @param mode How to draw the circle.
		 * @param x The position of the center along x-axis.
		 * @param y The position of the center along y-axis.
		 * @param radius The radius of the circle.
		 */
		circle(this: void, mode: DrawMode, x: number, y: number, radius: number): void;
		/**
		 * Draws a filled or unfilled arc at position (x, y). The arc is drawn from angle1 to angle2 in radians. The segments parameter determines how many segments are used to draw the arc. The more segments, the smoother the edge.
		 *

		 * @param mode How to draw the arc.
		 * @param x The position of the center along x-axis.
		 * @param y The position of the center along y-axis.
		 * @param radius Radius of the arc.
		 * @param angle1 The angle at which the arc begins.
		 * @param angle2 The angle at which the arc terminates.
		 * @param segments The number of segments used for drawing the arc. (Default: 10.)
		 */
		arc(this: void, mode: DrawMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: number): void;
		/**
		 * Draws a filled or unfilled arc at position (x, y). The arc is drawn from angle1 to angle2 in radians. The segments parameter determines how many segments are used to draw the arc. The more segments, the smoother the edge.
		 *

		 * @param mode How to draw the arc.
		 * @param arcMode The type of arc to draw.
		 * @param x The position of the center along x-axis.
		 * @param y The position of the center along y-axis.
		 * @param radius Radius of the arc.
		 * @param angle1 The angle at which the arc begins.
		 * @param angle2 The angle at which the arc terminates.
		 * @param segments The number of segments used for drawing the arc. (Default: 10.)
		 */
		arc(this: void, mode: DrawMode, arcMode: ArcMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: number): void;
		/**
		 * Draws an ellipse.
		 *
		 * @param mode How to draw the ellipse.
		 * @param x The position of the center along x-axis.
		 * @param y The position of the center along y-axis.
		 * @param radiusX The radius of the ellipse along the x-axis (half the ellipse's width).
		 * @param radiusY The radius of the ellipse along the y-axis (half the ellipse's height).
		 * @param segments The number of segments used for drawing the ellipse.
		 */
		ellipse(this: void, mode: DrawMode, x: number, y: number, radiusX: number, radiusY: number, segments?: number): void;
		/**
		 * Draws lines between points.
		 *
		 * @param x1 The position of first point on the x-axis.
		 * @param y1 The position of first point on the y-axis.
		 * @param x2 The position of second point on the x-axis.
		 * @param y2 The position of second point on the y-axis.
		 * @param coordinates You can continue passing point positions to draw a polyline.
		 */
		line(this: void, x1: number, y1: number, x2: number, y2: number, ...coordinates: number[]): void;
		/**
		 * Draw a polygon.
		 *
		 * Following the mode argument, this function can accept multiple numeric arguments or a single table of numeric arguments. In either case the arguments are interpreted as alternating x and y coordinates of the polygon's vertices.
		 *
		 * @param mode How to draw the polygon.
		 * @param x1 The vertices of the polygon. Depending on the overload: The vertices of the polygon as a table.
		 */
		polygon(this: void, mode: DrawMode, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, ...coordinates: number[]): void;
		/**
		 * Draws one or more points.
		 *
		 * Overload details:
		 * 1. Draws one or more individually colored points. In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1. The pixel grid is actually offset to the center of each pixel. So to get clean pixels drawn use 0.5 + integer increments. Points are not affected by size is always in pixels.
		 *
		 * @param x1 The position of the first point on the x-axis.
		 * @param y1 The position of the first point on the y-axis.
		 * @param coordinates The x and y coordinates of additional points.
		 */
		points(this: void, x1: number, y1: number, ...coordinates: number[]): void;
		/**
		 * Displays the results of drawing operations on the screen.
		 *
		 * This function is used when writing your own love.run function. It presents all the results of your drawing operations on the screen. See the example in love.run for a typical use of this function.
		 *
		 * Overload details:
		 * 1. * If love.window.setMode has vsync equal to true, this function can't run more frequently than the refresh rate (e.g. 60 Hz), and will halt the program until ready if necessary.
		 */
		present(this: void): void;
		/**
		 * Copies and pushes the current coordinate transformation to the transformation stack.
		 *
		 * This function is always used to prepare for a corresponding pop operation later. It stores the current coordinate transformation state into the transformation stack and keeps it active. Later changes to the transformation can be undone by using the pop operation, which returns the coordinate transform to the state it was in before calling push.
		 *
		 */
		push(this: void): void;
/**
 * Copies and pushes the current coordinate transformation to the transformation stack.
 *
 * This function is always used to prepare for a corresponding pop operation later. It stores the current coordinate transformation state into the transformation stack and keeps it active. Later changes to the transformation can be undone by using the pop operation, which returns the coordinate transform to the state it was in before calling push.
 *

 * @param stackType The type of stack to push (e.g. just transformation state, or all love.graphics state).
 */
		push(this: void, stackType: "transform" | "all"): void;
		/**
		 * Pops the current coordinate transformation from the transformation stack.
		 *
		 * This function is always used to reverse a previous push operation. It returns the current transformation state to what it was before the last preceding push.
		 */
		pop(this: void): void;
		/**
		 * Gets the current depth of the transform / state stack (the number of pushes without corresponding pops).
		 *
		 * @returns depth — The current depth of the transform and state love.graphics stack.
		 */
		getStackDepth(this: void): number;
		/**
		 * Resets the current coordinate transformation.
		 *
		 * This function is always used to reverse any previous calls to love.graphics.rotate, love.graphics.scale, love.graphics.shear or love.graphics.translate. It returns the current transformation state to its defaults.
		 */
		origin(this: void): void;
		/**
		 * Translates the coordinate system in two dimensions.
		 *
		 * When this function is called with two numbers, dx, and dy, all the following drawing operations take effect as if their x and y coordinates were x+dx and y+dy.
		 *
		 * Scale and translate are not commutative operations, therefore, calling them in different orders will change the outcome.
		 *
		 * This change lasts until love.draw() exits or else a love.graphics.pop reverts to a previous love.graphics.push.
		 *
		 * Translating using whole numbers will prevent tearing/blurring of images and fonts draw after translating.
		 *
		 * @param dx The translation relative to the x-axis.
		 * @param dy The translation relative to the y-axis.
		 */
		translate(this: void, dx: number, dy: number): void;
		/**
		 * Rotates the coordinate system in two dimensions.
		 *
		 * Calling this function affects all future drawing operations by rotating the coordinate system around the origin by the given amount of radians. This change lasts until love.draw() exits.
		 *
		 * @param angle The amount to rotate the coordinate system in radians.
		 */
		rotate(this: void, angle: number): void;
		/**
		 * Scales the coordinate system in two dimensions.
		 *
		 * By default the coordinate system in LÖVE corresponds to the display pixels in horizontal and vertical directions one-to-one, and the x-axis increases towards the right while the y-axis increases downwards. Scaling the coordinate system changes this relation.
		 *
		 * After scaling by sx and sy, all coordinates are treated as if they were multiplied by sx and sy. Every result of a drawing operation is also correspondingly scaled, so scaling by (2, 2) for example would mean making everything twice as large in both x- and y-directions. Scaling by a negative value flips the coordinate system in the corresponding direction, which also means everything will be drawn flipped or upside down, or both. Scaling by zero is not a useful operation.
		 *
		 * Scale and translate are not commutative operations, therefore, calling them in different orders will change the outcome.
		 *
		 * Scaling lasts until love.draw() exits.
		 *
		 * @param sx The scaling in the direction of the x-axis.
		 * @param sy The scaling in the direction of the y-axis. If omitted, it defaults to same as parameter sx. (Default: sx.)
		 */
		scale(this: void, sx: number, sy?: number): void;
		/**
		 * Shears the coordinate system.
		 *
		 * @param kx The shear factor on the x-axis.
		 * @param ky The shear factor on the y-axis.
		 */
		shear(this: void, kx: number, ky: number): void;
		/**
		 * Applies the given Transform object to the current coordinate transformation.
		 *
		 * This effectively multiplies the existing coordinate transformation's matrix with the Transform object's internal matrix to produce the new coordinate transformation.
		 *
		 * @param transform The Transform object to apply to the current graphics coordinate transform.
		 */
		applyTransform(this: void, transform: Transform): void;
		/**
		 * Replaces the current coordinate transformation with the given Transform object.
		 *
		 * @param transform The Transform object to replace the current graphics coordinate transform with.
		 */
		replaceTransform(this: void, transform: Transform): void;
		/**
		 * Converts the given 2D position from global coordinates into screen-space.
		 *
		 * This effectively applies the current graphics transformations to the given position. A similar Transform:transformPoint method exists for Transform objects.
		 *
		 * @param x The x component of the position in global coordinates.
		 * @param y The y component of the position in global coordinates.
		 *
		 * @returns screenX — The x component of the position with graphics transformations applied.
		 * @returns screenY — The y component of the position with graphics transformations applied.
		 */
		transformPoint(this: void, x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * Converts the given 2D position from screen-space into global coordinates.
		 *
		 * This effectively applies the reverse of the current graphics transformations to the given position. A similar Transform:inverseTransformPoint method exists for Transform objects.
		 *
		 * @param x The x component of the screen-space position.
		 * @param y The y component of the screen-space position.
		 *
		 * @returns globalX — The x component of the position in global coordinates.
		 * @returns globalY — The y component of the position in global coordinates.
		 */
		inverseTransformPoint(this: void, x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * Gets whether the graphics module is able to be used. If it is not active, love.graphics function and method calls will not work correctly and may cause the program to crash.
		 * The graphics module is inactive if a window is not open, or if the app is in the background on iOS. Typically the app's execution will be automatically paused by the system, in the latter case.
		 *
		 * @returns active — Whether the graphics module is active and able to be used.
		 */
		isActive(this: void): boolean;
		isCreated(this: void): boolean;
		/**
		 * Gets whether gamma-correct rendering is supported and enabled. It can be enabled by setting t.gammacorrect = true in love.conf.
		 *
		 * Not all devices support gamma-correct rendering, in which case it will be automatically disabled and this function will return false. It is supported on desktop systems which have graphics cards that are capable of using OpenGL 3 / DirectX 10, and iOS devices that can use OpenGL ES 3.
		 *
		 * Overload details:
		 * 1. When gamma-correct rendering is enabled, many functions and objects perform automatic color conversion between sRGB and linear RGB in order for blending and shader math to be mathematically correct (which they aren't if it's not enabled.) * The colors passed into converted from sRGB to linear RGB. * The colors set in text with per-character colors, points with per-point colors, standard custom Meshes which use the 'VertexColor' attribute name will automatically be converted from sRGB to linear RGB when those objects are drawn. * creating the Image. * Everything drawn to the screen will be blended in linear RGB and then the result will be converted to sRGB for display. * Canvases which use the 'normal' or 'srgb' CanvasFormat will have their content blended in linear RGB and the result will be stored in the canvas in sRGB, when drawing to them. When the Canvas itself is drawn, its pixel colors will be converted from sRGB to linear RGB in the same manner as Images. Keeping the canvas pixel data stored as sRGB allows for better precision (less banding) for darker colors compared to 'rgba8'. Because most conversions are automatically handled, your own code doesn't need to worry about sRGB and linear RGB color conversions when gamma-correct rendering is enabled, except in a couple cases: * If a Mesh with custom vertex attributes is used and one of the attributes is meant to be used as a color in a Shader, and the attribute isn't named 'VertexColor'. * If a Shader is used which has uniform / extern variables or other variables that are meant to be used as colors, and Shader:sendColor isn't used. In both cases, love.math.gammaToLinear can be used to convert color values to linear RGB in Lua code, or the gammaCorrectColor (or unGammaCorrectColor if necessary) shader functions can be used inside shader code. Those shader functions ''only'' do conversions if gamma-correct rendering is actually enabled. The LOVE_GAMMA_CORRECT shader preprocessor define will be set if so. Read more about gamma-correct rendering here, here, and here.
		 *
		 * @returns gammacorrect — True if gamma-correct rendering is supported and was enabled in love.conf, false otherwise.
		 */
		isGammaCorrect(this: void): boolean;
		/**
		 * Resets the current graphics settings.
		 *
		 * Calling reset makes the current drawing color white, the current background color black, disables any active color component masks, disables wireframe mode and resets the current graphics transformation to the origin. It also sets both the point and line drawing modes to smooth and their sizes to 1.0.
		 */
		reset(this: void): void;
		/**
		 * Sets the blending mode.
		 *
		 * Overload details:
		 * 1. The default 'alphamultiply' alpha mode should normally be preferred except when drawing content with pre-multiplied alpha. If content is drawn to a Canvas using the 'alphamultiply' mode, the Canvas texture will have pre-multiplied alpha afterwards, so the 'premultiplied' alpha mode should generally be used when drawing a Canvas to the screen.
		 *
		 * @param mode The blend mode to use.
		 * @param alphaMode What to do with the alpha of drawn objects when blending. (Default: 'alphamultiply'.)
		 */
		setBlendMode(this: void, mode: BlendMode, alphaMode?: BlendAlphaMode): void;
		/**
		 * Gets the blending mode.
		 *
		 * @returns mode — The current blend mode.
		 * @returns alphamode — The current blend alpha mode – it determines how the alpha of drawn objects affects blending.
		 */
		getBlendMode(this: void): LuaMultiReturn<[BlendMode, BlendAlphaMode]>;
		/**
		 * Sets or disables scissor.
		 *
		 * The scissor limits the drawing area to a specified rectangle. This affects all graphics calls, including love.graphics.clear.
		 *
		 * The dimensions of the scissor is unaffected by graphical transformations (translate, scale, ...).
		 *
		 */
		setScissor(this: void): void;
		/**
		 * Sets or disables scissor.
		 *
		 * The scissor limits the drawing area to a specified rectangle. This affects all graphics calls, including love.graphics.clear.
		 *
		 * The dimensions of the scissor is unaffected by graphical transformations (translate, scale, ...).
		 *

		 * @param x x coordinate of upper left corner.
		 * @param y y coordinate of upper left corner.
		 * @param width width of clipping rectangle.
		 * @param height height of clipping rectangle.
		 */
		setScissor(this: void, x: number, y: number, width: number, height: number): void;
		/**
		 * Gets the current scissor box.
		 *
		 * @returns x — The x-component of the top-left point of the box.
		 * @returns y — The y-component of the top-left point of the box.
		 * @returns width — The width of the box.
		 * @returns height — The height of the box.
		 */
		getScissor(this: void): LuaMultiReturn<[number, number, number, number]> | undefined;
		/**
		 * Sets the scissor to the rectangle created by the intersection of the specified rectangle with the existing scissor. If no scissor is active yet, it behaves like love.graphics.setScissor.
		 *
		 * The scissor limits the drawing area to a specified rectangle. This affects all graphics calls, including love.graphics.clear.
		 *
		 * The dimensions of the scissor is unaffected by graphical transformations (translate, scale, ...).
		 *
		 * @param x The x-coordinate of the upper left corner of the rectangle to intersect with the existing scissor rectangle.
		 * @param y The y-coordinate of the upper left corner of the rectangle to intersect with the existing scissor rectangle.
		 * @param width The width of the rectangle to intersect with the existing scissor rectangle.
		 * @param height The height of the rectangle to intersect with the existing scissor rectangle.
		 */
		intersectScissor(this: void, x: number, y: number, width: number, height: number): void;
		/**
		 * Sets the color mask. Enables or disables specific color components when rendering and clearing the screen. For example, if '''red''' is set to '''false''', no further changes will be made to the red component of any pixels.
		 *
		 */
		setColorMask(this: void): void;
		/**
		 * Sets the color mask. Enables or disables specific color components when rendering and clearing the screen. For example, if '''red''' is set to '''false''', no further changes will be made to the red component of any pixels.
		 *

		 * @param red Render red component.
		 * @param green Render green component.
		 * @param blue Render blue component.
		 * @param alpha Render alpha component.
		 */
		setColorMask(this: void, red: boolean, green: boolean, blue: boolean, alpha: boolean): void;
		/**
		 * Gets the active color components used when drawing. Normally all 4 components are active unless love.graphics.setColorMask has been used.
		 *
		 * The color mask determines whether individual components of the colors of drawn objects will affect the color of the screen. They affect love.graphics.clear and Canvas:clear as well.
		 *
		 * @returns r — Whether the red color component is active when rendering.
		 * @returns g — Whether the green color component is active when rendering.
		 * @returns b — Whether the blue color component is active when rendering.
		 * @returns a — Whether the alpha color component is active when rendering.
		 */
		getColorMask(this: void): LuaMultiReturn<[boolean, boolean, boolean, boolean]>;
		/**
		 * Configures depth testing and writing to the depth buffer.
		 *
		 * This is low-level functionality designed for use with custom vertex shaders and Meshes with custom vertex attributes. No higher level APIs are provided to set the depth of 2D graphics such as shapes, lines, and Images.
		 *
		 */
		setDepthMode(this: void): void;
		/**
		 * Configures depth testing and writing to the depth buffer.
		 *
		 * This is low-level functionality designed for use with custom vertex shaders and Meshes with custom vertex attributes. No higher level APIs are provided to set the depth of 2D graphics such as shapes, lines, and Images.
		 *

		 * @param compare Depth comparison mode used for depth testing.
		 * @param write Whether to write update / write values to the depth buffer when rendering.
		 */
		setDepthMode(this: void, compare: CompareMode, write: boolean): void;
		/**
		 * Gets the current depth test mode and whether writing to the depth buffer is enabled.
		 *
		 * This is low-level functionality designed for use with custom vertex shaders and Meshes with custom vertex attributes. No higher level APIs are provided to set the depth of 2D graphics such as shapes, lines, and Images.
		 *
		 * @returns comparemode — Depth comparison mode used for depth testing.
		 * @returns write — Whether to write update / write values to the depth buffer when rendering.
		 */
		getDepthMode(this: void): LuaMultiReturn<[CompareMode, boolean]>;
		/**
		 * Sets whether back-facing triangles in a Mesh are culled.
		 *
		 * This is designed for use with low level custom hardware-accelerated 3D rendering via custom vertex attributes on Meshes, custom vertex shaders, and depth testing with a depth buffer.
		 *
		 * By default, both front- and back-facing triangles in Meshes are rendered.
		 *
		 * @param mode The Mesh face culling mode to use (whether to render everything, cull back-facing triangles, or cull front-facing triangles).
		 */
		setMeshCullMode(this: void, mode: MeshCullMode): void;
		/**
		 * Gets whether back-facing triangles in a Mesh are culled.
		 *
		 * Mesh face culling is designed for use with low level custom hardware-accelerated 3D rendering via custom vertex attributes on Meshes, custom vertex shaders, and depth testing with a depth buffer.
		 *
		 * @returns mode — The Mesh face culling mode in use (whether to render everything, cull back-facing triangles, or cull front-facing triangles).
		 */
		getMeshCullMode(this: void): MeshCullMode;
		/**
		 * Sets whether triangles with clockwise- or counterclockwise-ordered vertices are considered front-facing.
		 *
		 * This is designed for use in combination with Mesh face culling. Other love.graphics shapes, lines, and sprites are not guaranteed to have a specific winding order to their internal vertices.
		 *
		 * @param winding The winding mode to use. The default winding is counterclockwise ('ccw').
		 */
		setFrontFaceWinding(this: void, winding: Winding): void;
		/**
		 * Gets whether triangles with clockwise- or counterclockwise-ordered vertices are considered front-facing.
		 *
		 * This is designed for use in combination with Mesh face culling. Other love.graphics shapes, lines, and sprites are not guaranteed to have a specific winding order to their internal vertices.
		 *
		 * @returns winding — The winding mode being used. The default winding is counterclockwise ('ccw').
		 */
		getFrontFaceWinding(this: void): Winding;
		/**
		 * Draws geometry as a stencil.
		 *
		 * The geometry drawn by the supplied function sets invisible stencil values of pixels, instead of setting pixel colors. The stencil buffer (which contains those stencil values) can act like a mask / stencil - love.graphics.setStencilTest can be used afterward to determine how further rendering is affected by the stencil values in each pixel.
		 *
		 * Stencil values are integers within the range of 255.
		 *

		 * @param draw Function which draws geometry. The stencil values of pixels, rather than the color of each pixel, will be affected by the geometry.
		 * @param action How to modify any stencil values of pixels that are touched by what's drawn in the stencil function. (Default: 'replace'.)
		 * @param value The new stencil value to use for pixels if the 'replace' stencil action is used. Has no effect with other stencil actions. Must be between 0 and 255. (Default: 1.)
		 * @param keepValuesOrClearValue True to preserve old stencil values of pixels, false to re-set every pixel's stencil value to 0 before executing the stencil function. love.graphics.clear will also re-set all stencil values. (Default: false.)
		 */
		stencil(this: void, draw: () => void, action?: StencilAction, value?: number, keepValuesOrClearValue?: boolean): void;
/**
 * Draws geometry as a stencil.
 *
 * The geometry drawn by the supplied function sets invisible stencil values of pixels, instead of setting pixel colors. The stencil buffer (which contains those stencil values) can act like a mask / stencil - love.graphics.setStencilTest can be used afterward to determine how further rendering is affected by the stencil values in each pixel.
 *
 * Stencil values are integers within the range of 255.
 *

 * @param draw Function which draws geometry. The stencil values of pixels, rather than the color of each pixel, will be affected by the geometry.
 * @param action How to modify any stencil values of pixels that are touched by what's drawn in the stencil function. (Default: 'replace'.)
 * @param value The new stencil value to use for pixels if the 'replace' stencil action is used. Has no effect with other stencil actions. Must be between 0 and 255. (Default: 1.)
 * @param keepValuesOrClearValue True to preserve old stencil values of pixels, false to re-set every pixel's stencil value to 0 before executing the stencil function. love.graphics.clear will also re-set all stencil values. (Default: false.)
 */
		stencil(this: void, draw: () => void, action: StencilAction, value: number, keepValuesOrClearValue: number): void;
		/**
		 * Configures or disables stencil testing.
		 *
		 * When stencil testing is enabled, the geometry of everything that is drawn afterward will be clipped / stencilled out based on a comparison between the arguments of this function and the stencil value of each pixel that the geometry touches. The stencil values of pixels are affected via love.graphics.stencil.
		 *
		 */
		setStencilTest(this: void): void;
		/**
		 * Configures or disables stencil testing.
		 *
		 * When stencil testing is enabled, the geometry of everything that is drawn afterward will be clipped / stencilled out based on a comparison between the arguments of this function and the stencil value of each pixel that the geometry touches. The stencil values of pixels are affected via love.graphics.stencil.
		 *

		 * @param compare The type of comparison to make for each pixel.
		 * @param value The value to use when comparing with the stencil value of each pixel. Must be between 0 and 255.
		 */
		setStencilTest(this: void, compare: CompareMode, value: number): void;
		/**
		 * Gets the current stencil test configuration.
		 *
		 * When stencil testing is enabled, the geometry of everything that is drawn afterward will be clipped / stencilled out based on a comparison between the arguments of this function and the stencil value of each pixel that the geometry touches. The stencil values of pixels are affected via love.graphics.stencil.
		 *
		 * Each Canvas has its own per-pixel stencil values.
		 *
		 * @returns comparemode — The type of comparison that is made for each pixel. Will be 'always' if stencil testing is disabled.
		 * @returns comparevalue — The value used when comparing with the stencil value of each pixel.
		 */
		getStencilTest(this: void): LuaMultiReturn<[CompareMode, number]>;
		/**
		 * Creates a new Font from a TrueType Font or BMFont file. Created fonts are not cached, in that calling this function with the same arguments will always create a new Font object.
		 *
		 * All variants which accept a filename can also accept a Data object instead.
		 *

		 * @param size The size of the font in pixels.
		 * @returns font — A Font object which can be used to draw text on screen.
		 */
		newFont(this: void, size?: number): Font;
		/**
		 * Creates a new Font from a TrueType Font or BMFont file. Created fonts are not cached, in that calling this function with the same arguments will always create a new Font object.
		 *
		 * All variants which accept a filename can also accept a Data object instead.
		 *

		 * @param filename The filepath to the TrueType font file.
		 * @param size The size of the font in pixels. (Default: 12.)
		 * @returns font — A Font object which can be used to draw text on screen.
		 */
		newFont(this: void, filename: string, size?: number): Font;
		/**
		 * Creates and sets a new Font.
		 *

		 * @param size The size of the font. (Default: 12.)
		 * @returns font — The new font.
		 */
		setNewFont(this: void, size?: number): Font;
		/**
		 * Creates and sets a new Font.
		 *

		 * @param filename The path and name of the file with the font.
		 * @param size The size of the font. (Default: 12.)
		 * @returns font — The new font.
		 */
		setNewFont(this: void, filename: string, size?: number): Font;
		/**
		 * Creates a new specifically formatted image.
		 *
		 * In versions prior to 0.9.0, LÖVE expects ISO 8859-1 encoding for the glyphs string.
		 *

		 * @param source The filepath to the image file.
		 * @param glyphs A string of the characters in the image in order from left to right.
		 * @param extraSpacing Additional spacing (positive or negative) to apply to each glyph in the Font. (Default: 0.)
		 * @param dpiScale The DPI scale factor of the font. (Default: 1.)
		 * @returns font — A Font object which can be used to draw text on screen.
		 */
		newImageFont(this: void, source: string | FileData | ImageData, glyphs: string, extraSpacing?: number, dpiScale?: number): Font;
		/**
		 * Creates a new specifically formatted image.
		 *
		 * In versions prior to 0.9.0, LÖVE expects ISO 8859-1 encoding for the glyphs string.
		 *

		 * @param rasterizer The ImageData object to create the font from.
		 * @returns font — A Font object which can be used to draw text on screen.
		 */
		newImageFont(this: void, rasterizer: Rasterizer): Font;
		/**
		 * Creates a new drawable Text object.
		 *
		 * @param font The font to use for the text.
		 * @param text The initial string of text that the new Text object will contain. May be nil. (Default: nil.) Depending on the overload: A table containing colors and strings to add to the object, in the form of {color1, string1, color2, string2, ...}.
		 * @param text.color1 A table containing red, green, blue, and optional alpha components to use as a color for the next string in the table, in the form of {red, green, blue, alpha}.
		 * @param text.string1 A string of text which has a color specified by the previous color.
		 * @param text.color2 A table containing red, green, blue, and optional alpha components to use as a color for the next string in the table, in the form of {red, green, blue, alpha}.
		 * @param text.string2 A string of text which has a color specified by the previous color.
		 * @param text.... Additional colors and strings.
		 *
		 * @returns text — The new drawable Text object.
		 */
		newText(this: void, font: Font, text?: ColoredText): Text;
		/**
		 * Set an already-loaded Font as the current font or create and load a new one from the file and size.
		 *
		 * It's recommended that Font objects are created with love.graphics.newFont in the loading stage and then passed to this function in the drawing stage.
		 *
		 * @param font The Font object to use.
		 */
		setFont(this: void, font: Font): void;
		/**
		 * Gets the current Font object.
		 *
		 * @returns font — The current Font. Automatically creates and sets the default font, if none is set yet.
		 */
		getFont(this: void): Font;
		/**
		 * Draws text on screen. If no Font is set, one will be created and set (once) if needed.
		 *
		 * As of LOVE 0.7.1, when using translation and scaling functions while drawing text, this function assumes the scale occurs first. If you don't script with this in mind, the text won't be in the right position, or possibly even on screen.
		 *
		 * love.graphics.print and love.graphics.printf both support UTF-8 encoding. You'll also need a proper Font for special characters.
		 *
		 * In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
		 *
		 * Overload details:
		 * 1. The color set by love.graphics.setColor will be combined (multiplied) with the colors of the text.
		 *
		 * @param text The text to draw.
		 * @param x The position to draw the object (x-axis). (Default: 0.) Depending on the overload: The position of the text on the x-axis. (Default: 0.)
		 * @param y The position to draw the object (y-axis). (Default: 0.) Depending on the overload: The position of the text on the y-axis. (Default: 0.)
		 * @param angle The orientation of the text in radians. (Default: 0.)
		 * @param scaleX Scale factor (x-axis). (Default: 1.) Depending on the overload: Scale factor on the x-axis. (Default: 1.)
		 * @param scaleY Scale factor (y-axis). (Default: sx.) Depending on the overload: Scale factor on the y-axis. (Default: sx.)
		 * @param originX Origin offset (x-axis). (Default: 0.) Depending on the overload: Origin offset on the x-axis. (Default: 0.)
		 * @param originY Origin offset (y-axis). (Default: 0.) Depending on the overload: Origin offset on the y-axis. (Default: 0.)
		 * @param shearX Shearing factor (x-axis). (Default: 0.) Depending on the overload: Shearing / skew factor on the x-axis. (Default: 0.)
		 * @param shearY Shearing factor (y-axis). (Default: 0.) Depending on the overload: Shearing / skew factor on the y-axis. (Default: 0.)
		 */
		print(this: void, text: string | number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * Draws formatted text, with word wrap and alignment.
		 *
		 * See additional notes in love.graphics.print.
		 *
		 * The word wrap limit is applied before any scaling, rotation, and other coordinate transformations. Therefore the amount of text per line stays constant given the same wrap limit, even if the scale arguments change.
		 *
		 * In version 0.9.2 and earlier, wrapping was implemented by breaking up words by spaces and putting them back together to make sure things fit nicely within the limit provided. However, due to the way this is done, extra spaces between words would end up missing when printed on the screen, and some lines could overflow past the provided wrap limit. In version 0.10.0 and newer this is no longer the case.
		 *
		 * In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
		 *
		 * Overload details:
		 * 1. The color set by love.graphics.setColor will be combined (multiplied) with the colors of the text.
		 *
		 * @param text A text string.
		 * @param x The position on the x-axis. Depending on the overload: The position of the text (x-axis).
		 * @param y The position on the y-axis. Depending on the overload: The position of the text (y-axis).
		 * @param limit Wrap the line after this many horizontal pixels. Depending on the overload: The maximum width in pixels of the text before it gets automatically wrapped to a new line.
		 * @param align The alignment. (Default: 'left'.) Depending on the overload: The alignment of the text.
		 * @param angle Orientation (radians). (Default: 0.)
		 * @param scaleX Scale factor (x-axis). (Default: 1.)
		 * @param scaleY Scale factor (y-axis). (Default: sx.)
		 * @param originX Origin offset (x-axis). (Default: 0.)
		 * @param originY Origin offset (y-axis). (Default: 0.)
		 * @param shearX Shearing factor (x-axis). (Default: 0.) Depending on the overload: Shearing / skew factor (x-axis). (Default: 0.)
		 * @param shearY Shearing factor (y-axis). (Default: 0.) Depending on the overload: Shearing / skew factor (y-axis). (Default: 0.)
		 */
		printf(this: void, text: string | number, x: number, y: number, limit: number, align?: AlignMode, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally generates or specifies mipmaps for the image.
		 *

		 * @param filename The filepath to the image file.
		 * @param settings A table containing the following fields: (Default: nil.)
		 * @returns image — A new Image object which can be drawn on screen.
		 */
		newImage(this: void, filename: string, settings?: ImageSettings): Image;
		/**
		 * Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally generates or specifies mipmaps for the image.
		 *

		 * @param data The FileData containing image file.
		 * @param settings A table containing the following fields: (Default: nil.)
		 * @returns image — A new Image object which can be drawn on screen.
		 */
		newImage(this: void, data: FileData, settings?: CompressedImageSettings): Image;
		/**
		 * Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally generates or specifies mipmaps for the image.
		 *

		 * @param data The ImageData containing image.
		 * @param settings A table containing the following fields: (Default: nil.)
		 * @returns image — A new Image object which can be drawn on screen.
		 */
		newImage(this: void, data: ImageData, settings?: ImageSettings): Image;
		/**
		 * Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally generates or specifies mipmaps for the image.
		 *

		 * @param data A CompressedImageData object. The Image will use this CompressedImageData to reload itself when love.window.setMode is called.
		 * @param settings A table containing the following fields: (Default: nil.)
		 * @returns image — A new Image object which can be drawn on screen.
		 */
		newImage(this: void, data: CompressedImageData, settings?: CompressedImageSettings): Image;
		/**
		 * Creates a new drawable Video. Currently only Ogg Theora video files are supported.
		 *

		 * @param filename The file path to the Ogg Theora video file.
		 * @param settings A table containing the following fields: (Default: nil.)
		 * @returns video — A new Video.
		 */
		newVideo(this: void, filename: string, settings?: {audio?: boolean; dpiscale?: number}): Video;
		/**
		 * Creates a new drawable Video. Currently only Ogg Theora video files are supported.
		 *

		 * @param stream The file path to the Ogg Theora video file.
		 * @param settings A table containing the following fields: (Default: nil.)
		 * @returns video — A new Video.
		 */
		newVideo(this: void, stream: VideoStream, settings?: {audio?: boolean; dpiscale?: number}): Video;
		_newVideo(this: void, filenameOrStream: string | VideoStream, dpiScale?: number): Video;
		/**
		 * Creates a new array Image.
		 *
		 * An array image / array texture is a single object which contains multiple 'layers' or 'slices' of 2D sub-images. It can be thought of similarly to a texture atlas or sprite sheet, but it doesn't suffer from the same tile / quad bleeding artifacts that texture atlases do – although every sub-image must have the same dimensions.
		 *
		 * A specific layer of an array image can be drawn with love.graphics.drawLayer / SpriteBatch:addLayer, or with the Quad variant of love.graphics.draw and Quad:setLayer, or via a custom Shader.
		 *
		 * To use an array image in a Shader, it must be declared as a ArrayImage or sampler2DArray type (instead of Image or sampler2D). The Texel(ArrayImage image, vec3 texturecoord) shader function must be used to get pixel colors from a slice of the array image. The vec3 argument contains the texture coordinate in the first two components, and the 0-based slice index in the third component.
		 *
		 * Overload details:
		 * 1. Creates an array Image given a different image file for each slice of the resulting array image object. Illustration of how an array image works: an external illustration A DPI scale of 2 (double the normal pixel density) will result in the image taking up the same space on-screen as an image with half its pixel dimensions that has a DPI scale of 1. This allows for easily swapping out image assets that take the same space on-screen but have different pixel densities, which makes supporting high-dpi / retina resolution require less code logic. In order to use an Array Texture or other non-2D texture types as the main texture in a custom void effect() variant must be used in the pixel shader, and MainTex must be declared as an ArrayImage or sampler2DArray like so: uniform ArrayImage MainTex;.
		 *
		 * @param layers A table containing filepaths to images (or File, FileData, ImageData, or CompressedImageData objects), in an array. Each sub-image must have the same dimensions. A table of tables can also be given, where each sub-table contains all mipmap levels for the slice index of that sub-table.
		 * @param settings Optional table of settings to configure the array image, containing the following fields: (Default: nil.)
		 * @param settings.mipmaps True to make the image use mipmaps, false to disable them. Mipmaps will be automatically generated if the image isn't a compressed texture format. (Default: false.)
		 * @param settings.linear True to treat the image's pixels as linear instead of sRGB, when gamma correct rendering is enabled. Most images are authored as sRGB. (Default: false.)
		 * @param settings.dpiscale The DPI scale to use when drawing the array image and calling getWidth/getHeight. (Default: 1.)
		 *
		 * @returns image — An Array Image object.
		 */
		newArrayImage(this: void, layers: ImageData[], settings?: LayeredImageSettings): Image;
		/**
		 * Creates a new cubemap Image.
		 *
		 * Cubemap images have 6 faces (sides) which represent a cube. They can't be rendered directly, they can only be used in Shader code (and sent to the shader via Shader:send).
		 *
		 * To use a cubemap image in a Shader, it must be declared as a CubeImage or samplerCube type (instead of Image or sampler2D). The Texel(CubeImage image, vec3 direction) shader function must be used to get pixel colors from the cubemap. The vec3 argument is a normalized direction from the center of the cube, rather than explicit texture coordinates.
		 *
		 * Each face in a cubemap image must have square dimensions.
		 *
		 * For variants of this function which accept a single image containing multiple cubemap faces, they must be laid out in one of the following forms in the image:
		 *
		 * +y
		 *
		 * +z +x -z
		 *
		 * -y
		 *
		 * -x
		 *
		 * or:
		 *
		 * +y
		 *
		 * -x +z +x -z
		 *
		 * -y
		 *
		 * or:
		 *
		 * +x
		 *
		 * -x
		 *
		 * +y
		 *
		 * -y
		 *
		 * +z
		 *
		 * -z
		 *
		 * or:
		 *
		 * +x -x +y -y +z -z
		 *
		 * Overload details:
		 * 1. Creates a cubemap Image given a single image file containing multiple cube faces.
		 * 2. Creates a cubemap Image given a different image file for each cube face.
		 *
		 * @param faces A table containing 6 filepaths to images (or File, FileData, ImageData, or CompressedImageData objects), in an array. Each face image must have the same dimensions. A table of tables can also be given, where each sub-table contains all mipmap levels for the cube face index of that sub-table.
		 * @param settings Optional table of settings to configure the cubemap image, containing the following fields: (Default: nil.)
		 * @param settings.mipmaps True to make the image use mipmaps, false to disable them. Mipmaps will be automatically generated if the image isn't a compressed texture format. (Default: false.)
		 * @param settings.linear True to treat the image's pixels as linear instead of sRGB, when gamma correct rendering is enabled. Most images are authored as sRGB. (Default: false.)
		 *
		 * @returns image — An cubemap Image object.
		 */
		newCubeImage(this: void, faces: [ImageData, ImageData, ImageData, ImageData, ImageData, ImageData], settings?: LayeredImageSettings): Image;
		/**
		 * Creates a new volume (3D) Image.
		 *
		 * Volume images are 3D textures with width, height, and depth. They can't be rendered directly, they can only be used in Shader code (and sent to the shader via Shader:send).
		 *
		 * To use a volume image in a Shader, it must be declared as a VolumeImage or sampler3D type (instead of Image or sampler2D). The Texel(VolumeImage image, vec3 texcoords) shader function must be used to get pixel colors from the volume image. The vec3 argument is a normalized texture coordinate with the z component representing the depth to sample at (ranging from 1).
		 *
		 * Volume images are typically used as lookup tables in shaders for color grading, for example, because sampling using a texture coordinate that is partway in between two pixels can interpolate across all 3 dimensions in the volume image, resulting in a smooth gradient even when a small-sized volume image is used as the lookup table.
		 *
		 * Array images are a much better choice than volume images for storing multiple different sprites in a single array image for directly drawing them.
		 *
		 * Overload details:
		 * 1. Creates a volume Image given multiple image files with matching dimensions. Volume images are not supported on some older mobile devices. Use love.graphics.getTextureTypes to check at runtime.
		 *
		 * @param slices A table containing filepaths to images (or File, FileData, ImageData, or CompressedImageData objects), in an array. A table of tables can also be given, where each sub-table represents a single mipmap level and contains all layers for that mipmap.
		 * @param settings Optional table of settings to configure the volume image, containing the following fields: (Default: nil.)
		 * @param settings.mipmaps True to make the image use mipmaps, false to disable them. Mipmaps will be automatically generated if the image isn't a compressed texture format. (Default: false.)
		 * @param settings.linear True to treat the image's pixels as linear instead of sRGB, when gamma correct rendering is enabled. Most images are authored as sRGB. (Default: false.)
		 *
		 * @returns image — A volume Image object.
		 */
		newVolumeImage(this: void, slices: ImageData[], settings?: LayeredImageSettings): Image;
		/**
		 * Creates a new Canvas object for offscreen rendering.
		 *

		 * @returns canvas — A new Canvas with dimensions equal to the window's size in pixels.
		 */
		newCanvas(this: void): Canvas;
/**
 * Creates a new Canvas object for offscreen rendering.
 *

 * @param width The desired width of the Canvas.
 * @param height The desired height of the Canvas.
 * @param settings A table containing the given fields: (Default: nil.)
 * @returns A new Canvas with specified width and height.
 */
		newCanvas(this: void, width: number, height: number, settings?: CanvasSettings): Canvas;
		/**
		 * Gets the available Canvas formats, and whether each is supported.
		 *
		 * @param readable If true, the returned formats will only be indicated as supported if readable flag set to true for that format, and vice versa if the parameter is false.
		 *
		 * @returns formats — A table containing CanvasFormats as keys, and a boolean indicating whether the format is supported as values. Not all systems support all formats. Depending on the overload: A table containing CanvasFormats as keys, and a boolean indicating whether the format is supported as values (taking into account the readable parameter). Not all systems support all formats.
		 */
		getCanvasFormats(this: void, readable?: boolean, formats?: CanvasFormats): CanvasFormats;
		/**
		 * Captures drawing operations to a Canvas.
		 *
		 */
		setCanvas(): void;
		/**
		 * Captures drawing operations to a Canvas.
		 *

		 * @param canvas The new render target.
		 * @param canvases A table specifying the active Canvas(es), their mipmap levels and active layers if applicable, and whether to use a stencil and/or depth buffer.
		 */
		setCanvas(canvas: Canvas, ...canvases: Canvas[]): void;
		/**
		 * Captures drawing operations to a Canvas.
		 *

		 * @param canvases A table specifying the active Canvas(es), their mipmap levels and active layers if applicable, and whether to use a stencil and/or depth buffer.
		 */
		setCanvas(canvases: Canvas[]): void;
		/**
		 * Captures drawing operations to a Canvas.
		 *

		 * @param setup A table specifying the active Canvas(es), their mipmap levels and active layers if applicable, and whether to use a stencil and/or depth buffer.
		 */
		setCanvas(setup: CanvasSetup): void;
		/**
		 * Gets the current target Canvas.
		 *
		 * @returns canvas — The Canvas set by setCanvas. Returns nil if drawing to the real screen.
		 */
		getCanvas(): Canvas | LuaMultiReturn<[Canvas, ...Canvas[]]> | CanvasSetup | undefined;
		/**
		 * Creates a new Quad.
		 *
		 * The purpose of a Quad is to use a fraction of an image to draw objects, as opposed to drawing entire image. It is most useful for sprite sheets and atlases: in a sprite atlas, multiple sprites reside in same image, quad is used to draw a specific sprite from that image; in animated sprites with all frames residing in the same image, quad is used to draw specific frame from the animation.
		 *

		 * @param x The top-left position in the Image along the x-axis.
		 * @param y The top-left position in the Image along the y-axis.
		 * @param width The width of the Quad in the Image. (Must be greater than 0.)
		 * @param height The height of the Quad in the Image. (Must be greater than 0.)
		 * @param image The texture whose width and height will be used as the reference width and height.
		 * @returns quad — The new Quad.
		 */
		newQuad(x: number, y: number, width: number, height: number, image: Image | Canvas): Quad;
		/**
		 * Creates a new Quad.
		 *
		 * The purpose of a Quad is to use a fraction of an image to draw objects, as opposed to drawing entire image. It is most useful for sprite sheets and atlases: in a sprite atlas, multiple sprites reside in same image, quad is used to draw a specific sprite from that image; in animated sprites with all frames residing in the same image, quad is used to draw specific frame from the animation.
		 *

		 * @param x The top-left position in the Image along the x-axis.
		 * @param y The top-left position in the Image along the y-axis.
		 * @param width The width of the Quad in the Image. (Must be greater than 0.)
		 * @param height The height of the Quad in the Image. (Must be greater than 0.)
		 * @param textureWidth The reference width, the width of the Image. (Must be greater than 0.)
		 * @param textureHeight The reference height, the height of the Image. (Must be greater than 0.)
		 * @returns quad — The new Quad.
		 */
		newQuad(x: number, y: number, width: number, height: number, textureWidth: number, textureHeight: number): Quad;
		/**
		 * Creates a new Mesh.
		 *
		 * Use Mesh:setTexture if the Mesh should be textured with an Image or Canvas when it's drawn.
		 *
		 * In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
		 *

		 * @param vertices The table filled with vertex information tables for each vertex as follows:
		 * @param drawMode How the vertices are used when drawing. The default mode 'fan' is sufficient for simple convex polygons. (Default: 'fan'.)
		 * @param usage The expected usage of the Mesh. The specified usage mode affects the Mesh's memory usage and performance. (Default: 'dynamic'.)
		 * @returns mesh — The new mesh.
		 */
		newMesh(vertices: MeshVertex[] | number, drawMode?: MeshDrawMode, usage?: MeshUsage): Mesh;
		/**
		 * Creates a new Mesh.
		 *
		 * Use Mesh:setTexture if the Mesh should be textured with an Image or Canvas when it's drawn.
		 *
		 * In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
		 *

		 * @param format A table in the form of {attribute, ...}. Each attribute is a table which specifies a custom vertex attribute used for each vertex.
		 * @param vertices The table filled with vertex information tables for each vertex, in the form of {vertex, ...} where each vertex is a table in the form of {attributecomponent, ...}.
		 * @param drawMode The Image or Canvas to use when drawing the Mesh. May be nil to use no texture. (Default: nil.)
		 * @param usage The expected usage of the Mesh. The specified usage mode affects the Mesh's memory usage and performance. (Default: 'dynamic'.)
		 * @returns mesh — The new mesh.
		 */
		newMesh(format: MeshVertexFormat[], vertices: MeshVertex[] | number | Data, drawMode?: MeshDrawMode, usage?: MeshUsage): Mesh;
		/**
		 * Creates a new SpriteBatch object.
		 *
		 * @param texture The Image or Canvas to use for the sprites.
		 * @param size The maximum number of sprites that the SpriteBatch can contain at any given time. Since version 11.0, additional sprites added past this number will automatically grow the spritebatch. (Default: 1000.)
		 * @param usage The expected usage of the SpriteBatch. The specified usage mode affects the SpriteBatch's memory usage and performance. (Default: 'dynamic'.)
		 *
		 * @returns spriteBatch — The new SpriteBatch.
		 */
		newSpriteBatch(texture: Image | Canvas, size?: number, usage?: MeshUsage): SpriteBatch;
		/**
		 * Creates a new ParticleSystem.
		 *
		 * @param texture The texture (Image or Canvas) to use.
		 * @param size The max number of particles at the same time. (Default: 1000.)
		 *
		 * @returns system — A new ParticleSystem.
		 */
		newParticleSystem(texture: Image | Canvas, size?: number): ParticleSystem;
		/**
		 * Creates a new Shader object for hardware-accelerated vertex and pixel effects. A Shader contains either vertex shader code, pixel shader code, or both.
		 *
		 * Shaders are small programs which are run on the graphics card when drawing. Vertex shaders are run once for each vertex (for example, an image has 4 vertices - one at each corner. A Mesh might have many more.) Pixel shaders are run once for each pixel on the screen which the drawn object touches. Pixel shader code is executed after all the object's vertices have been processed by the vertex shader.
		 *
		 * @param source The pixel shader code, or a filename pointing to a file with the code.
		 * @param pixelSource The vertex shader code, or a filename pointing to a file with the code.
		 *
		 * @returns shader — A Shader object for use in drawing operations.
		 */
		newShader(source: ShaderSource, pixelSource?: ShaderSource): Shader;
		/**
		 * Validates shader code. Check if specified shader code does not contain any errors.
		 *
		 * @param gles Validate code as GLSL ES shader.
		 * @param source The pixel shader code, or a filename pointing to a file with the code.
		 * @param pixelSource The vertex shader code, or a filename pointing to a file with the code.
		 *
		 * @returns status — true if specified shader code doesn't contain any errors. false otherwise.
		 * @returns message — Reason why shader code validation failed (or nil if validation succeded).
		 */
		validateShader(gles: boolean, source: ShaderSource, pixelSource?: ShaderSource): LuaMultiReturn<[boolean, string?]>;
		/**
		 * Sets or resets a Shader as the current pixel effect or vertex shaders. All drawing operations until the next ''love.graphics.setShader'' will be drawn using the Shader object specified.
		 *
		 */
		setShader(): void;
/**
 * Sets or resets a Shader as the current pixel effect or vertex shaders. All drawing operations until the next ''love.graphics.setShader'' will be drawn using the Shader object specified.
 *

 * @param shader The new shader.
 */
		setShader(shader: Shader): void;
		/**
		 * Gets the current Shader. Returns nil if none is set.
		 *
		 * @returns shader — The currently active Shader, or nil if none is set.
		 */
		getShader(): Shader | undefined;
		/**
		 * Draws a Drawable object (an Image, Canvas, SpriteBatch, ParticleSystem, Mesh, Text object, or Video) on the screen with optional rotation, scaling and shearing.
		 *
		 * Objects are drawn relative to their local coordinate system. The origin is by default located at the top left corner of Image and Canvas. All scaling, shearing, and rotation arguments transform the object relative to that point. Also, the position of the origin can be specified on the screen coordinate system.
		 *
		 * It's possible to rotate an object about its center by offsetting the origin to the center. Angles must be given in radians for rotation. One can also use a negative scaling factor to flip about its centerline.
		 *
		 * Note that the offsets are applied before rotation, scaling, or shearing; scaling and shearing are applied before rotation.
		 *
		 * The right and bottom edges of the object are shifted at an angle defined by the shearing factors.
		 *
		 * When using the default shader anything drawn with this function will be tinted according to the currently selected color. Set it to pure white to preserve the object's original colors.
		 *

		 * @param image A drawable object.
		 * @param x The position to draw the object (x-axis). (Default: 0.)
		 * @param y The position to draw the object (y-axis). (Default: 0.)
		 * @param angle Orientation (radians). (Default: 0.)
		 * @param scaleX Scale factor (x-axis). (Default: 1.)
		 * @param scaleY Scale factor (y-axis). (Default: sx.)
		 * @param originX Origin offset (x-axis). (Default: 0.)
		 * @param originY Origin offset (y-axis). (Default: 0.)
		 */
		draw(image: Image, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		/**
		 * Draws an Image on the screen using a Transform object.
		 *
		 * @param image The Image to draw.
		 * @param transform The Transform object containing the draw position, rotation, scale, shear, and origin.
		 */
		draw(image: Image, transform: Transform): void;
		/**
		 * Draws a Drawable object (an Image, Canvas, SpriteBatch, ParticleSystem, Mesh, Text object, or Video) on the screen with optional rotation, scaling and shearing.
		 *
		 * Objects are drawn relative to their local coordinate system. The origin is by default located at the top left corner of Image and Canvas. All scaling, shearing, and rotation arguments transform the object relative to that point. Also, the position of the origin can be specified on the screen coordinate system.
		 *
		 * It's possible to rotate an object about its center by offsetting the origin to the center. Angles must be given in radians for rotation. One can also use a negative scaling factor to flip about its centerline.
		 *
		 * Note that the offsets are applied before rotation, scaling, or shearing; scaling and shearing are applied before rotation.
		 *
		 * The right and bottom edges of the object are shifted at an angle defined by the shearing factors.
		 *
		 * When using the default shader anything drawn with this function will be tinted according to the currently selected color. Set it to pure white to preserve the object's original colors.
		 *

		 * @param image A drawable object.
		 * @param quad The Quad to draw on screen.
		 * @param x The position to draw the object (x-axis).
		 * @param y The position to draw the object (y-axis).
		 * @param angle Scale factor (x-axis). (Default: 1.)
		 * @param scaleX Scale factor (y-axis). (Default: sx.)
		 * @param scaleY Origin offset (x-axis). (Default: 0.)
		 * @param originX Origin offset (y-axis). (Default: 0.)
		 * @param originY Shearing factor (x-axis). (Default: 0.)
		 */
		draw(image: Image, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		/**
		 * Draws a Quad subsection of an Image on the screen using a Transform object.
		 *
		 * @param image The Image to draw.
		 * @param quad The subsection of the Image to draw.
		 * @param transform The Transform object containing the draw position, rotation, scale, shear, and origin.
		 */
		draw(image: Image, quad: Quad, transform: Transform): void;
		/**
		 * Draws a layer of an Array Texture.
		 *

		 * @param image The Array Texture to draw.
		 * @param layer The index of the layer to use when drawing.
		 * @param x The position to draw the texture (x-axis). (Default: 0.)
		 * @param y The position to draw the texture (y-axis). (Default: 0.)
		 * @param angle Orientation (radians). (Default: 0.)
		 * @param scaleX Scale factor (x-axis). (Default: 1.)
		 * @param scaleY Scale factor (y-axis). (Default: sx.)
		 * @param originX Origin offset (x-axis). (Default: 0.)
		 * @param originY Origin offset (y-axis). (Default: 0.)
		 */
		drawLayer(image: Image, layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		/**
		 * Draws a layer of an Array Texture.
		 *

		 * @param image The Array Texture to draw.
		 * @param layer The index of the layer to use when drawing.
		 * @param quad The subsection of the texture's layer to use when drawing.
		 * @param x The position to draw the texture (x-axis). (Default: 0.)
		 * @param y The position to draw the texture (y-axis). (Default: 0.)
		 * @param angle Scale factor (x-axis). (Default: 1.)
		 * @param scaleX Scale factor (y-axis). (Default: sx.)
		 * @param scaleY Origin offset (x-axis). (Default: 0.)
		 * @param originX Origin offset (y-axis). (Default: 0.)
		 * @param originY Shearing factor (x-axis). (Default: 0.)
		 */
		drawLayer(image: Image, layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		/**
		 * Draws a Canvas on the screen with optional rotation, scaling, and shearing.
		 *

		 * @param canvas The Canvas to draw.
		 * @param x The position to draw the object on the x-axis. (Default: 0.)
		 * @param y The position to draw the object on the y-axis. (Default: 0.)
		 * @param angle The orientation in radians. (Default: 0.)
		 * @param scaleX The scale factor on the x-axis. (Default: 1.)
		 * @param scaleY The scale factor on the y-axis. (Default: scaleX.)
		 * @param originX The origin offset on the x-axis. (Default: 0.)
		 * @param originY The origin offset on the y-axis. (Default: 0.)
		 */
		draw(canvas: Canvas, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		/**
		 * Draws a Canvas on the screen using a Transform object.
		 *
		 * @param canvas The Canvas to draw.
		 * @param transform The Transform object containing the draw position, rotation, scale, shear, and origin.
		 */
		draw(canvas: Canvas, transform: Transform): void;
		/**
		 * Draws a Canvas on the screen with optional rotation, scaling, and shearing.
		 *

		 * @param canvas The Canvas to draw.
		 * @param quad The subsection of the drawable to draw.
		 * @param x The position to draw the object on the x-axis. (Default: 0.)
		 * @param y The position to draw the object on the y-axis. (Default: 0.)
		 * @param angle The orientation in radians. (Default: 0.)
		 * @param scaleX The scale factor on the x-axis. (Default: 1.)
		 * @param scaleY The scale factor on the y-axis. (Default: scaleX.)
		 * @param originX The origin offset on the x-axis. (Default: 0.)
		 * @param originY The origin offset on the y-axis. (Default: 0.)
		 */
		draw(canvas: Canvas, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		/**
		 * Draws a Quad subsection of a Canvas on the screen using a Transform object.
		 *
		 * @param canvas The Canvas to draw.
		 * @param quad The subsection of the Canvas to draw.
		 * @param transform The Transform object containing the draw position, rotation, scale, shear, and origin.
		 */
		draw(canvas: Canvas, quad: Quad, transform: Transform): void;
		/**
		 * Draws a Mesh on the screen with optional rotation, scaling, and shearing.
		 *

		 * @param mesh The Mesh to draw.
		 * @param x The position to draw the object on the x-axis. (Default: 0.)
		 * @param y The position to draw the object on the y-axis. (Default: 0.)
		 * @param angle The orientation in radians. (Default: 0.)
		 * @param scaleX The scale factor on the x-axis. (Default: 1.)
		 * @param scaleY The scale factor on the y-axis. (Default: scaleX.)
		 * @param originX The origin offset on the x-axis. (Default: 0.)
		 * @param originY The origin offset on the y-axis. (Default: 0.)
		 * @param shearX The shearing factor on the x-axis. (Default: 0.)
		 * @param shearY The shearing factor on the y-axis. (Default: 0.)
		 */
		draw(mesh: Mesh, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * Draws a Mesh on the screen using a Transform object.
		 *
		 * @param mesh The Mesh to draw.
		 * @param transform The Transform object containing the draw position, rotation, scale, shear, and origin.
		 */
		draw(mesh: Mesh, transform: Transform): void;
		/**
		 * Draws many instances of a Mesh with a single draw call, using hardware geometry instancing.
		 *
		 * Each instance can have unique properties (positions, colors, etc.) but will not by default unless a custom per-instance vertex attributes or the love_InstanceID GLSL 3 vertex shader variable is used, otherwise they will all render at the same position on top of each other.
		 *
		 * Instancing is not supported by some older GPUs that are only capable of using OpenGL ES 2 or OpenGL 2. Use love.graphics.getSupported to check.
		 *
		 * @param mesh The mesh to render.
		 * @param instanceCount The number of instances to render.
		 * @param x The position to draw the instances (x-axis). (Default: 0.)
		 * @param y The position to draw the instances (y-axis). (Default: 0.)
		 * @param angle Orientation (radians). (Default: 0.)
		 * @param scaleX Scale factor (x-axis). (Default: 1.)
		 * @param scaleY Scale factor (y-axis). (Default: sx.)
		 * @param originX Origin offset (x-axis). (Default: 0.)
		 * @param originY Origin offset (y-axis). (Default: 0.)
		 * @param shearX Shearing factor (x-axis). (Default: 0.)
		 * @param shearY Shearing factor (y-axis). (Default: 0.)
		 */
		drawInstanced(mesh: Mesh, instanceCount: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * Draws many instances of a Mesh with a single draw call using a Transform object.
		 *
		 * @param mesh The Mesh to draw.
		 * @param instanceCount The number of instances to draw.
		 * @param transform The Transform object applied to every instance.
		 */
		drawInstanced(mesh: Mesh, instanceCount: number, transform: Transform): void;
		/**
		 * Draws a SpriteBatch on the screen with optional rotation, scaling, and shearing.
		 *

		 * @param batch The SpriteBatch to draw.
		 * @param x The position to draw the object on the x-axis. (Default: 0.)
		 * @param y The position to draw the object on the y-axis. (Default: 0.)
		 * @param angle The orientation in radians. (Default: 0.)
		 * @param scaleX The scale factor on the x-axis. (Default: 1.)
		 * @param scaleY The scale factor on the y-axis. (Default: scaleX.)
		 * @param originX The origin offset on the x-axis. (Default: 0.)
		 * @param originY The origin offset on the y-axis. (Default: 0.)
		 * @param shearX The shearing factor on the x-axis. (Default: 0.)
		 * @param shearY The shearing factor on the y-axis. (Default: 0.)
		 */
		draw(batch: SpriteBatch, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * Draws a SpriteBatch on the screen using a Transform object.
		 *
		 * @param batch The SpriteBatch to draw.
		 * @param transform The Transform object containing the draw position, rotation, scale, shear, and origin.
		 */
		draw(batch: SpriteBatch, transform: Transform): void;
		/**
		 * Draws a ParticleSystem on the screen with optional rotation, scaling, and shearing.
		 *

		 * @param particles The ParticleSystem to draw.
		 * @param x The position to draw the object on the x-axis. (Default: 0.)
		 * @param y The position to draw the object on the y-axis. (Default: 0.)
		 * @param angle The orientation in radians. (Default: 0.)
		 * @param scaleX The scale factor on the x-axis. (Default: 1.)
		 * @param scaleY The scale factor on the y-axis. (Default: scaleX.)
		 * @param originX The origin offset on the x-axis. (Default: 0.)
		 * @param originY The origin offset on the y-axis. (Default: 0.)
		 * @param shearX The shearing factor on the x-axis. (Default: 0.)
		 * @param shearY The shearing factor on the y-axis. (Default: 0.)
		 */
		draw(particles: ParticleSystem, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * Draws a ParticleSystem on the screen using a Transform object.
		 *
		 * @param particles The ParticleSystem to draw.
		 * @param transform The Transform object containing the draw position, rotation, scale, shear, and origin.
		 */
		draw(particles: ParticleSystem, transform: Transform): void;
		/**
		 * Draws a Text on the screen with optional rotation, scaling, and shearing.
		 *

		 * @param text The Text object to draw.
		 * @param x The position to draw the object on the x-axis. (Default: 0.)
		 * @param y The position to draw the object on the y-axis. (Default: 0.)
		 * @param angle The orientation in radians. (Default: 0.)
		 * @param scaleX The scale factor on the x-axis. (Default: 1.)
		 * @param scaleY The scale factor on the y-axis. (Default: scaleX.)
		 * @param originX The origin offset on the x-axis. (Default: 0.)
		 * @param originY The origin offset on the y-axis. (Default: 0.)
		 * @param shearX The shearing factor on the x-axis. (Default: 0.)
		 * @param shearY The shearing factor on the y-axis. (Default: 0.)
		 */
		draw(text: Text, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * Draws a Text object on the screen using a Transform object.
		 *
		 * @param text The Text object to draw.
		 * @param transform The Transform object containing the draw position, rotation, scale, shear, and origin.
		 */
		draw(text: Text, transform: Transform): void;
		/**
		 * Draws a Video on the screen with optional rotation, scaling, and shearing.
		 *

		 * @param video The Video to draw.
		 * @param x The position to draw the object on the x-axis. (Default: 0.)
		 * @param y The position to draw the object on the y-axis. (Default: 0.)
		 * @param angle The orientation in radians. (Default: 0.)
		 * @param scaleX The scale factor on the x-axis. (Default: 1.)
		 * @param scaleY The scale factor on the y-axis. (Default: scaleX.)
		 * @param originX The origin offset on the x-axis. (Default: 0.)
		 * @param originY The origin offset on the y-axis. (Default: 0.)
		 * @param shearX The shearing factor on the x-axis. (Default: 0.)
		 * @param shearY The shearing factor on the y-axis. (Default: 0.)
		 */
		draw(video: Video, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * Draws a Video on the screen using a Transform object.
		 *
		 * @param video The Video to draw.
		 * @param transform The Transform object containing the draw position, rotation, scale, shear, and origin.
		 */
		draw(video: Video, transform: Transform): void;
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
	 */
	interface Window {
		/** Deprecated alias for the current window width. */
		getWidth(this: void): number;
		/** Deprecated alias for the current window height. */
		getHeight(this: void): number;
		/** Deprecated alias for the current window dimensions. */
		getDimensions(this: void): LuaMultiReturn<[number, number]>;
		/**
		 * Gets the width and height of the desktop.
		 *
		 * @param display The index of the display, if multiple monitors are available. (Default: 1.)
		 *
		 * @returns width — The width of the desktop.
		 * @returns height — The height of the desktop.
		 */
		getDesktopDimensions(this: void, display?: number): LuaMultiReturn<[number, number]>;
		/**
		 * Gets the number of connected monitors.
		 *
		 * @returns count — The number of currently connected displays.
		 */
		getDisplayCount(this: void): number;
		/**
		 * Gets the name of a display.
		 *
		 * @param display The index of the display to get the name of. (Default: 1.)
		 *
		 * @returns name — The name of the specified display.
		 */
		getDisplayName(this: void, display: number): string;
		/**
		 * Gets current device display orientation.
		 *
		 * @param display Display index to get its display orientation, or nil for default display index. (Default: nil.)
		 *
		 * @returns orientation — Current device display orientation.
		 */
		getDisplayOrientation(this: void, display?: number): "unknown" | "landscape" | "portrait" | "landscapeflipped" | "portraitflipped";
		/**
		 * Gets a list of supported fullscreen modes.
		 *
		 * @param display The index of the display, if multiple monitors are available. (Default: 1.)
		 *
		 * @returns modes — A table of width/height pairs. (Note that this may not be in order.)
		 * @returns modes.width — Window fullscreen width.
		 * @returns modes.height — Window fullscreen height.
		 */
		getFullscreenModes(this: void, display?: number): WindowSize[];
		/**
		 * Enters or exits fullscreen. The display to use when entering fullscreen is chosen based on which display the window is currently in, if multiple monitors are connected.
		 *
		 * Overload details:
		 * 1. If fullscreen mode is entered and the window size doesn't match one of the monitor's display modes (in normal fullscreen mode) or the window size doesn't match the desktop size (in 'desktop' fullscreen mode), the window will be resized appropriately. The window will revert back to its original size again when fullscreen mode is exited using this function.
		 *
		 * @param fullscreen Whether to enter or exit fullscreen mode.
		 * @param type The type of fullscreen mode to use.
		 *
		 * @returns success — True if an attempt to enter fullscreen was successful, false otherwise.
		 */
		setFullscreen(this: void, fullscreen: boolean, type?: "desktop" | "exclusive"): boolean;
		/**
		 * Gets whether the window is fullscreen.
		 *
		 * @returns fullscreen — True if the window is fullscreen, false otherwise.
		 * @returns fstype — The type of fullscreen mode used.
		 */
		getFullscreen(this: void): LuaMultiReturn<[boolean, "desktop" | "exclusive"]>;
		/**
		 * Checks if the window is open.
		 *
		 * @returns open — True if the window is open, false otherwise.
		 */
		isOpen(this: void): boolean;
		/**
		 * Gets the window icon.
		 *
		 * @returns imagedata — The window icon imagedata, or nil if no icon has been set with love.window.setIcon.
		 */
		getIcon(this: void): ImageData | undefined;
		/**
		 * Sets the window icon from ImageData.
		 *
		 * Embedded LoveNode surfaces accept this request without changing the Dora host application's icon.
		 * @param imagedata — The window icon image data.
		 * @returns success — True when the icon request was accepted.
		 */
		setIcon(this: void, imagedata: ImageData): boolean;
		/**
		 * Gets the display mode and properties of the window.
		 *
		 * @returns width — Window width.
		 * @returns height — Window height.
		 * @returns flags — Table with the window properties:
		 * @returns flags.fullscreen — Fullscreen (true), or windowed (false).
		 * @returns flags.fullscreentype — The type of fullscreen mode used.
		 * @returns flags.vsync — True if the graphics framerate is synchronized with the monitor's refresh rate, false otherwise.
		 * @returns flags.msaa — The number of antialiasing samples used (0 if MSAA is disabled).
		 * @returns flags.resizable — True if the window is resizable in windowed mode, false otherwise.
		 * @returns flags.borderless — True if the window is borderless in windowed mode, false otherwise.
		 * @returns flags.centered — True if the window is centered in windowed mode, false otherwise.
		 * @returns flags.display — The index of the display the window is currently in, if multiple monitors are available.
		 * @returns flags.minwidth — The minimum width of the window, if it's resizable.
		 * @returns flags.minheight — The minimum height of the window, if it's resizable.
		 * @returns flags.highdpi — True if high-dpi mode is allowed on Retina displays in OS X. Does nothing on non-Retina displays.
		 * @returns flags.refreshrate — The refresh rate of the screen's current display mode, in Hz. May be 0 if the value can't be determined.
		 * @returns flags.x — The x-coordinate of the window's position in its current display.
		 * @returns flags.y — The y-coordinate of the window's position in its current display.
		 * @returns flags.srgb — Removed in 0.10.0 (use love.graphics.isGammaCorrect instead). True if sRGB gamma correction is applied when drawing to the screen.
		 */
		getMode(this: void): LuaMultiReturn<[number, number, WindowMode]>;
		/**
		 * Sets the display mode and properties of the window.
		 *
		 * If width or height is 0, setMode will use the width and height of the desktop.
		 *
		 * Changing the display mode may have side effects: for example, canvases will be cleared and values sent to shaders with canvases beforehand or re-draw to them afterward if you need to.
		 *
		 * Overload details:
		 * 1. * If fullscreen is enabled and the width or height is not supported (see resize event will be triggered. * If the fullscreen type is 'desktop', then the window will be automatically resized to the desktop resolution. * If the width and height is bigger than or equal to the desktop dimensions (this includes setting both to 0) and fullscreen is set to false, it will appear 'visually' fullscreen, but it's not true fullscreen and conf.lua (i.e. t.window = false) and use this function to manually create the window, then you must not call any other love.graphics.* function before this one. Doing so will result in undefined behavior and/or crashes because OpenGL cannot function properly without a window. * Transparent backgrounds are currently not supported.
		 *
		 * @param width Display width.
		 * @param height Display height.
		 * @param settings The flags table with the options:
		 * @param settings.fullscreen Fullscreen (true), or windowed (false). (Default: false.)
		 * @param settings.fullscreentype The type of fullscreen to use. This defaults to 'normal' in 0.9.0 through 0.9.2 and to 'desktop' in 0.10.0 and older. (Default: 'desktop'.)
		 * @param settings.vsync True if LÖVE should wait for vsync, false otherwise. (Default: true.)
		 * @param settings.msaa The number of antialiasing samples. (Default: 0.)
		 * @param settings.stencil Whether a stencil buffer should be allocated. If true, the stencil buffer will have 8 bits. (Default: true.)
		 * @param settings.depth The number of bits in the depth buffer. (Default: 0.)
		 * @param settings.resizable True if the window should be resizable in windowed mode, false otherwise. (Default: false.)
		 * @param settings.borderless True if the window should be borderless in windowed mode, false otherwise. (Default: false.)
		 * @param settings.centered True if the window should be centered in windowed mode, false otherwise. (Default: true.)
		 * @param settings.display The index of the display to show the window in, if multiple monitors are available. (Default: 1.)
		 * @param settings.minwidth The minimum width of the window, if it's resizable. Cannot be less than 1. (Default: 1.)
		 * @param settings.minheight The minimum height of the window, if it's resizable. Cannot be less than 1. (Default: 1.)
		 * @param settings.highdpi True if high-dpi mode should be used on Retina displays in macOS and iOS. Does nothing on non-Retina displays. (Default: false.)
		 * @param settings.x The x-coordinate of the window's position in the specified display. (Default: nil.)
		 * @param settings.y The y-coordinate of the window's position in the specified display. (Default: nil.)
		 * @param settings.usedpiscale Disables automatic DPI scaling when false. (Default: true.)
		 * @param settings.srgb Removed in 0.10.0 (set t.gammacorrect in conf.lua instead). True if sRGB gamma correction should be applied when drawing to the screen. (Default: false.)
		 *
		 * @returns success — True if successful, false otherwise.
		 */
		setMode(this: void, width: number, height: number, settings?: WindowModeSettings): boolean;
		/**
		 * Sets the display mode and properties of the window, without modifying unspecified properties.
		 *
		 * If width or height is 0, updateMode will use the width and height of the desktop.
		 *
		 * Changing the display mode may have side effects: for example, canvases will be cleared. Make sure to save the contents of canvases beforehand or re-draw to them afterward if you need to.
		 *

		 * @param settings The settings table with the following optional fields. Any field not filled in will use the current value that would be returned by love.window.getMode.
		 * @returns success — True if successful, false otherwise.
		 */
		updateMode(this: void, settings: WindowModeSettings): boolean;
		/**
		 * Sets the display mode and properties of the window, without modifying unspecified properties.
		 *
		 * If width or height is 0, updateMode will use the width and height of the desktop.
		 *
		 * Changing the display mode may have side effects: for example, canvases will be cleared. Make sure to save the contents of canvases beforehand or re-draw to them afterward if you need to.
		 *

		 * @param width Window width.
		 * @param height Window height.
		 * @param settings The settings table with the following optional fields. Any field not filled in will use the current value that would be returned by love.window.getMode.
		 * @returns success — True if successful, false otherwise.
		 */
		updateMode(this: void, width: number, height: number, settings?: WindowModeSettings): boolean;
		/**
		 * Gets the position of the window on the screen.
		 *
		 * The window position is in the coordinate space of the display it is currently in.
		 *
		 * @returns x — The x-coordinate of the window's position.
		 * @returns y — The y-coordinate of the window's position.
		 * @returns displayindex — The index of the display that the window is in.
		 */
		getPosition(this: void): LuaMultiReturn<[number, number, number]>;
		/**
		 * Gets area inside the window which is known to be unobstructed by a system title bar, the iPhone X notch, etc. Useful for making sure UI elements can be seen by the user.
		 *
		 * Overload details:
		 * 1. Values returned are in DPI-scaled units (the same coordinate system as most other window-related APIs), not in pixels.
		 *
		 * @returns x — Starting position of safe area (x-axis).
		 * @returns y — Starting position of safe area (y-axis).
		 * @returns w — Width of safe area.
		 * @returns h — Height of safe area.
		 */
		getSafeArea(this: void): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Sets the window title.
		 *
		 * @param title The new window title.
		 */
		setTitle(this: void, title: string): void;
		/**
		 * Gets the window title.
		 *
		 * @returns title — The current window title.
		 */
		getTitle(this: void): string;
		/**
		 * Sets vertical synchronization mode.
		 *
		 * Overload details:
		 * 1. * Not all graphics drivers support adaptive vsync (-1 value). In that case, it will be automatically set to 1. * It is recommended to keep vsync activated if you don't know about the possible implications of turning it off. * This function doesn't recreate the window, unlike love.window.setMode and love.window.updateMode.
		 *
		 * @param vsync VSync number: 1 to enable, 0 to disable, and -1 for adaptive vsync.
		 */
		setVSync(this: void, vsync: boolean | number): void;
		/**
		 * Gets current vertical synchronization (vsync).
		 *
		 * Overload details:
		 * 1. This can be less expensive alternative to love.window.getMode if you want to get current vsync status.
		 *
		 * @returns vsync — Current vsync status. 1 if enabled, 0 if disabled, and -1 for adaptive vsync.
		 */
		getVSync(this: void): number;
		/**
		 * Sets whether the display is allowed to sleep while the program is running.
		 *
		 * Display sleep is disabled by default. Some types of input (e.g. joystick button presses) might not prevent the display from sleeping, if display sleep is allowed.
		 *
		 * @param enabled True to enable system display sleep, false to disable it.
		 */
		setDisplaySleepEnabled(this: void, enabled: boolean): void;
		/**
		 * Gets whether the display is allowed to sleep while the program is running.
		 *
		 * Display sleep is disabled by default. Some types of input (e.g. joystick button presses) might not prevent the display from sleeping, if display sleep is allowed.
		 *
		 * @returns enabled — True if system display sleep is enabled / allowed, false otherwise.
		 */
		isDisplaySleepEnabled(this: void): boolean;
		/**
		 * Checks if the game window has keyboard focus.
		 *
		 * @returns focus — True if the window has the focus or false if not.
		 */
		hasFocus(this: void): boolean;
		/**
		 * Checks if the game window has mouse focus.
		 *
		 * @returns focus — True if the window has mouse focus or false if not.
		 */
		hasMouseFocus(this: void): boolean;
		/**
		 * Checks if the game window is visible.
		 *
		 * The window is considered visible if it's not minimized and the program isn't hidden.
		 *
		 * @returns visible — True if the window is visible or false if not.
		 */
		isVisible(this: void): boolean;
		/**
		 * Gets whether the Window is currently maximized.
		 *
		 * The window can be maximized if it is not fullscreen and is resizable, and either the user has pressed the window's Maximize button or love.window.maximize has been called.
		 *
		 * @returns maximized — True if the window is currently maximized in windowed mode, false otherwise.
		 */
		isMaximized(this: void): boolean;
		/**
		 * Gets whether the Window is currently minimized.
		 *
		 * @returns minimized — True if the window is currently minimized, false otherwise.
		 */
		isMinimized(this: void): boolean;
		/**
		 * Gets the DPI scale factor associated with the window.
		 *
		 * The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.getDPIScale() would return 2.0 in that case.
		 *
		 * The love.window.fromPixels and love.window.toPixels functions can also be used to convert between units.
		 *
		 * The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
		 *
		 * Overload details:
		 * 1. The units of love.graphics.getWidth, love.graphics.getHeight, love.mouse.getPosition, mouse events, love.touch.getPosition, and touch events are always in terms of pixels.
		 *
		 * @returns scale — The pixel scale factor associated with the window.
		 */
		getDPIScale(this: void): number;
		getNativeDPIScale(this: void): number;
		/**
		 * Converts a number from density-independent units to pixels.
		 *
		 * The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.toPixels(800) would return 1600 in that case.
		 *
		 * This is used to convert coordinates from the size users are expecting them to display at onscreen to pixels. love.window.fromPixels does the opposite. The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
		 *
		 * Most LÖVE functions return values and expect arguments in terms of pixels rather than density-independent units.
		 *

		 * @param value A number in density-independent units to convert to pixels.
		 * @returns pixelvalue — The converted number, in pixels.
		 * @returns px — The converted x-axis value of the coordinate, in pixels.
		 * @returns py — The converted y-axis value of the coordinate, in pixels.
		 */
		toPixels(this: void, value: number): number;
		/**
		 * Converts a number from density-independent units to pixels.
		 *
		 * The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.toPixels(800) would return 1600 in that case.
		 *
		 * This is used to convert coordinates from the size users are expecting them to display at onscreen to pixels. love.window.fromPixels does the opposite. The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
		 *
		 * Most LÖVE functions return values and expect arguments in terms of pixels rather than density-independent units.
		 *

		 * @param x The x-axis value of a coordinate in density-independent units to convert to pixels.
		 * @param y The y-axis value of a coordinate in density-independent units to convert to pixels.
		 * @returns pixelvalue — The converted number, in pixels.
		 * @returns px — The converted x-axis value of the coordinate, in pixels.
		 * @returns py — The converted y-axis value of the coordinate, in pixels.
		 */
		toPixels(this: void, x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * Converts a number from pixels to density-independent units.
		 *
		 * The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.fromPixels(1600) would return 800 in that case.
		 *
		 * This function converts coordinates from pixels to the size users are expecting them to display at onscreen. love.window.toPixels does the opposite. The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
		 *
		 * Most LÖVE functions return values and expect arguments in terms of pixels rather than density-independent units.
		 *

		 * @param value A number in pixels to convert to density-independent units.
		 * @returns value — The converted number, in density-independent units.
		 * @returns x — The converted x-axis value of the coordinate, in density-independent units.
		 * @returns y — The converted y-axis value of the coordinate, in density-independent units.
		 */
		fromPixels(this: void, value: number): number;
		/**
		 * Converts a number from pixels to density-independent units.
		 *
		 * The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.fromPixels(1600) would return 800 in that case.
		 *
		 * This function converts coordinates from pixels to the size users are expecting them to display at onscreen. love.window.toPixels does the opposite. The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
		 *
		 * Most LÖVE functions return values and expect arguments in terms of pixels rather than density-independent units.
		 *

		 * @param x The x-axis value of a coordinate in pixels.
		 * @param y The y-axis value of a coordinate in pixels.
		 * @returns value — The converted number, in density-independent units.
		 * @returns x — The converted x-axis value of the coordinate, in density-independent units.
		 * @returns y — The converted y-axis value of the coordinate, in density-independent units.
		 */
		fromPixels(this: void, x: number, y: number): LuaMultiReturn<[number, number]>;
	}

	/** @noSelf */
	/** Manages events, like keypresses.
	 */
	interface Event {
		/** Dora already owns the platform event pump; this synchronizes no additional OS queue. */
		/**
		 * Pump events into the event queue.
		 *
		 * This is a low-level function, and is usually not called by the user, but by love.run.
		 *
		 * Note that this does need to be called for any OS to think you're still running,
		 *
		 * and if you want to handle OS-generated events at all (think callbacks).
		 */
		pump(this: void): void;
		/**
		 * Returns an iterator for messages in the event queue.
		 *
		 * @returns i — Iterator function usable in a for loop.
		 */
		poll(this: void): () => LuaMultiReturn<[string, ...unknown[]] | []>;
		/** Returns immediately with no values when the embedded instance queue is empty. */
		/**
		 * Like love.event.poll(), but blocks until there is an event in the queue.
		 *
		 * @returns n — The name of event.
		 * @returns a — First event argument.
		 * @returns b — Second event argument.
		 * @returns c — Third event argument.
		 * @returns d — Fourth event argument.
		 * @returns e — Fifth event argument.
		 * @returns f — Sixth event argument.
		 * @returns ... — Further event arguments may follow.
		 */
		wait(this: void): LuaMultiReturn<[string, ...unknown[]] | []>;
		/**
		 * Adds an event to the event queue.
		 *
		 * From 0.10.0 onwards, you may pass an arbitrary amount of arguments with this function, though the default callbacks don't ever use more than six.
		 *
		 * @param name The name of the event.
		 * @param args First event argument. (Default: nil.)
		 */
		push(this: void, name: string, ...args: (boolean | number | string | LuaUserdata | undefined)[]): boolean;
		/**
		 * Clears the event queue.
		 */
		clear(this: void): void;
		/** Requests that only the current embedded Love instance stop. */
		/**
		 * Adds the quit event to the queue.
		 *
		 * The quit event is a signal for the event handler to close LÖVE. It's possible to abort the exit process with the love.quit callback.
		 *

		 * @param exitStatus The program exit status to use when closing the application. (Default: 0.)
		 * @returns Always returns true after the quit event is queued.
		 */
		quit(this: void, exitStatus?: number): true;
		/**
		 * Adds the quit event to the queue.
		 *
		 * The quit event is a signal for the event handler to close LÖVE. It's possible to abort the exit process with the love.quit callback.
		 *

		 * @param reason Tells the default love.run to exit and restart the game without relaunching the executable.
		 * @returns Always returns true after the restart quit event is queued.
		 */
		quit(this: void, reason: "restart"): true;
	}

	type FileType = "file" | "directory";
	type FileMode = "c" | "r" | "w" | "a";
	type OpenFileMode = "r" | "w" | "a";
	type BufferMode = "none" | "line" | "full";
	/** The superclass of all data.
	 */
	interface Data extends Object {
		/**
		 * Gets the full Data as a string.
		 *
		 * @returns data — The raw data.
		 */
		getString(): string;
		/**
		 * Gets the Data's size in bytes.
		 *
		 * @returns size — The size of the Data in bytes.
		 */
		getSize(): number;
		/**
		 * Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
		 *
		 * @returns pointer — A raw pointer to the Data.
		 */
		getPointer(): LuaUserdata;
		/**
		 * Gets an FFI pointer to the Data.
		 *
		 * This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.
		 *
		 * @returns pointer — A raw void* pointer to the Data, or nil if FFI is unavailable.
		 */
		getFFIPointer(): undefined;
	}
	/** Data object containing arbitrary bytes in an contiguous memory.
	 */
	interface ByteData extends Data { clone(): ByteData; }
	interface DataView extends Data { clone(): DataView; }
	/** Represents byte data compressed using a specific algorithm.
	 */
	interface CompressedData extends Data {
		/**
		 * Creates a new copy of the Data object.
		 *
		 * @returns clone — The new copy.
		 */
		clone(): CompressedData;
		/**
		 * Gets the compression format of the CompressedData.
		 *
		 * @returns format — The format of the CompressedData.
		 */
		getFormat(): "zlib" | "gzip" | "deflate" | "lz4";
	}
	type DataContainer = "data" | "string";
	type EncodeFormat = "hex" | "base64";
	type CompressionFormat = "zlib" | "gzip" | "deflate" | "lz4";
	type HashFunction = "md5" | "sha1" | "sha224" | "sha256" | "sha384" | "sha512";
	/** @noSelf */
	/** Provides functionality for creating and transforming data.
	 */
	interface DataModule {
		/**
		 * Creates a new Data object containing arbitrary bytes.
		 *
		 * Data:getPointer along with LuaJIT's FFI can be used to manipulate the contents of the ByteData object after it has been created.
		 *

		 * @param size The size in bytes of the new Data object. (Default: data:getSize().)
		 * @returns bytedata — The new Data object.
		 */
		newByteData(this: void, size: number): ByteData;
		/**
		 * Creates a new Data object containing arbitrary bytes.
		 *
		 * Data:getPointer along with LuaJIT's FFI can be used to manipulate the contents of the ByteData object after it has been created.
		 *

		 * @param bytes The size in bytes of the new Data object.
		 * @returns bytedata — The new Data object.
		 */
		newByteData(this: void, bytes: string): ByteData;
		/**
		 * Creates a new Data object containing arbitrary bytes.
		 *
		 * Data:getPointer along with LuaJIT's FFI can be used to manipulate the contents of the ByteData object after it has been created.
		 *

		 * @param data The existing Data object to copy.
		 * @param offset The offset of the subsection to copy, in bytes. (Default: 0.)
		 * @param size The size in bytes of the new Data object.
		 * @returns bytedata — The new Data object.
		 */
		newByteData(this: void, data: Data, offset?: number, size?: number): ByteData;
		/**
		 * Creates a new Data referencing a subsection of an existing Data object.
		 *
		 * Overload details:
		 * 1. Data:getString and Data:getPointer will return the original Data object's contents, with the view's offset and size applied.
		 *
		 * @param data The Data object to reference.
		 * @param offset The offset of the subsection to reference, in bytes.
		 * @param size The size in bytes of the subsection to reference.
		 *
		 * @returns view — The new Data view.
		 */
		newDataView(this: void, data: Data, offset: number, size: number): DataView;
		/**
		 * Encode Data or a string to a Data or string in one of the EncodeFormats.
		 *

		 * @param container What type to return the encoded data as.
		 * @param format The format of the output data.
		 * @param source The raw data to encode.
		 * @param lineLength The maximum line length of the output. Only supported for base64, ignored if 0. (Default: 0.)
		 * @returns encoded — ByteData/string which contains the encoded version of source.
		 */
		encode(this: void, container: "string", format: EncodeFormat, source: string | Data, lineLength?: number): string;
		/**
		 * Encode Data or a string to a Data or string in one of the EncodeFormats.
		 *

		 * @param container What type to return the encoded data as.
		 * @param format The format of the output data.
		 * @param source The raw data to encode.
		 * @param lineLength The maximum line length of the output. Only supported for base64, ignored if 0. (Default: 0.)
		 * @returns encoded — ByteData/string which contains the encoded version of source.
		 */
		encode(this: void, container: "data", format: EncodeFormat, source: string | Data, lineLength?: number): ByteData;
		/**
		 * Decode Data or a string from any of the EncodeFormats to Data or string.
		 *

		 * @param container What type to return the decoded data as.
		 * @param format The format of the input data.
		 * @param source The raw (encoded) data to decode.
		 * @returns decoded — ByteData/string which contains the decoded version of source.
		 */
		decode(this: void, container: "string", format: EncodeFormat, source: string | Data): string;
		/**
		 * Decode Data or a string from any of the EncodeFormats to Data or string.
		 *

		 * @param container What type to return the decoded data as.
		 * @param format The format of the input data.
		 * @param source The raw (encoded) data to decode.
		 * @returns decoded — ByteData/string which contains the decoded version of source.
		 */
		decode(this: void, container: "data", format: EncodeFormat, source: string | Data): ByteData;
		/**
		 * Compresses a string or data using a specific compression algorithm.
		 *

		 * @param container What type to return the compressed data as.
		 * @param format The format to use when compressing the string.
		 * @param source The raw (un-compressed) string to compress.
		 * @param level The level of compression to use, between 0 and 9. -1 indicates the default level. The meaning of this argument depends on the compression format being used. (Default: -1.)
		 * @returns compressedData — CompressedData/string which contains the compressed version of rawstring.
		 */
		compress(this: void, container: "string", format: CompressionFormat, source: string | Data, level?: number): string;
		/**
		 * Compresses a string or data using a specific compression algorithm.
		 *

		 * @param container What type to return the compressed data as.
		 * @param format The format to use when compressing the data.
		 * @param source A Data object containing the raw (un-compressed) data to compress.
		 * @param level The level of compression to use, between 0 and 9. -1 indicates the default level. The meaning of this argument depends on the compression format being used. (Default: -1.)
		 * @returns CompressedData/string which contains the compressed version of data.
		 */
		compress(this: void, container: "data", format: CompressionFormat, source: string | Data, level?: number): CompressedData;
		/**
		 * Decompresses a CompressedData or previously compressed string or Data object.
		 *

		 * @param container What type to return the decompressed data as.
		 * @param compressed The compressed data to decompress.
		 * @returns decompressedData — Data/string containing the raw decompressed data.
		 */
		decompress(this: void, container: "string", compressed: CompressedData): string;
		/**
		 * Decompresses a CompressedData or previously compressed string or Data object.
		 *

		 * @param container What type to return the decompressed data as.
		 * @param compressed The compressed data to decompress.
		 * @returns decompressedData — Data/string containing the raw decompressed data.
		 */
		decompress(this: void, container: "data", compressed: CompressedData): ByteData;
		/**
		 * Decompresses a CompressedData or previously compressed string or Data object.
		 *

		 * @param container What type to return the decompressed data as.
		 * @param format The format that was used to compress the given data.
		 * @param source A Data object containing data previously compressed with love.data.compress.
		 * @returns decompressedData — Data/string containing the raw decompressed data.
		 */
		decompress(this: void, container: "string", format: CompressionFormat, source: string | Data): string;
		/**
		 * Decompresses a CompressedData or previously compressed string or Data object.
		 *

		 * @param container What type to return the decompressed data as.
		 * @param format The format that was used to compress the given data.
		 * @param source A Data object containing data previously compressed with love.data.compress.
		 * @returns decompressedData — Data/string containing the raw decompressed data.
		 */
		decompress(this: void, container: "data", format: CompressionFormat, source: string | Data): ByteData;
		/**
		 * Packs (serializes) simple Lua values.
		 *
		 * This function behaves the same as Lua 5.3's string.pack.
		 *

		 * @param container What type to return the encoded data as.
		 * @param format A string determining how the values are packed. Follows the rules of Lua 5.3's string.pack format strings.
		 * @param values The first value (number, boolean, or string) to serialize.
		 * @returns data — Data/string which contains the serialized data.
		 */
		pack(this: void, container: "string", format: string, ...values: any[]): string;
		/**
		 * Packs (serializes) simple Lua values.
		 *
		 * This function behaves the same as Lua 5.3's string.pack.
		 *

		 * @param container What type to return the encoded data as.
		 * @param format A string determining how the values are packed. Follows the rules of Lua 5.3's string.pack format strings.
		 * @param values The first value (number, boolean, or string) to serialize.
		 * @returns data — Data/string which contains the serialized data.
		 */
		pack(this: void, container: "data", format: string, ...values: any[]): ByteData;
		/**
		 * Unpacks (deserializes) a byte-string or Data into simple Lua values.
		 *
		 * This function behaves the same as Lua 5.3's string.unpack.
		 *

		 * @param format A string determining how the values were packed. Follows the rules of Lua 5.3's string.pack format strings.
		 * @param source A string containing the packed (serialized) data.
		 * @param position Where to start reading in the string. Negative values can be used to read relative from the end of the string. (Default: 1.)
		 * @returns v1 — The first value (number, boolean, or string) that was unpacked.
		 * @returns ... — Additional unpacked values.
		 * @returns index — The index of the first unread byte in the data string.
		 */
		unpack(this: void, format: string, source: string, position?: number): LuaMultiReturn<any[]>;
/**
 * Unpacks (deserializes) a byte-string or Data into simple Lua values.
 *
 * This function behaves the same as Lua 5.3's string.unpack.
 *

 * @param format A string determining how the values were packed. Follows the rules of Lua 5.3's string.pack format strings.
 * @param source A Data object containing the packed (serialized) data.
 * @param position 1-based index indicating where to start reading in the Data. Negative values can be used to read relative from the end of the Data object. (Default: 1.)
 * @returns v1 — The first value (number, boolean, or string) that was unpacked.
 * @returns ... — Additional unpacked values.
 * @returns The 1-based index of the first unread byte in the Data.
 */
		unpack(this: void, format: string, source: Data, position?: number): LuaMultiReturn<any[]>;
		/**
		 * Gets the size in bytes that a given format used with love.data.pack will use.
		 *
		 * This function behaves the same as Lua 5.3's string.packsize.
		 *
		 * Overload details:
		 * 1. The format string cannot have the variable-length options 's' or 'z'.
		 *
		 * @param format A string determining how the values are packed. Follows the rules of Lua 5.3's string.pack format strings.
		 *
		 * @returns size — The size in bytes that the packed data will use.
		 */
		getPackedSize(this: void, format: string): number;
		/**
		 * Compute the message digest of a string using a specified hash algorithm.
		 *

		 * @param hashFunction Hash algorithm to use.
		 * @param source String to hash.
		 * @returns rawdigest — Raw message digest string.
		 */
		hash(this: void, hashFunction: HashFunction, source: string): string;
/**
 * Compute the message digest of a string using a specified hash algorithm.
 *

 * @param hashFunction Hash algorithm to use.
 * @param source Data to hash.
 * @returns rawdigest — Raw message digest string.
 */
		hash(this: void, hashFunction: HashFunction, source: Data): string;
	}
	/** Data representing the contents of a file.
	 */
	interface FileData extends Data {
		/**
		 * Creates a new copy of the Data object.
		 *
		 * @returns clone — The new copy.
		 */
		clone(): FileData;
		/**
		 * Gets the filename of the FileData.
		 *
		 * @returns name — The name of the file the FileData represents.
		 */
		getFilename(): string;
		/**
		 * Gets the extension of the FileData.
		 *
		 * @returns ext — The extension of the file the FileData represents.
		 */
		getExtension(): string;
	}
	/** Raw (decoded) image data.
	 */
	interface ImageData extends Data {
		/**
		 * Gets the type of the object as a string.
		 *
		 * @returns type — The type as a string.
		 */
		type(): "ImageData";
		/**
		 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 *
		 * @param typeName The name of the type to check for.
		 *
		 * @returns b — True if the object is of the specified type, false otherwise.
		 */
		typeOf(typeName: string): boolean;
		/**
		 * Creates a new copy of the Data object.
		 *
		 * @returns clone — The new copy.
		 */
		clone(): ImageData;
		/**
		 * Gets the width of the ImageData in pixels.
		 *
		 * @returns width — The width of the ImageData in pixels.
		 */
		getWidth(): number;
		/**
		 * Gets the height of the ImageData in pixels.
		 *
		 * @returns height — The height of the ImageData in pixels.
		 */
		getHeight(): number;
		/**
		 * Gets the width and height of the ImageData in pixels.
		 *
		 * @returns width — The width of the ImageData in pixels.
		 * @returns height — The height of the ImageData in pixels.
		 */
		getDimensions(): LuaMultiReturn<[number, number]>;
		/**
		 * Gets the pixel format of the ImageData.
		 *
		 * @returns format — The pixel format the ImageData was created with.
		 */
		getFormat(): ImagePixelFormat;
		/**
		 * Gets the color of a pixel at a specific position in the image.
		 *
		 * Valid x and y values start at 0 and go up to image width and height minus 1. Non-integer values are floored.
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *
		 * @param x The position of the pixel on the x-axis.
		 * @param y The position of the pixel on the y-axis.
		 *
		 * @returns r — The red component (0-1).
		 * @returns g — The green component (0-1).
		 * @returns b — The blue component (0-1).
		 * @returns a — The alpha component (0-1).
		 */
		getPixel(x: number, y: number): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Sets the color of a pixel at a specific position in the image.
		 *
		 * Valid x and y values start at 0 and go up to image width and height minus 1.
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *
		 * @param x The position of the pixel on the x-axis.
		 * @param y The position of the pixel on the y-axis.
		 * @param red The red component (0-1).
		 * @param green The green component (0-1).
		 * @param blue The blue component (0-1).
		 * @param alpha The alpha component (0-1).
		 */
		setPixel(x: number, y: number, red: number, green: number, blue: number, alpha?: number): void;
		/**
		 * Transform an image by applying a function to every pixel.
		 *
		 * This function is a higher-order function. It takes another function as a parameter, and calls it once for each pixel in the ImageData.
		 *
		 * The passed function is called with six parameters for each pixel in turn. The parameters are numbers that represent the x and y coordinates of the pixel and its red, green, blue and alpha values. The function should return the new red, green, blue, and alpha values for that pixel.
		 *
		 * function pixelFunction(x, y, r, g, b, a)
		 *
		 * -- template for defining your own pixel mapping function
		 *
		 * -- perform computations giving the new values for r, g, b and a
		 *
		 * -- ...
		 *
		 * return r, g, b, a
		 *
		 * end
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *
		 * @param mapper Function to apply to every pixel.
		 * @param x The x-axis of the top-left corner of the area within the ImageData to apply the function to. (Default: 0.)
		 * @param y The y-axis of the top-left corner of the area within the ImageData to apply the function to. (Default: 0.)
		 * @param width The width of the area within the ImageData to apply the function to. (Default: ImageData:getWidth().)
		 * @param height The height of the area within the ImageData to apply the function to. (Default: ImageData:getHeight().)
		 */
		mapPixel(mapper: (x: number, y: number, red: number, green: number, blue: number, alpha: number) => LuaMultiReturn<[number, number, number, number]>, x?: number, y?: number, width?: number, height?: number): void;
		/**
		 * Paste into ImageData from another source ImageData.
		 *
		 * Overload details:
		 * 1. Note that this function just replaces the contents in the destination rectangle; it does not do any alpha blending.
		 *
		 * @param source Source ImageData from which to copy.
		 * @param destinationX Destination top-left position on x-axis.
		 * @param destinationY Destination top-left position on y-axis.
		 * @param sourceX Source top-left position on x-axis.
		 * @param sourceY Source top-left position on y-axis.
		 * @param sourceWidth Source width.
		 * @param sourceHeight Source height.
		 */
		paste(source: ImageData, destinationX: number, destinationY: number, sourceX?: number, sourceY?: number, sourceWidth?: number, sourceHeight?: number): void;
		/**
		 * Encodes the ImageData and optionally writes it to the save directory.
		 *
		 * @param format The format to encode the image as. Depending on the overload: The format to encode the image in.
		 * @param filename The filename to write the file to. If nil, no file will be written but the FileData will still be returned. (Default: nil.)
		 *
		 * @returns filedata — The encoded image as a new FileData object.
		 */
		encode(format: "png" | "tga", filename?: string): FileData;
	}
	/** Represents compressed image data designed to stay compressed in RAM.
	 */
	interface CompressedImageData extends Data {
		/**
		 * Gets the type of the object as a string.
		 *
		 * @returns type — The type as a string.
		 */
		type(): "CompressedImageData";
		/**
		 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 *
		 * @param typeName The name of the type to check for.
		 *
		 * @returns b — True if the object is of the specified type, false otherwise.
		 */
		typeOf(typeName: string): boolean;
		/**
		 * Creates a new copy of the Data object.
		 *
		 * @returns clone — The new copy.
		 */
		clone(): CompressedImageData;
		/**
		 * Gets the width of the CompressedImageData.
		 *

		 * @returns width — The width of the CompressedImageData.
		 */
		getWidth(): number;
/**
 * Gets the width of the CompressedImageData.
 *

 * @param mipmap A mipmap level. Must be in the range of CompressedImageData:getMipmapCount().
 * @returns The width of a specific mipmap level of the CompressedImageData.
 */
		getWidth(mipmap: number): number;
		/**
		 * Gets the height of the CompressedImageData.
		 *

		 * @returns height — The height of the CompressedImageData.
		 */
		getHeight(): number;
/**
 * Gets the height of the CompressedImageData.
 *

 * @param mipmap A mipmap level. Must be in the range of CompressedImageData:getMipmapCount().
 * @returns The height of a specific mipmap level of the CompressedImageData.
 */
		getHeight(mipmap: number): number;
		/**
		 * Gets the width and height of the CompressedImageData.
		 *

		 * @returns width — The width of the CompressedImageData.
		 * @returns height — The height of the CompressedImageData.
		 */
		getDimensions(): LuaMultiReturn<[number, number]>;
/**
 * Gets the width and height of the CompressedImageData.
 *

 * @param mipmap A mipmap level. Must be in the range of CompressedImageData:getMipmapCount().
 * @returns The width of a specific mipmap level of the CompressedImageData.
 * @returns The height of a specific mipmap level of the CompressedImageData.
 */
		getDimensions(mipmap: number): LuaMultiReturn<[number, number]>;
		/**
		 * Gets the number of mipmap levels in the CompressedImageData. The base mipmap level (original image) is included in the count.
		 *
		 * Overload details:
		 * 1. Mipmap filtering cannot be activated for an Image:setMipmapFilter will error. Most tools which can create compressed textures are able to automatically generate mipmaps for them in the same file.
		 *
		 * @returns mipmaps — The number of mipmap levels stored in the CompressedImageData.
		 */
		getMipmapCount(): number;
		/**
		 * Gets the format of the CompressedImageData.
		 *
		 * @returns format — The format of the CompressedImageData.
		 */
		getFormat(): CompressedPixelFormat;
	}
	/** @noSelf */
	/** Provides an interface to decode encoded image data.
	 */
	interface ImageModule {
		/**
		 * Creates a new ImageData object.
		 *

		 * @param width The width of the ImageData.
		 * @param height The height of the ImageData.
		 * @param format The pixel format of the ImageData. (Default: 'rgba8'.)
		 * @param data Optional raw byte data to load into the ImageData, in the format specified by ''format''. (Default: nil.)
		 * @returns imageData — The new blank ImageData object. Each pixel's color values, (including the alpha values!) will be set to zero.
		 */
		newImageData(this: void, width: number, height: number, format?: ImagePixelFormat, data?: string | Data): ImageData;
		/**
		 * Creates a new ImageData object.
		 *

		 * @param filename The filename of the image file.
		 * @returns The new ImageData object.
		 */
		newImageData(this: void, filename: string): ImageData;
		/**
		 * Creates a new ImageData object.
		 *

		 * @param data Encoded image data to decode into the ImageData.
		 * @returns The new ImageData object.
		 */
		newImageData(this: void, data: Data): ImageData;
		/**
		 * Create a new CompressedImageData object from a compressed image file. LÖVE supports several compressed texture formats, enumerated in the CompressedImageFormat page.
		 *
		 * @param filenameOrData The filename of the compressed image file. Depending on the overload: A FileData containing a compressed image.
		 *
		 * @returns compressedImageData — The new CompressedImageData object.
		 */
		newCompressedData(this: void, filenameOrData: string | Data): CompressedImageData;
		/**
		 * Determines whether a file can be loaded as CompressedImageData.
		 *
		 * @param filenameOrData The filename of the potentially compressed image file. Depending on the overload: A FileData potentially containing a compressed image.
		 *
		 * @returns compressed — Whether the file can be loaded as CompressedImageData or not. Depending on the overload: Whether the FileData can be loaded as CompressedImageData or not.
		 */
		isCompressed(this: void, filenameOrData: string | Data): boolean;
	}
	/** A Rasterizer handles font rendering, containing the font data (image or TrueType font) and drawable glyphs.
	 */
	interface Rasterizer extends Object {
		/**
		 * Gets the type of the object as a string.
		 *
		 * @returns type — The type as a string.
		 */
		type(): "Rasterizer";
		/**
		 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 *
		 * @param typeName The name of the type to check for.
		 *
		 * @returns b — True if the object is of the specified type, false otherwise.
		 */
		typeOf(typeName: string): boolean;
		/**
		 * Gets font height.
		 *
		 * @returns height — Font height
		 */
		getHeight(): number;
		/**
		 * Gets font advance.
		 *
		 * @returns advance — Font advance.
		 */
		getAdvance(): number;
		/**
		 * Gets ascent height.
		 *
		 * @returns height — Ascent height.
		 */
		getAscent(): number;
		/**
		 * Gets descent height.
		 *
		 * @returns height — Descent height.
		 */
		getDescent(): number;
		/**
		 * Gets line height of a font.
		 *
		 * @returns height — Line height of a font.
		 */
		getLineHeight(): number;
		/**
		 * Gets glyph data of a specified glyph.
		 *
		 * @param glyph Glyph
		 *
		 * @returns glyphData — Glyph data
		 */
		getGlyphData(glyph: string | number): GlyphData;
		/**
		 * Gets number of glyphs in font.
		 *
		 * @returns count — Glyphs count.
		 */
		getGlyphCount(): number;
		/**
		 * Checks if font contains specified glyphs.
		 *
		 * @param glyphs Glyph
		 *
		 * @returns hasGlyphs — Whatever font contains specified glyphs.
		 */
		hasGlyphs(...glyphs: (string | number)[]): boolean;
	}
	/** A GlyphData represents a drawable symbol of a font Rasterizer.
	 */
	interface GlyphData extends Data {
		/**
		 * Gets the type of the object as a string.
		 *
		 * @returns type — The type as a string.
		 */
		type(): "GlyphData";
		/**
		 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 *
		 * @param typeName The name of the type to check for.
		 *
		 * @returns b — True if the object is of the specified type, false otherwise.
		 */
		typeOf(typeName: string): boolean;
		/**
		 * Creates a new copy of the Data object.
		 *
		 * @returns clone — The new copy.
		 */
		clone(): GlyphData;
		/**
		 * Gets glyph width.
		 *
		 * @returns width — Glyph width.
		 */
		getWidth(): number;
		/**
		 * Gets glyph height.
		 *
		 * @returns height — Glyph height.
		 */
		getHeight(): number;
		/**
		 * Gets glyph dimensions.
		 *
		 * @returns width — Glyph width.
		 * @returns height — Glyph height.
		 */
		getDimensions(): LuaMultiReturn<[number, number]>;
		/**
		 * Gets glyph number.
		 *
		 * @returns glyph — Glyph number.
		 */
		getGlyph(): number;
		/**
		 * Gets glyph string.
		 *
		 * @returns glyph — Glyph string.
		 */
		getGlyphString(): string;
		/**
		 * Gets glyph advance.
		 *
		 * @returns advance — Glyph advance.
		 */
		getAdvance(): number;
		/**
		 * Gets glyph bearing.
		 *
		 * @returns bx — Glyph bearing X.
		 * @returns by — Glyph bearing Y.
		 */
		getBearing(): LuaMultiReturn<[number, number]>;
		/**
		 * Gets glyph bounding box.
		 *
		 * @returns x — Glyph position x.
		 * @returns y — Glyph position y.
		 * @returns width — Glyph width.
		 * @returns height — Glyph height.
		 */
		getBoundingBox(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Gets glyph pixel format.
		 *
		 * @returns format — Glyph pixel format.
		 */
		getFormat(): "rgba8";
	}
	/** @noSelf */
	/** Allows you to work with fonts.
	 */
	interface FontModule {
		/**
		 * Creates a new Image Rasterizer.
		 *
		 * Overload details:
		 * 1. Create an ImageRasterizer from the image data.
		 *
		 * @param imageData Font image data.
		 * @param glyphs String containing font glyphs.
		 * @param extraSpacing Font extra spacing. (Default: 0.)
		 * @param dpiScale Font DPI scale. (Default: 1.)
		 *
		 * @returns rasterizer — The rasterizer.
		 */
		newImageRasterizer(this: void, imageData: ImageData, glyphs: string, extraSpacing?: number, dpiScale?: number): Rasterizer;
		/**
		 * Creates a new BMFont Rasterizer.
		 *
		 * @param filenameOrFileData The image data containing the drawable pictures of font glyphs. Depending on the overload: The path to file containing the drawable pictures of font glyphs.
		 * @param images The sequence of glyphs in the ImageData.
		 * @param dpiScale DPI scale. (Default: 1.)
		 *
		 * @returns rasterizer — The rasterizer.
		 */
		newBMFontRasterizer(this: void, filenameOrFileData: string | FileData, images?: ImageData | string | FileData | (ImageData | string | FileData)[], dpiScale?: number): Rasterizer;
		/**
		 * Creates a new TrueType Rasterizer.
		 *

		 * @param size The font size. (Default: 12.)
		 * @param hinting True Type hinting mode. (Default: 'normal'.)
		 * @param dpiScale The font DPI scale. (Default: love.window.getDPIScale().)
		 * @returns rasterizer — The rasterizer.
		 */
		newTrueTypeRasterizer(this: void, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		/**
		 * Creates a new TrueType Rasterizer.
		 *

		 * @param filenameOrData File data containing font.
		 * @param size The font size. (Default: 12.)
		 * @param hinting True Type hinting mode. (Default: 'normal'.)
		 * @param dpiScale The font DPI scale. (Default: love.window.getDPIScale().)
		 * @returns rasterizer — The rasterizer.
		 */
		newTrueTypeRasterizer(this: void, filenameOrData: string | Data, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		/**
		 * Creates a new Rasterizer.
		 *

		 * @param size The font size. (Default: 12.)
		 * @param hinting True Type hinting mode. (Default: 'normal'.)
		 * @param dpiScale The font DPI scale. (Default: love.window.getDPIScale().)
		 * @returns rasterizer — The rasterizer.
		 */
		newRasterizer(this: void, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		/**
		 * Creates a new Rasterizer.
		 *

		 * @param filenameOrData File data containing font.
		 * @param size The font size. (Default: 12.)
		 * @param hinting True Type hinting mode. (Default: 'normal'.)
		 * @param dpiScale DPI scale. (Default: 1.)
		 * @returns rasterizer — The rasterizer.
		 */
		newRasterizer(this: void, filenameOrData: string | Data, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		/**
		 * Creates a new GlyphData.
		 *
		 * @param rasterizer The Rasterizer containing the font.
		 * @param glyph The character code of the glyph.
		 */
		newGlyphData(this: void, rasterizer: Rasterizer, glyph: string | number): GlyphData;
	}
	/** Contains raw audio samples.
	 */
	interface SoundData extends Data {
		/**
		 * Creates a new copy of the Data object.
		 *
		 * @returns clone — The new copy.
		 */
		clone(): SoundData;
		/**
		 * Returns the number of channels in the SoundData.
		 *
		 * @returns channels — 1 for mono, 2 for stereo.
		 */
		getChannelCount(): number;
		/** Deprecated Love alias for getChannelCount. */
		getChannels(): number;
		/**
		 * Returns the number of bits per sample.
		 *
		 * @returns bitdepth — Either 8, or 16.
		 */
		getBitDepth(): 8 | 16;
		/**
		 * Returns the sample rate of the SoundData.
		 *
		 * @returns rate — Number of samples per second.
		 */
		getSampleRate(): number;
		/**
		 * Returns the number of samples per channel of the SoundData.
		 *
		 * @returns count — Total number of samples.
		 */
		getSampleCount(): number;
		/**
		 * Gets the duration of the sound data.
		 *
		 * @returns duration — The duration of the sound data in seconds.
		 */
		getDuration(): number;
		/**
		 * Gets the value of the sample-point at the specified position. For stereo SoundData objects, the data from the left and right channels are interleaved in that order.
		 *
		 * Overload details:
		 * 1. Gets the value of a sample using an explicit sample index instead of interleaving them in the sample position parameter.
		 *
		 * @param index An integer value specifying the position of the sample (starting at 0).
		 * @param channel The index of the channel to get within the given sample.
		 *
		 * @returns sample — The normalized samplepoint (range -1.0 to 1.0).
		 */
		getSample(index: number, channel?: number): number;
		/**
		 * Sets the value of the sample-point at the specified position. For stereo SoundData objects, the data from the left and right channels are interleaved in that order.
		 *

		 * @param index An integer value specifying the position of the sample (starting at 0).
		 * @param sample The normalized samplepoint (range -1.0 to 1.0).
		 */
		setSample(index: number, sample: number): void;
		/**
		 * Sets the value of the sample-point at the specified position. For stereo SoundData objects, the data from the left and right channels are interleaved in that order.
		 *

		 * @param index An integer value specifying the position of the sample (starting at 0).
		 * @param channel The index of the channel to set within the given sample.
		 * @param sample The normalized samplepoint (range -1.0 to 1.0).
		 */
		setSample(index: number, channel: number, sample: number): void;
	}
	/** An object which can gradually decode a sound file.
	 */
	interface Decoder extends Object {
		/**
		 * Creates a new copy of current decoder.
		 *
		 * The new decoder will start decoding from the beginning of the audio stream.
		 *
		 * @returns decoder — New copy of the decoder.
		 */
		clone(): Decoder;
		/**
		 * Returns the number of channels in the stream.
		 *
		 * @returns channels — 1 for mono, 2 for stereo.
		 */
		getChannelCount(): number;
		/** Deprecated Love alias for getChannelCount. */
		getChannels(): number;
		/**
		 * Returns the number of bits per sample.
		 *
		 * @returns bitDepth — Either 8, or 16.
		 */
		getBitDepth(): 16;
		/**
		 * Returns the sample rate of the Decoder.
		 *
		 * @returns rate — Number of samples per second.
		 */
		getSampleRate(): number;
		/**
		 * Gets the duration of the sound file. It may not always be sample-accurate, and it may return -1 if the duration cannot be determined at all.
		 *
		 * @returns duration — The duration of the sound file in seconds, or -1 if it cannot be determined.
		 */
		getDuration(): number;
		/**
		 * Decodes the audio and returns a SoundData object containing the decoded audio data.
		 *
		 * @returns soundData — Decoded audio data.
		 */
		decode(): SoundData | undefined;
		/**
		 * Sets the currently playing position of the Decoder.
		 *
		 * @param offset The position to seek to, in seconds.
		 */
		seek(offset: number): void;
	}
	/** @noSelf */
	/** This module is responsible for decoding sound files. It can't play the sounds, see love.audio for that.
	 */
	interface SoundModule {
		/**
		 * Attempts to find a decoder for the encoded sound data in the specified file.
		 *

		 * @param filename The filename of the file with encoded sound data.
		 * @param bufferSize The size of each decoded chunk, in bytes. (Default: 2048.)
		 * @returns decoder — A new Decoder object.
		 */
		newDecoder(this: void, filename: string, bufferSize?: number): Decoder;
		/**
		 * Attempts to find a decoder for the encoded sound data in the specified file.
		 *

		 * @param data The filename of the file with encoded sound data.
		 * @param bufferSize The size of each decoded chunk, in bytes. (Default: 2048.)
		 * @returns decoder — A new Decoder object.
		 */
		newDecoder(this: void, data: FileData, bufferSize?: number): Decoder;
		/**
		 * Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a custom sample rate, channel and bit depth.
		 *
		 * The sound data will be decoded to the memory in a raw format. It is recommended to create only short sounds like effects, as a 3 minute song uses 30 MB of memory this way.
		 *

		 * @param samples Total number of samples.
		 * @param sampleRate Number of samples per second (Default: 44100.)
		 * @param bitDepth Bits per sample (8 or 16). (Default: 16.)
		 * @param channels Either 1 for mono or 2 for stereo. (Default: 2.)
		 * @returns soundData — A new SoundData object.
		 */
		newSoundData(this: void, samples: number, sampleRate?: number, bitDepth?: 8 | 16, channels?: number): SoundData;
		/**
		 * Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a custom sample rate, channel and bit depth.
		 *
		 * The sound data will be decoded to the memory in a raw format. It is recommended to create only short sounds like effects, as a 3 minute song uses 30 MB of memory this way.
		 *

		 * @param filename The file name of the file to load.
		 * @param bufferSize Number of samples per second (Default: 44100.)
		 * @returns soundData — A new SoundData object.
		 */
		newSoundData(this: void, filename: string, bufferSize?: number): SoundData;
		/**
		 * Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a custom sample rate, channel and bit depth.
		 *
		 * The sound data will be decoded to the memory in a raw format. It is recommended to create only short sounds like effects, as a 3 minute song uses 30 MB of memory this way.
		 *

		 * @param data Decode data from this Decoder until EOF.
		 * @param bufferSize Number of samples per second (Default: 44100.)
		 * @returns soundData — A new SoundData object.
		 */
		newSoundData(this: void, data: FileData, bufferSize?: number): SoundData;
		/**
		 * Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a custom sample rate, channel and bit depth.
		 *
		 * The sound data will be decoded to the memory in a raw format. It is recommended to create only short sounds like effects, as a 3 minute song uses 30 MB of memory this way.
		 *

		 * @param decoder Decode data from this Decoder until EOF.
		 * @returns soundData — A new SoundData object.
		 */
		newSoundData(this: void, decoder: Decoder): SoundData;
	}
	/** A random number generation object which has its own random state.
	 */
	interface RandomGenerator extends Object {
		/**
		 * Generates a pseudo-random number in a platform independent manner.
		 *

		 * @returns number — The pseudo-random number.
		 */
		random(): number;
		/**
		 * Generates a pseudo-random number in a platform independent manner.
		 *

		 * @param upper The maximum possible value it should return.
		 * @returns The pseudo-random integer number.
		 */
		random(upper: number): number;
		/**
		 * Generates a pseudo-random number in a platform independent manner.
		 *

		 * @param lower The minimum possible value it should return.
		 * @param upper The maximum possible value it should return.
		 * @returns The pseudo-random integer number.
		 */
		random(lower: number, upper: number): number;
		/**
		 * Get a normally distributed pseudo random number.
		 *
		 * @param standardDeviation Standard deviation of the distribution. (Default: 1.)
		 * @param mean The mean of the distribution. (Default: 0.)
		 *
		 * @returns number — Normally distributed random number with variance (stddev)² and the specified mean.
		 */
		randomNormal(standardDeviation?: number, mean?: number): number;
		/**
		 * Sets the seed of the random number generator using the specified integer number.
		 *

		 * @param seed The integer number with which you want to seed the randomization. Must be within the range of 2^53.
		 */
		setSeed(seed: number): void;
		/**
		 * Sets the seed of the random number generator using the specified integer number.
		 *

		 * @param low The lower 32 bits of the seed value. Must be within the range of 2^32 - 1.
		 * @param high The higher 32 bits of the seed value. Must be within the range of 2^32 - 1.
		 */
		setSeed(low: number, high: number): void;
		/**
		 * Gets the seed of the random number generator object.
		 *
		 * The seed is split into two numbers due to Lua's use of doubles for all number values - doubles can't accurately represent integer values above 2^53, but the seed value is an integer number in the range of 2^64 - 1.
		 *
		 * @returns low — Integer number representing the lower 32 bits of the RandomGenerator's 64 bit seed value.
		 * @returns high — Integer number representing the higher 32 bits of the RandomGenerator's 64 bit seed value.
		 */
		getSeed(): LuaMultiReturn<[number, number]>;
		/**
		 * Sets the current state of the random number generator. The value used as an argument for this function is an opaque string and should only originate from a previous call to RandomGenerator:getState in the same major version of LÖVE.
		 *
		 * This is different from RandomGenerator:setSeed in that setState directly sets the RandomGenerator's current implementation-dependent state, whereas setSeed gives it a new seed value.
		 *
		 * Overload details:
		 * 1. The effect of the state string does not depend on the current operating system.
		 *
		 * @param state The new state of the RandomGenerator object, represented as a string. This should originate from a previous call to RandomGenerator:getState.
		 */
		setState(state: string): void;
		/**
		 * Gets the current state of the random number generator. This returns an opaque string which is only useful for later use with RandomGenerator:setState in the same major version of LÖVE.
		 *
		 * This is different from RandomGenerator:getSeed in that getState gets the RandomGenerator's current state, whereas getSeed gets the previously set seed number.
		 *
		 * Overload details:
		 * 1. The value of the state string does not depend on the current operating system.
		 *
		 * @returns state — The current state of the RandomGenerator object, represented as a string.
		 */
		getState(): string;
	}
	/** Object containing a coordinate system transformation.
	 */
	interface Transform extends Object {
		/**
		 * Creates a new copy of this Transform.
		 *
		 * @returns clone — The copy of this Transform.
		 */
		clone(): Transform;
		/**
		 * Creates a new Transform containing the inverse of this Transform.
		 *
		 * @returns inverse — A new Transform object representing the inverse of this Transform's matrix.
		 */
		inverse(): Transform;
		/**
		 * Applies the given other Transform object to this one.
		 *
		 * This effectively multiplies this Transform's internal transformation matrix with the other Transform's (i.e. self * other), and stores the result in this object.
		 *
		 * @param other The other Transform object to apply to this Transform.
		 *
		 * @returns transform — The Transform object the method was called on. Allows easily chaining Transform methods.
		 */
		apply(other: Transform): Transform;
		/**
		 * Checks whether the Transform is an affine transformation.
		 *
		 * @returns affine — true if the transform object is an affine transformation, false otherwise.
		 */
		isAffine2DTransform(): boolean;
		/**
		 * Applies a translation to the Transform's coordinate system. This method does not reset any previously applied transformations.
		 *
		 * @param x The relative translation along the x-axis.
		 * @param y The relative translation along the y-axis.
		 *
		 * @returns transform — The Transform object the method was called on. Allows easily chaining Transform methods.
		 */
		translate(x: number, y: number): Transform;
		/**
		 * Applies a rotation to the Transform's coordinate system. This method does not reset any previously applied transformations.
		 *
		 * @param angle The relative angle in radians to rotate this Transform by.
		 *
		 * @returns transform — The Transform object the method was called on. Allows easily chaining Transform methods.
		 */
		rotate(angle: number): Transform;
		/**
		 * Scales the Transform's coordinate system. This method does not reset any previously applied transformations.
		 *
		 * @param x The relative scale factor along the x-axis.
		 * @param y The relative scale factor along the y-axis. (Default: sx.)
		 *
		 * @returns transform — The Transform object the method was called on. Allows easily chaining Transform methods.
		 */
		scale(x: number, y?: number): Transform;
		/**
		 * Applies a shear factor (skew) to the Transform's coordinate system. This method does not reset any previously applied transformations.
		 *
		 * @param x The shear factor along the x-axis.
		 * @param y The shear factor along the y-axis.
		 *
		 * @returns transform — The Transform object the method was called on. Allows easily chaining Transform methods.
		 */
		shear(x: number, y: number): Transform;
		/**
		 * Resets the Transform to an identity state. All previously applied transformations are erased.
		 *
		 * @returns transform — The Transform object the method was called on. Allows easily chaining Transform methods.
		 */
		reset(): Transform;
		/**
		 * Resets the Transform to the specified transformation parameters.
		 *
		 * @param x The position of the Transform on the x-axis.
		 * @param y The position of the Transform on the y-axis.
		 * @param angle The orientation of the Transform in radians. (Default: 0.)
		 * @param scaleX Scale factor on the x-axis. (Default: 1.)
		 * @param scaleY Scale factor on the y-axis. (Default: sx.)
		 * @param originX Origin offset on the x-axis. (Default: 0.)
		 * @param originY Origin offset on the y-axis. (Default: 0.)
		 * @param shearX Shearing / skew factor on the x-axis. (Default: 0.)
		 * @param shearY Shearing / skew factor on the y-axis. (Default: 0.)
		 *
		 * @returns transform — The Transform object the method was called on. Allows easily chaining Transform methods.
		 */
		setTransformation(x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): Transform;
		/**
		 * Directly sets the Transform's internal 4x4 transformation matrix.
		 *

		 * @param layout How to interpret the matrix element arguments (row-major or column-major).
		 * @param elements A flat table containing the 16 matrix elements.
		 * @returns transform — The Transform object the method was called on. Allows easily chaining Transform methods.
		 */
		setMatrix(layout: "row" | "column", elements: number[] | number[][]): Transform;
		/**
		 * Directly sets the Transform's internal 4x4 transformation matrix.
		 *

		 * @param elements A table of 4 tables, with each sub-table containing 4 matrix elements.
		 * @returns transform — The Transform object the method was called on. Allows easily chaining Transform methods.
		 */
		setMatrix(elements: number[] | number[][]): Transform;
		/**
		 * Gets the internal 4x4 transformation matrix stored by this Transform. The matrix is returned in row-major order.
		 *
		 * @returns e1_1 — The first column of the first row of the matrix.
		 * @returns e1_2 — The second column of the first row of the matrix.
		 * @returns e1_3 — The third column of the first row of the matrix.
		 * @returns e1_4 — The fourth column of the first row of the matrix.
		 * @returns e2_1 — The first column of the second row of the matrix.
		 * @returns e2_2 — The second column of the second row of the matrix.
		 * @returns e2_3 — The third column of the second row of the matrix.
		 * @returns e2_4 — The fourth column of the second row of the matrix.
		 * @returns e3_1 — The first column of the third row of the matrix.
		 * @returns e3_2 — The second column of the third row of the matrix.
		 * @returns e3_3 — The third column of the third row of the matrix.
		 * @returns e3_4 — The fourth column of the third row of the matrix.
		 * @returns e4_1 — The first column of the fourth row of the matrix.
		 * @returns e4_2 — The second column of the fourth row of the matrix.
		 * @returns e4_3 — The third column of the fourth row of the matrix.
		 * @returns e4_4 — The fourth column of the fourth row of the matrix.
		 */
		getMatrix(): LuaMultiReturn<[number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number]>;
		/**
		 * Applies the Transform object's transformation to the given 2D position.
		 *
		 * This effectively converts the given position from global coordinates into the local coordinate space of the Transform.
		 *
		 * @param x The x component of the position in global coordinates.
		 * @param y The y component of the position in global coordinates.
		 *
		 * @returns localX — The x component of the position with the transform applied.
		 * @returns localY — The y component of the position with the transform applied.
		 */
		transformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * Applies the reverse of the Transform object's transformation to the given 2D position.
		 *
		 * This effectively converts the given position from the local coordinate space of the Transform into global coordinates.
		 *
		 * One use of this method can be to convert a screen-space mouse position into global world coordinates, if the given Transform has transformations applied that are used for a camera system in-game.
		 *
		 * @param x The x component of the position with the transform applied.
		 * @param y The y component of the position with the transform applied.
		 *
		 * @returns globalX — The x component of the position in global coordinates.
		 * @returns globalY — The y component of the position in global coordinates.
		 */
		inverseTransformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
	}
	/** A Bézier curve object that can evaluate and render Bézier curves of arbitrary degree.
	 */
	interface BezierCurve extends Object {
		/**
		 * Get degree of the Bézier curve. The degree is equal to number-of-control-points - 1.
		 *
		 * @returns degree — Degree of the Bézier curve.
		 */
		getDegree(): number;
		/**
		 * Get the derivative of the Bézier curve.
		 *
		 * This function can be used to rotate sprites moving along a curve in the direction of the movement and compute the direction perpendicular to the curve at some parameter t.
		 *
		 * @returns derivative — The derivative curve.
		 */
		getDerivative(): BezierCurve;
		/**
		 * Get coordinates of the i-th control point. Indices start with 1.
		 *
		 * @param index Index of the control point.
		 *
		 * @returns x — Position of the control point along the x axis.
		 * @returns y — Position of the control point along the y axis.
		 */
		getControlPoint(index: number): LuaMultiReturn<[number, number]>;
		/**
		 * Set coordinates of the i-th control point. Indices start with 1.
		 *
		 * @param index Index of the control point.
		 * @param x Position of the control point along the x axis.
		 * @param y Position of the control point along the y axis.
		 */
		setControlPoint(index: number, x: number, y: number): void;
		/**
		 * Insert control point as the new i-th control point. Existing control points from i onwards are pushed back by 1. Indices start with 1. Negative indices wrap around: -1 is the last control point, -2 the one before the last, etc.
		 *
		 * @param x Position of the control point along the x axis.
		 * @param y Position of the control point along the y axis.
		 * @param index Index of the control point. (Default: -1.)
		 */
		insertControlPoint(x: number, y: number, index?: number): void;
		/**
		 * Removes the specified control point.
		 *
		 * @param index The index of the control point to remove.
		 */
		removeControlPoint(index: number): void;
		/**
		 * Get the number of control points in the Bézier curve.
		 *
		 * @returns count — The number of control points.
		 */
		getControlPointCount(): number;
		/**
		 * Move the Bézier curve by an offset.
		 *
		 * @param x Offset along the x axis.
		 * @param y Offset along the y axis.
		 */
		translate(x: number, y: number): void;
		/**
		 * Rotate the Bézier curve by an angle.
		 *
		 * @param angle Rotation angle in radians.
		 * @param originX X coordinate of the rotation center. (Default: 0.)
		 * @param originY Y coordinate of the rotation center. (Default: 0.)
		 */
		rotate(angle: number, originX?: number, originY?: number): void;
		/**
		 * Scale the Bézier curve by a factor.
		 *
		 * @param scale Scale factor.
		 * @param originX X coordinate of the scaling center. (Default: 0.)
		 * @param originY Y coordinate of the scaling center. (Default: 0.)
		 */
		scale(scale: number, originX?: number, originY?: number): void;
		/**
		 * Evaluate Bézier curve at parameter t. The parameter must be between 0 and 1 (inclusive).
		 *
		 * This function can be used to move objects along paths or tween parameters. However it should not be used to render the curve, see BezierCurve:render for that purpose.
		 *
		 * @param time Where to evaluate the curve.
		 *
		 * @returns x — x coordinate of the curve at parameter t.
		 * @returns y — y coordinate of the curve at parameter t.
		 */
		evaluate(time: number): LuaMultiReturn<[number, number]>;
		/**
		 * Gets a BezierCurve that corresponds to the specified segment of this BezierCurve.
		 *
		 * @param start The starting point along the curve. Must be between 0 and 1.
		 * @param end The end of the segment. Must be between 0 and 1.
		 *
		 * @returns curve — A BezierCurve that corresponds to the specified segment.
		 */
		getSegment(start: number, end: number): BezierCurve;
		/**
		 * Get a list of coordinates to be used with love.graphics.line.
		 *
		 * This function samples the Bézier curve using recursive subdivision. You can control the recursion depth using the depth parameter.
		 *
		 * If you are just interested to know the position on the curve given a parameter, use BezierCurve:evaluate.
		 *
		 * @param accuracy Number of recursive subdivision steps. (Default: 5.)
		 *
		 * @returns coordinates — List of x,y-coordinate pairs of points on the curve.
		 */
		render(accuracy?: number): number[];
		/**
		 * Get a list of coordinates on a specific part of the curve, to be used with love.graphics.line.
		 *
		 * This function samples the Bézier curve using recursive subdivision. You can control the recursion depth using the depth parameter.
		 *
		 * If you are just need to know the position on the curve given a parameter, use BezierCurve:evaluate.
		 *
		 * @param start The starting point along the curve. Must be between 0 and 1.
		 * @param end The end of the segment to render. Must be between 0 and 1.
		 * @param accuracy Number of recursive subdivision steps. (Default: 5.)
		 *
		 * @returns coordinates — List of x,y-coordinate pairs of points on the specified part of the curve.
		 */
		renderSegment(start: number, end: number, accuracy?: number): number[];
	}
	/** @noSelf */
	/** Provides system-independent mathematical functions.
	 */
	interface MathModule {
		/**
		 * Creates a new RandomGenerator object which is completely independent of other RandomGenerator objects and random functions.
		 *

		 * @param seed The initial seed number to use for this object.
		 * @returns rng — The new Random Number Generator object.
		 */
		newRandomGenerator(this: void, seed?: number): RandomGenerator;
		/**
		 * Creates a new RandomGenerator object which is completely independent of other RandomGenerator objects and random functions.
		 *

		 * @param low The lower 32 bits of the seed number to use for this object.
		 * @param high The higher 32 bits of the seed number to use for this object.
		 * @returns rng — The new Random Number Generator object.
		 */
		newRandomGenerator(this: void, low: number, high: number): RandomGenerator;
		/**
		 * Creates a new Transform object.
		 *

		 * @returns transform — The new Transform object.
		 */
		newTransform(this: void): Transform;
/**
 * Creates a new Transform object.
 *

 * @param x The position of the new Transform on the x-axis.
 * @param y The position of the new Transform on the y-axis.
 * @param angle The orientation of the new Transform in radians. (Default: 0.)
 * @param scaleX Scale factor on the x-axis. (Default: 1.)
 * @param scaleY Scale factor on the y-axis. (Default: sx.)
 * @param originX Origin offset on the x-axis. (Default: 0.)
 * @param originY Origin offset on the y-axis. (Default: 0.)
 * @param shearX Shearing / skew factor on the x-axis. (Default: 0.)
 * @param shearY Shearing / skew factor on the y-axis. (Default: 0.)
 * @returns transform — The new Transform object.
 */
		newTransform(this: void, x: number, y: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): Transform;
		/**
		 * Creates a new BezierCurve object.
		 *
		 * The number of vertices in the control polygon determines the degree of the curve, e.g. three vertices define a quadratic (degree 2) Bézier curve, four vertices define a cubic (degree 3) Bézier curve, etc.
		 *

		 * @param vertices The vertices of the control polygon as a table in the form of {x1, y1, x2, y2, x3, y3, ...}.
		 * @returns curve — A Bézier curve object.
		 */
		newBezierCurve(this: void, vertices: number[]): BezierCurve;
		/**
		 * Creates a new BezierCurve object.
		 *
		 * The number of vertices in the control polygon determines the degree of the curve, e.g. three vertices define a quadratic (degree 2) Bézier curve, four vertices define a cubic (degree 3) Bézier curve, etc.
		 *

		 * @param coordinates The vertices of the control polygon as a table in the form of {x1, y1, x2, y2, x3, y3, ...}.
		 * @returns curve — A Bézier curve object.
		 */
		newBezierCurve(this: void, ...coordinates: number[]): BezierCurve;
		/**
		 * Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same, given the same arguments.
		 *
		 * Simplex noise is closely related to Perlin noise. It is widely used for procedural content generation.
		 *
		 * There are many webpages which discuss Perlin and Simplex noise in detail.
		 *

		 * @param x The number used to generate the noise value.
		 * @returns value — The noise value in the range of 1.
		 */
		noise(this: void, x: number): number;
/**
 * Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same, given the same arguments.
 *
 * Simplex noise is closely related to Perlin noise. It is widely used for procedural content generation.
 *
 * There are many webpages which discuss Perlin and Simplex noise in detail.
 *

 * @param x The first value of the 2-dimensional vector used to generate the noise value.
 * @param y The second value of the 2-dimensional vector used to generate the noise value.
 * @returns value — The noise value in the range of 1.
 */
		noise(this: void, x: number, y: number): number;
/**
 * Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same, given the same arguments.
 *
 * Simplex noise is closely related to Perlin noise. It is widely used for procedural content generation.
 *
 * There are many webpages which discuss Perlin and Simplex noise in detail.
 *

 * @param x The first value of the 3-dimensional vector used to generate the noise value.
 * @param y The second value of the 3-dimensional vector used to generate the noise value.
 * @param z The third value of the 3-dimensional vector used to generate the noise value.
 * @returns value — The noise value in the range of 1.
 */
		noise(this: void, x: number, y: number, z: number): number;
/**
 * Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same, given the same arguments.
 *
 * Simplex noise is closely related to Perlin noise. It is widely used for procedural content generation.
 *
 * There are many webpages which discuss Perlin and Simplex noise in detail.
 *

 * @param x The first value of the 4-dimensional vector used to generate the noise value.
 * @param y The second value of the 4-dimensional vector used to generate the noise value.
 * @param z The third value of the 4-dimensional vector used to generate the noise value.
 * @param w The fourth value of the 4-dimensional vector used to generate the noise value.
 * @returns value — The noise value in the range of 1.
 */
		noise(this: void, x: number, y: number, z: number, w: number): number;
		/**
		 * Deprecated alias of love.data.compress.
		 *

		 * @param container The type of value to return.
		 * @param format The compression format to use.
		 * @param source The uncompressed source data.
		 * @param level The compression level, from 0 to 9, or -1 for the default level.
		 * @returns The compressed data as a string.
		 */
		compress(this: void, container: "string", format: CompressionFormat, source: string | Data, level?: number): string;
		/**
		 * Deprecated alias of love.data.compress.
		 *

		 * @param container The type of value to return.
		 * @param format The compression format to use.
		 * @param source The uncompressed source data.
		 * @param level The compression level, from 0 to 9, or -1 for the default level.
		 * @returns The compressed data as a CompressedData object.
		 */
		compress(this: void, container: "data", format: CompressionFormat, source: string | Data, level?: number): CompressedData;
		/**
		 * Deprecated alias of love.data.decompress.
		 *

		 * @param container The type of value to return.
		 * @param compressed The compressed data to decompress.
		 * @returns The decompressed data as a string.
		 */
		decompress(this: void, container: "string", compressed: CompressedData): string;
		/**
		 * Deprecated alias of love.data.decompress.
		 *

		 * @param container The type of value to return.
		 * @param compressed The compressed data to decompress.
		 * @returns The decompressed data as a ByteData object.
		 */
		decompress(this: void, container: "data", compressed: CompressedData): ByteData;
		/**
		 * Generates a pseudo-random number in a platform independent manner. The default love.run seeds this function at startup, so you generally don't need to seed it yourself.
		 *

		 * @returns number — The pseudo-random number.
		 */
		random(this: void): number;
		/**
		 * Generates a pseudo-random number in a platform independent manner. The default love.run seeds this function at startup, so you generally don't need to seed it yourself.
		 *

		 * @param upper The maximum possible value it should return.
		 * @returns The pseudo-random integer number.
		 */
		random(this: void, upper: number): number;
		/**
		 * Generates a pseudo-random number in a platform independent manner. The default love.run seeds this function at startup, so you generally don't need to seed it yourself.
		 *

		 * @param lower The minimum possible value it should return.
		 * @param upper The maximum possible value it should return.
		 * @returns The pseudo-random integer number.
		 */
		random(this: void, lower: number, upper: number): number;
		/**
		 * Get a normally distributed pseudo random number.
		 *
		 * @param standardDeviation Standard deviation of the distribution. (Default: 1.)
		 * @param mean The mean of the distribution. (Default: 0.)
		 *
		 * @returns number — Normally distributed random number with variance (stddev)² and the specified mean.
		 */
		randomNormal(this: void, standardDeviation?: number, mean?: number): number;
		/**
		 * Sets the seed of the random number generator using the specified integer number. This is called internally at startup, so you generally don't need to call it yourself.
		 *

		 * @param seed The integer number with which you want to seed the randomization. Must be within the range of 2^53 - 1.
		 */
		setRandomSeed(this: void, seed: number): void;
		/**
		 * Sets the seed of the random number generator using the specified integer number. This is called internally at startup, so you generally don't need to call it yourself.
		 *

		 * @param low The lower 32 bits of the seed value. Must be within the range of 2^32 - 1.
		 * @param high The higher 32 bits of the seed value. Must be within the range of 2^32 - 1.
		 */
		setRandomSeed(this: void, low: number, high: number): void;
		/**
		 * Gets the seed of the random number generator.
		 *
		 * The seed is split into two numbers due to Lua's use of doubles for all number values - doubles can't accurately represent integer values above 2^53, but the seed can be an integer value up to 2^64.
		 *
		 * @returns low — Integer number representing the lower 32 bits of the random number generator's 64 bit seed value.
		 * @returns high — Integer number representing the higher 32 bits of the random number generator's 64 bit seed value.
		 */
		getRandomSeed(this: void): LuaMultiReturn<[number, number]>;
		/**
		 * Sets the current state of the random number generator. The value used as an argument for this function is an opaque implementation-dependent string and should only originate from a previous call to love.math.getRandomState.
		 *
		 * This is different from love.math.setRandomSeed in that setRandomState directly sets the random number generator's current implementation-dependent state, whereas setRandomSeed gives it a new seed value.
		 *
		 * Overload details:
		 * 1. The effect of the state string does not depend on the current operating system.
		 *
		 * @param state The new state of the random number generator, represented as a string. This should originate from a previous call to love.math.getRandomState.
		 */
		setRandomState(this: void, state: string): void;
		/**
		 * Gets the current state of the random number generator. This returns an opaque implementation-dependent string which is only useful for later use with love.math.setRandomState or RandomGenerator:setState.
		 *
		 * This is different from love.math.getRandomSeed in that getRandomState gets the random number generator's current state, whereas getRandomSeed gets the previously set seed number.
		 *
		 * Overload details:
		 * 1. The value of the state string does not depend on the current operating system.
		 *
		 * @returns state — The current state of the random number generator, represented as a string.
		 */
		getRandomState(this: void): string;
		/**
		 * Converts a color from 0..1 to 0..255 range.
		 *

		 * @param red Red color component.
		 * @param green Green color component.
		 * @param blue Blue color component.
		 * @param alpha Alpha color component. (Default: nil.)
		 * @returns rb — Red color component in 0..255 range.
		 * @returns gb — Green color component in 0..255 range.
		 * @returns bb — Blue color component in 0..255 range.
		 * @returns ab — Alpha color component in 0..255 range or nil if alpha is not specified.
		 */
		colorToBytes(this: void, red: number, green: number, blue: number, alpha?: number): LuaMultiReturn<[number, number, number, number?]>;
		/**
		 * Converts a color from 0..1 to 0..255 range.
		 *

		 * @param color Red color component.
		 * @returns rb — Red color component in 0..255 range.
		 * @returns gb — Green color component in 0..255 range.
		 * @returns bb — Blue color component in 0..255 range.
		 * @returns ab — Alpha color component in 0..255 range or nil if alpha is not specified.
		 */
		colorToBytes(this: void, color: number[]): LuaMultiReturn<[number, number, number, number?]>;
		/**
		 * Converts a color from 0..255 to 0..1 range.
		 *

		 * @param red Red color component in 0..255 range.
		 * @param green Green color component in 0..255 range.
		 * @param blue Blue color component in 0..255 range.
		 * @param alpha Alpha color component in 0..255 range. (Default: nil.)
		 * @returns r — Red color component in 0..1 range.
		 * @returns g — Green color component in 0..1 range.
		 * @returns b — Blue color component in 0..1 range.
		 * @returns a — Alpha color component in 0..1 range or nil if alpha is not specified.
		 */
		colorFromBytes(this: void, red: number, green: number, blue: number, alpha?: number): LuaMultiReturn<[number, number, number, number?]>;
		/**
		 * Converts a color from 0..255 to 0..1 range.
		 *

		 * @param color Red color component in 0..255 range.
		 * @returns r — Red color component in 0..1 range.
		 * @returns g — Green color component in 0..1 range.
		 * @returns b — Blue color component in 0..1 range.
		 * @returns a — Alpha color component in 0..1 range or nil if alpha is not specified.
		 */
		colorFromBytes(this: void, color: number[]): LuaMultiReturn<[number, number, number, number?]>;
		/**
		 * Converts a color from gamma-space (sRGB) to linear-space (RGB). This is useful when doing gamma-correct rendering and you need to do math in linear RGB in the few cases where LÖVE doesn't handle conversions automatically.
		 *
		 * Read more about gamma-correct rendering here, here, and here.
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *

		 * @param red The red channel of the sRGB color to convert.
		 * @param green The green channel of the sRGB color to convert.
		 * @param blue The blue channel of the sRGB color to convert.
		 * @param alpha The alpha channel, which is returned unchanged. (Default: nil.)
		 * @returns lr — The red channel of the converted color in linear RGB space.
		 * @returns lg — The green channel of the converted color in linear RGB space.
		 * @returns lb — The blue channel of the converted color in linear RGB space.
		 * @returns lc — The value of the color channel in linear RGB space.
		 */
		gammaToLinear(this: void, red: number, green?: number, blue?: number, alpha?: number): LuaMultiReturn<[number, number?, number?, number?]>;
		/**
		 * Converts a color from gamma-space (sRGB) to linear-space (RGB). This is useful when doing gamma-correct rendering and you need to do math in linear RGB in the few cases where LÖVE doesn't handle conversions automatically.
		 *
		 * Read more about gamma-correct rendering here, here, and here.
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *

		 * @param color An array with the red, green, and blue channels of the sRGB color to convert.
		 * @returns lr — The red channel of the converted color in linear RGB space.
		 * @returns lg — The green channel of the converted color in linear RGB space.
		 * @returns lb — The blue channel of the converted color in linear RGB space.
		 * @returns lc — The value of the color channel in linear RGB space.
		 */
		gammaToLinear(this: void, color: number[]): LuaMultiReturn<[number, number?, number?, number?]>;
		/**
		 * Converts a color from linear-space (RGB) to gamma-space (sRGB). This is useful when storing linear RGB color values in an image, because the linear RGB color space has less precision than sRGB for dark colors, which can result in noticeable color banding when drawing.
		 *
		 * In general, colors chosen based on what they look like on-screen are already in gamma-space and should not be double-converted. Colors calculated using math are often in the linear RGB space.
		 *
		 * Read more about gamma-correct rendering here, here, and here.
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *

		 * @param red The red channel of the linear RGB color to convert.
		 * @param green The green channel of the linear RGB color to convert.
		 * @param blue The blue channel of the linear RGB color to convert.
		 * @param alpha The alpha channel, which is returned unchanged. (Default: nil.)
		 * @returns cr — The red channel of the converted color in gamma sRGB space.
		 * @returns cg — The green channel of the converted color in gamma sRGB space.
		 * @returns cb — The blue channel of the converted color in gamma sRGB space.
		 * @returns c — The value of the color channel in gamma sRGB space.
		 */
		linearToGamma(this: void, red: number, green?: number, blue?: number, alpha?: number): LuaMultiReturn<[number, number?, number?, number?]>;
		/**
		 * Converts a color from linear-space (RGB) to gamma-space (sRGB). This is useful when storing linear RGB color values in an image, because the linear RGB color space has less precision than sRGB for dark colors, which can result in noticeable color banding when drawing.
		 *
		 * In general, colors chosen based on what they look like on-screen are already in gamma-space and should not be double-converted. Colors calculated using math are often in the linear RGB space.
		 *
		 * Read more about gamma-correct rendering here, here, and here.
		 *
		 * In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
		 *

		 * @param color An array with the red, green, and blue channels of the linear RGB color to convert.
		 * @returns cr — The red channel of the converted color in gamma sRGB space.
		 * @returns cg — The green channel of the converted color in gamma sRGB space.
		 * @returns cb — The blue channel of the converted color in gamma sRGB space.
		 * @returns c — The value of the color channel in gamma sRGB space.
		 */
		linearToGamma(this: void, color: number[]): LuaMultiReturn<[number, number?, number?, number?]>;
		/**
		 * Checks whether a polygon is convex.
		 *
		 * PolygonShapes in love.physics, some forms of Meshes, and polygons drawn with love.graphics.polygon must be simple convex polygons.
		 *

		 * @param vertices The vertices of the polygon as a table in the form of {x1, y1, x2, y2, x3, y3, ...}.
		 * @returns convex — Whether the given polygon is convex.
		 */
		isConvex(this: void, vertices: number[]): boolean;
		/**
		 * Checks whether a polygon is convex.
		 *
		 * PolygonShapes in love.physics, some forms of Meshes, and polygons drawn with love.graphics.polygon must be simple convex polygons.
		 *

		 * @param coordinates The vertices of the polygon as a table in the form of {x1, y1, x2, y2, x3, y3, ...}.
		 * @returns convex — Whether the given polygon is convex.
		 */
		isConvex(this: void, ...coordinates: number[]): boolean;
		/**
		 * Decomposes a simple convex or concave polygon into triangles.
		 *

		 * @param vertices Polygon to triangulate. Must not intersect itself.
		 * @returns triangles — List of triangles the polygon is composed of, in the form of {{x1, y1, x2, y2, x3, y3}, {x1, y1, x2, y2, x3, y3}, ...}.
		 */
		triangulate(this: void, vertices: number[]): number[][];
		/**
		 * Decomposes a simple convex or concave polygon into triangles.
		 *

		 * @param coordinates Polygon to triangulate. Must not intersect itself.
		 * @returns triangles — List of triangles the polygon is composed of, in the form of {{x1, y1, x2, y2, x3, y3}, {x1, y1, x2, y2, x3, y3}, ...}.
		 */
		triangulate(this: void, ...coordinates: number[]): number[][];
	}
	/** Represents a file on the filesystem. A function that takes a file path can also take a File.
	 */
	interface File extends Object {
		/**
		 * Open the file for write, read or append.
		 *
		 * Overload details:
		 * 1. If you are getting the error message 'Could not set write directory', try setting the save directory. This is done either with love.filesystem.setIdentity or by setting the identity field in love.conf (only available with love 0.7 or higher).
		 *
		 * @param mode The mode to open the file in.
		 *
		 * @returns ok — True on success, false otherwise.
		 * @returns err — The error string if an error occurred.
		 */
		open(mode: OpenFileMode): LuaMultiReturn<[true | undefined, string?]>;
		/**
		 * Closes a File.
		 *
		 * @returns success — Whether closing was successful.
		 */
		close(): boolean;
		/**
		 * Gets whether the file is open.
		 *
		 * @returns open — True if the file is currently open, false otherwise.
		 */
		isOpen(): boolean;
		/**
		 * Returns the file size.
		 *
		 * @returns size — The file size in bytes.
		 */
		getSize(): LuaMultiReturn<[number | undefined, string?]>;
		/**
		 * Read a number of bytes from a file.
		 *

		 * @param size The number of bytes to read. (Default: all.)
		 * @returns contents — The contents of the read bytes.
		 * @returns size — How many bytes have been read.
		 */
		read(size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		/**
		 * Read a number of bytes from a file.
		 *

		 * @param container What type to return the file's contents as.
		 * @param size The number of bytes to read. (Default: all.)
		 * @returns FileData or string containing the read bytes.
		 * @returns size — How many bytes have been read.
		 */
		read(container: "string", size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		/**
		 * Read a number of bytes from a file.
		 *

		 * @param container What type to return the file's contents as.
		 * @param size The number of bytes to read. (Default: all.)
		 * @returns FileData or string containing the read bytes.
		 * @returns size — How many bytes have been read.
		 */
		read(container: "data", size?: number): LuaMultiReturn<[FileData | undefined, number | string]>;
		/**
		 * Write data to a file.
		 *

		 * @param data The string data to write.
		 * @param size How many bytes to write. (Default: all.)
		 * @returns success — Whether the operation was successful.
		 * @returns err — The error string if an error occurred.
		 * @returns errorstr — The error string if an error occurred.
		 */
		write(data: string, size?: number): LuaMultiReturn<[true | undefined, string?]>;
/**
 * Write data to a file.
 *

 * @param data The Data object to write.
 * @param size How many bytes to write. (Default: all.)
 * @returns success — Whether the operation was successful.
 * @returns err — The error string if an error occurred.
 * @returns errorstr — The error string if an error occurred.
 */
		write(data: FileData, size?: number): LuaMultiReturn<[true | undefined, string?]>;
		/**
		 * Flushes any buffered written data in the file to the disk.
		 *
		 * @returns success — Whether the file successfully flushed any buffered data to the disk.
		 * @returns err — The error string, if an error occurred and the file could not be flushed.
		 */
		flush(): LuaMultiReturn<[true | undefined, string?]>;
		/**
		 * Gets whether end-of-file has been reached.
		 *
		 * @returns eof — Whether EOF has been reached.
		 */
		isEOF(): boolean;
		/**
		 * Returns the position in the file.
		 *
		 * @returns pos — The current position.
		 */
		tell(): LuaMultiReturn<[number | undefined, string?]>;
		/**
		 * Seek to a position in a file
		 *
		 * @param position The position to seek to
		 *
		 * @returns success — Whether the operation was successful
		 */
		seek(position: number): boolean;
		/**
		 * Iterate over all the lines in a file.
		 *
		 * @returns iterator — The iterator (can be used in for loops).
		 */
		lines(): () => string | undefined;
		/**
		 * Sets the buffer mode for a file opened for writing or appending. Files with buffering enabled will not write data to the disk until the buffer size limit is reached, depending on the buffer mode.
		 *
		 * File:flush will force any buffered data to be written to the disk.
		 *
		 * @param mode The buffer mode to use.
		 * @param size The maximum size in bytes of the file's buffer. (Default: 0.)
		 *
		 * @returns success — Whether the buffer mode was successfully set.
		 * @returns errorstr — The error string, if the buffer mode could not be set and an error occurred.
		 */
		setBuffer(mode: BufferMode, size?: number): boolean;
		/**
		 * Gets the buffer mode of a file.
		 *
		 * @returns mode — The current buffer mode of the file.
		 * @returns size — The maximum size in bytes of the file's buffer.
		 */
		getBuffer(): LuaMultiReturn<[BufferMode, number]>;
		/**
		 * Gets the FileMode the file has been opened with.
		 *
		 * @returns mode — The mode this file has been opened with.
		 */
		getMode(): FileMode;
		/**
		 * Gets the filename that the File object was created with. If the file object originated from the love.filedropped callback, the filename will be the full platform-dependent file path.
		 *
		 * @returns filename — The filename of the File.
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
	 */
	interface Filesystem {
		/**
		 * Sets the write directory for your game.
		 *
		 * Note that you can only set the name of the folder to store your files in, not the location.
		 *
		 * @param identity The new identity that will be used as write directory.
		 */
		setIdentity(this: void, identity: string, appendToPath?: boolean): void;
		/**
		 * Gets the write directory name for your game.
		 *
		 * Note that this only returns the name of the folder to store your files in, not the full path.
		 *
		 * @returns name — The identity that is used as write directory.
		 */
		getIdentity(this: void): string;
		/**
		 * Returns the full path to the the .love file or directory. If the game is fused to the LÖVE executable, then the executable is returned.
		 *
		 * @returns path — The full platform-dependent path of the .love file or directory.
		 */
		getSource(this: void): string;
		/**
		 * Gets the full path to the designated save directory.
		 *
		 * This can be useful if you want to use the standard io library (or something else) to
		 *
		 * read or write in the save directory.
		 *
		 * @returns dir — The absolute path to the save directory.
		 */
		getSaveDirectory(this: void): string;
		/**
		 * Gets the current working directory.
		 *
		 * @returns cwd — The current working directory.
		 */
		getWorkingDirectory(this: void): string;
		/**
		 * Returns the path of the user's directory
		 *
		 * @returns path — The path of the user's directory
		 */
		getUserDirectory(this: void): string;
		/**
		 * Returns the application data directory (could be the same as getUserDirectory)
		 *
		 * @returns path — The path of the application data directory
		 */
		getAppdataDirectory(this: void): string;
		/**
		 * Returns the full path to the directory containing the .love file. If the game is fused to the LÖVE executable, then the directory containing the executable is returned.
		 *
		 * If love.filesystem.isFused is true, the path returned by this function can be passed to love.filesystem.mount, which will make the directory containing the main game (e.g. C:\Program Files\coolgame\) readable by love.filesystem.
		 *
		 * @returns path — The full platform-dependent path of the directory containing the .love file.
		 */
		getSourceBaseDirectory(this: void): string;
		getExecutablePath(this: void): string;
		/**
		 * Gets the platform-specific absolute path of the directory containing a filepath.
		 *
		 * This can be used to determine whether a file is inside the save directory or the game's source .love.
		 *
		 * Overload details:
		 * 1. This function returns the directory containing the given ''file path'', rather than file. For example, if the file screenshot1.png exists in a directory called screenshots in the game's save directory, love.filesystem.getRealDirectory('screenshots/screenshot1.png') will return the same value as love.filesystem.getSaveDirectory.
		 *
		 * @param filename The filepath to get the directory of.
		 *
		 * @returns realdir — The platform-specific full path of the directory containing the filepath.
		 */
		getRealDirectory(this: void, filename: string): LuaMultiReturn<[string | undefined, string?]>;
		/**
		 * Gets the filesystem paths that will be searched when require is called.
		 *
		 * The paths string returned by this function is a sequence of path templates separated by semicolons. The argument passed to ''require'' will be inserted in place of any question mark ('?') character in each template (after the dot characters in the argument passed to ''require'' are replaced by directory separators.)
		 *
		 * The paths are relative to the game's source and save directories, as well as any paths mounted with love.filesystem.mount.
		 *
		 * Overload details:
		 * 1. The default paths string is '?.lua;?/init.lua', which makes require('cool') try to load cool.lua and then try cool/init.lua if cool.lua doesn't exist.
		 *
		 * @returns paths — The paths that the ''require'' function will check in love's filesystem.
		 */
		getRequirePath(this: void): string;
		/**
		 * Sets the filesystem paths that will be searched when require is called.
		 *
		 * The paths string given to this function is a sequence of path templates separated by semicolons. The argument passed to ''require'' will be inserted in place of any question mark ('?') character in each template (after the dot characters in the argument passed to ''require'' are replaced by directory separators.)
		 *
		 * The paths are relative to the game's source and save directories, as well as any paths mounted with love.filesystem.mount.
		 *
		 * Overload details:
		 * 1. The default paths string is '?.lua;?/init.lua', which makes require('cool') try to load cool.lua and then try cool/init.lua if cool.lua doesn't exist.
		 *
		 * @param path The paths that the ''require'' function will check in love's filesystem.
		 */
		setRequirePath(this: void, path: string): void;
		/**
		 * Mounts a zip file or folder in the game's save directory for reading.
		 *
		 * It is also possible to mount love.filesystem.getSourceBaseDirectory if the game is in fused mode.
		 *

		 * @param archive The folder or zip file in the game's save directory to mount.
		 * @param mountpoint The new path the archive will be mounted to.
		 * @param appendToPath Whether the archive will be searched when reading a filepath before or after already-mounted archives. This includes the game's source and save directories. (Default: false.)
		 * @returns success — True if the archive was successfully mounted, false otherwise.
		 */
		mount(this: void, archive: string, mountpoint: string, appendToPath?: boolean): boolean;
/**
 * Mounts a zip file or folder in the game's save directory for reading.
 *
 * It is also possible to mount love.filesystem.getSourceBaseDirectory if the game is in fused mode.
 *

 * @param archive The folder or zip file in the game's save directory to mount.
 * @param mountpoint The new path the archive will be mounted to.
 * @param appendToPath Whether the archive will be searched when reading a filepath before or after already-mounted archives. This includes the game's source and save directories. (Default: false.)
 * @returns success — True if the archive was successfully mounted, false otherwise.
 */
		mount(this: void, archive: FileData, mountpoint: string, appendToPath?: boolean): boolean;
		/**
		 * Unmounts a zip file or folder previously mounted for reading with love.filesystem.mount.
		 *

		 * @param archive The folder or zip file in the game's save directory which is currently mounted.
		 * @returns success — True if the archive was successfully unmounted, false otherwise.
		 */
		unmount(this: void, archive: string): boolean;
/**
 * Unmounts a zip file or folder previously mounted for reading with love.filesystem.mount.
 *

 * @param archive The folder or zip file in the game's save directory which is currently mounted.
 * @returns success — True if the archive was successfully unmounted, false otherwise.
 */
		unmount(this: void, archive: FileData): boolean;
		/**
		 * Gets whether the game is in fused mode or not.
		 *
		 * If a game is in fused mode, its save directory will be directly in the Appdata directory instead of Appdata/LOVE/. The game will also be able to load C Lua dynamic libraries which are located in the save directory.
		 *
		 * A game is in fused mode if the source .love has been fused to the executable (see Game Distribution), or if '--fused' has been given as a command-line argument when starting the game.
		 *
		 * @returns fused — True if the game is in fused mode, false otherwise.
		 */
		isFused(this: void): false;
		/**
		 * Creates a new File object.
		 *
		 * It needs to be opened before it can be accessed.
		 *

		 * @param filename The filename of the file.
		 * @returns file — The new File object.
		 * @returns errorstr — The error string if an error occurred.
		 */
		newFile(this: void, filename: string): File;
/**
 * Creates a new File object.
 *
 * It needs to be opened before it can be accessed.
 *

 * @param filename The filename of the file.
 * @param mode The mode to open the file in.
 * @returns The new File object, or nil if an error occurred.
 * @returns errorstr — The error string if an error occurred.
 */
		newFile(this: void, filename: string, mode: OpenFileMode): File;
		/**
		 * Creates a new FileData object from a file on disk, or from a string in memory.
		 *

		 * @param filename Path to the file.
		 * @returns data — The new FileData.
		 * @returns err — The error string, if an error occurred.
		 */
		newFileData(this: void, filename: string): FileData;
		/**
		 * Creates a new FileData object from a file on disk, or from a string in memory.
		 *

		 * @param file Path to the file.
		 * @returns The new FileData, or nil if an error occurred.
		 * @returns err — The error string, if an error occurred.
		 */
		newFileData(this: void, file: File): FileData;
		/**
		 * Creates a new FileData object from a file on disk, or from a string in memory.
		 *

		 * @param data The Data object to copy into the new FileData object.
		 * @param filename The name of the file. The extension may be parsed and used by LÖVE when passing the FileData object into love.audio.newSource.
		 * @returns The new FileData, or nil if an error occurred.
		 * @returns err — The error string, if an error occurred.
		 */
		newFileData(this: void, data: string, filename: string): FileData;
		/**
		 * Read the contents of a file.
		 *

		 * @param filename The name (and path) of the file.
		 * @param size How many bytes to read. (Default: all.)
		 * @returns contents — The file contents.
		 * @returns size — How many bytes have been read.
		 * @returns error — returns an error message.
		 */
		read(this: void, filename: string, size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		/**
		 * Read the contents of a file.
		 *

		 * @param container What type to return the file's contents as.
		 * @param filename The name (and path) of the file
		 * @param size How many bytes to read (Default: all.)
		 * @returns returns nil as content.
		 * @returns size — How many bytes have been read.
		 * @returns error — returns an error message.
		 */
		read(this: void, container: "string", filename: string, size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		/**
		 * Read the contents of a file.
		 *

		 * @param container What type to return the file's contents as.
		 * @param filename The name (and path) of the file
		 * @param size How many bytes to read (Default: all.)
		 * @returns FileData or string containing the file contents.
		 * @returns size — How many bytes have been read.
		 * @returns error — returns an error message.
		 */
		read(this: void, container: "data", filename: string, size?: number): LuaMultiReturn<[FileData | undefined, number | string]>;
		/**
		 * Loads a Lua file (but does not run it).
		 *
		 * @param filename The name (and path) of the file.
		 *
		 * @returns chunk — The loaded chunk.
		 * @returns errormsg — The error message if file could not be opened.
		 */
		load(this: void, filename: string): LuaMultiReturn<[((...args: unknown[]) => unknown) | undefined, string?]>;
		/**
		 * Iterate over the lines in a file.
		 *
		 * @param filename The name (and path) of the file
		 *
		 * @returns iterator — A function that iterates over all the lines in the file
		 */
		lines(this: void, filename: string): () => string | undefined;
		/**
		 * Write data to a file in the save directory. If the file existed already, it will be completely replaced by the new contents.
		 *

		 * @param filename The name (and path) of the file.
		 * @param data The string data to write to the file.
		 * @param size How many bytes to write. (Default: all.)
		 * @returns success — If the operation was successful.
		 * @returns message — Error message if operation was unsuccessful.
		 */
		write(this: void, filename: string, data: string, size?: number): LuaMultiReturn<[boolean, string?]>;
/**
 * Write data to a file in the save directory. If the file existed already, it will be completely replaced by the new contents.
 *

 * @param filename The name (and path) of the file.
 * @param data The Data object to write to the file.
 * @param size How many bytes to write. (Default: all.)
 * @returns success — If the operation was successful.
 * @returns message — Error message if operation was unsuccessful.
 */
		write(this: void, filename: string, data: FileData, size?: number): LuaMultiReturn<[boolean, string?]>;
		/**
		 * Append data to an existing file.
		 *

		 * @param filename The name (and path) of the file.
		 * @param data The string data to append to the file.
		 * @param size How many bytes to write. (Default: all.)
		 * @returns success — True if the operation was successful, or nil if there was an error.
		 * @returns errormsg — The error message on failure.
		 */
		append(this: void, filename: string, data: string, size?: number): LuaMultiReturn<[boolean, string?]>;
/**
 * Append data to an existing file.
 *

 * @param filename The name (and path) of the file.
 * @param data The Data object to append to the file.
 * @param size How many bytes to write. (Default: all.)
 * @returns success — True if the operation was successful, or nil if there was an error.
 * @returns errormsg — The error message on failure.
 */
		append(this: void, filename: string, data: FileData, size?: number): LuaMultiReturn<[boolean, string?]>;
		/**
		 * Gets information about the specified file or directory.
		 *

		 * @param filename The file or directory path to check.
		 * @returns info — A table containing information about the specified path, or nil if nothing exists at the path. The table contains the following fields:
		 * @returns info.type — The type of the object at the path (file, directory, symlink, etc.)
		 * @returns info.size — The size in bytes of the file, or nil if it can't be determined.
		 * @returns info.modtime — The file's last modification time in seconds since the unix epoch, or nil if it can't be determined.
		 */
		getInfo(this: void, filename: string): FileInfo | undefined;
/**
 * Gets information about the specified file or directory.
 *

 * @param filename The file or directory path to check.
 * @param filterType Causes getInfo to only return the info table if the item at the given path matches the specified file type.
 * @returns The table given as an argument, or nil if nothing exists at the path. The table will be filled in with the following fields:
 * @returns info.type — The type of the object at the path (file, directory, symlink, etc.)
 * @returns info.size — The size in bytes of the file, or nil if it can't be determined.
 * @returns info.modtime — The file's last modification time in seconds since the unix epoch, or nil if it can't be determined.
 */
		getInfo(this: void, filename: string, filterType: FileType): FileInfo | undefined;
		/** @deprecated Use getInfo instead. */
		exists(this: void, filename: string): boolean;
		/** @deprecated Use getInfo instead. */
		isDirectory(this: void, filename: string): boolean;
		/** @deprecated Use getInfo instead. */
		isFile(this: void, filename: string): boolean;
		/** @deprecated Use getInfo instead. */
		isSymlink(this: void, filename: string): boolean;
		/** @deprecated Use getInfo instead. */
		getLastModified(this: void, filename: string): LuaMultiReturn<[number | undefined, string?]>;
		/** @deprecated Use getInfo instead. */
		getSize(this: void, filename: string): LuaMultiReturn<[number | undefined, string?]>;
		/**
		 * Recursively creates a directory.
		 *
		 * When called with 'a/b' it creates both 'a' and 'a/b', if they don't exist already.
		 *
		 * @param name The directory to create.
		 *
		 * @returns success — True if the directory was created, false if not.
		 */
		createDirectory(this: void, name: string): LuaMultiReturn<[boolean, string?]>;
		/**
		 * Removes a file or empty directory.
		 *
		 * Overload details:
		 * 1. The directory must be empty before removal or else it will fail. Simply remove all files and folders in the directory beforehand. If the file exists in the .love but not in the save directory, it returns false as well. An opened File prevents removal of the underlying file. Simply close the File to remove it.
		 *
		 * @param name The file or directory to remove.
		 *
		 * @returns success — True if the file/directory was removed, false otherwise.
		 */
		remove(this: void, name: string): LuaMultiReturn<[boolean, string?]>;
		/**
		 * Returns a table with the names of files and subdirectories in the specified path. The table is not sorted in any way; the order is undefined.
		 *
		 * If the path passed to the function exists in the game and the save directory, it will list the files and directories from both places.
		 *
		 * @param directory The directory.
		 *
		 * @returns files — A sequence with the names of all files and subdirectories as strings.
		 */
		getDirectoryItems(this: void, directory?: string): string[];
	}

	/** @noSelf */
	/** Provides an interface to the user's keyboard.
	 */
	interface Keyboard {
		/**
		 * Enables or disables key repeat for love.keypressed. It is disabled by default.
		 *
		 * Overload details:
		 * 1. The interval between repeats depends on the user's system settings. This function doesn't affect whether love.textinput is called multiple times while a key is held down.
		 *
		 * @param enabled Whether repeat keypress events should be enabled when a key is held down.
		 */
		setKeyRepeat(this: void, enabled: boolean): void;
		/**
		 * Gets whether key repeat is enabled.
		 *
		 * @returns enabled — Whether key repeat is enabled.
		 */
		hasKeyRepeat(this: void): boolean;
		/**
		 * Checks whether a certain key is down. Not to be confused with love.keypressed or love.keyreleased.
		 *

		 * @param keys A table containing keys to check.
		 * @returns down — True if the key is down, false if not.
		 * @returns anyDown — True if any supplied key is down, false if not.
		 */
		isDown(this: void, ...keys: string[]): boolean;
		/**
		 * Checks whether a certain key is down. Not to be confused with love.keypressed or love.keyreleased.
		 *

		 * @param keys A table containing keys to check.
		 * @returns down — True if the key is down, false if not.
		 * @returns True if any of the keys in the table are down, false if not.
		 */
		isDown(this: void, keys: string[]): boolean;
		/**
		 * Checks whether the specified Scancodes are pressed. Not to be confused with love.keypressed or love.keyreleased.
		 *
		 * Unlike regular KeyConstants, Scancodes are keyboard layout-independent. The scancode 'w' is used if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.
		 *

		 * @param scancodes A Scancode to check.
		 * @returns down — True if any supplied Scancode is down, false if not.
		 */
		isScancodeDown(this: void, ...scancodes: string[]): boolean;
		/**
		 * Checks whether the specified Scancodes are pressed. Not to be confused with love.keypressed or love.keyreleased.
		 *
		 * Unlike regular KeyConstants, Scancodes are keyboard layout-independent. The scancode 'w' is used if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.
		 *

		 * @param scancodes A Scancode to check.
		 * @returns down — True if any supplied Scancode is down, false if not.
		 */
		isScancodeDown(this: void, scancodes: string[]): boolean;
		/**
		 * Gets the hardware scancode corresponding to the given key.
		 *
		 * Unlike key constants, Scancodes are keyboard layout-independent. For example the scancode 'w' will be generated if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.
		 *
		 * Scancodes are useful for creating default controls that have the same physical locations on on all systems.
		 *
		 * @param key The key to get the scancode from.
		 *
		 * @returns scancode — The scancode corresponding to the given key, or 'unknown' if the given key has no known physical representation on the current system.
		 */
		getScancodeFromKey(this: void, key: string): string;
		/**
		 * Gets the key corresponding to the given hardware scancode.
		 *
		 * Unlike key constants, Scancodes are keyboard layout-independent. For example the scancode 'w' will be generated if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.
		 *
		 * Scancodes are useful for creating default controls that have the same physical locations on on all systems.
		 *
		 * @param scancode The scancode to get the key from.
		 *
		 * @returns key — The key corresponding to the given scancode, or 'unknown' if the scancode doesn't map to a KeyConstant on the current system.
		 */
		getKeyFromScancode(this: void, scancode: string): string;
		/**
		 * Enables or disables text input events. It is enabled by default on Windows, Mac, and Linux, and disabled by default on iOS and Android.
		 *
		 * On touch devices, this shows the system's native on-screen keyboard when it's enabled.
		 *

		 * @param enabled Whether text input events should be enabled.
		 */
		setTextInput(this: void, enabled: boolean): void;
		/**
		 * Enables or disables text input events. It is enabled by default on Windows, Mac, and Linux, and disabled by default on iOS and Android.
		 *
		 * On touch devices, this shows the system's native on-screen keyboard when it's enabled.
		 *

		 * @param enabled Whether text input events should be enabled.
		 * @param x Text rectangle x position.
		 * @param y Text rectangle y position.
		 * @param width Text rectangle width.
		 * @param height Text rectangle height.
		 */
		setTextInput(this: void, enabled: boolean, x: number, y: number, width: number, height: number): void;
		/**
		 * Gets whether text input events are enabled.
		 *
		 * @returns enabled — Whether text input events are enabled.
		 */
		hasTextInput(this: void): boolean;
		/**
		 * Gets whether screen keyboard is supported.
		 *
		 * @returns supported — Whether screen keyboard is supported.
		 */
		hasScreenKeyboard(this: void): boolean;
	}

	/** @noSelf */
	type SystemCursor = "arrow" | "ibeam" | "wait" | "crosshair" | "waitarrow" | "sizenwse" | "sizenesw" | "sizewe" | "sizens" | "sizeall" | "no" | "hand";
	/** Represents a hardware cursor.
	 */
	interface Cursor extends Object {
		/**
		 * Gets the type of the Cursor.
		 *
		 * @returns ctype — The type of the Cursor.
		 */
		getType(): "image" | SystemCursor;
		/**
		 * Gets the type of the object as a string.
		 *
		 * @returns type — The type as a string.
		 */
		type(): "Cursor";
		/**
		 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 *
		 * @param typeName The name of the type to check for.
		 *
		 * @returns b — True if the object is of the specified type, false otherwise.
		 */
		typeOf(typeName: string): boolean;
	}
	/** @noSelf */
	/** Provides an interface to the user's mouse.
	 */
	interface Mouse {
		/**
		 * Returns the current position of the mouse.
		 *
		 * @returns x — The position of the mouse along the x-axis.
		 * @returns y — The position of the mouse along the y-axis.
		 */
		getPosition(this: void): LuaMultiReturn<[number, number]>;
		/**
		 * Returns the current x-position of the mouse.
		 *
		 * @returns x — The position of the mouse along the x-axis.
		 */
		getX(this: void): number;
		/**
		 * Returns the current y-position of the mouse.
		 *
		 * @returns y — The position of the mouse along the y-axis.
		 */
		getY(this: void): number;
		/**
		 * Sets the current position of the mouse. Non-integer values are floored.
		 *
		 * @param x The new position of the mouse along the x-axis.
		 * @param y The new position of the mouse along the y-axis.
		 */
		setPosition(this: void, x: number, y: number): void;
		/**
		 * Sets the current X position of the mouse.
		 *
		 * Non-integer values are floored.
		 *
		 * @param x The new position of the mouse along the x-axis.
		 */
		setX(this: void, x: number): void;
		/**
		 * Sets the current Y position of the mouse.
		 *
		 * Non-integer values are floored.
		 *
		 * @param y The new position of the mouse along the y-axis.
		 */
		setY(this: void, y: number): void;
		/**
		 * Checks whether a certain mouse button is down.
		 *
		 * This function does not detect mouse wheel scrolling; you must use the love.wheelmoved (or love.mousepressed in version 0.9.2 and older) callback for that.
		 *

		 * @param buttons The index of a button to check. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependant.
		 * @returns down — True if any specified button is down.
		 */
		isDown(this: void, ...buttons: number[]): boolean;
		/**
		 * Checks whether a certain mouse button is down.
		 *
		 * This function does not detect mouse wheel scrolling; you must use the love.wheelmoved (or love.mousepressed in version 0.9.2 and older) callback for that.
		 *

		 * @param buttons The index of a button to check. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependant.
		 * @returns down — True if any specified button is down.
		 */
		isDown(this: void, buttons: number[]): boolean;
		/**
		 * Sets the current visibility of the cursor.
		 *
		 * @param visible True to set the cursor to visible, false to hide the cursor.
		 */
		setVisible(this: void, visible: boolean): void;
		/**
		 * Checks if the cursor is visible.
		 *
		 * @returns visible — True if the cursor to visible, false if the cursor is hidden.
		 */
		isVisible(this: void): boolean;
		/**
		 * Grabs the mouse and confines it to the window.
		 *
		 * @param grabbed True to confine the mouse, false to let it leave the window.
		 */
		setGrabbed(this: void, grabbed: boolean): void;
		/**
		 * Checks if the mouse is grabbed.
		 *
		 * @returns grabbed — True if the cursor is grabbed, false if it is not.
		 */
		isGrabbed(this: void): boolean;
		/**
		 * Sets whether relative mode is enabled for the mouse.
		 *
		 * When relative mode is enabled, the cursor is hidden and doesn't move when the mouse does, but relative mouse motion events are still generated via love.mousemoved. This lets the mouse move in any direction indefinitely without the cursor getting stuck at the edges of the screen.
		 *
		 * The reported position of the mouse may not be updated while relative mode is enabled, even when relative mouse motion events are generated.
		 *
		 * @param relative True to enable relative mode, false to disable it.
		 */
		setRelativeMode(this: void, relative: boolean): boolean;
		/**
		 * Gets whether relative mode is enabled for the mouse.
		 *
		 * If relative mode is enabled, the cursor is hidden and doesn't move when the mouse does, but relative mouse motion events are still generated via love.mousemoved. This lets the mouse move in any direction indefinitely without the cursor getting stuck at the edges of the screen.
		 *
		 * The reported position of the mouse is not updated while relative mode is enabled, even when relative mouse motion events are generated.
		 *
		 * @returns enabled — True if relative mode is enabled, false if it's disabled.
		 */
		getRelativeMode(this: void): boolean;
		/**
		 * Creates a new hardware Cursor object from an image file or ImageData.
		 *
		 * Hardware cursors are framerate-independent and work the same way as normal operating system cursors. Unlike drawing an image at the mouse's current coordinates, hardware cursors never have visible lag between when the mouse is moved and when the cursor position updates, even at low framerates.
		 *
		 * The hot spot is the point the operating system uses to determine what was clicked and at what position the mouse cursor is. For example, the normal arrow pointer normally has its hot spot at the top left of the image, but a crosshair cursor might have it in the middle.
		 *
		 * @param image The ImageData to use for the new Cursor. Depending on the overload: Path to the image to use for the new Cursor. Depending on the overload: Data representing the image to use for the new Cursor.
		 * @param hotX The x-coordinate in the ImageData of the cursor's hot spot. (Default: 0.) Depending on the overload: The x-coordinate in the image of the cursor's hot spot. (Default: 0.)
		 * @param hotY The y-coordinate in the ImageData of the cursor's hot spot. (Default: 0.) Depending on the overload: The y-coordinate in the image of the cursor's hot spot. (Default: 0.)
		 *
		 * @returns cursor — The new Cursor object.
		 */
		newCursor(this: void, image: ImageData | FileData | string, hotX?: number, hotY?: number): Cursor;
		/**
		 * Gets a Cursor object representing a system-native hardware cursor.
		 *
		 * Hardware cursors are framerate-independent and work the same way as normal operating system cursors. Unlike drawing an image at the mouse's current coordinates, hardware cursors never have visible lag between when the mouse is moved and when the cursor position updates, even at low framerates.
		 *
		 * Overload details:
		 * 1. The 'image' CursorType is not a valid argument. Use love.mouse.newCursor to create a hardware cursor using a custom image.
		 *
		 * @param type The type of system cursor to get.
		 *
		 * @returns cursor — The Cursor object representing the system cursor type.
		 */
		getSystemCursor(this: void, type: SystemCursor): Cursor;
		/**
		 * Sets the current mouse cursor.
		 *
		 */
		setCursor(this: void): void;
/**
 * Sets the current mouse cursor.
 *

 * @param cursor The Cursor object to use as the current mouse cursor.
 */
		setCursor(this: void, cursor: Cursor): void;
		/**
		 * Gets the current Cursor.
		 *
		 * @returns cursor — The current cursor, or nil if no cursor is set.
		 */
		getCursor(this: void): Cursor | undefined;
		/**
		 * Gets whether cursor functionality is supported.
		 *
		 * If it isn't supported, calling love.mouse.newCursor and love.mouse.getSystemCursor will cause an error. Mobile devices do not support cursors.
		 *
		 * @returns supported — Whether the system has cursor functionality.
		 */
		isCursorSupported(this: void): boolean;
	}
	type TouchID = LuaUserdata;
	/** @noSelf */
	/** Provides an interface to touch-screen presses.
	 */
	interface Touch {
		/**
		 * Gets a list of all active touch-presses.
		 *
		 * Overload details:
		 * 1. The id values are the same as those used as arguments to love.touchpressed, love.touchmoved, and love.touchreleased. The id value of a specific touch-press is only guaranteed to be unique for the duration of that touch-press. As soon as love.touchreleased is called using that id, it may be reused for a new touch-press via love.touchpressed.
		 *
		 * @returns touches — A list of active touch-press id values, which can be used with love.touch.getPosition.
		 */
		getTouches(this: void): TouchID[];
		/**
		 * Gets the current position of the specified touch-press, in pixels.
		 *
		 * Overload details:
		 * 1. The unofficial Android and iOS ports of LÖVE 0.9.2 reported touch-press positions as normalized values in the range of 1, whereas this API reports positions in pixels.
		 *
		 * @param id The identifier of the touch-press. Use love.touch.getTouches, love.touchpressed, or love.touchmoved to obtain touch id values.
		 *
		 * @returns x — The position along the x-axis of the touch-press inside the window, in pixels.
		 * @returns y — The position along the y-axis of the touch-press inside the window, in pixels.
		 */
		getPosition(this: void, id: TouchID): LuaMultiReturn<[number, number]>;
		/**
		 * Gets the current pressure of the specified touch-press.
		 *
		 * @param id The identifier of the touch-press. Use love.touch.getTouches, love.touchpressed, or love.touchmoved to obtain touch id values.
		 *
		 * @returns pressure — The pressure of the touch-press. Most touch screens aren't pressure sensitive, in which case the pressure will be 1.
		 */
		getPressure(this: void, id: TouchID): number;
	}
	type GamepadButton = "a" | "b" | "x" | "y" | "back" | "guide" | "start" | "leftstick" | "rightstick" | "leftshoulder" | "rightshoulder" | "dpup" | "dpdown" | "dpleft" | "dpright" | "misc1" | "paddle1" | "paddle2" | "paddle3" | "paddle4" | "touchpad";
	type GamepadAxis = "leftx" | "lefty" | "rightx" | "righty" | "triggerleft" | "triggerright";
	type JoystickHat = "c" | "u" | "r" | "d" | "l" | "ru" | "rd" | "lu" | "ld";
	type JoystickInputType = "axis" | "button" | "hat";
	/** Represents a physical joystick.
	 */
	interface Joystick extends Object {
		/**
		 * Gets whether the Joystick is connected.
		 *
		 * @returns connected — True if the Joystick is currently connected, false otherwise.
		 */
		isConnected(): boolean;
		/**
		 * Gets the name of the joystick.
		 *
		 * @returns name — The name of the joystick.
		 */
		getName(): string;
		/**
		 * Gets the joystick's unique identifier. The identifier will remain the same for the life of the game, even when the Joystick is disconnected and reconnected, but it '''will''' change when the game is re-launched.
		 *
		 * @returns id — The Joystick's unique identifier. Remains the same as long as the game is running.
		 * @returns instanceid — Unique instance identifier. Changes every time the Joystick is reconnected. nil if the Joystick is not connected.
		 */
		getID(): LuaMultiReturn<[number, number | undefined]>;
		/**
		 * Gets a stable GUID unique to the type of the physical joystick which does not change over time. For example, all Sony Dualshock 3 controllers in OS X have the same GUID. The value is platform-dependent.
		 *
		 * @returns guid — The Joystick type's OS-dependent unique identifier.
		 */
		getGUID(): string;
		/**
		 * Gets the USB vendor ID, product ID, and product version numbers of joystick which consistent across operating systems.
		 *
		 * Can be used to show different icons, etc. for different gamepads.
		 *
		 * Overload details:
		 * 1. Some Linux distribution may not ship with SDL 2.0.6 or later, in which case this function will returns 0 for all the three values.
		 *
		 * @returns vendorID — The USB vendor ID of the joystick.
		 * @returns productID — The USB product ID of the joystick.
		 * @returns productVersion — The product version of the joystick.
		 */
		getDeviceInfo(): LuaMultiReturn<[number, number, number]>;
		/**
		 * Gets the number of axes on the joystick.
		 *
		 * @returns axes — The number of axes available.
		 */
		getAxisCount(): number;
		/**
		 * Gets the number of buttons on the joystick.
		 *
		 * @returns buttons — The number of buttons available.
		 */
		getButtonCount(): number;
		/**
		 * Gets the number of hats on the joystick.
		 *
		 * @returns hats — How many hats the joystick has.
		 */
		getHatCount(): number;
		/**
		 * Gets the direction of an axis.
		 *
		 * @param axis The index of the axis to be checked.
		 *
		 * @returns direction — Current value of the axis.
		 */
		getAxis(axis: number): number;
		/**
		 * Gets the direction of each axis.
		 *
		 * @returns axisDir1 — Direction of axis1.
		 * @returns axisDir2 — Direction of axis2.
		 * @returns axisDirN — Direction of axisN.
		 */
		getAxes(): LuaMultiReturn<number[]>;
		/**
		 * Gets the direction of the Joystick's hat.
		 *
		 * @param hat The index of the hat to be checked.
		 *
		 * @returns direction — The direction the hat is pushed.
		 */
		getHat(hat: number): JoystickHat;
		/**
		 * Checks if a button on the Joystick is pressed.
		 *
		 * LÖVE 0.9.0 had a bug which required the button indices passed to Joystick:isDown to be 0-based instead of 1-based, for example button 1 would be 0 for this function. It was fixed in 0.9.1.
		 *
		 * @param buttons The index of a button to check.
		 *
		 * @returns anyDown — True if any supplied button is down, false if not.
		 */
		isDown(...buttons: number[]): boolean;
		/**
		 * Gets whether the Joystick is recognized as a gamepad. If this is the case, the Joystick's buttons and axes can be used in a standardized manner across different operating systems and joystick models via Joystick:getGamepadAxis, Joystick:isGamepadDown, love.gamepadpressed, and related functions.
		 *
		 * LÖVE automatically recognizes most popular controllers with a similar layout to the Xbox 360 controller as gamepads, but you can add more with love.joystick.setGamepadMapping.
		 *
		 * Overload details:
		 * 1. If the Joystick is recognized as a gamepad, the physical locations for the virtual gamepad axes and buttons correspond as closely as possible to the layout of a standard Xbox 360 controller.
		 *
		 * @returns isgamepad — True if the Joystick is recognized as a gamepad, false otherwise.
		 */
		isGamepad(): boolean;
		/**
		 * Checks if a virtual gamepad button on the Joystick is pressed. If the Joystick is not recognized as a Gamepad or isn't connected, then this function will always return false.
		 *
		 * @param buttons The gamepad button to check.
		 *
		 * @returns anyDown — True if any supplied button is down, false if not.
		 */
		isGamepadDown(...buttons: GamepadButton[]): boolean;
		/**
		 * Gets the direction of a virtual gamepad axis. If the Joystick isn't recognized as a gamepad or isn't connected, this function will always return 0.
		 *
		 * @param axis The virtual axis to be checked.
		 *
		 * @returns direction — Current value of the axis.
		 */
		getGamepadAxis(axis: GamepadAxis): number;
		/**
		 * Gets the button, axis or hat that a virtual gamepad input is bound to.
		 *
		 * Overload details:
		 * 1. Returns nil if the Joystick isn't recognized as a gamepad or the virtual gamepad axis is not bound to a Joystick input.
		 * 2. The physical locations for the virtual gamepad axes and buttons correspond as closely as possible to the layout of a standard Xbox 360 controller.
		 *
		 * @param input The virtual gamepad axis to get the binding for. Depending on the overload: The virtual gamepad button to get the binding for.
		 *
		 * @returns inputtype — The type of input the virtual gamepad axis is bound to. Depending on the overload: The type of input the virtual gamepad button is bound to.
		 * @returns inputindex — The index of the Joystick's button, axis or hat that the virtual gamepad axis is bound to. Depending on the overload: The index of the Joystick's button, axis or hat that the virtual gamepad button is bound to.
		 * @returns hatdirection — The direction of the hat, if the virtual gamepad axis is bound to a hat. nil otherwise. Depending on the overload: The direction of the hat, if the virtual gamepad button is bound to a hat. nil otherwise.
		 */
		getGamepadMapping(input: GamepadAxis | GamepadButton): LuaMultiReturn<[JoystickInputType, number, JoystickHat?]> | undefined;
		/**
		 * Gets the full gamepad mapping string of this Joystick, or nil if it's not recognized as a gamepad.
		 *
		 * The mapping string contains binding information used to map the Joystick's buttons an axes to the standard gamepad layout, and can be used later with love.joystick.loadGamepadMappings.
		 *
		 * @returns mappingstring — A string containing the Joystick's gamepad mappings, or nil if the Joystick is not recognized as a gamepad.
		 */
		getGamepadMappingString(): string | undefined;
		/**
		 * Gets whether the Joystick supports vibration.
		 *
		 * Overload details:
		 * 1. The very first call to this function may take more time than expected because SDL's Haptic / Force Feedback subsystem needs to be initialized.
		 *
		 * @returns supported — True if rumble / force feedback vibration is supported on this Joystick, false if not.
		 */
		isVibrationSupported(): boolean;
		/**
		 * Sets the vibration motor speeds on a Joystick with rumble support. Most common gamepads have this functionality, although not all drivers give proper support. Use Joystick:isVibrationSupported to check.
		 *

		 * @returns success — True if the vibration was successfully applied, false if not.
		 */
		setVibration(): boolean;
		/**
		 * Sets the vibration motor speeds on a Joystick with rumble support. Most common gamepads have this functionality, although not all drivers give proper support. Use Joystick:isVibrationSupported to check.
		 *

		 * @param left Strength of the left vibration motor on the Joystick. Must be in the range of 1.
		 * @param right Strength of the right vibration motor on the Joystick. Must be in the range of 1.
		 * @param duration The duration of the vibration in seconds. A negative value means infinite duration. (Default: -1.)
		 * @returns True if the vibration was successfully disabled, false if not.
		 */
		setVibration(left: number, right?: number, duration?: number): boolean;
		/**
		 * Gets the current vibration motor strengths on a Joystick with rumble support.
		 *
		 * @returns left — Current strength of the left vibration motor on the Joystick.
		 * @returns right — Current strength of the right vibration motor on the Joystick.
		 */
		getVibration(): LuaMultiReturn<[number, number]>;
		getConnectedIndex(): number | undefined;
	}
	/** @noSelf */
	/** Provides an interface to the user's joystick.
	 */
	interface JoystickModule {
		/**
		 * Gets a list of connected Joysticks.
		 *
		 * @returns joysticks — The list of currently connected Joysticks.
		 */
		getJoysticks(this: void): Joystick[];
		/**
		 * Gets the number of connected joysticks.
		 *
		 * @returns joystickcount — The number of connected joysticks.
		 */
		getJoystickCount(this: void): number;
		/**
		 * Binds a virtual gamepad input to a button, axis or hat for all Joysticks of a certain type. For example, if this function is used with a GUID returned by a Dualshock 3 controller in OS X, the binding will affect Joystick:getGamepadAxis and Joystick:isGamepadDown for ''all'' Dualshock 3 controllers used with the game when run in OS X.
		 *
		 * LÖVE includes built-in gamepad bindings for many common controllers. This function lets you change the bindings or add new ones for types of Joysticks which aren't recognized as gamepads by default.
		 *
		 * The virtual gamepad buttons and axes are designed around the Xbox 360 controller layout.
		 *

		 * @param guid The OS-dependent GUID for the type of Joystick the binding will affect.
		 * @param input The virtual gamepad button to bind.
		 * @param type The type of input to bind the virtual gamepad button to.
		 * @param index The index of the axis, button, or hat to bind the virtual gamepad button to.
		 * @returns success — Whether the virtual gamepad button was successfully bound.
		 */
		setGamepadMapping(this: void, guid: string, input: GamepadAxis | GamepadButton, type: "axis" | "button", index: number): boolean;
		/**
		 * Binds a virtual gamepad input to a button, axis or hat for all Joysticks of a certain type. For example, if this function is used with a GUID returned by a Dualshock 3 controller in OS X, the binding will affect Joystick:getGamepadAxis and Joystick:isGamepadDown for ''all'' Dualshock 3 controllers used with the game when run in OS X.
		 *
		 * LÖVE includes built-in gamepad bindings for many common controllers. This function lets you change the bindings or add new ones for types of Joysticks which aren't recognized as gamepads by default.
		 *
		 * The virtual gamepad buttons and axes are designed around the Xbox 360 controller layout.
		 *

		 * @param guid The OS-dependent GUID for the type of Joystick the binding will affect.
		 * @param input The virtual gamepad axis to bind.
		 * @param type The type of input to bind the virtual gamepad axis to.
		 * @param index The index of the axis, button, or hat to bind the virtual gamepad axis to.
		 * @param direction The direction of the hat, if the virtual gamepad axis will be bound to a hat. nil otherwise. (Default: nil.)
		 * @returns Whether the virtual gamepad axis was successfully bound.
		 */
		setGamepadMapping(this: void, guid: string, input: GamepadAxis | GamepadButton, type: "hat", index: number, direction: JoystickHat): boolean;
		/**
		 * Loads a gamepad mappings string or file created with love.joystick.saveGamepadMappings.
		 *
		 * It also recognizes any SDL gamecontroller mapping string, such as those created with Steam's Big Picture controller configure interface, or this nice database. If a new mapping is loaded for an already known controller GUID, the later version will overwrite the one currently loaded.
		 *
		 * Overload details:
		 * 1. Loads a gamepad mappings string from a file.
		 * 2. Loads a gamepad mappings string directly.
		 *
		 * @param mappingsOrFilename The filename to load the mappings string from. Depending on the overload: The mappings string to load.
		 */
		loadGamepadMappings(this: void, mappingsOrFilename: string): void;
		/**
		 * Saves the virtual gamepad mappings of all recognized as gamepads and have either been recently used or their gamepad bindings have been modified.
		 *
		 * The mappings are stored as a string for use with love.joystick.loadGamepadMappings.
		 *

		 * @returns mappings — The mappings string that was written to the file.
		 */
		saveGamepadMappings(this: void): string;
/**
 * Saves the virtual gamepad mappings of all recognized as gamepads and have either been recently used or their gamepad bindings have been modified.
 *
 * The mappings are stored as a string for use with love.joystick.loadGamepadMappings.
 *

 * @param filename The filename to save the mappings string to.
 * @returns The mappings string.
 */
		saveGamepadMappings(this: void, filename: string): string;
		/**
		 * Gets the full gamepad mapping string of the Joysticks which have the given GUID, or nil if the GUID isn't recognized as a gamepad.
		 *
		 * The mapping string contains binding information used to map the Joystick's buttons an axes to the standard gamepad layout, and can be used later with love.joystick.loadGamepadMappings.
		 *
		 * @param guid The GUID value to get the mapping string for.
		 *
		 * @returns mappingstring — A string containing the Joystick's gamepad mappings, or nil if the GUID is not recognized as a gamepad.
		 */
		getGamepadMappingString(this: void, guid: string): string | undefined;
	}

	/** @noSelf */
	/** Provides an interface to the user's clock.
	 */
	interface Timer {
		/**
		 * Measures the time between two frames.
		 *
		 * Calling this changes the return value of love.timer.getDelta.
		 *
		 * @returns dt — The time passed (in seconds).
		 */
		step(this: void): number;
		/**
		 * Returns the time between the last two frames.
		 *
		 * @returns dt — The time passed (in seconds).
		 */
		getDelta(this: void): number;
		/**
		 * Returns the current frames per second.
		 *
		 * @returns fps — The current FPS.
		 */
		getFPS(this: void): number;
		/**
		 * Returns the average delta time (seconds per frame) over the last second.
		 *
		 * @returns delta — The average delta time over the last second.
		 */
		getAverageDelta(this: void): number;
		/**
		 * Pauses the current thread for the specified amount of time.
		 *
		 * @param seconds Seconds to sleep for.
		 */
		sleep(this: void, seconds: number): void;
		/**
		 * Returns the value of a timer with an unspecified starting time.
		 *
		 * This function should only be used to calculate differences between points in time, as the starting time of the timer is unknown.
		 *
		 * @returns time — The time in seconds. Given as a decimal, accurate to the microsecond.
		 */
		getTime(this: void): number;
	}
	type OS = "OS X" | "Windows" | "Linux" | "Android" | "iOS" | "UWP" | "Unknown";
	type PowerState = "unknown" | "battery" | "nobattery" | "charging" | "charged";
	/** @noSelf */
	/** Provides access to information about the user's system.
	 */
	interface System {
		/**
		 * Gets the current operating system. In general, LÖVE abstracts away the need to know the current operating system, but there are a few cases where it can be useful (especially in combination with os.execute.)
		 *
		 * Overload details:
		 * 1. In LÖVE version 0.8.0, the '''love._os''' string contains the current operating system.
		 *
		 * @returns osString — The current operating system. 'OS X', 'Windows', 'Linux', 'Android' or 'iOS'.
		 */
		getOS(this: void): OS;
		/**
		 * Gets the amount of logical processor in the system.
		 *
		 * Overload details:
		 * 1. The number includes the threads reported if technologies such as Intel's Hyper-threading are enabled. For example, on a 4-core CPU with Hyper-threading, this function will return 8.
		 *
		 * @returns processorCount — Amount of logical processors.
		 */
		getProcessorCount(this: void): number;
		/**
		 * Puts text in the clipboard.
		 *
		 * @param text The new text to hold in the system's clipboard.
		 */
		setClipboardText(this: void, text: string): void;
		/**
		 * Gets text from the clipboard.
		 *
		 * @returns text — The text currently held in the system's clipboard.
		 */
		getClipboardText(this: void): string;
		/**
		 * Gets information about the system's power supply.
		 *
		 * @returns state — The basic state of the power supply.
		 * @returns percent — Percentage of battery life left, between 0 and 100. nil if the value can't be determined or there's no battery.
		 * @returns seconds — Seconds of battery life left. nil if the value can't be determined or there's no battery.
		 */
		getPowerInfo(this: void): LuaMultiReturn<[PowerState, number | undefined, number | undefined]>;
		/** Embedded LoveNode permits only http, https, and mailto schemes. */
		/**
		 * Opens a URL with the user's web or file browser.
		 *
		 * Overload details:
		 * 1. Passing file:// scheme in Android 7.0 (Nougat) and later always result in failure. Prior to 11.2, this will crash LÖVE instead of returning false.
		 *
		 * @param url The URL to open. Must be formatted as a proper URL.
		 *
		 * @returns success — Whether the URL was opened successfully.
		 */
		openURL(this: void, url: string): boolean;
		/**
		 * Causes the device to vibrate, if possible. Currently this will only work on Android and iOS devices that have a built-in vibration motor.
		 *
		 * @param seconds The duration to vibrate for. If called on an iOS device, it will always vibrate for 0.5 seconds due to limitations in the iOS system APIs. (Default: 0.5.)
		 */
		vibrate(this: void, seconds?: number): void;
		/**
		 * Gets whether another application on the system is playing music in the background.
		 *
		 * Currently this is implemented on iOS and Android, and will always return false on other operating systems. The t.audio.mixwithsystem flag in love.conf can be used to configure whether background audio / music from other apps should play while LÖVE is open.
		 *
		 * @returns backgroundmusic — True if the user is playing music in the background via another app, false otherwise.
		 */
		hasBackgroundMusic(this: void): boolean;
	}

	type ThreadValue = boolean | number | string | Data | Channel | ThreadValue[] | {[key: string]: ThreadValue} | undefined;
	/** A Thread is a chunk of code that can run in parallel with other threads. Data can be sent between different threads with Channel objects.
	 */
	interface Thread extends Object {
		/**
		 * Gets the type of the object as a string.
		 *
		 * @returns type — The type as a string.
		 */
		type(): "Thread";
		/**
		 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 *
		 * @param typeName The name of the type to check for.
		 *
		 * @returns b — True if the object is of the specified type, false otherwise.
		 */
		typeOf(typeName: string): boolean;
		/**
		 * Starts the thread.
		 *
		 * Beginning with version 0.9.0, threads can be restarted after they have completed their execution.
		 *
		 * Overload details:
		 * 1. Arguments passed to Thread:start are accessible in the thread's main file via '''...''' (the vararg expression.)
		 *
		 * @param args A string, number, boolean, LÖVE object, or simple table.
		 */
		start(...args: ThreadValue[]): boolean;
		/**
		 * Wait for a thread to finish.
		 *
		 * This call will block until the thread finishes.
		 */
		wait(): void;
		/**
		 * Retrieves the error string from the thread if it produced an error.
		 *
		 * @returns err — The error message, or nil if the Thread has not caused an error.
		 */
		getError(): string | undefined;
		/**
		 * Returns whether the thread is currently running.
		 *
		 * Threads which are not running can be (re)started with Thread:start.
		 *
		 * @returns value — True if the thread is running, false otherwise.
		 */
		isRunning(): boolean;
	}
	/** An object which can be used to send and receive data between different threads.
	 */
	interface Channel extends Object {
		/**
		 * Gets the type of the object as a string.
		 *
		 * @returns type — The type as a string.
		 */
		type(): "Channel";
		/**
		 * Checks whether an object is of a certain type. If the object has the type with the specified name in its hierarchy, this function will return true.
		 *
		 * @param typeName The name of the type to check for.
		 *
		 * @returns b — True if the object is of the specified type, false otherwise.
		 */
		typeOf(typeName: string): boolean;
		/**
		 * Send a message to the thread Channel.
		 *
		 * See Variant for the list of supported types.
		 *
		 * @param value The contents of the message.
		 *
		 * @returns id — Identifier which can be supplied to Channel:hasRead
		 */
		push(value: ThreadValue): number;
		/**
		 * Send a message to the thread Channel and wait for a thread to accept it.
		 *
		 * See Variant for the list of supported types.
		 *
		 * @param value The contents of the message.
		 * @param timeout The maximum amount of time to wait.
		 *
		 * @returns success — Whether the message was successfully supplied (always true). Depending on the overload: Whether the message was successfully supplied before the timeout expired.
		 */
		supply(value: ThreadValue, timeout?: number): boolean;
		/**
		 * Retrieves the value of a Channel message and removes it from the message queue.
		 *
		 * It returns nil if there are no messages in the queue.
		 *
		 * @returns value — The contents of the message.
		 */
		pop(): ThreadValue;
		/**
		 * Retrieves the value of a Channel message and removes it from the message queue.
		 *
		 * It waits until a message is in the queue then returns the message value.
		 *
		 * @param timeout The maximum amount of time to wait.
		 *
		 * @returns value — The contents of the message. Depending on the overload: The contents of the message or nil if the timeout expired.
		 */
		demand(timeout?: number): ThreadValue;
		/**
		 * Retrieves the value of a Channel message, but leaves it in the queue.
		 *
		 * It returns nil if there's no message in the queue.
		 *
		 * @returns value — The contents of the message.
		 */
		peek(): ThreadValue;
		/**
		 * Retrieves the number of messages in the thread Channel queue.
		 *
		 * @returns count — The number of messages in the queue.
		 */
		getCount(): number;
		/**
		 * Gets whether a pushed value has been popped or otherwise removed from the Channel.
		 *
		 * @param id An id value previously returned by Channel:push.
		 *
		 * @returns hasread — Whether the value represented by the id has been removed from the Channel via Channel:pop, Channel:demand, or Channel:clear.
		 */
		hasRead(id: number): boolean;
		/**
		 * Clears all the messages in the Channel queue.
		 */
		clear(): void;
		/**
		 * Executes the specified function atomically with respect to this Channel.
		 *
		 * Calling multiple methods in a row on the same Channel is often useful. However if multiple Threads are calling this Channel's methods at the same time, the different calls on each Thread might end up interleaved (e.g. one or more of the second thread's calls may happen in between the first thread's calls.)
		 *
		 * This method avoids that issue by making sure the Thread calling the method has exclusive access to the Channel until the specified function has returned.
		 *
		 * @param callback The function to call, the form of function(channel, arg1, arg2, ...) end. The Channel is passed as the first argument to the function when it is called.
		 * @param args Additional arguments that the given function will receive when it is called.
		 *
		 * @returns ret1 — The first return value of the given function (if any.)
		 * @returns ... — Any other return values.
		 */
		performAtomic(callback: (channel: Channel, ...args: any[]) => any, ...args: any[]): any;
	}
	/** @noSelf */
	/** Allows you to work with threads.
	 */
	interface ThreadModule {
		/**
		 * Creates a new Thread from a filename, string or FileData object containing Lua code.
		 *
		 * @param codeOrFilename The name of the Lua file to use as the source. Depending on the overload: The FileData containing the Lua code to use as the source. Depending on the overload: A string containing the Lua code to use as the source. It needs to either be at least 1024 characters long, or contain at least one newline.
		 *
		 * @returns thread — A new Thread that has yet to be started.
		 */
		newThread(this: void, codeOrFilename: string | Data | File): Thread;
		/**
		 * Create a new unnamed thread channel.
		 *
		 * One use for them is to pass new unnamed channels to other threads via Channel:push on a named channel.
		 *
		 * @returns channel — The new Channel object.
		 */
		newChannel(this: void): Channel;
		/**
		 * Creates or retrieves a named thread channel.
		 *
		 * @param name The name of the channel you want to create or retrieve.
		 *
		 * @returns channel — The Channel object associated with the name.
		 */
		getChannel(this: void, name: string): Channel;
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
	 */
	interface Source extends Object {
		/**
		 * Creates an identical copy of the Source in the stopped state.
		 *
		 * Static Sources will use significantly less memory and take much less time to be created if Source:clone is used to create them instead of love.audio.newSource, so this method should be preferred when making multiple Sources which play the same sound.
		 *
		 * Overload details:
		 * 1. Cloned Sources inherit all the set-able state of the original Source, but they are initialized stopped.
		 *
		 * @returns source — The new identical copy of this Source.
		 */
		clone(): Source;
		/**
		 * Starts playing the Source.
		 *
		 * @returns success — Whether the Source was able to successfully start playing.
		 */
		play(): boolean;
		/**
		 * Pauses the Source.
		 */
		pause(): void;
		/**
		 * Stops a Source.
		 */
		stop(): void;
		/**
		 * Returns whether the Source is playing.
		 *
		 * @returns playing — True if the Source is playing, false otherwise.
		 */
		isPlaying(): boolean;
		/**
		 * Returns whether this Source is stopped. Deprecated compatibility alias for checking that it is neither playing nor paused.
		 *
		 * @deprecated Use `not source:isPlaying()` together with `not source:isPaused()` in Lua.
		 */
		isStopped(): boolean;
		isPaused(): boolean;
		/**
		 * Sets whether the Source should loop.
		 *
		 * @param looping True if the source should loop, false otherwise.
		 */
		setLooping(looping: boolean): void;
		/**
		 * Returns whether the Source will loop.
		 *
		 * @returns loop — True if the Source will loop, false otherwise.
		 */
		isLooping(): boolean;
		/**
		 * Sets the current volume of the Source.
		 *
		 * @param volume The volume for a Source, where 1.0 is normal volume. Volume cannot be raised above 1.0.
		 */
		setVolume(volume: number): void;
		/**
		 * Gets the current volume of the Source.
		 *
		 * @returns volume — The volume of the Source, where 1.0 is normal volume.
		 */
		getVolume(): number;
		/**
		 * Sets the pitch of the Source.
		 *
		 * @param pitch Calculated with regard to 1 being the base pitch. Each reduction by 50 percent equals a pitch shift of -12 semitones (one octave reduction). Each doubling equals a pitch shift of 12 semitones (one octave increase). Zero is not a legal value.
		 */
		setPitch(pitch: number): void;
		/**
		 * Gets the current pitch of the Source.
		 *
		 * @returns pitch — The pitch, where 1.0 is normal.
		 */
		getPitch(): number;
		/**
		 * Sets the currently playing position of the Source.
		 *
		 * @param offset The position to seek to.
		 * @param unit The unit of the position value. (Default: 'seconds'.)
		 */
		seek(offset: number, unit?: TimeUnit): void;
		/**
		 * Gets the currently playing position of the Source.
		 *
		 * @param unit The type of unit for the return value. (Default: 'seconds'.)
		 *
		 * @returns position — The currently playing position of the Source.
		 */
		tell(unit?: TimeUnit): number;
		/**
		 * Gets the duration of the Source. For streaming Sources it may not always be sample-accurate, and may return -1 if the duration cannot be determined at all.
		 *
		 * @param unit The time unit for the return value. (Default: 'seconds'.)
		 *
		 * @returns duration — The duration of the Source, or -1 if it cannot be determined.
		 */
		getDuration(unit?: TimeUnit): number;
		/**
		 * Gets the number of channels in the Source. Only 1-channel (mono) Sources can use directional and positional effects.
		 *
		 * @returns channels — 1 for mono, 2 for stereo.
		 */
		getChannelCount(): number;
		/** Deprecated Love alias for getChannelCount. */
		getChannels(): number;
		/**
		 * Gets the number of free buffer slots in a queueable Source. If the queueable Source is playing, this value will increase up to the amount the Source was created with. If the queueable Source is stopped, it will process all of its internal buffers first, in which case this function will always return the amount it was created with.
		 *
		 * @returns buffers — How many more SoundData objects can be queued up.
		 */
		getFreeBufferCount(): number;
		/**
		 * Queues SoundData for playback in a queueable Source.
		 *
		 * This method requires the Source to be created via love.audio.newQueueableSource.
		 *

		 * @param data The data to queue. The SoundData's sample rate, bit depth, and channel count must match the Source's.
		 * @param length The number of bytes to queue. (Default: all remaining data.)
		 * @returns success — True if the data was successfully queued for playback, false if there were no available buffers to use for queueing.
		 */
		queue(data: SoundData, length?: number): boolean;
		/**
		 * Queues SoundData for playback in a queueable Source.
		 *
		 * This method requires the Source to be created via love.audio.newQueueableSource.
		 *

		 * @param data The data to queue. The SoundData's sample rate, bit depth, and channel count must match the Source's.
		 * @param offset The byte offset at which to start queueing data.
		 * @param length The number of bytes to queue.
		 * @returns success — True if the data was successfully queued for playback, false if there were no available buffers to use for queueing.
		 */
		queue(data: SoundData, offset: number, length: number): boolean;
		/**
		 * Sets the position of the Source. Please note that this only works for mono (i.e. non-stereo) sound files!
		 *
		 * @param x The X position of the Source.
		 * @param y The Y position of the Source.
		 * @param z The Z position of the Source.
		 */
		setPosition(x: number, y: number, z?: number): void;
		/**
		 * Gets the position of the Source.
		 *
		 * @returns x — The X position of the Source.
		 * @returns y — The Y position of the Source.
		 * @returns z — The Z position of the Source.
		 */
		getPosition(): LuaMultiReturn<[number, number, number]>;
		/**
		 * Sets the velocity of the Source.
		 *
		 * This does '''not''' change the position of the Source, but lets the application know how it has to calculate the doppler effect.
		 *
		 * @param x The X part of the velocity vector.
		 * @param y The Y part of the velocity vector.
		 * @param z The Z part of the velocity vector.
		 */
		setVelocity(x: number, y: number, z?: number): void;
		/**
		 * Gets the velocity of the Source.
		 *
		 * @returns x — The X part of the velocity vector.
		 * @returns y — The Y part of the velocity vector.
		 * @returns z — The Z part of the velocity vector.
		 */
		getVelocity(): LuaMultiReturn<[number, number, number]>;
		/**
		 * Sets the direction vector of the Source. A zero vector makes the source non-directional.
		 *
		 * @param x The X part of the direction vector.
		 * @param y The Y part of the direction vector.
		 * @param z The Z part of the direction vector.
		 */
		setDirection(x: number, y: number, z?: number): void;
		/**
		 * Gets the direction of the Source.
		 *
		 * @returns x — The X part of the direction vector.
		 * @returns y — The Y part of the direction vector.
		 * @returns z — The Z part of the direction vector.
		 */
		getDirection(): LuaMultiReturn<[number, number, number]>;
		/**
		 * Sets the Source's directional volume cones. Together with Source:setDirection, the cone angles allow for the Source's volume to vary depending on its direction.
		 *
		 * @param innerAngle The inner angle from the Source's direction, in radians. The Source will play at normal volume if the listener is inside the cone defined by this angle.
		 * @param outerAngle The outer angle from the Source's direction, in radians. The Source will play at a volume between the normal and outer volumes, if the listener is in between the cones defined by the inner and outer angles.
		 * @param outerVolume The Source's volume when the listener is outside both the inner and outer cone angles. (Default: 0.)
		 */
		setCone(innerAngle: number, outerAngle: number, outerVolume?: number, outerHighGain?: number): void;
		/**
		 * Gets the Source's directional volume cones. Together with Source:setDirection, the cone angles allow for the Source's volume to vary depending on its direction.
		 *
		 * @returns innerAngle — The inner angle from the Source's direction, in radians. The Source will play at normal volume if the listener is inside the cone defined by this angle.
		 * @returns outerAngle — The outer angle from the Source's direction, in radians. The Source will play at a volume between the normal and outer volumes, if the listener is in between the cones defined by the inner and outer angles.
		 * @returns outerVolume — The Source's volume when the listener is outside both the inner and outer cone angles.
		 */
		getCone(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Sets the amount of air absorption applied to the Source.
		 *
		 * By default the value is set to 0 which means that air absorption effects are disabled. A value of 1 will apply high frequency attenuation to the Source at a rate of 0.05 dB per meter.
		 *
		 * Air absorption can simulate sound transmission through foggy air, dry air, smoky atmosphere, etc. It can be used to simulate different atmospheric conditions within different locations in an area.
		 *
		 * Overload details:
		 * 1. Audio air absorption functionality is not supported on iOS.
		 *
		 * @param factor The amount of air absorption applied to the Source. Must be between 0 and 10.
		 */
		setAirAbsorption(factor: number): void;
		/**
		 * Gets the amount of air absorption applied to the Source.
		 *
		 * By default the value is set to 0 which means that air absorption effects are disabled. A value of 1 will apply high frequency attenuation to the Source at a rate of 0.05 dB per meter.
		 *
		 * Overload details:
		 * 1. Audio air absorption functionality is not supported on iOS.
		 *
		 * @returns amount — The amount of air absorption applied to the Source.
		 */
		getAirAbsorption(): number;
		/**
		 * Sets the volume limits of the source. The limits have to be numbers from 0 to 1.
		 *
		 * @param minVolume The minimum volume.
		 * @param maxVolume The maximum volume.
		 */
		setVolumeLimits(minVolume: number, maxVolume: number): void;
		/**
		 * Returns the volume limits of the source.
		 *
		 * @returns min — The minimum volume.
		 * @returns max — The maximum volume.
		 */
		getVolumeLimits(): LuaMultiReturn<[number, number]>;
		/**
		 * Sets whether the Source's position, velocity, direction, and cone angles are relative to the listener, or absolute.
		 *
		 * By default, all sources are absolute and therefore relative to the origin of love's coordinate system 0, 0. Only absolute sources are affected by the position of the listener. Please note that positional audio only works for mono (i.e. non-stereo) sources.
		 *
		 * @param relative True to make the position, velocity, direction and cone angles relative to the listener, false to make them absolute. (Default: false.)
		 */
		setRelative(relative: boolean): void;
		/**
		 * Gets whether the Source's position, velocity, direction, and cone angles are relative to the listener.
		 *
		 * @returns relative — True if the position, velocity, direction and cone angles are relative to the listener, false if they're absolute.
		 */
		isRelative(): boolean;
		/**
		 * Sets the reference and maximum attenuation distances of the Source. The parameters, combined with the current DistanceModel, affect how the Source's volume attenuates based on distance.
		 *
		 * Distance attenuation is only applicable to Sources based on mono (rather than stereo) audio.
		 *
		 * @param referenceDistance The new reference attenuation distance. If the current DistanceModel is clamped, this is the minimum attenuation distance.
		 * @param maxDistance The new maximum attenuation distance.
		 */
		setAttenuationDistances(referenceDistance: number, maxDistance: number): void;
		/**
		 * Gets the reference and maximum attenuation distances of the Source. The values, combined with the current DistanceModel, affect how the Source's volume attenuates based on distance from the listener.
		 *
		 * @returns ref — The current reference attenuation distance. If the current DistanceModel is clamped, this is the minimum distance before the Source is no longer attenuated.
		 * @returns max — The current maximum attenuation distance.
		 */
		getAttenuationDistances(): LuaMultiReturn<[number, number]>;
		/**
		 * Sets the rolloff factor which affects the strength of the used distance attenuation.
		 *
		 * Extended information and detailed formulas can be found in the chapter '3.4. Attenuation By Distance' of OpenAL 1.1 specification.
		 *
		 * @param rolloff The new rolloff factor.
		 */
		setRolloff(rolloff: number): void;
		/**
		 * Returns the rolloff factor of the source.
		 *
		 * @returns rolloff — The rolloff factor.
		 */
		getRolloff(): number;
		/**
		 * Sets a low-pass, high-pass, or band-pass filter to apply when playing the Source.
		 *

		 * @returns success — Whether the filter was successfully applied to the Source.
		 */
		setFilter(): boolean;
/**
 * Sets a low-pass, high-pass, or band-pass filter to apply when playing the Source.
 *

 * @param filter The filter settings to use for this Source, with the following fields:
 * @returns success — Whether the filter was successfully applied to the Source.
 */
		setFilter(filter: AudioFilterSettings): boolean;
		getFilter<T extends AudioFilterSettings>(target?: T): T | AudioFilterSettings | undefined;
		/**
		 * Applies an audio effect to the Source.
		 *
		 * The effect must have been previously defined using love.audio.setEffect.
		 *

		 * @param name The name of the effect previously set up with love.audio.setEffect.
		 * @returns success — Whether the effect was successfully applied to this Source.
		 */
		setEffect(name: string): boolean;
/**
 * Applies an audio effect to the Source.
 *
 * The effect must have been previously defined using love.audio.setEffect.
 *

 * @param name The name of the effect previously set up with love.audio.setEffect.
 * @param enabled Whether the effect should be enabled. Pass false to disable an active effect. (Default: true.)
 * @returns success — Whether the effect was successfully applied to this Source.
 */
		setEffect(name: string, enabled: boolean): boolean;
/**
 * Applies an audio effect to the Source.
 *
 * The effect must have been previously defined using love.audio.setEffect.
 *

 * @param name The name of the effect previously set up with love.audio.setEffect.
 * @param enabled The filter settings to apply prior to the effect, with the following fields:
 * @returns Whether the effect and filter were successfully applied to this Source.
 */
		setEffect(name: string, enabled: AudioFilterSettings): boolean;
		/**
		 * Gets the filter settings associated to a specific effect.
		 *
		 * This function returns nil if the effect was applied with no filter settings associated to it.
		 *
		 * @param name The name of the effect.
		 * @param target An optional empty table that will be filled with the filter settings. (Default: {}.)
		 *
		 * @returns filtersettings — The settings for the filter associated to this effect, or nil if the effect is not present in this Source or has no filter associated. The table has the following fields:
		 * @returns filtersettings.volume — The overall volume of the audio.
		 * @returns filtersettings.highgain — Volume of high-frequency audio. Only applies to low-pass and band-pass filters.
		 * @returns filtersettings.lowgain — Volume of low-frequency audio. Only applies to high-pass and band-pass filters.
		 */
		getEffect(name: string, target?: AudioFilterSettings): LuaMultiReturn<[boolean, AudioFilterSettings?]>;
		/**
		 * Gets a list of the Source's active effect names.
		 *
		 * @returns effects — A list of the source's active effect names.
		 */
		getActiveEffects(): string[];
		/**
		 * Gets the type of the Source.
		 *
		 * @returns sourcetype — The type of the source.
		 */
		getType(): SourceType;
	}
	/** Represents an audio input device capable of recording sounds.
	 */
	interface RecordingDevice extends Object {
		/**
		 * Begins recording audio using this device.
		 *
		 * Overload details:
		 * 1. A ring buffer is used internally to store recorded data before RecordingDevice:getData or RecordingDevice:stop are called – the former clears the buffer. If the buffer completely fills up before getData or stop are called, the oldest data that doesn't fit into the buffer will be lost.
		 *
		 * @param samples The maximum number of samples to store in an internal ring buffer when recording. RecordingDevice:getData clears the internal buffer when called.
		 * @param sampleRate The number of samples per second to store when recording. (Default: 8000.)
		 * @param bitDepth The number of bits per sample. (Default: 16.)
		 * @param channels Whether to record in mono or stereo. Most microphones don't support more than 1 channel. (Default: 1.)
		 *
		 * @returns success — True if the device successfully began recording using the specified parameters, false if not.
		 */
		start(samples?: number, sampleRate?: number, bitDepth?: 8 | 16, channels?: 1 | 2): boolean;
		/** Stops recording and returns any buffered samples. */
		/**
		 * Stops recording audio from this device. Any sound data currently in the device's buffer will be returned.
		 *
		 * @returns data — The sound data currently in the device's buffer, or nil if the device wasn't recording.
		 */
		stop(): SoundData | undefined;
		/** Returns and consumes the samples currently buffered by this device. */
		/**
		 * Gets all recorded audio SoundData stored in the device's internal ring buffer.
		 *
		 * The internal ring buffer is cleared when this function is called, so calling it again will only get audio recorded after the previous call. If the device's internal ring buffer completely fills up before getData is called, the oldest data that doesn't fit into the buffer will be lost.
		 *
		 * @returns data — The recorded audio data, or nil if the device isn't recording.
		 */
		getData(): SoundData | undefined;
		/**
		 * Gets the number of currently recorded samples.
		 *
		 * @returns samples — The number of samples that have been recorded so far.
		 */
		getSampleCount(): number;
		/**
		 * Gets the number of samples per second currently being recorded.
		 *
		 * @returns rate — The number of samples being recorded per second (sample rate).
		 */
		getSampleRate(): number;
		/**
		 * Gets the number of bits per sample in the data currently being recorded.
		 *
		 * @returns bits — The number of bits per sample in the data that's currently being recorded.
		 */
		getBitDepth(): 8 | 16;
		/**
		 * Gets the number of channels currently being recorded (mono or stereo).
		 *
		 * @returns channels — The number of channels being recorded (1 for mono, 2 for stereo).
		 */
		getChannelCount(): 1 | 2;
		/**
		 * Gets the name of the recording device.
		 *
		 * @returns name — The name of the device.
		 */
		getName(): string;
		/**
		 * Gets whether the device is currently recording.
		 *
		 * @returns recording — True if the recording, false otherwise.
		 */
		isRecording(): boolean;
	}
	/** @noSelf */
	/** Provides an interface to create noise with the user's speakers.
	 */
	interface Audio {
		/**
		 * Creates a new Source from a filepath, File, Decoder or SoundData.
		 *
		 * Sources created from SoundData are always static.
		 *

		 * @param filename The filepath to the audio file.
		 * @param sourceType Streaming or static source.
		 * @returns source — A new Source that can play the specified audio.
		 */
		newSource(this: void, filename: string, sourceType?: "static" | "stream"): Source;
		/**
		 * Creates a new Source from a filepath, File, Decoder or SoundData.
		 *
		 * Sources created from SoundData are always static.
		 *

		 * @param data The SoundData to create a Source from.
		 * @returns A new Source that can play the specified audio. The SourceType of the returned audio is 'static'.
		 */
		newSource(this: void, data: SoundData): Source;
		/**
		 * Creates a new Source usable for real-time generated sound playback with Source:queue.
		 *
		 * Overload details:
		 * 1. The sample rate, bit depth, and channel count of any SoundData used with Source:queue must match the parameters given to this constructor.
		 *
		 * @param samplerate Number of samples per second when playing.
		 * @param bitdepth Bits per sample (8 or 16).
		 * @param channels 1 for mono or 2 for stereo.
		 * @param buffercount The number of buffers that can be queued up at any given time with Source:queue. Cannot be greater than 64. A sensible default (~8) is chosen if no value is specified. (Default: 0.)
		 *
		 * @returns source — The new Source usable with Source:queue.
		 */
		newQueueableSource(sampleRate: number, bitDepth: 8 | 16,
			channels: 1 | 2, buffers?: number): Source;
		/**
		 * Starts playing all Sources contained in an array simultaneously.
		 *

		 * @param sources An array containing the Sources to play.
		 * @returns Whether all specified Sources were successfully started.
		 */
		play(this: void, sources: Source[]): boolean;
		/**
		 * Starts playing all supplied Sources simultaneously.
		 *

		 * @param sources The Sources to play.
		 * @returns Whether all specified Sources were successfully started.
		 */
		play(this: void, ...sources: Source[]): boolean;
		/**
		 * Pauses all currently active Sources and returns them.
		 *

		 * @returns Sources — A table containing a list of Sources that were paused by this call.
		 */
		pause(this: void): Source[];
		/**
		 * Pauses all Sources contained in an array.
		 *

		 * @param sources An array containing the Sources to pause.
		 */
		pause(this: void, sources: Source[]): void;
		/**
		 * Pauses all supplied Sources.
		 *

		 * @param sources The Sources to pause.
		 */
		pause(this: void, ...sources: Source[]): void;
		/**
		 * Stops all currently active Sources.
		 *
		 */
		stop(this: void): void;
		/**
		 * Stops all Sources contained in an array.
		 *

		 * @param sources An array containing the Sources to stop.
		 */
		stop(this: void, sources: Source[]): void;
		/**
		 * Stops all supplied Sources simultaneously.
		 *

		 * @param sources The Sources to stop.
		 */
		stop(this: void, ...sources: Source[]): void;
		/**
		 * Gets the current number of simultaneously playing sources.
		 *
		 * @returns count — The current number of simultaneously playing sources.
		 */
		getActiveSourceCount(this: void): number;
		/** Deprecated Love alias for getActiveSourceCount. */
		getSourceCount(this: void): number;
		/**
		 * Sets the master volume.
		 *
		 * @param volume 1.0 is max and 0.0 is off.
		 */
		setVolume(this: void, volume: number): void;
		/**
		 * Returns the master volume.
		 *
		 * @returns volume — The current master volume
		 */
		getVolume(this: void): number;
		/** Sets the application-global iOS audio session mixing policy. Other platforms return false. */
		/**
		 * Sets whether the system should mix the audio with the system's audio.
		 *
		 * @param mix True to enable mixing, false to disable it.
		 *
		 * @returns success — True if the change succeeded, false otherwise.
		 */
		setMixWithSystem(this: void, mix: boolean): boolean;
		/** Sets the Dora application-global listener position shared by all LoveNode instances. */
		/**
		 * Sets the position of the listener, which determines how sounds play.
		 *
		 * @param x The x position of the listener.
		 * @param y The y position of the listener.
		 * @param z The z position of the listener.
		 */
		setPosition(this: void, x: number, y: number, z?: number): void;
		/**
		 * Returns the position of the listener. Please note that positional audio only works for mono (i.e. non-stereo) sources.
		 *
		 * @returns x — The X position of the listener.
		 * @returns y — The Y position of the listener.
		 * @returns z — The Z position of the listener.
		 */
		getPosition(this: void): LuaMultiReturn<[number, number, number]>;
		/** Sets the Dora application-global listener forward and up vectors. */
		/**
		 * Sets the orientation of the listener.
		 *
		 * @param fx, fy, fz Forward vector of the listener orientation.
		 * @param ux, uy, uz Up vector of the listener orientation.
		 */
		setOrientation(forwardX: number, forwardY: number, forwardZ: number,
			upX: number, upY: number, upZ: number): void;
		/**
		 * Returns the orientation of the listener.
		 *
		 * @returns fx — Forward x of the listener orientation.
		 * @returns fy — Forward y of the listener orientation.
		 * @returns fz — Forward z of the listener orientation.
		 * @returns ux — Up x of the listener orientation.
		 * @returns uy — Up y of the listener orientation.
		 * @returns uz — Up z of the listener orientation.
		 */
		getOrientation(this: void): LuaMultiReturn<[number, number, number, number, number, number]>;
		/** Sets the Dora application-global listener velocity shared by all LoveNode instances. */
		/**
		 * Sets the velocity of the listener.
		 *
		 * @param x The X velocity of the listener.
		 * @param y The Y velocity of the listener.
		 * @param z The Z velocity of the listener.
		 */
		setVelocity(this: void, x: number, y: number, z?: number): void;
		/**
		 * Returns the velocity of the listener.
		 *
		 * @returns x — The X velocity of the listener.
		 * @returns y — The Y velocity of the listener.
		 * @returns z — The Z velocity of the listener.
		 */
		getVelocity(this: void): LuaMultiReturn<[number, number, number]>;
		/** Sets the Dora application-global Doppler scale shared by all LoveNode instances. */
		/**
		 * Sets a global scale factor for velocity-based doppler effects. The default scale value is 1.
		 *
		 * @param scale The new doppler scale factor. The scale must be greater than 0.
		 */
		setDopplerScale(this: void, scale: number): void;
		/**
		 * Gets the current global scale factor for velocity-based doppler effects.
		 *
		 * @returns scale — The current doppler scale factor.
		 */
		getDopplerScale(this: void): number;
		/** Sets the Dora application-global distance attenuation model. */
		/**
		 * Sets the distance attenuation model.
		 *
		 * @param model The new distance model.
		 */
		setDistanceModel(this: void, model: DistanceModel): void;
		/**
		 * Returns the distance attenuation model.
		 *
		 * @returns model — The current distance model. The default is 'inverseclamped'.
		 */
		getDistanceModel(this: void): DistanceModel;
		/**
		 * Defines an effect that can be applied to a Source.
		 *
		 * Not all system supports audio effects. Use love.audio.isEffectsSupported to check.
		 *
		 * @param name The name of the effect.
		 * @param settings The settings to use for this effect, with the following fields:
		 * @param settings.type The type of effect to use.
		 * @param settings.volume The volume of the effect.
		 * @param settings.... Effect-specific settings. See EffectType for available effects and their corresponding settings.
		 *
		 * @returns success — Whether the effect was successfully created. Depending on the overload: Whether the effect was successfully disabled.
		 */
		setEffect(this: void, name: string, settings?: AudioEffectSettings | false): boolean;
		getEffect<T extends AudioEffectSettings>(name: string, target?: T): T | AudioEffectSettings | undefined;
		/**
		 * Gets a list of the names of the currently enabled effects.
		 *
		 * @returns effects — The list of the names of the currently enabled effects.
		 */
		getActiveEffects(this: void): string[];
		/**
		 * Gets the maximum number of active effects supported by the system.
		 *
		 * @returns maximum — The maximum number of active effects.
		 */
		getMaxSceneEffects(this: void): number;
		/**
		 * Gets the maximum number of active Effects in a single Source object, that the system can support.
		 *
		 * Overload details:
		 * 1. This function return 0 for system that doesn't support audio effects.
		 *
		 * @returns maximum — The maximum number of active Effects per Source.
		 */
		getMaxSourceEffects(this: void): number;
		/**
		 * Gets a list of RecordingDevices on the system.
		 *
		 * The first device in the list is the user's default recording device. The list may be empty if there are no microphones connected to the system.
		 *
		 * Audio recording is currently not supported on iOS.
		 *
		 * Overload details:
		 * 1. Audio recording for Android is supported since 11.3. However, it's not supported when APK from Play Store is used.
		 *
		 * @returns devices — The list of connected recording devices.
		 */
		getRecordingDevices(this: void): RecordingDevice[];
		/**
		 * Gets whether audio effects are supported in the system.
		 *
		 * Overload details:
		 * 1. Older Linux distributions that ship with older OpenAL library may not support audio effects. Furthermore, iOS doesn't support audio effects at all.
		 *
		 * @returns supported — True if effects are supported, false otherwise.
		 */
		isEffectsSupported(this: void): boolean;
	}
	type BodyType = "static" | "dynamic" | "kinematic";
	type ContactCallback = (fixtureA: Fixture, fixtureB: Fixture, contact: Contact) => void;
	type PostSolveCallback = (fixtureA: Fixture, fixtureB: Fixture, contact: Contact,
		...impulses: number[]) => void;
	/** Contacts are objects created to manage collisions in worlds.
	 */
	interface Contact extends Object {
		isValid(): boolean;
		/**
		 * Gets the two Fixtures that hold the shapes that are in contact.
		 *
		 * @returns fixtureA — The first Fixture.
		 * @returns fixtureB — The second Fixture.
		 */
		getFixtures(): LuaMultiReturn<[Fixture, Fixture]>;
		/**
		 * Gets the child indices of the shapes of the two colliding fixtures. For ChainShapes, an index of 1 is the first edge in the chain.
		 * Used together with Fixture:rayCast or ChainShape:getChildEdge.
		 *
		 * @returns indexA — The child index of the first fixture's shape.
		 * @returns indexB — The child index of the second fixture's shape.
		 */
		getChildren(): LuaMultiReturn<[number, number]>;
		/**
		 * Returns the contact points of the two colliding fixtures. There can be one or two points.
		 *
		 * @returns x1 — The x coordinate of the first contact point.
		 * @returns y1 — The y coordinate of the first contact point.
		 * @returns x2 — The x coordinate of the second contact point.
		 * @returns y2 — The y coordinate of the second contact point.
		 */
		getPositions(): LuaMultiReturn<number[]>;
		/**
		 * Get the normal vector between two shapes that are in contact.
		 *
		 * This function returns the coordinates of a unit vector that points from the first shape to the second.
		 *
		 * @returns nx — The x component of the normal vector.
		 * @returns ny — The y component of the normal vector.
		 */
		getNormal(): LuaMultiReturn<[number, number]>;
		/**
		 * Get the friction between two shapes that are in contact.
		 *
		 * @returns friction — The friction of the contact.
		 */
		getFriction(): number;
		/**
		 * Sets the contact friction.
		 *
		 * @param friction The contact friction.
		 */
		setFriction(friction: number): void;
		/**
		 * Resets the contact friction to the mixture value of both fixtures.
		 */
		resetFriction(): void;
		/**
		 * Get the restitution between two shapes that are in contact.
		 *
		 * @returns restitution — The restitution between the two shapes.
		 */
		getRestitution(): number;
		/**
		 * Sets the contact restitution.
		 *
		 * @param restitution The contact restitution.
		 */
		setRestitution(restitution: number): void;
		/**
		 * Resets the contact restitution to the mixture value of both fixtures.
		 */
		resetRestitution(): void;
		/**
		 * Returns whether the contact is enabled. The collision will be ignored if a contact gets disabled in the preSolve callback.
		 *
		 * @returns enabled — True if enabled, false otherwise.
		 */
		isEnabled(): boolean;
		/**
		 * Enables or disables the contact.
		 *
		 * @param enabled True to enable or false to disable.
		 */
		setEnabled(enabled: boolean): void;
		/**
		 * Returns whether the two colliding fixtures are touching each other.
		 *
		 * @returns touching — True if they touch or false if not.
		 */
		isTouching(): boolean;
		getTangentSpeed(): number;
		setTangentSpeed(speed: number): void;
	}
	/** A world is an object that contains all bodies and joints.
	 */
	interface World extends Object {
		/**
		 * Destroys the world, taking all bodies, joints, fixtures and their shapes with it.
		 *
		 * An error will occur if you attempt to use any of the destroyed objects after calling this function.
		 */
		destroy(): void;
		/**
		 * Gets whether the World is destroyed. Destroyed worlds cannot be used.
		 *
		 * @returns destroyed — Whether the World is destroyed.
		 */
		isDestroyed(): boolean;
		/** Returns all bodies in the world. */
		getBodies(): Body[];
		/**
		 * Update the state of the world.
		 *
		 * @param deltaTime The time (in seconds) to advance the physics simulation.
		 * @param velocityIterations The maximum number of steps used to determine the new velocities when resolving a collision. (Default: 8.)
		 * @param positionIterations The maximum number of steps used to determine the new positions when resolving a collision. (Default: 3.)
		 */
		update(deltaTime: number, velocityIterations?: number, positionIterations?: number): void;
		/**
		 * Set the gravity of the world.
		 *
		 * @param x The x component of gravity.
		 * @param y The y component of gravity.
		 */
		setGravity(x: number, y: number): void;
		/**
		 * Get the gravity of the world.
		 *
		 * @returns x — The x component of gravity.
		 * @returns y — The y component of gravity.
		 */
		getGravity(): LuaMultiReturn<[number, number]>;
		/**
		 * Sets the sleep behaviour of the world.
		 *
		 * @param allowed True if bodies in the world are allowed to sleep, or false if not.
		 */
		setSleepingAllowed(allowed: boolean): void;
		/**
		 * Gets the sleep behaviour of the world.
		 *
		 * @returns allow — True if bodies in the world are allowed to sleep, or false if not.
		 */
		isSleepingAllowed(): boolean;
		/**
		 * Calls a function for each fixture inside the specified area by searching for any overlapping bounding box (Fixture:getBoundingBox).
		 *
		 * @param topLeftX The x position of the top-left point.
		 * @param topLeftY The y position of the top-left point.
		 * @param bottomRightX The x position of the bottom-right point.
		 * @param bottomRightY The y position of the bottom-right point.
		 * @param callback This function gets passed one argument, the fixture, and should return a boolean. The search will continue if it is true or stop if it is false.
		 */
		queryBoundingBox(x1: number, y1: number, x2: number, y2: number,
			callback: (fixture: Fixture) => boolean): void;
		/**
		 * Casts a ray and calls a function for each fixtures it intersects.
		 *
		 * Overload details:
		 * 1. There is a bug in LÖVE 0.8.0 where the normal vector passed to the callback function gets scaled by love.physics.getMeter.
		 *
		 * @param x1 The x position of the starting point of the ray.
		 * @param y1 The x position of the starting point of the ray.
		 * @param x2 The x position of the end point of the ray.
		 * @param y2 The x value of the surface normal vector of the shape edge.
		 * @param callback A function called for each fixture intersected by the ray. The function gets six arguments and should return a number as a control value. The intersection points fed into the function will be in an arbitrary order. If you wish to find the closest point of intersection, you'll need to do that yourself within the function. The easiest way to do that is by using the fraction value.
		 */
		rayCast(x1: number, y1: number, x2: number, y2: number,
			callback: (fixture: Fixture, x: number, y: number,
				normalX: number, normalY: number, fraction: number) => number): void;
		/**
		 * Sets functions for the collision callbacks during the world update.
		 *
		 * Four Lua functions can be given as arguments. The value nil removes a function.
		 *
		 * When called, each function will be passed three arguments. The first two arguments are the colliding fixtures and the third argument is the Contact between them. The postSolve callback additionally gets the normal and tangent impulse for each contact point. See notes.
		 *
		 * If you are interested to know when exactly each callback is called, consult a Box2d manual
		 *
		 * @param beginContact Gets called when two fixtures begin to overlap.
		 * @param endContact Gets called when two fixtures cease to overlap. This will also be called outside of a world update, when colliding objects are destroyed.
		 * @param preSolve Gets called before a collision gets resolved. (Default: nil.)
		 * @param postSolve Gets called after the collision has been resolved. (Default: nil.)
		 */
		setCallbacks(beginContact?: ContactCallback, endContact?: ContactCallback,
			preSolve?: ContactCallback, postSolve?: PostSolveCallback): void;
		/**
		 * Returns functions for the callbacks during the world update.
		 *
		 * @returns beginContact — Gets called when two fixtures begin to overlap.
		 * @returns endContact — Gets called when two fixtures cease to overlap.
		 * @returns preSolve — Gets called before a collision gets resolved.
		 * @returns postSolve — Gets called after the collision has been resolved.
		 */
		getCallbacks(): LuaMultiReturn<[ContactCallback | undefined, ContactCallback | undefined,
			ContactCallback | undefined, PostSolveCallback | undefined]>;
	}
	/** Bodies are objects with velocity and position.
	 */
	interface Body extends Object {
		/**
		 * Explicitly destroys the Body and all fixtures and joints attached to it.
		 *
		 * An error will occur if you attempt to use the object after calling this function. In 0.7.2, when you don't have time to wait for garbage collection, this function may be used to free the object immediately.
		 */
		destroy(): void;
		/**
		 * Gets whether the Body is destroyed. Destroyed bodies cannot be used.
		 *
		 * @returns destroyed — Whether the Body is destroyed.
		 */
		isDestroyed(): boolean;
		/**
		 * Get the position of the body.
		 *
		 * Note that this may not be the center of mass of the body.
		 *
		 * @returns x — The x position.
		 * @returns y — The y position.
		 */
		getPosition(): LuaMultiReturn<[number, number]>;
		/**
		 * Set the position of the body.
		 *
		 * Note that this may not be the center of mass of the body.
		 *
		 * This function cannot wake up the body.
		 *
		 * @param x The x position.
		 * @param y The y position.
		 */
		setPosition(x: number, y: number): void;
		/**
		 * Get the x position of the body in world coordinates.
		 *
		 * @returns x — The x position in world coordinates.
		 */
		getX(): number;
		/**
		 * Set the x position of the body.
		 *
		 * This function cannot wake up the body.
		 *
		 * @param x The x position.
		 */
		setX(x: number): void;
		/**
		 * Get the y position of the body in world coordinates.
		 *
		 * @returns y — The y position in world coordinates.
		 */
		getY(): number;
		/**
		 * Set the y position of the body.
		 *
		 * This function cannot wake up the body.
		 *
		 * @param y The y position.
		 */
		setY(y: number): void;
		/**
		 * Get the position and angle of the body.
		 *
		 * Note that the position may not be the center of mass of the body. An angle of 0 radians will mean 'looking to the right'. Although radians increase counter-clockwise, the y axis points down so it becomes clockwise from our point of view.
		 *
		 * @returns x — The x component of the position.
		 * @returns y — The y component of the position.
		 * @returns angle — The angle in radians.
		 */
		getTransform(): LuaMultiReturn<[number, number, number]>;
		/**
		 * Set the position and angle of the body.
		 *
		 * Note that the position may not be the center of mass of the body. An angle of 0 radians will mean 'looking to the right'. Although radians increase counter-clockwise, the y axis points down so it becomes clockwise from our point of view.
		 *
		 * This function cannot wake up the body.
		 *
		 * @param x The x component of the position.
		 * @param y The y component of the position.
		 * @param angle The angle in radians.
		 */
		setTransform(x: number, y: number, angle: number): void;
		/**
		 * Get the angle of the body.
		 *
		 * The angle is measured in radians. If you need to transform it to degrees, use math.deg.
		 *
		 * A value of 0 radians will mean 'looking to the right'. Although radians increase counter-clockwise, the y axis points down so it becomes ''clockwise'' from our point of view.
		 *
		 * @returns angle — The angle in radians.
		 */
		getAngle(): number;
		/**
		 * Set the angle of the body.
		 *
		 * The angle is measured in radians. If you need to transform it from degrees, use math.rad.
		 *
		 * A value of 0 radians will mean 'looking to the right'. Although radians increase counter-clockwise, the y axis points down so it becomes ''clockwise'' from our point of view.
		 *
		 * It is possible to cause a collision with another body by changing its angle.
		 *
		 * @param angle The angle in radians.
		 */
		setAngle(angle: number): void;
		/**
		 * Gets the linear velocity of the Body from its center of mass.
		 *
		 * The linear velocity is the ''rate of change of position over time''.
		 *
		 * If you need the ''rate of change of angle over time'', use Body:getAngularVelocity.
		 *
		 * If you need to get the linear velocity of a point different from the center of mass:
		 *
		 * * Body:getLinearVelocityFromLocalPoint allows you to specify the point in local coordinates.
		 *
		 * * Body:getLinearVelocityFromWorldPoint allows you to specify the point in world coordinates.
		 *
		 * See page 136 of 'Essential Mathematics for Games and Interactive Applications' for definitions of local and world coordinates.
		 *
		 * @returns x — The x-component of the velocity vector
		 * @returns y — The y-component of the velocity vector
		 */
		getLinearVelocity(): LuaMultiReturn<[number, number]>;
		/**
		 * Sets a new linear velocity for the Body.
		 *
		 * This function will not accumulate anything; any impulses previously applied since the last call to World:update will be lost.
		 *
		 * @param x The x-component of the velocity vector.
		 * @param y The y-component of the velocity vector.
		 */
		setLinearVelocity(x: number, y: number): void;
		/**
		 * Get the angular velocity of the Body.
		 *
		 * The angular velocity is the ''rate of change of angle over time''.
		 *
		 * It is changed in World:update by applying torques, off centre forces/impulses, and angular damping. It can be set directly with Body:setAngularVelocity.
		 *
		 * If you need the ''rate of change of position over time'', use Body:getLinearVelocity.
		 *
		 * @returns w — The angular velocity in radians/second.
		 */
		getAngularVelocity(): number;
		/**
		 * Sets the angular velocity of a Body.
		 *
		 * The angular velocity is the ''rate of change of angle over time''.
		 *
		 * This function will not accumulate anything; any impulses previously applied since the last call to World:update will be lost.
		 *
		 * @param velocity The new angular velocity, in radians per second
		 */
		setAngularVelocity(velocity: number): void;
		/**
		 * Gets the linear damping of the Body.
		 *
		 * The linear damping is the ''rate of decrease of the linear velocity over time''. A moving body with no damping and no external forces will continue moving indefinitely, as is the case in space. A moving body with damping will gradually stop moving.
		 *
		 * Damping is not the same as friction - they can be modelled together.
		 *
		 * @returns damping — The value of the linear damping.
		 */
		getLinearDamping(): number;
		/**
		 * Sets the linear damping of a Body
		 *
		 * See Body:getLinearDamping for a definition of linear damping.
		 *
		 * Linear damping can take any value from 0 to infinity. It is recommended to stay between 0 and 0.1, though. Other values will make the objects look 'floaty'(if gravity is enabled).
		 *
		 * @param damping The new linear damping
		 */
		setLinearDamping(damping: number): void;
		/**
		 * Gets the Angular damping of the Body
		 *
		 * The angular damping is the ''rate of decrease of the angular velocity over time'': A spinning body with no damping and no external forces will continue spinning indefinitely. A spinning body with damping will gradually stop spinning.
		 *
		 * Damping is not the same as friction - they can be modelled together. However, only damping is provided by Box2D (and LOVE).
		 *
		 * Damping parameters should be between 0 and infinity, with 0 meaning no damping, and infinity meaning full damping. Normally you will use a damping value between 0 and 0.1.
		 *
		 * @returns damping — The value of the angular damping.
		 */
		getAngularDamping(): number;
		/**
		 * Sets the angular damping of a Body
		 *
		 * See Body:getAngularDamping for a definition of angular damping.
		 *
		 * Angular damping can take any value from 0 to infinity. It is recommended to stay between 0 and 0.1, though. Other values will look unrealistic.
		 *
		 * @param damping The new angular damping.
		 */
		setAngularDamping(damping: number): void;
		/**
		 * Get the mass of the body.
		 *
		 * Static bodies always have a mass of 0.
		 *
		 * @returns mass — The mass of the body (in kilograms).
		 */
		getMass(): number;
		/**
		 * Sets a new body mass.
		 *
		 * @param mass The mass, in kilograms.
		 */
		setMass(mass: number): void;
		/**
		 * Gets the rotational inertia of the body.
		 *
		 * The rotational inertia is how hard is it to make the body spin.
		 *
		 * @returns inertia — The rotational inertial of the body.
		 */
		getInertia(): number;
		/**
		 * Set the inertia of a body.
		 *
		 * @param inertia The new moment of inertia, in kilograms * pixel squared.
		 */
		setInertia(inertia: number): void;
		/**
		 * Returns the mass, its center, and the rotational inertia.
		 *
		 * @returns x — The x position of the center of mass.
		 * @returns y — The y position of the center of mass.
		 * @returns mass — The mass of the body.
		 * @returns inertia — The rotational inertia.
		 */
		getMassData(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Overrides the calculated mass data.
		 *
		 * @param centerX The x position of the center of mass.
		 * @param centerY The y position of the center of mass.
		 * @param mass The mass of the body.
		 * @param inertia The rotational inertia.
		 */
		setMassData(centerX: number, centerY: number, mass: number, inertia: number): void;
		/**
		 * Resets the mass of the body by recalculating it from the mass properties of the fixtures.
		 */
		resetMassData(): void;
		/**
		 * Returns the gravity scale factor.
		 *
		 * @returns scale — The gravity scale factor.
		 */
		getGravityScale(): number;
		/**
		 * Sets a new gravity scale factor for the body.
		 *
		 * @param scale The new gravity scale factor.
		 */
		setGravityScale(scale: number): void;
		/**
		 * Get the center of mass position in local coordinates.
		 *
		 * Use Body:getWorldCenter to get the center of mass in world coordinates.
		 *
		 * @returns x — The x coordinate of the center of mass.
		 * @returns y — The y coordinate of the center of mass.
		 */
		getLocalCenter(): LuaMultiReturn<[number, number]>;
		/**
		 * Get the center of mass position in world coordinates.
		 *
		 * Use Body:getLocalCenter to get the center of mass in local coordinates.
		 *
		 * @returns x — The x coordinate of the center of mass.
		 * @returns y — The y coordinate of the center of mass.
		 */
		getWorldCenter(): LuaMultiReturn<[number, number]>;
		/**
		 * Returns whether the body rotation is locked.
		 *
		 * @returns fixed — True if the body's rotation is locked or false if not.
		 */
		isFixedRotation(): boolean;
		/**
		 * Set whether a body has fixed rotation.
		 *
		 * Bodies with fixed rotation don't vary the speed at which they rotate. Calling this function causes the mass to be reset.
		 *
		 * @param fixed Whether the body should have fixed rotation.
		 */
		setFixedRotation(fixed: boolean): void;
		/**
		 * Returns the sleep status of the body.
		 *
		 * @returns status — True if the body is awake or false if not.
		 */
		isAwake(): boolean;
		/**
		 * Wakes the body up or puts it to sleep.
		 *
		 * @param awake The body sleep status.
		 */
		setAwake(awake: boolean): void;
		/**
		 * Returns the sleeping behaviour of the body.
		 *
		 * @returns allowed — True if the body is allowed to sleep or false if not.
		 */
		isSleepingAllowed(): boolean;
		/**
		 * Sets the sleeping behaviour of the body. Should sleeping be allowed, a body at rest will automatically sleep. A sleeping body is not simulated unless it collided with an awake body. Be wary that one can end up with a situation like a floating sleeping body if the floor was removed.
		 *
		 * @param allowed True if the body is allowed to sleep or false if not.
		 */
		setSleepingAllowed(allowed: boolean): void;
		/**
		 * Returns whether the body is actively used in the simulation.
		 *
		 * @returns status — True if the body is active or false if not.
		 */
		isActive(): boolean;
		/**
		 * Sets whether the body is active in the world.
		 *
		 * An inactive body does not take part in the simulation. It will not move or cause any collisions.
		 *
		 * @param active If the body is active or not.
		 */
		setActive(active: boolean): void;
		/**
		 * Get the bullet status of a body.
		 *
		 * There are two methods to check for body collisions:
		 *
		 * * at their location when the world is updated (default)
		 *
		 * * using continuous collision detection (CCD)
		 *
		 * The default method is efficient, but a body moving very quickly may sometimes jump over another body without producing a collision. A body that is set as a bullet will use CCD. This is less efficient, but is guaranteed not to jump when moving quickly.
		 *
		 * Note that static bodies (with zero mass) always use CCD, so your walls will not let a fast moving body pass through even if it is not a bullet.
		 *
		 * @returns status — The bullet status of the body.
		 */
		isBullet(): boolean;
		/**
		 * Set the bullet status of a body.
		 *
		 * There are two methods to check for body collisions:
		 *
		 * * at their location when the world is updated (default)
		 *
		 * * using continuous collision detection (CCD)
		 *
		 * The default method is efficient, but a body moving very quickly may sometimes jump over another body without producing a collision. A body that is set as a bullet will use CCD. This is less efficient, but is guaranteed not to jump when moving quickly.
		 *
		 * Note that static bodies (with zero mass) always use CCD, so your walls will not let a fast moving body pass through even if it is not a bullet.
		 *
		 * @param bullet The bullet status of the body.
		 */
		setBullet(bullet: boolean): void;
		/**
		 * Applies an impulse to a body.
		 *
		 * This makes a single, instantaneous addition to the body momentum.
		 *
		 * An impulse pushes a body in a direction. A body with with a larger mass will react less. The reaction does '''not''' depend on the timestep, and is equivalent to applying a force continuously for 1 second. Impulses are best used to give a single push to a body. For a continuous push to a body it is better to use Body:applyForce.
		 *
		 * If the position to apply the impulse is not given, it will act on the center of mass of the body. The part of the impulse not directed towards the center of mass will cause the body to spin (and depends on the rotational inertia).
		 *
		 * Note that the impulse components and position must be given in world coordinates.
		 *
		 * @param xImpulse The x component of the impulse.
		 * @param yImpulse The y component of the impulse.
		 * @param pointX The x position to apply the impulse.
		 * @param pointY The y position to apply the impulse.
		 */
		applyLinearImpulse(xImpulse: number, yImpulse: number, pointX?: number, pointY?: number): void;
		/**
		 * Applies an angular impulse to a body. This makes a single, instantaneous addition to the body momentum.
		 *
		 * A body with with a larger mass will react less. The reaction does '''not''' depend on the timestep, and is equivalent to applying a force continuously for 1 second. Impulses are best used to give a single push to a body. For a continuous push to a body it is better to use Body:applyForce.
		 *
		 * @param impulse The impulse in kilogram-square meter per second.
		 */
		applyAngularImpulse(impulse: number): void;
		/**
		 * Apply force to a Body.
		 *
		 * A force pushes a body in a direction. A body with with a larger mass will react less. The reaction also depends on how long a force is applied: since the force acts continuously over the entire timestep, a short timestep will only push the body for a short time. Thus forces are best used for many timesteps to give a continuous push to a body (like gravity). For a single push that is independent of timestep, it is better to use Body:applyLinearImpulse.
		 *
		 * If the position to apply the force is not given, it will act on the center of mass of the body. The part of the force not directed towards the center of mass will cause the body to spin (and depends on the rotational inertia).
		 *
		 * Note that the force components and position must be given in world coordinates.
		 *
		 * @param xForce The x component of force to apply.
		 * @param yForce The y component of force to apply.
		 * @param pointX The x position to apply the force.
		 * @param pointY The y position to apply the force.
		 */
		applyForce(xForce: number, yForce: number, pointX?: number, pointY?: number): void;
		/**
		 * Apply torque to a body.
		 *
		 * Torque is like a force that will change the angular velocity (spin) of a body. The effect will depend on the rotational inertia a body has.
		 *
		 * @param torque The torque to apply.
		 */
		applyTorque(torque: number): void;
		/**
		 * Returns the type of the body.
		 *
		 * @returns type — The body type.
		 */
		getType(): BodyType;
		/**
		 * Sets a new body type.
		 *
		 * @param type The new type.
		 */
		setType(type: BodyType): void;
		/**
		 * Transform a point from local coordinates to world coordinates.
		 *
		 * @param x The x position in local coordinates.
		 * @param y The y position in local coordinates.
		 *
		 * @returns worldX — The x position in world coordinates.
		 * @returns worldY — The y position in world coordinates.
		 */
		getWorldPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * Transform a vector from local coordinates to world coordinates.
		 *
		 * @param x The vector x component in local coordinates.
		 * @param y The vector y component in local coordinates.
		 *
		 * @returns worldX — The vector x component in world coordinates.
		 * @returns worldY — The vector y component in world coordinates.
		 */
		getWorldVector(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * Transforms multiple points from local coordinates to world coordinates.
		 *
		 * @param x The x position of the first point.
		 * @param y The y position of the first point.
		 * @param coordinates The x position of the second point.
		 *
		 * @returns x1 — The transformed x position of the first point.
		 * @returns y1 — The transformed y position of the first point.
		 * @returns x2 — The transformed x position of the second point.
		 * @returns y2 — The transformed y position of the second point.
		 */
		getWorldPoints(x: number, y: number, ...coordinates: number[]): LuaMultiReturn<number[]>;
		/**
		 * Transform a point from world coordinates to local coordinates.
		 *
		 * @param x The x position in world coordinates.
		 * @param y The y position in world coordinates.
		 *
		 * @returns localX — The x position in local coordinates.
		 * @returns localY — The y position in local coordinates.
		 */
		getLocalPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * Transform a vector from world coordinates to local coordinates.
		 *
		 * @param x The vector x component in world coordinates.
		 * @param y The vector y component in world coordinates.
		 *
		 * @returns localX — The vector x component in local coordinates.
		 * @returns localY — The vector y component in local coordinates.
		 */
		getLocalVector(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * Transforms multiple points from world coordinates to local coordinates.
		 *
		 * @param x (Argument) The x position of the first point.
		 * @param y (Argument) The y position of the first point.
		 * @param coordinates (Argument) The x position of the second point.
		 *
		 * @returns x1 — (Result) The transformed x position of the first point.
		 * @returns y1 — (Result) The transformed y position of the first point.
		 * @returns x2 — (Result) The transformed x position of the second point.
		 * @returns y2 — (Result) The transformed y position of the second point.
		 * @returns ... — (Result) Additional transformed x and y position of the points.
		 */
		getLocalPoints(x: number, y: number, ...coordinates: number[]): LuaMultiReturn<number[]>;
		/**
		 * Get the linear velocity of a point on the body.
		 *
		 * The linear velocity for a point on the body is the velocity of the body center of mass plus the velocity at that point from the body spinning.
		 *
		 * The point on the body must given in world coordinates. Use Body:getLinearVelocityFromLocalPoint to specify this with local coordinates.
		 *
		 * @param x The x position to measure velocity.
		 * @param y The y position to measure velocity.
		 *
		 * @returns vx — The x component of velocity at point (x,y).
		 * @returns vy — The y component of velocity at point (x,y).
		 */
		getLinearVelocityFromWorldPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * Get the linear velocity of a point on the body.
		 *
		 * The linear velocity for a point on the body is the velocity of the body center of mass plus the velocity at that point from the body spinning.
		 *
		 * The point on the body must given in local coordinates. Use Body:getLinearVelocityFromWorldPoint to specify this with world coordinates.
		 *
		 * @param x The x position to measure velocity.
		 * @param y The y position to measure velocity.
		 *
		 * @returns vx — The x component of velocity at point (x,y).
		 * @returns vy — The y component of velocity at point (x,y).
		 */
		getLinearVelocityFromLocalPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/** Returns all fixtures attached to the body. */
		getFixtures(): Fixture[];
	}
	/** Shapes are solid 2d geometrical objects which handle the mass and collision of a Body in love.physics.
	 */
	interface Shape extends Object { getType(): "circle" | "polygon" | "edge" | "chain"; }
	/** Circle extends Shape and adds a radius and a local position.
	 */
	interface CircleShape extends Shape { getRadius(): number; }
	/** A PolygonShape is a convex polygon with up to 8 vertices.
	 */
	interface PolygonShape extends Shape {
		/**
		 * Get the local coordinates of the polygon's vertices.
		 *
		 * This function has a variable number of return values. It can be used in a nested fashion with love.graphics.polygon.
		 *
		 * @returns x1 — The x-component of the first vertex.
		 * @returns y1 — The y-component of the first vertex.
		 * @returns x2 — The x-component of the second vertex.
		 * @returns y2 — The y-component of the second vertex.
		 */
		getPoints(): LuaMultiReturn<number[]>;
		validate(): boolean;
	}
	/** A EdgeShape is a line segment. They can be used to create the boundaries of your terrain. The shape does not have volume and can only collide with PolygonShape and CircleShape.
	 */
	interface EdgeShape extends Shape {
		/**
		 * Returns the local coordinates of the edge points.
		 *
		 * @returns x1 — The x-component of the first vertex.
		 * @returns y1 — The y-component of the first vertex.
		 * @returns x2 — The x-component of the second vertex.
		 * @returns y2 — The y-component of the second vertex.
		 */
		getPoints(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Gets the vertex that establishes a connection to the previous shape.
		 *
		 * Setting next and previous EdgeShape vertices can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.
		 *
		 * @returns x — The x-component of the vertex, or nil if EdgeShape:setPreviousVertex hasn't been called.
		 * @returns y — The y-component of the vertex, or nil if EdgeShape:setPreviousVertex hasn't been called.
		 */
		getPreviousVertex(): LuaMultiReturn<[number, number] | []>;
		/**
		 * Gets the vertex that establishes a connection to the next shape.
		 *
		 * Setting next and previous EdgeShape vertices can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.
		 *
		 * @returns x — The x-component of the vertex, or nil if EdgeShape:setNextVertex hasn't been called.
		 * @returns y — The y-component of the vertex, or nil if EdgeShape:setNextVertex hasn't been called.
		 */
		getNextVertex(): LuaMultiReturn<[number, number] | []>;
		/**
		 * Sets a vertex that establishes a connection to the previous shape.
		 *
		 * This can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.
		 *
		 * @param x The x-component of the vertex.
		 * @param y The y-component of the vertex.
		 */
		setPreviousVertex(x?: number, y?: number): void;
		/**
		 * Sets a vertex that establishes a connection to the next shape.
		 *
		 * This can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.
		 *
		 * @param x The x-component of the vertex.
		 * @param y The y-component of the vertex.
		 */
		setNextVertex(x?: number, y?: number): void;
	}
	/** A ChainShape consists of multiple line segments. It can be used to create the boundaries of your terrain. The shape does not have volume and can only collide with PolygonShape and CircleShape.
	 */
	interface ChainShape extends Shape {
		/**
		 * Returns all points of the shape.
		 *
		 * @returns x1 — The x-coordinate of the first point.
		 * @returns y1 — The y-coordinate of the first point.
		 * @returns x2 — The x-coordinate of the second point.
		 * @returns y2 — The y-coordinate of the second point.
		 */
		getPoints(): LuaMultiReturn<number[]>;
		/**
		 * Returns the number of vertices the shape has.
		 *
		 * @returns count — The number of vertices.
		 */
		getVertexCount(): number;
		/**
		 * Returns a point of the shape.
		 *
		 * @param index The index of the point to return.
		 *
		 * @returns x — The x-coordinate of the point.
		 * @returns y — The y-coordinate of the point.
		 */
		getPoint(index: number): LuaMultiReturn<[number, number]>;
		/**
		 * Returns a child of the shape as an EdgeShape.
		 *
		 * @param index The index of the child.
		 *
		 * @returns shape — The child as an EdgeShape.
		 */
		getChildEdge(index: number): EdgeShape;
		/**
		 * Gets the vertex that establishes a connection to the previous shape.
		 *
		 * Setting next and previous ChainShape vertices can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.
		 *
		 * @returns x — The x-component of the vertex, or nil if ChainShape:setPreviousVertex hasn't been called.
		 * @returns y — The y-component of the vertex, or nil if ChainShape:setPreviousVertex hasn't been called.
		 */
		getPreviousVertex(): LuaMultiReturn<[number, number] | []>;
		/**
		 * Gets the vertex that establishes a connection to the next shape.
		 *
		 * Setting next and previous ChainShape vertices can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.
		 *
		 * @returns x — The x-component of the vertex, or nil if ChainShape:setNextVertex hasn't been called.
		 * @returns y — The y-component of the vertex, or nil if ChainShape:setNextVertex hasn't been called.
		 */
		getNextVertex(): LuaMultiReturn<[number, number] | []>;
		/**
		 * Sets a vertex that establishes a connection to the previous shape.
		 *
		 * This can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.
		 *
		 * @param x The x-component of the vertex.
		 * @param y The y-component of the vertex.
		 */
		setPreviousVertex(x?: number, y?: number): void;
		/**
		 * Sets a vertex that establishes a connection to the next shape.
		 *
		 * This can help prevent unwanted collisions when a flat shape slides along the edge and moves over to the new shape.
		 *
		 * @param x The x-component of the vertex.
		 * @param y The y-component of the vertex.
		 */
		setNextVertex(x?: number, y?: number): void;
	}
	/** Fixtures attach shapes to bodies.
	 */
	interface Fixture extends Object {
		/**
		 * Destroys the fixture.
		 */
		destroy(): void;
		/**
		 * Gets whether the Fixture is destroyed. Destroyed fixtures cannot be used.
		 *
		 * @returns destroyed — Whether the Fixture is destroyed.
		 */
		isDestroyed(): boolean;
		getType(): "circle" | "polygon" | "edge" | "chain";
		/**
		 * Sets the friction of the fixture.
		 *
		 * Friction determines how shapes react when they 'slide' along other shapes. Low friction indicates a slippery surface, like ice, while high friction indicates a rough surface, like concrete. Range: 0.0 - 1.0.
		 *
		 * @param friction The fixture friction.
		 */
		setFriction(friction: number): void;
		/**
		 * Returns the friction of the fixture.
		 *
		 * @returns friction — The fixture friction.
		 */
		getFriction(): number;
		/**
		 * Sets the restitution of the fixture.
		 *
		 * @param restitution The fixture restitution.
		 */
		setRestitution(restitution: number): void;
		/**
		 * Returns the restitution of the fixture.
		 *
		 * @returns restitution — The fixture restitution.
		 */
		getRestitution(): number;
		/**
		 * Sets the density of the fixture. Call Body:resetMassData if this needs to take effect immediately.
		 *
		 * @param density The fixture density in kilograms per square meter.
		 */
		setDensity(density: number): void;
		/**
		 * Returns the density of the fixture.
		 *
		 * @returns density — The fixture density in kilograms per square meter.
		 */
		getDensity(): number;
		/**
		 * Sets whether the fixture should act as a sensor.
		 *
		 * Sensors do not cause collision responses, but the begin-contact and end-contact World callbacks will still be called for this fixture.
		 *
		 * @param sensor The sensor status.
		 */
		setSensor(sensor: boolean): void;
		/**
		 * Returns whether the fixture is a sensor.
		 *
		 * @returns sensor — If the fixture is a sensor.
		 */
		isSensor(): boolean;
		/**
		 * Returns the body to which the fixture is attached.
		 *
		 * @returns body — The parent body.
		 */
		getBody(): Body;
		/**
		 * Returns the shape of the fixture. This shape is a reference to the actual data used in the simulation. It's possible to change its values between timesteps.
		 *
		 * @returns shape — The fixture's shape.
		 */
		getShape(): Shape;
		/**
		 * Checks if a point is inside the shape of the fixture.
		 *
		 * @param x The x position of the point.
		 * @param y The y position of the point.
		 *
		 * @returns isInside — True if the point is inside or false if it is outside.
		 */
		testPoint(x: number, y: number): boolean;
		/**
		 * Casts a ray against the shape of the fixture and returns the surface normal vector and the line position where the ray hit. If the ray missed the shape, nil will be returned.
		 *
		 * The ray starts on the first point of the input line and goes towards the second point of the line. The fifth argument is the maximum distance the ray is going to travel as a scale factor of the input line length.
		 *
		 * The childIndex parameter is used to specify which child of a parent shape, such as a ChainShape, will be ray casted. For ChainShapes, the index of 1 is the first edge on the chain. Ray casting a parent shape will only test the child specified so if you want to test every shape of the parent, you must loop through all of its children.
		 *
		 * The world position of the impact can be calculated by multiplying the line vector with the third return value and adding it to the line starting point.
		 *
		 * hitx, hity = x1 + (x2 - x1) * fraction, y1 + (y2 - y1) * fraction
		 *
		 * @param x1 The x position of the input line starting point.
		 * @param y1 The y position of the input line starting point.
		 * @param x2 The x position of the input line end point.
		 * @param y2 The y position of the input line end point.
		 * @param maxFraction Ray length parameter.
		 * @param childIndex The index of the child the ray gets cast against. (Default: 1.)
		 *
		 * @returns xn — The x component of the normal vector of the edge where the ray hit the shape.
		 * @returns yn — The y component of the normal vector of the edge where the ray hit the shape.
		 * @returns fraction — The position on the input line where the intersection happened as a factor of the line length.
		 */
		rayCast(x1: number, y1: number, x2: number, y2: number, maxFraction: number, childIndex?: number): LuaMultiReturn<[number, number, number] | []>;
		/**
		 * Sets the filter data of the fixture.
		 *
		 * Groups, categories, and mask can be used to define the collision behaviour of the fixture.
		 *
		 * If two fixtures are in the same group they either always collide if the group is positive, or never collide if it's negative. If the group is zero or they do not match, then the contact filter checks if the fixtures select a category of the other fixture with their masks. The fixtures do not collide if that's not the case. If they do have each other's categories selected, the return value of the custom contact filter will be used. They always collide if none was set.
		 *
		 * There can be up to 16 categories. Categories and masks are encoded as the bits of a 16-bit integer.
		 *
		 * When created, prior to calling this function, all fixtures have category set to 1, mask set to 65535 (all categories) and group set to 0.
		 *
		 * This function allows setting all filter data for a fixture at once. To set only the categories, the mask or the group, you can use Fixture:setCategory, Fixture:setMask or Fixture:setGroupIndex respectively.
		 *
		 * @param categoryBits The categories as an integer from 0 to 65535.
		 * @param maskBits The mask as an integer from 0 to 65535.
		 * @param groupIndex The group as an integer from -32768 to 32767.
		 */
		setFilterData(categoryBits: number, maskBits: number, groupIndex: number): void;
		/**
		 * Returns the filter data of the fixture.
		 *
		 * Categories and masks are encoded as the bits of a 16-bit integer.
		 *
		 * @returns categories — The categories as an integer from 0 to 65535.
		 * @returns mask — The mask as an integer from 0 to 65535.
		 * @returns group — The group as an integer from -32768 to 32767.
		 */
		getFilterData(): LuaMultiReturn<[number, number, number]>;
		/**
		 * Sets the categories the fixture belongs to. There can be up to 16 categories represented as a number from 1 to 16.
		 *
		 * All fixture's default category is 1.
		 *

		 * @param categories The categories.
		 */
		setCategory(categories: number[]): void;
		/**
		 * Sets the categories the fixture belongs to. There can be up to 16 categories represented as a number from 1 to 16.
		 *
		 * All fixture's default category is 1.
		 *

		 * @param categories The categories.
		 */
		setCategory(...categories: number[]): void;
		/**
		 * Returns the categories the fixture belongs to.
		 *
		 * @returns ... — The categories.
		 */
		getCategory(): LuaMultiReturn<number[]>;
		/**
		 * Sets the category mask of the fixture. There can be up to 16 categories represented as a number from 1 to 16.
		 *
		 * This fixture will '''NOT''' collide with the fixtures that are in the selected categories if the other fixture also has a category of this fixture selected.
		 *

		 * @param categories The masks.
		 */
		setMask(categories: number[]): void;
		/**
		 * Sets the category mask of the fixture. There can be up to 16 categories represented as a number from 1 to 16.
		 *
		 * This fixture will '''NOT''' collide with the fixtures that are in the selected categories if the other fixture also has a category of this fixture selected.
		 *

		 * @param categories The masks.
		 */
		setMask(...categories: number[]): void;
		/**
		 * Returns which categories this fixture should '''NOT''' collide with.
		 *
		 * @returns ... — The masks.
		 */
		getMask(): LuaMultiReturn<number[]>;
		/**
		 * Associates a Lua value with the fixture.
		 *
		 * To delete the reference, explicitly pass nil.
		 *
		 * @param value The Lua value to associate with the fixture.
		 */
		setUserData(value: unknown): void;
		/**
		 * Returns the Lua value associated with this fixture.
		 *
		 * @returns value — The Lua value associated with the fixture.
		 */
		getUserData(): unknown;
		/**
		 * Returns the points of the fixture bounding box. In case the fixture has multiple children a 1-based index can be specified. For example, a fixture will have multiple children with a chain shape.
		 *
		 * @param childIndex A bounding box of the fixture. (Default: 1.)
		 *
		 * @returns topLeftX — The x position of the top-left point.
		 * @returns topLeftY — The y position of the top-left point.
		 * @returns bottomRightX — The x position of the bottom-right point.
		 * @returns bottomRightY — The y position of the bottom-right point.
		 */
		getBoundingBox(childIndex?: number): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Returns the mass, its center and the rotational inertia.
		 *
		 * @returns x — The x position of the center of mass.
		 * @returns y — The y position of the center of mass.
		 * @returns mass — The mass of the fixture.
		 * @returns inertia — The rotational inertia.
		 */
		getMassData(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Returns the group the fixture belongs to. Fixtures with the same group will always collide if the group is positive or never collide if it's negative. The group zero means no group.
		 *
		 * The groups range from -32768 to 32767.
		 *
		 * @returns group — The group of the fixture.
		 */
		getGroupIndex(): number;
		/**
		 * Sets the group the fixture belongs to. Fixtures with the same group will always collide if the group is positive or never collide if it's negative. The group zero means no group.
		 *
		 * The groups range from -32768 to 32767.
		 *
		 * @param index The group as an integer from -32768 to 32767.
		 */
		setGroupIndex(index: number): void;
	}
	/** Attach multiple bodies together to interact in unique ways.
	 */
	interface Joint extends Object {
		/**
		 * Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.
		 *
		 * In 0.7.2, when you don't have time to wait for garbage collection, this function
		 *
		 * may be used to free the object immediately.
		 */
		destroy(): void;
		/**
		 * Gets whether the Joint is destroyed. Destroyed joints cannot be used.
		 *
		 * @returns destroyed — Whether the Joint is destroyed.
		 */
		isDestroyed(): boolean;
		/**
		 * Gets a string representing the type.
		 *
		 * @returns type — A string with the name of the Joint type.
		 */
		getType(): "distance" | "revolute" | "prismatic" | "weld" | "friction" | "rope" | "pulley" | "wheel" | "mouse" | "motor" | "gear";
		/**
		 * Gets the bodies that the Joint is attached to.
		 *
		 * @returns bodyA — The first Body.
		 * @returns bodyB — The second Body.
		 */
		getBodies(): LuaMultiReturn<[Body, Body]>;
		/**
		 * Get the anchor points of the joint.
		 *
		 * @returns x1 — The x-component of the anchor on Body 1.
		 * @returns y1 — The y-component of the anchor on Body 1.
		 * @returns x2 — The x-component of the anchor on Body 2.
		 * @returns y2 — The y-component of the anchor on Body 2.
		 */
		getAnchors(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Returns the reaction force in newtons on the second body
		 *
		 * @param inverseDeltaTime How long the force applies. Usually the inverse time step or 1/dt.
		 *
		 * @returns x — The x-component of the force.
		 * @returns y — The y-component of the force.
		 */
		getReactionForce(inverseDeltaTime: number): LuaMultiReturn<[number, number]>;
		/**
		 * Returns the reaction torque on the second body.
		 *
		 * @param inverseDeltaTime How long the force applies. Usually the inverse time step or 1/dt.
		 *
		 * @returns torque — The reaction torque on the second body.
		 */
		getReactionTorque(inverseDeltaTime: number): number;
		/**
		 * Gets whether the connected Bodies collide.
		 *
		 * @returns c — True if they collide, false otherwise.
		 */
		getCollideConnected(): boolean;
		/**
		 * Associates a Lua value with the Joint.
		 *
		 * To delete the reference, explicitly pass nil.
		 *
		 * @param value The Lua value to associate with the Joint.
		 */
		setUserData(value: unknown): void;
		/**
		 * Returns the Lua value associated with this Joint.
		 *
		 * @returns value — The Lua value associated with the Joint.
		 */
		getUserData(): unknown;
	}
	/** Keeps two bodies at the same distance.
	 */
	interface DistanceJoint extends Joint {
		/**
		 * Sets the equilibrium distance between the two Bodies.
		 *
		 * @param length The length between the two Bodies.
		 */
		setLength(length: number): void;
		/**
		 * Gets the equilibrium distance between the two Bodies.
		 *
		 * @returns l — The length between the two Bodies.
		 */
		getLength(): number;
		/**
		 * Sets the response speed.
		 *
		 * @param frequency The response speed.
		 */
		setFrequency(frequency: number): void;
		/**
		 * Gets the response speed.
		 *
		 * @returns Hz — The response speed.
		 */
		getFrequency(): number;
		/**
		 * Sets the damping ratio.
		 *
		 * @param ratio The damping ratio.
		 */
		setDampingRatio(ratio: number): void;
		/**
		 * Gets the damping ratio.
		 *
		 * @returns ratio — The damping ratio.
		 */
		getDampingRatio(): number;
	}
	/** Allow two Bodies to revolve around a shared point.
	 */
	interface RevoluteJoint extends Joint {
		/**
		 * Get the current joint angle.
		 *
		 * @returns angle — The joint angle in radians.
		 */
		getJointAngle(): number;
		/**
		 * Get the current joint angle speed.
		 *
		 * @returns s — Joint angle speed in radians/second.
		 */
		getJointSpeed(): number;
		/**
		 * Enables/disables the joint motor.
		 *
		 * @param enabled True to enable, false to disable.
		 */
		setMotorEnabled(enabled: boolean): void;
		/**
		 * Checks whether the motor is enabled.
		 *
		 * @returns enabled — True if enabled, false if disabled.
		 */
		isMotorEnabled(): boolean;
		/**
		 * Set the maximum motor force.
		 *
		 * @param torque The maximum motor force, in Nm.
		 */
		setMaxMotorTorque(torque: number): void;
		/**
		 * Gets the maximum motor force.
		 *
		 * @returns f — The maximum motor force, in Nm.
		 */
		getMaxMotorTorque(): number;
		/**
		 * Sets the motor speed.
		 *
		 * @param speed The motor speed, radians per second.
		 */
		setMotorSpeed(speed: number): void;
		/**
		 * Gets the motor speed.
		 *
		 * @returns s — The motor speed, radians per second.
		 */
		getMotorSpeed(): number;
		/**
		 * Get the current motor force.
		 *
		 * @returns f — The current motor force, in Nm.
		 */
		getMotorTorque(inverseDeltaTime: number): number;
		/**
		 * Enables/disables the joint limit.
		 *
		 * @param enabled True to enable, false to disable.
		 */
		setLimitsEnabled(enabled: boolean): void;
		/**
		 * Checks whether limits are enabled.
		 *
		 * @returns enabled — True if enabled, false otherwise.
		 */
		areLimitsEnabled(): boolean;
		/** @deprecated Use areLimitsEnabled. */
		/**
		 * Checks whether limits are enabled.
		 *
		 * @returns enabled — True if enabled, false otherwise.
		 */
		hasLimitsEnabled(): boolean;
		/**
		 * Sets the upper limit.
		 *
		 * @param upper The upper limit, in radians.
		 */
		setUpperLimit(upper: number): void;
		/**
		 * Sets the lower limit.
		 *
		 * @param lower The lower limit, in radians.
		 */
		setLowerLimit(lower: number): void;
		/**
		 * Sets the limits.
		 *
		 * @param lower The lower limit, in radians.
		 * @param upper The upper limit, in radians.
		 */
		setLimits(lower: number, upper: number): void;
		/**
		 * Gets the upper limit.
		 *
		 * @returns upper — The upper limit, in radians.
		 */
		getUpperLimit(): number;
		/**
		 * Gets the lower limit.
		 *
		 * @returns lower — The lower limit, in radians.
		 */
		getLowerLimit(): number;
		/**
		 * Gets the joint limits.
		 *
		 * @returns lower — The lower limit, in radians.
		 * @returns upper — The upper limit, in radians.
		 */
		getLimits(): LuaMultiReturn<[number, number]>;
		/**
		 * Gets the reference angle.
		 *
		 * @returns angle — The reference angle in radians.
		 */
		getReferenceAngle(): number;
	}
	/** Restricts relative motion between Bodies to one shared axis.
	 */
	interface PrismaticJoint extends Joint {
		/**
		 * Get the current joint translation.
		 *
		 * @returns t — Joint translation, usually in meters..
		 */
		getJointTranslation(): number;
		/**
		 * Get the current joint angle speed.
		 *
		 * @returns s — Joint angle speed in meters/second.
		 */
		getJointSpeed(): number;
		/**
		 * Enables/disables the joint motor.
		 *
		 * @param enabled True to enable, false to disable.
		 */
		setMotorEnabled(enabled: boolean): void;
		/**
		 * Checks whether the motor is enabled.
		 *
		 * @returns enabled — True if enabled, false if disabled.
		 */
		isMotorEnabled(): boolean;
		/**
		 * Set the maximum motor force.
		 *
		 * @param force The maximum motor force, usually in N.
		 */
		setMaxMotorForce(force: number): void;
		/**
		 * Gets the maximum motor force.
		 *
		 * @returns f — The maximum motor force, usually in N.
		 */
		getMaxMotorForce(): number;
		/**
		 * Sets the motor speed.
		 *
		 * @param speed The motor speed, usually in meters per second.
		 */
		setMotorSpeed(speed: number): void;
		/**
		 * Gets the motor speed.
		 *
		 * @returns s — The motor speed, usually in meters per second.
		 */
		getMotorSpeed(): number;
		/**
		 * Returns the current motor force.
		 *
		 * @param inverseDeltaTime How long the force applies. Usually the inverse time step or 1/dt.
		 *
		 * @returns force — The force on the motor in newtons.
		 */
		getMotorForce(inverseDeltaTime: number): number;
		/**
		 * Enables/disables the joint limit.
		 *
		 * @returns enable — True if enabled, false if disabled.
		 */
		setLimitsEnabled(enabled: boolean): void;
		/**
		 * Checks whether the limits are enabled.
		 *
		 * @returns enabled — True if enabled, false otherwise.
		 */
		areLimitsEnabled(): boolean;
		/** @deprecated Use areLimitsEnabled. */
		hasLimitsEnabled(): boolean;
		/**
		 * Sets the upper limit.
		 *
		 * @param upper The upper limit, usually in meters.
		 */
		setUpperLimit(upper: number): void;
		/**
		 * Sets the lower limit.
		 *
		 * @param lower The lower limit, usually in meters.
		 */
		setLowerLimit(lower: number): void;
		/**
		 * Sets the limits.
		 *
		 * @param lower The lower limit, usually in meters.
		 * @param upper The upper limit, usually in meters.
		 */
		setLimits(lower: number, upper: number): void;
		/**
		 * Gets the upper limit.
		 *
		 * @returns upper — The upper limit, usually in meters.
		 */
		getUpperLimit(): number;
		/**
		 * Gets the lower limit.
		 *
		 * @returns lower — The lower limit, usually in meters.
		 */
		getLowerLimit(): number;
		/**
		 * Gets the joint limits.
		 *
		 * @returns lower — The lower limit, usually in meters.
		 * @returns upper — The upper limit, usually in meters.
		 */
		getLimits(): LuaMultiReturn<[number, number]>;
		/**
		 * Gets the world-space axis vector of the Prismatic Joint.
		 *
		 * @returns x — The x-axis coordinate of the world-space axis vector.
		 * @returns y — The y-axis coordinate of the world-space axis vector.
		 */
		getAxis(): LuaMultiReturn<[number, number]>;
		/**
		 * Gets the reference angle.
		 *
		 * @returns angle — The reference angle in radians.
		 */
		getReferenceAngle(): number;
	}
	/** A WeldJoint essentially glues two bodies together.
	 */
	interface WeldJoint extends Joint {
		/**
		 * Sets a new frequency.
		 *
		 * @param frequency The new frequency in hertz.
		 */
		setFrequency(frequency: number): void;
		/**
		 * Returns the frequency.
		 *
		 * @returns freq — The frequency in hertz.
		 */
		getFrequency(): number;
		/**
		 * Sets a new damping ratio.
		 *
		 * @param ratio The new damping ratio.
		 */
		setDampingRatio(ratio: number): void;
		/**
		 * Returns the damping ratio of the joint.
		 *
		 * @returns ratio — The damping ratio.
		 */
		getDampingRatio(): number;
		/**
		 * Gets the reference angle.
		 *
		 * @returns angle — The reference angle in radians.
		 */
		getReferenceAngle(): number;
	}
	/** A FrictionJoint applies friction to a body.
	 */
	interface FrictionJoint extends Joint {
		/**
		 * Sets the maximum friction force in Newtons.
		 *
		 * @param force Max force in Newtons.
		 */
		setMaxForce(force: number): void;
		/**
		 * Gets the maximum friction force in Newtons.
		 *
		 * @returns force — Maximum force in Newtons.
		 */
		getMaxForce(): number;
		/**
		 * Sets the maximum friction torque in Newton-meters.
		 *
		 * @param torque Maximum torque in Newton-meters.
		 */
		setMaxTorque(torque: number): void;
		/**
		 * Gets the maximum friction torque in Newton-meters.
		 *
		 * @returns torque — Maximum torque in Newton-meters.
		 */
		getMaxTorque(): number;
	}
	/** The RopeJoint enforces a maximum distance between two points on two bodies. It has no other effect.
	 */
	interface RopeJoint extends Joint {
		/**
		 * Sets the maximum length of a RopeJoint.
		 *
		 * @param length The new maximum length of the RopeJoint.
		 */
		setMaxLength(length: number): void;
		/**
		 * Gets the maximum length of a RopeJoint.
		 *
		 * @returns maxLength — The maximum length of the RopeJoint.
		 */
		getMaxLength(): number;
	}
	/** Allows you to simulate bodies connected through pulleys.
	 */
	interface PulleyJoint extends Joint {
		/**
		 * Get the ground anchor positions in world coordinates.
		 *
		 * @returns a1x — The x coordinate of the first anchor.
		 * @returns a1y — The y coordinate of the first anchor.
		 * @returns a2x — The x coordinate of the second anchor.
		 * @returns a2y — The y coordinate of the second anchor.
		 */
		getGroundAnchors(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * Get the current length of the rope segment attached to the first body.
		 *
		 * @returns length — The length of the rope segment.
		 */
		getLengthA(): number;
		/**
		 * Get the current length of the rope segment attached to the second body.
		 *
		 * @returns length — The length of the rope segment.
		 */
		getLengthB(): number;
		/**
		 * Get the pulley ratio.
		 *
		 * @returns ratio — The pulley ratio of the joint.
		 */
		getRatio(): number;
	}
	/** Restricts a point on the second body to a line on the first body.
	 */
	interface WheelJoint extends Joint {
		/**
		 * Returns the current joint translation.
		 *
		 * @returns position — The translation of the joint in meters.
		 */
		getJointTranslation(): number;
		/**
		 * Returns the current joint translation speed.
		 *
		 * @returns speed — The translation speed of the joint in meters per second.
		 */
		getJointSpeed(): number;
		/**
		 * Starts and stops the joint motor.
		 *
		 * @param enabled True turns the motor on and false turns it off.
		 */
		setMotorEnabled(enabled: boolean): void;
		/**
		 * Checks if the joint motor is running.
		 *
		 * @returns on — The status of the joint motor.
		 */
		isMotorEnabled(): boolean;
		/**
		 * Sets a new speed for the motor.
		 *
		 * @param speed The new speed for the joint motor in radians per second.
		 */
		setMotorSpeed(speed: number): void;
		/**
		 * Returns the speed of the motor.
		 *
		 * @returns speed — The speed of the joint motor in radians per second.
		 */
		getMotorSpeed(): number;
		/**
		 * Sets a new maximum motor torque.
		 *
		 * @param torque The new maximum torque for the joint motor in newton meters.
		 */
		setMaxMotorTorque(torque: number): void;
		/**
		 * Returns the maximum motor torque.
		 *
		 * @returns maxTorque — The maximum torque of the joint motor in newton meters.
		 */
		getMaxMotorTorque(): number;
		/**
		 * Returns the current torque on the motor.
		 *
		 * @param inverseDeltaTime How long the force applies. Usually the inverse time step or 1/dt.
		 *
		 * @returns torque — The torque on the motor in newton meters.
		 */
		getMotorTorque(inverseDeltaTime: number): number;
		/**
		 * Sets a new spring frequency.
		 *
		 * @param frequency The new frequency in hertz.
		 */
		setSpringFrequency(frequency: number): void;
		/**
		 * Returns the spring frequency.
		 *
		 * @returns freq — The frequency in hertz.
		 */
		getSpringFrequency(): number;
		/**
		 * Sets a new damping ratio.
		 *
		 * @param ratio The new damping ratio.
		 */
		setSpringDampingRatio(ratio: number): void;
		/**
		 * Returns the damping ratio.
		 *
		 * @returns ratio — The damping ratio.
		 */
		getSpringDampingRatio(): number;
		/**
		 * Gets the world-space axis vector of the Wheel Joint.
		 *
		 * @returns x — The x-axis coordinate of the world-space axis vector.
		 * @returns y — The y-axis coordinate of the world-space axis vector.
		 */
		getAxis(): LuaMultiReturn<[number, number]>;
	}
	/** For controlling objects with the mouse.
	 */
	interface MouseJoint extends Joint {
		/**
		 * Sets the target point.
		 *
		 * @param x The x-component of the target.
		 * @param y The y-component of the target.
		 */
		setTarget(x: number, y: number): void;
		/**
		 * Gets the target point.
		 *
		 * @returns x — The x-component of the target.
		 * @returns y — The x-component of the target.
		 */
		getTarget(): LuaMultiReturn<[number, number]>;
		/**
		 * Sets the highest allowed force.
		 *
		 * @param force The max allowed force.
		 */
		setMaxForce(force: number): void;
		/**
		 * Gets the highest allowed force.
		 *
		 * @returns f — The max allowed force.
		 */
		getMaxForce(): number;
		/**
		 * Sets a new frequency.
		 *
		 * @param frequency The new frequency in hertz.
		 */
		setFrequency(frequency: number): void;
		/**
		 * Returns the frequency.
		 *
		 * @returns freq — The frequency in hertz.
		 */
		getFrequency(): number;
		/**
		 * Sets a new damping ratio.
		 *
		 * @param ratio The new damping ratio.
		 */
		setDampingRatio(ratio: number): void;
		/**
		 * Returns the damping ratio.
		 *
		 * @returns ratio — The new damping ratio.
		 */
		getDampingRatio(): number;
	}
	/** Controls the relative motion between two Bodies. Position and rotation offsets can be specified, as well as the maximum motor force and torque that will be applied to reach the target offsets.
	 */
	interface MotorJoint extends Joint {
		/**
		 * Sets the target linear offset between the two Bodies the Joint is attached to.
		 *
		 * @param x The x component of the target linear offset, relative to the first Body.
		 * @param y The y component of the target linear offset, relative to the first Body.
		 */
		setLinearOffset(x: number, y: number): void;
		/**
		 * Gets the target linear offset between the two Bodies the Joint is attached to.
		 *
		 * @returns x — The x component of the target linear offset, relative to the first Body.
		 * @returns y — The y component of the target linear offset, relative to the first Body.
		 */
		getLinearOffset(): LuaMultiReturn<[number, number]>;
		/**
		 * Sets the target angluar offset between the two Bodies the Joint is attached to.
		 *
		 * @param angle The target angular offset in radians: the second body's angle minus the first body's angle.
		 */
		setAngularOffset(angle: number): void;
		/**
		 * Gets the target angular offset between the two Bodies the Joint is attached to.
		 *
		 * @returns angleoffset — The target angular offset in radians: the second body's angle minus the first body's angle.
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
	 */
	interface GearJoint extends Joint {
		/**
		 * Set the ratio of a gear joint.
		 *
		 * @param ratio The new ratio of the joint.
		 */
		setRatio(ratio: number): void;
		/**
		 * Get the ratio of a gear joint.
		 *
		 * @returns ratio — The ratio of the joint.
		 */
		getRatio(): number;
		/**
		 * Get the Joints connected by this GearJoint.
		 *
		 * @returns joint1 — The first connected Joint.
		 * @returns joint2 — The second connected Joint.
		 */
		getJoints(): LuaMultiReturn<[RevoluteJoint | PrismaticJoint, RevoluteJoint | PrismaticJoint]>;
	}
	/** @noSelf */
	/** Can simulate 2D rigid body physics in a realistic manner. This module is based on Box2D, and this API corresponds to the Box2D API as closely as possible.
	 */
	interface Physics {
		/**
		 * Sets the pixels to meter scale factor.
		 *
		 * All coordinates in the physics module are divided by this number and converted to meters, and it creates a convenient way to draw the objects directly to the screen without the need for graphics transformations.
		 *
		 * It is recommended to create shapes no larger than 10 times the scale. This is important because Box2D is tuned to work well with shape sizes from 0.1 to 10 meters. The default meter scale is 30.
		 *
		 * @param scale The scale factor as an integer.
		 */
		setMeter(this: void, scale: number): void;
		/**
		 * Returns the meter scale factor.
		 *
		 * All coordinates in the physics module are divided by this number, creating a convenient way to draw the objects directly to the screen without the need for graphics transformations.
		 *
		 * It is recommended to create shapes no larger than 10 times the scale. This is important because Box2D is tuned to work well with shape sizes from 0.1 to 10 meters.
		 *
		 * @returns scale — The scale factor as an integer.
		 */
		getMeter(this: void): number;
		/**
		 * Creates a new World.
		 *
		 * @param xGravity The x component of gravity. (Default: 0.)
		 * @param yGravity The y component of gravity. (Default: 0.)
		 * @param sleep Whether the bodies in this world are allowed to sleep. (Default: true.)
		 *
		 * @returns world — A brave new World.
		 */
		newWorld(this: void, xGravity?: number, yGravity?: number, sleep?: boolean): World;
		/**
		 * Creates a new body.
		 *
		 * There are three types of bodies.
		 *
		 * * Static bodies do not move, have a infinite mass, and can be used for level boundaries.
		 *
		 * * Dynamic bodies are the main actors in the simulation, they collide with everything.
		 *
		 * * Kinematic bodies do not react to forces and only collide with dynamic bodies.
		 *
		 * The mass of the body gets calculated when a Fixture is attached or removed, but can be changed at any time with Body:setMass or Body:resetMassData.
		 *
		 * @param world The world to create the body in.
		 * @param x The x position of the body. (Default: 0.)
		 * @param y The y position of the body. (Default: 0.)
		 * @param type The type of the body. (Default: 'static'.)
		 *
		 * @returns body — A new body.
		 */
		newBody(this: void, world: World, x?: number, y?: number, type?: BodyType): Body;
		/**
		 * Creates and attaches a Fixture to a body.
		 *
		 * Note that the Shape object is copied rather than kept as a reference when the Fixture is created. To get the Shape object that the Fixture owns, use Fixture:getShape.
		 *
		 * @param body The body which gets the fixture attached.
		 * @param shape The shape to be copied to the fixture.
		 * @param density The density of the fixture. (Default: 1.)
		 *
		 * @returns fixture — The new fixture.
		 */
		newFixture(this: void, body: Body, shape: Shape, density?: number): Fixture;
		/**
		 * Creates a new CircleShape.
		 *

		 * @param radius The radius of the circle.
		 * @returns shape — The new shape.
		 */
		newCircleShape(this: void, radius: number): CircleShape;
		/**
		 * Creates a new CircleShape.
		 *

		 * @param x The x position of the circle.
		 * @param y The y position of the circle.
		 * @param radius The radius of the circle.
		 * @returns shape — The new shape.
		 */
		newCircleShape(this: void, x: number, y: number, radius: number): CircleShape;
		/**
		 * Shorthand for creating rectangular PolygonShapes.
		 *
		 * By default, the local origin is located at the '''center''' of the rectangle as opposed to the top left for graphics.
		 *

		 * @param width The width of the rectangle.
		 * @param height The height of the rectangle.
		 * @returns shape — A new PolygonShape.
		 */
		newRectangleShape(this: void, width: number, height: number): PolygonShape;
		/**
		 * Shorthand for creating rectangular PolygonShapes.
		 *
		 * By default, the local origin is located at the '''center''' of the rectangle as opposed to the top left for graphics.
		 *

		 * @param x The offset along the x-axis.
		 * @param y The offset along the y-axis.
		 * @param width The width of the rectangle.
		 * @param height The height of the rectangle.
		 * @param angle The initial angle of the rectangle. (Default: 0.)
		 * @returns shape — A new PolygonShape.
		 */
		newRectangleShape(this: void, x: number, y: number, width: number, height: number, angle?: number): PolygonShape;
		/**
		 * Creates a new PolygonShape.
		 *
		 * This shape can have 8 vertices at most, and must form a convex shape.
		 *

		 * @param points A list of vertices to construct the polygon, in the form of {x1, y1, x2, y2, x3, y3, ...}.
		 * @returns shape — A new PolygonShape.
		 */
		newPolygonShape(this: void, points: number[]): PolygonShape;
		/**
		 * Creates a new PolygonShape.
		 *
		 * This shape can have 8 vertices at most, and must form a convex shape.
		 *

		 * @param points A list of vertices to construct the polygon, in the form of {x1, y1, x2, y2, x3, y3, ...}.
		 * @returns shape — A new PolygonShape.
		 */
		newPolygonShape(this: void, ...points: number[]): PolygonShape;
		/**
		 * Creates a new EdgeShape.
		 *
		 * @param x1 The x position of the first point.
		 * @param y1 The y position of the first point.
		 * @param x2 The x position of the second point.
		 * @param y2 The y position of the second point.
		 *
		 * @returns shape — The new shape.
		 */
		newEdgeShape(this: void, x1: number, y1: number, x2: number, y2: number): EdgeShape;
		/**
		 * Creates a new ChainShape.
		 *

		 * @param loop If the chain should loop back to the first point.
		 * @param points A list of points to construct the ChainShape, in the form of {x1, y1, x2, y2, ...}.
		 * @returns shape — The new shape.
		 */
		newChainShape(this: void, loop: boolean, points: number[]): ChainShape;
		/**
		 * Creates a new ChainShape.
		 *

		 * @param loop If the chain should loop back to the first point.
		 * @param points A list of points to construct the ChainShape, in the form of {x1, y1, x2, y2, ...}.
		 * @returns shape — The new shape.
		 */
		newChainShape(this: void, loop: boolean, ...points: number[]): ChainShape;
		/**
		 * Creates a DistanceJoint between two bodies.
		 *
		 * This joint constrains the distance between two points on two bodies to be constant. These two points are specified in world coordinates and the two bodies are assumed to be in place when this joint is created. The first anchor point is connected to the first body and the second to the second body, and the points define the length of the distance joint.
		 *
		 * @param body1 The first body to attach to the joint.
		 * @param body2 The second body to attach to the joint.
		 * @param x1 The x position of the first anchor point (world space).
		 * @param y1 The y position of the first anchor point (world space).
		 * @param x2 The x position of the second anchor point (world space).
		 * @param y2 The y position of the second anchor point (world space).
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 *
		 * @returns joint — The new distance joint.
		 */
		newDistanceJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean): DistanceJoint;
		/**
		 * Creates a pivot joint between two bodies.
		 *
		 * This joint connects two bodies to a point around which they can pivot.
		 *

		 * @param body1 The first body.
		 * @param body2 The second body.
		 * @param x The x position of the connecting point.
		 * @param y The y position of the connecting point.
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 * @returns joint — The new revolute joint.
		 */
		newRevoluteJoint(this: void, body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): RevoluteJoint;
		/**
		 * Creates a pivot joint between two bodies.
		 *
		 * This joint connects two bodies to a point around which they can pivot.
		 *

		 * @param body1 The first body.
		 * @param body2 The second body.
		 * @param x1 The x position of the first connecting point.
		 * @param y1 The y position of the first connecting point.
		 * @param x2 The x position of the second connecting point.
		 * @param y2 The y position of the second connecting point.
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 * @param referenceAngle The reference angle between body1 and body2, in radians. (Default: 0.)
		 * @returns joint — The new revolute joint.
		 */
		newRevoluteJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean, referenceAngle?: number): RevoluteJoint;
		/**
		 * Creates a PrismaticJoint between two bodies.
		 *
		 * A prismatic joint constrains two bodies to move relatively to each other on a specified axis. It does not allow for relative rotation. Its definition and operation are similar to a revolute joint, but with translation and force substituted for angle and torque.
		 *

		 * @param body1 The first body to connect with a prismatic joint.
		 * @param body2 The second body to connect with a prismatic joint.
		 * @param x The x coordinate of the anchor point.
		 * @param y The y coordinate of the anchor point.
		 * @param axisX The x coordinate of the axis vector.
		 * @param axisY The y coordinate of the axis vector.
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 * @returns joint — The new prismatic joint.
		 */
		newPrismaticJoint(this: void, body1: Body, body2: Body, x: number, y: number, axisX: number, axisY: number, collideConnected?: boolean): PrismaticJoint;
		/**
		 * Creates a PrismaticJoint between two bodies.
		 *
		 * A prismatic joint constrains two bodies to move relatively to each other on a specified axis. It does not allow for relative rotation. Its definition and operation are similar to a revolute joint, but with translation and force substituted for angle and torque.
		 *

		 * @param body1 The first body to connect with a prismatic joint.
		 * @param body2 The second body to connect with a prismatic joint.
		 * @param x1 The x coordinate of the first anchor point.
		 * @param y1 The y coordinate of the first anchor point.
		 * @param x2 The x coordinate of the second anchor point.
		 * @param y2 The y coordinate of the second anchor point.
		 * @param axisX The x coordinate of the axis unit vector.
		 * @param axisY The y coordinate of the axis unit vector.
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 * @param referenceAngle The reference angle between body1 and body2, in radians. (Default: 0.)
		 * @returns joint — The new prismatic joint.
		 */
		newPrismaticJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axisX: number, axisY: number, collideConnected?: boolean, referenceAngle?: number): PrismaticJoint;
		/**
		 * Creates a constraint joint between two bodies. A WeldJoint essentially glues two bodies together. The constraint is a bit soft, however, due to Box2D's iterative solver.
		 *

		 * @param body1 The first body to attach to the joint.
		 * @param body2 The second body to attach to the joint.
		 * @param x The x position of the anchor point (world space).
		 * @param y The y position of the anchor point (world space).
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 * @returns joint — The new WeldJoint.
		 */
		newWeldJoint(this: void, body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): WeldJoint;
		/**
		 * Creates a constraint joint between two bodies. A WeldJoint essentially glues two bodies together. The constraint is a bit soft, however, due to Box2D's iterative solver.
		 *

		 * @param body1 The first body to attach to the joint.
		 * @param body2 The second body to attach to the joint.
		 * @param x1 The x position of the first anchor point (world space).
		 * @param y1 The y position of the first anchor point (world space).
		 * @param x2 The x position of the second anchor point (world space).
		 * @param y2 The y position of the second anchor point (world space).
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 * @param referenceAngle The reference angle between body1 and body2, in radians. (Default: 0.)
		 * @returns joint — The new WeldJoint.
		 */
		newWeldJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean, referenceAngle?: number): WeldJoint;
		/**
		 * Create a friction joint between two bodies. A FrictionJoint applies friction to a body.
		 *

		 * @param body1 The first body to attach to the joint.
		 * @param body2 The second body to attach to the joint.
		 * @param x The x position of the anchor point.
		 * @param y The y position of the anchor point.
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 * @returns joint — The new FrictionJoint.
		 */
		newFrictionJoint(this: void, body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): FrictionJoint;
		/**
		 * Create a friction joint between two bodies. A FrictionJoint applies friction to a body.
		 *

		 * @param body1 The first body to attach to the joint.
		 * @param body2 The second body to attach to the joint.
		 * @param x1 The x position of the first anchor point.
		 * @param y1 The y position of the first anchor point.
		 * @param x2 The x position of the second anchor point.
		 * @param y2 The y position of the second anchor point.
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 * @returns joint — The new FrictionJoint.
		 */
		newFrictionJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean): FrictionJoint;
		/**
		 * Creates a joint between two bodies. Its only function is enforcing a max distance between these bodies.
		 *
		 * @param body1 The first body to attach to the joint.
		 * @param body2 The second body to attach to the joint.
		 * @param x1 The x position of the first anchor point.
		 * @param y1 The y position of the first anchor point.
		 * @param x2 The x position of the second anchor point.
		 * @param y2 The y position of the second anchor point.
		 * @param maxLength The maximum distance for the bodies.
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 *
		 * @returns joint — The new RopeJoint.
		 */
		newRopeJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, maxLength: number, collideConnected?: boolean): RopeJoint;
		/**
		 * Creates a PulleyJoint to join two bodies to each other and the ground.
		 *
		 * The pulley joint simulates a pulley with an optional block and tackle. If the ratio parameter has a value different from one, then the simulated rope extends faster on one side than the other. In a pulley joint the total length of the simulated rope is the constant length1 + ratio * length2, which is set when the pulley joint is created.
		 *
		 * Pulley joints can behave unpredictably if one side is fully extended. It is recommended that the method setMaxLengths  be used to constrain the maximum lengths each side can attain.
		 *
		 * @param body1 The first body to connect with a pulley joint.
		 * @param body2 The second body to connect with a pulley joint.
		 * @param groundX1 The x coordinate of the first body's ground anchor.
		 * @param groundY1 The y coordinate of the first body's ground anchor.
		 * @param groundX2 The x coordinate of the second body's ground anchor.
		 * @param groundY2 The y coordinate of the second body's ground anchor.
		 * @param x1 The x coordinate of the pulley joint anchor in the first body.
		 * @param y1 The y coordinate of the pulley joint anchor in the first body.
		 * @param x2 The x coordinate of the pulley joint anchor in the second body.
		 * @param y2 The y coordinate of the pulley joint anchor in the second body.
		 * @param ratio The joint ratio. (Default: 1.)
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: true.)
		 *
		 * @returns joint — The new pulley joint.
		 */
		newPulleyJoint(this: void, body1: Body, body2: Body, groundX1: number, groundY1: number, groundX2: number, groundY2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collideConnected?: boolean): PulleyJoint;
		/**
		 * Creates a wheel joint.
		 *

		 * @param body1 The first body.
		 * @param body2 The second body.
		 * @param x The x position of the anchor point.
		 * @param y The y position of the anchor point.
		 * @param axisX The x position of the axis unit vector.
		 * @param axisY The y position of the axis unit vector.
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 * @returns joint — The new WheelJoint.
		 */
		newWheelJoint(this: void, body1: Body, body2: Body, x: number, y: number, axisX: number, axisY: number, collideConnected?: boolean): WheelJoint;
		/**
		 * Creates a wheel joint.
		 *

		 * @param body1 The first body.
		 * @param body2 The second body.
		 * @param x1 The x position of the first anchor point.
		 * @param y1 The y position of the first anchor point.
		 * @param x2 The x position of the second anchor point.
		 * @param y2 The y position of the second anchor point.
		 * @param axisX The x position of the axis unit vector.
		 * @param axisY The y position of the axis unit vector.
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 * @returns joint — The new WheelJoint.
		 */
		newWheelJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axisX: number, axisY: number, collideConnected?: boolean): WheelJoint;
		/**
		 * Create a joint between a body and the mouse.
		 *
		 * This joint actually connects the body to a fixed point in the world. To make it follow the mouse, the fixed point must be updated every timestep (example below).
		 *
		 * The advantage of using a MouseJoint instead of just changing a body position directly is that collisions and reactions to other joints are handled by the physics engine.
		 *
		 * @param body The body to attach to the mouse.
		 * @param x The x position of the connecting point.
		 * @param y The y position of the connecting point.
		 *
		 * @returns joint — The new mouse joint.
		 */
		newMouseJoint(this: void, body: Body, x: number, y: number): MouseJoint;
		/**
		 * Creates a joint between two bodies which controls the relative motion between them.
		 *
		 * Position and rotation offsets can be specified once the MotorJoint has been created, as well as the maximum motor force and torque that will be be applied to reach the target offsets.
		 *
		 * @param body1 The first body to attach to the joint.
		 * @param body2 The second body to attach to the joint.
		 * @param correctionFactor The joint's initial position correction factor, in the range of 1. (Default: 0.3.)
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 *
		 * @returns joint — The new MotorJoint.
		 */
		newMotorJoint(this: void, body1: Body, body2: Body, correctionFactor?: number, collideConnected?: boolean): MotorJoint;
		/**
		 * Create a GearJoint connecting two Joints.
		 *
		 * The gear joint connects two joints that must be either prismatic or revolute joints. Using this joint requires that the joints it uses connect their respective bodies to the ground and have the ground as the first body. When destroying the bodies and joints you must make sure you destroy the gear joint before the other joints.
		 *
		 * The gear joint has a ratio the determines how the angular or distance values of the connected joints relate to each other. The formula coordinate1 + ratio * coordinate2 always has a constant value that is set when the gear joint is created.
		 *
		 * @param joint1 The first joint to connect with a gear joint.
		 * @param joint2 The second joint to connect with a gear joint.
		 * @param ratio The gear ratio. (Default: 1.)
		 * @param collideConnected Specifies whether the two bodies should collide with each other. (Default: false.)
		 *
		 * @returns joint — The new gear joint.
		 */
		newGearJoint(this: void, joint1: RevoluteJoint | PrismaticJoint, joint2: RevoluteJoint | PrismaticJoint, ratio?: number, collideConnected?: boolean): GearJoint;
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

		/**
		 * If a file called conf.lua is present in your game folder (or .love file), it is run before the LÖVE modules are loaded. You can use this file to overwrite the love.conf function, which is later called by the LÖVE 'boot' script. Using the love.conf function, you can set some configuration options, and change things like the default size of the window, which modules are loaded, and other stuff.
		 *
		 * @param t The love.conf function takes one argument: a table filled with all the default values which you can overwrite to your liking. If you want to change the default window size, for instance, do:

function love.conf(t)
 t.window.width = 1024
 t.window.height = 768
end

If you don't need the physics module or joystick module, do the following.

function love.conf(t)
 t.modules.joystick = false
 t.modules.physics = false
end

Setting unused modules to false is encouraged when you release your game. It reduces startup time slightly (especially if the joystick module is disabled) and reduces memory usage (slightly).

Note that you can't disable love.filesystem; it's mandatory. The same goes for the love module itself. love.graphics needs love.window to be enabled.
		 * @param t.identity This flag determines the name of the save directory for your game. Note that you can only specify the name, not the location where it will be created:
t.identity = "gabe_HL3" -- Correct

t.identity = "c:/Users/gabe/HL3" -- Incorrect
Alternatively love.filesystem.setIdentity can be used to set the save directory outside of the config file. (Default: nil.)
		 * @param t.appendidentity This flag determines if game directory should be searched first then save directory (true) or otherwise (false) (Default: false.)
		 * @param t.version t.version should be a string, representing the version of LÖVE for which your game was made. It should be formatted as "X.Y.Z" where X is the major release number, Y the minor, and Z the patch level. It allows LÖVE to display a warning if it isn't compatible. Its default is the version of LÖVE running. (Default: "11.5".)
		 * @param t.console Determines whether a console should be opened alongside the game window (Windows only) or not. Note: On OSX you can get console output by running LÖVE through the terminal. (Default: false.)
		 * @param t.accelerometerjoystick Sets whether the device accelerometer on iOS and Android should be exposed as a 3-axis Joystick. Disabling the accelerometer when it's not used may reduce CPU usage. (Default: true.)
		 * @param t.externalstorage Sets whether files are saved in external storage (true) or internal storage (false) on Android. (Default: false.)
		 * @param t.gammacorrect Determines whether gamma-correct rendering is enabled, when the system supports it. (Default: false.)
		 * @param t.audio Audio options.
		 * @param t.audio.mic Request microphone permission from the user. When user allows it, love.audio.getRecordingDevices will lists recording devices available. Otherwise, love.audio.getRecordingDevices returns empty table and a message is shown to inform user when called. (Default: false.)
		 * @param t.audio.mixwithsystem Sets whether background audio / music from other apps should play while LÖVE is open. See love.system.hasBackgroundMusic for more details. (Default: true.)
		 * @param t.window It is possible to defer window creation until love.window.setMode is first called in your code. To do so, set t.window = nil in love.conf (or t.screen = nil in older versions.) If this is done, LÖVE may crash if any function from love.graphics is called before the first love.window.setMode in your code.

The t.window table was named t.screen in versions prior to 0.9.0. The t.screen table doesn't exist in love.conf in 0.9.0, and the t.window table doesn't exist in love.conf in 0.8.0. This means love.conf will fail to execute (therefore it will fall back to default values) if care is not taken to use the correct table for the LÖVE version being used.
		 * @param t.window.title Sets the title of the window the game is in. Alternatively love.window.setTitle can be used to change the window title outside of the config file. (Default: "Untitled".)
		 * @param t.window.icon A filepath to an image to use as the window's icon. Not all operating systems support very large icon images. The icon can also be changed with love.window.setIcon. (Default: nil.)
		 * @param t.window.width Sets the window's dimensions. If these flags are set to 0 LÖVE automatically uses the user's desktop dimensions. (Default: 800.)
		 * @param t.window.height Sets the window's dimensions. If these flags are set to 0 LÖVE automatically uses the user's desktop dimensions. (Default: 600.)
		 * @param t.window.borderless Removes all border visuals from the window. Note that the effects may wary between operating systems. (Default: false.)
		 * @param t.window.resizable If set to true this allows the user to resize the game's window. (Default: false.)
		 * @param t.window.minwidth Sets the minimum width and height for the game's window if it can be resized by the user. If you set lower values to window.width and window.height LÖVE will always favor the minimum dimensions set via window.minwidth and window.minheight. (Default: 1.)
		 * @param t.window.minheight Sets the minimum width and height for the game's window if it can be resized by the user. If you set lower values to window.width and window.height LÖVE will always favor the minimum dimensions set via window.minwidth and window.minheight. (Default: 1.)
		 * @param t.window.fullscreen Whether to run the game in fullscreen (true) or windowed (false) mode. The fullscreen can also be toggled via love.window.setFullscreen or love.window.setMode. (Default: false.)
		 * @param t.window.fullscreentype Specifies the type of fullscreen mode to use (normal or desktop). Generally the desktop is recommended, as it is less restrictive than normal mode on some operating systems. (Default: "desktop".)
		 * @param t.window.usedpiscale Sets whetever to enable or disable automatic DPI scaling. (Default: true.)
		 * @param t.window.vsync Enables or deactivates vertical synchronization. Vsync tries to keep the game at a steady framerate and can prevent issues like screen tearing. It is recommended to keep vsync activated if you don't know about the possible implications of turning it off. Before LÖVE 11.0, this value was boolean (true or false). Since LÖVE 11.0, this value is number (1 to enable vsync, 0 to disable vsync, -1 to use adaptive vsync when supported).

Note that in iOS, vertical synchronization is always enabled and cannot be changed. (Default: true.)
		 * @param t.window.depth The number of bits per sample in the depth buffer (16/24/32, default nil) (Default: nil.)
		 * @param t.window.stencil Then number of bits per sample in the depth buffer (generally 8, default nil) (Default: nil.)
		 * @param t.window.msaa The number of samples to use with multi-sampled antialiasing. (Default: 0.)
		 * @param t.window.display The index of the display to show the window in, if multiple monitors are available. (Default: 1.)
		 * @param t.window.highdpi See love.window.getPixelScale, love.window.toPixels, and love.window.fromPixels. It is recommended to keep this option disabled if you can't test your game on a Mac or iOS system with a Retina display, because code will need tweaking to make sure things look correct. (Default: false.)
		 * @param t.window.x Determines the position of the window on the user's screen. Alternatively love.window.setPosition can be used to change the position on the fly. (Default: nil.)
		 * @param t.window.y Determines the position of the window on the user's screen. Alternatively love.window.setPosition can be used to change the position on the fly. (Default: nil.)
		 * @param t.modules Module options.
		 * @param t.modules.audio Enable the audio module. (Default: true.)
		 * @param t.modules.event Enable the event module. (Default: true.)
		 * @param t.modules.graphics Enable the graphics module. (Default: true.)
		 * @param t.modules.image Enable the image module. (Default: true.)
		 * @param t.modules.joystick Enable the joystick module. (Default: true.)
		 * @param t.modules.keyboard Enable the keyboard module. (Default: true.)
		 * @param t.modules.math Enable the math module. (Default: true.)
		 * @param t.modules.mouse Enable the mouse module. (Default: true.)
		 * @param t.modules.physics Enable the physics module. (Default: true.)
		 * @param t.modules.sound Enable the sound module. (Default: true.)
		 * @param t.modules.system Enable the system module. (Default: true.)
		 * @param t.modules.timer Enable the timer module. (Default: true.)
		 * @param t.modules.touch Enable the touch module. (Default: true.)
		 * @param t.modules.video Enable the video module. (Default: true.)
		 * @param t.modules.window Enable the window module. (Default: true.)
		 * @param t.modules.thread Enable the thread module. (Default: true.)
		 */
		conf?: (this: void, config: Config) => void;
		/**
		 * This function is called exactly once at the beginning of the game.
		 *
		 * Overload details:
		 * 1. In LÖVE 11.0, the passed arguments excludes the game name and the fused command-line flag (if exist) when runs from non-fused LÖVE executable. Previous version pass the argument as-is without any filtering.
		 *
		 * @param arg Command-line arguments given to the game.
		 * @param unfilteredArg Unfiltered command-line arguments given to the executable (see #Notes).
		 */
		load?: (this: void) => void;
		/**
		 * Callback function used to update the state of the game every frame.
		 *
		 * @param dt Time since the last update in seconds.
		 */
		update?: (this: void, deltaTime: number) => void;
		/**
		 * Callback function used to draw on the screen every frame.
		 */
		draw?: (this: void) => void;
		/** Return true to cancel a love.event.quit request. */
		/**
		 * Callback function triggered when the game is closed.
		 *
		 * @returns r — Abort quitting. If true, do not close the game.
		 */
		quit?: (this: void) => boolean | void;
		/**
		 * Callback function triggered when a key is pressed.
		 *
		 * Overload details:
		 * 1. Scancodes are keyboard layout-independent, so the scancode 'w' will be generated if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are. Key repeat needs to be enabled with love.keyboard.setKeyRepeat for repeat keypress events to be received. This does not affect love.textinput.
		 * 2. Key repeat needs to be enabled with love.keyboard.setKeyRepeat for repeat keypress events to be received.
		 *
		 * @param key Character of the pressed key. Depending on the overload: Character of the key pressed.
		 * @param scancode The scancode representing the pressed key.
		 * @param isrepeat Whether this keypress event is a repeat. The delay between key repeats depends on the user's system settings.
		 */
		keypressed?: (this: void, key: string, scancode: string, isRepeat: boolean) => void;
		/**
		 * Callback function triggered when a keyboard key is released.
		 *
		 * Overload details:
		 * 1. Scancodes are keyboard layout-independent, so the scancode 'w' will be used if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.
		 *
		 * @param key Character of the released key.
		 * @param scancode The scancode representing the released key.
		 */
		keyreleased?: (this: void, key: string, scancode: string) => void;
		/**
		 * Called when text has been entered by the user. For example if shift-2 is pressed on an American keyboard layout, the text '@' will be generated.
		 *
		 * Overload details:
		 * 1. Although Lua strings can store UTF-8 encoded unicode text just fine, many functions in Lua's string library will not treat the text as you might expect. For example, #text (and string.len(text)) will give the number of ''bytes'' in the string, rather than the number of unicode characters. The Lua wiki and a presentation by one of Lua's creators give more in-depth explanations, with some tips. The utf8 library can be used to operate on UTF-8 encoded unicode text (such as the text argument given in this function.) On Android and iOS, textinput is disabled by default; call love.keyboard.setTextInput to enable it.
		 *
		 * @param text The UTF-8 encoded unicode text.
		 */
		textinput?: (this: void, text: string) => void;
		/**
		 * Called when the candidate text for an IME (Input Method Editor) has changed.
		 *
		 * The candidate text is not the final text that the user will eventually choose. Use love.textinput for that.
		 *
		 * @param text The UTF-8 encoded unicode candidate text.
		 * @param start The start cursor of the selected candidate text.
		 * @param length The length of the selected candidate text. May be 0.
		 */
		textedited?: (this: void, text: string, start: number, length: number) => void;
		/**
		 * Callback function triggered when a mouse button is pressed.
		 *
		 * Overload details:
		 * 1. Use love.wheelmoved to detect mouse wheel motion. It will not register as a button press in version 0.10.0 and newer.
		 *
		 * @param x Mouse x position, in pixels.
		 * @param y Mouse y position, in pixels.
		 * @param button The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
		 * @param istouch True if the mouse button press originated from a touchscreen touch-press.
		 * @param presses The number of presses in a short time frame and small area, used to simulate double, triple clicks
		 */
		mousepressed?: (this: void, x: number, y: number, button: number, isTouch: boolean, presses: number) => void;
		/**
		 * Callback function triggered when a mouse button is released.
		 *
		 * @param x Mouse x position, in pixels.
		 * @param y Mouse y position, in pixels.
		 * @param button The button index that was released. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
		 * @param istouch True if the mouse button release originated from a touchscreen touch-release.
		 * @param presses The number of presses in a short time frame and small area, used to simulate double, triple clicks
		 */
		mousereleased?: (this: void, x: number, y: number, button: number, isTouch: boolean, presses: number) => void;
		/**
		 * Callback function triggered when the mouse is moved.
		 *
		 * Overload details:
		 * 1. If Relative Mode is enabled for the mouse, the '''dx''' and '''dy''' arguments of this callback will update but '''x''' and '''y''' are not guaranteed to.
		 *
		 * @param x The mouse position on the x-axis.
		 * @param y The mouse position on the y-axis.
		 * @param dx The amount moved along the x-axis since the last time love.mousemoved was called.
		 * @param dy The amount moved along the y-axis since the last time love.mousemoved was called.
		 * @param istouch True if the mouse button press originated from a touchscreen touch-press.
		 */
		mousemoved?: (this: void, x: number, y: number, deltaX: number, deltaY: number, isTouch: boolean) => void;
		/**
		 * Callback function triggered when the mouse wheel is moved.
		 *
		 * @param x Amount of horizontal mouse wheel movement. Positive values indicate movement to the right.
		 * @param y Amount of vertical mouse wheel movement. Positive values indicate upward movement.
		 */
		wheelmoved?: (this: void, x: number, y: number) => void;
		/**
		 * Callback function triggered when the touch screen is touched.
		 *
		 * Overload details:
		 * 1. The identifier is only guaranteed to be unique for the specific touch press until love.touchreleased is called with that identifier, at which point it may be reused for new touch presses. The unofficial Android and iOS ports of LÖVE 0.9.2 reported touch positions as normalized values in the range of 1, whereas this API reports positions in pixels.
		 *
		 * @param id The identifier for the touch press.
		 * @param x The x-axis position of the touch press inside the window, in pixels.
		 * @param y The y-axis position of the touch press inside the window, in pixels.
		 * @param dx The x-axis movement of the touch press inside the window, in pixels. This should always be zero.
		 * @param dy The y-axis movement of the touch press inside the window, in pixels. This should always be zero.
		 * @param pressure The amount of pressure being applied. Most touch screens aren't pressure sensitive, in which case the pressure will be 1.
		 */
		touchpressed?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		/**
		 * Callback function triggered when the touch screen stops being touched.
		 *
		 * Overload details:
		 * 1. The identifier is only guaranteed to be unique for the specific touch press until love.touchreleased is called with that identifier, at which point it may be reused for new touch presses. The unofficial Android and iOS ports of LÖVE 0.9.2 reported touch positions as normalized values in the range of 1, whereas this API reports positions in pixels.
		 *
		 * @param id The identifier for the touch press.
		 * @param x The x-axis position of the touch inside the window, in pixels.
		 * @param y The y-axis position of the touch inside the window, in pixels.
		 * @param dx The x-axis movement of the touch inside the window, in pixels.
		 * @param dy The y-axis movement of the touch inside the window, in pixels.
		 * @param pressure The amount of pressure being applied. Most touch screens aren't pressure sensitive, in which case the pressure will be 1.
		 */
		touchreleased?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		/**
		 * Callback function triggered when a touch press moves inside the touch screen.
		 *
		 * Overload details:
		 * 1. The identifier is only guaranteed to be unique for the specific touch press until love.touchreleased is called with that identifier, at which point it may be reused for new touch presses. The unofficial Android and iOS ports of LÖVE 0.9.2 reported touch positions as normalized values in the range of 1, whereas this API reports positions in pixels.
		 *
		 * @param id The identifier for the touch press.
		 * @param x The x-axis position of the touch inside the window, in pixels.
		 * @param y The y-axis position of the touch inside the window, in pixels.
		 * @param dx The x-axis movement of the touch inside the window, in pixels.
		 * @param dy The y-axis movement of the touch inside the window, in pixels.
		 * @param pressure The amount of pressure being applied. Most touch screens aren't pressure sensitive, in which case the pressure will be 1.
		 */
		touchmoved?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		/**
		 * Callback function triggered when a Thread encounters an error.
		 *
		 * @param thread The thread which produced the error.
		 * @param errorstr The error message.
		 */
		threaderror?: (this: void, thread: Thread, error: string) => void;
		/**
		 * Called when a Joystick is connected.
		 *
		 * Overload details:
		 * 1. This callback is also triggered after love.load for every Joystick which was already connected when the game started up.
		 *
		 * @param joystick The newly connected Joystick object.
		 */
		joystickadded?: (this: void, joystick: Joystick) => void;
		/**
		 * Called when a Joystick is disconnected.
		 *
		 * @param joystick The now-disconnected Joystick object.
		 */
		joystickremoved?: (this: void, joystick: Joystick) => void;
		/**
		 * Called when a joystick button is pressed.
		 *
		 * @param joystick The joystick object.
		 * @param button The button number.
		 */
		joystickpressed?: (this: void, joystick: Joystick, button: number) => void;
		/**
		 * Called when a joystick button is released.
		 *
		 * @param joystick The joystick object.
		 * @param button The button number.
		 */
		joystickreleased?: (this: void, joystick: Joystick, button: number) => void;
		/**
		 * Called when a joystick axis moves.
		 *
		 * @param joystick The joystick object.
		 * @param axis The axis number.
		 * @param value The new axis value.
		 */
		joystickaxis?: (this: void, joystick: Joystick, axis: number, value: number) => void;
		/**
		 * Called when a joystick hat direction changes.
		 *
		 * @param joystick The joystick object.
		 * @param hat The hat number.
		 * @param direction The new hat direction.
		 */
		joystickhat?: (this: void, joystick: Joystick, hat: number, direction: JoystickHat) => void;
		/**
		 * Called when a Joystick's virtual gamepad button is pressed.
		 *
		 * @param joystick The joystick object.
		 * @param button The virtual gamepad button.
		 */
		gamepadpressed?: (this: void, joystick: Joystick, button: GamepadButton) => void;
		/**
		 * Called when a Joystick's virtual gamepad button is released.
		 *
		 * @param joystick The joystick object.
		 * @param button The virtual gamepad button.
		 */
		gamepadreleased?: (this: void, joystick: Joystick, button: GamepadButton) => void;
		/**
		 * Called when a Joystick's virtual gamepad axis is moved.
		 *
		 * @param joystick The joystick object.
		 * @param axis The virtual gamepad axis.
		 * @param value The new axis value.
		 */
		gamepadaxis?: (this: void, joystick: Joystick, axis: GamepadAxis, value: number) => void;

		/** Compatibility entry point. Dora remains the only application loop owner. */
		/**
		 * The main function, containing the main loop. A sensible default is used when left out.
		 *
		 * @returns mainLoop — Function which handlers one frame, including events and rendering when called.
		 */
		run(this: void): void;
		}
	}

	const love: Love.Root;
}

declare const loveModule: Love.Root;
export = loveModule;
