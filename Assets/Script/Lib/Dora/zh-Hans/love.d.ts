/**
 * LÖVE 11.5 API文档，包括参数和返回值说明，
 * 改编自官方LÖVE Wiki。
 * 版权所有© 2006-2010 LÖVE 开发团队。文档重新分发
 * 在 FreeBSD 文档许可证下。
 * Dora 特定的兼容性说明仍会明确标记。
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
		 * 获取字符串形式的对象类型。
		 *
		 * @returns type — 字符串类型。
		 */
		type(): string;
		/**
		 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
		 *
		 * @param typeName 要检查的类型的名称。
		 *
		 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
		 */
		typeOf(typeName: string): boolean;
		/**
		 * 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
		 *
		 * 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
		 *
		 * @returns success — 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
		 */
		release(): boolean;
	}
		/** Drawable image type.
		 */
		interface Image extends Object {
			/**
			 * 获取字符串形式的对象类型。
			 *
			 * @returns type — 字符串类型。
			 */
			type(): "Image";
			/**
			 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
			 *
			 * @param typeName 要检查的类型的名称。
			 *
			 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
			 */
			typeOf(typeName: string): boolean;
			/**
			 * 获取纹理的宽度。
			 *
			 * @returns width — 纹理的宽度。
			 */
			getWidth(): number;
			/**
			 * 获取纹理的高度。
			 *
			 * @returns height — 纹理的高度。
			 */
			getHeight(): number;
			/**
			 * 获取纹理的宽度和高度。
			 *
			 * @returns width — 纹理的宽度。
			 * @returns height — 纹理的高度。
			 */
			getDimensions(): LuaMultiReturn<[number, number]>;
			/**
			 * 获取纹理的类型。
			 *
			 * @returns texturetype — 纹理的类型。
			 */
			getTextureType(): TextureType;
			/**
			 * 获取体积纹理的深度。对于 2D、立方体贴图和数组纹理返回 1。
			 *
			 * @returns depth — 体积纹理的深度。
			 */
			getDepth(): number;
			/**
			 * 获取数组纹理中的层数/切片数。对于 2D、立方体贴图和体积纹理，返回 1。
			 *
			 * @returns layers — 阵列纹理中的层数。
			 */
			getLayerCount(): number;
			/**
			 * 获取纹理中包含的 mipmap 数量。如果纹理不是使用 mipmap 创建的，它将返回 1。
			 *
			 * @returns mipmaps — 纹理中 mipmap 的数量。
			 */
			getMipmapCount(): number;
			/**
			 * 获取纹理的宽度（以像素为单位）。
			 *
			 * DPI 比例因子，而不是像素。使用 getWidth 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelWidth。
			 *
			 * @returns pixelwidth — 纹理的宽度，以像素为单位。
			 */
			getPixelWidth(): number;
			/**
			 * 获取纹理的高度（以像素为单位）。
			 *
			 * DPI 比例因子，而不是像素。使用 getHeight 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelHeight。
			 *
			 * @returns pixelheight — 纹理的高度，以像素为单位。
			 */
			getPixelHeight(): number;
			/**
			 * 获取纹理的宽度和高度（以像素为单位）。
			 *
			 * Texture:getDimensions 获取纹理的尺寸，单位是按纹理的 DPI 比例因子缩放的单位，而不是像素。使用 getDimensions 进行与绘制纹理相关的计算（例如计算原点偏移），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelDimensions。
			 *
			 * @returns pixelwidth — 纹理的宽度，以像素为单位。
			 * @returns pixelheight — 纹理的高度，以像素为单位。
			 */
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			/**
			 * 获取纹理的DPI比例因子。
			 *
			 * DPI 比例因子表示相对像素密度。 DPI 比例因子为 2 意味着纹理在每个维度上的像素密度是 DPI 比例因子为 1 的纹理的两倍（同一区域中像素数量的 4 倍）。
			 *
			 * 例如，像素尺寸为 100x100、DPI 比例因子为 2 的纹理将被绘制为 50x50。这对于高 dpi/视网膜显示器非常有用，可以轻松地交换更高或更低像素密度的图像和画布，而无需任何额外的手动缩放逻辑。
			 *
			 * @returns dpiscale — 纹理的 DPI 比例因子。
			 */
			getDPIScale(): number;
			/**
			 * 设置纹理的过滤模式。
			 *
			 * @param min 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
			 * @param mag 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更大的尺寸渲染它）。 （默认值：分钟。）
			 * @param anisotropy 使用的各向异性过滤的最大数量。 （默认值：1。）
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/**
			 * 获取纹理的滤镜模式。
			 *
			 * @returns min — 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
			 * @returns mag — 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
			 * @returns anisotropy — 使用的各向异性过滤的最大量。
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			/**
			 * 设置纹理的 mipmap 过滤器模式。在 11.0 之前，此方法仅适用于图像。
			 *
			 * Mipmapping 在以缩小比例绘制纹理时非常有用。它可以提高性能并减少锯齿问题。
			 *
			 * 在创建时启用了 mipmaps 标志，以便 mipmap 过滤器产生任何效果。在 0.10.0 之前的版本中，最好在使用 love.graphics.newImage 创建图像后直接调用此方法，以避免某些图形驱动程序中的错误。
			 *
			 * 由于硬件限制和驱动程序错误，在 0.10.0 之前的版本中，未从 CompressedData 加载的图像必须具有二维幂（64x64、512x256 等）才能使用 mipmap。
			 *
			 * 重载说明：
			 * 1. 在移动设备（Android 和 iOS）上，不支持清晰度参数，并且不会执行任何操作。您可以使用自定义压缩，其 CompressedData 包含 mipmap 数据，它将使用该数据。
			 * 2. 禁用 mipmap 过滤。
			 *
			 * @param filter 在 mipmap 级别之间使用的过滤模式。 'nearest' 通常会提供更好的性能。
			 * @param sharpness 正的锐度值使纹理在绘制时使用更详细的 mipmap 级别，但会牺牲性能。负值则相反。 （默认值：0。）
			 */
			setMipmapFilter(filter?: FilterMode, sharpness?: number): void;
			/**
			 * 获取纹理的 mipmap 过滤模式。在 11.0 之前，此方法仅适用于图像。
			 *
			 * @returns mode — 在 mipmap 级别之间使用的过滤模式。如果未启用 mipmap 过滤，则为 nil。
			 * @returns sharpness — 用于确定图像在绘制时是否应使用比正常情况更多或更少详细的 mipmap 级别的值。
			 */
			getMipmapFilter(): LuaMultiReturn<[FilterMode | undefined, number]>;
			/**
			 * 设置纹理的环绕属性。
			 *
			 * 当使用大于纹理范围的四边形绘制纹理时，或者使用使用 [0, 1] 之外的纹理坐标的自定义着色器时，此函数设置纹理的重复方式。纹理可以被夹紧或设置为在水平和垂直方向上重复。
			 *
			 * 夹紧的纹理仅出现一次（纹理的边缘拉伸以填充四边形的范围），而重复的纹理则根据四边形中的空间重复多次。
			 *
			 * @param horizontal 纹理的水平环绕模式。
			 * @param vertical 纹理的垂直环绕模式。 （默认：水平。）
			 * @param depth 体积纹理 z 轴的包裹模式。 （默认值：水平。）
			 */
			setWrap(horizontal: WrapMode, vertical?: WrapMode, depth?: WrapMode): boolean;
			/**
			 * 获取纹理的环绕属性。
			 *
			 * 该函数返回当前设置的纹理水平和垂直环绕模式。
			 *
			 * @returns horiz — 纹理的水平环绕模式。
			 * @returns vert — 纹理的垂直环绕模式。
			 * @returns depth — 体积纹理 z 轴的包裹模式。
			 */
			getWrap(): LuaMultiReturn<[WrapMode, WrapMode, WrapMode]>;
			/**
			 * 获取纹理的像素格式。
			 *
			 * @returns format — 创建纹理时使用的像素格式。
			 */
			getFormat(): string;
			/**
			 * 获取是否可以绘制纹理并将其发送到着色器。
			 *
			 * 使用模板和/或深度 PixelFormat 创建的画布默认情况下不可读，除非在传递到 love.graphics.newCanvas. 的设置表中指定 Readable=true
			 *
			 * 仍然可以渲染不可读的画布。
			 *
			 * @returns readable — 纹理是否可读。
			 */
			isReadable(): boolean;
			/**
			 * 获取图像是否是从压缩数据创建的。
			 *
			 * 压缩图像在 VRAM 中占用的空间更少，并且绘制压缩图像通常比绘制根据原始像素数据创建的图像更有效。
			 *
			 * @returns compressed — 图像是否作为压缩纹理存储在 GPU 上。
			 */
			isCompressed(): boolean;
			/**
			 * 获取图像是否是在线性（非伽玛校正）标志设置为 true 的情况下创建的。
			 *
			 * 当未启用伽玛校正渲染时，此方法始终返回 false。
			 *
			 * @returns linear — 当启用伽玛校正渲染时，图像的内部像素格式是否是线性的（未进行伽玛校正）。
			 */
			isFormatLinear(): boolean;
			/**
			 * 替换图像的内容。
			 *
			 * @param data 用于替换内容的新 ImageData。
			 * @param slice 要替换哪个立方体贴图面、数组索引或体积层（如果适用）。 （默认值：1。）
			 * @param mipmap 如果图像具有 mipmap，则要替换的 mimap 级别。 （默认值：1。）
			 * @param x 距要替换的图像左上角的 x 偏移量（以像素为单位）。给定 ImageData 的宽度加上此值不得大于图像指定 mipmap 级别的像素宽度。 （默认值：0。）
			 * @param y 距离要替换的图像左上角的 y 偏移量（以像素为单位）。给定 ImageData 的高度加上此值不得大于图像指定 mipmap 级别的像素高度。 （默认值：0。）
			 * @param reloadMipmaps 替换图像像素后是否生成新的 mipmap。如果图像是使用自动生成的 mipmap 创建的，则默认为 true，否则默认为 false。 （默认值：假。）
			 */
			replacePixels(data: ImageData, slice?: number, mipmap?: number, x?: number, y?: number, reloadMipmaps?: boolean): void;
			/**
			 * 设置从着色器中的深度纹理采样时使用的比较模式。深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
			 *
			 * 在着色器中使用具有比较模式设置的深度纹理时，必须将其声明为sampler2DShadow 并在GLSL 3 着色器中使用。在着色器中访问纹理的结果将返回一个介于 0 和 1 之间的浮点数，与通过比较操作的测试集的样本数量成正比（如果启用双线性过滤，最多将使用 4 个样本）。
			 *
			 * 深度纹理比较只能与可读的深度格式画布一起使用。
			 *
			 * @param compare 在着色器中从此纹理采样时使用的比较模式。
			 */
			setDepthSampleMode(compare?: CompareMode): void;
			/**
			 * 获取在着色器中从深度纹理采样时使用的比较模式。
			 *
			 * 深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
			 *
			 * @returns compare — 在着色器中从此纹理采样时使用的比较模式，如果尚未在此纹理上调用 setDepthSampleMode，则为 nil。 （默认值：无。）
			 */
			getDepthSampleMode(): CompareMode | undefined;
		}
		/** An object which decodes, streams, and controls Videos.
		 */
		interface VideoStream extends Object {
			/**
			 * 获取字符串形式的对象类型。
			 *
			 * @returns type — 字符串类型。
			 */
			type(): "VideoStream";
			/**
			 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
			 *
			 * @param typeName 要检查的类型的名称。
			 *
			 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
			 */
			typeOf(typeName: string): boolean;
			/**
			 * 播放视频流。
			 */
			play(): void;
			/**
			 * 暂停视频流。
			 */
			pause(): void;
			/**
			 * 设置VideoStream的当前播放位置。
			 *
			 * @param seconds 自视频流开始以来的时间（以秒为单位）。
			 */
			seek(seconds: number): void;
			/**
			 * 倒带视频流。与 VideoStream:seek(0) 同义词。
			 */
			rewind(): void;
			/**
			 * 获取VideoStream的当前播放位置。
			 *
			 * @returns seconds — 视频流开始处的秒数。
			 */
			tell(): number;
			/**
			 * 获取VideoStream是否正在播放。
			 *
			 * @returns playing — VideoStream是否正在播放。
			 */
			isPlaying(): boolean;
			/**
			 * 获取视频流的文件名。
			 *
			 * @returns filename — 视频流的文件名
			 */
			getFilename(): string;
			setSync(source?: Source): void;
		}
		/** A drawable video.
		 */
		interface Video extends Object {
			/**
			 * 获取字符串形式的对象类型。
			 *
			 * @returns type — 字符串类型。
			 */
			type(): "Video";
			/**
			 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
			 *
			 * @param typeName 要检查的类型的名称。
			 *
			 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
			 */
			typeOf(typeName: string): boolean;
			/**
			 * 获取用于解码和控制视频的VideoStream对象。
			 *
			 * @returns stream — 用于解码和控制视频的VideoStream。
			 */
			getStream(): VideoStream;
			/**
			 * 获取用于播放视频音频的音频源。如果视频没有音频，或者使用 nil 参数调用 Video:setSource ，则可能返回 nil。
			 *
			 * @returns source — 用于音频播放的音频源，如果视频没有音频则为零。
			 */
			getSource(): Source | undefined;
			/**
			 * 设置用于播放视频音频的音频源。音频源还控制播放速度和同步。
			 *
			 * @param source 用于音频播放的音频源，或 nil 以禁用音频同步。 （默认值：无。）
			 */
			setSource(source?: Source): void;
			/**
			 * 获取视频的宽度（以像素为单位）。
			 *
			 * @returns width — 视频的宽度。
			 */
			getWidth(): number;
			/**
			 * 获取视频的高度（以像素为单位）。
			 *
			 * @returns height — 视频的高度。
			 */
			getHeight(): number;
			/**
			 * 获取视频的宽度和高度（以像素为单位）。
			 *
			 * @returns width — 视频的宽度。
			 * @returns height — 视频的高度。
			 */
			getDimensions(): LuaMultiReturn<[number, number]>;
			getPixelWidth(): number;
			getPixelHeight(): number;
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			/**
			 * 设置绘制视频时使用的缩放过滤器。
			 *
			 * @param min 缩小视频时使用的过滤模式。
			 * @param mag 放大视频时使用的过滤模式。
			 * @param anisotropy 使用的各向异性过滤的最大量。 （默认值：1。）
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/**
			 * 获取绘制视频时使用的缩放过滤器。
			 *
			 * @returns min — 缩小视频时使用的过滤模式。
			 * @returns mag — 放大视频时使用的过滤模式。
			 * @returns anisotropy — 使用的各向异性过滤的最大量。
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
			 * 获取字符串形式的对象类型。
			 *
			 * @returns type — 字符串类型。
			 */
			type(): "Canvas";
			/**
			 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
			 *
			 * @param typeName 要检查的类型的名称。
			 *
			 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
			 */
			typeOf(typeName: string): boolean;
			/**
			 * 获取纹理的宽度。
			 *
			 * @returns width — 纹理的宽度。
			 */
			getWidth(): number;
			/**
			 * 获取纹理的高度。
			 *
			 * @returns height — 纹理的高度。
			 */
			getHeight(): number;
			/**
			 * 获取纹理的宽度和高度。
			 *
			 * @returns width — 纹理的宽度。
			 * @returns height — 纹理的高度。
			 */
			getDimensions(): LuaMultiReturn<[number, number]>;
			/**
			 * 获取纹理的宽度（以像素为单位）。
			 *
			 * DPI 比例因子，而不是像素。使用 getWidth 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelWidth。
			 *
			 * @returns pixelwidth — 纹理的宽度，以像素为单位。
			 */
			getPixelWidth(): number;
			/**
			 * 获取纹理的高度（以像素为单位）。
			 *
			 * DPI 比例因子，而不是像素。使用 getHeight 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelHeight。
			 *
			 * @returns pixelheight — 纹理的高度，以像素为单位。
			 */
			getPixelHeight(): number;
			/**
			 * 获取纹理的宽度和高度（以像素为单位）。
			 *
			 * Texture:getDimensions 获取纹理的尺寸，单位是按纹理的 DPI 比例因子缩放的单位，而不是像素。使用 getDimensions 进行与绘制纹理相关的计算（例如计算原点偏移），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelDimensions。
			 *
			 * @returns pixelwidth — 纹理的宽度，以像素为单位。
			 * @returns pixelheight — 纹理的高度，以像素为单位。
			 */
			getPixelDimensions(): LuaMultiReturn<[number, number]>;
			/**
			 * 获取纹理的DPI比例因子。
			 *
			 * DPI 比例因子表示相对像素密度。 DPI 比例因子为 2 意味着纹理在每个维度上的像素密度是 DPI 比例因子为 1 的纹理的两倍（同一区域中像素数量的 4 倍）。
			 *
			 * 例如，像素尺寸为 100x100、DPI 比例因子为 2 的纹理将被绘制为 50x50。这对于高 dpi/视网膜显示器非常有用，可以轻松地交换更高或更低像素密度的图像和画布，而无需任何额外的手动缩放逻辑。
			 *
			 * @returns dpiscale — 纹理的 DPI 比例因子。
			 */
			getDPIScale(): number;
			/**
			 * 获取纹理的类型。
			 *
			 * @returns texturetype — 纹理的类型。
			 */
			getTextureType(): TextureType;
			/**
			 * 获取体积纹理的深度。对于 2D、立方体贴图和数组纹理返回 1。
			 *
			 * @returns depth — 体积纹理的深度。
			 */
			getDepth(): number;
			/**
			 * 获取数组纹理中的层数/切片数。对于 2D、立方体贴图和体积纹理，返回 1。
			 *
			 * @returns layers — 阵列纹理中的层数。
			 */
			getLayerCount(): number;
			/**
			 * 获取纹理中包含的 mipmap 数量。如果纹理不是使用 mipmap 创建的，它将返回 1。
			 *
			 * @returns mipmaps — 纹理中 mipmap 的数量。
			 */
			getMipmapCount(): number;
			/**
			 * 获取创建此 Canvas 时使用的 MipmapMode。
			 *
			 * @returns mode — 创建此 Canvas 时使用的 mipmap 模式。
			 */
			getMipmapMode(): string;
			/**
			 * 获取纹理的像素格式。
			 *
			 * @returns format — 创建纹理时使用的像素格式。
			 */
			getFormat(): CanvasFormat;
			/**
			 * 获取绘制到画布时使用的多重采样抗锯齿 (MSAA) 样本数。
			 *
			 * 如果运行 LÖVE 的系统不支持该数字，则该数字可能与用作 love.graphics.newCanvas 参数的数字不同。
			 *
			 * @returns samples — 画布在绘制时使用的多重采样抗锯齿样本数。
			 */
			getMSAA(): 0 | 2 | 4 | 8 | 16;
			/**
			 * 获取是否可以绘制纹理并将其发送到着色器。
			 *
			 * 使用模板和/或深度 PixelFormat 创建的画布默认情况下不可读，除非在传递到 love.graphics.newCanvas. 的设置表中指定 Readable=true
			 *
			 * 仍然可以渲染不可读的画布。
			 *
			 * @returns readable — 纹理是否可读。
			 */
			isReadable(): boolean;
			/**
			 * 从画布的内容生成图像数据。
			 *
			 * @param slice 分别是立方体贴图、数组或体积类型画布的立方体贴图面索引、数组索引或深度层。对于常规 2D 画布，此参数将被忽略。
			 * @param mipmap 要使用的 mipmap 索引，用于具有 mipmap 的画布。 （默认值：1。）
			 * @param x 画布内要捕获的区域的左上角（以像素为单位）的 x 轴。
			 * @param y 画布内要捕获的区域的左上角（以像素为单位）的 y 轴。
			 * @param width 画布内要捕获的区域的宽度（以像素为单位）。
			 * @param height 画布内要捕获的区域的高度（以像素为单位）。
			 *
			 * @returns data — 由画布内容制成的新 ImageData。
			 */
			newImageData(slice?: 1, mipmap?: 1, x?: number, y?: number, width?: number, height?: number): ImageData;
			/**
			 * 设置纹理的过滤模式。
			 *
			 * @param min 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
			 * @param mag 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更大的尺寸渲染它）。 （默认值：分钟。）
			 * @param anisotropy 使用的各向异性过滤的最大数量。 （默认值：1。）
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/**
			 * 获取纹理的滤镜模式。
			 *
			 * @returns min — 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
			 * @returns mag — 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
			 * @returns anisotropy — 使用的各向异性过滤的最大量。
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			/**
			 * 设置纹理的 mipmap 过滤器模式。在 11.0 之前，此方法仅适用于图像。
			 *
			 * Mipmapping 在以缩小比例绘制纹理时非常有用。它可以提高性能并减少锯齿问题。
			 *
			 * 在创建时启用了 mipmaps 标志，以便 mipmap 过滤器产生任何效果。在 0.10.0 之前的版本中，最好在使用 love.graphics.newImage 创建图像后直接调用此方法，以避免某些图形驱动程序中的错误。
			 *
			 * 由于硬件限制和驱动程序错误，在 0.10.0 之前的版本中，未从 CompressedData 加载的图像必须具有二维幂（64x64、512x256 等）才能使用 mipmap。
			 *
			 * 重载说明：
			 * 1. 在移动设备（Android 和 iOS）上，不支持清晰度参数，并且不会执行任何操作。您可以使用自定义压缩，其 CompressedData 包含 mipmap 数据，它将使用该数据。
			 * 2. 禁用 mipmap 过滤。
			 *
			 * @param filter 在 mipmap 级别之间使用的过滤模式。 'nearest' 通常会提供更好的性能。
			 * @param sharpness 正的锐度值使纹理在绘制时使用更详细的 mipmap 级别，但会牺牲性能。负值则相反。 （默认值：0。）
			 */
			setMipmapFilter(filter?: FilterMode, sharpness?: number): void;
			/**
			 * 获取纹理的 mipmap 过滤模式。在 11.0 之前，此方法仅适用于图像。
			 *
			 * @returns mode — 在 mipmap 级别之间使用的过滤模式。如果未启用 mipmap 过滤，则为 nil。
			 * @returns sharpness — 用于确定图像在绘制时是否应使用比正常情况更多或更少详细的 mipmap 级别的值。
			 */
			getMipmapFilter(): LuaMultiReturn<[FilterMode | undefined, number]>;
			/**
			 * 设置纹理的环绕属性。
			 *
			 * 当使用大于纹理范围的四边形绘制纹理时，或者使用使用 [0, 1] 之外的纹理坐标的自定义着色器时，此函数设置纹理的重复方式。纹理可以被夹紧或设置为在水平和垂直方向上重复。
			 *
			 * 夹紧的纹理仅出现一次（纹理的边缘拉伸以填充四边形的范围），而重复的纹理则根据四边形中的空间重复多次。
			 *
			 * @param horizontal 纹理的水平环绕模式。
			 * @param vertical 纹理的垂直环绕模式。 （默认：水平。）
			 * @param depth 体积纹理 z 轴的包裹模式。 （默认值：水平。）
			 */
			setWrap(horizontal: WrapMode, vertical?: WrapMode, depth?: WrapMode): boolean;
			/**
			 * 获取纹理的环绕属性。
			 *
			 * 该函数返回当前设置的纹理水平和垂直环绕模式。
			 *
			 * @returns horiz — 纹理的水平环绕模式。
			 * @returns vert — 纹理的垂直环绕模式。
			 * @returns depth — 体积纹理 z 轴的包裹模式。
			 */
			getWrap(): LuaMultiReturn<[WrapMode, WrapMode, WrapMode]>;
			/**
			 * 设置从着色器中的深度纹理采样时使用的比较模式。深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
			 *
			 * 在着色器中使用具有比较模式设置的深度纹理时，必须将其声明为sampler2DShadow 并在GLSL 3 着色器中使用。在着色器中访问纹理的结果将返回一个介于 0 和 1 之间的浮点数，与通过比较操作的测试集的样本数量成正比（如果启用双线性过滤，最多将使用 4 个样本）。
			 *
			 * 深度纹理比较只能与可读的深度格式画布一起使用。
			 *
			 * @param compare 在着色器中从此纹理采样时使用的比较模式。
			 */
			setDepthSampleMode(compare?: CompareMode): void;
			/**
			 * 获取在着色器中从深度纹理采样时使用的比较模式。
			 *
			 * 深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
			 *
			 * @returns compare — 在着色器中从此纹理采样时使用的比较模式，如果尚未在此纹理上调用 setDepthSampleMode，则为 nil。 （默认值：无。）
			 */
			getDepthSampleMode(): CompareMode | undefined;
			/**
			 * 根据最高分辨率 mipmap 级别的内容为画布生成 mipmap。
			 *
			 * 创建画布时必须将 mipmap 设置为除 'none' 之外的 MipmapMode，此函数才能正常工作。仅当 Canvas 不是活动渲染目标时才应调用它。
			 *
			 * 如果mipmap模式设置为'auto'，当从这个Canvas切换到另一个Canvas或切换到主屏幕时，会在love.graphics.setCanvas内部自动调用此函数。
			 */
			generateMipmaps(): void;
			/**
			 * 使用函数渲染到画布。
			 *
			 * 这是 love.graphics.setCanvas 的快捷方式：
			 *
			 * canvas:renderTo( func )
			 *
			 * 与
			 *
			 * love.graphics.setCanvas( 画布 )
			 *
			 * func()
			 *
			 * love.graphics.setCanvas()
			 *
			 * @param callback 执行绘图操作的函数。
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
			 * 获取字符串形式的对象类型。
			 *
			 * @returns type — 字符串类型。
			 */
			type(): "Font";
			/**
			 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
			 *
			 * @param type 要检查的类型的名称。
			 *
			 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
			 */
			typeOf(type: string): boolean;
			/**
			 * 确定给定字符串所采用的最大宽度（考虑换行符）。
			 *
			 * @param text 一个字符串。
			 *
			 * @returns width — 文本的宽度。
			 */
			getWidth(text: string): number;
			/**
			 * 获取字体的高度。
			 *
			 * 字体的高度是包括任何间距的大小；它需要的高度。
			 *
			 * @returns height — 字体的高度（以像素为单位）。
			 */
			getHeight(): number;
			/**
			 * 获取字体的基线。
			 *
			 * 大多数脚本都共享基线的概念：字符所在的假想水平线。在某些脚本中，部分字形位于基线下方。
			 *
			 * @returns baseline — 字体的基线（以像素为单位）。
			 */
			getBaseline(): number;
			/**
			 * 获取字体的上升度。
			 *
			 * 上升跨越基线和距基线最远的字形顶部之间的距离。
			 *
			 * @returns ascent — 字体的上升（以像素为单位）。
			 */
			getAscent(): number;
			/**
			 * 获取字体的血统。
			 *
			 * 下降跨越字体中基线和最低下降字形之间的距离。
			 *
			 * @returns descent — 字体的下降（以像素为单位）。
			 */
			getDescent(): number;
			/**
			 * 获取 Font 是否可以渲染字符或字符串。
			 *
			 * @param textOrCodepoints UTF-8 编码的 unicode 字符串。
			 *
			 * @returns hasglyph — 字体是否可以渲染字符串中的所有UTF-8字符。取决于重载：字体是否可以渲染字符表示的所有字形。取决于重载：字体是否可以渲染由代码点数字表示的所有字形。
			 */
			hasGlyphs(...textOrCodepoints: (string | number)[]): boolean;
			/**
			 * 获取字体中两个字符之间的字距调整。
			 *
			 * 字距调整通常在 love.graphics.print、文本对象、Font:getWidth、Font:getWrap 等中自动处理。当手动将文本拼接在一起时，此功能非常有用。
			 *
			 * @param left 左边的字符。取决于重载：左侧字形的 unicode 编号。
			 * @param right 正确的字符。取决于重载：正确字形的 unicode 编号。
			 *
			 * @returns kerning — 添加到两个字符之间的间距的字距调整量。可能是负值。
			 */
			getKerning(left: string | number, right: string | number): number;
			/**
			 * 设置后备字体。当字体不包含字形时，它将替换下一个后续后备字体中的字形。这类似于在层叠样式表 (CSS) 中设置 'font stack'。
			 *
			 * 重载说明：
			 * 1. 如果调用它，它应该在调用 love.graphics.print、Font:getWrap 和其他使用字形定位信息的 Font 方法之前。每个后备字体必须从与主字体相同的文件类型创建。例如，从 .ttf 文件创建的字体只能使用从 .ttf 文件创建的后备字体。
			 *
			 * @param fallbacks 使用的第一个后备字体。
			 */
			setFallbacks(...fallbacks: Font[]): void;
			/**
			 * 设置行高。
			 *
			 * 当以行渲染字体时，实际高度将由行高乘以字体高度确定。默认值为 1.0。
			 *
			 * @param height 新行高。
			 */
			setLineHeight(height: number): void;
			/**
			 * 获取行高。
			 *
			 * 这将是之前由 Font:setLineHeight 设置的值，默认情况下为 1.0。
			 *
			 * @returns height — 当前行高。
			 */
			getLineHeight(): number;
			/**
			 * 获取字体的 DPI 比例因子。
			 *
			 * DPI 比例因子表示相对像素密度。 DPI 比例因子为 2 意味着与 DPI 比例因子为 1 的字体相比，字体的字形在每个维度上的像素密度是两倍（同一区域中像素数量的 4 倍）。
			 *
			 * TrueType 字体的字体大小在内部按字体指定的 DPI 比例因子进行缩放。默认情况下，LÖVE 在创建 TrueType 字体时使用屏幕的 DPI 比例因子。
			 *
			 * @returns dpiscale — 字体的 DPI 比例因子。
			 */
			getDPIScale(): number;
			/**
			 * 获取字体的过滤模式。
			 *
			 * @returns min — 缩小字体时使用的过滤模式。
			 * @returns mag — 放大字体时使用的过滤模式。
			 * @returns anisotropy — 使用的各向异性过滤的最大量。
			 */
			getFilter(): LuaMultiReturn<[FilterMode, FilterMode, number]>;
			/**
			 * 设置字体的过滤模式。
			 *
			 * @param min 如何缩小字体。
			 * @param mag 如何放大字体。
			 * @param anisotropy 使用的各向异性过滤的最大量。 （默认值：1。）
			 */
			setFilter(min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
			/**
			 * 获取文本的格式信息（给定换行限制）。
			 *
			 * 此函数正确解释换行符（即 '\n'）。
			 *
			 * @param text 将被换行的文本。
			 * @param wrapLimit 在换行之前允许“'text'”每行的最大宽度（以像素为单位）。
			 *
			 * @returns width — 换行文本的最大宽度。
			 * @returns wrappedtext — 包含换行的每一行文本的序列。
			 */
			getWrap(text: string, wrapLimit: number): LuaMultiReturn<[number, string[]]>;
		}
		/** Drawable text.
		 */
		interface Text extends Object {
			/**
			 * 用新的未格式化字符串替换 Text 对象的内容。
			 *
			 * 重载说明：
			 * 1. 在绘制文本对象时，love.graphics.setColor 设置的颜色将与文本的颜色组合（相乘）。
			 *
			 * @param text 要使用的新文本字符串。取决于重载：包含用作新文本的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
			 * @param text.color1 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
			 * @param text.string1 文本字符串，其颜色由前一个颜色指定。
			 * @param text.color2 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
			 * @param text.string2 文本字符串，其颜色由前一个颜色指定。
			 * @param text.... 附加颜色和字符串。
			 */
			set(text: ColoredText): void;
			/**
			 * 用新的格式化字符串替换 Text 对象的内容。
			 *
			 * 重载说明：
			 * 1. 在绘制文本对象时，love.graphics.setColor 设置的颜色将与文本的颜色组合（相乘）。
			 *
			 * @param text 要使用的新文本字符串。取决于重载：包含用作新文本的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
			 * @param text.color1 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
			 * @param text.string1 文本字符串，其颜色由前一个颜色指定。
			 * @param text.color2 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
			 * @param text.string2 文本字符串，其颜色由前一个颜色指定。
			 * @param text.... 附加颜色和字符串。
			 * @param wrapLimit 自动换行之前文本的最大宽度（以像素为单位）。
			 * @param align 文本的对齐方式。
			 */
			setf(text: ColoredText, wrapLimit: number, align: AlignMode): void;
			/**
			 * 将附加彩色文本添加到 Text 对象的指定位置。
			 *
			 * 重载说明：
			 * 1. 在绘制文本对象时，love.graphics.setColor 设置的颜色将与文本的颜色组合（相乘）。
			 *
			 * @param text 要添加到对象的文本。取决于重载：包含要添加到对象的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
			 * @param text.color1 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
			 * @param text.string1 文本字符串，其颜色由前一个颜色指定。
			 * @param text.color2 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
			 * @param text.string2 文本字符串，其颜色由前一个颜色指定。
			 * @param text.... 附加颜色和字符串。
			 * @param transform 新文本在 x 轴上的位置。 （默认值：0。）
			 * @param x 新文本在 x 轴上的位置。 （默认值：0。）
			 * @param y 新文本在 y 轴上的位置。 （默认值：0。）
			 * @param angle 新文本的方向（以弧度表示）。 （默认值：0。）
			 * @param scaleX x 轴上的比例因子。 （默认值：1。）
			 * @param scaleY y 轴的比例因子。 （默认值：sx。）
			 * @param originX x 轴上的原点偏移。 （默认值：0。）
			 * @param originY y 轴上的原点偏移。 （默认值：0。）
			 * @param shearX x 轴上的剪切/倾斜因子。 （默认值：0。）
			 * @param shearY y 轴上的剪切/倾斜因子。 （默认值：0。）
			 *
			 * @returns index — 可与 Text:getWidth 或 Text:getHeight 一起使用的索引号。
			 */
			add(text: ColoredText, transform: Transform): number;
			add(text: ColoredText, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/**
			 * 将附加格式化/彩色文本添加到 Text 对象的指定位置。
			 *
			 * 在任何缩放、旋转和其他坐标转换之前应用自动换行限制。因此，即使比例参数发生变化，在给定相同的换行限制的情况下，每行的文本量也保持不变。
			 *
			 * 重载说明：
			 * 1. 在绘制文本对象时，love.graphics.setColor 设置的颜色将与文本的颜色组合（相乘）。
			 *
			 * @param text 要添加到对象的文本。取决于重载：包含要添加到对象的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
			 * @param text.color1 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
			 * @param text.string1 文本字符串，其颜色由前一个颜色指定。
			 * @param text.color2 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
			 * @param text.string2 文本字符串，其颜色由前一个颜色指定。
			 * @param text.... 附加颜色和字符串。
			 * @param wrapLimit 自动换行之前文本的最大宽度（以像素为单位）。
			 * @param align 文本的对齐方式。
			 * @param transform 新文本的位置（x 轴）。
			 * @param x 新文本的位置（x 轴）。
			 * @param y 新文本的位置（y 轴）。
			 * @param angle 方向（弧度）。 （默认值：0。）
			 * @param scaleX 比例因子（x 轴）。 （默认值：1。）
			 * @param scaleY 比例因子（y 轴）。 （默认值：sx。）
			 * @param originX 原点偏移（x 轴）。 （默认值：0。）
			 * @param originY 原点偏移（y 轴）。 （默认值：0。）
			 * @param shearX 剪切/倾斜因子（x 轴）。 （默认值：0。）
			 * @param shearY 剪切/倾斜因子（y 轴）。 （默认值：0。）
			 *
			 * @returns index — 可与 Text:getWidth 或 Text:getHeight 一起使用的索引号。
			 */
			addf(text: ColoredText, wrapLimit: number, align: AlignMode, transform: Transform): number;
			addf(text: ColoredText, wrapLimit: number, align: AlignMode, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/**
			 * 清除文本对象的内容。
			 */
			clear(): void;
			/**
			 * 替换文本使用的字体。
			 *
			 * @param font 与此 Text 对象一起使用的新字体。
			 */
			setFont(font: Font): void;
			/**
			 * 获取与 Text 对象一起使用的 Font。
			 *
			 * @returns font — 此文本对象使用的字体。
			 */
			getFont(): Font;
			/**
			 * 获取文本的宽度（以像素为单位）。
			 *
			 * 重载说明：
			 * 1. 获取先前添加到 Text 对象的特定子字符串的宽度。
			 *
			 * @param index Text:add 或 Text:addf 返回的索引号。
			 *
			 * @returns width — 文本的宽度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的宽度。取决于重载：子字符串的宽度（在缩放和其他转换之前）。
			 */
			getWidth(index?: number): number;
			/**
			 * 获取文本的高度（以像素为单位）。
			 *
			 * 重载说明：
			 * 1. 获取先前添加到 Text 对象的特定子字符串的高度。
			 *
			 * @param index Text:add 或 Text:addf 返回的索引号。
			 *
			 * @returns  height  — 文本的高度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的高度。
			 * @returns height — 子字符串的高度（在缩放和其他转换之前）。
			 */
			getHeight(index?: number): number;
			/**
			 * 获取文本的宽度和高度（以像素为单位）。
			 *
			 * 重载说明：
			 * 1. 获取先前添加到 Text 对象的特定子字符串的宽度和高度。
			 *
			 * @param index Text:add 或 Text:addf 返回的索引号。
			 *
			 * @returns width — 文本的宽度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的宽度。取决于重载：子字符串的宽度（在缩放和其他转换之前）。
			 * @returns height — 文本的高度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的高度。取决于过载：子字符串的高度（在缩放和其他转换之前）。
			 */
			getDimensions(index?: number): LuaMultiReturn<[number, number]>;
		}
		/** A quadrilateral (a polygon with four sides and four corners) with texture coordinate information.
		 */
		interface Quad extends Object {
			/**
			 * 根据视口设置纹理坐标。
			 *
			 * @param x 沿 x 轴的左上角。
			 * @param y y 轴的左上角。
			 * @param width 视口的宽度。
			 * @param height 视口的高度。
			 * @param textureWidth 可选的新参考宽度，纹理的宽度。如果设置，则必须大于 0。 （默认值：无。）
			 * @param textureHeight 可选的新参考高度，纹理的高度。如果设置，则必须大于 0。 （默认值：无。）
			 */
			setViewport(x: number, y: number, width: number, height: number, textureWidth?: number, textureHeight?: number): void;
			/**
			 * 获取此Quad 的当前视口。
			 *
			 * @returns x — 沿 x 轴的左上角。
			 * @returns y — y 轴的左上角。
			 * @returns w — 视口的宽度。
			 * @returns h — 视口的高度。
			 */
			getViewport(): LuaMultiReturn<[number, number, number, number]>;
			/**
			 * 获取最初在 love.graphics.newQuad.
			 *
			 * @returns sw — 四边形使用的纹理宽度。
			 * @returns sh — 四边形使用的纹理高度。
			 */
			getTextureDimensions(): LuaMultiReturn<[number, number]>;
			setLayer(layer: number): void;
			getLayer(): number;
		}
		/** A 2D polygon mesh used for drawing arbitrary textured shapes.
		 */
		interface Mesh extends Object {
			/**
			 * 用新顶点替换网格中的一系列顶点。网格体的顶点总数在创建后就无法更改。这通常比在循环中调用 Mesh:setVertex 更有效。
			 *
			 * 重载说明：
			 * 1. 每个顶点表中的值与网格顶点格式中的顶点属性的顺序相同。不是使用自定义顶点格式创建的标准网格将使用两个位置编号、两个纹理坐标编号以及每个顶点的四个颜色分量：x、y、u、v、r、g、b、a。如果没有为特定顶点属性组件提供值，则如果其数据类型为 'float'，则将设置为默认值 0；如果其数据类型为 'byte'，则设置为 255。
			 * 2. 通过直接从数据对象的内存复制来设置网格的顶点组件。如果使用 LuaJIT 的 FFI 通过 Data:getPointer 和 ffi.cast 填充数据对象，则此变体比设置网格顶点数据的其他方法要高效得多。
			 * 3. 设置不是使用自定义顶点格式创建的网格体的顶点组件。
			 *
			 * @param vertices 该表填充了每个顶点的顶点信息表，其形式为{vertex, ...}，其中每个顶点是一个形式为{attributecomponent, ...}的表。根据过载情况：表格中每个顶点填充的顶点信息表如下：
			 * @param vertices.attributecomponent 顶点中第一个顶点属性的第一个组成部分。
			 * @param vertices.... 顶点中所有顶点属性的附加组件。
			 * @param vertices.1 顶点在 x 轴上的位置。
			 * @param vertices.2 顶点在 y 轴上的位置。
			 * @param vertices.3 纹理坐标的水平分量。纹理坐标通常在 1 范围内，但可以更大或更小（请参阅 WrapMode）。
			 * @param vertices.4 纹理坐标的垂直分量。纹理坐标通常在 1 范围内，但可以更大或更小（请参阅 WrapMode）。
			 * @param vertices.5 红色分量。 （默认值：1。）
			 * @param vertices.6 绿色分量。 （默认值：1。）
			 * @param vertices.7 蓝色分量。 （默认值：1。）
			 * @param vertices.8 Alpha 颜色分量。 （默认值：1。）
			 * @param startVertex 要替换的第一个顶点的索引。 （默认值：1。）
			 * @param vertexCount 要替换的顶点数量。 （默认值：全部。）
			 * @param data 要复制的数据对象。数据的内容必须与该网格体的顶点格式的布局相匹配。
			 */
			setVertices(vertices: MeshVertex[], startVertex?: number, vertexCount?: number): void;
			setVertices(data: Data, startVertex?: number, vertexCount?: number): void;
			/**
			 * 设置网格中顶点的属性。
			 *
			 * 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
			 *
			 * 重载说明：
			 * 1. 参数的顺序与网格顶点格式中的顶点属性相同。不是使用自定义顶点格式创建的标准网格将使用两个位置编号、两个纹理坐标编号以及每个顶点的四个颜色分量：x、y、u、v、r、g、b、a。如果没有为特定顶点属性组件提供值，则如果其数据类型为 'float'，则将设置为默认值 0；如果其数据类型为 'byte'，则将设置为 1。
			 * 2. 表索引的顺序与网格顶点格式中的顶点属性的顺序相同。不是使用自定义顶点格式创建的标准网格将使用两个位置编号、两个纹理坐标编号以及每个顶点的四个颜色分量：x、y、u、v、r、g、b、a。如果没有为特定顶点属性组件提供值，则如果其数据类型为 'float'，则将设置为默认值 0；如果其数据类型为 'byte'，则将设置为 1。
			 * 3. 设置不是使用自定义顶点格式创建的网格体的顶点组件。
			 *
			 * @param index 要修改的顶点的索引（从一开始）。
			 * @param vertex 包含顶点信息的表，格式为{attributecomponent, ...}。取决于过载：带有顶点信息的表。
			 * @param vertex.attributecomponent 指定顶点中第一个顶点属性的第一个组件。
			 * @param vertex.... 指定顶点中所有顶点属性的附加组件。
			 * @param vertex.1 顶点在 x 轴上的位置。
			 * @param vertex.2 顶点在 y 轴上的位置。
			 * @param vertex.3 u 纹理坐标。纹理坐标通常在 1 的范围内，但可以更大或更小（请参阅 WrapMode。）
			 * @param vertex.4 v 纹理坐标。纹理坐标通常在 1 的范围内，但可以更大或更小（请参阅 WrapMode。）
			 * @param vertex.5 红色分量。 （默认值：1。）
			 * @param vertex.6 绿色分量。 （默认值：1。）
			 * @param vertex.7 蓝色分量。 （默认值：1。）
			 * @param vertex.8 Alpha 颜色分量。 （默认值：1。）
			 * @param components 包含顶点信息的表，格式为{attributecomponent, ...}。取决于过载：带有顶点信息的表。
			 * @param components.attributecomponent 指定顶点中第一个顶点属性的第一个组件。
			 * @param components.... 指定顶点中所有顶点属性的附加组件。
			 * @param components.1 顶点在 x 轴上的位置。
			 * @param components.2 顶点在 y 轴上的位置。
			 * @param components.3 u 纹理坐标。纹理坐标通常在 1 的范围内，但可以更大或更小（请参阅 WrapMode。）
			 * @param components.4 v 纹理坐标。纹理坐标通常在 1 的范围内，但可以更大或更小（请参阅 WrapMode。）
			 * @param components.5 红色分量。 （默认值：1。）
			 * @param components.6 绿色分量。 （默认值：1。）
			 * @param components.7 蓝色分量。 （默认值：1。）
			 * @param components.8 Alpha 颜色分量。 （默认值：1。）
			 */
			setVertex(index: number, vertex: MeshVertex): void;
			setVertex(index: number, ...components: number[]): void;
			/**
			 * 获取网格中顶点的属性。
			 *
			 * 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
			 *
			 * 重载说明：
			 * 1. 值的返回顺序与网格顶点格式中的顶点属性相同。不是使用自定义顶点格式创建的标准网格将返回两个位置编号、两个纹理坐标编号和四个颜色分量：x、y、u、v、r、g、b、a。
			 * 2. 获取不是使用自定义顶点格式创建的网格体的顶点组件。
			 *
			 * @param index 要检索其信息的顶点的从一开始的索引。取决于过载：要检索其信息的顶点的索引。
			 *
			 * @returns attributecomponent — 指定顶点中第一个顶点属性的第一个组件。
			 * @returns ... — 指定顶点中所有顶点属性的附加组件。
			 * @returns x — 顶点在 x 轴上的位置。
			 * @returns y — 顶点在 y 轴上的位置。
			 * @returns u — 纹理坐标的水平分量。
			 * @returns v — 纹理坐标的垂直分量。
			 * @returns r — 顶点颜色的红色分量。
			 * @returns g — 顶点颜色的绿色分量。
			 * @returns b — 顶点颜色的蓝色分量。
			 * @returns a — 顶点颜色的 Alpha 分量。
			 */
			getVertex(index: number): LuaMultiReturn<[number, ...number[]]>;
			/**
			 * 设置网格中顶点内特定属性的属性。
			 *
			 * 没有在 love.graphics.newMesh 中指定的自定义顶点格式的网格体将位置作为其第一个属性，将纹理坐标作为其第二个属性，将颜色作为其第三个属性。
			 *
			 * 重载说明：
			 * 1. 存在于属性中但未指定为参数的属性组件对于浮点数据类型的属性默认为 0，对于字节数据类型默认为 255。
			 *
			 * @param vertexIndex 要修改的顶点的索引（从一开始）。
			 * @param attributeIndex 要修改的顶点中属性的索引（从一开始）。
			 * @param components 属性第一个组件的新值。
			 */
			setVertexAttribute(vertexIndex: number, attributeIndex: number, ...components: number[]): void;
			/**
			 * 获取网格中顶点内特定属性的属性。
			 *
			 * 没有在 love.graphics.newMesh 中指定的自定义顶点格式的网格体将位置作为其第一个属性，将纹理坐标作为其第二个属性，将颜色作为其第三个属性。
			 *
			 * @param vertexIndex 要检索其属性的顶点的索引（从一开始）。
			 * @param attributeIndex 要检索的顶点中的属性索引（从一开始）。
			 *
			 * @returns value1 — 属性第一个组成部分的值。
			 * @returns value2 — 属性第二个组成部分的值。
			 * @returns ... — 任何附加的顶点属性组件。
			 */
			getVertexAttribute(vertexIndex: number, attributeIndex: number): LuaMultiReturn<[number, ...number[]]>;
			/**
			 * 获取Mesh中的顶点总数。
			 *
			 * @returns count — 网格中的顶点总数。
			 */
			getVertexCount(): number;
			/**
			 * 获取创建网格体所用的顶点格式。
			 *
			 * 重载说明：
			 * 1. 如果网格不是使用自定义顶点格式创建的，它将具有以下顶点格式： defaultformat = { {'VertexPosition', 'float', 2}, -- 每个顶点的 x,y 位置。 {'VertexTexCoord', 'float', 2}, -- 每个顶点的 u,v 纹理坐标。 {'VertexColor', 'byte', 4} -- 每个顶点的 r,g,b,a 颜色。 }
			 *
			 * @returns format — 网格体的顶点格式，它是一个表，其中包含用于创建网格体的每个顶点属性的表，格式为 {attribute, ...}。
			 * @returns format.attribute — 包含属性名称、数据类型以及属性中组件数量的表，格式为{名称、数据类型、组件}。
			 * @returns format.... — 网格中的附加顶点属性。
			 */
			getVertexFormat(): MeshVertexFormat[];
			/**
			 * 启用或禁用网格中的特定顶点属性。绘制网格时不使用禁用属性中的顶点数据。
			 *
			 * 重载说明：
			 * 1. 如果网格体不是使用自定义顶点格式创建的，它将具有 3 个顶点属性，分别名为 VertexPosition、VertexTexCoord 和 VertexColor。否则，属性名称必须与创建网格体时以顶点格式指定的顶点属性之一匹配，或者必须与通过 Mesh:attachAttribute 连接到此网格体的另一个网格体的顶点属性匹配。
			 *
			 * @param name 要启用或禁用的顶点属性的名称。
			 * @param enabled 绘制此Mesh时是否使用顶点属性。
			 */
			setAttributeEnabled(name: string, enabled: boolean): void;
			/**
			 * 获取Mesh中特定顶点属性是否启用。绘制网格时不使用禁用属性中的顶点数据。
			 *
			 * 重载说明：
			 * 1. 如果网格体不是使用自定义顶点格式创建的，它将具有 3 个顶点属性，分别名为 VertexPosition、VertexTexCoord 和 VertexColor。否则，属性名称必须与创建网格体时以顶点格式指定的顶点属性之一匹配，或者必须与通过 Mesh:attachAttribute 连接到此网格体的另一个网格体的顶点属性匹配。
			 *
			 * @param name 要检查的顶点属性的名称。
			 *
			 * @returns enabled — 绘制此Mesh时是否使用顶点属性。
			 */
			isAttributeEnabled(name: string): boolean;
			/**
			 * 将来自不同网格的顶点属性附加到此网格上，以供绘制时使用。这可用于在多个不同网格之间共享顶点属性数据。
			 *
			 * 重载说明：
			 * 1. 如果网格不是使用自定义顶点格式创建的，它将具有 3 个顶点属性，分别名为 VertexPosition、VertexTexCoord 和 VertexColor。可以通过将自定义命名属性声明为属性 vec4 MyCustomAttributeName 在顶点着色器中访问它们；位于顶点着色器代码的顶层。该名称必须与网格体顶点格式和 Mesh:attachAttribute 的名称参数中指定的名称相匹配。
			 *
			 * @param name 要附加的顶点属性的名称。
			 * @param mesh 要从中获取顶点属性的网格体。
			 * @param step 绘制网格时该属性是按顶点还是按实例。 （默认：'pervertex'。）
			 * @param attributeName 在着色器代码中使用的属性的名称。默认为给定网格中的属性名称。可用于在渲染时为此属性使用不同的名称。 （默认值：名称。）
			 */
			attachAttribute(name: string, mesh: Mesh, step?: AttributeStep, attributeName?: string): void;
			/**
			 * 从此网格中删除先前附加的顶点属性。
			 *
			 * @param name 要分离的附加顶点属性的名称。
			 *
			 * @returns success — 属性是否已成功分离。
			 */
			detachAttribute(name: string): boolean;
			/**
			 * 设置网格的顶点贴图。顶点图描述了绘制Mesh时顶点的使用顺序。顶点、顶点贴图和网格绘制模式共同确定屏幕上显示的内容。
			 *
			 * 顶点贴图允许您在绘制时重新排序或重用顶点，而无需更改实际的顶点参数或复制顶点。当与不同的网格绘制模式结合使用时，它特别有用。
			 *
			 * @param indices 包含绘图时使用的顶点索引列表的表。值必须在 Mesh:getVertexCount() 范围内。
			 * @param data 绘制时使用的顶点索引数组。值必须在 Mesh:getVertexCount()-1
			 * @param dataType 上面顶点索引数组的数据类型。
			 * @param indexCount 绘制时使用的第三个顶点的索引。
			 */
			setVertexMap(): void;
			setVertexMap(indices: number[]): void;
			setVertexMap(...indices: number[]): void;
			setVertexMap(data: Data, dataType: IndexDataType, indexCount?: number): void;
			/**
			 * 获取网格的顶点贴图。顶点图描述了绘制Mesh时顶点的使用顺序。顶点、顶点贴图和网格绘制模式共同确定屏幕上显示的内容。
			 *
			 * 如果之前没有通过 Mesh:setVertexMap 设置顶点贴图，那么该函数在 LÖVE 0.10.0+ 中将返回 nil，或者在 0.9.2 及更早版本中返回空表。
			 *
			 * @returns map — 包含绘图时使用的顶点索引列表的表。
			 */
			getVertexMap(): number[] | undefined;
			/**
			 * 设置绘制网格时使用的纹理（图像或画布）。
			 *
			 * 重载说明：
			 * 1. 绘制网格时禁用任何纹理。默认情况下，无纹理的网格具有白色。
			 *
			 * @param texture 绘制时用于纹理网格的图像或画布。
			 */
			setTexture(texture?: Image | Canvas): void;
			/**
			 * 获取绘制网格时使用的纹理（图像或画布）。
			 *
			 * @returns texture — 绘制时用于纹理网格的图像或画布，如果未设置则为零。
			 */
			getTexture(): Image | Canvas | undefined;
			/**
			 * 设置绘制网格时使用的模式。
			 *
			 * @param mode 绘制网格时使用的模式。
			 */
			setDrawMode(mode: MeshDrawMode): void;
			/**
			 * 获取绘制网格时使用的模式。
			 *
			 * @returns mode — 绘制网格时使用的模式。
			 */
			getDrawMode(): MeshDrawMode;
			/**
			 * 将网格的绘制顶点限制为总数的子集。
			 *
			 * 重载说明：
			 * 1. 允许绘制网格中的所有顶点。
			 *
			 * @param start 绘制时要使用的第一个顶点的索引，或者如果为此网格设置了一个，则要使用的顶点映射中的第一个值的索引。
			 * @param count 绘制时要使用的顶点数，或者如果为此网格设置了一个，则要使用的顶点映射中的值的数量。
			 */
			setDrawRange(): void;
			setDrawRange(start: number, count: number): void;
			/**
			 * 获取绘制Mesh时使用的顶点范围。
			 *
			 * 重载说明：
			 * 1. 如果之前没有使用 Mesh:setDrawRange 设置网格体的绘制范围，则此函数将返回 nil。
			 *
			 * @returns min — 绘制时使用的第一个顶点的索引，或者如果为此网格设置了一个，则使用顶点映射中的第一个值的索引。
			 * @returns max — 绘制时使用的最后一个顶点的索引，或者如果为此网格设置了一个，则为使用的顶点映射中最后一个值的索引。
			 */
			getDrawRange(): LuaMultiReturn<[number, number]> | undefined;
			/**
			 * 立即将Mesh中所有修改的顶点数据发送到显卡。
			 *
			 * 通常不需要调用此方法，因为 love.graphics.draw(mesh, ...) 会在需要时自动执行此操作，但显式使用 **Mesh:flush** 可以更好地控制工作何时发生。
			 *
			 * 如果使用此方法，则通常不应在 love.graphics.draw(mesh, ...) 调用之间多次（最多）调用它。
			 */
			flush(): void;
		}
		/** Using a single image, draw any number of identical copies of the image using a single call to love.graphics.draw(). This can be used, for example, to draw repeating copies of a single background image with high performance.
		 */
		interface SpriteBatch extends Object {
			/**
			 * 将精灵添加到批次中。精灵按照添加的顺序绘制。
			 *
			 * 重载说明：
			 * 1. 将四边形添加到批次中。
			 *
			 * @param x 绘制对象的位置（x 轴）。
			 * @param y 绘制对象的位置（y 轴）。
			 * @param angle 方向（弧度）。 （默认值：0。）
			 * @param scaleX 比例因子（x 轴）。 （默认值：1。）
			 * @param scaleY 比例因子（y 轴）。 （默认值：sx。）
			 * @param originX 原点偏移（x 轴）。 （默认值：0。）
			 * @param originY 原点偏移（y 轴）。 （默认值：0。）
			 * @param shearX 剪切因子（x 轴）。 （默认值：0。）
			 * @param shearY 剪切因子（y 轴）。 （默认值：0。）
			 * @param quad 要添加的四边形。
			 *
			 * @returns id — 添加的精灵的标识符。
			 */
			add(x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			add(quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/**
			 * 更改批次中的精灵。这需要 SpriteBatch:add 或 SpriteBatch:addLayer 返回的精灵索引。
			 *
			 * 重载说明：
			 * 1. 批量更改带有四边形的精灵。这需要 SpriteBatch:add 或 SpriteBatch:addLayer 返回的索引。 SpriteBatches 不支持删除单个精灵。可以通过以下方式进行伪删除（而不是清除并重新添加所有内容）： SpriteBatch:set(id, 0, 0, 0, 0, 0) 这使得所有精灵的顶点相等（因为 x 和 y 比例为 0），这会阻止 GPU 在绘制 SpriteBatch 时完全处理精灵。
			 *
			 * @param index 将要更改的精灵的索引。
			 * @param x 绘制对象的位置（x 轴）。
			 * @param y 绘制对象的位置（y 轴）。
			 * @param angle 方向（弧度）。 （默认值：0。）
			 * @param scaleX 比例因子（x 轴）。 （默认值：1。）
			 * @param scaleY 比例因子（y 轴）。 （默认值：sx。）
			 * @param originX 原点偏移（x 轴）。 （默认值：0。）
			 * @param originY 原点偏移（y 轴）。 （默认值：0。）
			 * @param shearX 剪切因子（x 轴）。 （默认值：0。）
			 * @param shearY 剪切因子（y 轴）。 （默认值：0。）
			 * @param quad 批次图像上使用的 Quad。
			 */
			set(index: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			set(index: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			/**
			 * 将精灵添加到使用数组纹理创建的批次中。
			 *
			 * 重载说明：
			 * 1. 添加 SpriteBatch 的数组纹理层。
			 * 2. 使用指定的Quad添加SpriteBatch的数组纹理层。指定的图层索引会覆盖通过 Quad:setLayer 在 Quad 上设置的任何图层索引。
			 * 3. 使用指定的 Transform 添加 SpriteBatch 的数组纹理层。
			 * 4. 使用指定的 Quad 和 Transform 添加 SpriteBatch 的数组纹理层。为了在自定义 void effect() 变量中使用数组纹理或其他非 2D 纹理类型作为主纹理，必须在像素着色器中使用变体，并且必须将 MainTex 声明为 ArrayImage 或 sampler2DArray，如下所示：uniform ArrayImage MainTex;。
			 *
			 * @param layer 用于该精灵的图层索引。
			 * @param x 绘制精灵的位置（x 轴）。 （默认值：0。）
			 * @param y 绘制精灵的位置（y 轴）。 （默认值：0。）
			 * @param angle 方向（弧度）。 （默认值：0。）
			 * @param scaleX 比例因子（x 轴）。 （默认值：1。）
			 * @param scaleY 比例因子（y 轴）。 （默认值：sx。）
			 * @param originX 原点偏移（x 轴）。 （默认值：0。）
			 * @param originY 原点偏移（y 轴）。 （默认值：0。）
			 * @param shearX 剪切因子（x 轴）。 （默认值：0。）
			 * @param shearY 剪切因子（y 轴）。 （默认值：0。）
			 * @param quad 绘制精灵时使用的纹理层的分段。
			 *
			 * @returns spriteindex — 添加的精灵的索引，与 SpriteBatch:set 或 SpriteBatch:setLayer 一起使用。
			 */
			addLayer(layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			addLayer(layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): number;
			/**
			 * 在使用数组纹理创建的批处理中更改先前使用 add 或 addLayer 添加的精灵。
			 *
			 * 重载说明：
			 * 1. 更改 SpriteBatch 中的精灵。
			 * 2. 使用指定的Quad添加SpriteBatch的数组纹理层。指定的图层索引会覆盖通过 Quad:setLayer 在 Quad 上设置的任何图层索引。
			 * 3. 使用指定的 Transform 添加 SpriteBatch 的数组纹理层。
			 * 4. 使用指定的 Quad 和 Transform 添加 SpriteBatch 的数组纹理层。指定的图层索引会覆盖通过 Quad:setLayer 在 Quad 上设置的任何图层索引。
			 *
			 * @param index 要替换的现有精灵的索引。
			 * @param layer 用于此精灵的阵列纹理中的图层索引。取决于过载：用于此精灵的图层的索引。
			 * @param x 绘制精灵的位置（x 轴）。 （默认值：0。）
			 * @param y 绘制精灵的位置（y 轴）。 （默认值：0。）
			 * @param angle 方向（弧度）。 （默认值：0。）
			 * @param scaleX 比例因子（x 轴）。 （默认值：1。）
			 * @param scaleY 比例因子（y 轴）。 （默认值：sx。）
			 * @param originX 原点偏移（x 轴）。 （默认值：0。）
			 * @param originY 原点偏移（y 轴）。 （默认值：0。）
			 * @param shearX 剪切因子（x 轴）。 （默认值：0。）
			 * @param shearY 剪切因子（y 轴）。 （默认值：0。）
			 * @param quad 绘制精灵时使用的纹理层的分段。
			 */
			setLayer(index: number, layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			setLayer(index: number, layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
			/**
			 * 从缓冲区中删除所有精灵。
			 */
			clear(): void;
			/**
			 * 立即将批次中所有新的和修改的精灵数据发送到显卡。
			 *
			 * 通常不需要调用此方法，因为 love.graphics.draw(spritebatch, ...) 会在需要时自动执行此操作，但显式使用 SpriteBatch:flush 可以更好地控制工作何时发生。
			 *
			 * 如果使用此方法，则通常不应在 love.graphics.draw(spritebatch, ...) 调用之间多次（最多）调用它。
			 */
			flush(): void;
			/**
			 * 设置绘制时用于批处理中的精灵的纹理（图像或画布）。
			 *
			 * @param texture 用于批处理中的精灵的新图像或画布。
			 */
			setTexture(texture: Image | Canvas): void;
			/**
			 * 获取SpriteBatch使用的纹理（Image或Canvas）。
			 *
			 * @returns texture — SpriteBatch 使用的图像或画布。
			 */
			getTexture(): Image | Canvas;
			/**
			 * 设置将用于下一个添加和设置操作的颜色。调用不带参数的函数将禁用 SpriteBatch 的所有每个精灵颜色。
			 *
			 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
			 *
			 * 在版本 0.9.2 及更早版本中，如果任何精灵有自己的颜色，则使用 love.graphics.setColor 设置的全局颜色将无法在 SpriteBatch 上工作。
			 *
			 * 重载说明：
			 * 1. 禁用此 SpriteBatch 的所有每个精灵颜色。
			 *
			 * @param red 红色的量。
			 * @param green 绿色量。
			 * @param blue 蓝色的量。
			 * @param alpha 阿尔法的数量。 （默认值：1。）
			 * @param color 红色的量。
			 */
			setColor(): void;
			setColor(red: number, green: number, blue: number, alpha?: number): void;
			setColor(color: Color): void;
			/**
			 * 获取将用于下一个添加和设置操作的颜色。
			 *
			 * 如果没有使用 SpriteBatch:setColor 设置颜色或当前 SpriteBatch 颜色已被清除，则此方法将返回 nil。
			 *
			 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
			 *
			 * @returns r — 红色分量 (0-1)。
			 * @returns g — 绿色分量 (0-1)。
			 * @returns b — 蓝色分量 (0-1)。
			 * @returns a — alpha 分量 (0-1)。
			 */
			getColor(): LuaMultiReturn<[number, number, number, number]> | undefined;
			/**
			 * 获取SpriteBatch中当前精灵的数量。
			 *
			 * @returns count — 当前批次中的精灵数量。
			 */
			getCount(): number;
			/**
			 * 获取 SpriteBatch 可以容纳的最大精灵数。
			 *
			 * @returns size — 批次可以容纳的精灵的最大数量。
			 */
			getBufferSize(): number;
			/**
			 * 将网格中的每顶点属性附加到此 SpriteBatch 上，以供绘制时使用。它可以与 Shader 结合使用，以使用每个顶点或附加的每个精灵信息来增强 SpriteBatch，而不仅仅是每个精灵颜色。
			 *
			 * SpriteBatch 中的每个精灵都有 4 个顶点，按以下顺序排列：左上、左下、右上、右下。 SpriteBatch:add 返回的索引（并由 SpriteBatch:set 使用）可用于通过公式 1 + 4 * ( id - 1 ) 确定特定精灵的第一个顶点。
			 *
			 * 重载说明：
			 * 1. 如果使用自定义顶点格式创建，它将有 3 个顶点属性，名为 VertexPosition、VertexTexCoord 和 VertexColor。如果具有这些名称的顶点属性附加到 SpriteBatch，它将分别覆盖 SpriteBatch 的精灵位置、纹理坐标和精灵颜色。可以通过将自定义命名属性声明为属性 vec4 MyCustomAttributeName 在顶点着色器中访问它们；位于顶点着色器代码的顶层。该名称必须与网格体顶点格式和 SpriteBatch:attachAttribute 的名称参数中指定的名称相匹配。网格体必须至少有 4 * SpriteBatch:getBufferSize 顶点才能附加到 SpriteBatch。
			 *
			 * @param name 要附加的顶点属性的名称。
			 * @param mesh 要从中获取顶点属性的网格体。
			 */
			attachAttribute(name: string, mesh: Mesh): void;
			/**
			 * 将 SpriteBatch 中绘制的精灵限制为总数的子集。
			 *
			 * 重载说明：
			 * 1. 允许绘制SpriteBatch中的所有精灵。
			 *
			 * @param start 要绘制的第一个精灵的索引。索引 1 对应于添加了 SpriteBatch:add 的第一个精灵。
			 * @param count 要绘制的精灵数量。
			 */
			setDrawRange(): void;
			setDrawRange(start: number, count: number): void;
			getDrawRange(): LuaMultiReturn<[number, number]> | undefined;
		}
		/** A ParticleSystem can be used to create particle effects like fire or smoke.
		 */
		interface ParticleSystem extends Object {
			/**
			 * 创建处于停止状态的粒子系统的相同副本。
			 *
			 * 重载说明：
			 * 1. 克隆的粒子系统继承了原始粒子系统的所有可设置状态，但它们被初始化为停止状态。
			 *
			 * @returns particlesystem — 此粒子系统的新的相同副本。
			 */
			clone(): ParticleSystem;
			/**
			 * 设置用于粒子的纹理（图像或画布）。
			 *
			 * @param texture 用于粒子的图像或画布。
			 */
			setTexture(texture: Image | Canvas): void;
			/**
			 * 获取用于粒子的纹理（图像或画布）。
			 *
			 * @returns texture — 用于粒子的图像或画布。
			 */
			getTexture(): Image | Canvas;
			/**
			 * 设置缓冲区的大小（系统中允许的最大粒子量）。
			 *
			 * @param size 缓冲区大小。
			 */
			setBufferSize(size: number): void;
			/**
			 * 获取粒子系统一次可以拥有的最大粒子数。
			 *
			 * @returns size — 最大粒子数。
			 */
			getBufferSize(): number;
			/**
			 * 设置粒子系统添加新粒子时使用的模式。
			 *
			 * @param mode 粒子系统添加新粒子时使用的模式。
			 */
			setInsertMode(mode: ParticleInsertMode): void;
			/**
			 * 获取粒子系统添加新粒子时使用的模式。
			 *
			 * @returns mode — 粒子系统添加新粒子时使用的模式。
			 */
			getInsertMode(): ParticleInsertMode;
			/**
			 * 设置每秒发射的粒子数量。
			 *
			 * @param rate 每秒的粒子数。
			 */
			setEmissionRate(rate: number): void;
			/**
			 * 获取每秒发射的粒子数。
			 *
			 * @returns rate — 每秒的粒子数。
			 */
			getEmissionRate(): number;
			/**
			 * 设置粒子系统应发射粒子的时间长度（如果为 -1，则它将永远发射粒子）。
			 *
			 * @param lifetime 发射器的生命周期（以秒为单位）。
			 */
			setEmitterLifetime(lifetime: number): void;
			/**
			 * 获取粒子系统将发射粒子的时间（如果为-1则永远发射粒子）。
			 *
			 * @returns life — 发射器的生命周期（以秒为单位）。
			 */
			getEmitterLifetime(): number;
			/**
			 * 设置粒子的寿命。
			 *
			 * @param minimum 粒子的最短寿命（以秒为单位）。
			 * @param maximum 粒子的最大寿命（以秒为单位）。 （默认值：分钟。）
			 */
			setParticleLifetime(minimum: number, maximum?: number): void;
			/**
			 * 获取粒子的寿命。
			 *
			 * @returns min — 粒子的最短寿命（以秒为单位）。
			 * @returns max — 粒子的最大寿命（以秒为单位）。
			 */
			getParticleLifetime(): LuaMultiReturn<[number, number]>;
			/**
			 * 设置发射器的位置。
			 *
			 * @param x 沿 x 轴的位置。
			 * @param y 沿 y 轴的位置。
			 */
			setPosition(x: number, y: number): void;
			/**
			 * 获取发射器的位置。
			 *
			 * @returns x — 沿 x 轴的位置。
			 * @returns y — 沿 y 轴的位置。
			 */
			getPosition(): LuaMultiReturn<[number, number]>;
			/**
			 * 移动发射器的位置。与每帧使用 ParticleSystem:setPosition 相比，这会导致更平滑的粒子生成行为。
			 *
			 * @param x 沿 x 轴的位置。
			 * @param y 沿 y 轴的位置。
			 */
			moveTo(x: number, y: number): void;
			/**
			 * 设置粒子的基于区域的生成参数。新创建的粒子将根据此函数的参数在发射器周围的区域中生成。
			 *
			 * @param distribution 新粒子的分布类型。
			 * @param x 均匀分布时沿 x 轴距发射器的最大生成距离，或正态分布时沿 x 轴的标准偏差。
			 * @param y 均匀分布时沿 y 轴距发射器的最大生成距离，或正态分布时沿 y 轴的标准偏差。
			 * @param angle 发射区域的角度（以弧度表示）。 （默认值：0。）
			 * @param directionRelativeToCenter 如果新生成的粒子将相对于发射区域的中心定向，则为 true，否则为 false。 （默认值：假。）
			 */
			setEmissionArea(distribution?: ParticleAreaSpreadDistribution, x?: number, y?: number, angle?: number, directionRelativeToCenter?: boolean): void;
			/**
			 * 获取粒子基于区域的生成参数。
			 *
			 * @returns distribution — 新粒子的分布类型。
			 * @returns dx — 均匀分布时沿 x 轴距发射器的最大生成距离，或正态分布时沿 x 轴的标准偏差。
			 * @returns dy — 均匀分布时沿 y 轴距发射器的最大生成距离，或正态分布时沿 y 轴的标准偏差。
			 * @returns angle — 发射区域的角度（以弧度表示）。
			 * @returns directionRelativeToCenter — 如果新生成的粒子将相对于发射区域的中心定向，则为 true，否则为 false。
			 */
			getEmissionArea(): LuaMultiReturn<[ParticleAreaSpreadDistribution, number, number, number, boolean]>;
			/** @deprecated Use setEmissionArea. */
			setAreaSpread(distribution?: ParticleAreaSpreadDistribution, x?: number, y?: number): void;
			/** @deprecated Use getEmissionArea. */
			getAreaSpread(): LuaMultiReturn<[ParticleAreaSpreadDistribution, number, number]>;
			/**
			 * 设置粒子发射的方向。
			 *
			 * @param direction 粒子的方向（以弧度为单位）。
			 */
			setDirection(direction: number): void;
			/**
			 * 获取粒子发射器的方向（以弧度为单位）。
			 *
			 * @returns direction — 发射器的方向（弧度）。
			 */
			getDirection(): number;
			/**
			 * 设置系统的传播量。
			 *
			 * @param spread 传播量（弧度）。
			 */
			setSpread(spread: number): void;
			/**
			 * 获取粒子发射器的方向扩散量（以弧度为单位）。
			 *
			 * @returns spread — 发射器的扩散（弧度）。
			 */
			getSpread(): number;
			/**
			 * 设置粒子的速度。
			 *
			 * @param minimum 粒子的最小线速度。
			 * @param maximum 粒子的最大线速度。 （默认值：分钟。）
			 */
			setSpeed(minimum: number, maximum?: number): void;
			/**
			 * 获取粒子的速度。
			 *
			 * @returns min — 粒子的最小线速度。
			 * @returns max — 粒子的最大线速度。
			 */
			getSpeed(): LuaMultiReturn<[number, number]>;
			/**
			 * 设置粒子的线性加速度（沿x轴和y轴的加速度）。
			 *
			 * 创建的每个粒子都会沿着 x 轴和 y 轴在 xmin,ymin 和 xmax,ymax 之间加速。
			 *
			 * @param xMinimum 沿 x 轴的最小加速度。
			 * @param yMinimum 沿 y 轴的最小加速度。
			 * @param xMaximum 沿 x 轴的最大加速度。 （默认值：xmin。）
			 * @param yMaximum 沿 y 轴的最大加速度。 （默认值：ymin。）
			 */
			setLinearAcceleration(xMinimum: number, yMinimum: number, xMaximum?: number, yMaximum?: number): void;
			/**
			 * 获取粒子的线性加速度（沿x轴和y轴的加速度）。
			 *
			 * 创建的每个粒子都会沿着 x 轴和 y 轴在 xmin,ymin 和 xmax,ymax 之间加速。
			 *
			 * @returns xmin — 沿 x 轴的最小加速度。
			 * @returns ymin — 沿 y 轴的最小加速度。
			 * @returns xmax — 沿 x 轴的最大加速度。
			 * @returns ymax — 沿 y 轴的最大加速度。
			 */
			getLinearAcceleration(): LuaMultiReturn<[number, number, number, number]>;
			/**
			 * 设置径向加速度（远离发射器）。
			 *
			 * @param minimum 最小加速度。
			 * @param maximum 最大加速度。 （默认值：分钟。）
			 */
			setRadialAcceleration(minimum: number, maximum?: number): void;
			/**
			 * 获取径向加速度（远离发射器）。
			 *
			 * @returns min — 最小加速度。
			 * @returns max — 最大加速度。
			 */
			getRadialAcceleration(): LuaMultiReturn<[number, number]>;
			/**
			 * 设置切向加速度（垂直于粒子方向的加速度）。
			 *
			 * @param minimum 最小加速度。
			 * @param maximum 最大加速度。 （默认值：分钟。）
			 */
			setTangentialAcceleration(minimum: number, maximum?: number): void;
			/**
			 * 获取切向加速度（垂直于粒子方向的加速度）。
			 *
			 * @returns min — 最小加速度。
			 * @returns max — 最大加速度。
			 */
			getTangentialAcceleration(): LuaMultiReturn<[number, number]>;
			/**
			 * 设置粒子的线性阻尼（恒定减速度）量。
			 *
			 * @param minimum 应用于粒子的最小线性阻尼量。
			 * @param maximum 应用于粒子的最大线性阻尼量。 （默认值：分钟。）
			 */
			setLinearDamping(minimum: number, maximum?: number): void;
			/**
			 * 获取粒子的线性阻尼（恒定减速度）量。
			 *
			 * @returns min — 应用于粒子的最小线性阻尼量。
			 * @returns max — 应用于粒子的最大线性阻尼量。
			 */
			getLinearDamping(): LuaMultiReturn<[number, number]>;
			/**
			 * 设置一系列用于缩放粒子精灵的尺寸。 1.0是正常尺寸。粒子系统将在粒子的生命周期内均匀地在每个尺寸之间进行插值。
			 *
			 * 必须至少指定一种尺寸。最多可以使用八个。
			 *
			 * @param sizes 第一个尺寸。
			 */
			setSizes(...sizes: number[]): void;
			/**
			 * 获取精灵缩放的一系列尺寸。 1.0是正常尺寸。粒子系统将在粒子的生命周期内均匀地在每个尺寸之间进行插值。
			 *
			 * @returns size1 — 第一个尺寸。
			 * @returns size2 — 第二个尺寸。
			 * @returns size8 — 第八号。
			 */
			getSizes(): LuaMultiReturn<number[]>;
			/**
			 * 设置大小变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
			 *
			 * @param variation 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
			 */
			setSizeVariation(variation: number): void;
			/**
			 * 获取大小变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
			 *
			 * @returns variation — 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
			 */
			getSizeVariation(): number;
			/**
			 * 设置粒子创建时图像的旋转（以弧度为单位）。
			 *
			 * @param minimum 最小初始角度（弧度）。
			 * @param maximum 最大初始角度（弧度）。 （默认值：分钟。）
			 */
			setRotation(minimum: number, maximum?: number): void;
			/**
			 * 获取粒子创建时图像的旋转（以弧度为单位）。
			 *
			 * @returns min — 最小初始角度（弧度）。
			 * @returns max — 最大初始角度（弧度）。
			 */
			getRotation(): LuaMultiReturn<[number, number]>;
			/**
			 * 设置精灵的旋转。
			 *
			 * @param start 最小旋转（弧度每秒）。
			 * @param finish 最大旋转（弧度每秒）。 （默认值：分钟。）
			 */
			setSpin(start: number, finish?: number): void;
			/**
			 * 获取精灵的旋转。
			 *
			 * @returns min — 最小旋转（弧度每秒）。
			 * @returns max — 最大旋转（弧度每秒）。
			 * @returns variation — 变化程度（0 表示没有变化，1 表示开始和结束之间完全变化）。
			 */
			getSpin(): LuaMultiReturn<[number, number]>;
			/**
			 * 设置旋转变化量（0 表示无变化，1 表示开始和结束之间完全变化）。
			 *
			 * @param variation 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
			 */
			setSpinVariation(variation: number): void;
			/**
			 * 获取旋转变化量（0 表示无变化，1 表示开始和结束之间的完全变化）。
			 *
			 * @returns variation — 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
			 */
			getSpinVariation(): number;
			/**
			 * 设置粒子精灵旋转的偏移位置。
			 *
			 * 如果不使用此功能，粒子将绕其中心旋转。
			 *
			 * @param x 旋转偏移的x坐标。
			 * @param y 旋转偏移的 y 坐标。
			 */
			setOffset(x: number, y: number): void;
			/**
			 * 获取粒子图像的绘制偏移量。
			 *
			 * @returns ox — 粒子图像绘制偏移的x坐标。
			 * @returns oy — 粒子图像绘制偏移的 y 坐标。
			 */
			getOffset(): LuaMultiReturn<[number, number]>;
			/**
			 * 设置一系列应用于粒子精灵的颜色。粒子系统将在粒子的生命周期内均匀地在每种颜色之间进行插值。
			 *
			 * 参数可以以四个为一组传递，代表所需 RGBA 值的分量，或者作为 RGBA 分量值表，如果仅给出三个值，则默认 alpha 值为 1。必须至少指定一种颜色。最多可以使用八个。
			 *
			 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
			 *
			 * @param colors 第一种颜色，一个数字索引表，其中红色、绿色、蓝色和 alpha 值作为数字 (0-1)。 alpha 是可选的，如果省略则默认为 1。
			 */
			setColors(...colors: (Color | number)[]): void;
			/**
			 * 获取应用于粒子精灵的一系列颜色。
			 *
			 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
			 *
			 * @returns r1 — 第一种颜色，红色分量 (0-1)。
			 * @returns g1 — 第一种颜色，绿色分量 (0-1)。
			 * @returns b1 — 第一种颜色，蓝色分量 (0-1)。
			 * @returns a1 — 第一种颜色，alpha 分量 (0-1)。
			 * @returns r2 — 第二颜色，红色分量 (0-1)。
			 * @returns g2 — 第二颜色，绿色分量 (0-1)。
			 * @returns b2 — 第二颜色，蓝色分量 (0-1)。
			 * @returns a2 — 第二个颜色，alpha 分量 (0-1)。
			 * @returns r8 — 第八种颜色，红色分量 (0-1)。
			 * @returns g8 — 第八种颜色，绿色分量 (0-1)。
			 * @returns b8 — 第八种颜色，蓝色分量 (0-1)。
			 * @returns a8 — 第八种颜色，alpha 分量 (0-1)。
			 */
			getColors(): LuaMultiReturn<[number, number, number, number][]>;
			/**
			 * 设置一系列用于粒子精灵的四边形。粒子将根据粒子当前的生命周期从列表中选择一个四边形，从而允许将动画精灵表与粒子系统一起使用。
			 *
			 * @param quads 包含要使用的四边形的表。
			 */
			setQuads(...quads: (Quad | Quad[])[]): void;
			/**
			 * 获取用于粒子精灵的四边形系列。
			 *
			 * @returns quads — 包含所使用的四边形的表。
			 */
			getQuads(): Quad[];
			/**
			 * 设置粒子角度和旋转是否与其速度相关。如果启用，粒子将与其速度角度对齐并相对于该角度旋转。
			 *
			 * @param enabled true 则启用相对粒子旋转， false 则禁用它。
			 */
			setRelativeRotation(enabled: boolean): void;
			/**
			 * 获取粒子角度和旋转是否与其速度相关。如果启用，粒子将与其速度角度对齐并相对于该角度旋转。
			 *
			 * @returns enable — 如果启用相对粒子旋转则为 True，如果禁用则为 false。
			 */
			hasRelativeRotation(): boolean;
			/**
			 * 获取当前系统中的粒子数。
			 *
			 * @returns count — 当前活动粒子的数量。
			 */
			getCount(): number;
			/**
			 * 启动粒子发射器。
			 */
			start(): void;
			/**
			 * 停止粒子发射器，重置生命周期计数器。
			 */
			stop(): void;
			/**
			 * 暂停粒子发射器。
			 */
			pause(): void;
			/**
			 * 重置粒子发射器，删除任何现有粒子并重置生命周期计数器。
			 */
			reset(): void;
			/**
			 * 从粒子发射器中发射出一阵粒子。
			 *
			 * @param count 要发射的粒子数量。如果达到粒子系统的最大缓冲区大小，发射的粒子数量将被截断。
			 */
			emit(count: number): void;
			/**
			 * 检查粒子系统是否正在主动发射粒子。
			 *
			 * @returns active — 如果系统处于活动状态，则为 true，否则为 false。
			 */
			isActive(): boolean;
			/**
			 * 检查粒子系统是否暂停。
			 *
			 * @returns paused — 如果系统暂停则为 true，否则为 false。
			 */
			isPaused(): boolean;
			/**
			 * 检查粒子系统是否停止。
			 *
			 * @returns stopped — 如果系统停止则为 true，否则为 false。
			 */
			isStopped(): boolean;
			isEmpty(): boolean;
			isFull(): boolean;
			/**
			 * 更新粒子系统；移动、产生和杀死粒子。
			 *
			 * @param deltaTime 自上一帧以来的时间（秒）。
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
			 * 获取 Shader 中是否存在指定的 extern 变量。
			 *
			 * @deprecated 兼容 LÖVE 0.10 之前版本的接口，请改用 hasUniform。
			 */
			getExternVariable(name: string): boolean;
			/**
			 * 返回编译着色器代码时的任何警告和错误消息。如果图形硬件有任何不喜欢的地方，这可以用于调试着色器。
			 *
			 * @returns warnings — 警告和错误消息（如果有）。
			 */
			getWarnings(): string;
			/**
			 * 获取Shader中是否存在uniform / extern变量。
			 *
			 * 如果图形驱动程序的着色器编译器确定统一/外部变量不会影响着色器的最终输出，它可能会优化该变量。在这种情况下该函数将返回 false。
			 *
			 * @param name 统一变量的名称。
			 *
			 * @returns hasuniform — 着色器中是否存在uniform并影响其最终输出。
			 */
			hasUniform(name: string): boolean;
			/**
			 * 将一个或多个值发送到特殊的 (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' 关键字，例如
			 *
			 * 统一浮动时间； // 'float' 是 GLSL 着色器中使用的典型数字类型。
			 *
			 * 统一浮点varsvec2 light_pos；
			 *
			 * 统一vec4颜色[4;
			 *
			 * 相应的发送调用将是
			 *
			 * 着色器：发送('time', t)
			 *
			 * 着色器：发送('vars',a,b)
			 *
			 * 着色器：发送('light_pos', {light_x, light_y})
			 *
			 * 着色器：发送（'colors'，{r1，g1，b1，a1}，{r2，g2，b2，a2}，{r3，g3，b3，a3}，{r4，g4，b4，a4}）
			 *
			 * 统一/外部变量在着色器代码中是只读的，并保持不变，直到被 Shader:send 调用修改。统一变量可以在着色器的顶点和像素组件中访问，只要在每个组件中声明该变量即可。
			 *
			 * 重载说明：
			 * 1. 因为Lua中的所有数字都是浮点型，所以在0.10.2之前的版本中，您必须使用函数Shader:sendInt将值发送到着色器代码中的uniform int变量。
			 * 2. 将源自数据对象内容的统一值发送到着色器。这直接复制数据的字节。
			 * 3. 将来自数据对象内容的统一矩阵发送到着色器。这直接复制数据的字节。
			 *
			 * @param name 发送到着色器的数字名称。取决于重载：发送到着色器的向量的名称。取决于重载：发送到着色器的矩阵的名称。取决于重载：发送到着色器的纹理的名称。取决于重载：发送到着色器的布尔值的名称。取决于过载：发送到着色器的制服名称。取决于重载：发送到着色器的统一矩阵的名称。
			 * @param texture 纹理（图像或画布）发送到统一变量。
			 * @param textures 如果统一变量是数组，则要发送的附加数字。根据重载：如果统一变量是数组，则要发送其他向量。所有向量需要具有相同的大小（例如，只有 vec3's). Depending on the overload: Additional matrices of the same type as ''matrix'' 才能存储在统一数组中。取决于重载：如果统一变量是数组，则要发送其他布尔值。
			 * @param matrixLayout 矩阵的布局（行优先或列优先）。取决于过载：内存中矩阵的布局（行优先或列优先）。
			 * @param matrices 如果统一变量是数组，则要发送的附加数字。根据重载：如果统一变量是数组，则要发送其他向量。所有向量需要具有相同的大小（例如，只有 vec3's). Depending on the overload: Additional matrices of the same type as ''matrix'' 才能存储在统一数组中。取决于重载：如果统一变量是数组，则要发送其他布尔值。
			 * @param data 包含要发送的值的数据对象。
			 * @param offset 从数据对象开始处的偏移量（以字节为单位）。 （默认值：0。）
			 * @param size 要发送的数据的大小（以字节为单位）。如果为零，则将复制与指定的统一用途一样多的字节。 （默认值：全部。）
			 * @param values 纹理（图像或画布）发送到统一变量。
			 */
			send(name: string, texture: Image | Canvas, ...textures: (Image | Canvas)[]): void;
			send(name: string, matrixLayout: MatrixLayout, ...matrices: (number[] | number[][])[]): void;
			send(name: string, data: Data, offset?: number, size?: number): void;
			send(name: string, matrixLayout: MatrixLayout, data: Data, offset?: number, size?: number): void;
			send(name: string, data: Data, matrixLayout: MatrixLayout, offset?: number, size?: number): void;
			send(name: string, ...values: ShaderValue[]): void;
			/**
			 * 将一种或多种颜色发送到着色器内的特殊 (''extern'' / ''uniform'') vec3 或 vec4 变量。颜色分量必须在 1 的范围内。如果启用全局伽玛校正，则对颜色进行伽玛校正。
			 *
			 * 外部变量必须使用“'extern'”关键字进行标记，例如
			 *
			 * 外部 vec4 颜色；
			 *
			 * 相应的 sendColor 调用将是
			 *
			 * 着色器:sendColor('Color', {r, g, b, a})
			 *
			 * 外部变量可以在着色器的顶点和像素阶段访问，只要在每个阶段声明该变量即可。
			 *
			 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
			 *
			 * @param name 要在着色器中发送到的颜色外部变量的名称。
			 * @param data 一个表，其中包含红色、绿色、蓝色和 1 范围内的可选 alpha 颜色分量，以向量形式发送到外部。
			 * @param offset 当 extern 是数组时要发送的附加颜色。所有颜色都必须具有相同的大小（例如仅 vec3）。
			 * @param values 一个表，其中包含红色、绿色、蓝色和 1 范围内的可选 alpha 颜色分量，以向量形式发送到外部。
			 */
			sendColor(name: string, data: Data, offset?: number, size?: number): void;
			sendColor(name: string, ...values: ShaderValue[]): void;
		}

	/** @noSelf */
	/** The primary responsibility for the love.graphics module is the drawing of lines, shapes, text, Images and other Drawable objects onto the screen. Its secondary responsibilities include loading external files (including Images and Fonts) into memory, creating specialized objects (such as ParticleSystems or Canvases) and managing screen geometry.
	 */
	interface Graphics {
		/**
		 * 将屏幕或活动画布清除为指定颜色。
		 *
		 * 在默认的 love.run 函数中，该函数在 love.draw 之前自动调用。有关此函数的典型用法，请参阅 love.run 中的示例。
		 *
		 * 请注意，剪刀区域限制了清除区域。
		 *
		 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
		 *
		 * 在背景颜色之前的版本中。
		 *
		 * 重载说明：
		 * 1. 在 0.9.2 及更早版本中将屏幕清除为背景颜色，或在 LÖVE 0.10.0 及更高版本中将屏幕清除为透明黑色 (0, 0, 0, 0)。
		 * 2. 将屏幕或活动画布清除为指定颜色。
		 * 3. 如果多个画布通过 love.graphics.setCanvas. 同时处于活动状态，则将多个活动画布清除为不同的颜色。使用此函数变体时，必须为每个活动画布指定颜色。
		 * 4. 清除模板或深度缓冲区，而不必也清除彩色画布。
		 *
		 * @param red {r, g, b, a} 形式的表格，包含要清除第一个活动画布的颜色。
		 * @param green 每个活动画布的附加表。
		 * @param blue 是否清除活动模板缓冲区（如果存在）。它也可以是 0 到 255 之间的整数，用于将模板缓冲区清除为特定值。 （默认值：true。）
		 * @param alpha 是否清除活动深度缓冲区（如果存在）。它也可以是 0 到 1 之间的数字，用于将深度缓冲区清除为特定值。 （默认值：true。）
		 */
		clear(this: void, red?: number, green?: number, blue?: number, alpha?: number): void;
		/**
		 * 丢弃（垃圾）屏幕或活动画布的内容。这是一个具有利基用例的性能优化功能。
		 *
		 * 如果活动画布刚刚更改，并且 'replace' BlendMode 将用于绘制覆盖整个屏幕的内容，则调用 love.graphics.discard 而不是调用 love.graphics.clear 或不执行任何操作可能会提高移动设备上的性能。
		 *
		 * 在某些桌面系统上，此功能可能不执行任何操作。
		 *
		 * @param discardColor 是否丢弃活动画布的纹理（如果没有活动画布，则丢弃屏幕内容。）（默认值：true。）
		 * @param discardDepthStencil 是否丢弃屏幕/活动Canvas的模板缓冲区的内容。 （默认值：true。）
		 */
		discard(this: void, discardColor?: boolean | boolean[], discardDepthStencil?: boolean): void;
		/**
		 * 立即渲染任何挂起的自动批量绘制。
		 *
		 * LÖVE 在大多数状态发生变化时会根据需要在内部调用此函数，因此无需手动调用它。
		 *
		 * 当前批次将由 love.graphics 状态更改（变换堆栈和当前颜色除外）以及 Shader:send 和纹理上更改其状态的方法自动刷新。在连续的 love.graphics.draw 调用中使用不同的图像也会刷新当前批次。
		 *
		 * SpriteBatches、ParticleSystems、Meshes 和 Text 对象执行自己的批处理，除了在绘制时刷新当前批处理之外，不会影响其他绘制的自动批处理。
		 */
		flushBatch(this: void): void;
		/**
		 * 设置背景颜色。
		 *
		 * @param red 红色分量 (0-1)。
		 * @param green 绿色分量 (0-1)。
		 * @param blue 蓝色分量 (0-1)。
		 * @param alpha alpha 分量 (0-1)。 （默认值：1。）
		 * @param color 数字索引表，其中红色、绿色、蓝色和 alpha 值作为数字。 alpha 是可选的，如果省略则默认为 1。
		 */
		setBackgroundColor(this: void, red: number, green: number, blue: number, alpha?: number): void;
		setBackgroundColor(this: void, color: Color): void;
		/**
		 * 获取当前背景颜色。
		 *
		 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
		 *
		 * @returns r — 红色分量 (0-1)。
		 * @returns g — 绿色分量 (0-1)。
		 * @returns b — 蓝色分量 (0-1)。
		 * @returns a — alpha 分量 (0-1)。
		 */
		getBackgroundColor(this: void): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 设置与图像、画布和字体一起使用的默认缩放过滤器。
		 *
		 * 重载说明：
		 * 1. 此功能不适用于已加载的图像。
		 *
		 * @param min 缩小图像时使用的滤镜模式。
		 * @param mag 放大图像时使用的滤镜模式。 （默认值：分钟。）
		 * @param anisotropy 使用的各向异性过滤的最大数量。 （默认值：1。）
		 */
		setDefaultFilter(this: void, min: FilterMode, mag?: FilterMode, anisotropy?: number): void;
		/**
		 * 返回与图像、画布和字体一起使用的默认缩放过滤器。
		 *
		 * @returns min — 缩小图像时使用的滤镜模式。
		 * @returns mag — 放大图像时使用的滤镜模式。
		 * @returns anisotropy — 使用的各向异性过滤的最大数量。
		 */
		getDefaultFilter(this: void): LuaMultiReturn<[FilterMode, FilterMode, number]>;
		setDefaultMipmapFilter(this: void, filter?: FilterMode, sharpness?: number): void;
		getDefaultMipmapFilter(this: void): LuaMultiReturn<[FilterMode | undefined, number]>;
		/**
		 * 设置用于绘图的颜色。
		 *
		 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
		 *
		 * @param red 红色的量。
		 * @param green 绿色量。
		 * @param blue 蓝色的量。
		 * @param alpha Alpha 量。 alpha 值将应用于所有后续的绘制操作，甚至是图像的绘制。 （默认值：1。）
		 */
		setColor(this: void, red: number, green: number, blue: number, alpha?: number): void;
		/**
		 * 获取当前颜色。
		 *
		 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
		 *
		 * @returns r — 红色分量 (0-1)。
		 * @returns g — 绿色分量 (0-1)。
		 * @returns b — 蓝色分量 (0-1)。
		 * @returns a — alpha 分量 (0-1)。
		 */
		getColor(this: void): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 设置线宽。
		 *
		 * @param width 线的宽度。
		 */
		setLineWidth(this: void, width: number): void;
		/**
		 * 获取当前线宽。
		 *
		 * 重载说明：
		 * 1. 该功能在0.8.0中不起作用，但在0.9.0版本中已修复。在 0.8.0 中使用以下代码片段来规避此问题； love.graphics._getLineWidth = love.graphics.getLineWidth love.graphics._setLineWidth = love.graphics.setLineWidth 函数 love.graphics.getLineWidth() 返回 love.graphics.varlinewidth 或 1 结束函数 love.graphics.setLineWidth(w) love.graphics.varlinewidth = w;返回 love.graphics._setLineWidth(w) 结束
		 *
		 * @returns width — 当前线宽。
		 */
		getLineWidth(this: void): number;
		/**
		 * 设置线条样式。
		 *
		 * @param style 要使用的线条样式。线条样式包括平滑和粗糙。
		 */
		setLineStyle(this: void, style: LineStyle): void;
		/**
		 * 获取线条样式。
		 *
		 * @returns style — 当前的线条样式。
		 */
		getLineStyle(this: void): LineStyle;
		/**
		 * 设置线连接样式。请参阅 LineJoin 了解可能的选项。
		 *
		 * @param join 要使用的 LineJoin。
		 */
		setLineJoin(this: void, join: LineJoin): void;
		/**
		 * 获取线连接样式。
		 *
		 * @returns join — LineJoin 风格。
		 */
		getLineJoin(this: void): LineJoin;
		/**
		 * 设置绘图时是否使用线框线。
		 *
		 * @param enable 如果为 True，则在绘制时启用线框模式；如果为 false，则禁用它。
		 */
		setWireframe(this: void, enable: boolean): void;
		/**
		 * 获取绘制时是否使用线框模式。
		 *
		 * @returns wireframe — 如果绘制时使用线框线则为 True，否则为 false。
		 */
		isWireframe(this: void): boolean;
		/**
		 * 设置磅值。
		 *
		 * @param size 新的磅值。
		 */
		setPointSize(this: void, size: number): void;
		/**
		 * 获取磅值。
		 *
		 * @returns size — 当前磅值。
		 */
		getPointSize(this: void): number;
		/**
		 * 获取窗口的宽度和高度（以像素为单位）。
		 *
		 * @returns width — 窗口的宽度。
		 * @returns height — 窗口的高度。
		 */
		getDimensions(this: void): LuaMultiReturn<[number, number]>;
		/**
		 * 获取窗口的宽度（以像素为单位）。
		 *
		 * @returns width — 窗口的宽度。
		 */
		getWidth(this: void): number;
		/**
		 * 获取窗口的高度（以像素为单位）。
		 *
		 * @returns height — 窗口的高度。
		 */
		getHeight(this: void): number;
		/**
		 * 获取窗口的宽度和高度（以像素为单位）。
		 *
		 * love.graphics.getDimensions 获取窗口的尺寸，单位是按屏幕 DPI 比例因子缩放的单位，而不是像素。使用 getDimensions 进行与绘制到屏幕和使用图形坐标系相关的计算（例如，计算屏幕中心），并且仅在专门处理底层像素时使用 getPixelDimensions（例如，像素着色器中与像素相关的计算）。
		 *
		 * @returns pixelwidth — 窗口的宽度（以像素为单位）。
		 * @returns pixelheight — 窗口的高度（以像素为单位）。
		 */
		getPixelDimensions(this: void): LuaMultiReturn<[number, number]>;
		/**
		 * 获取窗口的宽度（以像素为单位）。
		 *
		 * 图形坐标系和DPI比例因子，而不是原始像素。使用 getWidth 进行与绘制到屏幕和使用坐标系相关的计算（例如，计算屏幕中心），并且仅在专门处理底层像素时使用 getPixelWidth（例如，像素着色器中与像素相关的计算）。
		 *
		 * @returns pixelwidth — 窗口的宽度（以像素为单位）。
		 */
		getPixelWidth(this: void): number;
		/**
		 * 获取窗口的高度（以像素为单位）。
		 *
		 * 图形坐标系和DPI比例因子，而不是原始像素。使用 getHeight 进行与绘制到屏幕和使用坐标系相关的计算（例如，计算屏幕中心），并且仅在专门处理底层像素时使用 getPixelHeight（例如，像素着色器中与像素相关的计算）。
		 *
		 * @returns pixelheight — 窗口的高度（以像素为单位）。
		 */
		getPixelHeight(this: void): number;
		/**
		 * 获取窗口的DPI比例因子。
		 *
		 * DPI 比例因子表示相对像素密度。窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用 1600x1200 像素。在这种情况下，love.graphics.getDPIScale() 将返回 2。
		 *
		 * love.window.fromPixels 和 love.window.toPixels 函数也可用于单位之间的转换。
		 *
		 * 必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android 上它实际上始终处于启用状态。
		 *
		 * 重载说明：
		 * 1. love.graphics.getWidth、love.graphics.getHeight、love.mouse.getPosition、鼠标事件、love.touch.getPosition 和触摸事件的单位始终采用 DPI 缩放单位而不是像素。在 LÖVE 0.10 及更早版本中，它们以像素为单位。
		 *
		 * @returns scale — 与窗口关联的像素比例因子。
		 */
		getDPIScale(this: void): number;
		/**
		 * 获取可选的图形功能以及系统是否支持它们。
		 *
		 * 一些较旧或低端的系统并不总是支持所有图形功能。
		 *
		 * @returns features — 包含 GraphicsFeature 键和指示是否支持每个功能的布尔值的表。
		 */
		getSupported(this: void, target?: any): GraphicsFeatures;
		/**
		 * 获取可用的纹理类型，以及是否支持每种纹理类型。
		 *
		 * @returns texturetypes — 包含TextureTypes作为键的表，以及一个指示是否支持该类型作为值的布尔值。并非所有系统都支持所有类型。
		 */
		getTextureTypes(this: void, target?: any): TextureTypes;
		/**
		 * 获取可用于图像的原始和压缩像素格式，以及是否支持每种格式。
		 *
		 * @returns formats — 包含 PixelFormats 作为键的表，以及一个指示是否支持该格式作为值的布尔值。并非所有系统都支持所有格式。
		 */
		getImageFormats(this: void, target?: any): ImageFormats;
		/**
		 * 获取有关系统显卡和驱动程序的信息。
		 *
		 * @returns name — 渲染器的名称，例如'OpenGL' 或 'OpenGL ES'。
		 * @returns version — 渲染器的版本，带有一些额外的依赖于驱动程序的版本信息，例如'2.1 INTEL-8.10.44'。
		 * @returns vendor — 显卡供应商的名称，例如'Intel Inc'。
		 * @returns device — 显卡的名称，例如'Intel HD Graphics 3000 OpenGL Engine'。
		 */
		getRendererInfo(this: void): LuaMultiReturn<[string, string, string, string]>;
		/**
		 * 获取 love.graphics 功能的系统相关最大值。
		 *
		 * @returns limits — 包含 GraphicsLimit 键和数值的表。
		 */
		getSystemLimits(this: void, target?: any): GraphicsSystemLimits;
		/**
		 * 获取与性能相关的渲染统计信息。
		 *
		 * 重载说明：
		 * 1. 此变体接受要填充的现有表，而不是创建新表。
		 *
		 * @param target 将用下面的统计字段填充的表格。
		 *
		 * @returns stats — 包含以下字段的表：取决于重载：上面传入的表，现在包含以下字段：
		 * @returns stats.drawcalls — 当前帧期间迄今为止进行的绘制调用的数量。
		 * @returns stats.canvasswitches — 当前帧期间活动画布迄今为止已切换的次数。
		 * @returns stats.texturememory — 所有加载的图像、画布和字体使用的视频内存的估计总大小（以字节为单位）。
		 * @returns stats.images — 当前加载的 Image 对象的数量。
		 * @returns stats.canvases — 当前加载的 Canvas 对象的数量。
		 * @returns stats.fonts — 当前加载的 Font 对象的数量。
		 * @returns stats.shaderswitches — 当前帧期间活动着色器迄今为止已更改的次数。
		 * @returns stats.drawcallsbatched — 自帧开始以来由 LÖVE 自动批处理保存的绘制调用数。
		 */
		getStats(this: void, target?: any): GraphicsStats;
		/**
		 * 当前帧完成后（love.draw 完成后）创建屏幕截图。
		 *
		 * 由于此函数将屏幕截图放入队列而不是立即执行它，因此可以从输入回调或 love.update 调用它，并且它仍然会捕获该帧中绘制到屏幕上的所有内容。
		 *
		 * 重载说明：
		 * 1. 捕获屏幕截图并将其保存到当前帧末尾的文件中。
		 * 2. 捕获屏幕截图并在当前帧末尾使用生成的 ImageData 调用回调。
		 * 3. 捕获屏幕截图并将生成的ImageData推送到当前帧末尾的Channel。
		 *
		 * @param filename 保存屏幕截图的文件名。编码图像类型根据文件名的扩展名确定，并且必须是 ImageFormat 之一。
		 * @param callback 捕获屏幕截图后调用的函数。 ImageData 作为唯一参数传递到函数中。
		 * @param channel 将生成的 ImageData 推送到的 Channel。
		 */
		captureScreenshot(this: void, filename: string): void;
		captureScreenshot(this: void, callback: (imageData: ImageData) => void): void;
		captureScreenshot(this: void, channel: Channel): void;
		/**
		 * 绘制一个矩形。
		 *
		 * 重载说明：
		 * 1. 绘制一个圆角矩形。
		 *
		 * @param mode 如何绘制矩形。
		 * @param x 左上角沿x轴的位置。
		 * @param y 左上角沿 y 轴的位置。
		 * @param width 矩形的宽度。
		 * @param height 矩形的高度。
		 */
		rectangle(this: void, mode: DrawMode, x: number, y: number, width: number, height: number): void;
		/**
		 * 画一个圆。
		 *
		 * @param mode 如何画圆。
		 * @param x 中心沿 x 轴的位置。
		 * @param y 中心沿 y 轴的位置。
		 * @param radius 圆的半径。
		 */
		circle(this: void, mode: DrawMode, x: number, y: number, radius: number): void;
		/**
		 * 在位置 (x, y) 处绘制填充或未填充的圆弧。弧线以弧度为单位从角度 1 到角度 2 绘制。段参数确定使用多少段来绘制圆弧。分段越多，边缘越平滑。
		 *
		 * 重载说明：
		 * 1. 使用 'pie' ArcType 绘制圆弧。
		 *
		 * @param mode 如何绘制圆弧。
		 * @param x 中心沿 x 轴的位置。
		 * @param y 中心沿 y 轴的位置。
		 * @param radius 圆弧半径。
		 * @param angle1 圆弧开始的角度。
		 * @param angle2 圆弧终止的角度。
		 * @param segments 用于绘制圆弧的段数。 （默认值：10。）
		 * @param arcMode 要绘制的圆弧类型。
		 */
		arc(this: void, mode: DrawMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: number): void;
		arc(this: void, mode: DrawMode, arcMode: ArcMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: number): void;
		/**
		 * 绘制一个椭圆。
		 *
		 * @param mode 如何绘制椭圆。
		 * @param x 中心沿 x 轴的位置。
		 * @param y 中心沿 y 轴的位置。
		 * @param radiusX 椭圆沿 x 轴的半径（椭圆宽度的一半）。
		 * @param radiusY 椭圆沿 y 轴的半径（椭圆高度的一半）。
		 * @param segments 用于绘制椭圆的线段数。
		 */
		ellipse(this: void, mode: DrawMode, x: number, y: number, radiusX: number, radiusY: number, segments?: number): void;
		/**
		 * 在点之间绘制线。
		 *
		 * @param x1 x 轴上第一个点的位置。
		 * @param y1 y 轴上第一个点的位置。
		 * @param x2 x 轴上第二个点的位置。
		 * @param y2 y 轴上第二个点的位置。
		 * @param coordinates 您可以继续通过点位置来绘制折线。
		 */
		line(this: void, x1: number, y1: number, x2: number, y2: number, ...coordinates: number[]): void;
		/**
		 * 画一个多边形。
		 *
		 * 在模式参数之后，该函数可以接受多个数字参数或单个数字参数表。无论哪种情况，参数都被解释为多边形顶点的交替 x 和 y 坐标。
		 *
		 * @param mode 如何绘制多边形。
		 * @param x1 多边形的顶点。取决于重载：将多边形的顶点作为表格。
		 */
		polygon(this: void, mode: DrawMode, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, ...coordinates: number[]): void;
		/**
		 * 绘制一个或多个点。
		 *
		 * 重载说明：
		 * 1. 绘制一个或多个单独着色的点。在 11.0 之前的版本中，颜色分量值的范围是 0 到 255，而不是 0 到 1。像素网格实际上偏移到每个像素的中心。因此，要获得干净的像素绘制，请使用 0.5 + 整数增量。点不受大小影响，始终以像素为单位。
		 *
		 * @param x1 x 轴上第一个点的位置。
		 * @param y1 y 轴上第一个点的位置。
		 * @param coordinates 附加点的 x 和 y 坐标。
		 */
		points(this: void, x1: number, y1: number, ...coordinates: number[]): void;
		/**
		 * 在屏幕上显示绘图操作的结果。
		 *
		 * 在编写自己的 love.run 函数时使用该函数。它在屏幕上显示绘图操作的所有结果。有关此函数的典型用法，请参阅 love.run 中的示例。
		 *
		 * 重载说明：
		 * 1. * 如果 love.window.setMode 的 vsync 等于 true，则该函数的运行频率不能高于刷新率（例如 60 Hz），并且将暂停程序直到准备就绪（如有必要）。
		 */
		present(this: void): void;
		/**
		 * 复制当前坐标变换并将其推入变换堆栈。
		 *
		 * 这个函数总是用来为后面相应的出栈操作做准备。它将当前坐标变换状态存储到变换堆栈中并保持其活动状态。稍后对变换所做的更改可以通过使用 pop 操作来撤消，该操作会将坐标变换返回到调用 push 之前的状态。
		 *
		 * 重载说明：
		 * 1. 将当前转换推入转换堆栈。
		 * 2. 将特定类型的状态推送到堆栈。
		 *
		 * @param stackType 要推送的堆栈类型（例如，仅转换状态，或所有 love.graphics 状态）。
		 */
		push(this: void, stackType?: "transform" | "all"): void;
		/**
		 * 从变换堆栈中弹出当前坐标变换。
		 *
		 * 该函数始终用于反转先前的推送操作。它将当前转换状态返回到上次推送之前的状态。
		 */
		pop(this: void): void;
		/**
		 * 获取变换/状态堆栈的当前深度（没有相应弹出的压入次数）。
		 *
		 * @returns depth — 变换和状态 love.graphics 堆栈的当前深度。
		 */
		getStackDepth(this: void): number;
		/**
		 * 重置当前坐标变换。
		 *
		 * 此函数始终用于反转任何先前对 love.graphics.rotate、love.graphics.scale、love.graphics.shear 或 love.graphics.translate. 的调用，它将当前转换状态返回为其默认值。
		 */
		origin(this: void): void;
		/**
		 * 将坐标系转换为二维。
		 *
		 * 当使用两个数字 dx 和 dy 调用此函数时，以下所有绘图操作都会生效，就好像它们的 x 和 y 坐标为 x+dx 和 y+dy 一样。
		 *
		 * 缩放和平移不是可交换操作，因此，以不同的顺序调用它们将改变结果。
		 *
		 * 此更改将持续到 love.draw() 退出，否则 love.graphics.pop 恢复为之前的 love.graphics.push.
		 *
		 * 使用整数进行翻译将防止翻译后绘制的图像和字体出现撕裂/模糊。
		 *
		 * @param dx 相对于 x 轴的平移。
		 * @param dy 相对于 y 轴的平移。
		 */
		translate(this: void, dx: number, dy: number): void;
		/**
		 * 二维旋转坐标系。
		 *
		 * 调用此函数会通过将坐标系围绕原点旋转给定的弧度来影响所有将来的绘图操作。此更改将持续到 love.draw() 退出为止。
		 *
		 * @param angle 坐标系的旋转量（以弧度为单位）。
		 */
		rotate(this: void, angle: number): void;
		/**
		 * 在二维中缩放坐标系。
		 *
		 * LÖVE中的坐标系默认与水平和垂直方向的显示像素一一对应，x轴向右增大，y轴向下增大。缩放坐标系会改变这种关系。
		 *
		 * 经过 sx 和 sy 缩放后，所有坐标都被视为乘以 sx 和 sy。绘图操作的每个结果也会相应地缩放，因此例如缩放 (2, 2) 意味着将所有内容在 x 和 y 方向上放大两倍。按负值缩放会沿相应方向翻转坐标系，这也意味着所有内容都将被翻转或颠倒或两者都绘制。按零缩放并不是一个有用的操作。
		 *
		 * 缩放和平移不是可交换操作，因此，以不同的顺序调用它们将改变结果。
		 *
		 * 缩放持续到 love.draw() 退出。
		 *
		 * @param sx x轴方向的缩放。
		 * @param sy y轴方向的缩放。如果省略，则默认与参数 sx 相同。 （默认值：sx。）
		 */
		scale(this: void, sx: number, sy?: number): void;
		/**
		 * 剪切坐标系。
		 *
		 * @param kx x 轴上的剪切因子。
		 * @param ky y 轴上的剪切因子。
		 */
		shear(this: void, kx: number, ky: number): void;
		/**
		 * 将给定的 Transform 对象应用于当前坐标变换。
		 *
		 * 这有效地将现有坐标变换的矩阵与 Transform 对象的内部矩阵相乘以产生新的坐标变换。
		 *
		 * @param transform 应用于当前图形坐标变换的 Transform 对象。
		 */
		applyTransform(this: void, transform: Transform): void;
		/**
		 * 用给定的 Transform 对象替换当前的坐标变换。
		 *
		 * @param transform 用于替换当前图形坐标变换的 Transform 对象。
		 */
		replaceTransform(this: void, transform: Transform): void;
		/**
		 * 将给定的 2D 位置从全局坐标转换为屏幕空间。
		 *
		 * 这有效地将当前图形变换应用于给定位置。 Transform 对象也存在类似的 Transform:transformPoint 方法。
		 *
		 * @param x 全局坐标中位置的 x 分量。
		 * @param y 全局坐标中位置的 y 分量。
		 *
		 * @returns screenX — 应用了图形变换的位置的 x 分量。
		 * @returns screenY — 应用了图形变换的位置的 y 分量。
		 */
		transformPoint(this: void, x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * 将给定的 2D 位置从屏幕空间转换为全局坐标。
		 *
		 * 这有效地将当前图形变换的反向应用到给定位置。 Transform 对象也存在类似的 Transform:inverseTransformPoint 方法。
		 *
		 * @param x 屏幕空间位置的 x 分量。
		 * @param y 屏幕空间位置的 y 分量。
		 *
		 * @returns globalX — 全局坐标中位置的 x 分量。
		 * @returns globalY — 全局坐标中位置的 y 分量。
		 */
		inverseTransformPoint(this: void, x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * 获取图形模块是否可以使用。如果未激活，love.graphics 函数和方法调用将无法正常工作，并可能导致程序崩溃。
		 * 如果窗口未打开，或者应用程序在 iOS 上处于后台，则图形模块处于非活动状态。通常，在后一种情况下，应用程序的执行将被系统自动暂停。
		 *
		 * @returns active — 图形模块是否处于活动状态并且可以使用。
		 */
		isActive(this: void): boolean;
		isCreated(this: void): boolean;
		/**
		 * 获取是否支持并启用伽玛校正渲染。可以通过在 love.conf 中设置 t.gammacorrect = true 来启用。
		 *
		 * 并非所有设备都支持伽玛校正渲染，在这种情况下它将自动禁用，并且此函数将返回 false。它在具有能够使用 OpenGL 3 / DirectX 10 的显卡的桌面系统以及可以使用 OpenGL ES 3 的 iOS 设备上受支持。
		 *
		 * 重载说明：
		 * 1. 启用伽玛校正渲染时，许多函数和对象会在 sRGB 和线性 RGB 之间执行自动颜色转换，以便混合和着色器数学在数学上正确（如果未启用，则不会。） * 传递的颜色从 sRGB 转换为线性 RGB。 * 当绘制这些对象时，文本中设置的每个字符颜色、每个点颜色的点、使用 'VertexColor' 属性名称的标准自定义网格将自动从 sRGB 转换为线性 RGB。 * 创建图像。 * 绘制到屏幕上的所有内容都将以线性 RGB 混合，然后结果将转换为 sRGB 进行显示。 * 使用 'normal' 或 'srgb' CanvasFormat 的画布将其内容以线性 RGB 混合，并且在绘制时结果将以 sRGB 形式存储在画布中。当画布本身被绘制时，其像素颜色将以与图像相同的方式从 sRGB 转换为线性 RGB。与 'rgba8' 相比，将画布像素数据存储为 sRGB 可以为较暗的颜色提供更好的精度（更少的条带）。由于大多数转换都是自动处理的，因此在启用伽马校正渲染时，您自己的代码无需担心 sRGB 和线性 RGB 颜色转换，但以下几种情况除外： * 如果使用具有自定义顶点属性的网格，并且其中一个属性旨在用作着色器中的颜色，并且该属性未命名为 'VertexColor'。 * 如果使用的着色器具有统一/外部变量或其他用作颜色的变量，则不使用 Shader:sendColor 。在这两种情况下，love.math.gammaToLinear 可用于在 Lua 代码中将颜色值转换为线性 RGB，或者可在着色器代码内部使用 gammaCorrectColor（或 unGammaCorrectColor，如果需要）着色器函数。如果确实启用了伽玛校正渲染，则这些着色器函数“'only'”会进行转换。如果是这样，将设置 LOVE_GAMMA_CORRECT 着色器预处理器定义。在此处、此处和此处阅读有关伽玛校正渲染的更多信息。
		 *
		 * @returns gammacorrect — 如果支持伽玛校正渲染并在 love.conf 中启用，则为 true，否则为 false。
		 */
		isGammaCorrect(this: void): boolean;
		/**
		 * 重置当前图形设置。
		 *
		 * 调用reset使当前绘图颜色为白色，当前背景颜色为黑色，禁用任何活动的颜色组件蒙版，禁用线框模式并将当前图形变换重置为原点。它还将点和线绘制模式设置为平滑，并将它们的大小设置为 1.0。
		 */
		reset(this: void): void;
		/**
		 * 设置混合模式。
		 *
		 * 重载说明：
		 * 1. 默认的 'alphamultiply' alpha 模式通常应该是首选，除非使用预乘 alpha 绘制内容。如果使用 'alphamultiply' 模式将内容绘制到 Canvas，则 Canvas 纹理随后将具有预乘 alpha，因此在将 Canvas 绘制到屏幕时通常应使用 'premultiplied' alpha 模式。
		 *
		 * @param mode 要使用的混合模式。
		 * @param alphaMode 混合时如何处理绘制对象的 Alpha。 （默认：'alphamultiply'。）
		 */
		setBlendMode(this: void, mode: BlendMode, alphaMode?: BlendAlphaMode): void;
		/**
		 * 获取混合模式。
		 *
		 * @returns mode — 当前的混合模式。
		 * @returns alphamode — 当前混合 Alpha 模式 – 它确定绘制对象的 Alpha 如何影响混合。
		 */
		getBlendMode(this: void): LuaMultiReturn<[BlendMode, BlendAlphaMode]>;
		/**
		 * 设置或禁用剪刀。
		 *
		 * 剪刀将绘图区域限制在指定的矩形内。这会影响所有图形调用，包括 love.graphics.clear.
		 *
		 * 剪刀的尺寸不受图形变换（平移、缩放……）的影响。
		 *
		 * 重载说明：
		 * 1. 将绘图区域限制为指定的矩形。
		 * 2. 禁用剪刀。
		 *
		 * @param x 左上角的x坐标。
		 * @param y 左上角的y坐标。
		 * @param width 剪切矩形的宽度。
		 * @param height 剪切矩形的高度。
		 */
		setScissor(this: void): void;
		setScissor(this: void, x: number, y: number, width: number, height: number): void;
		/**
		 * 获取当前剪刀框。
		 *
		 * @returns x — 框左上角点的 x 分量。
		 * @returns y — 框左上角点的 y 分量。
		 * @returns width — 框的宽度。
		 * @returns height — 盒子的高度。
		 */
		getScissor(this: void): LuaMultiReturn<[number, number, number, number]> | undefined;
		/**
		 * 将剪刀设置为由指定矩形与现有剪刀相交而创建的矩形。如果还没有激活的剪刀，则其行为类似于 love.graphics.setScissor.
		 *
		 * 剪刀将绘图区域限制在指定的矩形内。这会影响所有图形调用，包括 love.graphics.clear.
		 *
		 * 剪刀的尺寸不受图形变换（平移、缩放……）的影响。
		 *
		 * @param x 与现有剪刀矩形相交的矩形左上角的 x 坐标。
		 * @param y 与现有剪刀矩形相交的矩形左上角的 y 坐标。
		 * @param width 与现有剪刀矩形相交的矩形的宽度。
		 * @param height 与现有剪刀矩形相交的矩形的高度。
		 */
		intersectScissor(this: void, x: number, y: number, width: number, height: number): void;
		/**
		 * 设置颜色遮罩。渲染和清除屏幕时启用或禁用特定颜色组件。例如，如果“'red''' is set to '''false'”，则不会对任何像素的红色分量进行进一步的更改。
		 *
		 * 重载说明：
		 * 1. 启用指定颜色分量的颜色屏蔽。
		 * 2. 禁用颜色屏蔽。
		 *
		 * @param red 渲染红色分量。
		 * @param green 渲染绿色组件。
		 * @param blue 渲染蓝色分量。
		 * @param alpha 渲染 alpha 分量。
		 */
		setColorMask(this: void): void;
		setColorMask(this: void, red: boolean, green: boolean, blue: boolean, alpha: boolean): void;
		/**
		 * 获取绘图时使用的活动颜色分量。通常，除非使用 love.graphics.setColorMask，否则所有 4 个组件均处于活动状态。
		 *
		 * 颜色掩码确定绘制对象的颜色的各个分量是否会影响屏幕的颜色。它们也会影响 love.graphics.clear 和 Canvas:clear 。
		 *
		 * @returns r — 渲染时红色分量是否处于活动状态。
		 * @returns g — 渲染时绿色分量是否处于活动状态。
		 * @returns b — 渲染时蓝色分量是否处于活动状态。
		 * @returns a — 渲染时 Alpha 颜色分量是否处于活动状态。
		 */
		getColorMask(this: void): LuaMultiReturn<[boolean, boolean, boolean, boolean]>;
		/**
		 * 配置深度测试并写入深度缓冲区。
		 *
		 * 这是低级功能，设计用于自定义顶点着色器和具有自定义顶点属性的网格。没有提供更高级别的 API 来设置 2D 图形（例如形状、线条和图像）的深度。
		 *
		 * 重载说明：
		 * 1. 禁用深度测试和深度写入。
		 *
		 * @param compare 用于深度测试的深度比较模式。
		 * @param write 渲染时是否将更新/写入值写入深度缓冲区。
		 */
		setDepthMode(this: void): void;
		setDepthMode(this: void, compare: CompareMode, write: boolean): void;
		/**
		 * 获取当前深度测试模式以及是否启用写入深度缓冲区。
		 *
		 * 这是低级功能，设计用于自定义顶点着色器和具有自定义顶点属性的网格。没有提供更高级别的 API 来设置 2D 图形（例如形状、线条和图像）的深度。
		 *
		 * @returns comparemode — 用于深度测试的深度比较模式。
		 * @returns write — 渲染时是否将更新/写入值写入深度缓冲区。
		 */
		getDepthMode(this: void): LuaMultiReturn<[CompareMode, boolean]>;
		/**
		 * 设置是否剔除网格中的背面三角形。
		 *
		 * 它设计用于通过网格上的自定义顶点属性、自定义顶点着色器以及使用深度缓冲区进行深度测试来与低级自定义硬件加速 3D 渲染一起使用。
		 *
		 * 默认情况下，网格中的正面和背面三角形都会被渲染。
		 *
		 * @param mode 要使用的网格面剔除模式（是否渲染所有内容、剔除背面三角形或剔除正面三角形）。
		 */
		setMeshCullMode(this: void, mode: MeshCullMode): void;
		/**
		 * 获取网格中的背面三角形是否被剔除。
		 *
		 * 网格面剔除旨在通过网格上的自定义顶点属性、自定义顶点着色器以及使用深度缓冲区的深度测试与低级自定义硬件加速 3D 渲染一起使用。
		 *
		 * @returns mode — 使用中的网格面剔除模式（是否渲染所有内容、剔除背面三角形或剔除正面三角形）。
		 */
		getMeshCullMode(this: void): MeshCullMode;
		/**
		 * 设置是否将具有顺时针或逆时针顺序顶点的三角形视为正面。
		 *
		 * 这是设计用于与网格面剔除结合使用的。其他 love.graphics 形状、线条和精灵不保证其内部顶点具有特定的缠绕顺序。
		 *
		 * @param winding 使用的绕线模式。默认绕线为逆时针方向 ('ccw')。
		 */
		setFrontFaceWinding(this: void, winding: Winding): void;
		/**
		 * 获取具有顺时针或逆时针顺序顶点的三角形是否被视为正面。
		 *
		 * 这是设计用于与网格面剔除结合使用的。其他 love.graphics 形状、线条和精灵不保证其内部顶点具有特定的缠绕顺序。
		 *
		 * @returns winding — 使用的绕线模式。默认绕线为逆时针方向 ('ccw')。
		 */
		getFrontFaceWinding(this: void): Winding;
		/**
		 * 将几何图形绘制为模板。
		 *
		 * 所提供的函数绘制的几何图形设置像素的不可见模板值，而不是设置像素颜色。模板缓冲区（包含这些模板值）可以像蒙版/模板一样工作 - 随后可以使用 love.graphics.setStencilTest 来确定每个像素中的模板值如何影响进一步的渲染。
		 *
		 * 模板值是 255 范围内的整数。
		 *
		 * 重载说明：
		 * 1. 通过在模板函数中使用 love.graphics.setColorMask 来启用对所有颜色分量的绘制，可以同时绘制到屏幕和像素的模板值。
		 *
		 * @param draw 绘制几何图形的函数。像素的模板值，而不是每个像素的颜色，将受到几何形状的影响。
		 * @param action 如何修改模板函数中绘制的内容所涉及的像素的任何模板值。 （默认：'replace'。）
		 * @param value 如果使用 'replace' 模板操作，则用于像素的新模板值。对其他模板操作没有影响。必须介于 0 到 255 之间。（默认值：1。）
		 * @param keepValuesOrClearValue 如果为 true，则保留像素的旧模板值；如果为 false，则在执行模板函数之前将每个像素的模板值重置为 0。 love.graphics.clear 还将重置所有模板值。 （默认值：假。）
		 */
		stencil(this: void, draw: () => void, action?: StencilAction, value?: number, keepValuesOrClearValue?: boolean | number): void;
		/**
		 * 配置或禁用模板测试。
		 *
		 * 当启用模板测试时，之后绘制的所有内容的几何图形都将根据该函数的参数与几何图形接触的每个像素的模板值之间的比较被剪裁/模板化。像素的模板值受 love.graphics.stencil.
		 *
		 * 重载说明：
		 * 1. 禁用模板测试。
		 *
		 * @param compare 对每个像素进行比较的类型。
		 * @param value 与每个像素的模板值进行比较时使用的值。必须介于 0 到 255 之间。
		 */
		setStencilTest(this: void): void;
		setStencilTest(this: void, compare: CompareMode, value: number): void;
		/**
		 * 获取当前模板测试配置。
		 *
		 * 当启用模板测试时，之后绘制的所有内容的几何图形都将根据该函数的参数与几何图形接触的每个像素的模板值之间的比较被剪裁/模板化。像素的模板值受 love.graphics.stencil.
		 *
		 * 每个画布都有自己的每像素模板值。
		 *
		 * @returns comparemode — 对每个像素进行的比较类型。如果禁用模板测试，则将为 'always'。
		 * @returns comparevalue — 与每个像素的模板值进行比较时使用的值。
		 */
		getStencilTest(this: void): LuaMultiReturn<[CompareMode, number]>;
		/**
		 * 从 TrueType 字体或 BMFont 文件创建新字体。创建的字体不会被缓存，因为使用相同的参数调用此函数将始终创建一个新的 Font 对象。
		 *
		 * 所有接受文件名的变体也可以接受数据对象。
		 *
		 * 重载说明：
		 * 1. 创建新的 BMFont 或 TrueType 字体。如果文件是 TrueType 字体，则其大小将为 12。使用下面的变体创建具有自定义大小的 TrueType 字体。
		 * 2. 创建新的 TrueType 字体。
		 * 3. 创建一个新的 BMFont。
		 * 4. 创建具有自定义大小的默认字体 (Vera Sans) 的新实例。
		 *
		 * @param size 字体大小（以像素为单位）。取决于过载：字体的大小（以像素为单位）。 （默认值：12。）
		 * @param filename BMFont 或 TrueType 字体文件的文件路径。取决于重载：TrueType 字体文件的文件路径。取决于重载：BMFont 文件的文件路径。
		 *
		 * @returns font — 可用于在屏幕上绘制文本的 Font 对象。
		 */
		newFont(this: void, size?: number): Font;
		newFont(this: void, filename: string, size?: number): Font;
		/**
		 * 创建并设置新字体。
		 *
		 * @param size 字体大小。 （默认值：12。）
		 * @param filename 字体文件的路径和名称。
		 *
		 * @returns font — 新字体。
		 */
		setNewFont(this: void, size?: number): Font;
		setNewFont(this: void, filename: string, size?: number): Font;
		/**
		 * 创建一个新的特定格式的图像。
		 *
		 * 在 0.9.0 之前的版本中，LÖVE 期望字形字符串采用 ISO 8859-1 编码。
		 *
		 * @param source 图像文件的文件路径。取决于重载：用于创建字体的 ImageData 对象。
		 * @param glyphs 图像中从左到右排列的字符字符串。
		 * @param extraSpacing 应用于字体中每个字形的附加间距（正或负）。 （默认值：0。）
		 * @param rasterizer 图像文件的文件路径。取决于重载：用于创建字体的 ImageData 对象。
		 *
		 * @returns font — 可用于在屏幕上绘制文本的 Font 对象。
		 */
		newImageFont(this: void, source: string | FileData | ImageData, glyphs: string, extraSpacing?: number, dpiScale?: number): Font;
		newImageFont(this: void, rasterizer: Rasterizer): Font;
		/**
		 * 创建一个新的可绘制文本对象。
		 *
		 * @param font 用于文本的字体。
		 * @param text 新 Text 对象将包含的初始文本字符串。可能为零。 （默认值：nil。）取决于重载：包含要添加到对象的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
		 * @param text.color1 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
		 * @param text.string1 文本字符串，其颜色由前一个颜色指定。
		 * @param text.color2 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
		 * @param text.string2 文本字符串，其颜色由前一个颜色指定。
		 * @param text.... 附加颜色和字符串。
		 *
		 * @returns text — 新的可绘制文本对象。
		 */
		newText(this: void, font: Font, text?: ColoredText): Text;
		/**
		 * 将已加载的字体设置为当前字体，或根据文件和大小创建并加载新字体。
		 *
		 * 建议在加载阶段使用 love.graphics.newFont 创建 Font 对象，然后在绘图阶段传递给此函数。
		 *
		 * @param font 要使用的 Font 对象。
		 */
		setFont(this: void, font: Font): void;
		/**
		 * 获取当前的 Font 对象。
		 *
		 * @returns font — 当前字体。自动创建并设置默认字体（如果尚未设置）。
		 */
		getFont(this: void): Font;
		/**
		 * 在屏幕上绘制文本。如果未设置字体，则将根据需要创建并设置（一次）字体。
		 *
		 * 从 LOVE 0.7.1 开始，当在绘制文本时使用平移和缩放函数时，此函数假设首先发生缩放。如果您在编写脚本时没有考虑到这一点，则文本将不会位于正确的位置，甚至可能不会出现在屏幕上。
		 *
		 * love.graphics.print 和 love.graphics.printf 均支持 UTF-8 编码。您还需要适合特殊字符的字体。
		 *
		 * 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
		 *
		 * 重载说明：
		 * 1. love.graphics.setColor 设置的颜色将与文本的颜色组合（相乘）。
		 *
		 * @param text 要绘制的文本。
		 * @param x 绘制对象的位置（x 轴）。 （默认值：0。）取决于过载：文本在 x 轴上的位置。 （默认值：0。）
		 * @param y 绘制对象的位置（y 轴）。 （默认值：0。）取决于过载：文本在 y 轴上的位置。 （默认值：0。）
		 * @param angle 以弧度表示的文本方向。 （默认值：0。）
		 * @param scaleX 比例因子（x 轴）。 （默认值：1。）取决于过载：x 轴上的比例因子。 （默认值：1。）
		 * @param scaleY 比例因子（y 轴）。 （默认值：sx。）取决于过载：y 轴上的比例因子。 （默认值：sx。）
		 * @param originX 原点偏移（x 轴）。 （默认值：0。）取决于过载：x 轴上的原点偏移。 （默认值：0。）
		 * @param originY 原点偏移（y 轴）。 （默认值：0。）取决于过载：y 轴上的原点偏移。 （默认值：0。）
		 * @param shearX 剪切因子（x 轴）。 （默认值：0。）取决于过载：x 轴上的剪切/倾斜系数。 （默认值：0。）
		 * @param shearY 剪切因子（y 轴）。 （默认值：0。）取决于过载：y 轴上的剪切/倾斜系数。 （默认值：0。）
		 */
		print(this: void, text: string | number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * 绘制格式化文本，并进行自动换行和对齐。
		 *
		 * 请参阅 love.graphics.print.
		 *
		 * 在任何缩放、旋转和其他坐标转换之前应用自动换行限制。因此，即使比例参数发生变化，在给定相同的换行限制的情况下，每行的文本量也保持不变。
		 *
		 * 在版本 0.9.2 及更早版本中，换行是通过用空格分隔单词并将它们重新组合在一起来实现的，以确保事物在提供的限制内很好地契合。但是，由于这样做的方式，在屏幕上打印时，单词之间的额外空格最终会丢失，并且某些行可能会溢出超过提供的换行限制。在 0.10.0 及更高版本中，情况不再如此。
		 *
		 * 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
		 *
		 * 重载说明：
		 * 1. love.graphics.setColor 设置的颜色将与文本的颜色组合（相乘）。
		 *
		 * @param text 文本字符串。
		 * @param x x 轴上的位置。取决于过载：文本的位置（x 轴）。
		 * @param y y 轴上的位置。取决于过载：文本的位置（y 轴）。
		 * @param limit 在这么多水平像素之后换行。取决于过载：自动换行之前文本的最大宽度（以像素为单位）。
		 * @param align 对齐。 （默认值：'left'。）取决于重载：文本的对齐方式。
		 * @param angle 方向（弧度）。 （默认值：0。）
		 * @param scaleX 比例因子（x 轴）。 （默认值：1。）
		 * @param scaleY 比例因子（y 轴）。 （默认值：sx。）
		 * @param originX 原点偏移（x 轴）。 （默认值：0。）
		 * @param originY 原点偏移（y 轴）。 （默认值：0。）
		 * @param shearX 剪切因子（x 轴）。 （默认值：0。）取决于过载：剪切/倾斜系数（x 轴）。 （默认值：0。）
		 * @param shearY 剪切因子（y 轴）。 （默认值：0。）取决于过载：剪切/倾斜系数（y 轴）。 （默认值：0。）
		 */
		printf(this: void, text: string | number, x: number, y: number, limit: number, align?: AlignMode, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * 从文件路径、FileData、ImageData 或 CompressedImageData 创建新图像，并可选择生成或指定图像的 mipmap。
		 *
		 * @param filename 图像文件的文件路径。
		 * @param settings 包含以下字段的表：（默认值：nil。）
		 * @param settings.dpiscale 绘制图像和调用 getWidth/getHeight 时使用的 DPI 比例。 （默认值：1。）
		 * @param settings.linear 如果启用伽玛校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。）
		 * @param settings.mipmaps 如果为 true，将自动生成图像的 mipmap（如果可能，如果图像源自 CompressedImageData，则从图像文件中获取）。 （默认值：假。）
		 * @param data 图像文件的文件路径。根据重载：包含图像文件的 FileData。取决于重载：包含图像的 ImageData。根据重载：一个 CompressedImageData 对象。当调用 love.window.setMode 时，Image 将使用此 CompressedImageData 重新加载自身。
		 *
		 * @returns image — 一个可以在屏幕上绘制的新图像对象。
		 */
		newImage(this: void, filename: string, settings?: ImageSettings): Image;
		newImage(this: void, data: FileData, settings?: CompressedImageSettings): Image;
		newImage(this: void, data: ImageData, settings?: ImageSettings): Image;
		newImage(this: void, data: CompressedImageData, settings?: CompressedImageSettings): Image;
		/**
		 * 创建一个新的可绘制视频。目前仅支持 Ogg Theora 视频文件。
		 *
		 * @param filename Ogg Theora 视频文件的文件路径。取决于过载：Ogg Theora 视频文件（或 VideoStream）的文件路径。
		 * @param settings 包含以下字段的表：（默认值：nil。）
		 * @param settings.audio 是否尝试将视频的音频加载到音频源中。如果未明确设置为 true 或 false，则如果视频没有音频，它将尝试，而不会导致错误。 （默认值：假。）
		 * @param settings.dpiscale 视频的 DPI 比例因子。 （默认：love.graphics.getDPIScale()。）
		 * @param stream Ogg Theora 视频文件（或 VideoStream）的文件路径。取决于过载：Ogg Theora 视频文件的文件路径。取决于过载：视频流对象。
		 *
		 * @returns video — 一个新视频。
		 */
		newVideo(this: void, filename: string, settings?: {audio?: boolean; dpiscale?: number}): Video;
		newVideo(this: void, stream: VideoStream, settings?: {audio?: boolean; dpiscale?: number}): Video;
		_newVideo(this: void, filenameOrStream: string | VideoStream, dpiScale?: number): Video;
		/**
		 * 创建一个新的数组图像。
		 *
		 * 数组图像/数组纹理是包含多个 'layers' 或 'slices' 2D 子图像的单个对象。它可以被认为类似于纹理图集或精灵表，但它不会遭受与纹理图集相同的平铺/四边形渗色伪影的影响 - 尽管每个子图像必须具有相同的尺寸。
		 *
		 * 阵列图像的特定层可以使用 love.graphics.drawLayer / SpriteBatch:addLayer 绘制，或者使用 love.graphics.draw 和 Quad:setLayer 的 Quad 变体，或者通过自定义着色器绘制。
		 *
		 * 要在Shader 中使用数组图像，必须将其声明为ArrayImage 或sampler2DArray 类型（而不是Image 或sampler2D）。必须使用 Texel(ArrayImage image, vec3texturecoord) 着色器函数从数组图像的切片中获取像素颜色。 vec3 参数包含前两个组件中的纹理坐标，以及第三个组件中从 0 开始的切片索引。
		 *
		 * 重载说明：
		 * 1. 创建一个数组图像，为生成的数组图像对象的每个切片指定不同的图像文件。阵列图像工作原理的说明：外部插图 DPI 比例为 2（正常像素密度的两倍）将导致图像在屏幕上占据与 DPI 比例为 1 的像素尺寸一半的图像相同的空间。这允许轻松交换在屏幕上占据相同空间但具有不同像素密度的图像资源，这使得支持高 dpi/视网膜分辨率需要更少的代码逻辑。为了在自定义 void effect() 变量中使用数组纹理或其他非 2D 纹理类型作为主纹理，必须在像素着色器中使用变体，并且必须将 MainTex 声明为 ArrayImage 或 sampler2DArray，如下所示：uniform ArrayImage MainTex;。
		 *
		 * @param layers 一个表，其中包含数组中图像（或 File、FileData、ImageData 或 CompressedImageData 对象）的文件路径。每个子图像必须具有相同的尺寸。还可以给出表的表，其中每个子表包含该子表的切片索引的所有mipmap级别。
		 * @param settings 用于配置阵列映像的可选设置表，包含以下字段：（默认值：nil。）
		 * @param settings.mipmaps 如果为 True 则使图像使用 mipmap，为 false 则禁用它们。如果图像不是压缩纹理格式，则会自动生成 Mipmap。 （默认值：假。）
		 * @param settings.linear 如果启用伽玛校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。）
		 * @param settings.dpiscale 绘制数组图像并调用 getWidth/getHeight 时使用的 DPI 比例。 （默认值：1。）
		 *
		 * @returns image — 数组图像对象。
		 */
		newArrayImage(this: void, layers: ImageData[], settings?: LayeredImageSettings): Image;
		/**
		 * 创建一个新的立方体贴图图像。
		 *
		 * 立方体贴图图像有 6 个面（侧面），代表一个立方体。它们不能直接渲染，只能在着色器代码中使用（并通过 Shader:send 发送到着色器）。
		 *
		 * 要在Shader 中使用立方体贴图图像，必须将其声明为CubeImage 或samplerCube 类型（而不是Image 或sampler2D）。必须使用 Texel(CubeImage image, vec3 Direction) 着色器函数从立方体贴图中获取像素颜色。 vec3 参数是从立方体中心开始的标准化方向，而不是显式的纹理坐标。
		 *
		 * 立方体贴图图像中的每个面都必须具有正方形尺寸。
		 *
		 * 对于接受包含多个立方体贴图面的单个图像的此函数的变体，它们必须在图像中以以下形式之一布局：
		 *
		 * +y
		 *
		 * +z +x -z
		 *
		 * -y
		 *
		 * -x
		 *
		 * 或：
		 *
		 * +y
		 *
		 * -x +z +x -z
		 *
		 * -y
		 *
		 * 或：
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
		 * 或：
		 *
		 * +x -x +y -y +z -z
		 *
		 * 重载说明：
		 * 1. 在给定包含多个立方体面的单个图像文件的情况下创建立方体贴图图像。
		 * 2. 为每个立方体面指定不同的图像文件，创建立方体贴图图像。
		 *
		 * @param faces 包含 6 个图像文件路径（或 File、FileData、ImageData 或 CompressedImageData 对象）的表，位于数组中。每个面部图像必须具有相同的尺寸。还可以给出表的表，其中每个子表包含该子表的立方体面索引的所有mipmap级别。
		 * @param settings 用于配置立方体贴图图像的可选设置表，包含以下字段：（默认值：nil。）
		 * @param settings.mipmaps 如果为 True 则使图像使用 mipmap，为 false 则禁用它们。如果图像不是压缩纹理格式，则会自动生成 Mipmap。 （默认值：假。）
		 * @param settings.linear 如果启用伽玛校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。）
		 *
		 * @returns image — 立方体贴图图像对象。
		 */
		newCubeImage(this: void, faces: [ImageData, ImageData, ImageData, ImageData, ImageData, ImageData], settings?: LayeredImageSettings): Image;
		/**
		 * 创建新体积 (3D) 图像。
		 *
		 * 体积图像是具有宽度、高度和深度的 3D 纹理。它们不能直接渲染，只能在着色器代码中使用（并通过 Shader:send 发送到着色器）。
		 *
		 * 要在Shader中使用体积图像，必须将其声明为VolumeImage或sampler3D类型（而不是Image或sampler2D）。必须使用 Texel(VolumeImage image, vec3 texcoords) 着色器函数从体积图像中获取像素颜色。 vec3 参数是标准化纹理坐标，其中 z 分量表示采样深度（范围从 1 开始）。
		 *
		 * 体积图像通常用作着色器中颜色分级的查找表，例如，因为使用两个像素之间的纹理坐标进行采样可以在体积图像中的所有 3 个维度上进行插值，从而即使在使用小尺寸体积图像作为查找表时也会产生平滑的渐变。
		 *
		 * 数组图像是比体积图像更好的选择，用于将多个不同的精灵存储在单个数组图像中以便直接绘制它们。
		 *
		 * 重载说明：
		 * 1. 在给定多个具有匹配尺寸的图像文件的情况下创建体积图像。某些较旧的移动设备不支持卷映像。使用 love.graphics.getTextureTypes 在运行时检查。
		 *
		 * @param slices 一个表，其中包含数组中图像（或 File、FileData、ImageData 或 CompressedImageData 对象）的文件路径。还可以给出表中的表，其中每个子表代表单个 mipmap 级别并包含该 mipmap 的所有层。
		 * @param settings 用于配置卷映像的可选设置表，包含以下字段：（默认值：nil。）
		 * @param settings.mipmaps 如果为 True 则使图像使用 mipmap，为 false 则禁用它们。如果图像不是压缩纹理格式，则会自动生成 Mipmap。 （默认值：假。）
		 * @param settings.linear 如果启用伽玛校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。）
		 *
		 * @returns image — 体积图像对象。
		 */
		newVolumeImage(this: void, slices: ImageData[], settings?: LayeredImageSettings): Image;
		/**
		 * 创建一个新的 Canvas 对象用于离屏渲染。
		 *
		 * 重载说明：
		 * 1. 使用给定的设置创建 2D 或立方体贴图画布。某些 Canvas 格式的系统要求比默认格式更高。使用 love.graphics.getCanvasFormats 检查支持。
		 * 2. 创建体积或数组纹理类型画布。
		 *
		 * @param width 画布所需的宽度。
		 * @param height 画布所需的高度。
		 * @param settings 包含给定字段的表：（默认值：nil。）
		 * @param settings.type 要创建的画布类型。 （默认值：'2d'。）取决于重载：要创建的画布类型。 （默认：'array'。）
		 * @param settings.format 画布的格式。 （默认：'normal'。）
		 * @param settings.readable Canvas 是否可读（可在着色器中绘制和访问）。对于常规格式默认为 true，对于深度/模板格式默认为 false。取决于重载：画布是否可读（可在着色器中绘制和访问）。对于常规格式默认为 true，对于深度/模板格式默认为 false。 （默认值：无。）
		 * @param settings.msaa 绘制到画布时所需的多重采样抗锯齿 (MSAA) 样本数。 （默认值：0。）
		 * @param settings.dpiscale Canvas 的 DPI 比例因子，在绘制到 Canvas 以及将 Canvas 绘制到屏幕时使用。 （默认：love.graphics.getDPIScale()。）
		 * @param settings.mipmaps Canvas是否有mipmap，如果有的话是否自动重新生成它们。 （默认：'none'。）
		 *
		 * @returns canvas — 尺寸等于窗口大小（以像素为单位）的新画布。根据过载：具有指定宽度和高度的新画布。
		 */
		newCanvas(this: void, width?: number, height?: number, settings?: CanvasSettings): Canvas;
		/**
		 * 获取可用的 Canvas 格式以及是否支持每种格式。
		 *
		 * @param readable 如果为 true，则仅当该格式的可读标志设置为 true 时，返回的格式才会被指示为受支持，反之亦然，如果参数为 false。
		 *
		 * @returns formats — 包含 CanvasFormats 作为键的表，以及一个指示是否支持该格式作为值的布尔值。并非所有系统都支持所有格式。取决于重载：包含 CanvasFormats 作为键的表，以及指示是否支持该格式作为值的布尔值（考虑到可读参数）。并非所有系统都支持所有格式。
		 */
		getCanvasFormats(this: void, readable?: boolean, formats?: CanvasFormats): CanvasFormats;
		/**
		 * 将绘图操作捕获到画布上。
		 *
		 * 重载说明：
		 * 1. 将渲染目标设置为指定的模板或使用活动画布进行深度测试，必须通过以下变体在 setCanvas 中显式启用模板缓冲区或深度缓冲区。请注意，当“'love.graphics.present'' is called. ''love.graphics.present'' is called at the end of love.draw in the default love.run, hence if you activate a canvas using this function, you normally need to deactivate it at some point before ''love.draw'”完成时，画布不应处于活动状态。
		 * 2. 将渲染目标重置为屏幕，即重新启用在屏幕上的绘制。
		 * 3. 将渲染目标设置为多个同时 2D 画布。直到下一个“'love.graphics.setCanvas'”调用之前的所有绘图操作都将被重定向到指定的画布，并且不会显示在屏幕上。通常，所有绘图操作都只会绘制到传递给该函数的第一个画布，但如果像素着色器与 void 效果函数而不是常规 vec4 效果一起使用，则可以更改这一情况。所有画布参数必须具有相同的宽度和高度以及相同的纹理类型。并非所有支持画布的计算机都支持多个渲染目标。如果 love.graphics.isSupported('multicanvas') 返回 true，则至少支持 4 个同时活动的画布。
		 * 4. 将渲染目标设置为给定非 2D 画布的指定图层/切片和 mipmap 级别。直到下一个“'love.graphics.setCanvas'”调用之前的所有绘图操作都将被重定向到画布，并且不会显示在屏幕上。
		 * 5. 根据指定的设置信息设置活动渲染目标以及活动模板和深度缓冲区。直到下一个“'love.graphics.setCanvas'”调用之前的所有绘图操作都将被重定向到指定的画布，并且不会显示在屏幕上。 RenderTargetSetup 参数可以是 Canvas|[1]|用于此活动渲染目标的 Canvas。}} {{param|number|mipmap (1)|要渲染到的 mipmap 级别，对于带有 [[Texture:getMipmapCount|mipmaps 的画布。}} {{param|number|layer (1)|仅用于体积和数组类型画布。对于数组纹理，这是要渲染到的数组层。对于体积纹理，这是深度切片。}} {{param|number|face (1)|仅用于立方体贴图类型画布。要渲染到的立方体面索引（1 到 6 之间）}}
		 *
		 * @param canvas 新目标。取决于重载：新的渲染目标。
		 * @param canvases 对于具有 mipmap 的画布，要渲染到的 mipmap 级别。 （默认值：1。）取决于重载：指定活动画布、其 mipmap 级别和活动图层（如果适用）以及是否使用模板和/或深度缓冲区的表。
		 * @param canvases.1 要渲染的画布。
		 * @param canvases.2 如果需要多个同时渲染目标，则需要渲染到的附加画布。 （默认值：无。）
		 * @param canvases.... 如果需要多个同时渲染目标，则需要渲染到其他画布。
		 * @param canvases.stencil 如果未设置 heightstencil 字段，是否应使用内部管理的模板缓冲区。 （默认值：假。）
		 * @param canvases.depth 如果未设置 heightstencil 字段，是否应使用内部管理的深度缓冲区。 （默认值：假。）
		 * @param canvases.depthstencil 可选的自定义深度/模板格式化画布，用于深度和/或模板缓冲区。 （默认值：无。）
		 * @param setup 指定活动画布、其 mipmap 级别和活动层（如果适用）以及是否使用模板和/或深度缓冲区的表格。
		 * @param setup.1 要渲染的画布。
		 * @param setup.2 如果需要多个同时渲染目标，则需要渲染到的附加画布。 （默认值：无。）
		 * @param setup.... 如果需要多个同时渲染目标，则需要渲染到其他画布。
		 * @param setup.stencil 如果未设置 heightstencil 字段，是否应使用内部管理的模板缓冲区。 （默认值：假。）
		 * @param setup.depth 如果未设置 heightstencil 字段，是否应使用内部管理的深度缓冲区。 （默认值：假。）
		 * @param setup.depthstencil 可选的自定义深度/模板格式化画布，用于深度和/或模板缓冲区。 （默认值：无。）
		 */
		setCanvas(): void;
		setCanvas(canvas: Canvas, ...canvases: Canvas[]): void;
		setCanvas(canvases: Canvas[]): void;
		setCanvas(setup: CanvasSetup): void;
		/**
		 * 获取当前目标Canvas。
		 *
		 * @returns canvas — setCanvas 设置的 Canvas。如果绘制到真实屏幕则返回 nil。
		 */
		getCanvas(): Canvas | LuaMultiReturn<[Canvas, ...Canvas[]]> | CanvasSetup | undefined;
		/**
		 * 创建一个新的四边形。
		 *
		 * Quad 的目的是使用图像的一部分来绘制对象，而不是绘制整个图像。它对于精灵表和图集最有用：在精灵图集中，多个精灵驻留在同一图像中，四边形用于从该图像中绘制特定的精灵；在所有帧都驻留在同一图像中的动画精灵中，四边形用于从动画中绘制特定帧。
		 *
		 * @param x 图像中沿 x 轴的左上角位置。
		 * @param y 图像中沿 y 轴的左上角位置。
		 * @param width 图像中四边形的宽度。 （必须大于 0。）
		 * @param height 图像中四边形的高度。 （必须大于 0。）
		 * @param image 纹理的宽度和高度将用作参考宽度和高度。
		 * @param textureWidth 参考宽度，Image的宽度。 （必须大于 0。）
		 * @param textureHeight 参考高度，Image的高度。 （必须大于 0。）
		 *
		 * @returns quad — 新的四边形。
		 */
		newQuad(x: number, y: number, width: number, height: number, image: Image | Canvas): Quad;
		newQuad(x: number, y: number, width: number, height: number, textureWidth: number, textureHeight: number): Quad;
		/**
		 * 创建一个新的网格。
		 *
		 * 如果网格在绘制时应使用图像或画布进行纹理化，请使用 Mesh:setTexture 。
		 *
		 * 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
		 *
		 * 重载说明：
		 * 1. 创建具有指定顶点的标准网格。
		 * 2. 创建具有指定顶点数的标准网格。创建网格后，可以使用 Mesh:setVertices 或 Mesh:setVertex 和 Mesh:setDrawRange 指定顶点信息。
		 * 3. 创建具有自定义顶点属性和指定顶点数据的网格。每个顶点表中的值的顺序与指定顶点格式中的顶点属性的顺序相同。如果没有为特定顶点属性组件提供值，则如果其数据类型为 'float'，则将设置为默认值 0；如果其数据类型为 'byte'，则将设置为 1。如果属性的数据类型为 'float'，则组件的范围可以为 1 到 4，如果数据类型为 'byte'，则必须为 4。如果自定义顶点属性使用名称 'VertexPosition'、'VertexTexCoord' 或 'VertexColor'，则该顶点属性的顶点数据将用于标准顶点位置、纹理坐标或顶点颜色分别在绘制网格时。否则，需要顶点着色器才能在绘制网格时使用顶点属性。网格体“'must'”具有 'VertexPosition' 属性以便绘制，但它可以通过 Mesh:attachAttribute 从不同的网格体附加。要在顶点着色器中使用自定义命名顶点属性，必须将其声明为同名的属性变量。通过创建变量，可以将变量从顶点着色器代码发送到像素着色器代码。例如： ''Vertex Shader code'' attribute vec2 CoolVertexAttribute; varying vec2 CoolVariable; vec4 position(mat4 transform_projection, vec4 vertex_position) {  CoolVariable = CoolVertexAttribute;  return transform_projection * vertex_position; } ''Pixel Shader code'' 变化 vec2 CoolVariable； vec4 效果（vec4 颜色，图像 tex，vec2 texcoord，vec2 pixcoord）{ vec4 texcolor = Texel（tex，texcoord + CoolVariable）; 返回 texcolor * 颜色； }
		 * 4. 创建具有自定义顶点属性和指定顶点数的网格。如果每个顶点属性组件的数据类型为 'float'，则其初始化为 0；如果其数据类型为 'byte'，则初始化为 1。为了在绘制网格时使用顶点属性，需要顶点着色器。网格体“'must'”具有 'VertexPosition' 属性以便绘制，但它可以通过 Mesh:attachAttribute 从不同的网格体附加。
		 * 5. Mesh:setVertices 或 Mesh:setVertex 和 Mesh:setDrawRange 可用于在创建网格后指定顶点信息。
		 *
		 * @param vertices 该表填充了每个顶点的顶点信息表，如下所示： 取决于重载：该表填充了每个顶点的顶点信息表，其形式为{vertex, ...}，其中每个顶点是一个形式为{attributecomponent, ...}的表。
		 * @param vertices.1 顶点在 x 轴上的位置。
		 * @param vertices.2 顶点在 y 轴上的位置。
		 * @param vertices.3 顶点的u纹理坐标。纹理坐标通常在 1 的范围内，但可以更大或更小（请参阅 WrapMode。）（默认值：0。）
		 * @param vertices.4 顶点的 v 纹理坐标。纹理坐标通常在 1 的范围内，但可以更大或更小（请参阅 WrapMode。）（默认值：0。）
		 * @param vertices.5 顶点颜色的红色分量。 （默认值：1。）
		 * @param vertices.6 顶点颜色的绿色分量。 （默认值：1。）
		 * @param vertices.7 顶点颜色的蓝色分量。 （默认值：1。）
		 * @param vertices.8 顶点颜色的 Alpha 分量。 （默认值：1。）
		 * @param vertices.attributecomponent 顶点中第一个顶点属性的第一个组成部分。
		 * @param vertices.... 顶点中所有顶点属性的附加组件。
		 * @param drawMode 绘制时如何使用顶点。默认模式 'fan' 对于简单的凸多边形来说已经足够了。 （默认值：'fan'。）取决于重载：绘制网格时使用的图像或画布。不使用纹理可能为零。 （默认值：无。）
		 * @param usage 网格的预期用途。指定的使用模式会影响Mesh的内存使用和性能。 （默认：'dynamic'。）
		 * @param format {attribute, ...} 形式的表。每个属性都是一个表，其中指定用于每个顶点的自定义顶点属性。
		 * @param format.attribute 包含属性名称、数据类型以及属性中组件数量的表，格式为{名称、数据类型、组件}。
		 * @param format.... 附加顶点属性格式表。
		 *
		 * @returns mesh — 新网格。
		 */
		newMesh(vertices: MeshVertex[] | number, drawMode?: MeshDrawMode, usage?: MeshUsage): Mesh;
		newMesh(format: MeshVertexFormat[], vertices: MeshVertex[] | number | Data, drawMode?: MeshDrawMode, usage?: MeshUsage): Mesh;
		/**
		 * 创建一个新的 SpriteBatch 对象。
		 *
		 * @param texture 用于精灵的图像或画布。
		 * @param size SpriteBatch 在任何给定时间可以包含的精灵的最大数量。自版本 11.0 起，添加超过此数量的额外精灵将自动增加精灵批次。 （默认值：1000。）
		 * @param usage SpriteBatch 的预期用法。指定的使用模式会影响SpriteBatch的内存使用和性能。 （默认：'dynamic'。）
		 *
		 * @returns spriteBatch — 新的 SpriteBatch。
		 */
		newSpriteBatch(texture: Image | Canvas, size?: number, usage?: MeshUsage): SpriteBatch;
		/**
		 * 创建一个新的粒子系统。
		 *
		 * @param texture 要使用的纹理（图像或画布）。
		 * @param size 同时最大粒子数。 （默认值：1000。）
		 *
		 * @returns system — 一个新的粒子系统。
		 */
		newParticleSystem(texture: Image | Canvas, size?: number): ParticleSystem;
		/**
		 * 为硬件加速顶点和像素效果创建一个新的 Shader 对象。着色器包含顶点着色器代码、像素着色器代码或两者。
		 *
		 * 着色器是绘图时在显卡上运行的小程序。顶点着色器针对每个顶点运行一次（例如，图像有 4 个顶点 - 每个角各一个。网格可能有更多。）像素着色器针对绘制对象接触的屏幕上的每个像素运行一次。像素着色器代码在顶点着色器处理完所有对象的顶点后执行。
		 *
		 * @param source 像素着色器代码，或指向包含该代码的文件的文件名。
		 * @param pixelSource 顶点着色器代码，或指向包含该代码的文件的文件名。
		 *
		 * @returns shader — 用于绘图操作的 Shader 对象。
		 */
		newShader(source: ShaderSource, pixelSource?: ShaderSource): Shader;
		/**
		 * 验证着色器代码。检查指定的着色器代码是否不包含任何错误。
		 *
		 * @param gles 验证代码为 GLSL ES 着色器。
		 * @param source 像素着色器代码，或指向包含该代码的文件的文件名。
		 * @param pixelSource 顶点着色器代码，或指向包含该代码的文件的文件名。
		 *
		 * @returns status — true 如果指定的着色器代码不包含任何错误。否则为假。
		 * @returns message — 着色器代码验证失败的原因（如果验证成功则为零）。
		 */
		validateShader(gles: boolean, source: ShaderSource, pixelSource?: ShaderSource): LuaMultiReturn<[boolean, string?]>;
		/**
		 * 将着色器设置或重置为当前像素效果或顶点着色器。直到下一个“'love.graphics.setShader'”之前的所有绘制操作都将使用指定的 Shader 对象进行绘制。
		 *
		 * 重载说明：
		 * 1. 将当前着色器设置为指定的着色器。直到下一个“'love.graphics.setShader'”之前的所有绘制操作都将使用指定的 Shader 对象进行绘制。
		 * 2. 禁用着色器，允许未过滤的绘图操作。
		 *
		 * @param shader 新的着色器。
		 */
		setShader(shader?: Shader): void;
		/**
		 * 获取当前的Shader。如果未设置则返回 nil。
		 *
		 * @returns shader — 当前活动的着色器，如果未设置则为零。
		 */
		getShader(): Shader | undefined;
		/**
		 * 在屏幕上绘制可绘制对象（图像、画布、SpriteBatch、粒子系统、网格、文本对象或视频），并可选择旋转、缩放和剪切。
		 *
		 * 对象是相对于其局部坐标系绘制的。原点默认位于图像和画布的左上角。所有缩放、剪切和旋转参数都会相对于该点变换对象。另外，还可以在屏幕坐标系上指定原点位置。
		 *
		 * 通过将原点偏移到中心，可以绕其中心旋转对象。旋转角度必须以弧度为单位。还可以使用负比例因子来围绕其中心线翻转。
		 *
		 * 请注意，偏移是在旋转、缩放或剪切之前应用的；缩放和剪切在旋转之前应用。
		 *
		 * 对象的右边缘和底边缘以剪切因子定义的角度移动。
		 *
		 * 使用默认着色器时，使用此函数绘制的任何内容都将根据当前选择的颜色进行着色。将其设置为纯白色以保留对象的原始颜色。
		 *
		 * @param image 可绘制对象。
		 * @param x 绘制对象的位置（x 轴）。 （默认值：0。）取决于重载：绘制对象的位置（x 轴）。
		 * @param y 绘制对象的位置（y 轴）。 （默认值：0。）取决于过载：绘制对象的位置（y 轴）。
		 * @param angle 方向（弧度）。 （默认值：0。）取决于过载：比例因子（x 轴）。 （默认值：1。）
		 * @param scaleX 比例因子（x 轴）。 （默认值：1。）取决于过载：比例因子（y 轴）。 （默认值：sx。）
		 * @param scaleY 比例因子（y 轴）。 （默认值：sx。）取决于过载：原点偏移（x 轴）。 （默认值：0。）
		 * @param originX 原点偏移（x 轴）。 （默认值：0。）取决于过载：原点偏移（y 轴）。 （默认值：0。）
		 * @param originY 原点偏移（y 轴）。 （默认值：0。）取决于过载：剪切系数（x 轴）。 （默认值：0。）
		 * @param quad 在屏幕上绘制的四边形。
		 */
		draw(image: Image, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(image: Image, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		/**
		 * 绘制数组纹理的一层。
		 *
		 * 重载说明：
		 * 1. 绘制数组纹理的一层。
		 * 2. 使用指定的四边形绘制一层阵列纹理。指定的图层索引会覆盖通过 Quad:setLayer 在 Quad 上设置的任何图层索引。
		 * 3. 使用指定的变换绘制一层阵列纹理。
		 * 4. 使用指定的四边形和变换绘制一层阵列纹理。为了在自定义 void effect() 变量中使用数组纹理或其他非 2D 纹理类型作为主纹理，必须在像素着色器中使用变体，并且必须将 MainTex 声明为 ArrayImage 或 sampler2DArray，如下所示：uniform ArrayImage MainTex;。
		 *
		 * @param image 要绘制的数组纹理。
		 * @param layer 绘制时使用的图层的索引。
		 * @param x 绘制纹理的位置（x 轴）。 （默认值：0。）
		 * @param y 绘制纹理的位置（y 轴）。 （默认值：0。）
		 * @param angle 方向（弧度）。 （默认值：0。）取决于过载：比例因子（x 轴）。 （默认值：1。）
		 * @param scaleX 比例因子（x 轴）。 （默认值：1。）取决于过载：比例因子（y 轴）。 （默认值：sx。）
		 * @param scaleY 比例因子（y 轴）。 （默认值：sx。）取决于过载：原点偏移（x 轴）。 （默认值：0。）
		 * @param originX 原点偏移（x 轴）。 （默认值：0。）取决于过载：原点偏移（y 轴）。 （默认值：0。）
		 * @param originY 原点偏移（y 轴）。 （默认值：0。）取决于过载：剪切系数（x 轴）。 （默认值：0。）
		 * @param quad 绘制时使用的纹理层的分段。
		 */
		drawLayer(image: Image, layer: number, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		drawLayer(image: Image, layer: number, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(canvas: Canvas, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(canvas: Canvas, quad: Quad, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number): void;
		draw(mesh: Mesh, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): void;
		/**
		 * 使用硬件几何实例，通过一次绘制调用绘制网格的许多实例。
		 *
		 * 每个实例都可以具有唯一的属性（位置、颜色等），但默认情况下不会，除非使用自定义的每个实例顶点属性或 love_InstanceID GLSL 3 顶点着色器变量，否则它们将全部渲染在彼此之上的相同位置。
		 *
		 * 某些旧版 GPU 不支持实例化，这些 GPU 只能使用 OpenGL ES 2 或 OpenGL 2。使用 love.graphics.getSupported 进行检查。
		 *
		 * @param mesh 要渲染的网格物体。
		 * @param instanceCount 要渲染的实例数。
		 * @param x 绘制实例的位置（x 轴）。 （默认值：0。）
		 * @param y 绘制实例的位置（y 轴）。 （默认值：0。）
		 * @param angle 方向（弧度）。 （默认值：0。）
		 * @param scaleX 比例因子（x 轴）。 （默认值：1。）
		 * @param scaleY 比例因子（y 轴）。 （默认值：sx。）
		 * @param originX 原点偏移（x 轴）。 （默认值：0。）
		 * @param originY 原点偏移（y 轴）。 （默认值：0。）
		 * @param shearX 剪切因子（x 轴）。 （默认值：0。）
		 * @param shearY 剪切因子（y 轴）。 （默认值：0。）
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
	 */
	interface Window {
		/**
		 * 获取桌面的宽度和高度。
		 *
		 * @param display 显示的索引（如果有多个监视器可用）。 （默认值：1。）
		 *
		 * @returns width — 桌面的宽度。
		 * @returns height — 桌面的高度。
		 */
		getDesktopDimensions(this: void, display?: number): LuaMultiReturn<[number, number]>;
		/**
		 * 获取已连接显示器的数量。
		 *
		 * @returns count — 当前连接的显示器数量。
		 */
		getDisplayCount(this: void): number;
		/**
		 * 获取显示器的名称。
		 *
		 * @param display 要获取其名称的显示器的索引。 （默认值：1。）
		 *
		 * @returns name — 指定显示器的名称。
		 */
		getDisplayName(this: void, display: number): string;
		/**
		 * 获取当前设备显示方向。
		 *
		 * @param display 显示索引以获取其显示方向，或 nil 以获得默认显示索引。 （默认值：无。）
		 *
		 * @returns orientation — 当前设备显示方向。
		 */
		getDisplayOrientation(this: void, display?: number): "unknown" | "landscape" | "portrait" | "landscapeflipped" | "portraitflipped";
		/**
		 * 获取支持的全屏模式列表。
		 *
		 * @param display 显示的索引（如果有多个监视器可用）。 （默认值：1。）
		 *
		 * @returns modes — 宽度/高度对的表。 （请注意，这可能不按顺序排列。）
		 * @returns modes.width — 窗口全屏宽度。
		 * @returns modes.height — 窗口全屏高度。
		 */
		getFullscreenModes(this: void, display?: number): WindowSize[];
		/**
		 * 进入或退出全屏。如果连接了多个显示器，则根据窗口当前所在的显示来选择进入全屏时要使用的显示。
		 *
		 * 重载说明：
		 * 1. 如果进入全屏模式并且窗口大小与显示器的显示模式之一不匹配（在正常全屏模式下）或窗口大小与桌面大小不匹配（在 'desktop' 全屏模式下），窗口将适当调整大小。当使用此功能退出全屏模式时，窗口将再次恢复到其原始大小。
		 *
		 * @param fullscreen 是否进入或退出全屏模式。
		 * @param type 要使用的全屏模式类型。
		 *
		 * @returns success — 如果尝试进入全屏成功则为 true，否则为 false。
		 */
		setFullscreen(this: void, fullscreen: boolean, type?: "desktop" | "exclusive"): boolean;
		/**
		 * 获取窗口是否全屏。
		 *
		 * @returns fullscreen — 如果窗口是全屏则为 true，否则为 false。
		 * @returns fstype — 使用的全屏模式类型。
		 */
		getFullscreen(this: void): LuaMultiReturn<[boolean, "desktop" | "exclusive"]>;
		/**
		 * 检查窗口是否打开。
		 *
		 * @returns open — 如果窗口打开则为 true，否则为 false。
		 */
		isOpen(this: void): boolean;
		/**
		 * 获取窗口图标。
		 *
		 * @returns imagedata — 窗口图标图像数据，如果没有使用 love.window.setIcon. 设置图标则为零
		 */
		getIcon(this: void): ImageData | undefined;
		/**
		 * 使用 ImageData 设置窗口图标。
		 *
		 * 嵌入式 LoveNode 会接受该请求，但不会修改 Dora 宿主应用的图标。
		 * @param imagedata — 窗口图标的图像数据。
		 * @returns success — 图标请求被接受时返回 true。
		 */
		setIcon(this: void, imagedata: ImageData): boolean;
		/**
		 * 获取窗口的显示模式和属性。
		 *
		 * @returns width — 窗口宽度。
		 * @returns height — 窗口高度。
		 * @returns flags — 具有窗口属性的表：
		 * @returns flags.fullscreen — 全屏（true）或窗口化（false）。
		 * @returns flags.fullscreentype — 使用的全屏模式类型。
		 * @returns flags.vsync — 如果图形帧率与显示器的刷新率同步则为 True，否则为 false。
		 * @returns flags.msaa — 使用的抗锯齿样本数（如果禁用 MSAA，则为 0）。
		 * @returns flags.resizable — 如果窗口在窗口模式下可调整大小，则为 true，否则为 false。
		 * @returns flags.borderless — 如果窗口在窗口模式下无边框，则为 true，否则为 false。
		 * @returns flags.centered — 如果窗口在窗口模式下居中则为 true，否则为 false。
		 * @returns flags.display — 如果有多个显示器可用，则窗口当前所在显示器的索引。
		 * @returns flags.minwidth — 窗口的最小宽度（如果可以调整大小）。
		 * @returns flags.minheight — 窗口的最小高度（如果可以调整大小）。
		 * @returns flags.highdpi — 如果 OS X 中的 Retina 显示器允许使用高 dpi 模式，则为 True。在非 Retina 显示器上不执行任何操作。
		 * @returns flags.refreshrate — 屏幕当前显示模式的刷新率，单位为Hz。如果无法确定该值，则可能为 0。
		 * @returns flags.x — 窗口在当前显示中的位置的 x 坐标。
		 * @returns flags.y — 窗口在当前显示中的位置的 y 坐标。
		 * @returns flags.srgb — 在 0.10.0 中删除（使用 love.graphics.isGammaCorrect 代替）。如果在绘制到屏幕时应用 sRGB gamma 校正，则为 true。
		 */
		getMode(this: void): LuaMultiReturn<[number, number, WindowMode]>;
		/**
		 * 设置窗口的显示模式和属性。
		 *
		 * 如果宽度或高度为0，setMode 将使用桌面的宽度和高度。
		 *
		 * 更改显示模式可能会产生副作用：例如，画布将被清除，并且值会预先发送到带有画布的着色器，或者如果需要的话，之后重新绘制到它们。
		 *
		 * 重载说明：
		 * 1. * 如果启用全屏并且不支持宽度或高度（请参阅 resize 事件将被触发。 * 如果全屏类型为 'desktop'，那么窗口将自动调整大小到桌面分辨率。 * 如果宽度和高度大于或等于桌面尺寸（包括设置为 0）并且全屏设置为 false，则会显示 'visually' 全屏，但不是真正的全屏和 conf.lua （即 t.window = false）并使用此函数手动创建窗口，那么您不得在此函数之前调用任何其他 love.graphics.* 函数，否则将导致未定义的行为和/或崩溃，因为没有窗口，OpenGL 无法正常运行 * 目前不支持透明背景。
		 *
		 * @param width 显示宽度。
		 * @param height 显示高度。
		 * @param settings 带有选项的标志表：
		 * @param settings.fullscreen 全屏（true）或窗口化（false）。 （默认值：假。）
		 * @param settings.fullscreentype 要使用的全屏类型。在 0.9.0 到 0.9.2 中默认为 'normal'，在 0.10.0 及更早版本中默认为 'desktop'。 （默认：'desktop'。）
		 * @param settings.vsync 如果 LÖVE 应该等待垂直同步则为 true，否则为 false。 （默认值：true。）
		 * @param settings.msaa 抗锯齿样本数。 （默认值：0。）
		 * @param settings.stencil 是否应分配模板缓冲区。如果为 true，模板缓冲区将有 8 位。 （默认值：true。）
		 * @param settings.depth 深度缓冲区中的位数。 （默认值：0。）
		 * @param settings.resizable 如果窗口应在窗口模式下调整大小，则为 true，否则为 false。 （默认值：假。）
		 * @param settings.borderless 如果窗口在窗口模式下应无边框，则为 true，否则为 false。 （默认值：假。）
		 * @param settings.centered 如果窗口应在窗口模式下居中，则为 true，否则为 false。 （默认值：true。）
		 * @param settings.display 如果有多个监视器可用，则显示窗口的显示器索引。 （默认值：1。）
		 * @param settings.minwidth 窗口的最小宽度（如果可以调整大小）。不能小于 1。（默认值：1。）
		 * @param settings.minheight 窗口的最小高度（如果可以调整大小）。不能小于 1。（默认值：1。）
		 * @param settings.highdpi 如果应在 macOS 和 iOS 中的 Retina 显示屏上使用高 dpi 模式，则为 True。在非 Retina 显示器上不执行任何操作。 （默认值：假。）
		 * @param settings.x 指定显示中窗口位置的 x 坐标。 （默认值：无。）
		 * @param settings.y 指定显示中窗口位置的 y 坐标。 （默认值：无。）
		 * @param settings.usedpiscale 如果为 false，则禁用自动 DPI 缩放。 （默认值：true。）
		 * @param settings.srgb 在0.10.0中删除（改为在conf.lua中设置t.gamma Correct）。如果在绘制到屏幕时应应用 sRGB gamma 校正，则为 true。 （默认值：假。）
		 *
		 * @returns success — 如果成功则为 true，否则为 false。
		 */
		setMode(this: void, width: number, height: number, settings?: WindowModeSettings): boolean;
		/**
		 * 设置窗口的显示模式和属性，不修改未指定的属性。
		 *
		 * 如果宽度或高度为0，updateMode 将使用桌面的宽度和高度。
		 *
		 * 更改显示模式可能会产生副作用：例如，画布将被清除。确保事先保存画布的内容，或者如果需要的话，之后重新绘制。
		 *
		 * 重载说明：
		 * 1. 如果启用全屏且不支持宽度或高度（请参阅 resize 事件将被触发。如果全屏类型为 'desktop'，则窗口将自动调整大小到桌面分辨率。目前不支持透明背景。
		 *
		 * @param settings 具有以下可选字段的设置表。任何未填写的字段都将使用 love.window.getMode.
		 * @param settings.fullscreen 全屏（true）或窗口化（false）。
		 * @param settings.fullscreentype 要使用的全屏类型。
		 * @param settings.vsync 如果 LÖVE 应该等待垂直同步则为 true，否则为 false。
		 * @param settings.msaa 抗锯齿样本数。
		 * @param settings.resizable 如果窗口应在窗口模式下调整大小，则为 true，否则为 false。
		 * @param settings.borderless 如果窗口在窗口模式下应无边框，则为 true，否则为 false。
		 * @param settings.centered 如果窗口应在窗口模式下居中，则为 true，否则为 false。
		 * @param settings.display 如果有多个监视器可用，则显示窗口的显示器索引。
		 * @param settings.minwidth 窗口的最小宽度（如果可以调整大小）。不能小于 1。
		 * @param settings.minheight 窗口的最小高度（如果可调整大小）。不能小于 1。
		 * @param settings.highdpi 如果应在 macOS 和 iOS 中的 Retina 显示屏上使用高 dpi 模式，则为 true。在非 Retina 显示器上不执行任何操作。
		 * @param settings.x 指定显示中窗口位置的 x 坐标。
		 * @param settings.y 指定显示中窗口位置的 y 坐标。
		 * @param width 窗口宽度。
		 * @param height 窗口高度。
		 *
		 * @returns success — 如果成功则为 true，否则为 false。
		 */
		updateMode(this: void, settings: WindowModeSettings): boolean;
		updateMode(this: void, width: number, height: number, settings?: WindowModeSettings): boolean;
		/**
		 * 获取窗口在屏幕上的位置。
		 *
		 * 窗口位置位于其当前所在显示器的坐标空间中。
		 *
		 * @returns x — 窗口位置的 x 坐标。
		 * @returns y — 窗口位置的 y 坐标。
		 * @returns displayindex — 窗口所在显示器的索引。
		 */
		getPosition(this: void): LuaMultiReturn<[number, number, number]>;
		/**
		 * 获取窗口内已知未被系统标题栏、iPhone X 缺口等遮挡的区域。有助于确保用户可以看到 UI 元素。
		 *
		 * 重载说明：
		 * 1. 返回的值采用 DPI 缩放单位（与大多数其他与窗口相关的 API 相同的坐标系），而不是像素。
		 *
		 * @returns x — 安全区域的起始位置（x 轴）。
		 * @returns y — 安全区域的起始位置（y 轴）。
		 * @returns w — 安全区域的宽度。
		 * @returns h — 安全区域的高度。
		 */
		getSafeArea(this: void): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 设置窗口标题。
		 *
		 * @param title 新窗口标题。
		 */
		setTitle(this: void, title: string): void;
		/**
		 * 获取窗口标题。
		 *
		 * @returns title — 当前窗口标题。
		 */
		getTitle(this: void): string;
		/**
		 * 设置垂直同步模式。
		 *
		 * 重载说明：
		 * 1. * 并非所有图形驱动程序都支持自适应垂直同步（-1 值）。在这种情况下，它将自动设置为 1。 * 如果您不知道关闭垂直同步可能产生的影响，建议保持垂直同步处于激活状态。 * 与 love.window.setMode 和 love.window.updateMode. 不同，该函数不会重新创建窗口
		 *
		 * @param vsync 垂直同步编号：1 表示启用，0 表示禁用，-1 表示自适应垂直同步。
		 */
		setVSync(this: void, vsync: boolean | number): void;
		/**
		 * 获取当前垂直同步（vsync）。
		 *
		 * 重载说明：
		 * 1. 如果您想获取当前的垂直同步状态，这可能是 love.window.getMode 的更便宜的替代方案。
		 *
		 * @returns vsync — 当前垂直同步状态。如果启用，则为 1；如果禁用，则为 0；如果为自适应垂直同步，则为 -1。
		 */
		getVSync(this: void): number;
		/**
		 * 设置程序运行时是否允许显示器休眠。
		 *
		 * 默认情况下禁用显示睡眠。如果允许显示器休眠，某些类型的输入（例如按下操纵杆按钮）可能不会阻止显示器休眠。
		 *
		 * @param enabled true 则启用系统显示睡眠， false 则禁用它。
		 */
		setDisplaySleepEnabled(this: void, enabled: boolean): void;
		/**
		 * 获取程序运行时是否允许显示器休眠。
		 *
		 * 默认情况下禁用显示睡眠。如果允许显示器休眠，某些类型的输入（例如按下操纵杆按钮）可能不会阻止显示器休眠。
		 *
		 * @returns enabled — 如果启用/允许系统显示睡眠则为 true，否则为 false。
		 */
		isDisplaySleepEnabled(this: void): boolean;
		/**
		 * 检查游戏窗口是否有键盘焦点。
		 *
		 * @returns focus — 如果窗口具有焦点则为 True，否则为 false。
		 */
		hasFocus(this: void): boolean;
		/**
		 * 检查游戏窗口是否有鼠标焦点。
		 *
		 * @returns focus — 如果窗口有鼠标焦点则为 true，否则为 false。
		 */
		hasMouseFocus(this: void): boolean;
		/**
		 * 检查游戏窗口是否可见。
		 *
		 * 如果窗口未最小化且程序未隐藏，则窗口被视为可见。
		 *
		 * @returns visible — 如果窗口可见则为 true，如果不可见则为 false。
		 */
		isVisible(this: void): boolean;
		/**
		 * 获取Window当前是否最大化。
		 *
		 * 如果窗口不是全屏且可调整大小，并且用户已按下窗口的最大化按钮或已调用 love.window.maximize ，则窗口可以最大化。
		 *
		 * @returns maximized — 如果窗口当前在窗口模式下最大化，则为 true，否则为 false。
		 */
		isMaximized(this: void): boolean;
		/**
		 * 获取窗口当前是否最小化。
		 *
		 * @returns minimized — 如果窗口当前最小化则为 true，否则为 false。
		 */
		isMinimized(this: void): boolean;
		/**
		 * 获取与窗口关联的 DPI 比例因子。
		 *
		 * 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用 1600x1200 像素。在这种情况下，love.window.getDPIScale() 将返回 2.0。
		 *
		 * love.window.fromPixels 和 love.window.toPixels 函数也可用于单位之间的转换。
		 *
		 * 必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android 上它实际上始终处于启用状态。
		 *
		 * 重载说明：
		 * 1. love.graphics.getWidth、love.graphics.getHeight、love.mouse.getPosition、鼠标事件、love.touch.getPosition 和触摸事件的单位始终以像素为单位。
		 *
		 * @returns scale — 与窗口关联的像素比例因子。
		 */
		getDPIScale(this: void): number;
		getNativeDPIScale(this: void): number;
		/**
		 * 将数字从与密度无关的单位转换为像素。
		 *
		 * 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用 1600x1200 像素。在这种情况下，love.window.toPixels(800) 将返回 1600。
		 *
		 * 这用于将坐标从用户期望它们在屏幕上显示的尺寸转换为像素。 love.window.fromPixels 则相反。必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android 上它实际上始终处于启用状态。
		 *
		 * 大多数 LÖVE 函数返回值并期望参数以像素为单位，而不是与密度无关的单位。
		 *
		 * 重载说明：
		 * 1. love.graphics.getWidth、love.graphics.getHeight、love.mouse.getPosition、鼠标事件、love.touch.getPosition 和触摸事件的单位始终以像素为单位。
		 *
		 * @param value 与密度无关的单位中要转换为像素的数字。
		 * @param x 以与密度无关的单位表示的坐标的 x 轴值，以转换为像素。
		 * @param y 以与密度无关的单位表示的坐标的 y 轴值，以转换为像素。
		 *
		 * @returns pixelvalue — 转换后的数字，以像素为单位。
		 * @returns px — 转换后的 x 轴坐标值，以像素为单位。
		 * @returns py — 转换后的 y 轴坐标值，以像素为单位。
		 */
		toPixels(this: void, value: number): number;
		toPixels(this: void, x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * 将数字从像素转换为与密度无关的单位。
		 *
		 * 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用 1600x1200 像素。在这种情况下，love.window.fromPixels(1600) 将返回 800。
		 *
		 * 此函数将坐标从像素转换为用户期望它们在屏幕上显示的大小。 love.window.toPixels 则相反。必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android 上它实际上始终处于启用状态。
		 *
		 * 大多数 LÖVE 函数返回值并期望参数以像素为单位，而不是与密度无关的单位。
		 *
		 * 重载说明：
		 * 1. love.graphics.getWidth、love.graphics.getHeight、love.mouse.getPosition、鼠标事件、love.touch.getPosition 和触摸事件的单位始终以像素为单位。
		 *
		 * @param value 以像素为单位的数字，要转换为与密度无关的单位。
		 * @param x 坐标的 x 轴值（以像素为单位）。
		 * @param y 坐标的 y 轴值（以像素为单位）。
		 *
		 * @returns value — 转换后的数字，采用与密度无关的单位。
		 * @returns x — 转换后的 x 轴坐标值，采用与密度无关的单位。
		 * @returns y — 转换后的 y 轴坐标值，采用与密度无关的单位。
		 */
		fromPixels(this: void, value: number): number;
		fromPixels(this: void, x: number, y: number): LuaMultiReturn<[number, number]>;
	}

	/** @noSelf */
	/** Manages events, like keypresses.
	 */
	interface Event {
		/** Dora already owns the platform event pump; this synchronizes no additional OS queue. */
		/**
		 * 将事件泵入事件队列。
		 *
		 * 这是一个低级函数，通常不由用户调用，而是由 love.run.
		 *
		 * 请注意，确实需要调用此命令才能让任何操作系统认为您仍在运行，
		 *
		 * 如果您想处理操作系统生成的事件（考虑回调）。
		 */
		pump(this: void): void;
		/**
		 * 返回事件队列中消息的迭代器。
		 *
		 * @returns i — 可在 for 循环中使用的迭代器函数。
		 */
		poll(this: void): () => LuaMultiReturn<[string, ...unknown[]] | []>;
		/** Returns immediately with no values when the embedded instance queue is empty. */
		/**
		 * 与 love.event.poll() 类似，但会阻塞，直到队列中有事件为止。
		 *
		 * @returns n — 事件名称。
		 * @returns a — 第一个事件参数。
		 * @returns b — 第二个事件参数。
		 * @returns c — 第三个事件参数。
		 * @returns d — 第四个事件参数。
		 * @returns e — 第五个事件参数。
		 * @returns f — 第六个事件参数。
		 * @returns ... — 可能会出现更多事件参数。
		 */
		wait(this: void): LuaMultiReturn<[string, ...unknown[]] | []>;
		/**
		 * 将事件添加到事件队列。
		 *
		 * 从 0.10.0 开始，您可以使用此函数传递任意数量的参数，但默认回调不会使用超过六个。
		 *
		 * @param name 事件的名称。
		 * @param args 第一个事件参数。 （默认值：无。）
		 */
		push(this: void, name: string, ...args: (boolean | number | string | LuaUserdata | undefined)[]): boolean;
		/**
		 * 清除事件队列。
		 */
		clear(this: void): void;
		/** Requests that only the current embedded Love instance stop. */
		/**
		 * 将退出事件添加到队列中。
		 *
		 * quit 事件是事件处理程序关闭 LÖVE 的信号。可以使用 love.quit 回调中止退出过程。
		 *
		 * 重载说明：
		 * 1. 重新启动游戏而不重新启动可执行文件。这会干净地关闭主 Lua 状态实例并创建一个全新的实例。
		 *
		 * @param exitStatus 关闭应用程序时使用的程序退出状态。 （默认值：0。）
		 * @param reason 关闭应用程序时使用的程序退出状态。 （默认值：0。）取决于重载：告诉默认的 love.run 退出并重新启动游戏，而不重新启动可执行文件。
		 */
		quit(this: void, exitStatus?: number): true;
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
		 * 获取字符串形式的完整数据。
		 *
		 * @returns data — 原始数据。
		 */
		getString(): string;
		/**
		 * 获取数据的大小（以字节为单位）。
		 *
		 * @returns size — 数据的大小（以字节为单位）。
		 */
		getSize(): number;
		/**
		 * 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
		 *
		 * @returns pointer — 指向数据的原始指针。
		 */
		getPointer(): LuaUserdata;
		/**
		 * 获取指向数据的 FFI 指针。
		 *
		 * 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
		 *
		 * @returns pointer — 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
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
		 * 创建数据对象的新副本。
		 *
		 * @returns clone — 新副本。
		 */
		clone(): CompressedData;
		/**
		 * 获取CompressedData的压缩格式。
		 *
		 * @returns format — 压缩数据的格式。
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
		 * 创建一个包含任意字节的新数据对象。
		 *
		 * Data:getPointer 与 LuaJIT 的 FFI 一起可用于在创建 ByteData 对象后对其内容进行操作。
		 *
		 * 重载说明：
		 * 1. 通过复制指定字符串的内容来创建新的 ByteData。
		 * 2. 通过从现有数据对象复制来创建新的 ByteData。
		 * 3. 创建一个具有特定大小的新空 ByteData。
		 *
		 * @param size 新数据对象的大小（以字节为单位）。 （默认值：data:getSize()。）取决于重载：新数据对象的大小（以字节为单位）。
		 * @param bytes 要复制的字节字符串。取决于重载：新数据对象的大小（以字节为单位）。
		 * @param data 要复制的现有数据对象。
		 * @param offset 要复制的子节的偏移量（以字节为单位）。 （默认值：0。）
		 *
		 * @returns bytedata — 新的数据对象。
		 */
		newByteData(this: void, size: number): ByteData;
		newByteData(this: void, bytes: string): ByteData;
		newByteData(this: void, data: Data, offset?: number, size?: number): ByteData;
		/**
		 * 创建引用现有数据对象的一部分的新数据。
		 *
		 * 重载说明：
		 * 1. Data:getString 和 Data:getPointer 将返回原始数据对象的内容，并应用视图的偏移量和大小。
		 *
		 * @param data 要引用的数据对象。
		 * @param offset 要引用的子节的偏移量（以字节为单位）。
		 * @param size 要引用的小节的大小（以字节为单位）。
		 *
		 * @returns view — 新的数据视图。
		 */
		newDataView(this: void, data: Data, offset: number, size: number): DataView;
		/**
		 * 将数据或字符串编码为采用一种编码格式的数据或字符串。
		 *
		 * @param container 返回编码数据的类型。
		 * @param format 输出数据的格式。
		 * @param source 要编码的原始数据。
		 * @param lineLength 输出的最大行长度。仅支持 base64，如果为 0，则忽略。（默认值：0。）
		 *
		 * @returns encoded — ByteData/string，其中包含源的编码版本。
		 */
		encode(this: void, container: "string", format: EncodeFormat, source: string | Data, lineLength?: number): string;
		encode(this: void, container: "data", format: EncodeFormat, source: string | Data, lineLength?: number): ByteData;
		/**
		 * 将数据或字符串从任何 EncodeFormat 解码为数据或字符串。
		 *
		 * @param container 解码后的数据返回什么类型。
		 * @param format 输入数据的格式。
		 * @param source 要解码的原始（编码）数据。
		 *
		 * @returns decoded — ByteData/string，其中包含源的解码版本。
		 */
		decode(this: void, container: "string", format: EncodeFormat, source: string | Data): string;
		decode(this: void, container: "data", format: EncodeFormat, source: string | Data): ByteData;
		/**
		 * 使用特定的压缩算法压缩字符串或数据。
		 *
		 * @param container 返回压缩数据的类型。
		 * @param format 压缩字符串时使用的格式。取决于过载：压缩数据时使用的格式。
		 * @param source 要压缩的原始（未压缩）字符串。取决于重载：包含要压缩的原始（未压缩）数据的数据对象。
		 * @param level 要使用的压缩级别，介于 0 和 9 之间。-1 表示默认级别。该参数的含义取决于所使用的压缩格式。 （默认值：-1。）
		 *
		 * @returns compressedData — 压缩数据/字符串，其中包含原始字符串的压缩版本。取决于重载：压缩数据/字符串，其中包含数据的压缩版本。
		 */
		compress(this: void, container: "string", format: CompressionFormat, source: string | Data, level?: number): string;
		compress(this: void, container: "data", format: CompressionFormat, source: string | Data, level?: number): CompressedData;
		/**
		 * 解压缩 CompressedData 或先前压缩的字符串或数据对象。
		 *
		 * @param container 解压后的数据返回什么类型。
		 * @param compressed 要解压的压缩数据。
		 * @param format 用于压缩给定字符串的格式。取决于过载：用于压缩给定数据的格式。
		 * @param source 包含先前使用 love.data.compress. 压缩的数据的字符串 取决于重载：包含先前使用 love.data.compress. 压缩的数据的数据对象
		 *
		 * @returns decompressedData — 包含原始解压缩数据的数据/字符串。
		 */
		decompress(this: void, container: "string", compressed: CompressedData): string;
		decompress(this: void, container: "data", compressed: CompressedData): ByteData;
		decompress(this: void, container: "string", format: CompressionFormat, source: string | Data): string;
		decompress(this: void, container: "data", format: CompressionFormat, source: string | Data): ByteData;
		/**
		 * 打包（序列化）简单的 Lua 值。
		 *
		 * 该函数的行为与 Lua 5.3 的 string.pack 相同。
		 *
		 * 重载说明：
		 * 1. 不支持打包大于 2^52 的整数，因为 Lua 5.1 无法用数字类型表示这些值。
		 *
		 * @param container 返回编码数据的类型。
		 * @param format 决定如何打包值的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
		 * @param values 要序列化的第一个值（数字、布尔值或字符串）。
		 *
		 * @returns data — 包含序列化数据的数据/字符串。
		 */
		pack(this: void, container: "string", format: string, ...values: any[]): string;
		pack(this: void, container: "data", format: string, ...values: any[]): ByteData;
		/**
		 * 将字节字符串或数据解包（反序列化）为简单的 Lua 值。
		 *
		 * 该函数的行为与 Lua 5.3 的 string.unpack 相同。
		 *
		 * 重载说明：
		 * 1. 不支持解包大于 2^52 的整数，因为 Lua 5.1 无法用数字类型表示这些值。
		 *
		 * @param format 确定值如何打包的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
		 * @param source 包含打包（序列化）数据的字符串。根据重载：包含打包（序列化）数据的数据对象。
		 * @param position 从哪里开始读取字符串。负值可用于从字符串末尾读取相对值。 （默认值：1。）取决于过载：从 1 开始的索引，指示从何处开始读取数据。负值可用于从数据对象末尾读取相对值。 （默认值：1。）
		 *
		 * @returns v1 — 解压的第一个值（数字、布尔值或字符串）。
		 * @returns ... — 附加解压值。
		 * @returns index — 数据字符串中第一个未读字节的索引。取决于过载：数据中第一个未读字节的从 1 开始的索引。
		 */
		unpack(this: void, format: string, source: string | Data, position?: number): LuaMultiReturn<any[]>;
		/**
		 * 获取与 love.data.pack 一起使用的给定格式将使用的大小（以字节为单位）。
		 *
		 * 该函数的行为与 Lua 5.3 的 string.packsize 相同。
		 *
		 * 重载说明：
		 * 1. 格式字符串不能有可变长度选项 's' 或 'z'。
		 *
		 * @param format 决定如何打包值的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
		 *
		 * @returns size — 打包数据将使用的大小（以字节为单位）。
		 */
		getPackedSize(this: void, format: string): number;
		/**
		 * 使用指定的哈希算法计算字符串的消息摘要。
		 *
		 * 重载说明：
		 * 1. 要返回哈希的十六进制字符串表示形式，请使用 love.data.encode hexDigestString = love.data.encode('string', 'hex', love.data.hash(algo, data))
		 *
		 * @param hashFunction 要使用的哈希算法。
		 * @param source 要散列的字符串。根据过载：要散列的数据。
		 *
		 * @returns rawdigest — 原始消息摘要字符串。
		 */
		hash(this: void, hashFunction: HashFunction, source: string | Data): string;
	}
	/** Data representing the contents of a file.
	 */
	interface FileData extends Data {
		/**
		 * 创建数据对象的新副本。
		 *
		 * @returns clone — 新副本。
		 */
		clone(): FileData;
		/**
		 * 获取FileData 的文件名。
		 *
		 * @returns name — FileData 代表的文件的名称。
		 */
		getFilename(): string;
		/**
		 * 获取FileData 的扩展名。
		 *
		 * @returns ext — FileData 代表的文件的扩展名。
		 */
		getExtension(): string;
	}
	/** Raw (decoded) image data.
	 */
	interface ImageData extends Data {
		/**
		 * 获取字符串形式的对象类型。
		 *
		 * @returns type — 字符串类型。
		 */
		type(): "ImageData";
		/**
		 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
		 *
		 * @param typeName 要检查的类型的名称。
		 *
		 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
		 */
		typeOf(typeName: string): boolean;
		/**
		 * 创建数据对象的新副本。
		 *
		 * @returns clone — 新副本。
		 */
		clone(): ImageData;
		/**
		 * 获取 ImageData 的宽度（以像素为单位）。
		 *
		 * @returns width — ImageData 的宽度（以像素为单位）。
		 */
		getWidth(): number;
		/**
		 * 获取 ImageData 的高度（以像素为单位）。
		 *
		 * @returns height — ImageData 的高度（以像素为单位）。
		 */
		getHeight(): number;
		/**
		 * 获取 ImageData 的宽度和高度（以像素为单位）。
		 *
		 * @returns width — ImageData 的宽度（以像素为单位）。
		 * @returns height — ImageData 的高度（以像素为单位）。
		 */
		getDimensions(): LuaMultiReturn<[number, number]>;
		/**
		 * 获取ImageData的像素格式。
		 *
		 * @returns format — 创建 ImageData 时使用的像素格式。
		 */
		getFormat(): ImagePixelFormat;
		/**
		 * 获取图像中特定位置的像素的颜色。
		 *
		 * 有效的 x 和 y 值从 0 开始，直到图像宽度和高度减 1。非整数值将被下限。
		 *
		 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
		 *
		 * @param x 像素在 x 轴上的位置。
		 * @param y 像素在 y 轴上的位置。
		 *
		 * @returns r — 红色分量 (0-1)。
		 * @returns g — 绿色分量 (0-1)。
		 * @returns b — 蓝色分量 (0-1)。
		 * @returns a — alpha 分量 (0-1)。
		 */
		getPixel(x: number, y: number): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 设置图像中特定位置的像素颜色。
		 *
		 * 有效的 x 和 y 值从 0 开始，直到图像宽度和高度减 1。
		 *
		 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
		 *
		 * @param x 像素在 x 轴上的位置。
		 * @param y 像素在 y 轴上的位置。
		 * @param red 红色分量 (0-1)。
		 * @param green 绿色分量 (0-1)。
		 * @param blue 蓝色分量 (0-1)。
		 * @param alpha alpha 分量 (0-1)。
		 */
		setPixel(x: number, y: number, red: number, green: number, blue: number, alpha?: number): void;
		/**
		 * 通过对每个像素应用函数来变换图像。
		 *
		 * 该函数是一个高阶函数。它采用另一个函数作为参数，并为 ImageData 中的每个像素调用一次。
		 *
		 * 传递的函数被依次调用，每个像素有六个参数。这些参数是代表像素的 x 和 y 坐标及其红色、绿色、蓝色和 alpha 值的数字。该函数应返回该像素的新红色、绿色、蓝色和 alpha 值。
		 *
		 * 函数pixelFunction(x,y,r,g,b,a)
		 *
		 * -- 用于定义您自己的像素映射函数的模板
		 *
		 * -- 执行计算，给出 r、g、b 和 a 的新值
		 *
		 * -- ...
		 *
		 * 返回r，g，b，a
		 *
		 * 结束
		 *
		 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
		 *
		 * @param mapper 应用于每个像素的函数。
		 * @param x ImageData 中要应用函数的区域左上角的 x 轴。 （默认值：0。）
		 * @param y ImageData 中要应用函数的区域左上角的 y 轴。 （默认值：0。）
		 * @param width ImageData 中应用函数的区域的宽度。 （默认：ImageData:getWidth()。）
		 * @param height ImageData 中要应用函数的区域的高度。 （默认：ImageData:getHeight()。）
		 */
		mapPixel(mapper: (x: number, y: number, red: number, green: number, blue: number, alpha: number) => LuaMultiReturn<[number, number, number, number]>, x?: number, y?: number, width?: number, height?: number): void;
		/**
		 * 从另一个源 ImageData 粘贴到 ImageData 中。
		 *
		 * 重载说明：
		 * 1. 请注意，此函数只是替换目标矩形中的内容；它不进行任何 alpha 混合。
		 *
		 * @param source 要从中复制的源图像数据。
		 * @param destinationX x 轴上的目标左上角位置。
		 * @param destinationY y 轴上的目标左上角位置。
		 * @param sourceX x 轴上的源左上角位置。
		 * @param sourceY y 轴上的源左上角位置。
		 * @param sourceWidth 源宽度。
		 * @param sourceHeight 源高度。
		 */
		paste(source: ImageData, destinationX: number, destinationY: number, sourceX?: number, sourceY?: number, sourceWidth?: number, sourceHeight?: number): void;
		/**
		 * 对 ImageData 进行编码并可选择将其写入保存目录。
		 *
		 * @param format 图像编码的格式。取决于重载：对图像进行编码的格式。
		 * @param filename 将文件写入的文件名。如果为 nil，则不会写入任何文件，但仍会返回 FileData。 （默认值：无。）
		 *
		 * @returns filedata — 作为新 FileData 对象的编码图像。
		 */
		encode(format: "png" | "tga", filename?: string): FileData;
	}
	/** Represents compressed image data designed to stay compressed in RAM.
	 */
	interface CompressedImageData extends Data {
		/**
		 * 获取字符串形式的对象类型。
		 *
		 * @returns type — 字符串类型。
		 */
		type(): "CompressedImageData";
		/**
		 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
		 *
		 * @param typeName 要检查的类型的名称。
		 *
		 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
		 */
		typeOf(typeName: string): boolean;
		/**
		 * 创建数据对象的新副本。
		 *
		 * @returns clone — 新副本。
		 */
		clone(): CompressedImageData;
		/**
		 * 获取压缩图像数据的宽度。
		 *
		 * @param mipmap mipmap 级别。必须在 CompressedImageData:getMipmapCount() 范围内。
		 *
		 * @returns width — 压缩图像数据的宽度。取决于重载： CompressedImageData 的特定 mipmap 级别的宽度。
		 */
		getWidth(mipmap?: number): number;
		/**
		 * 获取 CompressedImageData 的高度。
		 *
		 * @param mipmap mipmap 级别。必须在 CompressedImageData:getMipmapCount() 范围内。
		 *
		 * @returns height — 压缩图像数据的高度。取决于过载：压缩图像数据的特定 mipmap 级别的高度。
		 */
		getHeight(mipmap?: number): number;
		/**
		 * 获取 CompressedImageData 的宽度和高度。
		 *
		 * @param mipmap mipmap 级别。必须在 CompressedImageData:getMipmapCount() 范围内。
		 *
		 * @returns width — 压缩图像数据的宽度。取决于重载： CompressedImageData 的特定 mipmap 级别的宽度。
		 * @returns height — 压缩图像数据的高度。取决于过载：压缩图像数据的特定 mipmap 级别的高度。
		 */
		getDimensions(mipmap?: number): LuaMultiReturn<[number, number]>;
		/**
		 * 获取 CompressedImageData 中的 mipmap 级别数。基本 mipmap 级别（原始图像）包含在计数中。
		 *
		 * 重载说明：
		 * 1. Mipmap 过滤无法激活，会出现 Image:setMipmapFilter 错误。大多数可以创建压缩纹理的工具都能够在同一文件中自动为其生成 mipmap。
		 *
		 * @returns mipmaps — 压缩图像数据中存储的 mipmap 级别数。
		 */
		getMipmapCount(): number;
		/**
		 * 获取压缩图像数据的格式。
		 *
		 * @returns format — 压缩图像数据的格式。
		 */
		getFormat(): CompressedPixelFormat;
	}
	/** @noSelf */
	/** Provides an interface to decode encoded image data.
	 */
	interface ImageModule {
		/**
		 * 创建一个新的 ImageData 对象。
		 *
		 * @param width ImageData 的宽度。
		 * @param height ImageData 的高度。
		 * @param format ImageData 的像素格式。 （默认：'rgba8'。）
		 * @param data 可选的原始字节数据，以“'format'”指定的格式加载到 ImageData 中。 （默认值：nil。）取决于重载：要加载到 ImageData 中的数据（RGBA 字节，从左到右、从上到下）。
		 * @param filename 图像文件的文件名。
		 *
		 * @returns imageData — 新的空白 ImageData 对象。每个像素的颜色值（包括 Alpha 值！）将设置为零。取决于重载：新的 ImageData 对象。
		 */
		newImageData(this: void, width: number, height: number, format?: ImagePixelFormat, data?: string | FileData): ImageData;
		newImageData(this: void, filename: string): ImageData;
		newImageData(this: void, data: FileData): ImageData;
		/**
		 * 从压缩图像文件创建一个新的 CompressedImageData 对象。 LÖVE 支持多种压缩纹理格式，在 CompressedImageFormat 页面中列出。
		 *
		 * @param filenameOrData 压缩图像文件的文件名。取决于重载：包含压缩图像的 FileData。
		 *
		 * @returns compressedImageData — 新的 CompressedImageData 对象。
		 */
		newCompressedData(this: void, filenameOrData: string | Data): CompressedImageData;
		/**
		 * 确定文件是否可以作为 CompressedImageData 加载。
		 *
		 * @param filenameOrData 可能压缩的图像文件的文件名。根据重载：可能包含压缩图像的 FileData。
		 *
		 * @returns compressed — 文件是否可以作为 CompressedImageData 加载。取决于重载：FileData 是否可以作为 CompressedImageData 加载。
		 */
		isCompressed(this: void, filenameOrData: string | Data): boolean;
	}
	/** A Rasterizer handles font rendering, containing the font data (image or TrueType font) and drawable glyphs.
	 */
	interface Rasterizer extends Object {
		/**
		 * 获取字符串形式的对象类型。
		 *
		 * @returns type — 字符串类型。
		 */
		type(): "Rasterizer";
		/**
		 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
		 *
		 * @param typeName 要检查的类型的名称。
		 *
		 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
		 */
		typeOf(typeName: string): boolean;
		/**
		 * 获取字体高度。
		 *
		 * @returns height — 字体高度
		 */
		getHeight(): number;
		/**
		 * 获取字体提前。
		 *
		 * @returns advance — 字体提前。
		 */
		getAdvance(): number;
		/**
		 * 获取上升高度。
		 *
		 * @returns height — 上升高度。
		 */
		getAscent(): number;
		/**
		 * 获取下降高度。
		 *
		 * @returns height — 下降高度。
		 */
		getDescent(): number;
		/**
		 * 获取字体的行高。
		 *
		 * @returns height — 字体的行高。
		 */
		getLineHeight(): number;
		/**
		 * 获取指定字形的字形数据。
		 *
		 * @param glyph 字形
		 *
		 * @returns glyphData — 字形数据
		 */
		getGlyphData(glyph: string | number): GlyphData;
		/**
		 * 获取字体中的字形数量。
		 *
		 * @returns count — 字形计数。
		 */
		getGlyphCount(): number;
		/**
		 * 检查字体是否包含指定的字形。
		 *
		 * @param glyphs 字形
		 *
		 * @returns hasGlyphs — 任何包含指定字形的字体。
		 */
		hasGlyphs(...glyphs: (string | number)[]): boolean;
	}
	/** A GlyphData represents a drawable symbol of a font Rasterizer.
	 */
	interface GlyphData extends Data {
		/**
		 * 获取字符串形式的对象类型。
		 *
		 * @returns type — 字符串类型。
		 */
		type(): "GlyphData";
		/**
		 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
		 *
		 * @param typeName 要检查的类型的名称。
		 *
		 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
		 */
		typeOf(typeName: string): boolean;
		/**
		 * 创建数据对象的新副本。
		 *
		 * @returns clone — 新副本。
		 */
		clone(): GlyphData;
		/**
		 * 获取字形宽度。
		 *
		 * @returns width — 字形宽度。
		 */
		getWidth(): number;
		/**
		 * 获取字形高度。
		 *
		 * @returns height — 字形高度。
		 */
		getHeight(): number;
		/**
		 * 获取字形尺寸。
		 *
		 * @returns width — 字形宽度。
		 * @returns height — 字形高度。
		 */
		getDimensions(): LuaMultiReturn<[number, number]>;
		/**
		 * 获取字形编号。
		 *
		 * @returns glyph — 字形编号。
		 */
		getGlyph(): number;
		/**
		 * 获取字形字符串。
		 *
		 * @returns glyph — 字形字符串。
		 */
		getGlyphString(): string;
		/**
		 * 获取字形提前。
		 *
		 * @returns advance — 字形前进。
		 */
		getAdvance(): number;
		/**
		 * 获取字形方位。
		 *
		 * @returns bx — 字形轴承 X.
		 * @returns by — 字形轴承 Y。
		 */
		getBearing(): LuaMultiReturn<[number, number]>;
		/**
		 * 获取字形边界框。
		 *
		 * @returns x — 字形位置 x。
		 * @returns y — 字形位置 y。
		 * @returns width — 字形宽度。
		 * @returns height — 字形高度。
		 */
		getBoundingBox(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 获取字形像素格式。
		 *
		 * @returns format — 字形像素格式。
		 */
		getFormat(): "rgba8";
	}
	/** @noSelf */
	/** Allows you to work with fonts.
	 */
	interface FontModule {
		/**
		 * 创建一个新的图像光栅化器。
		 *
		 * 重载说明：
		 * 1. 从图像数据创建一个ImageRasterizer。
		 *
		 * @param imageData 字体图像数据。
		 * @param glyphs 包含字体字形的字符串。
		 * @param extraSpacing 字体额外间距。 （默认值：0。）
		 * @param dpiScale 字体 DPI 比例。 （默认值：1。）
		 *
		 * @returns rasterizer — 光栅器。
		 */
		newImageRasterizer(this: void, imageData: ImageData, glyphs: string, extraSpacing?: number, dpiScale?: number): Rasterizer;
		/**
		 * 创建一个新的 BMFont 光栅化器。
		 *
		 * @param filenameOrFileData 包含字体字形的可绘制图片的图像数据。取决于重载：包含字体字形的可绘制图片的文件的路径。
		 * @param images ImageData 中的字形序列。
		 * @param dpiScale DPI 比例。 （默认值：1。）
		 *
		 * @returns rasterizer — 光栅器。
		 */
		newBMFontRasterizer(this: void, filenameOrFileData: string | FileData, images?: ImageData | string | FileData | (ImageData | string | FileData)[], dpiScale?: number): Rasterizer;
		/**
		 * 创建一个新的 TrueType 光栅化器。
		 *
		 * 重载说明：
		 * 1. 使用默认字体创建 TrueTypeRasterizer。
		 * 2. 使用自定义字体创建 TrueTypeRasterizer。
		 *
		 * @param size 字体大小。 （默认值：12。）
		 * @param hinting True Type 提示模式。 （默认：'normal'。）
		 * @param dpiScale 字体 DPI 比例。 （默认：love.window.getDPIScale()。）
		 * @param filenameOrData 字体文件的路径。取决于重载：包含字体的文件数据。
		 *
		 * @returns rasterizer — 光栅器。
		 */
		newTrueTypeRasterizer(this: void, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		newTrueTypeRasterizer(this: void, filenameOrData: string | Data, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		/**
		 * 创建一个新的光栅化器。
		 *
		 * 重载说明：
		 * 1. 使用默认字体创建 TrueTypeRasterizer。
		 * 2. 使用自定义字体创建 TrueTypeRasterizer。
		 * 3. 创建一个新的 BMFont 光栅化器。
		 *
		 * @param size 字体大小。 （默认值：12。）
		 * @param hinting True Type 提示模式。 （默认：'normal'。）
		 * @param dpiScale 字体 DPI 比例。 （默认值：love.window.getDPIScale()。）取决于过载：DPI 比例。 （默认值：1。）
		 * @param filenameOrData 字体文件的路径。取决于重载：包含字体的文件数据。
		 *
		 * @returns rasterizer — 光栅器。
		 */
		newRasterizer(this: void, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		newRasterizer(this: void, filenameOrData: string | Data, size?: number, hinting?: "normal" | "light" | "mono" | "none", dpiScale?: number): Rasterizer;
		/**
		 * 创建一个新的 GlyphData。
		 *
		 * @param rasterizer 包含字体的光栅化器。
		 * @param glyph 字形的字符代码。
		 */
		newGlyphData(this: void, rasterizer: Rasterizer, glyph: string | number): GlyphData;
	}
	/** Contains raw audio samples.
	 */
	interface SoundData extends Data {
		/**
		 * 创建数据对象的新副本。
		 *
		 * @returns clone — 新副本。
		 */
		clone(): SoundData;
		/**
		 * 返回 SoundData 中的通道数。
		 *
		 * @returns channels — 1 用于单声道，2 用于立体声。
		 */
		getChannelCount(): number;
		/** Deprecated Love alias for getChannelCount. */
		getChannels(): number;
		/**
		 * 返回每个样本的位数。
		 *
		 * @returns bitdepth — 8 或 16。
		 */
		getBitDepth(): 8 | 16;
		/**
		 * 返回声音数据的采样率。
		 *
		 * @returns rate — 每秒的样本数。
		 */
		getSampleRate(): number;
		/**
		 * 返回 SoundData 每个通道的样本数。
		 *
		 * @returns count — 样本总数。
		 */
		getSampleCount(): number;
		/**
		 * 获取声音数据的持续时间。
		 *
		 * @returns duration — 声音数据的持续时间（以秒为单位）。
		 */
		getDuration(): number;
		/**
		 * 获取指定位置的采样点值。对于立体声 SoundData 对象，来自左声道和右声道的数据按该顺序交错。
		 *
		 * 重载说明：
		 * 1. 使用显式样本索引获取样本值，而不是将它们交错在样本位置参数中。
		 *
		 * @param index 指定样本位置的整数值（从 0 开始）。
		 * @param channel 给定样本中要获取的通道索引。
		 *
		 * @returns sample — 归一化采样点（范围 -1.0 到 1.0）。
		 */
		getSample(index: number, channel?: number): number;
		/**
		 * 设置指定位置的采样点值。对于立体声 SoundData 对象，来自左声道和右声道的数据按该顺序交错。
		 *
		 * 重载说明：
		 * 1. 使用显式样本索引设置样本值，而不是在样本位置参数中交错它们。
		 *
		 * @param index 指定样本位置的整数值（从 0 开始）。
		 * @param sample 归一化采样点（范围 -1.0 到 1.0）。
		 * @param channel 在给定样本中设置的通道索引。
		 */
		setSample(index: number, sample: number): void;
		setSample(index: number, channel: number, sample: number): void;
	}
	/** An object which can gradually decode a sound file.
	 */
	interface Decoder extends Object {
		/**
		 * 创建当前解码器的新副本。
		 *
		 * 新解码器将从音频流的开头开始解码。
		 *
		 * @returns decoder — 解码器的新副本。
		 */
		clone(): Decoder;
		/**
		 * 返回流中的通道数。
		 *
		 * @returns channels — 1 用于单声道，2 用于立体声。
		 */
		getChannelCount(): number;
		/** Deprecated Love alias for getChannelCount. */
		getChannels(): number;
		/**
		 * 返回每个样本的位数。
		 *
		 * @returns bitDepth — 8 或 16。
		 */
		getBitDepth(): 16;
		/**
		 * 返回解码器的采样率。
		 *
		 * @returns rate — 每秒的样本数。
		 */
		getSampleRate(): number;
		/**
		 * 获取声音文件的持续时间。它可能并不总是样本准确的，如果根本无法确定持续时间，它可能会返回 -1。
		 *
		 * @returns duration — 声音文件的持续时间（以秒为单位），如果无法确定则为 -1。
		 */
		getDuration(): number;
		/**
		 * 解码音频并返回包含解码后的音频数据的 SoundData 对象。
		 *
		 * @returns soundData — 解码的音频数据。
		 */
		decode(): SoundData | undefined;
		/**
		 * 设置解码器当前的播放位置。
		 *
		 * @param offset 要寻找的位置，以秒为单位。
		 */
		seek(offset: number): void;
	}
	/** @noSelf */
	/** This module is responsible for decoding sound files. It can't play the sounds, see love.audio for that.
	 */
	interface SoundModule {
		/**
		 * 尝试在指定文件中查找编码声音数据的解码器。
		 *
		 * @param filename 带有编码声音数据的文件的文件名。
		 * @param bufferSize 每个解码块的大小（以字节为单位）。 （默认值：2048。）
		 * @param data 包含编码声音数据的文件。取决于过载：带有编码声音数据的文件的文件名。
		 *
		 * @returns decoder — 一个新的解码器对象。
		 */
		newDecoder(this: void, filename: string, bufferSize?: number): Decoder;
		newDecoder(this: void, data: FileData, bufferSize?: number): Decoder;
		/**
		 * 从文件路径、文件或解码器创建新的 SoundData。还可以创建具有自定义采样率、通道和位深度的 SoundData。
		 *
		 * 声音数据将以原始格式解码到内存中。建议仅创建简短的声音（例如效果），因为这样 3 分钟的歌曲会使用 30 MB 的内存。
		 *
		 * @param samples 样本总数。
		 * @param sampleRate 每秒采样数（默认值：44100。）
		 * @param bitDepth 每个样本的位数（8 或 16）。 （默认值：16。）
		 * @param channels 1 表示单声道，2 表示立体声。 （默认值：2。）
		 * @param filename 要加载的文件的文件名。
		 * @param bufferSize 每秒采样数（默认值：44100。）
		 * @param data 要加载的文件的文件名。根据过载：指向音频文件的文件。根据过载：从此解码器解码数据直到 EOF。
		 * @param decoder 从该解码器解码数据直到 EOF。
		 *
		 * @returns soundData — 一个新的 SoundData 对象。
		 */
		newSoundData(this: void, samples: number, sampleRate?: number, bitDepth?: 8 | 16, channels?: number): SoundData;
		newSoundData(this: void, filename: string, bufferSize?: number): SoundData;
		newSoundData(this: void, data: FileData, bufferSize?: number): SoundData;
		newSoundData(this: void, decoder: Decoder): SoundData;
	}
	/** A random number generation object which has its own random state.
	 */
	interface RandomGenerator extends Object {
		/**
		 * 以独立于平台的方式生成伪随机数。
		 *
		 * 重载说明：
		 * 1. 获取1以内均匀分布的伪随机数。
		 * 2. 获取最大范围内均匀分布的伪随机整数
		 *
		 * @param upper 它应该返回的最大可能值。
		 * @param lower 它应该返回的最小可能值。
		 *
		 * @returns number — 伪随机数。取决于过载：伪随机整数。
		 */
		random(): number;
		random(upper: number): number;
		random(lower: number, upper: number): number;
		/**
		 * 获取正态分布的伪随机数。
		 *
		 * @param standardDeviation 分布的标准偏差。 （默认值：1。）
		 * @param mean 分布的平均值。 （默认值：0。）
		 *
		 * @returns number — 具有方差 (stddev)² 和指定平均值的正态分布随机数。
		 */
		randomNormal(standardDeviation?: number, mean?: number): number;
		/**
		 * 使用指定的整数设置随机数生成器的种子。
		 *
		 * 重载说明：
		 * 1. 由于Lua使用双精度浮点数，无法准确表示2^53以上的值。如果您的种子具有更大的值，请使用此函数的其他变体。
		 * 2. 将两个 32 位整数组合成一个 64 位整数值，并使用该值设置随机数生成器的种子。
		 *
		 * @param seed 您想要用于随机化种子的整数。必须在 2^53 范围内。
		 * @param low 种子值的低 32 位。必须在 2^32 - 1 范围内。
		 * @param high 种子值的高 32 位。必须在 2^32 - 1 范围内。
		 */
		setSeed(seed: number): void;
		setSeed(low: number, high: number): void;
		/**
		 * 获取随机数生成器对象的种子。
		 *
		 * 由于 Lua 对所有数值都使用双精度数，因此种子被分成两个数字 - 双精度数无法准确表示 2^53 以上的整数值，但种子值是 2^64 - 1 范围内的整数。
		 *
		 * @returns low — 表示 RandomGenerator 的 64 位种子值的低 32 位的整数。
		 * @returns high — 表示 RandomGenerator 的 64 位种子值的高 32 位的整数。
		 */
		getSeed(): LuaMultiReturn<[number, number]>;
		/**
		 * 设置随机数生成器的当前状态。用作此函数参数的值是一个不透明字符串，并且只能源自 LÖVE 的同一主要版本中之前对 RandomGenerator:getState 的调用。
		 *
		 * 这与 RandomGenerator:setSeed 不同，setState 直接设置 RandomGenerator 的当前依赖于实现的状态，而 setSeed 为其提供新的种子值。
		 *
		 * 重载说明：
		 * 1. 状态字符串的效果与当前操作系统无关。
		 *
		 * @param state RandomGenerator 对象的新状态，表示为字符串。这应该源自之前对 RandomGenerator:getState 的调用。
		 */
		setState(state: string): void;
		/**
		 * 获取随机数生成器的当前状态。这会返回一个不透明的字符串，该字符串仅适用于以后与 LÖVE 的相同主要版本中的 RandomGenerator:setState 一起使用。
		 *
		 * 这与 RandomGenerator:getSeed 不同，getState 获取 RandomGenerator 的当前状态，而 getSeed 获取之前设置的种子数。
		 *
		 * 重载说明：
		 * 1. 状态字符串的值不依赖于当前操作系统。
		 *
		 * @returns state — RandomGenerator 对象的当前状态，表示为字符串。
		 */
		getState(): string;
	}
	/** Object containing a coordinate system transformation.
	 */
	interface Transform extends Object {
		/**
		 * 创建此变换的新副本。
		 *
		 * @returns clone — 此变换的副本。
		 */
		clone(): Transform;
		/**
		 * 创建一个包含此变换的逆变换的新变换。
		 *
		 * @returns inverse — 一个新的 Transform 对象，表示此 Transform 矩阵的逆矩阵。
		 */
		inverse(): Transform;
		/**
		 * 将给定的其他 Transform 对象应用于此对象。
		 *
		 * 这有效地将此 Transform 的内部变换矩阵与其他 Transform 的（即 self * other）相乘，并将结果存储在此对象中。
		 *
		 * @param other 应用于此变换的另一个变换对象。
		 *
		 * @returns transform — 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
		 */
		apply(other: Transform): Transform;
		/**
		 * 检查变换是否是仿射变换。
		 *
		 * @returns affine — 如果变换对象是仿射变换，则为 true，否则为 false。
		 */
		isAffine2DTransform(): boolean;
		/**
		 * 将平移应用到变换的坐标系。此方法不会重置任何先前应用的转换。
		 *
		 * @param x 沿 x 轴的相对平移。
		 * @param y 沿 y 轴的相对平移。
		 *
		 * @returns transform — 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
		 */
		translate(x: number, y: number): Transform;
		/**
		 * 对变换的坐标系应用旋转。此方法不会重置任何先前应用的转换。
		 *
		 * @param angle 旋转此变换的相对角度（以弧度为单位）。
		 *
		 * @returns transform — 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
		 */
		rotate(angle: number): Transform;
		/**
		 * 缩放变换的坐标系。此方法不会重置任何先前应用的转换。
		 *
		 * @param x 沿 x 轴的相对比例因子。
		 * @param y 沿 y 轴的相对比例因子。 （默认值：sx。）
		 *
		 * @returns transform — 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
		 */
		scale(x: number, y?: number): Transform;
		/**
		 * 将剪切因子（倾斜）应用于变换的坐标系。此方法不会重置任何先前应用的转换。
		 *
		 * @param x 沿 x 轴的剪切因子。
		 * @param y 沿 y 轴的剪切因子。
		 *
		 * @returns transform — 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
		 */
		shear(x: number, y: number): Transform;
		/**
		 * 将变换重置为同一状态。所有先前应用的转换都将被删除。
		 *
		 * @returns transform — 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
		 */
		reset(): Transform;
		/**
		 * 将变换重置为指定的变换参数。
		 *
		 * @param x 变换在 x 轴上的位置。
		 * @param y 变换在 y 轴上的位置。
		 * @param angle 变换的方向（以弧度为单位）。 （默认值：0。）
		 * @param scaleX x 轴上的比例因子。 （默认值：1。）
		 * @param scaleY y 轴的比例因子。 （默认值：sx。）
		 * @param originX x 轴上的原点偏移。 （默认值：0。）
		 * @param originY y 轴上的原点偏移。 （默认值：0。）
		 * @param shearX x 轴上的剪切/倾斜因子。 （默认值：0。）
		 * @param shearY y 轴上的剪切/倾斜因子。 （默认值：0。）
		 *
		 * @returns transform — 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
		 */
		setTransformation(x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): Transform;
		/**
		 * 直接设置Transform的内部4x4变换矩阵。
		 *
		 * @param layout 如何解释矩阵元素参数（行优先或列优先）。
		 * @param elements 包含 16 个矩阵元素的平面表。取决于过载：一个由 4 个表组成的表，每个子表包含 4 个矩阵元素。取决于重载：如何解释矩阵元素参数（行优先或列优先）。
		 *
		 * @returns transform — 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
		 */
		setMatrix(layout: "row" | "column", elements: number[] | number[][]): Transform;
		setMatrix(elements: number[] | number[][]): Transform;
		/**
		 * 获取此Transform存储的内部4x4变换矩阵。矩阵按行优先顺序返回。
		 *
		 * @returns e1_1 — 矩阵第一行的第一列。
		 * @returns e1_2 — 矩阵第一行的第二列。
		 * @returns e1_3 — 矩阵第一行的第三列。
		 * @returns e1_4 — 矩阵第一行的第四列。
		 * @returns e2_1 — 矩阵第二行第一列。
		 * @returns e2_2 — 矩阵第二行的第二列。
		 * @returns e2_3 — 矩阵第二行第三列。
		 * @returns e2_4 — 矩阵第二行第四列。
		 * @returns e3_1 — 矩阵第三行第一列。
		 * @returns e3_2 — 矩阵第三行第二列。
		 * @returns e3_3 — 矩阵第三行第三列。
		 * @returns e3_4 — 矩阵第三行第四列。
		 * @returns e4_1 — 矩阵第四行第一列。
		 * @returns e4_2 — 矩阵第四行第二列。
		 * @returns e4_3 — 矩阵第四行第三列。
		 * @returns e4_4 — 矩阵第四行第四列。
		 */
		getMatrix(): LuaMultiReturn<[number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number]>;
		/**
		 * 将 Transform 对象的变换应用到给定的 2D 位置。
		 *
		 * 这有效地将给定位置从全局坐标转换到变换的局部坐标空间。
		 *
		 * @param x 全局坐标中位置的 x 分量。
		 * @param y 全局坐标中位置的 y 分量。
		 *
		 * @returns localX — 应用变换的位置的 x 分量。
		 * @returns localY — 应用变换的位置的 y 分量。
		 */
		transformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * 将 Transform 对象的变换反向应用到给定的 2D 位置。
		 *
		 * 这有效地将给定位置从变换的局部坐标空间转换为全局坐标。
		 *
		 * 如果给定的变换应用了用于游戏中相机系统的变换，则此方法的一种用途是将屏幕空间鼠标位置转换为全局世界坐标。
		 *
		 * @param x 应用变换的位置的 x 分量。
		 * @param y 应用变换的位置的 y 分量。
		 *
		 * @returns globalX — 全局坐标中位置的 x 分量。
		 * @returns globalY — 全局坐标中位置的 y 分量。
		 */
		inverseTransformPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
	}
	/** A Bézier curve object that can evaluate and render Bézier curves of arbitrary degree.
	 */
	interface BezierCurve extends Object {
		/**
		 * 获取贝塞尔曲线的阶数。次数等于控制点数 - 1。
		 *
		 * @returns degree — 贝塞尔曲线的阶数。
		 */
		getDegree(): number;
		/**
		 * 获取贝塞尔曲线的导数。
		 *
		 * 该函数可用于旋转沿着曲线移动的精灵的运动方向，并在某个参数 t 处计算垂直于曲线的方向。
		 *
		 * @returns derivative — 导数曲线。
		 */
		getDerivative(): BezierCurve;
		/**
		 * 获取第i个控制点的坐标。索引从 1 开始。
		 *
		 * @param index 控制点的索引。
		 *
		 * @returns x — 控制点沿 x 轴的位置。
		 * @returns y — 控制点沿 y 轴的位置。
		 */
		getControlPoint(index: number): LuaMultiReturn<[number, number]>;
		/**
		 * 设置第i个控制点的坐标。索引从 1 开始。
		 *
		 * @param index 控制点的索引。
		 * @param x 控制点沿 x 轴的位置。
		 * @param y 控制点沿 y 轴的位置。
		 */
		setControlPoint(index: number, x: number, y: number): void;
		/**
		 * 插入控制点作为新的第 i 个控制点。从 i 开始的现有控制点向后推 1。索引从 1 开始。负索引环绕：-1 是最后一个控制点，-2 是最后一个控制点之前的控制点，等等。
		 *
		 * @param x 控制点沿 x 轴的位置。
		 * @param y 控制点沿 y 轴的位置。
		 * @param index 控制点的索引。 （默认值：-1。）
		 */
		insertControlPoint(x: number, y: number, index?: number): void;
		/**
		 * 删除指定的控制点。
		 *
		 * @param index 要删除的控制点的索引。
		 */
		removeControlPoint(index: number): void;
		/**
		 * 获取贝塞尔曲线中控制点的数量。
		 *
		 * @returns count — 控制点数。
		 */
		getControlPointCount(): number;
		/**
		 * 将贝塞尔曲线移动一个偏移量。
		 *
		 * @param x 沿 x 轴的偏移。
		 * @param y 沿 y 轴的偏移。
		 */
		translate(x: number, y: number): void;
		/**
		 * 将贝塞尔曲线旋转一个角度。
		 *
		 * @param angle 以弧度为单位的旋转角度。
		 * @param originX 旋转中心的X坐标。 （默认值：0。）
		 * @param originY 旋转中心的Y坐标。 （默认值：0。）
		 */
		rotate(angle: number, originX?: number, originY?: number): void;
		/**
		 * 将贝塞尔曲线缩放一个因子。
		 *
		 * @param scale 比例因子。
		 * @param originX 缩放中心的X坐标。 （默认值：0。）
		 * @param originY 缩放中心的Y坐标。 （默认值：0。）
		 */
		scale(scale: number, originX?: number, originY?: number): void;
		/**
		 * 在参数 t 处评估贝塞尔曲线。该参数必须介于 0 和 1 之间（包含 0 和 1）。
		 *
		 * 此函数可用于沿路径或补间参数移动对象。但是，它不应该用于渲染曲线，为此目的请参阅 BezierCurve:render 。
		 *
		 * @param time 在哪里评估曲线。
		 *
		 * @returns x — 参数 t 处曲线的 x 坐标。
		 * @returns y — 参数 t 处曲线的 y 坐标。
		 */
		evaluate(time: number): LuaMultiReturn<[number, number]>;
		/**
		 * 获取与此 BezierCurve 的指定段相对应的 BezierCurve。
		 *
		 * @param start 沿曲线的起点。必须介于 0 和 1 之间。
		 * @param end 段结束。必须介于 0 和 1 之间。
		 *
		 * @returns curve — 与指定线段相对应的贝塞尔曲线。
		 */
		getSegment(start: number, end: number): BezierCurve;
		/**
		 * 获取要与love.graphics.line.
		 *
		 * 该函数使用递归细分对贝塞尔曲线进行采样。您可以使用深度参数控制递归深度。
		 *
		 * 如果您只是想知道给定参数的曲线上的位置，请使用 BezierCurve:evaluate。
		 *
		 * @param accuracy 递归细分步骤数。 （默认值：5。）
		 *
		 * @returns coordinates — 曲线上 x,y 坐标点对的列表。
		 */
		render(accuracy?: number): number[];
		/**
		 * 获取曲线特定部分的坐标列表，与 love.graphics.line.
		 *
		 * 该函数使用递归细分对贝塞尔曲线进行采样。您可以使用深度参数控制递归深度。
		 *
		 * 如果您只需要知道给定参数的曲线上的位置，请使用BezierCurve:evaluate。
		 *
		 * @param start 沿曲线的起点。必须介于 0 和 1 之间。
		 * @param end 要渲染的段的结尾。必须介于 0 和 1 之间。
		 * @param accuracy 递归细分步骤数。 （默认值：5。）
		 *
		 * @returns coordinates — 曲线指定部分上的点的 x,y 坐标对列表。
		 */
		renderSegment(start: number, end: number, accuracy?: number): number[];
	}
	/** @noSelf */
	/** Provides system-independent mathematical functions.
	 */
	interface MathModule {
		/**
		 * 创建一个新的 RandomGenerator 对象，该对象完全独立于其他 RandomGenerator 对象和随机函数。
		 *
		 * 重载说明：
		 * 1. 请参阅RandomGenerator:setSeed。
		 *
		 * @param seed 用于此对象的初始种子号。
		 * @param low 用于此对象的种子号的低 32 位。
		 * @param high 用于此对象的种子号的高 32 位。
		 *
		 * @returns rng — 新的随机数生成器对象。
		 */
		newRandomGenerator(this: void, seed?: number): RandomGenerator;
		newRandomGenerator(this: void, low: number, high: number): RandomGenerator;
		/**
		 * 创建一个新的 Transform 对象。
		 *
		 * 重载说明：
		 * 1. 创建一个未应用任何变换的变换。对返回的对象调用方法以应用转换。
		 * 2. 创建一个变换，并在创建时应用指定的变换。
		 *
		 * @param x 新变换在 x 轴上的位置。
		 * @param y 新变换在 y 轴上的位置。
		 * @param angle 新变换的方向（以弧度为单位）。 （默认值：0。）
		 * @param scaleX x 轴上的比例因子。 （默认值：1。）
		 * @param scaleY y 轴的比例因子。 （默认值：sx。）
		 * @param originX x 轴上的原点偏移。 （默认值：0。）
		 * @param originY y 轴上的原点偏移。 （默认值：0。）
		 * @param shearX x 轴上的剪切/倾斜因子。 （默认值：0。）
		 * @param shearY y 轴上的剪切/倾斜因子。 （默认值：0。）
		 *
		 * @returns transform — 新的变换对象。
		 */
		newTransform(this: void, x?: number, y?: number, angle?: number, scaleX?: number, scaleY?: number, originX?: number, originY?: number, shearX?: number, shearY?: number): Transform;
		/**
		 * 创建一个新的 BezierCurve 对象。
		 *
		 * 控制多边形中的顶点数决定了曲线的阶数，例如三个顶点定义二次（2 次）贝塞尔曲线，四个顶点定义三次（3 次）贝塞尔曲线，等等。
		 *
		 * @param vertices 控制多边形的顶点作为表格，形式为{x1, y1, x2, y2, x3, y3, ...}。
		 * @param coordinates 控制多边形的顶点作为表格，形式为{x1, y1, x2, y2, x3, y3, ...}。
		 *
		 * @returns curve — 贝塞尔曲线对象。
		 */
		newBezierCurve(this: void, vertices: number[]): BezierCurve;
		newBezierCurve(this: void, ...coordinates: number[]): BezierCurve;
		/**
		 * 生成 1-4 维的 Simplex 或 Perlin 噪声值。给定相同的参数，返回值将始终相同。
		 *
		 * 单纯形噪声与 Perlin 噪声密切相关。它广泛用于程序内容生成。
		 *
		 * 有很多网页详细讨论了 Perlin 和 Simplex 噪声。
		 *
		 * 重载说明：
		 * 1. 从一维生成单纯形噪声。
		 * 2. 从二维生成单纯形噪声。
		 * 3. 从 3 个维度生成 Perlin 噪声（0.9.2 及更早版本中的单纯形噪声）。
		 * 4. 从 4 个维度生成 Perlin 噪声（0.9.2 及更早版本中的单纯形噪声）。
		 *
		 * @param x 用于生成噪声值的数字。取决于过载：用于生成噪声值的二维向量的第一个值。取决于过载：用于生成噪声值的 3 维向量的第一个值。取决于过载：用于生成噪声值的 4 维向量的第一个值。
		 * @param y 用于生成噪声值的二维向量的第二个值。取决于过载：用于生成噪声值的 3 维向量的第二个值。取决于过载：用于生成噪声值的 4 维向量的第二个值。
		 * @param z 用于生成噪声值的三维向量的第三个值。取决于过载：用于生成噪声值的 4 维向量的第三个值。
		 * @param w 用于生成噪声值的 4 维向量的第四个值。
		 *
		 * @returns value — 1范围内的噪声值。
		 */
		noise(this: void, x: number, y?: number, z?: number, w?: number): number;
		/** Deprecated alias of love.data.compress. */
		compress(this: void, container: "string", format: CompressionFormat, source: string | Data, level?: number): string;
		compress(this: void, container: "data", format: CompressionFormat, source: string | Data, level?: number): CompressedData;
		/** Deprecated alias of love.data.decompress. */
		decompress(this: void, container: "string", compressed: CompressedData): string;
		decompress(this: void, container: "data", compressed: CompressedData): ByteData;
		/**
		 * 以独立于平台的方式生成伪随机数。默认的 love.run 在启动时为该函数设置种子，因此您通常不需要自己为其设置种子。
		 *
		 * 重载说明：
		 * 1. 获取1以内均匀分布的伪随机实数。
		 * 2. 获取最大范围内均匀分布的伪随机整数。
		 * 3. 获取最大范围内均匀分布的伪随机整数。
		 *
		 * @param upper 它应该返回的最大可能值。
		 * @param lower 它应该返回的最小可能值。
		 *
		 * @returns number — 伪随机数。取决于过载：伪随机整数。
		 */
		random(this: void): number;
		random(this: void, upper: number): number;
		random(this: void, lower: number, upper: number): number;
		/**
		 * 获取正态分布的伪随机数。
		 *
		 * @param standardDeviation 分布的标准偏差。 （默认值：1。）
		 * @param mean 分布的平均值。 （默认值：0。）
		 *
		 * @returns number — 具有方差 (stddev)² 和指定平均值的正态分布随机数。
		 */
		randomNormal(this: void, standardDeviation?: number, mean?: number): number;
		/**
		 * 使用指定的整数设置随机数生成器的种子。这是在启动时内部调用的，因此您通常不需要自己调用它。
		 *
		 * 重载说明：
		 * 1. 由于Lua使用双精度浮点数，无法准确表示2^53以上的整数值。如果您想使用更大的数字，请使用该函数的其他变体。
		 * 2. 将两个 32 位整数组合成一个 64 位整数值，并使用该值设置随机数生成器的种子。
		 *
		 * @param seed 您想要用于随机化种子的整数。必须在 2^53 - 1 范围内。
		 * @param low 种子值的低 32 位。必须在 2^32 - 1 范围内。
		 * @param high 种子值的高 32 位。必须在 2^32 - 1 范围内。
		 */
		setRandomSeed(this: void, seed: number): void;
		setRandomSeed(this: void, low: number, high: number): void;
		/**
		 * 获取随机数生成器的种子。
		 *
		 * 由于Lua对所有数值都使用双精度数，因此种子被分成两个数字 - 双精度数无法准确表示大于2^53的整数值，但种子可以是最大2^64的整数值。
		 *
		 * @returns low — 表示随机数生成器的 64 位种子值的低 32 位的整数。
		 * @returns high — 表示随机数生成器的 64 位种子值的高 32 位的整数。
		 */
		getRandomSeed(this: void): LuaMultiReturn<[number, number]>;
		/**
		 * 设置随机数生成器的当前状态。用作此函数参数的值是一个不透明的依赖于实现的字符串，并且只能源自先前对 love.math.getRandomState.
		 *
		 * 这与 love.math.setRandomSeed 不同，setRandomState 直接设置随机数生成器的当前依赖于实现的状态，而 setRandomSeed 为其提供新的种子值。
		 *
		 * 重载说明：
		 * 1. 状态字符串的效果与当前操作系统无关。
		 *
		 * @param state 随机数生成器的新状态，表示为字符串。这应该源自之前对 love.math.getRandomState.
		 */
		setRandomState(this: void, state: string): void;
		/**
		 * 获取随机数生成器的当前状态。这将返回一个不透明的依赖于实现的字符串，该字符串仅对以后与 love.math.setRandomState 或 RandomGenerator:setState 一起使用有用。
		 *
		 * 这与 love.math.getRandomSeed 不同，getRandomState 获取随机数生成器的当前状态，而 getRandomSeed 获取之前设置的种子数。
		 *
		 * 重载说明：
		 * 1. 状态字符串的值不依赖于当前操作系统。
		 *
		 * @returns state — 随机数生成器的当前状态，表示为字符串。
		 */
		getRandomState(this: void): string;
		/**
		 * 将颜色从 0..1 转换到 0..255 范围。
		 *
		 * 重载说明：
		 * 1. 这是 11.2 及更早版本的实现。函数 love.math.colorToBytes(r, g, b, a) if type(r) == 'table' then r, g, b, a = rr[2, rr[4 end r = 地板(clamp01(r) * 255 + 0.5) g = 地板(clamp01(g) * 255 + 0.5) b = 地板(clamp01(b) * 255 + 0.5) a = a ~= nil and Floor(clamp01(a) * 255 + 0.5) or nil return r, g, b, a end 其中clamp01定义如下局部函数clamp01(x) return math.min(math.max(x, 0), 1) end
		 *
		 * @param red 红色分量。
		 * @param green 绿色分量。
		 * @param blue 蓝色分量。
		 * @param alpha Alpha 颜色分量。 （默认值：无。）
		 * @param color 红色分量。
		 *
		 * @returns rb — 0..255 范围内的红色分量。
		 * @returns gb — 0..255 范围内的绿色分量。
		 * @returns bb — 0..255 范围内的蓝色分量。
		 * @returns ab — 0..255 范围内的 Alpha 颜色分量，如果未指定 alpha，则为零。
		 */
		colorToBytes(this: void, red: number, green: number, blue: number, alpha?: number): LuaMultiReturn<[number, number, number, number?]>;
		colorToBytes(this: void, color: number[]): LuaMultiReturn<[number, number, number, number?]>;
		/**
		 * 将颜色从 0..255 转换为 0..1 范围。
		 *
		 * 重载说明：
		 * 1. 这是 11.2 及更早版本的实现。函数 love.math.colorFromBytes(r, g, b, a) if type(r) == 'table' then r, g, b, a = rr[2, rr[4 end r = lamp01(floor(r + 0.5) / 255) g =限定器01(floor(g + 0.5) / 255) b =限定器01(floor(b + 0.5) / 255) a = a ~= nil并且clamp01(floor(a + 0.5) / 255) or nil return r, g, b, a end 其中clamp01定义如下局部函数clamp01(x) return math.min(math.max(x, 0), 1) end
		 *
		 * @param red 0..255 范围内的红色分量。
		 * @param green 0..255 范围内的绿色分量。
		 * @param blue 0..255 范围内的蓝色分量。
		 * @param alpha 0..255 范围内的 Alpha 颜色分量。 （默认值：无。）
		 * @param color 0..255 范围内的红色分量。
		 *
		 * @returns r — 0..1 范围内的红色分量。
		 * @returns g — 0..1 范围内的绿色分量。
		 * @returns b — 0..1 范围内的蓝色分量。
		 * @returns a — 0..1 范围内的 Alpha 颜色分量，如果未指定 alpha，则为零。
		 */
		colorFromBytes(this: void, red: number, green: number, blue: number, alpha?: number): LuaMultiReturn<[number, number, number, number?]>;
		colorFromBytes(this: void, color: number[]): LuaMultiReturn<[number, number, number, number?]>;
		/**
		 * 将颜色从伽玛空间 (sRGB) 转换为线性空间 (RGB)。这在进行伽马校正渲染时非常有用，并且在 LÖVE 无法自动处理转换的少数情况下，您需要使用线性 RGB 进行数学计算。
		 *
		 * 在此处、此处和此处阅读有关伽玛校正渲染的更多信息。
		 *
		 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
		 *
		 * 重载说明：
		 * 1. alpha 值可以作为第四个参数传递到函数中，但它将原封不动地返回，因为 alpha 始终是线性的。
		 *
		 * @param red 要转换的 sRGB 颜色的红色通道。
		 * @param green 要转换的 sRGB 颜色的绿色通道。
		 * @param blue 要转换的 sRGB 颜色的蓝色通道。
		 * @param color 一个数组，其中包含要转换的 sRGB 颜色的红色、绿色和蓝色通道。
		 *
		 * @returns lr — 线性 RGB 空间中转换颜色的红色通道。
		 * @returns lg — 线性 RGB 空间中转换颜色的绿色通道。
		 * @returns lb — 线性RGB空间中转换颜色的蓝色通道。
		 * @returns lc — 线性RGB空间中颜色通道的值。
		 */
		gammaToLinear(this: void, red: number, green?: number, blue?: number, alpha?: number): LuaMultiReturn<[number, number?, number?, number?]>;
		gammaToLinear(this: void, color: number[]): LuaMultiReturn<[number, number?, number?, number?]>;
		/**
		 * 将颜色从线性空间 (RGB) 转换为伽玛空间 (sRGB)。这在图像中存储线性 RGB 颜色值时非常有用，因为对于深色，线性 RGB 颜色空间的精度低于 sRGB，这可能会导致绘图时出现明显的色带。
		 *
		 * 一般来说，根据屏幕上的外观选择的颜色已经在伽马空间中，不应该进行双重转换。使用数学计算的颜色通常位于线性 RGB 空间中。
		 *
		 * 在此处、此处和此处阅读有关伽玛校正渲染的更多信息。
		 *
		 * 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
		 *
		 * 重载说明：
		 * 1. alpha 值可以作为第四个参数传递到函数中，但它将原封不动地返回，因为 alpha 始终是线性的。
		 *
		 * @param red 要转换的线性 RGB 颜色的红色通道。
		 * @param green 要转换的线性 RGB 颜色的绿色通道。
		 * @param blue 要转换的线性 RGB 颜色的蓝色通道。
		 * @param color 一个数组，其中包含要转换的线性 RGB 颜色的红色、绿色和蓝色通道。
		 *
		 * @returns cr — gamma sRGB 空间中转换颜色的红色通道。
		 * @returns cg — gamma sRGB 空间中转换颜色的绿色通道。
		 * @returns cb — gamma sRGB 空间中转换颜色的蓝色通道。
		 * @returns c — gamma sRGB 空间中颜色通道的值。
		 */
		linearToGamma(this: void, red: number, green?: number, blue?: number, alpha?: number): LuaMultiReturn<[number, number?, number?, number?]>;
		linearToGamma(this: void, color: number[]): LuaMultiReturn<[number, number?, number?, number?]>;
		/**
		 * 检查多边形是否为凸多边形。
		 *
		 * love.physics 中的 PolygonShapes、某些形式的网格以及使用 love.graphics.polygon 绘制的多边形必须是简单的凸多边形。
		 *
		 * @param vertices 多边形的顶点作为表格，形式为{x1, y1, x2, y2, x3, y3, ...}。
		 * @param coordinates 多边形的顶点作为表格，形式为{x1, y1, x2, y2, x3, y3, ...}。
		 *
		 * @returns convex — 给定的多边形是否是凸的。
		 */
		isConvex(this: void, vertices: number[]): boolean;
		isConvex(this: void, ...coordinates: number[]): boolean;
		/**
		 * 将简单的凸多边形或凹多边形分解为三角形。
		 *
		 * @param vertices 用于三角测量的多边形。不得与自身相交。
		 * @param coordinates 用于三角测量的多边形。不得与自身相交。
		 *
		 * @returns triangles — 多边形组成的三角形列表，格式为 {{x1, y1, x2, y2, x3, y3}, {x1, y1, x2, y2, x3, y3}, ...}。
		 */
		triangulate(this: void, vertices: number[]): number[][];
		triangulate(this: void, ...coordinates: number[]): number[][];
	}
	/** Represents a file on the filesystem. A function that takes a file path can also take a File.
	 */
	interface File extends Object {
		/**
		 * 打开文件进行写入、读取或追加。
		 *
		 * 重载说明：
		 * 1. 如果您收到错误消息'Could not set write directory'，请尝试设置保存目录。这可以通过 love.filesystem.setIdentity 或通过在 love.conf 中设置身份字段来完成（仅适用于 love 0.7 或更高版本）。
		 *
		 * @param mode 打开文件的模式。
		 *
		 * @returns ok — 成功则为 true，否则为 false。
		 * @returns err — 发生错误时的错误字符串。
		 */
		open(mode: OpenFileMode): LuaMultiReturn<[true | undefined, string?]>;
		/**
		 * 关闭文件。
		 *
		 * @returns success — 是否关闭成功。
		 */
		close(): boolean;
		/**
		 * 获取文件是否打开。
		 *
		 * @returns open — 如果文件当前打开则为 true，否则为 false。
		 */
		isOpen(): boolean;
		/**
		 * 返回文件大小。
		 *
		 * @returns size — 文件大小（以字节为单位）。
		 */
		getSize(): LuaMultiReturn<[number | undefined, string?]>;
		/**
		 * 从文件中读取多个字节。
		 *
		 * 重载说明：
		 * 1. 将文件的内容读入字符串或 FileData 对象。
		 *
		 * @param size 要读取的字节数。 （默认值：全部。）
		 * @param container 返回文件内容的类型。
		 *
		 * @returns contents — 读取字节的内容。取决于重载：FileData 或包含读取字节的字符串。
		 * @returns size — 已读取多少字节。
		 */
		read(size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(container: "string", size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(container: "data", size?: number): LuaMultiReturn<[FileData | undefined, number | string]>;
		/**
		 * 将数据写入文件。
		 *
		 * 重载说明：
		 * 1. '''Writing to multiple lines''': In Windows, some text editors (e.g. Notepad before Windows 10 1809) only treat CRLF ('\r\n') 作为新行。 --example f = love.filesystem.newFile('note.txt') f:open('w') for i = 1, 10 do f:write('This is line '..i..'!\r\n') end f:close()
		 *
		 * @param data 要写入的字符串数据。取决于重载：要写入的数据对象。
		 * @param size 要写入多少字节。 （默认值：全部。）
		 *
		 * @returns success — 操作是否成功。
		 * @returns err — 发生错误时的错误字符串。
		 * @returns errorstr — 发生错误时的错误字符串。
		 */
		write(data: string | FileData, size?: number): LuaMultiReturn<[true | undefined, string?]>;
		/**
		 * 将文件中所有缓冲的写入数据刷新到磁盘。
		 *
		 * @returns success — 文件是否成功将任何缓冲数据刷新到磁盘。
		 * @returns err — 错误字符串，如果发生错误并且文件无法刷新。
		 */
		flush(): LuaMultiReturn<[true | undefined, string?]>;
		/**
		 * 获取是否已到达文件结尾。
		 *
		 * @returns eof — 是否已到达EOF。
		 */
		isEOF(): boolean;
		/**
		 * 返回文件中的位置。
		 *
		 * @returns pos — 当前位置。
		 */
		tell(): LuaMultiReturn<[number | undefined, string?]>;
		/**
		 * 查找文件中的位置
		 *
		 * @param position 寻求
		 *
		 * @returns success — 操作是否成功
		 */
		seek(position: number): boolean;
		/**
		 * 迭代文件中的所有行。
		 *
		 * @returns iterator — 迭代器（可用于 for 循环）。
		 */
		lines(): () => string | undefined;
		/**
		 * 设置为写入或追加而打开的文件的缓冲模式。启用缓冲的文件在达到缓冲区大小限制之前不会将数据写入磁盘，具体取决于缓冲模式。
		 *
		 * File:flush 将强制将所有缓冲数据写入磁盘。
		 *
		 * @param mode 要使用的缓冲模式。
		 * @param size 文件缓冲区的最大大小（以字节为单位）。 （默认值：0。）
		 *
		 * @returns success — 缓冲模式是否设置成功。
		 * @returns errorstr — 错误字符串，如果无法设置缓冲模式并且发生错误。
		 */
		setBuffer(mode: BufferMode, size?: number): boolean;
		/**
		 * 获取文件的缓冲模式。
		 *
		 * @returns mode — 文件当前的缓冲模式。
		 * @returns size — 文件缓冲区的最大大小（以字节为单位）。
		 */
		getBuffer(): LuaMultiReturn<[BufferMode, number]>;
		/**
		 * 获取打开文件的FileMode。
		 *
		 * @returns mode — 此文件打开的模式。
		 */
		getMode(): FileMode;
		/**
		 * 获取创建 File 对象时使用的文件名。如果文件对象源自 love.filedropped 回调，则文件名将是完整的与平台相关的文件路径。
		 *
		 * @returns filename — 文件的文件名。
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
		 * 设置游戏的写入目录。
		 *
		 * 请注意，您只能设置用于存储文件的文件夹名称，而不能设置位置。
		 *
		 * @param identity 将用作写入目录的新标识。
		 */
		setIdentity(this: void, identity: string, appendToPath?: boolean): void;
		/**
		 * 获取游戏的写入目录名称。
		 *
		 * 请注意，这仅返回存储文件的文件夹的名称，而不是完整路径。
		 *
		 * @returns name — 用作写入目录的标识。
		 */
		getIdentity(this: void): string;
		/**
		 * 返回 .love 文件或目录的完整路径。如果游戏融合到 LÖVE 可执行文件，则返回可执行文件。
		 *
		 * @returns path — .love 文件或目录的完整平台相关路径。
		 */
		getSource(this: void): string;
		/**
		 * 获取指定保存目录的完整路径。
		 *
		 * 如果您想使用标准 io 库（或其他库）来
		 *
		 * 在保存目录中读取或写入。
		 *
		 * @returns dir — 保存目录的绝对路径。
		 */
		getSaveDirectory(this: void): string;
		/**
		 * 获取当前工作目录。
		 *
		 * @returns cwd — 当前工作目录。
		 */
		getWorkingDirectory(this: void): string;
		/**
		 * 返回用户目录
		 *
		 * @returns path — 用户目录的路径
		 */
		getUserDirectory(this: void): string;
		/**
		 * 返回应用程序数据目录（可能与 getUserDirectory 相同）
		 *
		 * @returns path — 应用程序数据目录的路径
		 */
		getAppdataDirectory(this: void): string;
		/**
		 * 返回包含 .love 文件的目录的完整路径。如果游戏融合到 LÖVE 可执行文件，则返回包含可执行文件的目录。
		 *
		 * 如果 love.filesystem.isFused 为 true，则该函数返回的路径可以传递给 love.filesystem.mount，这将使包含主游戏的目录（例如 C:\Program Files\coolgame\）可以被 love.filesystem. 读取
		 *
		 * @returns path — 包含 .love 文件的目录的完整平台相关路径。
		 */
		getSourceBaseDirectory(this: void): string;
		getExecutablePath(this: void): string;
		/**
		 * 获取包含文件路径的目录的特定于平台的绝对路径。
		 *
		 * 这可用于确定文件是否位于保存目录或游戏源.love 内。
		 *
		 * 重载说明：
		 * 1. 该函数返回包含给定“'file path'”的目录，而不是文件。例如，如果文件 snapshot1.png 存在于游戏保存目录中名为 snapshots 的目录中，则 love.filesystem.getRealDirectory('screenshots/screenshot1.png') 将返回与 love.filesystem.getSaveDirectory.
		 *
		 * @param filename 要获取目录的文件路径。
		 *
		 * @returns realdir — 包含文件路径的目录的特定于平台的完整路径。
		 */
		getRealDirectory(this: void, filename: string): LuaMultiReturn<[string | undefined, string?]>;
		/**
		 * 获取调用 require 时将搜索的文件系统路径。
		 *
		 * 该函数返回的路径字符串是由分号分隔的路径模板序列。传递给 ''require'' will be inserted in place of any question mark ('?') character in each template (after the dot characters in the argument passed to ''require'' 的参数被目录分隔符替换。）
		 *
		 * 路径相对于游戏的源目录和保存目录，以及使用 love.filesystem.mount.
		 *
		 * 重载说明：
		 * 1. 默认路径字符串是'?.lua;?/init.lua'，这使得require('cool')尝试加载cool.lua，然后尝试cool/init.lua（如果cool.lua不存在）。
		 *
		 * @returns paths — ''require''函数将在love的文件系统中检查的路径。
		 */
		getRequirePath(this: void): string;
		/**
		 * 设置调用 require 时将搜索的文件系统路径。
		 *
		 * 提供给此函数的路径字符串是由分号分隔的路径模板序列。传递给 ''require'' will be inserted in place of any question mark ('?') character in each template (after the dot characters in the argument passed to ''require'' 的参数被目录分隔符替换。）
		 *
		 * 路径相对于游戏的源目录和保存目录，以及使用 love.filesystem.mount.
		 *
		 * 重载说明：
		 * 1. 默认路径字符串是'?.lua;?/init.lua'，这使得require('cool')尝试加载cool.lua，然后尝试cool/init.lua（如果cool.lua不存在）。
		 *
		 * @param path ''require''函数将在love的文件系统中检查的路径。
		 */
		setRequirePath(this: void, path: string): void;
		/**
		 * 在游戏的保存目录中安装zip文件或文件夹以供读取。
		 *
		 * 如果游戏处于融合模式，也可以挂载love.filesystem.getSourceBaseDirectory。
		 *
		 * 重载说明：
		 * 1. 将给定 FileData 的内容装载到内存中。 FileData 的数据必须包含压缩的目录结构。
		 * 2. 将给定数据对象的内容装载到内存中。数据必须包含压缩目录结构。
		 *
		 * @param archive 游戏保存目录中要挂载的文件夹或zip文件。
		 * @param mountpoint 存档将安装到的新路径。
		 * @param appendToPath 读取已安装存档之前或之后的文件路径时是否搜索存档。这包括游戏的源目录和保存目录。 （默认值：假。）
		 *
		 * @returns success — 如果存档已成功安装，则为 true，否则为 false。
		 */
		mount(this: void, archive: string | FileData, mountpoint: string, appendToPath?: boolean): boolean;
		/**
		 * 卸载之前使用 love.filesystem.mount.
		 *
		 * @param archive 当前挂载的游戏保存目录中的文件夹或zip文件。
		 *
		 * @returns success — 如果存档已成功卸载，则为 true，否则为 false。
		 */
		unmount(this: void, archive: string | FileData): boolean;
		/**
		 * 获取游戏是否处于融合模式。
		 *
		 * 如果游戏处于融合模式，其保存目录将直接位于Appdata目录中，而不是Appdata/LOVE/中。游戏还能够加载位于保存目录中的 C Lua 动态库。
		 *
		 * 如果源 .love 已融合到可执行文件（请参阅游戏分发），或者在启动游戏时将 '--fused' 作为命令行参数给出，则游戏处于融合模式。
		 *
		 * @returns fused — 如果游戏处于融合模式则为 true，否则为 false。
		 */
		isFused(this: void): false;
		/**
		 * 创建一个新的文件对象。
		 *
		 * 需要打开才可以访问。
		 *
		 * 重载说明：
		 * 1. 请注意，此函数不会返回任何错误消息（例如，如果您使用无效的文件名），因为它只是创建文件对象。您仍然可以使用 File:open 检查文件是否有效，如果打开文件时出现问题，它会返回一个布尔值和一条错误消息。
		 * 2. 创建一个 File 对象并打开它以进行读取、写入或追加。
		 *
		 * @param filename 文件的文件名。
		 * @param mode 打开文件的模式。
		 *
		 * @returns file — 新的文件对象。取决于重载：新的 File 对象，如果发生错误则为 nil。
		 * @returns errorstr — 发生错误时的错误字符串。
		 */
		newFile(this: void, filename: string, mode?: OpenFileMode): File;
		/**
		 * 从磁盘上的文件或内存中的字符串创建一个新的 FileData 对象。
		 *
		 * 重载说明：
		 * 1. 从内存中的字符串创建一个新的 FileData 对象。
		 * 2. 从内存中的 Data 对象创建一个新的 FileData 对象。
		 * 3. 从存储设备上的文件创建新的 FileData。
		 *
		 * @param filename 文件路径。取决于过载：文件的名称。当将 FileData 对象传递到 love.audio.newSource.
		 * @param file 文件路径。
		 * @param data 内存中文件的内容表示为字符串。根据重载：要复制到新 FileData 对象中的 Data 对象。
		 *
		 * @returns data — 新的文件数据。取决于重载：新的 FileData，如果发生错误则为零。
		 * @returns err — 错误字符串（如果发生错误）。
		 */
		newFileData(this: void, filename: string): FileData;
		newFileData(this: void, file: File): FileData;
		newFileData(this: void, data: string, filename: string): FileData;
		/**
		 * 读取文件的内容。
		 *
		 * 重载说明：
		 * 1. 将文件的内容读入字符串或 FileData 对象。
		 *
		 * @param filename 文件的名称（和路径）。取决于重载：文件的名称（和路径）
		 * @param size 读取多少字节。 （默认：全部。）取决于过载：读取多少字节（默认：全部。）
		 * @param container 返回文件内容的类型。
		 *
		 * @returns contents — 文件内容。根据重载：返回 nil 作为内容。取决于重载：FileData 或包含文件内容的字符串。
		 * @returns size — 已读取多少字节。
		 * @returns error — 返回错误消息。
		 */
		read(this: void, filename: string, size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(this: void, container: "string", filename: string, size?: number): LuaMultiReturn<[string | undefined, number | string]>;
		read(this: void, container: "data", filename: string, size?: number): LuaMultiReturn<[FileData | undefined, number | string]>;
		/**
		 * 加载 Lua 文件（但不运行它）。
		 *
		 * @param filename 文件的名称（和路径）。
		 *
		 * @returns chunk — 加载的块。
		 * @returns errormsg — 文件无法打开时的错误消息。
		 */
		load(this: void, filename: string): LuaMultiReturn<[((...args: unknown[]) => unknown) | undefined, string?]>;
		/**
		 * 迭代文件中的行。
		 *
		 * @param filename 文件的名称（和路径）
		 *
		 * @returns iterator — 迭代文件
		 */
		lines(this: void, filename: string): () => string | undefined;
		/**
		 * 将数据写入保存目录中的文件。如果该文件已经存在，它将被新内容完全替换。
		 *
		 * 重载说明：
		 * 1. 如果您收到错误消息'Could not set write directory'，请尝试设置保存目录。这可以使用 love.filesystem.setIdentity 或通过将 love.conf. '''Writing to multiple lines''': In Windows, some text editors (e.g. Notepad) only treat CRLF ('\r\n') 中的标识字段设置为新行来完成。
		 *
		 * @param filename 文件的名称（和路径）。
		 * @param data 要写入文件的字符串数据。根据重载：要写入文件的数据对象。
		 * @param size 要写入多少字节。 （默认值：全部。）
		 *
		 * @returns success — 如果操作成功。
		 * @returns message — 如果操作不成功，则会出现错误消息。
		 */
		write(this: void, filename: string, data: string | FileData, size?: number): LuaMultiReturn<[boolean, string?]>;
		/**
		 * 将数据附加到现有文件。
		 *
		 * @param filename 文件的名称（和路径）。
		 * @param data 要附加到文件的字符串数据。根据重载：要附加到文件的数据对象。
		 * @param size 要写入多少字节。 （默认值：全部。）
		 *
		 * @returns success — 如果操作成功则为 True，如果有错误则为 nil。
		 * @returns errormsg — 失败时的错误消息。
		 */
		append(this: void, filename: string, data: string | FileData, size?: number): LuaMultiReturn<[boolean, string?]>;
		/**
		 * 获取有关指定文件或目录的信息。
		 *
		 * 重载说明：
		 * 1. 此变体接受要填充的现有表，而不是创建新表。
		 * 2. 如果给定路径中的项目与 filtertype 参数中指定的文件类型相同，则此变体仅返回信息，并接受现有表进行填充，而不是创建新表。
		 *
		 * @param filename 要检查的文件或目录路径。
		 * @param filterType 如果提供，此参数将导致 getInfo 仅在给定路径中的项目与指定文件类型匹配时返回信息表。 （默认值：nil。）取决于重载：如果给定路径中的项目与指定的文件类型匹配，则导致 getInfo 仅返回信息表。
		 *
		 * @returns info — 包含有关指定路径的信息的表，如果路径中不存在任何内容，则为零。该表包含以下字段： 取决于重载：作为参数给出的表，如果路径中不存在任何内容，则为 nil。该表将填写以下字段：
		 * @returns info.type — 路径处对象的类型（文件、目录、符号链接等）
		 * @returns info.size — 文件的大小（以字节为单位），如果无法确定则为零。
		 * @returns info.modtime — 自unix 纪元以来文件的最后修改时间（以秒为单位），如果无法确定则为零。
		 */
		getInfo(this: void, filename: string, filterType?: FileType): FileInfo | undefined;
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
		 * 递归创建一个目录。
		 *
		 * 当使用 'a/b' 调用时，它会创建 'a' 和 'a/b'（如果它们尚不存在）。
		 *
		 * @param name 要创建的目录。
		 *
		 * @returns success — 如果目录已创建则为 True，否则为 false。
		 */
		createDirectory(this: void, name: string): LuaMultiReturn<[boolean, string?]>;
		/**
		 * 删除文件或空目录。
		 *
		 * 重载说明：
		 * 1. 删除前目录必须为空，否则会失败。只需事先删除目录中的所有文件和文件夹即可。如果文件存在于 .love 但不存在于保存目录中，它也会返回 false。打开的文件会阻止删除底层文件。只需关闭文件即可将其删除。
		 *
		 * @param name 要删除的文件或目录。
		 *
		 * @returns success — 如果文件/目录被删除则为 true，否则为 false。
		 */
		remove(this: void, name: string): LuaMultiReturn<[boolean, string?]>;
		/**
		 * 返回一个表，其中包含指定路径中的文件和子目录的名称。该表未以任何方式排序；顺序未定义。
		 *
		 * 如果传递给函数的路径存在于游戏和保存目录中，它将列出两个地方的文件和目录。
		 *
		 * @param directory 目录。
		 *
		 * @returns files — 以字符串形式包含所有文件和子目录名称的序列。
		 */
		getDirectoryItems(this: void, directory?: string): string[];
	}

	/** @noSelf */
	/** Provides an interface to the user's keyboard.
	 */
	interface Keyboard {
		/**
		 * 启用或禁用 love.keypressed. 的按键重复 默认情况下禁用。
		 *
		 * 重载说明：
		 * 1. 重复之间的间隔取决于用户的系统设置。此函数不会影响按住某个键时是否多次调用 love.textinput 。
		 *
		 * @param enabled 按住某个键时是否应启用重复按键事件。
		 */
		setKeyRepeat(this: void, enabled: boolean): void;
		/**
		 * 获取是否启用按键重复。
		 *
		 * @returns enabled — 是否启用按键重复。
		 */
		hasKeyRepeat(this: void): boolean;
		/**
		 * 检查某个键是否按下。不要与 love.keypressed 或 love.keyreleased.
		 *
		 * @param keys 包含要检查的键的表。
		 *
		 * @returns down — 如果按键按下则为 True，否则为 false。
		 * @returns anyDown — 如果提供的任何键按下则为 true，否则为 false。取决于过载：如果表中的任何键已关闭，则为 true，否则为 false。
		 */
		isDown(this: void, ...keys: string[]): boolean;
		isDown(this: void, keys: string[]): boolean;
		/**
		 * 检查指定的扫描码是否被按下。不要与 love.keypressed 或 love.keyreleased.
		 *
		 * 与常规的 KeyConstants 不同，扫描码与键盘布局无关。如果按下与美式键盘上的 'w' 键相同位置的键，则使用扫描码 'w'，无论该键的标签是什么或用户的操作系统设置是什么。
		 *
		 * @param scancodes 要检查的扫描码。
		 *
		 * @returns down — 如果提供的任何扫描码已关闭，则为 True，否则为 false。
		 */
		isScancodeDown(this: void, ...scancodes: string[]): boolean;
		isScancodeDown(this: void, scancodes: string[]): boolean;
		/**
		 * 获取给定按键对应的硬件扫描码。
		 *
		 * 与按键常量不同，扫描码与键盘布局无关。例如，如果按下与美式键盘上的 'w' 键相同位置的键，则无论该键的标签是什么或用户的操作系统设置是什么，都会生成扫描码 'w' 。
		 *
		 * 扫描码对于创建在所有系统上具有相同物理位置的默认控件非常有用。
		 *
		 * @param key 获取扫描码的密钥。
		 *
		 * @returns scancode — 与给定键对应的扫描码，如果给定键在当前系统上没有已知的物理表示，则为 'unknown' 。
		 */
		getScancodeFromKey(this: void, key: string): string;
		/**
		 * 获取与给定硬件扫描码对应的密钥。
		 *
		 * 与按键常量不同，扫描码与键盘布局无关。例如，如果按下与美式键盘上的 'w' 键相同位置的键，则无论该键的标签是什么或用户的操作系统设置是什么，都会生成扫描码 'w' 。
		 *
		 * 扫描码对于创建在所有系统上具有相同物理位置的默认控件非常有用。
		 *
		 * @param scancode 用于获取密钥的扫描码。
		 *
		 * @returns key — 与给定扫描码相对应的键，如果扫描码未映射到当前系统上的 KeyConstant，则为 'unknown' 。
		 */
		getKeyFromScancode(this: void, scancode: string): string;
		/**
		 * 启用或禁用文本输入事件。它在 Windows、Mac 和 Linux 上默认启用，在 iOS 和 Android 上默认禁用。
		 *
		 * 在触摸设备上，这会在启用时显示系统的本机屏幕键盘。
		 *
		 * 重载说明：
		 * 1. 在 iOS 和 Android 上，此变体告诉操作系统指定的矩形是游戏中显示文本的位置，这会阻止系统屏幕键盘覆盖文本。
		 *
		 * @param enabled 是否应启用文本输入事件。
		 * @param x 文本矩形 x 位置。
		 * @param y 文本矩形 y 位置。
		 * @param width 文本矩形宽度。
		 * @param height 文本矩形高度。
		 */
		setTextInput(this: void, enabled: boolean): void;
		setTextInput(this: void, enabled: boolean, x: number, y: number, width: number, height: number): void;
		/**
		 * 获取是否启用文本输入事件。
		 *
		 * @returns enabled — 是否启用文本输入事件。
		 */
		hasTextInput(this: void): boolean;
		/**
		 * 获取是否支持屏幕键盘。
		 *
		 * @returns supported — 是否支持屏幕键盘。
		 */
		hasScreenKeyboard(this: void): boolean;
	}

	/** @noSelf */
	type SystemCursor = "arrow" | "ibeam" | "wait" | "crosshair" | "waitarrow" | "sizenwse" | "sizenesw" | "sizewe" | "sizens" | "sizeall" | "no" | "hand";
	/** Represents a hardware cursor.
	 */
	interface Cursor extends Object {
		/**
		 * 获取光标的类型。
		 *
		 * @returns ctype — 光标的类型。
		 */
		getType(): "image" | SystemCursor;
		/**
		 * 获取字符串形式的对象类型。
		 *
		 * @returns type — 字符串类型。
		 */
		type(): "Cursor";
		/**
		 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
		 *
		 * @param typeName 要检查的类型的名称。
		 *
		 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
		 */
		typeOf(typeName: string): boolean;
	}
	/** @noSelf */
	/** Provides an interface to the user's mouse.
	 */
	interface Mouse {
		/**
		 * 返回鼠标的当前位置。
		 *
		 * @returns x — 鼠标沿 x 轴的位置。
		 * @returns y — 鼠标沿 y 轴的位置。
		 */
		getPosition(this: void): LuaMultiReturn<[number, number]>;
		/**
		 * 返回鼠标当前的 x 位置。
		 *
		 * @returns x — 鼠标沿 x 轴的位置。
		 */
		getX(this: void): number;
		/**
		 * 返回鼠标当前的 y 位置。
		 *
		 * @returns y — 鼠标沿 y 轴的位置。
		 */
		getY(this: void): number;
		/**
		 * 设置鼠标的当前位置。非整数值被下限。
		 *
		 * @param x 鼠标沿 x 轴的新位置。
		 * @param y 鼠标沿 y 轴的新位置。
		 */
		setPosition(this: void, x: number, y: number): void;
		/**
		 * 设置鼠标当前的 X 位置。
		 *
		 * 非整数值被下限。
		 *
		 * @param x 鼠标沿 x 轴的新位置。
		 */
		setX(this: void, x: number): void;
		/**
		 * 设置鼠标当前的 Y 位置。
		 *
		 * 非整数值被下限。
		 *
		 * @param y 鼠标沿 y 轴的新位置。
		 */
		setY(this: void, y: number): void;
		/**
		 * 检查某个鼠标按钮是否按下。
		 *
		 * 该函数不检测鼠标滚轮滚动；您必须使用 love.wheelmoved （或 0.9.2 及更早版本中的 love.mousepressed ）回调。
		 *
		 * @param buttons 要检查的按钮的索引。 1 是鼠标主按钮，2 是鼠标辅助按钮，3 是中间按钮。其他按钮取决于鼠标。
		 *
		 * @returns down — 如果任何指定的按钮被按下，则为真。
		 */
		isDown(this: void, ...buttons: number[]): boolean;
		isDown(this: void, buttons: number[]): boolean;
		/**
		 * 设置光标的当前可见性。
		 *
		 * @param visible true 将光标设置为可见， false 将隐藏光标。
		 */
		setVisible(this: void, visible: boolean): void;
		/**
		 * 检查光标是否可见。
		 *
		 * @returns visible — 如果光标可见则为 true，如果光标隐藏则为 false。
		 */
		isVisible(this: void): boolean;
		/**
		 * 抓住鼠标并将其限制在窗口内。
		 *
		 * @param grabbed True 限制鼠标，False 让它离开窗口。
		 */
		setGrabbed(this: void, grabbed: boolean): void;
		/**
		 * 检查鼠标是否被抓住。
		 *
		 * @returns grabbed — 如果光标被抓取则为 true，否则为 false。
		 */
		isGrabbed(this: void): boolean;
		/**
		 * 设置鼠标是否启用相对模式。
		 *
		 * 当启用相对模式时，光标被隐藏，并且在鼠标移动时不会移动，但仍然通过 love.mousemoved. 生成相对鼠标运动事件，这使得鼠标可以无限期地向任何方向移动，而光标不会卡在屏幕边缘。
		 *
		 * 在启用相对模式时，即使生成了相对鼠标运动事件，报告的鼠标位置也可能不会更新。
		 *
		 * @param relative true 则启用相对模式， false 则禁用它。
		 */
		setRelativeMode(this: void, relative: boolean): boolean;
		/**
		 * 获取鼠标是否启用相对模式。
		 *
		 * 如果启用相对模式，光标将被隐藏，并且在鼠标移动时不会移动，但仍然通过 love.mousemoved. 生成相对鼠标运动事件，这使鼠标可以无限期地向任何方向移动，而光标不会卡在屏幕边缘。
		 *
		 * 在启用相对模式时，即使生成了相对鼠标运动事件，报告的鼠标位置也不会更新。
		 *
		 * @returns enabled — 如果启用相对模式则为 True，如果禁用则为 false。
		 */
		getRelativeMode(this: void): boolean;
		/**
		 * 从图像文件或 ImageData 创建新的硬件 Cursor 对象。
		 *
		 * 硬件光标与帧速率无关，并且与普通操作系统光标的工作方式相同。与在鼠标的当前坐标处绘制图像不同，即使在低帧速率下，硬件光标在鼠标移动和光标位置更新之间也不会出现明显的滞后。
		 *
		 * 热点是操作系统用来确定单击的内容以及鼠标光标所在位置的点。例如，普通箭头指针通常将其热点放在图像的左上角，但十字光标可能将其放在中间。
		 *
		 * @param image 用于新 Cursor 的 ImageData。根据重载：用于新光标的图像路径。取决于重载：表示用于新光标的图像的数据。
		 * @param hotX 光标热点的 ImageData 中的 x 坐标。 （默认值：0。）取决于重载：光标热点图像中的 x 坐标。 （默认值：0。）
		 * @param hotY 光标热点的 ImageData 中的 y 坐标。 （默认值：0。）取决于过载：光标热点图像中的 y 坐标。 （默认值：0。）
		 *
		 * @returns cursor — 新的 Cursor 对象。
		 */
		newCursor(this: void, image: ImageData | FileData | string, hotX?: number, hotY?: number): Cursor;
		/**
		 * 获取表示系统本机硬件光标的 Cursor 对象。
		 *
		 * 硬件光标与帧速率无关，并且与普通操作系统光标的工作方式相同。与在鼠标的当前坐标处绘制图像不同，即使在低帧速率下，硬件光标在鼠标移动和光标位置更新之间也不会出现明显的滞后。
		 *
		 * 重载说明：
		 * 1. 'image' CursorType 不是有效参数。使用 love.mouse.newCursor 使用自定义图像创建硬件光标。
		 *
		 * @param type 要获取的系统光标的类型。
		 *
		 * @returns cursor — 表示系统游标类型的 Cursor 对象。
		 */
		getSystemCursor(this: void, type: SystemCursor): Cursor;
		/**
		 * 设置当前鼠标光标。
		 *
		 * 重载说明：
		 * 1. 将当前鼠标光标重置为默认值。
		 *
		 * @param cursor 用作当前鼠标光标的 Cursor 对象。
		 */
		setCursor(this: void, cursor?: Cursor): void;
		/**
		 * 获取当前光标。
		 *
		 * @returns cursor — 当前光标，如果未设置光标则为零。
		 */
		getCursor(this: void): Cursor | undefined;
		/**
		 * 获取是否支持光标功能。
		 *
		 * 如果不支持，调用 love.mouse.newCursor 和 love.mouse.getSystemCursor 会出错。移动设备不支持光标。
		 *
		 * @returns supported — 系统是否有光标功能。
		 */
		isCursorSupported(this: void): boolean;
	}
	type TouchID = LuaUserdata;
	/** @noSelf */
	/** Provides an interface to touch-screen presses.
	 */
	interface Touch {
		/**
		 * 获取所有活动触摸按键的列表。
		 *
		 * 重载说明：
		 * 1. id 值与用作 love.touchpressed、love.touchmoved 和 love.touchreleased. 参数的 id 值相同。特定触摸按下的 id 值仅保证在该触摸按下期间是唯一的。一旦使用该 id 调用 love.touchreleased，它就可以通过 love.touchpressed.
		 *
		 * @returns touches — 活动触摸按键 ID 值列表，可与 love.touch.getPosition.
		 */
		getTouches(this: void): TouchID[];
		/**
		 * 获取指定触摸的当前位置（以像素为单位）。
		 *
		 * 重载说明：
		 * 1. LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为 1 范围内的标准化值，而此 API 报告的位置以像素为单位。
		 *
		 * @param id 触摸按键的标识符。使用 love.touch.getTouches、love.touchpressed 或 love.touchmoved 获取触摸 ID 值。
		 *
		 * @returns x — 窗口内触摸按键沿 x 轴的位置（以像素为单位）。
		 * @returns y — 窗口内触摸按键沿 y 轴的位置（以像素为单位）。
		 */
		getPosition(this: void, id: TouchID): LuaMultiReturn<[number, number]>;
		/**
		 * 获取指定触摸的当前压力。
		 *
		 * @param id 触摸按键的标识符。使用 love.touch.getTouches、love.touchpressed 或 love.touchmoved 获取触摸 ID 值。
		 *
		 * @returns pressure — 触摸压力。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
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
		 * 获取Joystick是否已连接。
		 *
		 * @returns connected — 如果操纵杆当前已连接，则为 true，否则为 false。
		 */
		isConnected(): boolean;
		/**
		 * 获取操纵杆的名称。
		 *
		 * @returns name — 操纵杆的名称。
		 */
		getName(): string;
		/**
		 * 获取操纵杆的唯一标识符。即使操纵杆断开连接并重新连接，标识符在游戏的生命周期中也将保持不变，但当游戏重新启动时，它“'will'”会发生变化。
		 *
		 * @returns id — 操纵杆的唯一标识符。只要游戏运行，就保持不变。
		 * @returns instanceid — 唯一的实例标识符。每次重新连接操纵杆时都会发生变化。如果操纵杆未连接则为零。
		 */
		getID(): LuaMultiReturn<[number, number | undefined]>;
		/**
		 * 获取物理操纵杆类型所特有的稳定 GUID，该 GUID 不会随时间变化。例如，OS X 中的所有 Sony Dualshock 3 控制器都具有相同的 GUID。该值取决于平台。
		 *
		 * @returns guid — 操纵杆类型的依赖于操作系统的唯一标识符。
		 */
		getGUID(): string;
		/**
		 * 获取操纵杆的 USB 供应商 ID、产品 ID 和产品版本号，这些信息在不同操作系统中保持一致。
		 *
		 * 可用于为不同的游戏手柄显示不同的图标等。
		 *
		 * 重载说明：
		 * 1. 某些 Linux 发行版可能未附带 SDL 2.0.6 或更高版本，在这种情况下，此函数将为所有三个值返回 0。
		 *
		 * @returns vendorID — 操纵杆的 USB 供应商 ID。
		 * @returns productID — 操纵杆的 USB 产品 ID。
		 * @returns productVersion — 操纵杆的产品版本。
		 */
		getDeviceInfo(): LuaMultiReturn<[number, number, number]>;
		/**
		 * 获取操纵杆上的轴数。
		 *
		 * @returns axes — 可用轴的数量。
		 */
		getAxisCount(): number;
		/**
		 * 获取操纵杆上的按钮数量。
		 *
		 * @returns buttons — 可用按钮的数量。
		 */
		getButtonCount(): number;
		/**
		 * 获取操纵杆上的帽子数量。
		 *
		 * @returns hats — 操纵杆有多少顶帽子。
		 */
		getHatCount(): number;
		/**
		 * 获取轴的方向。
		 *
		 * @param axis 要检查的轴的索引。
		 *
		 * @returns direction — 轴的当前值。
		 */
		getAxis(axis: number): number;
		/**
		 * 获取每个轴的方向。
		 *
		 * @returns axisDir1 — 轴 1 的方向。
		 * @returns axisDir2 — 轴2的方向。
		 * @returns axisDirN — 轴方向N。
		 */
		getAxes(): LuaMultiReturn<number[]>;
		/**
		 * 获取操纵杆帽子的方向。
		 *
		 * @param hat 要检查的帽子的索引。
		 *
		 * @returns direction — 帽子被推的方向。
		 */
		getHat(hat: number): JoystickHat;
		/**
		 * 检查操纵杆上的按钮是否被按下。
		 *
		 * LÖVE 0.9.0 有一个错误，要求传递给 Joystick:isDown 的按钮索引是基于 0 的而不是基于 1 的，例如对于此功能，按钮 1 将为 0。它在 0.9.1 中被修复。
		 *
		 * @param buttons 要检查的按钮的索引。
		 *
		 * @returns anyDown — 如果任何提供的按钮被按下，则为 True，否则为 false。
		 */
		isDown(...buttons: number[]): boolean;
		/**
		 * 获取Joystick是否被识别为游戏手柄。如果是这种情况，则可以通过 Joystick:getGamepadAxis、Joystick:isGamepadDown、love.gamepadpressed 和相关函数，在不同的操作系统和操纵杆型号中以标准化方式使用操纵杆的按钮和轴。
		 *
		 * LÖVE 自动识别与 Xbox 360 控制器布局相似的最流行的控制器作为游戏手柄，但您可以使用 love.joystick.setGamepadMapping.
		 *
		 * 重载说明：
		 * 1. 如果操纵杆被识别为游戏手柄，则虚拟游戏手柄轴和按钮的物理位置将尽可能与标准 Xbox 360 控制器的布局相对应。
		 *
		 * @returns isgamepad — 如果操纵杆被识别为游戏手柄则为 true，否则为 false。
		 */
		isGamepad(): boolean;
		/**
		 * 检查是否按下了操纵杆上的虚拟游戏手柄按钮。如果操纵杆未被识别为游戏手柄或未连接，则此函数将始终返回 false。
		 *
		 * @param buttons 要检查的游戏手柄按钮。
		 *
		 * @returns anyDown — 如果任何提供的按钮被按下，则为 True，否则为 false。
		 */
		isGamepadDown(...buttons: GamepadButton[]): boolean;
		/**
		 * 获取虚拟游戏手柄轴的方向。如果操纵杆未被识别为游戏手柄或未连接，此函数将始终返回 0。
		 *
		 * @param axis 要检查的虚拟轴。
		 *
		 * @returns direction — 轴的当前值。
		 */
		getGamepadAxis(axis: GamepadAxis): number;
		/**
		 * 获取虚拟游戏手柄输入绑定的按钮、轴或帽子。
		 *
		 * 重载说明：
		 * 1. 如果操纵杆未被识别为游戏手柄或虚拟游戏手柄轴未绑定到操纵杆输入，则返回 nil。
		 * 2. 虚拟游戏手柄轴和按钮的物理位置尽可能与标准 Xbox 360 控制器的布局相对应。
		 *
		 * @param input 要获取绑定的虚拟游戏手柄轴。根据过载：要获取绑定的虚拟游戏手柄按钮。
		 *
		 * @returns inputtype — 虚拟游戏手柄轴绑定的输入类型。取决于过载：虚拟游戏手柄按钮绑定的输入类型。
		 * @returns inputindex — 虚拟游戏手柄轴绑定到的操纵杆按钮、轴或帽子的索引。取决于过载：虚拟游戏手柄按钮绑定到的操纵杆按钮、轴或帽子的索引。
		 * @returns hatdirection — 帽子的方向，如果虚拟游戏手柄轴绑定到帽子。否则为零。取决于过载：帽子的方向（如果虚拟游戏手柄按钮绑定到帽子）。否则为零。
		 */
		getGamepadMapping(input: GamepadAxis | GamepadButton): LuaMultiReturn<[JoystickInputType, number, JoystickHat?]> | undefined;
		/**
		 * 获取此操纵杆的完整游戏手柄映射字符串，如果未将其识别为游戏手柄，则返回 nil。
		 *
		 * 映射字符串包含用于将操纵杆的按钮和轴映射到标准游戏手柄布局的绑定信息，并且可以在以后与 love.joystick.loadGamepadMappings.
		 *
		 * @returns mappingstring — 包含操纵杆的游戏手柄映射的字符串，如果操纵杆未被识别为游戏手柄则为零。
		 */
		getGamepadMappingString(): string | undefined;
		/**
		 * 获取Joystick是否支持振动。
		 *
		 * 重载说明：
		 * 1. 第一次调用此函数可能会比预期花费更多时间，因为需要初始化 SDL 的触觉/力反馈子系统。
		 *
		 * @returns supported — 如果此操纵杆支持隆隆声/力反馈振动，则为 true，否则为 false。
		 */
		isVibrationSupported(): boolean;
		/**
		 * 设置带有震动支持的操纵杆上的振动电机速度。大多数常见的游戏手柄都具有此功能，但并非所有驱动程序都提供适当的支持。使用Joystick:isVibrationSupported进行检查。
		 *
		 * 重载说明：
		 * 1. 禁用振动。
		 * 2. 如果摇杆只有一个振动电机，它仍然可以工作，但会使用左右参数中的最大值。如果使用 Tattiebogle 驱动程序的修改版本，则 Mac OS X 上的 Xbox 360 控制器仅支持振动。第一次调用此函数可能会比预期花费更多时间，因为需要初始化 SDL 的触觉/力反馈子系统。
		 *
		 * @param left 操纵杆上左侧振动电机的强度。必须在 1 范围内。
		 * @param right 操纵杆上右侧振动电机的强度。必须在 1 范围内。
		 * @param duration 振动的持续时间（以秒为单位）。负值意味着无限的持续时间。 （默认值：-1。）
		 *
		 * @returns success — 如果振动成功应用则为 true，否则为 false。取决于过载：如果振动已成功禁用，则为 true；如果未成功禁用，则为 false。
		 */
		setVibration(): boolean;
		setVibration(left: number, right?: number, duration?: number): boolean;
		/**
		 * 获取支持震动的操纵杆上当前的振动电机强度。
		 *
		 * @returns left — 操纵杆上左侧振动电机的当前强度。
		 * @returns right — 操纵杆上右侧振动电机的当前强度。
		 */
		getVibration(): LuaMultiReturn<[number, number]>;
		getConnectedIndex(): number | undefined;
	}
	/** @noSelf */
	/** Provides an interface to the user's joystick.
	 */
	interface JoystickModule {
		/**
		 * 获取已连接操纵杆的列表。
		 *
		 * @returns joysticks — 当前连接的操纵杆列表。
		 */
		getJoysticks(this: void): Joystick[];
		/**
		 * 获取连接的操纵杆数量。
		 *
		 * @returns joystickcount — 连接的操纵杆数量。
		 */
		getJoystickCount(this: void): number;
		/**
		 * 将虚拟游戏手柄输入绑定到特定类型的所有操纵杆的按钮、轴或帽子。例如，如果此函数与 OS X 中的 Dualshock 3 控制器返回的 GUID 一起使用，则绑定将影响在 OS X 中运行时与游戏一起使用的“'all'”Dualshock 3 控制器的 Joystick:getGamepadAxis 和 Joystick:isGamepadDown。
		 *
		 * LÖVE 包含许多常见控制器的内置游戏手柄绑定。此功能允许您更改默认情况下不被识别为游戏手柄的操纵杆类型的绑定或添加新的绑定。
		 *
		 * 虚拟游戏手柄按钮和轴是围绕 Xbox 360 控制器布局设计的。
		 *
		 * 重载说明：
		 * 1. 绑定游戏手柄轴和按钮的物理位置应尽可能与标准 Xbox 360 控制器的布局相对应。
		 *
		 * @param guid 绑定将影响的操纵杆类型的依赖于操作系统的 GUID。
		 * @param input 要绑定的虚拟游戏手柄按钮。根据过载：要绑定的虚拟游戏手柄轴。
		 * @param type 将虚拟游戏手柄按钮绑定到的输入类型。取决于过载：将虚拟游戏手柄轴绑定到的输入类型。
		 * @param index 将虚拟游戏手柄按钮绑定到的轴、按钮或帽子的索引。取决于过载：将虚拟游戏手柄轴绑定到的轴、按钮或帽子的索引。
		 * @param direction 帽子的方向，如果虚拟手柄按钮会绑定到帽子上。否则为零。 （默认值：nil。）取决于过载：帽子的方向，如果虚拟游戏手柄轴将绑定到帽子。否则为零。 （默认值：无。）
		 *
		 * @returns success — 虚拟手柄按键是否绑定成功。根据过载情况：虚拟手柄轴是否绑定成功。
		 */
		setGamepadMapping(this: void, guid: string, input: GamepadAxis | GamepadButton, type: "axis" | "button", index: number): boolean;
		setGamepadMapping(this: void, guid: string, input: GamepadAxis | GamepadButton, type: "hat", index: number, direction: JoystickHat): boolean;
		/**
		 * 加载使用 love.joystick.saveGamepadMappings. 创建的游戏手柄映射字符串或文件
		 *
		 * 它还可以识别任何 SDL 游戏控制器映射字符串，例如使用 Steam 的 Big Picture 控制器配置界面或这个漂亮的数据库创建的字符串。如果为已知的控制器 GUID 加载新映射，则更高版本将覆盖当前加载的映射。
		 *
		 * 重载说明：
		 * 1. 从文件加载游戏手柄映射字符串。
		 * 2. 直接加载游戏手柄映射字符串。
		 *
		 * @param mappingsOrFilename 要从中加载映射字符串的文件名。取决于重载：要加载的映射字符串。
		 */
		loadGamepadMappings(this: void, mappingsOrFilename: string): void;
		/**
		 * 保存所有被识别为游戏手柄并且最近使用过或者其游戏手柄绑定已被修改的虚拟游戏手柄映射。
		 *
		 * 映射存储为字符串，以便与 love.joystick.loadGamepadMappings.
		 *
		 * 重载说明：
		 * 1. 将所有相关操纵杆的游戏手柄映射保存到文件中。
		 * 2. 返回映射字符串而不写入文件。
		 *
		 * @param filename 保存映射字符串的文件名。
		 *
		 * @returns mappings — 写入文件的映射字符串。取决于重载：映射字符串。
		 */
		saveGamepadMappings(this: void, filename?: string): string;
		/**
		 * 获取具有给定 GUID 的操纵杆的完整游戏手柄映射字符串，如果 GUID 未被识别为游戏手柄，则返回 nil。
		 *
		 * 映射字符串包含用于将操纵杆的按钮和轴映射到标准游戏手柄布局的绑定信息，并且可以在以后与 love.joystick.loadGamepadMappings.
		 *
		 * @param guid 要获取其映射字符串的 GUID 值。
		 *
		 * @returns mappingstring — 包含操纵杆游戏手柄映射的字符串，如果 GUID 未被识别为游戏手柄则为零。
		 */
		getGamepadMappingString(this: void, guid: string): string | undefined;
	}

	/** @noSelf */
	/** Provides an interface to the user's clock.
	 */
	interface Timer {
		/**
		 * 测量两帧之间的时间。
		 *
		 * 调用此函数会更改 love.timer.getDelta.
		 *
		 * @returns dt — 过去的时间（以秒为单位）。
		 */
		step(this: void): number;
		/**
		 * 返回最后两帧之间的时间。
		 *
		 * @returns dt — 过去的时间（以秒为单位）。
		 */
		getDelta(this: void): number;
		/**
		 * 返回当前每秒帧数。
		 *
		 * @returns fps — 当前的 FPS。
		 */
		getFPS(this: void): number;
		/**
		 * 返回最后一秒的平均增量时间（每帧秒数）。
		 *
		 * @returns delta — 最后一秒的平均增量时间。
		 */
		getAverageDelta(this: void): number;
		/**
		 * 将当前线程暂停指定的时间。
		 *
		 * @param seconds 还需要睡觉几秒。
		 */
		sleep(this: void, seconds: number): void;
		/**
		 * 返回未指定起始时间的计时器的值。
		 *
		 * 该函数只能用于计算时间点之间的差异，因为计时器的启动时间未知。
		 *
		 * @returns time — 时间以秒为单位。以十进制形式给出，精确到微秒。
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
		 * 获取当前操作系统。一般来说，LÖVE 抽象了了解当前操作系统的需要，但在某些情况下它可能很有用（特别是与 os.execute 结合使用。）
		 *
		 * 重载说明：
		 * 1. 在 LÖVE 版本 0.8.0 中，“'love._os'”字符串包含当前操作系统。
		 *
		 * @returns osString — 当前操作系统。 'OS X'、'Windows'、'Linux'、'Android' 或 'iOS'。
		 */
		getOS(this: void): OS;
		/**
		 * 获取系统中逻辑处理器的数量。
		 *
		 * 重载说明：
		 * 1. 该数字包括启用英特尔超线程等技术时报告的线程数。例如，在具有超线程的 4 核 CPU 上，此函数将返回 8。
		 *
		 * @returns processorCount — 逻辑处理器的数量。
		 */
		getProcessorCount(this: void): number;
		/**
		 * 将文本放入剪贴板。
		 *
		 * @param text 要保存在系统剪贴板中的新文本。
		 */
		setClipboardText(this: void, text: string): void;
		/**
		 * 从剪贴板获取文本。
		 *
		 * @returns text — 当前保存在系统剪贴板中的文本。
		 */
		getClipboardText(this: void): string;
		/**
		 * 获取有关系统电源的信息。
		 *
		 * @returns state — 电源的基本状态。
		 * @returns percent — 剩余电池寿命百分比，介于 0 到 100 之间。如果无法确定该值或没有电池，则为零。
		 * @returns seconds — 电池寿命还剩几秒。如果无法确定该值或没有电池，则为零。
		 */
		getPowerInfo(this: void): LuaMultiReturn<[PowerState, number | undefined, number | undefined]>;
		/** Embedded LoveNode permits only http, https, and mailto schemes. */
		/**
		 * 使用用户的 Web 或文件浏览器打开 URL。
		 *
		 * 重载说明：
		 * 1. 在 Android 7.0 (Nougat) 及更高版本中传递 file:// 方案总是会导致失败。在 11.2 之前，这会使 LÖVE 崩溃而不是返回 false。
		 *
		 * @param url 要打开的 URL。必须格式化为正确的 URL。
		 *
		 * @returns success — URL是否打开成功。
		 */
		openURL(this: void, url: string): boolean;
		/**
		 * 如果可能的话，使设备振动。目前，这仅适用于具有内置振动电机的 Android 和 iOS 设备。
		 *
		 * @param seconds 振动的持续时间。如果在iOS设备上调用，由于iOS系统API的限制，它总是会振动0.5秒。 （默认值：0.5。）
		 */
		vibrate(this: void, seconds?: number): void;
		/**
		 * 获取系统上的另一个应用程序是否正在后台播放音乐。
		 *
		 * 目前这是在 iOS 和 Android 上实现的，并且在其他操作系统上将始终返回 false。 love.conf 中的 t.audio.mixwithsystem 标志可用于配置 LÖVE 打开时是否应播放其他应用程序的背景音频/音乐。
		 *
		 * @returns backgroundmusic — 如果用户通过另一个应用程序在后台播放音乐，则为 true，否则为 false。
		 */
		hasBackgroundMusic(this: void): boolean;
	}

	type ThreadValue = boolean | number | string | Data | Channel | ThreadValue[] | {[key: string]: ThreadValue} | undefined;
	/** A Thread is a chunk of code that can run in parallel with other threads. Data can be sent between different threads with Channel objects.
	 */
	interface Thread extends Object {
		/**
		 * 获取字符串形式的对象类型。
		 *
		 * @returns type — 字符串类型。
		 */
		type(): "Thread";
		/**
		 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
		 *
		 * @param typeName 要检查的类型的名称。
		 *
		 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
		 */
		typeOf(typeName: string): boolean;
		/**
		 * 启动线程。
		 *
		 * 从0.9.0版本开始，线程可以在执行完成后重新启动。
		 *
		 * 重载说明：
		 * 1. 传递给 Thread:start 的参数可以通过“'...'”（可变参数表达式）在线程的主文件中访问。
		 *
		 * @param args 字符串、数字、布尔值、LÖVE 对象或简单表格。
		 */
		start(...args: ThreadValue[]): boolean;
		/**
		 * 等待线程完成。
		 *
		 * 该调用将阻塞，直到线程完成。
		 */
		wait(): void;
		/**
		 * 如果线程产生错误，则从线程中检索错误字符串。
		 *
		 * @returns err — 错误消息，如果线程没有引起错误则为零。
		 */
		getError(): string | undefined;
		/**
		 * 返回线程当前是否正在运行。
		 *
		 * 未运行的线程可以用Thread:start（重新）启动。
		 *
		 * @returns value — 如果线程正在运行则为 true，否则为 false。
		 */
		isRunning(): boolean;
	}
	/** An object which can be used to send and receive data between different threads.
	 */
	interface Channel extends Object {
		/**
		 * 获取字符串形式的对象类型。
		 *
		 * @returns type — 字符串类型。
		 */
		type(): "Channel";
		/**
		 * 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
		 *
		 * @param typeName 要检查的类型的名称。
		 *
		 * @returns b — 如果对象属于指定类型，则为 true，否则为 false。
		 */
		typeOf(typeName: string): boolean;
		/**
		 * 向线程Channel发送消息。
		 *
		 * 有关受支持类型的列表，请参阅变体。
		 *
		 * @param value 消息的内容。
		 *
		 * @returns id — 可以提供给Channel:hasRead
		 */
		push(value: ThreadValue): number;
		/**
		 * 向线程Channel发送消息并等待线程接受它。
		 *
		 * 有关受支持类型的列表，请参阅变体。
		 *
		 * @param value 消息的内容。
		 * @param timeout 等待的最长时间。
		 *
		 * @returns success — 消息是否已成功提供（始终为真）。取决于过载：在超时到期之前消息是否成功提供。
		 */
		supply(value: ThreadValue, timeout?: number): boolean;
		/**
		 * 检索 Channel 消息的值并将其从消息队列中删除。
		 *
		 * 如果队列中没有消息，则返回 nil。
		 *
		 * @returns value — 消息的内容。
		 */
		pop(): ThreadValue;
		/**
		 * 检索 Channel 消息的值并将其从消息队列中删除。
		 *
		 * 它会等待消息进入队列，然后返回消息值。
		 *
		 * @param timeout 等待的最长时间。
		 *
		 * @returns value — 消息的内容。取决于过载：消息的内容或 nil（如果超时）。
		 */
		demand(timeout?: number): ThreadValue;
		/**
		 * 检索 Channel 消息的值，但将其保留在队列中。
		 *
		 * 如果队列中没有消息，则返回 nil。
		 *
		 * @returns value — 消息的内容。
		 */
		peek(): ThreadValue;
		/**
		 * 检索线程 Channel 队列中的消息数。
		 *
		 * @returns count — 队列中的消息数。
		 */
		getCount(): number;
		/**
		 * 获取推送的值是否已被弹出或以其他方式从通道中删除。
		 *
		 * @param id Channel:push 之前返回的 id 值。
		 *
		 * @returns hasread — id 表示的值是否已通过 Channel:pop、Channel:demand 或 Channel:clear 从 Channel 中删除。
		 */
		hasRead(id: number): boolean;
		/**
		 * 清除Channel队列中的所有消息。
		 */
		clear(): void;
		/**
		 * 相对于此 Channel 以原子方式执行指定的函数。
		 *
		 * 在同一个 Channel 上连续调用多个方法通常很有用。但是，如果多个线程同时调用此 Channel 的方法，则每个线程上的不同调用可能最终会交错（例如，第二个线程的一个或多个调用可能发生在第一个线程的调用之间。）
		 *
		 * 此方法通过确保调用该方法的线程在指定函数返回之前具有对 Channel 的独占访问权来避免该问题。
		 *
		 * @param callback 要调用的函数，形式为 function(channel, arg1, arg2, ...) end。调用函数时，通道将作为第一个参数传递给该函数。
		 * @param args 调用给定函数时将收到的附加参数。
		 *
		 * @returns ret1 — 给定函数的第一个返回值（如果有）。
		 * @returns ... — 任何其他返回值。
		 */
		performAtomic(callback: (channel: Channel, ...args: any[]) => any, ...args: any[]): any;
	}
	/** @noSelf */
	/** Allows you to work with threads.
	 */
	interface ThreadModule {
		/**
		 * 从包含 Lua 代码的文件名、字符串或 FileData 对象创建一个新线程。
		 *
		 * @param codeOrFilename 用作源的 Lua 文件的名称。取决于重载：包含用作源的 Lua 代码的 FileData。取决于重载：包含用作源的 Lua 代码的字符串。它的长度至少需要 1024 个字符，或者至少包含一个换行符。
		 *
		 * @returns thread — 尚未启动的新线程。
		 */
		newThread(this: void, codeOrFilename: string | Data | File): Thread;
		/**
		 * 创建一个新的未命名线程通道。
		 *
		 * 它们的一种用途是通过命名通道上的 Channel:push 将新的未命名通道传递到其他线程。
		 *
		 * @returns channel — 新的 Channel 对象。
		 */
		newChannel(this: void): Channel;
		/**
		 * 创建或检索命名线程通道。
		 *
		 * @param name 您要创建或检索的频道的名称。
		 *
		 * @returns channel — 与名称关联的 Channel 对象。
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
		 * 创建处于停止状态的源的相同副本。
		 *
		 * 静态源将使用显着更少的内存，并且创建它们所需的时间也更少，因此在制作播放相同声音的多个源时应首选此方法。
		 *
		 * 重载说明：
		 * 1. 克隆源继承了原始源的所有可设置状态，但它们被初始化为停止状态。
		 *
		 * @returns source — 此源的新的相同副本。
		 */
		clone(): Source;
		/**
		 * 开始播放源。
		 *
		 * @returns success — Source是否能够成功开始播放。
		 */
		play(): boolean;
		/**
		 * 暂停源。
		 */
		pause(): void;
		/**
		 * 停止源。
		 */
		stop(): void;
		/**
		 * 返回源是否正在播放。
		 *
		 * @returns playing — 如果源正在播放则为 true，否则为 false。
		 */
		isPlaying(): boolean;
		/**
		 * 返回此 Source 是否处于停止状态。此方法是兼容旧版 LÖVE 的废弃接口，表示既未播放也未暂停。
		 *
		 * @deprecated Lua 中请同时使用 `not source:isPlaying()` 与 `not source:isPaused()`。
		 */
		isStopped(): boolean;
		isPaused(): boolean;
		/**
		 * 设置源是否应循环。
		 *
		 * @param looping 如果源应该循环则为 true，否则为 false。
		 */
		setLooping(looping: boolean): void;
		/**
		 * 返回 Source 是否循环。
		 *
		 * @returns loop — 如果源将循环则为 true，否则为 false。
		 */
		isLooping(): boolean;
		/**
		 * 设置源的当前音量。
		 *
		 * @param volume 源的音量，其中 1.0 是正常音量。音量不能调高到 1.0 以上。
		 */
		setVolume(volume: number): void;
		/**
		 * 获取源的当前音量。
		 *
		 * @returns volume — 源的音量，其中 1.0 是正常音量。
		 */
		getVolume(): number;
		/**
		 * 设置源的音高。
		 *
		 * @param pitch 以 1 为基距计算。每降低 50% 就等于音高移动 -12 个半音（降低一个八度）。每次加倍等于音高移动 12 个半音（增加一个八度）。零不是合法值。
		 */
		setPitch(pitch: number): void;
		/**
		 * 获取源的当前音高。
		 *
		 * @returns pitch — 音高，其中 1.0 为正常值。
		 */
		getPitch(): number;
		/**
		 * 设置源的当前播放位置。
		 *
		 * @param offset 要寻求的位置。
		 * @param unit 位置值的单位。 （默认：'seconds'。）
		 */
		seek(offset: number, unit?: TimeUnit): void;
		/**
		 * 获取Source 当前的播放位置。
		 *
		 * @param unit 返回值的单位类型。 （默认：'seconds'。）
		 *
		 * @returns position — 源的当前播放位置。
		 */
		tell(unit?: TimeUnit): number;
		/**
		 * 获取源的持续时间。对于流源，它可能并不总是样本准确的，并且如果根本无法确定持续时间，则可能返回 -1。
		 *
		 * @param unit 返回值的时间单位。 （默认：'seconds'。）
		 *
		 * @returns duration — 源的持续时间，如果无法确定则为 -1。
		 */
		getDuration(unit?: TimeUnit): number;
		/**
		 * 获取源中的通道数。只有 1 通道（单声道）源可以使用方向和位置效果。
		 *
		 * @returns channels — 1 用于单声道，2 用于立体声。
		 */
		getChannelCount(): number;
		/** Deprecated Love alias for getChannelCount. */
		getChannels(): number;
		/**
		 * 获取可排队源中的空闲缓冲区槽数。如果可排队源正在播放，则该值将增加到创建源时所用的数量。如果可排队源停止，它将首先处理其所有内部缓冲区，在这种情况下，该函数将始终返回其创建时所用的数量。
		 *
		 * @returns buffers — 还有多少个 SoundData 对象可以排队。
		 */
		getFreeBufferCount(): number;
		/**
		 * 将 SoundData 排队以便在可排队源中播放。
		 *
		 * 此方法需要通过 love.audio.newQueueableSource. 创建源
		 *
		 * @param data 要排队的数据。 SoundData 的采样率、位深度和通道数必须与 Source 相匹配。
		 *
		 * @returns success — 如果数据已成功排队播放，则为 true；如果没有可用于排队的可用缓冲区，则为 false。
		 */
		queue(data: SoundData, length?: number): boolean;
		queue(data: SoundData, offset: number, length: number): boolean;
		/**
		 * 设置源的位置。请注意，这仅适用于单声道（即非立体声）声音文件！
		 *
		 * @param x 源的 X 位置。
		 * @param y 源的 Y 位置。
		 * @param z 源的 Z 位置。
		 */
		setPosition(x: number, y: number, z?: number): void;
		/**
		 * 获取源的位置。
		 *
		 * @returns x — 源的 X 位置。
		 * @returns y — 源的 Y 位置。
		 * @returns z — 源的 Z 位置。
		 */
		getPosition(): LuaMultiReturn<[number, number, number]>;
		/**
		 * 设置源的速度。
		 *
		 * 这确实“'not'”改变了源的位置，但让应用程序知道它如何计算多普勒效应。
		 *
		 * @param x 速度矢量的 X 部分。
		 * @param y 速度矢量的 Y 部分。
		 * @param z 速度矢量的 Z 部分。
		 */
		setVelocity(x: number, y: number, z?: number): void;
		/**
		 * 获取源的速度。
		 *
		 * @returns x — 速度矢量的 X 部分。
		 * @returns y — 速度矢量的 Y 部分。
		 * @returns z — 速度矢量的 Z 部分。
		 */
		getVelocity(): LuaMultiReturn<[number, number, number]>;
		/**
		 * 设置源的方向向量。零矢量使源无方向性。
		 *
		 * @param x 方向向量的X部分。
		 * @param y 方向向量的Y部分。
		 * @param z 方向向量的 Z 部分。
		 */
		setDirection(x: number, y: number, z?: number): void;
		/**
		 * 获取源的方向。
		 *
		 * @returns x — 方向向量的X部分。
		 * @returns y — 方向向量的Y部分。
		 * @returns z — 方向向量的 Z 部分。
		 */
		getDirection(): LuaMultiReturn<[number, number, number]>;
		/**
		 * 设置源的定向体积锥体。与 Source:setDirection 一起，锥角允许源的体积根据其方向而变化。
		 *
		 * @param innerAngle 与源方向的内角，以弧度为单位。如果听者位于此角度定义的圆锥体内，则源将以正常音量播放。
		 * @param outerAngle 与源方向的外角，以弧度为单位。如果听者位于由内角和外角定义的锥体之间，则源将以正常音量和外音量之间的音量播放。
		 * @param outerVolume 当听者位于内锥角和外锥角之外时源的音量。 （默认值：0。）
		 */
		setCone(innerAngle: number, outerAngle: number, outerVolume?: number, outerHighGain?: number): void;
		/**
		 * 获取源的定向体积锥体。与 Source:setDirection 一起，锥角允许源的体积根据其方向而变化。
		 *
		 * @returns innerAngle — 与源方向的内角，以弧度为单位。如果听者位于此角度定义的圆锥体内，则源将以正常音量播放。
		 * @returns outerAngle — 与源方向的外角，以弧度为单位。如果听者位于由内角和外角定义的锥体之间，则源将以正常音量和外音量之间的音量播放。
		 * @returns outerVolume — 当听者位于内锥角和外锥角之外时源的音量。
		 */
		getCone(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 设置应用于源的空气吸收量。
		 *
		 * 默认情况下，该值设置为 0，这意味着空气吸收效果被禁用。值为 1 将以每米 0.05 dB 的速率对源应用高频衰减。
		 *
		 * 空气吸收可以模拟声音在雾气、干燥空气、烟雾气氛等中的传播。它可以用来模拟一个区域内不同地点的不同大气条件。
		 *
		 * 重载说明：
		 * 1. iOS 不支持音频空气吸收功能。
		 *
		 * @param factor 应用于源的空气吸收量。必须介于 0 和 10 之间。
		 */
		setAirAbsorption(factor: number): void;
		/**
		 * 获取应用于源的空气吸收量。
		 *
		 * 默认情况下，该值设置为 0，这意味着空气吸收效果被禁用。值为 1 将以每米 0.05 dB 的速率对源应用高频衰减。
		 *
		 * 重载说明：
		 * 1. iOS 不支持音频空气吸收功能。
		 *
		 * @returns amount — 应用于源的空气吸收量。
		 */
		getAirAbsorption(): number;
		/**
		 * 设置源的音量限制。限制必须是 0 到 1 之间的数字。
		 *
		 * @param minVolume 最小音量。
		 * @param maxVolume 最大音量。
		 */
		setVolumeLimits(minVolume: number, maxVolume: number): void;
		/**
		 * 返回源的音量限制。
		 *
		 * @returns min — 最小音量。
		 * @returns max — 最大音量。
		 */
		getVolumeLimits(): LuaMultiReturn<[number, number]>;
		/**
		 * 设置源的位置、速度、方向和锥角是相对于听者的还是绝对的。
		 *
		 * 默认情况下，所有源都是绝对源，因此相对于爱的坐标系 0, 0 的原点。只有绝对源才会受到听者位置的影响。请注意，位置音频仅适用于单声道（即非立体声）源。
		 *
		 * @param relative True 使位置、速度、方向和锥角相对于听者，为 false 使它们绝对。 （默认值：假。）
		 */
		setRelative(relative: boolean): void;
		/**
		 * 获取Source 的位置、速度、方向和锥角是否相对于听者。
		 *
		 * @returns relative — 如果位置、速度、方向和锥角是相对于听者的，则为 true；如果是绝对的，则为 false。
		 */
		isRelative(): boolean;
		/**
		 * 设置源的参考距离和最大衰减距离。这些参数与当前的 DistanceModel 相结合，会影响源的音量如何根据距离衰减。
		 *
		 * 距离衰减仅适用于基于单声道（而不是立体声）音频的源。
		 *
		 * @param referenceDistance 新的参考衰减距离。如果当前距离模型被钳制，则这是最小衰减距离。
		 * @param maxDistance 新的最大衰减距离。
		 */
		setAttenuationDistances(referenceDistance: number, maxDistance: number): void;
		/**
		 * 获取源的参考距离和最大衰减距离。这些值与当前的 DistanceModel 相结合，会影响源的音量如何根据距收听者的距离衰减。
		 *
		 * @returns ref — 当前参考衰减距离。如果当前距离模型被钳制，则这是源不再衰减之前的最小距离。
		 * @returns max — 当前最大衰减距离。
		 */
		getAttenuationDistances(): LuaMultiReturn<[number, number]>;
		/**
		 * 设置影响所用距离衰减强度的滚降系数。
		 *
		 * 扩展信息和详细公式可以在OpenAL 1.1规范的'3.4. Attenuation By Distance'章节中找到。
		 *
		 * @param rolloff 新的滚降因子。
		 */
		setRolloff(rolloff: number): void;
		/**
		 * 返回源的滚降系数。
		 *
		 * @returns rolloff — 滚降因子。
		 */
		getRolloff(): number;
		/**
		 * 设置播放源时要应用的低通、高通或带通滤波器。
		 *
		 * 重载说明：
		 * 1. 禁用对此源的过滤。
		 *
		 * @param filter 用于此源的过滤器设置，具有以下字段：
		 * @param filter.type 要使用的过滤器类型。
		 * @param filter.volume 音频的总音量。必须介于 0 和 1 之间。
		 * @param filter.highgain 高频音频的音量。仅适用于低通和带通滤波器。必须介于 0 和 1 之间。
		 * @param filter.lowgain 低频音频的音量。仅适用于高通和带通滤波器。必须介于 0 和 1 之间。
		 *
		 * @returns success — 过滤器是否成功应用于源。
		 */
		setFilter(filter?: AudioFilterSettings): boolean;
		getFilter<T extends AudioFilterSettings>(target?: T): T | AudioFilterSettings | undefined;
		/**
		 * 将音频效果应用于源。
		 *
		 * 该效果必须事先使用 love.audio.setEffect.
		 *
		 * 重载说明：
		 * 1. 将给定的先前定义的效果应用于此源。
		 * 2. 将给定的先前定义的效果应用于此源，并将过滤器应用于影响馈入效果的声音的源。 iOS 不支持音频效果功能。
		 *
		 * @param name 之前使用 love.audio.setEffect. 设置的效果名称
		 * @param enabled 如果为 false 并且给定的效果名称先前已在此源上启用，则禁用该效果。 （默认值：true。）取决于过载：在效果之前应用的过滤器设置，具有以下字段：
		 * @param enabled.type 要使用的过滤器类型。
		 * @param enabled.volume 音频的总音量。必须介于 0 和 1 之间。
		 * @param enabled.highgain 高频音频的音量。仅适用于低通和带通滤波器。必须介于 0 和 1 之间。
		 * @param enabled.lowgain 低频音频的音量。仅适用于高通和带通滤波器。必须介于 0 和 1 之间。
		 *
		 * @returns success — 效果是否成功应用于此源。取决于过载：效果和滤波器是否成功应用于此源。
		 */
		setEffect(name: string, enabled?: boolean | AudioFilterSettings): boolean;
		/**
		 * 获取与特定效果关联的过滤器设置。
		 *
		 * 如果应用效果时没有与其关联的滤镜设置，则此函数返回 nil。
		 *
		 * @param name 效果的名称。
		 * @param target 一个可选的空表，将填充过滤器设置。 （默认值：{}。）
		 *
		 * @returns filtersettings — 与此效果关联的过滤器的设置，如果此源中不存在该效果或没有关联的过滤器，则为零。该表具有以下字段：
		 * @returns filtersettings.volume — 音频的总音量。
		 * @returns filtersettings.highgain — 高频音频的音量。仅适用于低通和带通滤波器。
		 * @returns filtersettings.lowgain — 低频音频的音量。仅适用于高通和带通滤波器。
		 */
		getEffect(name: string, target?: AudioFilterSettings): LuaMultiReturn<[boolean, AudioFilterSettings?]>;
		/**
		 * 获取源的活动效果名称列表。
		 *
		 * @returns effects — 源的活动效果名称列表。
		 */
		getActiveEffects(): string[];
		/**
		 * 获取源的类型。
		 *
		 * @returns sourcetype — 源的类型。
		 */
		getType(): SourceType;
	}
	/** Represents an audio input device capable of recording sounds.
	 */
	interface RecordingDevice extends Object {
		/**
		 * 开始使用此设备录制音频。
		 *
		 * 重载说明：
		 * 1. 在调用 RecordingDevice:getData 或 RecordingDevice:stop 之前，内部使用环形缓冲区来存储记录的数据 - 前者会清除缓冲区。如果在调用 getData 或 stop 之前缓冲区完全填满，则不适合缓冲区的最旧数据将丢失。
		 *
		 * @param samples 记录时存储在内部环形缓冲区中的最大样本数。 RecordingDevice:getData 调用时会清除内部缓冲区。
		 * @param sampleRate 记录时每秒存储的样本数。 （默认值：8000。）
		 * @param bitDepth 每个样本的位数。 （默认值：16。）
		 * @param channels 是否以单声道或立体声录制。大多数麦克风不支持超过 1 个通道。 （默认值：1。）
		 *
		 * @returns success — 如果设备使用指定参数成功开始录制，则为 true，否则为 false。
		 */
		start(samples?: number, sampleRate?: number, bitDepth?: 8 | 16, channels?: 1 | 2): boolean;
		/** Stops recording and returns any buffered samples. */
		/**
		 * 停止从此设备录制音频。当前位于设备缓冲区中的任何声音数据都将被返回。
		 *
		 * @returns data — 当前在设备缓冲区中的声音数据，如果设备没有录音则为零。
		 */
		stop(): SoundData | undefined;
		/** Returns and consumes the samples currently buffered by this device. */
		/**
		 * 获取存储在设备内部环形缓冲区中的所有录制音频 SoundData。
		 *
		 * 调用此函数时，内部环形缓冲区会被清除，因此再次调用它只会在上次调用后录制音频。如果设备的内部环形缓冲区在调用 getData 之前完全填满，则不适合缓冲区的最旧数据将丢失。
		 *
		 * @returns data — 录制的音频数据，如果设备未录制则为零。
		 */
		getData(): SoundData | undefined;
		/**
		 * 获取当前记录的样本数。
		 *
		 * @returns samples — 迄今为止已记录的样本数。
		 */
		getSampleCount(): number;
		/**
		 * 获取当前记录的每秒样本数。
		 *
		 * @returns rate — 每秒记录的样本数（采样率）。
		 */
		getSampleRate(): number;
		/**
		 * 获取当前记录的数据中每个样本的位数。
		 *
		 * @returns bits — 当前记录的数据中每个样本的位数。
		 */
		getBitDepth(): 8 | 16;
		/**
		 * 获取当前正在录制的通道数（单声道或立体声）。
		 *
		 * @returns channels — 正在录制的通道数（1 个为单声道，2 个为立体声）。
		 */
		getChannelCount(): 1 | 2;
		/**
		 * 获取录音设备的名称。
		 *
		 * @returns name — 设备的名称。
		 */
		getName(): string;
		/**
		 * 获取设备当前是否正在录制。
		 *
		 * @returns recording — 如果录音则为 true，否则为 false。
		 */
		isRecording(): boolean;
	}
	/** @noSelf */
	/** Provides an interface to create noise with the user's speakers.
	 */
	interface Audio {
		/**
		 * 从文件路径、文件、解码器或声音数据创建新的源。
		 *
		 * 从 SoundData 创建的源始终是静态的。
		 *
		 * @param filename 音频文件的文件路径。
		 * @param sourceType 流式或静态源。
		 * @param data 用于创建源的 FileData。取决于重载：要从中创建源的 SoundData。
		 *
		 * @returns source — 可以播放指定音频的新源。根据过载：可以播放指定音频的新源。返回音频的SourceType是'static'。
		 */
		newSource(this: void, filename: string, sourceType?: "static" | "stream"): Source;
		newSource(this: void, data: SoundData): Source;
		/**
		 * 创建一个新的源，可用于使用 Source:queue 实时生成的声音播放。
		 *
		 * 重载说明：
		 * 1. 与 Source:queue 一起使用的任何 SoundData 的采样率、位深度和通道数必须与提供给此构造函数的参数相匹配。
		 *
		 * @param samplerate 播放时每秒的采样数。
		 * @param bitdepth 每个样本的位数（8 或 16）。
		 * @param channels 1 用于单声道或 2 用于立体声。
		 * @param buffercount 在任何给定时间可以使用 Source:queue 排队的缓冲区数量。不能大于 64。如果未指定值，则选择合理的默认值 (~8)。 （默认值：0。）
		 *
		 * @returns source — 可与 Source:queue 一起使用的新源。
		 */
		newQueueableSource(sampleRate: number, bitDepth: 8 | 16,
			channels: 1 | 2, buffers?: number): Source;
		/**
		 * 播放指定的源。
		 *
		 * 重载说明：
		 * 1. 开始同时播放多个源。
		 *
		 * @param sources 包含要播放的源列表的表。
		 */
		play(this: void, sources: Source[]): boolean;
		play(this: void, ...sources: Source[]): boolean;
		/**
		 * 暂停特定或所有当前播放的源。
		 *
		 * 重载说明：
		 * 1. 暂停所有当前活动的源并返回它们。
		 * 2. 暂停给定的源。
		 *
		 * @param sources 包含要暂停的源列表的表。
		 *
		 * @returns Sources — 包含由此调用暂停的源列表的表。
		 */
		pause(this: void): Source[];
		pause(this: void, sources: Source[]): void;
		pause(this: void, ...sources: Source[]): void;
		/**
		 * 停止当前播放的源。
		 *
		 * 重载说明：
		 * 1. 此功能将停止所有当前活动的源。
		 * 2. 该函数只会停止指定的源。
		 * 3. 同时停止所有给定的源。
		 *
		 * @param sources 包含要停止的源列表的表。
		 */
		stop(this: void, sources: Source[]): void;
		stop(this: void, ...sources: Source[]): void;
		/**
		 * 获取当前同时播放的音源数量。
		 *
		 * @returns count — 当前同时播放的音源数量。
		 */
		getActiveSourceCount(this: void): number;
		/** Deprecated Love alias for getActiveSourceCount. */
		getSourceCount(this: void): number;
		/**
		 * 设置主音量。
		 *
		 * @param volume 1.0 为最大值，0.0 为关闭。
		 */
		setVolume(this: void, volume: number): void;
		/**
		 * 返回主卷。
		 *
		 * @returns volume — 当前主卷
		 */
		getVolume(this: void): number;
		/** Sets the application-global iOS audio session mixing policy. Other platforms return false. */
		/**
		 * 设置系统是否应将音频与系统的音频混合。
		 *
		 * @param mix true 启用混合， false 禁用它。
		 *
		 * @returns success — 如果更改成功则为 true，否则为 false。
		 */
		setMixWithSystem(this: void, mix: boolean): boolean;
		/** Sets the Dora application-global listener position shared by all LoveNode instances. */
		/**
		 * 设置听者的位置，这决定了声音的播放方式。
		 *
		 * @param x 听者的 x 位置。
		 * @param y 听者的 y 位置。
		 * @param z 听者的 z 位置。
		 */
		setPosition(this: void, x: number, y: number, z?: number): void;
		/**
		 * 返回听者的位置。请注意，位置音频仅适用于单声道（即非立体声）源。
		 *
		 * @returns x — 听者的 X 位置。
		 * @returns y — 听者的 Y 位置。
		 * @returns z — 听者的 Z 位置。
		 */
		getPosition(this: void): LuaMultiReturn<[number, number, number]>;
		/** Sets the Dora application-global listener forward and up vectors. */
		/**
		 * 设置听者的方向。
		 *
		 * @param fx, fy, fz 听者方向的前向向量。
		 * @param ux, uy, uz 听者方向的向上向量。
		 */
		setOrientation(forwardX: number, forwardY: number, forwardZ: number,
			upX: number, upY: number, upZ: number): void;
		/**
		 * 返回听者的方向。
		 *
		 * @returns fx — 收听者方向的前向 x。
		 * @returns fy — 向前 y 收听者方向。
		 * @returns fz — 收听者方向的正向 z。
		 * @returns ux — 听者方向的向上 x。
		 * @returns uy — 听者方向的向上 y。
		 * @returns uz — 听者方向的 z 上方向。
		 */
		getOrientation(this: void): LuaMultiReturn<[number, number, number, number, number, number]>;
		/** Sets the Dora application-global listener velocity shared by all LoveNode instances. */
		/**
		 * 设置听者的速度。
		 *
		 * @param x 听者的 X 速度。
		 * @param y 听者的 Y 速度。
		 * @param z 听者的 Z 速度。
		 */
		setVelocity(this: void, x: number, y: number, z?: number): void;
		/**
		 * 返回听者的速度。
		 *
		 * @returns x — 听者的 X 速度。
		 * @returns y — 听者的 Y 速度。
		 * @returns z — 听者的 Z 速度。
		 */
		getVelocity(this: void): LuaMultiReturn<[number, number, number]>;
		/** Sets the Dora application-global Doppler scale shared by all LoveNode instances. */
		/**
		 * 为基于速度的多普勒效应设置全局比例因子。默认比例值为 1。
		 *
		 * @param scale 新的多普勒比例因子。小数位数必须大于 0。
		 */
		setDopplerScale(this: void, scale: number): void;
		/**
		 * 获取基于速度的多普勒效应的当前全局比例因子。
		 *
		 * @returns scale — 当前的多普勒比例因子。
		 */
		getDopplerScale(this: void): number;
		/** Sets the Dora application-global distance attenuation model. */
		/**
		 * 设置距离衰减模型。
		 *
		 * @param model 新的距离模型。
		 */
		setDistanceModel(this: void, model: DistanceModel): void;
		/**
		 * 返回距离衰减模型。
		 *
		 * @returns model — 当前距离模型。默认值为 'inverseclamped'。
		 */
		getDistanceModel(this: void): DistanceModel;
		/**
		 * 定义可以应用于源的效果。
		 *
		 * 并非所有系统都支持音频效果。使用love.audio.isEffectsSupported进行检查。
		 *
		 * @param name 效果的名称。
		 * @param settings 用于此效果的设置，具有以下字段：
		 * @param settings.type 要使用的效果类型。
		 * @param settings.volume 效果的音量。
		 * @param settings.... 特定于效果的设置。请参阅 EffectType 了解可用效果及其相应的设置。
		 *
		 * @returns success — 效果是否创建成功。取决于过载：效果是否成功禁用。
		 */
		setEffect(this: void, name: string, settings?: AudioEffectSettings | false): boolean;
		getEffect<T extends AudioEffectSettings>(name: string, target?: T): T | AudioEffectSettings | undefined;
		/**
		 * 获取当前启用的效果的名称列表。
		 *
		 * @returns effects — 当前启用的效果名称列表。
		 */
		getActiveEffects(this: void): string[];
		/**
		 * 获取系统支持的最大活动效果数。
		 *
		 * @returns maximum — 活动效果的最大数量。
		 */
		getMaxSceneEffects(this: void): number;
		/**
		 * 获取系统可以支持的单个源对象中活动效果的最大数量。
		 *
		 * 重载说明：
		 * 1. 对于不支持音频效果的系统，该函数返回0。
		 *
		 * @returns maximum — 每个源的活动效果的最大数量。
		 */
		getMaxSourceEffects(this: void): number;
		/**
		 * 获取系统上的 RecordingDevices 列表。
		 *
		 * 列表中的第一个设备是用户的默认录音设备。如果没有麦克风连接到系统，则该列表可能为空。
		 *
		 * iOS 目前不支持录音。
		 *
		 * 重载说明：
		 * 1. 从 11.3 开始支持 Android 音频录制。但是，使用 Play Store 中的 APK 时不支持。
		 *
		 * @returns devices — 连接的录音设备列表。
		 */
		getRecordingDevices(this: void): RecordingDevice[];
		/**
		 * 获取系统是否支持音效。
		 *
		 * 重载说明：
		 * 1. 附带旧版 OpenAL 库的旧版 Linux 发行版可能不支持音频效果。此外，iOS根本不支持音频效果。
		 *
		 * @returns supported — 如果支持效果则为 true，否则为 false。
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
		 * 获取保持接触形状的两个夹具。
		 *
		 * @returns fixtureA — 第一个装置。
		 * @returns fixtureB — 第二场比赛。
		 */
		getFixtures(): LuaMultiReturn<[Fixture, Fixture]>;
		/**
		 * 获取两个碰撞灯具形状的子索引。对于 ChainShapes，索引 1 是链中的第一条边。
		 * 与 Fixture:rayCast 或 ChainShape:getChildEdge 一起使用。
		 *
		 * @returns indexA — 第一个灯具形状的子索引。
		 * @returns indexB — 第二个灯具形状的子索引。
		 */
		getChildren(): LuaMultiReturn<[number, number]>;
		/**
		 * 返回两个碰撞夹具的接触点。可以有一个或两个点。
		 *
		 * @returns x1 — 第一个接触点的 x 坐标。
		 * @returns y1 — 第一个接触点的 y 坐标。
		 * @returns x2 — 第二个接触点的 x 坐标。
		 * @returns y2 — 第二个接触点的 y 坐标。
		 */
		getPositions(): LuaMultiReturn<number[]>;
		/**
		 * 获取两个接触形状之间的法向量。
		 *
		 * 该函数返回从第一个形状指向第二个形状的单位向量的坐标。
		 *
		 * @returns nx — 法线向量的 x 分量。
		 * @returns ny — 法向量的 y 分量。
		 */
		getNormal(): LuaMultiReturn<[number, number]>;
		/**
		 * 获取两个接触形状之间的摩擦力。
		 *
		 * @returns friction — 接触的摩擦力。
		 */
		getFriction(): number;
		/**
		 * 设置接触摩擦力。
		 *
		 * @param friction 接触摩擦力。
		 */
		setFriction(friction: number): void;
		/**
		 * 将接触摩擦重置为两个夹具的混合值。
		 */
		resetFriction(): void;
		/**
		 * 获取两个接触形状之间的恢复。
		 *
		 * @returns restitution — 两个形状之间的恢复。
		 */
		getRestitution(): number;
		/**
		 * 设置接触恢复。
		 *
		 * @param restitution 联系人恢复原状。
		 */
		setRestitution(restitution: number): void;
		/**
		 * 将接触恢复重置为两个灯具的混合值。
		 */
		resetRestitution(): void;
		/**
		 * 返回联系人是否已启用。如果在 preSolve 回调中禁用了接触，则碰撞将被忽略。
		 *
		 * @returns enabled — 如果启用则为 true，否则为 false。
		 */
		isEnabled(): boolean;
		/**
		 * 启用或禁用联系人。
		 *
		 * @param enabled True 表示启用，False 表示禁用。
		 */
		setEnabled(enabled: boolean): void;
		/**
		 * 返回两个碰撞的装置是否相互接触。
		 *
		 * @returns touching — 如果它们接触则为真，否则为假。
		 */
		isTouching(): boolean;
		getTangentSpeed(): number;
		setTangentSpeed(speed: number): void;
	}
	/** A world is an object that contains all bodies and joints.
	 */
	interface World extends Object {
		/**
		 * 毁灭世界，带走所有的身体、关节、固定装置及其形状。
		 *
		 * 如果您在调用此函数后尝试使用任何已销毁的对象，将会发生错误。
		 */
		destroy(): void;
		/**
		 * 获取世界是否被毁灭。被摧毁的世界无法使用。
		 *
		 * @returns destroyed — 世界是否毁灭。
		 */
		isDestroyed(): boolean;
		/**
		 * 更新世界状况。
		 *
		 * @param deltaTime 推进物理模拟的时间（以秒为单位）。
		 * @param velocityIterations 解决碰撞时用于确定新速度的最大步数。 （默认值：8。）
		 * @param positionIterations 解决碰撞时用于确定新位置的最大步骤数。 （默认值：3。）
		 */
		update(deltaTime: number, velocityIterations?: number, positionIterations?: number): void;
		/**
		 * 设置世界的重力。
		 *
		 * @param x 重力的 x 分量。
		 * @param y 重力的 y 分量。
		 */
		setGravity(x: number, y: number): void;
		/**
		 * 获取世界的重力。
		 *
		 * @returns x — 重力的 x 分量。
		 * @returns y — 重力的 y 分量。
		 */
		getGravity(): LuaMultiReturn<[number, number]>;
		/**
		 * 设置世界的睡眠行为。
		 *
		 * @param allowed 如果世界上的物体被允许睡觉，则为真，否则为假。
		 */
		setSleepingAllowed(allowed: boolean): void;
		/**
		 * 获取世界的睡眠行为。
		 *
		 * @returns allow — 如果世界上的物体被允许睡觉，则为真，否则为假。
		 */
		isSleepingAllowed(): boolean;
		/**
		 * 通过搜索任何重叠的边界框 (Fixture:getBoundingBox)，为指定区域内的每个灯具调用函数。
		 *
		 * @param topLeftX 左上角点的 x 位置。
		 * @param topLeftY 左上角点的 y 位置。
		 * @param bottomRightX 右下点的 x 位置。
		 * @param bottomRightY 右下点的 y 位置。
		 * @param callback 这个函数传递一个参数，即固定装置，并且应该返回一个布尔值。如果为 true，则继续搜索；如果为 false，则停止搜索。
		 */
		queryBoundingBox(x1: number, y1: number, x2: number, y2: number,
			callback: (fixture: Fixture) => boolean): void;
		/**
		 * 投射光线并为其相交的每个灯具调用函数。
		 *
		 * 重载说明：
		 * 1. LÖVE 0.8.0 中有一个错误，传递给回调函数的法线向量按 love.physics.getMeter.
		 *
		 * @param x1 射线起点的 x 位置。
		 * @param y1 射线起点的 x 位置。
		 * @param x2 射线终点的 x 位置。
		 * @param y2 形状边缘的表面法线向量的 x 值。
		 * @param callback 为与光线相交的每个夹具调用的函数。该函数有六个参数，并应返回一个数字作为控制值。输入到函数中的交点将采用任意顺序。如果您希望找到最近的交点，则需要在函数内自行完成。最简单的方法是使用分数值。
		 */
		rayCast(x1: number, y1: number, x2: number, y2: number,
			callback: (fixture: Fixture, x: number, y: number,
				normalX: number, normalY: number, fraction: number) => number): void;
		/**
		 * 设置世界更新期间碰撞回调的函数。
		 *
		 * 四个 Lua 函数可以作为参数给出。值 nil 删除一个函数。
		 *
		 * 调用时，每个函数将传递三个参数。前两个参数是碰撞装置，第三个参数是它们之间的接触。 postSolve 回调还获取每个接触点的法线和切线冲量。参见注释。
		 *
		 * 如果您有兴趣了解每个回调的确切调用时间，请参阅 Box2d 手册
		 *
		 * @param beginContact 当两个灯具开始重叠时被调用。
		 * @param endContact 当两个灯具不再重叠时被调用。当碰撞对象被销毁时，这也会在世界更新之外被调用。
		 * @param preSolve 在冲突解决之前被调用。 （默认值：无。）
		 * @param postSolve 冲突解决后被调用。 （默认值：无。）
		 */
		setCallbacks(beginContact?: ContactCallback, endContact?: ContactCallback,
			preSolve?: ContactCallback, postSolve?: PostSolveCallback): void;
		/**
		 * 返回世界更新期间回调的函数。
		 *
		 * @returns beginContact — 当两个灯具开始重叠时被调用。
		 * @returns endContact — 当两个灯具不再重叠时被调用。
		 * @returns preSolve — 在冲突解决之前被调用。
		 * @returns postSolve — 冲突解决后被调用。
		 */
		getCallbacks(): LuaMultiReturn<[ContactCallback | undefined, ContactCallback | undefined,
			ContactCallback | undefined, PostSolveCallback | undefined]>;
	}
	/** Bodies are objects with velocity and position.
	 */
	interface Body extends Object {
		/**
		 * 显式地破坏身体以及附着在其上的所有固定装置和关节。
		 *
		 * 如果您在调用此函数后尝试使用该对象，将会发生错误。在0.7.2中，当你没有时间等待垃圾回收时，可以使用此函数立即释放对象。
		 */
		destroy(): void;
		/**
		 * 获取Body是否被破坏。被毁坏的尸体无法使用。
		 *
		 * @returns destroyed — 本体是否被破坏。
		 */
		isDestroyed(): boolean;
		/**
		 * 获取身体的位置。
		 *
		 * 请注意，这可能不是身体的质心。
		 *
		 * @returns x — x 位置。
		 * @returns y — y 位置。
		 */
		getPosition(): LuaMultiReturn<[number, number]>;
		/**
		 * 设置主体的位置。
		 *
		 * 请注意，这可能不是身体的质心。
		 *
		 * 该功能无法唤醒本体。
		 *
		 * @param x x 位置。
		 * @param y y 位置。
		 */
		setPosition(x: number, y: number): void;
		/**
		 * 获取身体在世界坐标中的 x 位置。
		 *
		 * @returns x — 世界坐标中的 x 位置。
		 */
		getX(): number;
		/**
		 * 设置主体的 x 位置。
		 *
		 * 该功能无法唤醒本体。
		 *
		 * @param x x 位置。
		 */
		setX(x: number): void;
		/**
		 * 获取身体在世界坐标中的 y 位置。
		 *
		 * @returns y — 世界坐标中的 y 位置。
		 */
		getY(): number;
		/**
		 * 设置主体的 y 位置。
		 *
		 * 该功能无法唤醒本体。
		 *
		 * @param y y 位置。
		 */
		setY(y: number): void;
		/**
		 * 获取身体的位置和角度。
		 *
		 * 请注意，该位置可能不是身体的质心。 0 弧度的角度意味着 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成顺时针。
		 *
		 * @returns x — 位置的 x 分量。
		 * @returns y — 位置的 y 分量。
		 * @returns angle — 以弧度表示的角度。
		 */
		getTransform(): LuaMultiReturn<[number, number, number]>;
		/**
		 * 设置主体的位置和角度。
		 *
		 * 请注意，该位置可能不是身体的质心。 0 弧度的角度意味着 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成顺时针。
		 *
		 * 该功能无法唤醒本体。
		 *
		 * @param x 位置的 x 分量。
		 * @param y 位置的 y 分量。
		 * @param angle 以弧度表示的角度。
		 */
		setTransform(x: number, y: number, angle: number): void;
		/**
		 * 获取身体的角度。
		 *
		 * 角度以弧度为单位测量。如果需要将其转换为度数，请使用 math.deg。
		 *
		 * 0 弧度值表示 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成了“'clockwise'”。
		 *
		 * @returns angle — 以弧度表示的角度。
		 */
		getAngle(): number;
		/**
		 * 设置主体的角度。
		 *
		 * 角度以弧度为单位测量。如果您需要将其从度数转换，请使用 math.rad。
		 *
		 * 0 弧度值表示 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成了“'clockwise'”。
		 *
		 * 通过改变角度有可能与另一个物体发生碰撞。
		 *
		 * @param angle 以弧度表示的角度。
		 */
		setAngle(angle: number): void;
		/**
		 * 获取 Body 从其质心开始的线速度。
		 *
		 * 线速度是“'rate of change of position over time'”。
		 *
		 * 如果您需要“'rate of change of angle over time'”，请使用Body:getAngularVelocity。
		 *
		 * 如果需要获取与质心不同的点的线速度：
		 *
		 * * Body:getLinearVelocityFromLocalPoint 允许您指定本地坐标中的点。
		 *
		 * * Body:getLinearVelocityFromWorldPoint 允许您指定世界坐标中的点。
		 *
		 * 请参阅 'Essential Mathematics for Games and Interactive Applications' 第 136 页了解本地坐标和世界坐标的定义。
		 *
		 * @returns x — 速度矢量的 x 分量
		 * @returns y — 速度矢量的 y 分量
		 */
		getLinearVelocity(): LuaMultiReturn<[number, number]>;
		/**
		 * 为主体设置新的线速度。
		 *
		 * 该函数不会累积任何东西；自上次调用 World:update 以来先前应用的任何脉冲都将丢失。
		 *
		 * @param x 速度矢量的 x 分量。
		 * @param y 速度矢量的 y 分量。
		 */
		setLinearVelocity(x: number, y: number): void;
		/**
		 * 获取Body的角速度。
		 *
		 * 角速度是“'rate of change of angle over time'”。
		 *
		 * 通过施加扭矩、偏心力/脉冲和角阻尼在 World:update 中进行更改。可以直接用Body:setAngularVelocity设置。
		 *
		 * 如果您需要“'rate of change of position over time'”，请使用Body:getLinearVelocity。
		 *
		 * @returns w — 以弧度/秒为单位的角速度。
		 */
		getAngularVelocity(): number;
		/**
		 * 设置物体的角速度。
		 *
		 * 角速度是“'rate of change of angle over time'”。
		 *
		 * 该函数不会累积任何东西；自上次调用 World:update 以来先前应用的任何脉冲都将丢失。
		 *
		 * @param velocity 新的角速度，以弧度每秒为单位
		 */
		setAngularVelocity(velocity: number): void;
		/**
		 * 获取Body的线性阻尼。
		 *
		 * 线性阻尼是“'rate of decrease of the linear velocity over time'”。没有阻尼且没有外力的运动物体将无限期地继续运动，就像在太空中的情况一样。具有阻尼的运动体会逐渐停止运动。
		 *
		 * 阻尼与摩擦不同 - 它们可以一起建模。
		 *
		 * @returns damping — 线性阻尼值。
		 */
		getLinearDamping(): number;
		/**
		 * 设置主体的线性阻尼
		 *
		 * 有关线性阻尼的定义，请参阅Body:getLinearDamping。
		 *
		 * 线性阻尼可以取从 0 到无穷大的任何值。不过，建议保持在 0 到 0.1 之间。其他值将使对象看起来 'floaty'（如果启用重力）。
		 *
		 * @param damping 新的线性阻尼
		 */
		setLinearDamping(damping: number): void;
		/**
		 * 获取Body的角阻尼
		 *
		 * 角度阻尼是“'rate of decrease of the angular velocity over time'”：没有阻尼且没有外力的旋转体将无限期地继续旋转。具有阻尼的旋转体将逐渐停止旋转。
		 *
		 * 阻尼与摩擦不同 - 它们可以一起建模。然而，Box2D（和 LOVE）仅提供阻尼。
		 *
		 * 阻尼参数应介于 0 和无穷大之间，0 表示无阻尼，无穷大表示完全阻尼。通常您将使用 0 到 0.1 之间的阻尼值。
		 *
		 * @returns damping — 角度阻尼值。
		 */
		getAngularDamping(): number;
		/**
		 * 设置主体的角度阻尼
		 *
		 * 有关角度阻尼的定义，请参阅Body:getAngularDamping。
		 *
		 * 角度阻尼可以取从 0 到无穷大的任何值。不过，建议保持在 0 到 0.1 之间。其他值看起来不切实际。
		 *
		 * @param damping 新的角度阻尼。
		 */
		setAngularDamping(damping: number): void;
		/**
		 * 获取物体的质量。
		 *
		 * 静态物体的质量始终为 0。
		 *
		 * @returns mass — 身体的质量（以千克为单位）。
		 */
		getMass(): number;
		/**
		 * 设置新的体重。
		 *
		 * @param mass 质量，以千克为单位。
		 */
		setMass(mass: number): void;
		/**
		 * 获取物体的转动惯量。
		 *
		 * 转动惯量是指使身体旋转的难度。
		 *
		 * @returns inertia — 身体的旋转惯性。
		 */
		getInertia(): number;
		/**
		 * 设置物体的惯性。
		 *
		 * @param inertia 新的转动惯量，单位为千克 * 像素平方。
		 */
		setInertia(inertia: number): void;
		/**
		 * 返回质量、中心和转动惯量。
		 *
		 * @returns x — 质心的 x 位置。
		 * @returns y — 质心的 y 位置。
		 * @returns mass — 身体的质量。
		 * @returns inertia — 转动惯量。
		 */
		getMassData(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 覆盖计算的质量数据。
		 *
		 * @param centerX 质心的 x 位置。
		 * @param centerY 质心的 y 位置。
		 * @param mass 身体的质量。
		 * @param inertia 转动惯量。
		 */
		setMassData(centerX: number, centerY: number, mass: number, inertia: number): void;
		/**
		 * 通过根据夹具的质量属性重新计算来重置主体的质量。
		 */
		resetMassData(): void;
		/**
		 * 返回重力比例因子。
		 *
		 * @returns scale — 重力比例因子。
		 */
		getGravityScale(): number;
		/**
		 * 为主体设置新的重力比例因子。
		 *
		 * @param scale 新的重力比例因子。
		 */
		setGravityScale(scale: number): void;
		/**
		 * 获取本地坐标中的质心位置。
		 *
		 * 使用 Body:getWorldCenter 获取世界坐标中的质心。
		 *
		 * @returns x — 质心的 x 坐标。
		 * @returns y — 质心的 y 坐标。
		 */
		getLocalCenter(): LuaMultiReturn<[number, number]>;
		/**
		 * 获取世界坐标中的质心位置。
		 *
		 * 使用 Body:getLocalCenter 获取局部坐标中的质心。
		 *
		 * @returns x — 质心的 x 坐标。
		 * @returns y — 质心的 y 坐标。
		 */
		getWorldCenter(): LuaMultiReturn<[number, number]>;
		/**
		 * 返回主体旋转是否被锁定。
		 *
		 * @returns fixed — 如果身体的旋转被锁定则为 True，否则为 false。
		 */
		isFixedRotation(): boolean;
		/**
		 * 设置物体是否有固定旋转。
		 *
		 * 具有固定旋转的物体不会改变它们旋转的速度。调用此函数会导致质量重置。
		 *
		 * @param fixed 身体是否应该有固定的旋转。
		 */
		setFixedRotation(fixed: boolean): void;
		/**
		 * 返回主体的睡眠状态。
		 *
		 * @returns status — 如果身体清醒则为真，否则为假。
		 */
		isAwake(): boolean;
		/**
		 * 唤醒身体或使其进入睡眠状态。
		 *
		 * @param awake 身体睡眠状态。
		 */
		setAwake(awake: boolean): void;
		/**
		 * 返回主体的睡眠行为。
		 *
		 * @returns allowed — 如果允许身体睡眠则为 true，否则为 false。
		 */
		isSleepingAllowed(): boolean;
		/**
		 * 设置身体的睡眠行为。如果允许睡觉，休息的身体就会自动睡觉。除非与清醒的身体发生碰撞，否则不会模拟睡眠的身体。请注意，如果地板被拆除，人们最终可能会遇到像漂浮的睡着的身体这样的情况。
		 *
		 * @param allowed 如果允许身体睡眠则为 true，否则为 false。
		 */
		setSleepingAllowed(allowed: boolean): void;
		/**
		 * 返回模拟中是否主动使用主体。
		 *
		 * @returns status — 如果主体处于活动状态，则为 True，否则为 false。
		 */
		isActive(): boolean;
		/**
		 * 设置物体在世界中是否活跃。
		 *
		 * 不活跃的物体不参与模拟。它不会移动或造成任何碰撞。
		 *
		 * @param active 身体是否活跃。
		 */
		setActive(active: boolean): void;
		/**
		 * 获取主体的子弹状态。
		 *
		 * 有两种方法来检查身体碰撞：
		 *
		 * * 世界更新时的位置（默认）
		 *
		 * * 使用连续碰撞检测 (CCD)
		 *
		 * 默认方法很有效，但是移动速度非常快的物体有时可能会跳过另一个物体而不会产生碰撞。被设置为子弹的物体将使用 CCD。这样效率较低，但保证快速移动时不会跳跃。
		 *
		 * 请注意，静态物体（质量为零）始终使用 CCD，因此您的墙壁不会让快速移动的物体穿过，即使它不是子弹。
		 *
		 * @returns status — 主体的子弹状态。
		 */
		isBullet(): boolean;
		/**
		 * 设置正文的项目符号状态。
		 *
		 * 有两种方法来检查身体碰撞：
		 *
		 * * 世界更新时的位置（默认）
		 *
		 * * 使用连续碰撞检测 (CCD)
		 *
		 * 默认方法很有效，但是移动速度非常快的物体有时可能会跳过另一个物体而不会产生碰撞。被设置为子弹的物体将使用 CCD。这样效率较低，但保证快速移动时不会跳跃。
		 *
		 * 请注意，静态物体（质量为零）始终使用 CCD，因此您的墙壁不会让快速移动的物体穿过，即使它不是子弹。
		 *
		 * @param bullet 主体的子弹状态。
		 */
		setBullet(bullet: boolean): void;
		/**
		 * 对身体施加脉冲。
		 *
		 * 这使得身体动量瞬间增加。
		 *
		 * 冲动将身体推向一个方向。质量较大的物体反应较小。反应“'not'”取决于时间步长，相当于连续施加一个力 1 秒。脉冲最好用于对身体进行一次推力。对于连续推动身体，最好使用 Body:applyForce。
		 *
		 * 如果没有给出施加脉冲的位置，它将作用于身体的质心。未指向质心的部分脉冲将导致身体旋转（并且取决于旋转惯性）。
		 *
		 * 请注意，脉冲分量和位置必须在世界坐标中给出。
		 *
		 * @param xImpulse 脉冲的 x 分量。
		 * @param yImpulse 脉冲的 y 分量。
		 * @param pointX 应用脉冲的 x 位置。
		 * @param pointY 施加脉冲的 y 位置。
		 */
		applyLinearImpulse(xImpulse: number, yImpulse: number, pointX?: number, pointY?: number): void;
		/**
		 * 对物体施加角冲量。这使得身体动量瞬间增加。
		 *
		 * 质量越大的物体反应越小。反应“'not'”取决于时间步长，相当于连续施加一个力 1 秒。脉冲最好用于对身体进行一次推力。对于连续推动身体，最好使用 Body:applyForce。
		 *
		 * @param impulse 每秒千克平方米的脉冲。
		 */
		applyAngularImpulse(impulse: number): void;
		/**
		 * 对身体施加力。
		 *
		 * 力将物体推向一个方向。质量较大的物体反应较小。该反应还取决于施加力的时间长短：由于力在整个时间步长内连续作用，因此短时间步长只会推动身体很短的时间。因此，力最好在多个时间步中使用，以持续推动物体（如重力）。对于与时间步无关的单次推送，最好使用 Body:applyLinearImpulse。
		 *
		 * 如果没有给出施加力的位置，它将作用在身体的质心上。不指向质心的部分力将导致身体旋转（并且取决于旋转惯性）。
		 *
		 * 请注意，力的分量和位置必须在世界坐标中给出。
		 *
		 * @param xForce 要施加的力的 x 分量。
		 * @param yForce 要施加的力的 y 分量。
		 * @param pointX 施加力的 x 位置。
		 * @param pointY 施加力的 y 位置。
		 */
		applyForce(xForce: number, yForce: number, pointX?: number, pointY?: number): void;
		/**
		 * 对主体施加扭矩。
		 *
		 * 扭矩就像一种会改变物体角速度（旋转）的力。效果取决于物体的转动惯量。
		 *
		 * @param torque 要施加的扭矩。
		 */
		applyTorque(torque: number): void;
		/**
		 * 返回主体的类型。
		 *
		 * @returns type — 体型。
		 */
		getType(): BodyType;
		/**
		 * 设置新的身体类型。
		 *
		 * @param type 新类型。
		 */
		setType(type: BodyType): void;
		/**
		 * 将点从本地坐标转换为世界坐标。
		 *
		 * @param x 本地坐标中的 x 位置。
		 * @param y 本地坐标中的 y 位置。
		 *
		 * @returns worldX — 世界坐标中的 x 位置。
		 * @returns worldY — 世界坐标中的 y 位置。
		 */
		getWorldPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * 将向量从本地坐标转换为世界坐标。
		 *
		 * @param x 局部坐标中的向量 x 分量。
		 * @param y 局部坐标中的向量 y 分量。
		 *
		 * @returns worldX — 世界坐标中的向量 x 分量。
		 * @returns worldY — 世界坐标中的向量 y 分量。
		 */
		getWorldVector(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * 将多个点从本地坐标转换为世界坐标。
		 *
		 * @param x 第一个点的 x 位置。
		 * @param y 第一个点的 y 位置。
		 * @param coordinates 第二个点的 x 位置。
		 *
		 * @returns x1 — 第一个点的变换后的 x 位置。
		 * @returns y1 — 第一个点的变换 y 位置。
		 * @returns x2 — 第二个点的变换后的 x 位置。
		 * @returns y2 — 第二个点的变换后的 y 位置。
		 */
		getWorldPoints(x: number, y: number, ...coordinates: number[]): LuaMultiReturn<number[]>;
		/**
		 * 将点从世界坐标转换为本地坐标。
		 *
		 * @param x 世界坐标中的 x 位置。
		 * @param y 世界坐标中的 y 位置。
		 *
		 * @returns localX — 本地坐标中的 x 位置。
		 * @returns localY — 本地坐标中的 y 位置。
		 */
		getLocalPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * 将向量从世界坐标转换为局部坐标。
		 *
		 * @param x 世界坐标中的向量 x 分量。
		 * @param y 世界坐标中的向量 y 分量。
		 *
		 * @returns localX — 局部坐标中的向量 x 分量。
		 * @returns localY — 局部坐标中的向量 y 分量。
		 */
		getLocalVector(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * 将多个点从世界坐标转换为本地坐标。
		 *
		 * @param x （参数）第一个点的 x 位置。
		 * @param y （参数）第一个点的 y 位置。
		 * @param coordinates （参数）第二个点的 x 位置。
		 *
		 * @returns x1 — （结果）第一个点的变换后的 x 位置。
		 * @returns y1 — （结果）第一个点的变换后的 y 位置。
		 * @returns x2 — （结果）第二个点的变换后的 x 位置。
		 * @returns y2 — （结果）第二个点的变换后的 y 位置。
		 * @returns ... — （结果）额外变换的点的 x 和 y 位置。
		 */
		getLocalPoints(x: number, y: number, ...coordinates: number[]): LuaMultiReturn<number[]>;
		/**
		 * 获取物体上一点的线速度。
		 *
		 * 身体上一点的线速度是身体质心的速度加上该点处身体旋转的速度。
		 *
		 * 身体上的点必须以世界坐标给出。使用 Body:getLinearVelocityFromLocalPoint 来指定本地坐标。
		 *
		 * @param x 测量速度的 x 位置。
		 * @param y 测量速度的 y 位置。
		 *
		 * @returns vx — (x,y) 点速度的 x 分量。
		 * @returns vy — (x,y) 点速度的 y 分量。
		 */
		getLinearVelocityFromWorldPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
		/**
		 * 获取物体上一点的线速度。
		 *
		 * 身体上一点的线速度是身体质心的速度加上该点处身体旋转的速度。
		 *
		 * 物体上的点必须以本地坐标给出。使用 Body:getLinearVelocityFromWorldPoint 来指定世界坐标。
		 *
		 * @param x 测量速度的 x 位置。
		 * @param y 测量速度的 y 位置。
		 *
		 * @returns vx — (x,y) 点速度的 x 分量。
		 * @returns vy — (x,y) 点速度的 y 分量。
		 */
		getLinearVelocityFromLocalPoint(x: number, y: number): LuaMultiReturn<[number, number]>;
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
		 * 获取多边形顶点的局部坐标。
		 *
		 * 该函数具有可变数量的返回值。它可以以嵌套方式与 love.graphics.polygon.
		 *
		 * @returns x1 — 第一个顶点的 x 分量。
		 * @returns y1 — 第一个顶点的 y 分量。
		 * @returns x2 — 第二个顶点的 x 分量。
		 * @returns y2 — 第二个顶点的 y 分量。
		 */
		getPoints(): LuaMultiReturn<number[]>;
		validate(): boolean;
	}
	/** A EdgeShape is a line segment. They can be used to create the boundaries of your terrain. The shape does not have volume and can only collide with PolygonShape and CircleShape.
	 */
	interface EdgeShape extends Shape {
		/**
		 * 返回边缘点的局部坐标。
		 *
		 * @returns x1 — 第一个顶点的 x 分量。
		 * @returns y1 — 第一个顶点的 y 分量。
		 * @returns x2 — 第二个顶点的 x 分量。
		 * @returns y2 — 第二个顶点的 y 分量。
		 */
		getPoints(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 获取与前一个形状建立连接的顶点。
		 *
		 * 设置下一个和上一个 EdgeShape 顶点可以帮助防止当平面形状沿着边缘滑动并移动到新形状时发生不必要的碰撞。
		 *
		 * @returns x — 顶点的 x 分量，如果 EdgeShape:setPreviousVertex 尚未被调用，则为零。
		 * @returns y — 顶点的 y 分量，如果 EdgeShape:setPreviousVertex 尚未被调用，则为零。
		 */
		getPreviousVertex(): LuaMultiReturn<[number, number] | []>;
		/**
		 * 获取与下一个形状建立连接的顶点。
		 *
		 * 设置下一个和上一个 EdgeShape 顶点可以帮助防止当平面形状沿着边缘滑动并移动到新形状时发生不必要的碰撞。
		 *
		 * @returns x — 顶点的 x 分量，如果 EdgeShape:setNextVertex 尚未被调用，则为零。
		 * @returns y — 顶点的 y 分量，如果 EdgeShape:setNextVertex 尚未被调用，则为零。
		 */
		getNextVertex(): LuaMultiReturn<[number, number] | []>;
		/**
		 * 设置与前一个形状建立连接的顶点。
		 *
		 * 当平面形状沿着边缘滑动并移动到新形状时，这可以帮助防止不必要的碰撞。
		 *
		 * @param x 顶点的 x 分量。
		 * @param y 顶点的 y 分量。
		 */
		setPreviousVertex(x?: number, y?: number): void;
		/**
		 * 设置与下一个形状建立连接的顶点。
		 *
		 * 当平面形状沿着边缘滑动并移动到新形状时，这可以帮助防止不必要的碰撞。
		 *
		 * @param x 顶点的 x 分量。
		 * @param y 顶点的 y 分量。
		 */
		setNextVertex(x?: number, y?: number): void;
	}
	/** A ChainShape consists of multiple line segments. It can be used to create the boundaries of your terrain. The shape does not have volume and can only collide with PolygonShape and CircleShape.
	 */
	interface ChainShape extends Shape {
		/**
		 * 返回形状的所有点。
		 *
		 * @returns x1 — 第一个点的 x 坐标。
		 * @returns y1 — 第一个点的 y 坐标。
		 * @returns x2 — 第二个点的 x 坐标。
		 * @returns y2 — 第二个点的 y 坐标。
		 */
		getPoints(): LuaMultiReturn<number[]>;
		/**
		 * 返回形状的顶点数。
		 *
		 * @returns count — 顶点数。
		 */
		getVertexCount(): number;
		/**
		 * 返回形状的一个点。
		 *
		 * @param index 要返回的点的索引。
		 *
		 * @returns x — 点的 x 坐标。
		 * @returns y — 点的 y 坐标。
		 */
		getPoint(index: number): LuaMultiReturn<[number, number]>;
		/**
		 * 返回形状的子项作为 EdgeShape。
		 *
		 * @param index 子项的索引。
		 *
		 * @returns shape — 作为 EdgeShape 的子项。
		 */
		getChildEdge(index: number): EdgeShape;
		/**
		 * 获取与前一个形状建立连接的顶点。
		 *
		 * 设置下一个和上一个 ChainShape 顶点可以帮助防止当平面形状沿着边缘滑动并移动到新形状时发生不必要的碰撞。
		 *
		 * @returns x — 顶点的 x 分量，如果 ChainShape:setPreviousVertex 尚未被调用，则为零。
		 * @returns y — 顶点的 y 分量，如果 ChainShape:setPreviousVertex 尚未被调用，则为零。
		 */
		getPreviousVertex(): LuaMultiReturn<[number, number] | []>;
		/**
		 * 获取与下一个形状建立连接的顶点。
		 *
		 * 设置下一个和上一个 ChainShape 顶点可以帮助防止当平面形状沿着边缘滑动并移动到新形状时发生不必要的碰撞。
		 *
		 * @returns x — 顶点的 x 分量，如果 ChainShape:setNextVertex 尚未被调用，则为零。
		 * @returns y — 顶点的 y 分量，如果 ChainShape:setNextVertex 尚未被调用，则为零。
		 */
		getNextVertex(): LuaMultiReturn<[number, number] | []>;
		/**
		 * 设置与前一个形状建立连接的顶点。
		 *
		 * 当平面形状沿着边缘滑动并移动到新形状时，这可以帮助防止不必要的碰撞。
		 *
		 * @param x 顶点的 x 分量。
		 * @param y 顶点的 y 分量。
		 */
		setPreviousVertex(x?: number, y?: number): void;
		/**
		 * 设置与下一个形状建立连接的顶点。
		 *
		 * 当平面形状沿着边缘滑动并移动到新形状时，这可以帮助防止不必要的碰撞。
		 *
		 * @param x 顶点的 x 分量。
		 * @param y 顶点的 y 分量。
		 */
		setNextVertex(x?: number, y?: number): void;
	}
	/** Fixtures attach shapes to bodies.
	 */
	interface Fixture extends Object {
		/**
		 * 摧毁灯具。
		 */
		destroy(): void;
		/**
		 * 获取Fixture是否被破坏。损坏的固定装置不能再使用。
		 *
		 * @returns destroyed — Fixture是否被破坏。
		 */
		isDestroyed(): boolean;
		getType(): "circle" | "polygon" | "edge" | "chain";
		/**
		 * 设置夹具的摩擦力。
		 *
		 * 摩擦力决定了形状沿着其他形状 'slide' 时如何反应。低摩擦力表示光滑的表面，如冰，而高摩擦力表示粗糙的表面，如混凝土。范围：0.0 - 1.0。
		 *
		 * @param friction 夹具摩擦力。
		 */
		setFriction(friction: number): void;
		/**
		 * 返回夹具的摩擦力。
		 *
		 * @returns friction — 夹具摩擦力。
		 */
		getFriction(): number;
		/**
		 * 设置灯具的恢复。
		 *
		 * @param restitution 灯具恢复原状。
		 */
		setRestitution(restitution: number): void;
		/**
		 * 返回灯具的恢复状态。
		 *
		 * @returns restitution — 灯具恢复原状。
		 */
		getRestitution(): number;
		/**
		 * 设置灯具的密度。如果需要立即生效，请调用Body:resetMassData。
		 *
		 * @param density 灯具密度，单位为千克每平方米。
		 */
		setDensity(density: number): void;
		/**
		 * 返回灯具的密度。
		 *
		 * @returns density — 灯具密度，单位为千克每平方米。
		 */
		getDensity(): number;
		/**
		 * 设置灯具是否应充当传感器。
		 *
		 * 传感器不会引起碰撞响应，但该装置仍会调用开始接触和结束接触世界回调。
		 *
		 * @param sensor 传感器状态。
		 */
		setSensor(sensor: boolean): void;
		/**
		 * 返回夹具是否为传感器。
		 *
		 * @returns sensor — 如果夹具是传感器。
		 */
		isSensor(): boolean;
		/**
		 * 返回固定装置所连接的主体。
		 *
		 * @returns body — 父体。
		 */
		getBody(): Body;
		/**
		 * 返回夹具的形状。该形状是对模拟中使用的实际数据的参考。可以在时间步之间更改其值。
		 *
		 * @returns shape — 灯具的形状。
		 */
		getShape(): Shape;
		/**
		 * 检查点是否位于夹具形状内部。
		 *
		 * @param x 点的 x 位置。
		 * @param y 点的 y 位置。
		 *
		 * @returns isInside — 如果该点在内部，则为 True；如果在外部，则为 false。
		 */
		testPoint(x: number, y: number): boolean;
		/**
		 * 将光线投射到夹具的形状上，并返回表面法线向量和光线击中的线位置。如果光线错过了形状，则返回 nil。
		 *
		 * 射线从输入线的第一个点开始，朝向该线的第二个点。第五个参数是光线将行进的最大距离，作为输入线长度的比例因子。
		 *
		 * childIndex 参数用于指定父形状（例如 ChainShape）的哪个子形状将进行光线投射。对于 ChainShapes，索引 1 是链上的第一条边。射线投射父形状只会测试指定的子形状，因此如果您想测试父形状的每个形状，则必须循环遍历其所有子形状。
		 *
		 * 撞击的世界位置可以通过将线向量乘以第三个返回值并将其与线起点相加来计算。
		 *
		 * hitx，hity = x1 + (x2 - x1) * 分数，y1 + (y2 - y1) * 分数
		 *
		 * @param x1 输入线起点的 x 位置。
		 * @param y1 输入线起点的 y 位置。
		 * @param x2 输入线终点的 x 位置。
		 * @param y2 输入线终点的 y 位置。
		 * @param maxFraction 光线长度参数。
		 * @param childIndex 光线投射到的子项的索引。 （默认值：1。）
		 *
		 * @returns xn — 光线击中形状的边缘的法线向量的 x 分量。
		 * @returns yn — 光线照射到形状的边缘的法线向量的 y 分量。
		 * @returns fraction — 输入线上相交的位置，是线长度的一个因素。
		 */
		rayCast(x1: number, y1: number, x2: number, y2: number, maxFraction: number, childIndex?: number): LuaMultiReturn<[number, number, number] | []>;
		/**
		 * 设置灯具的滤波器数据。
		 *
		 * 组、类别和遮罩可用于定义夹具的碰撞行为。
		 *
		 * 如果两个灯具位于同一组中，则它们要么在组为正时总是发生碰撞，要么在组为负时从不发生碰撞。如果该组为零或它们不匹配，则接触过滤器将检查灯具是否选择了具有其掩码的其他灯具的类别。如果不是这种情况，灯具就不会发生碰撞。如果他们确实选择了彼此的类别，则将使用自定义联系人过滤器的返回值。如果没有设置，它们总是会发生碰撞。
		 *
		 * 最多可以有 16 个类别。类别和掩码被编码为 16 位整数的位。
		 *
		 * 创建后，在调用此函数之前，所有灯具的类别设置为 1，掩码设置为 65535（所有类别），组设置为 0。
		 *
		 * 此功能允许一次设置灯具的所有过滤器数据。要仅设置类别、掩码或组，可以分别使用 Fixture:setCategory、Fixture:setMask 或 Fixture:setGroupIndex。
		 *
		 * @param categoryBits 类别为 0 到 65535 之间的整数。
		 * @param maskBits 掩码为 0 到 65535 之间的整数。
		 * @param groupIndex 组为从 -32768 到 32767 的整数。
		 */
		setFilterData(categoryBits: number, maskBits: number, groupIndex: number): void;
		/**
		 * 返回灯具的滤波器数据。
		 *
		 * 类别和掩码被编码为 16 位整数的位。
		 *
		 * @returns categories — 类别为 0 到 65535 之间的整数。
		 * @returns mask — 掩码为 0 到 65535 之间的整数。
		 * @returns group — 组为从 -32768 到 32767 的整数。
		 */
		getFilterData(): LuaMultiReturn<[number, number, number]>;
		/**
		 * 设置灯具所属的类别。最多可以有 16 个类别，以 1 到 16 之间的数字表示。
		 *
		 * 所有灯具的默认类别为 1。
		 *
		 * @param categories 类别。
		 */
		setCategory(categories: number[]): void;
		setCategory(...categories: number[]): void;
		/**
		 * 返回灯具所属的类别。
		 *
		 * @returns ... — 类别。
		 */
		getCategory(): LuaMultiReturn<number[]>;
		/**
		 * 设置灯具的类别掩码。最多可以有 16 个类别，以 1 到 16 之间的数字表示。
		 *
		 * 如果其他灯具也选择了该灯具的类别，则该灯具将与所选类别中的灯具发生“'NOT'”碰撞。
		 *
		 * @param categories 面具。
		 */
		setMask(categories: number[]): void;
		setMask(...categories: number[]): void;
		/**
		 * 返回该装置应与“'NOT'”碰撞的类别。
		 *
		 * @returns ... — 面具。
		 */
		getMask(): LuaMultiReturn<number[]>;
		/**
		 * 将 Lua 值与固定装置相关联。
		 *
		 * 要删除引用，请显式传递 nil。
		 *
		 * @param value 与装置关联的Lua值。
		 */
		setUserData(value: unknown): void;
		/**
		 * 返回与该装置关联的Lua值。
		 *
		 * @returns value — 与装置关联的Lua值。
		 */
		getUserData(): unknown;
		/**
		 * 返回夹具边界框的点。如果灯具有多个子级，则可以指定从 1 开始的索引。例如，一个固定装置将有多个呈链状的子项。
		 *
		 * @param childIndex 夹具的边界框。 （默认值：1。）
		 *
		 * @returns topLeftX — 左上角点的 x 位置。
		 * @returns topLeftY — 左上角点的 y 位置。
		 * @returns bottomRightX — 右下点的 x 位置。
		 * @returns bottomRightY — 右下点的 y 位置。
		 */
		getBoundingBox(childIndex?: number): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 返回质量、中心和转动惯量。
		 *
		 * @returns x — 质心的 x 位置。
		 * @returns y — 质心的 y 位置。
		 * @returns mass — 夹具的质量。
		 * @returns inertia — 转动惯量。
		 */
		getMassData(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 返回灯具所属的组。如果该组为正，则具有同一组的灯具将始终发生碰撞；如果该组为负，则永远不会发生碰撞。组零表示没有组。
		 *
		 * 组范围从 -32768 到 32767。
		 *
		 * @returns group — 灯具组。
		 */
		getGroupIndex(): number;
		/**
		 * 设置灯具所属的组。如果该组为正，则具有同一组的灯具将始终发生碰撞；如果该组为负，则永远不会发生碰撞。组零表示没有组。
		 *
		 * 组范围从 -32768 到 32767。
		 *
		 * @param index 组为从 -32768 到 32767 的整数。
		 */
		setGroupIndex(index: number): void;
	}
	/** Attach multiple bodies together to interact in unique ways.
	 */
	interface Joint extends Object {
		/**
		 * 明确摧毁关节。如果您在调用此函数后尝试使用该对象，将会发生错误。
		 *
		 * 在0.7.2中，当你没有时间等待垃圾回收时，这个函数
		 *
		 * 可用于立即释放对象。
		 */
		destroy(): void;
		/**
		 * 获取关节是否被破坏。损坏的关节无法使用。
		 *
		 * @returns destroyed — 关节是否被破坏。
		 */
		isDestroyed(): boolean;
		/**
		 * 获取表示类型的字符串。
		 *
		 * @returns type — 带有关节类型名称的字符串。
		 */
		getType(): "distance" | "revolute" | "prismatic" | "weld" | "friction" | "rope" | "pulley" | "wheel" | "mouse" | "motor" | "gear";
		/**
		 * 获取关节所附加的实体。
		 *
		 * @returns bodyA — 第一个身体。
		 * @returns bodyB — 第二个身体。
		 */
		getBodies(): LuaMultiReturn<[Body, Body]>;
		/**
		 * 获取关节的锚点。
		 *
		 * @returns x1 — 主体 1 上锚点的 x 分量。
		 * @returns y1 — 主体 1 上锚点的 y 分量。
		 * @returns x2 — 主体 2 上锚点的 x 分量。
		 * @returns y2 — 主体 2 上锚点的 y 分量。
		 */
		getAnchors(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 返回第二个物体上的反作用力（以牛顿为单位）
		 *
		 * @param inverseDeltaTime 力作用多长时间。通常为反时间步长或 1/dt。
		 *
		 * @returns x — 力的 x 分量。
		 * @returns y — 力的 y 分量。
		 */
		getReactionForce(inverseDeltaTime: number): LuaMultiReturn<[number, number]>;
		/**
		 * 返回第二个物体上的反作用扭矩。
		 *
		 * @param inverseDeltaTime 力作用多长时间。通常为反时间步长或 1/dt。
		 *
		 * @returns torque — 第二个物体上的反作用扭矩。
		 */
		getReactionTorque(inverseDeltaTime: number): number;
		/**
		 * 获取连接的Bodies是否发生碰撞。
		 *
		 * @returns c — 如果碰撞则为 true，否则为 false。
		 */
		getCollideConnected(): boolean;
		/**
		 * 将 Lua 值与关节相关联。
		 *
		 * 要删除引用，请显式传递 nil。
		 *
		 * @param value 与关节关联的 Lua 值。
		 */
		setUserData(value: unknown): void;
		/**
		 * 返回与此关节关联的 Lua 值。
		 *
		 * @returns value — 与关节关联的 Lua 值。
		 */
		getUserData(): unknown;
	}
	/** Keeps two bodies at the same distance.
	 */
	interface DistanceJoint extends Joint {
		/**
		 * 设置两个物体之间的平衡距离。
		 *
		 * @param length 两个实体之间的长度。
		 */
		setLength(length: number): void;
		/**
		 * 获取两个Body之间的平衡距离。
		 *
		 * @returns l — 两个实体之间的长度。
		 */
		getLength(): number;
		/**
		 * 设置响应速度。
		 *
		 * @param frequency 响应速度。
		 */
		setFrequency(frequency: number): void;
		/**
		 * 获取响应速度。
		 *
		 * @returns Hz — 响应速度。
		 */
		getFrequency(): number;
		/**
		 * 设置阻尼比。
		 *
		 * @param ratio 阻尼比。
		 */
		setDampingRatio(ratio: number): void;
		/**
		 * 获取阻尼比。
		 *
		 * @returns ratio — 阻尼比。
		 */
		getDampingRatio(): number;
	}
	/** Allow two Bodies to revolve around a shared point.
	 */
	interface RevoluteJoint extends Joint {
		/**
		 * 获取当前关节角度。
		 *
		 * @returns angle — 以弧度表示的关节角度。
		 */
		getJointAngle(): number;
		/**
		 * 获取当前关节角速度。
		 *
		 * @returns s — 关节角速度（弧度/秒）。
		 */
		getJointSpeed(): number;
		/**
		 * 启用/禁用关节电机。
		 *
		 * @param enabled True 表示启用，False 表示禁用。
		 */
		setMotorEnabled(enabled: boolean): void;
		/**
		 * 检查电机是否启用。
		 *
		 * @returns enabled — 如果启用则为 true，如果禁用则为 false。
		 */
		isMotorEnabled(): boolean;
		/**
		 * 设置最大电机力。
		 *
		 * @param torque 最大电机力，单位 Nm。
		 */
		setMaxMotorTorque(torque: number): void;
		/**
		 * 获取最大电机力。
		 *
		 * @returns f — 最大电机力，单位 Nm。
		 */
		getMaxMotorTorque(): number;
		/**
		 * 设置电机速度。
		 *
		 * @param speed 电机速度，弧度每秒。
		 */
		setMotorSpeed(speed: number): void;
		/**
		 * 获取电机速度。
		 *
		 * @returns s — 电机速度，弧度每秒。
		 */
		getMotorSpeed(): number;
		/**
		 * 获取当前电机力。
		 *
		 * @returns f — 当前电机力，单位 Nm。
		 */
		getMotorTorque(inverseDeltaTime: number): number;
		/**
		 * 启用/禁用关节限制。
		 *
		 * @param enabled True 表示启用，False 表示禁用。
		 */
		setLimitsEnabled(enabled: boolean): void;
		/**
		 * 检查限制是否启用。
		 *
		 * @returns enabled — 如果启用则为 true，否则为 false。
		 */
		areLimitsEnabled(): boolean;
		/** @deprecated Use areLimitsEnabled. */
		/**
		 * 检查限制是否启用。
		 *
		 * @returns enabled — 如果启用则为 true，否则为 false。
		 */
		hasLimitsEnabled(): boolean;
		/**
		 * 设置上限。
		 *
		 * @param upper 上限，以弧度为单位。
		 */
		setUpperLimit(upper: number): void;
		/**
		 * 设置下限。
		 *
		 * @param lower 下限，以弧度为单位。
		 */
		setLowerLimit(lower: number): void;
		/**
		 * 设置限制。
		 *
		 * @param lower 下限，以弧度为单位。
		 * @param upper 上限，以弧度为单位。
		 */
		setLimits(lower: number, upper: number): void;
		/**
		 * 获取上限。
		 *
		 * @returns upper — 上限，以弧度为单位。
		 */
		getUpperLimit(): number;
		/**
		 * 获取下限。
		 *
		 * @returns lower — 下限，以弧度为单位。
		 */
		getLowerLimit(): number;
		/**
		 * 获取关节限制。
		 *
		 * @returns lower — 下限，以弧度为单位。
		 * @returns upper — 上限，以弧度为单位。
		 */
		getLimits(): LuaMultiReturn<[number, number]>;
		/**
		 * 获取参考角度。
		 *
		 * @returns angle — 以弧度为单位的参考角度。
		 */
		getReferenceAngle(): number;
	}
	/** Restricts relative motion between Bodies to one shared axis.
	 */
	interface PrismaticJoint extends Joint {
		/**
		 * 获取当前联合翻译。
		 *
		 * @returns t — 联合翻译，通常以米为单位..
		 */
		getJointTranslation(): number;
		/**
		 * 获取当前关节角速度。
		 *
		 * @returns s — 关节角速度（米/秒）。
		 */
		getJointSpeed(): number;
		/**
		 * 启用/禁用关节电机。
		 *
		 * @param enabled True 表示启用，False 表示禁用。
		 */
		setMotorEnabled(enabled: boolean): void;
		/**
		 * 检查电机是否启用。
		 *
		 * @returns enabled — 如果启用则为 true，如果禁用则为 false。
		 */
		isMotorEnabled(): boolean;
		/**
		 * 设置最大电机力。
		 *
		 * @param force 最大电机力，通常以 N 为单位。
		 */
		setMaxMotorForce(force: number): void;
		/**
		 * 获取最大电机力。
		 *
		 * @returns f — 最大电机力，通常以 N 为单位。
		 */
		getMaxMotorForce(): number;
		/**
		 * 设置电机速度。
		 *
		 * @param speed 电机速度，通常以米每秒为单位。
		 */
		setMotorSpeed(speed: number): void;
		/**
		 * 获取电机速度。
		 *
		 * @returns s — 电机速度，通常以米每秒为单位。
		 */
		getMotorSpeed(): number;
		/**
		 * 返回当前电机力。
		 *
		 * @param inverseDeltaTime 力作用多长时间。通常为反时间步长或 1/dt。
		 *
		 * @returns force — 电机上的力，以牛顿为单位。
		 */
		getMotorForce(inverseDeltaTime: number): number;
		/**
		 * 启用/禁用关节限制。
		 *
		 * @returns enable — 如果启用则为 true，如果禁用则为 false。
		 */
		setLimitsEnabled(enabled: boolean): void;
		/**
		 * 检查限制是否启用。
		 *
		 * @returns enabled — 如果启用则为 true，否则为 false。
		 */
		areLimitsEnabled(): boolean;
		/** @deprecated Use areLimitsEnabled. */
		hasLimitsEnabled(): boolean;
		/**
		 * 设置上限。
		 *
		 * @param upper 上限，通常以米为单位。
		 */
		setUpperLimit(upper: number): void;
		/**
		 * 设置下限。
		 *
		 * @param lower 下限，通常以米为单位。
		 */
		setLowerLimit(lower: number): void;
		/**
		 * 设置限制。
		 *
		 * @param lower 下限，通常以米为单位。
		 * @param upper 上限，通常以米为单位。
		 */
		setLimits(lower: number, upper: number): void;
		/**
		 * 获取上限。
		 *
		 * @returns upper — 上限，通常以米为单位。
		 */
		getUpperLimit(): number;
		/**
		 * 获取下限。
		 *
		 * @returns lower — 下限，通常以米为单位。
		 */
		getLowerLimit(): number;
		/**
		 * 获取关节限制。
		 *
		 * @returns lower — 下限，通常以米为单位。
		 * @returns upper — 上限，通常以米为单位。
		 */
		getLimits(): LuaMultiReturn<[number, number]>;
		/**
		 * 获取棱柱关节的世界空间轴向量。
		 *
		 * @returns x — 世界空间轴向量的 x 轴坐标。
		 * @returns y — 世界空间轴向量的 y 轴坐标。
		 */
		getAxis(): LuaMultiReturn<[number, number]>;
		/**
		 * 获取参考角度。
		 *
		 * @returns angle — 以弧度为单位的参考角度。
		 */
		getReferenceAngle(): number;
	}
	/** A WeldJoint essentially glues two bodies together.
	 */
	interface WeldJoint extends Joint {
		/**
		 * 设置新频率。
		 *
		 * @param frequency 新频率（以赫兹为单位）。
		 */
		setFrequency(frequency: number): void;
		/**
		 * 返回频率。
		 *
		 * @returns freq — 频率（以赫兹为单位）。
		 */
		getFrequency(): number;
		/**
		 * 设置新的阻尼比。
		 *
		 * @param ratio 新的阻尼比。
		 */
		setDampingRatio(ratio: number): void;
		/**
		 * 返回关节的阻尼比。
		 *
		 * @returns ratio — 阻尼比。
		 */
		getDampingRatio(): number;
		/**
		 * 获取参考角度。
		 *
		 * @returns angle — 以弧度为单位的参考角度。
		 */
		getReferenceAngle(): number;
	}
	/** A FrictionJoint applies friction to a body.
	 */
	interface FrictionJoint extends Joint {
		/**
		 * 设置最大摩擦力（以牛顿为单位）。
		 *
		 * @param force 最大力，单位为牛顿。
		 */
		setMaxForce(force: number): void;
		/**
		 * 获取最大摩擦力（以牛顿为单位）。
		 *
		 * @returns force — 最大力，单位为牛顿。
		 */
		getMaxForce(): number;
		/**
		 * 设置最大摩擦扭矩（以牛顿米为单位）。
		 *
		 * @param torque 最大扭矩，单位为牛顿米。
		 */
		setMaxTorque(torque: number): void;
		/**
		 * 获取最大摩擦扭矩（以牛顿米为单位）。
		 *
		 * @returns torque — 最大扭矩，单位为牛顿米。
		 */
		getMaxTorque(): number;
	}
	/** The RopeJoint enforces a maximum distance between two points on two bodies. It has no other effect.
	 */
	interface RopeJoint extends Joint {
		/**
		 * 设置 RopeJoint 的最大长度。
		 *
		 * @param length RopeJoint 的新最大长度。
		 */
		setMaxLength(length: number): void;
		/**
		 * 获取 RopeJoint 的最大长度。
		 *
		 * @returns maxLength — RopeJoint 的最大长度。
		 */
		getMaxLength(): number;
	}
	/** Allows you to simulate bodies connected through pulleys.
	 */
	interface PulleyJoint extends Joint {
		/**
		 * 获取世界坐标中的地锚位置。
		 *
		 * @returns a1x — 第一个锚点的 x 坐标。
		 * @returns a1y — 第一个锚点的 y 坐标。
		 * @returns a2x — 第二个锚点的 x 坐标。
		 * @returns a2y — 第二个锚点的 y 坐标。
		 */
		getGroundAnchors(): LuaMultiReturn<[number, number, number, number]>;
		/**
		 * 获取连接到第一个主体的绳段的当前长度。
		 *
		 * @returns length — 绳段的长度。
		 */
		getLengthA(): number;
		/**
		 * 获取连接到第二个身体的绳段的当前长度。
		 *
		 * @returns length — 绳段的长度。
		 */
		getLengthB(): number;
		/**
		 * 获取滑轮比。
		 *
		 * @returns ratio — 关节的滑轮比。
		 */
		getRatio(): number;
	}
	/** Restricts a point on the second body to a line on the first body.
	 */
	interface WheelJoint extends Joint {
		/**
		 * 返回当前联合翻译。
		 *
		 * @returns position — 以米为单位的关节平移。
		 */
		getJointTranslation(): number;
		/**
		 * 返回当前关节平移速度。
		 *
		 * @returns speed — 关节的平移速度（以米/秒为单位）。
		 */
		getJointSpeed(): number;
		/**
		 * 启动和停止关节电机。
		 *
		 * @param enabled True 打开电机， false 将其关闭。
		 */
		setMotorEnabled(enabled: boolean): void;
		/**
		 * 检查关节电机是否正在运行。
		 *
		 * @returns on — 关节电机的状态。
		 */
		isMotorEnabled(): boolean;
		/**
		 * 设置电机的新速度。
		 *
		 * @param speed 关节电机的新速度，以弧度每秒为单位。
		 */
		setMotorSpeed(speed: number): void;
		/**
		 * 返回电机的速度。
		 *
		 * @returns speed — 关节电机的速度，以弧度每秒为单位。
		 */
		getMotorSpeed(): number;
		/**
		 * 设置新的最大电机扭矩。
		 *
		 * @param torque 关节电机的新最大扭矩（以牛顿米为单位）。
		 */
		setMaxMotorTorque(torque: number): void;
		/**
		 * 返回最大电机扭矩。
		 *
		 * @returns maxTorque — 关节电机的最大扭矩，单位为牛顿米。
		 */
		getMaxMotorTorque(): number;
		/**
		 * 返回电机上的当前扭矩。
		 *
		 * @param inverseDeltaTime 力作用多长时间。通常为反时间步长或 1/dt。
		 *
		 * @returns torque — 电机上的扭矩，以牛顿米为单位。
		 */
		getMotorTorque(inverseDeltaTime: number): number;
		/**
		 * 设置新的弹簧频率。
		 *
		 * @param frequency 新频率（以赫兹为单位）。
		 */
		setSpringFrequency(frequency: number): void;
		/**
		 * 返回弹簧频率。
		 *
		 * @returns freq — 频率（以赫兹为单位）。
		 */
		getSpringFrequency(): number;
		/**
		 * 设置新的阻尼比。
		 *
		 * @param ratio 新的阻尼比。
		 */
		setSpringDampingRatio(ratio: number): void;
		/**
		 * 返回阻尼比。
		 *
		 * @returns ratio — 阻尼比。
		 */
		getSpringDampingRatio(): number;
		/**
		 * 获取轮关节的世界空间轴向量。
		 *
		 * @returns x — 世界空间轴向量的 x 轴坐标。
		 * @returns y — 世界空间轴向量的 y 轴坐标。
		 */
		getAxis(): LuaMultiReturn<[number, number]>;
	}
	/** For controlling objects with the mouse.
	 */
	interface MouseJoint extends Joint {
		/**
		 * 设置目标点。
		 *
		 * @param x 目标的 x 分量。
		 * @param y 目标的 y 分量。
		 */
		setTarget(x: number, y: number): void;
		/**
		 * 获取目标点。
		 *
		 * @returns x — 目标的 x 分量。
		 * @returns y — 目标的 x 分量。
		 */
		getTarget(): LuaMultiReturn<[number, number]>;
		/**
		 * 设置允许的最高力。
		 *
		 * @param force 最大允许力。
		 */
		setMaxForce(force: number): void;
		/**
		 * 获取允许的最高力。
		 *
		 * @returns f — 最大允许力。
		 */
		getMaxForce(): number;
		/**
		 * 设置新频率。
		 *
		 * @param frequency 新频率（以赫兹为单位）。
		 */
		setFrequency(frequency: number): void;
		/**
		 * 返回频率。
		 *
		 * @returns freq — 频率（以赫兹为单位）。
		 */
		getFrequency(): number;
		/**
		 * 设置新的阻尼比。
		 *
		 * @param ratio 新的阻尼比。
		 */
		setDampingRatio(ratio: number): void;
		/**
		 * 返回阻尼比。
		 *
		 * @returns ratio — 新的阻尼比。
		 */
		getDampingRatio(): number;
	}
	/** Controls the relative motion between two Bodies. Position and rotation offsets can be specified, as well as the maximum motor force and torque that will be applied to reach the target offsets.
	 */
	interface MotorJoint extends Joint {
		/**
		 * 设置关节所连接的两个实体之间的目标线性偏移。
		 *
		 * @param x 目标线性偏移的 x 分量，相对于第一个 Body。
		 * @param y 相对于第一个 Body 的目标线性偏移的 y 分量。
		 */
		setLinearOffset(x: number, y: number): void;
		/**
		 * 获取关节所附着的两个实体之间的目标线性偏移。
		 *
		 * @returns x — 目标线性偏移的 x 分量，相对于第一个 Body。
		 * @returns y — 相对于第一个 Body 的目标线性偏移的 y 分量。
		 */
		getLinearOffset(): LuaMultiReturn<[number, number]>;
		/**
		 * 设置关节所连接的两个实体之间的目标角度偏移。
		 *
		 * @param angle 以弧度为单位的目标角度偏移：第二个物体的角度减去第一个物体的角度。
		 */
		setAngularOffset(angle: number): void;
		/**
		 * 获取关节所连接的两个主体之间的目标角度偏移。
		 *
		 * @returns angleoffset — 以弧度为单位的目标角度偏移：第二个物体的角度减去第一个物体的角度。
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
		 * 设置齿轮接头的比率。
		 *
		 * @param ratio 关节的新比例。
		 */
		setRatio(ratio: number): void;
		/**
		 * 获取齿轮接头的比率。
		 *
		 * @returns ratio — 关节的比例。
		 */
		getRatio(): number;
		/**
		 * 获取此 GearJoint 连接的关节。
		 *
		 * @returns joint1 — 第一个连接的关节。
		 * @returns joint2 — 第二个连接的关节。
		 */
		getJoints(): LuaMultiReturn<[RevoluteJoint | PrismaticJoint, RevoluteJoint | PrismaticJoint]>;
	}
	/** @noSelf */
	/** Can simulate 2D rigid body physics in a realistic manner. This module is based on Box2D, and this API corresponds to the Box2D API as closely as possible.
	 */
	interface Physics {
		/**
		 * 将像素设置为米比例因子。
		 *
		 * 物理模块中的所有坐标都除以该数字并转换为米，它创建了一种将对象直接绘制到屏幕上而不需要图形转换的便捷方法。
		 *
		 * 建议创建不大于10倍比例的形状。这很重要，因为 Box2D 经过调整，可以很好地处理 0.1 到 10 米的形状尺寸。默认仪表刻度为 30。
		 *
		 * @param scale 整数比例因子。
		 */
		setMeter(this: void, scale: number): void;
		/**
		 * 返回仪表比例因子。
		 *
		 * 物理模块中的所有坐标都除以这个数字，创建了一种将对象直接绘制到屏幕上的便捷方法，而无需进行图形转换。
		 *
		 * 建议创建不大于10倍比例的形状。这很重要，因为 Box2D 经过调整，可以很好地处理 0.1 到 10 米的形状尺寸。
		 *
		 * @returns scale — 整数比例因子。
		 */
		getMeter(this: void): number;
		/**
		 * 创造一个新世界。
		 *
		 * @param xGravity 重力的 x 分量。 （默认值：0。）
		 * @param yGravity 重力的 y 分量。 （默认值：0。）
		 * @param sleep 这个世界的身体是否可以睡觉。 （默认值：true。）
		 *
		 * @returns world — 美丽的新世界。
		 */
		newWorld(this: void, xGravity?: number, yGravity?: number, sleep?: boolean): World;
		/**
		 * 创建一个新的实体。
		 *
		 * 身体分为三种类型。
		 *
		 * * 静态物体不移动，具有无限质量，可用于关卡边界。
		 *
		 * * 动态物体是模拟中的主要角色，它们与一切物体发生碰撞。
		 *
		 * * 运动体不会对力产生反应，只会与动态体发生碰撞。
		 *
		 * 连接或移除夹具时会计算主体的质量，但可以随时使用 Body:setMass 或 Body:resetMassData 进行更改。
		 *
		 * @param world 创造身体的世界。
		 * @param x 主体的 x 位置。 （默认值：0。）
		 * @param y 主体的 y 位置。 （默认值：0。）
		 * @param type 主体的类型。 （默认：'static'。）
		 *
		 * @returns body — 一个新的身体。
		 */
		newBody(this: void, world: World, x?: number, y?: number, type?: BodyType): Body;
		/**
		 * 创建夹具并将其附加到主体。
		 *
		 * 请注意，在创建 Fixture 时，Shape 对象被复制而不是保留为引用。要获取 Fixture 拥有的 Shape 对象，请使用 Fixture:getShape。
		 *
		 * @param body 连接固定装置的主体。
		 * @param shape 要复制到夹具的形状。
		 * @param density 灯具的密度。 （默认值：1。）
		 *
		 * @returns fixture — 新的固定装置。
		 */
		newFixture(this: void, body: Body, shape: Shape, density?: number): Fixture;
		/**
		 * 创建一个新的 CircleShape。
		 *
		 * @param radius 圆的半径。
		 * @param x 圆的 x 位置。
		 * @param y 圆的 y 位置。
		 *
		 * @returns shape — 新形状。
		 */
		newCircleShape(this: void, radius: number): CircleShape;
		newCircleShape(this: void, x: number, y: number, radius: number): CircleShape;
		/**
		 * 创建矩形 PolygonShapes 的简写。
		 *
		 * 默认情况下，本地原点位于矩形的“'center'”，而不是图形的左上角。
		 *
		 * @param width 矩形的宽度。
		 * @param height 矩形的高度。
		 * @param x 沿 x 轴的偏移。
		 * @param y 沿 y 轴的偏移量。
		 * @param angle 矩形的初始角度。 （默认值：0。）
		 *
		 * @returns shape — 一个新的多边形形状。
		 */
		newRectangleShape(this: void, width: number, height: number): PolygonShape;
		newRectangleShape(this: void, x: number, y: number, width: number, height: number, angle?: number): PolygonShape;
		/**
		 * 创建一个新的PolygonShape。
		 *
		 * 这个形状最多可以有8个顶点，并且必须形成一个凸形状。
		 *
		 * @param points 用于构造多边形的顶点列表，格式为{x1, y1, x2, y2, x3, y3, ...}。
		 *
		 * @returns shape — 一个新的多边形形状。
		 */
		newPolygonShape(this: void, points: number[]): PolygonShape;
		newPolygonShape(this: void, ...points: number[]): PolygonShape;
		/**
		 * 创建一个新的 EdgeShape。
		 *
		 * @param x1 第一个点的 x 位置。
		 * @param y1 第一个点的 y 位置。
		 * @param x2 第二个点的 x 位置。
		 * @param y2 第二个点的 y 位置。
		 *
		 * @returns shape — 新形状。
		 */
		newEdgeShape(this: void, x1: number, y1: number, x2: number, y2: number): EdgeShape;
		/**
		 * 创建一个新的 ChainShape。
		 *
		 * @param loop 如果链应该循环回到第一个点。
		 * @param points 用于构造 ChainShape 的点列表，格式为 {x1, y1, x2, y2, ...}。
		 *
		 * @returns shape — 新形状。
		 */
		newChainShape(this: void, loop: boolean, points: number[]): ChainShape;
		newChainShape(this: void, loop: boolean, ...points: number[]): ChainShape;
		/**
		 * 在两个实体之间创建一个 DistanceJoint。
		 *
		 * 该关节将两个物体上两点之间的距离限制为恒定。这两个点是在世界坐标中指定的，并且在创建此关节时假定两个主体就位。第一个锚点连接到第一主体，第二个锚点连接到第二主体，并且这些点限定距离关节的长度。
		 *
		 * @param body1 第一个连接到关节的主体。
		 * @param body2 连接到关节的第二个主体。
		 * @param x1 第一个锚点（世界空间）的 x 位置。
		 * @param y1 第一个锚点（世界空间）的 y 位置。
		 * @param x2 第二个锚点（世界空间）的 x 位置。
		 * @param y2 第二个锚点（世界空间）的 y 位置。
		 * @param collideConnected 指定两个实体是否应该相互碰撞。 （默认值：假。）
		 *
		 * @returns joint — 新的距离关节。
		 */
		newDistanceJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean): DistanceJoint;
		/**
		 * 在两个实体之间创建枢轴关节。
		 *
		 * 这个关节将两个物体连接到一个点，它们可以围绕该点旋转。
		 *
		 * @param body1 第一具尸体。
		 * @param body2 第二具尸体。
		 * @param x 连接点的 x 位置。
		 * @param y 连接点的 y 位置。
		 * @param collideConnected 指定两个实体是否应该相互碰撞。 （默认值：假。）
		 * @param x1 第一个连接点的 x 位置。
		 * @param y1 第一个连接点的 y 位置。
		 * @param x2 第二个连接点的 x 位置。
		 * @param y2 第二个连接点的 y 位置。
		 * @param referenceAngle body1 和 body2 之间的参考角度，以弧度为单位。 （默认值：0。）
		 *
		 * @returns joint — 新的旋转接头。
		 */
		newRevoluteJoint(this: void, body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): RevoluteJoint;
		newRevoluteJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean, referenceAngle?: number): RevoluteJoint;
		/**
		 * 在两个实体之间创建 PrismaticJoint。
		 *
		 * 棱柱关节约束两个实体在指定轴上相对移动。它不允许相对旋转。其定义和操作与旋转关节类似，但用平移和力代替角度和扭矩。
		 *
		 * @param body1 第一个用棱柱关节连接的主体。
		 * @param body2 用棱柱关节连接的第二个主体。
		 * @param x 锚点的 x 坐标。
		 * @param y 锚点的 y 坐标。
		 * @param axisX 轴向量的 x 坐标。取决于过载：轴单位矢量的 x 坐标。
		 * @param axisY 轴向量的 y 坐标。取决于过载：轴单位矢量的 y 坐标。
		 * @param collideConnected 指定两个实体是否应该相互碰撞。 （默认值：假。）
		 * @param x1 第一个锚点的 x 坐标。
		 * @param y1 第一个锚点的 y 坐标。
		 * @param x2 第二个锚点的 x 坐标。
		 * @param y2 第二个锚点的 y 坐标。
		 * @param referenceAngle body1 和 body2 之间的参考角度，以弧度为单位。 （默认值：0。）
		 *
		 * @returns joint — 新的棱柱形关节。
		 */
		newPrismaticJoint(this: void, body1: Body, body2: Body, x: number, y: number, axisX: number, axisY: number, collideConnected?: boolean): PrismaticJoint;
		newPrismaticJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axisX: number, axisY: number, collideConnected?: boolean, referenceAngle?: number): PrismaticJoint;
		/**
		 * 在两个实体之间创建约束关节。 WeldJoint 本质上是将两个实体粘合在一起。然而，由于 Box2D 的迭代求解器，约束有点软。
		 *
		 * @param body1 第一个连接到关节的主体。
		 * @param body2 连接到关节的第二个主体。
		 * @param x 锚点的 x 位置（世界空间）。
		 * @param y 锚点（世界空间）的 y 位置。
		 * @param collideConnected 指定两个实体是否应该相互碰撞。 （默认值：假。）
		 * @param x1 第一个锚点（世界空间）的 x 位置。
		 * @param y1 第一个锚点（世界空间）的 y 位置。
		 * @param x2 第二个锚点（世界空间）的 x 位置。
		 * @param y2 第二个锚点（世界空间）的 y 位置。
		 * @param referenceAngle body1 和 body2 之间的参考角度，以弧度为单位。 （默认值：0。）
		 *
		 * @returns joint — 新的 WeldJoint。
		 */
		newWeldJoint(this: void, body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): WeldJoint;
		newWeldJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean, referenceAngle?: number): WeldJoint;
		/**
		 * 在两个物体之间创建摩擦接头。 FrictionJoint 将摩擦力施加到物体上。
		 *
		 * @param body1 第一个连接到关节的主体。
		 * @param body2 连接到关节的第二个主体。
		 * @param x 锚点的 x 位置。
		 * @param y 锚点的 y 位置。
		 * @param collideConnected 指定两个实体是否应该相互碰撞。 （默认值：假。）
		 * @param x1 第一个锚点的 x 位置。
		 * @param y1 第一个锚点的 y 位置。
		 * @param x2 第二个锚点的 x 位置。
		 * @param y2 第二个锚点的 y 位置。
		 *
		 * @returns joint — 新的摩擦关节。
		 */
		newFrictionJoint(this: void, body1: Body, body2: Body, x: number, y: number, collideConnected?: boolean): FrictionJoint;
		newFrictionJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collideConnected?: boolean): FrictionJoint;
		/**
		 * 在两个实体之间创建关节。它的唯一功能是强制这些实体之间的最大距离。
		 *
		 * @param body1 第一个连接到关节的主体。
		 * @param body2 连接到关节的第二个主体。
		 * @param x1 第一个锚点的 x 位置。
		 * @param y1 第一个锚点的 y 位置。
		 * @param x2 第二个锚点的 x 位置。
		 * @param y2 第二个锚点的 y 位置。
		 * @param maxLength 实体的最大距离。
		 * @param collideConnected 指定两个实体是否应该相互碰撞。 （默认值：假。）
		 *
		 * @returns joint — 新的 RopeJoint。
		 */
		newRopeJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, maxLength: number, collideConnected?: boolean): RopeJoint;
		/**
		 * 创建一个 PulleyJoint 将两个实体相互连接并连接到地面。
		 *
		 * 滑轮接头模拟带有可选滑轮组的滑轮。如果比率参数的值不同于 1，则模拟绳索在一侧比另一侧延伸得更快。在滑轮接头中，模拟绳索的总长度为常数 length1 +ratio * length2，该值在创建滑轮接头时设置。
		 *
		 * 如果一侧完全伸展，滑轮接头可能会出现不可预测的行为。建议使用 setMaxLengths 方法来限制每条边可以达到的最大长度。
		 *
		 * @param body1 第一个与滑轮接头连接的主体。
		 * @param body2 与滑轮接头连接的第二个主体。
		 * @param groundX1 第一个主体的地锚点的 x 坐标。
		 * @param groundY1 第一个主体的地锚的 y 坐标。
		 * @param groundX2 第二个主体的地锚点的 x 坐标。
		 * @param groundY2 第二个物体的地锚点的 y 坐标。
		 * @param x1 第一个主体中滑轮关节锚点的 x 坐标。
		 * @param y1 第一个主体中滑轮关节锚点的 y 坐标。
		 * @param x2 第二个主体中滑轮关节锚点的 x 坐标。
		 * @param y2 第二个主体中滑轮关节锚点的 y 坐标。
		 * @param ratio 关节比例。 （默认值：1。）
		 * @param collideConnected 指定两个实体是否应该相互碰撞。 （默认值：true。）
		 *
		 * @returns joint — 新的滑轮接头。
		 */
		newPulleyJoint(this: void, body1: Body, body2: Body, groundX1: number, groundY1: number, groundX2: number, groundY2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collideConnected?: boolean): PulleyJoint;
		/**
		 * 创建车轮接头。
		 *
		 * @param body1 第一具尸体。
		 * @param body2 第二具尸体。
		 * @param x 锚点的 x 位置。
		 * @param y 锚点的 y 位置。
		 * @param axisX 轴单位向量的 x 位置。
		 * @param axisY 轴单位向量的 y 位置。
		 * @param collideConnected 指定两个实体是否应该相互碰撞。 （默认值：假。）
		 * @param x1 第一个锚点的 x 位置。
		 * @param y1 第一个锚点的 y 位置。
		 * @param x2 第二个锚点的 x 位置。
		 * @param y2 第二个锚点的 y 位置。
		 *
		 * @returns joint — 新的 WheelJoint。
		 */
		newWheelJoint(this: void, body1: Body, body2: Body, x: number, y: number, axisX: number, axisY: number, collideConnected?: boolean): WheelJoint;
		newWheelJoint(this: void, body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axisX: number, axisY: number, collideConnected?: boolean): WheelJoint;
		/**
		 * 在身体和鼠标之间创建一个关节。
		 *
		 * 这个关节实际上将身体连接到世界上的一个固定点。为了使其跟随鼠标，固定点必须在每个时间步更新（示例如下）。
		 *
		 * 使用 MouseJoint 而不是直接更改身体位置的优点是，对其他关节的碰撞和反应由物理引擎处理。
		 *
		 * @param body 连接到鼠标的主体。
		 * @param x 连接点的 x 位置。
		 * @param y 连接点的 y 位置。
		 *
		 * @returns joint — 新的鼠标关节。
		 */
		newMouseJoint(this: void, body: Body, x: number, y: number): MouseJoint;
		/**
		 * 在两个实体之间创建一个关节，控制它们之间的相对运动。
		 *
		 * 一旦创建了 MotorJoint，就可以指定位置和旋转偏移，以及为达到目标偏移而应用的最大电机力和扭矩。
		 *
		 * @param body1 第一个连接到关节的主体。
		 * @param body2 连接到关节的第二个主体。
		 * @param correctionFactor 关节的初始位置修正系数，取值范围为1。（默认：0.3。）
		 * @param collideConnected 指定两个实体是否应该相互碰撞。 （默认值：假。）
		 *
		 * @returns joint — 新的 MotorJoint。
		 */
		newMotorJoint(this: void, body1: Body, body2: Body, correctionFactor?: number, collideConnected?: boolean): MotorJoint;
		/**
		 * 创建连接两个关节的 GearJoint。
		 *
		 * 齿轮接头连接两个必须是棱柱或旋转接头的接头。使用这个关节需要它使用的关节将各自的身体连接到地面，并以地面作为第一身体。破坏主体和关节时，必须确保先破坏齿轮关节，然后再破坏其他关节。
		 *
		 * 齿轮接头具有一个比率，该比率确定所连接接头的角度或距离值如何相互关联。公式坐标 1 + 比率 * 坐标 2 始终具有在创建齿轮接头时设置的常量值。
		 *
		 * @param joint1 第一个与齿轮接头连接的接头。
		 * @param joint2 与齿轮接头连接的第二个接头。
		 * @param ratio 齿轮比。 （默认值：1。）
		 * @param collideConnected 指定两个实体是否应该相互碰撞。 （默认值：假。）
		 *
		 * @returns joint — 新的齿轮接头。
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
		 * 如果您的游戏文件夹（或 .love 文件）中存在名为 conf.lua 的文件，则该文件会在加载 LÖVE 模块之前运行。您可以使用此文件覆盖 love.conf 函数，该函数稍后由 LÖVE 'boot' 脚本调用。使用 love.conf 函数，您可以设置一些配置选项，并更改窗口的默认大小、加载哪些模块等内容。
		 *
		 * @param t love.conf 函数采用一个参数：一张包含所有默认值的表，您可以根据自己的喜好覆盖这些默认值。例如，如果您想更改默认窗口大小，请执行：

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
		 * @param t.identity 该标志确定游戏的保存目录的名称。请注意，您只能指定名称，而不能指定创建位置：
t.identity = "gabe_HL3" -- Correct

t.identity = "c:/Users/gabe/HL3" -- Incorrect
Alternatively love.filesystem.setIdentity can be used to set the save directory outside of the config file. (Default: nil.)
		 * @param t.appendidentity 该标志确定是否应先搜索游戏目录然后保存目录（true）或否则（false）（默认值：false。）
		 * @param t.version t.version 应该是一个字符串，代表您的游戏所针对的 LÖVE 版本。它的格式应为 "X.Y.Z"，其中 X 是主要版本号，Y 是次要版本号，Z 是补丁级别。它允许 LÖVE 在不兼容时显示警告。它的默认值是运行的 LÖVE 版本。 （默认："11.5"。）
		 * @param t.console 确定是否应在游戏窗口旁边打开控制台（仅限 Windows）。注意：在 OSX 上，您可以通过终端运行 LÖVE 来获取控制台输出。 （默认值：假。）
		 * @param t.accelerometerjoystick 设置 iOS 和 Android 上的设备加速计是否应显示为 3 轴操纵杆。不使用时禁用加速计可能会减少 CPU 使用率。 （默认值：true。）
		 * @param t.externalstorage 设置文件是保存在 Android 上的外部存储（true）还是内部存储（false）中。 （默认值：假。）
		 * @param t.gammacorrect 确定是否启用伽玛校正渲染（当系统支持时）。 （默认值：假。）
		 * @param t.audio 音频选项。
		 * @param t.audio.mic 向用户请求麦克风权限。当用户允许时，love.audio.getRecordingDevices 将列出可用的录音设备。否则，love.audio.getRecordingDevices 返回空表，并在调用时显示一条消息以通知用户。 （默认值： false。）
		 * @param t.audio.mixwithsystem 设置 LÖVE 打开时是否播放其他应用程序的背景音频/音乐。有关更多详细信息，请参阅 love.system.hasBackgroundMusic。 （默认值：true。）
		 * @param t.window 可以推迟窗口创建，直到在代码中首次调用 love.window.setMode 。为此，请在 love.conf 中设置 t.window = nil （或在旧版本中设置 t.screen = nil。）如果这样做，如果在代码中的第一个 love.window.setMode 之前调用 love.graphics 中的任何函数，LÖVE 可能会崩溃。

The t.window table was named t.screen in versions prior to 0.9.0. The t.screen table doesn't exist in love.conf in 0.9.0, and the t.window table doesn't exist in love.conf in 0.8.0. This means love.conf will fail to execute (therefore it will fall back to default values) if care is not taken to use the correct table for the LÖVE version being used.
		 * @param t.window.title 设置游戏所在窗口的标题。或者可以使用 love.window.setTitle 在配置文件之外更改窗口标题。 （默认："Untitled"。）
		 * @param t.window.icon 用作窗口图标的图像的文件路径。并非所有操作系统都支持非常大的图标图像。也可以使用 love.window.setIcon. 更改图标（默认：nil。）
		 * @param t.window.width 设置窗口的尺寸。如果这些标志设置为 0，LÖVE 会自动使用用户的桌面尺寸。 （默认值：800。）
		 * @param t.window.height 设置窗口的尺寸。如果这些标志设置为 0，LÖVE 会自动使用用户的桌面尺寸。 （默认值：600。）
		 * @param t.window.borderless 从窗口中删除所有边框视觉效果。请注意，不同操作系统的影响可能会有所不同。 （默认值：假。）
		 * @param t.window.resizable 如果设置为 true，则允许用户调整游戏窗口的大小。 （默认值：假。）
		 * @param t.window.minwidth 设置游戏窗口的最小宽度和高度（如果用户可以调整其大小）。如果您将 window.width 和 window.height 设置较低的值，LÖVE 将始终支持通过 window.minwidth 和 window.minheight 设置的最小尺寸。 （默认值：1。）
		 * @param t.window.minheight 设置游戏窗口的最小宽度和高度（如果用户可以调整其大小）。如果您将 window.width 和 window.height 设置较低的值，LÖVE 将始终支持通过 window.minwidth 和 window.minheight 设置的最小尺寸。 （默认值：1。）
		 * @param t.window.fullscreen 是否以全屏（true）或窗口（false）模式运行游戏。也可以通过 love.window.setFullscreen 或 love.window.setMode. 切换全屏（默认： false。）
		 * @param t.window.fullscreentype 指定要使用的全屏模式类型（正常或桌面）。通常建议使用桌面，因为它在某些操作系统上比正常模式限制更少。 （默认："desktop"。）
		 * @param t.window.usedpiscale 设置是否启用或禁用自动 DPI 缩放。 （默认值：true。）
		 * @param t.window.vsync 启用或禁用垂直同步。垂直同步尝试使游戏保持稳定的帧速率，并可以防止屏幕撕裂等问题。如果您不知道关闭垂直同步可能产生的影响，建议保持垂直同步处于激活状态。在 LÖVE 11.0 之前，该值是布尔值（true 或 false）。从 LÖVE 11.0 开始，该值为数字（1 表示启用垂直同步，0 表示禁用垂直同步，-1 表示在支持时使用自适应垂直同步）。

Note that in iOS, vertical synchronization is always enabled and cannot be changed. (Default: true.)
		 * @param t.window.depth 深度缓冲区中每个样本的位数（16/24/32，默认为 nil）（默认：nil。）
		 * @param t.window.stencil 然后是深度缓冲区中每个样本的位数（一般为 8，默认为 nil）（默认：nil。）
		 * @param t.window.msaa 用于多重采样抗锯齿的样本数。 （默认值：0。）
		 * @param t.window.display 如果有多个监视器可用，则显示窗口的显示器索引。 （默认值：1。）
		 * @param t.window.highdpi 请参阅 love.window.getPixelScale、love.window.toPixels 和 love.window.fromPixels. 如果您无法在具有 Retina 显示屏的 Mac 或 iOS 系统上测试游戏，建议禁用此选项，因为需要调整代码以确保内容看起来正确。 （默认值：假。）
		 * @param t.window.x 确定窗口在用户屏幕上的位置。或者 love.window.setPosition 可用于动态更改位置。 （默认值：无。）
		 * @param t.window.y 确定窗口在用户屏幕上的位置。或者 love.window.setPosition 可用于动态更改位置。 （默认值：无。）
		 * @param t.modules 模块选项。
		 * @param t.modules.audio 启用音频模块。 （默认值：true。）
		 * @param t.modules.event 启用事件模块。 （默认值：true。）
		 * @param t.modules.graphics 启用图形模块。 （默认值：true。）
		 * @param t.modules.image 启用图像模块。 （默认值：true。）
		 * @param t.modules.joystick 启用摇杆模块。 （默认值：true。）
		 * @param t.modules.keyboard 启用键盘模块。 （默认值：true。）
		 * @param t.modules.math 启用数学模块。 （默认值：true。）
		 * @param t.modules.mouse 启用鼠标模块。 （默认值：true。）
		 * @param t.modules.physics 启用物理模块。 （默认值：true。）
		 * @param t.modules.sound 启用声音模块。 （默认值：true。）
		 * @param t.modules.system 启用系统模块。 （默认值：true。）
		 * @param t.modules.timer 启用定时器模块。 （默认值：true。）
		 * @param t.modules.touch 启用触摸模块。 （默认值：true。）
		 * @param t.modules.video 启用视频模块。 （默认值：true。）
		 * @param t.modules.window 启用窗口模块。 （默认值：true。）
		 * @param t.modules.thread 启用线程模块。 （默认值：true。）
		 */
		conf?: (this: void, config: Config) => void;
		/**
		 * 该函数在游戏开始时仅调用一次。
		 *
		 * 重载说明：
		 * 1. 在 LÖVE 11.0 中，当从非 fused LÖVE 可执行文件运行时，传递的参数不包括游戏名称和 fused 命令行标志（如果存在）。以前的版本按原样传递参数，不进行任何过滤。
		 *
		 * @param arg 给予游戏的命令行参数。
		 * @param unfilteredArg 给可执行文件的未过滤的命令行参数（参见#Notes）。
		 */
		load?: (this: void) => void;
		/**
		 * 回调函数用于更新游戏每一帧的状态。
		 *
		 * @param dt 自上次更新以来的时间（以秒为单位）。
		 */
		update?: (this: void, deltaTime: number) => void;
		/**
		 * 用于在屏幕上绘制每一帧的回调函数。
		 */
		draw?: (this: void) => void;
		/** Return true to cancel a love.event.quit request. */
		/**
		 * 游戏关闭时触发的回调函数。
		 *
		 * @returns r — 中止退出。如果属实，请勿关闭游戏。
		 */
		quit?: (this: void) => boolean | void;
		/**
		 * 按键时触发的回调函数。
		 *
		 * 重载说明：
		 * 1. 扫描码与键盘布局无关，因此如果按下美式键盘上与 'w' 键相同位置的键，无论该键的标签是什么或用户的操作系统设置是什么，都会生成扫描码 'w' 。需要使用 love.keyboard.setKeyRepeat 启用按键重复才能接收重复按键事件。这不会影响 love.textinput.
		 * 2. 需要使用 love.keyboard.setKeyRepeat 启用按键重复才能接收重复按键事件。
		 *
		 * @param key 按键的字符。取决于过载：按下的按键的字符。
		 * @param scancode 代表按下的键的扫描码。
		 * @param isrepeat 该按键事件是否重复。按键重复之间的延迟取决于用户的系统设置。
		 */
		keypressed?: (this: void, key: string, scancode: string, isRepeat: boolean) => void;
		/**
		 * 释放键盘按键时触发的回调函数。
		 *
		 * 重载说明：
		 * 1. 扫描码与键盘布局无关，因此如果按下与美式键盘上的 'w' 键相同位置的键，将使用扫描码 'w'，无论该键的标签是什么或用户的操作系统设置是什么。
		 *
		 * @param key 已释放按键的字符。
		 * @param scancode 代表释放密钥的扫描码。
		 */
		keyreleased?: (this: void, key: string, scancode: string) => void;
		/**
		 * 当用户输入文本时调用。例如，如果在美式键盘布局上按下 shift-2，将生成文本 '@'。
		 *
		 * 重载说明：
		 * 1. 虽然Lua字符串可以很好地存储UTF-8编码的unicode文本，但是Lua字符串库中的许多函数不会像您期望的那样处理文本。例如，#text（和 string.len(text)）将给出字符串中“'bytes'”的数量，而不是 unicode 字符的数量。 Lua wiki 和 Lua 创建者之一的演示给出了更深入的解释，并提供了一些技巧。 utf8 库可用于操作 UTF-8 编码的 unicode 文本（例如此函数中给出的 text 参数）。在 Android 和 iOS 上，默认情况下禁用 textinput；调用 love.keyboard.setTextInput 来启用它。
		 *
		 * @param text UTF-8 编码的 unicode 文本。
		 */
		textinput?: (this: void, text: string) => void;
		/**
		 * 当 IME（输入法编辑器）的候选文本发生更改时调用。
		 *
		 * 候选文本并不是用户最终选择的最终文本。为此使用 love.textinput 。
		 *
		 * @param text UTF-8 编码的 unicode 候选文本。
		 * @param start 所选候选文本的起始光标。
		 * @param length 所选候选文本的长度。可能是 0。
		 */
		textedited?: (this: void, text: string, start: number, length: number) => void;
		/**
		 * 按下鼠标按钮时触发的回调函数。
		 *
		 * 重载说明：
		 * 1. 使用love.wheelmoved 检测鼠标滚轮运动。在 0.10.0 及更高版本中，它不会注册为按钮按下。
		 *
		 * @param x 鼠标 x 位置，以像素为单位。
		 * @param y 鼠标 y 位置（以像素为单位）。
		 * @param button 按下的按钮索引。 1 是鼠标主按钮，2 是鼠标辅助按钮，3 是中间按钮。其他按钮取决于鼠标。
		 * @param istouch 如果鼠标按钮按下源自触摸屏触摸，则为 true。
		 * @param presses 短时间、小面积的按下次数，用于模拟双击、三击
		 */
		mousepressed?: (this: void, x: number, y: number, button: number, isTouch: boolean, presses: number) => void;
		/**
		 * 释放鼠标按钮时触发的回调函数。
		 *
		 * @param x 鼠标 x 位置，以像素为单位。
		 * @param y 鼠标 y 位置（以像素为单位）。
		 * @param button 已释放的按钮索引。 1 是鼠标主按钮，2 是鼠标辅助按钮，3 是中间按钮。其他按钮取决于鼠标。
		 * @param istouch 如果鼠标按钮释放源自触摸屏触摸释放，则为 true。
		 * @param presses 短时间、小面积的按下次数，用于模拟双击、三击
		 */
		mousereleased?: (this: void, x: number, y: number, button: number, isTouch: boolean, presses: number) => void;
		/**
		 * 鼠标移动时触发的回调函数。
		 *
		 * 重载说明：
		 * 1. 如果为鼠标启用了相对模式，则不保证 '''dx''' and '''dy''' arguments of this callback will update but '''x''' and '''y''' 。
		 *
		 * @param x x 轴上的鼠标位置。
		 * @param y y 轴上的鼠标位置。
		 * @param dx 自上次调用 love.mousemoved 以来沿 x 轴移动的量。
		 * @param dy 自上次调用 love.mousemoved 以来沿 y 轴移动的量。
		 * @param istouch 如果鼠标按钮按下源自触摸屏触摸，则为 true。
		 */
		mousemoved?: (this: void, x: number, y: number, deltaX: number, deltaY: number, isTouch: boolean) => void;
		/**
		 * 鼠标滚轮移动时触发的回调函数。
		 *
		 * @param x 水平鼠标滚轮移动量。正值表示向右移动。
		 * @param y 垂直鼠标滚轮移动量。正值表示向上移动。
		 */
		wheelmoved?: (this: void, x: number, y: number) => void;
		/**
		 * 触摸屏被触摸时触发的回调函数。
		 *
		 * 重载说明：
		 * 1. 该标识符仅保证对于特定的触摸按压是唯一的，直到使用该标识符调用 love.touchreleased 为止，此时它可以重新用于新的触摸按压。 LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为 1 范围内的标准化值，而此 API 报告以像素为单位的位置。
		 *
		 * @param id 触摸按键的标识符。
		 * @param x 触摸按键在窗口内的 x 轴位置（以像素为单位）。
		 * @param y 触摸按键在窗口内的 y 轴位置（以像素为单位）。
		 * @param dx 触摸按键在窗口内的 x 轴移动（以像素为单位）。这应该始终为零。
		 * @param dy 触摸按键在窗口内的 y 轴移动（以像素为单位）。这应该始终为零。
		 * @param pressure 施加的压力大小。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
		 */
		touchpressed?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		/**
		 * 触摸屏停止触摸时触发的回调函数。
		 *
		 * 重载说明：
		 * 1. 该标识符仅保证对于特定的触摸按压是唯一的，直到使用该标识符调用 love.touchreleased 为止，此时它可以重新用于新的触摸按压。 LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为 1 范围内的标准化值，而此 API 报告以像素为单位的位置。
		 *
		 * @param id 触摸按键的标识符。
		 * @param x 窗口内触摸的 x 轴位置（以像素为单位）。
		 * @param y 窗口内触摸的 y 轴位置（以像素为单位）。
		 * @param dx 窗口内触摸的 x 轴移动（以像素为单位）。
		 * @param dy 窗口内触摸的 y 轴移动（以像素为单位）。
		 * @param pressure 施加的压力大小。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
		 */
		touchreleased?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		/**
		 * 触摸按键在触摸屏内移动时触发的回调函数。
		 *
		 * 重载说明：
		 * 1. 该标识符仅保证对于特定的触摸按压是唯一的，直到使用该标识符调用 love.touchreleased 为止，此时它可以重新用于新的触摸按压。 LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为 1 范围内的标准化值，而此 API 报告以像素为单位的位置。
		 *
		 * @param id 触摸按键的标识符。
		 * @param x 窗口内触摸的 x 轴位置（以像素为单位）。
		 * @param y 窗口内触摸的 y 轴位置（以像素为单位）。
		 * @param dx 窗口内触摸的 x 轴移动（以像素为单位）。
		 * @param dy 窗口内触摸的 y 轴移动（以像素为单位）。
		 * @param pressure 施加的压力大小。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
		 */
		touchmoved?: (this: void, id: TouchID, x: number, y: number, deltaX: number, deltaY: number, pressure: number) => void;
		/**
		 * 线程遇到错误时触发的回调函数。
		 *
		 * @param thread 产生错误的线程。
		 * @param errorstr 错误消息。
		 */
		threaderror?: (this: void, thread: Thread, error: string) => void;
		/**
		 * 连接操纵杆时调用。
		 *
		 * 重载说明：
		 * 1. 对于游戏启动时已连接的每个操纵杆，也会在 love.load 之后触发此回调。
		 *
		 * @param joystick 新连接的操纵杆对象。
		 */
		joystickadded?: (this: void, joystick: Joystick) => void;
		/**
		 * 当操纵杆断开连接时调用。
		 *
		 * @param joystick 现在断开连接的操纵杆对象。
		 */
		joystickremoved?: (this: void, joystick: Joystick) => void;
		/**
		 * 当按下操纵杆按钮时调用。
		 *
		 * @param joystick 操纵杆对象。
		 * @param button 按钮编号。
		 */
		joystickpressed?: (this: void, joystick: Joystick, button: number) => void;
		/**
		 * 释放操纵杆按钮时调用。
		 *
		 * @param joystick 操纵杆对象。
		 * @param button 按钮编号。
		 */
		joystickreleased?: (this: void, joystick: Joystick, button: number) => void;
		/**
		 * 当操纵杆轴移动时调用。
		 *
		 * @param joystick 操纵杆对象。
		 * @param axis 轴编号。
		 * @param value 新的轴值。
		 */
		joystickaxis?: (this: void, joystick: Joystick, axis: number, value: number) => void;
		/**
		 * 当操纵杆帽方向改变时调用。
		 *
		 * @param joystick 操纵杆对象。
		 * @param hat 帽子号码。
		 * @param direction 新帽子方向。
		 */
		joystickhat?: (this: void, joystick: Joystick, hat: number, direction: JoystickHat) => void;
		/**
		 * 当按下操纵杆的虚拟游戏手柄按钮时调用。
		 *
		 * @param joystick 操纵杆对象。
		 * @param button 虚拟游戏手柄按钮。
		 */
		gamepadpressed?: (this: void, joystick: Joystick, button: GamepadButton) => void;
		/**
		 * 当操纵杆的虚拟游戏手柄按钮被释放时调用。
		 *
		 * @param joystick 操纵杆对象。
		 * @param button 虚拟游戏手柄按钮。
		 */
		gamepadreleased?: (this: void, joystick: Joystick, button: GamepadButton) => void;
		/**
		 * 当操纵杆的虚拟游戏手柄轴移动时调用。
		 *
		 * @param joystick 操纵杆对象。
		 * @param axis 虚拟游戏手柄轴。
		 * @param value 新的轴值。
		 */
		gamepadaxis?: (this: void, joystick: Joystick, axis: GamepadAxis, value: number) => void;

		/** Compatibility entry point. Dora remains the only application loop owner. */
		/**
		 * main 函数，包含主循环。省略时使用合理的默认值。
		 *
		 * @returns mainLoop — 处理一帧的函数，包括调用时的事件和渲染。
		 */
		run(this: void): void;
		}
	}

	const love: Love.Root;
}

declare const loveModule: Love.Root;
export = loveModule;
