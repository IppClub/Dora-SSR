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
	interface Object {
		type(): string;
		typeOf(typeName: string): boolean;
		release(): boolean;
	}
		interface Image extends Object {
			type(): "Image";
			typeOf(typeName: string): boolean;
			getWidth(): number;
			getHeight(): number;
			getDimensions(): LuaMultiReturn<[number, number]>;
			getTextureType(): TextureType;
			getDepth(): number;
			getLayerCount(): number;
			getMipmapCount(): number;
			getPixelWidth(): number;
			getPixelHeight(): number;
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			getDPIScale(): number;
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			setMipmapFilter(filter?: FilterMode, sharpness?: number): void;
			getMipmapFilter(): LuaMultiReturn<[FilterMode | undefined, number]>;
			setWrap(horizontal: WrapMode, vertical?: WrapMode, depth?: WrapMode): boolean;
			getWrap(): LuaMultiReturn<[WrapMode, WrapMode, WrapMode]>;
			getFormat(): string;
			isReadable(): boolean;
			isCompressed(): boolean;
			isFormatLinear(): boolean;
			replacePixels(data: ImageData, slice?: number, mipmap?: number, x?: number, y?: number, reloadMipmaps?: boolean): void;
			setDepthSampleMode(compare?: CompareMode): void;
			getDepthSampleMode(): CompareMode | undefined;
		}
		interface VideoStream extends Object {
			type(): "VideoStream";
			typeOf(typeName: string): boolean;
			play(): void;
			pause(): void;
			seek(seconds: number): void;
			rewind(): void;
			tell(): number;
			isPlaying(): boolean;
			getFilename(): string;
			setSync(source?: Source): void;
		}
		interface Video extends Object {
			type(): "Video";
			typeOf(typeName: string): boolean;
			getStream(): VideoStream;
			getSource(): Source | undefined;
			setSource(source?: Source): void;
			getWidth(): number;
			getHeight(): number;
			getDimensions(): LuaMultiReturn<[number, number]>;
			getPixelWidth(): number;
			getPixelHeight(): number;
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
		}
		interface VideoModule { newVideoStream(filename: string): VideoStream; }
		interface Canvas extends Object {
			type(): "Canvas";
			typeOf(typeName: string): boolean;
			getWidth(): number;
			getHeight(): number;
			getDimensions(): LuaMultiReturn<[number, number]>;
			getPixelWidth(): number;
			getPixelHeight(): number;
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			getDPIScale(): number;
			getTextureType(): TextureType;
			getDepth(): number;
			getLayerCount(): number;
			getMipmapCount(): number;
			getMipmapMode(): string;
			getFormat(): CanvasFormat;
			getMSAA(): 0 | 2 | 4 | 8 | 16;
			isReadable(): boolean;
			newImageData(slice?: 1, mipmap?: 1, x?: number, y?: number, width?: number, height?: number): ImageData;
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			setMipmapFilter(filter?: FilterMode, sharpness?: number): void;
			getMipmapFilter(): LuaMultiReturn<[FilterMode | undefined, number]>;
			setWrap(horizontal: WrapMode, vertical?: WrapMode, depth?: WrapMode): boolean;
			getWrap(): LuaMultiReturn<[WrapMode, WrapMode, WrapMode]>;
			setDepthSampleMode(compare?: CompareMode): void;
			getDepthSampleMode(): CompareMode | undefined;
			generateMipmaps(): void;
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
		interface Font extends Object {
			type(): "Font";
			typeOf(type: string): boolean;
			getWidth(text: string): number;
			getHeight(): number;
			getBaseline(): number;
			getAscent(): number;
			getDescent(): number;
			hasGlyphs(...textOrCodepoints: (string | number)[]): boolean;
			getKerning(left: string | number, right: string | number): number;
			setFallbacks(...fallbacks: Font[]): void;
			setLineHeight(height: number): void;
			getLineHeight(): number;
			getDPIScale(): number;
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			getWrap(text: string, wrapLimit: number): LuaMultiReturn<[number, string[]]>;
		}
		interface Text extends Object {
			set(text: ColoredText): void;
			setf(text: ColoredText, wrapLimit: number, align: AlignMode): void;
			add(text: ColoredText, transform: Transform): number;
			add(text: ColoredText, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			addf(text: ColoredText, wrapLimit: number, align: AlignMode, transform: Transform): number;
			addf(text: ColoredText, wrapLimit: number, align: AlignMode, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			clear(): void;
			setFont(font: Font): void;
			getFont(): Font;
			getWidth(index?: number): number;
			getHeight(index?: number): number;
			getDimensions(index?: number): LuaMultiReturn<[number, number]>;
		}
		interface Quad extends Object {
			setViewport(x: number, y: number, width: number, height: number, textureWidth?: number, textureHeight?: number): void;
			getViewport(): LuaMultiReturn<[number, number, number, number]>;
			getTextureDimensions(): LuaMultiReturn<[number, number]>;
			setLayer(layer: number): void;
			getLayer(): number;
		}
		interface Mesh extends Object {
			setVertices(vertices: MeshVertex[], startVertex?: number, vertexCount?: number): void;
			setVertices(data: Data, startVertex?: number, vertexCount?: number): void;
			setVertex(index: number, vertex: MeshVertex): void;
			setVertex(index: number, ...components: number[]): void;
			getVertex(index: number): LuaMultiReturn<[number, ...number[]]>;
			setVertexAttribute(vertexIndex: number, attributeIndex: number, ...components: number[]): void;
			getVertexAttribute(vertexIndex: number, attributeIndex: number): LuaMultiReturn<[number, ...number[]]>;
			getVertexCount(): number;
			getVertexFormat(): MeshVertexFormat[];
			setAttributeEnabled(name: string, enabled: boolean): void;
			isAttributeEnabled(name: string): boolean;
			attachAttribute(name: string, mesh: Mesh, step?: AttributeStep, attributeName?: string): void;
			detachAttribute(name: string): boolean;
			setVertexMap(): void;
			setVertexMap(indices: number[]): void;
			setVertexMap(...indices: number[]): void;
			setVertexMap(data: Data, dataType: IndexDataType, indexCount?: number): void;
			getVertexMap(): number[] | undefined;
			setTexture(texture?: Image | Canvas): void;
			getTexture(): Image | Canvas | undefined;
			setDrawMode(mode: MeshDrawMode): void;
			getDrawMode(): MeshDrawMode;
			setDrawRange(): void;
			setDrawRange(start: number, count: number): void;
			getDrawRange(): LuaMultiReturn<[number, number]> | undefined;
			flush(): void;
		}
		interface SpriteBatch extends Object {
			add(x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			add(quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			set(index: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			set(index: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			addLayer(layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			addLayer(layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			setLayer(index: number, layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			setLayer(index: number, layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			clear(): void;
			flush(): void;
			setTexture(texture: Image | Canvas): void;
			getTexture(): Image | Canvas;
			setColor(): void;
			setColor(red: number, green: number, blue: number, alpha?: number): void;
			setColor(color: Color): void;
			getColor(): LuaMultiReturn<[number, number, number, number]> | undefined;
			getCount(): number;
			getBufferSize(): number;
			attachAttribute(name: string, mesh: Mesh): void;
			setDrawRange(): void;
			setDrawRange(start: number, count: number): void;
			getDrawRange(): LuaMultiReturn<[number, number]> | undefined;
		}
		interface ParticleSystem extends Object {
			clone(): ParticleSystem;
			setTexture(texture: Image | Canvas): void;
			getTexture(): Image | Canvas;
			setBufferSize(size: number): void;
			getBufferSize(): number;
			setInsertMode(mode: ParticleInsertMode): void;
			getInsertMode(): ParticleInsertMode;
			setEmissionRate(rate: number): void;
			getEmissionRate(): number;
			setEmitterLifetime(lifetime: number): void;
			getEmitterLifetime(): number;
			setParticleLifetime(minimum: number, maximum?: number): void;
			getParticleLifetime(): LuaMultiReturn<[number, number]>;
			setPosition(x: number, y: number): void;
			getPosition(): LuaMultiReturn<[number, number]>;
			moveTo(x: number, y: number): void;
			setEmissionArea(distribution?: ParticleAreaSpreadDistribution, x?: number, y?: number, angle?: number, directionRelativeToCenter?: boolean): void;
			getEmissionArea(): LuaMultiReturn<[ParticleAreaSpreadDistribution, number, number, number, boolean]>;
			/** @deprecated Use setEmissionArea. */
			setAreaSpread(distribution?: ParticleAreaSpreadDistribution, x?: number, y?: number): void;
			/** @deprecated Use getEmissionArea. */
			getAreaSpread(): LuaMultiReturn<[ParticleAreaSpreadDistribution, number, number]>;
			setDirection(direction: number): void;
			getDirection(): number;
			setSpread(spread: number): void;
			getSpread(): number;
			setSpeed(minimum: number, maximum?: number): void;
			getSpeed(): LuaMultiReturn<[number, number]>;
			setLinearAcceleration(xMinimum: number, yMinimum: number, xMaximum?: number, yMaximum?: number): void;
			getLinearAcceleration(): LuaMultiReturn<[number, number, number, number]>;
			setRadialAcceleration(minimum: number, maximum?: number): void;
			getRadialAcceleration(): LuaMultiReturn<[number, number]>;
			setTangentialAcceleration(minimum: number, maximum?: number): void;
			getTangentialAcceleration(): LuaMultiReturn<[number, number]>;
			setLinearDamping(minimum: number, maximum?: number): void;
			getLinearDamping(): LuaMultiReturn<[number, number]>;
			setSizes(...sizes: number[]): void;
			getSizes(): LuaMultiReturn<number[]>;
			setSizeVariation(variation: number): void;
			getSizeVariation(): number;
			setRotation(minimum: number, maximum?: number): void;
			getRotation(): LuaMultiReturn<[number, number]>;
			setSpin(start: number, finish?: number): void;
			getSpin(): LuaMultiReturn<[number, number]>;
			setSpinVariation(variation: number): void;
			getSpinVariation(): number;
			setOffset(x: number, y: number): void;
			getOffset(): LuaMultiReturn<[number, number]>;
			setColors(...colors: (Color | number)[]): void;
			getColors(): LuaMultiReturn<[number, number, number, number][]>;
			setQuads(...quads: (Quad | Quad[])[]): void;
			getQuads(): Quad[];
			setRelativeRotation(enabled: boolean): void;
			hasRelativeRotation(): boolean;
			getCount(): number;
			start(): void;
			stop(): void;
			pause(): void;
			reset(): void;
			emit(count: number): void;
			isActive(): boolean;
			isPaused(): boolean;
			isStopped(): boolean;
			isEmpty(): boolean;
			isFull(): boolean;
			update(deltaTime: number): void;
		}
		type ShaderSource = string | FileData;
		type ShaderValue = number | boolean | number[] | number[][] | boolean[];
		type MatrixLayout = "row" | "column";
		interface Shader extends Object {
			getWarnings(): string;
			hasUniform(name: string): boolean;
			send(name: string, texture: Image | Canvas, ...textures: (Image | Canvas)[]): void;
			send(name: string, matrixLayout: MatrixLayout, ...matrices: (number[] | number[][])[]): void;
			send(name: string, data: Data, offset?: number, size?: number): void;
			send(name: string, matrixLayout: MatrixLayout, data: Data, offset?: number, size?: number): void;
			send(name: string, data: Data, matrixLayout: MatrixLayout, offset?: number, size?: number): void;
			send(name: string, ...values: ShaderValue[]): void;
			sendColor(name: string, data: Data, offset?: number, size?: number): void;
			sendColor(name: string, ...values: ShaderValue[]): void;
		}

	/** @noSelf */
	interface Graphics {
		clear(red?: number, green?: number, blue?: number, alpha?: number): void;
		discard(discardColor?: boolean | boolean[], discardDepthStencil?: boolean): void;
		flushBatch(): void;
		setBackgroundColor(red: number, green: number, blue: number, alpha?: number): void;
		setBackgroundColor(color: Color): void;
		getBackgroundColor(): LuaMultiReturn<[number, number, number, number]>;
		setDefaultFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
		getDefaultFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
		setDefaultMipmapFilter(filter?: FilterMode, sharpness?: number): void;
		getDefaultMipmapFilter(): LuaMultiReturn<[FilterMode | undefined, number]>;
		setColor(red: number, green: number, blue: number, alpha?: number): void;
		getColor(): LuaMultiReturn<[number, number, number, number]>;
		setLineWidth(width: number): void;
		getLineWidth(): number;
		setLineStyle(style: LineStyle): void;
		getLineStyle(): LineStyle;
		setLineJoin(join: LineJoin): void;
		getLineJoin(): LineJoin;
		setWireframe(enable: boolean): void;
		isWireframe(): boolean;
		setPointSize(size: number): void;
		getPointSize(): number;
		getDimensions(): LuaMultiReturn<[number, number]>;
		getWidth(): number;
		getHeight(): number;
		getPixelDimensions(): LuaMultiReturn<[number, number]>;
		getPixelWidth(): number;
		getPixelHeight(): number;
		getDPIScale(): number;
		getSupported(target?: any): GraphicsFeatures;
		getTextureTypes(target?: any): TextureTypes;
		getImageFormats(target?: any): ImageFormats;
		getRendererInfo(): LuaMultiReturn<[string, string, string, string]>;
		getSystemLimits(target?: any): GraphicsSystemLimits;
		getStats(target?: any): GraphicsStats;
		captureScreenshot(filename: string): void;
		captureScreenshot(callback: (imageData: ImageData) => void): void;
		captureScreenshot(channel: Channel): void;
		rectangle(mode: DrawMode, x: number, y: number, width: number, height: number): void;
		circle(mode: DrawMode, x: number, y: number, radius: number): void;
		arc(mode: DrawMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: number): void;
		arc(mode: DrawMode, arcMode: ArcMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: number): void;
		ellipse(mode: DrawMode, x: number, y: number, radiusX: number, radiusY: number, segments?: number): void;
		line(x1: number, y1: number, x2: number, y2: number, ...coordinates: number[]): void;
		polygon(mode: DrawMode, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, ...coordinates: number[]): void;
		points(x1: number, y1: number, ...coordinates: number[]): void;
		present(): void;
		push(stackType?: "transform" | "all"): void;
		pop(): void;
		getStackDepth(): number;
		origin(): void;
		translate(dx: number, dy: number): void;
		rotate(angle: number): void;
		scale(sx: number, sy?: number): void;
		shear(kx: number, ky: number): void;
		applyTransform(transform: Transform): void;
		replaceTransform(transform: Transform): void;
		transformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		inverseTransformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		isActive(): boolean;
		isCreated(): boolean;
		isGammaCorrect(): boolean;
		reset(): void;
		setBlendMode(mode: BlendMode, alphaMode?: BlendAlphaMode): void;
		getBlendMode(): LuaMultiReturn<[BlendMode, BlendAlphaMode]>;
		setScissor(): void;
		setScissor(x: number, y: number, width: number, height: number): void;
		getScissor(): LuaMultiReturn<[number, number, number, number]> | undefined;
		intersectScissor(x: number, y: number, width: number, height: number): void;
		setColorMask(): void;
		setColorMask(red: boolean, green: boolean, blue: boolean, alpha: boolean): void;
		getColorMask(): LuaMultiReturn<[boolean, boolean, boolean, boolean]>;
		setDepthMode(): void;
		setDepthMode(compare: CompareMode, write: boolean): void;
		getDepthMode(): LuaMultiReturn<[CompareMode, boolean]>;
		setMeshCullMode(mode: MeshCullMode): void;
		getMeshCullMode(): MeshCullMode;
		setFrontFaceWinding(winding: Winding): void;
		getFrontFaceWinding(): Winding;
		stencil(draw: () => void, action?: StencilAction, value?: number, keepValuesOrClearValue?: boolean | number): void;
		setStencilTest(): void;
		setStencilTest(compare: CompareMode, value: number): void;
		getStencilTest(): LuaMultiReturn<[CompareMode, number]>;
		newFont(size?: number): Font;
		newFont(filename: string, size?: number): Font;
		setNewFont(size?: number): Font;
		setNewFont(filename: string, size?: number): Font;
		newImageFont(source: string | FileData | ImageData, glyphs: string, extraSpacing?: number, dpiScale?: number): Font;
		newImageFont(rasterizer: Rasterizer): Font;
		newText(font: Font, text?: ColoredText): Text;
		setFont(font: Font): void;
		getFont(): Font;
		print(text: string | number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		printf(text: string | number, x: number, y: number, limit: number, align?: AlignMode, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		newImage(filename: string, settings?: ImageSettings): Image;
		newImage(data: FileData, settings?: CompressedImageSettings): Image;
		newImage(data: ImageData, settings?: ImageSettings): Image;
		newImage(data: CompressedImageData, settings?: CompressedImageSettings): Image;
		newVideo(filename: string, settings?: {audio?: boolean; dpiscale?: number}): Video;
		newVideo(stream: VideoStream, settings?: {audio?: boolean; dpiscale?: number}): Video;
		_newVideo(filenameOrStream: string | VideoStream, dpiScale?: number): Video;
		newArrayImage(layers: ImageData[], settings?: LayeredImageSettings): Image;
		newCubeImage(faces: [ImageData, ImageData, ImageData, ImageData, ImageData, ImageData], settings?: LayeredImageSettings): Image;
		newVolumeImage(slices: ImageData[], settings?: LayeredImageSettings): Image;
		newCanvas(width?: number, height?: number, settings?: CanvasSettings): Canvas;
		getCanvasFormats(readable?: boolean, formats?: CanvasFormats): CanvasFormats;
		setCanvas(): void;
		setCanvas(canvas: Canvas, ...canvases: Canvas[]): void;
		setCanvas(canvases: Canvas[]): void;
		setCanvas(setup: CanvasSetup): void;
		getCanvas(): Canvas | LuaMultiReturn<[Canvas, ...Canvas[]]> | CanvasSetup | undefined;
		newQuad(x: number, y: number, width: number, height: number, image: Image | Canvas): Quad;
		newQuad(x: number, y: number, width: number, height: number, textureWidth: number, textureHeight: number): Quad;
		newMesh(vertices: MeshVertex[] | number, drawMode?: MeshDrawMode, usage?: MeshUsage): Mesh;
		newMesh(format: MeshVertexFormat[], vertices: MeshVertex[] | number | Data, drawMode?: MeshDrawMode, usage?: MeshUsage): Mesh;
		newSpriteBatch(texture: Image | Canvas, size?: number, usage?: MeshUsage): SpriteBatch;
		newParticleSystem(texture: Image | Canvas, size?: number): ParticleSystem;
		newShader(source: ShaderSource, pixelSource?: ShaderSource): Shader;
		validateShader(gles: boolean, source: ShaderSource, pixelSource?: ShaderSource): LuaMultiReturn<[boolean, string?]>;
		setShader(shader?: Shader): void;
		getShader(): Shader | undefined;
		draw(image: Image, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(image: Image, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		drawLayer(image: Image, layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		drawLayer(image: Image, layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(canvas: Canvas, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(canvas: Canvas, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(mesh: Mesh, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
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
	interface Window {
		getDesktopDimensions(display?: number): LuaMultiReturn<[number, number]>;
		getDisplayCount(): number;
		getDisplayName(display: number): string;
		getDisplayOrientation(display?: number): "unknown" | "landscape" | "portrait" | "landscapeflipped" | "portraitflipped";
		getFullscreenModes(display?: number): WindowSize[];
		setFullscreen(fullscreen: boolean, type?: "desktop" | "exclusive"): boolean;
		getFullscreen(): LuaMultiReturn<[boolean, "desktop" | "exclusive"]>;
		isOpen(): boolean;
		getIcon(): ImageData | undefined;
		getMode(): LuaMultiReturn<[number, number, WindowMode]>;
		setMode(width: number, height: number, settings?: WindowModeSettings): boolean;
		updateMode(settings: WindowModeSettings): boolean;
		updateMode(width: number, height: number, settings?: WindowModeSettings): boolean;
		getPosition(): LuaMultiReturn<[number, number, number]>;
		getSafeArea(): LuaMultiReturn<[number, number, number, number]>;
		setTitle(title: string): void;
		getTitle(): string;
		setVSync(vsync: boolean | number): void;
		getVSync(): number;
		setDisplaySleepEnabled(enabled: boolean): void;
		isDisplaySleepEnabled(): boolean;
		hasFocus(): boolean;
		hasMouseFocus(): boolean;
		isVisible(): boolean;
		isMaximized(): boolean;
		isMinimized(): boolean;
		getDPIScale(): number;
		getNativeDPIScale(): number;
		toPixels(value: number): number;
		toPixels(x: number, y: number): LuaMultiReturn<[number, number]>;
		fromPixels(value: number): number;
		fromPixels(x: number, y: number): LuaMultiReturn<[number, number]>;
	}

	/** @noSelf */
	interface Event {
		/** Dora 已统一接管平台事件泵；此调用不会额外读取操作系统队列。 */
		pump(): void;
		poll(): () => LuaMultiReturn<[string, ...unknown[]] | []>;
		/** 嵌入实例队列为空时立即返回，不阻塞 Dora 主线程。 */
		wait(): LuaMultiReturn<[string, ...unknown[]] | []>;
		push(name: string, ...args: (boolean | number | string | LuaUserdata | undefined)[]): boolean;
		clear(): void;
		/** 请求只停止当前嵌入式 Love 实例。 */
		quit(exitStatus?: number): true;
		quit(reason: "restart"): true;
	}

	type FileType = "file" | "directory";
	type FileMode = "c" | "r" | "w" | "a";
	type OpenFileMode = "r" | "w" | "a";
	type BufferMode = "none" | "line" | "full";
	interface Data extends Object {
		getString(): string;
		getSize(): number;
		getPointer(): LuaUserdata;
		getFFIPointer(): undefined;
	}
	interface ByteData extends Data { clone(): ByteData; }
	interface DataView extends Data { clone(): DataView; }
	interface CompressedData extends Data {
		clone(): CompressedData;
		getFormat(): "zlib" | "gzip" | "deflate" | "lz4";
	}
	type DataContainer = "data" | "string";
	type EncodeFormat = "hex" | "base64";
	type CompressionFormat = "zlib" | "gzip" | "deflate" | "lz4";
	type HashFunction = "md5" | "sha1" | "sha224" | "sha256" | "sha384" | "sha512";
	/** @noSelf */
	interface DataModule {
		newByteData(size: number): ByteData;
		newByteData(bytes: string): ByteData;
		newByteData(data: Data, offset?: number, size?: number): ByteData;
		newDataView(data: Data, offset: number, size: number): DataView;
		encode(container: "string", format: EncodeFormat, source: string | Data, lineLength?: number): string;
		encode(container: "data", format: EncodeFormat, source: string | Data, lineLength?: number): ByteData;
		decode(container: "string", format: EncodeFormat, source: string | Data): string;
		decode(container: "data", format: EncodeFormat, source: string | Data): ByteData;
		compress(container: "string", format: CompressionFormat, source: string | Data, level?: number): string;
		compress(container: "data", format: CompressionFormat, source: string | Data, level?: number): CompressedData;
		decompress(container: "string", compressed: CompressedData): string;
		decompress(container: "data", compressed: CompressedData): ByteData;
		decompress(container: "string", format: CompressionFormat, source: string | Data): string;
		decompress(container: "data", format: CompressionFormat, source: string | Data): ByteData;
		pack(container: "string", format: string, ...values: any[]): string;
		pack(container: "data", format: string, ...values: any[]): ByteData;
		unpack(format: string, source: string | Data, position?: number): LuaMultiReturn<any[]>;
		getPackedSize(format: string): number;
		hash(hashFunction: HashFunction, source: string | Data): string;
	}
	interface FileData extends Data {
		clone(): FileData;
		getFilename(): string;
		getExtension(): string;
	}
	interface ImageData extends Data {
		type(): "ImageData";
		typeOf(typeName: string): boolean;
		clone(): ImageData;
		getWidth(): number;
		getHeight(): number;
		getDimensions(): LuaMultiReturn<[number, number]>;
		getFormat(): ImagePixelFormat;
		getPixel(x: number, y: number): LuaMultiReturn<[number, number, number, number]>;
		setPixel(x: number, y: number, red: number, green: number, blue: number, alpha?: number): void;
		mapPixel(mapper: (x: number, y: number, red: number, green: number, blue: number, alpha: number) => LuaMultiReturn<[number, number, number, number]>, x?: number, y?: number, width?: number, height?: number): void;
		paste(source: ImageData, destinationX: number, destinationY: number, sourceX?: number, sourceY?: number, sourceWidth?: number, sourceHeight?: number): void;
		encode(format: "png" | "tga", filename?: string): FileData;
	}
	interface CompressedImageData extends Data {
		type(): "CompressedImageData";
		typeOf(typeName: string): boolean;
		clone(): CompressedImageData;
		getWidth(mipmap?: number): number;
		getHeight(mipmap?: number): number;
		getDimensions(mipmap?: number): LuaMultiReturn<[number, number]>;
		getMipmapCount(): number;
		getFormat(): CompressedPixelFormat;
	}
	/** @noSelf */
	interface ImageModule {
		newImageData(width: number, height: number, format?: ImagePixelFormat, data?: string | FileData): ImageData;
		newImageData(filename: string): ImageData;
		newImageData(data: FileData): ImageData;
		newCompressedData(filenameOrData: string | Data): CompressedImageData;
		isCompressed(filenameOrData: string | Data): boolean;
	}
	interface Rasterizer extends Object {
		type(): "Rasterizer";
		typeOf(typeName: string): boolean;
		getHeight(): number;
		getAdvance(): number;
		getAscent(): number;
		getDescent(): number;
		getLineHeight(): number;
		getGlyphData(glyph: string | number): GlyphData;
		getGlyphCount(): number;
		hasGlyphs(...glyphs: (string | number)[]): boolean;
	}
	interface GlyphData extends Data {
		type(): "GlyphData";
		typeOf(typeName: string): boolean;
		clone(): GlyphData;
		getWidth(): number;
		getHeight(): number;
		getDimensions(): LuaMultiReturn<[number, number]>;
		getGlyph(): number;
		getGlyphString(): string;
		getAdvance(): number;
		getBearing(): LuaMultiReturn<[number, number]>;
		getBoundingBox(): LuaMultiReturn<[number, number, number, number]>;
		getFormat(): "rgba8";
	}
	/** @noSelf */
	interface FontModule {
		newImageRasterizer(imageData: ImageData, glyphs: string, extraSpacing?: number, dpiScale?: number): Rasterizer;
		newBMFontRasterizer(filenameOrFileData: string | FileData, images?: ImageData | string | FileData | (ImageData | string | FileData)[], dpiScale?: number): Rasterizer;
		newTrueTypeRasterizer(size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		newTrueTypeRasterizer(filenameOrData: string | Data, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		newRasterizer(size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		newRasterizer(filenameOrData: string | Data, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		newGlyphData(rasterizer: Rasterizer, glyph: string | number): GlyphData;
	}
	interface SoundData extends Data {
		clone(): SoundData;
		getChannelCount(): number;
		/** Love 对 getChannelCount 的弃用别名。 */
		getChannels(): number;
		getBitDepth(): 8 | 16;
		getSampleRate(): number;
		getSampleCount(): number;
		getDuration(): number;
		getSample(index: number, channel?: number): number;
		setSample(index: number, sample: number): void;
		setSample(index: number, channel: number, sample: number): void;
	}
	interface Decoder extends Object {
		clone(): Decoder;
		getChannelCount(): number;
		/** 已弃用的 getChannelCount Love 别名。 */
		getChannels(): number;
		getBitDepth(): 16;
		getSampleRate(): number;
		getDuration(): number;
		decode(): SoundData | undefined;
		seek(offset: number): void;
	}
	/** @noSelf */
	interface SoundModule {
		newDecoder(filename: string, bufferSize?: number): Decoder;
		newDecoder(data: FileData, bufferSize?: number): Decoder;
		newSoundData(samples: number, sampleRate?: number, bitDepth?: 8 | 16, channels?: number): SoundData;
		newSoundData(filename: string, bufferSize?: number): SoundData;
		newSoundData(data: FileData, bufferSize?: number): SoundData;
		newSoundData(decoder: Decoder): SoundData;
	}
	interface RandomGenerator extends Object {
		random(): number;
		random(upper: number): number;
		random(lower: number, upper: number): number;
		randomNormal(standardDeviation?: number, mean?: number): number;
		setSeed(seed: number): void;
		setSeed(low: number, high: number): void;
		getSeed(): LuaMultiReturn<[number, number]>;
		setState(state: string): void;
		getState(): string;
	}
	interface Transform extends Object {
		clone(): Transform;
		inverse(): Transform;
		apply(other: Transform): Transform;
		isAffine2DTransform(): boolean;
		translate(x: number, y: number): Transform;
		rotate(angle: number): Transform;
		scale(x: number, y?: number): Transform;
		shear(x: number, y: number): Transform;
		reset(): Transform;
		setTransformation(x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): Transform;
		setMatrix(layout: "row" | "column", elements: number[] | number[][]): Transform;
		setMatrix(elements: number[] | number[][]): Transform;
		getMatrix(): LuaMultiReturn<[number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number]>;
		transformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		inverseTransformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
	}
	interface BezierCurve extends Object {
		getDegree(): number;
		getDerivative(): BezierCurve;
		getControlPoint(index: number): LuaMultiReturn<[number, number]>;
		setControlPoint(index: number, x: number, y: number): void;
		insertControlPoint(x: number, y: number, index?: number): void;
		removeControlPoint(index: number): void;
		getControlPointCount(): number;
		translate(x: number, y: number): void;
		rotate(angle: number, originX?: number, originY?: number): void;
		scale(scale: number, originX?: number, originY?: number): void;
		evaluate(time: number): LuaMultiReturn<[number, number]>;
		getSegment(start: number, end: number): BezierCurve;
		render(accuracy?: number): number[];
		renderSegment(start: number, end: number, accuracy?: number): number[];
	}
	/** @noSelf */
	interface MathModule {
		newRandomGenerator(seed?: number): RandomGenerator;
		newRandomGenerator(low: number, high: number): RandomGenerator;
		newTransform(x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): Transform;
		newBezierCurve(vertices: number[]): BezierCurve;
		newBezierCurve(...coordinates: number[]): BezierCurve;
		noise(x: number, y?: number, z?: number, w?: number): number;
		/** Deprecated alias of love.data.compress. */
		compress(container: "string", format: CompressionFormat, source: string | Data, level?: number): string;
		compress(container: "data", format: CompressionFormat, source: string | Data, level?: number): CompressedData;
		/** Deprecated alias of love.data.decompress. */
		decompress(container: "string", compressed: CompressedData): string;
		decompress(container: "data", compressed: CompressedData): ByteData;
		random(): number;
		random(upper: number): number;
		random(lower: number, upper: number): number;
		randomNormal(standardDeviation?: number, mean?: number): number;
		setRandomSeed(seed: number): void;
		setRandomSeed(low: number, high: number): void;
		getRandomSeed(): LuaMultiReturn<[number, number]>;
		setRandomState(state: string): void;
		getRandomState(): string;
		colorToBytes(red: number, green: number, blue: number, alpha?: number): LuaMultiReturn<[number, number, number, number?]>;
		colorToBytes(color: number[]): LuaMultiReturn<[number, number, number, number?]>;
		colorFromBytes(red: number, green: number, blue: number, alpha?: number): LuaMultiReturn<[number, number, number, number?]>;
		colorFromBytes(color: number[]): LuaMultiReturn<[number, number, number, number?]>;
		gammaToLinear(red: number, green?: number, blue?: number, alpha?: number): LuaMultiReturn<[number, number?, number?, number?]>;
		gammaToLinear(color: number[]): LuaMultiReturn<[number, number?, number?, number?]>;
		linearToGamma(red: number, green?: number, blue?: number, alpha?: number): LuaMultiReturn<[number, number?, number?, number?]>;
		linearToGamma(color: number[]): LuaMultiReturn<[number, number?, number?, number?]>;
		isConvex(vertices: number[]): boolean;
		isConvex(...coordinates: number[]): boolean;
		triangulate(vertices: number[]): number[][];
		triangulate(...coordinates: number[]): number[][];
	}
	interface File extends Object {
		open(mode: OpenFileMode): LuaMultiReturn<[true | undefined, string?]>;
		close(): boolean;
		isOpen(): boolean;
		getSize(): LuaMultiReturn<[number | undefined, string?]>;
		read(size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(container: "string", size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(container: "data", size?: number): LuaMultiReturn<[FileData | undefined, number | string]>;
		write(data: string | FileData, size?: number): LuaMultiReturn<[true | undefined, string?]>;
		flush(): LuaMultiReturn<[true | undefined, string?]>;
		isEOF(): boolean;
		tell(): LuaMultiReturn<[number | undefined, string?]>;
		seek(position: number): boolean;
		lines(): () => string | undefined;
		setBuffer(mode: BufferMode, size?: number): boolean;
		getBuffer(): LuaMultiReturn<[BufferMode, number]>;
		getMode(): FileMode;
		getFilename(): string;
		getExtension(): string;
	}
	interface FileInfo {
		type: FileType;
		size?: number;
		modtime?: number;
	}
	/** @noSelf */
	interface Filesystem {
		setIdentity(identity: string, appendToPath?: boolean): void;
		getIdentity(): string;
		getSource(): string;
		getSaveDirectory(): string;
		getWorkingDirectory(): string;
		getUserDirectory(): string;
		getAppdataDirectory(): string;
		getSourceBaseDirectory(): string;
		getExecutablePath(): string;
		getRealDirectory(filename: string): LuaMultiReturn<[string | undefined, string?]>;
		getRequirePath(): string;
		setRequirePath(path: string): void;
		mount(archive: string | FileData, mountpoint: string, appendToPath?: boolean): boolean;
		unmount(archive: string | FileData): boolean;
		isFused(): false;
		newFile(filename: string, mode?: OpenFileMode): File;
		newFileData(filename: string): FileData;
		newFileData(file: File): FileData;
		newFileData(data: string, filename: string): FileData;
		read(filename: string, size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(container: "string", filename: string, size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(container: "data", filename: string, size?: number): LuaMultiReturn<[FileData | undefined, number | string]>;
		load(filename: string): LuaMultiReturn<[((...args: unknown[]) => unknown) | undefined, string?]>;
		lines(filename: string): () => string | undefined;
		write(filename: string, data: string | FileData, size?: number): LuaMultiReturn<[boolean, string?]>;
		append(filename: string, data: string | FileData, size?: number): LuaMultiReturn<[boolean, string?]>;
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
		createDirectory(name: string): LuaMultiReturn<[boolean, string?]>;
		remove(name: string): LuaMultiReturn<[boolean, string?]>;
		getDirectoryItems(directory?: string): string[];
	}

	/** @noSelf */
	interface Keyboard {
		setKeyRepeat(enabled: boolean): void;
		hasKeyRepeat(): boolean;
		isDown(...keys: string[]): boolean;
		isDown(keys: string[]): boolean;
		isScancodeDown(...scancodes: string[]): boolean;
		isScancodeDown(scancodes: string[]): boolean;
		getScancodeFromKey(key: string): string;
		getKeyFromScancode(scancode: string): string;
		setTextInput(enabled: boolean): void;
		setTextInput(enabled: boolean, x: number, y: number, width: number, height: number): void;
		hasTextInput(): boolean;
		hasScreenKeyboard(): boolean;
	}

	/** @noSelf */
	type SystemCursor = "arrow" | "ibeam" | "wait" | "crosshair" | "waitarrow" | "sizenwse" | "sizenesw" | "sizewe" | "sizens" | "sizeall" | "no" | "hand";
	interface Cursor extends Object {
		getType(): "image" | SystemCursor;
		type(): "Cursor";
		typeOf(typeName: string): boolean;
	}
	/** @noSelf */
	interface Mouse {
		getPosition(): LuaMultiReturn<[number, number]>;
		getX(): number;
		getY(): number;
		setPosition(x: number, y: number): void;
		setX(x: number): void;
		setY(y: number): void;
		isDown(...buttons: number[]): boolean;
		isDown(buttons: number[]): boolean;
		setVisible(visible: boolean): void;
		isVisible(): boolean;
		setGrabbed(grabbed: boolean): void;
		isGrabbed(): boolean;
		setRelativeMode(relative: boolean): boolean;
		getRelativeMode(): boolean;
		newCursor(image: ImageData | FileData | string, hotX?: number, hotY?: number): Cursor;
		getSystemCursor(type: SystemCursor): Cursor;
		setCursor(cursor?: Cursor): void;
		getCursor(): Cursor | undefined;
		isCursorSupported(): boolean;
	}
	type TouchID = LuaUserdata;
	/** @noSelf */
	interface Touch {
		getTouches(): TouchID[];
		getPosition(id: TouchID): LuaMultiReturn<[number, number]>;
		getPressure(id: TouchID): number;
	}
	type GamepadButton = "a" | "b" | "x" | "y" | "back" | "guide" | "start" | "leftstick" | "rightstick" | "leftshoulder" | "rightshoulder" | "dpup" | "dpdown" | "dpleft" | "dpright" | "misc1" | "paddle1" | "paddle2" | "paddle3" | "paddle4" | "touchpad";
	type GamepadAxis = "leftx" | "lefty" | "rightx" | "righty" | "triggerleft" | "triggerright";
	type JoystickHat = "c" | "u" | "r" | "d" | "l" | "ru" | "rd" | "lu" | "ld";
	type JoystickInputType = "axis" | "button" | "hat";
	interface Joystick extends Object {
		isConnected(): boolean;
		getName(): string;
		getID(): LuaMultiReturn<[number, number | undefined]>;
		getGUID(): string;
		getDeviceInfo(): LuaMultiReturn<[number, number, number]>;
		getAxisCount(): number;
		getButtonCount(): number;
		getHatCount(): number;
		getAxis(axis: number): number;
		getAxes(): LuaMultiReturn<number[]>;
		getHat(hat: number): JoystickHat;
		isDown(...buttons: number[]): boolean;
		isGamepad(): boolean;
		isGamepadDown(...buttons: GamepadButton[]): boolean;
		getGamepadAxis(axis: GamepadAxis): number;
		getGamepadMapping(input: GamepadAxis | GamepadButton): LuaMultiReturn<[JoystickInputType, number, JoystickHat?]> | undefined;
		getGamepadMappingString(): string | undefined;
		isVibrationSupported(): boolean;
		setVibration(): boolean;
		setVibration(left: number, right?: number, duration?: number): boolean;
		getVibration(): LuaMultiReturn<[number, number]>;
		getConnectedIndex(): number | undefined;
	}
	/** @noSelf */
	interface JoystickModule {
		getJoysticks(): Joystick[];
		getJoystickCount(): number;
		setGamepadMapping(guid: string, input: GamepadAxis | GamepadButton, type: "axis" | "button", index: number): boolean;
		setGamepadMapping(guid: string, input: GamepadAxis | GamepadButton, type: "hat", index: number, direction: JoystickHat): boolean;
		loadGamepadMappings(mappingsOrFilename: string): void;
		saveGamepadMappings(filename?: string): string;
		getGamepadMappingString(guid: string): string | undefined;
	}

	/** @noSelf */
	interface Timer {
		step(): number;
		getDelta(): number;
		getFPS(): number;
		getAverageDelta(): number;
		sleep(seconds: number): void;
		getTime(): number;
	}
	type OS = "OS X" | "Windows" | "Linux" | "Android" | "iOS" | "UWP" | "Unknown";
	type PowerState = "unknown" | "battery" | "nobattery" | "charging" | "charged";
	/** @noSelf */
	interface System {
		getOS(): OS;
		getProcessorCount(): number;
		setClipboardText(text: string): void;
		getClipboardText(): string;
		getPowerInfo(): LuaMultiReturn<[PowerState, number | undefined, number | undefined]>;
		/** 嵌入式 LoveNode 仅允许 http、https 和 mailto scheme。 */
		openURL(url: string): boolean;
		vibrate(seconds?: number): void;
		hasBackgroundMusic(): boolean;
	}

	type ThreadValue = boolean | number | string | Data | Channel | ThreadValue[] | {[key: string]: ThreadValue} | undefined;
	interface Thread extends Object {
		type(): "Thread";
		typeOf(typeName: string): boolean;
		start(...args: ThreadValue[]): boolean;
		wait(): void;
		getError(): string | undefined;
		isRunning(): boolean;
	}
	interface Channel extends Object {
		type(): "Channel";
		typeOf(typeName: string): boolean;
		push(value: ThreadValue): number;
		supply(value: ThreadValue, timeout?: number): boolean;
		pop(): ThreadValue;
		demand(timeout?: number): ThreadValue;
		peek(): ThreadValue;
		getCount(): number;
		hasRead(id: number): boolean;
		clear(): void;
		performAtomic(callback: (channel: Channel, ...args: any[]) => any, ...args: any[]): any;
	}
	/** @noSelf */
	interface ThreadModule {
		newThread(codeOrFilename: string | Data | File): Thread;
		newChannel(): Channel;
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
	interface Source extends Object {
		clone(): Source;
		play(): boolean;
		pause(): void;
		stop(): void;
		isPlaying(): boolean;
		isPaused(): boolean;
		setLooping(looping: boolean): void;
		isLooping(): boolean;
		setVolume(volume: number): void;
		getVolume(): number;
		setPitch(pitch: number): void;
		getPitch(): number;
		seek(offset: number, unit?: TimeUnit): void;
		tell(unit?: TimeUnit): number;
		getDuration(unit?: TimeUnit): number;
		getChannelCount(): number;
		/** Love 对 getChannelCount 的弃用别名。 */
		getChannels(): number;
		getFreeBufferCount(): number;
		queue(data: SoundData, length?: number): boolean;
		queue(data: SoundData, offset: number, length: number): boolean;
		setPosition(x: number, y: number, z?: number): void;
		getPosition(): LuaMultiReturn<[number, number, number]>;
		setVelocity(x: number, y: number, z?: number): void;
		getVelocity(): LuaMultiReturn<[number, number, number]>;
		setDirection(x: number, y: number, z?: number): void;
		getDirection(): LuaMultiReturn<[number, number, number]>;
		setCone(innerAngle: number, outerAngle: number, outerVolume?: number, outerHighGain?: number): void;
		getCone(): LuaMultiReturn<[number, number, number, number]>;
		setAirAbsorption(factor: number): void;
		getAirAbsorption(): number;
		setVolumeLimits(minVolume: number, maxVolume: number): void;
		getVolumeLimits(): LuaMultiReturn<[number, number]>;
		setRelative(relative: boolean): void;
		isRelative(): boolean;
		setAttenuationDistances(referenceDistance: number, maxDistance: number): void;
		getAttenuationDistances(): LuaMultiReturn<[number, number]>;
		setRolloff(rolloff: number): void;
		getRolloff(): number;
		setFilter(filter?: AudioFilterSettings): boolean;
		getFilter<T extends AudioFilterSettings>(target?: T): T | AudioFilterSettings | undefined;
		setEffect(name: string, enabled?: boolean | AudioFilterSettings): boolean;
		getEffect(name: string, target?: AudioFilterSettings): LuaMultiReturn<[boolean, AudioFilterSettings?]>;
		getActiveEffects(): string[];
		getType(): SourceType;
	}
	interface RecordingDevice extends Object {
		start(samples?: number, sampleRate?: number, bitDepth?: 8 | 16, channels?: 1 | 2): boolean;
		/** 停止录音并返回当前缓冲的采样。 */
		stop(): SoundData | undefined;
		/** 返回并消费当前设备中已缓冲的采样。 */
		getData(): SoundData | undefined;
		getSampleCount(): number;
		getSampleRate(): number;
		getBitDepth(): 8 | 16;
		getChannelCount(): 1 | 2;
		getName(): string;
		isRecording(): boolean;
	}
	/** @noSelf */
	interface Audio {
		newSource(filename: string, sourceType?: "static" | "stream"): Source;
		newSource(data: SoundData): Source;
		newQueueableSource(sampleRate: number, bitDepth: 8 | 16,
			channels: 1 | 2, buffers?: number): Source;
		play(sources: Source[]): boolean;
		play(...sources: Source[]): boolean;
		pause(): Source[];
		pause(sources: Source[]): void;
		pause(...sources: Source[]): void;
		stop(sources: Source[]): void;
		stop(...sources: Source[]): void;
		getActiveSourceCount(): number;
		/** Love 对 getActiveSourceCount 的弃用别名。 */
		getSourceCount(): number;
		setVolume(volume: number): void;
		getVolume(): number;
		/** 设置应用级 iOS 音频会话混音策略。其他平台返回 false。 */
		setMixWithSystem(mix: boolean): boolean;
		/** 设置所有 LoveNode 共享的 Dora 应用级听者位置。 */
		setPosition(x: number, y: number, z?: number): void;
		getPosition(): LuaMultiReturn<[number, number, number]>;
		/** 设置 Dora 应用级听者的前向与向上向量。 */
		setOrientation(forwardX: number, forwardY: number, forwardZ: number,
			upX: number, upY: number, upZ: number): void;
		getOrientation(): LuaMultiReturn<[number, number, number, number, number, number]>;
		/** 设置所有 LoveNode 共享的 Dora 应用级听者速度。 */
		setVelocity(x: number, y: number, z?: number): void;
		getVelocity(): LuaMultiReturn<[number, number, number]>;
		/** 设置所有 LoveNode 共享的 Dora 应用级 Doppler 缩放。 */
		setDopplerScale(scale: number): void;
		getDopplerScale(): number;
		/** 设置 Dora 应用级共享的距离衰减模型。 */
		setDistanceModel(model: DistanceModel): void;
		getDistanceModel(): DistanceModel;
		setEffect(name: string, settings?: AudioEffectSettings | false): boolean;
		getEffect<T extends AudioEffectSettings>(name: string, target?: T): T | AudioEffectSettings | undefined;
		getActiveEffects(): string[];
		getMaxSceneEffects(): number;
		getMaxSourceEffects(): number;
		getRecordingDevices(): RecordingDevice[];
		isEffectsSupported(): boolean;
	}
	type BodyType = "static" | "dynamic" | "kinematic";
	type ContactCallback = (fixtureA: Fixture, fixtureB: Fixture, contact: Contact) => void;
	type PostSolveCallback = (fixtureA: Fixture, fixtureB: Fixture, contact: Contact,
		...impulses: number[]) => void;
	interface Contact extends Object {
		isValid(): boolean;
		getFixtures(): LuaMultiReturn<[Fixture, Fixture]>;
		getChildren(): LuaMultiReturn<[number, number]>;
		getPositions(): LuaMultiReturn<number[]>;
		getNormal(): LuaMultiReturn<[number, number]>;
		getFriction(): number;
		setFriction(friction: number): void;
		resetFriction(): void;
		getRestitution(): number;
		setRestitution(restitution: number): void;
		resetRestitution(): void;
		isEnabled(): boolean;
		setEnabled(enabled: boolean): void;
		isTouching(): boolean;
		getTangentSpeed(): number;
		setTangentSpeed(speed: number): void;
	}
	interface World extends Object {
		destroy(): void;
		isDestroyed(): boolean;
		update(deltaTime: number, velocityIterations?: number, positionIterations?: number): void;
		setGravity(x: number, y: number): void;
		getGravity(): LuaMultiReturn<[number, number]>;
		setSleepingAllowed(allowed: boolean): void;
		isSleepingAllowed(): boolean;
		queryBoundingBox(x1: number, y1: number, x2: number, y2: number,
			callback: (fixture: Fixture) => boolean): void;
		rayCast(x1: number, y1: number, x2: number, y2: number,
			callback: (fixture: Fixture, x: number, y: number,
				normalX: number, normalY: number, fraction: number) => number): void;
		setCallbacks(beginContact?: ContactCallback, endContact?: ContactCallback,
			preSolve?: ContactCallback, postSolve?: PostSolveCallback): void;
		getCallbacks(): LuaMultiReturn<[ContactCallback | undefined, ContactCallback | undefined,
			ContactCallback | undefined, PostSolveCallback | undefined]>;
	}
	interface Body extends Object {
		destroy(): void;
		isDestroyed(): boolean;
		getPosition(): LuaMultiReturn<[number, number]>;
		setPosition(x: number, y: number): void;
		getX(): number;
		setX(x: number): void;
		getY(): number;
		setY(y: number): void;
		getTransform(): LuaMultiReturn<[number, number, number]>;
		setTransform(x: number, y: number, angle: number): void;
		getAngle(): number;
		setAngle(angle: number): void;
		getLinearVelocity(): LuaMultiReturn<[number, number]>;
		setLinearVelocity(x: number, y: number): void;
		getAngularVelocity(): number;
		setAngularVelocity(velocity: number): void;
		getLinearDamping(): number;
		setLinearDamping(damping: number): void;
		getAngularDamping(): number;
		setAngularDamping(damping: number): void;
		getMass(): number;
		setMass(mass: number): void;
		getInertia(): number;
		setInertia(inertia: number): void;
		getMassData(): LuaMultiReturn<[number, number, number, number]>;
		setMassData(centerX: number, centerY: number, mass: number, inertia: number): void;
		resetMassData(): void;
		getGravityScale(): number;
		setGravityScale(scale: number): void;
		getLocalCenter(): LuaMultiReturn<[number, number]>;
		getWorldCenter(): LuaMultiReturn<[number, number]>;
		isFixedRotation(): boolean;
		setFixedRotation(fixed: boolean): void;
		isAwake(): boolean;
		setAwake(awake: boolean): void;
		isSleepingAllowed(): boolean;
		setSleepingAllowed(allowed: boolean): void;
		isActive(): boolean;
		setActive(active: boolean): void;
		isBullet(): boolean;
		setBullet(bullet: boolean): void;
		applyLinearImpulse(xImpulse: number, yImpulse: number, pointX?: number, pointY?: number): void;
		applyAngularImpulse(impulse: number): void;
		applyForce(xForce: number, yForce: number, pointX?: number, pointY?: number): void;
		applyTorque(torque: number): void;
		getType(): BodyType;
		setType(type: BodyType): void;
		getWorldPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		getWorldVector(x: number, y: number): LuaMultiReturn<[number, number]>;
		getWorldPoints(x: number, y: number, ...coordinates: number[]): LuaMultiReturn<number[]>;
		getLocalPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		getLocalVector(x: number, y: number): LuaMultiReturn<[number, number]>;
		getLocalPoints(x: number, y: number, ...coordinates: number[]): LuaMultiReturn<number[]>;
		getLinearVelocityFromWorldPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		getLinearVelocityFromLocalPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
	}
	interface Shape extends Object { getType(): "circle" | "polygon" | "edge" | "chain"; }
	interface CircleShape extends Shape { getRadius(): number; }
	interface PolygonShape extends Shape {
		getPoints(): LuaMultiReturn<number[]>;
		validate(): boolean;
	}
	interface EdgeShape extends Shape {
		getPoints(): LuaMultiReturn<[number, number, number, number]>;
		getPreviousVertex(): LuaMultiReturn<[number, number] | []>;
		getNextVertex(): LuaMultiReturn<[number, number] | []>;
		setPreviousVertex(x?: number, y?: number): void;
		setNextVertex(x?: number, y?: number): void;
	}
	interface ChainShape extends Shape {
		getPoints(): LuaMultiReturn<number[]>;
		getVertexCount(): number;
		getPoint(index: number): LuaMultiReturn<[number, number]>;
		getChildEdge(index: number): EdgeShape;
		getPreviousVertex(): LuaMultiReturn<[number, number] | []>;
		getNextVertex(): LuaMultiReturn<[number, number] | []>;
		setPreviousVertex(x?: number, y?: number): void;
		setNextVertex(x?: number, y?: number): void;
	}
	interface Fixture extends Object {
		destroy(): void;
		isDestroyed(): boolean;
		getType(): "circle" | "polygon" | "edge" | "chain";
		setFriction(friction: number): void;
		getFriction(): number;
		setRestitution(restitution: number): void;
		getRestitution(): number;
		setDensity(density: number): void;
		getDensity(): number;
		setSensor(sensor: boolean): void;
		isSensor(): boolean;
		getBody(): Body;
		getShape(): Shape;
		testPoint(x: number, y: number): boolean;
		rayCast(x1: number, y1: number, x2: number, y2: number, maxFraction: number, childIndex?: number): LuaMultiReturn<[number, number, number] | []>;
		setFilterData(categoryBits: number, maskBits: number, groupIndex: number): void;
		getFilterData(): LuaMultiReturn<[number, number, number]>;
		setCategory(categories: number[]): void;
		setCategory(...categories: number[]): void;
		getCategory(): LuaMultiReturn<number[]>;
		setMask(categories: number[]): void;
		setMask(...categories: number[]): void;
		getMask(): LuaMultiReturn<number[]>;
		setUserData(value: unknown): void;
		getUserData(): unknown;
		getBoundingBox(childIndex?: number): LuaMultiReturn<[number, number, number, number]>;
		getMassData(): LuaMultiReturn<[number, number, number, number]>;
		getGroupIndex(): number;
		setGroupIndex(index: number): void;
	}
	interface Joint extends Object {
		destroy(): void;
		isDestroyed(): boolean;
		getType(): "distance" | "revolute" | "prismatic" | "weld" | "friction" | "rope" | "pulley" | "wheel" | "mouse" | "motor" | "gear";
		getBodies(): LuaMultiReturn<[Body, Body]>;
		getAnchors(): LuaMultiReturn<[number, number, number, number]>;
		getReactionForce(inverseDeltaTime: number): LuaMultiReturn<[number, number]>;
		getReactionTorque(inverseDeltaTime: number): number;
		getCollideConnected(): boolean;
		setUserData(value: unknown): void;
		getUserData(): unknown;
	}
	interface DistanceJoint extends Joint {
		setLength(length: number): void;
		getLength(): number;
		setFrequency(frequency: number): void;
		getFrequency(): number;
		setDampingRatio(ratio: number): void;
		getDampingRatio(): number;
	}
	interface RevoluteJoint extends Joint {
		getJointAngle(): number;
		getJointSpeed(): number;
		setMotorEnabled(enabled: boolean): void;
		isMotorEnabled(): boolean;
		setMaxMotorTorque(torque: number): void;
		getMaxMotorTorque(): number;
		setMotorSpeed(speed: number): void;
		getMotorSpeed(): number;
		getMotorTorque(inverseDeltaTime: number): number;
		setLimitsEnabled(enabled: boolean): void;
		areLimitsEnabled(): boolean;
		/** @deprecated Use areLimitsEnabled. */
		hasLimitsEnabled(): boolean;
		setUpperLimit(upper: number): void;
		setLowerLimit(lower: number): void;
		setLimits(lower: number, upper: number): void;
		getUpperLimit(): number;
		getLowerLimit(): number;
		getLimits(): LuaMultiReturn<[number, number]>;
		getReferenceAngle(): number;
	}
	interface PrismaticJoint extends Joint {
		getJointTranslation(): number;
		getJointSpeed(): number;
		setMotorEnabled(enabled: boolean): void;
		isMotorEnabled(): boolean;
		setMaxMotorForce(force: number): void;
		getMaxMotorForce(): number;
		setMotorSpeed(speed: number): void;
		getMotorSpeed(): number;
		getMotorForce(inverseDeltaTime: number): number;
		setLimitsEnabled(enabled: boolean): void;
		areLimitsEnabled(): boolean;
		/** @deprecated Use areLimitsEnabled. */
		hasLimitsEnabled(): boolean;
		setUpperLimit(upper: number): void;
		setLowerLimit(lower: number): void;
		setLimits(lower: number, upper: number): void;
		getUpperLimit(): number;
		getLowerLimit(): number;
		getLimits(): LuaMultiReturn<[number, number]>;
		getAxis(): LuaMultiReturn<[number, number]>;
		getReferenceAngle(): number;
	}
	interface WeldJoint extends Joint {
		setFrequency(frequency: number): void;
		getFrequency(): number;
		setDampingRatio(ratio: number): void;
		getDampingRatio(): number;
		getReferenceAngle(): number;
	}
	interface FrictionJoint extends Joint {
		setMaxForce(force: number): void;
		getMaxForce(): number;
		setMaxTorque(torque: number): void;
		getMaxTorque(): number;
	}
	interface RopeJoint extends Joint {
		setMaxLength(length: number): void;
		getMaxLength(): number;
	}
	interface PulleyJoint extends Joint {
		getGroundAnchors(): LuaMultiReturn<[number, number, number, number]>;
		getLengthA(): number;
		getLengthB(): number;
		getRatio(): number;
	}
	interface WheelJoint extends Joint {
		getJointTranslation(): number;
		getJointSpeed(): number;
		setMotorEnabled(enabled: boolean): void;
		isMotorEnabled(): boolean;
		setMotorSpeed(speed: number): void;
		getMotorSpeed(): number;
		setMaxMotorTorque(torque: number): void;
		getMaxMotorTorque(): number;
		getMotorTorque(inverseDeltaTime: number): number;
		setSpringFrequency(frequency: number): void;
		getSpringFrequency(): number;
		setSpringDampingRatio(ratio: number): void;
		getSpringDampingRatio(): number;
		getAxis(): LuaMultiReturn<[number, number]>;
	}
	interface MouseJoint extends Joint {
		setTarget(x: number, y: number): void;
		getTarget(): LuaMultiReturn<[number, number]>;
		setMaxForce(force: number): void;
		getMaxForce(): number;
		setFrequency(frequency: number): void;
		getFrequency(): number;
		setDampingRatio(ratio: number): void;
		getDampingRatio(): number;
	}
	interface MotorJoint extends Joint {
		setLinearOffset(x: number, y: number): void;
		getLinearOffset(): LuaMultiReturn<[number, number]>;
		setAngularOffset(angle: number): void;
		getAngularOffset(): number;
		setMaxForce(force: number): void;
		getMaxForce(): number;
		setMaxTorque(torque: number): void;
		getMaxTorque(): number;
		setCorrectionFactor(factor: number): void;
		getCorrectionFactor(): number;
	}
	interface GearJoint extends Joint {
		setRatio(ratio: number): void;
		getRatio(): number;
		getJoints(): LuaMultiReturn<[RevoluteJoint | PrismaticJoint, RevoluteJoint | PrismaticJoint]>;
	}
	/** @noSelf */
	interface Physics {
		setMeter(scale: number): void;
		getMeter(): number;
		newWorld(xGravity?: number, yGravity?: number, sleep?: boolean): World;
		newBody(world: World, x?: number, y?: number, type?: BodyType): Body;
		newFixture(body: Body, shape: Shape, density?: number): Fixture;
		newCircleShape(radius: number): CircleShape;
		newCircleShape(x: number, y: number, radius: number): CircleShape;
		newRectangleShape(width: number, height: number): PolygonShape;
		newRectangleShape(x: number, y: number, width: number, height: number, angle?: number): PolygonShape;
		newPolygonShape(points: number[]): PolygonShape;
		newPolygonShape(...points: number[]): PolygonShape;
		newEdgeShape(x1: number, y1: number, x2: number, y2: number): EdgeShape;
		newChainShape(loop: boolean, points: number[]): ChainShape;
		newChainShape(loop: boolean, ...points: number[]): ChainShape;
		newDistanceJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean): DistanceJoint;
		newRevoluteJoint(body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): RevoluteJoint;
		newRevoluteJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean, referenceAngle?: number): RevoluteJoint;
		newPrismaticJoint(body1: Body, body2: Body, x: number, y: number, axisX: number, axisY: number, collideConnected?: boolean): PrismaticJoint;
		newPrismaticJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axisX: number, axisY: number, collideConnected?: boolean, referenceAngle?: number): PrismaticJoint;
		newWeldJoint(body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): WeldJoint;
		newWeldJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean, referenceAngle?: number): WeldJoint;
		newFrictionJoint(body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): FrictionJoint;
		newFrictionJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean): FrictionJoint;
		newRopeJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, maxLength: number, collideConnected?: boolean): RopeJoint;
		newPulleyJoint(body1: Body, body2: Body, groundX1: number, groundY1: number, groundX2: number, groundY2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collideConnected?: boolean): PulleyJoint;
		newWheelJoint(body1: Body, body2: Body, x: number, y: number, axisX: number, axisY: number, collideConnected?: boolean): WheelJoint;
		newWheelJoint(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axisX: number, axisY: number, collideConnected?: boolean): WheelJoint;
		newMouseJoint(body: Body, x: number, y: number): MouseJoint;
		newMotorJoint(body1: Body, body2: Body, correctionFactor?: number, collideConnected?: boolean): MotorJoint;
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

		conf?: (this: void, config: Config) => void;
		load?: (this: void) => void;
		update?: (this: void, deltaTime: number) => void;
		draw?: (this: void) => void;
		/** 返回 true 可取消 love.event.quit 请求。 */
		quit?: (this: void) => boolean | void;
		keypressed?: (this: void, key: string, scancode: string, isRepeat: boolean) => void;
		keyreleased?: (this: void, key: string, scancode: string) => void;
		textinput?: (this: void, text: string) => void;
		textedited?: (this: void, text: string, start: number, length: number) => void;
		mousepressed?: (this: void, x: number, y: number, button: number, isTouch: boolean, presses: number) => void;
		mousereleased?: (this: void, x: number, y: number, button: number, isTouch: boolean, presses: number) => void;
		mousemoved?: (this: void, x: number, y: number, deltaX: number, deltaY: number, isTouch: boolean) => void;
		wheelmoved?: (this: void, x: number, y: number) => void;
		touchpressed?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		touchreleased?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		touchmoved?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		threaderror?: (this: void, thread: Thread, error: string) => void;
		joystickadded?: (this: void, joystick: Joystick) => void;
		joystickremoved?: (this: void, joystick: Joystick) => void;
		joystickpressed?: (this: void, joystick: Joystick, button: number) => void;
		joystickreleased?: (this: void, joystick: Joystick, button: number) => void;
		joystickaxis?: (this: void, joystick: Joystick, axis: number, value: number) => void;
		joystickhat?: (this: void, joystick: Joystick, hat: number, direction: JoystickHat) => void;
		gamepadpressed?: (this: void, joystick: Joystick, button: GamepadButton) => void;
		gamepadreleased?: (this: void, joystick: Joystick, button: GamepadButton) => void;
		gamepadaxis?: (this: void, joystick: Joystick, axis: GamepadAxis, value: number) => void;

		/** 兼容入口。Dora 始终是唯一的应用主循环所有者。 */
		run(this: void): void;
		}
	}

	const love: Love.Root;
}

declare const loveModule: Love.Root;
export = loveModule;
