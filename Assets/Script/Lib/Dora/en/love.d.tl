-- Enumeration types exported through the root Love API record.
local record LoveEnums
	-- Available values for DrawMode.
	enum DrawMode
		"fill"
		"line"
	end

	-- Available values for ArcMode.
	enum ArcMode
		"open"
		"closed"
		"pie"
	end

	-- Available values for LineStyle.
	enum LineStyle
		"rough"
		"smooth"
	end

	-- Available values for LineJoin.
	enum LineJoin
		"none"
		"miter"
		"bevel"
	end

	-- Available values for BlendMode.
	enum BlendMode
		"alpha"
		"add"
		"subtract"
		"multiply"
		"replace"
		"screen"
		"premultiplied"
	end

	-- Available values for BlendAlphaMode.
	enum BlendAlphaMode
		"alphamultiply"
		"premultiplied"
	end

	-- Available values for AlignMode.
	enum AlignMode
		"left"
		"center"
		"right"
		"justify"
	end

	-- Available values for FilterMode.
	enum FilterMode
		"linear"
		"nearest"
	end

	-- Available values for WrapMode.
	enum WrapMode
		"clamp"
		"clampzero"
		"repeat"
		"mirroredrepeat"
	end

	-- Available values for TextureType.
	enum TextureType
		"2d"
		"array"
		"cube"
		"volume"
	end

	-- Available values for StencilAction.
	enum StencilAction
		"replace"
		"increment"
		"decrement"
		"incrementwrap"
		"decrementwrap"
		"invert"
	end

	-- Available values for CompareMode.
	enum CompareMode
		"less"
		"lequal"
		"equal"
		"gequal"
		"greater"
		"notequal"
		"always"
		"never"
	end

	-- Available values for MeshDrawMode.
	enum MeshDrawMode
		"fan"
		"strip"
		"triangles"
		"points"
	end

	-- Available values for MeshUsage.
	enum MeshUsage
		"stream"
		"dynamic"
		"static"
	end

	-- Available values for VertexDataType.
	enum VertexDataType
		"float"
		"byte"
		"unorm16"
	end

	-- Available values for AttributeStep.
	enum AttributeStep
		"pervertex"
		"perinstance"
	end

	-- Available values for IndexDataType.
	enum IndexDataType
		"uint16"
		"uint32"
	end

	-- Available values for MeshCullMode.
	enum MeshCullMode
		"none"
		"back"
		"front"
	end

	-- Available values for Winding.
	enum Winding
		"cw"
		"ccw"
	end

	-- Available values for ParticleInsertMode.
	enum ParticleInsertMode
		"top"
		"bottom"
		"random"
	end

	-- Available values for ParticleAreaSpreadDistribution.
	enum ParticleAreaSpreadDistribution
		"none"
		"uniform"
		"normal"
		"ellipse"
		"borderellipse"
		"borderrectangle"
	end

	-- Available values for CanvasFormat.
	enum CanvasFormat
		"normal"
		"hdr"
		"r8"
		"rg8"
		"rgba8"
		"srgba8"
		"r16"
		"rg16"
		"rgba16"
		"r16f"
		"rg16f"
		"rgba16f"
		"r32f"
		"rg32f"
		"rgba32f"
		"la8"
		"rgba4"
		"rgb5a1"
		"rgb565"
		"rgb10a2"
		"rg11b10f"
		"stencil8"
		"depth16"
		"depth24"
		"depth32f"
		"depth24stencil8"
		"depth32fstencil8"
	end

	-- Available values for ImagePixelFormat.
	enum ImagePixelFormat
		"r8"
		"rg8"
		"rgba8"
		"r16"
		"rg16"
		"rgba16"
		"r16f"
		"rg16f"
		"rgba16f"
		"r32f"
		"rg32f"
		"rgba32f"
		"rgba4"
		"rgb5a1"
		"rgb565"
		"rgb10a2"
		"rg11b10f"
	end

	-- Available values for CompressedPixelFormat.
	enum CompressedPixelFormat
		"DXT1"
		"DXT3"
		"DXT5"
		"BC4"
		"BC4s"
		"BC5"
		"BC5s"
		"BC6h"
		"BC6hs"
		"BC7"
		"PVR1rgb2"
		"PVR1rgb4"
		"PVR1rgba2"
		"PVR1rgba4"
		"ETC1"
		"ETC2rgb"
		"ETC2rgba"
		"ETC2rgba1"
		"EACr"
		"EACrs"
		"EACrg"
		"EACrgs"
		"ASTC4x4"
		"ASTC5x4"
		"ASTC5x5"
		"ASTC6x5"
		"ASTC6x6"
		"ASTC8x5"
		"ASTC8x6"
		"ASTC8x8"
		"ASTC10x5"
		"ASTC10x6"
		"ASTC10x8"
		"ASTC10x10"
		"ASTC12x10"
		"ASTC12x12"
	end

	-- Available values for MatrixLayout.
	enum MatrixLayout
		"row"
		"column"
	end

	-- Available values for FileType.
	enum FileType
		"file"
		"directory"
	end

	-- Available values for FileMode.
	enum FileMode
		"c"
		"r"
		"w"
		"a"
	end

	-- Available values for OpenFileMode.
	enum OpenFileMode
		"r"
		"w"
		"a"
	end

	-- Available values for BufferMode.
	enum BufferMode
		"none"
		"line"
		"full"
	end

	-- Available values for DataContainer.
	enum DataContainer
		"data"
		"string"
	end

	-- Available values for EncodeFormat.
	enum EncodeFormat
		"hex"
		"base64"
	end

	-- Available values for CompressionFormat.
	enum CompressionFormat
		"zlib"
		"gzip"
		"deflate"
		"lz4"
	end

	-- Available values for HashFunction.
	enum HashFunction
		"md5"
		"sha1"
		"sha224"
		"sha256"
		"sha384"
		"sha512"
	end

	-- Available values for SystemCursor.
	enum SystemCursor
		"arrow"
		"ibeam"
		"wait"
		"crosshair"
		"waitarrow"
		"sizenwse"
		"sizenesw"
		"sizewe"
		"sizens"
		"sizeall"
		"no"
		"hand"
	end

	-- Available values for GamepadButton.
	enum GamepadButton
		"a"
		"b"
		"x"
		"y"
		"back"
		"guide"
		"start"
		"leftstick"
		"rightstick"
		"leftshoulder"
		"rightshoulder"
		"dpup"
		"dpdown"
		"dpleft"
		"dpright"
		"misc1"
		"paddle1"
		"paddle2"
		"paddle3"
		"paddle4"
		"touchpad"
	end

	-- Available values for GamepadAxis.
	enum GamepadAxis
		"leftx"
		"lefty"
		"rightx"
		"righty"
		"triggerleft"
		"triggerright"
	end

	-- Available values for JoystickHat.
	enum JoystickHat
		"c"
		"u"
		"r"
		"d"
		"l"
		"ru"
		"rd"
		"lu"
		"ld"
	end

	-- Available values for JoystickInputType.
	enum JoystickInputType
		"axis"
		"button"
		"hat"
	end

	-- Available values for OS.
	enum OS
		"OS X"
		"Windows"
		"Linux"
		"Android"
		"iOS"
		"UWP"
		"Unknown"
	end

	-- Available values for PowerState.
	enum PowerState
		"unknown"
		"battery"
		"nobattery"
		"charging"
		"charged"
	end

	-- Available values for SourceType.
	enum SourceType
		"static"
		"stream"
		"queue"
	end

	-- Available values for TimeUnit.
	enum TimeUnit
		"seconds"
		"samples"
	end

	-- Available values for DistanceModel.
	enum DistanceModel
		"none"
		"inverse"
		"inverseclamped"
		"linear"
		"linearclamped"
		"exponent"
		"exponentclamped"
	end

	-- Available values for AudioFilterType.
	enum AudioFilterType
		"lowpass"
		"highpass"
		"bandpass"
	end

	-- Available values for AudioEffectType.
	enum AudioEffectType
		"reverb"
		"chorus"
		"distortion"
		"echo"
		"flanger"
		"ringmodulator"
		"compressor"
		"equalizer"
	end

	-- Available values for BodyType.
	enum BodyType
		"static"
		"dynamic"
		"kinematic"
	end
end

local type DrawMode = LoveEnums.DrawMode
local type ArcMode = LoveEnums.ArcMode
local type LineStyle = LoveEnums.LineStyle
local type LineJoin = LoveEnums.LineJoin
local type BlendMode = LoveEnums.BlendMode
local type BlendAlphaMode = LoveEnums.BlendAlphaMode
local type AlignMode = LoveEnums.AlignMode
local type FilterMode = LoveEnums.FilterMode
local type WrapMode = LoveEnums.WrapMode
local type TextureType = LoveEnums.TextureType
local type StencilAction = LoveEnums.StencilAction
local type CompareMode = LoveEnums.CompareMode
local type MeshDrawMode = LoveEnums.MeshDrawMode
local type MeshUsage = LoveEnums.MeshUsage
local type VertexDataType = LoveEnums.VertexDataType
local type AttributeStep = LoveEnums.AttributeStep
local type IndexDataType = LoveEnums.IndexDataType
local type MeshCullMode = LoveEnums.MeshCullMode
local type Winding = LoveEnums.Winding
local type ParticleInsertMode = LoveEnums.ParticleInsertMode
local type ParticleAreaSpreadDistribution = LoveEnums.ParticleAreaSpreadDistribution
local type CanvasFormat = LoveEnums.CanvasFormat
local type ImagePixelFormat = LoveEnums.ImagePixelFormat
local type CompressedPixelFormat = LoveEnums.CompressedPixelFormat
local type MatrixLayout = LoveEnums.MatrixLayout
local type FileType = LoveEnums.FileType
local type FileMode = LoveEnums.FileMode
local type OpenFileMode = LoveEnums.OpenFileMode
local type BufferMode = LoveEnums.BufferMode
local type DataContainer = LoveEnums.DataContainer
local type EncodeFormat = LoveEnums.EncodeFormat
local type CompressionFormat = LoveEnums.CompressionFormat
local type HashFunction = LoveEnums.HashFunction
local type SystemCursor = LoveEnums.SystemCursor
local type GamepadButton = LoveEnums.GamepadButton
local type GamepadAxis = LoveEnums.GamepadAxis
local type JoystickHat = LoveEnums.JoystickHat
local type JoystickInputType = LoveEnums.JoystickInputType
local type OS = LoveEnums.OS
local type PowerState = LoveEnums.PowerState
local type SourceType = LoveEnums.SourceType
local type TimeUnit = LoveEnums.TimeUnit
local type DistanceModel = LoveEnums.DistanceModel
local type AudioFilterType = LoveEnums.AudioFilterType
local type AudioEffectType = LoveEnums.AudioEffectType
local type BodyType = LoveEnums.BodyType

-- Drawable image type.
local record Image

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Image): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Image): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Image, type_name: string): boolean

	-- Gets the width of the Texture.
	-- @return (number) The width of the Texture.
	getWidth: function(self: Image): number

	-- Gets the height of the Texture.
	-- @return (number) The height of the Texture.
	getHeight: function(self: Image): number

	-- Gets the width and height of the Texture.
	-- @return (number) The width of the Texture.
	-- @return (number) The height of the Texture.
	getDimensions: function(self: Image): number, number

	-- Gets the width in pixels of the Texture.
	-- DPI scale factor, rather than pixels. Use getWidth for calculations related to drawing the texture (calculating an
	-- origin offset, for example), and getPixelWidth only when dealing specifically with pixels, for example when using
	-- Canvas:newImageData.
	-- @return (integer) The width of the Texture, in pixels.
	getPixelWidth: function(self: Image): integer

	-- Gets the height in pixels of the Texture.
	-- DPI scale factor, rather than pixels. Use getHeight for calculations related to drawing the texture (calculating
	-- an origin offset, for example), and getPixelHeight only when dealing specifically with pixels, for example when
	-- using Canvas:newImageData.
	-- @return (integer) The height of the Texture, in pixels.
	getPixelHeight: function(self: Image): integer

	-- Gets the width and height in pixels of the Texture.
	-- Texture:getDimensions gets the dimensions of the texture in units scaled by the texture's DPI scale factor, rather
	-- than pixels. Use getDimensions for calculations related to drawing the texture (calculating an origin offset, for
	-- example), and getPixelDimensions only when dealing specifically with pixels, for example when using
	-- Canvas:newImageData.
	-- @return (integer) The width of the Texture, in pixels.
	-- @return (integer) The height of the Texture, in pixels.
	getPixelDimensions: function(self: Image): integer, integer

	-- Gets the DPI scale factor of the Texture.
	-- The DPI scale factor represents relative pixel density. A DPI scale factor of 2 means the texture has twice the
	-- pixel density in each dimension (4 times as many pixels in the same area) compared to a texture with a DPI scale
	-- factor of 1.
	-- For example, a texture with pixel dimensions of 100x100 with a DPI scale factor of 2 will be drawn as if it was
	-- 50x50. This is useful with high-dpi / retina displays to easily allow swapping out higher or lower pixel density
	-- Images and Canvases without needing any extra manual scaling logic.
	-- @return (number) The DPI scale factor of the Texture.
	getDPIScale: function(self: Image): number

	-- Gets the type of the Texture.
	-- @return (TextureType) The type of the Texture.
	getTextureType: function(self: Image): TextureType

	-- Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.
	-- @return (integer) The depth of the volume Texture.
	getDepth: function(self: Image): integer

	-- Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.
	-- @return (integer) The number of layers in the Array Texture.
	getLayerCount: function(self: Image): integer

	-- Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will return
	-- 1.
	-- @return (integer) The number of mipmaps in the Texture.
	getMipmapCount: function(self: Image): integer

	-- Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
	-- @return (FilterMode | nil) The filter mode used in between mipmap levels. nil if mipmap filtering is not enabled.
	-- @return (number) Value used to determine whether the image should use more or less detailed mipmap levels than normal when drawing.
	getMipmapFilter: function(self: Image): FilterMode | nil, number

	-- Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
	--
	-- Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.
	--
	-- In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.
	--
	-- Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.
	setMipmapFilter: function(self: Image)

	-- Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
	--
	-- Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.
	--
	-- In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.
	--
	-- Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.
	-- @param filter (FilterMode) The filter mode to use in between mipmap levels. 'nearest' will often give better performance.
	-- @param sharpness (number) A positive sharpness value makes the texture use a more detailed mipmap level when drawing, at the expense of performance. A negative value does the reverse. (Default: 0.)
	setMipmapFilter: function(self: Image, filter: FilterMode, sharpness?: number)

	-- Gets the pixel format of the Texture.
	-- @return (ImagePixelFormat) The pixel format the Texture was created with.
	getFormat: function(self: Image): ImagePixelFormat

	-- Gets whether the Image was created from CompressedData.
	-- Compressed images take up less space in VRAM, and drawing a compressed image will generally be more efficient than
	-- drawing one created from raw pixel data.
	-- @return (boolean) Whether the Image is stored as a compressed texture on the GPU.
	isCompressed: function(self: Image): boolean

	-- Gets whether the Image was created with the linear (non-gamma corrected) flag set to true.
	-- This method always returns false when gamma-correct rendering is not enabled.
	-- @return (boolean) Whether the Image's internal pixel format is linear (not gamma corrected), when gamma-correct rendering is enabled.
	isFormatLinear: function(self: Image): boolean

	-- Replace the contents of an Image.
	-- @param data (any) The new ImageData to replace the contents with.
	-- @param slice (integer) Which cubemap face, array index, or volume layer to replace, if applicable. (Default: 1.)
	-- @param mipmap (integer) The mimap level to replace, if the Image has mipmaps. (Default: 1.)
	-- @param x (integer) The x-offset in pixels from the top-left of the image to replace. The given ImageData's width plus this value must not be greater than the pixel width of the Image's specified mipmap level. (Default: 0.)
	-- @param y (integer) The y-offset in pixels from the top-left of the image to replace. The given ImageData's height plus this value must not be greater than the pixel height of the Image's specified mipmap level. (Default: 0.)
	-- @param reload_mipmaps (boolean) Whether to generate new mipmaps after replacing the Image's pixels. True by default if the Image was created with automatically generated mipmaps, false by default otherwise. (Default: false.)
	replacePixels: function(self: Image, data: any, slice?: integer, mipmap?: integer, x?: integer, y?: integer, reload_mipmaps?: boolean)

	-- Gets whether the Texture can be drawn and sent to a Shader.
	-- Canvases created with stencil and/or depth PixelFormats are not readable by default, unless readable=true is
	-- specified in the settings table passed into love.graphics.newCanvas.
	-- Non-readable Canvases can still be rendered to.
	-- @return (boolean) Whether the Texture is readable.
	isReadable: function(self: Image): boolean

	-- Gets the comparison mode used when sampling from a depth texture in a shader.
	-- Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.
	-- @return (CompareMode | nil) The comparison mode used when sampling from this texture in a shader, or nil if setDepthSampleMode has not been called on this Texture. (Default: nil.)
	getDepthSampleMode: function(self: Image): CompareMode | nil

	-- Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison modes are
	-- advanced low-level functionality typically used with shadow mapping in 3D.
	-- When using a depth texture with a comparison mode set in a shader, it must be declared as a sampler2DShadow and
	-- used in a GLSL 3 Shader. The result of accessing the texture in the shader will return a float between 0 and 1,
	-- proportional to the number of samples (up to 4 samples will be used if bilinear filtering is enabled) that passed
	-- the test set by the comparison operation.
	-- Depth texture comparison can only be used with readable depth-formatted Canvases.
	-- @param mode (CompareMode) The comparison mode used when sampling from this texture in a shader.
	setDepthSampleMode: function(self: Image, mode?: CompareMode)

	-- Sets the filter mode of the Texture.
	-- @param min_filter (FilterMode) Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).
	-- @param mag_filter (FilterMode) Filter mode to use when magnifying the texture (rendering it at a larger size on-screen than its size in pixels). (Default: min.)
	-- @param anisotropy (number) Maximum amount of anisotropic filtering to use. (Default: 1.)
	setFilter: function(self: Image, min_filter: FilterMode, mag_filter?: FilterMode, anisotropy?: number)

	-- Gets the filter mode of the Texture.
	-- @return (FilterMode) Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).
	-- @return (FilterMode) Filter mode to use when magnifying the texture (rendering it at a smaller size on-screen than its size in pixels).
	-- @return (number) Maximum amount of anisotropic filtering used.
	getFilter: function(self: Image): FilterMode, FilterMode, number

	-- Sets the wrapping properties of a Texture.
	-- This function sets the way a Texture is repeated when it is drawn with a Quad that is larger than the texture's
	-- extent, or when a custom Shader is used which uses texture coordinates outside of [0, 1]. A texture may be clamped
	-- or set to repeat in both horizontal and vertical directions.
	-- Clamped textures appear only once (with the edges of the texture stretching to fill the extent of the Quad),
	-- whereas repeated ones repeat as many times as there is room in the Quad.
	-- @param horizontal (WrapMode) Horizontal wrapping mode of the texture.
	-- @param vertical (WrapMode) Vertical wrapping mode of the texture. (Default: horiz.)
	-- @param depth (WrapMode) Wrapping mode for the z-axis of a Volume texture. (Default: horiz.)
	setWrap: function(self: Image, horizontal: WrapMode, vertical?: WrapMode, depth?: WrapMode): boolean

	-- Gets the wrapping properties of a Texture.
	-- This function returns the currently set horizontal and vertical wrapping modes for the texture.
	-- @return (WrapMode) Horizontal wrapping mode of the texture.
	-- @return (WrapMode) Vertical wrapping mode of the texture.
	-- @return (WrapMode) Wrapping mode for the z-axis of a Volume texture.
	getWrap: function(self: Image): WrapMode, WrapMode, WrapMode
end

-- An object which decodes, streams, and controls Videos.
local record VideoStream

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: VideoStream): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: VideoStream): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: VideoStream, type_name: string): boolean

	-- Plays the VideoStream.
	play: function(self: VideoStream)

	-- Pauses the VideoStream.
	pause: function(self: VideoStream)

	-- Sets the current playback position of the VideoStream.
	-- @param seconds (number) The time in seconds since the beginning of the VideoStream.
	seek: function(self: VideoStream, seconds: number)

	-- Rewinds the VideoStream. Synonym to VideoStream:seek(0).
	rewind: function(self: VideoStream)

	-- Gets the current playback position of the VideoStream.
	-- @return (number) The number of seconds sionce the beginning of the VideoStream.
	tell: function(self: VideoStream): number

	-- Gets whether the VideoStream is playing.
	-- @return (boolean) Whether the VideoStream is playing.
	isPlaying: function(self: VideoStream): boolean

	-- Gets the filename of the VideoStream.
	-- @param source (Source) The source parameter.
	-- @return (string) The filename of the VideoStream
	getFilename: function(self: VideoStream): string
	setSync: function(self: VideoStream, source?: Source)
end

local record Video

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Video): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Video): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Video, type_name: string): boolean

	-- Gets the VideoStream object used for decoding and controlling the video.
	-- @return (VideoStream) The VideoStream used for decoding and controlling the video.
	getStream: function(self: Video): VideoStream

	-- Gets the audio Source used for playing back the video's audio. May return nil if the video has no audio, or if
	-- Video:setSource is called with a nil argument.
	-- @return (Source or nil) The audio Source used for audio playback, or nil if the video has no audio.
	getSource: function(self: Video): Source | nil

	-- Sets the audio Source used for playing back the video's audio. The audio Source also controls playback speed and
	-- synchronization.
	-- @param source (Source) The audio Source used for audio playback, or nil to disable audio synchronization. (Default: nil.)
	setSource: function(self: Video, source?: Source)

	-- Gets the width of the Video in pixels.
	-- @return (integer) The width of the Video.
	getWidth: function(self: Video): integer

	-- Gets the height of the Video in pixels.
	-- @return (integer) The height of the Video.
	getHeight: function(self: Video): integer

	-- Gets the width and height of the Video in pixels.
	-- @return (integer) The width of the Video.
	-- @return (integer) The height of the Video.
	getDimensions: function(self: Video): integer, integer
	getPixelWidth: function(self: Video): integer
	getPixelHeight: function(self: Video): integer
	getPixelDimensions: function(self: Video): integer, integer

	-- Sets the scaling filters used when drawing the Video.
	-- @param min_filter (FilterMode) The filter mode used when scaling the Video down.
	-- @param mag_filter (FilterMode) The filter mode used when scaling the Video up.
	-- @param anisotropy (number) Maximum amount of anisotropic filtering used. (Default: 1.)
	setFilter: function(self: Video, min_filter: FilterMode, mag_filter?: FilterMode, anisotropy?: number)

	-- Gets the scaling filters used when drawing the Video.
	-- @return (FilterMode) The filter mode used when scaling the Video down.
	-- @return (FilterMode) The filter mode used when scaling the Video up.
	-- @return (number) Maximum amount of anisotropic filtering used.
	getFilter: function(self: Video): FilterMode, FilterMode, number
end

-- This module is responsible for decoding, controlling, and streaming video files.
local record VideoModule

	-- Creates a new VideoStream. Currently only Ogg Theora video files are supported. VideoStreams can't draw videos,
	-- see love.graphics.newVideo for that.
	-- @param filename (string) The file path to the Ogg Theora video file.
	-- @return (VideoStream) A new VideoStream.
	newVideoStream: function(filename: string): VideoStream
end

-- A Canvas is used for off-screen rendering. Think of it as an invisible screen that you can draw to, but
-- that will not be visible until you draw it to the actual visible screen. It is also known as "render to
-- texture".
local record Canvas

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Canvas): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Canvas): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Canvas, type_name: string): boolean

	-- Gets the width of the Texture.
	-- @return (integer) The width of the Texture.
	getWidth: function(self: Canvas): integer

	-- Gets the height of the Texture.
	-- @return (integer) The height of the Texture.
	getHeight: function(self: Canvas): integer

	-- Gets the width and height of the Texture.
	-- @return (integer) The width of the Texture.
	-- @return (integer) The height of the Texture.
	getDimensions: function(self: Canvas): integer, integer

	-- Gets the width in pixels of the Texture.
	-- DPI scale factor, rather than pixels. Use getWidth for calculations related to drawing the texture (calculating an
	-- origin offset, for example), and getPixelWidth only when dealing specifically with pixels, for example when using
	-- Canvas:newImageData.
	-- @return (integer) The width of the Texture, in pixels.
	getPixelWidth: function(self: Canvas): integer

	-- Gets the height in pixels of the Texture.
	-- DPI scale factor, rather than pixels. Use getHeight for calculations related to drawing the texture (calculating
	-- an origin offset, for example), and getPixelHeight only when dealing specifically with pixels, for example when
	-- using Canvas:newImageData.
	-- @return (integer) The height of the Texture, in pixels.
	getPixelHeight: function(self: Canvas): integer

	-- Gets the width and height in pixels of the Texture.
	-- Texture:getDimensions gets the dimensions of the texture in units scaled by the texture's DPI scale factor, rather
	-- than pixels. Use getDimensions for calculations related to drawing the texture (calculating an origin offset, for
	-- example), and getPixelDimensions only when dealing specifically with pixels, for example when using
	-- Canvas:newImageData.
	-- @return (integer) The width of the Texture, in pixels.
	-- @return (integer) The height of the Texture, in pixels.
	getPixelDimensions: function(self: Canvas): integer, integer

	-- Gets the DPI scale factor of the Texture.
	-- The DPI scale factor represents relative pixel density. A DPI scale factor of 2 means the texture has twice the
	-- pixel density in each dimension (4 times as many pixels in the same area) compared to a texture with a DPI scale
	-- factor of 1.
	-- For example, a texture with pixel dimensions of 100x100 with a DPI scale factor of 2 will be drawn as if it was
	-- 50x50. This is useful with high-dpi / retina displays to easily allow swapping out higher or lower pixel density
	-- Images and Canvases without needing any extra manual scaling logic.
	-- @return (number) The DPI scale factor of the Texture.
	getDPIScale: function(self: Canvas): number

	-- Gets the pixel format of the Texture.
	-- @return (CanvasFormat) The pixel format the Texture was created with.
	getFormat: function(self: Canvas): CanvasFormat

	-- Gets the number of multisample antialiasing (MSAA) samples used when drawing to the Canvas.
	-- This may be different than the number used as an argument to love.graphics.newCanvas if the system running LÖVE
	-- doesn't support that number.
	-- @return (integer) The number of multisample antialiasing samples used by the canvas when drawing to it.
	getMSAA: function(self: Canvas): integer

	-- Gets the type of the Texture.
	-- @return (TextureType) The type of the Texture.
	getTextureType: function(self: Canvas): TextureType

	-- Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.
	-- @return (integer) The depth of the volume Texture.
	getDepth: function(self: Canvas): integer

	-- Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.
	-- @return (integer) The number of layers in the Array Texture.
	getLayerCount: function(self: Canvas): integer

	-- Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will return
	-- 1.
	-- @return (integer) The number of mipmaps in the Texture.
	getMipmapCount: function(self: Canvas): integer

	-- Gets the MipmapMode this Canvas was created with.
	-- @return (string) The mipmap mode this Canvas was created with.
	getMipmapMode: function(self: Canvas): string

	-- Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
	-- @return (FilterMode | nil) The filter mode used in between mipmap levels. nil if mipmap filtering is not enabled.
	-- @return (number) Value used to determine whether the image should use more or less detailed mipmap levels than normal when drawing.
	getMipmapFilter: function(self: Canvas): FilterMode | nil, number

	-- Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
	--
	-- Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.
	--
	-- In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.
	--
	-- Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.
	setMipmapFilter: function(self: Canvas)

	-- Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
	--
	-- Mipmapping is useful when drawing a texture at a reduced scale. It can improve performance and reduce aliasing issues.
	--
	-- In created with the mipmaps flag enabled for the mipmap filter to have any effect. In versions prior to 0.10.0 it's best to call this method directly after creating the image with love.graphics.newImage, to avoid bugs in certain graphics drivers.
	--
	-- Due to hardware restrictions and driver bugs, in versions prior to 0.10.0 images that weren't loaded from a CompressedData must have power-of-two dimensions (64x64, 512x256, etc.) to use mipmaps.
	-- @param filter (FilterMode) The filter mode to use in between mipmap levels. 'nearest' will often give better performance.
	-- @param sharpness (number) A positive sharpness value makes the texture use a more detailed mipmap level when drawing, at the expense of performance. A negative value does the reverse. (Default: 0.)
	setMipmapFilter: function(self: Canvas, filter: FilterMode, sharpness?: number)

	-- Gets the comparison mode used when sampling from a depth texture in a shader.
	-- Depth texture comparison modes are advanced low-level functionality typically used with shadow mapping in 3D.
	-- @return (CompareMode | nil) The comparison mode used when sampling from this texture in a shader, or nil if setDepthSampleMode has not been called on this Texture. (Default: nil.)
	getDepthSampleMode: function(self: Canvas): CompareMode | nil

	-- Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison modes are
	-- advanced low-level functionality typically used with shadow mapping in 3D.
	-- When using a depth texture with a comparison mode set in a shader, it must be declared as a sampler2DShadow and
	-- used in a GLSL 3 Shader. The result of accessing the texture in the shader will return a float between 0 and 1,
	-- proportional to the number of samples (up to 4 samples will be used if bilinear filtering is enabled) that passed
	-- the test set by the comparison operation.
	-- Depth texture comparison can only be used with readable depth-formatted Canvases.
	-- @param mode (CompareMode) The comparison mode used when sampling from this texture in a shader.
	setDepthSampleMode: function(self: Canvas, mode?: CompareMode)

	-- Generates mipmaps for the Canvas, based on the contents of the highest-resolution mipmap level.
	-- The Canvas must be created with mipmaps set to a MipmapMode other than 'none' for this function to work. It should
	-- only be called while the Canvas is not the active render target.
	-- If the mipmap mode is set to 'auto', this function is automatically called inside love.graphics.setCanvas when
	-- switching from this Canvas to another Canvas or to the main screen.
	generateMipmaps: function(self: Canvas)

	-- Render to the Canvas using a function.
	-- This is a shortcut to love.graphics.setCanvas:
	-- canvas:renderTo( func )
	-- is the same as
	-- love.graphics.setCanvas( canvas )
	-- func()
	-- love.graphics.setCanvas()
	-- @param callback (function) A function performing drawing operations.
	renderTo: function(self: Canvas, callback: function())

	-- Gets whether the Texture can be drawn and sent to a Shader.
	-- Canvases created with stencil and/or depth PixelFormats are not readable by default, unless readable=true is
	-- specified in the settings table passed into love.graphics.newCanvas.
	-- Non-readable Canvases can still be rendered to.
	-- @return (boolean) Whether the Texture is readable.
	isReadable: function(self: Canvas): boolean

	-- Generates ImageData from the contents of the Canvas.
	-- @param slice (integer) The cubemap face index, array index, or depth layer for cubemap, array, or volume type Canvases, respectively. This argument is ignored for regular 2D canvases.
	-- @param mipmap (integer) The mipmap index to use, for Canvases with mipmaps. (Default: 1.)
	-- @param x (integer) The x-axis of the top-left corner (in pixels) of the area within the Canvas to capture.
	-- @param y (integer) The y-axis of the top-left corner (in pixels) of the area within the Canvas to capture.
	-- @param width (integer) The width in pixels of the area within the Canvas to capture.
	-- @param height (integer) The height in pixels of the area within the Canvas to capture.
	-- @return (any) The new ImageData made from the Canvas' contents.
	newImageData: function(self: Canvas, slice?: integer, mipmap?: integer, x?: integer, y?: integer, width?: integer, height?: integer): any

	-- Sets the filter mode of the Texture.
	-- @param min_filter (FilterMode) Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).
	-- @param mag_filter (FilterMode) Filter mode to use when magnifying the texture (rendering it at a larger size on-screen than its size in pixels). (Default: min.)
	-- @param anisotropy (number) Maximum amount of anisotropic filtering to use. (Default: 1.)
	setFilter: function(self: Canvas, min_filter: FilterMode, mag_filter?: FilterMode, anisotropy?: number)

	-- Gets the filter mode of the Texture.
	-- @return (FilterMode) Filter mode to use when minifying the texture (rendering it at a smaller size on-screen than its size in pixels).
	-- @return (FilterMode) Filter mode to use when magnifying the texture (rendering it at a smaller size on-screen than its size in pixels).
	-- @return (number) Maximum amount of anisotropic filtering used.
	getFilter: function(self: Canvas): FilterMode, FilterMode, number

	-- Sets the wrapping properties of a Texture.
	-- This function sets the way a Texture is repeated when it is drawn with a Quad that is larger than the texture's
	-- extent, or when a custom Shader is used which uses texture coordinates outside of [0, 1]. A texture may be clamped
	-- or set to repeat in both horizontal and vertical directions.
	-- Clamped textures appear only once (with the edges of the texture stretching to fill the extent of the Quad),
	-- whereas repeated ones repeat as many times as there is room in the Quad.
	-- @param horizontal (WrapMode) Horizontal wrapping mode of the texture.
	-- @param vertical (WrapMode) Vertical wrapping mode of the texture. (Default: horiz.)
	-- @param depth (WrapMode) Wrapping mode for the z-axis of a Volume texture. (Default: horiz.)
	setWrap: function(self: Canvas, horizontal: WrapMode, vertical?: WrapMode, depth?: WrapMode): boolean

	-- Gets the wrapping properties of a Texture.
	-- This function returns the currently set horizontal and vertical wrapping modes for the texture.
	-- @return (WrapMode) Horizontal wrapping mode of the texture.
	-- @return (WrapMode) Vertical wrapping mode of the texture.
	-- @return (WrapMode) Wrapping mode for the z-axis of a Volume texture.
	getWrap: function(self: Canvas): WrapMode, WrapMode, WrapMode
end

local record CanvasSettings
	dpiscale: number
	msaa: integer
	format: string
	type: string
	readable: boolean
	mipmaps: string
end

local record WindowConfig
	title: string
	width: integer
	height: integer
	fullscreen: boolean
	display: integer
	highdpi: boolean
	resizable: boolean
	vsync: integer
end

local record Config
	version: string
	title: string
	identity: string
	window: WindowConfig
end

local record GraphicsSystemLimits
	pointsize: number
	texturesize: number
	volumetexturesize: number
	cubetexturesize: number
	texturelayers: number
	multicanvas: number
	canvasmsaa: number
	anisotropy: number
end

local record GraphicsStats
	drawcalls: integer
	drawcallsbatched: integer
	canvasswitches: integer
	shaderswitches: integer
	canvases: integer
	images: integer
	fonts: integer
	texturememory: integer
end

local record GraphicsFeatures
	multicanvasformats: boolean
	clampzero: boolean
	lighten: boolean
	fullnpot: boolean
	pixelshaderhighp: boolean
	shaderderivatives: boolean
	glsl3: boolean
	instancing: boolean
end

local record LayeredImageSettings
	mipmaps: boolean
	linear: boolean
	dpiscale: number
end

-- Defines the shape of characters that can be drawn onto the screen.
local record Font

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Font): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Font): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Font, type_name: string): boolean

	-- Determines the maximum width (accounting for newlines) taken by the given string.
	-- @param text (string) A string.
	-- @return (number) The width of the text.
	getWidth: function(self: Font, text: string): number

	-- Gets the height of the Font.
	-- The height of the font is the size including any spacing; the height which it will need.
	-- @return (number) The height of the Font in pixels.
	getHeight: function(self: Font): number

	-- Gets the baseline of the Font.
	-- Most scripts share the notion of a baseline: an imaginary horizontal line on which characters rest. In some
	-- scripts, parts of glyphs lie below the baseline.
	-- @return (number) The baseline of the Font in pixels.
	getBaseline: function(self: Font): number

	-- Gets the ascent of the Font.
	-- The ascent spans the distance between the baseline and the top of the glyph that reaches farthest from the
	-- baseline.
	-- @return (number) The ascent of the Font in pixels.
	getAscent: function(self: Font): number

	-- Gets the descent of the Font.
	-- The descent spans the distance between the baseline and the lowest descending glyph in a typeface.
	-- @return (number) The descent of the Font in pixels.
	getDescent: function(self: Font): number

	-- Gets whether the Font can render a character or string.
	-- @param text_or_codepoint (string or integer) A UTF-8 encoded unicode string.
	-- @param ... (string or integer) The ... parameter.
	-- @return (boolean) Whether the font can render all the UTF-8 characters in the string. Depending on the overload: Whether the font can render all the glyphs represented by the characters. Depending on the overload: Whether the font can render all the glyphs represented by the codepoint numbers.
	hasGlyphs: function(self: Font, text_or_codepoint: string | integer, ...: string | integer): boolean

	-- Gets the kerning between two characters in the Font.
	-- Kerning is normally handled automatically in love.graphics.print, Text objects, Font:getWidth, Font:getWrap, etc.
	-- This function is useful when stitching text together manually.
	-- @param left (string or integer) The left character. Depending on the overload: The unicode number for the left glyph.
	-- @param right (string or integer) The right character. Depending on the overload: The unicode number for the right glyph.
	-- @return (number) The kerning amount to add to the spacing between the two characters. May be negative.
	getKerning: function(self: Font, left: string | integer, right: string | integer): number

	-- Sets the fallback fonts. When the Font doesn't contain a glyph, it will substitute the glyph from the next
	-- subsequent fallback Fonts. This is akin to setting a 'font stack' in Cascading Style Sheets (CSS).
	-- Overload details:
	--   1. If this is called it should be before love.graphics.print, Font:getWrap, and other Font methods which use
	--      glyph positioning information are called. Every fallback Font must be created from the same file type as the
	--      primary Font. For example, a Font created from a .ttf file can only use fallback Fonts that were created from
	--      .ttf files.
	-- @param ... (Font) The ... parameter.
	setFallbacks: function(self: Font, ...: Font)

	-- Sets the line height.
	-- When rendering the font in lines the actual height will be determined by the line height multiplied by the height
	-- of the font. The default is 1.0.
	-- @param height (number) The new line height.
	setLineHeight: function(self: Font, height: number)

	-- Gets the line height.
	-- This will be the value previously set by Font:setLineHeight, or 1.0 by default.
	-- @return (number) The current line height.
	getLineHeight: function(self: Font): number

	-- Gets the DPI scale factor of the Font.
	-- The DPI scale factor represents relative pixel density. A DPI scale factor of 2 means the font's glyphs have twice
	-- the pixel density in each dimension (4 times as many pixels in the same area) compared to a font with a DPI scale
	-- factor of 1.
	-- The font size of TrueType fonts is scaled internally by the font's specified DPI scale factor. By default, LÖVE
	-- uses the screen's DPI scale factor when creating TrueType fonts.
	-- @return (number) The DPI scale factor of the Font.
	getDPIScale: function(self: Font): number

	-- Gets the filter mode for a font.
	-- @return (FilterMode) Filter mode used when minifying the font.
	-- @return (FilterMode) Filter mode used when magnifying the font.
	-- @return (number) Maximum amount of anisotropic filtering used.
	getFilter: function(self: Font): FilterMode, FilterMode, number

	-- Sets the filter mode for a font.
	-- @param min (FilterMode) How to scale a font down.
	-- @param mag (FilterMode) How to scale a font up.
	-- @param anisotropy (number) Maximum amount of anisotropic filtering used. (Default: 1.)
	setFilter: function(self: Font, min: FilterMode, mag?: FilterMode, anisotropy?: number)

	-- Gets formatting information for text, given a wrap limit.
	-- This function accounts for newlines correctly (i.e. '\n').
	-- @param text (string) The text that will be wrapped.
	-- @param wrap_limit (number) The maximum width in pixels of each line that ''text'' is allowed before wrapping.
	-- @return (number) The maximum width of the wrapped text.
	-- @return ({string}) A sequence containing each line of text that was wrapped.
	getWrap: function(self: Font, text: string, wrap_limit: number): number, {string}
end

-- Drawable text.
local record Text

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Text): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Text, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Text): boolean

	-- Replaces the contents of the Text object with a new unformatted string.
	-- @param text (string) The new string of text to use.
	set: function(self: Text, text: string)

	-- Replaces the contents of the Text object with a new unformatted string.
	-- @param text ({string | Color}) A table containing colors and strings to use as the new text, in the form of {color1, string1, color2, string2, ...}.
	set: function(self: Text, text: {string | Color})

	-- Replaces the contents of the Text object with a new formatted string.
	-- @param text (string) The new string of text to use.
	-- @param wrap_limit (number) The maximum width in pixels of the text before it gets automatically wrapped to a new line.
	-- @param align (AlignMode) The alignment of the text.
	setf: function(self: Text, text: string, wrap_limit: number, align: AlignMode)

	-- Replaces the contents of the Text object with a new formatted string.
	-- @param text ({string | Color}) A table containing colors and strings to use as the new text, in the form of {color1, string1, color2, string2, ...}.
	-- @param wrap_limit (number) The maximum width in pixels of the text before it gets automatically wrapped to a new line.
	-- @param align (AlignMode) The alignment of the text.
	setf: function(self: Text, text: {string | Color}, wrap_limit: number, align: AlignMode)

	-- Adds additional colored text to the Text object at the specified position.
	-- @param text (ColoredText) The text to add to the object.
	-- @param transform (Transform) The position of the new text on the x-axis. (Default: 0.)
	-- @return (integer) index — An index number that can be used with Text:getWidth or Text:getHeight.
	add: function(self: Text, text: ColoredText, transform: Transform): integer

	-- Adds additional colored text to the Text object at the specified position.
	-- @param text (ColoredText) A table containing colors and strings to add to the object, in the form of {color1, string1, color2, string2, ...}.
	-- @param x (number) The position of the new text on the x-axis. (Default: 0.)
	-- @param y (number) The position of the new text on the y-axis. (Default: 0.)
	-- @param angle (number) The orientation of the new text in radians. (Default: 0.)
	-- @param scale_x (number) Scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) Scale factor on the y-axis. (Default: sx.)
	-- @param origin_x (number) Origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) Origin offset on the y-axis. (Default: 0.)
	-- @param shear_x (number) Shearing / skew factor on the x-axis. (Default: 0.)
	-- @param shear_y (number) Shearing / skew factor on the y-axis. (Default: 0.)
	-- @return (integer) index — An index number that can be used with Text:getWidth or Text:getHeight.
	add: function(self: Text, text: ColoredText, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- Adds additional formatted / colored text to the Text object at the specified position.
	--
	-- The word wrap limit is applied before any scaling, rotation, and other coordinate transformations. Therefore the amount of text per line stays constant given the same wrap limit, even if the scale arguments change.
	-- @param text (ColoredText) The text to add to the object.
	-- @param wrap_limit (number) The maximum width in pixels of the text before it gets automatically wrapped to a new line.
	-- @param align (AlignMode) The alignment of the text.
	-- @param transform (Transform) The position of the new text (x-axis).
	-- @return (integer) index — An index number that can be used with Text:getWidth or Text:getHeight.
	addf: function(self: Text, text: ColoredText, wrap_limit: number, align: AlignMode, transform: Transform): integer

	-- Adds additional formatted / colored text to the Text object at the specified position.
	--
	-- The word wrap limit is applied before any scaling, rotation, and other coordinate transformations. Therefore the amount of text per line stays constant given the same wrap limit, even if the scale arguments change.
	-- @param text (ColoredText) A table containing colors and strings to add to the object, in the form of {color1, string1, color2, string2, ...}.
	-- @param wrap_limit (number) The maximum width in pixels of the text before it gets automatically wrapped to a new line.
	-- @param align (AlignMode) The alignment of the text.
	-- @param x (number) The position of the new text (x-axis).
	-- @param y (number) The position of the new text (y-axis).
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shearing / skew factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shearing / skew factor (y-axis). (Default: 0.)
	-- @return (integer) index — An index number that can be used with Text:getWidth or Text:getHeight.
	addf: function(self: Text, text: ColoredText, wrap_limit: number, align: AlignMode, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- Clears the contents of the Text object.
	clear: function(self: Text)

	-- Replaces the Font used with the text.
	-- @param font (Font) The new font to use with this Text object.
	setFont: function(self: Text, font: Font)

	-- Gets the Font used with the Text object.
	-- @return (Font) The font used with this Text object.
	getFont: function(self: Text): Font

	-- Gets the width of the text in pixels.
	-- @return (number) width — The width of the text. If multiple sub-strings have been added with Text:add, the width of the last sub-string is returned.
	getWidth: function(self: Text): number

	-- Gets the width of the text in pixels.
	-- @param index (integer) An index number returned by Text:add or Text:addf.
	-- @return (number) The width of the sub-string (before scaling and other transformations).
	getWidth: function(self: Text, index: integer): number

	-- Gets the height of the text in pixels.
	-- @return (number) height  — The height of the text. If multiple sub-strings have been added with Text:add, the height of the last sub-string is returned.
	getHeight: function(self: Text): number

	-- Gets the height of the text in pixels.
	-- @param index (integer) An index number returned by Text:add or Text:addf.
	-- @return (number) height  — The height of the text. If multiple sub-strings have been added with Text:add, the height of the last sub-string is returned.
	getHeight: function(self: Text, index: integer): number

	-- Gets the width and height of the text in pixels.
	-- @return (number) width — The width of the text. If multiple sub-strings have been added with Text:add, the width of the last sub-string is returned.
	-- @return (number) height — The height of the text. If multiple sub-strings have been added with Text:add, the height of the last sub-string is returned.
	getDimensions: function(self: Text): number, number

	-- Gets the width and height of the text in pixels.
	-- @param index (integer) An index number returned by Text:add or Text:addf.
	-- @return (number) The width of the sub-string (before scaling and other transformations).
	-- @return (number) The height of the sub-string (before scaling and other transformations).
	getDimensions: function(self: Text, index: integer): number, number
end

-- A quadrilateral (a polygon with four sides and four corners) with texture coordinate information.
local record Quad

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Quad): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Quad, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Quad): boolean

	-- Sets the texture coordinates according to a viewport.
	-- @param x (number) The top-left corner along the x-axis.
	-- @param y (number) The top-left corner along the y-axis.
	-- @param width (number) The width of the viewport.
	-- @param height (number) The height of the viewport.
	-- @param texture_width (number) Optional new reference width, the width of the Texture. Must be greater than 0 if set. (Default: nil.)
	-- @param texture_height (number) Optional new reference height, the height of the Texture. Must be greater than 0 if set. (Default: nil.)
	setViewport: function(self: Quad, x: number, y: number, width: number, height: number, texture_width?: number, texture_height?: number)

	-- Gets the current viewport of this Quad.
	-- @return (number) The top-left corner along the x-axis.
	-- @return (number) The top-left corner along the y-axis.
	-- @return (number) The width of the viewport.
	-- @return (number) The height of the viewport.
	getViewport: function(self: Quad): number, number, number, number

	-- Gets reference texture dimensions initially specified in love.graphics.newQuad.
	-- @param layer (integer) The layer parameter.
	-- @return (number or integer) The Texture width used by the Quad.
	-- @return (number) The Texture height used by the Quad.
	getTextureDimensions: function(self: Quad): number, number
	setLayer: function(self: Quad, layer: integer)
	getLayer: function(self: Quad): integer
end

-- A 2D polygon mesh used for drawing arbitrary textured shapes.
local record Mesh

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Mesh): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Mesh, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Mesh): boolean

	-- Replaces a range of vertices in the Mesh with new ones. The total number of vertices in a Mesh cannot be changed after it has been created. This is often more efficient than calling Mesh:setVertex in a loop.
	-- @param vertices ({MeshVertex}) The table filled with vertex information tables for each vertex, in the form of {vertex, ...} where each vertex is a table in the form of {attributecomponent, ...}.
	-- @param start_vertex (integer) The index of the first vertex to replace. (Default: 1.)
	-- @param vertex_count (integer) Amount of vertices to replace. (Default: all.)
	setVertices: function(self: Mesh, vertices: {MeshVertex}, start_vertex?: integer, vertex_count?: integer)

	-- Replaces a range of vertices in the Mesh with new ones. The total number of vertices in a Mesh cannot be changed after it has been created. This is often more efficient than calling Mesh:setVertex in a loop.
	-- @param data (Data) A Data object to copy from. The contents of the Data must match the layout of this Mesh's vertex format.
	-- @param start_vertex (integer) The index of the first vertex to replace. (Default: 1.)
	-- @param vertex_count (integer) Amount of vertices to replace. (Default: all.)
	setVertices: function(self: Mesh, data: Data, start_vertex?: integer, vertex_count?: integer)

	-- Sets the properties of a vertex in the Mesh.
	--
	-- In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param index (integer) The index of the the vertex you want to modify (one-based).
	-- @param vertex (MeshVertex) A table with vertex information, in the form of {attributecomponent, ...}.
	setVertex: function(self: Mesh, index: integer, vertex: MeshVertex)

	-- Sets the properties of a vertex in the Mesh.
	--
	-- In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param index (integer) The index of the the vertex you want to modify (one-based).
	-- @param components (number...) A table with vertex information.
	setVertex: function(self: Mesh, index: integer, components: number...)

	-- Gets the properties of a vertex in the Mesh.
	-- In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
	-- Overload details:
	--   1. The values are returned in the same order as the vertex attributes in the Mesh's vertex format. A standard
	--      Mesh that wasn't created with a custom vertex format will return two position numbers, two texture coordinate
	--      numbers, and four color components: x, y, u, v, r, g, b, a.
	--   2. Gets the vertex components of a Mesh that wasn't created with a custom vertex format.
	-- @param index (integer) The one-based index of the vertex you want to retrieve the information for. Depending on the overload: The index of the vertex you want to retrieve the information for.
	-- @return (any) The first component of the first vertex attribute in the specified vertex.
	getVertex: function(self: Mesh, index: integer): any

	-- Sets the properties of a specific attribute within a vertex in the Mesh.
	-- Meshes without a custom vertex format specified in love.graphics.newMesh have position as their first attribute,
	-- texture coordinates as their second attribute, and color as their third attribute.
	-- Overload details:
	--   1. Attribute components which exist within the attribute but are not specified as arguments default to 0 for
	--      attributes with the float data type, and 255 for the byte data type.
	-- @param vertex_index (integer) The index of the the vertex to be modified (one-based).
	-- @param attribute_index (integer) The index of the attribute within the vertex to be modified (one-based).
	-- @param components (number...) The new value for the first component of the attribute.
	setVertexAttribute: function(self: Mesh, vertex_index: integer, attribute_index: integer, components: number...)

	-- Gets the properties of a specific attribute within a vertex in the Mesh.
	-- Meshes without a custom vertex format specified in love.graphics.newMesh have position as their first attribute,
	-- texture coordinates as their second attribute, and color as their third attribute.
	-- @param vertex_index (integer) The index of the the vertex you want to retrieve the attribute for (one-based).
	-- @param attribute_index (integer) The index of the attribute within the vertex to be retrieved (one-based).
	-- @return (any) The value of the first component of the attribute.
	getVertexAttribute: function(self: Mesh, vertex_index: integer, attribute_index: integer): any

	-- Gets the total number of vertices in the Mesh.
	-- @return (integer) The total number of vertices in the mesh.
	getVertexCount: function(self: Mesh): integer

	-- Gets the vertex format that the Mesh was created with.
	-- Overload details:
	--   1. If a Mesh wasn't created with a custom vertex format, it will have the following vertex format: defaultformat
	--      = { {'VertexPosition', 'float', 2}, -- The x,y position of each vertex. {'VertexTexCoord', 'float', 2}, --
	--      The u,v texture coordinates of each vertex. {'VertexColor', 'byte', 4} -- The r,g,b,a color of each vertex. }
	-- @return ({{any}}) The vertex format of the Mesh, which is a table containing tables for each vertex attribute the Mesh was created with, in the form of {attribute, ...}.
	getVertexFormat: function(self: Mesh): {{any}}

	-- Enables or disables a specific vertex attribute in the Mesh. Vertex data from disabled attributes is not used when
	-- drawing the Mesh.
	-- Overload details:
	--   1. If a Mesh wasn't created with a custom vertex format, it will have 3 vertex attributes named VertexPosition,
	--      VertexTexCoord, and VertexColor. Otherwise the attribute name must either match one of the vertex attributes
	--      specified in the vertex format when creating the Mesh, or must match a vertex attribute from another Mesh
	--      attached to this Mesh via Mesh:attachAttribute.
	-- @param name (string) The name of the vertex attribute to enable or disable.
	-- @param enabled (boolean) Whether the vertex attribute is used when drawing this Mesh.
	setAttributeEnabled: function(self: Mesh, name: string, enabled: boolean)

	-- Gets whether a specific vertex attribute in the Mesh is enabled. Vertex data from disabled attributes is not used
	-- when drawing the Mesh.
	-- Overload details:
	--   1. If a Mesh wasn't created with a custom vertex format, it will have 3 vertex attributes named VertexPosition,
	--      VertexTexCoord, and VertexColor. Otherwise the attribute name must either match one of the vertex attributes
	--      specified in the vertex format when creating the Mesh, or must match a vertex attribute from another Mesh
	--      attached to this Mesh via Mesh:attachAttribute.
	-- @param name (string) The name of the vertex attribute to be checked.
	-- @return (boolean) Whether the vertex attribute is used when drawing this Mesh.
	isAttributeEnabled: function(self: Mesh, name: string): boolean

	-- Attaches a vertex attribute from a different Mesh onto this Mesh, for use when drawing. This can be used to share
	-- vertex attribute data between several different Meshes.
	-- Overload details:
	--   1. If a Mesh wasn't created with a custom vertex format, it will have 3 vertex attributes named VertexPosition,
	--      VertexTexCoord, and VertexColor. Custom named attributes can be accessed in a vertex shader by declaring them
	--      as attribute vec4 MyCustomAttributeName; at the top-level of the vertex shader code. The name must match what
	--      was specified in the Mesh's vertex format and in the name argument of Mesh:attachAttribute.
	-- @param name (string) The name of the vertex attribute to attach.
	-- @param mesh (Mesh) The Mesh to get the vertex attribute from.
	-- @param step (AttributeStep) Whether the attribute will be per-vertex or per-instance when the mesh is drawn. (Default: 'pervertex'.)
	-- @param attribute_name (string) The name of the attribute to use in shader code. Defaults to the name of the attribute in the given mesh. Can be used to use a different name for this attribute when rendering. (Default: name.)
	attachAttribute: function(self: Mesh, name: string, mesh: Mesh, step?: AttributeStep, attribute_name?: string)

	-- Removes a previously attached vertex attribute from this Mesh.
	-- @param name (string) The name of the attached vertex attribute to detach.
	-- @return (boolean) Whether the attribute was successfully detached.
	detachAttribute: function(self: Mesh, name: string): boolean

	-- Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
	--
	-- The vertex map allows you to re-order or reuse vertices when drawing without changing the actual vertex parameters or duplicating vertices. It is especially useful when combined with different Mesh Draw Modes.
	setVertexMap: function(self: Mesh)

	-- Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
	--
	-- The vertex map allows you to re-order or reuse vertices when drawing without changing the actual vertex parameters or duplicating vertices. It is especially useful when combined with different Mesh Draw Modes.
	-- @param indices ({number}) A table containing a list of vertex indices to use when drawing. Values must be in the range of Mesh:getVertexCount().
	setVertexMap: function(self: Mesh, indices: {number})

	-- Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
	--
	-- The vertex map allows you to re-order or reuse vertices when drawing without changing the actual vertex parameters or duplicating vertices. It is especially useful when combined with different Mesh Draw Modes.
	-- @param indices (number...) A table containing a list of vertex indices to use when drawing. Values must be in the range of Mesh:getVertexCount().
	setVertexMap: function(self: Mesh, indices: number...)

	-- Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the screen.
	--
	-- The vertex map allows you to re-order or reuse vertices when drawing without changing the actual vertex parameters or duplicating vertices. It is especially useful when combined with different Mesh Draw Modes.
	-- @param data (Data) Table of vertex indices to use when drawing. Values must be in the range of Mesh:getVertexCount()-1
	-- @param data_type (IndexDataType) Datatype of the vertex indices table above.
	-- @param index_count (number) The index of the third vertex to use when drawing.
	setVertexMap: function(self: Mesh, data: Data, data_type: IndexDataType, index_count?: number)

	-- Gets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when the Mesh
	-- is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is displayed on the
	-- screen.
	-- If no vertex map has been set previously via Mesh:setVertexMap, then this function will return nil in LÖVE
	-- 0.10.0+, or an empty table in 0.9.2 and older.
	-- @return ({integer} or nil) A table containing the list of vertex indices used when drawing.
	getVertexMap: function(self: Mesh): {integer} | nil

	-- Sets the texture (Image or Canvas) used when drawing the Mesh.
	setTexture: function(self: Mesh)

	-- Sets the texture (Image or Canvas) used when drawing the Mesh.
	-- @param texture (Image | Canvas) The Image or Canvas to texture the Mesh with when drawing.
	setTexture: function(self: Mesh, texture: Image | Canvas)

	-- Gets the texture (Image or Canvas) used when drawing the Mesh.
	-- @return (Image or Canvas or nil) The Image or Canvas to texture the Mesh with when drawing, or nil if none is set.
	getTexture: function(self: Mesh): Image | Canvas | nil

	-- Sets the mode used when drawing the Mesh.
	-- @param mode (MeshDrawMode) The mode to use when drawing the Mesh.
	setDrawMode: function(self: Mesh, mode: MeshDrawMode)

	-- Gets the mode used when drawing the Mesh.
	-- @return (MeshDrawMode) The mode used when drawing the Mesh.
	getDrawMode: function(self: Mesh): MeshDrawMode

	-- Restricts the drawn vertices of the Mesh to a subset of the total.
	setDrawRange: function(self: Mesh)

	-- Restricts the drawn vertices of the Mesh to a subset of the total.
	-- @param start (integer) The index of the first vertex to use when drawing, or the index of the first value in the vertex map to use if one is set for this Mesh.
	-- @param count (integer) The number of vertices to use when drawing, or number of values in the vertex map to use if one is set for this Mesh.
	setDrawRange: function(self: Mesh, start: integer, count: integer)

	-- Gets the range of vertices used when drawing the Mesh.
	-- Overload details:
	--   1. If the Mesh's draw range has not been set previously with Mesh:setDrawRange, this function will return nil.
	-- @return (any) The index of the first vertex used when drawing, or the index of the first value in the vertex map used if one is set for this Mesh.
	getDrawRange: function(self: Mesh): any

	-- Immediately sends all modified vertex data in the Mesh to the graphics card.
	-- Normally it isn't necessary to call this method as love.graphics.draw(mesh, ...) will do it automatically if
	-- needed, but explicitly using **Mesh:flush** gives more control over when the work happens.
	-- If this method is used, it generally shouldn't be called more than once (at most) between love.graphics.draw(mesh,
	-- ...) calls.
	flush: function(self: Mesh)
end

-- Using a single image, draw any number of identical copies of the image using a single call to
-- love.graphics.draw(). This can be used, for example, to draw repeating copies of a single background image
-- with high performance.
local record SpriteBatch

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: SpriteBatch): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: SpriteBatch, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: SpriteBatch): boolean

	-- Adds a sprite to the batch. Sprites are drawn in the order they are added.
	-- @param x (number) The position to draw the object (x-axis).
	-- @param y (number) The position to draw the object (y-axis).
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shear factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shear factor (y-axis). (Default: 0.)
	-- @return (integer) id — An identifier for the added sprite.
	add: function(self: SpriteBatch, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- Adds a sprite to the batch. Sprites are drawn in the order they are added.
	-- @param quad (Quad) The Quad to add.
	-- @param x (number) The position to draw the object (x-axis).
	-- @param y (number) The position to draw the object (y-axis).
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shear factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shear factor (y-axis). (Default: 0.)
	-- @return (integer) id — An identifier for the added sprite.
	add: function(self: SpriteBatch, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- Changes a sprite in the batch. This requires the sprite index returned by SpriteBatch:add or SpriteBatch:addLayer.
	-- @param index (integer) The index of the sprite that will be changed.
	-- @param x (number) The position to draw the object (x-axis).
	-- @param y (number) The position to draw the object (y-axis).
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shear factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shear factor (y-axis). (Default: 0.)
	set: function(self: SpriteBatch, index: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Changes a sprite in the batch. This requires the sprite index returned by SpriteBatch:add or SpriteBatch:addLayer.
	-- @param index (integer) The index of the sprite that will be changed.
	-- @param quad (Quad) The Quad used on the image of the batch.
	-- @param x (number) The position to draw the object (x-axis).
	-- @param y (number) The position to draw the object (y-axis).
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shear factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shear factor (y-axis). (Default: 0.)
	set: function(self: SpriteBatch, index: integer, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Adds a sprite to a batch created with an Table Texture.
	-- @param layer (integer) The index of the layer to use for this sprite.
	-- @param x (number) The position to draw the sprite (x-axis). (Default: 0.)
	-- @param y (number) The position to draw the sprite (y-axis). (Default: 0.)
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shearing factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shearing factor (y-axis). (Default: 0.)
	-- @return (integer) spriteindex — The index of the added sprite, for use with SpriteBatch:set or SpriteBatch:setLayer.
	addLayer: function(self: SpriteBatch, layer: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- Adds a sprite to a batch created with an Table Texture.
	-- @param layer (integer) The index of the layer to use for this sprite.
	-- @param quad (Quad) The subsection of the texture's layer to use when drawing the sprite.
	-- @param x (number) The position to draw the sprite (x-axis). (Default: 0.)
	-- @param y (number) The position to draw the sprite (y-axis). (Default: 0.)
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shearing factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shearing factor (y-axis). (Default: 0.)
	-- @return (integer) spriteindex — The index of the added sprite, for use with SpriteBatch:set or SpriteBatch:setLayer.
	addLayer: function(self: SpriteBatch, layer: integer, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- Changes a sprite previously added with add or addLayer, in a batch created with an Table Texture.
	-- @param index (integer) The index of the existing sprite to replace.
	-- @param layer (integer) The index of the layer in the Table Texture to use for this sprite.
	-- @param x (number) The position to draw the sprite (x-axis). (Default: 0.)
	-- @param y (number) The position to draw the sprite (y-axis). (Default: 0.)
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shearing factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shearing factor (y-axis). (Default: 0.)
	setLayer: function(self: SpriteBatch, index: integer, layer: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Changes a sprite previously added with add or addLayer, in a batch created with an Table Texture.
	-- @param index (integer) The index of the existing sprite to replace.
	-- @param layer (integer) The index of the layer to use for this sprite.
	-- @param quad (Quad) The subsection of the texture's layer to use when drawing the sprite.
	-- @param x (number) The position to draw the sprite (x-axis). (Default: 0.)
	-- @param y (number) The position to draw the sprite (y-axis). (Default: 0.)
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shearing factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shearing factor (y-axis). (Default: 0.)
	setLayer: function(self: SpriteBatch, index: integer, layer: integer, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Removes all sprites from the buffer.
	clear: function(self: SpriteBatch)

	-- Immediately sends all new and modified sprite data in the batch to the graphics card.
	-- Normally it isn't necessary to call this method as love.graphics.draw(spritebatch, ...) will do it automatically
	-- if needed, but explicitly using SpriteBatch:flush gives more control over when the work happens.
	-- If this method is used, it generally shouldn't be called more than once (at most) between
	-- love.graphics.draw(spritebatch, ...) calls.
	flush: function(self: SpriteBatch)

	-- Sets the texture (Image or Canvas) used for the sprites in the batch, when drawing.
	-- @param texture (Image or Canvas) The new Image or Canvas to use for the sprites in the batch.
	setTexture: function(self: SpriteBatch, texture: Image | Canvas)

	-- Gets the texture (Image or Canvas) used by the SpriteBatch.
	-- @return (Image or Canvas) The Image or Canvas used by the SpriteBatch.
	getTexture: function(self: SpriteBatch): Image | Canvas

	-- Sets the color that will be used for the next add and set operations. Calling the function without arguments will disable all per-sprite colors for the SpriteBatch.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	--
	-- In version 0.9.2 and older, the global color set with love.graphics.setColor will not work on the SpriteBatch if any of the sprites has its own color.
	setColor: function(self: SpriteBatch)

	-- Sets the color that will be used for the next add and set operations. Calling the function without arguments will disable all per-sprite colors for the SpriteBatch.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	--
	-- In version 0.9.2 and older, the global color set with love.graphics.setColor will not work on the SpriteBatch if any of the sprites has its own color.
	-- @param red (number) The amount of red.
	-- @param green (number) The amount of green.
	-- @param blue (number) The amount of blue.
	-- @param alpha (number) The amount of alpha. (Default: 1.)
	setColor: function(self: SpriteBatch, red: number, green: number, blue: number, alpha?: number)

	-- Sets the color that will be used for the next add and set operations. Calling the function without arguments will disable all per-sprite colors for the SpriteBatch.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	--
	-- In version 0.9.2 and older, the global color set with love.graphics.setColor will not work on the SpriteBatch if any of the sprites has its own color.
	-- @param color (Color) The amount of red.
	setColor: function(self: SpriteBatch, color: Color)

	-- Gets the color that will be used for the next add and set operations.
	-- If no color has been set with SpriteBatch:setColor or the current SpriteBatch color has been cleared, this method
	-- will return nil.
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @return (number) The red component (0-1).
	-- @return (number) The green component (0-1).
	-- @return (number) The blue component (0-1).
	-- @return (number) The alpha component (0-1).
	getColor: function(self: SpriteBatch): number, number, number, number

	-- Gets the number of sprites currently in the SpriteBatch.
	-- @return (integer) The number of sprites currently in the batch.
	getCount: function(self: SpriteBatch): integer

	-- Gets the maximum number of sprites the SpriteBatch can hold.
	-- @return (integer) The maximum number of sprites the batch can hold.
	getBufferSize: function(self: SpriteBatch): integer

	-- Attaches a per-vertex attribute from a Mesh onto this SpriteBatch, for use when drawing. This can be combined with
	-- a Shader to augment a SpriteBatch with per-vertex or additional per-sprite information instead of just having
	-- per-sprite colors.
	-- Each sprite in a SpriteBatch has 4 vertices in the following order: top-left, bottom-left, top-right,
	-- bottom-right. The index returned by SpriteBatch:add (and used by SpriteBatch:set) can used to determine the first
	-- vertex of a specific sprite with the formula 1 + 4 * ( id - 1 ).
	-- Overload details:
	--   1. If a created with a custom vertex format, it will have 3 vertex attributes named VertexPosition,
	--      VertexTexCoord, and VertexColor. If vertex attributes with those names are attached to the SpriteBatch, it
	--      will override the SpriteBatch's sprite positions, texture coordinates, and sprite colors, respectively.
	--      Custom named attributes can be accessed in a vertex shader by declaring them as attribute vec4
	--      MyCustomAttributeName; at the top-level of the vertex shader code. The name must match what was specified in
	--      the Mesh's vertex format and in the name argument of SpriteBatch:attachAttribute. A Mesh must have at least 4
	--      * SpriteBatch:getBufferSize vertices in order to be attachable to a SpriteBatch.
	-- @param name (string) The name of the vertex attribute to attach.
	-- @param mesh (Mesh) The Mesh to get the vertex attribute from.
	attachAttribute: function(self: SpriteBatch, name: string, mesh: Mesh)

	-- Restricts the drawn sprites in the SpriteBatch to a subset of the total.
	setDrawRange: function(self: SpriteBatch)

	-- Restricts the drawn sprites in the SpriteBatch to a subset of the total.
	-- @param start (integer) The index of the first sprite to draw. Index 1 corresponds to the first sprite added with SpriteBatch:add.
	-- @param count (integer) The number of sprites to draw.
	setDrawRange: function(self: SpriteBatch, start: integer, count: integer)
	getDrawRange: function(self: SpriteBatch): number, number
end

-- A ParticleSystem can be used to create particle effects like fire or smoke.
local record ParticleSystem

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: ParticleSystem): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: ParticleSystem, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: ParticleSystem): boolean

	-- Creates an identical copy of the ParticleSystem in the stopped state.
	-- Overload details:
	--   1. Cloned ParticleSystem inherit all the set-able state of the original ParticleSystem, but they are initialized
	--      stopped.
	-- @return (ParticleSystem) The new identical copy of this ParticleSystem.
	clone: function(self: ParticleSystem): ParticleSystem

	-- Sets the texture (Image or Canvas) to be used for the particles.
	-- @param texture (Image or Canvas) An Image or Canvas to use for the particles.
	setTexture: function(self: ParticleSystem, texture: Image | Canvas)

	-- Gets the texture (Image or Canvas) used for the particles.
	-- @return (Image or Canvas) The Image or Canvas used for the particles.
	getTexture: function(self: ParticleSystem): Image | Canvas

	-- Sets the size of the buffer (the max allowed amount of particles in the system).
	-- @param size (integer) The buffer size.
	setBufferSize: function(self: ParticleSystem, size: integer)

	-- Gets the maximum number of particles the ParticleSystem can have at once.
	-- @return (integer) The maximum number of particles.
	getBufferSize: function(self: ParticleSystem): integer

	-- Sets the mode to use when the ParticleSystem adds new particles.
	-- @param mode (ParticleInsertMode) The mode to use when the ParticleSystem adds new particles.
	setInsertMode: function(self: ParticleSystem, mode: ParticleInsertMode)

	-- Gets the mode used when the ParticleSystem adds new particles.
	-- @return (ParticleInsertMode) The mode used when the ParticleSystem adds new particles.
	getInsertMode: function(self: ParticleSystem): ParticleInsertMode

	-- Sets the amount of particles emitted per second.
	-- @param rate (number) The amount of particles per second.
	setEmissionRate: function(self: ParticleSystem, rate: number)

	-- Gets the amount of particles emitted per second.
	-- @return (number) The amount of particles per second.
	getEmissionRate: function(self: ParticleSystem): number

	-- Sets how long the particle system should emit particles (if -1 then it emits particles forever).
	-- @param lifetime (number) The lifetime of the emitter (in seconds).
	setEmitterLifetime: function(self: ParticleSystem, lifetime: number)

	-- Gets how long the particle system will emit particles (if -1 then it emits particles forever).
	-- @return (number) The lifetime of the emitter (in seconds).
	getEmitterLifetime: function(self: ParticleSystem): number

	-- Sets the lifetime of the particles.
	-- @param minimum (number) The minimum life of the particles (in seconds).
	-- @param maximum (number) The maximum life of the particles (in seconds). (Default: min.)
	setParticleLifetime: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- Gets the lifetime of the particles.
	-- @return (number) The minimum life of the particles (in seconds).
	-- @return (number) The maximum life of the particles (in seconds).
	getParticleLifetime: function(self: ParticleSystem): number, number

	-- Sets the position of the emitter.
	-- @param x (number) Position along x-axis.
	-- @param y (number) Position along y-axis.
	setPosition: function(self: ParticleSystem, x: number, y: number)

	-- Gets the position of the emitter.
	-- @return (number) Position along x-axis.
	-- @return (number) Position along y-axis.
	getPosition: function(self: ParticleSystem): number, number

	-- Moves the position of the emitter. This results in smoother particle spawning behaviour than if
	-- ParticleSystem:setPosition is used every frame.
	-- @param x (number) Position along x-axis.
	-- @param y (number) Position along y-axis.
	moveTo: function(self: ParticleSystem, x: number, y: number)

	-- Sets area-based spawn parameters for the particles. Newly created particles will spawn in an area around the
	-- emitter based on the parameters to this function.
	-- @param distribution (ParticleAreaSpreadDistribution) The type of distribution for new particles.
	-- @param x (number) The maximum spawn distance from the emitter along the x-axis for uniform distribution, or the standard deviation along the x-axis for normal distribution.
	-- @param y (number) The maximum spawn distance from the emitter along the y-axis for uniform distribution, or the standard deviation along the y-axis for normal distribution.
	-- @param angle (number) The angle in radians of the emission area. (Default: 0.)
	-- @param relative (boolean) True if newly spawned particles will be oriented relative to the center of the emission area, false otherwise. (Default: false.)
	setEmissionArea: function(self: ParticleSystem, distribution?: ParticleAreaSpreadDistribution, x?: number, y?: number, angle?: number, relative?: boolean)

	-- Gets the area-based spawn parameters for the particles.
	-- @param distribution (string) The distribution parameter.
	-- @param x (number) The x parameter.
	-- @param y (number) The y parameter.
	-- @return (ParticleAreaSpreadDistribution) The type of distribution for new particles.
	-- @return (number) The maximum spawn distance from the emitter along the x-axis for uniform distribution, or the standard deviation along the x-axis for normal distribution.
	-- @return (number) The maximum spawn distance from the emitter along the y-axis for uniform distribution, or the standard deviation along the y-axis for normal distribution.
	-- @return (number) The angle in radians of the emission area.
	-- @return (boolean) True if newly spawned particles will be oriented relative to the center of the emission area, false otherwise.
	getEmissionArea: function(self: ParticleSystem): ParticleAreaSpreadDistribution, number, number, number, boolean
	setAreaSpread: function(self: ParticleSystem, distribution?: ParticleAreaSpreadDistribution, x?: number, y?: number)
	getAreaSpread: function(self: ParticleSystem): ParticleAreaSpreadDistribution, number, number

	-- Sets the direction the particles will be emitted in.
	-- @param direction (number) The direction of the particles (in radians).
	setDirection: function(self: ParticleSystem, direction: number)

	-- Gets the direction of the particle emitter (in radians).
	-- @return (number) The direction of the emitter (radians).
	getDirection: function(self: ParticleSystem): number

	-- Sets the amount of spread for the system.
	-- @param spread (number) The amount of spread (radians).
	setSpread: function(self: ParticleSystem, spread: number)

	-- Gets the amount of directional spread of the particle emitter (in radians).
	-- @return (number) The spread of the emitter (radians).
	getSpread: function(self: ParticleSystem): number

	-- Sets the speed of the particles.
	-- @param minimum (number) The minimum linear speed of the particles.
	-- @param maximum (number) The maximum linear speed of the particles. (Default: min.)
	setSpeed: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- Gets the speed of the particles.
	-- @return (number) The minimum linear speed of the particles.
	-- @return (number) The maximum linear speed of the particles.
	getSpeed: function(self: ParticleSystem): number, number

	-- Sets the linear acceleration (acceleration along the x and y axes) for particles.
	-- Every particle created will accelerate along the x and y axes between xmin,ymin and xmax,ymax.
	-- @param xmin (number) The minimum acceleration along the x axis.
	-- @param ymin (number) The minimum acceleration along the y axis.
	-- @param xmax (number) The maximum acceleration along the x axis. (Default: xmin.)
	-- @param ymax (number) The maximum acceleration along the y axis. (Default: ymin.)
	setLinearAcceleration: function(self: ParticleSystem, xmin: number, ymin: number, xmax?: number, ymax?: number)

	-- Gets the linear acceleration (acceleration along the x and y axes) for particles.
	-- Every particle created will accelerate along the x and y axes between xmin,ymin and xmax,ymax.
	-- @return (number) The minimum acceleration along the x axis.
	-- @return (number) The minimum acceleration along the y axis.
	-- @return (number) The maximum acceleration along the x axis.
	-- @return (number) The maximum acceleration along the y axis.
	getLinearAcceleration: function(self: ParticleSystem): number, number, number, number

	-- Set the radial acceleration (away from the emitter).
	-- @param minimum (number) The minimum acceleration.
	-- @param maximum (number) The maximum acceleration. (Default: min.)
	setRadialAcceleration: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- Gets the radial acceleration (away from the emitter).
	-- @return (number) The minimum acceleration.
	-- @return (number) The maximum acceleration.
	getRadialAcceleration: function(self: ParticleSystem): number, number

	-- Sets the tangential acceleration (acceleration perpendicular to the particle's direction).
	-- @param minimum (number) The minimum acceleration.
	-- @param maximum (number) The maximum acceleration. (Default: min.)
	setTangentialAcceleration: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- Gets the tangential acceleration (acceleration perpendicular to the particle's direction).
	-- @return (number) The minimum acceleration.
	-- @return (number) The maximum acceleration.
	getTangentialAcceleration: function(self: ParticleSystem): number, number

	-- Sets the amount of linear damping (constant deceleration) for particles.
	-- @param minimum (number) The minimum amount of linear damping applied to particles.
	-- @param maximum (number) The maximum amount of linear damping applied to particles. (Default: min.)
	setLinearDamping: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- Gets the amount of linear damping (constant deceleration) for particles.
	-- @return (number) The minimum amount of linear damping applied to particles.
	-- @return (number) The maximum amount of linear damping applied to particles.
	getLinearDamping: function(self: ParticleSystem): number, number

	-- Sets a series of sizes by which to scale a particle sprite. 1.0 is normal size. The particle system will
	-- interpolate between each size evenly over the particle's lifetime.
	-- At least one size must be specified. A maximum of eight may be used.
	-- @param sizes (number...) The first size.
	setSizes: function(self: ParticleSystem, sizes: number...)

	-- Gets the series of sizes by which the sprite is scaled. 1.0 is normal size. The particle system will interpolate
	-- between each size evenly over the particle's lifetime.
	-- @return (number...) The first size.
	getSizes: function(self: ParticleSystem): number...

	-- Sets the amount of size variation (0 meaning no variation and 1 meaning full variation between start and end).
	-- @param variation (number) The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).
	setSizeVariation: function(self: ParticleSystem, variation: number)

	-- Gets the amount of size variation (0 meaning no variation and 1 meaning full variation between start and end).
	-- @return (number) The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).
	getSizeVariation: function(self: ParticleSystem): number

	-- Sets the rotation of the image upon particle creation (in radians).
	-- @param minimum (number) The minimum initial angle (radians).
	-- @param maximum (number) The maximum initial angle (radians). (Default: min.)
	setRotation: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- Gets the rotation of the image upon particle creation (in radians).
	-- @return (number) The minimum initial angle (radians).
	-- @return (number) The maximum initial angle (radians).
	getRotation: function(self: ParticleSystem): number, number

	-- Sets the spin of the sprite.
	-- @param start (number) The minimum spin (radians per second).
	-- @param finish (number) The maximum spin (radians per second). (Default: min.)
	setSpin: function(self: ParticleSystem, start: number, finish?: number)

	-- Gets the spin of the sprite.
	-- @return (number) The minimum spin (radians per second).
	-- @return (number) The maximum spin (radians per second).
	getSpin: function(self: ParticleSystem): number, number

	-- Sets the amount of spin variation (0 meaning no variation and 1 meaning full variation between start and end).
	-- @param variation (number) The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).
	setSpinVariation: function(self: ParticleSystem, variation: number)

	-- Gets the amount of spin variation (0 meaning no variation and 1 meaning full variation between start and end).
	-- @return (number) The amount of variation (0 meaning no variation and 1 meaning full variation between start and end).
	getSpinVariation: function(self: ParticleSystem): number

	-- Set the offset position which the particle sprite is rotated around.
	-- If this function is not used, the particles rotate around their center.
	-- @param x (number) The x coordinate of the rotation offset.
	-- @param y (number) The y coordinate of the rotation offset.
	setOffset: function(self: ParticleSystem, x: number, y: number)

	-- Gets the particle image's draw offset.
	-- @return (number) The x coordinate of the particle image's draw offset.
	-- @return (number) The y coordinate of the particle image's draw offset.
	getOffset: function(self: ParticleSystem): number, number

	-- Sets a series of colors to apply to the particle sprite. The particle system will interpolate between each color
	-- evenly over the particle's lifetime.
	-- Arguments can be passed in groups of four, representing the components of the desired RGBA value, or as tables of
	-- RGBA component values, with a default alpha value of 1 if only three values are given. At least one color must be
	-- specified. A maximum of eight may be used.
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param colors (any...) First color, a numerical indexed table with the red, green, blue and alpha values as numbers (0-1). The alpha is optional and defaults to 1 if it is left out.
	setColors: function(self: ParticleSystem, colors: any...)

	-- Gets the series of colors applied to the particle sprite.
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @return ({number}...) First color, red component (0-1).
	getColors: function(self: ParticleSystem): {number}...

	-- Sets a series of Quads to use for the particle sprites. Particles will choose a Quad from the list based on the
	-- particle's current lifetime, allowing for the use of animated sprite sheets with ParticleSystems.
	-- @param quads (any...) A table containing the Quads to use.
	setQuads: function(self: ParticleSystem, quads: any...)

	-- Gets the series of Quads used for the particle sprites.
	-- @return ({Quad}) A table containing the Quads used.
	getQuads: function(self: ParticleSystem): {Quad}

	-- Sets whether particle angles and rotations are relative to their velocities. If enabled, particles are aligned to
	-- the angle of their velocities and rotate relative to that angle.
	-- @param enabled (boolean) True to enable relative particle rotation, false to disable it.
	setRelativeRotation: function(self: ParticleSystem, enabled: boolean)

	-- Gets whether particle angles and rotations are relative to their velocities. If enabled, particles are aligned to
	-- the angle of their velocities and rotate relative to that angle.
	-- @return (boolean) True if relative particle rotation is enabled, false if it's disabled.
	hasRelativeRotation: function(self: ParticleSystem): boolean

	-- Gets the number of particles that are currently in the system.
	-- @return (integer) The current number of live particles.
	getCount: function(self: ParticleSystem): integer

	-- Starts the particle emitter.
	start: function(self: ParticleSystem)

	-- Stops the particle emitter, resetting the lifetime counter.
	stop: function(self: ParticleSystem)

	-- Pauses the particle emitter.
	pause: function(self: ParticleSystem)

	-- Resets the particle emitter, removing any existing particles and resetting the lifetime counter.
	reset: function(self: ParticleSystem)

	-- Emits a burst of particles from the particle emitter.
	-- @param count (integer) The amount of particles to emit. The number of emitted particles will be truncated if the particle system's max buffer size is reached.
	emit: function(self: ParticleSystem, count: integer)

	-- Checks whether the particle system is actively emitting particles.
	-- @return (boolean) True if system is active, false otherwise.
	isActive: function(self: ParticleSystem): boolean

	-- Checks whether the particle system is paused.
	-- @return (boolean) True if system is paused, false otherwise.
	isPaused: function(self: ParticleSystem): boolean

	-- Checks whether the particle system is stopped.
	-- @return (boolean) True if system is stopped, false otherwise.
	isStopped: function(self: ParticleSystem): boolean
	isEmpty: function(self: ParticleSystem): boolean
	isFull: function(self: ParticleSystem): boolean

	-- Updates the particle system; moving, creating and killing particles.
	-- @param delta_time (number) The time (seconds) since last frame.
	update: function(self: ParticleSystem, delta_time: number)
end

-- A Shader is used for advanced hardware-accelerated pixel or vertex manipulation. These effects are written
-- in a language based on GLSL (OpenGL Shading Language) with a few things simplified for easier coding.
local record Shader

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Shader): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Shader, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Shader): boolean

	-- Returns any warning and error messages from compiling the shader code. This can be used for debugging your shaders
	-- if there's anything the graphics hardware doesn't like.
	-- @return (string) Warning and error messages (if any).
	getWarnings: function(self: Shader): string

	-- Gets whether an extern variable exists in the Shader.
	-- Deprecated compatibility alias for hasUniform used by LÖVE versions before 0.10.
	-- @param name (string) The name parameter.
	getExternVariable: function(self: Shader, name: string): boolean

	-- Gets whether a uniform / extern variable exists in the Shader.
	-- If a graphics driver's shader compiler determines that a uniform / extern variable doesn't affect the final output
	-- of the shader, it may optimize the variable out. This function will return false in that case.
	-- @param name (string) The name of the uniform variable.
	-- @return (boolean) Whether the uniform exists in the shader and affects its final output.
	hasUniform: function(self: Shader, name: string): boolean

	-- Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
	--
	-- uniform float time; // 'float' is the typical number type used in GLSL shaders.
	--
	-- uniform float varsvec2 light_pos;
	--
	-- uniform vec4 colors[4;
	--
	-- The corresponding send calls would be
	--
	-- shader:send('time', t)
	--
	-- shader:send('vars',a,b)
	--
	-- shader:send('light_pos', {light_x, light_y})
	--
	-- shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
	--
	-- Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
	-- @param name (string) Name of the number to send to the shader.
	-- @param texture (Image | Canvas) Texture (Image or Canvas) to send to the uniform variable.
	-- @param textures (Image | Canvas...) Additional numbers to send if the uniform variable is a table.
	send: function(self: Shader, name: string, texture: Image | Canvas, textures: Image | Canvas...)

	-- Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
	--
	-- uniform float time; // 'float' is the typical number type used in GLSL shaders.
	--
	-- uniform float varsvec2 light_pos;
	--
	-- uniform vec4 colors[4;
	--
	-- The corresponding send calls would be
	--
	-- shader:send('time', t)
	--
	-- shader:send('vars',a,b)
	--
	-- shader:send('light_pos', {light_x, light_y})
	--
	-- shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
	--
	-- Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
	-- @param name (string) Name of the vector to send to the shader.
	-- @param matrix_layout (MatrixLayout) The layout (row- or column-major) of the matrix in memory.
	-- @param matrices ({number} | {{number}}...) Additional vectors to send if the uniform variable is a table. All vectors need to be of the same size (e.g. only vec3's).
	send: function(self: Shader, name: string, matrix_layout: MatrixLayout, matrices: {number} | {{number}}...)

	-- Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
	--
	-- uniform float time; // 'float' is the typical number type used in GLSL shaders.
	--
	-- uniform float varsvec2 light_pos;
	--
	-- uniform vec4 colors[4;
	--
	-- The corresponding send calls would be
	--
	-- shader:send('time', t)
	--
	-- shader:send('vars',a,b)
	--
	-- shader:send('light_pos', {light_x, light_y})
	--
	-- shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
	--
	-- Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
	-- @param name (string) Name of the matrix to send to the shader.
	-- @param data (Data) Data object containing the values to send.
	-- @param offset (number) Offset in bytes from the start of the Data object. (Default: 0.)
	-- @param size (number) Size in bytes of the data to send. If nil, as many bytes as the specified uniform uses will be copied. (Default: all.)
	send: function(self: Shader, name: string, data: Data, offset?: number, size?: number)

	-- Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
	--
	-- uniform float time; // 'float' is the typical number type used in GLSL shaders.
	--
	-- uniform float varsvec2 light_pos;
	--
	-- uniform vec4 colors[4;
	--
	-- The corresponding send calls would be
	--
	-- shader:send('time', t)
	--
	-- shader:send('vars',a,b)
	--
	-- shader:send('light_pos', {light_x, light_y})
	--
	-- shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
	--
	-- Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
	-- @param name (string) Name of the Texture to send to the shader.
	-- @param matrix_layout (MatrixLayout) The layout (row- or column-major) of the matrix in memory.
	-- @param data (Data) Data object containing the values to send.
	-- @param offset (number) Offset in bytes from the start of the Data object. (Default: 0.)
	-- @param size (number) Size in bytes of the data to send. If nil, as many bytes as the specified uniform uses will be copied. (Default: all.)
	send: function(self: Shader, name: string, matrix_layout: MatrixLayout, data: Data, offset?: number, size?: number)

	-- Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
	--
	-- uniform float time; // 'float' is the typical number type used in GLSL shaders.
	--
	-- uniform float varsvec2 light_pos;
	--
	-- uniform vec4 colors[4;
	--
	-- The corresponding send calls would be
	--
	-- shader:send('time', t)
	--
	-- shader:send('vars',a,b)
	--
	-- shader:send('light_pos', {light_x, light_y})
	--
	-- shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
	--
	-- Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
	-- @param name (string) Name of the boolean to send to the shader.
	-- @param data (Data) Data object containing the values to send.
	-- @param matrix_layout (MatrixLayout) The layout (row- or column-major) of the matrix in memory.
	-- @param offset (number) Offset in bytes from the start of the Data object. (Default: 0.)
	-- @param size (number) Size in bytes of the data to send. If nil, as many bytes as the specified uniform uses will be copied. (Default: all.)
	send: function(self: Shader, name: string, data: Data, matrix_layout: MatrixLayout, offset?: number, size?: number)

	-- Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
	--
	-- uniform float time; // 'float' is the typical number type used in GLSL shaders.
	--
	-- uniform float varsvec2 light_pos;
	--
	-- uniform vec4 colors[4;
	--
	-- The corresponding send calls would be
	--
	-- shader:send('time', t)
	--
	-- shader:send('vars',a,b)
	--
	-- shader:send('light_pos', {light_x, light_y})
	--
	-- shader:send('colors', {r1, g1, b1, a1}, {r2, g2, b2, a2}, {r3, g3, b3, a3}, {r4, g4, b4, a4})
	--
	-- Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
	-- @param name (string) Name of the uniform to send to the shader.
	-- @param values (ShaderValue...) Texture (Image or Canvas) to send to the uniform variable.
	send: function(self: Shader, name: string, values: ShaderValue...)

	-- Sends one or more colors to a special (''extern'' / ''uniform'') vec3 or vec4 variable inside the shader. The color components must be in the range of 1. The colors are gamma-corrected if global gamma-correction is enabled.
	--
	-- Extern variables must be marked using the ''extern'' keyword, e.g.
	--
	-- extern vec4 Color;
	--
	-- The corresponding sendColor call would be
	--
	-- shader:sendColor('Color', {r, g, b, a})
	--
	-- Extern variables can be accessed in both the Vertex and Pixel stages of a shader, as long as the variable is declared in each.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param name (string) The name of the color extern variable to send to in the shader.
	-- @param data (Data) A table with red, green, blue, and optional alpha color components in the range of 1 to send to the extern as a vector.
	-- @param offset (number) Additional colors to send in case the extern is a table. All colors need to be of the same size (e.g. only vec3's).
	-- @param size (number) The number of bytes to read from the Data object.
	sendColor: function(self: Shader, name: string, data: Data, offset?: number, size?: number)

	-- Sends one or more colors to a special (''extern'' / ''uniform'') vec3 or vec4 variable inside the shader. The color components must be in the range of 1. The colors are gamma-corrected if global gamma-correction is enabled.
	--
	-- Extern variables must be marked using the ''extern'' keyword, e.g.
	--
	-- extern vec4 Color;
	--
	-- The corresponding sendColor call would be
	--
	-- shader:sendColor('Color', {r, g, b, a})
	--
	-- Extern variables can be accessed in both the Vertex and Pixel stages of a shader, as long as the variable is declared in each.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param name (string) The name of the color extern variable to send to in the shader.
	-- @param values (ShaderValue...) A table with red, green, blue, and optional alpha color components in the range of 1 to send to the extern as a vector.
	sendColor: function(self: Shader, name: string, values: ShaderValue...)
end

local record WindowMode
	fullscreen: boolean
	display: integer
	highdpi: boolean
	resizable: boolean
end

local record WindowSize
	width: integer
	height: integer
end

-- Provides an interface for modifying and retrieving information about the program's window.
local record Window
	-- Deprecated aliases for the current window dimensions.
	getWidth: function(): integer
	getHeight: function(): integer
	getDimensions: function(): integer, integer

	-- Gets the width and height of the desktop.
	-- @param display (integer) The index of the display, if multiple monitors are available. (Default: 1.)
	-- @return (integer) The width of the desktop.
	-- @return (integer) The height of the desktop.
	getDesktopDimensions: function(display?: integer): integer, integer

	-- Gets the number of connected monitors.
	-- @return (integer) The number of currently connected displays.
	getDisplayCount: function(): integer

	-- Gets the name of a display.
	-- @param display (integer) The index of the display to get the name of. (Default: 1.)
	-- @return (string) The name of the specified display.
	getDisplayName: function(display: integer): string

	-- Gets current device display orientation.
	-- @param display (integer) Display index to get its display orientation, or nil for default display index. (Default: nil.)
	-- @return (string) Current device display orientation.
	getDisplayOrientation: function(display?: integer): string

	-- Gets a list of supported fullscreen modes.
	-- @param display (integer) The index of the display, if multiple monitors are available. (Default: 1.)
	-- @return ({WindowSize}) A table of width/height pairs. (Note that this may not be in order.)
	getFullscreenModes: function(display?: integer): {WindowSize}

	-- Enters or exits fullscreen. The display to use when entering fullscreen is chosen based on which display the
	-- window is currently in, if multiple monitors are connected.
	-- Overload details:
	--   1. If fullscreen mode is entered and the window size doesn't match one of the monitor's display modes (in normal
	--      fullscreen mode) or the window size doesn't match the desktop size (in 'desktop' fullscreen mode), the window
	--      will be resized appropriately. The window will revert back to its original size again when fullscreen mode is
	--      exited using this function.
	-- @param fullscreen (boolean) Whether to enter or exit fullscreen mode.
	-- @param fullscreen_type (string) The type of fullscreen mode to use.
	-- @return (boolean) True if an attempt to enter fullscreen was successful, false otherwise.
	setFullscreen: function(fullscreen: boolean, fullscreen_type?: string): boolean

	-- Gets whether the window is fullscreen.
	-- @return (boolean) True if the window is fullscreen, false otherwise.
	-- @return (string) The type of fullscreen mode used.
	getFullscreen: function(): boolean, string

	-- Checks if the window is open.
	-- @return (boolean) True if the window is open, false otherwise.
	isOpen: function(): boolean

	-- Gets the window icon.
	-- @return (any) The window icon imagedata, or nil if no icon has been set with love.window.setIcon.
	getIcon: function(): any

	-- Sets the window icon from ImageData.
	-- Embedded LoveNode surfaces accept this request without changing the Dora host application's icon.
	-- @param imagedata (any) The window icon image data.
	-- @return (boolean) True when the icon request was accepted.
	setIcon: function(imagedata: any): boolean

	-- Gets the display mode and properties of the window.
	-- @return (integer) Window width.
	-- @return (integer) Window height.
	-- @return (WindowMode) Table with the window properties:
	getMode: function(): integer, integer, WindowMode

	-- Sets the display mode and properties of the window.
	-- If width or height is 0, setMode will use the width and height of the desktop.
	-- Changing the display mode may have side effects: for example, canvases will be cleared and values sent to shaders
	-- with canvases beforehand or re-draw to them afterward if you need to.
	-- Overload details:
	--   1. * If fullscreen is enabled and the width or height is not supported (see resize event will be triggered. * If
	--      the fullscreen type is 'desktop', then the window will be automatically resized to the desktop resolution. *
	--      If the width and height is bigger than or equal to the desktop dimensions (this includes setting both to 0)
	--      and fullscreen is set to false, it will appear 'visually' fullscreen, but it's not true fullscreen and
	--      conf.lua (i.e. t.window = false) and use this function to manually create the window, then you must not call
	--      any other love.graphics.* function before this one. Doing so will result in undefined behavior and/or crashes
	--      because OpenGL cannot function properly without a window. * Transparent backgrounds are currently not
	--      supported.
	-- @param width (integer) Display width.
	-- @param height (integer) Display height.
	-- @param settings (WindowMode) The flags table with the options: fullscreen: Fullscreen (true), or windowed (false). (Default: false.) fullscreentype: The type of fullscreen to use. This defaults to 'normal' in 0.9.0 through 0.9.2 and to 'desktop' in 0.10.0 and older. (Default: 'desktop'.) vsync: True if LÖVE should wait for vsync, false otherwise. (Default: true.) msaa: The number of antialiasing samples. (Default: 0.) stencil: Whether a stencil buffer should be allocated. If true, the stencil buffer will have 8 bits. (Default: true.) depth: The number of bits in the depth buffer. (Default: 0.) resizable: True if the window should be resizable in windowed mode, false otherwise. (Default: false.) borderless: True if the window should be borderless in windowed mode, false otherwise. (Default: false.) centered: True if the window should be centered in windowed mode, false otherwise. (Default: true.) display: The index of the display to show the window in, if multiple monitors are available. (Default: 1.) minwidth: The minimum width of the window, if it's resizable. Cannot be less than 1. (Default: 1.) minheight: The minimum height of the window, if it's resizable. Cannot be less than 1. (Default: 1.) highdpi: True if high-dpi mode should be used on Retina displays in macOS and iOS. Does nothing on non-Retina displays. (Default: false.) x: The x-coordinate of the window's position in the specified display. (Default: nil.) y: The y-coordinate of the window's position in the specified display. (Default: nil.) usedpiscale: Disables automatic DPI scaling when false. (Default: true.) srgb: Removed in 0.10.0 (set t.gammacorrect in conf.lua instead). True if sRGB gamma correction should be applied when drawing to the screen. (Default: false.)
	-- @return (boolean) True if successful, false otherwise.
	setMode: function(width: integer, height: integer, settings?: WindowMode): boolean

	-- Sets the display mode and properties of the window, without modifying unspecified properties.
	--
	-- If width or height is 0, updateMode will use the width and height of the desktop.
	--
	-- Changing the display mode may have side effects: for example, canvases will be cleared. Make sure to save the contents of canvases beforehand or re-draw to them afterward if you need to.
	-- @param settings (WindowModeSettings) The settings table with the following optional fields. Any field not filled in will use the current value that would be returned by love.window.getMode.
	-- @return (boolean) success — True if successful, false otherwise.
	updateMode: function(settings: WindowModeSettings): boolean

	-- Sets the display mode and properties of the window, without modifying unspecified properties.
	--
	-- If width or height is 0, updateMode will use the width and height of the desktop.
	--
	-- Changing the display mode may have side effects: for example, canvases will be cleared. Make sure to save the contents of canvases beforehand or re-draw to them afterward if you need to.
	-- @param width (number) Window width.
	-- @param height (integer) Window height.
	-- @param settings (WindowModeSettings) The settings table with the following optional fields. Any field not filled in will use the current value that would be returned by love.window.getMode.
	-- @return (boolean) success — True if successful, false otherwise.
	updateMode: function(width: number, height: integer, settings?: WindowModeSettings): boolean

	-- Gets the position of the window on the screen.
	-- The window position is in the coordinate space of the display it is currently in.
	-- @return (integer) The x-coordinate of the window's position.
	-- @return (integer) The y-coordinate of the window's position.
	-- @return (integer) The index of the display that the window is in.
	getPosition: function(): integer, integer, integer

	-- Gets area inside the window which is known to be unobstructed by a system title bar, the iPhone X notch, etc.
	-- Useful for making sure UI elements can be seen by the user.
	-- Overload details:
	--   1. Values returned are in DPI-scaled units (the same coordinate system as most other window-related APIs), not
	--      in pixels.
	-- @return (number) Starting position of safe area (x-axis).
	-- @return (number) Starting position of safe area (y-axis).
	-- @return (number) Width of safe area.
	-- @return (number) Height of safe area.
	getSafeArea: function(): number, number, number, number

	-- Sets the window title.
	-- @param title (string) The new window title.
	setTitle: function(title: string)

	-- Gets the window title.
	-- @return (string) The current window title.
	getTitle: function(): string

	-- Sets vertical synchronization mode.
	-- Overload details:
	--   1. * Not all graphics drivers support adaptive vsync (-1 value). In that case, it will be automatically set to
	--      1. * It is recommended to keep vsync activated if you don't know about the possible implications of turning
	--      it off. * This function doesn't recreate the window, unlike love.window.setMode and love.window.updateMode.
	-- @param vsync (boolean or integer) VSync number: 1 to enable, 0 to disable, and -1 for adaptive vsync.
	setVSync: function(vsync: boolean | integer)

	-- Gets current vertical synchronization (vsync).
	-- Overload details:
	--   1. This can be less expensive alternative to love.window.getMode if you want to get current vsync status.
	-- @return (integer) Current vsync status. 1 if enabled, 0 if disabled, and -1 for adaptive vsync.
	getVSync: function(): integer

	-- Sets whether the display is allowed to sleep while the program is running.
	-- Display sleep is disabled by default. Some types of input (e.g. joystick button presses) might not prevent the
	-- display from sleeping, if display sleep is allowed.
	-- @param enabled (boolean) True to enable system display sleep, false to disable it.
	setDisplaySleepEnabled: function(enabled: boolean)

	-- Gets whether the display is allowed to sleep while the program is running.
	-- Display sleep is disabled by default. Some types of input (e.g. joystick button presses) might not prevent the
	-- display from sleeping, if display sleep is allowed.
	-- @return (boolean) True if system display sleep is enabled / allowed, false otherwise.
	isDisplaySleepEnabled: function(): boolean

	-- Checks if the game window has keyboard focus.
	-- @return (boolean) True if the window has the focus or false if not.
	hasFocus: function(): boolean

	-- Checks if the game window has mouse focus.
	-- @return (boolean) True if the window has mouse focus or false if not.
	hasMouseFocus: function(): boolean

	-- Checks if the game window is visible.
	-- The window is considered visible if it's not minimized and the program isn't hidden.
	-- @return (boolean) True if the window is visible or false if not.
	isVisible: function(): boolean

	-- Gets whether the Window is currently maximized.
	-- The window can be maximized if it is not fullscreen and is resizable, and either the user has pressed the window's
	-- Maximize button or love.window.maximize has been called.
	-- @return (boolean) True if the window is currently maximized in windowed mode, false otherwise.
	isMaximized: function(): boolean

	-- Gets whether the Window is currently minimized.
	-- @return (boolean) True if the window is currently minimized, false otherwise.
	isMinimized: function(): boolean

	-- Gets the DPI scale factor associated with the window.
	-- The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a
	-- retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as
	-- an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.getDPIScale() would return
	-- 2.0 in that case.
	-- The love.window.fromPixels and love.window.toPixels functions can also be used to convert between units.
	-- The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The
	-- flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
	-- Overload details:
	--   1. The units of love.graphics.getWidth, love.graphics.getHeight, love.mouse.getPosition, mouse events,
	--      love.touch.getPosition, and touch events are always in terms of pixels.
	-- @return (number) The pixel scale factor associated with the window.
	getDPIScale: function(): number
	getNativeDPIScale: function(): number

	-- Converts a number from density-independent units to pixels.
	--
	-- The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.toPixels(800) would return 1600 in that case.
	--
	-- This is used to convert coordinates from the size users are expecting them to display at onscreen to pixels. love.window.fromPixels does the opposite. The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
	--
	-- Most LÖVE functions return values and expect arguments in terms of pixels rather than density-independent units.
	-- @param value (number) A number in density-independent units to convert to pixels.
	-- @return (number) pixelvalue — The converted number, in pixels.
	toPixels: function(value: number): number

	-- Converts a number from density-independent units to pixels.
	--
	-- The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.toPixels(800) would return 1600 in that case.
	--
	-- This is used to convert coordinates from the size users are expecting them to display at onscreen to pixels. love.window.fromPixels does the opposite. The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
	--
	-- Most LÖVE functions return values and expect arguments in terms of pixels rather than density-independent units.
	-- @param x (number) The x-axis value of a coordinate in density-independent units to convert to pixels.
	-- @param y (number) The y-axis value of a coordinate in density-independent units to convert to pixels.
	-- @return (number) pixelvalue — The converted number, in pixels.
	-- @return (number) px — The converted x-axis value of the coordinate, in pixels.
	toPixels: function(x: number, y: number): number, number

	-- Converts a number from pixels to density-independent units.
	--
	-- The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.fromPixels(1600) would return 800 in that case.
	--
	-- This function converts coordinates from pixels to the size users are expecting them to display at onscreen. love.window.toPixels does the opposite. The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
	--
	-- Most LÖVE functions return values and expect arguments in terms of pixels rather than density-independent units.
	-- @param value (number) A number in pixels to convert to density-independent units.
	-- @return (number) value — The converted number, in density-independent units.
	fromPixels: function(value: number): number

	-- Converts a number from pixels to density-independent units.
	--
	-- The pixel density inside the window might be greater (or smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses 1600x1200 pixels. love.window.fromPixels(1600) would return 800 in that case.
	--
	-- This function converts coordinates from pixels to the size users are expecting them to display at onscreen. love.window.toPixels does the opposite. The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
	--
	-- Most LÖVE functions return values and expect arguments in terms of pixels rather than density-independent units.
	-- @param x (number) The x-axis value of a coordinate in pixels.
	-- @param y (number) The y-axis value of a coordinate in pixels.
	-- @return (number) value — The converted number, in density-independent units.
	-- @return (number) x — The converted x-axis value of the coordinate, in density-independent units.
	fromPixels: function(x: number, y: number): number, number
end

-- Manages events, like keypresses.
local record Event

	-- Dora owns the platform event pump; this does not pump a second OS queue.
	-- Pump events into the event queue.
	-- This is a low-level function, and is usually not called by the user, but by love.run.
	-- Note that this does need to be called for any OS to think you're still running,
	-- and if you want to handle OS-generated events at all (think callbacks).
	pump: function()

	-- Returns an iterator for messages in the event queue.
	-- @return (function or any...) Iterator function usable in a for loop.
	poll: function(): function(): any...

	-- Like love.event.poll(), but blocks until there is an event in the queue.
	-- @return (any...) The name of event.
	wait: function(): any...

	-- Adds an event to the event queue.
	-- From 0.10.0 onwards, you may pass an arbitrary amount of arguments with this function, though the default
	-- callbacks don't ever use more than six.
	-- @param name (string) The name of the event.
	-- @param args (any...) First event argument. (Default: nil.)
	push: function(name: string, args: any...): boolean

	-- Clears the event queue.
	clear: function()

	-- Adds the quit event to the queue.
	--
	-- The quit event is a signal for the event handler to close LÖVE. It's possible to abort the exit process with the love.quit callback.
	-- @param exit_status (number) The program exit status to use when closing the application. (Default: 0.)
	-- @return (boolean) Always returns true after the quit event is queued.
	quit: function(exit_status?: number): boolean

	-- Adds the quit event to the queue.
	--
	-- The quit event is a signal for the event handler to close LÖVE. It's possible to abort the exit process with the love.quit callback.
	-- @param reason (string) Tells the default love.run to exit and restart the game without relaunching the executable.
	-- @return (boolean) Always returns true after the restart quit event is queued.
	quit: function(reason: string): boolean
end

-- Data representing the contents of a file.
local record FileData

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: FileData): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: FileData, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: FileData): boolean

	-- Gets the full Data as a string.
	-- @return (string) The raw data.
	getString: function(self: FileData): string

	-- Gets the Data's size in bytes.
	-- @return (integer) The size of the Data in bytes.
	getSize: function(self: FileData): integer

	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- @return (any) A raw pointer to the Data.
	getPointer: function(self: FileData): any

	-- Gets an FFI pointer to the Data.
	-- This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't
	-- store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.
	-- @return (nil) A raw void* pointer to the Data, or nil if FFI is unavailable.
	getFFIPointer: function(self: FileData): nil

	-- Creates a new copy of the Data object.
	-- @return (FileData) The new copy.
	clone: function(self: FileData): FileData

	-- Gets the filename of the FileData.
	-- @return (string) The name of the file the FileData represents.
	getFilename: function(self: FileData): string

	-- Gets the extension of the FileData.
	-- @return (string) The extension of the file the FileData represents.
	getExtension: function(self: FileData): string
end

-- Raw (decoded) image data.
local record ImageData

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: ImageData): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: ImageData): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: ImageData, type_name: string): boolean

	-- Gets the full Data as a string.
	-- @return (string) The raw data.
	getString: function(self: ImageData): string

	-- Gets the Data's size in bytes.
	-- @return (integer) The size of the Data in bytes.
	getSize: function(self: ImageData): integer

	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- @return (any) A raw pointer to the Data.
	getPointer: function(self: ImageData): any

	-- Gets an FFI pointer to the Data.
	-- This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't
	-- store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.
	-- @return (nil) A raw void* pointer to the Data, or nil if FFI is unavailable.
	getFFIPointer: function(self: ImageData): nil

	-- Creates a new copy of the Data object.
	-- @return (ImageData) The new copy.
	clone: function(self: ImageData): ImageData

	-- Gets the width of the ImageData in pixels.
	-- @return (integer) The width of the ImageData in pixels.
	getWidth: function(self: ImageData): integer

	-- Gets the height of the ImageData in pixels.
	-- @return (integer) The height of the ImageData in pixels.
	getHeight: function(self: ImageData): integer

	-- Gets the width and height of the ImageData in pixels.
	-- @return (integer) The width of the ImageData in pixels.
	-- @return (integer) The height of the ImageData in pixels.
	getDimensions: function(self: ImageData): integer, integer

	-- Gets the pixel format of the ImageData.
	-- @return (ImagePixelFormat) The pixel format the ImageData was created with.
	getFormat: function(self: ImageData): ImagePixelFormat

	-- Gets the color of a pixel at a specific position in the image.
	-- Valid x and y values start at 0 and go up to image width and height minus 1. Non-integer values are floored.
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param x (integer) The position of the pixel on the x-axis.
	-- @param y (integer) The position of the pixel on the y-axis.
	-- @return (number) The red component (0-1).
	-- @return (number) The green component (0-1).
	-- @return (number) The blue component (0-1).
	-- @return (number) The alpha component (0-1).
	getPixel: function(self: ImageData, x: integer, y: integer): number, number, number, number

	-- Sets the color of a pixel at a specific position in the image.
	-- Valid x and y values start at 0 and go up to image width and height minus 1.
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param x (integer) The position of the pixel on the x-axis.
	-- @param y (integer) The position of the pixel on the y-axis.
	-- @param red (number) The red component (0-1).
	-- @param green (number) The green component (0-1).
	-- @param blue (number) The blue component (0-1).
	-- @param alpha (number) The alpha component (0-1).
	setPixel: function(self: ImageData, x: integer, y: integer, red: number, green: number, blue: number, alpha?: number)

	-- Transform an image by applying a function to every pixel.
	-- This function is a higher-order function. It takes another function as a parameter, and calls it once for each
	-- pixel in the ImageData.
	-- The passed function is called with six parameters for each pixel in turn. The parameters are numbers that
	-- represent the x and y coordinates of the pixel and its red, green, blue and alpha values. The function should
	-- return the new red, green, blue, and alpha values for that pixel.
	-- function pixelFunction(x, y, r, g, b, a)
	-- -- template for defining your own pixel mapping function
	-- -- perform computations giving the new values for r, g, b and a
	-- -- ...
	-- return r, g, b, a
	-- end
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param mapper (function) Function to apply to every pixel.
	-- @param x (integer) The x-axis of the top-left corner of the area within the ImageData to apply the function to. (Default: 0.)
	-- @param y (integer) The y-axis of the top-left corner of the area within the ImageData to apply the function to. (Default: 0.)
	-- @param width (integer) The width of the area within the ImageData to apply the function to. (Default: ImageData:getWidth().)
	-- @param height (integer) The height of the area within the ImageData to apply the function to. (Default: ImageData:getHeight().)
	mapPixel: function(self: ImageData, mapper: function(x: integer, y: integer, red: number, green: number, blue: number, alpha: number): (number, number, number, number), x?: integer, y?: integer, width?: integer, height?: integer)

	-- Paste into ImageData from another source ImageData.
	-- Overload details:
	--   1. Note that this function just replaces the contents in the destination rectangle; it does not do any alpha
	--      blending.
	-- @param source (ImageData) Source ImageData from which to copy.
	-- @param destination_x (integer) Destination top-left position on x-axis.
	-- @param destination_y (integer) Destination top-left position on y-axis.
	-- @param source_x (integer) Source top-left position on x-axis.
	-- @param source_y (integer) Source top-left position on y-axis.
	-- @param source_width (integer) Source width.
	-- @param source_height (integer) Source height.
	paste: function(self: ImageData, source: ImageData, destination_x: integer, destination_y: integer, source_x?: integer, source_y?: integer, source_width?: integer, source_height?: integer)

	-- Encodes the ImageData and optionally writes it to the save directory.
	-- @param format (string) The format to encode the image as. Depending on the overload: The format to encode the image in.
	-- @param filename (string) The filename to write the file to. If nil, no file will be written but the FileData will still be returned. (Default: nil.)
	-- @return (FileData) The encoded image as a new FileData object.
	encode: function(self: ImageData, format: string, filename?: string): FileData
end

-- Represents compressed image data designed to stay compressed in RAM.
local record CompressedImageData

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: CompressedImageData): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: CompressedImageData): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: CompressedImageData, type_name: string): boolean

	-- Gets the full Data as a string.
	-- @return (string) The raw data.
	getString: function(self: CompressedImageData): string

	-- Gets the Data's size in bytes.
	-- @return (integer) The size of the Data in bytes.
	getSize: function(self: CompressedImageData): integer

	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- @return (any) A raw pointer to the Data.
	getPointer: function(self: CompressedImageData): any

	-- Gets an FFI pointer to the Data.
	-- This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't
	-- store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.
	-- @return (nil) A raw void* pointer to the Data, or nil if FFI is unavailable.
	getFFIPointer: function(self: CompressedImageData): nil

	-- Creates a new copy of the Data object.
	-- @return (CompressedImageData) The new copy.
	clone: function(self: CompressedImageData): CompressedImageData

	-- Gets the width of the CompressedImageData.
	-- @return (integer) width — The width of the CompressedImageData.
	getWidth: function(self: CompressedImageData): integer

	-- Gets the width of the CompressedImageData.
	-- @param mipmap (integer) A mipmap level. Must be in the range of CompressedImageData:getMipmapCount().
	-- @return (integer) The width of a specific mipmap level of the CompressedImageData.
	getWidth: function(self: CompressedImageData, mipmap: integer): integer

	-- Gets the height of the CompressedImageData.
	-- @return (integer) height — The height of the CompressedImageData.
	getHeight: function(self: CompressedImageData): integer

	-- Gets the height of the CompressedImageData.
	-- @param mipmap (integer) A mipmap level. Must be in the range of CompressedImageData:getMipmapCount().
	-- @return (integer) The height of a specific mipmap level of the CompressedImageData.
	getHeight: function(self: CompressedImageData, mipmap: integer): integer

	-- Gets the width and height of the CompressedImageData.
	-- @return (integer) width — The width of the CompressedImageData.
	-- @return (integer) height — The height of the CompressedImageData.
	getDimensions: function(self: CompressedImageData): integer, integer

	-- Gets the width and height of the CompressedImageData.
	-- @param mipmap (integer) A mipmap level. Must be in the range of CompressedImageData:getMipmapCount().
	-- @return (integer) The width of a specific mipmap level of the CompressedImageData.
	-- @return (integer) The height of a specific mipmap level of the CompressedImageData.
	getDimensions: function(self: CompressedImageData, mipmap: integer): integer, integer

	-- Gets the number of mipmap levels in the CompressedImageData. The base mipmap level (original image) is included in
	-- the count.
	-- Overload details:
	--   1. Mipmap filtering cannot be activated for an Image:setMipmapFilter will error. Most tools which can create
	--      compressed textures are able to automatically generate mipmaps for them in the same file.
	-- @return (integer) The number of mipmap levels stored in the CompressedImageData.
	getMipmapCount: function(self: CompressedImageData): integer

	-- Gets the format of the CompressedImageData.
	-- @return (CompressedPixelFormat) The format of the CompressedImageData.
	getFormat: function(self: CompressedImageData): CompressedPixelFormat
end

-- Provides an interface to decode encoded image data.
local record ImageModule

	-- Creates a new ImageData object.
	-- @param width (number) The width of the ImageData.
	-- @param height (integer) The height of the ImageData.
	-- @param format (ImagePixelFormat) The pixel format of the ImageData. (Default: 'rgba8'.)
	-- @param data (string | Data) Optional raw byte data to load into the ImageData, in the format specified by ''format''. (Default: nil.)
	-- @return (ImageData) imageData — The new blank ImageData object. Each pixel's color values, (including the alpha values!) will be set to zero.
	newImageData: function(width: number, height: integer, format?: ImagePixelFormat, data?: string | Data): ImageData

	-- Creates a new ImageData object.
	-- @param filename (string) The filename of the image file.
	-- @return (ImageData) The new ImageData object.
	newImageData: function(filename: string): ImageData

	-- Creates a new ImageData object.
	-- @param data (Data) Encoded image data to decode into the ImageData.
	-- @return (ImageData) The new ImageData object.
	newImageData: function(data: Data): ImageData

	-- Create a new CompressedImageData object from a compressed image file. LÖVE supports several compressed texture
	-- formats, enumerated in the CompressedImageFormat page.
	-- @param filename_or_data (string or FileData) The filename of the compressed image file. Depending on the overload: A FileData containing a compressed image.
	-- @return (CompressedImageData) The new CompressedImageData object.
	newCompressedData: function(filename_or_data: string | FileData): CompressedImageData

	-- Determines whether a file can be loaded as CompressedImageData.
	-- @param filename_or_data (string or FileData) The filename of the potentially compressed image file. Depending on the overload: A FileData potentially containing a compressed image.
	-- @return (boolean) Whether the file can be loaded as CompressedImageData or not. Depending on the overload: Whether the FileData can be loaded as CompressedImageData or not.
	isCompressed: function(filename_or_data: string | FileData): boolean
end

-- A Rasterizer handles font rendering, containing the font data (image or TrueType font) and drawable glyphs.
local record Rasterizer

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Rasterizer): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Rasterizer): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Rasterizer, type_name: string): boolean

	-- Gets font height.
	-- @return (integer) Font height
	getHeight: function(self: Rasterizer): integer

	-- Gets font advance.
	-- @return (integer) Font advance.
	getAdvance: function(self: Rasterizer): integer

	-- Gets ascent height.
	-- @return (integer) Ascent height.
	getAscent: function(self: Rasterizer): integer

	-- Gets descent height.
	-- @return (integer) Descent height.
	getDescent: function(self: Rasterizer): integer

	-- Gets line height of a font.
	-- @return (integer) Line height of a font.
	getLineHeight: function(self: Rasterizer): integer

	-- Gets glyph data of a specified glyph.
	-- @param glyph (string or integer) Glyph
	-- @return (GlyphData) Glyph data
	getGlyphData: function(self: Rasterizer, glyph: string | integer): GlyphData

	-- Gets number of glyphs in font.
	-- @return (integer) Glyphs count.
	getGlyphCount: function(self: Rasterizer): integer

	-- Checks if font contains specified glyphs.
	-- @param glyph (string or integer) Glyph
	-- @param ... (string or integer) The ... parameter.
	-- @return (boolean) Whatever font contains specified glyphs.
	hasGlyphs: function(self: Rasterizer, glyph: string | integer, ...: string | integer): boolean
end

-- A GlyphData represents a drawable symbol of a font Rasterizer.
local record GlyphData

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: GlyphData): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: GlyphData): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: GlyphData, type_name: string): boolean

	-- Gets the full Data as a string.
	-- @return (string) The raw data.
	getString: function(self: GlyphData): string

	-- Gets the Data's size in bytes.
	-- @return (integer) The size of the Data in bytes.
	getSize: function(self: GlyphData): integer

	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- @return (any) A raw pointer to the Data.
	getPointer: function(self: GlyphData): any

	-- Gets an FFI pointer to the Data.
	-- This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't
	-- store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.
	-- @return (nil) A raw void* pointer to the Data, or nil if FFI is unavailable.
	getFFIPointer: function(self: GlyphData): nil

	-- Creates a new copy of the Data object.
	-- @return (GlyphData) The new copy.
	clone: function(self: GlyphData): GlyphData

	-- Gets glyph width.
	-- @return (integer) Glyph width.
	getWidth: function(self: GlyphData): integer

	-- Gets glyph height.
	-- @return (integer) Glyph height.
	getHeight: function(self: GlyphData): integer

	-- Gets glyph dimensions.
	-- @return (integer) Glyph width.
	-- @return (integer) Glyph height.
	getDimensions: function(self: GlyphData): integer, integer

	-- Gets glyph number.
	-- @return (integer) Glyph number.
	getGlyph: function(self: GlyphData): integer

	-- Gets glyph string.
	-- @return (string) Glyph string.
	getGlyphString: function(self: GlyphData): string

	-- Gets glyph advance.
	-- @return (integer) Glyph advance.
	getAdvance: function(self: GlyphData): integer

	-- Gets glyph bearing.
	-- @return (integer) Glyph bearing X.
	-- @return (integer) Glyph bearing Y.
	getBearing: function(self: GlyphData): integer, integer

	-- Gets glyph bounding box.
	-- @return (integer) Glyph position x.
	-- @return (integer) Glyph position y.
	-- @return (integer) Glyph width.
	-- @return (integer) Glyph height.
	getBoundingBox: function(self: GlyphData): integer, integer, integer, integer

	-- Gets glyph pixel format.
	-- @return (string) Glyph pixel format.
	getFormat: function(self: GlyphData): string
end

-- Allows you to work with fonts.
local record FontModule

	-- Creates a new Image Rasterizer.
	-- Overload details:
	--   1. Create an ImageRasterizer from the image data.
	-- @param image_data (ImageData) Font image data.
	-- @param glyphs (string) String containing font glyphs.
	-- @param extra_spacing (integer) Font extra spacing. (Default: 0.)
	-- @param dpi_scale (number) Font DPI scale. (Default: 1.)
	-- @return (Rasterizer) The rasterizer.
	newImageRasterizer: function(image_data: ImageData, glyphs: string, extra_spacing?: integer, dpi_scale?: number): Rasterizer

	-- Creates a new BMFont Rasterizer.
	-- @param filename_or_file_data (string or FileData) The image data containing the drawable pictures of font glyphs. Depending on the
	-- @param images (ImageData or string or FileData or {ImageData or string or FileData}) The sequence of glyphs in the ImageData.
	-- @param dpi_scale (number) DPI scale. (Default: 1.)
	-- @return (Rasterizer) The rasterizer.
	newBMFontRasterizer: function(filename_or_file_data: string | FileData, images?: ImageData | string | FileData | {ImageData | string | FileData}, dpi_scale?: number): Rasterizer

	-- Creates a new TrueType Rasterizer.
	-- @param size (number) The font size. (Default: 12.)
	-- @param hinting (string) True Type hinting mode. (Default: 'normal'.)
	-- @param dpi_scale (number) The font DPI scale. (Default: love.window.getDPIScale().)
	-- @return (Rasterizer) rasterizer — The rasterizer.
	newTrueTypeRasterizer: function(size?: number, hinting?: string, dpi_scale?: number): Rasterizer

	-- Creates a new TrueType Rasterizer.
	-- @param filename_or_data (string | Data) File data containing font.
	-- @param size (number) The font size. (Default: 12.)
	-- @param hinting (string) True Type hinting mode. (Default: 'normal'.)
	-- @param dpi_scale (number) The font DPI scale. (Default: love.window.getDPIScale().)
	-- @return (Rasterizer) rasterizer — The rasterizer.
	newTrueTypeRasterizer: function(filename_or_data: string | Data, size?: number, hinting?: string, dpi_scale?: number): Rasterizer

	-- Creates a new Rasterizer.
	-- @param size (number) The font size. (Default: 12.)
	-- @param hinting (string) True Type hinting mode. (Default: 'normal'.)
	-- @param dpi_scale (number) The font DPI scale. (Default: love.window.getDPIScale().)
	-- @return (Rasterizer) rasterizer — The rasterizer.
	newRasterizer: function(size?: number, hinting?: string, dpi_scale?: number): Rasterizer

	-- Creates a new Rasterizer.
	-- @param filename_or_data (string | Data) File data containing font.
	-- @param size (number) The font size. (Default: 12.)
	-- @param hinting (string) True Type hinting mode. (Default: 'normal'.)
	-- @param dpi_scale (number) DPI scale. (Default: 1.)
	-- @return (Rasterizer) rasterizer — The rasterizer.
	newRasterizer: function(filename_or_data: string | Data, size?: number, hinting?: string, dpi_scale?: number): Rasterizer

	-- Creates a new GlyphData.
	-- @param rasterizer (Rasterizer) The Rasterizer containing the font.
	-- @param glyph (string or integer) The character code of the glyph.
	newGlyphData: function(rasterizer: Rasterizer, glyph: string | integer): GlyphData
end

-- Contains raw audio samples.
local record SoundData

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: SoundData): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: SoundData, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: SoundData): boolean

	-- Gets the full Data as a string.
	-- @return (string) The raw data.
	getString: function(self: SoundData): string

	-- Gets the Data's size in bytes.
	-- @return (integer) The size of the Data in bytes.
	getSize: function(self: SoundData): integer

	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- @return (any) A raw pointer to the Data.
	getPointer: function(self: SoundData): any

	-- Gets an FFI pointer to the Data.
	-- This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't
	-- store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.
	-- @return (nil) A raw void* pointer to the Data, or nil if FFI is unavailable.
	getFFIPointer: function(self: SoundData): nil

	-- Creates a new copy of the Data object.
	-- @return (SoundData) The new copy.
	clone: function(self: SoundData): SoundData

	-- Returns the number of channels in the SoundData.
	-- @return (integer) 1 for mono, 2 for stereo.
	getChannelCount: function(self: SoundData): integer
	getChannels: function(self: SoundData): integer

	-- Returns the number of bits per sample.
	-- @return (integer) Either 8, or 16.
	getBitDepth: function(self: SoundData): integer

	-- Returns the sample rate of the SoundData.
	-- @return (integer) Number of samples per second.
	getSampleRate: function(self: SoundData): integer

	-- Returns the number of samples per channel of the SoundData.
	-- @return (integer) Total number of samples.
	getSampleCount: function(self: SoundData): integer

	-- Gets the duration of the sound data.
	-- @param index (integer) The index parameter.
	-- @param channel (integer) The channel parameter.
	-- @return (number) The duration of the sound data in seconds.
	getDuration: function(self: SoundData): number
	getSample: function(self: SoundData, index: integer, channel?: integer): number

	-- Sets the value of the sample-point at the specified position. For stereo SoundData objects, the data from the left and right channels are interleaved in that order.
	-- @param index (integer) An integer value specifying the position of the sample (starting at 0).
	-- @param sample (number) The normalized samplepoint (range -1.0 to 1.0).
	setSample: function(self: SoundData, index: integer, sample: number)

	-- Sets the value of the sample-point at the specified position. For stereo SoundData objects, the data from the left and right channels are interleaved in that order.
	-- @param index (integer) An integer value specifying the position of the sample (starting at 0).
	-- @param channel (number) The index of the channel to set within the given sample.
	-- @param sample (number) The normalized samplepoint (range -1.0 to 1.0).
	setSample: function(self: SoundData, index: integer, channel: number, sample: number)
end

-- An object which can gradually decode a sound file.
local record Decoder

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Decoder): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Decoder, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Decoder): boolean

	-- Creates a new copy of current decoder.
	-- The new decoder will start decoding from the beginning of the audio stream.
	-- @return (Decoder) New copy of the decoder.
	clone: function(self: Decoder): Decoder

	-- Returns the number of channels in the stream.
	-- @return (integer) 1 for mono, 2 for stereo.
	getChannelCount: function(self: Decoder): integer
	getChannels: function(self: Decoder): integer

	-- Returns the number of bits per sample.
	-- @return (integer) Either 8, or 16.
	getBitDepth: function(self: Decoder): integer

	-- Returns the sample rate of the Decoder.
	-- @return (integer) Number of samples per second.
	getSampleRate: function(self: Decoder): integer

	-- Gets the duration of the sound file. It may not always be sample-accurate, and it may return -1 if the duration
	-- cannot be determined at all.
	-- @return (number) The duration of the sound file in seconds, or -1 if it cannot be determined.
	getDuration: function(self: Decoder): number

	-- Decodes the audio and returns a SoundData object containing the decoded audio data.
	-- @return (SoundData or nil) Decoded audio data.
	decode: function(self: Decoder): SoundData | nil

	-- Sets the currently playing position of the Decoder.
	-- @param offset (number) The position to seek to, in seconds.
	seek: function(self: Decoder, offset: number)
end

-- This module is responsible for decoding sound files. It can't play the sounds, see love.audio for that.
local record SoundModule

	-- Attempts to find a decoder for the encoded sound data in the specified file.
	-- @param filename (string) The filename of the file with encoded sound data.
	-- @param buffer_size (integer) The size of each decoded chunk, in bytes. (Default: 2048.)
	-- @return (Decoder) decoder — A new Decoder object.
	newDecoder: function(filename: string, buffer_size?: integer): Decoder

	-- Attempts to find a decoder for the encoded sound data in the specified file.
	-- @param data (FileData) The filename of the file with encoded sound data.
	-- @param buffer_size (integer) The size of each decoded chunk, in bytes. (Default: 2048.)
	-- @return (Decoder) decoder — A new Decoder object.
	newDecoder: function(data: FileData, buffer_size?: integer): Decoder

	-- Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a custom sample rate, channel and bit depth.
	--
	-- The sound data will be decoded to the memory in a raw format. It is recommended to create only short sounds like effects, as a 3 minute song uses 30 MB of memory this way.
	-- @param samples (number) Total number of samples.
	-- @param sample_rate (integer) Number of samples per second (Default: 44100.)
	-- @param bit_depth (integer) Bits per sample (8 or 16). (Default: 16.)
	-- @param channels (integer) Either 1 for mono or 2 for stereo. (Default: 2.)
	-- @return (SoundData) soundData — A new SoundData object.
	newSoundData: function(samples: number, sample_rate?: integer, bit_depth?: integer, channels?: integer): SoundData

	-- Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a custom sample rate, channel and bit depth.
	--
	-- The sound data will be decoded to the memory in a raw format. It is recommended to create only short sounds like effects, as a 3 minute song uses 30 MB of memory this way.
	-- @param filename (string) The file name of the file to load.
	-- @param buffer_size (integer) Number of samples per second (Default: 44100.)
	-- @return (SoundData) soundData — A new SoundData object.
	newSoundData: function(filename: string, buffer_size?: integer): SoundData

	-- Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a custom sample rate, channel and bit depth.
	--
	-- The sound data will be decoded to the memory in a raw format. It is recommended to create only short sounds like effects, as a 3 minute song uses 30 MB of memory this way.
	-- @param data (FileData) Decode data from this Decoder until EOF.
	-- @param buffer_size (integer) Number of samples per second (Default: 44100.)
	-- @return (SoundData) soundData — A new SoundData object.
	newSoundData: function(data: FileData, buffer_size?: integer): SoundData

	-- Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a custom sample rate, channel and bit depth.
	--
	-- The sound data will be decoded to the memory in a raw format. It is recommended to create only short sounds like effects, as a 3 minute song uses 30 MB of memory this way.
	-- @param decoder (Decoder) Decode data from this Decoder until EOF.
	-- @return (SoundData) soundData — A new SoundData object.
	newSoundData: function(decoder: Decoder): SoundData
end

-- Data object containing arbitrary bytes in an contiguous memory.
local record ByteData

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: ByteData): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: ByteData, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: ByteData): boolean

	-- Gets the full Data as a string.
	-- @return (string) The raw data.
	getString: function(self: ByteData): string

	-- Gets the Data's size in bytes.
	-- @return (integer) The size of the Data in bytes.
	getSize: function(self: ByteData): integer

	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- @return (any) A raw pointer to the Data.
	getPointer: function(self: ByteData): any

	-- Gets an FFI pointer to the Data.
	-- This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't
	-- store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.
	-- @return (nil) A raw void* pointer to the Data, or nil if FFI is unavailable.
	getFFIPointer: function(self: ByteData): nil

	-- Creates a new copy of the Data object.
	-- @param type_name (string) The type_name parameter.
	-- @return (ByteData or string or boolean or integer or any or nil or DataView) The new copy.
	clone: function(self: ByteData): ByteData
end
local record DataView
	type: function(self: DataView): string
	typeOf: function(self: DataView, type_name: string): boolean
	release: function(self: DataView): boolean
	getString: function(self: DataView): string
	getSize: function(self: DataView): integer
	getPointer: function(self: DataView): any
	getFFIPointer: function(self: DataView): nil
	clone: function(self: DataView): DataView
end

-- Represents byte data compressed using a specific algorithm.
local record CompressedData

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: CompressedData): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: CompressedData, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: CompressedData): boolean

	-- Gets the full Data as a string.
	-- @return (string) The raw data.
	getString: function(self: CompressedData): string

	-- Gets the Data's size in bytes.
	-- @return (integer) The size of the Data in bytes.
	getSize: function(self: CompressedData): integer

	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- @return (any) A raw pointer to the Data.
	getPointer: function(self: CompressedData): any

	-- Gets an FFI pointer to the Data.
	-- This function should be preferred instead of Data:getPointer because the latter uses light userdata which can't
	-- store more all possible memory addresses on some new ARM64 architectures, when LuaJIT is used.
	-- @return (nil) A raw void* pointer to the Data, or nil if FFI is unavailable.
	getFFIPointer: function(self: CompressedData): nil

	-- Creates a new copy of the Data object.
	-- @return (CompressedData) The new copy.
	clone: function(self: CompressedData): CompressedData

	-- Gets the compression format of the CompressedData.
	-- @return (CompressionFormat) The format of the CompressedData.
	getFormat: function(self: CompressedData): CompressionFormat
end

-- Provides functionality for creating and transforming data.
local record DataModule

	-- Creates a new Data object containing arbitrary bytes.
	--
	-- Data:getPointer along with LuaJIT's FFI can be used to manipulate the contents of the ByteData object after it has been created.
	-- @param size (integer) The size in bytes of the new Data object. (Default: data:getSize().)
	-- @return (ByteData) bytedata — The new Data object.
	newByteData: function(size: integer): ByteData

	-- Creates a new Data object containing arbitrary bytes.
	--
	-- Data:getPointer along with LuaJIT's FFI can be used to manipulate the contents of the ByteData object after it has been created.
	-- @param bytes (string) The size in bytes of the new Data object.
	-- @return (ByteData) bytedata — The new Data object.
	newByteData: function(bytes: string): ByteData

	-- Creates a new Data object containing arbitrary bytes.
	--
	-- Data:getPointer along with LuaJIT's FFI can be used to manipulate the contents of the ByteData object after it has been created.
	-- @param data (Data) The existing Data object to copy.
	-- @param offset (integer) The offset of the subsection to copy, in bytes. (Default: 0.)
	-- @param size (integer) The size in bytes of the new Data object.
	-- @return (ByteData) bytedata — The new Data object.
	newByteData: function(data: Data, offset?: integer, size?: integer): ByteData

	-- Creates a new Data referencing a subsection of an existing Data object.
	-- Overload details:
	--   1. Data:getString and Data:getPointer will return the original Data object's contents, with the view's offset
	--      and size applied.
	-- @param data (any) The Data object to reference.
	-- @param offset (integer) The offset of the subsection to reference, in bytes.
	-- @param size (integer) The size in bytes of the subsection to reference.
	-- @return (DataView) The new Data view.
	newDataView: function(data: any, offset: integer, size: integer): DataView

	-- Encode Data or a string to a Data or string in one of the EncodeFormats.
	-- @param container (DataContainer) What type to return the encoded data as.
	-- @param format (EncodeFormat) The format of the output data.
	-- @param source (string | Data) The raw data to encode.
	-- @param line_length (integer) The maximum line length of the output. Only supported for base64, ignored if 0. (Default: 0.)
	-- @return (string) encoded — ByteData/string which contains the encoded version of source.
	encode: function(container: DataContainer, format: EncodeFormat, source: string | Data, line_length?: integer): string

	-- Encode Data or a string to a Data or string in one of the EncodeFormats.
	-- @param container (DataContainer) What type to return the encoded data as.
	-- @param format (EncodeFormat) The format of the output data.
	-- @param source (string | Data) The raw data to encode.
	-- @param line_length (integer) The maximum line length of the output. Only supported for base64, ignored if 0. (Default: 0.)
	-- @return (ByteData) encoded — ByteData/string which contains the encoded version of source.
	encode: function(container: DataContainer, format: EncodeFormat, source: string | Data, line_length?: integer): ByteData

	-- Decode Data or a string from any of the EncodeFormats to Data or string.
	-- @param container (DataContainer) What type to return the decoded data as.
	-- @param format (EncodeFormat) The format of the input data.
	-- @param source (string | Data) The raw (encoded) data to decode.
	-- @return (string) decoded — ByteData/string which contains the decoded version of source.
	decode: function(container: DataContainer, format: EncodeFormat, source: string | Data): string

	-- Decode Data or a string from any of the EncodeFormats to Data or string.
	-- @param container (DataContainer) What type to return the decoded data as.
	-- @param format (EncodeFormat) The format of the input data.
	-- @param source (string | Data) The raw (encoded) data to decode.
	-- @return (ByteData) decoded — ByteData/string which contains the decoded version of source.
	decode: function(container: DataContainer, format: EncodeFormat, source: string | Data): ByteData

	-- Compresses a string or data using a specific compression algorithm.
	-- @param container (DataContainer) What type to return the compressed data as.
	-- @param format (CompressionFormat) The format to use when compressing the string.
	-- @param source (string | Data) The raw (un-compressed) string to compress.
	-- @param level (integer) The level of compression to use, between 0 and 9. -1 indicates the default level. The meaning of this argument depends on the compression format being used. (Default: -1.)
	-- @return (string) compressedData — CompressedData/string which contains the compressed version of rawstring.
	compress: function(container: DataContainer, format: CompressionFormat, source: string | Data, level?: integer): string

	-- Compresses a string or data using a specific compression algorithm.
	-- @param container (DataContainer) What type to return the compressed data as.
	-- @param format (CompressionFormat) The format to use when compressing the data.
	-- @param source (string | Data) A Data object containing the raw (un-compressed) data to compress.
	-- @param level (integer) The level of compression to use, between 0 and 9. -1 indicates the default level. The meaning of this argument depends on the compression format being used. (Default: -1.)
	-- @return (CompressedData) CompressedData/string which contains the compressed version of data.
	compress: function(container: DataContainer, format: CompressionFormat, source: string | Data, level?: integer): CompressedData

	-- Decompresses a CompressedData or previously compressed string or Data object.
	-- @param container (DataContainer) What type to return the decompressed data as.
	-- @param compressed (CompressedData) The compressed data to decompress.
	-- @return (string) decompressedData — Data/string containing the raw decompressed data.
	decompress: function(container: DataContainer, compressed: CompressedData): string

	-- Decompresses a CompressedData or previously compressed string or Data object.
	-- @param container (DataContainer) What type to return the decompressed data as.
	-- @param compressed (CompressedData) The compressed data to decompress.
	-- @return (ByteData) decompressedData — Data/string containing the raw decompressed data.
	decompress: function(container: DataContainer, compressed: CompressedData): ByteData

	-- Decompresses a CompressedData or previously compressed string or Data object.
	-- @param container (DataContainer) What type to return the decompressed data as.
	-- @param format (CompressionFormat) The format that was used to compress the given data.
	-- @param source (string | Data) A Data object containing data previously compressed with love.data.compress.
	-- @return (string) decompressedData — Data/string containing the raw decompressed data.
	decompress: function(container: DataContainer, format: CompressionFormat, source: string | Data): string

	-- Decompresses a CompressedData or previously compressed string or Data object.
	-- @param container (DataContainer) What type to return the decompressed data as.
	-- @param format (CompressionFormat) The format that was used to compress the given data.
	-- @param source (string | Data) A Data object containing data previously compressed with love.data.compress.
	-- @return (ByteData) decompressedData — Data/string containing the raw decompressed data.
	decompress: function(container: DataContainer, format: CompressionFormat, source: string | Data): ByteData

	-- Packs (serializes) simple Lua values.
	--
	-- This function behaves the same as Lua 5.3's string.pack.
	-- @param container (DataContainer) What type to return the encoded data as.
	-- @param format (string) A string determining how the values are packed. Follows the rules of Lua 5.3's string.pack format strings.
	-- @param values (any...) The first value (number, boolean, or string) to serialize.
	-- @return (string) data — Data/string which contains the serialized data.
	pack: function(container: DataContainer, format: string, values: any...): string

	-- Packs (serializes) simple Lua values.
	--
	-- This function behaves the same as Lua 5.3's string.pack.
	-- @param container (DataContainer) What type to return the encoded data as.
	-- @param format (string) A string determining how the values are packed. Follows the rules of Lua 5.3's string.pack format strings.
	-- @param values (any...) The first value (number, boolean, or string) to serialize.
	-- @return (ByteData) data — Data/string which contains the serialized data.
	pack: function(container: DataContainer, format: string, values: any...): ByteData

	-- Unpacks (deserializes) a byte-string or Data into simple Lua values.
	--
	-- This function behaves the same as Lua 5.3's string.unpack.
	-- @param format (string) A string determining how the values were packed. Follows the rules of Lua 5.3's string.pack format strings.
	-- @param source (string) A string containing the packed (serialized) data.
	-- @param position (integer) Where to start reading in the string. Negative values can be used to read relative from the end of the string. (Default: 1.)
	-- @return (any...) v1 — The first value (number, boolean, or string) that was unpacked.
	unpack: function(format: string, source: string, position?: integer): any...

	-- Unpacks (deserializes) a byte-string or Data into simple Lua values.
	--
	-- This function behaves the same as Lua 5.3's string.unpack.
	-- @param format (string) A string determining how the values were packed. Follows the rules of Lua 5.3's string.pack format strings.
	-- @param source (Data) A Data object containing the packed (serialized) data.
	-- @param position (integer) 1-based index indicating where to start reading in the Data. Negative values can be used to read relative from the end of the Data object. (Default: 1.)
	-- @return (any...) v1 — The first value (number, boolean, or string) that was unpacked.
	unpack: function(format: string, source: Data, position?: integer): any...

	-- Gets the size in bytes that a given format used with love.data.pack will use.
	-- This function behaves the same as Lua 5.3's string.packsize.
	-- Overload details:
	--   1. The format string cannot have the variable-length options 's' or 'z'.
	-- @param format (string) A string determining how the values are packed. Follows the rules of Lua 5.3's string.pack format strings.
	-- @return (integer) The size in bytes that the packed data will use.
	getPackedSize: function(format: string): integer

	-- Compute the message digest of a string using a specified hash algorithm.
	-- @param hash_function (HashFunction) Hash algorithm to use.
	-- @param source (string) String to hash.
	-- @return (string) rawdigest — Raw message digest string.
	hash: function(hash_function: HashFunction, source: string): string

	-- Compute the message digest of a string using a specified hash algorithm.
	-- @param hash_function (HashFunction) Hash algorithm to use.
	-- @param source (Data) Data to hash.
	-- @return (string) rawdigest — Raw message digest string.
	hash: function(hash_function: HashFunction, source: Data): string
end

-- A random number generation object which has its own random state.
local record RandomGenerator

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: RandomGenerator): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: RandomGenerator, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: RandomGenerator): boolean

	-- Generates a pseudo-random number in a platform independent manner.
	-- @return (number) number — The pseudo-random number.
	random: function(self: RandomGenerator): number

	-- Generates a pseudo-random number in a platform independent manner.
	-- @param upper (number) The maximum possible value it should return.
	-- @return (number) The pseudo-random integer number.
	random: function(self: RandomGenerator, upper: number): number

	-- Generates a pseudo-random number in a platform independent manner.
	-- @param lower (number) The minimum possible value it should return.
	-- @param upper (number) The maximum possible value it should return.
	-- @return (number) The pseudo-random integer number.
	random: function(self: RandomGenerator, lower: number, upper: number): number

	-- Get a normally distributed pseudo random number.
	-- @param standard_deviation (number) Standard deviation of the distribution. (Default: 1.)
	-- @param mean (number) The mean of the distribution. (Default: 0.)
	-- @return (number) Normally distributed random number with variance (stddev)² and the specified mean.
	randomNormal: function(self: RandomGenerator, standard_deviation?: number, mean?: number): number

	-- Sets the seed of the random number generator using the specified integer number.
	-- @param seed (number) The integer number with which you want to seed the randomization. Must be within the range of 2^53.
	setSeed: function(self: RandomGenerator, seed: number)

	-- Sets the seed of the random number generator using the specified integer number.
	-- @param low (number) The lower 32 bits of the seed value. Must be within the range of 2^32 - 1.
	-- @param high (number) The higher 32 bits of the seed value. Must be within the range of 2^32 - 1.
	setSeed: function(self: RandomGenerator, low: number, high: number)

	-- Gets the seed of the random number generator object.
	-- The seed is split into two numbers due to Lua's use of doubles for all number values - doubles can't accurately
	-- represent integer values above 2^53, but the seed value is an integer number in the range of 2^64 - 1.
	-- @return (number) Integer number representing the lower 32 bits of the RandomGenerator's 64 bit seed value.
	-- @return (number) Integer number representing the higher 32 bits of the RandomGenerator's 64 bit seed value.
	getSeed: function(self: RandomGenerator): number, number

	-- Sets the current state of the random number generator. The value used as an argument for this function is an
	-- opaque string and should only originate from a previous call to RandomGenerator:getState in the same major version
	-- of LÖVE.
	-- This is different from RandomGenerator:setSeed in that setState directly sets the RandomGenerator's current
	-- implementation-dependent state, whereas setSeed gives it a new seed value.
	-- Overload details:
	--   1. The effect of the state string does not depend on the current operating system.
	-- @param state (string) The new state of the RandomGenerator object, represented as a string. This should originate from a previous call to RandomGenerator:getState.
	setState: function(self: RandomGenerator, state: string)

	-- Gets the current state of the random number generator. This returns an opaque string which is only useful for
	-- later use with RandomGenerator:setState in the same major version of LÖVE.
	-- This is different from RandomGenerator:getSeed in that getState gets the RandomGenerator's current state, whereas
	-- getSeed gets the previously set seed number.
	-- Overload details:
	--   1. The value of the state string does not depend on the current operating system.
	-- @return (string) The current state of the RandomGenerator object, represented as a string.
	getState: function(self: RandomGenerator): string
end

-- Object containing a coordinate system transformation.
local record Transform

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Transform): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Transform, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Transform): boolean

	-- Creates a new copy of this Transform.
	-- @return (Transform) The copy of this Transform.
	clone: function(self: Transform): Transform

	-- Creates a new Transform containing the inverse of this Transform.
	-- @return (Transform) A new Transform object representing the inverse of this Transform's matrix.
	inverse: function(self: Transform): Transform

	-- Applies the given other Transform object to this one.
	-- This effectively multiplies this Transform's internal transformation matrix with the other Transform's (i.e. self
	-- * other), and stores the result in this object.
	-- @param other (Transform) The other Transform object to apply to this Transform.
	-- @return (Transform) The Transform object the method was called on. Allows easily chaining Transform methods.
	apply: function(self: Transform, other: Transform): Transform

	-- Checks whether the Transform is an affine transformation.
	-- @return (boolean) true if the transform object is an affine transformation, false otherwise.
	isAffine2DTransform: function(self: Transform): boolean

	-- Applies a translation to the Transform's coordinate system. This method does not reset any previously applied
	-- transformations.
	-- @param x (number) The relative translation along the x-axis.
	-- @param y (number) The relative translation along the y-axis.
	-- @return (Transform) The Transform object the method was called on. Allows easily chaining Transform methods.
	translate: function(self: Transform, x: number, y: number): Transform

	-- Applies a rotation to the Transform's coordinate system. This method does not reset any previously applied
	-- transformations.
	-- @param angle (number) The relative angle in radians to rotate this Transform by.
	-- @return (Transform) The Transform object the method was called on. Allows easily chaining Transform methods.
	rotate: function(self: Transform, angle: number): Transform

	-- Scales the Transform's coordinate system. This method does not reset any previously applied transformations.
	-- @param x (number) The relative scale factor along the x-axis.
	-- @param y (number) The relative scale factor along the y-axis. (Default: sx.)
	-- @return (Transform) The Transform object the method was called on. Allows easily chaining Transform methods.
	scale: function(self: Transform, x: number, y?: number): Transform

	-- Applies a shear factor (skew) to the Transform's coordinate system. This method does not reset any previously
	-- applied transformations.
	-- @param x (number) The shear factor along the x-axis.
	-- @param y (number) The shear factor along the y-axis.
	-- @return (Transform) The Transform object the method was called on. Allows easily chaining Transform methods.
	shear: function(self: Transform, x: number, y: number): Transform

	-- Resets the Transform to an identity state. All previously applied transformations are erased.
	-- @return (Transform) The Transform object the method was called on. Allows easily chaining Transform methods.
	reset: function(self: Transform): Transform

	-- Resets the Transform to the specified transformation parameters.
	-- @param x (number) The position of the Transform on the x-axis.
	-- @param y (number) The position of the Transform on the y-axis.
	-- @param angle (number) The orientation of the Transform in radians. (Default: 0.)
	-- @param scale_x (number) Scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) Scale factor on the y-axis. (Default: sx.)
	-- @param origin_x (number) Origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) Origin offset on the y-axis. (Default: 0.)
	-- @param shear_x (number) Shearing / skew factor on the x-axis. (Default: 0.)
	-- @param shear_y (number) Shearing / skew factor on the y-axis. (Default: 0.)
	-- @return (Transform) The Transform object the method was called on. Allows easily chaining Transform methods.
	setTransformation: function(self: Transform, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): Transform

	-- Directly sets the Transform's internal 4x4 transformation matrix.
	-- @param layout (string) How to interpret the matrix element arguments (row-major or column-major).
	-- @param elements ({number} | {{number}}) A flat table containing the 16 matrix elements.
	-- @return (Transform) transform — The Transform object the method was called on. Allows easily chaining Transform methods.
	setMatrix: function(self: Transform, layout: string, elements: {number} | {{number}}): Transform

	-- Directly sets the Transform's internal 4x4 transformation matrix.
	-- @param elements ({number} | {{number}}) A table of 4 tables, with each sub-table containing 4 matrix elements.
	-- @return (Transform) transform — The Transform object the method was called on. Allows easily chaining Transform methods.
	setMatrix: function(self: Transform, elements: {number} | {{number}}): Transform

	-- Gets the internal 4x4 transformation matrix stored by this Transform. The matrix is returned in row-major order.
	-- @return (number) The first column of the first row of the matrix.
	-- @return (number) The second column of the first row of the matrix.
	-- @return (number) The third column of the first row of the matrix.
	-- @return (number) The fourth column of the first row of the matrix.
	-- @return (number) The first column of the second row of the matrix.
	-- @return (number) The second column of the second row of the matrix.
	-- @return (number) The third column of the second row of the matrix.
	-- @return (number) The fourth column of the second row of the matrix.
	-- @return (number) The first column of the third row of the matrix.
	-- @return (number) The second column of the third row of the matrix.
	-- @return (number) The third column of the third row of the matrix.
	-- @return (number) The fourth column of the third row of the matrix.
	-- @return (number) The first column of the fourth row of the matrix.
	-- @return (number) The second column of the fourth row of the matrix.
	-- @return (number) The third column of the fourth row of the matrix.
	-- @return (number) The fourth column of the fourth row of the matrix.
	getMatrix: function(self: Transform): number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number

	-- Applies the Transform object's transformation to the given 2D position.
	-- This effectively converts the given position from global coordinates into the local coordinate space of the
	-- Transform.
	-- @param x (number) The x component of the position in global coordinates.
	-- @param y (number) The y component of the position in global coordinates.
	-- @return (number) The x component of the position with the transform applied.
	-- @return (number) The y component of the position with the transform applied.
	transformPoint: function(self: Transform, x: number, y: number): number, number

	-- Applies the reverse of the Transform object's transformation to the given 2D position.
	-- This effectively converts the given position from the local coordinate space of the Transform into global
	-- coordinates.
	-- One use of this method can be to convert a screen-space mouse position into global world coordinates, if the given
	-- Transform has transformations applied that are used for a camera system in-game.
	-- @param x (number) The x component of the position with the transform applied.
	-- @param y (number) The y component of the position with the transform applied.
	-- @return (number) The x component of the position in global coordinates.
	-- @return (number) The y component of the position in global coordinates.
	inverseTransformPoint: function(self: Transform, x: number, y: number): number, number
end

-- A Bézier curve object that can evaluate and render Bézier curves of arbitrary degree.
local record BezierCurve

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: BezierCurve): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: BezierCurve, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: BezierCurve): boolean

	-- Get degree of the Bézier curve. The degree is equal to number-of-control-points - 1.
	-- @return (integer) Degree of the Bézier curve.
	getDegree: function(self: BezierCurve): integer

	-- Get the derivative of the Bézier curve.
	-- This function can be used to rotate sprites moving along a curve in the direction of the movement and compute the
	-- direction perpendicular to the curve at some parameter t.
	-- @return (BezierCurve) The derivative curve.
	getDerivative: function(self: BezierCurve): BezierCurve

	-- Get coordinates of the i-th control point. Indices start with 1.
	-- @param index (integer) Index of the control point.
	-- @return (number) Position of the control point along the x axis.
	-- @return (number) Position of the control point along the y axis.
	getControlPoint: function(self: BezierCurve, index: integer): number, number

	-- Set coordinates of the i-th control point. Indices start with 1.
	-- @param index (integer) Index of the control point.
	-- @param x (number) Position of the control point along the x axis.
	-- @param y (number) Position of the control point along the y axis.
	setControlPoint: function(self: BezierCurve, index: integer, x: number, y: number)

	-- Insert control point as the new i-th control point. Existing control points from i onwards are pushed back by 1.
	-- Indices start with 1. Negative indices wrap around: -1 is the last control point, -2 the one before the last, etc.
	-- @param x (number) Position of the control point along the x axis.
	-- @param y (number) Position of the control point along the y axis.
	-- @param index (integer) Index of the control point. (Default: -1.)
	insertControlPoint: function(self: BezierCurve, x: number, y: number, index?: integer)

	-- Removes the specified control point.
	-- @param index (integer) The index of the control point to remove.
	removeControlPoint: function(self: BezierCurve, index: integer)

	-- Get the number of control points in the Bézier curve.
	-- @return (integer) The number of control points.
	getControlPointCount: function(self: BezierCurve): integer

	-- Move the Bézier curve by an offset.
	-- @param x (number) Offset along the x axis.
	-- @param y (number) Offset along the y axis.
	translate: function(self: BezierCurve, x: number, y: number)

	-- Rotate the Bézier curve by an angle.
	-- @param angle (number) Rotation angle in radians.
	-- @param origin_x (number) X coordinate of the rotation center. (Default: 0.)
	-- @param origin_y (number) Y coordinate of the rotation center. (Default: 0.)
	rotate: function(self: BezierCurve, angle: number, origin_x?: number, origin_y?: number)

	-- Scale the Bézier curve by a factor.
	-- @param scale (number) Scale factor.
	-- @param origin_x (number) X coordinate of the scaling center. (Default: 0.)
	-- @param origin_y (number) Y coordinate of the scaling center. (Default: 0.)
	scale: function(self: BezierCurve, scale: number, origin_x?: number, origin_y?: number)

	-- Evaluate Bézier curve at parameter t. The parameter must be between 0 and 1 (inclusive).
	-- This function can be used to move objects along paths or tween parameters. However it should not be used to render
	-- the curve, see BezierCurve:render for that purpose.
	-- @param time (number) Where to evaluate the curve.
	-- @return (number) x coordinate of the curve at parameter t.
	-- @return (number) y coordinate of the curve at parameter t.
	evaluate: function(self: BezierCurve, time: number): number, number

	-- Gets a BezierCurve that corresponds to the specified segment of this BezierCurve.
	-- @param start (number) The starting point along the curve. Must be between 0 and 1.
	-- @param finish (number) The end of the segment. Must be between 0 and 1.
	-- @return (BezierCurve) A BezierCurve that corresponds to the specified segment.
	getSegment: function(self: BezierCurve, start: number, finish: number): BezierCurve

	-- Get a list of coordinates to be used with love.graphics.line.
	-- This function samples the Bézier curve using recursive subdivision. You can control the recursion depth using the
	-- depth parameter.
	-- If you are just interested to know the position on the curve given a parameter, use BezierCurve:evaluate.
	-- @param accuracy (integer) Number of recursive subdivision steps. (Default: 5.)
	-- @return ({number}) List of x,y-coordinate pairs of points on the curve.
	render: function(self: BezierCurve, accuracy?: integer): {number}

	-- Get a list of coordinates on a specific part of the curve, to be used with love.graphics.line.
	-- This function samples the Bézier curve using recursive subdivision. You can control the recursion depth using the
	-- depth parameter.
	-- If you are just need to know the position on the curve given a parameter, use BezierCurve:evaluate.
	-- @param start (number) The starting point along the curve. Must be between 0 and 1.
	-- @param finish (number) The end of the segment to render. Must be between 0 and 1.
	-- @param accuracy (integer) Number of recursive subdivision steps. (Default: 5.)
	-- @return ({number}) List of x,y-coordinate pairs of points on the specified part of the curve.
	renderSegment: function(self: BezierCurve, start: number, finish: number, accuracy?: integer): {number}
end

-- Provides system-independent mathematical functions.
local record MathModule

	-- Creates a new RandomGenerator object which is completely independent of other RandomGenerator objects and random functions.
	-- @param seed (number) The initial seed number to use for this object.
	-- @return (RandomGenerator) rng — The new Random Number Generator object.
	newRandomGenerator: function(seed?: number): RandomGenerator

	-- Creates a new RandomGenerator object which is completely independent of other RandomGenerator objects and random functions.
	-- @param low (number) The lower 32 bits of the seed number to use for this object.
	-- @param high (number) The higher 32 bits of the seed number to use for this object.
	-- @return (RandomGenerator) rng — The new Random Number Generator object.
	newRandomGenerator: function(low: number, high: number): RandomGenerator

	-- Creates a new Transform object.
	-- @return (Transform) transform — The new Transform object.
	newTransform: function(): Transform

	-- Creates a new Transform object.
	-- @param x (number) The position of the new Transform on the x-axis.
	-- @param y (number) The position of the new Transform on the y-axis.
	-- @param angle (number) The orientation of the new Transform in radians. (Default: 0.)
	-- @param scale_x (number) Scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) Scale factor on the y-axis. (Default: sx.)
	-- @param origin_x (number) Origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) Origin offset on the y-axis. (Default: 0.)
	-- @param shear_x (number) Shearing / skew factor on the x-axis. (Default: 0.)
	-- @param shear_y (number) Shearing / skew factor on the y-axis. (Default: 0.)
	-- @return (Transform) transform — The new Transform object.
	newTransform: function(x: number, y: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): Transform

	-- Creates a new BezierCurve object.
	--
	-- The number of vertices in the control polygon determines the degree of the curve, e.g. three vertices define a quadratic (degree 2) Bézier curve, four vertices define a cubic (degree 3) Bézier curve, etc.
	-- @param vertices ({number}) The vertices of the control polygon as a table in the form of {x1, y1, x2, y2, x3, y3, ...}.
	-- @return (BezierCurve) curve — A Bézier curve object.
	newBezierCurve: function(vertices: {number}): BezierCurve

	-- Creates a new BezierCurve object.
	--
	-- The number of vertices in the control polygon determines the degree of the curve, e.g. three vertices define a quadratic (degree 2) Bézier curve, four vertices define a cubic (degree 3) Bézier curve, etc.
	-- @param coordinates (number...) The vertices of the control polygon as a table in the form of {x1, y1, x2, y2, x3, y3, ...}.
	-- @return (BezierCurve) curve — A Bézier curve object.
	newBezierCurve: function(coordinates: number...): BezierCurve

	-- Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same, given the same arguments.
	--
	-- Simplex noise is closely related to Perlin noise. It is widely used for procedural content generation.
	--
	-- There are many webpages which discuss Perlin and Simplex noise in detail.
	-- @param x (number) The number used to generate the noise value.
	-- @return (number) value — The noise value in the range of 1.
	noise: function(x: number): number

	-- Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same, given the same arguments.
	--
	-- Simplex noise is closely related to Perlin noise. It is widely used for procedural content generation.
	--
	-- There are many webpages which discuss Perlin and Simplex noise in detail.
	-- @param x (number) The first value of the 2-dimensional vector used to generate the noise value.
	-- @param y (number) The second value of the 2-dimensional vector used to generate the noise value.
	-- @return (number) value — The noise value in the range of 1.
	noise: function(x: number, y: number): number

	-- Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same, given the same arguments.
	--
	-- Simplex noise is closely related to Perlin noise. It is widely used for procedural content generation.
	--
	-- There are many webpages which discuss Perlin and Simplex noise in detail.
	-- @param x (number) The first value of the 3-dimensional vector used to generate the noise value.
	-- @param y (number) The second value of the 3-dimensional vector used to generate the noise value.
	-- @param z (number) The third value of the 3-dimensional vector used to generate the noise value.
	-- @return (number) value — The noise value in the range of 1.
	noise: function(x: number, y: number, z: number): number

	-- Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same, given the same arguments.
	--
	-- Simplex noise is closely related to Perlin noise. It is widely used for procedural content generation.
	--
	-- There are many webpages which discuss Perlin and Simplex noise in detail.
	-- @param x (number) The first value of the 4-dimensional vector used to generate the noise value.
	-- @param y (number) The second value of the 4-dimensional vector used to generate the noise value.
	-- @param z (number) The third value of the 4-dimensional vector used to generate the noise value.
	-- @param w (number) The fourth value of the 4-dimensional vector used to generate the noise value.
	-- @return (number) value — The noise value in the range of 1.
	noise: function(x: number, y: number, z: number, w: number): number

	-- Generates a pseudo-random number in a platform independent manner. The default love.run seeds this function at startup, so you generally don't need to seed it yourself.
	-- @return (number) number — The pseudo-random number.
	random: function(): number

	-- Generates a pseudo-random number in a platform independent manner. The default love.run seeds this function at startup, so you generally don't need to seed it yourself.
	-- @param upper (number) The maximum possible value it should return.
	-- @return (number) The pseudo-random integer number.
	random: function(upper: number): number

	-- Generates a pseudo-random number in a platform independent manner. The default love.run seeds this function at startup, so you generally don't need to seed it yourself.
	-- @param lower (number) The minimum possible value it should return.
	-- @param upper (number) The maximum possible value it should return.
	-- @return (number) The pseudo-random integer number.
	random: function(lower: number, upper: number): number

	-- Get a normally distributed pseudo random number.
	-- @param standard_deviation (number) Standard deviation of the distribution. (Default: 1.)
	-- @param mean (number) The mean of the distribution. (Default: 0.)
	-- @return (number) Normally distributed random number with variance (stddev)² and the specified mean.
	randomNormal: function(standard_deviation?: number, mean?: number): number

	-- Sets the seed of the random number generator using the specified integer number. This is called internally at startup, so you generally don't need to call it yourself.
	-- @param seed (number) The integer number with which you want to seed the randomization. Must be within the range of 2^53 - 1.
	setRandomSeed: function(seed: number)

	-- Sets the seed of the random number generator using the specified integer number. This is called internally at startup, so you generally don't need to call it yourself.
	-- @param low (number) The lower 32 bits of the seed value. Must be within the range of 2^32 - 1.
	-- @param high (number) The higher 32 bits of the seed value. Must be within the range of 2^32 - 1.
	setRandomSeed: function(low: number, high: number)

	-- Gets the seed of the random number generator.
	-- The seed is split into two numbers due to Lua's use of doubles for all number values - doubles can't accurately
	-- represent integer values above 2^53, but the seed can be an integer value up to 2^64.
	-- @return (number) Integer number representing the lower 32 bits of the random number generator's 64 bit seed value.
	-- @return (number) Integer number representing the higher 32 bits of the random number generator's 64 bit seed value.
	getRandomSeed: function(): number, number

	-- Sets the current state of the random number generator. The value used as an argument for this function is an
	-- opaque implementation-dependent string and should only originate from a previous call to love.math.getRandomState.
	-- This is different from love.math.setRandomSeed in that setRandomState directly sets the random number generator's
	-- current implementation-dependent state, whereas setRandomSeed gives it a new seed value.
	-- Overload details:
	--   1. The effect of the state string does not depend on the current operating system.
	-- @param state (string) The new state of the random number generator, represented as a string. This should originate from a previous call to love.math.getRandomState.
	setRandomState: function(state: string)

	-- Gets the current state of the random number generator. This returns an opaque implementation-dependent string
	-- which is only useful for later use with love.math.setRandomState or RandomGenerator:setState.
	-- This is different from love.math.getRandomSeed in that getRandomState gets the random number generator's current
	-- state, whereas getRandomSeed gets the previously set seed number.
	-- Overload details:
	--   1. The value of the state string does not depend on the current operating system.
	-- @return (string) The current state of the random number generator, represented as a string.
	getRandomState: function(): string

	-- Converts a color from 0..1 to 0..255 range.
	-- @param red (number) Red color component.
	-- @param green (number) Green color component.
	-- @param blue (number) Blue color component.
	-- @param alpha (number) Alpha color component. (Default: nil.)
	-- @return (number) rb — Red color component in 0..255 range.
	-- @return (number) gb — Green color component in 0..255 range.
	-- @return (number) bb — Blue color component in 0..255 range.
	-- @return (number | nil) ab — Alpha color component in 0..255 range or nil if alpha is not specified.
	colorToBytes: function(red: number, green: number, blue: number, alpha?: number): number, number, number, number | nil

	-- Converts a color from 0..1 to 0..255 range.
	-- @param color ({number}) Red color component.
	-- @return (number) rb — Red color component in 0..255 range.
	-- @return (number) gb — Green color component in 0..255 range.
	-- @return (number) bb — Blue color component in 0..255 range.
	-- @return (number | nil) ab — Alpha color component in 0..255 range or nil if alpha is not specified.
	colorToBytes: function(color: {number}): number, number, number, number | nil

	-- Converts a color from 0..255 to 0..1 range.
	-- @param red (number) Red color component in 0..255 range.
	-- @param green (number) Green color component in 0..255 range.
	-- @param blue (number) Blue color component in 0..255 range.
	-- @param alpha (number) Alpha color component in 0..255 range. (Default: nil.)
	-- @return (number) r — Red color component in 0..1 range.
	-- @return (number) g — Green color component in 0..1 range.
	-- @return (number) b — Blue color component in 0..1 range.
	-- @return (number | nil) a — Alpha color component in 0..1 range or nil if alpha is not specified.
	colorFromBytes: function(red: number, green: number, blue: number, alpha?: number): number, number, number, number | nil

	-- Converts a color from 0..255 to 0..1 range.
	-- @param color ({number}) Red color component in 0..255 range.
	-- @return (number) r — Red color component in 0..1 range.
	-- @return (number) g — Green color component in 0..1 range.
	-- @return (number) b — Blue color component in 0..1 range.
	-- @return (number | nil) a — Alpha color component in 0..1 range or nil if alpha is not specified.
	colorFromBytes: function(color: {number}): number, number, number, number | nil

	-- Converts a color from gamma-space (sRGB) to linear-space (RGB). This is useful when doing gamma-correct rendering and you need to do math in linear RGB in the few cases where LÖVE doesn't handle conversions automatically.
	--
	-- Read more about gamma-correct rendering here, here, and here.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param red (number) The red channel of the sRGB color to convert.
	-- @param green (number) The green channel of the sRGB color to convert.
	-- @param blue (number) The blue channel of the sRGB color to convert.
	-- @param alpha (number) The alpha channel, which is returned unchanged. (Default: nil.)
	-- @return (number) lr — The red channel of the converted color in linear RGB space.
	-- @return (number | nil) lg — The green channel of the converted color in linear RGB space.
	-- @return (number | nil) lb — The blue channel of the converted color in linear RGB space.
	-- @return (number | nil) lc — The value of the color channel in linear RGB space.
	gammaToLinear: function(red: number, green?: number, blue?: number, alpha?: number): number, number | nil, number | nil, number | nil

	-- Converts a color from gamma-space (sRGB) to linear-space (RGB). This is useful when doing gamma-correct rendering and you need to do math in linear RGB in the few cases where LÖVE doesn't handle conversions automatically.
	--
	-- Read more about gamma-correct rendering here, here, and here.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param color ({number}) A table with the red, green, and blue channels of the sRGB color to convert.
	-- @return (number) lr — The red channel of the converted color in linear RGB space.
	-- @return (number | nil) lg — The green channel of the converted color in linear RGB space.
	-- @return (number | nil) lb — The blue channel of the converted color in linear RGB space.
	-- @return (number | nil) lc — The value of the color channel in linear RGB space.
	gammaToLinear: function(color: {number}): number, number | nil, number | nil, number | nil

	-- Converts a color from linear-space (RGB) to gamma-space (sRGB). This is useful when storing linear RGB color values in an image, because the linear RGB color space has less precision than sRGB for dark colors, which can result in noticeable color banding when drawing.
	--
	-- In general, colors chosen based on what they look like on-screen are already in gamma-space and should not be double-converted. Colors calculated using math are often in the linear RGB space.
	--
	-- Read more about gamma-correct rendering here, here, and here.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param red (number) The red channel of the linear RGB color to convert.
	-- @param green (number) The green channel of the linear RGB color to convert.
	-- @param blue (number) The blue channel of the linear RGB color to convert.
	-- @param alpha (number) The alpha channel, which is returned unchanged. (Default: nil.)
	-- @return (number) cr — The red channel of the converted color in gamma sRGB space.
	-- @return (number | nil) cg — The green channel of the converted color in gamma sRGB space.
	-- @return (number | nil) cb — The blue channel of the converted color in gamma sRGB space.
	-- @return (number | nil) c — The value of the color channel in gamma sRGB space.
	linearToGamma: function(red: number, green?: number, blue?: number, alpha?: number): number, number | nil, number | nil, number | nil

	-- Converts a color from linear-space (RGB) to gamma-space (sRGB). This is useful when storing linear RGB color values in an image, because the linear RGB color space has less precision than sRGB for dark colors, which can result in noticeable color banding when drawing.
	--
	-- In general, colors chosen based on what they look like on-screen are already in gamma-space and should not be double-converted. Colors calculated using math are often in the linear RGB space.
	--
	-- Read more about gamma-correct rendering here, here, and here.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param color ({number}) A table with the red, green, and blue channels of the linear RGB color to convert.
	-- @return (number) cr — The red channel of the converted color in gamma sRGB space.
	-- @return (number | nil) cg — The green channel of the converted color in gamma sRGB space.
	-- @return (number | nil) cb — The blue channel of the converted color in gamma sRGB space.
	-- @return (number | nil) c — The value of the color channel in gamma sRGB space.
	linearToGamma: function(color: {number}): number, number | nil, number | nil, number | nil

	-- Checks whether a polygon is convex.
	--
	-- PolygonShapes in love.physics, some forms of Meshes, and polygons drawn with love.graphics.polygon must be simple convex polygons.
	-- @param vertices ({number}) The vertices of the polygon as a table in the form of {x1, y1, x2, y2, x3, y3, ...}.
	-- @return (boolean) convex — Whether the given polygon is convex.
	isConvex: function(vertices: {number}): boolean

	-- Checks whether a polygon is convex.
	--
	-- PolygonShapes in love.physics, some forms of Meshes, and polygons drawn with love.graphics.polygon must be simple convex polygons.
	-- @param coordinates (number...) The vertices of the polygon as a table in the form of {x1, y1, x2, y2, x3, y3, ...}.
	-- @return (boolean) convex — Whether the given polygon is convex.
	isConvex: function(coordinates: number...): boolean

	-- Decomposes a simple convex or concave polygon into triangles.
	-- @param vertices ({number}) Polygon to triangulate. Must not intersect itself.
	-- @return ({{number}}) triangles — List of triangles the polygon is composed of, in the form of {{x1, y1, x2, y2, x3, y3}, {x1, y1, x2, y2, x3, y3}, ...}.
	triangulate: function(vertices: {number}): {{number}}

	-- Decomposes a simple convex or concave polygon into triangles.
	-- @param coordinates (number...) Polygon to triangulate. Must not intersect itself.
	-- @return ({{number}}) triangles — List of triangles the polygon is composed of, in the form of {{x1, y1, x2, y2, x3, y3}, {x1, y1, x2, y2, x3, y3}, ...}.
	triangulate: function(coordinates: number...): {{number}}

	-- Deprecated alias of love.data.compress.
	-- @param container (DataContainer) The type of value to return.
	-- @param format (CompressionFormat) The compression format to use.
	-- @param source (string | Data) The uncompressed source data.
	-- @param level (integer) The compression level, from 0 to 9, or -1 for the default level.
	-- @return (string) The compressed data as a string.
	compress: function(container: DataContainer, format: CompressionFormat, source: string | Data, level?: integer): string

	-- Deprecated alias of love.data.compress.
	-- @param container (DataContainer) The type of value to return.
	-- @param format (CompressionFormat) The compression format to use.
	-- @param source (string | Data) The uncompressed source data.
	-- @param level (integer) The compression level, from 0 to 9, or -1 for the default level.
	-- @return (CompressedData) The compressed data as a CompressedData object.
	compress: function(container: DataContainer, format: CompressionFormat, source: string | Data, level?: integer): CompressedData

	-- Deprecated alias of love.data.decompress.
	-- @param container (DataContainer) The type of value to return.
	-- @param compressed (CompressedData) The compressed data to decompress.
	-- @return (string) The decompressed data as a string.
	decompress: function(container: DataContainer, compressed: CompressedData): string

	-- Deprecated alias of love.data.decompress.
	-- @param container (DataContainer) The type of value to return.
	-- @param compressed (CompressedData) The compressed data to decompress.
	-- @return (ByteData) The decompressed data as a ByteData object.
	decompress: function(container: DataContainer, compressed: CompressedData): ByteData
end

-- Represents a file on the filesystem. A function that takes a file path can also take a File.
local record File

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: File): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: File, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: File): boolean

	-- Open the file for write, read or append.
	-- Overload details:
	--   1. If you are getting the error message 'Could not set write directory', try setting the save directory. This is
	--      done either with love.filesystem.setIdentity or by setting the identity field in love.conf (only available
	--      with love 0.7 or higher).
	-- @param mode (FileMode) The mode to open the file in.
	-- @return (boolean or nil) True on success, false otherwise.
	-- @return (string or nil) The error string if an error occurred.
	open: function(self: File, mode: FileMode): boolean | nil, string | nil

	-- Closes a File.
	-- @return (boolean) Whether closing was successful.
	close: function(self: File): boolean

	-- Gets whether the file is open.
	-- @return (boolean) True if the file is currently open, false otherwise.
	isOpen: function(self: File): boolean

	-- Returns the file size.
	-- @return (number or nil) The file size in bytes.
	getSize: function(self: File): number | nil, string | nil

	-- Read a number of bytes from a file.
	-- @param size (integer) The number of bytes to read. (Default: all.)
	-- @return (string | nil) contents — The contents of the read bytes.
	-- @return (number | string) size — How many bytes have been read.
	read: function(self: File, size?: integer): string | nil, number | string

	-- Read a number of bytes from a file.
	-- @param container (DataContainer) What type to return the file's contents as.
	-- @param size (integer) The number of bytes to read. (Default: all.)
	-- @return (string | nil) FileData or string containing the read bytes.
	-- @return (number | string) size — How many bytes have been read.
	read: function(self: File, container: DataContainer, size?: integer): string | nil, number | string

	-- Read a number of bytes from a file.
	-- @param container (DataContainer) What type to return the file's contents as.
	-- @param size (integer) The number of bytes to read. (Default: all.)
	-- @return (FileData | nil) FileData or string containing the read bytes.
	-- @return (number | string) size — How many bytes have been read.
	read: function(self: File, container: DataContainer, size?: integer): FileData | nil, number | string

	-- Write data to a file.
	-- @param data (string) The string data to write.
	-- @param size (integer) How many bytes to write. (Default: all.)
	-- @return (boolean | nil) success — Whether the operation was successful.
	-- @return (string | nil) err — The error string if an error occurred.
	write: function(self: File, data: string, size?: integer): boolean | nil, string | nil

	-- Write data to a file.
	-- @param data (FileData) The Data object to write.
	-- @param size (integer) How many bytes to write. (Default: all.)
	-- @return (boolean | nil) success — Whether the operation was successful.
	-- @return (string | nil) err — The error string if an error occurred.
	write: function(self: File, data: FileData, size?: integer): boolean | nil, string | nil

	-- Flushes any buffered written data in the file to the disk.
	-- @return (boolean or nil) Whether the file successfully flushed any buffered data to the disk.
	-- @return (string or nil) The error string, if an error occurred and the file could not be flushed.
	flush: function(self: File): boolean | nil, string | nil

	-- Gets whether end-of-file has been reached.
	-- @return (boolean) Whether EOF has been reached.
	isEOF: function(self: File): boolean

	-- Returns the position in the file.
	-- @return (number or nil) The current position.
	tell: function(self: File): number | nil, string | nil

	-- Seek to a position in a file
	-- @param position (number) The position to seek to
	-- @return (boolean) Whether the operation was successful
	seek: function(self: File, position: number): boolean

	-- Iterate over all the lines in a file.
	-- @return (function or string or nil) The iterator (can be used in for loops).
	lines: function(self: File): function(): string | nil

	-- Sets the buffer mode for a file opened for writing or appending. Files with buffering enabled will not write data
	-- to the disk until the buffer size limit is reached, depending on the buffer mode.
	-- File:flush will force any buffered data to be written to the disk.
	-- @param mode (BufferMode) The buffer mode to use.
	-- @param size (integer) The maximum size in bytes of the file's buffer. (Default: 0.)
	-- @return (boolean) Whether the buffer mode was successfully set.
	setBuffer: function(self: File, mode: BufferMode, size?: integer): boolean

	-- Gets the buffer mode of a file.
	-- @return (BufferMode) The current buffer mode of the file.
	-- @return (integer) The maximum size in bytes of the file's buffer.
	getBuffer: function(self: File): BufferMode, integer

	-- Gets the FileMode the file has been opened with.
	-- @return (FileMode) The mode this file has been opened with.
	getMode: function(self: File): FileMode

	-- Gets the filename that the File object was created with. If the file object originated from the love.filedropped
	-- callback, the filename will be the full platform-dependent file path.
	-- @return (string) The filename of the File.
	getFilename: function(self: File): string
	getExtension: function(self: File): string
end
local record FileInfo
	type: FileType
	size: number | nil
	modtime: number | nil
end

-- Provides an interface to the user's filesystem.
local record Filesystem

	-- Sets the write directory for your game.
	-- Note that you can only set the name of the folder to store your files in, not the location.
	-- @param identity (string) The new identity that will be used as write directory.
	-- @param append_to_path (boolean) The append_to_path parameter.
	setIdentity: function(identity: string, append_to_path?: boolean)

	-- Gets the write directory name for your game.
	-- Note that this only returns the name of the folder to store your files in, not the full path.
	-- @return (string) The identity that is used as write directory.
	getIdentity: function(): string

	-- Returns the full path to the the .love file or directory. If the game is fused to the LÖVE executable, then the
	-- executable is returned.
	-- @return (string) The full platform-dependent path of the .love file or directory.
	getSource: function(): string

	-- Gets the full path to the designated save directory.
	-- This can be useful if you want to use the standard io library (or something else) to
	-- read or write in the save directory.
	-- @return (string) The absolute path to the save directory.
	getSaveDirectory: function(): string

	-- Gets the current working directory.
	-- @return (string) The current working directory.
	getWorkingDirectory: function(): string

	-- Returns the path of the user's directory
	-- @return (string) The path of the user's directory
	getUserDirectory: function(): string

	-- Returns the application data directory (could be the same as getUserDirectory)
	-- @return (string) The path of the application data directory
	getAppdataDirectory: function(): string

	-- Returns the full path to the directory containing the .love file. If the game is fused to the LÖVE executable,
	-- then the directory containing the executable is returned.
	-- If love.filesystem.isFused is true, the path returned by this function can be passed to love.filesystem.mount,
	-- which will make the directory containing the main game (e.g. C:\Program Files\coolgame\) readable by
	-- love.filesystem.
	-- @return (string) The full platform-dependent path of the directory containing the .love file.
	getSourceBaseDirectory: function(): string
	getExecutablePath: function(): string

	-- Gets the platform-specific absolute path of the directory containing a filepath.
	-- This can be used to determine whether a file is inside the save directory or the game's source .love.
	-- Overload details:
	--   1. This function returns the directory containing the given ''file path'', rather than file. For example, if the
	--      file screenshot1.png exists in a directory called screenshots in the game's save directory,
	--      love.filesystem.getRealDirectory('screenshots/screenshot1.png') will return the same value as
	--      love.filesystem.getSaveDirectory.
	-- @param filename (string) The filepath to get the directory of.
	-- @return (string or nil) The platform-specific full path of the directory containing the filepath.
	getRealDirectory: function(filename: string): string | nil, string | nil

	-- Gets the filesystem paths that will be searched when require is called.
	-- The paths string returned by this function is a sequence of path templates separated by semicolons. The argument
	-- passed to ''require'' will be inserted in place of any question mark ('?') character in each template (after the
	-- dot characters in the argument passed to ''require'' are replaced by directory separators.)
	-- The paths are relative to the game's source and save directories, as well as any paths mounted with
	-- love.filesystem.mount.
	-- Overload details:
	--   1. The default paths string is '?.lua;?/init.lua', which makes require('cool') try to load cool.lua and then try
	--      cool/init.lua if cool.lua doesn't exist.
	-- @return (string) The paths that the ''require'' function will check in love's filesystem.
	getRequirePath: function(): string

	-- Sets the filesystem paths that will be searched when require is called.
	-- The paths string given to this function is a sequence of path templates separated by semicolons. The argument
	-- passed to ''require'' will be inserted in place of any question mark ('?') character in each template (after the
	-- dot characters in the argument passed to ''require'' are replaced by directory separators.)
	-- The paths are relative to the game's source and save directories, as well as any paths mounted with
	-- love.filesystem.mount.
	-- Overload details:
	--   1. The default paths string is '?.lua;?/init.lua', which makes require('cool') try to load cool.lua and then try
	--      cool/init.lua if cool.lua doesn't exist.
	-- @param path (string) The paths that the ''require'' function will check in love's filesystem.
	setRequirePath: function(path: string)

	-- Mounts a zip file or folder in the game's save directory for reading.
	--
	-- It is also possible to mount love.filesystem.getSourceBaseDirectory if the game is in fused mode.
	-- @param archive (string) The folder or zip file in the game's save directory to mount.
	-- @param mountpoint (string) The new path the archive will be mounted to.
	-- @param append_to_path (boolean) Whether the archive will be searched when reading a filepath before or after already-mounted archives. This includes the game's source and save directories. (Default: false.)
	-- @return (boolean) success — True if the archive was successfully mounted, false otherwise.
	mount: function(archive: string, mountpoint: string, append_to_path?: boolean): boolean

	-- Mounts a zip file or folder in the game's save directory for reading.
	--
	-- It is also possible to mount love.filesystem.getSourceBaseDirectory if the game is in fused mode.
	-- @param archive (FileData) The folder or zip file in the game's save directory to mount.
	-- @param mountpoint (string) The new path the archive will be mounted to.
	-- @param append_to_path (boolean) Whether the archive will be searched when reading a filepath before or after already-mounted archives. This includes the game's source and save directories. (Default: false.)
	-- @return (boolean) success — True if the archive was successfully mounted, false otherwise.
	mount: function(archive: FileData, mountpoint: string, append_to_path?: boolean): boolean

	-- Unmounts a zip file or folder previously mounted for reading with love.filesystem.mount.
	-- @param archive (string) The folder or zip file in the game's save directory which is currently mounted.
	-- @return (boolean) success — True if the archive was successfully unmounted, false otherwise.
	unmount: function(archive: string): boolean

	-- Unmounts a zip file or folder previously mounted for reading with love.filesystem.mount.
	-- @param archive (FileData) The folder or zip file in the game's save directory which is currently mounted.
	-- @return (boolean) success — True if the archive was successfully unmounted, false otherwise.
	unmount: function(archive: FileData): boolean

	-- Gets whether the game is in fused mode or not.
	-- If a game is in fused mode, its save directory will be directly in the Appdata directory instead of Appdata/LOVE/.
	-- The game will also be able to load C Lua dynamic libraries which are located in the save directory.
	-- A game is in fused mode if the source .love has been fused to the executable (see Game Distribution), or if
	-- '--fused' has been given as a command-line argument when starting the game.
	-- @return (boolean) True if the game is in fused mode, false otherwise.
	isFused: function(): boolean

	-- Creates a new File object.
	--
	-- It needs to be opened before it can be accessed.
	-- @param filename (string) The filename of the file.
	-- @return (File) file — The new File object.
	newFile: function(filename: string): File

	-- Creates a new File object.
	--
	-- It needs to be opened before it can be accessed.
	-- @param filename (string) The filename of the file.
	-- @param mode (OpenFileMode) The mode to open the file in.
	-- @return (File) The new File object, or nil if an error occurred.
	newFile: function(filename: string, mode: OpenFileMode): File

	-- Creates a new FileData object from a file on disk, or from a string in memory.
	-- @param filename (string) Path to the file.
	-- @return (FileData) data — The new FileData.
	newFileData: function(filename: string): FileData

	-- Creates a new FileData object from a file on disk, or from a string in memory.
	-- @param file (File) Path to the file.
	-- @return (FileData) The new FileData, or nil if an error occurred.
	newFileData: function(file: File): FileData

	-- Creates a new FileData object from a file on disk, or from a string in memory.
	-- @param data (string) The Data object to copy into the new FileData object.
	-- @param filename (string) The name of the file. The extension may be parsed and used by LÖVE when passing the FileData object into love.audio.newSource.
	-- @return (FileData) The new FileData, or nil if an error occurred.
	newFileData: function(data: string, filename: string): FileData

	-- Read the contents of a file.
	-- @param filename (string) The name (and path) of the file.
	-- @param size (integer) How many bytes to read. (Default: all.)
	-- @return (string | nil) contents — The file contents.
	-- @return (number | string) size — How many bytes have been read.
	read: function(filename: string, size?: integer): string | nil, number | string

	-- Read the contents of a file.
	-- @param container (DataContainer) What type to return the file's contents as.
	-- @param filename (string) The name (and path) of the file
	-- @param size (integer) How many bytes to read (Default: all.)
	-- @return (string | nil) returns nil as content.
	-- @return (number | string) size — How many bytes have been read.
	read: function(container: DataContainer, filename: string, size?: integer): string | nil, number | string

	-- Read the contents of a file.
	-- @param container (DataContainer) What type to return the file's contents as.
	-- @param filename (string) The name (and path) of the file
	-- @param size (integer) How many bytes to read (Default: all.)
	-- @return (FileData | nil) FileData or string containing the file contents.
	-- @return (number | string) size — How many bytes have been read.
	read: function(container: DataContainer, filename: string, size?: integer): FileData | nil, number | string

	-- Loads a Lua file (but does not run it).
	-- @param filename (string) The name (and path) of the file.
	-- @return (function) The loaded chunk.
	-- @return (string or nil) The error message if file could not be opened.
	load: function(filename: string): function | nil, string | nil

	-- Iterate over the lines in a file.
	-- @param filename (string) The name (and path) of the file
	-- @return (function or string or nil) A function that iterates over all the lines in the file
	lines: function(filename: string): function(): string | nil

	-- Write data to a file in the save directory. If the file existed already, it will be completely replaced by the new contents.
	-- @param filename (string) The name (and path) of the file.
	-- @param data (string) The string data to write to the file.
	-- @param size (integer) How many bytes to write. (Default: all.)
	-- @return (boolean) success — If the operation was successful.
	-- @return (string | nil) message — Error message if operation was unsuccessful.
	write: function(filename: string, data: string, size?: integer): boolean, string | nil

	-- Write data to a file in the save directory. If the file existed already, it will be completely replaced by the new contents.
	-- @param filename (string) The name (and path) of the file.
	-- @param data (FileData) The Data object to write to the file.
	-- @param size (integer) How many bytes to write. (Default: all.)
	-- @return (boolean) success — If the operation was successful.
	-- @return (string | nil) message — Error message if operation was unsuccessful.
	write: function(filename: string, data: FileData, size?: integer): boolean, string | nil

	-- Append data to an existing file.
	-- @param filename (string) The name (and path) of the file.
	-- @param data (string) The string data to append to the file.
	-- @param size (integer) How many bytes to write. (Default: all.)
	-- @return (boolean) success — True if the operation was successful, or nil if there was an error.
	-- @return (string | nil) errormsg — The error message on failure.
	append: function(filename: string, data: string, size?: integer): boolean, string | nil

	-- Append data to an existing file.
	-- @param filename (string) The name (and path) of the file.
	-- @param data (FileData) The Data object to append to the file.
	-- @param size (integer) How many bytes to write. (Default: all.)
	-- @return (boolean) success — True if the operation was successful, or nil if there was an error.
	-- @return (string | nil) errormsg — The error message on failure.
	append: function(filename: string, data: FileData, size?: integer): boolean, string | nil

	-- Gets information about the specified file or directory.
	-- @param filename (string) The file or directory path to check.
	-- @return (FileInfo | nil) info — A table containing information about the specified path, or nil if nothing exists at the path. The table contains the following fields:
	getInfo: function(filename: string): FileInfo | nil

	-- Gets information about the specified file or directory.
	-- @param filename (string) The file or directory path to check.
	-- @param filter_type (FileType) Causes getInfo to only return the info table if the item at the given path matches the specified file type.
	-- @return (FileInfo | nil) The table given as an argument, or nil if nothing exists at the path. The table will be filled in with the following fields:
	getInfo: function(filename: string, filter_type: FileType): FileInfo | nil
	exists: function(filename: string): boolean
	isDirectory: function(filename: string): boolean
	isFile: function(filename: string): boolean
	isSymlink: function(filename: string): boolean
	getLastModified: function(filename: string): number | nil, string | nil
	getSize: function(filename: string): number | nil, string | nil

	-- Recursively creates a directory.
	-- When called with 'a/b' it creates both 'a' and 'a/b', if they don't exist already.
	-- @param name (string) The directory to create.
	-- @return (boolean) True if the directory was created, false if not.
	createDirectory: function(name: string): boolean, string | nil

	-- Removes a file or empty directory.
	-- Overload details:
	--   1. The directory must be empty before removal or else it will fail. Simply remove all files and folders in the
	--      directory beforehand. If the file exists in the .love but not in the save directory, it returns false as
	--      well. An opened File prevents removal of the underlying file. Simply close the File to remove it.
	-- @param name (string) The file or directory to remove.
	-- @return (boolean) True if the file/directory was removed, false otherwise.
	remove: function(name: string): boolean, string | nil

	-- Returns a table with the names of files and subdirectories in the specified path. The table is not sorted in any
	-- way; the order is undefined.
	-- If the path passed to the function exists in the game and the save directory, it will list the files and
	-- directories from both places.
	-- @param directory (string) The directory.
	-- @return ({string}) A sequence with the names of all files and subdirectories as strings.
	getDirectoryItems: function(directory?: string): {string}
end

local type QuitCallback = function(): boolean | nil

-- Provides an interface to the user's keyboard.
local record Keyboard

	-- Enables or disables key repeat for love.keypressed. It is disabled by default.
	-- Overload details:
	--   1. The interval between repeats depends on the user's system settings. This function doesn't affect whether
	--      love.textinput is called multiple times while a key is held down.
	-- @param enabled (boolean) Whether repeat keypress events should be enabled when a key is held down.
	setKeyRepeat: function(enabled: boolean)

	-- Gets whether key repeat is enabled.
	-- @return (boolean) Whether key repeat is enabled.
	hasKeyRepeat: function(): boolean

	-- Checks whether a certain key is down. Not to be confused with love.keypressed or love.keyreleased.
	-- @param keys (string...) A table containing keys to check.
	-- @return (boolean) down — True if the key is down, false if not.
	isDown: function(keys: string...): boolean

	-- Checks whether a certain key is down. Not to be confused with love.keypressed or love.keyreleased.
	-- @param keys ({string}) A table containing keys to check.
	-- @return (boolean) down — True if the key is down, false if not.
	isDown: function(keys: {string}): boolean

	-- Checks whether the specified Scancodes are pressed. Not to be confused with love.keypressed or love.keyreleased.
	--
	-- Unlike regular KeyConstants, Scancodes are keyboard layout-independent. The scancode 'w' is used if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.
	-- @param scancodes (string...) A Scancode to check.
	-- @return (boolean) down — True if any supplied Scancode is down, false if not.
	isScancodeDown: function(scancodes: string...): boolean

	-- Checks whether the specified Scancodes are pressed. Not to be confused with love.keypressed or love.keyreleased.
	--
	-- Unlike regular KeyConstants, Scancodes are keyboard layout-independent. The scancode 'w' is used if the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's operating system settings are.
	-- @param scancodes ({string}) A Scancode to check.
	-- @return (boolean) down — True if any supplied Scancode is down, false if not.
	isScancodeDown: function(scancodes: {string}): boolean

	-- Gets the hardware scancode corresponding to the given key.
	-- Unlike key constants, Scancodes are keyboard layout-independent. For example the scancode 'w' will be generated if
	-- the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or
	-- what the user's operating system settings are.
	-- Scancodes are useful for creating default controls that have the same physical locations on on all systems.
	-- @param key (string) The key to get the scancode from.
	-- @return (string) The scancode corresponding to the given key, or 'unknown' if the given key has no known physical representation on the current system.
	getScancodeFromKey: function(key: string): string

	-- Gets the key corresponding to the given hardware scancode.
	-- Unlike key constants, Scancodes are keyboard layout-independent. For example the scancode 'w' will be generated if
	-- the key in the same place as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or
	-- what the user's operating system settings are.
	-- Scancodes are useful for creating default controls that have the same physical locations on on all systems.
	-- @param scancode (string) The scancode to get the key from.
	-- @return (string) The key corresponding to the given scancode, or 'unknown' if the scancode doesn't map to a KeyConstant on the current system.
	getKeyFromScancode: function(scancode: string): string

	-- Enables or disables text input events. It is enabled by default on Windows, Mac, and Linux, and disabled by default on iOS and Android.
	--
	-- On touch devices, this shows the system's native on-screen keyboard when it's enabled.
	-- @param enabled (boolean) Whether text input events should be enabled.
	setTextInput: function(enabled: boolean)

	-- Enables or disables text input events. It is enabled by default on Windows, Mac, and Linux, and disabled by default on iOS and Android.
	--
	-- On touch devices, this shows the system's native on-screen keyboard when it's enabled.
	-- @param enabled (boolean) Whether text input events should be enabled.
	-- @param x (number) Text rectangle x position.
	-- @param y (number) Text rectangle y position.
	-- @param width (number) Text rectangle width.
	-- @param height (number) Text rectangle height.
	setTextInput: function(enabled: boolean, x: number, y: number, width: number, height: number)

	-- Gets whether text input events are enabled.
	-- @return (boolean) Whether text input events are enabled.
	hasTextInput: function(): boolean

	-- Gets whether screen keyboard is supported.
	-- @return (boolean) Whether screen keyboard is supported.
	hasScreenKeyboard: function(): boolean
end

local enum CursorType
	"image"
	"arrow"
	"ibeam"
	"wait"
	"crosshair"
	"waitarrow"
	"sizenwse"
	"sizenesw"
	"sizewe"
	"sizens"
	"sizeall"
	"no"
	"hand"
end

-- Represents a hardware cursor.
local record Cursor

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Cursor): boolean

	-- Gets the type of the Cursor.
	-- @return (CursorType) The type of the Cursor.
	getType: function(self: Cursor): CursorType

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Cursor): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Cursor, type_name: string): boolean
end

-- Provides an interface to the user's mouse.
local record Mouse

	-- Returns the current position of the mouse.
	-- @return (number) The position of the mouse along the x-axis.
	-- @return (number) The position of the mouse along the y-axis.
	getPosition: function(): number, number

	-- Returns the current x-position of the mouse.
	-- @return (number) The position of the mouse along the x-axis.
	getX: function(): number

	-- Returns the current y-position of the mouse.
	-- @return (number) The position of the mouse along the y-axis.
	getY: function(): number

	-- Sets the current position of the mouse. Non-integer values are floored.
	-- @param x (number) The new position of the mouse along the x-axis.
	-- @param y (number) The new position of the mouse along the y-axis.
	setPosition: function(x: number, y: number)

	-- Sets the current X position of the mouse.
	-- Non-integer values are floored.
	-- @param x (number) The new position of the mouse along the x-axis.
	setX: function(x: number)

	-- Sets the current Y position of the mouse.
	-- Non-integer values are floored.
	-- @param y (number) The new position of the mouse along the y-axis.
	setY: function(y: number)

	-- Checks whether a certain mouse button is down.
	--
	-- This function does not detect mouse wheel scrolling; you must use the love.wheelmoved (or love.mousepressed in version 0.9.2 and older) callback for that.
	-- @param buttons (number...) The index of a button to check. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependant.
	-- @return (boolean) down — True if any specified button is down.
	isDown: function(buttons: number...): boolean

	-- Checks whether a certain mouse button is down.
	--
	-- This function does not detect mouse wheel scrolling; you must use the love.wheelmoved (or love.mousepressed in version 0.9.2 and older) callback for that.
	-- @param buttons ({number}) The index of a button to check. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependant.
	-- @return (boolean) down — True if any specified button is down.
	isDown: function(buttons: {number}): boolean

	-- Sets the current visibility of the cursor.
	-- @param visible (boolean) True to set the cursor to visible, false to hide the cursor.
	setVisible: function(visible: boolean)

	-- Checks if the cursor is visible.
	-- @return (boolean) True if the cursor to visible, false if the cursor is hidden.
	isVisible: function(): boolean

	-- Grabs the mouse and confines it to the window.
	-- @param grabbed (boolean) True to confine the mouse, false to let it leave the window.
	setGrabbed: function(grabbed: boolean)

	-- Checks if the mouse is grabbed.
	-- @return (boolean) True if the cursor is grabbed, false if it is not.
	isGrabbed: function(): boolean

	-- Sets whether relative mode is enabled for the mouse.
	-- When relative mode is enabled, the cursor is hidden and doesn't move when the mouse does, but relative mouse
	-- motion events are still generated via love.mousemoved. This lets the mouse move in any direction indefinitely
	-- without the cursor getting stuck at the edges of the screen.
	-- The reported position of the mouse may not be updated while relative mode is enabled, even when relative mouse
	-- motion events are generated.
	-- @param relative (boolean) True to enable relative mode, false to disable it.
	setRelativeMode: function(relative: boolean): boolean

	-- Gets whether relative mode is enabled for the mouse.
	-- If relative mode is enabled, the cursor is hidden and doesn't move when the mouse does, but relative mouse motion
	-- events are still generated via love.mousemoved. This lets the mouse move in any direction indefinitely without the
	-- cursor getting stuck at the edges of the screen.
	-- The reported position of the mouse is not updated while relative mode is enabled, even when relative mouse motion
	-- events are generated.
	-- @return (boolean) True if relative mode is enabled, false if it's disabled.
	getRelativeMode: function(): boolean

	-- Creates a new hardware Cursor object from an image file or ImageData.
	-- Hardware cursors are framerate-independent and work the same way as normal operating system cursors. Unlike
	-- drawing an image at the mouse's current coordinates, hardware cursors never have visible lag between when the
	-- mouse is moved and when the cursor position updates, even at low framerates.
	-- The hot spot is the point the operating system uses to determine what was clicked and at what position the mouse
	-- cursor is. For example, the normal arrow pointer normally has its hot spot at the top left of the image, but a
	-- crosshair cursor might have it in the middle.
	-- @param image (ImageData or FileData or string) The ImageData to use for the new Cursor. Depending on the overload: Path to the image to use for the new Cursor. Depending on the overload: Data representing the image to use for the new Cursor.
	-- @param hot_x (integer) The x-coordinate in the ImageData of the cursor's hot spot. (Default: 0.) Depending on the overload: The x-coordinate in the image of the cursor's hot spot. (Default: 0.)
	-- @param hot_y (integer) The y-coordinate in the ImageData of the cursor's hot spot. (Default: 0.) Depending on the overload: The y-coordinate in the image of the cursor's hot spot. (Default: 0.)
	-- @return (Cursor) The new Cursor object.
	newCursor: function(image: ImageData | FileData | string, hot_x?: integer, hot_y?: integer): Cursor

	-- Gets a Cursor object representing a system-native hardware cursor.
	-- Hardware cursors are framerate-independent and work the same way as normal operating system cursors. Unlike
	-- drawing an image at the mouse's current coordinates, hardware cursors never have visible lag between when the
	-- mouse is moved and when the cursor position updates, even at low framerates.
	-- Overload details:
	--   1. The 'image' CursorType is not a valid argument. Use love.mouse.newCursor to create a hardware cursor using a
	--      custom image.
	-- @param cursor_type (SystemCursor) The type of system cursor to get.
	-- @return (Cursor) The Cursor object representing the system cursor type.
	getSystemCursor: function(cursor_type: SystemCursor): Cursor

	-- Sets the current mouse cursor.
	setCursor: function()

	-- Sets the current mouse cursor.
	-- @param cursor (Cursor) The Cursor object to use as the current mouse cursor.
	setCursor: function(cursor: Cursor)

	-- Gets the current Cursor.
	-- @return (Cursor or nil) The current cursor, or nil if no cursor is set.
	getCursor: function(): Cursor | nil

	-- Gets whether cursor functionality is supported.
	-- If it isn't supported, calling love.mouse.newCursor and love.mouse.getSystemCursor will cause an error. Mobile
	-- devices do not support cursors.
	-- @return (boolean) Whether the system has cursor functionality.
	isCursorSupported: function(): boolean
end

-- Provides an interface to the user's clock.
local record Timer

	-- Measures the time between two frames.
	-- Calling this changes the return value of love.timer.getDelta.
	-- @return (number) The time passed (in seconds).
	step: function(): number

	-- Returns the time between the last two frames.
	-- @return (number) The time passed (in seconds).
	getDelta: function(): number

	-- Returns the current frames per second.
	-- @return (integer) The current FPS.
	getFPS: function(): integer

	-- Returns the average delta time (seconds per frame) over the last second.
	-- @return (number) The average delta time over the last second.
	getAverageDelta: function(): number

	-- Pauses the current thread for the specified amount of time.
	-- @param seconds (number) Seconds to sleep for.
	sleep: function(seconds: number)

	-- Returns the value of a timer with an unspecified starting time.
	-- This function should only be used to calculate differences between points in time, as the starting time of the
	-- timer is unknown.
	-- @return (number) The time in seconds. Given as a decimal, accurate to the microsecond.
	getTime: function(): number
end

-- Provides access to information about the user's system.
local record System

	-- Gets the current operating system. In general, LÖVE abstracts away the need to know the current operating system,
	-- but there are a few cases where it can be useful (especially in combination with os.execute.)
	-- Overload details:
	--   1. In LÖVE version 0.8.0, the '''love._os''' string contains the current operating system.
	-- @return (OS) The current operating system. 'OS X', 'Windows', 'Linux', 'Android' or 'iOS'.
	getOS: function(): OS

	-- Gets the amount of logical processor in the system.
	-- Overload details:
	--   1. The number includes the threads reported if technologies such as Intel's Hyper-threading are enabled. For
	--      example, on a 4-core CPU with Hyper-threading, this function will return 8.
	-- @return (integer) Amount of logical processors.
	getProcessorCount: function(): integer

	-- Puts text in the clipboard.
	-- @param text (string) The new text to hold in the system's clipboard.
	setClipboardText: function(text: string)

	-- Gets text from the clipboard.
	-- @return (string) The text currently held in the system's clipboard.
	getClipboardText: function(): string

	-- Gets information about the system's power supply.
	-- @return (PowerState) The basic state of the power supply.
	-- @return (integer or nil) Percentage of battery life left, between 0 and 100. nil if the value can't be determined or there's no battery.
	-- @return (integer or nil) Seconds of battery life left. nil if the value can't be determined or there's no battery.
	getPowerInfo: function(): PowerState, integer | nil, integer | nil

	-- Opens a URL with the user's web or file browser.
	-- Overload details:
	--   1. Passing file:// scheme in Android 7.0 (Nougat) and later always result in failure. Prior to 11.2, this will
	--      crash LÖVE instead of returning false.
	-- @param url (string) The URL to open. Must be formatted as a proper URL.
	-- @return (boolean) Whether the URL was opened successfully.
	openURL: function(url: string): boolean

	-- Causes the device to vibrate, if possible. Currently this will only work on Android and iOS devices that have a
	-- built-in vibration motor.
	-- @param seconds (number) The duration to vibrate for. If called on an iOS device, it will always vibrate for 0.5 seconds due to limitations in the iOS system APIs. (Default: 0.5.)
	vibrate: function(seconds?: number)

	-- Gets whether another application on the system is playing music in the background.
	-- Currently this is implemented on iOS and Android, and will always return false on other operating systems. The
	-- t.audio.mixwithsystem flag in love.conf can be used to configure whether background audio / music from other apps
	-- should play while LÖVE is open.
	-- @return (boolean) True if the user is playing music in the background via another app, false otherwise.
	hasBackgroundMusic: function(): boolean
end

-- A Thread is a chunk of code that can run in parallel with other threads. Data can be sent between different
-- threads with Channel objects.
local record Thread

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Thread): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Thread): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Thread, type_name: string): boolean

	-- Starts the thread.
	-- Beginning with version 0.9.0, threads can be restarted after they have completed their execution.
	-- Overload details:
	--   1. Arguments passed to Thread:start are accessible in the thread's main file via '''...''' (the vararg
	--      expression.)
	-- @param args (any...) A string, number, boolean, LÖVE object, or simple table.
	start: function(self: Thread, args: any...): boolean

	-- Wait for a thread to finish.
	-- This call will block until the thread finishes.
	wait: function(self: Thread)

	-- Retrieves the error string from the thread if it produced an error.
	-- @return (string or nil) The error message, or nil if the Thread has not caused an error.
	getError: function(self: Thread): string | nil

	-- Returns whether the thread is currently running.
	-- Threads which are not running can be (re)started with Thread:start.
	-- @return (boolean) True if the thread is running, false otherwise.
	isRunning: function(self: Thread): boolean
end

-- An object which can be used to send and receive data between different threads.
local record Channel

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Channel): boolean

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Channel): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Channel, type_name: string): boolean

	-- Send a message to the thread Channel.
	-- See Variant for the list of supported types.
	-- @param value (any) The contents of the message.
	-- @return (number) Identifier which can be supplied to Channel:hasRead
	push: function(self: Channel, value: any): number

	-- Send a message to the thread Channel and wait for a thread to accept it.
	-- See Variant for the list of supported types.
	-- @param value (any) The contents of the message.
	-- @param timeout (number) The maximum amount of time to wait.
	-- @return (boolean) Whether the message was successfully supplied (always true). Depending on the overload: Whether the message was successfully supplied before the timeout expired.
	supply: function(self: Channel, value: any, timeout?: number): boolean

	-- Retrieves the value of a Channel message and removes it from the message queue.
	-- It returns nil if there are no messages in the queue.
	-- @return (any) The contents of the message.
	pop: function(self: Channel): any

	-- Retrieves the value of a Channel message and removes it from the message queue.
	-- It waits until a message is in the queue then returns the message value.
	-- @param timeout (number) The maximum amount of time to wait.
	-- @return (any) The contents of the message. Depending on the overload: The contents of the message or nil if the timeout expired.
	demand: function(self: Channel, timeout?: number): any

	-- Retrieves the value of a Channel message, but leaves it in the queue.
	-- It returns nil if there's no message in the queue.
	-- @return (any) The contents of the message.
	peek: function(self: Channel): any

	-- Retrieves the number of messages in the thread Channel queue.
	-- @return (integer) The number of messages in the queue.
	getCount: function(self: Channel): integer

	-- Gets whether a pushed value has been popped or otherwise removed from the Channel.
	-- @param id (number) An id value previously returned by Channel:push.
	-- @return (boolean) Whether the value represented by the id has been removed from the Channel via Channel:pop,
	hasRead: function(self: Channel, id: number): boolean

	-- Clears all the messages in the Channel queue.
	clear: function(self: Channel)

	-- Executes the specified function atomically with respect to this Channel.
	-- Calling multiple methods in a row on the same Channel is often useful. However if multiple Threads are calling
	-- this Channel's methods at the same time, the different calls on each Thread might end up interleaved (e.g. one or
	-- more of the second thread's calls may happen in between the first thread's calls.)
	-- This method avoids that issue by making sure the Thread calling the method has exclusive access to the Channel
	-- until the specified function has returned.
	-- @param callback (any) The function to call, the form of function(channel, arg1, arg2, ...) end. The Channel is passed as the first argument to the function when it is called.
	-- @param args (any...) Additional arguments that the given function will receive when it is called.
	-- @return (any) The first return value of the given function (if any.)
	performAtomic: function(self: Channel, callback: any, args: any...): any
end

-- Allows you to work with threads.
local record ThreadModule

	-- Creates a new Thread from a filename, string or FileData object containing Lua code.
	-- @param code_or_filename (string or any) The name of the Lua file to use as the source. Depending on the overload: The FileData containing the Lua code to use as the source. Depending on the overload: A string containing the Lua code to use as the source. It needs to either be at least 1024 characters long, or contain at least one newline.
	-- @return (Thread) A new Thread that has yet to be started.
	newThread: function(code_or_filename: string | any): Thread

	-- Create a new unnamed thread channel.
	-- One use for them is to pass new unnamed channels to other threads via Channel:push on a named channel.
	-- @return (Channel) The new Channel object.
	newChannel: function(): Channel

	-- Creates or retrieves a named thread channel.
	-- @param name (string) The name of the channel you want to create or retrieve.
	-- @return (Channel) The Channel object associated with the name.
	getChannel: function(name: string): Channel
end

local record AudioFilterSettings
	type: AudioFilterType
	volume: number
	lowgain: number
	highgain: number
end

local record AudioEffectSettings
	type: AudioEffectType
	volume: number
	gain: number
	highgain: number
	density: number
	diffusion: number
	decaytime: number
	decayhighratio: number
	earlygain: number
	earlydelay: number
	lategain: number
	latedelay: number
	roomrolloff: number
	airabsorption: number
	highlimit: boolean
	waveform: string
	phase: number
	rate: number
	depth: number
	feedback: number
	delay: number
	edge: number
	lowcut: number
	center: number
	bandwidth: number
	tapdelay: number
	damping: number
	spread: number
	frequency: number
	highcut: number
	enable: boolean
	lowgain: number
	lowmidgain: number
	lowmidfrequency: number
	lowmidbandwidth: number
	highmidgain: number
	highmidfrequency: number
	highmidbandwidth: number
end

-- A Source represents audio you can play back.
local record Source

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Source): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Source, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Source): boolean

	-- Creates an identical copy of the Source in the stopped state.
	-- Static Sources will use significantly less memory and take much less time to be created if Source:clone is used to
	-- create them instead of love.audio.newSource, so this method should be preferred when making multiple Sources which
	-- play the same sound.
	-- Overload details:
	--   1. Cloned Sources inherit all the set-able state of the original Source, but they are initialized stopped.
	-- @return (Source) The new identical copy of this Source.
	clone: function(self: Source): Source

	-- Starts playing the Source.
	-- @return (boolean) Whether the Source was able to successfully start playing.
	play: function(self: Source): boolean

	-- Pauses the Source.
	pause: function(self: Source)

	-- Stops a Source.
	stop: function(self: Source)

	-- Returns whether the Source is playing.
	-- @return (boolean) True if the Source is playing, false otherwise.
	isPlaying: function(self: Source): boolean

	-- Returns whether this Source is stopped. Deprecated compatibility alias which is true only when the Source is
	-- neither playing nor paused.
	isStopped: function(self: Source): boolean
	isPaused: function(self: Source): boolean

	-- Sets whether the Source should loop.
	-- @param looping (boolean) True if the source should loop, false otherwise.
	setLooping: function(self: Source, looping: boolean)

	-- Returns whether the Source will loop.
	-- @return (boolean) True if the Source will loop, false otherwise.
	isLooping: function(self: Source): boolean

	-- Sets the current volume of the Source.
	-- @param volume (number) The volume for a Source, where 1.0 is normal volume. Volume cannot be raised above 1.0.
	setVolume: function(self: Source, volume: number)

	-- Gets the current volume of the Source.
	-- @return (number) The volume of the Source, where 1.0 is normal volume.
	getVolume: function(self: Source): number

	-- Sets the pitch of the Source.
	-- @param pitch (number) Calculated with regard to 1 being the base pitch. Each reduction by 50 percent equals a pitch shift of -12 semitones (one octave reduction). Each doubling equals a pitch shift of 12 semitones (one octave increase). Zero is not a legal value.
	setPitch: function(self: Source, pitch: number)

	-- Gets the current pitch of the Source.
	-- @return (number) The pitch, where 1.0 is normal.
	getPitch: function(self: Source): number

	-- Sets the currently playing position of the Source.
	-- @param offset (number) The position to seek to.
	-- @param unit (TimeUnit) The unit of the position value. (Default: 'seconds'.)
	seek: function(self: Source, offset: number, unit?: TimeUnit)

	-- Gets the currently playing position of the Source.
	-- @param unit (TimeUnit) The type of unit for the return value. (Default: 'seconds'.)
	-- @return (number) The currently playing position of the Source.
	tell: function(self: Source, unit?: TimeUnit): number

	-- Gets the duration of the Source. For streaming Sources it may not always be sample-accurate, and may return -1 if
	-- the duration cannot be determined at all.
	-- @param unit (TimeUnit) The time unit for the return value. (Default: 'seconds'.)
	-- @return (number) The duration of the Source, or -1 if it cannot be determined.
	getDuration: function(self: Source, unit?: TimeUnit): number

	-- Gets the number of channels in the Source. Only 1-channel (mono) Sources can use directional and positional
	-- effects.
	-- @return (integer) 1 for mono, 2 for stereo.
	getChannelCount: function(self: Source): integer
	getChannels: function(self: Source): integer

	-- Gets the number of free buffer slots in a queueable Source. If the queueable Source is playing, this value will
	-- increase up to the amount the Source was created with. If the queueable Source is stopped, it will process all of
	-- its internal buffers first, in which case this function will always return the amount it was created with.
	-- @return (integer) How many more SoundData objects can be queued up.
	getFreeBufferCount: function(self: Source): integer

	-- Queues SoundData for playback in a queueable Source.
	--
	-- This method requires the Source to be created via love.audio.newQueueableSource.
	-- @param data (SoundData) The data to queue. The SoundData's sample rate, bit depth, and channel count must match the Source's.
	-- @param length (number) The number of bytes to queue. (Default: all remaining data.)
	-- @return (boolean) success — True if the data was successfully queued for playback, false if there were no available buffers to use for queueing.
	queue: function(self: Source, data: SoundData, length?: number): boolean

	-- Queues SoundData for playback in a queueable Source.
	--
	-- This method requires the Source to be created via love.audio.newQueueableSource.
	-- @param data (SoundData) The data to queue. The SoundData's sample rate, bit depth, and channel count must match the Source's.
	-- @param offset (number) The byte offset at which to start queueing data.
	-- @param length (number) The number of bytes to queue.
	-- @return (boolean) success — True if the data was successfully queued for playback, false if there were no available buffers to use for queueing.
	queue: function(self: Source, data: SoundData, offset: number, length: number): boolean

	-- Sets the position of the Source. Please note that this only works for mono (i.e. non-stereo) sound files!
	-- @param x (number) The X position of the Source.
	-- @param y (number) The Y position of the Source.
	-- @param z (number) The Z position of the Source.
	setPosition: function(self: Source, x: number, y: number, z?: number)

	-- Gets the position of the Source.
	-- @return (number) The X position of the Source.
	-- @return (number) The Y position of the Source.
	-- @return (number) The Z position of the Source.
	getPosition: function(self: Source): number, number, number

	-- Sets the velocity of the Source.
	-- This does '''not''' change the position of the Source, but lets the application know how it has to calculate the
	-- doppler effect.
	-- @param x (number) The X part of the velocity vector.
	-- @param y (number) The Y part of the velocity vector.
	-- @param z (number) The Z part of the velocity vector.
	setVelocity: function(self: Source, x: number, y: number, z?: number)

	-- Gets the velocity of the Source.
	-- @return (number) The X part of the velocity vector.
	-- @return (number) The Y part of the velocity vector.
	-- @return (number) The Z part of the velocity vector.
	getVelocity: function(self: Source): number, number, number

	-- Sets the direction vector of the Source. A zero vector makes the source non-directional.
	-- @param x (number) The X part of the direction vector.
	-- @param y (number) The Y part of the direction vector.
	-- @param z (number) The Z part of the direction vector.
	setDirection: function(self: Source, x: number, y: number, z?: number)

	-- Gets the direction of the Source.
	-- @return (number) The X part of the direction vector.
	-- @return (number) The Y part of the direction vector.
	-- @return (number) The Z part of the direction vector.
	getDirection: function(self: Source): number, number, number

	-- Sets the Source's directional volume cones. Together with Source:setDirection, the cone angles allow for the
	-- Source's volume to vary depending on its direction.
	-- @param inner_angle (number) The inner angle from the Source's direction, in radians. The Source will play at normal volume if the listener is inside the cone defined by this angle.
	-- @param outer_angle (number) The outer angle from the Source's direction, in radians. The Source will play at a volume between the normal and outer volumes, if the listener is in between the cones defined by the inner and outer angles.
	-- @param outer_volume (number) The Source's volume when the listener is outside both the inner and outer cone angles. (Default: 0.)
	-- @param outer_high_gain (number) The outer_high_gain parameter.
	setCone: function(self: Source, inner_angle: number, outer_angle: number, outer_volume?: number, outer_high_gain?: number)

	-- Gets the Source's directional volume cones. Together with Source:setDirection, the cone angles allow for the
	-- Source's volume to vary depending on its direction.
	-- @return (number) The inner angle from the Source's direction, in radians. The Source will play at normal volume if the listener is inside the cone defined by this angle.
	-- @return (number) The outer angle from the Source's direction, in radians. The Source will play at a volume between the normal and outer volumes, if the listener is in between the cones defined by the inner and outer angles.
	-- @return (number) The Source's volume when the listener is outside both the inner and outer cone angles.
	getCone: function(self: Source): number, number, number, number

	-- Sets the amount of air absorption applied to the Source.
	-- By default the value is set to 0 which means that air absorption effects are disabled. A value of 1 will apply
	-- high frequency attenuation to the Source at a rate of 0.05 dB per meter.
	-- Air absorption can simulate sound transmission through foggy air, dry air, smoky atmosphere, etc. It can be used
	-- to simulate different atmospheric conditions within different locations in an area.
	-- Overload details:
	--   1. Audio air absorption functionality is not supported on iOS.
	-- @param factor (number) The amount of air absorption applied to the Source. Must be between 0 and 10.
	setAirAbsorption: function(self: Source, factor: number)

	-- Gets the amount of air absorption applied to the Source.
	-- By default the value is set to 0 which means that air absorption effects are disabled. A value of 1 will apply
	-- high frequency attenuation to the Source at a rate of 0.05 dB per meter.
	-- Overload details:
	--   1. Audio air absorption functionality is not supported on iOS.
	-- @return (number) The amount of air absorption applied to the Source.
	getAirAbsorption: function(self: Source): number

	-- Sets the volume limits of the source. The limits have to be numbers from 0 to 1.
	-- @param min_volume (number) The minimum volume.
	-- @param max_volume (number) The maximum volume.
	setVolumeLimits: function(self: Source, min_volume: number, max_volume: number)

	-- Returns the volume limits of the source.
	-- @return (number) The minimum volume.
	-- @return (number) The maximum volume.
	getVolumeLimits: function(self: Source): number, number

	-- Sets whether the Source's position, velocity, direction, and cone angles are relative to the listener, or
	-- absolute.
	-- By default, all sources are absolute and therefore relative to the origin of love's coordinate system 0, 0. Only
	-- absolute sources are affected by the position of the listener. Please note that positional audio only works for
	-- mono (i.e. non-stereo) sources.
	-- @param relative (boolean) True to make the position, velocity, direction and cone angles relative to the listener, false to make them absolute. (Default: false.)
	setRelative: function(self: Source, relative: boolean)

	-- Gets whether the Source's position, velocity, direction, and cone angles are relative to the listener.
	-- @return (boolean) True if the position, velocity, direction and cone angles are relative to the listener, false if they're absolute.
	isRelative: function(self: Source): boolean

	-- Sets the reference and maximum attenuation distances of the Source. The parameters, combined with the current
	-- DistanceModel, affect how the Source's volume attenuates based on distance.
	-- Distance attenuation is only applicable to Sources based on mono (rather than stereo) audio.
	-- @param reference_distance (number) The new reference attenuation distance. If the current DistanceModel is clamped, this is the minimum attenuation distance.
	-- @param max_distance (number) The new maximum attenuation distance.
	setAttenuationDistances: function(self: Source, reference_distance: number, max_distance: number)

	-- Gets the reference and maximum attenuation distances of the Source. The values, combined with the current
	-- DistanceModel, affect how the Source's volume attenuates based on distance from the listener.
	-- @return (number) The current reference attenuation distance. If the current DistanceModel is clamped, this is the minimum distance before the Source is no longer attenuated.
	-- @return (number) The current maximum attenuation distance.
	getAttenuationDistances: function(self: Source): number, number

	-- Sets the rolloff factor which affects the strength of the used distance attenuation.
	-- Extended information and detailed formulas can be found in the chapter '3.4. Attenuation By Distance' of OpenAL
	-- 1.1 specification.
	-- @param rolloff (number) The new rolloff factor.
	setRolloff: function(self: Source, rolloff: number)

	-- Returns the rolloff factor of the source.
	-- @return (number) The rolloff factor.
	getRolloff: function(self: Source): number

	-- Sets a low-pass, high-pass, or band-pass filter to apply when playing the Source.
	-- @return (boolean) success — Whether the filter was successfully applied to the Source.
	setFilter: function(self: Source): boolean

	-- Sets a low-pass, high-pass, or band-pass filter to apply when playing the Source.
	-- @param filter (AudioFilterSettings) The filter settings to use for this Source, with the following fields:
	-- @return (boolean) success — Whether the filter was successfully applied to the Source.
	setFilter: function(self: Source, filter: AudioFilterSettings): boolean

	-- Gets the filter settings currently applied to the Source.
	-- @param target (AudioFilterSettings) The target parameter.
	-- @return (AudioFilterSettings or nil) The filter settings to use for this Source, or nil if the Source has no active filter. The table has the following fields:
	getFilter: function(self: Source, target?: AudioFilterSettings): AudioFilterSettings | nil

	-- Applies an audio effect to the Source.
	--
	-- The effect must have been previously defined using love.audio.setEffect.
	-- @param name (string) The name of the effect previously set up with love.audio.setEffect.
	-- @return (boolean) success — Whether the effect was successfully applied to this Source.
	setEffect: function(self: Source, name: string): boolean

	-- Applies an audio effect to the Source.
	--
	-- The effect must have been previously defined using love.audio.setEffect.
	-- @param name (string) The name of the effect previously set up with love.audio.setEffect.
	-- @param enabled (boolean) Whether the effect should be enabled. Pass false to disable an active effect. (Default: true.)
	-- @return (boolean) success — Whether the effect was successfully applied to this Source.
	setEffect: function(self: Source, name: string, enabled: boolean): boolean

	-- Applies an audio effect to the Source.
	--
	-- The effect must have been previously defined using love.audio.setEffect.
	-- @param name (string) The name of the effect previously set up with love.audio.setEffect.
	-- @param enabled (AudioFilterSettings) The filter settings to apply prior to the effect, with the following fields:
	-- @return (boolean) Whether the effect and filter were successfully applied to this Source.
	setEffect: function(self: Source, name: string, enabled: AudioFilterSettings): boolean

	-- Gets the filter settings associated to a specific effect.
	-- This function returns nil if the effect was applied with no filter settings associated to it.
	-- @param name (string) The name of the effect.
	-- @param target (AudioFilterSettings) An optional empty table that will be filled with the filter settings. (Default: {}.)
	-- @return (boolean) The settings for the filter associated to this effect, or nil if the effect is not present in this Source or has no filter associated. The table has the following fields:
	getEffect: function(self: Source, name: string, target?: AudioFilterSettings): boolean, AudioFilterSettings | nil

	-- Gets a list of the Source's active effect names.
	-- @return ({string}) A list of the source's active effect names.
	getActiveEffects: function(self: Source): {string}

	-- Gets the type of the Source.
	-- @return (SourceType) The type of the source.
	getType: function(self: Source): SourceType
end

-- Represents an audio input device capable of recording sounds.
local record RecordingDevice

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: RecordingDevice): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: RecordingDevice, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: RecordingDevice): boolean

	-- Begins recording audio using this device.
	-- Overload details:
	--   1. A ring buffer is used internally to store recorded data before RecordingDevice:getData or
	--      RecordingDevice:stop are called – the former clears the buffer. If the buffer completely fills up before
	--      getData or stop are called, the oldest data that doesn't fit into the buffer will be lost.
	-- @param samples (integer) The maximum number of samples to store in an internal ring buffer when recording.
	-- @param sample_rate (integer) The number of samples per second to store when recording. (Default: 8000.)
	-- @param bit_depth (integer) The number of bits per sample. (Default: 16.)
	-- @param channels (integer) Whether to record in mono or stereo. Most microphones don't support more than 1 channel. (Default: 1.)
	-- @return (boolean) True if the device successfully began recording using the specified parameters, false if not.
	start: function(self: RecordingDevice, samples?: integer, sample_rate?: integer, bit_depth?: integer, channels?: integer): boolean

	-- Stops recording audio from this device. Any sound data currently in the device's buffer will be returned.
	-- @return (SoundData or nil) The sound data currently in the device's buffer, or nil if the device wasn't recording.
	stop: function(self: RecordingDevice): SoundData | nil

	-- Gets all recorded audio SoundData stored in the device's internal ring buffer.
	-- The internal ring buffer is cleared when this function is called, so calling it again will only get audio recorded
	-- after the previous call. If the device's internal ring buffer completely fills up before getData is called, the
	-- oldest data that doesn't fit into the buffer will be lost.
	-- @return (SoundData or nil) The recorded audio data, or nil if the device isn't recording.
	getData: function(self: RecordingDevice): SoundData | nil

	-- Gets the number of currently recorded samples.
	-- @return (integer) The number of samples that have been recorded so far.
	getSampleCount: function(self: RecordingDevice): integer

	-- Gets the number of samples per second currently being recorded.
	-- @return (integer) The number of samples being recorded per second (sample rate).
	getSampleRate: function(self: RecordingDevice): integer

	-- Gets the number of bits per sample in the data currently being recorded.
	-- @return (integer) The number of bits per sample in the data that's currently being recorded.
	getBitDepth: function(self: RecordingDevice): integer

	-- Gets the number of channels currently being recorded (mono or stereo).
	-- @return (integer) The number of channels being recorded (1 for mono, 2 for stereo).
	getChannelCount: function(self: RecordingDevice): integer

	-- Gets the name of the recording device.
	-- @return (string) The name of the device.
	getName: function(self: RecordingDevice): string

	-- Gets whether the device is currently recording.
	-- @return (boolean) True if the recording, false otherwise.
	isRecording: function(self: RecordingDevice): boolean
end

-- Provides an interface to create noise with the user's speakers.
local record Audio

	-- Creates a new Source from a filepath, File, Decoder or SoundData.
	--
	-- Sources created from SoundData are always static.
	-- @param filename (string) The filepath to the audio file.
	-- @param source_type (string) Streaming or static source.
	-- @return (Source) source — A new Source that can play the specified audio.
	newSource: function(filename: string, source_type?: string): Source

	-- Creates a new Source from a filepath, File, Decoder or SoundData.
	--
	-- Sources created from SoundData are always static.
	-- @param data (SoundData) The SoundData to create a Source from.
	-- @return (Source) A new Source that can play the specified audio. The SourceType of the returned audio is 'static'.
	newSource: function(data: SoundData): Source

	-- Creates a new Source usable for real-time generated sound playback with Source:queue.
	-- Overload details:
	--   1. The sample rate, bit depth, and channel count of any SoundData used with Source:queue must match the
	--      parameters given to this constructor.
	-- @param sample_rate (integer) Number of samples per second when playing.
	-- @param bit_depth (integer) Bits per sample (8 or 16).
	-- @param channels (integer) 1 for mono or 2 for stereo.
	-- @param buffers (integer) The number of buffers that can be queued up at any given time with Source:queue. Cannot be greater than 64. A sensible default (~8) is chosen if no value is specified. (Default: 0.)
	-- @return (Source) The new Source usable with Source:queue.
	newQueueableSource: function(sample_rate: integer, bit_depth: integer, channels: integer, buffers?: integer): Source

	-- Starts playing all Sources contained in a table simultaneously.
	-- @param sources ({Source}) A table containing the Sources to play.
	-- @return (boolean) Whether all specified Sources were successfully started.
	play: function(sources: {Source}): boolean

	-- Starts playing all supplied Sources simultaneously.
	-- @param sources (Source...) The Sources to play.
	-- @return (boolean) Whether all specified Sources were successfully started.
	play: function(sources: Source...): boolean

	-- Pauses all currently active Sources and returns them.
	-- @return ({Source}) Sources — A table containing a list of Sources that were paused by this call.
	pause: function(): {Source}

	-- Pauses all Sources contained in a table.
	-- @param sources ({Source}) A table containing the Sources to pause.
	pause: function(sources: {Source})

	-- Pauses all supplied Sources.
	-- @param sources (Source...) The Sources to pause.
	pause: function(sources: Source...)

	-- Stops all currently active Sources.
	stop: function()

	-- Stops all Sources contained in a table.
	-- @param sources ({Source}) A table containing the Sources to stop.
	stop: function(sources: {Source})

	-- Stops all supplied Sources simultaneously.
	-- @param sources (Source...) The Sources to stop.
	stop: function(sources: Source...)

	-- Gets the current number of simultaneously playing sources.
	-- @return (integer) The current number of simultaneously playing sources.
	getActiveSourceCount: function(): integer
	getSourceCount: function(): integer

	-- Sets the master volume.
	-- @param volume (number) 1.0 is max and 0.0 is off.
	setVolume: function(volume: number)

	-- Returns the master volume.
	-- @return (number) The current master volume
	getVolume: function(): number

	-- Sets whether the system should mix the audio with the system's audio.
	-- @param mix (boolean) True to enable mixing, false to disable it.
	-- @return (boolean) True if the change succeeded, false otherwise.
	setMixWithSystem: function(mix: boolean): boolean

	-- Sets the position of the listener, which determines how sounds play.
	-- @param x (number) The x position of the listener.
	-- @param y (number) The y position of the listener.
	-- @param z (number) The z position of the listener.
	setPosition: function(x: number, y: number, z?: number)

	-- Returns the position of the listener. Please note that positional audio only works for mono (i.e. non-stereo)
	-- sources.
	-- @return (number) The X position of the listener.
	-- @return (number) The Y position of the listener.
	-- @return (number) The Z position of the listener.
	getPosition: function(): number, number, number

	-- Sets the orientation of the listener.
	-- @param forward_x (number) The forward_x parameter.
	-- @param forward_y (number) The forward_y parameter.
	-- @param forward_z (number) The forward_z parameter.
	-- @param up_x (number) The up_x parameter.
	-- @param up_y (number) The up_y parameter.
	-- @param up_z (number) The up_z parameter.
	setOrientation: function(forward_x: number, forward_y: number, forward_z: number,
		up_x: number, up_y: number, up_z: number)

	-- Returns the orientation of the listener.
	-- @return (number) Forward x of the listener orientation.
	-- @return (number) Forward y of the listener orientation.
	-- @return (number) Forward z of the listener orientation.
	-- @return (number) Up x of the listener orientation.
	-- @return (number) Up y of the listener orientation.
	-- @return (number) Up z of the listener orientation.
	getOrientation: function(): number, number, number, number, number, number

	-- Sets the velocity of the listener.
	-- @param x (number) The X velocity of the listener.
	-- @param y (number) The Y velocity of the listener.
	-- @param z (number) The Z velocity of the listener.
	setVelocity: function(x: number, y: number, z?: number)

	-- Returns the velocity of the listener.
	-- @return (number) The X velocity of the listener.
	-- @return (number) The Y velocity of the listener.
	-- @return (number) The Z velocity of the listener.
	getVelocity: function(): number, number, number

	-- Sets a global scale factor for velocity-based doppler effects. The default scale value is 1.
	-- @param scale (number) The new doppler scale factor. The scale must be greater than 0.
	setDopplerScale: function(scale: number)

	-- Gets the current global scale factor for velocity-based doppler effects.
	-- @return (number) The current doppler scale factor.
	getDopplerScale: function(): number

	-- Sets the distance attenuation model.
	-- @param model (DistanceModel) The new distance model.
	setDistanceModel: function(model: DistanceModel)

	-- Returns the distance attenuation model.
	-- @return (DistanceModel) The current distance model. The default is 'inverseclamped'.
	getDistanceModel: function(): DistanceModel

	-- Defines an effect that can be applied to a Source.
	-- Not all system supports audio effects. Use love.audio.isEffectsSupported to check.
	-- @param name (string) The name of the effect.
	-- @param settings (AudioEffectSettings or boolean) The settings to use for this effect, with the following fields: type: The type of effect to use. volume: The volume of the effect. ...: Effect-specific settings. See EffectType for available effects and their corresponding settings.
	-- @return (boolean) Whether the effect was successfully created. Depending on the overload: Whether the effect was successfully disabled.
	setEffect: function(name: string, settings?: AudioEffectSettings | boolean): boolean

	-- Gets the settings associated with an effect.
	-- @param name (string) The name of the effect.
	-- @param target (AudioEffectSettings) The target parameter.
	-- @return (AudioEffectSettings or nil) The settings associated with the effect.
	getEffect: function(name: string, target?: AudioEffectSettings): AudioEffectSettings | nil

	-- Gets a list of the names of the currently enabled effects.
	-- @return ({string}) The list of the names of the currently enabled effects.
	getActiveEffects: function(): {string}

	-- Gets the maximum number of active effects supported by the system.
	-- @return (integer) The maximum number of active effects.
	getMaxSceneEffects: function(): integer

	-- Gets the maximum number of active Effects in a single Source object, that the system can support.
	-- Overload details:
	--   1. This function return 0 for system that doesn't support audio effects.
	-- @return (integer) The maximum number of active Effects per Source.
	getMaxSourceEffects: function(): integer

	-- Gets a list of RecordingDevices on the system.
	-- The first device in the list is the user's default recording device. The list may be empty if there are no
	-- microphones connected to the system.
	-- Audio recording is currently not supported on iOS.
	-- Overload details:
	--   1. Audio recording for Android is supported since 11.3. However, it's not supported when APK from Play Store is
	--      used.
	-- @return ({RecordingDevice}) The list of connected recording devices.
	getRecordingDevices: function(): {RecordingDevice}

	-- Gets whether audio effects are supported in the system.
	-- Overload details:
	--   1. Older Linux distributions that ship with older OpenAL library may not support audio effects. Furthermore, iOS
	--      doesn't support audio effects at all.
	-- @return (boolean) True if effects are supported, false otherwise.
	isEffectsSupported: function(): boolean
end

-- Bodies are objects with velocity and position.
local record Body

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Body): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Body, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Body): boolean

	-- Explicitly destroys the Body and all fixtures and joints attached to it.
	-- An error will occur if you attempt to use the object after calling this function. In 0.7.2, when you don't have
	-- time to wait for garbage collection, this function may be used to free the object immediately.
	destroy: function(self: Body)

	-- Gets whether the Body is destroyed. Destroyed bodies cannot be used.
	-- @return (boolean) Whether the Body is destroyed.
	isDestroyed: function(self: Body): boolean

	-- Get the position of the body.
	-- Note that this may not be the center of mass of the body.
	-- @return (number) The x position.
	-- @return (number) The y position.
	getPosition: function(self: Body): number, number

	-- Set the position of the body.
	-- Note that this may not be the center of mass of the body.
	-- This function cannot wake up the body.
	-- @param x (number) The x position.
	-- @param y (number) The y position.
	setPosition: function(self: Body, x: number, y: number)

	-- Get the x position of the body in world coordinates.
	-- @return (number) The x position in world coordinates.
	getX: function(self: Body): number

	-- Set the x position of the body.
	-- This function cannot wake up the body.
	-- @param x (number) The x position.
	setX: function(self: Body, x: number)

	-- Get the y position of the body in world coordinates.
	-- @return (number) The y position in world coordinates.
	getY: function(self: Body): number

	-- Set the y position of the body.
	-- This function cannot wake up the body.
	-- @param y (number) The y position.
	setY: function(self: Body, y: number)

	-- Get the position and angle of the body.
	-- Note that the position may not be the center of mass of the body. An angle of 0 radians will mean 'looking to the
	-- right'. Although radians increase counter-clockwise, the y axis points down so it becomes clockwise from our point
	-- of view.
	-- @return (number) The x component of the position.
	-- @return (number) The y component of the position.
	-- @return (number) The angle in radians.
	getTransform: function(self: Body): number, number, number

	-- Set the position and angle of the body.
	-- Note that the position may not be the center of mass of the body. An angle of 0 radians will mean 'looking to the
	-- right'. Although radians increase counter-clockwise, the y axis points down so it becomes clockwise from our point
	-- of view.
	-- This function cannot wake up the body.
	-- @param x (number) The x component of the position.
	-- @param y (number) The y component of the position.
	-- @param angle (number) The angle in radians.
	setTransform: function(self: Body, x: number, y: number, angle: number)

	-- Get the angle of the body.
	-- The angle is measured in radians. If you need to transform it to degrees, use math.deg.
	-- A value of 0 radians will mean 'looking to the right'. Although radians increase counter-clockwise, the y axis
	-- points down so it becomes ''clockwise'' from our point of view.
	-- @return (number) The angle in radians.
	getAngle: function(self: Body): number

	-- Set the angle of the body.
	-- The angle is measured in radians. If you need to transform it from degrees, use math.rad.
	-- A value of 0 radians will mean 'looking to the right'. Although radians increase counter-clockwise, the y axis
	-- points down so it becomes ''clockwise'' from our point of view.
	-- It is possible to cause a collision with another body by changing its angle.
	-- @param angle (number) The angle in radians.
	setAngle: function(self: Body, angle: number)

	-- Gets the linear velocity of the Body from its center of mass.
	-- The linear velocity is the ''rate of change of position over time''.
	-- If you need the ''rate of change of angle over time'', use Body:getAngularVelocity.
	-- If you need to get the linear velocity of a point different from the center of mass:
	-- * Body:getLinearVelocityFromLocalPoint allows you to specify the point in local coordinates.
	-- * Body:getLinearVelocityFromWorldPoint allows you to specify the point in world coordinates.
	-- See page 136 of 'Essential Mathematics for Games and Interactive Applications' for definitions of local and world
	-- coordinates.
	-- @return (number) The x-component of the velocity vector
	-- @return (number) The y-component of the velocity vector
	getLinearVelocity: function(self: Body): number, number

	-- Sets a new linear velocity for the Body.
	-- This function will not accumulate anything; any impulses previously applied since the last call to World:update
	-- will be lost.
	-- @param x (number) The x-component of the velocity vector.
	-- @param y (number) The y-component of the velocity vector.
	setLinearVelocity: function(self: Body, x: number, y: number)

	-- Get the angular velocity of the Body.
	-- The angular velocity is the ''rate of change of angle over time''.
	-- It is changed in World:update by applying torques, off centre forces/impulses, and angular damping. It can be set
	-- directly with Body:setAngularVelocity.
	-- If you need the ''rate of change of position over time'', use Body:getLinearVelocity.
	-- @return (number) The angular velocity in radians/second.
	getAngularVelocity: function(self: Body): number

	-- Sets the angular velocity of a Body.
	-- The angular velocity is the ''rate of change of angle over time''.
	-- This function will not accumulate anything; any impulses previously applied since the last call to World:update
	-- will be lost.
	-- @param velocity (number) The new angular velocity, in radians per second
	setAngularVelocity: function(self: Body, velocity: number)

	-- Gets the linear damping of the Body.
	-- The linear damping is the ''rate of decrease of the linear velocity over time''. A moving body with no damping and
	-- no external forces will continue moving indefinitely, as is the case in space. A moving body with damping will
	-- gradually stop moving.
	-- Damping is not the same as friction - they can be modelled together.
	-- @return (number) The value of the linear damping.
	getLinearDamping: function(self: Body): number

	-- Sets the linear damping of a Body
	-- See Body:getLinearDamping for a definition of linear damping.
	-- Linear damping can take any value from 0 to infinity. It is recommended to stay between 0 and 0.1, though. Other
	-- values will make the objects look 'floaty'(if gravity is enabled).
	-- @param damping (number) The new linear damping
	setLinearDamping: function(self: Body, damping: number)

	-- Gets the Angular damping of the Body
	-- The angular damping is the ''rate of decrease of the angular velocity over time'': A spinning body with no damping
	-- and no external forces will continue spinning indefinitely. A spinning body with damping will gradually stop
	-- spinning.
	-- Damping is not the same as friction - they can be modelled together. However, only damping is provided by Box2D
	-- (and LOVE).
	-- Damping parameters should be between 0 and infinity, with 0 meaning no damping, and infinity meaning full damping.
	-- Normally you will use a damping value between 0 and 0.1.
	-- @return (number) The value of the angular damping.
	getAngularDamping: function(self: Body): number

	-- Sets the angular damping of a Body
	-- See Body:getAngularDamping for a definition of angular damping.
	-- Angular damping can take any value from 0 to infinity. It is recommended to stay between 0 and 0.1, though. Other
	-- values will look unrealistic.
	-- @param damping (number) The new angular damping.
	setAngularDamping: function(self: Body, damping: number)

	-- Get the mass of the body.
	-- Static bodies always have a mass of 0.
	-- @return (number) The mass of the body (in kilograms).
	getMass: function(self: Body): number

	-- Sets a new body mass.
	-- @param mass (number) The mass, in kilograms.
	setMass: function(self: Body, mass: number)

	-- Gets the rotational inertia of the body.
	-- The rotational inertia is how hard is it to make the body spin.
	-- @return (number) The rotational inertial of the body.
	getInertia: function(self: Body): number

	-- Set the inertia of a body.
	-- @param inertia (number) The new moment of inertia, in kilograms * pixel squared.
	setInertia: function(self: Body, inertia: number)

	-- Returns the mass, its center, and the rotational inertia.
	-- @return (number) The x position of the center of mass.
	-- @return (number) The y position of the center of mass.
	-- @return (number) The mass of the body.
	-- @return (number) The rotational inertia.
	getMassData: function(self: Body): number, number, number, number

	-- Overrides the calculated mass data.
	-- @param center_x (number) The x position of the center of mass.
	-- @param center_y (number) The y position of the center of mass.
	-- @param mass (number) The mass of the body.
	-- @param inertia (number) The rotational inertia.
	setMassData: function(self: Body, center_x: number, center_y: number, mass: number, inertia: number)

	-- Resets the mass of the body by recalculating it from the mass properties of the fixtures.
	resetMassData: function(self: Body)

	-- Returns the gravity scale factor.
	-- @return (number) The gravity scale factor.
	getGravityScale: function(self: Body): number

	-- Sets a new gravity scale factor for the body.
	-- @param scale (number) The new gravity scale factor.
	setGravityScale: function(self: Body, scale: number)

	-- Get the center of mass position in local coordinates.
	-- Use Body:getWorldCenter to get the center of mass in world coordinates.
	-- @return (number) The x coordinate of the center of mass.
	-- @return (number) The y coordinate of the center of mass.
	getLocalCenter: function(self: Body): number, number

	-- Get the center of mass position in world coordinates.
	-- Use Body:getLocalCenter to get the center of mass in local coordinates.
	-- @return (number) The x coordinate of the center of mass.
	-- @return (number) The y coordinate of the center of mass.
	getWorldCenter: function(self: Body): number, number

	-- Returns whether the body rotation is locked.
	-- @return (boolean) True if the body's rotation is locked or false if not.
	isFixedRotation: function(self: Body): boolean

	-- Set whether a body has fixed rotation.
	-- Bodies with fixed rotation don't vary the speed at which they rotate. Calling this function causes the mass to be
	-- reset.
	-- @param fixed (boolean) Whether the body should have fixed rotation.
	setFixedRotation: function(self: Body, fixed: boolean)

	-- Returns the sleep status of the body.
	-- @return (boolean) True if the body is awake or false if not.
	isAwake: function(self: Body): boolean

	-- Wakes the body up or puts it to sleep.
	-- @param awake (boolean) The body sleep status.
	setAwake: function(self: Body, awake: boolean)

	-- Returns the sleeping behaviour of the body.
	-- @return (boolean) True if the body is allowed to sleep or false if not.
	isSleepingAllowed: function(self: Body): boolean

	-- Sets the sleeping behaviour of the body. Should sleeping be allowed, a body at rest will automatically sleep. A
	-- sleeping body is not simulated unless it collided with an awake body. Be wary that one can end up with a situation
	-- like a floating sleeping body if the floor was removed.
	-- @param allowed (boolean) True if the body is allowed to sleep or false if not.
	setSleepingAllowed: function(self: Body, allowed: boolean)

	-- Returns whether the body is actively used in the simulation.
	-- @return (boolean) True if the body is active or false if not.
	isActive: function(self: Body): boolean

	-- Sets whether the body is active in the world.
	-- An inactive body does not take part in the simulation. It will not move or cause any collisions.
	-- @param active (boolean) If the body is active or not.
	setActive: function(self: Body, active: boolean)

	-- Get the bullet status of a body.
	-- There are two methods to check for body collisions:
	-- * at their location when the world is updated (default)
	-- * using continuous collision detection (CCD)
	-- The default method is efficient, but a body moving very quickly may sometimes jump over another body without
	-- producing a collision. A body that is set as a bullet will use CCD. This is less efficient, but is guaranteed not
	-- to jump when moving quickly.
	-- Note that static bodies (with zero mass) always use CCD, so your walls will not let a fast moving body pass
	-- through even if it is not a bullet.
	-- @return (boolean) The bullet status of the body.
	isBullet: function(self: Body): boolean

	-- Set the bullet status of a body.
	-- There are two methods to check for body collisions:
	-- * at their location when the world is updated (default)
	-- * using continuous collision detection (CCD)
	-- The default method is efficient, but a body moving very quickly may sometimes jump over another body without
	-- producing a collision. A body that is set as a bullet will use CCD. This is less efficient, but is guaranteed not
	-- to jump when moving quickly.
	-- Note that static bodies (with zero mass) always use CCD, so your walls will not let a fast moving body pass
	-- through even if it is not a bullet.
	-- @param bullet (boolean) The bullet status of the body.
	setBullet: function(self: Body, bullet: boolean)

	-- Applies an impulse to a body.
	-- This makes a single, instantaneous addition to the body momentum.
	-- An impulse pushes a body in a direction. A body with with a larger mass will react less. The reaction does
	-- '''not''' depend on the timestep, and is equivalent to applying a force continuously for 1 second. Impulses are
	-- best used to give a single push to a body. For a continuous push to a body it is better to use Body:applyForce.
	-- If the position to apply the impulse is not given, it will act on the center of mass of the body. The part of the
	-- impulse not directed towards the center of mass will cause the body to spin (and depends on the rotational
	-- inertia).
	-- Note that the impulse components and position must be given in world coordinates.
	-- @param x_impulse (number) The x component of the impulse.
	-- @param y_impulse (number) The y component of the impulse.
	-- @param point_x (number) The x position to apply the impulse.
	-- @param point_y (number) The y position to apply the impulse.
	applyLinearImpulse: function(self: Body, x_impulse: number, y_impulse: number, point_x?: number, point_y?: number)

	-- Applies an angular impulse to a body. This makes a single, instantaneous addition to the body momentum.
	-- A body with with a larger mass will react less. The reaction does '''not''' depend on the timestep, and is
	-- equivalent to applying a force continuously for 1 second. Impulses are best used to give a single push to a body.
	-- For a continuous push to a body it is better to use Body:applyForce.
	-- @param impulse (number) The impulse in kilogram-square meter per second.
	applyAngularImpulse: function(self: Body, impulse: number)

	-- Apply force to a Body.
	-- A force pushes a body in a direction. A body with with a larger mass will react less. The reaction also depends on
	-- how long a force is applied: since the force acts continuously over the entire timestep, a short timestep will
	-- only push the body for a short time. Thus forces are best used for many timesteps to give a continuous push to a
	-- body (like gravity). For a single push that is independent of timestep, it is better to use
	-- Body:applyLinearImpulse.
	-- If the position to apply the force is not given, it will act on the center of mass of the body. The part of the
	-- force not directed towards the center of mass will cause the body to spin (and depends on the rotational inertia).
	-- Note that the force components and position must be given in world coordinates.
	-- @param x_force (number) The x component of force to apply.
	-- @param y_force (number) The y component of force to apply.
	-- @param point_x (number) The x position to apply the force.
	-- @param point_y (number) The y position to apply the force.
	applyForce: function(self: Body, x_force: number, y_force: number, point_x?: number, point_y?: number)

	-- Apply torque to a body.
	-- Torque is like a force that will change the angular velocity (spin) of a body. The effect will depend on the
	-- rotational inertia a body has.
	-- @param torque (number) The torque to apply.
	applyTorque: function(self: Body, torque: number)

	-- Returns the type of the body.
	-- @return (BodyType) The body type.
	getType: function(self: Body): BodyType

	-- Sets a new body type.
	-- @param body_type (BodyType) The new type.
	setType: function(self: Body, body_type: BodyType)

	-- Transform a point from local coordinates to world coordinates.
	-- @param x (number) The x position in local coordinates.
	-- @param y (number) The y position in local coordinates.
	-- @return (number) The x position in world coordinates.
	-- @return (number) The y position in world coordinates.
	getWorldPoint: function(self: Body, x: number, y: number): number, number

	-- Transform a vector from local coordinates to world coordinates.
	-- @param x (number) The vector x component in local coordinates.
	-- @param y (number) The vector y component in local coordinates.
	-- @return (number) The vector x component in world coordinates.
	-- @return (number) The vector y component in world coordinates.
	getWorldVector: function(self: Body, x: number, y: number): number, number

	-- Transforms multiple points from local coordinates to world coordinates.
	-- @param x (number) The x position of the first point.
	-- @param y (number) The y position of the first point.
	-- @param coordinates (number...) The x position of the second point.
	-- @return (number...) The transformed x position of the first point.
	getWorldPoints: function(self: Body, x: number, y: number, coordinates: number...): number...

	-- Transform a point from world coordinates to local coordinates.
	-- @param x (number) The x position in world coordinates.
	-- @param y (number) The y position in world coordinates.
	-- @return (number) The x position in local coordinates.
	-- @return (number) The y position in local coordinates.
	getLocalPoint: function(self: Body, x: number, y: number): number, number

	-- Transform a vector from world coordinates to local coordinates.
	-- @param x (number) The vector x component in world coordinates.
	-- @param y (number) The vector y component in world coordinates.
	-- @return (number) The vector x component in local coordinates.
	-- @return (number) The vector y component in local coordinates.
	getLocalVector: function(self: Body, x: number, y: number): number, number

	-- Transforms multiple points from world coordinates to local coordinates.
	-- @param x (number) (Argument) The x position of the first point.
	-- @param y (number) (Argument) The y position of the first point.
	-- @param coordinates (number...) (Argument) The x position of the second point.
	-- @return (number...) (Result) The transformed x position of the first point.
	getLocalPoints: function(self: Body, x: number, y: number, coordinates: number...): number...

	-- Get the linear velocity of a point on the body.
	-- The linear velocity for a point on the body is the velocity of the body center of mass plus the velocity at that
	-- point from the body spinning.
	-- The point on the body must given in world coordinates. Use Body:getLinearVelocityFromLocalPoint to specify this
	-- with local coordinates.
	-- @param x (number) The x position to measure velocity.
	-- @param y (number) The y position to measure velocity.
	-- @return (number) The x component of velocity at point (x,y).
	-- @return (number) The y component of velocity at point (x,y).
	getLinearVelocityFromWorldPoint: function(self: Body, x: number, y: number): number, number

	-- Get the linear velocity of a point on the body.
	-- The linear velocity for a point on the body is the velocity of the body center of mass plus the velocity at that
	-- point from the body spinning.
	-- The point on the body must given in local coordinates. Use Body:getLinearVelocityFromWorldPoint to specify this
	-- with world coordinates.
	-- @param x (number) The x position to measure velocity.
	-- @param y (number) The y position to measure velocity.
	-- @return (number) The x component of velocity at point (x,y).
	-- @return (number) The y component of velocity at point (x,y).
	getLinearVelocityFromLocalPoint: function(self: Body, x: number, y: number): number, number

	-- Returns all fixtures attached to the body.
	-- @return (Fixture[]) A table containing all fixtures attached to the body.
	getFixtures: function(self: Body): {Fixture}
end

-- Shapes are solid 2d geometrical objects which handle the mass and collision of a Body in love.physics.
local record Shape

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Shape): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Shape, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Shape): boolean

	-- Gets a string representing the Shape.
	-- This function can be useful for conditional debug drawing.
	-- @return (string) The type of the Shape.
	getType: function(self: Shape): string

	-- Gets the radius of the shape.
	-- @param index (integer) The index parameter.
	-- @param x (number) The x parameter.
	-- @param y (number) The y parameter.
	-- @return (number or number... or boolean or integer or Shape or number or nil) The radius of the shape.
	getRadius: function(self: Shape): number
	getPoints: function(self: Shape): number...
	validate: function(self: Shape): boolean
	getVertexCount: function(self: Shape): integer
	getPoint: function(self: Shape, index: integer): number, number
	getChildEdge: function(self: Shape, index: integer): Shape
	getPreviousVertex: function(self: Shape): number | nil, number | nil
	getNextVertex: function(self: Shape): number | nil, number | nil
	setPreviousVertex: function(self: Shape, x?: number, y?: number)
	setNextVertex: function(self: Shape, x?: number, y?: number)
end

-- Fixtures attach shapes to bodies.
local record Fixture

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Fixture): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Fixture, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Fixture): boolean

	-- Destroys the fixture.
	destroy: function(self: Fixture)

	-- Gets whether the Fixture is destroyed. Destroyed fixtures cannot be used.
	-- @return (boolean or string) Whether the Fixture is destroyed.
	isDestroyed: function(self: Fixture): boolean
	getType: function(self: Fixture): string

	-- Sets the friction of the fixture.
	-- Friction determines how shapes react when they 'slide' along other shapes. Low friction indicates a slippery
	-- surface, like ice, while high friction indicates a rough surface, like concrete. Range: 0.0 - 1.0.
	-- @param friction (number) The fixture friction.
	setFriction: function(self: Fixture, friction: number)

	-- Returns the friction of the fixture.
	-- @return (number) The fixture friction.
	getFriction: function(self: Fixture): number

	-- Sets the restitution of the fixture.
	-- @param restitution (number) The fixture restitution.
	setRestitution: function(self: Fixture, restitution: number)

	-- Returns the restitution of the fixture.
	-- @return (number) The fixture restitution.
	getRestitution: function(self: Fixture): number

	-- Sets the density of the fixture. Call Body:resetMassData if this needs to take effect immediately.
	-- @param density (number) The fixture density in kilograms per square meter.
	setDensity: function(self: Fixture, density: number)

	-- Returns the density of the fixture.
	-- @return (number) The fixture density in kilograms per square meter.
	getDensity: function(self: Fixture): number

	-- Sets whether the fixture should act as a sensor.
	-- Sensors do not cause collision responses, but the begin-contact and end-contact World callbacks will still be
	-- called for this fixture.
	-- @param sensor (boolean) The sensor status.
	setSensor: function(self: Fixture, sensor: boolean)

	-- Returns whether the fixture is a sensor.
	-- @return (boolean) If the fixture is a sensor.
	isSensor: function(self: Fixture): boolean

	-- Returns the body to which the fixture is attached.
	-- @return (Body) The parent body.
	getBody: function(self: Fixture): Body

	-- Returns the shape of the fixture. This shape is a reference to the actual data used in the simulation. It's
	-- possible to change its values between timesteps.
	-- @return (Shape) The fixture's shape.
	getShape: function(self: Fixture): Shape

	-- Checks if a point is inside the shape of the fixture.
	-- @param x (number) The x position of the point.
	-- @param y (number) The y position of the point.
	-- @return (boolean) True if the point is inside or false if it is outside.
	testPoint: function(self: Fixture, x: number, y: number): boolean

	-- Casts a ray against the shape of the fixture and returns the surface normal vector and the line position where the
	-- ray hit. If the ray missed the shape, nil will be returned.
	-- The ray starts on the first point of the input line and goes towards the second point of the line. The fifth
	-- argument is the maximum distance the ray is going to travel as a scale factor of the input line length.
	-- The childIndex parameter is used to specify which child of a parent shape, such as a ChainShape, will be ray
	-- casted. For ChainShapes, the index of 1 is the first edge on the chain. Ray casting a parent shape will only test
	-- the child specified so if you want to test every shape of the parent, you must loop through all of its children.
	-- The world position of the impact can be calculated by multiplying the line vector with the third return value and
	-- adding it to the line starting point.
	-- hitx, hity = x1 + (x2 - x1) * fraction, y1 + (y2 - y1) * fraction
	-- @param x1 (number) The x position of the input line starting point.
	-- @param y1 (number) The y position of the input line starting point.
	-- @param x2 (number) The x position of the input line end point.
	-- @param y2 (number) The y position of the input line end point.
	-- @param max_fraction (number) Ray length parameter.
	-- @param child_index (integer) The index of the child the ray gets cast against. (Default: 1.)
	-- @return (number or nil) The x component of the normal vector of the edge where the ray hit the shape.
	-- @return (number or nil) The y component of the normal vector of the edge where the ray hit the shape.
	-- @return (number or nil) The position on the input line where the intersection happened as a factor of the line length.
	rayCast: function(self: Fixture, x1: number, y1: number, x2: number, y2: number, max_fraction: number, child_index?: integer): number | nil, number | nil, number | nil

	-- Sets the filter data of the fixture.
	-- Groups, categories, and mask can be used to define the collision behaviour of the fixture.
	-- If two fixtures are in the same group they either always collide if the group is positive, or never collide if
	-- it's negative. If the group is zero or they do not match, then the contact filter checks if the fixtures select a
	-- category of the other fixture with their masks. The fixtures do not collide if that's not the case. If they do
	-- have each other's categories selected, the return value of the custom contact filter will be used. They always
	-- collide if none was set.
	-- There can be up to 16 categories. Categories and masks are encoded as the bits of a 16-bit integer.
	-- When created, prior to calling this function, all fixtures have category set to 1, mask set to 65535 (all
	-- categories) and group set to 0.
	-- This function allows setting all filter data for a fixture at once. To set only the categories, the mask or the
	-- group, you can use Fixture:setCategory, Fixture:setMask or Fixture:setGroupIndex respectively.
	-- @param category_bits (integer) The categories as an integer from 0 to 65535.
	-- @param mask_bits (integer) The mask as an integer from 0 to 65535.
	-- @param group_index (integer) The group as an integer from -32768 to 32767.
	setFilterData: function(self: Fixture, category_bits: integer, mask_bits: integer, group_index: integer)

	-- Returns the filter data of the fixture.
	-- Categories and masks are encoded as the bits of a 16-bit integer.
	-- @return (integer) The categories as an integer from 0 to 65535.
	-- @return (integer) The mask as an integer from 0 to 65535.
	-- @return (integer) The group as an integer from -32768 to 32767.
	getFilterData: function(self: Fixture): integer, integer, integer

	-- Sets the categories the fixture belongs to. There can be up to 16 categories represented as a number from 1 to 16.
	--
	-- All fixture's default category is 1.
	-- @param categories ({number}) The categories.
	setCategory: function(self: Fixture, categories: {number})

	-- Sets the categories the fixture belongs to. There can be up to 16 categories represented as a number from 1 to 16.
	--
	-- All fixture's default category is 1.
	-- @param categories (number...) The categories.
	setCategory: function(self: Fixture, categories: number...)

	-- Returns the categories the fixture belongs to.
	-- @return (integer...) The categories.
	getCategory: function(self: Fixture): integer...

	-- Sets the category mask of the fixture. There can be up to 16 categories represented as a number from 1 to 16.
	--
	-- This fixture will '''NOT''' collide with the fixtures that are in the selected categories if the other fixture also has a category of this fixture selected.
	-- @param categories ({number}) The masks.
	setMask: function(self: Fixture, categories: {number})

	-- Sets the category mask of the fixture. There can be up to 16 categories represented as a number from 1 to 16.
	--
	-- This fixture will '''NOT''' collide with the fixtures that are in the selected categories if the other fixture also has a category of this fixture selected.
	-- @param categories (number...) The masks.
	setMask: function(self: Fixture, categories: number...)

	-- Returns which categories this fixture should '''NOT''' collide with.
	-- @return (integer...) The masks.
	getMask: function(self: Fixture): integer...

	-- Associates a Lua value with the fixture.
	-- To delete the reference, explicitly pass nil.
	-- @param value (any) The Lua value to associate with the fixture.
	setUserData: function(self: Fixture, value: any)

	-- Returns the Lua value associated with this fixture.
	-- @return (any) The Lua value associated with the fixture.
	getUserData: function(self: Fixture): any

	-- Returns the points of the fixture bounding box. In case the fixture has multiple children a 1-based index can be
	-- specified. For example, a fixture will have multiple children with a chain shape.
	-- @param child_index (integer) A bounding box of the fixture. (Default: 1.)
	-- @return (number) The x position of the top-left point.
	-- @return (number) The y position of the top-left point.
	-- @return (number) The x position of the bottom-right point.
	-- @return (number) The y position of the bottom-right point.
	getBoundingBox: function(self: Fixture, child_index?: integer): number, number, number, number

	-- Returns the mass, its center and the rotational inertia.
	-- @return (number) The x position of the center of mass.
	-- @return (number) The y position of the center of mass.
	-- @return (number) The mass of the fixture.
	-- @return (number) The rotational inertia.
	getMassData: function(self: Fixture): number, number, number, number

	-- Returns the group the fixture belongs to. Fixtures with the same group will always collide if the group is
	-- positive or never collide if it's negative. The group zero means no group.
	-- The groups range from -32768 to 32767.
	-- @return (integer) The group of the fixture.
	getGroupIndex: function(self: Fixture): integer

	-- Sets the group the fixture belongs to. Fixtures with the same group will always collide if the group is positive
	-- or never collide if it's negative. The group zero means no group.
	-- The groups range from -32768 to 32767.
	-- @param index (integer) The group as an integer from -32768 to 32767.
	setGroupIndex: function(self: Fixture, index: integer)
end

-- Contacts are objects created to manage collisions in worlds.
local record Contact

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Contact): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Contact, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Contact): boolean
	isValid: function(self: Contact): boolean

	-- Gets the two Fixtures that hold the shapes that are in contact.
	-- @return (Fixture) The first Fixture.
	-- @return (Fixture) The second Fixture.
	getFixtures: function(self: Contact): Fixture, Fixture

	-- Gets the child indices of the shapes of the two colliding fixtures. For ChainShapes, an index of 1 is the first
	-- edge in the chain.
	-- Used together with Fixture:rayCast or ChainShape:getChildEdge.
	-- @return (integer) The child index of the first fixture's shape.
	-- @return (integer) The child index of the second fixture's shape.
	getChildren: function(self: Contact): integer, integer

	-- Returns the contact points of the two colliding fixtures. There can be one or two points.
	-- @return (number...) The x coordinate of the first contact point.
	getPositions: function(self: Contact): number...

	-- Get the normal vector between two shapes that are in contact.
	-- This function returns the coordinates of a unit vector that points from the first shape to the second.
	-- @return (number) The x component of the normal vector.
	-- @return (number) The y component of the normal vector.
	getNormal: function(self: Contact): number, number

	-- Get the friction between two shapes that are in contact.
	-- @return (number) The friction of the contact.
	getFriction: function(self: Contact): number

	-- Sets the contact friction.
	-- @param friction (number) The contact friction.
	setFriction: function(self: Contact, friction: number)

	-- Resets the contact friction to the mixture value of both fixtures.
	resetFriction: function(self: Contact)

	-- Get the restitution between two shapes that are in contact.
	-- @return (number) The restitution between the two shapes.
	getRestitution: function(self: Contact): number

	-- Sets the contact restitution.
	-- @param restitution (number) The contact restitution.
	setRestitution: function(self: Contact, restitution: number)

	-- Resets the contact restitution to the mixture value of both fixtures.
	resetRestitution: function(self: Contact)

	-- Returns whether the contact is enabled. The collision will be ignored if a contact gets disabled in the preSolve
	-- callback.
	-- @return (boolean) True if enabled, false otherwise.
	isEnabled: function(self: Contact): boolean

	-- Enables or disables the contact.
	-- @param enabled (boolean) True to enable or false to disable.
	setEnabled: function(self: Contact, enabled: boolean)

	-- Returns whether the two colliding fixtures are touching each other.
	-- @param speed (number) The speed parameter.
	-- @return (boolean or number) True if they touch or false if not.
	isTouching: function(self: Contact): boolean
	getTangentSpeed: function(self: Contact): number
	setTangentSpeed: function(self: Contact, speed: number)
end

-- A world is an object that contains all bodies and joints.
local record World

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: World): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: World, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: World): boolean

	-- Destroys the world, taking all bodies, joints, fixtures and their shapes with it.
	-- An error will occur if you attempt to use any of the destroyed objects after calling this function.
	destroy: function(self: World)

	-- Gets whether the World is destroyed. Destroyed worlds cannot be used.
	-- @return (boolean) Whether the World is destroyed.
	isDestroyed: function(self: World): boolean

	-- Returns all bodies in the world.
	-- @return (Body[]) A table containing all bodies in the world.
	getBodies: function(self: World): {Body}

	-- Update the state of the world.
	-- @param delta_time (number) The time (in seconds) to advance the physics simulation.
	-- @param velocity_iterations (integer) The maximum number of steps used to determine the new velocities when resolving a collision. (Default: 8.)
	-- @param position_iterations (integer) The maximum number of steps used to determine the new positions when resolving a collision. (Default: 3.)
	update: function(self: World, delta_time: number, velocity_iterations?: integer, position_iterations?: integer)

	-- Set the gravity of the world.
	-- @param x (number) The x component of gravity.
	-- @param y (number) The y component of gravity.
	setGravity: function(self: World, x: number, y: number)

	-- Get the gravity of the world.
	-- @return (number) The x component of gravity.
	-- @return (number) The y component of gravity.
	getGravity: function(self: World): number, number

	-- Sets the sleep behaviour of the world.
	-- @param allowed (boolean) True if bodies in the world are allowed to sleep, or false if not.
	setSleepingAllowed: function(self: World, allowed: boolean)

	-- Gets the sleep behaviour of the world.
	-- @return (boolean) True if bodies in the world are allowed to sleep, or false if not.
	isSleepingAllowed: function(self: World): boolean

	-- Calls a function for each fixture inside the specified area by searching for any overlapping bounding box
	-- (Fixture:getBoundingBox).
	-- @param x1 (number) The x position of the top-left point.
	-- @param y1 (number) The y position of the top-left point.
	-- @param x2 (number) The x position of the bottom-right point.
	-- @param y2 (number) The y position of the bottom-right point.
	-- @param callback (function) This function gets passed one argument, the fixture, and should return a boolean. The search will continue if it is true or stop if it is false.
	queryBoundingBox: function(self: World, x1: number, y1: number, x2: number, y2: number, callback: function(any): boolean)

	-- Casts a ray and calls a function for each fixtures it intersects.
	-- Overload details:
	--   1. There is a bug in LÖVE 0.8.0 where the normal vector passed to the callback function gets scaled by
	--      love.physics.getMeter.
	-- @param x1 (number) The x position of the starting point of the ray.
	-- @param y1 (number) The x position of the starting point of the ray.
	-- @param x2 (number) The x position of the end point of the ray.
	-- @param y2 (number) The x value of the surface normal vector of the shape edge.
	-- @param callback (function) A function called for each fixture intersected by the ray. The function gets six arguments and should return a number as a control value. The intersection points fed into the function will be in an arbitrary order. If you wish to find the closest point of intersection, you'll need to do that yourself within the function. The easiest way to do that is by using the fraction value.
	rayCast: function(self: World, x1: number, y1: number, x2: number, y2: number, callback: function(any, number, number, number, number, number): number)

	-- Sets functions for the collision callbacks during the world update.
	-- Four Lua functions can be given as arguments. The value nil removes a function.
	-- When called, each function will be passed three arguments. The first two arguments are the colliding fixtures and
	-- the third argument is the Contact between them. The postSolve callback additionally gets the normal and tangent
	-- impulse for each contact point. See notes.
	-- If you are interested to know when exactly each callback is called, consult a Box2d manual
	-- @param begin_contact (function) Gets called when two fixtures begin to overlap.
	-- @param end_contact (function) Gets called when two fixtures cease to overlap. This will also be called outside of a world update, when colliding objects are destroyed.
	-- @param pre_solve (function) Gets called before a collision gets resolved. (Default: nil.)
	-- @param post_solve (function) Gets called after the collision has been resolved. (Default: nil.)
	setCallbacks: function(self: World, begin_contact?: function(any, any, any), end_contact?: function(any, any, any), pre_solve?: function(any, any, any), post_solve?: function(any, any, any, ...: number))

	-- Returns functions for the callbacks during the world update.
	-- @param ... (number) The ... parameter.
	-- @return (function) Gets called when two fixtures begin to overlap.
	-- @return (function) Gets called when two fixtures cease to overlap.
	-- @return (function) Gets called before a collision gets resolved.
	-- @return (function) Gets called after the collision has been resolved.
	getCallbacks: function(self: World): function(any, any, any) | nil, function(any, any, any) | nil, function(any, any, any) | nil, function(any, any, any, ...: number) | nil
end

-- Attach multiple bodies together to interact in unique ways.
local record Joint

	-- Gets the type of the object as a string.
	-- @return (string) The type as a string.
	type: function(self: Joint): string

	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- @param type_name (string) The name of the type to check for.
	-- @return (boolean) True if the object is of the specified type, false otherwise.
	typeOf: function(self: Joint, type_name: string): boolean

	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
	-- LÖVE object or thread.
	-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
	-- @return (boolean) True if the object was released by this call, false if it had been previously released.
	release: function(self: Joint): boolean

	-- Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this function.
	-- In 0.7.2, when you don't have time to wait for garbage collection, this function
	-- may be used to free the object immediately.
	destroy: function(self: Joint)

	-- Gets whether the Joint is destroyed. Destroyed joints cannot be used.
	-- @return (boolean) Whether the Joint is destroyed.
	isDestroyed: function(self: Joint): boolean

	-- Gets a string representing the type.
	-- @return (string) A string with the name of the Joint type.
	getType: function(self: Joint): string

	-- Gets the bodies that the Joint is attached to.
	-- @return (Body) The first Body.
	-- @return (Body) The second Body.
	getBodies: function(self: Joint): Body, Body

	-- Get the anchor points of the joint.
	-- @return (number) The x-component of the anchor on Body 1.
	-- @return (number) The y-component of the anchor on Body 1.
	-- @return (number) The x-component of the anchor on Body 2.
	-- @return (number) The y-component of the anchor on Body 2.
	getAnchors: function(self: Joint): number, number, number, number

	-- Returns the reaction force in newtons on the second body
	-- @param inverse_delta_time (number) How long the force applies. Usually the inverse time step or 1/dt.
	-- @return (number) The x-component of the force.
	-- @return (number) The y-component of the force.
	getReactionForce: function(self: Joint, inverse_delta_time: number): number, number

	-- Returns the reaction torque on the second body.
	-- @param inverse_delta_time (number) How long the force applies. Usually the inverse time step or 1/dt.
	-- @return (number) The reaction torque on the second body.
	getReactionTorque: function(self: Joint, inverse_delta_time: number): number

	-- Gets whether the connected Bodies collide.
	-- @return (boolean) True if they collide, false otherwise.
	getCollideConnected: function(self: Joint): boolean

	-- Associates a Lua value with the Joint.
	-- To delete the reference, explicitly pass nil.
	-- @param value (any) The Lua value to associate with the Joint.
	setUserData: function(self: Joint, value: any)

	-- Returns the Lua value associated with this Joint.
	-- @param length (number) The length parameter.
	-- @param frequency (number) The frequency parameter.
	-- @param ratio (number) The ratio parameter.
	-- @param enabled (boolean) The enabled parameter.
	-- @param torque (number) The torque parameter.
	-- @param speed (number) The speed parameter.
	-- @param inverse_delta_time (number) The inverse_delta_time parameter.
	-- @param upper (number) The upper parameter.
	-- @param lower (number) The lower parameter.
	-- @param force (number) The force parameter.
	-- @param x (number) The x parameter.
	-- @param y (number) The y parameter.
	-- @param angle (number) The angle parameter.
	-- @param factor (number) The factor parameter.
	-- @return (any or number or boolean or Joint) The Lua value associated with the Joint.
	getUserData: function(self: Joint): any
	setLength: function(self: Joint, length: number)
	getLength: function(self: Joint): number
	setFrequency: function(self: Joint, frequency: number)
	getFrequency: function(self: Joint): number
	setDampingRatio: function(self: Joint, ratio: number)
	getDampingRatio: function(self: Joint): number
	getJointAngle: function(self: Joint): number
	getJointSpeed: function(self: Joint): number
	setMotorEnabled: function(self: Joint, enabled: boolean)
	isMotorEnabled: function(self: Joint): boolean
	setMaxMotorTorque: function(self: Joint, torque: number)
	getMaxMotorTorque: function(self: Joint): number
	setMotorSpeed: function(self: Joint, speed: number)
	getMotorSpeed: function(self: Joint): number
	getMotorTorque: function(self: Joint, inverse_delta_time: number): number
	setLimitsEnabled: function(self: Joint, enabled: boolean)
	areLimitsEnabled: function(self: Joint): boolean
	hasLimitsEnabled: function(self: Joint): boolean
	setUpperLimit: function(self: Joint, upper: number)
	setLowerLimit: function(self: Joint, lower: number)
	setLimits: function(self: Joint, lower: number, upper: number)
	getUpperLimit: function(self: Joint): number
	getLowerLimit: function(self: Joint): number
	getLimits: function(self: Joint): number, number
	getReferenceAngle: function(self: Joint): number
	getJointTranslation: function(self: Joint): number
	setMaxMotorForce: function(self: Joint, force: number)
	getMaxMotorForce: function(self: Joint): number
	getMotorForce: function(self: Joint, inverse_delta_time: number): number
	getAxis: function(self: Joint): number, number
	setMaxForce: function(self: Joint, force: number)
	getMaxForce: function(self: Joint): number
	setMaxTorque: function(self: Joint, torque: number)
	getMaxTorque: function(self: Joint): number
	setMaxLength: function(self: Joint, length: number)
	getMaxLength: function(self: Joint): number
	getGroundAnchors: function(self: Joint): number, number, number, number
	getLengthA: function(self: Joint): number
	getLengthB: function(self: Joint): number
	getRatio: function(self: Joint): number
	setSpringFrequency: function(self: Joint, frequency: number)
	getSpringFrequency: function(self: Joint): number
	setSpringDampingRatio: function(self: Joint, ratio: number)
	getSpringDampingRatio: function(self: Joint): number
	setTarget: function(self: Joint, x: number, y: number)
	getTarget: function(self: Joint): number, number
	setLinearOffset: function(self: Joint, x: number, y: number)
	getLinearOffset: function(self: Joint): number, number
	setAngularOffset: function(self: Joint, angle: number)
	getAngularOffset: function(self: Joint): number
	setCorrectionFactor: function(self: Joint, factor: number)
	getCorrectionFactor: function(self: Joint): number
	setRatio: function(self: Joint, ratio: number)
	getJoints: function(self: Joint): Joint, Joint
end

-- Can simulate 2D rigid body physics in a realistic manner. This module is based on Box2D, and this API
-- corresponds to the Box2D API as closely as possible.
local record Physics

	-- Sets the pixels to meter scale factor.
	-- All coordinates in the physics module are divided by this number and converted to meters, and it creates a
	-- convenient way to draw the objects directly to the screen without the need for graphics transformations.
	-- It is recommended to create shapes no larger than 10 times the scale. This is important because Box2D is tuned to
	-- work well with shape sizes from 0.1 to 10 meters. The default meter scale is 30.
	-- @param scale (number) The scale factor as an integer.
	setMeter: function(scale: number)

	-- Returns the meter scale factor.
	-- All coordinates in the physics module are divided by this number, creating a convenient way to draw the objects
	-- directly to the screen without the need for graphics transformations.
	-- It is recommended to create shapes no larger than 10 times the scale. This is important because Box2D is tuned to
	-- work well with shape sizes from 0.1 to 10 meters.
	-- @return (number) The scale factor as an integer.
	getMeter: function(): number

	-- Creates a new World.
	-- @param x_gravity (number) The x component of gravity. (Default: 0.)
	-- @param y_gravity (number) The y component of gravity. (Default: 0.)
	-- @param sleep (boolean) Whether the bodies in this world are allowed to sleep. (Default: true.)
	-- @return (World) A brave new World.
	newWorld: function(x_gravity?: number, y_gravity?: number, sleep?: boolean): World

	-- Creates a new body.
	-- There are three types of bodies.
	-- * Static bodies do not move, have a infinite mass, and can be used for level boundaries.
	-- * Dynamic bodies are the main actors in the simulation, they collide with everything.
	-- * Kinematic bodies do not react to forces and only collide with dynamic bodies.
	-- The mass of the body gets calculated when a Fixture is attached or removed, but can be changed at any time with
	-- Body:setMass or Body:resetMassData.
	-- @param world (World) The world to create the body in.
	-- @param x (number) The x position of the body. (Default: 0.)
	-- @param y (number) The y position of the body. (Default: 0.)
	-- @param body_type (BodyType) The type of the body. (Default: 'static'.)
	-- @return (Body) A new body.
	newBody: function(world: World, x?: number, y?: number, body_type?: BodyType): Body

	-- Creates and attaches a Fixture to a body.
	-- Note that the Shape object is copied rather than kept as a reference when the Fixture is created. To get the Shape
	-- object that the Fixture owns, use Fixture:getShape.
	-- @param body (Body) The body which gets the fixture attached.
	-- @param shape (Shape) The shape to be copied to the fixture.
	-- @param density (number) The density of the fixture. (Default: 1.)
	-- @return (Fixture) The new fixture.
	newFixture: function(body: Body, shape: Shape, density?: number): Fixture

	-- Creates a new CircleShape.
	-- @param radius (number) The radius of the circle.
	-- @return (CircleShape) shape — The new shape.
	newCircleShape: function(radius: number): CircleShape

	-- Creates a new CircleShape.
	-- @param x (number) The x position of the circle.
	-- @param y (number) The y position of the circle.
	-- @param radius (number) The radius of the circle.
	-- @return (CircleShape) shape — The new shape.
	newCircleShape: function(x: number, y: number, radius: number): CircleShape

	-- Shorthand for creating rectangular PolygonShapes.
	--
	-- By default, the local origin is located at the '''center''' of the rectangle as opposed to the top left for graphics.
	-- @param width (number) The width of the rectangle.
	-- @param height (number) The height of the rectangle.
	-- @return (PolygonShape) shape — A new PolygonShape.
	newRectangleShape: function(width: number, height: number): PolygonShape

	-- Shorthand for creating rectangular PolygonShapes.
	--
	-- By default, the local origin is located at the '''center''' of the rectangle as opposed to the top left for graphics.
	-- @param x (number) The offset along the x-axis.
	-- @param y (number) The offset along the y-axis.
	-- @param width (number) The width of the rectangle.
	-- @param height (number) The height of the rectangle.
	-- @param angle (number) The initial angle of the rectangle. (Default: 0.)
	-- @return (PolygonShape) shape — A new PolygonShape.
	newRectangleShape: function(x: number, y: number, width: number, height: number, angle?: number): PolygonShape

	-- Creates a new PolygonShape.
	--
	-- This shape can have 8 vertices at most, and must form a convex shape.
	-- @param points ({number}) A list of vertices to construct the polygon, in the form of {x1, y1, x2, y2, x3, y3, ...}.
	-- @return (PolygonShape) shape — A new PolygonShape.
	newPolygonShape: function(points: {number}): PolygonShape

	-- Creates a new PolygonShape.
	--
	-- This shape can have 8 vertices at most, and must form a convex shape.
	-- @param points (number...) A list of vertices to construct the polygon, in the form of {x1, y1, x2, y2, x3, y3, ...}.
	-- @return (PolygonShape) shape — A new PolygonShape.
	newPolygonShape: function(points: number...): PolygonShape

	-- Creates a new EdgeShape.
	-- @param x1 (number) The x position of the first point.
	-- @param y1 (number) The y position of the first point.
	-- @param x2 (number) The x position of the second point.
	-- @param y2 (number) The y position of the second point.
	-- @return (Shape) The new shape.
	newEdgeShape: function(x1: number, y1: number, x2: number, y2: number): Shape

	-- Creates a new ChainShape.
	-- @param loop (boolean) If the chain should loop back to the first point.
	-- @param points ({number}) A list of points to construct the ChainShape, in the form of {x1, y1, x2, y2, ...}.
	-- @return (ChainShape) shape — The new shape.
	newChainShape: function(loop: boolean, points: {number}): ChainShape

	-- Creates a new ChainShape.
	-- @param loop (boolean) If the chain should loop back to the first point.
	-- @param points (number...) A list of points to construct the ChainShape, in the form of {x1, y1, x2, y2, ...}.
	-- @return (ChainShape) shape — The new shape.
	newChainShape: function(loop: boolean, points: number...): ChainShape

	-- Creates a DistanceJoint between two bodies.
	-- This joint constrains the distance between two points on two bodies to be constant. These two points are specified
	-- in world coordinates and the two bodies are assumed to be in place when this joint is created. The first anchor
	-- point is connected to the first body and the second to the second body, and the points define the length of the
	-- distance joint.
	-- @param body1 (Body) The first body to attach to the joint.
	-- @param body2 (Body) The second body to attach to the joint.
	-- @param x1 (number) The x position of the first anchor point (world space).
	-- @param y1 (number) The y position of the first anchor point (world space).
	-- @param x2 (number) The x position of the second anchor point (world space).
	-- @param y2 (number) The y position of the second anchor point (world space).
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (Joint) The new distance joint.
	newDistanceJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean): Joint

	-- Creates a pivot joint between two bodies.
	--
	-- This joint connects two bodies to a point around which they can pivot.
	-- @param body1 (Body) The first body.
	-- @param body2 (Body) The second body.
	-- @param x (number) The x position of the connecting point.
	-- @param y (number) The y position of the connecting point.
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (RevoluteJoint) joint — The new revolute joint.
	newRevoluteJoint: function(body1: Body, body2: Body, x: number, y: number, collide_connected?: boolean): RevoluteJoint

	-- Creates a pivot joint between two bodies.
	--
	-- This joint connects two bodies to a point around which they can pivot.
	-- @param body1 (Body) The first body.
	-- @param body2 (Body) The second body.
	-- @param x1 (number) The x position of the first connecting point.
	-- @param y1 (number) The y position of the first connecting point.
	-- @param x2 (number) The x position of the second connecting point.
	-- @param y2 (number) The y position of the second connecting point.
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @param reference_angle (number) The reference angle between body1 and body2, in radians. (Default: 0.)
	-- @return (RevoluteJoint) joint — The new revolute joint.
	newRevoluteJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean, reference_angle?: number): RevoluteJoint

	-- Creates a PrismaticJoint between two bodies.
	--
	-- A prismatic joint constrains two bodies to move relatively to each other on a specified axis. It does not allow for relative rotation. Its definition and operation are similar to a revolute joint, but with translation and force substituted for angle and torque.
	-- @param body1 (Body) The first body to connect with a prismatic joint.
	-- @param body2 (Body) The second body to connect with a prismatic joint.
	-- @param x (number) The x coordinate of the anchor point.
	-- @param y (number) The y coordinate of the anchor point.
	-- @param axis_x (number) The x coordinate of the axis vector.
	-- @param axis_y (number) The y coordinate of the axis vector.
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (PrismaticJoint) joint — The new prismatic joint.
	newPrismaticJoint: function(body1: Body, body2: Body, x: number, y: number, axis_x: number, axis_y: number, collide_connected?: boolean): PrismaticJoint

	-- Creates a PrismaticJoint between two bodies.
	--
	-- A prismatic joint constrains two bodies to move relatively to each other on a specified axis. It does not allow for relative rotation. Its definition and operation are similar to a revolute joint, but with translation and force substituted for angle and torque.
	-- @param body1 (Body) The first body to connect with a prismatic joint.
	-- @param body2 (Body) The second body to connect with a prismatic joint.
	-- @param x1 (number) The x coordinate of the first anchor point.
	-- @param y1 (number) The y coordinate of the first anchor point.
	-- @param x2 (number) The x coordinate of the second anchor point.
	-- @param y2 (number) The y coordinate of the second anchor point.
	-- @param axis_x (number) The x coordinate of the axis unit vector.
	-- @param axis_y (number) The y coordinate of the axis unit vector.
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @param reference_angle (number) The reference angle between body1 and body2, in radians. (Default: 0.)
	-- @return (PrismaticJoint) joint — The new prismatic joint.
	newPrismaticJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axis_x: number, axis_y: number, collide_connected?: boolean, reference_angle?: number): PrismaticJoint

	-- Creates a constraint joint between two bodies. A WeldJoint essentially glues two bodies together. The constraint is a bit soft, however, due to Box2D's iterative solver.
	-- @param body1 (Body) The first body to attach to the joint.
	-- @param body2 (Body) The second body to attach to the joint.
	-- @param x (number) The x position of the anchor point (world space).
	-- @param y (number) The y position of the anchor point (world space).
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (WeldJoint) joint — The new WeldJoint.
	newWeldJoint: function(body1: Body, body2: Body, x: number, y: number, collide_connected?: boolean): WeldJoint

	-- Creates a constraint joint between two bodies. A WeldJoint essentially glues two bodies together. The constraint is a bit soft, however, due to Box2D's iterative solver.
	-- @param body1 (Body) The first body to attach to the joint.
	-- @param body2 (Body) The second body to attach to the joint.
	-- @param x1 (number) The x position of the first anchor point (world space).
	-- @param y1 (number) The y position of the first anchor point (world space).
	-- @param x2 (number) The x position of the second anchor point (world space).
	-- @param y2 (number) The y position of the second anchor point (world space).
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @param reference_angle (number) The reference angle between body1 and body2, in radians. (Default: 0.)
	-- @return (WeldJoint) joint — The new WeldJoint.
	newWeldJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean, reference_angle?: number): WeldJoint

	-- Create a friction joint between two bodies. A FrictionJoint applies friction to a body.
	-- @param body1 (Body) The first body to attach to the joint.
	-- @param body2 (Body) The second body to attach to the joint.
	-- @param x (number) The x position of the anchor point.
	-- @param y (number) The y position of the anchor point.
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (FrictionJoint) joint — The new FrictionJoint.
	newFrictionJoint: function(body1: Body, body2: Body, x: number, y: number, collide_connected?: boolean): FrictionJoint

	-- Create a friction joint between two bodies. A FrictionJoint applies friction to a body.
	-- @param body1 (Body) The first body to attach to the joint.
	-- @param body2 (Body) The second body to attach to the joint.
	-- @param x1 (number) The x position of the first anchor point.
	-- @param y1 (number) The y position of the first anchor point.
	-- @param x2 (number) The x position of the second anchor point.
	-- @param y2 (number) The y position of the second anchor point.
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (FrictionJoint) joint — The new FrictionJoint.
	newFrictionJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean): FrictionJoint

	-- Creates a joint between two bodies. Its only function is enforcing a max distance between these bodies.
	-- @param body1 (Body) The first body to attach to the joint.
	-- @param body2 (Body) The second body to attach to the joint.
	-- @param x1 (number) The x position of the first anchor point.
	-- @param y1 (number) The y position of the first anchor point.
	-- @param x2 (number) The x position of the second anchor point.
	-- @param y2 (number) The y position of the second anchor point.
	-- @param max_length (number) The maximum distance for the bodies.
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (Joint) The new RopeJoint.
	newRopeJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, max_length: number, collide_connected?: boolean): Joint

	-- Creates a PulleyJoint to join two bodies to each other and the ground.
	-- The pulley joint simulates a pulley with an optional block and tackle. If the ratio parameter has a value
	-- different from one, then the simulated rope extends faster on one side than the other. In a pulley joint the total
	-- length of the simulated rope is the constant length1 + ratio * length2, which is set when the pulley joint is
	-- created.
	-- Pulley joints can behave unpredictably if one side is fully extended. It is recommended that the method
	-- setMaxLengths be used to constrain the maximum lengths each side can attain.
	-- @param body1 (Body) The first body to connect with a pulley joint.
	-- @param body2 (Body) The second body to connect with a pulley joint.
	-- @param ground_x1 (number) The x coordinate of the first body's ground anchor.
	-- @param ground_y1 (number) The y coordinate of the first body's ground anchor.
	-- @param ground_x2 (number) The x coordinate of the second body's ground anchor.
	-- @param ground_y2 (number) The y coordinate of the second body's ground anchor.
	-- @param x1 (number) The x coordinate of the pulley joint anchor in the first body.
	-- @param y1 (number) The y coordinate of the pulley joint anchor in the first body.
	-- @param x2 (number) The x coordinate of the pulley joint anchor in the second body.
	-- @param y2 (number) The y coordinate of the pulley joint anchor in the second body.
	-- @param ratio (number) The joint ratio. (Default: 1.)
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: true.)
	-- @return (Joint) The new pulley joint.
	newPulleyJoint: function(body1: Body, body2: Body, ground_x1: number, ground_y1: number, ground_x2: number, ground_y2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collide_connected?: boolean): Joint

	-- Creates a wheel joint.
	-- @param body1 (Body) The first body.
	-- @param body2 (Body) The second body.
	-- @param x (number) The x position of the anchor point.
	-- @param y (number) The y position of the anchor point.
	-- @param axis_x (number) The x position of the axis unit vector.
	-- @param axis_y (number) The y position of the axis unit vector.
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (WheelJoint) joint — The new WheelJoint.
	newWheelJoint: function(body1: Body, body2: Body, x: number, y: number, axis_x: number, axis_y: number, collide_connected?: boolean): WheelJoint

	-- Creates a wheel joint.
	-- @param body1 (Body) The first body.
	-- @param body2 (Body) The second body.
	-- @param x1 (number) The x position of the first anchor point.
	-- @param y1 (number) The y position of the first anchor point.
	-- @param x2 (number) The x position of the second anchor point.
	-- @param y2 (number) The y position of the second anchor point.
	-- @param axis_x (number) The x position of the axis unit vector.
	-- @param axis_y (number) The y position of the axis unit vector.
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (WheelJoint) joint — The new WheelJoint.
	newWheelJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axis_x: number, axis_y: number, collide_connected?: boolean): WheelJoint

	-- Create a joint between a body and the mouse.
	-- This joint actually connects the body to a fixed point in the world. To make it follow the mouse, the fixed point
	-- must be updated every timestep (example below).
	-- The advantage of using a MouseJoint instead of just changing a body position directly is that collisions and
	-- reactions to other joints are handled by the physics engine.
	-- @param body (Body) The body to attach to the mouse.
	-- @param x (number) The x position of the connecting point.
	-- @param y (number) The y position of the connecting point.
	-- @return (Joint) The new mouse joint.
	newMouseJoint: function(body: Body, x: number, y: number): Joint

	-- Creates a joint between two bodies which controls the relative motion between them.
	-- Position and rotation offsets can be specified once the MotorJoint has been created, as well as the maximum motor
	-- force and torque that will be be applied to reach the target offsets.
	-- @param body1 (Body) The first body to attach to the joint.
	-- @param body2 (Body) The second body to attach to the joint.
	-- @param correction_factor (number) The joint's initial position correction factor, in the range of 1. (Default: 0.3.)
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (Joint) The new MotorJoint.
	newMotorJoint: function(body1: Body, body2: Body, correction_factor?: number, collide_connected?: boolean): Joint

	-- Create a GearJoint connecting two Joints.
	-- The gear joint connects two joints that must be either prismatic or revolute joints. Using this joint requires
	-- that the joints it uses connect their respective bodies to the ground and have the ground as the first body. When
	-- destroying the bodies and joints you must make sure you destroy the gear joint before the other joints.
	-- The gear joint has a ratio the determines how the angular or distance values of the connected joints relate to
	-- each other. The formula coordinate1 + ratio * coordinate2 always has a constant value that is set when the gear
	-- joint is created.
	-- @param joint1 (Joint) The first joint to connect with a gear joint.
	-- @param joint2 (Joint) The second joint to connect with a gear joint.
	-- @param ratio (number) The gear ratio. (Default: 1.)
	-- @param collide_connected (boolean) Specifies whether the two bodies should collide with each other. (Default: false.)
	-- @return (Joint) The new gear joint.
	newGearJoint: function(joint1: Joint, joint2: Joint, ratio?: number, collide_connected?: boolean): Joint
end

-- The primary responsibility for the love.graphics module is the drawing of lines, shapes, text, Images and
-- other Drawable objects onto the screen. Its secondary responsibilities include loading external files
-- (including Images and Fonts) into memory, creating specialized objects (such as ParticleSystems or
-- Canvases) and managing screen geometry.
local record Graphics

	-- Clears the screen or active Canvas to the specified color.
	--
	-- This function is called automatically before love.draw in the default love.run function. See the example in love.run for a typical use of this function.
	--
	-- Note that the scissor area bounds the cleared region.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	--
	-- In versions prior to background color instead.
	clear: function()

	-- Clears the screen or active Canvas to the specified color.
	--
	-- This function is called automatically before love.draw in the default love.run function. See the example in love.run for a typical use of this function.
	--
	-- Note that the scissor area bounds the cleared region.
	--
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	--
	-- In versions prior to background color instead.
	-- @param red (number) A table in the form of {r, g, b, a} containing the color to clear the first active Canvas to.
	-- @param green (number) Additional tables for each active Canvas.
	-- @param blue (number) Whether to clear the active stencil buffer, if present. It can also be an integer between 0 and 255 to clear the stencil buffer to a specific value. (Default: true.)
	-- @param alpha (number) Whether to clear the active depth buffer, if present. It can also be a number between 0 and 1 to clear the depth buffer to a specific value. (Default: true.)
	clear: function(red: number, green: number, blue: number, alpha?: number)

	-- Discards (trashes) the contents of the screen or active Canvas. This is a performance optimization function with
	-- niche use cases.
	-- If the active Canvas has just been changed and the 'replace' BlendMode is about to be used to draw something which
	-- covers the entire screen, calling love.graphics.discard rather than calling love.graphics.clear or doing nothing
	-- may improve performance on mobile devices.
	-- On some desktop systems this function may do nothing.
	-- @param discard_color (boolean or {boolean}) Whether to discard the texture(s) of the active Canvas(es) (the contents of the screen if no Canvas is active.) (Default: true.)
	-- @param discard_depth_stencil (boolean) Whether to discard the contents of the stencil buffer of the screen / active Canvas. (Default: true.)
	discard: function(discard_color?: boolean | {boolean}, discard_depth_stencil?: boolean)

	-- Immediately renders any pending automatically batched draws.
	-- LÖVE will call this function internally as needed when most state is changed, so it is not necessary to manually
	-- call it.
	-- The current batch will be automatically flushed by love.graphics state changes (except for the transform stack and
	-- the current color), as well as Shader:send and methods on Textures which change their state. Using a different
	-- Image in consecutive love.graphics.draw calls will also flush the current batch.
	-- SpriteBatches, ParticleSystems, Meshes, and Text objects do their own batching and do not affect automatic
	-- batching of other draws, aside from flushing the current batch when they're drawn.
	flushBatch: function()

	-- Sets the background color.
	-- @param red (number) The red component (0-1).
	-- @param green (number) The green component (0-1).
	-- @param blue (number) The blue component (0-1).
	-- @param alpha (number) The alpha component (0-1). (Default: 1.)
	setBackgroundColor: function(red: number, green: number, blue: number, alpha?: number)

	-- Sets the background color.
	-- @param color (Color) A numerical indexed table with the red, green, blue and alpha values as numbers. The alpha is optional and defaults to 1 if it is left out.
	setBackgroundColor: function(color: Color)

	-- Gets the current background color.
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @return (number) The red component (0-1).
	-- @return (number) The green component (0-1).
	-- @return (number) The blue component (0-1).
	-- @return (number) The alpha component (0-1).
	getBackgroundColor: function(): number, number, number, number

	-- Sets the default scaling filters used with Images, Canvases, and Fonts.
	-- Overload details:
	--   1. This function does not apply retroactively to loaded images.
	-- @param min_filter (FilterMode) Filter mode used when scaling the image down.
	-- @param mag_filter (FilterMode) Filter mode used when scaling the image up. (Default: min.)
	-- @param anisotropy (number) Maximum amount of Anisotropic Filtering used. (Default: 1.)
	setDefaultFilter: function(min_filter: FilterMode, mag_filter?: FilterMode, anisotropy?: number)

	-- Returns the default scaling filters used with Images, Canvases, and Fonts.
	-- @param filter (string) The filter parameter.
	-- @param sharpness (number) The sharpness parameter.
	-- @return (FilterMode) Filter mode used when scaling the image down.
	-- @return (FilterMode) Filter mode used when scaling the image up.
	-- @return (number) Maximum amount of Anisotropic Filtering used.
	getDefaultFilter: function(): FilterMode, FilterMode, number
	setDefaultMipmapFilter: function(filter?: FilterMode, sharpness?: number)
	getDefaultMipmapFilter: function(): FilterMode | nil, number

	-- Sets the color used for drawing.
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param red (number) The amount of red.
	-- @param green (number) The amount of green.
	-- @param blue (number) The amount of blue.
	-- @param alpha (number) The amount of alpha. The alpha value will be applied to all subsequent draw operations, even the drawing of an image. (Default: 1.)
	setColor: function(red: number, green: number, blue: number, alpha?: number)

	-- Gets the current color.
	-- In versions prior to 11.0, color component values were within the range of 0 to 255 instead of 0 to 1.
	-- @return (number) The red component (0-1).
	-- @return (number) The green component (0-1).
	-- @return (number) The blue component (0-1).
	-- @return (number) The alpha component (0-1).
	getColor: function(): number, number, number, number

	-- Sets the line width.
	-- @param width (number) The width of the line.
	setLineWidth: function(width: number)

	-- Gets the current line width.
	-- Overload details:
	--   1. This function does not work in 0.8.0, but has been fixed in version 0.9.0. Use the following snippet to
	--      circumvent this in 0.8.0; love.graphics._getLineWidth = love.graphics.getLineWidth
	--      love.graphics._setLineWidth = love.graphics.setLineWidth function love.graphics.getLineWidth() return
	--      love.graphics.varlinewidth or 1 end function love.graphics.setLineWidth(w) love.graphics.varlinewidth = w;
	--      return love.graphics._setLineWidth(w) end
	-- @return (number) The current line width.
	getLineWidth: function(): number

	-- Sets the line style.
	-- @param style (LineStyle) The LineStyle to use. Line styles include smooth and rough.
	setLineStyle: function(style: LineStyle)

	-- Gets the line style.
	-- @return (LineStyle) The current line style.
	getLineStyle: function(): LineStyle

	-- Sets the line join style. See LineJoin for the possible options.
	-- @param join (LineJoin) The LineJoin to use.
	setLineJoin: function(join: LineJoin)

	-- Gets the line join style.
	-- @return (LineJoin) The LineJoin style.
	getLineJoin: function(): LineJoin

	-- Sets whether wireframe lines will be used when drawing.
	-- @param enable (boolean) True to enable wireframe mode when drawing, false to disable it.
	setWireframe: function(enable: boolean)

	-- Gets whether wireframe mode is used when drawing.
	-- @return (boolean) True if wireframe lines are used when drawing, false if it's not.
	isWireframe: function(): boolean

	-- Sets the point size.
	-- @param size (number) The new point size.
	setPointSize: function(size: number)

	-- Gets the point size.
	-- @return (number) The current point size.
	getPointSize: function(): number

	-- Gets the width and height in pixels of the window.
	-- @return (number) The width of the window.
	-- @return (number) The height of the window.
	getDimensions: function(): number, number

	-- Gets the width in pixels of the window.
	-- @return (number) The width of the window.
	getWidth: function(): number

	-- Gets the height in pixels of the window.
	-- @return (number) The height of the window.
	getHeight: function(): number

	-- Gets the width and height in pixels of the window.
	-- love.graphics.getDimensions gets the dimensions of the window in units scaled by the screen's DPI scale factor,
	-- rather than pixels. Use getDimensions for calculations related to drawing to the screen and using the graphics
	-- coordinate system (calculating the center of the screen, for example), and getPixelDimensions only when dealing
	-- specifically with underlying pixels (pixel-related calculations in a pixel Shader, for example).
	-- @return (number) The width of the window in pixels.
	-- @return (number) The height of the window in pixels.
	getPixelDimensions: function(): number, number

	-- Gets the width in pixels of the window.
	-- The graphics coordinate system and DPI scale factor, rather than raw pixels. Use getWidth for calculations related
	-- to drawing to the screen and using the coordinate system (calculating the center of the screen, for example), and
	-- getPixelWidth only when dealing specifically with underlying pixels (pixel-related calculations in a pixel Shader,
	-- for example).
	-- @return (number) The width of the window in pixels.
	getPixelWidth: function(): number

	-- Gets the height in pixels of the window.
	-- The graphics coordinate system and DPI scale factor, rather than raw pixels. Use getHeight for calculations
	-- related to drawing to the screen and using the coordinate system (calculating the center of the screen, for
	-- example), and getPixelHeight only when dealing specifically with underlying pixels (pixel-related calculations in
	-- a pixel Shader, for example).
	-- @return (number) The height of the window in pixels.
	getPixelHeight: function(): number

	-- Gets the DPI scale factor of the window.
	-- The DPI scale factor represents relative pixel density. The pixel density inside the window might be greater (or
	-- smaller) than the 'size' of the window. For example on a retina screen in Mac OS X with the highdpi window flag
	-- enabled, the window may take up the same physical size as an 800x600 window, but the area inside the window uses
	-- 1600x1200 pixels. love.graphics.getDPIScale() would return 2 in that case.
	-- The love.window.fromPixels and love.window.toPixels functions can also be used to convert between units.
	-- The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS. The
	-- flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
	-- Overload details:
	--   1. The units of love.graphics.getWidth, love.graphics.getHeight, love.mouse.getPosition, mouse events,
	--      love.touch.getPosition, and touch events are always in DPI-scaled units rather than pixels. In LÖVE 0.10 and
	--      older they were in pixels.
	-- @return (number) The pixel scale factor associated with the window.
	getDPIScale: function(): number

	-- Gets the optional graphics features and whether they're supported on the system.
	-- Some older or low-end systems don't always support all graphics features.
	-- @param target (any) The target parameter.
	-- @return (GraphicsFeatures) A table containing GraphicsFeature keys, and boolean values indicating whether each feature is supported.
	getSupported: function(target?: any): GraphicsFeatures

	-- Gets the available texture types, and whether each is supported.
	-- @param target (any) The target parameter.
	-- @return ({string: boolean}) A table containing TextureTypes as keys, and a boolean indicating whether the type is supported as values. Not all systems support all types.
	getTextureTypes: function(target?: any): {string: boolean}

	-- Gets the raw and compressed pixel formats usable for Images, and whether each is supported.
	-- @param target (any) The target parameter.
	-- @return ({string: boolean}) A table containing PixelFormats as keys, and a boolean indicating whether the format is supported as values. Not all systems support all formats.
	getImageFormats: function(target?: any): {string: boolean}

	-- Gets information about the system's video card and drivers.
	-- @return (string) The name of the renderer, e.g. 'OpenGL' or 'OpenGL ES'.
	-- @return (string) The version of the renderer with some extra driver-dependent version info, e.g. '2.1 INTEL-8.10.44'.
	-- @return (string) The name of the graphics card vendor, e.g. 'Intel Inc'.
	-- @return (string) The name of the graphics card, e.g. 'Intel HD Graphics 3000 OpenGL Engine'.
	getRendererInfo: function(): string, string, string, string

	-- Gets the system-dependent maximum values for love.graphics features.
	-- @param target (any) The target parameter.
	-- @return (GraphicsSystemLimits) A table containing GraphicsLimit keys, and number values.
	getSystemLimits: function(target?: any): GraphicsSystemLimits

	-- Gets performance-related rendering statistics.
	-- @return (GraphicsStats) stats — A table with the following fields:
	getStats: function(): GraphicsStats

	-- Gets performance-related rendering statistics.
	-- @param target (any) A table which will be filled in with the stat fields below.
	-- @return (GraphicsStats) The table that was passed in above, now containing the following fields:
	getStats: function(target: any): GraphicsStats

	-- Creates a screenshot once the current frame is done (after love.draw has finished).
	--
	-- Since this function enqueues a screenshot capture rather than executing it immediately, it can be called from an input callback or love.update and it will still capture all of what's drawn to the screen in that frame.
	-- @param filename (string) The filename to save the screenshot to. The encoded image type is determined based on the extension of the filename, and must be one of the ImageFormats.
	captureScreenshot: function(filename: string)

	-- Creates a screenshot once the current frame is done (after love.draw has finished).
	--
	-- Since this function enqueues a screenshot capture rather than executing it immediately, it can be called from an input callback or love.update and it will still capture all of what's drawn to the screen in that frame.
	-- @param callback (function(image_data: ImageData)) Function which gets called once the screenshot has been captured. An ImageData is passed into the function as its only argument.
	captureScreenshot: function(callback: function(image_data: ImageData))

	-- Creates a screenshot once the current frame is done (after love.draw has finished).
	--
	-- Since this function enqueues a screenshot capture rather than executing it immediately, it can be called from an input callback or love.update and it will still capture all of what's drawn to the screen in that frame.
	-- @param channel (Channel) The Channel to push the generated ImageData to.
	captureScreenshot: function(channel: Channel)

	-- Draws a rectangle.
	-- Overload details:
	--   1. Draws a rectangle with rounded corners.
	-- @param mode (DrawMode) How to draw the rectangle.
	-- @param x (number) The position of top-left corner along the x-axis.
	-- @param y (number) The position of top-left corner along the y-axis.
	-- @param width (number) Width of the rectangle.
	-- @param height (number) Height of the rectangle.
	rectangle: function(mode: DrawMode, x: number, y: number, width: number, height: number)

	-- Draws a circle.
	-- @param mode (DrawMode) How to draw the circle.
	-- @param x (number) The position of the center along x-axis.
	-- @param y (number) The position of the center along y-axis.
	-- @param radius (number) The radius of the circle.
	circle: function(mode: DrawMode, x: number, y: number, radius: number)

	-- Draws a filled or unfilled arc at position (x, y). The arc is drawn from angle1 to angle2 in radians. The segments parameter determines how many segments are used to draw the arc. The more segments, the smoother the edge.
	-- @param mode (DrawMode) How to draw the arc.
	-- @param x (number) The position of the center along x-axis.
	-- @param y (number) The position of the center along y-axis.
	-- @param radius (number) Radius of the arc.
	-- @param angle1 (number) The angle at which the arc begins.
	-- @param angle2 (number) The angle at which the arc terminates.
	-- @param segments (integer) The number of segments used for drawing the arc. (Default: 10.)
	arc: function(mode: DrawMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: integer)

	-- Draws a filled or unfilled arc at position (x, y). The arc is drawn from angle1 to angle2 in radians. The segments parameter determines how many segments are used to draw the arc. The more segments, the smoother the edge.
	-- @param mode (DrawMode) How to draw the arc.
	-- @param arc_mode (ArcMode) The type of arc to draw.
	-- @param x (number) The position of the center along x-axis.
	-- @param y (number) The position of the center along y-axis.
	-- @param radius (number) Radius of the arc.
	-- @param angle1 (number) The angle at which the arc begins.
	-- @param angle2 (number) The angle at which the arc terminates.
	-- @param segments (integer) The number of segments used for drawing the arc. (Default: 10.)
	arc: function(mode: DrawMode, arc_mode: ArcMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: integer)

	-- Draws an ellipse.
	-- @param mode (DrawMode) How to draw the ellipse.
	-- @param x (number) The position of the center along x-axis.
	-- @param y (number) The position of the center along y-axis.
	-- @param radius_x (number) The radius of the ellipse along the x-axis (half the ellipse's width).
	-- @param radius_y (number) The radius of the ellipse along the y-axis (half the ellipse's height).
	-- @param segments (integer) The number of segments used for drawing the ellipse.
	ellipse: function(mode: DrawMode, x: number, y: number, radius_x: number, radius_y: number, segments?: integer)

	-- Draws lines between points.
	-- @param x1 (number) The position of first point on the x-axis.
	-- @param y1 (number) The position of first point on the y-axis.
	-- @param x2 (number) The position of second point on the x-axis.
	-- @param y2 (number) The position of second point on the y-axis.
	-- @param coordinates (number...) You can continue passing point positions to draw a polyline.
	line: function(x1: number, y1: number, x2: number, y2: number, coordinates: number...)

	-- Draw a polygon.
	-- Following the mode argument, this function can accept multiple numeric arguments or a single table of numeric
	-- arguments. In either case the arguments are interpreted as alternating x and y coordinates of the polygon's
	-- vertices.
	-- @param mode (DrawMode) How to draw the polygon.
	-- @param x1 (number) The vertices of the polygon. Depending on the overload: The vertices of the polygon as a table.
	-- @param y1 (number) The y1 parameter.
	-- @param x2 (number) The x2 parameter.
	-- @param y2 (number) The y2 parameter.
	-- @param x3 (number) The x3 parameter.
	-- @param y3 (number) The y3 parameter.
	-- @param coordinates (number...) The coordinates parameter.
	polygon: function(mode: DrawMode, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, coordinates: number...)

	-- Draws one or more points.
	-- Overload details:
	--   1. Draws one or more individually colored points. In versions prior to 11.0, color component values were within
	--      the range of 0 to 255 instead of 0 to 1. The pixel grid is actually offset to the center of each pixel. So to
	--      get clean pixels drawn use 0.5 + integer increments. Points are not affected by size is always in pixels.
	-- @param x1 (number) The position of the first point on the x-axis.
	-- @param y1 (number) The position of the first point on the y-axis.
	-- @param coordinates (number...) The x and y coordinates of additional points.
	points: function(x1: number, y1: number, coordinates: number...)

	-- Displays the results of drawing operations on the screen.
	-- This function is used when writing your own love.run function. It presents all the results of your drawing
	-- operations on the screen. See the example in love.run for a typical use of this function.
	-- Overload details:
	--   1. * If love.window.setMode has vsync equal to true, this function can't run more frequently than the refresh
	--      rate (e.g. 60 Hz), and will halt the program until ready if necessary.
	present: function()

	-- Copies and pushes the current coordinate transformation to the transformation stack.
	--
	-- This function is always used to prepare for a corresponding pop operation later. It stores the current coordinate transformation state into the transformation stack and keeps it active. Later changes to the transformation can be undone by using the pop operation, which returns the coordinate transform to the state it was in before calling push.
	push: function()

	-- Copies and pushes the current coordinate transformation to the transformation stack.
	--
	-- This function is always used to prepare for a corresponding pop operation later. It stores the current coordinate transformation state into the transformation stack and keeps it active. Later changes to the transformation can be undone by using the pop operation, which returns the coordinate transform to the state it was in before calling push.
	-- @param stack_type (string) The type of stack to push (e.g. just transformation state, or all love.graphics state).
	push: function(stack_type: string)

	-- Pops the current coordinate transformation from the transformation stack.
	-- This function is always used to reverse a previous push operation. It returns the current transformation state to
	-- what it was before the last preceding push.
	pop: function()

	-- Gets the current depth of the transform / state stack (the number of pushes without corresponding pops).
	-- @return (integer) The current depth of the transform and state love.graphics stack.
	getStackDepth: function(): integer

	-- Resets the current coordinate transformation.
	-- This function is always used to reverse any previous calls to love.graphics.rotate, love.graphics.scale,
	-- love.graphics.shear or love.graphics.translate. It returns the current transformation state to its defaults.
	origin: function()

	-- Translates the coordinate system in two dimensions.
	-- When this function is called with two numbers, dx, and dy, all the following drawing operations take effect as if
	-- their x and y coordinates were x+dx and y+dy.
	-- Scale and translate are not commutative operations, therefore, calling them in different orders will change the
	-- outcome.
	-- This change lasts until love.draw() exits or else a love.graphics.pop reverts to a previous love.graphics.push.
	-- Translating using whole numbers will prevent tearing/blurring of images and fonts draw after translating.
	-- @param dx (number) The translation relative to the x-axis.
	-- @param dy (number) The translation relative to the y-axis.
	translate: function(dx: number, dy: number)

	-- Rotates the coordinate system in two dimensions.
	-- Calling this function affects all future drawing operations by rotating the coordinate system around the origin by
	-- the given amount of radians. This change lasts until love.draw() exits.
	-- @param angle (number) The amount to rotate the coordinate system in radians.
	rotate: function(angle: number)

	-- Scales the coordinate system in two dimensions.
	-- By default the coordinate system in LÖVE corresponds to the display pixels in horizontal and vertical directions
	-- one-to-one, and the x-axis increases towards the right while the y-axis increases downwards. Scaling the
	-- coordinate system changes this relation.
	-- After scaling by sx and sy, all coordinates are treated as if they were multiplied by sx and sy. Every result of a
	-- drawing operation is also correspondingly scaled, so scaling by (2, 2) for example would mean making everything
	-- twice as large in both x- and y-directions. Scaling by a negative value flips the coordinate system in the
	-- corresponding direction, which also means everything will be drawn flipped or upside down, or both. Scaling by
	-- zero is not a useful operation.
	-- Scale and translate are not commutative operations, therefore, calling them in different orders will change the
	-- outcome.
	-- Scaling lasts until love.draw() exits.
	-- @param sx (number) The scaling in the direction of the x-axis.
	-- @param sy (number) The scaling in the direction of the y-axis. If omitted, it defaults to same as parameter sx. (Default: sx.)
	scale: function(sx: number, sy?: number)

	-- Shears the coordinate system.
	-- @param kx (number) The shear factor on the x-axis.
	-- @param ky (number) The shear factor on the y-axis.
	shear: function(kx: number, ky: number)

	-- Applies the given Transform object to the current coordinate transformation.
	-- This effectively multiplies the existing coordinate transformation's matrix with the Transform object's internal
	-- matrix to produce the new coordinate transformation.
	-- @param transform (Transform) The Transform object to apply to the current graphics coordinate transform.
	applyTransform: function(transform: Transform)

	-- Replaces the current coordinate transformation with the given Transform object.
	-- @param transform (Transform) The Transform object to replace the current graphics coordinate transform with.
	replaceTransform: function(transform: Transform)

	-- Converts the given 2D position from global coordinates into screen-space.
	-- This effectively applies the current graphics transformations to the given position. A similar
	-- Transform:transformPoint method exists for Transform objects.
	-- @param x (number) The x component of the position in global coordinates.
	-- @param y (number) The y component of the position in global coordinates.
	-- @return (number) The x component of the position with graphics transformations applied.
	-- @return (number) The y component of the position with graphics transformations applied.
	transformPoint: function(x: number, y: number): number, number

	-- Converts the given 2D position from screen-space into global coordinates.
	-- This effectively applies the reverse of the current graphics transformations to the given position. A similar
	-- Transform:inverseTransformPoint method exists for Transform objects.
	-- @param x (number) The x component of the screen-space position.
	-- @param y (number) The y component of the screen-space position.
	-- @return (number) The x component of the position in global coordinates.
	-- @return (number) The y component of the position in global coordinates.
	inverseTransformPoint: function(x: number, y: number): number, number

	-- Gets whether the graphics module is able to be used. If it is not active, love.graphics function and method calls
	-- will not work correctly and may cause the program to crash.
	-- The graphics module is inactive if a window is not open, or if the app is in the background on iOS. Typically the
	-- app's execution will be automatically paused by the system, in the latter case.
	-- @return (boolean) Whether the graphics module is active and able to be used.
	isActive: function(): boolean
	isCreated: function(): boolean

	-- Gets whether gamma-correct rendering is supported and enabled. It can be enabled by setting t.gammacorrect = true
	-- in love.conf.
	-- Not all devices support gamma-correct rendering, in which case it will be automatically disabled and this function
	-- will return false. It is supported on desktop systems which have graphics cards that are capable of using OpenGL 3
	-- / DirectX 10, and iOS devices that can use OpenGL ES 3.
	-- Overload details:
	--   1. When gamma-correct rendering is enabled, many functions and objects perform automatic color conversion
	--      between sRGB and linear RGB in order for blending and shader math to be mathematically correct (which they
	--      aren't if it's not enabled.) * The colors passed into converted from sRGB to linear RGB. * The colors set in
	--      text with per-character colors, points with per-point colors, standard custom Meshes which use the
	--      'VertexColor' attribute name will automatically be converted from sRGB to linear RGB when those objects are
	--      drawn. * creating the Image. * Everything drawn to the screen will be blended in linear RGB and then the
	--      result will be converted to sRGB for display. * Canvases which use the 'normal' or 'srgb' CanvasFormat will
	--      have their content blended in linear RGB and the result will be stored in the canvas in sRGB, when drawing to
	--      them. When the Canvas itself is drawn, its pixel colors will be converted from sRGB to linear RGB in the same
	--      manner as Images. Keeping the canvas pixel data stored as sRGB allows for better precision (less banding) for
	--      darker colors compared to 'rgba8'. Because most conversions are automatically handled, your own code doesn't
	--      need to worry about sRGB and linear RGB color conversions when gamma-correct rendering is enabled, except in
	--      a couple cases: * If a Mesh with custom vertex attributes is used and one of the attributes is meant to be
	--      used as a color in a Shader, and the attribute isn't named 'VertexColor'. * If a Shader is used which has
	--      uniform / extern variables or other variables that are meant to be used as colors, and Shader:sendColor isn't
	--      used. In both cases, love.math.gammaToLinear can be used to convert color values to linear RGB in Lua code,
	--      or the gammaCorrectColor (or unGammaCorrectColor if necessary) shader functions can be used inside shader
	--      code. Those shader functions ''only'' do conversions if gamma-correct rendering is actually enabled. The
	--      LOVE_GAMMA_CORRECT shader preprocessor define will be set if so. Read more about gamma-correct rendering
	--      here, here, and here.
	-- @return (boolean) True if gamma-correct rendering is supported and was enabled in love.conf, false otherwise.
	isGammaCorrect: function(): boolean

	-- Resets the current graphics settings.
	-- Calling reset makes the current drawing color white, the current background color black, disables any active color
	-- component masks, disables wireframe mode and resets the current graphics transformation to the origin. It also
	-- sets both the point and line drawing modes to smooth and their sizes to 1.0.
	reset: function()

	-- Sets the blending mode.
	-- Overload details:
	--   1. The default 'alphamultiply' alpha mode should normally be preferred except when drawing content with
	--      pre-multiplied alpha. If content is drawn to a Canvas using the 'alphamultiply' mode, the Canvas texture will
	--      have pre-multiplied alpha afterwards, so the 'premultiplied' alpha mode should generally be used when drawing
	--      a Canvas to the screen.
	-- @param mode (BlendMode) The blend mode to use.
	-- @param alpha_mode (BlendAlphaMode) What to do with the alpha of drawn objects when blending. (Default: 'alphamultiply'.)
	setBlendMode: function(mode: BlendMode, alpha_mode?: BlendAlphaMode)

	-- Gets the blending mode.
	-- @return (BlendMode) The current blend mode.
	-- @return (BlendAlphaMode) The current blend alpha mode – it determines how the alpha of drawn objects affects blending.
	getBlendMode: function(): BlendMode, BlendAlphaMode

	-- Sets or disables scissor.
	--
	-- The scissor limits the drawing area to a specified rectangle. This affects all graphics calls, including love.graphics.clear.
	--
	-- The dimensions of the scissor is unaffected by graphical transformations (translate, scale, ...).
	setScissor: function()

	-- Sets or disables scissor.
	--
	-- The scissor limits the drawing area to a specified rectangle. This affects all graphics calls, including love.graphics.clear.
	--
	-- The dimensions of the scissor is unaffected by graphical transformations (translate, scale, ...).
	-- @param x (number) x coordinate of upper left corner.
	-- @param y (number) y coordinate of upper left corner.
	-- @param width (number) width of clipping rectangle.
	-- @param height (number) height of clipping rectangle.
	setScissor: function(x: number, y: number, width: number, height: number)

	-- Gets the current scissor box.
	-- @return (number or nil) The x-component of the top-left point of the box.
	-- @return (number or nil) The y-component of the top-left point of the box.
	-- @return (number or nil) The width of the box.
	-- @return (number or nil) The height of the box.
	getScissor: function(): number | nil, number | nil, number | nil, number | nil

	-- Sets the scissor to the rectangle created by the intersection of the specified rectangle with the existing
	-- scissor. If no scissor is active yet, it behaves like love.graphics.setScissor.
	-- The scissor limits the drawing area to a specified rectangle. This affects all graphics calls, including
	-- love.graphics.clear.
	-- The dimensions of the scissor is unaffected by graphical transformations (translate, scale, ...).
	-- @param x (number) The x-coordinate of the upper left corner of the rectangle to intersect with the existing scissor rectangle.
	-- @param y (number) The y-coordinate of the upper left corner of the rectangle to intersect with the existing scissor rectangle.
	-- @param width (number) The width of the rectangle to intersect with the existing scissor rectangle.
	-- @param height (number) The height of the rectangle to intersect with the existing scissor rectangle.
	intersectScissor: function(x: number, y: number, width: number, height: number)

	-- Sets the color mask. Enables or disables specific color components when rendering and clearing the screen. For example, if '''red''' is set to '''false''', no further changes will be made to the red component of any pixels.
	setColorMask: function()

	-- Sets the color mask. Enables or disables specific color components when rendering and clearing the screen. For example, if '''red''' is set to '''false''', no further changes will be made to the red component of any pixels.
	-- @param red (boolean) Render red component.
	-- @param green (boolean) Render green component.
	-- @param blue (boolean) Render blue component.
	-- @param alpha (boolean) Render alpha component.
	setColorMask: function(red: boolean, green: boolean, blue: boolean, alpha: boolean)

	-- Gets the active color components used when drawing. Normally all 4 components are active unless
	-- love.graphics.setColorMask has been used.
	-- The color mask determines whether individual components of the colors of drawn objects will affect the color of
	-- the screen. They affect love.graphics.clear and Canvas:clear as well.
	-- @return (boolean) Whether the red color component is active when rendering.
	-- @return (boolean) Whether the green color component is active when rendering.
	-- @return (boolean) Whether the blue color component is active when rendering.
	-- @return (boolean) Whether the alpha color component is active when rendering.
	getColorMask: function(): boolean, boolean, boolean, boolean

	-- Configures depth testing and writing to the depth buffer.
	--
	-- This is low-level functionality designed for use with custom vertex shaders and Meshes with custom vertex attributes. No higher level APIs are provided to set the depth of 2D graphics such as shapes, lines, and Images.
	setDepthMode: function()

	-- Configures depth testing and writing to the depth buffer.
	--
	-- This is low-level functionality designed for use with custom vertex shaders and Meshes with custom vertex attributes. No higher level APIs are provided to set the depth of 2D graphics such as shapes, lines, and Images.
	-- @param compare (CompareMode) Depth comparison mode used for depth testing.
	-- @param write (boolean) Whether to write update / write values to the depth buffer when rendering.
	setDepthMode: function(compare: CompareMode, write: boolean)

	-- Gets the current depth test mode and whether writing to the depth buffer is enabled.
	-- This is low-level functionality designed for use with custom vertex shaders and Meshes with custom vertex
	-- attributes. No higher level APIs are provided to set the depth of 2D graphics such as shapes, lines, and Images.
	-- @return (CompareMode) Depth comparison mode used for depth testing.
	-- @return (boolean) Whether to write update / write values to the depth buffer when rendering.
	getDepthMode: function(): CompareMode, boolean

	-- Sets whether back-facing triangles in a Mesh are culled.
	-- This is designed for use with low level custom hardware-accelerated 3D rendering via custom vertex attributes on
	-- Meshes, custom vertex shaders, and depth testing with a depth buffer.
	-- By default, both front- and back-facing triangles in Meshes are rendered.
	-- @param mode (MeshCullMode) The Mesh face culling mode to use (whether to render everything, cull back-facing triangles, or cull front-facing triangles).
	setMeshCullMode: function(mode: MeshCullMode)

	-- Gets whether back-facing triangles in a Mesh are culled.
	-- Mesh face culling is designed for use with low level custom hardware-accelerated 3D rendering via custom vertex
	-- attributes on Meshes, custom vertex shaders, and depth testing with a depth buffer.
	-- @return (MeshCullMode) The Mesh face culling mode in use (whether to render everything, cull back-facing triangles, or cull front-facing triangles).
	getMeshCullMode: function(): MeshCullMode

	-- Sets whether triangles with clockwise- or counterclockwise-ordered vertices are considered front-facing.
	-- This is designed for use in combination with Mesh face culling. Other love.graphics shapes, lines, and sprites are
	-- not guaranteed to have a specific winding order to their internal vertices.
	-- @param winding (Winding) The winding mode to use. The default winding is counterclockwise ('ccw').
	setFrontFaceWinding: function(winding: Winding)

	-- Gets whether triangles with clockwise- or counterclockwise-ordered vertices are considered front-facing.
	-- This is designed for use in combination with Mesh face culling. Other love.graphics shapes, lines, and sprites are
	-- not guaranteed to have a specific winding order to their internal vertices.
	-- @return (Winding) The winding mode being used. The default winding is counterclockwise ('ccw').
	getFrontFaceWinding: function(): Winding

	-- Draws geometry as a stencil.
	--
	-- The geometry drawn by the supplied function sets invisible stencil values of pixels, instead of setting pixel colors. The stencil buffer (which contains those stencil values) can act like a mask / stencil - love.graphics.setStencilTest can be used afterward to determine how further rendering is affected by the stencil values in each pixel.
	--
	-- Stencil values are integers within the range of 255.
	-- @param draw (function()) Function which draws geometry. The stencil values of pixels, rather than the color of each pixel, will be affected by the geometry.
	-- @param action (StencilAction) How to modify any stencil values of pixels that are touched by what's drawn in the stencil function. (Default: 'replace'.)
	-- @param value (integer) The new stencil value to use for pixels if the 'replace' stencil action is used. Has no effect with other stencil actions. Must be between 0 and 255. (Default: 1.)
	-- @param keep_values_or_clear_value (boolean) True to preserve old stencil values of pixels, false to re-set every pixel's stencil value to 0 before executing the stencil function. love.graphics.clear will also re-set all stencil values. (Default: false.)
	stencil: function(draw: function(), action?: StencilAction, value?: integer, keep_values_or_clear_value?: boolean)

	-- Draws geometry as a stencil.
	--
	-- The geometry drawn by the supplied function sets invisible stencil values of pixels, instead of setting pixel colors. The stencil buffer (which contains those stencil values) can act like a mask / stencil - love.graphics.setStencilTest can be used afterward to determine how further rendering is affected by the stencil values in each pixel.
	--
	-- Stencil values are integers within the range of 255.
	-- @param draw (function()) Function which draws geometry. The stencil values of pixels, rather than the color of each pixel, will be affected by the geometry.
	-- @param action (StencilAction) How to modify any stencil values of pixels that are touched by what's drawn in the stencil function. (Default: 'replace'.)
	-- @param value (integer) The new stencil value to use for pixels if the 'replace' stencil action is used. Has no effect with other stencil actions. Must be between 0 and 255. (Default: 1.)
	-- @param keep_values_or_clear_value (number) True to preserve old stencil values of pixels, false to re-set every pixel's stencil value to 0 before executing the stencil function. love.graphics.clear will also re-set all stencil values. (Default: false.)
	stencil: function(draw: function(), action: StencilAction, value: integer, keep_values_or_clear_value: number)

	-- Configures or disables stencil testing.
	--
	-- When stencil testing is enabled, the geometry of everything that is drawn afterward will be clipped / stencilled out based on a comparison between the arguments of this function and the stencil value of each pixel that the geometry touches. The stencil values of pixels are affected via love.graphics.stencil.
	setStencilTest: function()

	-- Configures or disables stencil testing.
	--
	-- When stencil testing is enabled, the geometry of everything that is drawn afterward will be clipped / stencilled out based on a comparison between the arguments of this function and the stencil value of each pixel that the geometry touches. The stencil values of pixels are affected via love.graphics.stencil.
	-- @param compare (CompareMode) The type of comparison to make for each pixel.
	-- @param value (integer) The value to use when comparing with the stencil value of each pixel. Must be between 0 and 255.
	setStencilTest: function(compare: CompareMode, value: integer)

	-- Gets the current stencil test configuration.
	-- When stencil testing is enabled, the geometry of everything that is drawn afterward will be clipped / stencilled
	-- out based on a comparison between the arguments of this function and the stencil value of each pixel that the
	-- geometry touches. The stencil values of pixels are affected via love.graphics.stencil.
	-- Each Canvas has its own per-pixel stencil values.
	-- @return (CompareMode) The type of comparison that is made for each pixel. Will be 'always' if stencil testing is disabled.
	-- @return (integer) The value used when comparing with the stencil value of each pixel.
	getStencilTest: function(): CompareMode, integer

	-- Creates a new Font from a TrueType Font or BMFont file. Created fonts are not cached, in that calling this function with the same arguments will always create a new Font object.
	--
	-- All variants which accept a filename can also accept a Data object instead.
	-- @param size (integer) The size of the font in pixels.
	-- @return (Font) font — A Font object which can be used to draw text on screen.
	newFont: function(size?: integer): Font

	-- Creates a new Font from a TrueType Font or BMFont file. Created fonts are not cached, in that calling this function with the same arguments will always create a new Font object.
	--
	-- All variants which accept a filename can also accept a Data object instead.
	-- @param filename (string) The filepath to the TrueType font file.
	-- @param size (integer) The size of the font in pixels. (Default: 12.)
	-- @return (Font) font — A Font object which can be used to draw text on screen.
	newFont: function(filename: string, size?: integer): Font

	-- Creates and sets a new Font.
	-- @param size (integer) The size of the font. (Default: 12.)
	-- @return (Font) font — The new font.
	setNewFont: function(size?: integer): Font

	-- Creates and sets a new Font.
	-- @param filename (string) The path and name of the file with the font.
	-- @param size (integer) The size of the font. (Default: 12.)
	-- @return (Font) font — The new font.
	setNewFont: function(filename: string, size?: integer): Font

	-- Creates a new specifically formatted image.
	--
	-- In versions prior to 0.9.0, LÖVE expects ISO 8859-1 encoding for the glyphs string.
	-- @param source (string | FileData | ImageData) The filepath to the image file.
	-- @param glyphs (string) A string of the characters in the image in order from left to right.
	-- @param extra_spacing (integer) Additional spacing (positive or negative) to apply to each glyph in the Font. (Default: 0.)
	-- @param dpi_scale (number) The DPI scale factor of the font. (Default: 1.)
	-- @return (Font) font — A Font object which can be used to draw text on screen.
	newImageFont: function(source: string | FileData | ImageData, glyphs: string, extra_spacing?: integer, dpi_scale?: number): Font

	-- Creates a new specifically formatted image.
	--
	-- In versions prior to 0.9.0, LÖVE expects ISO 8859-1 encoding for the glyphs string.
	-- @param rasterizer (Rasterizer) The ImageData object to create the font from.
	-- @return (Font) font — A Font object which can be used to draw text on screen.
	newImageFont: function(rasterizer: Rasterizer): Font

	-- Creates a new drawable Text object.
	-- @param font (Font) The font to use for the text.
	-- @param text (any) The initial string of text that the new Text object will contain. May be nil. (Default: nil.) Depending on the overload: A table containing colors and strings to add to the object, in the form of {color1, string1, color2, string2, ...}. color1: A table containing red, green, blue, and optional alpha components to use as a color for the next string in the table, in the form of {red, green, blue, alpha}. string1: A string of text which has a color specified by the previous color. color2: A table containing red, green, blue, and optional alpha components to use as a color for the next string in the table, in the form of {red, green, blue, alpha}. string2: A string of text which has a color specified by the previous color. ...: Additional colors and strings.
	-- @return (Text) The new drawable Text object.
	newText: function(font: Font, text?: any): Text

	-- Set an already-loaded Font as the current font or create and load a new one from the file and size.
	-- It's recommended that Font objects are created with love.graphics.newFont in the loading stage and then passed to
	-- this function in the drawing stage.
	-- @param font (Font) The Font object to use.
	setFont: function(font: Font)

	-- Gets the current Font object.
	-- @return (Font) The current Font. Automatically creates and sets the default font, if none is set yet.
	getFont: function(): Font

	-- Draws text on screen. If no Font is set, one will be created and set (once) if needed.
	-- As of LOVE 0.7.1, when using translation and scaling functions while drawing text, this function assumes the scale
	-- occurs first. If you don't script with this in mind, the text won't be in the right position, or possibly even on
	-- screen.
	-- love.graphics.print and love.graphics.printf both support UTF-8 encoding. You'll also need a proper Font for
	-- special characters.
	-- In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
	-- Overload details:
	--   1. The color set by love.graphics.setColor will be combined (multiplied) with the colors of the text.
	-- @param text (string or number) The text to draw.
	-- @param x (number) The position to draw the object (x-axis). (Default: 0.) Depending on the overload: The position of the text on the x-axis. (Default: 0.)
	-- @param y (number) The position to draw the object (y-axis). (Default: 0.) Depending on the overload: The position of the text on the y-axis. (Default: 0.)
	-- @param angle (number) The orientation of the text in radians. (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.) Depending on the overload: Scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.) Depending on the overload: Scale factor on the y-axis. (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.) Depending on the overload: Origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.) Depending on the overload: Origin offset on the y-axis. (Default: 0.)
	-- @param shear_x (number) Shearing factor (x-axis). (Default: 0.) Depending on the overload: Shearing / skew factor on the x-axis. (Default: 0.)
	-- @param shear_y (number) Shearing factor (y-axis). (Default: 0.) Depending on the overload: Shearing / skew factor on the y-axis. (Default: 0.)
	print: function(text: string | number, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Draws formatted text, with word wrap and alignment.
	-- See additional notes in love.graphics.print.
	-- The word wrap limit is applied before any scaling, rotation, and other coordinate transformations. Therefore the
	-- amount of text per line stays constant given the same wrap limit, even if the scale arguments change.
	-- In version 0.9.2 and earlier, wrapping was implemented by breaking up words by spaces and putting them back
	-- together to make sure things fit nicely within the limit provided. However, due to the way this is done, extra
	-- spaces between words would end up missing when printed on the screen, and some lines could overflow past the
	-- provided wrap limit. In version 0.10.0 and newer this is no longer the case.
	-- In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
	-- Overload details:
	--   1. The color set by love.graphics.setColor will be combined (multiplied) with the colors of the text.
	-- @param text (string or number) A text string.
	-- @param x (number) The position on the x-axis. Depending on the overload: The position of the text (x-axis).
	-- @param y (number) The position on the y-axis. Depending on the overload: The position of the text (y-axis).
	-- @param limit (number) Wrap the line after this many horizontal pixels. Depending on the overload: The maximum width in pixels of the text before it gets automatically wrapped to a new line.
	-- @param align (AlignMode) The alignment. (Default: 'left'.) Depending on the overload: The alignment of the text.
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shearing factor (x-axis). (Default: 0.) Depending on the overload: Shearing / skew factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shearing factor (y-axis). (Default: 0.) Depending on the overload: Shearing / skew factor (y-axis). (Default: 0.)
	printf: function(text: string | number, x: number, y: number, limit: number, align?: AlignMode, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally generates or specifies mipmaps for the image.
	-- @param filename (string) The filepath to the image file.
	-- @param settings (ImageSettings) A table containing the following fields: (Default: nil.)
	-- @return (Image) image — A new Image object which can be drawn on screen.
	newImage: function(filename: string, settings?: ImageSettings): Image

	-- Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally generates or specifies mipmaps for the image.
	-- @param data (FileData) The FileData containing image file.
	-- @param settings (CompressedImageSettings) A table containing the following fields: (Default: nil.)
	-- @return (Image) image — A new Image object which can be drawn on screen.
	newImage: function(data: FileData, settings?: CompressedImageSettings): Image

	-- Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally generates or specifies mipmaps for the image.
	-- @param data (ImageData) The ImageData containing image.
	-- @param settings (ImageSettings) A table containing the following fields: (Default: nil.)
	-- @return (Image) image — A new Image object which can be drawn on screen.
	newImage: function(data: ImageData, settings?: ImageSettings): Image

	-- Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally generates or specifies mipmaps for the image.
	-- @param data (CompressedImageData) A CompressedImageData object. The Image will use this CompressedImageData to reload itself when love.window.setMode is called.
	-- @param settings (CompressedImageSettings) A table containing the following fields: (Default: nil.)
	-- @return (Image) image — A new Image object which can be drawn on screen.
	newImage: function(data: CompressedImageData, settings?: CompressedImageSettings): Image

	-- Creates a new drawable Video. Currently only Ogg Theora video files are supported.
	-- @param filename (string) The file path to the Ogg Theora video file.
	-- @param settings (any) A table containing the following fields: (Default: nil.)
	-- @return (Video) video — A new Video.
	newVideo: function(filename: string, settings?: any): Video

	-- Creates a new drawable Video. Currently only Ogg Theora video files are supported.
	-- @param stream (VideoStream) The file path to the Ogg Theora video file.
	-- @param settings (any) A table containing the following fields: (Default: nil.)
	-- @return (Video) video — A new Video.
	newVideo: function(stream: VideoStream, settings?: any): Video
	_newVideo: function(filename_or_stream: string | VideoStream, dpi_scale?: number): Video

	-- Creates a new array Image.
	-- An array image / array texture is a single object which contains multiple 'layers' or 'slices' of 2D sub-images.
	-- It can be thought of similarly to a texture atlas or sprite sheet, but it doesn't suffer from the same tile / quad
	-- bleeding artifacts that texture atlases do – although every sub-image must have the same dimensions.
	-- A specific layer of an array image can be drawn with love.graphics.drawLayer / SpriteBatch:addLayer, or with the
	-- Quad variant of love.graphics.draw and Quad:setLayer, or via a custom Shader.
	-- To use an array image in a Shader, it must be declared as a ArrayImage or sampler2DArray type (instead of Image or
	-- sampler2D). The Texel(ArrayImage image, vec3 texturecoord) shader function must be used to get pixel colors from a
	-- slice of the array image. The vec3 argument contains the texture coordinate in the first two components, and the
	-- 0-based slice index in the third component.
	-- Overload details:
	--   1. Creates an array Image given a different image file for each slice of the resulting array image object.
	--      Illustration of how an array image works: an external illustration A DPI scale of 2 (double the normal pixel
	--      density) will result in the image taking up the same space on-screen as an image with half its pixel
	--      dimensions that has a DPI scale of 1. This allows for easily swapping out image assets that take the same
	--      space on-screen but have different pixel densities, which makes supporting high-dpi / retina resolution
	--      require less code logic. In order to use an Array Texture or other non-2D texture types as the main texture
	--      in a custom void effect() variant must be used in the pixel shader, and MainTex must be declared as an
	--      ArrayImage or sampler2DArray like so: uniform ArrayImage MainTex;.
	-- @param layers ({ImageData}) A table containing filepaths to images (or File, FileData, ImageData, or CompressedImageData objects), in an array. Each sub-image must have the same dimensions. A table of tables can also be given, where each sub-table contains all mipmap levels for the slice index of that sub-table.
	-- @param settings (LayeredImageSettings) Optional table of settings to configure the array image, containing the following fields: (Default: nil.) mipmaps: True to make the image use mipmaps, false to disable them. Mipmaps will be automatically generated if the image isn't a compressed texture format. (Default: false.) linear: True to treat the image's pixels as linear instead of sRGB, when gamma correct rendering is enabled. Most images are authored as sRGB. (Default: false.) dpiscale: The DPI scale to use when drawing the array image and calling getWidth/getHeight. (Default: 1.)
	-- @return (Image) An Array Image object.
	newArrayImage: function(layers: {ImageData}, settings?: LayeredImageSettings): Image

	-- Creates a new cubemap Image.
	-- Cubemap images have 6 faces (sides) which represent a cube. They can't be rendered directly, they can only be used
	-- in Shader code (and sent to the shader via Shader:send).
	-- To use a cubemap image in a Shader, it must be declared as a CubeImage or samplerCube type (instead of Image or
	-- sampler2D). The Texel(CubeImage image, vec3 direction) shader function must be used to get pixel colors from the
	-- cubemap. The vec3 argument is a normalized direction from the center of the cube, rather than explicit texture
	-- coordinates.
	-- Each face in a cubemap image must have square dimensions.
	-- For variants of this function which accept a single image containing multiple cubemap faces, they must be laid out
	-- in one of the following forms in the image:
	-- +y
	-- +z +x -z
	-- -y
	-- -x
	-- or:
	-- +y
	-- -x +z +x -z
	-- -y
	-- or:
	-- +x
	-- -x
	-- +y
	-- -y
	-- +z
	-- -z
	-- or:
	-- +x -x +y -y +z -z
	-- Overload details:
	--   1. Creates a cubemap Image given a single image file containing multiple cube faces.
	--   2. Creates a cubemap Image given a different image file for each cube face.
	-- @param faces ({ImageData}) A table containing 6 filepaths to images (or File, FileData, ImageData, or CompressedImageData objects), in an array. Each face image must have the same dimensions. A table of tables can also be given, where each sub-table contains all mipmap levels for the cube face index of that sub-table.
	-- @param settings (LayeredImageSettings) Optional table of settings to configure the cubemap image, containing the following fields: (Default: nil.) mipmaps: True to make the image use mipmaps, false to disable them. Mipmaps will be automatically generated if the image isn't a compressed texture format. (Default: false.) linear: True to treat the image's pixels as linear instead of sRGB, when gamma correct rendering is enabled. Most images are authored as sRGB. (Default: false.)
	-- @return (Image) An cubemap Image object.
	newCubeImage: function(faces: {ImageData}, settings?: LayeredImageSettings): Image

	-- Creates a new volume (3D) Image.
	-- Volume images are 3D textures with width, height, and depth. They can't be rendered directly, they can only be
	-- used in Shader code (and sent to the shader via Shader:send).
	-- To use a volume image in a Shader, it must be declared as a VolumeImage or sampler3D type (instead of Image or
	-- sampler2D). The Texel(VolumeImage image, vec3 texcoords) shader function must be used to get pixel colors from the
	-- volume image. The vec3 argument is a normalized texture coordinate with the z component representing the depth to
	-- sample at (ranging from 1).
	-- Volume images are typically used as lookup tables in shaders for color grading, for example, because sampling
	-- using a texture coordinate that is partway in between two pixels can interpolate across all 3 dimensions in the
	-- volume image, resulting in a smooth gradient even when a small-sized volume image is used as the lookup table.
	-- Array images are a much better choice than volume images for storing multiple different sprites in a single array
	-- image for directly drawing them.
	-- Overload details:
	--   1. Creates a volume Image given multiple image files with matching dimensions. Volume images are not supported
	--      on some older mobile devices. Use love.graphics.getTextureTypes to check at runtime.
	-- @param slices ({ImageData}) A table containing filepaths to images (or File, FileData, ImageData, or CompressedImageData objects), in an array. A table of tables can also be given, where each sub-table represents a single mipmap level and contains all layers for that mipmap.
	-- @param settings (LayeredImageSettings) Optional table of settings to configure the volume image, containing the following fields: (Default: nil.) mipmaps: True to make the image use mipmaps, false to disable them. Mipmaps will be automatically generated if the image isn't a compressed texture format. (Default: false.) linear: True to treat the image's pixels as linear instead of sRGB, when gamma correct rendering is enabled. Most images are authored as sRGB. (Default: false.)
	-- @return (Image) A volume Image object.
	newVolumeImage: function(slices: {ImageData}, settings?: LayeredImageSettings): Image

	-- Creates a new Canvas object for offscreen rendering.
	-- @return (Canvas) canvas — A new Canvas with dimensions equal to the window's size in pixels.
	newCanvas: function(): Canvas

	-- Creates a new Canvas object for offscreen rendering.
	-- @param width (integer) The desired width of the Canvas.
	-- @param height (integer) The desired height of the Canvas.
	-- @param settings (CanvasSettings) A table containing the given fields: (Default: nil.)
	-- @return (Canvas) A new Canvas with specified width and height.
	newCanvas: function(width: integer, height: integer, settings?: CanvasSettings): Canvas

	-- Gets the available Canvas formats, and whether each is supported.
	-- @param readable (boolean) If true, the returned formats will only be indicated as supported if readable flag set to true for that format, and vice versa if the parameter is false.
	-- @param formats ({string: boolean}) The formats parameter.
	-- @return ({string: boolean}) A table containing CanvasFormats as keys, and a boolean indicating whether the format is supported as values. Not all systems support all formats. Depending on the overload: A table containing CanvasFormats as keys, and a boolean indicating whether the format is supported as values (taking into account the readable parameter). Not all systems support all formats.
	getCanvasFormats: function(readable?: boolean, formats?: {string: boolean}): {string: boolean}

	-- Captures drawing operations to a Canvas.
	setCanvas: function()

	-- Captures drawing operations to a Canvas.
	-- @param canvas (Canvas) The new render target.
	-- @param canvases (Canvas...) A table specifying the active Canvas(es), their mipmap levels and active layers if applicable, and whether to use a stencil and/or depth buffer.
	setCanvas: function(canvas: Canvas, canvases: Canvas...)

	-- Captures drawing operations to a Canvas.
	-- @param canvases ({Canvas}) A table specifying the active Canvas(es), their mipmap levels and active layers if applicable, and whether to use a stencil and/or depth buffer.
	setCanvas: function(canvases: {Canvas})

	-- Captures drawing operations to a Canvas.
	-- @param setup (CanvasSetup) A table specifying the active Canvas(es), their mipmap levels and active layers if applicable, and whether to use a stencil and/or depth buffer.
	setCanvas: function(setup: CanvasSetup)

	-- Gets the current target Canvas.
	-- @return (Canvas or nil) The Canvas set by setCanvas. Returns nil if drawing to the real screen.
	getCanvas: function(): Canvas | nil

	-- Creates a new Quad.
	--
	-- The purpose of a Quad is to use a fraction of an image to draw objects, as opposed to drawing entire image. It is most useful for sprite sheets and atlases: in a sprite atlas, multiple sprites reside in same image, quad is used to draw a specific sprite from that image; in animated sprites with all frames residing in the same image, quad is used to draw specific frame from the animation.
	-- @param x (number) The top-left position in the Image along the x-axis.
	-- @param y (number) The top-left position in the Image along the y-axis.
	-- @param width (number) The width of the Quad in the Image. (Must be greater than 0.)
	-- @param height (number) The height of the Quad in the Image. (Must be greater than 0.)
	-- @param image (Image | Canvas) The texture whose width and height will be used as the reference width and height.
	-- @return (Quad) quad — The new Quad.
	newQuad: function(x: number, y: number, width: number, height: number, image: Image | Canvas): Quad

	-- Creates a new Quad.
	--
	-- The purpose of a Quad is to use a fraction of an image to draw objects, as opposed to drawing entire image. It is most useful for sprite sheets and atlases: in a sprite atlas, multiple sprites reside in same image, quad is used to draw a specific sprite from that image; in animated sprites with all frames residing in the same image, quad is used to draw specific frame from the animation.
	-- @param x (number) The top-left position in the Image along the x-axis.
	-- @param y (number) The top-left position in the Image along the y-axis.
	-- @param width (number) The width of the Quad in the Image. (Must be greater than 0.)
	-- @param height (number) The height of the Quad in the Image. (Must be greater than 0.)
	-- @param texture_width (number) The reference width, the width of the Image. (Must be greater than 0.)
	-- @param texture_height (number) The reference height, the height of the Image. (Must be greater than 0.)
	-- @return (Quad) quad — The new Quad.
	newQuad: function(x: number, y: number, width: number, height: number, texture_width: number, texture_height: number): Quad

	-- Creates a new Mesh.
	--
	-- Use Mesh:setTexture if the Mesh should be textured with an Image or Canvas when it's drawn.
	--
	-- In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param vertices ({MeshVertex} | number) The table filled with vertex information tables for each vertex as follows:
	-- @param draw_mode (MeshDrawMode) How the vertices are used when drawing. The default mode 'fan' is sufficient for simple convex polygons. (Default: 'fan'.)
	-- @param usage (MeshUsage) The expected usage of the Mesh. The specified usage mode affects the Mesh's memory usage and performance. (Default: 'dynamic'.)
	-- @return (Mesh) mesh — The new mesh.
	newMesh: function(vertices: {MeshVertex} | number, draw_mode?: MeshDrawMode, usage?: MeshUsage): Mesh

	-- Creates a new Mesh.
	--
	-- Use Mesh:setTexture if the Mesh should be textured with an Image or Canvas when it's drawn.
	--
	-- In versions prior to 11.0, color and byte component values were within the range of 0 to 255 instead of 0 to 1.
	-- @param format ({MeshVertexFormat}) A table in the form of {attribute, ...}. Each attribute is a table which specifies a custom vertex attribute used for each vertex.
	-- @param vertices ({MeshVertex} | number | Data) The table filled with vertex information tables for each vertex, in the form of {vertex, ...} where each vertex is a table in the form of {attributecomponent, ...}.
	-- @param draw_mode (MeshDrawMode) The Image or Canvas to use when drawing the Mesh. May be nil to use no texture. (Default: nil.)
	-- @param usage (MeshUsage) The expected usage of the Mesh. The specified usage mode affects the Mesh's memory usage and performance. (Default: 'dynamic'.)
	-- @return (Mesh) mesh — The new mesh.
	newMesh: function(format: {MeshVertexFormat}, vertices: {MeshVertex} | number | Data, draw_mode?: MeshDrawMode, usage?: MeshUsage): Mesh

	-- Creates a new SpriteBatch object.
	-- @param texture (Image or Canvas) The Image or Canvas to use for the sprites.
	-- @param size (integer) The maximum number of sprites that the SpriteBatch can contain at any given time. Since version 11.0, additional sprites added past this number will automatically grow the spritebatch. (Default: 1000.)
	-- @param usage (MeshUsage) The expected usage of the SpriteBatch. The specified usage mode affects the SpriteBatch's memory usage and performance. (Default: 'dynamic'.)
	-- @return (SpriteBatch) The new SpriteBatch.
	newSpriteBatch: function(texture: Image | Canvas, size?: integer, usage?: MeshUsage): SpriteBatch

	-- Creates a new ParticleSystem.
	-- @param texture (Image or Canvas) The texture (Image or Canvas) to use.
	-- @param size (integer) The max number of particles at the same time. (Default: 1000.)
	-- @return (ParticleSystem) A new ParticleSystem.
	newParticleSystem: function(texture: Image | Canvas, size?: integer): ParticleSystem

	-- Creates a new Shader object for hardware-accelerated vertex and pixel effects. A Shader contains either vertex
	-- shader code, pixel shader code, or both.
	-- Shaders are small programs which are run on the graphics card when drawing. Vertex shaders are run once for each
	-- vertex (for example, an image has 4 vertices - one at each corner. A Mesh might have many more.) Pixel shaders are
	-- run once for each pixel on the screen which the drawn object touches. Pixel shader code is executed after all the
	-- object's vertices have been processed by the vertex shader.
	-- @param source (string or FileData) The pixel shader code, or a filename pointing to a file with the code.
	-- @param pixel_source (string or FileData) The vertex shader code, or a filename pointing to a file with the code.
	-- @return (Shader) A Shader object for use in drawing operations.
	newShader: function(source: string | FileData, pixel_source?: string | FileData): Shader

	-- Validates shader code. Check if specified shader code does not contain any errors.
	-- @param gles (boolean) Validate code as GLSL ES shader.
	-- @param source (string or FileData) The pixel shader code, or a filename pointing to a file with the code.
	-- @param pixel_source (string or FileData) The vertex shader code, or a filename pointing to a file with the code.
	-- @return (boolean) true if specified shader code doesn't contain any errors. false otherwise.
	-- @return (string or nil) Reason why shader code validation failed (or nil if validation succeded).
	validateShader: function(gles: boolean, source: string | FileData, pixel_source?: string | FileData): boolean, string | nil

	-- Sets or resets a Shader as the current pixel effect or vertex shaders. All drawing operations until the next ''love.graphics.setShader'' will be drawn using the Shader object specified.
	setShader: function()

	-- Sets or resets a Shader as the current pixel effect or vertex shaders. All drawing operations until the next ''love.graphics.setShader'' will be drawn using the Shader object specified.
	-- @param shader (Shader) The new shader.
	setShader: function(shader: Shader)

	-- Gets the current Shader. Returns nil if none is set.
	-- @return (Shader or nil) The currently active Shader, or nil if none is set.
	getShader: function(): Shader | nil

	-- Draws a Drawable object (an Image, Canvas, SpriteBatch, ParticleSystem, Mesh, Text object, or Video) on the screen with optional rotation, scaling and shearing.
	--
	-- Objects are drawn relative to their local coordinate system. The origin is by default located at the top left corner of Image and Canvas. All scaling, shearing, and rotation arguments transform the object relative to that point. Also, the position of the origin can be specified on the screen coordinate system.
	--
	-- It's possible to rotate an object about its center by offsetting the origin to the center. Angles must be given in radians for rotation. One can also use a negative scaling factor to flip about its centerline.
	--
	-- Note that the offsets are applied before rotation, scaling, or shearing; scaling and shearing are applied before rotation.
	--
	-- The right and bottom edges of the object are shifted at an angle defined by the shearing factors.
	--
	-- When using the default shader anything drawn with this function will be tinted according to the currently selected color. Set it to pure white to preserve the object's original colors.
	-- @param image (Image) A drawable object.
	-- @param x (number) The position to draw the object (x-axis). (Default: 0.)
	-- @param y (number) The position to draw the object (y-axis). (Default: 0.)
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	draw: function(image: Image, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- Draws a Drawable object (an Image, Canvas, SpriteBatch, ParticleSystem, Mesh, Text object, or Video) on the screen with optional rotation, scaling and shearing.
	--
	-- Objects are drawn relative to their local coordinate system. The origin is by default located at the top left corner of Image and Canvas. All scaling, shearing, and rotation arguments transform the object relative to that point. Also, the position of the origin can be specified on the screen coordinate system.
	--
	-- It's possible to rotate an object about its center by offsetting the origin to the center. Angles must be given in radians for rotation. One can also use a negative scaling factor to flip about its centerline.
	--
	-- Note that the offsets are applied before rotation, scaling, or shearing; scaling and shearing are applied before rotation.
	--
	-- The right and bottom edges of the object are shifted at an angle defined by the shearing factors.
	--
	-- When using the default shader anything drawn with this function will be tinted according to the currently selected color. Set it to pure white to preserve the object's original colors.
	-- @param image (Image) A drawable object.
	-- @param quad (Quad) The Quad to draw on screen.
	-- @param x (number) The position to draw the object (x-axis).
	-- @param y (number) The position to draw the object (y-axis).
	-- @param angle (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_x (number) Scale factor (y-axis). (Default: sx.)
	-- @param scale_y (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_x (number) Origin offset (y-axis). (Default: 0.)
	-- @param origin_y (number) Shearing factor (x-axis). (Default: 0.)
	draw: function(image: Image, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- Draws a Canvas on the screen with optional rotation, scaling, and shearing.
	-- @param canvas (Canvas) The Canvas to draw.
	-- @param x (number) The position to draw the object on the x-axis. (Default: 0.)
	-- @param y (number) The position to draw the object on the y-axis. (Default: 0.)
	-- @param angle (number) The orientation in radians. (Default: 0.)
	-- @param scale_x (number) The scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) The scale factor on the y-axis. (Default: scaleX.)
	-- @param origin_x (number) The origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) The origin offset on the y-axis. (Default: 0.)
	draw: function(canvas: Canvas, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- Draws a Canvas on the screen with optional rotation, scaling, and shearing.
	-- @param canvas (Canvas) The Canvas to draw.
	-- @param quad (Quad) The subsection of the drawable to draw.
	-- @param x (number) The position to draw the object on the x-axis. (Default: 0.)
	-- @param y (number) The position to draw the object on the y-axis. (Default: 0.)
	-- @param angle (number) The orientation in radians. (Default: 0.)
	-- @param scale_x (number) The scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) The scale factor on the y-axis. (Default: scaleX.)
	-- @param origin_x (number) The origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) The origin offset on the y-axis. (Default: 0.)
	draw: function(canvas: Canvas, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- Draws a Mesh on the screen with optional rotation, scaling, and shearing.
	-- @param mesh (Mesh) The Mesh to draw.
	-- @param x (number) The position to draw the object on the x-axis. (Default: 0.)
	-- @param y (number) The position to draw the object on the y-axis. (Default: 0.)
	-- @param angle (number) The orientation in radians. (Default: 0.)
	-- @param scale_x (number) The scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) The scale factor on the y-axis. (Default: scaleX.)
	-- @param origin_x (number) The origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) The origin offset on the y-axis. (Default: 0.)
	-- @param shear_x (number) The shearing factor on the x-axis. (Default: 0.)
	-- @param shear_y (number) The shearing factor on the y-axis. (Default: 0.)
	draw: function(mesh: Mesh, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Draws a SpriteBatch on the screen with optional rotation, scaling, and shearing.
	-- @param batch (SpriteBatch) The SpriteBatch to draw.
	-- @param x (number) The position to draw the object on the x-axis. (Default: 0.)
	-- @param y (number) The position to draw the object on the y-axis. (Default: 0.)
	-- @param angle (number) The orientation in radians. (Default: 0.)
	-- @param scale_x (number) The scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) The scale factor on the y-axis. (Default: scaleX.)
	-- @param origin_x (number) The origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) The origin offset on the y-axis. (Default: 0.)
	-- @param shear_x (number) The shearing factor on the x-axis. (Default: 0.)
	-- @param shear_y (number) The shearing factor on the y-axis. (Default: 0.)
	draw: function(batch: SpriteBatch, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Draws a ParticleSystem on the screen with optional rotation, scaling, and shearing.
	-- @param particles (ParticleSystem) The ParticleSystem to draw.
	-- @param x (number) The position to draw the object on the x-axis. (Default: 0.)
	-- @param y (number) The position to draw the object on the y-axis. (Default: 0.)
	-- @param angle (number) The orientation in radians. (Default: 0.)
	-- @param scale_x (number) The scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) The scale factor on the y-axis. (Default: scaleX.)
	-- @param origin_x (number) The origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) The origin offset on the y-axis. (Default: 0.)
	-- @param shear_x (number) The shearing factor on the x-axis. (Default: 0.)
	-- @param shear_y (number) The shearing factor on the y-axis. (Default: 0.)
	draw: function(particles: ParticleSystem, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Draws a Text on the screen with optional rotation, scaling, and shearing.
	-- @param text (Text) The Text object to draw.
	-- @param x (number) The position to draw the object on the x-axis. (Default: 0.)
	-- @param y (number) The position to draw the object on the y-axis. (Default: 0.)
	-- @param angle (number) The orientation in radians. (Default: 0.)
	-- @param scale_x (number) The scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) The scale factor on the y-axis. (Default: scaleX.)
	-- @param origin_x (number) The origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) The origin offset on the y-axis. (Default: 0.)
	-- @param shear_x (number) The shearing factor on the x-axis. (Default: 0.)
	-- @param shear_y (number) The shearing factor on the y-axis. (Default: 0.)
	draw: function(text: Text, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Draws a Video on the screen with optional rotation, scaling, and shearing.
	-- @param video (Video) The Video to draw.
	-- @param x (number) The position to draw the object on the x-axis. (Default: 0.)
	-- @param y (number) The position to draw the object on the y-axis. (Default: 0.)
	-- @param angle (number) The orientation in radians. (Default: 0.)
	-- @param scale_x (number) The scale factor on the x-axis. (Default: 1.)
	-- @param scale_y (number) The scale factor on the y-axis. (Default: scaleX.)
	-- @param origin_x (number) The origin offset on the x-axis. (Default: 0.)
	-- @param origin_y (number) The origin offset on the y-axis. (Default: 0.)
	-- @param shear_x (number) The shearing factor on the x-axis. (Default: 0.)
	-- @param shear_y (number) The shearing factor on the y-axis. (Default: 0.)
	draw: function(video: Video, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- Draws a layer of an Table Texture.
	-- @param image (Image) The Table Texture to draw.
	-- @param layer (integer) The index of the layer to use when drawing.
	-- @param x (number) The position to draw the texture (x-axis). (Default: 0.)
	-- @param y (number) The position to draw the texture (y-axis). (Default: 0.)
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	drawLayer: function(image: Image, layer: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- Draws a layer of an Table Texture.
	-- @param image (Image) The Table Texture to draw.
	-- @param layer (integer) The index of the layer to use when drawing.
	-- @param quad (Quad) The subsection of the texture's layer to use when drawing.
	-- @param x (number) The position to draw the texture (x-axis). (Default: 0.)
	-- @param y (number) The position to draw the texture (y-axis). (Default: 0.)
	-- @param angle (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_x (number) Scale factor (y-axis). (Default: sx.)
	-- @param scale_y (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_x (number) Origin offset (y-axis). (Default: 0.)
	-- @param origin_y (number) Shearing factor (x-axis). (Default: 0.)
	drawLayer: function(image: Image, layer: integer, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- Draws many instances of a Mesh with a single draw call, using hardware geometry instancing.
	-- Each instance can have unique properties (positions, colors, etc.) but will not by default unless a custom
	-- per-instance vertex attributes or the love_InstanceID GLSL 3 vertex shader variable is used, otherwise they will
	-- all render at the same position on top of each other.
	-- Instancing is not supported by some older GPUs that are only capable of using OpenGL ES 2 or OpenGL 2. Use
	-- love.graphics.getSupported to check.
	-- @param mesh (Mesh) The mesh to render.
	-- @param instance_count (integer) The number of instances to render.
	-- @param x (number) The position to draw the instances (x-axis). (Default: 0.)
	-- @param y (number) The position to draw the instances (y-axis). (Default: 0.)
	-- @param angle (number) Orientation (radians). (Default: 0.)
	-- @param scale_x (number) Scale factor (x-axis). (Default: 1.)
	-- @param scale_y (number) Scale factor (y-axis). (Default: sx.)
	-- @param origin_x (number) Origin offset (x-axis). (Default: 0.)
	-- @param origin_y (number) Origin offset (y-axis). (Default: 0.)
	-- @param shear_x (number) Shearing factor (x-axis). (Default: 0.)
	-- @param shear_y (number) Shearing factor (y-axis). (Default: 0.)
	drawInstanced: function(mesh: Mesh, instance_count: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)
end

-- Love 11.5 root module. This file only declares the currently implemented subset.
local record Love
	embed LoveEnums

	record TouchID
		userdata
	end

	-- Provides an interface to touch-screen presses.
	record Touch

		-- Gets a list of all active touch-presses.
		-- Overload details:
		--   1. The id values are the same as those used as arguments to love.touchpressed, love.touchmoved, and
		--      love.touchreleased. The id value of a specific touch-press is only guaranteed to be unique for the duration
		--      of that touch-press. As soon as love.touchreleased is called using that id, it may be reused for a new
		--      touch-press via love.touchpressed.
		-- @return ({TouchID}) A list of active touch-press id values, which can be used with love.touch.getPosition.
		getTouches: function(): {TouchID}

		-- Gets the current position of the specified touch-press, in pixels.
		-- Overload details:
		--   1. The unofficial Android and iOS ports of LÖVE 0.9.2 reported touch-press positions as normalized values in
		--      the range of 1, whereas this API reports positions in pixels.
		-- @param id (TouchID) The identifier of the touch-press. Use love.touch.getTouches, love.touchpressed, or love.touchmoved to obtain touch id values.
		-- @return (number) The position along the x-axis of the touch-press inside the window, in pixels.
		-- @return (number) The position along the y-axis of the touch-press inside the window, in pixels.
		getPosition: function(id: TouchID): number, number

		-- Gets the current pressure of the specified touch-press.
		-- @param id (TouchID) The identifier of the touch-press. Use love.touch.getTouches, love.touchpressed, or love.touchmoved to obtain touch id values.
		-- @return (number) The pressure of the touch-press. Most touch screens aren't pressure sensitive, in which case the pressure will be 1.
		getPressure: function(id: TouchID): number
	end

	-- Represents a physical joystick.
	record Joystick

		-- Gets the type of the object as a string.
		-- @return (string) The type as a string.
		type: function(self: Joystick): string

		-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
		-- hierarchy, this function will return true.
		-- @param type_name (string) The name of the type to check for.
		-- @return (boolean) True if the object is of the specified type, false otherwise.
		typeOf: function(self: Joystick, type_name: string): boolean

		-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any other
		-- LÖVE object or thread.
		-- This method can be used to immediately clean up resources without waiting for Lua's garbage collector.
		-- @return (boolean) True if the object was released by this call, false if it had been previously released.
		release: function(self: Joystick): boolean

		-- Gets whether the Joystick is connected.
		-- @return (boolean) True if the Joystick is currently connected, false otherwise.
		isConnected: function(self: Joystick): boolean

		-- Gets the name of the joystick.
		-- @return (string) The name of the joystick.
		getName: function(self: Joystick): string

		-- Gets the joystick's unique identifier. The identifier will remain the same for the life of the game, even when
		-- the Joystick is disconnected and reconnected, but it '''will''' change when the game is re-launched.
		-- @return (integer) The Joystick's unique identifier. Remains the same as long as the game is running.
		-- @return (integer or nil) Unique instance identifier. Changes every time the Joystick is reconnected. nil if the Joystick is not connected.
		getID: function(self: Joystick): integer, integer | nil

		-- Gets a stable GUID unique to the type of the physical joystick which does not change over time. For example, all
		-- Sony Dualshock 3 controllers in OS X have the same GUID. The value is platform-dependent.
		-- @return (string) The Joystick type's OS-dependent unique identifier.
		getGUID: function(self: Joystick): string

		-- Gets the USB vendor ID, product ID, and product version numbers of joystick which consistent across operating
		-- systems.
		-- Can be used to show different icons, etc. for different gamepads.
		-- Overload details:
		--   1. Some Linux distribution may not ship with SDL 2.0.6 or later, in which case this function will returns 0 for
		--      all the three values.
		-- @return (integer) The USB vendor ID of the joystick.
		-- @return (integer) The USB product ID of the joystick.
		-- @return (integer) The product version of the joystick.
		getDeviceInfo: function(self: Joystick): integer, integer, integer

		-- Gets the number of axes on the joystick.
		-- @return (integer) The number of axes available.
		getAxisCount: function(self: Joystick): integer

		-- Gets the number of buttons on the joystick.
		-- @return (integer) The number of buttons available.
		getButtonCount: function(self: Joystick): integer

		-- Gets the number of hats on the joystick.
		-- @return (integer) How many hats the joystick has.
		getHatCount: function(self: Joystick): integer

		-- Gets the direction of an axis.
		-- @param axis (integer) The index of the axis to be checked.
		-- @return (number) Current value of the axis.
		getAxis: function(self: Joystick, axis: integer): number

		-- Gets the direction of each axis.
		-- @return (number...) Direction of axis1.
		getAxes: function(self: Joystick): number...

		-- Gets the direction of the Joystick's hat.
		-- @param hat (integer) The index of the hat to be checked.
		-- @return (JoystickHat) The direction the hat is pushed.
		getHat: function(self: Joystick, hat: integer): JoystickHat

		-- Checks if a button on the Joystick is pressed.
		-- LÖVE 0.9.0 had a bug which required the button indices passed to Joystick:isDown to be 0-based instead of
		-- 1-based, for example button 1 would be 0 for this function. It was fixed in 0.9.1.
		-- @param buttons (integer...) The index of a button to check.
		-- @return (boolean) True if any supplied button is down, false if not.
		isDown: function(self: Joystick, buttons: integer...): boolean

		-- Gets whether the Joystick is recognized as a gamepad. If this is the case, the Joystick's buttons and axes can be
		-- used in a standardized manner across different operating systems and joystick models via Joystick:getGamepadAxis,
		-- Joystick:isGamepadDown, love.gamepadpressed, and related functions.
		-- LÖVE automatically recognizes most popular controllers with a similar layout to the Xbox 360 controller as
		-- gamepads, but you can add more with love.joystick.setGamepadMapping.
		-- Overload details:
		--   1. If the Joystick is recognized as a gamepad, the physical locations for the virtual gamepad axes and buttons
		--      correspond as closely as possible to the layout of a standard Xbox 360 controller.
		-- @return (boolean) True if the Joystick is recognized as a gamepad, false otherwise.
		isGamepad: function(self: Joystick): boolean

		-- Checks if a virtual gamepad button on the Joystick is pressed. If the Joystick is not recognized as a Gamepad or
		-- isn't connected, then this function will always return false.
		-- @param buttons (GamepadButton...) The gamepad button to check.
		-- @return (boolean) True if any supplied button is down, false if not.
		isGamepadDown: function(self: Joystick, buttons: GamepadButton...): boolean

		-- Gets the direction of a virtual gamepad axis. If the Joystick isn't recognized as a gamepad or isn't connected,
		-- this function will always return 0.
		-- @param axis (GamepadAxis) The virtual axis to be checked.
		-- @return (number) Current value of the axis.
		getGamepadAxis: function(self: Joystick, axis: GamepadAxis): number

		-- Gets the button, axis or hat that a virtual gamepad input is bound to.
		-- Overload details:
		--   1. Returns nil if the Joystick isn't recognized as a gamepad or the virtual gamepad axis is not bound to a
		--      Joystick input.
		--   2. The physical locations for the virtual gamepad axes and buttons correspond as closely as possible to the
		--      layout of a standard Xbox 360 controller.
		-- @param input (GamepadAxis | GamepadButton) The virtual gamepad axis to get the binding for. Depending on the overload: The virtual gamepad button to get the binding for.
		-- @return (JoystickInputType | nil) The type of input the virtual gamepad axis is bound to. Depending on the overload: The type of input the virtual gamepad button is bound to.
		-- @return (integer or nil) The index of the Joystick's button, axis or hat that the virtual gamepad axis is bound to. Depending on the overload: The index of the Joystick's button, axis or hat that the virtual gamepad button is bound to.
		-- @return (JoystickHat | nil) The direction of the hat, if the virtual gamepad axis is bound to a hat. nil otherwise. Depending on the overload: The direction of the hat, if the virtual gamepad button is bound to a hat. nil otherwise.
		getGamepadMapping: function(self: Joystick, input: GamepadAxis | GamepadButton): JoystickInputType | nil, integer | nil, JoystickHat | nil

		-- Gets the full gamepad mapping string of this Joystick, or nil if it's not recognized as a gamepad.
		-- The mapping string contains binding information used to map the Joystick's buttons an axes to the standard
		-- gamepad layout, and can be used later with love.joystick.loadGamepadMappings.
		-- @return (string or nil) A string containing the Joystick's gamepad mappings, or nil if the Joystick is not recognized as a gamepad.
		getGamepadMappingString: function(self: Joystick): string | nil

		-- Gets whether the Joystick supports vibration.
		-- Overload details:
		--   1. The very first call to this function may take more time than expected because SDL's Haptic / Force Feedback
		--      subsystem needs to be initialized.
		-- @return (boolean) True if rumble / force feedback vibration is supported on this Joystick, false if not.
		isVibrationSupported: function(self: Joystick): boolean

	-- Sets the vibration motor speeds on a Joystick with rumble support. Most common gamepads have this functionality, although not all drivers give proper support. Use Joystick:isVibrationSupported to check.
	-- @return (boolean) success — True if the vibration was successfully applied, false if not.
	setVibration: function(self: Joystick): boolean

	-- Sets the vibration motor speeds on a Joystick with rumble support. Most common gamepads have this functionality, although not all drivers give proper support. Use Joystick:isVibrationSupported to check.
	-- @param left (number) Strength of the left vibration motor on the Joystick. Must be in the range of 1.
	-- @param right (number) Strength of the right vibration motor on the Joystick. Must be in the range of 1.
	-- @param duration (number) The duration of the vibration in seconds. A negative value means infinite duration. (Default: -1.)
	-- @return (boolean) True if the vibration was successfully disabled, false if not.
	setVibration: function(self: Joystick, left: number, right?: number, duration?: number): boolean

		-- Gets the current vibration motor strengths on a Joystick with rumble support.
		-- @return (number or integer or nil) Current strength of the left vibration motor on the Joystick.
		-- @return (number) Current strength of the right vibration motor on the Joystick.
		getVibration: function(self: Joystick): number, number
		getConnectedIndex: function(self: Joystick): integer | nil
	end

	-- Provides an interface to the user's joystick.
	record JoystickModule

		-- Gets a list of connected Joysticks.
		-- @return ({Joystick}) The list of currently connected Joysticks.
		getJoysticks: function(): {Joystick}

		-- Gets the number of connected joysticks.
		-- @return (integer) The number of connected joysticks.
		getJoystickCount: function(): integer

	-- Binds a virtual gamepad input to a button, axis or hat for all Joysticks of a certain type. For example, if this function is used with a GUID returned by a Dualshock 3 controller in OS X, the binding will affect Joystick:getGamepadAxis and Joystick:isGamepadDown for ''all'' Dualshock 3 controllers used with the game when run in OS X.
	--
	-- LÖVE includes built-in gamepad bindings for many common controllers. This function lets you change the bindings or add new ones for types of Joysticks which aren't recognized as gamepads by default.
	--
	-- The virtual gamepad buttons and axes are designed around the Xbox 360 controller layout.
	-- @param guid (string) The OS-dependent GUID for the type of Joystick the binding will affect.
	-- @param input (GamepadAxis | GamepadButton) The virtual gamepad button to bind.
	-- @param type (JoystickInputType) The type of input to bind the virtual gamepad button to.
	-- @param index (integer) The index of the axis, button, or hat to bind the virtual gamepad button to.
	-- @return (boolean) success — Whether the virtual gamepad button was successfully bound.
	setGamepadMapping: function(guid: string, input: GamepadAxis | GamepadButton, type: JoystickInputType, index: integer): boolean

	-- Binds a virtual gamepad input to a button, axis or hat for all Joysticks of a certain type. For example, if this function is used with a GUID returned by a Dualshock 3 controller in OS X, the binding will affect Joystick:getGamepadAxis and Joystick:isGamepadDown for ''all'' Dualshock 3 controllers used with the game when run in OS X.
	--
	-- LÖVE includes built-in gamepad bindings for many common controllers. This function lets you change the bindings or add new ones for types of Joysticks which aren't recognized as gamepads by default.
	--
	-- The virtual gamepad buttons and axes are designed around the Xbox 360 controller layout.
	-- @param guid (string) The OS-dependent GUID for the type of Joystick the binding will affect.
	-- @param input (GamepadAxis | GamepadButton) The virtual gamepad axis to bind.
	-- @param type (JoystickInputType) The type of input to bind the virtual gamepad axis to.
	-- @param index (integer) The index of the axis, button, or hat to bind the virtual gamepad axis to.
	-- @param direction (JoystickHat) The direction of the hat, if the virtual gamepad axis will be bound to a hat. nil otherwise. (Default: nil.)
	-- @return (boolean) Whether the virtual gamepad axis was successfully bound.
	setGamepadMapping: function(guid: string, input: GamepadAxis | GamepadButton, type: JoystickInputType, index: integer, direction: JoystickHat): boolean

		-- Loads a gamepad mappings string or file created with love.joystick.saveGamepadMappings.
		-- It also recognizes any SDL gamecontroller mapping string, such as those created with Steam's Big Picture
		-- controller configure interface, or this nice database. If a new mapping is loaded for an already known controller
		-- GUID, the later version will overwrite the one currently loaded.
		-- Overload details:
		--   1. Loads a gamepad mappings string from a file.
		--   2. Loads a gamepad mappings string directly.
		-- @param mappings_or_filename (string) The filename to load the mappings string from. Depending on the overload: The mappings string to load.
		loadGamepadMappings: function(mappings_or_filename: string)

	-- Saves the virtual gamepad mappings of all recognized as gamepads and have either been recently used or their gamepad bindings have been modified.
	--
	-- The mappings are stored as a string for use with love.joystick.loadGamepadMappings.
	-- @return (string) mappings — The mappings string that was written to the file.
	saveGamepadMappings: function(): string

	-- Saves the virtual gamepad mappings of all recognized as gamepads and have either been recently used or their gamepad bindings have been modified.
	--
	-- The mappings are stored as a string for use with love.joystick.loadGamepadMappings.
	-- @param filename (string) The filename to save the mappings string to.
	-- @return (string) The mappings string.
	saveGamepadMappings: function(filename: string): string

		-- Gets the full gamepad mapping string of the Joysticks which have the given GUID, or nil if the GUID isn't
		-- recognized as a gamepad.
		-- The mapping string contains binding information used to map the Joystick's buttons an axes to the standard
		-- gamepad layout, and can be used later with love.joystick.loadGamepadMappings.
		-- @param guid (string) The GUID value to get the mapping string for.
		-- @return (string or nil) A string containing the Joystick's gamepad mappings, or nil if the GUID is not recognized as a gamepad.
		getGamepadMappingString: function(guid: string): string | nil
	end
	_version: string
	_version_major: integer
	_version_minor: integer
	_version_revision: integer
	graphics: Graphics
	image: ImageModule
	font: FontModule
	sound: SoundModule
	data: DataModule
	math: MathModule
	window: Window
	event: Event
	filesystem: Filesystem
	keyboard: Keyboard
	mouse: Mouse
	touch: Touch
	joystick: JoystickModule
	timer: Timer
	system: System
	["thread"]: ThreadModule
	audio: Audio
	video: VideoModule
	physics: Physics

	-- If a file called conf.lua is present in your game folder (or .love file), it is run before the LÖVE modules are
	-- loaded. You can use this file to overwrite the love.conf function, which is later called by the LÖVE 'boot'
	-- script. Using the love.conf function, you can set some configuration options, and change things like the default
	-- size of the window, which modules are loaded, and other stuff.
	-- @param config (Config) The love.conf function takes one argument: a table filled with all the default values which you can overwrite to your liking. If you want to change the default window size, for instance, do: function love.conf(t) t.window.width = 1024 t.window.height = 768 end If you don't need the physics module or joystick module, do the following. function love.conf(t) t.modules.joystick = false t.modules.physics = false end Setting unused modules to false is encouraged when you release your game. It reduces startup time slightly (especially if the joystick module is disabled) and reduces memory usage (slightly). Note that you can't disable love.filesystem; it's mandatory. The same goes for the love module itself. love.graphics needs love.window to be enabled. identity: This flag determines the name of the save directory for your game. Note that you can only specify the name, not the location where it will be created: t.identity = "gabe_HL3" -- Correct t.identity = "c:/Users/gabe/HL3" -- Incorrect Alternatively love.filesystem.setIdentity can be used to set the save directory outside of the config file. (Default: nil.) appendidentity: This flag determines if game directory should be searched first then save directory (true) or otherwise (false) (Default: false.) version: t.version should be a string, representing the version of LÖVE for which your game was made. It should be formatted as "X.Y.Z" where X is the major release number, Y the minor, and Z the patch level. It allows LÖVE to display a warning if it isn't compatible. Its default is the version of LÖVE running. (Default: "11.5".) console: Determines whether a console should be opened alongside the game window (Windows only) or not. accelerometerjoystick: Sets whether the device accelerometer on iOS and Android should be exposed as a 3-axis Joystick. Disabling the accelerometer when it's not used may reduce CPU usage. (Default: true.) externalstorage: Sets whether files are saved in external storage (true) or internal storage (false) on Android. (Default: false.) gammacorrect: Determines whether gamma-correct rendering is enabled, when the system supports it. (Default: false.) audio: Audio options. audio.mic: Request microphone permission from the user. When user allows it, love.audio.getRecordingDevices will lists recording devices available. Otherwise, love.audio.getRecordingDevices returns empty table and a message is shown to inform user when called. (Default: false.) audio.mixwithsystem: Sets whether background audio / music from other apps should play while LÖVE is open. See love.system.hasBackgroundMusic for more details. (Default: true.) window: It is possible to defer window creation until love.window.setMode is first called in your code. To do so, set t.window = nil in love.conf (or t.screen = nil in older versions.) If this is done, LÖVE may crash if any function from love.graphics is called before the first love.window.setMode in your code. The t.window table was named t.screen in versions prior to 0.9.0. The t.screen table doesn't exist in love.conf in 0.9.0, and the t.window table doesn't exist in love.conf in 0.8.0. This means love.conf will fail to execute (therefore it will fall back to default values) if care is not taken to use the correct table for the LÖVE version being used. window.title: Sets the title of the window the game is in. Alternatively love.window.setTitle can be used to change the window title outside of the config file. (Default: "Untitled".) window.icon: A filepath to an image to use as the window's icon. Not all operating systems support very large icon images. The icon can also be changed with love.window.setIcon. (Default: nil.) window.width: Sets the window's dimensions. If these flags are set to 0 LÖVE automatically uses the user's desktop dimensions. (Default: 800.) window.height: Sets the window's dimensions. If these flags are set to 0 LÖVE automatically uses the user's desktop dimensions. (Default: 600.) window.borderless: Removes all border visuals from the window. Note that the effects may wary between operating systems. (Default: false.) window.resizable: If set to true this allows the user to resize the game's window. (Default: false.) window.minwidth: Sets the minimum width and height for the game's window if it can be resized by the user. If you set lower values to window.width and window.height LÖVE will always favor the minimum dimensions set via window.minwidth and window.minheight. (Default: 1.) window.minheight: Sets the minimum width and height for the game's window if it can be resized by the user. If you set lower values to window.width and window.height LÖVE will always favor the minimum dimensions set via window.minwidth and window.minheight. (Default: 1.) window.fullscreen: Whether to run the game in fullscreen (true) or windowed (false) mode. The fullscreen can also be toggled via love.window.setFullscreen or love.window.setMode. (Default: false.) window.fullscreentype: Specifies the type of fullscreen mode to use (normal or desktop). Generally the desktop is recommended, as it is less restrictive than normal mode on some operating systems. (Default: "desktop".) window.usedpiscale: Sets whetever to enable or disable automatic DPI scaling. (Default: true.) window.vsync: Enables or deactivates vertical synchronization. Vsync tries to keep the game at a steady framerate and can prevent issues like screen tearing. It is recommended to keep vsync activated if you don't know about the possible implications of turning it off. Before LÖVE 11.0, this value was boolean (true or false). Since LÖVE 11.0, this value is number (1 to enable vsync, 0 to disable vsync, -1 to use adaptive vsync when supported). Note that in iOS, vertical synchronization is always enabled and cannot be changed. (Default: true.) window.depth: The number of bits per sample in the depth buffer (16/24/32, default nil) (Default: nil.) window.stencil: Then number of bits per sample in the depth buffer (generally 8, default nil) (Default: nil.) window.msaa: The number of samples to use with multi-sampled antialiasing. (Default: 0.) window.display: The index of the display to show the window in, if multiple monitors are available. (Default: 1.) window.highdpi: See love.window.getPixelScale, love.window.toPixels, and love.window.fromPixels. It is recommended to keep this option disabled if you can't test your game on a Mac or iOS system with a Retina display, because code will need tweaking to make sure things look correct. (Default: false.) window.x: Determines the position of the window on the user's screen. Alternatively love.window.setPosition can be used to change the position on the fly. (Default: nil.) window.y: Determines the position of the window on the user's screen. Alternatively love.window.setPosition can be used to change the position on the fly. (Default: nil.) modules: Module options. modules.audio: Enable the audio module. (Default: true.) modules.event: Enable the event module. (Default: true.) modules.graphics: Enable the graphics module. (Default: true.) modules.image: Enable the image module. (Default: true.) modules.joystick: Enable the joystick module. (Default: true.) modules.keyboard: Enable the keyboard module. (Default: true.) modules.math: Enable the math module. (Default: true.) modules.mouse: Enable the mouse module. (Default: true.) modules.physics: Enable the physics module. (Default: true.) modules.sound: Enable the sound module. (Default: true.) modules.system: Enable the system module. (Default: true.) modules.timer: Enable the timer module. (Default: true.) modules.touch: Enable the touch module. (Default: true.) modules.video: Enable the video module. (Default: true.) modules.window: Enable the window module. (Default: true.) modules.thread: Enable the thread module. (Default: true.)
	conf: function(config: Config) | nil

	-- This function is called exactly once at the beginning of the game.
	-- Overload details:
	--   1. In LÖVE 11.0, the passed arguments excludes the game name and the fused command-line flag (if exist) when
	--      runs from non-fused LÖVE executable. Previous version pass the argument as-is without any filtering.
	load: function() | nil

	-- Callback function used to update the state of the game every frame.
	-- @param deltaTime (number) Time since the last update in seconds.
	update: function(deltaTime: number) | nil

	-- Callback function used to draw on the screen every frame.
	draw: function() | nil

	-- Callback function triggered when the game is closed.
	quit: QuitCallback | nil

	-- Callback function triggered when a key is pressed.
	-- Overload details:
	--   1. Scancodes are keyboard layout-independent, so the scancode 'w' will be generated if the key in the same place
	--      as the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's
	--      operating system settings are. Key repeat needs to be enabled with love.keyboard.setKeyRepeat for repeat
	--      keypress events to be received. This does not affect love.textinput.
	--   2. Key repeat needs to be enabled with love.keyboard.setKeyRepeat for repeat keypress events to be received.
	-- @param key (string) Character of the pressed key. Depending on the overload: Character of the key pressed.
	-- @param scancode (string) The scancode representing the pressed key.
	-- @param is_repeat (boolean) Whether this keypress event is a repeat. The delay between key repeats depends on the user's system settings.
	keypressed: function(key: string, scancode: string, is_repeat: boolean) | nil

	-- Callback function triggered when a keyboard key is released.
	-- Overload details:
	--   1. Scancodes are keyboard layout-independent, so the scancode 'w' will be used if the key in the same place as
	--      the 'w' key on an American keyboard is pressed, no matter what the key is labelled or what the user's
	--      operating system settings are.
	-- @param key (string) Character of the released key.
	-- @param scancode (string) The scancode representing the released key.
	keyreleased: function(key: string, scancode: string) | nil

	-- Called when text has been entered by the user. For example if shift-2 is pressed on an American keyboard layout,
	-- the text '@' will be generated.
	-- Overload details:
	--   1. Although Lua strings can store UTF-8 encoded unicode text just fine, many functions in Lua's string library
	--      will not treat the text as you might expect. For example, #text (and string.len(text)) will give the number
	--      of ''bytes'' in the string, rather than the number of unicode characters. The Lua wiki and a presentation by
	--      one of Lua's creators give more in-depth explanations, with some tips. The utf8 library can be used to
	--      operate on UTF-8 encoded unicode text (such as the text argument given in this function.) On Android and iOS,
	--      textinput is disabled by default; call love.keyboard.setTextInput to enable it.
	-- @param text (string) The UTF-8 encoded unicode text.
	textinput: function(text: string) | nil

	-- Called when the candidate text for an IME (Input Method Editor) has changed.
	-- The candidate text is not the final text that the user will eventually choose. Use love.textinput for that.
	-- @param text (string) The UTF-8 encoded unicode candidate text.
	-- @param start (integer) The start cursor of the selected candidate text.
	-- @param length (integer) The length of the selected candidate text. May be 0.
	textedited: function(text: string, start: integer, length: integer) | nil

	-- Callback function triggered when a mouse button is pressed.
	-- Overload details:
	--   1. Use love.wheelmoved to detect mouse wheel motion. It will not register as a button press in version 0.10.0
	--      and newer.
	-- @param x (number) Mouse x position, in pixels.
	-- @param y (number) Mouse y position, in pixels.
	-- @param button (integer) The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
	-- @param is_touch (boolean) True if the mouse button press originated from a touchscreen touch-press.
	-- @param presses (integer) The number of presses in a short time frame and small area, used to simulate double, triple clicks
	mousepressed: function(x: number, y: number, button: integer, is_touch: boolean, presses: integer) | nil

	-- Callback function triggered when a mouse button is released.
	-- @param x (number) Mouse x position, in pixels.
	-- @param y (number) Mouse y position, in pixels.
	-- @param button (integer) The button index that was released. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent.
	-- @param is_touch (boolean) True if the mouse button release originated from a touchscreen touch-release.
	-- @param presses (integer) The number of presses in a short time frame and small area, used to simulate double, triple clicks
	mousereleased: function(x: number, y: number, button: integer, is_touch: boolean, presses: integer) | nil

	-- Callback function triggered when the mouse is moved.
	-- Overload details:
	--   1. If Relative Mode is enabled for the mouse, the '''dx''' and '''dy''' arguments of this callback will update
	--      but '''x''' and '''y''' are not guaranteed to.
	-- @param x (number) The mouse position on the x-axis.
	-- @param y (number) The mouse position on the y-axis.
	-- @param delta_x (number) The amount moved along the x-axis since the last time love.mousemoved was called.
	-- @param delta_y (number) The amount moved along the y-axis since the last time love.mousemoved was called.
	-- @param is_touch (boolean) True if the mouse button press originated from a touchscreen touch-press.
	mousemoved: function(x: number, y: number, delta_x: number, delta_y: number, is_touch: boolean) | nil

	-- Callback function triggered when the mouse wheel is moved.
	-- @param x (number) Amount of horizontal mouse wheel movement. Positive values indicate movement to the right.
	-- @param y (number) Amount of vertical mouse wheel movement. Positive values indicate upward movement.
	wheelmoved: function(x: number, y: number) | nil

	-- Callback function triggered when the touch screen is touched.
	-- Overload details:
	--   1. The identifier is only guaranteed to be unique for the specific touch press until love.touchreleased is
	--      called with that identifier, at which point it may be reused for new touch presses. The unofficial Android
	--      and iOS ports of LÖVE 0.9.2 reported touch positions as normalized values in the range of 1, whereas this API
	--      reports positions in pixels.
	-- @param id (TouchID) The identifier for the touch press.
	-- @param x (number) The x-axis position of the touch press inside the window, in pixels.
	-- @param y (number) The y-axis position of the touch press inside the window, in pixels.
	-- @param delta_x (number) The x-axis movement of the touch press inside the window, in pixels. This should always be zero.
	-- @param delta_y (number) The y-axis movement of the touch press inside the window, in pixels. This should always be zero.
	-- @param pressure (number) The amount of pressure being applied. Most touch screens aren't pressure sensitive, in which case the pressure will be 1.
	touchpressed: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil

	-- Callback function triggered when the touch screen stops being touched.
	-- Overload details:
	--   1. The identifier is only guaranteed to be unique for the specific touch press until love.touchreleased is
	--      called with that identifier, at which point it may be reused for new touch presses. The unofficial Android
	--      and iOS ports of LÖVE 0.9.2 reported touch positions as normalized values in the range of 1, whereas this API
	--      reports positions in pixels.
	-- @param id (TouchID) The identifier for the touch press.
	-- @param x (number) The x-axis position of the touch inside the window, in pixels.
	-- @param y (number) The y-axis position of the touch inside the window, in pixels.
	-- @param delta_x (number) The x-axis movement of the touch inside the window, in pixels.
	-- @param delta_y (number) The y-axis movement of the touch inside the window, in pixels.
	-- @param pressure (number) The amount of pressure being applied. Most touch screens aren't pressure sensitive, in which case the pressure will be 1.
	touchreleased: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil

	-- Callback function triggered when a touch press moves inside the touch screen.
	-- Overload details:
	--   1. The identifier is only guaranteed to be unique for the specific touch press until love.touchreleased is
	--      called with that identifier, at which point it may be reused for new touch presses. The unofficial Android
	--      and iOS ports of LÖVE 0.9.2 reported touch positions as normalized values in the range of 1, whereas this API
	--      reports positions in pixels.
	-- @param id (TouchID) The identifier for the touch press.
	-- @param x (number) The x-axis position of the touch inside the window, in pixels.
	-- @param y (number) The y-axis position of the touch inside the window, in pixels.
	-- @param delta_x (number) The x-axis movement of the touch inside the window, in pixels.
	-- @param delta_y (number) The y-axis movement of the touch inside the window, in pixels.
	-- @param pressure (number) The amount of pressure being applied. Most touch screens aren't pressure sensitive, in which case the pressure will be 1.
	touchmoved: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil

	-- Callback function triggered when a Thread encounters an error.
	-- @param thread (Thread) The thread which produced the error.
	-- @param error (string) The error message.
	threaderror: function(thread: Thread, error: string) | nil

	-- Called when a Joystick is connected.
	-- Overload details:
	--   1. This callback is also triggered after love.load for every Joystick which was already connected when the game
	--      started up.
	-- @param joystick (Joystick) The newly connected Joystick object.
	joystickadded: function(joystick: Joystick) | nil

	-- Called when a Joystick is disconnected.
	-- @param joystick (Joystick) The now-disconnected Joystick object.
	joystickremoved: function(joystick: Joystick) | nil

	-- Called when a joystick button is pressed.
	-- @param joystick (Joystick) The joystick object.
	-- @param button (integer) The button number.
	joystickpressed: function(joystick: Joystick, button: integer) | nil

	-- Called when a joystick button is released.
	-- @param joystick (Joystick) The joystick object.
	-- @param button (integer) The button number.
	joystickreleased: function(joystick: Joystick, button: integer) | nil

	-- Called when a joystick axis moves.
	-- @param joystick (Joystick) The joystick object.
	-- @param axis (integer) The axis number.
	-- @param value (number) The new axis value.
	joystickaxis: function(joystick: Joystick, axis: integer, value: number) | nil

	-- Called when a joystick hat direction changes.
	-- @param joystick (Joystick) The joystick object.
	-- @param hat (integer) The hat number.
	-- @param direction (string) The new hat direction.
	joystickhat: function(joystick: Joystick, hat: integer, direction: string) | nil

	-- Called when a Joystick's virtual gamepad button is pressed.
	-- @param joystick (Joystick) The joystick object.
	-- @param button (string) The virtual gamepad button.
	gamepadpressed: function(joystick: Joystick, button: string) | nil

	-- Called when a Joystick's virtual gamepad button is released.
	-- @param joystick (Joystick) The joystick object.
	-- @param button (string) The virtual gamepad button.
	gamepadreleased: function(joystick: Joystick, button: string) | nil

	-- Called when a Joystick's virtual gamepad axis is moved.
	-- @param joystick (Joystick) The joystick object.
	-- @param axis (string) The virtual gamepad axis.
	-- @param value (number) The new axis value.
	gamepadaxis: function(joystick: Joystick, axis: string, value: number) | nil

	-- Compatibility entry point; Dora remains the application loop owner.
	-- The main function, containing the main loop. A sensible default is used when left out.
	run: function()
end

local love: Love
return love

-- LÖVE 11.5 API documentation, including parameter and return value descriptions, is adapted from the
-- official LÖVE Wiki. Copyright © 2006-2010 LÖVE Development Team. Documentation is redistributed under
-- the FreeBSD Documentation License. Dora-specific compatibility notes remain explicitly marked as such.
