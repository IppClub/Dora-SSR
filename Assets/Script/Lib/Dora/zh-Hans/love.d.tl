-- Drawable image type.
-- See: https://love2d.org/wiki/Image
local record Image
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Image): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Image): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Image, type_name: string): boolean
	-- Gets the width of the Texture.
	-- See: https://love2d.org/wiki/Texture:getWidth
	getWidth: function(self: Image): number
	-- Gets the height of the Texture.
	-- See: https://love2d.org/wiki/Texture:getHeight
	getHeight: function(self: Image): number
	-- Gets the width and height of the Texture.
	-- See: https://love2d.org/wiki/Texture:getDimensions
	getDimensions: function(self: Image): number, number
	-- Gets the width in pixels of the Texture.
	-- See: https://love2d.org/wiki/Texture:getPixelWidth
	getPixelWidth: function(self: Image): integer
	-- Gets the height in pixels of the Texture.
	-- See: https://love2d.org/wiki/Texture:getPixelHeight
	getPixelHeight: function(self: Image): integer
	-- Gets the width and height in pixels of the Texture.
	-- See: https://love2d.org/wiki/Texture:getPixelDimensions
	getPixelDimensions: function(self: Image): integer, integer
	-- Gets the DPI scale factor of the Texture.
	-- See: https://love2d.org/wiki/Texture:getDPIScale
	getDPIScale: function(self: Image): number
	-- Gets the type of the Texture.
	-- See: https://love2d.org/wiki/Texture:getTextureType
	getTextureType: function(self: Image): string
	-- Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.
	-- See: https://love2d.org/wiki/Texture:getDepth
	getDepth: function(self: Image): integer
	-- Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.
	-- See: https://love2d.org/wiki/Texture:getLayerCount
	getLayerCount: function(self: Image): integer
	-- Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will
	-- return 1.
	-- See: https://love2d.org/wiki/Texture:getMipmapCount
	getMipmapCount: function(self: Image): integer
	-- Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
	-- See: https://love2d.org/wiki/Texture:getMipmapFilter
	getMipmapFilter: function(self: Image): string, number
	-- Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
	-- See: https://love2d.org/wiki/Texture:setMipmapFilter
	setMipmapFilter: function(self: Image, filter?: string, sharpness?: number)
	-- Gets the pixel format of the Texture.
	-- See: https://love2d.org/wiki/Texture:getFormat
	getFormat: function(self: Image): string
	-- Gets whether the Image was created from CompressedData.
	-- See: https://love2d.org/wiki/Image:isCompressed
	isCompressed: function(self: Image): boolean
	-- Gets whether the Image was created with the linear (non-gamma corrected) flag set to true.
	-- See: https://love2d.org/wiki/Image:isFormatLinear
	isFormatLinear: function(self: Image): boolean
	-- Replace the contents of an Image.
	-- See: https://love2d.org/wiki/Image:replacePixels
	replacePixels: function(self: Image, data: any, slice?: integer, mipmap?: integer, x?: integer, y?: integer, reload_mipmaps?: boolean)
	-- Gets whether the Texture can be drawn and sent to a Shader.
	-- See: https://love2d.org/wiki/Texture:isReadable
	isReadable: function(self: Image): boolean
	-- Gets the comparison mode used when sampling from a depth texture in a shader.
	-- See: https://love2d.org/wiki/Texture:getDepthSampleMode
	getDepthSampleMode: function(self: Image): string | nil
	-- Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison
	-- modes are advanced low-level functionality typically used with shadow mapping in 3D.
	-- See: https://love2d.org/wiki/Texture:setDepthSampleMode
	setDepthSampleMode: function(self: Image, mode?: string)
	-- Sets the filter mode of the Texture.
	-- See: https://love2d.org/wiki/Texture:setFilter
	setFilter: function(self: Image, min_filter: string, mag_filter?: string, anisotropy?: number)
	-- Gets the filter mode of the Texture.
	-- See: https://love2d.org/wiki/Texture:getFilter
	getFilter: function(self: Image): string, string, number
	-- Sets the wrapping properties of a Texture.
	-- See: https://love2d.org/wiki/Texture:setWrap
	setWrap: function(self: Image, horizontal: string, vertical?: string, depth?: string): boolean
	-- Gets the wrapping properties of a Texture.
	-- See: https://love2d.org/wiki/Texture:getWrap
	getWrap: function(self: Image): string, string, string
end

-- An object which decodes, streams, and controls Videos.
-- See: https://love2d.org/wiki/VideoStream
local record VideoStream
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: VideoStream): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: VideoStream): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: VideoStream, type_name: string): boolean
	-- Plays the VideoStream.
	-- See: https://love2d.org/wiki/VideoStream:play
	play: function(self: VideoStream)
	-- Pauses the VideoStream.
	-- See: https://love2d.org/wiki/VideoStream:pause
	pause: function(self: VideoStream)
	-- Sets the current playback position of the VideoStream.
	-- See: https://love2d.org/wiki/VideoStream:seek
	seek: function(self: VideoStream, seconds: number)
	-- Rewinds the VideoStream. Synonym to VideoStream:seek(0).
	-- See: https://love2d.org/wiki/VideoStream:rewind
	rewind: function(self: VideoStream)
	-- Gets the current playback position of the VideoStream.
	-- See: https://love2d.org/wiki/VideoStream:tell
	tell: function(self: VideoStream): number
	-- Gets whether the VideoStream is playing.
	-- See: https://love2d.org/wiki/VideoStream:isPlaying
	isPlaying: function(self: VideoStream): boolean
	-- Gets the filename of the VideoStream.
	-- See: https://love2d.org/wiki/VideoStream:getFilename
	getFilename: function(self: VideoStream): string
	setSync: function(self: VideoStream, source?: Source)
end

local record Video
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Video): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Video): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Video, type_name: string): boolean
	-- Gets the VideoStream object used for decoding and controlling the video.
	-- See: https://love2d.org/wiki/Video:getStream
	getStream: function(self: Video): VideoStream
	-- Gets the audio Source used for playing back the video's audio. May return nil if the video has no audio, or
	-- if Video:setSource is called with a nil argument.
	-- See: https://love2d.org/wiki/Video:getSource
	getSource: function(self: Video): Source | nil
	-- Sets the audio Source used for playing back the video's audio. The audio Source also controls playback
	-- speed and synchronization.
	-- See: https://love2d.org/wiki/Video:setSource
	setSource: function(self: Video, source?: Source)
	-- Gets the width of the Video in pixels.
	-- See: https://love2d.org/wiki/Video:getWidth
	getWidth: function(self: Video): integer
	-- Gets the height of the Video in pixels.
	-- See: https://love2d.org/wiki/Video:getHeight
	getHeight: function(self: Video): integer
	-- Gets the width and height of the Video in pixels.
	-- See: https://love2d.org/wiki/Video:getDimensions
	getDimensions: function(self: Video): integer, integer
	getPixelWidth: function(self: Video): integer
	getPixelHeight: function(self: Video): integer
	getPixelDimensions: function(self: Video): integer, integer
	-- Sets the scaling filters used when drawing the Video.
	-- See: https://love2d.org/wiki/Video:setFilter
	setFilter: function(self: Video, min_filter: string, mag_filter?: string, anisotropy?: number)
	-- Gets the scaling filters used when drawing the Video.
	-- See: https://love2d.org/wiki/Video:getFilter
	getFilter: function(self: Video): string, string, number
end

-- This module is responsible for decoding, controlling, and streaming video files.
-- See: https://love2d.org/wiki/love.video
local record VideoModule
	-- Creates a new VideoStream. Currently only Ogg Theora video files are supported. VideoStreams can't draw
	-- videos, see love.graphics.newVideo for that.
	-- See: https://love2d.org/wiki/love.video.newVideoStream
	newVideoStream: function(filename: string): VideoStream
end

-- A Canvas is used for off-screen rendering. Think of it as an invisible screen that you can draw to, but
-- that will not be visible until you draw it to the actual visible screen. It is also known as "render to
-- texture".
-- See: https://love2d.org/wiki/Canvas
local record Canvas
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Canvas): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Canvas): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Canvas, type_name: string): boolean
	-- Gets the width of the Texture.
	-- See: https://love2d.org/wiki/Texture:getWidth
	getWidth: function(self: Canvas): integer
	-- Gets the height of the Texture.
	-- See: https://love2d.org/wiki/Texture:getHeight
	getHeight: function(self: Canvas): integer
	-- Gets the width and height of the Texture.
	-- See: https://love2d.org/wiki/Texture:getDimensions
	getDimensions: function(self: Canvas): integer, integer
	-- Gets the width in pixels of the Texture.
	-- See: https://love2d.org/wiki/Texture:getPixelWidth
	getPixelWidth: function(self: Canvas): integer
	-- Gets the height in pixels of the Texture.
	-- See: https://love2d.org/wiki/Texture:getPixelHeight
	getPixelHeight: function(self: Canvas): integer
	-- Gets the width and height in pixels of the Texture.
	-- See: https://love2d.org/wiki/Texture:getPixelDimensions
	getPixelDimensions: function(self: Canvas): integer, integer
	-- Gets the DPI scale factor of the Texture.
	-- See: https://love2d.org/wiki/Texture:getDPIScale
	getDPIScale: function(self: Canvas): number
	-- Gets the pixel format of the Texture.
	-- See: https://love2d.org/wiki/Texture:getFormat
	getFormat: function(self: Canvas): string
	-- Gets the number of multisample antialiasing (MSAA) samples used when drawing to the Canvas.
	-- See: https://love2d.org/wiki/Canvas:getMSAA
	getMSAA: function(self: Canvas): integer
	-- Gets the type of the Texture.
	-- See: https://love2d.org/wiki/Texture:getTextureType
	getTextureType: function(self: Canvas): string
	-- Gets the depth of a Volume Texture. Returns 1 for 2D, Cubemap, and Array textures.
	-- See: https://love2d.org/wiki/Texture:getDepth
	getDepth: function(self: Canvas): integer
	-- Gets the number of layers / slices in an Array Texture. Returns 1 for 2D, Cubemap, and Volume textures.
	-- See: https://love2d.org/wiki/Texture:getLayerCount
	getLayerCount: function(self: Canvas): integer
	-- Gets the number of mipmaps contained in the Texture. If the texture was not created with mipmaps, it will
	-- return 1.
	-- See: https://love2d.org/wiki/Texture:getMipmapCount
	getMipmapCount: function(self: Canvas): integer
	-- Gets the MipmapMode this Canvas was created with.
	-- See: https://love2d.org/wiki/Canvas:getMipmapMode
	getMipmapMode: function(self: Canvas): string
	-- Gets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
	-- See: https://love2d.org/wiki/Texture:getMipmapFilter
	getMipmapFilter: function(self: Canvas): string, number
	-- Sets the mipmap filter mode for a Texture. Prior to 11.0 this method only worked on Images.
	-- See: https://love2d.org/wiki/Texture:setMipmapFilter
	setMipmapFilter: function(self: Canvas, filter?: string, sharpness?: number)
	-- Gets the comparison mode used when sampling from a depth texture in a shader.
	-- See: https://love2d.org/wiki/Texture:getDepthSampleMode
	getDepthSampleMode: function(self: Canvas): string | nil
	-- Sets the comparison mode used when sampling from a depth texture in a shader. Depth texture comparison
	-- modes are advanced low-level functionality typically used with shadow mapping in 3D.
	-- See: https://love2d.org/wiki/Texture:setDepthSampleMode
	setDepthSampleMode: function(self: Canvas, mode?: string)
	-- Generates mipmaps for the Canvas, based on the contents of the highest-resolution mipmap level.
	-- See: https://love2d.org/wiki/Canvas:generateMipmaps
	generateMipmaps: function(self: Canvas)
	-- Render to the Canvas using a function.
	-- See: https://love2d.org/wiki/Canvas:renderTo
	renderTo: function(self: Canvas, callback: function())
	-- Gets whether the Texture can be drawn and sent to a Shader.
	-- See: https://love2d.org/wiki/Texture:isReadable
	isReadable: function(self: Canvas): boolean
	-- Generates ImageData from the contents of the Canvas.
	-- See: https://love2d.org/wiki/Canvas:newImageData
	newImageData: function(self: Canvas, slice?: integer, mipmap?: integer, x?: integer, y?: integer, width?: integer, height?: integer): any
	-- Sets the filter mode of the Texture.
	-- See: https://love2d.org/wiki/Texture:setFilter
	setFilter: function(self: Canvas, min_filter: string, mag_filter?: string, anisotropy?: number)
	-- Gets the filter mode of the Texture.
	-- See: https://love2d.org/wiki/Texture:getFilter
	getFilter: function(self: Canvas): string, string, number
	-- Sets the wrapping properties of a Texture.
	-- See: https://love2d.org/wiki/Texture:setWrap
	setWrap: function(self: Canvas, horizontal: string, vertical?: string, depth?: string): boolean
	-- Gets the wrapping properties of a Texture.
	-- See: https://love2d.org/wiki/Texture:getWrap
	getWrap: function(self: Canvas): string, string, string
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
-- See: https://love2d.org/wiki/Font
local record Font
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Font): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Font): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Font, type_name: string): boolean
	-- Determines the maximum width (accounting for newlines) taken by the given string.
	-- See: https://love2d.org/wiki/Font:getWidth
	getWidth: function(self: Font, text: string): number
	-- Gets the height of the Font.
	-- See: https://love2d.org/wiki/Font:getHeight
	getHeight: function(self: Font): number
	-- Gets the baseline of the Font.
	-- See: https://love2d.org/wiki/Font:getBaseline
	getBaseline: function(self: Font): number
	-- Gets the ascent of the Font.
	-- See: https://love2d.org/wiki/Font:getAscent
	getAscent: function(self: Font): number
	-- Gets the descent of the Font.
	-- See: https://love2d.org/wiki/Font:getDescent
	getDescent: function(self: Font): number
	-- Gets whether the Font can render a character or string.
	-- See: https://love2d.org/wiki/Font:hasGlyphs
	hasGlyphs: function(self: Font, text_or_codepoint: string | integer, ...: string | integer): boolean
	-- Gets the kerning between two characters in the Font.
	-- See: https://love2d.org/wiki/Font:getKerning
	getKerning: function(self: Font, left: string | integer, right: string | integer): number
	-- Sets the fallback fonts. When the Font doesn't contain a glyph, it will substitute the glyph from the next
	-- subsequent fallback Fonts. This is akin to setting a 'font stack' in Cascading Style Sheets (CSS).
	-- See: https://love2d.org/wiki/Font:setFallbacks
	setFallbacks: function(self: Font, ...: Font)
	-- Sets the line height.
	-- See: https://love2d.org/wiki/Font:setLineHeight
	setLineHeight: function(self: Font, height: number)
	-- Gets the line height.
	-- See: https://love2d.org/wiki/Font:getLineHeight
	getLineHeight: function(self: Font): number
	-- Gets the DPI scale factor of the Font.
	-- See: https://love2d.org/wiki/Font:getDPIScale
	getDPIScale: function(self: Font): number
	-- Gets the filter mode for a font.
	-- See: https://love2d.org/wiki/Font:getFilter
	getFilter: function(self: Font): string, string, number
	-- Sets the filter mode for a font.
	-- See: https://love2d.org/wiki/Font:setFilter
	setFilter: function(self: Font, min: string, mag?: string, anisotropy?: number)
	-- Gets formatting information for text, given a wrap limit.
	-- See: https://love2d.org/wiki/Font:getWrap
	getWrap: function(self: Font, text: string, wrap_limit: number): number, {string}
end

-- Drawable text.
-- See: https://love2d.org/wiki/Text
local record Text
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Text): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Text, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Text): boolean
	-- Replaces the contents of the Text object with a new unformatted string.
	-- See: https://love2d.org/wiki/Text:set
	set: function(self: Text, text: any)
	-- Replaces the contents of the Text object with a new formatted string.
	-- See: https://love2d.org/wiki/Text:setf
	setf: function(self: Text, text: any, wrap_limit: number, align: string)
	-- Adds additional colored text to the Text object at the specified position.
	-- See: https://love2d.org/wiki/Text:add
	add: function(self: Text, text: any, transform_or_x?: any, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer
	-- Adds additional formatted / colored text to the Text object at the specified position.
	-- See: https://love2d.org/wiki/Text:addf
	addf: function(self: Text, text: any, wrap_limit: number, align: string, transform_or_x?: any, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer
	-- Clears the contents of the Text object.
	-- See: https://love2d.org/wiki/Text:clear
	clear: function(self: Text)
	-- Replaces the Font used with the text.
	-- See: https://love2d.org/wiki/Text:setFont
	setFont: function(self: Text, font: Font)
	-- Gets the Font used with the Text object.
	-- See: https://love2d.org/wiki/Text:getFont
	getFont: function(self: Text): Font
	-- Gets the width of the text in pixels.
	-- See: https://love2d.org/wiki/Text:getWidth
	getWidth: function(self: Text, index?: integer): number
	-- Gets the height of the text in pixels.
	-- See: https://love2d.org/wiki/Text:getHeight
	getHeight: function(self: Text, index?: integer): number
	-- Gets the width and height of the text in pixels.
	-- See: https://love2d.org/wiki/Text:getDimensions
	getDimensions: function(self: Text, index?: integer): number, number
end

-- A quadrilateral (a polygon with four sides and four corners) with texture coordinate information.
-- See: https://love2d.org/wiki/Quad
local record Quad
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Quad): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Quad, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Quad): boolean
	-- Sets the texture coordinates according to a viewport.
	-- See: https://love2d.org/wiki/Quad:setViewport
	setViewport: function(self: Quad, x: number, y: number, width: number, height: number, texture_width?: number, texture_height?: number)
	-- Gets the current viewport of this Quad.
	-- See: https://love2d.org/wiki/Quad:getViewport
	getViewport: function(self: Quad): number, number, number, number
	-- Gets reference texture dimensions initially specified in love.graphics.newQuad.
	-- See: https://love2d.org/wiki/Quad:getTextureDimensions
	getTextureDimensions: function(self: Quad): number, number
	setLayer: function(self: Quad, layer: integer)
	getLayer: function(self: Quad): integer
end

-- A 2D polygon mesh used for drawing arbitrary textured shapes.
-- See: https://love2d.org/wiki/Mesh
local record Mesh
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Mesh): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Mesh, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Mesh): boolean
	-- Replaces a range of vertices in the Mesh with new ones. The total number of vertices in a Mesh cannot be
	-- changed after it has been created. This is often more efficient than calling Mesh:setVertex in a loop.
	-- See: https://love2d.org/wiki/Mesh:setVertices
	setVertices: function(self: Mesh, vertices_or_data: any, start_vertex?: integer, vertex_count?: integer)
	-- 第二个参数可以是顶点表，也可以是第一个数值分量。
	-- Sets the properties of a vertex in the Mesh.
	-- See: https://love2d.org/wiki/Mesh:setVertex
	setVertex: function(self: Mesh, index: integer, vertex_or_component: any, components: number...)
	-- Gets the properties of a vertex in the Mesh.
	-- See: https://love2d.org/wiki/Mesh:getVertex
	getVertex: function(self: Mesh, index: integer): any
	-- Sets the properties of a specific attribute within a vertex in the Mesh.
	-- See: https://love2d.org/wiki/Mesh:setVertexAttribute
	setVertexAttribute: function(self: Mesh, vertex_index: integer, attribute_index: integer, components: number...)
	-- Gets the properties of a specific attribute within a vertex in the Mesh.
	-- See: https://love2d.org/wiki/Mesh:getVertexAttribute
	getVertexAttribute: function(self: Mesh, vertex_index: integer, attribute_index: integer): any
	-- Gets the total number of vertices in the Mesh.
	-- See: https://love2d.org/wiki/Mesh:getVertexCount
	getVertexCount: function(self: Mesh): integer
	-- Gets the vertex format that the Mesh was created with.
	-- See: https://love2d.org/wiki/Mesh:getVertexFormat
	getVertexFormat: function(self: Mesh): {{any}}
	-- Enables or disables a specific vertex attribute in the Mesh. Vertex data from disabled attributes is not
	-- used when drawing the Mesh.
	-- See: https://love2d.org/wiki/Mesh:setAttributeEnabled
	setAttributeEnabled: function(self: Mesh, name: string, enabled: boolean)
	-- Gets whether a specific vertex attribute in the Mesh is enabled. Vertex data from disabled attributes is
	-- not used when drawing the Mesh.
	-- See: https://love2d.org/wiki/Mesh:isAttributeEnabled
	isAttributeEnabled: function(self: Mesh, name: string): boolean
	-- Attaches a vertex attribute from a different Mesh onto this Mesh, for use when drawing. This can be used to
	-- share vertex attribute data between several different Meshes.
	-- See: https://love2d.org/wiki/Mesh:attachAttribute
	attachAttribute: function(self: Mesh, name: string, mesh: Mesh, step?: string, attribute_name?: string)
	-- Removes a previously attached vertex attribute from this Mesh.
	-- See: https://love2d.org/wiki/Mesh:detachAttribute
	detachAttribute: function(self: Mesh, name: string): boolean
	-- Sets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when
	-- the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is
	-- displayed on the screen.
	-- See: https://love2d.org/wiki/Mesh:setVertexMap
	setVertexMap: function(self: Mesh, indices: any...)
	-- Gets the vertex map for the Mesh. The vertex map describes the order in which the vertices are used when
	-- the Mesh is drawn. The vertices, vertex map, and mesh draw mode work together to determine what exactly is
	-- displayed on the screen.
	-- See: https://love2d.org/wiki/Mesh:getVertexMap
	getVertexMap: function(self: Mesh): {integer} | nil
	-- Sets the texture (Image or Canvas) used when drawing the Mesh.
	-- See: https://love2d.org/wiki/Mesh:setTexture
	setTexture: function(self: Mesh, texture?: Image | Canvas)
	-- Gets the texture (Image or Canvas) used when drawing the Mesh.
	-- See: https://love2d.org/wiki/Mesh:getTexture
	getTexture: function(self: Mesh): Image | Canvas | nil
	-- Sets the mode used when drawing the Mesh.
	-- See: https://love2d.org/wiki/Mesh:setDrawMode
	setDrawMode: function(self: Mesh, mode: string)
	-- Gets the mode used when drawing the Mesh.
	-- See: https://love2d.org/wiki/Mesh:getDrawMode
	getDrawMode: function(self: Mesh): string
	-- Restricts the drawn vertices of the Mesh to a subset of the total.
	-- See: https://love2d.org/wiki/Mesh:setDrawRange
	setDrawRange: function(self: Mesh, start?: integer, count?: integer)
	-- Gets the range of vertices used when drawing the Mesh.
	-- See: https://love2d.org/wiki/Mesh:getDrawRange
	getDrawRange: function(self: Mesh): any
	-- Immediately sends all modified vertex data in the Mesh to the graphics card.
	-- See: https://love2d.org/wiki/Mesh:flush
	flush: function(self: Mesh)
end

-- Using a single image, draw any number of identical copies of the image using a single call to
-- love.graphics.draw(). This can be used, for example, to draw repeating copies of a single background image
-- with high performance.
-- See: https://love2d.org/wiki/SpriteBatch
local record SpriteBatch
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: SpriteBatch): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: SpriteBatch, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: SpriteBatch): boolean
	-- add/set accept either a Quad followed by a standard transform, or a transform directly.
	-- Adds a sprite to the batch. Sprites are drawn in the order they are added.
	-- See: https://love2d.org/wiki/SpriteBatch:add
	add: function(self: SpriteBatch, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number): integer
	-- Changes a sprite in the batch. This requires the sprite index returned by SpriteBatch:add or
	-- SpriteBatch:addLayer.
	-- See: https://love2d.org/wiki/SpriteBatch:set
	set: function(self: SpriteBatch, index: integer, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number)
	-- Adds a sprite to a batch created with an Array Texture.
	-- See: https://love2d.org/wiki/SpriteBatch:addLayer
	addLayer: function(self: SpriteBatch, layer: integer, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number): integer
	-- Changes a sprite previously added with add or addLayer, in a batch created with an Array Texture.
	-- See: https://love2d.org/wiki/SpriteBatch:setLayer
	setLayer: function(self: SpriteBatch, index: integer, layer: integer, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number)
	-- Removes all sprites from the buffer.
	-- See: https://love2d.org/wiki/SpriteBatch:clear
	clear: function(self: SpriteBatch)
	-- Immediately sends all new and modified sprite data in the batch to the graphics card.
	-- See: https://love2d.org/wiki/SpriteBatch:flush
	flush: function(self: SpriteBatch)
	-- Sets the texture (Image or Canvas) used for the sprites in the batch, when drawing.
	-- See: https://love2d.org/wiki/SpriteBatch:setTexture
	setTexture: function(self: SpriteBatch, texture: Image | Canvas)
	-- Gets the texture (Image or Canvas) used by the SpriteBatch.
	-- See: https://love2d.org/wiki/SpriteBatch:getTexture
	getTexture: function(self: SpriteBatch): Image | Canvas
	-- Sets the color that will be used for the next add and set operations. Calling the function without
	-- arguments will disable all per-sprite colors for the SpriteBatch.
	-- See: https://love2d.org/wiki/SpriteBatch:setColor
	setColor: function(self: SpriteBatch, red_or_color?: number | {number}, green?: number, blue?: number, alpha?: number)
	-- Gets the color that will be used for the next add and set operations.
	-- See: https://love2d.org/wiki/SpriteBatch:getColor
	getColor: function(self: SpriteBatch): number, number, number, number
	-- Gets the number of sprites currently in the SpriteBatch.
	-- See: https://love2d.org/wiki/SpriteBatch:getCount
	getCount: function(self: SpriteBatch): integer
	-- Gets the maximum number of sprites the SpriteBatch can hold.
	-- See: https://love2d.org/wiki/SpriteBatch:getBufferSize
	getBufferSize: function(self: SpriteBatch): integer
	-- Attaches a per-vertex attribute from a Mesh onto this SpriteBatch, for use when drawing. This can be
	-- combined with a Shader to augment a SpriteBatch with per-vertex or additional per-sprite information
	-- instead of just having per-sprite colors.
	-- See: https://love2d.org/wiki/SpriteBatch:attachAttribute
	attachAttribute: function(self: SpriteBatch, name: string, mesh: Mesh)
	-- Restricts the drawn sprites in the SpriteBatch to a subset of the total.
	-- See: https://love2d.org/wiki/SpriteBatch:setDrawRange
	setDrawRange: function(self: SpriteBatch, start?: integer, count?: integer)
	getDrawRange: function(self: SpriteBatch): number, number
end

-- A ParticleSystem can be used to create particle effects like fire or smoke.
-- See: https://love2d.org/wiki/ParticleSystem
local record ParticleSystem
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: ParticleSystem): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: ParticleSystem, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: ParticleSystem): boolean
	-- Creates an identical copy of the ParticleSystem in the stopped state.
	-- See: https://love2d.org/wiki/ParticleSystem:clone
	clone: function(self: ParticleSystem): ParticleSystem
	-- Sets the texture (Image or Canvas) to be used for the particles.
	-- See: https://love2d.org/wiki/ParticleSystem:setTexture
	setTexture: function(self: ParticleSystem, texture: Image | Canvas)
	-- Gets the texture (Image or Canvas) used for the particles.
	-- See: https://love2d.org/wiki/ParticleSystem:getTexture
	getTexture: function(self: ParticleSystem): Image | Canvas
	-- Sets the size of the buffer (the max allowed amount of particles in the system).
	-- See: https://love2d.org/wiki/ParticleSystem:setBufferSize
	setBufferSize: function(self: ParticleSystem, size: integer)
	-- Gets the maximum number of particles the ParticleSystem can have at once.
	-- See: https://love2d.org/wiki/ParticleSystem:getBufferSize
	getBufferSize: function(self: ParticleSystem): integer
	-- Sets the mode to use when the ParticleSystem adds new particles.
	-- See: https://love2d.org/wiki/ParticleSystem:setInsertMode
	setInsertMode: function(self: ParticleSystem, mode: string)
	-- Gets the mode used when the ParticleSystem adds new particles.
	-- See: https://love2d.org/wiki/ParticleSystem:getInsertMode
	getInsertMode: function(self: ParticleSystem): string
	-- Sets the amount of particles emitted per second.
	-- See: https://love2d.org/wiki/ParticleSystem:setEmissionRate
	setEmissionRate: function(self: ParticleSystem, rate: number)
	-- Gets the amount of particles emitted per second.
	-- See: https://love2d.org/wiki/ParticleSystem:getEmissionRate
	getEmissionRate: function(self: ParticleSystem): number
	-- Sets how long the particle system should emit particles (if -1 then it emits particles forever).
	-- See: https://love2d.org/wiki/ParticleSystem:setEmitterLifetime
	setEmitterLifetime: function(self: ParticleSystem, lifetime: number)
	-- Gets how long the particle system will emit particles (if -1 then it emits particles forever).
	-- See: https://love2d.org/wiki/ParticleSystem:getEmitterLifetime
	getEmitterLifetime: function(self: ParticleSystem): number
	-- Sets the lifetime of the particles.
	-- See: https://love2d.org/wiki/ParticleSystem:setParticleLifetime
	setParticleLifetime: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- Gets the lifetime of the particles.
	-- See: https://love2d.org/wiki/ParticleSystem:getParticleLifetime
	getParticleLifetime: function(self: ParticleSystem): number, number
	-- Sets the position of the emitter.
	-- See: https://love2d.org/wiki/ParticleSystem:setPosition
	setPosition: function(self: ParticleSystem, x: number, y: number)
	-- Gets the position of the emitter.
	-- See: https://love2d.org/wiki/ParticleSystem:getPosition
	getPosition: function(self: ParticleSystem): number, number
	-- Moves the position of the emitter. This results in smoother particle spawning behaviour than if
	-- ParticleSystem:setPosition is used every frame.
	-- See: https://love2d.org/wiki/ParticleSystem:moveTo
	moveTo: function(self: ParticleSystem, x: number, y: number)
	-- Sets area-based spawn parameters for the particles. Newly created particles will spawn in an area around
	-- the emitter based on the parameters to this function.
	-- See: https://love2d.org/wiki/ParticleSystem:setEmissionArea
	setEmissionArea: function(self: ParticleSystem, distribution?: string, x?: number, y?: number, angle?: number, relative?: boolean)
	-- Gets the area-based spawn parameters for the particles.
	-- See: https://love2d.org/wiki/ParticleSystem:getEmissionArea
	getEmissionArea: function(self: ParticleSystem): string, number, number, number, boolean
	setAreaSpread: function(self: ParticleSystem, distribution?: string, x?: number, y?: number)
	getAreaSpread: function(self: ParticleSystem): string, number, number
	-- Sets the direction the particles will be emitted in.
	-- See: https://love2d.org/wiki/ParticleSystem:setDirection
	setDirection: function(self: ParticleSystem, direction: number)
	-- Gets the direction of the particle emitter (in radians).
	-- See: https://love2d.org/wiki/ParticleSystem:getDirection
	getDirection: function(self: ParticleSystem): number
	-- Sets the amount of spread for the system.
	-- See: https://love2d.org/wiki/ParticleSystem:setSpread
	setSpread: function(self: ParticleSystem, spread: number)
	-- Gets the amount of directional spread of the particle emitter (in radians).
	-- See: https://love2d.org/wiki/ParticleSystem:getSpread
	getSpread: function(self: ParticleSystem): number
	-- Sets the speed of the particles.
	-- See: https://love2d.org/wiki/ParticleSystem:setSpeed
	setSpeed: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- Gets the speed of the particles.
	-- See: https://love2d.org/wiki/ParticleSystem:getSpeed
	getSpeed: function(self: ParticleSystem): number, number
	-- Sets the linear acceleration (acceleration along the x and y axes) for particles.
	-- See: https://love2d.org/wiki/ParticleSystem:setLinearAcceleration
	setLinearAcceleration: function(self: ParticleSystem, xmin: number, ymin: number, xmax?: number, ymax?: number)
	-- Gets the linear acceleration (acceleration along the x and y axes) for particles.
	-- See: https://love2d.org/wiki/ParticleSystem:getLinearAcceleration
	getLinearAcceleration: function(self: ParticleSystem): number, number, number, number
	-- Set the radial acceleration (away from the emitter).
	-- See: https://love2d.org/wiki/ParticleSystem:setRadialAcceleration
	setRadialAcceleration: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- Gets the radial acceleration (away from the emitter).
	-- See: https://love2d.org/wiki/ParticleSystem:getRadialAcceleration
	getRadialAcceleration: function(self: ParticleSystem): number, number
	-- Sets the tangential acceleration (acceleration perpendicular to the particle's direction).
	-- See: https://love2d.org/wiki/ParticleSystem:setTangentialAcceleration
	setTangentialAcceleration: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- Gets the tangential acceleration (acceleration perpendicular to the particle's direction).
	-- See: https://love2d.org/wiki/ParticleSystem:getTangentialAcceleration
	getTangentialAcceleration: function(self: ParticleSystem): number, number
	-- Sets the amount of linear damping (constant deceleration) for particles.
	-- See: https://love2d.org/wiki/ParticleSystem:setLinearDamping
	setLinearDamping: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- Gets the amount of linear damping (constant deceleration) for particles.
	-- See: https://love2d.org/wiki/ParticleSystem:getLinearDamping
	getLinearDamping: function(self: ParticleSystem): number, number
	-- Sets a series of sizes by which to scale a particle sprite. 1.0 is normal size. The particle system will
	-- interpolate between each size evenly over the particle's lifetime.
	-- See: https://love2d.org/wiki/ParticleSystem:setSizes
	setSizes: function(self: ParticleSystem, sizes: number...)
	-- Gets the series of sizes by which the sprite is scaled. 1.0 is normal size. The particle system will
	-- interpolate between each size evenly over the particle's lifetime.
	-- See: https://love2d.org/wiki/ParticleSystem:getSizes
	getSizes: function(self: ParticleSystem): number...
	-- Sets the amount of size variation (0 meaning no variation and 1 meaning full variation between start and
	-- end).
	-- See: https://love2d.org/wiki/ParticleSystem:setSizeVariation
	setSizeVariation: function(self: ParticleSystem, variation: number)
	-- Gets the amount of size variation (0 meaning no variation and 1 meaning full variation between start and
	-- end).
	-- See: https://love2d.org/wiki/ParticleSystem:getSizeVariation
	getSizeVariation: function(self: ParticleSystem): number
	-- Sets the rotation of the image upon particle creation (in radians).
	-- See: https://love2d.org/wiki/ParticleSystem:setRotation
	setRotation: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- Gets the rotation of the image upon particle creation (in radians).
	-- See: https://love2d.org/wiki/ParticleSystem:getRotation
	getRotation: function(self: ParticleSystem): number, number
	-- Sets the spin of the sprite.
	-- See: https://love2d.org/wiki/ParticleSystem:setSpin
	setSpin: function(self: ParticleSystem, start: number, finish?: number)
	-- Gets the spin of the sprite.
	-- See: https://love2d.org/wiki/ParticleSystem:getSpin
	getSpin: function(self: ParticleSystem): number, number
	-- Sets the amount of spin variation (0 meaning no variation and 1 meaning full variation between start and
	-- end).
	-- See: https://love2d.org/wiki/ParticleSystem:setSpinVariation
	setSpinVariation: function(self: ParticleSystem, variation: number)
	-- Gets the amount of spin variation (0 meaning no variation and 1 meaning full variation between start and
	-- end).
	-- See: https://love2d.org/wiki/ParticleSystem:getSpinVariation
	getSpinVariation: function(self: ParticleSystem): number
	-- Set the offset position which the particle sprite is rotated around.
	-- See: https://love2d.org/wiki/ParticleSystem:setOffset
	setOffset: function(self: ParticleSystem, x: number, y: number)
	-- Gets the particle image's draw offset.
	-- See: https://love2d.org/wiki/ParticleSystem:getOffset
	getOffset: function(self: ParticleSystem): number, number
	-- Sets a series of colors to apply to the particle sprite. The particle system will interpolate between each
	-- color evenly over the particle's lifetime.
	-- See: https://love2d.org/wiki/ParticleSystem:setColors
	setColors: function(self: ParticleSystem, colors: any...)
	-- Gets the series of colors applied to the particle sprite.
	-- See: https://love2d.org/wiki/ParticleSystem:getColors
	getColors: function(self: ParticleSystem): {number}...
	-- Sets a series of Quads to use for the particle sprites. Particles will choose a Quad from the list based on
	-- the particle's current lifetime, allowing for the use of animated sprite sheets with ParticleSystems.
	-- See: https://love2d.org/wiki/ParticleSystem:setQuads
	setQuads: function(self: ParticleSystem, quads: any...)
	-- Gets the series of Quads used for the particle sprites.
	-- See: https://love2d.org/wiki/ParticleSystem:getQuads
	getQuads: function(self: ParticleSystem): {Quad}
	-- Sets whether particle angles and rotations are relative to their velocities. If enabled, particles are
	-- aligned to the angle of their velocities and rotate relative to that angle.
	-- See: https://love2d.org/wiki/ParticleSystem:setRelativeRotation
	setRelativeRotation: function(self: ParticleSystem, enabled: boolean)
	-- Gets whether particle angles and rotations are relative to their velocities. If enabled, particles are
	-- aligned to the angle of their velocities and rotate relative to that angle.
	-- See: https://love2d.org/wiki/ParticleSystem:hasRelativeRotation
	hasRelativeRotation: function(self: ParticleSystem): boolean
	-- Gets the number of particles that are currently in the system.
	-- See: https://love2d.org/wiki/ParticleSystem:getCount
	getCount: function(self: ParticleSystem): integer
	-- Starts the particle emitter.
	-- See: https://love2d.org/wiki/ParticleSystem:start
	start: function(self: ParticleSystem)
	-- Stops the particle emitter, resetting the lifetime counter.
	-- See: https://love2d.org/wiki/ParticleSystem:stop
	stop: function(self: ParticleSystem)
	-- Pauses the particle emitter.
	-- See: https://love2d.org/wiki/ParticleSystem:pause
	pause: function(self: ParticleSystem)
	-- Resets the particle emitter, removing any existing particles and resetting the lifetime counter.
	-- See: https://love2d.org/wiki/ParticleSystem:reset
	reset: function(self: ParticleSystem)
	-- Emits a burst of particles from the particle emitter.
	-- See: https://love2d.org/wiki/ParticleSystem:emit
	emit: function(self: ParticleSystem, count: integer)
	-- Checks whether the particle system is actively emitting particles.
	-- See: https://love2d.org/wiki/ParticleSystem:isActive
	isActive: function(self: ParticleSystem): boolean
	-- Checks whether the particle system is paused.
	-- See: https://love2d.org/wiki/ParticleSystem:isPaused
	isPaused: function(self: ParticleSystem): boolean
	-- Checks whether the particle system is stopped.
	-- See: https://love2d.org/wiki/ParticleSystem:isStopped
	isStopped: function(self: ParticleSystem): boolean
	isEmpty: function(self: ParticleSystem): boolean
	isFull: function(self: ParticleSystem): boolean
	-- Updates the particle system; moving, creating and killing particles.
	-- See: https://love2d.org/wiki/ParticleSystem:update
	update: function(self: ParticleSystem, delta_time: number)
end

-- A Shader is used for advanced hardware-accelerated pixel or vertex manipulation. These effects are written
-- in a language based on GLSL (OpenGL Shading Language) with a few things simplified for easier coding.
-- See: https://love2d.org/wiki/Shader
local record Shader
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Shader): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Shader, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Shader): boolean
	-- Returns any warning and error messages from compiling the shader code. This can be used for debugging your
	-- shaders if there's anything the graphics hardware doesn't like.
	-- See: https://love2d.org/wiki/Shader:getWarnings
	getWarnings: function(self: Shader): string
	-- Gets whether a uniform / extern variable exists in the Shader.
	-- See: https://love2d.org/wiki/Shader:hasUniform
	hasUniform: function(self: Shader, name: string): boolean
	-- Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to
	-- be marked using the ''uniform'' or ''extern'' keyword, e.g.
	-- See: https://love2d.org/wiki/Shader:send
	send: function(self: Shader, name: string, values: any...)
	-- Sends one or more colors to a special (''extern'' / ''uniform'') vec3 or vec4 variable inside the shader.
	-- The color components must be in the range of 1. The colors are gamma-corrected if global gamma-correction
	-- is enabled.
	-- See: https://love2d.org/wiki/Shader:sendColor
	sendColor: function(self: Shader, name: string, values: any...)
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
-- See: https://love2d.org/wiki/love.window
local record Window
	-- Gets the width and height of the desktop.
	-- See: https://love2d.org/wiki/love.window.getDesktopDimensions
	getDesktopDimensions: function(display?: integer): integer, integer
	-- Gets the number of connected monitors.
	-- See: https://love2d.org/wiki/love.window.getDisplayCount
	getDisplayCount: function(): integer
	-- Gets the name of a display.
	-- See: https://love2d.org/wiki/love.window.getDisplayName
	getDisplayName: function(display: integer): string
	-- Gets current device display orientation.
	-- See: https://love2d.org/wiki/love.window.getDisplayOrientation
	getDisplayOrientation: function(display?: integer): string
	-- Gets a list of supported fullscreen modes.
	-- See: https://love2d.org/wiki/love.window.getFullscreenModes
	getFullscreenModes: function(display?: integer): {WindowSize}
	-- Enters or exits fullscreen. The display to use when entering fullscreen is chosen based on which display
	-- the window is currently in, if multiple monitors are connected.
	-- See: https://love2d.org/wiki/love.window.setFullscreen
	setFullscreen: function(fullscreen: boolean, fullscreen_type?: string): boolean
	-- Gets whether the window is fullscreen.
	-- See: https://love2d.org/wiki/love.window.getFullscreen
	getFullscreen: function(): boolean, string
	-- Checks if the window is open.
	-- See: https://love2d.org/wiki/love.window.isOpen
	isOpen: function(): boolean
	-- Gets the window icon.
	-- See: https://love2d.org/wiki/love.window.getIcon
	getIcon: function(): any
	-- Gets the display mode and properties of the window.
	-- See: https://love2d.org/wiki/love.window.getMode
	getMode: function(): integer, integer, WindowMode
	-- Sets the display mode and properties of the window.
	-- See: https://love2d.org/wiki/love.window.setMode
	setMode: function(width: integer, height: integer, settings?: WindowMode): boolean
	-- Sets the display mode and properties of the window, without modifying unspecified properties.
	-- See: https://love2d.org/wiki/love.window.updateMode
	updateMode: function(settings_or_width: WindowMode | integer, height?: integer, settings?: WindowMode): boolean
	-- Gets the position of the window on the screen.
	-- See: https://love2d.org/wiki/love.window.getPosition
	getPosition: function(): integer, integer, integer
	-- Gets area inside the window which is known to be unobstructed by a system title bar, the iPhone X notch,
	-- etc. Useful for making sure UI elements can be seen by the user.
	-- See: https://love2d.org/wiki/love.window.getSafeArea
	getSafeArea: function(): number, number, number, number
	-- Sets the window title.
	-- See: https://love2d.org/wiki/love.window.setTitle
	setTitle: function(title: string)
	-- Gets the window title.
	-- See: https://love2d.org/wiki/love.window.getTitle
	getTitle: function(): string
	-- Sets vertical synchronization mode.
	-- See: https://love2d.org/wiki/love.window.setVSync
	setVSync: function(vsync: boolean | integer)
	-- Gets current vertical synchronization (vsync).
	-- See: https://love2d.org/wiki/love.window.getVSync
	getVSync: function(): integer
	-- Sets whether the display is allowed to sleep while the program is running.
	-- See: https://love2d.org/wiki/love.window.setDisplaySleepEnabled
	setDisplaySleepEnabled: function(enabled: boolean)
	-- Gets whether the display is allowed to sleep while the program is running.
	-- See: https://love2d.org/wiki/love.window.isDisplaySleepEnabled
	isDisplaySleepEnabled: function(): boolean
	-- Checks if the game window has keyboard focus.
	-- See: https://love2d.org/wiki/love.window.hasFocus
	hasFocus: function(): boolean
	-- Checks if the game window has mouse focus.
	-- See: https://love2d.org/wiki/love.window.hasMouseFocus
	hasMouseFocus: function(): boolean
	-- Checks if the game window is visible.
	-- See: https://love2d.org/wiki/love.window.isVisible
	isVisible: function(): boolean
	-- Gets whether the Window is currently maximized.
	-- See: https://love2d.org/wiki/love.window.isMaximized
	isMaximized: function(): boolean
	-- Gets whether the Window is currently minimized.
	-- See: https://love2d.org/wiki/love.window.isMinimized
	isMinimized: function(): boolean
	-- Gets the DPI scale factor associated with the window.
	-- See: https://love2d.org/wiki/love.window.getDPIScale
	getDPIScale: function(): number
	getNativeDPIScale: function(): number
	-- Converts a number from density-independent units to pixels.
	-- See: https://love2d.org/wiki/love.window.toPixels
	toPixels: function(value: number, y?: number): number, number
	-- Converts a number from pixels to density-independent units.
	-- See: https://love2d.org/wiki/love.window.fromPixels
	fromPixels: function(value: number, y?: number): number, number
end

-- Manages events, like keypresses.
-- See: https://love2d.org/wiki/love.event
local record Event
	-- Dora 统一接管平台事件泵；此调用不会读取第二套操作系统队列。
	-- Pump events into the event queue.
	-- See: https://love2d.org/wiki/love.event.pump
	pump: function()
	-- Returns an iterator for messages in the event queue.
	-- See: https://love2d.org/wiki/love.event.poll
	poll: function(): function(): any...
	-- 嵌入实例队列为空时立即返回，不阻塞 Dora 主线程。
	-- Like love.event.poll(), but blocks until there is an event in the queue.
	-- See: https://love2d.org/wiki/love.event.wait
	wait: function(): any...
	-- Adds an event to the event queue.
	-- See: https://love2d.org/wiki/love.event.push
	push: function(name: string, args: any...): boolean
	-- Clears the event queue.
	-- See: https://love2d.org/wiki/love.event.clear
	clear: function()
	-- 请求只停止当前嵌入式 Love 实例。
	-- Adds the quit event to the queue.
	-- See: https://love2d.org/wiki/love.event.quit
	quit: function(exit_status?: integer | string): boolean
end

local type FileType = string
local type FileMode = string
local type BufferMode = string
-- Data representing the contents of a file.
-- See: https://love2d.org/wiki/FileData
local record FileData
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: FileData): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: FileData, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: FileData): boolean
	-- Gets the full Data as a string.
	-- See: https://love2d.org/wiki/Data:getString
	getString: function(self: FileData): string
	-- Gets the Data's size in bytes.
	-- See: https://love2d.org/wiki/Data:getSize
	getSize: function(self: FileData): integer
	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- See: https://love2d.org/wiki/Data:getPointer
	getPointer: function(self: FileData): any
	-- Gets an FFI pointer to the Data.
	-- See: https://love2d.org/wiki/Data:getFFIPointer
	getFFIPointer: function(self: FileData): nil
	-- Creates a new copy of the Data object.
	-- See: https://love2d.org/wiki/Data:clone
	clone: function(self: FileData): FileData
	-- Gets the filename of the FileData.
	-- See: https://love2d.org/wiki/FileData:getFilename
	getFilename: function(self: FileData): string
	-- Gets the extension of the FileData.
	-- See: https://love2d.org/wiki/FileData:getExtension
	getExtension: function(self: FileData): string
end
-- Raw (decoded) image data.
-- See: https://love2d.org/wiki/ImageData
local record ImageData
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: ImageData): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: ImageData): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: ImageData, type_name: string): boolean
	-- Gets the full Data as a string.
	-- See: https://love2d.org/wiki/Data:getString
	getString: function(self: ImageData): string
	-- Gets the Data's size in bytes.
	-- See: https://love2d.org/wiki/Data:getSize
	getSize: function(self: ImageData): integer
	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- See: https://love2d.org/wiki/Data:getPointer
	getPointer: function(self: ImageData): any
	-- Gets an FFI pointer to the Data.
	-- See: https://love2d.org/wiki/Data:getFFIPointer
	getFFIPointer: function(self: ImageData): nil
	-- Creates a new copy of the Data object.
	-- See: https://love2d.org/wiki/Data:clone
	clone: function(self: ImageData): ImageData
	-- Gets the width of the ImageData in pixels.
	-- See: https://love2d.org/wiki/ImageData:getWidth
	getWidth: function(self: ImageData): integer
	-- Gets the height of the ImageData in pixels.
	-- See: https://love2d.org/wiki/ImageData:getHeight
	getHeight: function(self: ImageData): integer
	-- Gets the width and height of the ImageData in pixels.
	-- See: https://love2d.org/wiki/ImageData:getDimensions
	getDimensions: function(self: ImageData): integer, integer
	-- Gets the pixel format of the ImageData.
	-- See: https://love2d.org/wiki/ImageData:getFormat
	getFormat: function(self: ImageData): string
	-- Gets the color of a pixel at a specific position in the image.
	-- See: https://love2d.org/wiki/ImageData:getPixel
	getPixel: function(self: ImageData, x: integer, y: integer): number, number, number, number
	-- Sets the color of a pixel at a specific position in the image.
	-- See: https://love2d.org/wiki/ImageData:setPixel
	setPixel: function(self: ImageData, x: integer, y: integer, red: number, green: number, blue: number, alpha?: number)
	-- Transform an image by applying a function to every pixel.
	-- See: https://love2d.org/wiki/ImageData:mapPixel
	mapPixel: function(self: ImageData, mapper: function(x: integer, y: integer, red: number, green: number, blue: number, alpha: number): (number, number, number, number), x?: integer, y?: integer, width?: integer, height?: integer)
	-- Paste into ImageData from another source ImageData.
	-- See: https://love2d.org/wiki/ImageData:paste
	paste: function(self: ImageData, source: ImageData, destination_x: integer, destination_y: integer, source_x?: integer, source_y?: integer, source_width?: integer, source_height?: integer)
	-- Encodes the ImageData and optionally writes it to the save directory.
	-- See: https://love2d.org/wiki/ImageData:encode
	encode: function(self: ImageData, format: string, filename?: string): FileData
end
-- Represents compressed image data designed to stay compressed in RAM.
-- See: https://love2d.org/wiki/CompressedImageData
local record CompressedImageData
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: CompressedImageData): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: CompressedImageData): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: CompressedImageData, type_name: string): boolean
	-- Gets the full Data as a string.
	-- See: https://love2d.org/wiki/Data:getString
	getString: function(self: CompressedImageData): string
	-- Gets the Data's size in bytes.
	-- See: https://love2d.org/wiki/Data:getSize
	getSize: function(self: CompressedImageData): integer
	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- See: https://love2d.org/wiki/Data:getPointer
	getPointer: function(self: CompressedImageData): any
	-- Gets an FFI pointer to the Data.
	-- See: https://love2d.org/wiki/Data:getFFIPointer
	getFFIPointer: function(self: CompressedImageData): nil
	-- Creates a new copy of the Data object.
	-- See: https://love2d.org/wiki/Data:clone
	clone: function(self: CompressedImageData): CompressedImageData
	-- Gets the width of the CompressedImageData.
	-- See: https://love2d.org/wiki/CompressedImageData:getWidth
	getWidth: function(self: CompressedImageData, mipmap?: integer): integer
	-- Gets the height of the CompressedImageData.
	-- See: https://love2d.org/wiki/CompressedImageData:getHeight
	getHeight: function(self: CompressedImageData, mipmap?: integer): integer
	-- Gets the width and height of the CompressedImageData.
	-- See: https://love2d.org/wiki/CompressedImageData:getDimensions
	getDimensions: function(self: CompressedImageData, mipmap?: integer): integer, integer
	-- Gets the number of mipmap levels in the CompressedImageData. The base mipmap level (original image) is
	-- included in the count.
	-- See: https://love2d.org/wiki/CompressedImageData:getMipmapCount
	getMipmapCount: function(self: CompressedImageData): integer
	-- Gets the format of the CompressedImageData.
	-- See: https://love2d.org/wiki/CompressedImageData:getFormat
	getFormat: function(self: CompressedImageData): string
end
-- Provides an interface to decode encoded image data.
-- See: https://love2d.org/wiki/love.image
local record ImageModule
	-- Creates a new ImageData object.
	-- See: https://love2d.org/wiki/love.image.newImageData
	newImageData: function(filename_or_width_or_data: string | integer | FileData, height?: integer, format?: string, data?: string | FileData): ImageData
	-- Create a new CompressedImageData object from a compressed image file. LÖVE supports several compressed
	-- texture formats, enumerated in the CompressedImageFormat page.
	-- See: https://love2d.org/wiki/love.image.newCompressedData
	newCompressedData: function(filename_or_data: string | FileData): CompressedImageData
	-- Determines whether a file can be loaded as CompressedImageData.
	-- See: https://love2d.org/wiki/love.image.isCompressed
	isCompressed: function(filename_or_data: string | FileData): boolean
end
-- A Rasterizer handles font rendering, containing the font data (image or TrueType font) and drawable glyphs.
-- See: https://love2d.org/wiki/Rasterizer
local record Rasterizer
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Rasterizer): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Rasterizer): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Rasterizer, type_name: string): boolean
	-- Gets font height.
	-- See: https://love2d.org/wiki/Rasterizer:getHeight
	getHeight: function(self: Rasterizer): integer
	-- Gets font advance.
	-- See: https://love2d.org/wiki/Rasterizer:getAdvance
	getAdvance: function(self: Rasterizer): integer
	-- Gets ascent height.
	-- See: https://love2d.org/wiki/Rasterizer:getAscent
	getAscent: function(self: Rasterizer): integer
	-- Gets descent height.
	-- See: https://love2d.org/wiki/Rasterizer:getDescent
	getDescent: function(self: Rasterizer): integer
	-- Gets line height of a font.
	-- See: https://love2d.org/wiki/Rasterizer:getLineHeight
	getLineHeight: function(self: Rasterizer): integer
	-- Gets glyph data of a specified glyph.
	-- See: https://love2d.org/wiki/Rasterizer:getGlyphData
	getGlyphData: function(self: Rasterizer, glyph: string | integer): GlyphData
	-- Gets number of glyphs in font.
	-- See: https://love2d.org/wiki/Rasterizer:getGlyphCount
	getGlyphCount: function(self: Rasterizer): integer
	-- Checks if font contains specified glyphs.
	-- See: https://love2d.org/wiki/Rasterizer:hasGlyphs
	hasGlyphs: function(self: Rasterizer, glyph: string | integer, ...: string | integer): boolean
end
-- A GlyphData represents a drawable symbol of a font Rasterizer.
-- See: https://love2d.org/wiki/GlyphData
local record GlyphData
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: GlyphData): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: GlyphData): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: GlyphData, type_name: string): boolean
	-- Gets the full Data as a string.
	-- See: https://love2d.org/wiki/Data:getString
	getString: function(self: GlyphData): string
	-- Gets the Data's size in bytes.
	-- See: https://love2d.org/wiki/Data:getSize
	getSize: function(self: GlyphData): integer
	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- See: https://love2d.org/wiki/Data:getPointer
	getPointer: function(self: GlyphData): any
	-- Gets an FFI pointer to the Data.
	-- See: https://love2d.org/wiki/Data:getFFIPointer
	getFFIPointer: function(self: GlyphData): nil
	-- Creates a new copy of the Data object.
	-- See: https://love2d.org/wiki/Data:clone
	clone: function(self: GlyphData): GlyphData
	-- Gets glyph width.
	-- See: https://love2d.org/wiki/GlyphData:getWidth
	getWidth: function(self: GlyphData): integer
	-- Gets glyph height.
	-- See: https://love2d.org/wiki/GlyphData:getHeight
	getHeight: function(self: GlyphData): integer
	-- Gets glyph dimensions.
	-- See: https://love2d.org/wiki/GlyphData:getDimensions
	getDimensions: function(self: GlyphData): integer, integer
	-- Gets glyph number.
	-- See: https://love2d.org/wiki/GlyphData:getGlyph
	getGlyph: function(self: GlyphData): integer
	-- Gets glyph string.
	-- See: https://love2d.org/wiki/GlyphData:getGlyphString
	getGlyphString: function(self: GlyphData): string
	-- Gets glyph advance.
	-- See: https://love2d.org/wiki/GlyphData:getAdvance
	getAdvance: function(self: GlyphData): integer
	-- Gets glyph bearing.
	-- See: https://love2d.org/wiki/GlyphData:getBearing
	getBearing: function(self: GlyphData): integer, integer
	-- Gets glyph bounding box.
	-- See: https://love2d.org/wiki/GlyphData:getBoundingBox
	getBoundingBox: function(self: GlyphData): integer, integer, integer, integer
	-- Gets glyph pixel format.
	-- See: https://love2d.org/wiki/GlyphData:getFormat
	getFormat: function(self: GlyphData): string
end
-- Allows you to work with fonts.
-- See: https://love2d.org/wiki/love.font
local record FontModule
	-- Creates a new Image Rasterizer.
	-- See: https://love2d.org/wiki/love.font.newImageRasterizer
	newImageRasterizer: function(image_data: ImageData, glyphs: string, extra_spacing?: integer, dpi_scale?: number): Rasterizer
	-- Creates a new BMFont Rasterizer.
	-- See: https://love2d.org/wiki/love.font.newBMFontRasterizer
	newBMFontRasterizer: function(filename_or_file_data: string | FileData, images?: ImageData | string | FileData | {ImageData | string | FileData}, dpi_scale?: number): Rasterizer
	-- Creates a new TrueType Rasterizer.
	-- See: https://love2d.org/wiki/love.font.newTrueTypeRasterizer
	newTrueTypeRasterizer: function(filename_or_size_or_data?: string | integer | FileData, size_or_hinting?: integer | string, hinting_or_dpi?: string | number, dpi_scale?: number): Rasterizer
	-- Creates a new Rasterizer.
	-- See: https://love2d.org/wiki/love.font.newRasterizer
	newRasterizer: function(filename_or_size_or_data?: string | integer | FileData, size_or_hinting?: integer | string, hinting_or_dpi?: string | number, dpi_scale?: number): Rasterizer
	-- Creates a new GlyphData.
	-- See: https://love2d.org/wiki/love.font.newGlyphData
	newGlyphData: function(rasterizer: Rasterizer, glyph: string | integer): GlyphData
end
-- Contains raw audio samples.
-- See: https://love2d.org/wiki/SoundData
local record SoundData
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: SoundData): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: SoundData, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: SoundData): boolean
	-- Gets the full Data as a string.
	-- See: https://love2d.org/wiki/Data:getString
	getString: function(self: SoundData): string
	-- Gets the Data's size in bytes.
	-- See: https://love2d.org/wiki/Data:getSize
	getSize: function(self: SoundData): integer
	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- See: https://love2d.org/wiki/Data:getPointer
	getPointer: function(self: SoundData): any
	-- Gets an FFI pointer to the Data.
	-- See: https://love2d.org/wiki/Data:getFFIPointer
	getFFIPointer: function(self: SoundData): nil
	-- Creates a new copy of the Data object.
	-- See: https://love2d.org/wiki/Data:clone
	clone: function(self: SoundData): SoundData
	-- Returns the number of channels in the SoundData.
	-- See: https://love2d.org/wiki/SoundData:getChannelCount
	getChannelCount: function(self: SoundData): integer
	getChannels: function(self: SoundData): integer
	-- Returns the number of bits per sample.
	-- See: https://love2d.org/wiki/SoundData:getBitDepth
	getBitDepth: function(self: SoundData): integer
	-- Returns the sample rate of the SoundData.
	-- See: https://love2d.org/wiki/SoundData:getSampleRate
	getSampleRate: function(self: SoundData): integer
	-- Returns the number of samples per channel of the SoundData.
	-- See: https://love2d.org/wiki/SoundData:getSampleCount
	getSampleCount: function(self: SoundData): integer
	-- Gets the duration of the sound data.
	-- See: https://love2d.org/wiki/SoundData:getDuration
	getDuration: function(self: SoundData): number
	getSample: function(self: SoundData, index: integer, channel?: integer): number
	-- Sets the value of the sample-point at the specified position. For stereo SoundData objects, the data from
	-- the left and right channels are interleaved in that order.
	-- See: https://love2d.org/wiki/SoundData:setSample
	setSample: function(self: SoundData, index: integer, channel_or_sample: number, sample?: number)
end
-- An object which can gradually decode a sound file.
-- See: https://love2d.org/wiki/Decoder
local record Decoder
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Decoder): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Decoder, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Decoder): boolean
	-- Creates a new copy of current decoder.
	-- See: https://love2d.org/wiki/Decoder:clone
	clone: function(self: Decoder): Decoder
	-- Returns the number of channels in the stream.
	-- See: https://love2d.org/wiki/Decoder:getChannelCount
	getChannelCount: function(self: Decoder): integer
	getChannels: function(self: Decoder): integer
	-- Returns the number of bits per sample.
	-- See: https://love2d.org/wiki/Decoder:getBitDepth
	getBitDepth: function(self: Decoder): integer
	-- Returns the sample rate of the Decoder.
	-- See: https://love2d.org/wiki/Decoder:getSampleRate
	getSampleRate: function(self: Decoder): integer
	-- Gets the duration of the sound file. It may not always be sample-accurate, and it may return -1 if the
	-- duration cannot be determined at all.
	-- See: https://love2d.org/wiki/Decoder:getDuration
	getDuration: function(self: Decoder): number
	-- Decodes the audio and returns a SoundData object containing the decoded audio data.
	-- See: https://love2d.org/wiki/Decoder:decode
	decode: function(self: Decoder): SoundData | nil
	-- Sets the currently playing position of the Decoder.
	-- See: https://love2d.org/wiki/Decoder:seek
	seek: function(self: Decoder, offset: number)
end
-- This module is responsible for decoding sound files. It can't play the sounds, see love.audio for that.
-- See: https://love2d.org/wiki/love.sound
local record SoundModule
	-- Attempts to find a decoder for the encoded sound data in the specified file.
	-- See: https://love2d.org/wiki/love.sound.newDecoder
	newDecoder: function(filename_or_data: string | FileData, buffer_size?: integer): Decoder
	-- Creates new SoundData from a filepath, File, or Decoder. It's also possible to create SoundData with a
	-- custom sample rate, channel and bit depth.
	-- See: https://love2d.org/wiki/love.sound.newSoundData
	newSoundData: function(filename_or_samples_or_data_or_decoder: string | integer | FileData | Decoder, sample_rate_or_buffer_size?: integer, bit_depth?: integer, channels?: integer): SoundData
end
-- Data object containing arbitrary bytes in an contiguous memory.
-- See: https://love2d.org/wiki/ByteData
local record ByteData
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: ByteData): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: ByteData, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: ByteData): boolean
	-- Gets the full Data as a string.
	-- See: https://love2d.org/wiki/Data:getString
	getString: function(self: ByteData): string
	-- Gets the Data's size in bytes.
	-- See: https://love2d.org/wiki/Data:getSize
	getSize: function(self: ByteData): integer
	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- See: https://love2d.org/wiki/Data:getPointer
	getPointer: function(self: ByteData): any
	-- Gets an FFI pointer to the Data.
	-- See: https://love2d.org/wiki/Data:getFFIPointer
	getFFIPointer: function(self: ByteData): nil
	-- Creates a new copy of the Data object.
	-- See: https://love2d.org/wiki/Data:clone
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
-- See: https://love2d.org/wiki/CompressedData
local record CompressedData
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: CompressedData): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: CompressedData, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: CompressedData): boolean
	-- Gets the full Data as a string.
	-- See: https://love2d.org/wiki/Data:getString
	getString: function(self: CompressedData): string
	-- Gets the Data's size in bytes.
	-- See: https://love2d.org/wiki/Data:getSize
	getSize: function(self: CompressedData): integer
	-- Gets a pointer to the Data. Can be used with libraries such as LuaJIT's FFI.
	-- See: https://love2d.org/wiki/Data:getPointer
	getPointer: function(self: CompressedData): any
	-- Gets an FFI pointer to the Data.
	-- See: https://love2d.org/wiki/Data:getFFIPointer
	getFFIPointer: function(self: CompressedData): nil
	-- Creates a new copy of the Data object.
	-- See: https://love2d.org/wiki/Data:clone
	clone: function(self: CompressedData): CompressedData
	-- Gets the compression format of the CompressedData.
	-- See: https://love2d.org/wiki/CompressedData:getFormat
	getFormat: function(self: CompressedData): string
end
-- Provides functionality for creating and transforming data.
-- See: https://love2d.org/wiki/love.data
local record DataModule
	-- Creates a new Data object containing arbitrary bytes.
	-- See: https://love2d.org/wiki/love.data.newByteData
	newByteData: function(size_or_string_or_data: any, offset?: integer, size?: integer): ByteData
	-- Creates a new Data referencing a subsection of an existing Data object.
	-- See: https://love2d.org/wiki/love.data.newDataView
	newDataView: function(data: any, offset: integer, size: integer): DataView
	-- Encode Data or a string to a Data or string in one of the EncodeFormats.
	-- See: https://love2d.org/wiki/love.data.encode
	encode: function(container: string, format: string, source: any, line_length?: integer): string | ByteData
	-- Decode Data or a string from any of the EncodeFormats to Data or string.
	-- See: https://love2d.org/wiki/love.data.decode
	decode: function(container: string, format: string, source: any): string | ByteData
	-- Compresses a string or data using a specific compression algorithm.
	-- See: https://love2d.org/wiki/love.data.compress
	compress: function(container: string, format: string, source: any, level?: integer): string | CompressedData
	-- Decompresses a CompressedData or previously compressed string or Data object.
	-- See: https://love2d.org/wiki/love.data.decompress
	decompress: function(container: string, format_or_data: any, source?: any): string | ByteData
	-- Packs (serializes) simple Lua values.
	-- See: https://love2d.org/wiki/love.data.pack
	pack: function(container: string, format: string, values: any...): string | ByteData
	-- Unpacks (deserializes) a byte-string or Data into simple Lua values.
	-- See: https://love2d.org/wiki/love.data.unpack
	unpack: function(format: string, source: any, position?: integer): any...
	-- Gets the size in bytes that a given format used with love.data.pack will use.
	-- See: https://love2d.org/wiki/love.data.getPackedSize
	getPackedSize: function(format: string): integer
	-- Compute the message digest of a string using a specified hash algorithm.
	-- See: https://love2d.org/wiki/love.data.hash
	hash: function(hash_function: string, source: any): string
end
-- A random number generation object which has its own random state.
-- See: https://love2d.org/wiki/RandomGenerator
local record RandomGenerator
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: RandomGenerator): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: RandomGenerator, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: RandomGenerator): boolean
	-- Generates a pseudo-random number in a platform independent manner.
	-- See: https://love2d.org/wiki/RandomGenerator:random
	random: function(self: RandomGenerator, lower_or_upper?: number, upper?: number): number
	-- Get a normally distributed pseudo random number.
	-- See: https://love2d.org/wiki/RandomGenerator:randomNormal
	randomNormal: function(self: RandomGenerator, standard_deviation?: number, mean?: number): number
	-- Sets the seed of the random number generator using the specified integer number.
	-- See: https://love2d.org/wiki/RandomGenerator:setSeed
	setSeed: function(self: RandomGenerator, low_or_seed: number, high?: number)
	-- Gets the seed of the random number generator object.
	-- See: https://love2d.org/wiki/RandomGenerator:getSeed
	getSeed: function(self: RandomGenerator): number, number
	-- Sets the current state of the random number generator. The value used as an argument for this function is
	-- an opaque string and should only originate from a previous call to RandomGenerator:getState in the same
	-- major version of LÖVE.
	-- See: https://love2d.org/wiki/RandomGenerator:setState
	setState: function(self: RandomGenerator, state: string)
	-- Gets the current state of the random number generator. This returns an opaque string which is only useful
	-- for later use with RandomGenerator:setState in the same major version of LÖVE.
	-- See: https://love2d.org/wiki/RandomGenerator:getState
	getState: function(self: RandomGenerator): string
end
-- Object containing a coordinate system transformation.
-- See: https://love2d.org/wiki/Transform
local record Transform
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Transform): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Transform, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Transform): boolean
	-- Creates a new copy of this Transform.
	-- See: https://love2d.org/wiki/Transform:clone
	clone: function(self: Transform): Transform
	-- Creates a new Transform containing the inverse of this Transform.
	-- See: https://love2d.org/wiki/Transform:inverse
	inverse: function(self: Transform): Transform
	-- Applies the given other Transform object to this one.
	-- See: https://love2d.org/wiki/Transform:apply
	apply: function(self: Transform, other: Transform): Transform
	-- Checks whether the Transform is an affine transformation.
	-- See: https://love2d.org/wiki/Transform:isAffine2DTransform
	isAffine2DTransform: function(self: Transform): boolean
	-- Applies a translation to the Transform's coordinate system. This method does not reset any previously
	-- applied transformations.
	-- See: https://love2d.org/wiki/Transform:translate
	translate: function(self: Transform, x: number, y: number): Transform
	-- Applies a rotation to the Transform's coordinate system. This method does not reset any previously applied
	-- transformations.
	-- See: https://love2d.org/wiki/Transform:rotate
	rotate: function(self: Transform, angle: number): Transform
	-- Scales the Transform's coordinate system. This method does not reset any previously applied
	-- transformations.
	-- See: https://love2d.org/wiki/Transform:scale
	scale: function(self: Transform, x: number, y?: number): Transform
	-- Applies a shear factor (skew) to the Transform's coordinate system. This method does not reset any
	-- previously applied transformations.
	-- See: https://love2d.org/wiki/Transform:shear
	shear: function(self: Transform, x: number, y: number): Transform
	-- Resets the Transform to an identity state. All previously applied transformations are erased.
	-- See: https://love2d.org/wiki/Transform:reset
	reset: function(self: Transform): Transform
	-- Resets the Transform to the specified transformation parameters.
	-- See: https://love2d.org/wiki/Transform:setTransformation
	setTransformation: function(self: Transform, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): Transform
	-- Directly sets the Transform's internal 4x4 transformation matrix.
	-- See: https://love2d.org/wiki/Transform:setMatrix
	setMatrix: function(self: Transform, layout_or_elements: string | {number} | {{number}}, elements?: {number} | {{number}}): Transform
	-- Gets the internal 4x4 transformation matrix stored by this Transform. The matrix is returned in row-major
	-- order.
	-- See: https://love2d.org/wiki/Transform:getMatrix
	getMatrix: function(self: Transform): number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number
	-- Applies the Transform object's transformation to the given 2D position.
	-- See: https://love2d.org/wiki/Transform:transformPoint
	transformPoint: function(self: Transform, x: number, y: number): number, number
	-- Applies the reverse of the Transform object's transformation to the given 2D position.
	-- See: https://love2d.org/wiki/Transform:inverseTransformPoint
	inverseTransformPoint: function(self: Transform, x: number, y: number): number, number
end
-- A Bézier curve object that can evaluate and render Bézier curves of arbitrary degree.
-- See: https://love2d.org/wiki/BezierCurve
local record BezierCurve
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: BezierCurve): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: BezierCurve, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: BezierCurve): boolean
	-- Get degree of the Bézier curve. The degree is equal to number-of-control-points - 1.
	-- See: https://love2d.org/wiki/BezierCurve:getDegree
	getDegree: function(self: BezierCurve): integer
	-- Get the derivative of the Bézier curve.
	-- See: https://love2d.org/wiki/BezierCurve:getDerivative
	getDerivative: function(self: BezierCurve): BezierCurve
	-- Get coordinates of the i-th control point. Indices start with 1.
	-- See: https://love2d.org/wiki/BezierCurve:getControlPoint
	getControlPoint: function(self: BezierCurve, index: integer): number, number
	-- Set coordinates of the i-th control point. Indices start with 1.
	-- See: https://love2d.org/wiki/BezierCurve:setControlPoint
	setControlPoint: function(self: BezierCurve, index: integer, x: number, y: number)
	-- Insert control point as the new i-th control point. Existing control points from i onwards are pushed back
	-- by 1. Indices start with 1. Negative indices wrap around: -1 is the last control point, -2 the one before
	-- the last, etc.
	-- See: https://love2d.org/wiki/BezierCurve:insertControlPoint
	insertControlPoint: function(self: BezierCurve, x: number, y: number, index?: integer)
	-- Removes the specified control point.
	-- See: https://love2d.org/wiki/BezierCurve:removeControlPoint
	removeControlPoint: function(self: BezierCurve, index: integer)
	-- Get the number of control points in the Bézier curve.
	-- See: https://love2d.org/wiki/BezierCurve:getControlPointCount
	getControlPointCount: function(self: BezierCurve): integer
	-- Move the Bézier curve by an offset.
	-- See: https://love2d.org/wiki/BezierCurve:translate
	translate: function(self: BezierCurve, x: number, y: number)
	-- Rotate the Bézier curve by an angle.
	-- See: https://love2d.org/wiki/BezierCurve:rotate
	rotate: function(self: BezierCurve, angle: number, origin_x?: number, origin_y?: number)
	-- Scale the Bézier curve by a factor.
	-- See: https://love2d.org/wiki/BezierCurve:scale
	scale: function(self: BezierCurve, scale: number, origin_x?: number, origin_y?: number)
	-- Evaluate Bézier curve at parameter t. The parameter must be between 0 and 1 (inclusive).
	-- See: https://love2d.org/wiki/BezierCurve:evaluate
	evaluate: function(self: BezierCurve, time: number): number, number
	-- Gets a BezierCurve that corresponds to the specified segment of this BezierCurve.
	-- See: https://love2d.org/wiki/BezierCurve:getSegment
	getSegment: function(self: BezierCurve, start: number, finish: number): BezierCurve
	-- Get a list of coordinates to be used with love.graphics.line.
	-- See: https://love2d.org/wiki/BezierCurve:render
	render: function(self: BezierCurve, accuracy?: integer): {number}
	-- Get a list of coordinates on a specific part of the curve, to be used with love.graphics.line.
	-- See: https://love2d.org/wiki/BezierCurve:renderSegment
	renderSegment: function(self: BezierCurve, start: number, finish: number, accuracy?: integer): {number}
end
-- Provides system-independent mathematical functions.
-- See: https://love2d.org/wiki/love.math
local record MathModule
	-- Creates a new RandomGenerator object which is completely independent of other RandomGenerator objects and
	-- random functions.
	-- See: https://love2d.org/wiki/love.math.newRandomGenerator
	newRandomGenerator: function(low_or_seed?: number, high?: number): RandomGenerator
	-- Creates a new Transform object.
	-- See: https://love2d.org/wiki/love.math.newTransform
	newTransform: function(x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): Transform
	-- Creates a new BezierCurve object.
	-- See: https://love2d.org/wiki/love.math.newBezierCurve
	newBezierCurve: function(vertices_or_coordinates: any, coordinates: number...): BezierCurve
	-- Generates a Simplex or Perlin noise value in 1-4 dimensions. The return value will always be the same,
	-- given the same arguments.
	-- See: https://love2d.org/wiki/love.math.noise
	noise: function(x: number, y?: number, z?: number, w?: number): number
	-- Generates a pseudo-random number in a platform independent manner. The default love.run seeds this function
	-- at startup, so you generally don't need to seed it yourself.
	-- See: https://love2d.org/wiki/love.math.random
	random: function(lower_or_upper?: number, upper?: number): number
	-- Get a normally distributed pseudo random number.
	-- See: https://love2d.org/wiki/love.math.randomNormal
	randomNormal: function(standard_deviation?: number, mean?: number): number
	-- Sets the seed of the random number generator using the specified integer number. This is called internally
	-- at startup, so you generally don't need to call it yourself.
	-- See: https://love2d.org/wiki/love.math.setRandomSeed
	setRandomSeed: function(low_or_seed: number, high?: number)
	-- Gets the seed of the random number generator.
	-- See: https://love2d.org/wiki/love.math.getRandomSeed
	getRandomSeed: function(): number, number
	-- Sets the current state of the random number generator. The value used as an argument for this function is
	-- an opaque implementation-dependent string and should only originate from a previous call to
	-- love.math.getRandomState.
	-- See: https://love2d.org/wiki/love.math.setRandomState
	setRandomState: function(state: string)
	-- Gets the current state of the random number generator. This returns an opaque implementation-dependent
	-- string which is only useful for later use with love.math.setRandomState or RandomGenerator:setState.
	-- See: https://love2d.org/wiki/love.math.getRandomState
	getRandomState: function(): string
	-- Converts a color from 0..1 to 0..255 range.
	-- See: https://love2d.org/wiki/love.math.colorToBytes
	colorToBytes: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number, number, number | nil
	-- Converts a color from 0..255 to 0..1 range.
	-- See: https://love2d.org/wiki/love.math.colorFromBytes
	colorFromBytes: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number, number, number | nil
	-- Converts a color from gamma-space (sRGB) to linear-space (RGB). This is useful when doing gamma-correct
	-- rendering and you need to do math in linear RGB in the few cases where LÖVE doesn't handle conversions
	-- automatically.
	-- See: https://love2d.org/wiki/love.math.gammaToLinear
	gammaToLinear: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number | nil, number | nil, number | nil
	-- Converts a color from linear-space (RGB) to gamma-space (sRGB). This is useful when storing linear RGB
	-- color values in an image, because the linear RGB color space has less precision than sRGB for dark colors,
	-- which can result in noticeable color banding when drawing.
	-- See: https://love2d.org/wiki/love.math.linearToGamma
	linearToGamma: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number | nil, number | nil, number | nil
	-- Checks whether a polygon is convex.
	-- See: https://love2d.org/wiki/love.math.isConvex
	isConvex: function(vertices_or_coordinates: any, coordinates: number...): boolean
	-- Decomposes a simple convex or concave polygon into triangles.
	-- See: https://love2d.org/wiki/love.math.triangulate
	triangulate: function(vertices_or_coordinates: any, coordinates: number...): {{number}}
	compress: function(container: string, format: string, source: any, level?: integer): string | CompressedData
	decompress: function(container: string, format_or_data: any, source?: any): string | ByteData
end
-- Represents a file on the filesystem. A function that takes a file path can also take a File.
-- See: https://love2d.org/wiki/File
local record File
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: File): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: File, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: File): boolean
	-- Open the file for write, read or append.
	-- See: https://love2d.org/wiki/File:open
	open: function(self: File, mode: FileMode): boolean | nil, string | nil
	-- Closes a File.
	-- See: https://love2d.org/wiki/File:close
	close: function(self: File): boolean
	-- Gets whether the file is open.
	-- See: https://love2d.org/wiki/File:isOpen
	isOpen: function(self: File): boolean
	-- Returns the file size.
	-- See: https://love2d.org/wiki/File:getSize
	getSize: function(self: File): number | nil, string | nil
	-- Read a number of bytes from a file.
	-- See: https://love2d.org/wiki/File:read
	read: function(self: File, container_or_size?: string | integer, size?: integer): string | FileData | nil, number | string
	-- Write data to a file.
	-- See: https://love2d.org/wiki/File:write
	write: function(self: File, data: string | FileData, size?: integer): boolean | nil, string | nil
	-- Flushes any buffered written data in the file to the disk.
	-- See: https://love2d.org/wiki/File:flush
	flush: function(self: File): boolean | nil, string | nil
	-- Gets whether end-of-file has been reached.
	-- See: https://love2d.org/wiki/File:isEOF
	isEOF: function(self: File): boolean
	-- Returns the position in the file.
	-- See: https://love2d.org/wiki/File:tell
	tell: function(self: File): number | nil, string | nil
	-- Seek to a position in a file
	-- See: https://love2d.org/wiki/File:seek
	seek: function(self: File, position: number): boolean
	-- Iterate over all the lines in a file.
	-- See: https://love2d.org/wiki/File:lines
	lines: function(self: File): function(): string | nil
	-- Sets the buffer mode for a file opened for writing or appending. Files with buffering enabled will not
	-- write data to the disk until the buffer size limit is reached, depending on the buffer mode.
	-- See: https://love2d.org/wiki/File:setBuffer
	setBuffer: function(self: File, mode: BufferMode, size?: integer): boolean
	-- Gets the buffer mode of a file.
	-- See: https://love2d.org/wiki/File:getBuffer
	getBuffer: function(self: File): BufferMode, integer
	-- Gets the FileMode the file has been opened with.
	-- See: https://love2d.org/wiki/File:getMode
	getMode: function(self: File): FileMode
	-- Gets the filename that the File object was created with. If the file object originated from the
	-- love.filedropped callback, the filename will be the full platform-dependent file path.
	-- See: https://love2d.org/wiki/File:getFilename
	getFilename: function(self: File): string
	getExtension: function(self: File): string
end
local record FileInfo
	type: FileType
	size: number | nil
	modtime: number | nil
end
-- Provides an interface to the user's filesystem.
-- See: https://love2d.org/wiki/love.filesystem
local record Filesystem
	-- Sets the write directory for your game.
	-- See: https://love2d.org/wiki/love.filesystem.setIdentity
	setIdentity: function(identity: string, append_to_path?: boolean)
	-- Gets the write directory name for your game.
	-- See: https://love2d.org/wiki/love.filesystem.getIdentity
	getIdentity: function(): string
	-- Returns the full path to the the .love file or directory. If the game is fused to the LÖVE executable, then
	-- the executable is returned.
	-- See: https://love2d.org/wiki/love.filesystem.getSource
	getSource: function(): string
	-- Gets the full path to the designated save directory.
	-- See: https://love2d.org/wiki/love.filesystem.getSaveDirectory
	getSaveDirectory: function(): string
	-- Gets the current working directory.
	-- See: https://love2d.org/wiki/love.filesystem.getWorkingDirectory
	getWorkingDirectory: function(): string
	-- Returns the path of the user's directory
	-- See: https://love2d.org/wiki/love.filesystem.getUserDirectory
	getUserDirectory: function(): string
	-- Returns the application data directory (could be the same as getUserDirectory)
	-- See: https://love2d.org/wiki/love.filesystem.getAppdataDirectory
	getAppdataDirectory: function(): string
	-- Returns the full path to the directory containing the .love file. If the game is fused to the LÖVE
	-- executable, then the directory containing the executable is returned.
	-- See: https://love2d.org/wiki/love.filesystem.getSourceBaseDirectory
	getSourceBaseDirectory: function(): string
	getExecutablePath: function(): string
	-- Gets the platform-specific absolute path of the directory containing a filepath.
	-- See: https://love2d.org/wiki/love.filesystem.getRealDirectory
	getRealDirectory: function(filename: string): string | nil, string | nil
	-- Gets the filesystem paths that will be searched when require is called.
	-- See: https://love2d.org/wiki/love.filesystem.getRequirePath
	getRequirePath: function(): string
	-- Sets the filesystem paths that will be searched when require is called.
	-- See: https://love2d.org/wiki/love.filesystem.setRequirePath
	setRequirePath: function(path: string)
	-- Mounts a zip file or folder in the game's save directory for reading.
	-- See: https://love2d.org/wiki/love.filesystem.mount
	mount: function(archive: string | FileData, mountpoint: string, append_to_path?: boolean): boolean
	-- Unmounts a zip file or folder previously mounted for reading with love.filesystem.mount.
	-- See: https://love2d.org/wiki/love.filesystem.unmount
	unmount: function(archive: string | FileData): boolean
	-- Gets whether the game is in fused mode or not.
	-- See: https://love2d.org/wiki/love.filesystem.isFused
	isFused: function(): boolean
	-- Creates a new File object.
	-- See: https://love2d.org/wiki/love.filesystem.newFile
	newFile: function(filename: string, mode?: FileMode): File
	-- Creates a new FileData object from a file on disk, or from a string in memory.
	-- See: https://love2d.org/wiki/love.filesystem.newFileData
	newFileData: function(data_or_filename_or_file: string | File, filename?: string): FileData
	-- Read the contents of a file.
	-- See: https://love2d.org/wiki/love.filesystem.read
	read: function(container_or_filename: string, filename_or_size?: string | integer, size?: integer): string | FileData | nil, number | string
	-- Loads a Lua file (but does not run it).
	-- See: https://love2d.org/wiki/love.filesystem.load
	load: function(filename: string): function | nil, string | nil
	-- Iterate over the lines in a file.
	-- See: https://love2d.org/wiki/love.filesystem.lines
	lines: function(filename: string): function(): string | nil
	-- Write data to a file in the save directory. If the file existed already, it will be completely replaced by
	-- the new contents.
	-- See: https://love2d.org/wiki/love.filesystem.write
	write: function(filename: string, data: string | FileData, size?: integer): boolean, string | nil
	-- Append data to an existing file.
	-- See: https://love2d.org/wiki/love.filesystem.append
	append: function(filename: string, data: string | FileData, size?: integer): boolean, string | nil
	-- Gets information about the specified file or directory.
	-- See: https://love2d.org/wiki/love.filesystem.getInfo
	getInfo: function(filename: string, filter_type?: FileType): FileInfo | nil
	exists: function(filename: string): boolean
	isDirectory: function(filename: string): boolean
	isFile: function(filename: string): boolean
	isSymlink: function(filename: string): boolean
	getLastModified: function(filename: string): number | nil, string | nil
	getSize: function(filename: string): number | nil, string | nil
	-- Recursively creates a directory.
	-- See: https://love2d.org/wiki/love.filesystem.createDirectory
	createDirectory: function(name: string): boolean, string | nil
	-- Removes a file or empty directory.
	-- See: https://love2d.org/wiki/love.filesystem.remove
	remove: function(name: string): boolean, string | nil
	-- Returns a table with the names of files and subdirectories in the specified path. The table is not sorted
	-- in any way; the order is undefined.
	-- See: https://love2d.org/wiki/love.filesystem.getDirectoryItems
	getDirectoryItems: function(directory?: string): {string}
end

local type QuitCallback = function(): boolean | nil

-- Provides an interface to the user's keyboard.
-- See: https://love2d.org/wiki/love.keyboard
local record Keyboard
	-- Enables or disables key repeat for love.keypressed. It is disabled by default.
	-- See: https://love2d.org/wiki/love.keyboard.setKeyRepeat
	setKeyRepeat: function(enabled: boolean)
	-- Gets whether key repeat is enabled.
	-- See: https://love2d.org/wiki/love.keyboard.hasKeyRepeat
	hasKeyRepeat: function(): boolean
	-- Checks whether a certain key is down. Not to be confused with love.keypressed or love.keyreleased.
	-- See: https://love2d.org/wiki/love.keyboard.isDown
	isDown: function(keys: string...): boolean
	-- Checks whether the specified Scancodes are pressed. Not to be confused with love.keypressed or
	-- love.keyreleased.
	-- See: https://love2d.org/wiki/love.keyboard.isScancodeDown
	isScancodeDown: function(scancodes: string...): boolean
	-- Gets the hardware scancode corresponding to the given key.
	-- See: https://love2d.org/wiki/love.keyboard.getScancodeFromKey
	getScancodeFromKey: function(key: string): string
	-- Gets the key corresponding to the given hardware scancode.
	-- See: https://love2d.org/wiki/love.keyboard.getKeyFromScancode
	getKeyFromScancode: function(scancode: string): string
	-- Enables or disables text input events. It is enabled by default on Windows, Mac, and Linux, and disabled by
	-- default on iOS and Android.
	-- See: https://love2d.org/wiki/love.keyboard.setTextInput
	setTextInput: function(enabled: boolean, x?: number, y?: number, width?: number, height?: number)
	-- Gets whether text input events are enabled.
	-- See: https://love2d.org/wiki/love.keyboard.hasTextInput
	hasTextInput: function(): boolean
	-- Gets whether screen keyboard is supported.
	-- See: https://love2d.org/wiki/love.keyboard.hasScreenKeyboard
	hasScreenKeyboard: function(): boolean
end

local enum SystemCursor
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
-- See: https://love2d.org/wiki/Cursor
local record Cursor
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Cursor): boolean
	-- Gets the type of the Cursor.
	-- See: https://love2d.org/wiki/Cursor:getType
	getType: function(self: Cursor): CursorType
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Cursor): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Cursor, type_name: string): boolean
end

-- Provides an interface to the user's mouse.
-- See: https://love2d.org/wiki/love.mouse
local record Mouse
	-- Returns the current position of the mouse.
	-- See: https://love2d.org/wiki/love.mouse.getPosition
	getPosition: function(): number, number
	-- Returns the current x-position of the mouse.
	-- See: https://love2d.org/wiki/love.mouse.getX
	getX: function(): number
	-- Returns the current y-position of the mouse.
	-- See: https://love2d.org/wiki/love.mouse.getY
	getY: function(): number
	-- Sets the current position of the mouse. Non-integer values are floored.
	-- See: https://love2d.org/wiki/love.mouse.setPosition
	setPosition: function(x: number, y: number)
	-- Sets the current X position of the mouse.
	-- See: https://love2d.org/wiki/love.mouse.setX
	setX: function(x: number)
	-- Sets the current Y position of the mouse.
	-- See: https://love2d.org/wiki/love.mouse.setY
	setY: function(y: number)
	-- Checks whether a certain mouse button is down.
	-- See: https://love2d.org/wiki/love.mouse.isDown
	isDown: function(buttons: integer | {integer}, ...: integer): boolean
	-- Sets the current visibility of the cursor.
	-- See: https://love2d.org/wiki/love.mouse.setVisible
	setVisible: function(visible: boolean)
	-- Checks if the cursor is visible.
	-- See: https://love2d.org/wiki/love.mouse.isVisible
	isVisible: function(): boolean
	-- Grabs the mouse and confines it to the window.
	-- See: https://love2d.org/wiki/love.mouse.setGrabbed
	setGrabbed: function(grabbed: boolean)
	-- Checks if the mouse is grabbed.
	-- See: https://love2d.org/wiki/love.mouse.isGrabbed
	isGrabbed: function(): boolean
	-- Sets whether relative mode is enabled for the mouse.
	-- See: https://love2d.org/wiki/love.mouse.setRelativeMode
	setRelativeMode: function(relative: boolean): boolean
	-- Gets whether relative mode is enabled for the mouse.
	-- See: https://love2d.org/wiki/love.mouse.getRelativeMode
	getRelativeMode: function(): boolean
	-- Creates a new hardware Cursor object from an image file or ImageData.
	-- See: https://love2d.org/wiki/love.mouse.newCursor
	newCursor: function(image: ImageData | FileData | string, hot_x?: integer, hot_y?: integer): Cursor
	-- Gets a Cursor object representing a system-native hardware cursor.
	-- See: https://love2d.org/wiki/love.mouse.getSystemCursor
	getSystemCursor: function(cursor_type: SystemCursor): Cursor
	-- Sets the current mouse cursor.
	-- See: https://love2d.org/wiki/love.mouse.setCursor
	setCursor: function(cursor?: Cursor)
	-- Gets the current Cursor.
	-- See: https://love2d.org/wiki/love.mouse.getCursor
	getCursor: function(): Cursor | nil
	-- Gets whether cursor functionality is supported.
	-- See: https://love2d.org/wiki/love.mouse.isCursorSupported
	isCursorSupported: function(): boolean
end

-- Provides an interface to the user's clock.
-- See: https://love2d.org/wiki/love.timer
local record Timer
	-- Measures the time between two frames.
	-- See: https://love2d.org/wiki/love.timer.step
	step: function(): number
	-- Returns the time between the last two frames.
	-- See: https://love2d.org/wiki/love.timer.getDelta
	getDelta: function(): number
	-- Returns the current frames per second.
	-- See: https://love2d.org/wiki/love.timer.getFPS
	getFPS: function(): integer
	-- Returns the average delta time (seconds per frame) over the last second.
	-- See: https://love2d.org/wiki/love.timer.getAverageDelta
	getAverageDelta: function(): number
	-- Pauses the current thread for the specified amount of time.
	-- See: https://love2d.org/wiki/love.timer.sleep
	sleep: function(seconds: number)
	-- Returns the value of a timer with an unspecified starting time.
	-- See: https://love2d.org/wiki/love.timer.getTime
	getTime: function(): number
end

-- Provides access to information about the user's system.
-- See: https://love2d.org/wiki/love.system
local record System
	-- Gets the current operating system. In general, LÖVE abstracts away the need to know the current operating
	-- system, but there are a few cases where it can be useful (especially in combination with os.execute.)
	-- See: https://love2d.org/wiki/love.system.getOS
	getOS: function(): string
	-- Gets the amount of logical processor in the system.
	-- See: https://love2d.org/wiki/love.system.getProcessorCount
	getProcessorCount: function(): integer
	-- Puts text in the clipboard.
	-- See: https://love2d.org/wiki/love.system.setClipboardText
	setClipboardText: function(text: string)
	-- Gets text from the clipboard.
	-- See: https://love2d.org/wiki/love.system.getClipboardText
	getClipboardText: function(): string
	-- Gets information about the system's power supply.
	-- See: https://love2d.org/wiki/love.system.getPowerInfo
	getPowerInfo: function(): string, integer | nil, integer | nil
	-- 嵌入式 LoveNode 仅允许 http、https 和 mailto scheme。
	-- Opens a URL with the user's web or file browser.
	-- See: https://love2d.org/wiki/love.system.openURL
	openURL: function(url: string): boolean
	-- Causes the device to vibrate, if possible. Currently this will only work on Android and iOS devices that
	-- have a built-in vibration motor.
	-- See: https://love2d.org/wiki/love.system.vibrate
	vibrate: function(seconds?: number)
	-- Gets whether another application on the system is playing music in the background.
	-- See: https://love2d.org/wiki/love.system.hasBackgroundMusic
	hasBackgroundMusic: function(): boolean
end

-- A Thread is a chunk of code that can run in parallel with other threads. Data can be sent between different
-- threads with Channel objects.
-- See: https://love2d.org/wiki/Thread
local record Thread
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Thread): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Thread): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Thread, type_name: string): boolean
	-- Starts the thread.
	-- See: https://love2d.org/wiki/Thread:start
	start: function(self: Thread, args: any...): boolean
	-- Wait for a thread to finish.
	-- See: https://love2d.org/wiki/Thread:wait
	wait: function(self: Thread)
	-- Retrieves the error string from the thread if it produced an error.
	-- See: https://love2d.org/wiki/Thread:getError
	getError: function(self: Thread): string | nil
	-- Returns whether the thread is currently running.
	-- See: https://love2d.org/wiki/Thread:isRunning
	isRunning: function(self: Thread): boolean
end

-- An object which can be used to send and receive data between different threads.
-- See: https://love2d.org/wiki/Channel
local record Channel
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Channel): boolean
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Channel): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Channel, type_name: string): boolean
	-- Send a message to the thread Channel.
	-- See: https://love2d.org/wiki/Channel:push
	push: function(self: Channel, value: any): number
	-- Send a message to the thread Channel and wait for a thread to accept it.
	-- See: https://love2d.org/wiki/Channel:supply
	supply: function(self: Channel, value: any, timeout?: number): boolean
	-- Retrieves the value of a Channel message and removes it from the message queue.
	-- See: https://love2d.org/wiki/Channel:pop
	pop: function(self: Channel): any
	-- Retrieves the value of a Channel message and removes it from the message queue.
	-- See: https://love2d.org/wiki/Channel:demand
	demand: function(self: Channel, timeout?: number): any
	-- Retrieves the value of a Channel message, but leaves it in the queue.
	-- See: https://love2d.org/wiki/Channel:peek
	peek: function(self: Channel): any
	-- Retrieves the number of messages in the thread Channel queue.
	-- See: https://love2d.org/wiki/Channel:getCount
	getCount: function(self: Channel): integer
	-- Gets whether a pushed value has been popped or otherwise removed from the Channel.
	-- See: https://love2d.org/wiki/Channel:hasRead
	hasRead: function(self: Channel, id: number): boolean
	-- Clears all the messages in the Channel queue.
	-- See: https://love2d.org/wiki/Channel:clear
	clear: function(self: Channel)
	-- Executes the specified function atomically with respect to this Channel.
	-- See: https://love2d.org/wiki/Channel:performAtomic
	performAtomic: function(self: Channel, callback: any, args: any...): any
end

-- Allows you to work with threads.
-- See: https://love2d.org/wiki/love.thread
local record ThreadModule
	-- Creates a new Thread from a filename, string or FileData object containing Lua code.
	-- See: https://love2d.org/wiki/love.thread.newThread
	newThread: function(code_or_filename: string | any): Thread
	-- Create a new unnamed thread channel.
	-- See: https://love2d.org/wiki/love.thread.newChannel
	newChannel: function(): Channel
	-- Creates or retrieves a named thread channel.
	-- See: https://love2d.org/wiki/love.thread.getChannel
	getChannel: function(name: string): Channel
end

local record AudioFilterSettings
	type: string
	volume: number
	lowgain: number
	highgain: number
end

local record AudioEffectSettings
	type: string
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
-- See: https://love2d.org/wiki/Source
local record Source
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Source): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Source, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Source): boolean
	-- Creates an identical copy of the Source in the stopped state.
	-- See: https://love2d.org/wiki/Source:clone
	clone: function(self: Source): Source
	-- Starts playing the Source.
	-- See: https://love2d.org/wiki/Source:play
	play: function(self: Source): boolean
	-- Pauses the Source.
	-- See: https://love2d.org/wiki/Source:pause
	pause: function(self: Source)
	-- Stops a Source.
	-- See: https://love2d.org/wiki/Source:stop
	stop: function(self: Source)
	-- Returns whether the Source is playing.
	-- See: https://love2d.org/wiki/Source:isPlaying
	isPlaying: function(self: Source): boolean
	isPaused: function(self: Source): boolean
	-- Sets whether the Source should loop.
	-- See: https://love2d.org/wiki/Source:setLooping
	setLooping: function(self: Source, looping: boolean)
	-- Returns whether the Source will loop.
	-- See: https://love2d.org/wiki/Source:isLooping
	isLooping: function(self: Source): boolean
	-- Sets the current volume of the Source.
	-- See: https://love2d.org/wiki/Source:setVolume
	setVolume: function(self: Source, volume: number)
	-- Gets the current volume of the Source.
	-- See: https://love2d.org/wiki/Source:getVolume
	getVolume: function(self: Source): number
	-- Sets the pitch of the Source.
	-- See: https://love2d.org/wiki/Source:setPitch
	setPitch: function(self: Source, pitch: number)
	-- Gets the current pitch of the Source.
	-- See: https://love2d.org/wiki/Source:getPitch
	getPitch: function(self: Source): number
	-- Sets the currently playing position of the Source.
	-- See: https://love2d.org/wiki/Source:seek
	seek: function(self: Source, offset: number, unit?: string)
	-- Gets the currently playing position of the Source.
	-- See: https://love2d.org/wiki/Source:tell
	tell: function(self: Source, unit?: string): number
	-- Gets the duration of the Source. For streaming Sources it may not always be sample-accurate, and may return
	-- -1 if the duration cannot be determined at all.
	-- See: https://love2d.org/wiki/Source:getDuration
	getDuration: function(self: Source, unit?: string): number
	-- Gets the number of channels in the Source. Only 1-channel (mono) Sources can use directional and positional
	-- effects.
	-- See: https://love2d.org/wiki/Source:getChannelCount
	getChannelCount: function(self: Source): integer
	getChannels: function(self: Source): integer
	-- Gets the number of free buffer slots in a queueable Source. If the queueable Source is playing, this value
	-- will increase up to the amount the Source was created with. If the queueable Source is stopped, it will
	-- process all of its internal buffers first, in which case this function will always return the amount it was
	-- created with.
	-- See: https://love2d.org/wiki/Source:getFreeBufferCount
	getFreeBufferCount: function(self: Source): integer
	-- Queues SoundData for playback in a queueable Source.
	-- See: https://love2d.org/wiki/Source:queue
	queue: function(self: Source, data: SoundData, offset_or_length?: number, length?: number): boolean
	-- Sets the position of the Source. Please note that this only works for mono (i.e. non-stereo) sound files!
	-- See: https://love2d.org/wiki/Source:setPosition
	setPosition: function(self: Source, x: number, y: number, z?: number)
	-- Gets the position of the Source.
	-- See: https://love2d.org/wiki/Source:getPosition
	getPosition: function(self: Source): number, number, number
	-- Sets the velocity of the Source.
	-- See: https://love2d.org/wiki/Source:setVelocity
	setVelocity: function(self: Source, x: number, y: number, z?: number)
	-- Gets the velocity of the Source.
	-- See: https://love2d.org/wiki/Source:getVelocity
	getVelocity: function(self: Source): number, number, number
	-- Sets the direction vector of the Source. A zero vector makes the source non-directional.
	-- See: https://love2d.org/wiki/Source:setDirection
	setDirection: function(self: Source, x: number, y: number, z?: number)
	-- Gets the direction of the Source.
	-- See: https://love2d.org/wiki/Source:getDirection
	getDirection: function(self: Source): number, number, number
	-- Sets the Source's directional volume cones. Together with Source:setDirection, the cone angles allow for
	-- the Source's volume to vary depending on its direction.
	-- See: https://love2d.org/wiki/Source:setCone
	setCone: function(self: Source, inner_angle: number, outer_angle: number, outer_volume?: number, outer_high_gain?: number)
	-- Gets the Source's directional volume cones. Together with Source:setDirection, the cone angles allow for
	-- the Source's volume to vary depending on its direction.
	-- See: https://love2d.org/wiki/Source:getCone
	getCone: function(self: Source): number, number, number, number
	-- Sets the amount of air absorption applied to the Source.
	-- See: https://love2d.org/wiki/Source:setAirAbsorption
	setAirAbsorption: function(self: Source, factor: number)
	-- Gets the amount of air absorption applied to the Source.
	-- See: https://love2d.org/wiki/Source:getAirAbsorption
	getAirAbsorption: function(self: Source): number
	-- Sets the volume limits of the source. The limits have to be numbers from 0 to 1.
	-- See: https://love2d.org/wiki/Source:setVolumeLimits
	setVolumeLimits: function(self: Source, min_volume: number, max_volume: number)
	-- Returns the volume limits of the source.
	-- See: https://love2d.org/wiki/Source:getVolumeLimits
	getVolumeLimits: function(self: Source): number, number
	-- Sets whether the Source's position, velocity, direction, and cone angles are relative to the listener, or
	-- absolute.
	-- See: https://love2d.org/wiki/Source:setRelative
	setRelative: function(self: Source, relative: boolean)
	-- Gets whether the Source's position, velocity, direction, and cone angles are relative to the listener.
	-- See: https://love2d.org/wiki/Source:isRelative
	isRelative: function(self: Source): boolean
	-- Sets the reference and maximum attenuation distances of the Source. The parameters, combined with the
	-- current DistanceModel, affect how the Source's volume attenuates based on distance.
	-- See: https://love2d.org/wiki/Source:setAttenuationDistances
	setAttenuationDistances: function(self: Source, reference_distance: number, max_distance: number)
	-- Gets the reference and maximum attenuation distances of the Source. The values, combined with the current
	-- DistanceModel, affect how the Source's volume attenuates based on distance from the listener.
	-- See: https://love2d.org/wiki/Source:getAttenuationDistances
	getAttenuationDistances: function(self: Source): number, number
	-- Sets the rolloff factor which affects the strength of the used distance attenuation.
	-- See: https://love2d.org/wiki/Source:setRolloff
	setRolloff: function(self: Source, rolloff: number)
	-- Returns the rolloff factor of the source.
	-- See: https://love2d.org/wiki/Source:getRolloff
	getRolloff: function(self: Source): number
	-- Sets a low-pass, high-pass, or band-pass filter to apply when playing the Source.
	-- See: https://love2d.org/wiki/Source:setFilter
	setFilter: function(self: Source, filter?: AudioFilterSettings): boolean
	-- Gets the filter settings currently applied to the Source.
	-- See: https://love2d.org/wiki/Source:getFilter
	getFilter: function(self: Source, target?: AudioFilterSettings): AudioFilterSettings | nil
	-- Applies an audio effect to the Source.
	-- See: https://love2d.org/wiki/Source:setEffect
	setEffect: function(self: Source, name: string, enabled?: boolean | AudioFilterSettings): boolean
	-- Gets the filter settings associated to a specific effect.
	-- See: https://love2d.org/wiki/Source:getEffect
	getEffect: function(self: Source, name: string, target?: AudioFilterSettings): boolean, AudioFilterSettings | nil
	-- Gets a list of the Source's active effect names.
	-- See: https://love2d.org/wiki/Source:getActiveEffects
	getActiveEffects: function(self: Source): {string}
	-- Gets the type of the Source.
	-- See: https://love2d.org/wiki/Source:getType
	getType: function(self: Source): string
end

-- Represents an audio input device capable of recording sounds.
-- See: https://love2d.org/wiki/RecordingDevice
local record RecordingDevice
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: RecordingDevice): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: RecordingDevice, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: RecordingDevice): boolean
	-- Begins recording audio using this device.
	-- See: https://love2d.org/wiki/RecordingDevice:start
	start: function(self: RecordingDevice, samples?: integer, sample_rate?: integer, bit_depth?: integer, channels?: integer): boolean
	-- Stops recording audio from this device. Any sound data currently in the device's buffer will be returned.
	-- See: https://love2d.org/wiki/RecordingDevice:stop
	stop: function(self: RecordingDevice): SoundData | nil
	-- Gets all recorded audio SoundData stored in the device's internal ring buffer.
	-- See: https://love2d.org/wiki/RecordingDevice:getData
	getData: function(self: RecordingDevice): SoundData | nil
	-- Gets the number of currently recorded samples.
	-- See: https://love2d.org/wiki/RecordingDevice:getSampleCount
	getSampleCount: function(self: RecordingDevice): integer
	-- Gets the number of samples per second currently being recorded.
	-- See: https://love2d.org/wiki/RecordingDevice:getSampleRate
	getSampleRate: function(self: RecordingDevice): integer
	-- Gets the number of bits per sample in the data currently being recorded.
	-- See: https://love2d.org/wiki/RecordingDevice:getBitDepth
	getBitDepth: function(self: RecordingDevice): integer
	-- Gets the number of channels currently being recorded (mono or stereo).
	-- See: https://love2d.org/wiki/RecordingDevice:getChannelCount
	getChannelCount: function(self: RecordingDevice): integer
	-- Gets the name of the recording device.
	-- See: https://love2d.org/wiki/RecordingDevice:getName
	getName: function(self: RecordingDevice): string
	-- Gets whether the device is currently recording.
	-- See: https://love2d.org/wiki/RecordingDevice:isRecording
	isRecording: function(self: RecordingDevice): boolean
end

-- Provides an interface to create noise with the user's speakers.
-- See: https://love2d.org/wiki/love.audio
local record Audio
	-- Creates a new Source from a filepath, File, Decoder or SoundData.
	-- See: https://love2d.org/wiki/love.audio.newSource
	newSource: function(filename_or_data: string | SoundData, source_type?: string): Source
	-- Creates a new Source usable for real-time generated sound playback with Source:queue.
	-- See: https://love2d.org/wiki/love.audio.newQueueableSource
	newQueueableSource: function(sample_rate: integer, bit_depth: integer, channels: integer, buffers?: integer): Source
	-- Plays the specified Source.
	-- See: https://love2d.org/wiki/love.audio.play
	play: function(sources: {Source}): boolean
	play: function(sources: Source...): boolean
	-- Pauses specific or all currently played Sources.
	-- See: https://love2d.org/wiki/love.audio.pause
	pause: function(): {Source}
	pause: function(sources: {Source})
	pause: function(sources: Source...)
	-- Stops currently played sources.
	-- See: https://love2d.org/wiki/love.audio.stop
	stop: function(sources: {Source})
	stop: function(sources: Source...)
	-- Gets the current number of simultaneously playing sources.
	-- See: https://love2d.org/wiki/love.audio.getActiveSourceCount
	getActiveSourceCount: function(): integer
	getSourceCount: function(): integer
	-- Sets the master volume.
	-- See: https://love2d.org/wiki/love.audio.setVolume
	setVolume: function(volume: number)
	-- Returns the master volume.
	-- See: https://love2d.org/wiki/love.audio.getVolume
	getVolume: function(): number
	-- 设置应用级 iOS 音频会话混音策略。其他平台返回 false。
	-- Sets whether the system should mix the audio with the system's audio.
	-- See: https://love2d.org/wiki/love.audio.setMixWithSystem
	setMixWithSystem: function(mix: boolean): boolean
	-- Sets the position of the listener, which determines how sounds play.
	-- See: https://love2d.org/wiki/love.audio.setPosition
	setPosition: function(x: number, y: number, z?: number)
	-- Returns the position of the listener. Please note that positional audio only works for mono (i.e.
	-- non-stereo) sources.
	-- See: https://love2d.org/wiki/love.audio.getPosition
	getPosition: function(): number, number, number
	-- Sets the orientation of the listener.
	-- See: https://love2d.org/wiki/love.audio.setOrientation
	setOrientation: function(forward_x: number, forward_y: number, forward_z: number,
		up_x: number, up_y: number, up_z: number)
	-- Returns the orientation of the listener.
	-- See: https://love2d.org/wiki/love.audio.getOrientation
	getOrientation: function(): number, number, number, number, number, number
	-- Sets the velocity of the listener.
	-- See: https://love2d.org/wiki/love.audio.setVelocity
	setVelocity: function(x: number, y: number, z?: number)
	-- Returns the velocity of the listener.
	-- See: https://love2d.org/wiki/love.audio.getVelocity
	getVelocity: function(): number, number, number
	-- Sets a global scale factor for velocity-based doppler effects. The default scale value is 1.
	-- See: https://love2d.org/wiki/love.audio.setDopplerScale
	setDopplerScale: function(scale: number)
	-- Gets the current global scale factor for velocity-based doppler effects.
	-- See: https://love2d.org/wiki/love.audio.getDopplerScale
	getDopplerScale: function(): number
	-- Sets the distance attenuation model.
	-- See: https://love2d.org/wiki/love.audio.setDistanceModel
	setDistanceModel: function(model: string)
	-- Returns the distance attenuation model.
	-- See: https://love2d.org/wiki/love.audio.getDistanceModel
	getDistanceModel: function(): string
	-- Defines an effect that can be applied to a Source.
	-- See: https://love2d.org/wiki/love.audio.setEffect
	setEffect: function(name: string, settings?: AudioEffectSettings | boolean): boolean
	-- Gets the settings associated with an effect.
	-- See: https://love2d.org/wiki/love.audio.getEffect
	getEffect: function(name: string, target?: AudioEffectSettings): AudioEffectSettings | nil
	-- Gets a list of the names of the currently enabled effects.
	-- See: https://love2d.org/wiki/love.audio.getActiveEffects
	getActiveEffects: function(): {string}
	-- Gets the maximum number of active effects supported by the system.
	-- See: https://love2d.org/wiki/love.audio.getMaxSceneEffects
	getMaxSceneEffects: function(): integer
	-- Gets the maximum number of active Effects in a single Source object, that the system can support.
	-- See: https://love2d.org/wiki/love.audio.getMaxSourceEffects
	getMaxSourceEffects: function(): integer
	-- Gets a list of RecordingDevices on the system.
	-- See: https://love2d.org/wiki/love.audio.getRecordingDevices
	getRecordingDevices: function(): {RecordingDevice}
	-- Gets whether audio effects are supported in the system.
	-- See: https://love2d.org/wiki/love.audio.isEffectsSupported
	isEffectsSupported: function(): boolean
end

-- Bodies are objects with velocity and position.
-- See: https://love2d.org/wiki/Body
local record Body
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Body): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Body, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Body): boolean
	-- Explicitly destroys the Body and all fixtures and joints attached to it.
	-- See: https://love2d.org/wiki/Body:destroy
	destroy: function(self: Body)
	-- Gets whether the Body is destroyed. Destroyed bodies cannot be used.
	-- See: https://love2d.org/wiki/Body:isDestroyed
	isDestroyed: function(self: Body): boolean
	-- Get the position of the body.
	-- See: https://love2d.org/wiki/Body:getPosition
	getPosition: function(self: Body): number, number
	-- Set the position of the body.
	-- See: https://love2d.org/wiki/Body:setPosition
	setPosition: function(self: Body, x: number, y: number)
	-- Get the x position of the body in world coordinates.
	-- See: https://love2d.org/wiki/Body:getX
	getX: function(self: Body): number
	-- Set the x position of the body.
	-- See: https://love2d.org/wiki/Body:setX
	setX: function(self: Body, x: number)
	-- Get the y position of the body in world coordinates.
	-- See: https://love2d.org/wiki/Body:getY
	getY: function(self: Body): number
	-- Set the y position of the body.
	-- See: https://love2d.org/wiki/Body:setY
	setY: function(self: Body, y: number)
	-- Get the position and angle of the body.
	-- See: https://love2d.org/wiki/Body:getTransform
	getTransform: function(self: Body): number, number, number
	-- Set the position and angle of the body.
	-- See: https://love2d.org/wiki/Body:setTransform
	setTransform: function(self: Body, x: number, y: number, angle: number)
	-- Get the angle of the body.
	-- See: https://love2d.org/wiki/Body:getAngle
	getAngle: function(self: Body): number
	-- Set the angle of the body.
	-- See: https://love2d.org/wiki/Body:setAngle
	setAngle: function(self: Body, angle: number)
	-- Gets the linear velocity of the Body from its center of mass.
	-- See: https://love2d.org/wiki/Body:getLinearVelocity
	getLinearVelocity: function(self: Body): number, number
	-- Sets a new linear velocity for the Body.
	-- See: https://love2d.org/wiki/Body:setLinearVelocity
	setLinearVelocity: function(self: Body, x: number, y: number)
	-- Get the angular velocity of the Body.
	-- See: https://love2d.org/wiki/Body:getAngularVelocity
	getAngularVelocity: function(self: Body): number
	-- Sets the angular velocity of a Body.
	-- See: https://love2d.org/wiki/Body:setAngularVelocity
	setAngularVelocity: function(self: Body, velocity: number)
	-- Gets the linear damping of the Body.
	-- See: https://love2d.org/wiki/Body:getLinearDamping
	getLinearDamping: function(self: Body): number
	-- Sets the linear damping of a Body
	-- See: https://love2d.org/wiki/Body:setLinearDamping
	setLinearDamping: function(self: Body, damping: number)
	-- Gets the Angular damping of the Body
	-- See: https://love2d.org/wiki/Body:getAngularDamping
	getAngularDamping: function(self: Body): number
	-- Sets the angular damping of a Body
	-- See: https://love2d.org/wiki/Body:setAngularDamping
	setAngularDamping: function(self: Body, damping: number)
	-- Get the mass of the body.
	-- See: https://love2d.org/wiki/Body:getMass
	getMass: function(self: Body): number
	-- Sets a new body mass.
	-- See: https://love2d.org/wiki/Body:setMass
	setMass: function(self: Body, mass: number)
	-- Gets the rotational inertia of the body.
	-- See: https://love2d.org/wiki/Body:getInertia
	getInertia: function(self: Body): number
	-- Set the inertia of a body.
	-- See: https://love2d.org/wiki/Body:setInertia
	setInertia: function(self: Body, inertia: number)
	-- Returns the mass, its center, and the rotational inertia.
	-- See: https://love2d.org/wiki/Body:getMassData
	getMassData: function(self: Body): number, number, number, number
	-- Overrides the calculated mass data.
	-- See: https://love2d.org/wiki/Body:setMassData
	setMassData: function(self: Body, center_x: number, center_y: number, mass: number, inertia: number)
	-- Resets the mass of the body by recalculating it from the mass properties of the fixtures.
	-- See: https://love2d.org/wiki/Body:resetMassData
	resetMassData: function(self: Body)
	-- Returns the gravity scale factor.
	-- See: https://love2d.org/wiki/Body:getGravityScale
	getGravityScale: function(self: Body): number
	-- Sets a new gravity scale factor for the body.
	-- See: https://love2d.org/wiki/Body:setGravityScale
	setGravityScale: function(self: Body, scale: number)
	-- Get the center of mass position in local coordinates.
	-- See: https://love2d.org/wiki/Body:getLocalCenter
	getLocalCenter: function(self: Body): number, number
	-- Get the center of mass position in world coordinates.
	-- See: https://love2d.org/wiki/Body:getWorldCenter
	getWorldCenter: function(self: Body): number, number
	-- Returns whether the body rotation is locked.
	-- See: https://love2d.org/wiki/Body:isFixedRotation
	isFixedRotation: function(self: Body): boolean
	-- Set whether a body has fixed rotation.
	-- See: https://love2d.org/wiki/Body:setFixedRotation
	setFixedRotation: function(self: Body, fixed: boolean)
	-- Returns the sleep status of the body.
	-- See: https://love2d.org/wiki/Body:isAwake
	isAwake: function(self: Body): boolean
	-- Wakes the body up or puts it to sleep.
	-- See: https://love2d.org/wiki/Body:setAwake
	setAwake: function(self: Body, awake: boolean)
	-- Returns the sleeping behaviour of the body.
	-- See: https://love2d.org/wiki/Body:isSleepingAllowed
	isSleepingAllowed: function(self: Body): boolean
	-- Sets the sleeping behaviour of the body. Should sleeping be allowed, a body at rest will automatically
	-- sleep. A sleeping body is not simulated unless it collided with an awake body. Be wary that one can end up
	-- with a situation like a floating sleeping body if the floor was removed.
	-- See: https://love2d.org/wiki/Body:setSleepingAllowed
	setSleepingAllowed: function(self: Body, allowed: boolean)
	-- Returns whether the body is actively used in the simulation.
	-- See: https://love2d.org/wiki/Body:isActive
	isActive: function(self: Body): boolean
	-- Sets whether the body is active in the world.
	-- See: https://love2d.org/wiki/Body:setActive
	setActive: function(self: Body, active: boolean)
	-- Get the bullet status of a body.
	-- See: https://love2d.org/wiki/Body:isBullet
	isBullet: function(self: Body): boolean
	-- Set the bullet status of a body.
	-- See: https://love2d.org/wiki/Body:setBullet
	setBullet: function(self: Body, bullet: boolean)
	-- Applies an impulse to a body.
	-- See: https://love2d.org/wiki/Body:applyLinearImpulse
	applyLinearImpulse: function(self: Body, x_impulse: number, y_impulse: number, point_x?: number, point_y?: number)
	-- Applies an angular impulse to a body. This makes a single, instantaneous addition to the body momentum.
	-- See: https://love2d.org/wiki/Body:applyAngularImpulse
	applyAngularImpulse: function(self: Body, impulse: number)
	-- Apply force to a Body.
	-- See: https://love2d.org/wiki/Body:applyForce
	applyForce: function(self: Body, x_force: number, y_force: number, point_x?: number, point_y?: number)
	-- Apply torque to a body.
	-- See: https://love2d.org/wiki/Body:applyTorque
	applyTorque: function(self: Body, torque: number)
	-- Returns the type of the body.
	-- See: https://love2d.org/wiki/Body:getType
	getType: function(self: Body): string
	-- Sets a new body type.
	-- See: https://love2d.org/wiki/Body:setType
	setType: function(self: Body, body_type: string)
	-- Transform a point from local coordinates to world coordinates.
	-- See: https://love2d.org/wiki/Body:getWorldPoint
	getWorldPoint: function(self: Body, x: number, y: number): number, number
	-- Transform a vector from local coordinates to world coordinates.
	-- See: https://love2d.org/wiki/Body:getWorldVector
	getWorldVector: function(self: Body, x: number, y: number): number, number
	-- Transforms multiple points from local coordinates to world coordinates.
	-- See: https://love2d.org/wiki/Body:getWorldPoints
	getWorldPoints: function(self: Body, x: number, y: number, coordinates: number...): number...
	-- Transform a point from world coordinates to local coordinates.
	-- See: https://love2d.org/wiki/Body:getLocalPoint
	getLocalPoint: function(self: Body, x: number, y: number): number, number
	-- Transform a vector from world coordinates to local coordinates.
	-- See: https://love2d.org/wiki/Body:getLocalVector
	getLocalVector: function(self: Body, x: number, y: number): number, number
	-- Transforms multiple points from world coordinates to local coordinates.
	-- See: https://love2d.org/wiki/Body:getLocalPoints
	getLocalPoints: function(self: Body, x: number, y: number, coordinates: number...): number...
	-- Get the linear velocity of a point on the body.
	-- See: https://love2d.org/wiki/Body:getLinearVelocityFromWorldPoint
	getLinearVelocityFromWorldPoint: function(self: Body, x: number, y: number): number, number
	-- Get the linear velocity of a point on the body.
	-- See: https://love2d.org/wiki/Body:getLinearVelocityFromLocalPoint
	getLinearVelocityFromLocalPoint: function(self: Body, x: number, y: number): number, number
end

-- Shapes are solid 2d geometrical objects which handle the mass and collision of a Body in love.physics.
-- See: https://love2d.org/wiki/Shape
local record Shape
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Shape): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Shape, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Shape): boolean
	-- Gets a string representing the Shape.
	-- See: https://love2d.org/wiki/Shape:getType
	getType: function(self: Shape): string
	-- Gets the radius of the shape.
	-- See: https://love2d.org/wiki/Shape:getRadius
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
-- See: https://love2d.org/wiki/Fixture
local record Fixture
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Fixture): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Fixture, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Fixture): boolean
	-- Destroys the fixture.
	-- See: https://love2d.org/wiki/Fixture:destroy
	destroy: function(self: Fixture)
	-- Gets whether the Fixture is destroyed. Destroyed fixtures cannot be used.
	-- See: https://love2d.org/wiki/Fixture:isDestroyed
	isDestroyed: function(self: Fixture): boolean
	getType: function(self: Fixture): string
	-- Sets the friction of the fixture.
	-- See: https://love2d.org/wiki/Fixture:setFriction
	setFriction: function(self: Fixture, friction: number)
	-- Returns the friction of the fixture.
	-- See: https://love2d.org/wiki/Fixture:getFriction
	getFriction: function(self: Fixture): number
	-- Sets the restitution of the fixture.
	-- See: https://love2d.org/wiki/Fixture:setRestitution
	setRestitution: function(self: Fixture, restitution: number)
	-- Returns the restitution of the fixture.
	-- See: https://love2d.org/wiki/Fixture:getRestitution
	getRestitution: function(self: Fixture): number
	-- Sets the density of the fixture. Call Body:resetMassData if this needs to take effect immediately.
	-- See: https://love2d.org/wiki/Fixture:setDensity
	setDensity: function(self: Fixture, density: number)
	-- Returns the density of the fixture.
	-- See: https://love2d.org/wiki/Fixture:getDensity
	getDensity: function(self: Fixture): number
	-- Sets whether the fixture should act as a sensor.
	-- See: https://love2d.org/wiki/Fixture:setSensor
	setSensor: function(self: Fixture, sensor: boolean)
	-- Returns whether the fixture is a sensor.
	-- See: https://love2d.org/wiki/Fixture:isSensor
	isSensor: function(self: Fixture): boolean
	-- Returns the body to which the fixture is attached.
	-- See: https://love2d.org/wiki/Fixture:getBody
	getBody: function(self: Fixture): Body
	-- Returns the shape of the fixture. This shape is a reference to the actual data used in the simulation. It's
	-- possible to change its values between timesteps.
	-- See: https://love2d.org/wiki/Fixture:getShape
	getShape: function(self: Fixture): Shape
	-- Checks if a point is inside the shape of the fixture.
	-- See: https://love2d.org/wiki/Fixture:testPoint
	testPoint: function(self: Fixture, x: number, y: number): boolean
	-- Casts a ray against the shape of the fixture and returns the surface normal vector and the line position
	-- where the ray hit. If the ray missed the shape, nil will be returned.
	-- See: https://love2d.org/wiki/Fixture:rayCast
	rayCast: function(self: Fixture, x1: number, y1: number, x2: number, y2: number, max_fraction: number, child_index?: integer): number | nil, number | nil, number | nil
	-- Sets the filter data of the fixture.
	-- See: https://love2d.org/wiki/Fixture:setFilterData
	setFilterData: function(self: Fixture, category_bits: integer, mask_bits: integer, group_index: integer)
	-- Returns the filter data of the fixture.
	-- See: https://love2d.org/wiki/Fixture:getFilterData
	getFilterData: function(self: Fixture): integer, integer, integer
	-- Sets the categories the fixture belongs to. There can be up to 16 categories represented as a number from 1
	-- to 16.
	-- See: https://love2d.org/wiki/Fixture:setCategory
	setCategory: function(self: Fixture, categories: integer | {integer}, ...: integer)
	-- Returns the categories the fixture belongs to.
	-- See: https://love2d.org/wiki/Fixture:getCategory
	getCategory: function(self: Fixture): integer...
	-- Sets the category mask of the fixture. There can be up to 16 categories represented as a number from 1 to
	-- 16.
	-- See: https://love2d.org/wiki/Fixture:setMask
	setMask: function(self: Fixture, categories: integer | {integer}, ...: integer)
	-- Returns which categories this fixture should '''NOT''' collide with.
	-- See: https://love2d.org/wiki/Fixture:getMask
	getMask: function(self: Fixture): integer...
	-- Associates a Lua value with the fixture.
	-- See: https://love2d.org/wiki/Fixture:setUserData
	setUserData: function(self: Fixture, value: any)
	-- Returns the Lua value associated with this fixture.
	-- See: https://love2d.org/wiki/Fixture:getUserData
	getUserData: function(self: Fixture): any
	-- Returns the points of the fixture bounding box. In case the fixture has multiple children a 1-based index
	-- can be specified. For example, a fixture will have multiple children with a chain shape.
	-- See: https://love2d.org/wiki/Fixture:getBoundingBox
	getBoundingBox: function(self: Fixture, child_index?: integer): number, number, number, number
	-- Returns the mass, its center and the rotational inertia.
	-- See: https://love2d.org/wiki/Fixture:getMassData
	getMassData: function(self: Fixture): number, number, number, number
	-- Returns the group the fixture belongs to. Fixtures with the same group will always collide if the group is
	-- positive or never collide if it's negative. The group zero means no group.
	-- See: https://love2d.org/wiki/Fixture:getGroupIndex
	getGroupIndex: function(self: Fixture): integer
	-- Sets the group the fixture belongs to. Fixtures with the same group will always collide if the group is
	-- positive or never collide if it's negative. The group zero means no group.
	-- See: https://love2d.org/wiki/Fixture:setGroupIndex
	setGroupIndex: function(self: Fixture, index: integer)
end

-- Contacts are objects created to manage collisions in worlds.
-- See: https://love2d.org/wiki/Contact
local record Contact
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Contact): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Contact, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Contact): boolean
	isValid: function(self: Contact): boolean
	-- Gets the two Fixtures that hold the shapes that are in contact.
	-- See: https://love2d.org/wiki/Contact:getFixtures
	getFixtures: function(self: Contact): Fixture, Fixture
	-- Gets the child indices of the shapes of the two colliding fixtures. For ChainShapes, an index of 1 is the
	-- first edge in the chain. Used together with Fixture:rayCast or ChainShape:getChildEdge.
	-- See: https://love2d.org/wiki/Contact:getChildren
	getChildren: function(self: Contact): integer, integer
	-- Returns the contact points of the two colliding fixtures. There can be one or two points.
	-- See: https://love2d.org/wiki/Contact:getPositions
	getPositions: function(self: Contact): number...
	-- Get the normal vector between two shapes that are in contact.
	-- See: https://love2d.org/wiki/Contact:getNormal
	getNormal: function(self: Contact): number, number
	-- Get the friction between two shapes that are in contact.
	-- See: https://love2d.org/wiki/Contact:getFriction
	getFriction: function(self: Contact): number
	-- Sets the contact friction.
	-- See: https://love2d.org/wiki/Contact:setFriction
	setFriction: function(self: Contact, friction: number)
	-- Resets the contact friction to the mixture value of both fixtures.
	-- See: https://love2d.org/wiki/Contact:resetFriction
	resetFriction: function(self: Contact)
	-- Get the restitution between two shapes that are in contact.
	-- See: https://love2d.org/wiki/Contact:getRestitution
	getRestitution: function(self: Contact): number
	-- Sets the contact restitution.
	-- See: https://love2d.org/wiki/Contact:setRestitution
	setRestitution: function(self: Contact, restitution: number)
	-- Resets the contact restitution to the mixture value of both fixtures.
	-- See: https://love2d.org/wiki/Contact:resetRestitution
	resetRestitution: function(self: Contact)
	-- Returns whether the contact is enabled. The collision will be ignored if a contact gets disabled in the
	-- preSolve callback.
	-- See: https://love2d.org/wiki/Contact:isEnabled
	isEnabled: function(self: Contact): boolean
	-- Enables or disables the contact.
	-- See: https://love2d.org/wiki/Contact:setEnabled
	setEnabled: function(self: Contact, enabled: boolean)
	-- Returns whether the two colliding fixtures are touching each other.
	-- See: https://love2d.org/wiki/Contact:isTouching
	isTouching: function(self: Contact): boolean
	getTangentSpeed: function(self: Contact): number
	setTangentSpeed: function(self: Contact, speed: number)
end

-- A world is an object that contains all bodies and joints.
-- See: https://love2d.org/wiki/World
local record World
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: World): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: World, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: World): boolean
	-- Destroys the world, taking all bodies, joints, fixtures and their shapes with it.
	-- See: https://love2d.org/wiki/World:destroy
	destroy: function(self: World)
	-- Gets whether the World is destroyed. Destroyed worlds cannot be used.
	-- See: https://love2d.org/wiki/World:isDestroyed
	isDestroyed: function(self: World): boolean
	-- Update the state of the world.
	-- See: https://love2d.org/wiki/World:update
	update: function(self: World, delta_time: number, velocity_iterations?: integer, position_iterations?: integer)
	-- Set the gravity of the world.
	-- See: https://love2d.org/wiki/World:setGravity
	setGravity: function(self: World, x: number, y: number)
	-- Get the gravity of the world.
	-- See: https://love2d.org/wiki/World:getGravity
	getGravity: function(self: World): number, number
	-- Sets the sleep behaviour of the world.
	-- See: https://love2d.org/wiki/World:setSleepingAllowed
	setSleepingAllowed: function(self: World, allowed: boolean)
	-- Gets the sleep behaviour of the world.
	-- See: https://love2d.org/wiki/World:isSleepingAllowed
	isSleepingAllowed: function(self: World): boolean
	-- Fixture 在 Teal 模块中仍是内部 record，因此回调使用 any 接收它。
	-- Calls a function for each fixture inside the specified area by searching for any overlapping bounding box
	-- (Fixture:getBoundingBox).
	-- See: https://love2d.org/wiki/World:queryBoundingBox
	queryBoundingBox: function(self: World, x1: number, y1: number, x2: number, y2: number, callback: function(any): boolean)
	-- Casts a ray and calls a function for each fixtures it intersects.
	-- See: https://love2d.org/wiki/World:rayCast
	rayCast: function(self: World, x1: number, y1: number, x2: number, y2: number, callback: function(any, number, number, number, number, number): number)
	-- 物理对象 record 是模块内部类型，因此回调中的对象参数使用 any。
	-- Sets functions for the collision callbacks during the world update.
	-- See: https://love2d.org/wiki/World:setCallbacks
	setCallbacks: function(self: World, begin_contact?: function(any, any, any), end_contact?: function(any, any, any), pre_solve?: function(any, any, any), post_solve?: function(any, any, any, ...: number))
	-- Returns functions for the callbacks during the world update.
	-- See: https://love2d.org/wiki/World:getCallbacks
	getCallbacks: function(self: World): function(any, any, any) | nil, function(any, any, any) | nil, function(any, any, any) | nil, function(any, any, any, ...: number) | nil
end

-- Attach multiple bodies together to interact in unique ways.
-- See: https://love2d.org/wiki/Joint
local record Joint
	-- Gets the type of the object as a string.
	-- See: https://love2d.org/wiki/Object:type
	type: function(self: Joint): string
	-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
	-- hierarchy, this function will return true.
	-- See: https://love2d.org/wiki/Object:typeOf
	typeOf: function(self: Joint, type_name: string): boolean
	-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
	-- other LÖVE object or thread.
	-- See: https://love2d.org/wiki/Object:release
	release: function(self: Joint): boolean
	-- Explicitly destroys the Joint. An error will occur if you attempt to use the object after calling this
	-- function.
	-- See: https://love2d.org/wiki/Joint:destroy
	destroy: function(self: Joint)
	-- Gets whether the Joint is destroyed. Destroyed joints cannot be used.
	-- See: https://love2d.org/wiki/Joint:isDestroyed
	isDestroyed: function(self: Joint): boolean
	-- Gets a string representing the type.
	-- See: https://love2d.org/wiki/Joint:getType
	getType: function(self: Joint): string
	-- Gets the bodies that the Joint is attached to.
	-- See: https://love2d.org/wiki/Joint:getBodies
	getBodies: function(self: Joint): Body, Body
	-- Get the anchor points of the joint.
	-- See: https://love2d.org/wiki/Joint:getAnchors
	getAnchors: function(self: Joint): number, number, number, number
	-- Returns the reaction force in newtons on the second body
	-- See: https://love2d.org/wiki/Joint:getReactionForce
	getReactionForce: function(self: Joint, inverse_delta_time: number): number, number
	-- Returns the reaction torque on the second body.
	-- See: https://love2d.org/wiki/Joint:getReactionTorque
	getReactionTorque: function(self: Joint, inverse_delta_time: number): number
	-- Gets whether the connected Bodies collide.
	-- See: https://love2d.org/wiki/Joint:getCollideConnected
	getCollideConnected: function(self: Joint): boolean
	-- Associates a Lua value with the Joint.
	-- See: https://love2d.org/wiki/Joint:setUserData
	setUserData: function(self: Joint, value: any)
	-- Returns the Lua value associated with this Joint.
	-- See: https://love2d.org/wiki/Joint:getUserData
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
-- See: https://love2d.org/wiki/love.physics
local record Physics
	-- Sets the pixels to meter scale factor.
	-- See: https://love2d.org/wiki/love.physics.setMeter
	setMeter: function(scale: number)
	-- Returns the meter scale factor.
	-- See: https://love2d.org/wiki/love.physics.getMeter
	getMeter: function(): number
	-- Creates a new World.
	-- See: https://love2d.org/wiki/love.physics.newWorld
	newWorld: function(x_gravity?: number, y_gravity?: number, sleep?: boolean): World
	-- Creates a new body.
	-- See: https://love2d.org/wiki/love.physics.newBody
	newBody: function(world: World, x?: number, y?: number, body_type?: string): Body
	-- Creates and attaches a Fixture to a body.
	-- See: https://love2d.org/wiki/love.physics.newFixture
	newFixture: function(body: Body, shape: Shape, density?: number): Fixture
	-- Covers both radius and x, y, radius overloads.
	-- Creates a new CircleShape.
	-- See: https://love2d.org/wiki/love.physics.newCircleShape
	newCircleShape: function(first: number, second?: number, radius?: number): Shape
	-- Covers both width, height and x, y, width, height, angle overloads.
	-- Shorthand for creating rectangular PolygonShapes.
	-- See: https://love2d.org/wiki/love.physics.newRectangleShape
	newRectangleShape: function(first: number, second: number, third?: number, fourth?: number, angle?: number): Shape
	-- Creates a new PolygonShape.
	-- See: https://love2d.org/wiki/love.physics.newPolygonShape
	newPolygonShape: function(first: number | {number}, ...: number): Shape
	-- Creates a new EdgeShape.
	-- See: https://love2d.org/wiki/love.physics.newEdgeShape
	newEdgeShape: function(x1: number, y1: number, x2: number, y2: number): Shape
	-- Creates a new ChainShape.
	-- See: https://love2d.org/wiki/love.physics.newChainShape
	newChainShape: function(loop: boolean, first: number | {number}, ...: number): Shape
	-- Creates a DistanceJoint between two bodies.
	-- See: https://love2d.org/wiki/love.physics.newDistanceJoint
	newDistanceJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean): Joint
	-- 第五个参数可表示共享锚点重载的 collide_connected，或第二个锚点的 x 坐标。
	-- Creates a pivot joint between two bodies.
	-- See: https://love2d.org/wiki/love.physics.newRevoluteJoint
	newRevoluteJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2_or_collide?: number | boolean, y2?: number, collide_connected?: boolean, reference_angle?: number): Joint
	-- 同时覆盖共享锚点和独立锚点重载。
	-- Creates a PrismaticJoint between two bodies.
	-- See: https://love2d.org/wiki/love.physics.newPrismaticJoint
	newPrismaticJoint: function(body1: Body, body2: Body, x1: number, y1: number, fifth: number, sixth: number, axis_x_or_collide?: number | boolean, axis_y?: number, collide_connected?: boolean, reference_angle?: number): Joint
	-- The fifth argument covers shared-anchor collide_connected or the second anchor x coordinate.
	-- Creates a constraint joint between two bodies. A WeldJoint essentially glues two bodies together. The
	-- constraint is a bit soft, however, due to Box2D's iterative solver.
	-- See: https://love2d.org/wiki/love.physics.newWeldJoint
	newWeldJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2_or_collide?: number | boolean, y2?: number, collide_connected?: boolean, reference_angle?: number): Joint
	-- The fifth argument covers shared-anchor collide_connected or the second anchor x coordinate.
	-- Create a friction joint between two bodies. A FrictionJoint applies friction to a body.
	-- See: https://love2d.org/wiki/love.physics.newFrictionJoint
	newFrictionJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2_or_collide?: number | boolean, y2?: number, collide_connected?: boolean): Joint
	-- Creates a joint between two bodies. Its only function is enforcing a max distance between these bodies.
	-- See: https://love2d.org/wiki/love.physics.newRopeJoint
	newRopeJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, max_length: number, collide_connected?: boolean): Joint
	-- Creates a PulleyJoint to join two bodies to each other and the ground.
	-- See: https://love2d.org/wiki/love.physics.newPulleyJoint
	newPulleyJoint: function(body1: Body, body2: Body, ground_x1: number, ground_y1: number, ground_x2: number, ground_y2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collide_connected?: boolean): Joint
	-- Covers shared-anchor and independent-anchor overloads.
	-- Creates a wheel joint.
	-- See: https://love2d.org/wiki/love.physics.newWheelJoint
	newWheelJoint: function(body1: Body, body2: Body, x1: number, y1: number, fifth: number, sixth: number, axis_x_or_collide?: number | boolean, axis_y?: number, collide_connected?: boolean): Joint
	-- Create a joint between a body and the mouse.
	-- See: https://love2d.org/wiki/love.physics.newMouseJoint
	newMouseJoint: function(body: Body, x: number, y: number): Joint
	-- Creates a joint between two bodies which controls the relative motion between them.
	-- See: https://love2d.org/wiki/love.physics.newMotorJoint
	newMotorJoint: function(body1: Body, body2: Body, correction_factor?: number, collide_connected?: boolean): Joint
	-- Create a GearJoint connecting two Joints.
	-- See: https://love2d.org/wiki/love.physics.newGearJoint
	newGearJoint: function(joint1: Joint, joint2: Joint, ratio?: number, collide_connected?: boolean): Joint
end

-- The primary responsibility for the love.graphics module is the drawing of lines, shapes, text, Images and
-- other Drawable objects onto the screen. Its secondary responsibilities include loading external files
-- (including Images and Fonts) into memory, creating specialized objects (such as ParticleSystems or
-- Canvases) and managing screen geometry.
-- See: https://love2d.org/wiki/love.graphics
local record Graphics
	-- Clears the screen or active Canvas to the specified color.
	-- See: https://love2d.org/wiki/love.graphics.clear
	clear: function(red?: number, green?: number, blue?: number, alpha?: number)
	-- Discards (trashes) the contents of the screen or active Canvas. This is a performance optimization function
	-- with niche use cases.
	-- See: https://love2d.org/wiki/love.graphics.discard
	discard: function(discard_color?: boolean | {boolean}, discard_depth_stencil?: boolean)
	-- Immediately renders any pending automatically batched draws.
	-- See: https://love2d.org/wiki/love.graphics.flushBatch
	flushBatch: function()
	-- Sets the background color.
	-- See: https://love2d.org/wiki/love.graphics.setBackgroundColor
	setBackgroundColor: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number)
	-- Gets the current background color.
	-- See: https://love2d.org/wiki/love.graphics.getBackgroundColor
	getBackgroundColor: function(): number, number, number, number
	-- Sets the default scaling filters used with Images, Canvases, and Fonts.
	-- See: https://love2d.org/wiki/love.graphics.setDefaultFilter
	setDefaultFilter: function(min_filter: string, mag_filter?: string, anisotropy?: number)
	-- Returns the default scaling filters used with Images, Canvases, and Fonts.
	-- See: https://love2d.org/wiki/love.graphics.getDefaultFilter
	getDefaultFilter: function(): string, string, number
	setDefaultMipmapFilter: function(filter?: string, sharpness?: number)
	getDefaultMipmapFilter: function(): string | nil, number
	-- Sets the color used for drawing.
	-- See: https://love2d.org/wiki/love.graphics.setColor
	setColor: function(red: number, green: number, blue: number, alpha?: number)
	-- Gets the current color.
	-- See: https://love2d.org/wiki/love.graphics.getColor
	getColor: function(): number, number, number, number
	-- Sets the line width.
	-- See: https://love2d.org/wiki/love.graphics.setLineWidth
	setLineWidth: function(width: number)
	-- Gets the current line width.
	-- See: https://love2d.org/wiki/love.graphics.getLineWidth
	getLineWidth: function(): number
	-- Sets the line style.
	-- See: https://love2d.org/wiki/love.graphics.setLineStyle
	setLineStyle: function(style: string)
	-- Gets the line style.
	-- See: https://love2d.org/wiki/love.graphics.getLineStyle
	getLineStyle: function(): string
	-- Sets the line join style. See LineJoin for the possible options.
	-- See: https://love2d.org/wiki/love.graphics.setLineJoin
	setLineJoin: function(join: string)
	-- Gets the line join style.
	-- See: https://love2d.org/wiki/love.graphics.getLineJoin
	getLineJoin: function(): string
	-- Sets whether wireframe lines will be used when drawing.
	-- See: https://love2d.org/wiki/love.graphics.setWireframe
	setWireframe: function(enable: boolean)
	-- Gets whether wireframe mode is used when drawing.
	-- See: https://love2d.org/wiki/love.graphics.isWireframe
	isWireframe: function(): boolean
	-- Sets the point size.
	-- See: https://love2d.org/wiki/love.graphics.setPointSize
	setPointSize: function(size: number)
	-- Gets the point size.
	-- See: https://love2d.org/wiki/love.graphics.getPointSize
	getPointSize: function(): number
	-- Gets the width and height in pixels of the window.
	-- See: https://love2d.org/wiki/love.graphics.getDimensions
	getDimensions: function(): number, number
	-- Gets the width in pixels of the window.
	-- See: https://love2d.org/wiki/love.graphics.getWidth
	getWidth: function(): number
	-- Gets the height in pixels of the window.
	-- See: https://love2d.org/wiki/love.graphics.getHeight
	getHeight: function(): number
	-- Gets the width and height in pixels of the window.
	-- See: https://love2d.org/wiki/love.graphics.getPixelDimensions
	getPixelDimensions: function(): number, number
	-- Gets the width in pixels of the window.
	-- See: https://love2d.org/wiki/love.graphics.getPixelWidth
	getPixelWidth: function(): number
	-- Gets the height in pixels of the window.
	-- See: https://love2d.org/wiki/love.graphics.getPixelHeight
	getPixelHeight: function(): number
	-- Gets the DPI scale factor of the window.
	-- See: https://love2d.org/wiki/love.graphics.getDPIScale
	getDPIScale: function(): number
	-- Gets the optional graphics features and whether they're supported on the system.
	-- See: https://love2d.org/wiki/love.graphics.getSupported
	getSupported: function(target?: any): GraphicsFeatures
	-- Gets the available texture types, and whether each is supported.
	-- See: https://love2d.org/wiki/love.graphics.getTextureTypes
	getTextureTypes: function(target?: any): {string: boolean}
	-- Gets the raw and compressed pixel formats usable for Images, and whether each is supported.
	-- See: https://love2d.org/wiki/love.graphics.getImageFormats
	getImageFormats: function(target?: any): {string: boolean}
	-- Gets information about the system's video card and drivers.
	-- See: https://love2d.org/wiki/love.graphics.getRendererInfo
	getRendererInfo: function(): string, string, string, string
	-- Gets the system-dependent maximum values for love.graphics features.
	-- See: https://love2d.org/wiki/love.graphics.getSystemLimits
	getSystemLimits: function(target?: any): GraphicsSystemLimits
	-- Gets performance-related rendering statistics.
	-- See: https://love2d.org/wiki/love.graphics.getStats
	getStats: function(target?: any): GraphicsStats
	-- Creates a screenshot once the current frame is done (after love.draw has finished).
	-- See: https://love2d.org/wiki/love.graphics.captureScreenshot
	captureScreenshot: function(filename_callback_or_channel: string | function(image_data: ImageData) | Channel)
	-- Draws a rectangle.
	-- See: https://love2d.org/wiki/love.graphics.rectangle
	rectangle: function(mode: string, x: number, y: number, width: number, height: number)
	-- Draws a circle.
	-- See: https://love2d.org/wiki/love.graphics.circle
	circle: function(mode: string, x: number, y: number, radius: number)
	-- Draws a filled or unfilled arc at position (x, y). The arc is drawn from angle1 to angle2 in radians. The
	-- segments parameter determines how many segments are used to draw the arc. The more segments, the smoother
	-- the edge.
	-- See: https://love2d.org/wiki/love.graphics.arc
	arc: function(mode: string, arc_mode_or_x: string | number, y_or_x: number, radius_or_y: number, angle1_or_radius: number, angle2_or_angle1: number, segments_or_angle2?: number, segments?: integer)
	-- Draws an ellipse.
	-- See: https://love2d.org/wiki/love.graphics.ellipse
	ellipse: function(mode: string, x: number, y: number, radius_x: number, radius_y: number, segments?: integer)
	-- Draws lines between points.
	-- See: https://love2d.org/wiki/love.graphics.line
	line: function(x1: number, y1: number, x2: number, y2: number, coordinates: number...)
	-- Draw a polygon.
	-- See: https://love2d.org/wiki/love.graphics.polygon
	polygon: function(mode: string, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, coordinates: number...)
	-- Draws one or more points.
	-- See: https://love2d.org/wiki/love.graphics.points
	points: function(x1: number, y1: number, coordinates: number...)
	-- Displays the results of drawing operations on the screen.
	-- See: https://love2d.org/wiki/love.graphics.present
	present: function()
	-- Copies and pushes the current coordinate transformation to the transformation stack.
	-- See: https://love2d.org/wiki/love.graphics.push
	push: function(stack_type?: string)
	-- Pops the current coordinate transformation from the transformation stack.
	-- See: https://love2d.org/wiki/love.graphics.pop
	pop: function()
	-- Gets the current depth of the transform / state stack (the number of pushes without corresponding pops).
	-- See: https://love2d.org/wiki/love.graphics.getStackDepth
	getStackDepth: function(): integer
	-- Resets the current coordinate transformation.
	-- See: https://love2d.org/wiki/love.graphics.origin
	origin: function()
	-- Translates the coordinate system in two dimensions.
	-- See: https://love2d.org/wiki/love.graphics.translate
	translate: function(dx: number, dy: number)
	-- Rotates the coordinate system in two dimensions.
	-- See: https://love2d.org/wiki/love.graphics.rotate
	rotate: function(angle: number)
	-- Scales the coordinate system in two dimensions.
	-- See: https://love2d.org/wiki/love.graphics.scale
	scale: function(sx: number, sy?: number)
	-- Shears the coordinate system.
	-- See: https://love2d.org/wiki/love.graphics.shear
	shear: function(kx: number, ky: number)
	-- Applies the given Transform object to the current coordinate transformation.
	-- See: https://love2d.org/wiki/love.graphics.applyTransform
	applyTransform: function(transform: Transform)
	-- Replaces the current coordinate transformation with the given Transform object.
	-- See: https://love2d.org/wiki/love.graphics.replaceTransform
	replaceTransform: function(transform: Transform)
	-- Converts the given 2D position from global coordinates into screen-space.
	-- See: https://love2d.org/wiki/love.graphics.transformPoint
	transformPoint: function(x: number, y: number): number, number
	-- Converts the given 2D position from screen-space into global coordinates.
	-- See: https://love2d.org/wiki/love.graphics.inverseTransformPoint
	inverseTransformPoint: function(x: number, y: number): number, number
	-- Gets whether the graphics module is able to be used. If it is not active, love.graphics function and method
	-- calls will not work correctly and may cause the program to crash. The graphics module is inactive if a
	-- window is not open, or if the app is in the background on iOS. Typically the app's execution will be
	-- automatically paused by the system, in the latter case.
	-- See: https://love2d.org/wiki/love.graphics.isActive
	isActive: function(): boolean
	isCreated: function(): boolean
	-- Gets whether gamma-correct rendering is supported and enabled. It can be enabled by setting t.gammacorrect
	-- = true in love.conf.
	-- See: https://love2d.org/wiki/love.graphics.isGammaCorrect
	isGammaCorrect: function(): boolean
	-- Resets the current graphics settings.
	-- See: https://love2d.org/wiki/love.graphics.reset
	reset: function()
	-- Sets the blending mode.
	-- See: https://love2d.org/wiki/love.graphics.setBlendMode
	setBlendMode: function(mode: string, alpha_mode?: string)
	-- Gets the blending mode.
	-- See: https://love2d.org/wiki/love.graphics.getBlendMode
	getBlendMode: function(): string, string
	-- Sets or disables scissor.
	-- See: https://love2d.org/wiki/love.graphics.setScissor
	setScissor: function(x?: number, y?: number, width?: number, height?: number)
	-- Gets the current scissor box.
	-- See: https://love2d.org/wiki/love.graphics.getScissor
	getScissor: function(): number | nil, number | nil, number | nil, number | nil
	-- Sets the scissor to the rectangle created by the intersection of the specified rectangle with the existing
	-- scissor. If no scissor is active yet, it behaves like love.graphics.setScissor.
	-- See: https://love2d.org/wiki/love.graphics.intersectScissor
	intersectScissor: function(x: number, y: number, width: number, height: number)
	-- Sets the color mask. Enables or disables specific color components when rendering and clearing the screen.
	-- For example, if '''red''' is set to '''false''', no further changes will be made to the red component of
	-- any pixels.
	-- See: https://love2d.org/wiki/love.graphics.setColorMask
	setColorMask: function(red?: boolean, green?: boolean, blue?: boolean, alpha?: boolean)
	-- Gets the active color components used when drawing. Normally all 4 components are active unless
	-- love.graphics.setColorMask has been used.
	-- See: https://love2d.org/wiki/love.graphics.getColorMask
	getColorMask: function(): boolean, boolean, boolean, boolean
	-- Configures depth testing and writing to the depth buffer.
	-- See: https://love2d.org/wiki/love.graphics.setDepthMode
	setDepthMode: function(compare?: string, write?: boolean)
	-- Gets the current depth test mode and whether writing to the depth buffer is enabled.
	-- See: https://love2d.org/wiki/love.graphics.getDepthMode
	getDepthMode: function(): string, boolean
	-- Sets whether back-facing triangles in a Mesh are culled.
	-- See: https://love2d.org/wiki/love.graphics.setMeshCullMode
	setMeshCullMode: function(mode: string)
	-- Gets whether back-facing triangles in a Mesh are culled.
	-- See: https://love2d.org/wiki/love.graphics.getMeshCullMode
	getMeshCullMode: function(): string
	-- Sets whether triangles with clockwise- or counterclockwise-ordered vertices are considered front-facing.
	-- See: https://love2d.org/wiki/love.graphics.setFrontFaceWinding
	setFrontFaceWinding: function(winding: string)
	-- Gets whether triangles with clockwise- or counterclockwise-ordered vertices are considered front-facing.
	-- See: https://love2d.org/wiki/love.graphics.getFrontFaceWinding
	getFrontFaceWinding: function(): string
	-- Draws geometry as a stencil.
	-- See: https://love2d.org/wiki/love.graphics.stencil
	stencil: function(draw: function(), action?: string, value?: integer, keep_values_or_clear_value?: boolean | integer)
	-- Configures or disables stencil testing.
	-- See: https://love2d.org/wiki/love.graphics.setStencilTest
	setStencilTest: function(compare?: string, value?: integer)
	-- Gets the current stencil test configuration.
	-- See: https://love2d.org/wiki/love.graphics.getStencilTest
	getStencilTest: function(): string, integer
	-- Creates a new Font from a TrueType Font or BMFont file. Created fonts are not cached, in that calling this
	-- function with the same arguments will always create a new Font object.
	-- See: https://love2d.org/wiki/love.graphics.newFont
	newFont: function(filename_or_size?: string | number, size?: integer): Font
	-- Creates and sets a new Font.
	-- See: https://love2d.org/wiki/love.graphics.setNewFont
	setNewFont: function(filename_or_size?: string | number, size?: integer): Font
	-- Creates a new specifically formatted image.
	-- See: https://love2d.org/wiki/love.graphics.newImageFont
	newImageFont: function(source_or_rasterizer: string | FileData | ImageData | Rasterizer, glyphs?: string, extra_spacing?: integer, dpi_scale?: number): Font
	-- Creates a new drawable Text object.
	-- See: https://love2d.org/wiki/love.graphics.newText
	newText: function(font: Font, text?: any): Text
	-- Set an already-loaded Font as the current font or create and load a new one from the file and size.
	-- See: https://love2d.org/wiki/love.graphics.setFont
	setFont: function(font: Font)
	-- Gets the current Font object.
	-- See: https://love2d.org/wiki/love.graphics.getFont
	getFont: function(): Font
	-- Draws text on screen. If no Font is set, one will be created and set (once) if needed.
	-- See: https://love2d.org/wiki/love.graphics.print
	print: function(text: string | number, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)
	-- Draws formatted text, with word wrap and alignment.
	-- See: https://love2d.org/wiki/love.graphics.printf
	printf: function(text: string | number, x: number, y: number, limit: number, align?: string, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)
	-- Creates a new Image from a filepath, FileData, an ImageData, or a CompressedImageData, and optionally
	-- generates or specifies mipmaps for the image.
	-- See: https://love2d.org/wiki/love.graphics.newImage
	newImage: function(filename_or_data: string | FileData | ImageData | CompressedImageData, settings?: LayeredImageSettings): Image
	-- Creates a new drawable Video. Currently only Ogg Theora video files are supported.
	-- See: https://love2d.org/wiki/love.graphics.newVideo
	newVideo: function(filename_or_stream: string | VideoStream, settings?: any): Video
	_newVideo: function(filename_or_stream: string | VideoStream, dpi_scale?: number): Video
	-- Creates a new array Image.
	-- See: https://love2d.org/wiki/love.graphics.newArrayImage
	newArrayImage: function(layers: {ImageData}, settings?: LayeredImageSettings): Image
	-- Creates a new cubemap Image.
	-- See: https://love2d.org/wiki/love.graphics.newCubeImage
	newCubeImage: function(faces: {ImageData}, settings?: LayeredImageSettings): Image
	-- Creates a new volume (3D) Image.
	-- See: https://love2d.org/wiki/love.graphics.newVolumeImage
	newVolumeImage: function(slices: {ImageData}, settings?: LayeredImageSettings): Image
	-- Creates a new Canvas object for offscreen rendering.
	-- See: https://love2d.org/wiki/love.graphics.newCanvas
	newCanvas: function(width?: integer, height?: integer, settings?: CanvasSettings): Canvas
	-- Gets the available Canvas formats, and whether each is supported.
	-- See: https://love2d.org/wiki/love.graphics.getCanvasFormats
	getCanvasFormats: function(readable?: boolean, formats?: {string: boolean}): {string: boolean}
	-- Teal 无法区分 Canvas record 与 Canvas record 数组。
	-- Captures drawing operations to a Canvas.
	-- See: https://love2d.org/wiki/love.graphics.setCanvas
	setCanvas: function(...: any)
	-- Gets the current target Canvas.
	-- See: https://love2d.org/wiki/love.graphics.getCanvas
	getCanvas: function(): Canvas | nil
	-- 以下参数覆盖 Teal record 无法直接表达的 Love 重载。
	-- Creates a new Quad.
	-- See: https://love2d.org/wiki/love.graphics.newQuad
	newQuad: function(x: number, y: number, width: number, height: number, image_or_texture_width: any, texture_height?: number): Quad
	-- 覆盖标准顶点格式和自定义顶点格式两种重载。
	-- Creates a new Mesh.
	-- See: https://love2d.org/wiki/love.graphics.newMesh
	newMesh: function(vertices_or_format: any, vertices_or_mode?: any, draw_mode_or_usage?: string, usage?: string): Mesh
	-- Creates a new SpriteBatch object.
	-- See: https://love2d.org/wiki/love.graphics.newSpriteBatch
	newSpriteBatch: function(texture: Image | Canvas, size?: integer, usage?: string): SpriteBatch
	-- Creates a new ParticleSystem.
	-- See: https://love2d.org/wiki/love.graphics.newParticleSystem
	newParticleSystem: function(texture: Image | Canvas, size?: integer): ParticleSystem
	-- Creates a new Shader object for hardware-accelerated vertex and pixel effects. A Shader contains either
	-- vertex shader code, pixel shader code, or both.
	-- See: https://love2d.org/wiki/love.graphics.newShader
	newShader: function(source: string | FileData, pixel_source?: string | FileData): Shader
	-- Validates shader code. Check if specified shader code does not contain any errors.
	-- See: https://love2d.org/wiki/love.graphics.validateShader
	validateShader: function(gles: boolean, source: string | FileData, pixel_source?: string | FileData): boolean, string | nil
	-- Sets or resets a Shader as the current pixel effect or vertex shaders. All drawing operations until the
	-- next ''love.graphics.setShader'' will be drawn using the Shader object specified.
	-- See: https://love2d.org/wiki/love.graphics.setShader
	setShader: function(shader?: Shader)
	-- Gets the current Shader. Returns nil if none is set.
	-- See: https://love2d.org/wiki/love.graphics.getShader
	getShader: function(): Shader | nil
	-- Draws a Drawable object (an Image, Canvas, SpriteBatch, ParticleSystem, Mesh, Text object, or Video) on the
	-- screen with optional rotation, scaling and shearing.
	-- See: https://love2d.org/wiki/love.graphics.draw
	draw: function(image: any, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y?: number)
	-- Draws a layer of an Array Texture.
	-- See: https://love2d.org/wiki/love.graphics.drawLayer
	drawLayer: function(image: Image, layer: integer, quad_or_x?: Quad | number, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y?: number)
	-- Draws many instances of a Mesh with a single draw call, using hardware geometry instancing.
	-- See: https://love2d.org/wiki/love.graphics.drawInstanced
	drawInstanced: function(mesh: Mesh, instance_count: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)
end

-- Love 11.5 根模块。本文件只声明当前已经实现的子集。
local record Love
	record TouchID
		userdata
	end
	-- Provides an interface to touch-screen presses.
	-- See: https://love2d.org/wiki/love.touch
	record Touch
		-- Gets a list of all active touch-presses.
		-- See: https://love2d.org/wiki/love.touch.getTouches
		getTouches: function(): {TouchID}
		-- Gets the current position of the specified touch-press, in pixels.
		-- See: https://love2d.org/wiki/love.touch.getPosition
		getPosition: function(id: TouchID): number, number
		-- Gets the current pressure of the specified touch-press.
		-- See: https://love2d.org/wiki/love.touch.getPressure
		getPressure: function(id: TouchID): number
	end
	-- Represents a physical joystick.
	-- See: https://love2d.org/wiki/Joystick
	record Joystick
		-- Gets the type of the object as a string.
		-- See: https://love2d.org/wiki/Object:type
		type: function(self: Joystick): string
		-- Checks whether an object is of a certain type. If the object has the type with the specified name in its
		-- hierarchy, this function will return true.
		-- See: https://love2d.org/wiki/Object:typeOf
		typeOf: function(self: Joystick, type_name: string): boolean
		-- Destroys the object's Lua reference. The object will be completely deleted if it's not referenced by any
		-- other LÖVE object or thread.
		-- See: https://love2d.org/wiki/Object:release
		release: function(self: Joystick): boolean
		-- Gets whether the Joystick is connected.
		-- See: https://love2d.org/wiki/Joystick:isConnected
		isConnected: function(self: Joystick): boolean
		-- Gets the name of the joystick.
		-- See: https://love2d.org/wiki/Joystick:getName
		getName: function(self: Joystick): string
		-- Gets the joystick's unique identifier. The identifier will remain the same for the life of the game, even
		-- when the Joystick is disconnected and reconnected, but it '''will''' change when the game is re-launched.
		-- See: https://love2d.org/wiki/Joystick:getID
		getID: function(self: Joystick): integer, integer | nil
		-- Gets a stable GUID unique to the type of the physical joystick which does not change over time. For
		-- example, all Sony Dualshock 3 controllers in OS X have the same GUID. The value is platform-dependent.
		-- See: https://love2d.org/wiki/Joystick:getGUID
		getGUID: function(self: Joystick): string
		-- Gets the USB vendor ID, product ID, and product version numbers of joystick which consistent across
		-- operating systems.
		-- See: https://love2d.org/wiki/Joystick:getDeviceInfo
		getDeviceInfo: function(self: Joystick): integer, integer, integer
		-- Gets the number of axes on the joystick.
		-- See: https://love2d.org/wiki/Joystick:getAxisCount
		getAxisCount: function(self: Joystick): integer
		-- Gets the number of buttons on the joystick.
		-- See: https://love2d.org/wiki/Joystick:getButtonCount
		getButtonCount: function(self: Joystick): integer
		-- Gets the number of hats on the joystick.
		-- See: https://love2d.org/wiki/Joystick:getHatCount
		getHatCount: function(self: Joystick): integer
		-- Gets the direction of an axis.
		-- See: https://love2d.org/wiki/Joystick:getAxis
		getAxis: function(self: Joystick, axis: integer): number
		-- Gets the direction of each axis.
		-- See: https://love2d.org/wiki/Joystick:getAxes
		getAxes: function(self: Joystick): number...
		-- Gets the direction of the Joystick's hat.
		-- See: https://love2d.org/wiki/Joystick:getHat
		getHat: function(self: Joystick, hat: integer): string
		-- Checks if a button on the Joystick is pressed.
		-- See: https://love2d.org/wiki/Joystick:isDown
		isDown: function(self: Joystick, buttons: integer...): boolean
		-- Gets whether the Joystick is recognized as a gamepad. If this is the case, the Joystick's buttons and axes
		-- can be used in a standardized manner across different operating systems and joystick models via
		-- Joystick:getGamepadAxis, Joystick:isGamepadDown, love.gamepadpressed, and related functions.
		-- See: https://love2d.org/wiki/Joystick:isGamepad
		isGamepad: function(self: Joystick): boolean
		-- Checks if a virtual gamepad button on the Joystick is pressed. If the Joystick is not recognized as a
		-- Gamepad or isn't connected, then this function will always return false.
		-- See: https://love2d.org/wiki/Joystick:isGamepadDown
		isGamepadDown: function(self: Joystick, buttons: string...): boolean
		-- Gets the direction of a virtual gamepad axis. If the Joystick isn't recognized as a gamepad or isn't
		-- connected, this function will always return 0.
		-- See: https://love2d.org/wiki/Joystick:getGamepadAxis
		getGamepadAxis: function(self: Joystick, axis: string): number
		-- Gets the button, axis or hat that a virtual gamepad input is bound to.
		-- See: https://love2d.org/wiki/Joystick:getGamepadMapping
		getGamepadMapping: function(self: Joystick, input: string): string | nil, integer | nil, string | nil
		-- Gets the full gamepad mapping string of this Joystick, or nil if it's not recognized as a gamepad.
		-- See: https://love2d.org/wiki/Joystick:getGamepadMappingString
		getGamepadMappingString: function(self: Joystick): string | nil
		-- Gets whether the Joystick supports vibration.
		-- See: https://love2d.org/wiki/Joystick:isVibrationSupported
		isVibrationSupported: function(self: Joystick): boolean
		-- Sets the vibration motor speeds on a Joystick with rumble support. Most common gamepads have this
		-- functionality, although not all drivers give proper support. Use Joystick:isVibrationSupported to check.
		-- See: https://love2d.org/wiki/Joystick:setVibration
		setVibration: function(self: Joystick, left?: number, right?: number, duration?: number): boolean
		-- Gets the current vibration motor strengths on a Joystick with rumble support.
		-- See: https://love2d.org/wiki/Joystick:getVibration
		getVibration: function(self: Joystick): number, number
		getConnectedIndex: function(self: Joystick): integer | nil
	end
	-- Provides an interface to the user's joystick.
	-- See: https://love2d.org/wiki/love.joystick
	record JoystickModule
		-- Gets a list of connected Joysticks.
		-- See: https://love2d.org/wiki/love.joystick.getJoysticks
		getJoysticks: function(): {Joystick}
		-- Gets the number of connected joysticks.
		-- See: https://love2d.org/wiki/love.joystick.getJoystickCount
		getJoystickCount: function(): integer
		-- Binds a virtual gamepad input to a button, axis or hat for all Joysticks of a certain type. For example, if
		-- this function is used with a GUID returned by a Dualshock 3 controller in OS X, the binding will affect
		-- Joystick:getGamepadAxis and Joystick:isGamepadDown for ''all'' Dualshock 3 controllers used with the game
		-- when run in OS X.
		-- See: https://love2d.org/wiki/love.joystick.setGamepadMapping
		setGamepadMapping: function(guid: string, input: string, input_type: string, index: integer, direction?: string): boolean
		-- Loads a gamepad mappings string or file created with love.joystick.saveGamepadMappings.
		-- See: https://love2d.org/wiki/love.joystick.loadGamepadMappings
		loadGamepadMappings: function(mappings_or_filename: string)
		-- Saves the virtual gamepad mappings of all recognized as gamepads and have either been recently used or
		-- their gamepad bindings have been modified.
		-- See: https://love2d.org/wiki/love.joystick.saveGamepadMappings
		saveGamepadMappings: function(filename?: string): string
		-- Gets the full gamepad mapping string of the Joysticks which have the given GUID, or nil if the GUID isn't
		-- recognized as a gamepad.
		-- See: https://love2d.org/wiki/love.joystick.getGamepadMappingString
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

	-- If a file called conf.lua is present in your game folder (or .love file), it is run before the LÖVE modules
	-- are loaded. You can use this file to overwrite the love.conf function, which is later called by the LÖVE
	-- 'boot' script. Using the love.conf function, you can set some configuration options, and change things like
	-- the default size of the window, which modules are loaded, and other stuff.
	-- See: https://love2d.org/wiki/love.conf
	conf: function(config: Config) | nil
	-- This function is called exactly once at the beginning of the game.
	-- See: https://love2d.org/wiki/love.load
	load: function() | nil
	-- Callback function used to update the state of the game every frame.
	-- See: https://love2d.org/wiki/love.update
	update: function(deltaTime: number) | nil
	-- Callback function used to draw on the screen every frame.
	-- See: https://love2d.org/wiki/love.draw
	draw: function() | nil
	-- 返回 true 可取消 love.event.quit 请求。
	-- Callback function triggered when the game is closed.
	-- See: https://love2d.org/wiki/love.quit
	quit: QuitCallback | nil
	-- Callback function triggered when a key is pressed.
	-- See: https://love2d.org/wiki/love.keypressed
	keypressed: function(key: string, scancode: string, is_repeat: boolean) | nil
	-- Callback function triggered when a keyboard key is released.
	-- See: https://love2d.org/wiki/love.keyreleased
	keyreleased: function(key: string, scancode: string) | nil
	-- Called when text has been entered by the user. For example if shift-2 is pressed on an American keyboard
	-- layout, the text '@' will be generated.
	-- See: https://love2d.org/wiki/love.textinput
	textinput: function(text: string) | nil
	-- Called when the candidate text for an IME (Input Method Editor) has changed.
	-- See: https://love2d.org/wiki/love.textedited
	textedited: function(text: string, start: integer, length: integer) | nil
	-- Callback function triggered when a mouse button is pressed.
	-- See: https://love2d.org/wiki/love.mousepressed
	mousepressed: function(x: number, y: number, button: integer, is_touch: boolean, presses: integer) | nil
	-- Callback function triggered when a mouse button is released.
	-- See: https://love2d.org/wiki/love.mousereleased
	mousereleased: function(x: number, y: number, button: integer, is_touch: boolean, presses: integer) | nil
	-- Callback function triggered when the mouse is moved.
	-- See: https://love2d.org/wiki/love.mousemoved
	mousemoved: function(x: number, y: number, delta_x: number, delta_y: number, is_touch: boolean) | nil
	-- Callback function triggered when the mouse wheel is moved.
	-- See: https://love2d.org/wiki/love.wheelmoved
	wheelmoved: function(x: number, y: number) | nil
	-- Callback function triggered when the touch screen is touched.
	-- See: https://love2d.org/wiki/love.touchpressed
	touchpressed: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil
	-- Callback function triggered when the touch screen stops being touched.
	-- See: https://love2d.org/wiki/love.touchreleased
	touchreleased: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil
	-- Callback function triggered when a touch press moves inside the touch screen.
	-- See: https://love2d.org/wiki/love.touchmoved
	touchmoved: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil
	-- Callback function triggered when a Thread encounters an error.
	-- See: https://love2d.org/wiki/love.threaderror
	threaderror: function(thread: Thread, error: string) | nil
	-- Called when a Joystick is connected.
	-- See: https://love2d.org/wiki/love.joystickadded
	joystickadded: function(joystick: Joystick) | nil
	-- Called when a Joystick is disconnected.
	-- See: https://love2d.org/wiki/love.joystickremoved
	joystickremoved: function(joystick: Joystick) | nil
	-- Called when a joystick button is pressed.
	-- See: https://love2d.org/wiki/love.joystickpressed
	joystickpressed: function(joystick: Joystick, button: integer) | nil
	-- Called when a joystick button is released.
	-- See: https://love2d.org/wiki/love.joystickreleased
	joystickreleased: function(joystick: Joystick, button: integer) | nil
	-- Called when a joystick axis moves.
	-- See: https://love2d.org/wiki/love.joystickaxis
	joystickaxis: function(joystick: Joystick, axis: integer, value: number) | nil
	-- Called when a joystick hat direction changes.
	-- See: https://love2d.org/wiki/love.joystickhat
	joystickhat: function(joystick: Joystick, hat: integer, direction: string) | nil
	-- Called when a Joystick's virtual gamepad button is pressed.
	-- See: https://love2d.org/wiki/love.gamepadpressed
	gamepadpressed: function(joystick: Joystick, button: string) | nil
	-- Called when a Joystick's virtual gamepad button is released.
	-- See: https://love2d.org/wiki/love.gamepadreleased
	gamepadreleased: function(joystick: Joystick, button: string) | nil
	-- Called when a Joystick's virtual gamepad axis is moved.
	-- See: https://love2d.org/wiki/love.gamepadaxis
	gamepadaxis: function(joystick: Joystick, axis: string, value: number) | nil

	-- 兼容入口；Dora 始终是应用主循环所有者。
	-- The main function, containing the main loop. A sensible default is used when left out.
	-- See: https://love2d.org/wiki/love.run
	run: function()
end

local love: Love
return love
-- LÖVE 11.5 API summaries are adapted from the official LÖVE Wiki.
-- Copyright © 2006-2010 LÖVE Development Team. Documentation is redistributed under the
-- FreeBSD Documentation License described at https://love2d.org/wiki/License.
-- Each declaration links to its authoritative Wiki page; Dora-specific compatibility notes
-- remain explicitly marked as such.
