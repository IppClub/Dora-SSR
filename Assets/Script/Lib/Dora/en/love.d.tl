local record Image
	release: function(self: Image): boolean
	type: function(self: Image): string
	typeOf: function(self: Image, type_name: string): boolean
	getWidth: function(self: Image): number
	getHeight: function(self: Image): number
	getDimensions: function(self: Image): number, number
	getPixelWidth: function(self: Image): integer
	getPixelHeight: function(self: Image): integer
	getPixelDimensions: function(self: Image): integer, integer
	getDPIScale: function(self: Image): number
	getTextureType: function(self: Image): string
	getDepth: function(self: Image): integer
	getLayerCount: function(self: Image): integer
	getMipmapCount: function(self: Image): integer
	getMipmapFilter: function(self: Image): string, number
	setMipmapFilter: function(self: Image, filter?: string, sharpness?: number)
	getFormat: function(self: Image): string
	isCompressed: function(self: Image): boolean
	isFormatLinear: function(self: Image): boolean
	replacePixels: function(self: Image, data: any, slice?: integer, mipmap?: integer, x?: integer, y?: integer, reload_mipmaps?: boolean)
	isReadable: function(self: Image): boolean
	getDepthSampleMode: function(self: Image): string | nil
	setDepthSampleMode: function(self: Image, mode?: string)
	setFilter: function(self: Image, min_filter: string, mag_filter?: string, anisotropy?: number)
	getFilter: function(self: Image): string, string, number
	setWrap: function(self: Image, horizontal: string, vertical?: string, depth?: string): boolean
	getWrap: function(self: Image): string, string, string
end

local record VideoStream
	release: function(self: VideoStream): boolean
	type: function(self: VideoStream): string
	typeOf: function(self: VideoStream, type_name: string): boolean
	play: function(self: VideoStream)
	pause: function(self: VideoStream)
	seek: function(self: VideoStream, seconds: number)
	rewind: function(self: VideoStream)
	tell: function(self: VideoStream): number
	isPlaying: function(self: VideoStream): boolean
	getFilename: function(self: VideoStream): string
	setSync: function(self: VideoStream, source?: Source)
end

local record Video
	release: function(self: Video): boolean
	type: function(self: Video): string
	typeOf: function(self: Video, type_name: string): boolean
	getStream: function(self: Video): VideoStream
	getSource: function(self: Video): Source | nil
	setSource: function(self: Video, source?: Source)
	getWidth: function(self: Video): integer
	getHeight: function(self: Video): integer
	getDimensions: function(self: Video): integer, integer
	getPixelWidth: function(self: Video): integer
	getPixelHeight: function(self: Video): integer
	getPixelDimensions: function(self: Video): integer, integer
	setFilter: function(self: Video, min_filter: string, mag_filter?: string, anisotropy?: number)
	getFilter: function(self: Video): string, string, number
end

local record VideoModule
	newVideoStream: function(filename: string): VideoStream
end

local record Canvas
	release: function(self: Canvas): boolean
	type: function(self: Canvas): string
	typeOf: function(self: Canvas, type_name: string): boolean
	getWidth: function(self: Canvas): integer
	getHeight: function(self: Canvas): integer
	getDimensions: function(self: Canvas): integer, integer
	getPixelWidth: function(self: Canvas): integer
	getPixelHeight: function(self: Canvas): integer
	getPixelDimensions: function(self: Canvas): integer, integer
	getDPIScale: function(self: Canvas): number
	getFormat: function(self: Canvas): string
	getMSAA: function(self: Canvas): integer
	getTextureType: function(self: Canvas): string
	getDepth: function(self: Canvas): integer
	getLayerCount: function(self: Canvas): integer
	getMipmapCount: function(self: Canvas): integer
	getMipmapMode: function(self: Canvas): string
	getMipmapFilter: function(self: Canvas): string, number
	setMipmapFilter: function(self: Canvas, filter?: string, sharpness?: number)
	getDepthSampleMode: function(self: Canvas): string | nil
	setDepthSampleMode: function(self: Canvas, mode?: string)
	generateMipmaps: function(self: Canvas)
	renderTo: function(self: Canvas, callback: function())
	isReadable: function(self: Canvas): boolean
	newImageData: function(self: Canvas, slice?: integer, mipmap?: integer, x?: integer, y?: integer, width?: integer, height?: integer): any
	setFilter: function(self: Canvas, min_filter: string, mag_filter?: string, anisotropy?: number)
	getFilter: function(self: Canvas): string, string, number
	setWrap: function(self: Canvas, horizontal: string, vertical?: string, depth?: string): boolean
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

local record Font
	release: function(self: Font): boolean
	type: function(self: Font): string
	typeOf: function(self: Font, type_name: string): boolean
	getWidth: function(self: Font, text: string): number
	getHeight: function(self: Font): number
	getBaseline: function(self: Font): number
	getAscent: function(self: Font): number
	getDescent: function(self: Font): number
	hasGlyphs: function(self: Font, text_or_codepoint: string | integer, ...: string | integer): boolean
	getKerning: function(self: Font, left: string | integer, right: string | integer): number
	setFallbacks: function(self: Font, ...: Font)
	setLineHeight: function(self: Font, height: number)
	getLineHeight: function(self: Font): number
	getDPIScale: function(self: Font): number
	getFilter: function(self: Font): string, string, number
	setFilter: function(self: Font, min: string, mag?: string, anisotropy?: number)
	getWrap: function(self: Font, text: string, wrap_limit: number): number, {string}
end

local record Text
	type: function(self: Text): string
	typeOf: function(self: Text, type_name: string): boolean
	release: function(self: Text): boolean
	set: function(self: Text, text: any)
	setf: function(self: Text, text: any, wrap_limit: number, align: string)
	add: function(self: Text, text: any, transform_or_x?: any, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer
	addf: function(self: Text, text: any, wrap_limit: number, align: string, transform_or_x?: any, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer
	clear: function(self: Text)
	setFont: function(self: Text, font: Font)
	getFont: function(self: Text): Font
	getWidth: function(self: Text, index?: integer): number
	getHeight: function(self: Text, index?: integer): number
	getDimensions: function(self: Text, index?: integer): number, number
end

local record Quad
	type: function(self: Quad): string
	typeOf: function(self: Quad, type_name: string): boolean
	release: function(self: Quad): boolean
	setViewport: function(self: Quad, x: number, y: number, width: number, height: number, texture_width?: number, texture_height?: number)
	getViewport: function(self: Quad): number, number, number, number
	getTextureDimensions: function(self: Quad): number, number
	setLayer: function(self: Quad, layer: integer)
	getLayer: function(self: Quad): integer
end

local record Mesh
	type: function(self: Mesh): string
	typeOf: function(self: Mesh, type_name: string): boolean
	release: function(self: Mesh): boolean
	setVertices: function(self: Mesh, vertices_or_data: any, start_vertex?: integer, vertex_count?: integer)
	-- The second argument may be a vertex table or the first numeric component.
	setVertex: function(self: Mesh, index: integer, vertex_or_component: any, components: number...)
	getVertex: function(self: Mesh, index: integer): any
	setVertexAttribute: function(self: Mesh, vertex_index: integer, attribute_index: integer, components: number...)
	getVertexAttribute: function(self: Mesh, vertex_index: integer, attribute_index: integer): any
	getVertexCount: function(self: Mesh): integer
	getVertexFormat: function(self: Mesh): {{any}}
	setAttributeEnabled: function(self: Mesh, name: string, enabled: boolean)
	isAttributeEnabled: function(self: Mesh, name: string): boolean
	attachAttribute: function(self: Mesh, name: string, mesh: Mesh, step?: string, attribute_name?: string)
	detachAttribute: function(self: Mesh, name: string): boolean
	setVertexMap: function(self: Mesh, indices: any...)
	getVertexMap: function(self: Mesh): {integer} | nil
	setTexture: function(self: Mesh, texture?: Image | Canvas)
	getTexture: function(self: Mesh): Image | Canvas | nil
	setDrawMode: function(self: Mesh, mode: string)
	getDrawMode: function(self: Mesh): string
	setDrawRange: function(self: Mesh, start?: integer, count?: integer)
	getDrawRange: function(self: Mesh): any
	flush: function(self: Mesh)
end

local record SpriteBatch
	type: function(self: SpriteBatch): string
	typeOf: function(self: SpriteBatch, type_name: string): boolean
	release: function(self: SpriteBatch): boolean
	-- add/set accept either a Quad followed by a standard transform, or a transform directly.
	add: function(self: SpriteBatch, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number): integer
	set: function(self: SpriteBatch, index: integer, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number)
	addLayer: function(self: SpriteBatch, layer: integer, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number): integer
	setLayer: function(self: SpriteBatch, index: integer, layer: integer, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number)
	clear: function(self: SpriteBatch)
	flush: function(self: SpriteBatch)
	setTexture: function(self: SpriteBatch, texture: Image | Canvas)
	getTexture: function(self: SpriteBatch): Image | Canvas
	setColor: function(self: SpriteBatch, red_or_color?: number | {number}, green?: number, blue?: number, alpha?: number)
	getColor: function(self: SpriteBatch): number, number, number, number
	getCount: function(self: SpriteBatch): integer
	getBufferSize: function(self: SpriteBatch): integer
	attachAttribute: function(self: SpriteBatch, name: string, mesh: Mesh)
	setDrawRange: function(self: SpriteBatch, start?: integer, count?: integer)
	getDrawRange: function(self: SpriteBatch): number, number
end

local record ParticleSystem
	type: function(self: ParticleSystem): string
	typeOf: function(self: ParticleSystem, type_name: string): boolean
	release: function(self: ParticleSystem): boolean
	clone: function(self: ParticleSystem): ParticleSystem
	setTexture: function(self: ParticleSystem, texture: Image | Canvas)
	getTexture: function(self: ParticleSystem): Image | Canvas
	setBufferSize: function(self: ParticleSystem, size: integer)
	getBufferSize: function(self: ParticleSystem): integer
	setInsertMode: function(self: ParticleSystem, mode: string)
	getInsertMode: function(self: ParticleSystem): string
	setEmissionRate: function(self: ParticleSystem, rate: number)
	getEmissionRate: function(self: ParticleSystem): number
	setEmitterLifetime: function(self: ParticleSystem, lifetime: number)
	getEmitterLifetime: function(self: ParticleSystem): number
	setParticleLifetime: function(self: ParticleSystem, minimum: number, maximum?: number)
	getParticleLifetime: function(self: ParticleSystem): number, number
	setPosition: function(self: ParticleSystem, x: number, y: number)
	getPosition: function(self: ParticleSystem): number, number
	moveTo: function(self: ParticleSystem, x: number, y: number)
	setEmissionArea: function(self: ParticleSystem, distribution?: string, x?: number, y?: number, angle?: number, relative?: boolean)
	getEmissionArea: function(self: ParticleSystem): string, number, number, number, boolean
	setAreaSpread: function(self: ParticleSystem, distribution?: string, x?: number, y?: number)
	getAreaSpread: function(self: ParticleSystem): string, number, number
	setDirection: function(self: ParticleSystem, direction: number)
	getDirection: function(self: ParticleSystem): number
	setSpread: function(self: ParticleSystem, spread: number)
	getSpread: function(self: ParticleSystem): number
	setSpeed: function(self: ParticleSystem, minimum: number, maximum?: number)
	getSpeed: function(self: ParticleSystem): number, number
	setLinearAcceleration: function(self: ParticleSystem, xmin: number, ymin: number, xmax?: number, ymax?: number)
	getLinearAcceleration: function(self: ParticleSystem): number, number, number, number
	setRadialAcceleration: function(self: ParticleSystem, minimum: number, maximum?: number)
	getRadialAcceleration: function(self: ParticleSystem): number, number
	setTangentialAcceleration: function(self: ParticleSystem, minimum: number, maximum?: number)
	getTangentialAcceleration: function(self: ParticleSystem): number, number
	setLinearDamping: function(self: ParticleSystem, minimum: number, maximum?: number)
	getLinearDamping: function(self: ParticleSystem): number, number
	setSizes: function(self: ParticleSystem, sizes: number...)
	getSizes: function(self: ParticleSystem): number...
	setSizeVariation: function(self: ParticleSystem, variation: number)
	getSizeVariation: function(self: ParticleSystem): number
	setRotation: function(self: ParticleSystem, minimum: number, maximum?: number)
	getRotation: function(self: ParticleSystem): number, number
	setSpin: function(self: ParticleSystem, start: number, finish?: number)
	getSpin: function(self: ParticleSystem): number, number
	setSpinVariation: function(self: ParticleSystem, variation: number)
	getSpinVariation: function(self: ParticleSystem): number
	setOffset: function(self: ParticleSystem, x: number, y: number)
	getOffset: function(self: ParticleSystem): number, number
	setColors: function(self: ParticleSystem, colors: any...)
	getColors: function(self: ParticleSystem): {number}...
	setQuads: function(self: ParticleSystem, quads: any...)
	getQuads: function(self: ParticleSystem): {Quad}
	setRelativeRotation: function(self: ParticleSystem, enabled: boolean)
	hasRelativeRotation: function(self: ParticleSystem): boolean
	getCount: function(self: ParticleSystem): integer
	start: function(self: ParticleSystem)
	stop: function(self: ParticleSystem)
	pause: function(self: ParticleSystem)
	reset: function(self: ParticleSystem)
	emit: function(self: ParticleSystem, count: integer)
	isActive: function(self: ParticleSystem): boolean
	isPaused: function(self: ParticleSystem): boolean
	isStopped: function(self: ParticleSystem): boolean
	isEmpty: function(self: ParticleSystem): boolean
	isFull: function(self: ParticleSystem): boolean
	update: function(self: ParticleSystem, delta_time: number)
end

local record Shader
	type: function(self: Shader): string
	typeOf: function(self: Shader, type_name: string): boolean
	release: function(self: Shader): boolean
	getWarnings: function(self: Shader): string
	hasUniform: function(self: Shader, name: string): boolean
	send: function(self: Shader, name: string, values: any...)
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

local record Window
	getDesktopDimensions: function(display?: integer): integer, integer
	getDisplayCount: function(): integer
	getDisplayName: function(display: integer): string
	getDisplayOrientation: function(display?: integer): string
	getFullscreenModes: function(display?: integer): {WindowSize}
	setFullscreen: function(fullscreen: boolean, fullscreen_type?: string): boolean
	getFullscreen: function(): boolean, string
	isOpen: function(): boolean
	getIcon: function(): any
	getMode: function(): integer, integer, WindowMode
	setMode: function(width: integer, height: integer, settings?: WindowMode): boolean
	updateMode: function(settings_or_width: WindowMode | integer, height?: integer, settings?: WindowMode): boolean
	getPosition: function(): integer, integer, integer
	getSafeArea: function(): number, number, number, number
	setTitle: function(title: string)
	getTitle: function(): string
	setVSync: function(vsync: boolean | integer)
	getVSync: function(): integer
	setDisplaySleepEnabled: function(enabled: boolean)
	isDisplaySleepEnabled: function(): boolean
	hasFocus: function(): boolean
	hasMouseFocus: function(): boolean
	isVisible: function(): boolean
	isMaximized: function(): boolean
	isMinimized: function(): boolean
	getDPIScale: function(): number
	getNativeDPIScale: function(): number
	toPixels: function(value: number, y?: number): number, number
	fromPixels: function(value: number, y?: number): number, number
end

local record Event
	-- Dora owns the platform event pump; this does not pump a second OS queue.
	pump: function()
	poll: function(): function(): any...
	-- Returns no values immediately when the embedded instance queue is empty.
	wait: function(): any...
	push: function(name: string, args: any...): boolean
	clear: function()
	-- Requests that only the current embedded Love instance stop.
	quit: function(exit_status?: integer | string): boolean
end

local type FileType = string
local type FileMode = string
local type BufferMode = string
local record FileData
	type: function(self: FileData): string
	typeOf: function(self: FileData, type_name: string): boolean
	release: function(self: FileData): boolean
	getString: function(self: FileData): string
	getSize: function(self: FileData): integer
	getPointer: function(self: FileData): any
	getFFIPointer: function(self: FileData): nil
	clone: function(self: FileData): FileData
	getFilename: function(self: FileData): string
	getExtension: function(self: FileData): string
end
local record ImageData
	release: function(self: ImageData): boolean
	type: function(self: ImageData): string
	typeOf: function(self: ImageData, type_name: string): boolean
	getString: function(self: ImageData): string
	getSize: function(self: ImageData): integer
	getPointer: function(self: ImageData): any
	getFFIPointer: function(self: ImageData): nil
	clone: function(self: ImageData): ImageData
	getWidth: function(self: ImageData): integer
	getHeight: function(self: ImageData): integer
	getDimensions: function(self: ImageData): integer, integer
	getFormat: function(self: ImageData): string
	getPixel: function(self: ImageData, x: integer, y: integer): number, number, number, number
	setPixel: function(self: ImageData, x: integer, y: integer, red: number, green: number, blue: number, alpha?: number)
	mapPixel: function(self: ImageData, mapper: function(x: integer, y: integer, red: number, green: number, blue: number, alpha: number): (number, number, number, number), x?: integer, y?: integer, width?: integer, height?: integer)
	paste: function(self: ImageData, source: ImageData, destination_x: integer, destination_y: integer, source_x?: integer, source_y?: integer, source_width?: integer, source_height?: integer)
	encode: function(self: ImageData, format: string, filename?: string): FileData
end
local record CompressedImageData
	release: function(self: CompressedImageData): boolean
	type: function(self: CompressedImageData): string
	typeOf: function(self: CompressedImageData, type_name: string): boolean
	getString: function(self: CompressedImageData): string
	getSize: function(self: CompressedImageData): integer
	getPointer: function(self: CompressedImageData): any
	getFFIPointer: function(self: CompressedImageData): nil
	clone: function(self: CompressedImageData): CompressedImageData
	getWidth: function(self: CompressedImageData, mipmap?: integer): integer
	getHeight: function(self: CompressedImageData, mipmap?: integer): integer
	getDimensions: function(self: CompressedImageData, mipmap?: integer): integer, integer
	getMipmapCount: function(self: CompressedImageData): integer
	getFormat: function(self: CompressedImageData): string
end
local record ImageModule
	newImageData: function(filename_or_width_or_data: string | integer | FileData, height?: integer, format?: string, data?: string | FileData): ImageData
	newCompressedData: function(filename_or_data: string | FileData): CompressedImageData
	isCompressed: function(filename_or_data: string | FileData): boolean
end
local record Rasterizer
	release: function(self: Rasterizer): boolean
	type: function(self: Rasterizer): string
	typeOf: function(self: Rasterizer, type_name: string): boolean
	getHeight: function(self: Rasterizer): integer
	getAdvance: function(self: Rasterizer): integer
	getAscent: function(self: Rasterizer): integer
	getDescent: function(self: Rasterizer): integer
	getLineHeight: function(self: Rasterizer): integer
	getGlyphData: function(self: Rasterizer, glyph: string | integer): GlyphData
	getGlyphCount: function(self: Rasterizer): integer
	hasGlyphs: function(self: Rasterizer, glyph: string | integer, ...: string | integer): boolean
end
local record GlyphData
	release: function(self: GlyphData): boolean
	type: function(self: GlyphData): string
	typeOf: function(self: GlyphData, type_name: string): boolean
	getString: function(self: GlyphData): string
	getSize: function(self: GlyphData): integer
	getPointer: function(self: GlyphData): any
	getFFIPointer: function(self: GlyphData): nil
	clone: function(self: GlyphData): GlyphData
	getWidth: function(self: GlyphData): integer
	getHeight: function(self: GlyphData): integer
	getDimensions: function(self: GlyphData): integer, integer
	getGlyph: function(self: GlyphData): integer
	getGlyphString: function(self: GlyphData): string
	getAdvance: function(self: GlyphData): integer
	getBearing: function(self: GlyphData): integer, integer
	getBoundingBox: function(self: GlyphData): integer, integer, integer, integer
	getFormat: function(self: GlyphData): string
end
local record FontModule
	newImageRasterizer: function(image_data: ImageData, glyphs: string, extra_spacing?: integer, dpi_scale?: number): Rasterizer
	newBMFontRasterizer: function(filename_or_file_data: string | FileData, images?: ImageData | string | FileData | {ImageData | string | FileData}, dpi_scale?: number): Rasterizer
	newTrueTypeRasterizer: function(filename_or_size_or_data?: string | integer | FileData, size_or_hinting?: integer | string, hinting_or_dpi?: string | number, dpi_scale?: number): Rasterizer
	newRasterizer: function(filename_or_size_or_data?: string | integer | FileData, size_or_hinting?: integer | string, hinting_or_dpi?: string | number, dpi_scale?: number): Rasterizer
	newGlyphData: function(rasterizer: Rasterizer, glyph: string | integer): GlyphData
end
local record SoundData
	type: function(self: SoundData): string
	typeOf: function(self: SoundData, type_name: string): boolean
	release: function(self: SoundData): boolean
	getString: function(self: SoundData): string
	getSize: function(self: SoundData): integer
	getPointer: function(self: SoundData): any
	getFFIPointer: function(self: SoundData): nil
	clone: function(self: SoundData): SoundData
	getChannelCount: function(self: SoundData): integer
	getChannels: function(self: SoundData): integer
	getBitDepth: function(self: SoundData): integer
	getSampleRate: function(self: SoundData): integer
	getSampleCount: function(self: SoundData): integer
	getDuration: function(self: SoundData): number
	getSample: function(self: SoundData, index: integer, channel?: integer): number
	setSample: function(self: SoundData, index: integer, channel_or_sample: number, sample?: number)
end
local record Decoder
	type: function(self: Decoder): string
	typeOf: function(self: Decoder, type_name: string): boolean
	release: function(self: Decoder): boolean
	clone: function(self: Decoder): Decoder
	getChannelCount: function(self: Decoder): integer
	getChannels: function(self: Decoder): integer
	getBitDepth: function(self: Decoder): integer
	getSampleRate: function(self: Decoder): integer
	getDuration: function(self: Decoder): number
	decode: function(self: Decoder): SoundData | nil
	seek: function(self: Decoder, offset: number)
end
local record SoundModule
	newDecoder: function(filename_or_data: string | FileData, buffer_size?: integer): Decoder
	newSoundData: function(filename_or_samples_or_data_or_decoder: string | integer | FileData | Decoder, sample_rate_or_buffer_size?: integer, bit_depth?: integer, channels?: integer): SoundData
end
local record ByteData
	type: function(self: ByteData): string
	typeOf: function(self: ByteData, type_name: string): boolean
	release: function(self: ByteData): boolean
	getString: function(self: ByteData): string
	getSize: function(self: ByteData): integer
	getPointer: function(self: ByteData): any
	getFFIPointer: function(self: ByteData): nil
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
local record CompressedData
	type: function(self: CompressedData): string
	typeOf: function(self: CompressedData, type_name: string): boolean
	release: function(self: CompressedData): boolean
	getString: function(self: CompressedData): string
	getSize: function(self: CompressedData): integer
	getPointer: function(self: CompressedData): any
	getFFIPointer: function(self: CompressedData): nil
	clone: function(self: CompressedData): CompressedData
	getFormat: function(self: CompressedData): string
end
local record DataModule
	newByteData: function(size_or_string_or_data: any, offset?: integer, size?: integer): ByteData
	newDataView: function(data: any, offset: integer, size: integer): DataView
	encode: function(container: string, format: string, source: any, line_length?: integer): string | ByteData
	decode: function(container: string, format: string, source: any): string | ByteData
	compress: function(container: string, format: string, source: any, level?: integer): string | CompressedData
	decompress: function(container: string, format_or_data: any, source?: any): string | ByteData
	pack: function(container: string, format: string, values: any...): string | ByteData
	unpack: function(format: string, source: any, position?: integer): any...
	getPackedSize: function(format: string): integer
	hash: function(hash_function: string, source: any): string
end
local record RandomGenerator
	type: function(self: RandomGenerator): string
	typeOf: function(self: RandomGenerator, type_name: string): boolean
	release: function(self: RandomGenerator): boolean
	random: function(self: RandomGenerator, lower_or_upper?: number, upper?: number): number
	randomNormal: function(self: RandomGenerator, standard_deviation?: number, mean?: number): number
	setSeed: function(self: RandomGenerator, low_or_seed: number, high?: number)
	getSeed: function(self: RandomGenerator): number, number
	setState: function(self: RandomGenerator, state: string)
	getState: function(self: RandomGenerator): string
end
local record Transform
	type: function(self: Transform): string
	typeOf: function(self: Transform, type_name: string): boolean
	release: function(self: Transform): boolean
	clone: function(self: Transform): Transform
	inverse: function(self: Transform): Transform
	apply: function(self: Transform, other: Transform): Transform
	isAffine2DTransform: function(self: Transform): boolean
	translate: function(self: Transform, x: number, y: number): Transform
	rotate: function(self: Transform, angle: number): Transform
	scale: function(self: Transform, x: number, y?: number): Transform
	shear: function(self: Transform, x: number, y: number): Transform
	reset: function(self: Transform): Transform
	setTransformation: function(self: Transform, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): Transform
	setMatrix: function(self: Transform, layout_or_elements: string | {number} | {{number}}, elements?: {number} | {{number}}): Transform
	getMatrix: function(self: Transform): number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number
	transformPoint: function(self: Transform, x: number, y: number): number, number
	inverseTransformPoint: function(self: Transform, x: number, y: number): number, number
end
local record BezierCurve
	type: function(self: BezierCurve): string
	typeOf: function(self: BezierCurve, type_name: string): boolean
	release: function(self: BezierCurve): boolean
	getDegree: function(self: BezierCurve): integer
	getDerivative: function(self: BezierCurve): BezierCurve
	getControlPoint: function(self: BezierCurve, index: integer): number, number
	setControlPoint: function(self: BezierCurve, index: integer, x: number, y: number)
	insertControlPoint: function(self: BezierCurve, x: number, y: number, index?: integer)
	removeControlPoint: function(self: BezierCurve, index: integer)
	getControlPointCount: function(self: BezierCurve): integer
	translate: function(self: BezierCurve, x: number, y: number)
	rotate: function(self: BezierCurve, angle: number, origin_x?: number, origin_y?: number)
	scale: function(self: BezierCurve, scale: number, origin_x?: number, origin_y?: number)
	evaluate: function(self: BezierCurve, time: number): number, number
	getSegment: function(self: BezierCurve, start: number, finish: number): BezierCurve
	render: function(self: BezierCurve, accuracy?: integer): {number}
	renderSegment: function(self: BezierCurve, start: number, finish: number, accuracy?: integer): {number}
end
local record MathModule
	newRandomGenerator: function(low_or_seed?: number, high?: number): RandomGenerator
	newTransform: function(x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): Transform
	newBezierCurve: function(vertices_or_coordinates: any, coordinates: number...): BezierCurve
	noise: function(x: number, y?: number, z?: number, w?: number): number
	random: function(lower_or_upper?: number, upper?: number): number
	randomNormal: function(standard_deviation?: number, mean?: number): number
	setRandomSeed: function(low_or_seed: number, high?: number)
	getRandomSeed: function(): number, number
	setRandomState: function(state: string)
	getRandomState: function(): string
	colorToBytes: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number, number, number | nil
	colorFromBytes: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number, number, number | nil
	gammaToLinear: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number | nil, number | nil, number | nil
	linearToGamma: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number | nil, number | nil, number | nil
	isConvex: function(vertices_or_coordinates: any, coordinates: number...): boolean
	triangulate: function(vertices_or_coordinates: any, coordinates: number...): {{number}}
	compress: function(container: string, format: string, source: any, level?: integer): string | CompressedData
	decompress: function(container: string, format_or_data: any, source?: any): string | ByteData
end
local record File
	type: function(self: File): string
	typeOf: function(self: File, type_name: string): boolean
	release: function(self: File): boolean
	open: function(self: File, mode: FileMode): boolean | nil, string | nil
	close: function(self: File): boolean
	isOpen: function(self: File): boolean
	getSize: function(self: File): number | nil, string | nil
	read: function(self: File, container_or_size?: string | integer, size?: integer): string | FileData | nil, number | string
	write: function(self: File, data: string | FileData, size?: integer): boolean | nil, string | nil
	flush: function(self: File): boolean | nil, string | nil
	isEOF: function(self: File): boolean
	tell: function(self: File): number | nil, string | nil
	seek: function(self: File, position: number): boolean
	lines: function(self: File): function(): string | nil
	setBuffer: function(self: File, mode: BufferMode, size?: integer): boolean
	getBuffer: function(self: File): BufferMode, integer
	getMode: function(self: File): FileMode
	getFilename: function(self: File): string
	getExtension: function(self: File): string
end
local record FileInfo
	type: FileType
	size: number | nil
	modtime: number | nil
end
local record Filesystem
	setIdentity: function(identity: string, append_to_path?: boolean)
	getIdentity: function(): string
	getSource: function(): string
	getSaveDirectory: function(): string
	getWorkingDirectory: function(): string
	getUserDirectory: function(): string
	getAppdataDirectory: function(): string
	getSourceBaseDirectory: function(): string
	getExecutablePath: function(): string
	getRealDirectory: function(filename: string): string | nil, string | nil
	getRequirePath: function(): string
	setRequirePath: function(path: string)
	mount: function(archive: string | FileData, mountpoint: string, append_to_path?: boolean): boolean
	unmount: function(archive: string | FileData): boolean
	isFused: function(): boolean
	newFile: function(filename: string, mode?: FileMode): File
	newFileData: function(data_or_filename_or_file: string | File, filename?: string): FileData
	read: function(container_or_filename: string, filename_or_size?: string | integer, size?: integer): string | FileData | nil, number | string
	load: function(filename: string): function | nil, string | nil
	lines: function(filename: string): function(): string | nil
	write: function(filename: string, data: string | FileData, size?: integer): boolean, string | nil
	append: function(filename: string, data: string | FileData, size?: integer): boolean, string | nil
	getInfo: function(filename: string, filter_type?: FileType): FileInfo | nil
	exists: function(filename: string): boolean
	isDirectory: function(filename: string): boolean
	isFile: function(filename: string): boolean
	isSymlink: function(filename: string): boolean
	getLastModified: function(filename: string): number | nil, string | nil
	getSize: function(filename: string): number | nil, string | nil
	createDirectory: function(name: string): boolean, string | nil
	remove: function(name: string): boolean, string | nil
	getDirectoryItems: function(directory?: string): {string}
end

local type QuitCallback = function(): boolean | nil

local record Keyboard
	setKeyRepeat: function(enabled: boolean)
	hasKeyRepeat: function(): boolean
	isDown: function(keys: string...): boolean
	isScancodeDown: function(scancodes: string...): boolean
	getScancodeFromKey: function(key: string): string
	getKeyFromScancode: function(scancode: string): string
	setTextInput: function(enabled: boolean, x?: number, y?: number, width?: number, height?: number)
	hasTextInput: function(): boolean
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

local record Cursor
	release: function(self: Cursor): boolean
	getType: function(self: Cursor): CursorType
	type: function(self: Cursor): string
	typeOf: function(self: Cursor, type_name: string): boolean
end

local record Mouse
	getPosition: function(): number, number
	getX: function(): number
	getY: function(): number
	setPosition: function(x: number, y: number)
	setX: function(x: number)
	setY: function(y: number)
	isDown: function(buttons: integer | {integer}, ...: integer): boolean
	setVisible: function(visible: boolean)
	isVisible: function(): boolean
	setGrabbed: function(grabbed: boolean)
	isGrabbed: function(): boolean
	setRelativeMode: function(relative: boolean): boolean
	getRelativeMode: function(): boolean
	newCursor: function(image: ImageData | FileData | string, hot_x?: integer, hot_y?: integer): Cursor
	getSystemCursor: function(cursor_type: SystemCursor): Cursor
	setCursor: function(cursor?: Cursor)
	getCursor: function(): Cursor | nil
	isCursorSupported: function(): boolean
end

local record Timer
	step: function(): number
	getDelta: function(): number
	getFPS: function(): integer
	getAverageDelta: function(): number
	sleep: function(seconds: number)
	getTime: function(): number
end

local record System
	getOS: function(): string
	getProcessorCount: function(): integer
	setClipboardText: function(text: string)
	getClipboardText: function(): string
	getPowerInfo: function(): string, integer | nil, integer | nil
	-- Embedded LoveNode permits only http, https, and mailto schemes.
	openURL: function(url: string): boolean
	vibrate: function(seconds?: number)
	hasBackgroundMusic: function(): boolean
end

local record Thread
	release: function(self: Thread): boolean
	type: function(self: Thread): string
	typeOf: function(self: Thread, type_name: string): boolean
	start: function(self: Thread, args: any...): boolean
	wait: function(self: Thread)
	getError: function(self: Thread): string | nil
	isRunning: function(self: Thread): boolean
end

local record Channel
	release: function(self: Channel): boolean
	type: function(self: Channel): string
	typeOf: function(self: Channel, type_name: string): boolean
	push: function(self: Channel, value: any): number
	supply: function(self: Channel, value: any, timeout?: number): boolean
	pop: function(self: Channel): any
	demand: function(self: Channel, timeout?: number): any
	peek: function(self: Channel): any
	getCount: function(self: Channel): integer
	hasRead: function(self: Channel, id: number): boolean
	clear: function(self: Channel)
	performAtomic: function(self: Channel, callback: any, args: any...): any
end

local record ThreadModule
	newThread: function(code_or_filename: string | any): Thread
	newChannel: function(): Channel
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

local record Source
	type: function(self: Source): string
	typeOf: function(self: Source, type_name: string): boolean
	release: function(self: Source): boolean
	clone: function(self: Source): Source
	play: function(self: Source): boolean
	pause: function(self: Source)
	stop: function(self: Source)
	isPlaying: function(self: Source): boolean
	isPaused: function(self: Source): boolean
	setLooping: function(self: Source, looping: boolean)
	isLooping: function(self: Source): boolean
	setVolume: function(self: Source, volume: number)
	getVolume: function(self: Source): number
	setPitch: function(self: Source, pitch: number)
	getPitch: function(self: Source): number
	seek: function(self: Source, offset: number, unit?: string)
	tell: function(self: Source, unit?: string): number
	getDuration: function(self: Source, unit?: string): number
	getChannelCount: function(self: Source): integer
	getChannels: function(self: Source): integer
	getFreeBufferCount: function(self: Source): integer
	queue: function(self: Source, data: SoundData, offset_or_length?: number, length?: number): boolean
	setPosition: function(self: Source, x: number, y: number, z?: number)
	getPosition: function(self: Source): number, number, number
	setVelocity: function(self: Source, x: number, y: number, z?: number)
	getVelocity: function(self: Source): number, number, number
	setDirection: function(self: Source, x: number, y: number, z?: number)
	getDirection: function(self: Source): number, number, number
	setCone: function(self: Source, inner_angle: number, outer_angle: number, outer_volume?: number, outer_high_gain?: number)
	getCone: function(self: Source): number, number, number, number
	setAirAbsorption: function(self: Source, factor: number)
	getAirAbsorption: function(self: Source): number
	setVolumeLimits: function(self: Source, min_volume: number, max_volume: number)
	getVolumeLimits: function(self: Source): number, number
	setRelative: function(self: Source, relative: boolean)
	isRelative: function(self: Source): boolean
	setAttenuationDistances: function(self: Source, reference_distance: number, max_distance: number)
	getAttenuationDistances: function(self: Source): number, number
	setRolloff: function(self: Source, rolloff: number)
	getRolloff: function(self: Source): number
	setFilter: function(self: Source, filter?: AudioFilterSettings): boolean
	getFilter: function(self: Source, target?: AudioFilterSettings): AudioFilterSettings | nil
	setEffect: function(self: Source, name: string, enabled?: boolean | AudioFilterSettings): boolean
	getEffect: function(self: Source, name: string, target?: AudioFilterSettings): boolean, AudioFilterSettings | nil
	getActiveEffects: function(self: Source): {string}
	getType: function(self: Source): string
end

local record RecordingDevice
	type: function(self: RecordingDevice): string
	typeOf: function(self: RecordingDevice, type_name: string): boolean
	release: function(self: RecordingDevice): boolean
	start: function(self: RecordingDevice, samples?: integer, sample_rate?: integer, bit_depth?: integer, channels?: integer): boolean
	stop: function(self: RecordingDevice): SoundData | nil
	getData: function(self: RecordingDevice): SoundData | nil
	getSampleCount: function(self: RecordingDevice): integer
	getSampleRate: function(self: RecordingDevice): integer
	getBitDepth: function(self: RecordingDevice): integer
	getChannelCount: function(self: RecordingDevice): integer
	getName: function(self: RecordingDevice): string
	isRecording: function(self: RecordingDevice): boolean
end

local record Audio
	newSource: function(filename_or_data: string | SoundData, source_type?: string): Source
	newQueueableSource: function(sample_rate: integer, bit_depth: integer, channels: integer, buffers?: integer): Source
	play: function(sources: {Source}): boolean
	play: function(sources: Source...): boolean
	pause: function(): {Source}
	pause: function(sources: {Source})
	pause: function(sources: Source...)
	stop: function(sources: {Source})
	stop: function(sources: Source...)
	getActiveSourceCount: function(): integer
	getSourceCount: function(): integer
	setVolume: function(volume: number)
	getVolume: function(): number
	-- Sets the application-global iOS audio session mixing policy. Other platforms return false.
	setMixWithSystem: function(mix: boolean): boolean
	setPosition: function(x: number, y: number, z?: number)
	getPosition: function(): number, number, number
	setOrientation: function(forward_x: number, forward_y: number, forward_z: number,
		up_x: number, up_y: number, up_z: number)
	getOrientation: function(): number, number, number, number, number, number
	setVelocity: function(x: number, y: number, z?: number)
	getVelocity: function(): number, number, number
	setDopplerScale: function(scale: number)
	getDopplerScale: function(): number
	setDistanceModel: function(model: string)
	getDistanceModel: function(): string
	setEffect: function(name: string, settings?: AudioEffectSettings | boolean): boolean
	getEffect: function(name: string, target?: AudioEffectSettings): AudioEffectSettings | nil
	getActiveEffects: function(): {string}
	getMaxSceneEffects: function(): integer
	getMaxSourceEffects: function(): integer
	getRecordingDevices: function(): {RecordingDevice}
	isEffectsSupported: function(): boolean
end

local record Body
	type: function(self: Body): string
	typeOf: function(self: Body, type_name: string): boolean
	release: function(self: Body): boolean
	destroy: function(self: Body)
	isDestroyed: function(self: Body): boolean
	getPosition: function(self: Body): number, number
	setPosition: function(self: Body, x: number, y: number)
	getX: function(self: Body): number
	setX: function(self: Body, x: number)
	getY: function(self: Body): number
	setY: function(self: Body, y: number)
	getTransform: function(self: Body): number, number, number
	setTransform: function(self: Body, x: number, y: number, angle: number)
	getAngle: function(self: Body): number
	setAngle: function(self: Body, angle: number)
	getLinearVelocity: function(self: Body): number, number
	setLinearVelocity: function(self: Body, x: number, y: number)
	getAngularVelocity: function(self: Body): number
	setAngularVelocity: function(self: Body, velocity: number)
	getLinearDamping: function(self: Body): number
	setLinearDamping: function(self: Body, damping: number)
	getAngularDamping: function(self: Body): number
	setAngularDamping: function(self: Body, damping: number)
	getMass: function(self: Body): number
	setMass: function(self: Body, mass: number)
	getInertia: function(self: Body): number
	setInertia: function(self: Body, inertia: number)
	getMassData: function(self: Body): number, number, number, number
	setMassData: function(self: Body, center_x: number, center_y: number, mass: number, inertia: number)
	resetMassData: function(self: Body)
	getGravityScale: function(self: Body): number
	setGravityScale: function(self: Body, scale: number)
	getLocalCenter: function(self: Body): number, number
	getWorldCenter: function(self: Body): number, number
	isFixedRotation: function(self: Body): boolean
	setFixedRotation: function(self: Body, fixed: boolean)
	isAwake: function(self: Body): boolean
	setAwake: function(self: Body, awake: boolean)
	isSleepingAllowed: function(self: Body): boolean
	setSleepingAllowed: function(self: Body, allowed: boolean)
	isActive: function(self: Body): boolean
	setActive: function(self: Body, active: boolean)
	isBullet: function(self: Body): boolean
	setBullet: function(self: Body, bullet: boolean)
	applyLinearImpulse: function(self: Body, x_impulse: number, y_impulse: number, point_x?: number, point_y?: number)
	applyAngularImpulse: function(self: Body, impulse: number)
	applyForce: function(self: Body, x_force: number, y_force: number, point_x?: number, point_y?: number)
	applyTorque: function(self: Body, torque: number)
	getType: function(self: Body): string
	setType: function(self: Body, body_type: string)
	getWorldPoint: function(self: Body, x: number, y: number): number, number
	getWorldVector: function(self: Body, x: number, y: number): number, number
	getWorldPoints: function(self: Body, x: number, y: number, coordinates: number...): number...
	getLocalPoint: function(self: Body, x: number, y: number): number, number
	getLocalVector: function(self: Body, x: number, y: number): number, number
	getLocalPoints: function(self: Body, x: number, y: number, coordinates: number...): number...
	getLinearVelocityFromWorldPoint: function(self: Body, x: number, y: number): number, number
	getLinearVelocityFromLocalPoint: function(self: Body, x: number, y: number): number, number
end

local record Shape
	type: function(self: Shape): string
	typeOf: function(self: Shape, type_name: string): boolean
	release: function(self: Shape): boolean
	getType: function(self: Shape): string
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

local record Fixture
	type: function(self: Fixture): string
	typeOf: function(self: Fixture, type_name: string): boolean
	release: function(self: Fixture): boolean
	destroy: function(self: Fixture)
	isDestroyed: function(self: Fixture): boolean
	getType: function(self: Fixture): string
	setFriction: function(self: Fixture, friction: number)
	getFriction: function(self: Fixture): number
	setRestitution: function(self: Fixture, restitution: number)
	getRestitution: function(self: Fixture): number
	setDensity: function(self: Fixture, density: number)
	getDensity: function(self: Fixture): number
	setSensor: function(self: Fixture, sensor: boolean)
	isSensor: function(self: Fixture): boolean
	getBody: function(self: Fixture): Body
	getShape: function(self: Fixture): Shape
	testPoint: function(self: Fixture, x: number, y: number): boolean
	rayCast: function(self: Fixture, x1: number, y1: number, x2: number, y2: number, max_fraction: number, child_index?: integer): number | nil, number | nil, number | nil
	setFilterData: function(self: Fixture, category_bits: integer, mask_bits: integer, group_index: integer)
	getFilterData: function(self: Fixture): integer, integer, integer
	setCategory: function(self: Fixture, categories: integer | {integer}, ...: integer)
	getCategory: function(self: Fixture): integer...
	setMask: function(self: Fixture, categories: integer | {integer}, ...: integer)
	getMask: function(self: Fixture): integer...
	setUserData: function(self: Fixture, value: any)
	getUserData: function(self: Fixture): any
	getBoundingBox: function(self: Fixture, child_index?: integer): number, number, number, number
	getMassData: function(self: Fixture): number, number, number, number
	getGroupIndex: function(self: Fixture): integer
	setGroupIndex: function(self: Fixture, index: integer)
end

local record Contact
	type: function(self: Contact): string
	typeOf: function(self: Contact, type_name: string): boolean
	release: function(self: Contact): boolean
	isValid: function(self: Contact): boolean
	getFixtures: function(self: Contact): Fixture, Fixture
	getChildren: function(self: Contact): integer, integer
	getPositions: function(self: Contact): number...
	getNormal: function(self: Contact): number, number
	getFriction: function(self: Contact): number
	setFriction: function(self: Contact, friction: number)
	resetFriction: function(self: Contact)
	getRestitution: function(self: Contact): number
	setRestitution: function(self: Contact, restitution: number)
	resetRestitution: function(self: Contact)
	isEnabled: function(self: Contact): boolean
	setEnabled: function(self: Contact, enabled: boolean)
	isTouching: function(self: Contact): boolean
	getTangentSpeed: function(self: Contact): number
	setTangentSpeed: function(self: Contact, speed: number)
end

local record World
	type: function(self: World): string
	typeOf: function(self: World, type_name: string): boolean
	release: function(self: World): boolean
	destroy: function(self: World)
	isDestroyed: function(self: World): boolean
	update: function(self: World, delta_time: number, velocity_iterations?: integer, position_iterations?: integer)
	setGravity: function(self: World, x: number, y: number)
	getGravity: function(self: World): number, number
	setSleepingAllowed: function(self: World, allowed: boolean)
	isSleepingAllowed: function(self: World): boolean
	-- Fixture remains an internal record in the Teal module, so callback consumers receive it as any.
	queryBoundingBox: function(self: World, x1: number, y1: number, x2: number, y2: number, callback: function(any): boolean)
	rayCast: function(self: World, x1: number, y1: number, x2: number, y2: number, callback: function(any, number, number, number, number, number): number)
	-- Physics object records are internal to this module, so callback object parameters use any.
	setCallbacks: function(self: World, begin_contact?: function(any, any, any), end_contact?: function(any, any, any), pre_solve?: function(any, any, any), post_solve?: function(any, any, any, ...: number))
	getCallbacks: function(self: World): function(any, any, any) | nil, function(any, any, any) | nil, function(any, any, any) | nil, function(any, any, any, ...: number) | nil
end

local record Joint
	type: function(self: Joint): string
	typeOf: function(self: Joint, type_name: string): boolean
	release: function(self: Joint): boolean
	destroy: function(self: Joint)
	isDestroyed: function(self: Joint): boolean
	getType: function(self: Joint): string
	getBodies: function(self: Joint): Body, Body
	getAnchors: function(self: Joint): number, number, number, number
	getReactionForce: function(self: Joint, inverse_delta_time: number): number, number
	getReactionTorque: function(self: Joint, inverse_delta_time: number): number
	getCollideConnected: function(self: Joint): boolean
	setUserData: function(self: Joint, value: any)
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

local record Physics
	setMeter: function(scale: number)
	getMeter: function(): number
	newWorld: function(x_gravity?: number, y_gravity?: number, sleep?: boolean): World
	newBody: function(world: World, x?: number, y?: number, body_type?: string): Body
	newFixture: function(body: Body, shape: Shape, density?: number): Fixture
	-- Covers both radius and x, y, radius overloads.
	newCircleShape: function(first: number, second?: number, radius?: number): Shape
	-- Covers both width, height and x, y, width, height, angle overloads.
	newRectangleShape: function(first: number, second: number, third?: number, fourth?: number, angle?: number): Shape
	newPolygonShape: function(first: number | {number}, ...: number): Shape
	newEdgeShape: function(x1: number, y1: number, x2: number, y2: number): Shape
	newChainShape: function(loop: boolean, first: number | {number}, ...: number): Shape
	newDistanceJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean): Joint
	-- The fifth argument covers shared-anchor collide_connected or the second anchor x coordinate.
	newRevoluteJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2_or_collide?: number | boolean, y2?: number, collide_connected?: boolean, reference_angle?: number): Joint
	-- Covers shared-anchor and independent-anchor overloads.
	newPrismaticJoint: function(body1: Body, body2: Body, x1: number, y1: number, fifth: number, sixth: number, axis_x_or_collide?: number | boolean, axis_y?: number, collide_connected?: boolean, reference_angle?: number): Joint
	-- The fifth argument covers shared-anchor collide_connected or the second anchor x coordinate.
	newWeldJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2_or_collide?: number | boolean, y2?: number, collide_connected?: boolean, reference_angle?: number): Joint
	-- The fifth argument covers shared-anchor collide_connected or the second anchor x coordinate.
	newFrictionJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2_or_collide?: number | boolean, y2?: number, collide_connected?: boolean): Joint
	newRopeJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, max_length: number, collide_connected?: boolean): Joint
	newPulleyJoint: function(body1: Body, body2: Body, ground_x1: number, ground_y1: number, ground_x2: number, ground_y2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collide_connected?: boolean): Joint
	-- Covers shared-anchor and independent-anchor overloads.
	newWheelJoint: function(body1: Body, body2: Body, x1: number, y1: number, fifth: number, sixth: number, axis_x_or_collide?: number | boolean, axis_y?: number, collide_connected?: boolean): Joint
	newMouseJoint: function(body: Body, x: number, y: number): Joint
	newMotorJoint: function(body1: Body, body2: Body, correction_factor?: number, collide_connected?: boolean): Joint
	newGearJoint: function(joint1: Joint, joint2: Joint, ratio?: number, collide_connected?: boolean): Joint
end

local record Graphics
	clear: function(red?: number, green?: number, blue?: number, alpha?: number)
	discard: function(discard_color?: boolean | {boolean}, discard_depth_stencil?: boolean)
	flushBatch: function()
	setBackgroundColor: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number)
	getBackgroundColor: function(): number, number, number, number
	setDefaultFilter: function(min_filter: string, mag_filter?: string, anisotropy?: number)
	getDefaultFilter: function(): string, string, number
	setDefaultMipmapFilter: function(filter?: string, sharpness?: number)
	getDefaultMipmapFilter: function(): string | nil, number
	setColor: function(red: number, green: number, blue: number, alpha?: number)
	getColor: function(): number, number, number, number
	setLineWidth: function(width: number)
	getLineWidth: function(): number
	setLineStyle: function(style: string)
	getLineStyle: function(): string
	setLineJoin: function(join: string)
	getLineJoin: function(): string
	setWireframe: function(enable: boolean)
	isWireframe: function(): boolean
	setPointSize: function(size: number)
	getPointSize: function(): number
	getDimensions: function(): number, number
	getWidth: function(): number
	getHeight: function(): number
	getPixelDimensions: function(): number, number
	getPixelWidth: function(): number
	getPixelHeight: function(): number
	getDPIScale: function(): number
	getSupported: function(target?: any): GraphicsFeatures
	getTextureTypes: function(target?: any): {string: boolean}
	getImageFormats: function(target?: any): {string: boolean}
	getRendererInfo: function(): string, string, string, string
	getSystemLimits: function(target?: any): GraphicsSystemLimits
	getStats: function(target?: any): GraphicsStats
	captureScreenshot: function(filename_callback_or_channel: string | function(image_data: ImageData) | Channel)
	rectangle: function(mode: string, x: number, y: number, width: number, height: number)
	circle: function(mode: string, x: number, y: number, radius: number)
	arc: function(mode: string, arc_mode_or_x: string | number, y_or_x: number, radius_or_y: number, angle1_or_radius: number, angle2_or_angle1: number, segments_or_angle2?: number, segments?: integer)
	ellipse: function(mode: string, x: number, y: number, radius_x: number, radius_y: number, segments?: integer)
	line: function(x1: number, y1: number, x2: number, y2: number, coordinates: number...)
	polygon: function(mode: string, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, coordinates: number...)
	points: function(x1: number, y1: number, coordinates: number...)
	present: function()
	push: function(stack_type?: string)
	pop: function()
	getStackDepth: function(): integer
	origin: function()
	translate: function(dx: number, dy: number)
	rotate: function(angle: number)
	scale: function(sx: number, sy?: number)
	shear: function(kx: number, ky: number)
	applyTransform: function(transform: Transform)
	replaceTransform: function(transform: Transform)
	transformPoint: function(x: number, y: number): number, number
	inverseTransformPoint: function(x: number, y: number): number, number
	isActive: function(): boolean
	isCreated: function(): boolean
	isGammaCorrect: function(): boolean
	reset: function()
	setBlendMode: function(mode: string, alpha_mode?: string)
	getBlendMode: function(): string, string
	setScissor: function(x?: number, y?: number, width?: number, height?: number)
	getScissor: function(): number | nil, number | nil, number | nil, number | nil
	intersectScissor: function(x: number, y: number, width: number, height: number)
	setColorMask: function(red?: boolean, green?: boolean, blue?: boolean, alpha?: boolean)
	getColorMask: function(): boolean, boolean, boolean, boolean
	setDepthMode: function(compare?: string, write?: boolean)
	getDepthMode: function(): string, boolean
	setMeshCullMode: function(mode: string)
	getMeshCullMode: function(): string
	setFrontFaceWinding: function(winding: string)
	getFrontFaceWinding: function(): string
	stencil: function(draw: function(), action?: string, value?: integer, keep_values_or_clear_value?: boolean | integer)
	setStencilTest: function(compare?: string, value?: integer)
	getStencilTest: function(): string, integer
	newFont: function(filename_or_size?: string | number, size?: integer): Font
	setNewFont: function(filename_or_size?: string | number, size?: integer): Font
	newImageFont: function(source_or_rasterizer: string | FileData | ImageData | Rasterizer, glyphs?: string, extra_spacing?: integer, dpi_scale?: number): Font
	newText: function(font: Font, text?: any): Text
	setFont: function(font: Font)
	getFont: function(): Font
	print: function(text: string | number, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)
	printf: function(text: string | number, x: number, y: number, limit: number, align?: string, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)
	newImage: function(filename_or_data: string | FileData | ImageData | CompressedImageData, settings?: LayeredImageSettings): Image
	newVideo: function(filename_or_stream: string | VideoStream, settings?: any): Video
	_newVideo: function(filename_or_stream: string | VideoStream, dpi_scale?: number): Video
	newArrayImage: function(layers: {ImageData}, settings?: LayeredImageSettings): Image
	newCubeImage: function(faces: {ImageData}, settings?: LayeredImageSettings): Image
	newVolumeImage: function(slices: {ImageData}, settings?: LayeredImageSettings): Image
	newCanvas: function(width?: integer, height?: integer, settings?: CanvasSettings): Canvas
	getCanvasFormats: function(readable?: boolean, formats?: {string: boolean}): {string: boolean}
	-- Teal cannot discriminate Canvas records from an array of Canvas records.
	setCanvas: function(...: any)
	getCanvas: function(): Canvas | nil
	-- These arguments cover Love overloads which Teal records cannot express directly.
	newQuad: function(x: number, y: number, width: number, height: number, image_or_texture_width: any, texture_height?: number): Quad
	-- Covers both the standard and custom vertex-format overloads.
	newMesh: function(vertices_or_format: any, vertices_or_mode?: any, draw_mode_or_usage?: string, usage?: string): Mesh
	newSpriteBatch: function(texture: Image | Canvas, size?: integer, usage?: string): SpriteBatch
	newParticleSystem: function(texture: Image | Canvas, size?: integer): ParticleSystem
	newShader: function(source: string | FileData, pixel_source?: string | FileData): Shader
	validateShader: function(gles: boolean, source: string | FileData, pixel_source?: string | FileData): boolean, string | nil
	setShader: function(shader?: Shader)
	getShader: function(): Shader | nil
	draw: function(image: any, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y?: number)
	drawLayer: function(image: Image, layer: integer, quad_or_x?: Quad | number, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y?: number)
	drawInstanced: function(mesh: Mesh, instance_count: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)
end

-- Love 11.5 root module. This file only declares the currently implemented subset.
local record Love
	record TouchID
		userdata
	end
	record Touch
		getTouches: function(): {TouchID}
		getPosition: function(id: TouchID): number, number
		getPressure: function(id: TouchID): number
	end
	record Joystick
		type: function(self: Joystick): string
		typeOf: function(self: Joystick, type_name: string): boolean
		release: function(self: Joystick): boolean
		isConnected: function(self: Joystick): boolean
		getName: function(self: Joystick): string
		getID: function(self: Joystick): integer, integer | nil
		getGUID: function(self: Joystick): string
		getDeviceInfo: function(self: Joystick): integer, integer, integer
		getAxisCount: function(self: Joystick): integer
		getButtonCount: function(self: Joystick): integer
		getHatCount: function(self: Joystick): integer
		getAxis: function(self: Joystick, axis: integer): number
		getAxes: function(self: Joystick): number...
		getHat: function(self: Joystick, hat: integer): string
		isDown: function(self: Joystick, buttons: integer...): boolean
		isGamepad: function(self: Joystick): boolean
		isGamepadDown: function(self: Joystick, buttons: string...): boolean
		getGamepadAxis: function(self: Joystick, axis: string): number
		getGamepadMapping: function(self: Joystick, input: string): string | nil, integer | nil, string | nil
		getGamepadMappingString: function(self: Joystick): string | nil
		isVibrationSupported: function(self: Joystick): boolean
		setVibration: function(self: Joystick, left?: number, right?: number, duration?: number): boolean
		getVibration: function(self: Joystick): number, number
		getConnectedIndex: function(self: Joystick): integer | nil
	end
	record JoystickModule
		getJoysticks: function(): {Joystick}
		getJoystickCount: function(): integer
		setGamepadMapping: function(guid: string, input: string, input_type: string, index: integer, direction?: string): boolean
		loadGamepadMappings: function(mappings_or_filename: string)
		saveGamepadMappings: function(filename?: string): string
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

	conf: function(config: Config) | nil
	load: function() | nil
	update: function(deltaTime: number) | nil
	draw: function() | nil
	-- Returning true cancels a love.event.quit request.
	quit: QuitCallback | nil
	keypressed: function(key: string, scancode: string, is_repeat: boolean) | nil
	keyreleased: function(key: string, scancode: string) | nil
	textinput: function(text: string) | nil
	textedited: function(text: string, start: integer, length: integer) | nil
	mousepressed: function(x: number, y: number, button: integer, is_touch: boolean, presses: integer) | nil
	mousereleased: function(x: number, y: number, button: integer, is_touch: boolean, presses: integer) | nil
	mousemoved: function(x: number, y: number, delta_x: number, delta_y: number, is_touch: boolean) | nil
	wheelmoved: function(x: number, y: number) | nil
	touchpressed: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil
	touchreleased: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil
	touchmoved: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil
	threaderror: function(thread: Thread, error: string) | nil
	joystickadded: function(joystick: Joystick) | nil
	joystickremoved: function(joystick: Joystick) | nil
	joystickpressed: function(joystick: Joystick, button: integer) | nil
	joystickreleased: function(joystick: Joystick, button: integer) | nil
	joystickaxis: function(joystick: Joystick, axis: integer, value: number) | nil
	joystickhat: function(joystick: Joystick, hat: integer, direction: string) | nil
	gamepadpressed: function(joystick: Joystick, button: string) | nil
	gamepadreleased: function(joystick: Joystick, button: string) | nil
	gamepadaxis: function(joystick: Joystick, axis: string, value: number) | nil

	-- Compatibility entry point; Dora remains the application loop owner.
	run: function()
end

local love: Love
return love
