-- 可绘制图像类型。
local record Image
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Image): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Image): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Image, type_name: string): boolean
	-- 获取纹理的宽度。
	--
	-- 返回值：
	--  width: 纹理的宽度。
	getWidth: function(self: Image): number
	-- 获取纹理的高度。
	--
	-- 返回值：
	--  height: 纹理的高度。
	getHeight: function(self: Image): number
	-- 获取纹理的宽度和高度。
	--
	-- 返回值：
	--  width: 纹理的宽度。
	--  height: 纹理的高度。
	getDimensions: function(self: Image): number, number
	-- 获取纹理的宽度（以像素为单位）。
	--
	-- DPI 比例因子，而不是像素。使用 getWidth 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelWidth。
	--
	-- 返回值：
	--  pixelwidth: 纹理的宽度，以像素为单位。
	getPixelWidth: function(self: Image): integer
	-- 获取纹理的高度（以像素为单位）。
	--
	-- DPI 比例因子，而不是像素。使用 getHeight 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelHeight。
	--
	-- 返回值：
	--  pixelheight: 纹理的高度，以像素为单位。
	getPixelHeight: function(self: Image): integer
	-- 获取纹理的宽度和高度（以像素为单位）。
	--
	-- Texture:getDimensions 获取纹理的尺寸，单位是按纹理的 DPI 比例因子缩放的单位，而不是像素。使用 getDimensions
	-- 进行与绘制纹理相关的计算（例如计算原点偏移），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelDimensions。
	--
	-- 返回值：
	--  pixelwidth: 纹理的宽度，以像素为单位。
	--  pixelheight: 纹理的高度，以像素为单位。
	getPixelDimensions: function(self: Image): integer, integer
	-- 获取纹理的DPI比例因子。
	--
	-- DPI 比例因子表示相对像素密度。 DPI 比例因子为 2 意味着纹理在每个维度上的像素密度是 DPI 比例因子为 1 的纹理的两倍（同一区域中像素数量的 4 倍）。
	--
	-- 例如，像素尺寸为 100x100、DPI 比例因子为 2 的纹理将被绘制为 50x50。这对于高 dpi/视网膜显示器非常有用，可以轻松地交换更高或更低像素密度的图像和画布，而无需任何额外的手动缩放逻辑。
	--
	-- 返回值：
	--  dpiscale: 纹理的 DPI 比例因子。
	getDPIScale: function(self: Image): number
	-- 获取纹理的类型。
	--
	-- 返回值：
	--  texturetype: 纹理的类型。
	getTextureType: function(self: Image): string
	-- 获取体积纹理的深度。对于 2D、立方体贴图和数组纹理返回 1。
	--
	-- 返回值：
	--  depth: 体积纹理的深度。
	getDepth: function(self: Image): integer
	-- 获取数组纹理中的层数/切片数。对于 2D、立方体贴图和体积纹理，返回 1。
	--
	-- 返回值：
	--  layers: 阵列纹理中的层数。
	getLayerCount: function(self: Image): integer
	-- 获取纹理中包含的 mipmap 数量。如果纹理不是使用 mipmap 创建的，它将返回 1。
	--
	-- 返回值：
	--  mipmaps: 纹理中 mipmap 的数量。
	getMipmapCount: function(self: Image): integer
	-- 获取纹理的 mipmap 过滤模式。在 11.0 之前，此方法仅适用于图像。
	--
	-- 返回值：
	--  mode: 在 mipmap 级别之间使用的过滤模式。如果未启用 mipmap 过滤，则为 nil。
	--  sharpness: 用于确定图像在绘制时是否应使用比正常情况更多或更少详细的 mipmap 级别的值。
	getMipmapFilter: function(self: Image): string, number
	-- 设置纹理的 mipmap 过滤器模式。在 11.0 之前，此方法仅适用于图像。
	--
	-- Mipmapping 在以缩小比例绘制纹理时非常有用。它可以提高性能并减少锯齿问题。
	--
	-- 在创建时启用了 mipmaps 标志，以便 mipmap 过滤器产生任何效果。在 0.10.0 之前的版本中，最好在使用 love.graphics.newImage
	-- 创建图像后直接调用此方法，以避免某些图形驱动程序中的错误。
	--
	-- 由于硬件限制和驱动程序错误，在 0.10.0 之前的版本中，未从 CompressedData 加载的图像必须具有二维幂（64x64、512x256 等）才能使用 mipmap。
	--
	-- 重载说明：
	-- 1. 在移动设备（Android 和 iOS）上，不支持清晰度参数，并且不会执行任何操作。您可以使用自定义压缩，其 CompressedData 包含 mipmap 数据，它将使用该数据。 2. 禁用 mipmap 过滤。
	--
	-- 参数：
	--  filter: 在 mipmap 级别之间使用的过滤模式。 'nearest' 通常会提供更好的性能。
	--  sharpness: 正的锐度值使纹理在绘制时使用更详细的 mipmap 级别，但会牺牲性能。负值则相反。 （默认值：0。）
	setMipmapFilter: function(self: Image, filter?: string, sharpness?: number)
	-- 获取纹理的像素格式。
	--
	-- 返回值：
	--  format: 创建纹理时使用的像素格式。
	getFormat: function(self: Image): string
	-- 获取图像是否是从压缩数据创建的。
	--
	-- 压缩图像在 VRAM 中占用的空间更少，并且绘制压缩图像通常比绘制根据原始像素数据创建的图像更有效。
	--
	-- 返回值：
	--  compressed: 图像是否作为压缩纹理存储在 GPU 上。
	isCompressed: function(self: Image): boolean
	-- 获取图像是否是在线性（非伽玛校正）标志设置为 true 的情况下创建的。
	--
	-- 当未启用伽玛校正渲染时，此方法始终返回 false。
	--
	-- 返回值：
	--  linear: 当启用伽玛校正渲染时，图像的内部像素格式是否是线性的（未进行伽玛校正）。
	isFormatLinear: function(self: Image): boolean
	-- 替换图像的内容。
	--
	-- 参数：
	--  data: 用于替换内容的新 ImageData。
	--  slice: 要替换哪个立方体贴图面、数组索引或体积层（如果适用）。 （默认值：1。）
	--  mipmap: 如果图像具有 mipmap，则要替换的 mimap 级别。 （默认值：1。）
	--  x: 距要替换的图像左上角的 x 偏移量（以像素为单位）。给定 ImageData 的宽度加上此值不得大于图像指定 mipmap 级别的像素宽度。 （默认值：0。）
	--  y: 距要替换的图像左上角的 y 偏移量（以像素为单位）。给定 ImageData 的高度加上此值不得大于图像指定 mipmap 级别的像素高度。 （默认值：0。）
	--  reload_mipmaps: 替换图像像素后是否生成新的 mipmap。如果图像是使用自动生成的 mipmap 创建的，则默认为 true，否则默认为 false。 （默认值：假。）
	replacePixels: function(self: Image, data: any, slice?: integer, mipmap?: integer, x?: integer, y?: integer, reload_mipmaps?: boolean)
	-- 获取是否可以绘制纹理并将其发送到着色器。
	--
	-- 使用模板和/或深度 PixelFormat 创建的画布默认情况下不可读，除非在传递到 love.graphics.newCanvas. 的设置表中指定 Readable=true
	--
	-- 仍然可以渲染不可读的画布。
	--
	-- 返回值：
	--  readable: 纹理是否可读。
	isReadable: function(self: Image): boolean
	-- 获取在着色器中从深度纹理采样时使用的比较模式。
	--
	-- 深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
	--
	-- 返回值：
	--  compare: 在着色器中从此纹理采样时使用的比较模式，如果尚未在此纹理上调用 setDepthSampleMode，则为 nil。 （默认值：无。）
	getDepthSampleMode: function(self: Image): string | nil
	-- 设置从着色器中的深度纹理采样时使用的比较模式。深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
	--
	-- 在着色器中使用具有比较模式设置的深度纹理时，必须将其声明为sampler2DShadow 并在GLSL 3 着色器中使用。在着色器中访问纹理的结果将返回一个介于 0 和 1
	-- 之间的浮点数，与通过比较操作的测试集的样本数量成正比（如果启用双线性过滤，最多将使用 4 个样本）。
	--
	-- 深度纹理比较只能与可读的深度格式画布一起使用。
	--
	-- 参数：
	--  mode: 在着色器中从此纹理采样时使用的比较模式。
	setDepthSampleMode: function(self: Image, mode?: string)
	-- 设置纹理的过滤模式。
	--
	-- 参数：
	--  min_filter: 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	--  mag_filter: 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更大的尺寸渲染它）。 （默认值：分钟。）
	--  anisotropy: 使用的各向异性过滤的最大数量。 （默认值：1。）
	setFilter: function(self: Image, min_filter: string, mag_filter?: string, anisotropy?: number)
	-- 获取纹理的滤镜模式。
	--
	-- 返回值：
	--  min: 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	--  mag: 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	--  anisotropy: 使用的各向异性过滤的最大量。
	getFilter: function(self: Image): string, string, number
	-- 设置纹理的环绕属性。
	--
	-- 当使用大于纹理范围的四边形绘制纹理时，或者使用使用 [0, 1] 之外的纹理坐标的自定义着色器时，此函数设置纹理的重复方式。纹理可以被夹紧或设置为在水平和垂直方向上重复。
	--
	-- 夹紧的纹理仅出现一次（纹理的边缘拉伸以填充四边形的范围），而重复的纹理则根据四边形中的空间重复多次。
	--
	-- 参数：
	--  horizontal: 纹理的水平环绕模式。
	--  vertical: 纹理的垂直环绕模式。 （默认：水平。）
	--  depth: 体积纹理 z 轴的包裹模式。 （默认值：水平。）
	setWrap: function(self: Image, horizontal: string, vertical?: string, depth?: string): boolean
	-- 获取纹理的环绕属性。
	--
	-- 该函数返回当前设置的纹理水平和垂直环绕模式。
	--
	-- 返回值：
	--  horiz: 纹理的水平环绕模式。
	--  vert: 纹理的垂直环绕模式。
	--  depth: 体积纹理 z 轴的包裹模式。
	getWrap: function(self: Image): string, string, string
end

-- 解码、流式传输和控制视频的对象。
local record VideoStream
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: VideoStream): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: VideoStream): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: VideoStream, type_name: string): boolean
	-- 播放视频流。
	play: function(self: VideoStream)
	-- 暂停视频流。
	pause: function(self: VideoStream)
	-- 设置VideoStream的当前播放位置。
	--
	-- 参数：
	--  seconds: 自视频流开始以来的时间（以秒为单位）。
	seek: function(self: VideoStream, seconds: number)
	-- 倒带视频流。与 VideoStream:seek(0) 同义词。
	rewind: function(self: VideoStream)
	-- 获取VideoStream的当前播放位置。
	--
	-- 返回值：
	--  seconds: 视频流开始处的秒数。
	tell: function(self: VideoStream): number
	-- 获取VideoStream是否正在播放。
	--
	-- 返回值：
	--  playing: VideoStream是否正在播放。
	isPlaying: function(self: VideoStream): boolean
	-- 获取视频流的文件名。
	--
	-- 返回值：
	--  filename: 视频流的文件名
	getFilename: function(self: VideoStream): string
	setSync: function(self: VideoStream, source?: Source)
end

local record Video
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Video): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Video): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Video, type_name: string): boolean
	-- 获取用于解码和控制视频的VideoStream对象。
	--
	-- 返回值：
	--  stream: 用于解码和控制视频的VideoStream。
	getStream: function(self: Video): VideoStream
	-- 获取用于播放视频音频的音频源。如果视频没有音频，或者使用 nil 参数调用 Video:setSource ，则可能返回 nil。
	--
	-- 返回值：
	--  source: 用于音频播放的音频源，如果视频没有音频则为零。
	getSource: function(self: Video): Source | nil
	-- 设置用于播放视频音频的音频源。音频源还控制播放速度和同步。
	--
	-- 参数：
	--  source: 用于音频播放的音频源，或 nil 以禁用音频同步。 （默认值：无。）
	setSource: function(self: Video, source?: Source)
	-- 获取视频的宽度（以像素为单位）。
	--
	-- 返回值：
	--  width: 视频的宽度。
	getWidth: function(self: Video): integer
	-- 获取视频的高度（以像素为单位）。
	--
	-- 返回值：
	--  height: 视频的高度。
	getHeight: function(self: Video): integer
	-- 获取视频的宽度和高度（以像素为单位）。
	--
	-- 返回值：
	--  width: 视频的宽度。
	--  height: 视频的高度。
	getDimensions: function(self: Video): integer, integer
	getPixelWidth: function(self: Video): integer
	getPixelHeight: function(self: Video): integer
	getPixelDimensions: function(self: Video): integer, integer
	-- 设置绘制视频时使用的缩放过滤器。
	--
	-- 参数：
	--  min_filter: 缩小视频时使用的过滤模式。
	--  mag_filter: 放大视频时使用的过滤模式。
	--  anisotropy: 使用的各向异性过滤的最大量。 （默认值：1。）
	setFilter: function(self: Video, min_filter: string, mag_filter?: string, anisotropy?: number)
	-- 获取绘制视频时使用的缩放过滤器。
	--
	-- 返回值：
	--  min: 缩小视频时使用的过滤模式。
	--  mag: 放大视频时使用的过滤模式。
	--  anisotropy: 使用的各向异性过滤的最大量。
	getFilter: function(self: Video): string, string, number
end

-- 该模块负责解码、控制和流式传输视频文件。
local record VideoModule
	-- 创建一个新的视频流。目前仅支持 Ogg Theora 视频文件。 VideoStreams 无法绘制视频，请参阅 love.graphics.newVideo 。
	--
	-- 参数：
	--  filename: Ogg Theora 视频文件的文件路径。
	--
	-- 返回值：
	--  videostream: 一个新的视频流。
	newVideoStream: function(filename: string): VideoStream
end

-- Canvas 用于离屏渲染。将其视为您可以绘制的不可见屏幕，但只有将其绘制到实际可见屏幕上时，它才会可见。它也称为 "render to texture"。
local record Canvas
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Canvas): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Canvas): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Canvas, type_name: string): boolean
	-- 获取纹理的宽度。
	--
	-- 返回值：
	--  width: 纹理的宽度。
	getWidth: function(self: Canvas): integer
	-- 获取纹理的高度。
	--
	-- 返回值：
	--  height: 纹理的高度。
	getHeight: function(self: Canvas): integer
	-- 获取纹理的宽度和高度。
	--
	-- 返回值：
	--  width: 纹理的宽度。
	--  height: 纹理的高度。
	getDimensions: function(self: Canvas): integer, integer
	-- 获取纹理的宽度（以像素为单位）。
	--
	-- DPI 比例因子，而不是像素。使用 getWidth 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelWidth。
	--
	-- 返回值：
	--  pixelwidth: 纹理的宽度，以像素为单位。
	getPixelWidth: function(self: Canvas): integer
	-- 获取纹理的高度（以像素为单位）。
	--
	-- DPI 比例因子，而不是像素。使用 getHeight 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelHeight。
	--
	-- 返回值：
	--  pixelheight: 纹理的高度，以像素为单位。
	getPixelHeight: function(self: Canvas): integer
	-- 获取纹理的宽度和高度（以像素为单位）。
	--
	-- Texture:getDimensions 获取纹理的尺寸，单位是按纹理的 DPI 比例因子缩放的单位，而不是像素。使用 getDimensions
	-- 进行与绘制纹理相关的计算（例如计算原点偏移），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelDimensions。
	--
	-- 返回值：
	--  pixelwidth: 纹理的宽度，以像素为单位。
	--  pixelheight: 纹理的高度，以像素为单位。
	getPixelDimensions: function(self: Canvas): integer, integer
	-- 获取纹理的DPI比例因子。
	--
	-- DPI 比例因子表示相对像素密度。 DPI 比例因子为 2 意味着纹理在每个维度上的像素密度是 DPI 比例因子为 1 的纹理的两倍（同一区域中像素数量的 4 倍）。
	--
	-- 例如，像素尺寸为 100x100、DPI 比例因子为 2 的纹理将被绘制为 50x50。这对于高 dpi/视网膜显示器非常有用，可以轻松地交换更高或更低像素密度的图像和画布，而无需任何额外的手动缩放逻辑。
	--
	-- 返回值：
	--  dpiscale: 纹理的 DPI 比例因子。
	getDPIScale: function(self: Canvas): number
	-- 获取纹理的像素格式。
	--
	-- 返回值：
	--  format: 创建纹理时使用的像素格式。
	getFormat: function(self: Canvas): string
	-- 获取绘制到画布时使用的多重采样抗锯齿 (MSAA) 样本数。
	--
	-- 如果运行 LÖVE 的系统不支持该数字，则该数字可能与用作 love.graphics.newCanvas 参数的数字不同。
	--
	-- 返回值：
	--  samples: 画布在绘制时使用的多重采样抗锯齿样本数。
	getMSAA: function(self: Canvas): integer
	-- 获取纹理的类型。
	--
	-- 返回值：
	--  texturetype: 纹理的类型。
	getTextureType: function(self: Canvas): string
	-- 获取体积纹理的深度。对于 2D、立方体贴图和数组纹理返回 1。
	--
	-- 返回值：
	--  depth: 体积纹理的深度。
	getDepth: function(self: Canvas): integer
	-- 获取数组纹理中的层数/切片数。对于 2D、立方体贴图和体积纹理，返回 1。
	--
	-- 返回值：
	--  layers: 阵列纹理中的层数。
	getLayerCount: function(self: Canvas): integer
	-- 获取纹理中包含的 mipmap 数量。如果纹理不是使用 mipmap 创建的，它将返回 1。
	--
	-- 返回值：
	--  mipmaps: 纹理中 mipmap 的数量。
	getMipmapCount: function(self: Canvas): integer
	-- 获取创建此 Canvas 时使用的 MipmapMode。
	--
	-- 返回值：
	--  mode: 创建此 Canvas 时使用的 mipmap 模式。
	getMipmapMode: function(self: Canvas): string
	-- 获取纹理的 mipmap 过滤模式。在 11.0 之前，此方法仅适用于图像。
	--
	-- 返回值：
	--  mode: 在 mipmap 级别之间使用的过滤模式。如果未启用 mipmap 过滤，则为 nil。
	--  sharpness: 用于确定图像在绘制时是否应使用比正常情况更多或更少详细的 mipmap 级别的值。
	getMipmapFilter: function(self: Canvas): string, number
	-- 设置纹理的 mipmap 过滤器模式。在 11.0 之前，此方法仅适用于图像。
	--
	-- Mipmapping 在以缩小比例绘制纹理时非常有用。它可以提高性能并减少锯齿问题。
	--
	-- 在创建时启用了 mipmaps 标志，以便 mipmap 过滤器产生任何效果。在 0.10.0 之前的版本中，最好在使用 love.graphics.newImage
	-- 创建图像后直接调用此方法，以避免某些图形驱动程序中的错误。
	--
	-- 由于硬件限制和驱动程序错误，在 0.10.0 之前的版本中，未从 CompressedData 加载的图像必须具有二维幂（64x64、512x256 等）才能使用 mipmap。
	--
	-- 重载说明：
	-- 1. 在移动设备（Android 和 iOS）上，不支持清晰度参数，并且不会执行任何操作。您可以使用自定义压缩，其 CompressedData 包含 mipmap 数据，它将使用该数据。 2. 禁用 mipmap 过滤。
	--
	-- 参数：
	--  filter: 在 mipmap 级别之间使用的过滤模式。 'nearest' 通常会提供更好的性能。
	--  sharpness: 正的锐度值使纹理在绘制时使用更详细的 mipmap 级别，但会牺牲性能。负值则相反。 （默认值：0。）
	setMipmapFilter: function(self: Canvas, filter?: string, sharpness?: number)
	-- 获取在着色器中从深度纹理采样时使用的比较模式。
	--
	-- 深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
	--
	-- 返回值：
	--  compare: 在着色器中从此纹理采样时使用的比较模式，如果尚未在此纹理上调用 setDepthSampleMode，则为 nil。 （默认值：无。）
	getDepthSampleMode: function(self: Canvas): string | nil
	-- 设置从着色器中的深度纹理采样时使用的比较模式。深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
	--
	-- 在着色器中使用具有比较模式设置的深度纹理时，必须将其声明为sampler2DShadow 并在GLSL 3 着色器中使用。在着色器中访问纹理的结果将返回一个介于 0 和 1
	-- 之间的浮点数，与通过比较操作的测试集的样本数量成正比（如果启用双线性过滤，最多将使用 4 个样本）。
	--
	-- 深度纹理比较只能与可读的深度格式画布一起使用。
	--
	-- 参数：
	--  mode: 在着色器中从此纹理采样时使用的比较模式。
	setDepthSampleMode: function(self: Canvas, mode?: string)
	-- 根据最高分辨率 mipmap 级别的内容为画布生成 mipmap。
	--
	-- 创建画布时必须将 mipmap 设置为除 'none' 之外的 MipmapMode，此函数才能正常工作。仅当 Canvas 不是活动渲染目标时才应调用它。
	--
	-- 如果mipmap模式设置为'auto'，当从这个Canvas切换到另一个Canvas或切换到主屏幕时，会在love.graphics.setCanvas内部自动调用此函数。
	generateMipmaps: function(self: Canvas)
	-- 使用函数渲染到画布。
	--
	-- 这是 love.graphics.setCanvas 的快捷方式：
	--
	-- canvas:renderTo( func )
	--
	-- 与
	--
	-- love.graphics.setCanvas( 画布 )
	--
	-- func()
	--
	-- love.graphics.setCanvas()
	--
	-- 参数：
	--  callback: 执行绘图操作的函数。
	renderTo: function(self: Canvas, callback: function())
	-- 获取是否可以绘制纹理并将其发送到着色器。
	--
	-- 使用模板和/或深度 PixelFormat 创建的画布默认情况下不可读，除非在传递到 love.graphics.newCanvas. 的设置表中指定 Readable=true
	--
	-- 仍然可以渲染不可读的画布。
	--
	-- 返回值：
	--  readable: 纹理是否可读。
	isReadable: function(self: Canvas): boolean
	-- 从画布的内容生成图像数据。
	--
	-- 参数：
	--  slice: 分别是立方体贴图、数组或体积类型画布的立方体贴图面索引、数组索引或深度层。对于常规 2D 画布，此参数将被忽略。
	--  mipmap: 要使用的 mipmap 索引，用于具有 mipmap 的画布。 （默认值：1。）
	--  x: 画布内要捕获的区域的左上角（以像素为单位）的 x 轴。
	--  y: 画布内要捕获的区域的左上角（以像素为单位）的 y 轴。
	--  width: 画布内要捕获的区域的宽度（以像素为单位）。
	--  height: 画布内要捕获的区域的高度（以像素为单位）。
	--
	-- 返回值：
	--  data: 由画布内容制成的新 ImageData。
	newImageData: function(self: Canvas, slice?: integer, mipmap?: integer, x?: integer, y?: integer, width?: integer, height?: integer): any
	-- 设置纹理的过滤模式。
	--
	-- 参数：
	--  min_filter: 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	--  mag_filter: 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更大的尺寸渲染它）。 （默认值：分钟。）
	--  anisotropy: 使用的各向异性过滤的最大数量。 （默认值：1。）
	setFilter: function(self: Canvas, min_filter: string, mag_filter?: string, anisotropy?: number)
	-- 获取纹理的滤镜模式。
	--
	-- 返回值：
	--  min: 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	--  mag: 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	--  anisotropy: 使用的各向异性过滤的最大量。
	getFilter: function(self: Canvas): string, string, number
	-- 设置纹理的环绕属性。
	--
	-- 当使用大于纹理范围的四边形绘制纹理时，或者使用使用 [0, 1] 之外的纹理坐标的自定义着色器时，此函数设置纹理的重复方式。纹理可以被夹紧或设置为在水平和垂直方向上重复。
	--
	-- 夹紧的纹理仅出现一次（纹理的边缘拉伸以填充四边形的范围），而重复的纹理则根据四边形中的空间重复多次。
	--
	-- 参数：
	--  horizontal: 纹理的水平环绕模式。
	--  vertical: 纹理的垂直环绕模式。 （默认：水平。）
	--  depth: 体积纹理 z 轴的包裹模式。 （默认值：水平。）
	setWrap: function(self: Canvas, horizontal: string, vertical?: string, depth?: string): boolean
	-- 获取纹理的环绕属性。
	--
	-- 该函数返回当前设置的纹理水平和垂直环绕模式。
	--
	-- 返回值：
	--  horiz: 纹理的水平环绕模式。
	--  vert: 纹理的垂直环绕模式。
	--  depth: 体积纹理 z 轴的包裹模式。
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

-- 定义可以在屏幕上绘制的字符的形状。
local record Font
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Font): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Font): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Font, type_name: string): boolean
	-- 确定给定字符串所采用的最大宽度（考虑换行符）。
	--
	-- 参数：
	--  text: 一个字符串。
	--
	-- 返回值：
	--  width: 文本的宽度。
	getWidth: function(self: Font, text: string): number
	-- 获取字体的高度。
	--
	-- 字体的高度是包括任何间距的大小；它需要的高度。
	--
	-- 返回值：
	--  height: 字体的高度（以像素为单位）。
	getHeight: function(self: Font): number
	-- 获取字体的基线。
	--
	-- 大多数脚本都共享基线的概念：字符所在的假想水平线。在某些脚本中，部分字形位于基线下方。
	--
	-- 返回值：
	--  baseline: 字体的基线（以像素为单位）。
	getBaseline: function(self: Font): number
	-- 获取字体的上升度。
	--
	-- 上升跨越基线和距基线最远的字形顶部之间的距离。
	--
	-- 返回值：
	--  ascent: 字体的上升（以像素为单位）。
	getAscent: function(self: Font): number
	-- 获取字体的血统。
	--
	-- 下降跨越字体中基线和最低下降字形之间的距离。
	--
	-- 返回值：
	--  descent: 字体的下降（以像素为单位）。
	getDescent: function(self: Font): number
	-- 获取 Font 是否可以渲染字符或字符串。
	--
	-- 参数：
	--  text_or_codepoint: UTF-8 编码的 unicode 字符串。
	--
	-- 返回值：
	--  hasglyph: 字体是否可以渲染字符串中的所有UTF-8字符。取决于重载：字体是否可以渲染字符表示的所有字形。取决于重载：字体是否可以渲染由代码点数字表示的所有字形。
	hasGlyphs: function(self: Font, text_or_codepoint: string | integer, ...: string | integer): boolean
	-- 获取字体中两个字符之间的字距调整。
	--
	-- 字距调整通常在 love.graphics.print、文本对象、Font:getWidth、Font:getWrap 等中自动处理。当手动将文本拼接在一起时，此功能非常有用。
	--
	-- 参数：
	--  left: 左边的字符。取决于重载：左侧字形的 unicode 编号。
	--  right: 正确的字符。取决于重载：正确字形的 unicode 编号。
	--
	-- 返回值：
	--  kerning: 添加到两个字符之间的间距的字距调整量。可能是负值。
	getKerning: function(self: Font, left: string | integer, right: string | integer): number
	-- 设置后备字体。当字体不包含字形时，它将替换下一个后续后备字体中的字形。这类似于在层叠样式表 (CSS) 中设置 'font stack'。
	--
	-- 重载说明：
	-- 1. 如果调用此函数，则应在调用 love.graphics.print、Font:getWrap 和其他使用字形定位信息的 Font 方法之前调用。每个后备字体必须从与主字体相同的文件类型创建。例如，从 .ttf
	-- 文件创建的字体只能使用从 .ttf 文件创建的后备字体。
	setFallbacks: function(self: Font, ...: Font)
	-- 设置行高。
	--
	-- 当以行渲染字体时，实际高度将由行高乘以字体高度确定。默认值为 1.0。
	--
	-- 参数：
	--  height: 新行高。
	setLineHeight: function(self: Font, height: number)
	-- 获取行高。
	--
	-- 这将是之前由 Font:setLineHeight 设置的值，默认情况下为 1.0。
	--
	-- 返回值：
	--  height: 当前行高。
	getLineHeight: function(self: Font): number
	-- 获取字体的 DPI 比例因子。
	--
	-- DPI 比例因子表示相对像素密度。 DPI 比例因子为 2 意味着与 DPI 比例因子为 1 的字体相比，字体的字形在每个维度上的像素密度是两倍（同一区域中像素数量的 4 倍）。
	--
	-- TrueType 字体的字体大小在内部按字体指定的 DPI 比例因子进行缩放。默认情况下，LÖVE 在创建 TrueType 字体时使用屏幕的 DPI 比例因子。
	--
	-- 返回值：
	--  dpiscale: 字体的 DPI 比例因子。
	getDPIScale: function(self: Font): number
	-- 获取字体的过滤模式。
	--
	-- 返回值：
	--  min: 缩小字体时使用的过滤模式。
	--  mag: 放大字体时使用的过滤模式。
	--  anisotropy: 使用的各向异性过滤的最大量。
	getFilter: function(self: Font): string, string, number
	-- 设置字体的过滤模式。
	--
	-- 参数：
	--  min: 如何缩小字体。
	--  mag: 如何放大字体。
	--  anisotropy: 使用的各向异性过滤的最大量。 （默认值：1。）
	setFilter: function(self: Font, min: string, mag?: string, anisotropy?: number)
	-- 获取文本的格式信息（给定换行限制）。
	--
	-- 此函数正确解释换行符（即 '\n'）。
	--
	-- 参数：
	--  text: 将被换行的文本。
	--  wrap_limit: 在换行之前允许“'text'”每行的最大宽度（以像素为单位）。
	--
	-- 返回值：
	--  width: 换行文本的最大宽度。
	--  wrappedtext: 包含换行的每一行文本的序列。
	getWrap: function(self: Font, text: string, wrap_limit: number): number, {string}
end

-- 可绘制文本。
local record Text
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Text): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Text, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Text): boolean
	-- 用新的未格式化字符串替换 Text 对象的内容。
	--
	-- 重载说明：
	-- 1. 在绘制文本对象时，love.graphics.setColor 设置的颜色将与文本的颜色相结合（相乘）。
	--
	-- 参数：
	--  text: 要使用的新文本字符串。取决于重载：包含用作新文本的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
	--  text.color1: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
	--  text.string1: 文本字符串，其颜色由前一个颜色指定。
	--  text.color2: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
	--  text.string2: 文本字符串，其颜色由前一个颜色指定。
	--  text....: 附加颜色和字符串。
	set: function(self: Text, text: any)
	-- 用新的格式化字符串替换 Text 对象的内容。
	--
	-- 重载说明：
	-- 1. 在绘制文本对象时，love.graphics.setColor 设置的颜色将与文本的颜色相结合（相乘）。
	--
	-- 参数：
	--  text: 要使用的新文本字符串。取决于重载：包含用作新文本的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
	--  text.color1: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
	--  text.string1: 文本字符串，其颜色由前一个颜色指定。
	--  text.color2: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
	--  text.string2: 文本字符串，其颜色由前一个颜色指定。
	--  text....: 附加颜色和字符串。
	--  wrap_limit: 自动换行之前文本的最大宽度（以像素为单位）。
	--  align: 文本的对齐方式。
	setf: function(self: Text, text: any, wrap_limit: number, align: string)
	-- 将附加彩色文本添加到 Text 对象的指定位置。
	--
	-- 重载说明：
	-- 1. 在绘制文本对象时，love.graphics.setColor 设置的颜色将与文本的颜色相结合（相乘）。
	--
	-- 参数：
	--  text: 要添加到对象的文本。取决于重载：包含要添加到对象的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
	--  text.color1: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
	--  text.string1: 文本字符串，其颜色由前一个颜色指定。
	--  text.color2: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
	--  text.string2: 文本字符串，其颜色由前一个颜色指定。
	--  text....: 附加颜色和字符串。
	--  transform_or_x: 新文本在 x 轴上的位置。 （默认值：0。）
	--  y: 新文本在 y 轴上的位置。 （默认值：0。）
	--  angle: 新文本的方向（以弧度表示）。 （默认值：0。）
	--  scale_x: x 轴上的比例因子。 （默认值：1。）
	--  scale_y: y 轴的比例因子。 （默认值：sx。）
	--  origin_x: x 轴上的原点偏移。 （默认值：0。）
	--  origin_y: y 轴上的原点偏移。 （默认值：0。）
	--  shear_x: x 轴上的剪切/倾斜因子。 （默认值：0。）
	--  shear_y: y 轴上的剪切/倾斜因子。 （默认值：0。）
	--
	-- 返回值：
	--  index: 可与 Text:getWidth 或 Text:getHeight 一起使用的索引号。
	add: function(self: Text, text: any, transform_or_x?: any, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer
	-- 将附加格式化/彩色文本添加到 Text 对象的指定位置。
	--
	-- 在任何缩放、旋转和其他坐标转换之前应用自动换行限制。因此，即使比例参数发生变化，在给定相同的换行限制的情况下，每行的文本量也保持不变。
	--
	-- 重载说明：
	-- 1. 在绘制文本对象时，love.graphics.setColor 设置的颜色将与文本的颜色相结合（相乘）。
	--
	-- 参数：
	--  text: 要添加到对象的文本。取决于重载：包含要添加到对象的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
	--  text.color1: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
	--  text.string1: 文本字符串，其颜色由前一个颜色指定。
	--  text.color2: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
	--  text.string2: 文本字符串，其颜色由前一个颜色指定。
	--  text....: 附加颜色和字符串。
	--  wrap_limit: 自动换行之前文本的最大宽度（以像素为单位）。
	--  align: 文本的对齐方式。
	--  transform_or_x: 新文本的位置（x 轴）。
	--  y: 新文本的位置（y 轴）。
	--  angle: 方向（弧度）。 （默认值：0。）
	--  scale_x: 比例因子（x 轴）。 （默认值：1。）
	--  scale_y: 比例因子（y 轴）。 （默认值：sx。）
	--  origin_x: 原点偏移（x 轴）。 （默认值：0。）
	--  origin_y: 原点偏移（y 轴）。 （默认值：0。）
	--  shear_x: 剪切/倾斜因子（x 轴）。 （默认值：0。）
	--  shear_y: 剪切/倾斜因子（y 轴）。 （默认值：0。）
	--
	-- 返回值：
	--  index: 可与 Text:getWidth 或 Text:getHeight 一起使用的索引号。
	addf: function(self: Text, text: any, wrap_limit: number, align: string, transform_or_x?: any, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer
	-- 清除文本对象的内容。
	clear: function(self: Text)
	-- 替换文本使用的字体。
	--
	-- 参数：
	--  font: 与此 Text 对象一起使用的新字体。
	setFont: function(self: Text, font: Font)
	-- 获取与 Text 对象一起使用的 Font。
	--
	-- 返回值：
	--  font: 此文本对象使用的字体。
	getFont: function(self: Text): Font
	-- 获取文本的宽度（以像素为单位）。
	--
	-- 重载说明：
	-- 1. 获取之前添加到Text 对象的特定子字符串的宽度。
	--
	-- 参数：
	--  index: Text:add 或 Text:addf 返回的索引号。
	--
	-- 返回值：
	--  width: 文本的宽度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的宽度。取决于重载：子字符串的宽度（在缩放和其他转换之前）。
	getWidth: function(self: Text, index?: integer): number
	-- 获取文本的高度（以像素为单位）。
	--
	-- 重载说明：
	-- 1. 获取先前添加到 Text 对象的特定子字符串的高度。
	--
	-- 参数：
	--  index: Text:add 或 Text:addf 返回的索引号。
	--
	-- 返回值：
	--   height : 文本的高度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的高度。
	--  height: 子字符串的高度（在缩放和其他转换之前）。
	getHeight: function(self: Text, index?: integer): number
	-- 获取文本的宽度和高度（以像素为单位）。
	--
	-- 重载说明：
	-- 1. 获取之前添加到Text 对象的特定子字符串的宽度和高度。
	--
	-- 参数：
	--  index: Text:add 或 Text:addf 返回的索引号。
	--
	-- 返回值：
	--  width: 文本的宽度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的宽度。取决于重载：子字符串的宽度（在缩放和其他转换之前）。
	--  height: 文本的高度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的高度。取决于过载：子字符串的高度（在缩放和其他转换之前）。
	getDimensions: function(self: Text, index?: integer): number, number
end

-- 具有纹理坐标信息的四边形（具有四个边和四个角的多边形）。
local record Quad
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Quad): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Quad, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Quad): boolean
	-- 根据视口设置纹理坐标。
	--
	-- 参数：
	--  x: 沿 x 轴的左上角。
	--  y: y 轴的左上角。
	--  width: 视口的宽度。
	--  height: 视口的高度。
	--  texture_width: 可选的新参考宽度，纹理的宽度。如果设置，则必须大于 0。 （默认值：无。）
	--  texture_height: 可选的新参考高度，纹理的高度。如果设置，则必须大于 0。 （默认值：无。）
	setViewport: function(self: Quad, x: number, y: number, width: number, height: number, texture_width?: number, texture_height?: number)
	-- 获取此Quad 的当前视口。
	--
	-- 返回值：
	--  x: 沿 x 轴的左上角。
	--  y: y 轴的左上角。
	--  w: 视口的宽度。
	--  h: 视口的高度。
	getViewport: function(self: Quad): number, number, number, number
	-- 获取最初在 love.graphics.newQuad.
	--
	-- 返回值：
	--  sw: 四边形使用的纹理宽度。
	--  sh: 四边形使用的纹理高度。
	getTextureDimensions: function(self: Quad): number, number
	setLayer: function(self: Quad, layer: integer)
	getLayer: function(self: Quad): integer
end

-- 用于绘制任意纹理形状的 2D 多边形网格。
local record Mesh
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Mesh): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Mesh, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Mesh): boolean
	-- 用新顶点替换网格中的一系列顶点。网格体的顶点总数在创建后就无法更改。这通常比在循环中调用 Mesh:setVertex 更有效。
	--
	-- 重载说明：
	-- 1. 每个顶点表中的值与Mesh顶点格式中的顶点属性的顺序相同。不是使用自定义顶点格式创建的标准网格将使用两个位置号、两个纹理
	--     coordinate numbers, and four color components per vertex: x、y、u、v、r、g、b、a。如果没有为
	-- 一个特定的顶点属性组件，如果其数据类型为'float'，则将其设置为默认值0；如果其数据类型为'byte'，则将其设置为默认值255。 2. 通过直接从Data对象的内存中复制来设置Mesh的顶点组件。如果使用 LuaJIT
	-- 的 FFI 通过 Data:getPointer 和 ffi.cast 填充数据对象，则此变体比设置网格顶点数据的其他方法要高效得多。 3. 设置不是使用自定义顶点格式创建的网格的顶点组件。
	--
	-- 参数：
	--  vertices_or_data: 该表填充了每个顶点的顶点信息表，其形式为{vertex, ...}，其中每个顶点是一个形式为{attributecomponent, ...}的表。
	--  vertices_or_data.attributecomponent: 顶点中第一个顶点属性的第一个组成部分。
	--  vertices_or_data....: 顶点中所有顶点属性的附加组件。
	--  start_vertex: 要替换的第一个顶点的索引。 （默认值：1。）
	--  vertex_count: 要替换的顶点数量。 （默认值：全部。）
	setVertices: function(self: Mesh, vertices_or_data: any, start_vertex?: integer, vertex_count?: integer)
	-- 设置网格中顶点的属性。
	--
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	--
	-- 重载说明：
	-- 1. 参数的顺序与网格顶点格式中顶点属性的顺序相同。不是使用自定义顶点格式创建的标准网格将使用两个位置号、两个纹理坐标
	--     numbers, and four color components per vertex: x、y、u、v、r、g、b、a。如果没有为特定的
	-- 顶点属性组件，如果其数据类型为'float'，则设置为默认值0，如果其数据类型为'byte'，则设置为1。 2.
	-- 表索引的顺序与网格顶点格式中顶点属性的顺序相同。不是使用自定义顶点格式创建的标准网格将使用两个位置号、两个纹理坐标
	--     numbers, and four color components per vertex: x、y、u、v、r、g、b、a。如果没有为特定的
	-- 顶点属性组件，如果其数据类型为'float'，则将其设置为默认值0；如果其数据类型为'byte'，则将其设置为默认值1。 3. 设置不是使用自定义顶点格式创建的网格的顶点组件。
	--
	-- 参数：
	--  index: 要修改的顶点的索引（从一开始）。
	--  vertex_or_component: 指定顶点中第一个顶点属性的第一个组件。
	--  components: 指定顶点中所有顶点属性的附加组件。
	setVertex: function(self: Mesh, index: integer, vertex_or_component: any, components: number...)
	-- 获取网格中顶点的属性。
	--
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	--
	-- 重载说明：
	-- 1. 返回值的顺序与网格顶点格式中顶点属性的顺序相同。不是使用自定义顶点格式创建的标准网格将返回两个位置号、两个纹理坐标
	--     numbers, and four color components: x, y, u, v, r, g, b, a.
	-- 2. 获取不是使用自定义顶点格式创建的网格的顶点组件。
	--
	-- 参数：
	--  index: 要检索其信息的顶点的从一开始的索引。取决于过载：要检索其信息的顶点的索引。
	--
	-- 返回值：
	--  attributecomponent: 指定顶点中第一个顶点属性的第一个组件。
	--  ...: 指定顶点中所有顶点属性的附加组件。
	--  x: 顶点在 x 轴上的位置。
	--  y: 顶点在 y 轴上的位置。
	--  u: 纹理坐标的水平分量。
	--  v: 纹理坐标的垂直分量。
	--  r: 顶点颜色的红色分量。
	--  g: 顶点颜色的绿色分量。
	--  b: 顶点颜色的蓝色分量。
	--  a: 顶点颜色的 Alpha 分量。
	getVertex: function(self: Mesh, index: integer): any
	-- 设置网格中顶点内特定属性的属性。
	--
	-- 没有在 love.graphics.newMesh 中指定的自定义顶点格式的网格体将位置作为其第一个属性，将纹理坐标作为其第二个属性，将颜色作为其第三个属性。
	--
	-- 重载说明：
	-- 1. 存在于属性中但未指定为参数的属性组件对于浮点数据类型的属性默认为 0，对于字节数据类型默认为 255。
	--
	-- 参数：
	--  vertex_index: 要修改的顶点的索引（从一开始）。
	--  attribute_index: 要修改的顶点中属性的索引（从一开始）。
	--  components: 属性第一个组件的新值。
	setVertexAttribute: function(self: Mesh, vertex_index: integer, attribute_index: integer, components: number...)
	-- 获取网格中顶点内特定属性的属性。
	--
	-- 没有在 love.graphics.newMesh 中指定的自定义顶点格式的网格体将位置作为其第一个属性，将纹理坐标作为其第二个属性，将颜色作为其第三个属性。
	--
	-- 参数：
	--  vertex_index: 要检索其属性的顶点的索引（从一开始）。
	--  attribute_index: 要检索的顶点中的属性索引（从一开始）。
	--
	-- 返回值：
	--  value1: 属性第一个组成部分的值。
	--  value2: 属性第二个组成部分的值。
	--  ...: 任何附加的顶点属性组件。
	getVertexAttribute: function(self: Mesh, vertex_index: integer, attribute_index: integer): any
	-- 获取Mesh中的顶点总数。
	--
	-- 返回值：
	--  count: 网格中的顶点总数。
	getVertexCount: function(self: Mesh): integer
	-- 获取创建网格体所用的顶点格式。
	--
	-- 重载说明：
	--  1. If a Mesh wasn't created with a custom vertex format, it will have the following vertex format: 默认格式
	-- = { {'VertexPosition', 'float', 2}, -- 每个顶点的 x,y 位置。 {'VertexTexCoord', 'float', 2}, -- 每个顶点的 u,v 纹理坐标。
	-- {'VertexColor', 'byte', 4} -- 每个顶点的 r,g,b,a 颜色。 }
	--
	-- 返回值：
	--  format: 网格体的顶点格式，它是一个表，其中包含用于创建网格体的每个顶点属性的表，格式为 {attribute, ...}。
	getVertexFormat: function(self: Mesh): {{any}}
	-- 启用或禁用网格中的特定顶点属性。绘制网格时不使用禁用属性中的顶点数据。
	--
	-- 重载说明：
	-- 1. 如果网格不是使用自定义顶点格式创建的，它将具有 3 个顶点属性，分别名为 VertexPosition、VertexTexCoord 和
	-- VertexColor。否则，属性名称必须与创建网格体时以顶点格式指定的顶点属性之一匹配，或者必须与通过 Mesh:attachAttribute 连接到此网格体的另一个网格体的顶点属性匹配。
	--
	-- 参数：
	--  name: 要启用或禁用的顶点属性的名称。
	--  enabled: 绘制此Mesh时是否使用顶点属性。
	setAttributeEnabled: function(self: Mesh, name: string, enabled: boolean)
	-- 获取Mesh中特定顶点属性是否启用。绘制网格时不使用禁用属性中的顶点数据。
	--
	-- 重载说明：
	-- 1. 如果网格不是使用自定义顶点格式创建的，它将具有 3 个顶点属性，分别名为 VertexPosition、VertexTexCoord 和
	-- VertexColor。否则，属性名称必须与创建网格体时以顶点格式指定的顶点属性之一匹配，或者必须与通过 Mesh:attachAttribute 连接到此网格体的另一个网格体的顶点属性匹配。
	--
	-- 参数：
	--  name: 要检查的顶点属性的名称。
	--
	-- 返回值：
	--  enabled: 绘制此Mesh时是否使用顶点属性。
	isAttributeEnabled: function(self: Mesh, name: string): boolean
	-- 将来自不同网格的顶点属性附加到此网格上，以供绘制时使用。这可用于在多个不同网格之间共享顶点属性数据。
	--
	-- 重载说明：
	-- 1. 如果网格不是使用自定义顶点格式创建的，它将具有 3 个顶点属性，分别名为 VertexPosition、VertexTexCoord 和 VertexColor。可以通过将自定义命名属性声明为属性 vec4
	-- MyCustomAttributeName 在顶点着色器中访问它们；位于顶点着色器代码的顶层。该名称必须与网格体顶点格式和 Mesh:attachAttribute 的名称参数中指定的名称相匹配。
	--
	-- 参数：
	--  name: 要附加的顶点属性的名称。
	--  mesh: 要从中获取顶点属性的网格体。
	--  step: 绘制网格时该属性是按顶点还是按实例。 （默认：'pervertex'。）
	--  attribute_name: 在着色器代码中使用的属性的名称。默认为给定网格中的属性名称。可用于在渲染时为此属性使用不同的名称。 （默认值：名称。）
	attachAttribute: function(self: Mesh, name: string, mesh: Mesh, step?: string, attribute_name?: string)
	-- 从此网格中删除先前附加的顶点属性。
	--
	-- 参数：
	--  name: 要分离的附加顶点属性的名称。
	--
	-- 返回值：
	--  success: 属性是否已成功分离。
	detachAttribute: function(self: Mesh, name: string): boolean
	-- 设置网格的顶点贴图。顶点图描述了绘制Mesh时顶点的使用顺序。顶点、顶点贴图和网格绘制模式共同确定屏幕上显示的内容。
	--
	-- 顶点贴图允许您在绘制时重新排序或重用顶点，而无需更改实际的顶点参数或复制顶点。当与不同的网格绘制模式结合使用时，它特别有用。
	--
	-- 参数：
	--  indices: 包含绘图时使用的顶点索引列表的表。值必须在 Mesh:getVertexCount() 范围内。
	setVertexMap: function(self: Mesh, indices: any...)
	-- 获取网格的顶点贴图。顶点图描述了绘制Mesh时顶点的使用顺序。顶点、顶点贴图和网格绘制模式共同确定屏幕上显示的内容。
	--
	-- 如果之前没有通过 Mesh:setVertexMap 设置顶点贴图，那么该函数在 LÖVE 0.10.0+ 中将返回 nil，或者在 0.9.2 及更早版本中返回空表。
	--
	-- 返回值：
	--  map: 包含绘图时使用的顶点索引列表的表。
	getVertexMap: function(self: Mesh): {integer} | nil
	-- 设置绘制网格时使用的纹理（图像或画布）。
	--
	-- 重载说明：
	-- 1. 绘制网格时禁用任何纹理。默认情况下，无纹理的网格具有白色。
	--
	-- 参数：
	--  texture: 绘制时用于纹理网格的图像或画布。
	setTexture: function(self: Mesh, texture?: Image | Canvas)
	-- 获取绘制网格时使用的纹理（图像或画布）。
	--
	-- 返回值：
	--  texture: 绘制时用于纹理网格的图像或画布，如果未设置则为零。
	getTexture: function(self: Mesh): Image | Canvas | nil
	-- 设置绘制网格时使用的模式。
	--
	-- 参数：
	--  mode: 绘制网格时使用的模式。
	setDrawMode: function(self: Mesh, mode: string)
	-- 获取绘制网格时使用的模式。
	--
	-- 返回值：
	--  mode: 绘制网格时使用的模式。
	getDrawMode: function(self: Mesh): string
	-- 将网格的绘制顶点限制为总数的子集。
	--
	-- 重载说明：
	-- 1. 允许绘制网格中的所有顶点。
	--
	-- 参数：
	--  start: 绘制时要使用的第一个顶点的索引，或者如果为此网格设置了一个，则要使用的顶点映射中的第一个值的索引。
	--  count: 绘制时要使用的顶点数，或者如果为此网格设置了一个，则要使用的顶点映射中的值的数量。
	setDrawRange: function(self: Mesh, start?: integer, count?: integer)
	-- 获取绘制Mesh时使用的顶点范围。
	--
	-- 重载说明：
	-- 1. 如果之前没有用Mesh:setDrawRange设置Mesh的绘制范围，该函数将返回nil。
	--
	-- 返回值：
	--  min: 绘制时使用的第一个顶点的索引，或者如果为此网格设置了一个，则使用顶点映射中的第一个值的索引。
	--  max: 绘制时使用的最后一个顶点的索引，或者如果为此网格设置了则使用的顶点图中最后一个值的索引。
	getDrawRange: function(self: Mesh): any
	-- 立即将Mesh中所有修改的顶点数据发送到显卡。
	--
	-- 通常不需要调用此方法，因为 love.graphics.draw(mesh, ...) 会在需要时自动执行此操作，但显式使用 **Mesh:flush** 可以更好地控制工作何时发生。
	--
	-- 如果使用此方法，则通常不应在 love.graphics.draw(mesh, ...) 调用之间多次（最多）调用它。
	flush: function(self: Mesh)
end

-- 使用单个图像，通过一次调用 love.graphics.draw() 绘制任意数量的相同图像副本。例如，这可用于以高性能绘制单个背景图像的重复副本。
local record SpriteBatch
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: SpriteBatch): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: SpriteBatch, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: SpriteBatch): boolean
	-- 将精灵添加到批次中。精灵按照添加的顺序绘制。
	--
	-- 重载说明：
	-- 1. 将四边形添加到批次中。
	--
	-- 参数：
	--  quad_or_x: 要添加的四边形。
	--  x_or_y: 绘制对象的位置（x 轴）。
	--  y_or_angle: 绘制对象的位置（y 轴）。
	--  angle_or_scale_x: 方向（弧度）。 （默认值：0。）
	--  scale_x_or_scale_y: 比例因子（x 轴）。 （默认值：1。）
	--  scale_y_or_origin_x: 比例因子（y 轴）。 （默认值：sx。）
	--  origin_x_or_origin_y: 原点偏移（x 轴）。 （默认值：0。）
	--  origin_y_or_shear_x: 原点偏移（y 轴）。 （默认值：0。）
	--  shear_x_or_shear_y: 剪切因子（x 轴）。 （默认值：0。）
	--  shear_y: 剪切因子（y 轴）。 （默认值：0。）
	--
	-- 返回值：
	--  id: 添加的精灵的标识符。
	add: function(self: SpriteBatch, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number): integer
	-- 更改批次中的精灵。这需要 SpriteBatch:add 或 SpriteBatch:addLayer 返回的精灵索引。
	--
	-- 重载说明：
	-- 1. 批量更改带有Quad的精灵。这需要 SpriteBatch:add 或 SpriteBatch:addLayer 返回的索引。 SpriteBatches 不支持删除单个精灵。可以进行伪删除
	--     (instead of clearing and re-adding everything) by: SpriteBatch:set(id, 0, 0, 0, 0, 0) 这使得所有的
	-- sprite 的顶点相等（因为 x 和 y 尺度均为 0），这会阻止 GPU 在绘制 SpriteBatch 时完全处理 sprite。
	--
	-- 参数：
	--  index: 将要更改的精灵的索引。
	--  quad_or_x: 批次图像上使用的 Quad。
	--  x_or_y: 绘制对象的位置（x 轴）。
	--  y_or_angle: 绘制对象的位置（y 轴）。
	--  angle_or_scale_x: 方向（弧度）。 （默认值：0。）
	--  scale_x_or_scale_y: 比例因子（x 轴）。 （默认值：1。）
	--  scale_y_or_origin_x: 比例因子（y 轴）。 （默认值：sx。）
	--  origin_x_or_origin_y: 原点偏移（x 轴）。 （默认值：0。）
	--  origin_y_or_shear_x: 原点偏移（y 轴）。 （默认值：0。）
	--  shear_x_or_shear_y: 剪切因子（x 轴）。 （默认值：0。）
	--  shear_y: 剪切因子（y 轴）。 （默认值：0。）
	set: function(self: SpriteBatch, index: integer, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number)
	-- 将精灵添加到使用数组纹理创建的批次中。
	--
	-- 重载说明：
	-- 1. 添加一层SpriteBatch的数组纹理。 2.使用指定的Quad添加SpriteBatch的ArrayTexture的一层。指定的图层索引会覆盖通过 Quad:setLayer 在 Quad 上设置的任何图层索引。
	-- 3. 使用指定的 Transform 添加 SpriteBatch 的数组纹理层。 4.使用指定的Quad和Transform添加SpriteBatch的ArrayTexture层。为了使用数组纹理或其他非 2D
	-- 纹理类型作为自定义 void effect() 变体中的主要纹理，必须是
	--     used in the pixel shader, and MainTex must be declared as an ArrayImage or sampler2DArray like so: 制服
	-- ArrayImage MainTex;。
	--
	-- 参数：
	--  layer: 用于该精灵的图层索引。
	--  quad_or_x: 绘制精灵时使用的纹理层的分段。
	--  x_or_y: 绘制精灵的位置（x 轴）。 （默认值：0。）
	--  y_or_angle: 绘制精灵的位置（y 轴）。 （默认值：0。）
	--  angle_or_scale_x: 方向（弧度）。 （默认值：0。）
	--  scale_x_or_scale_y: 比例因子（x 轴）。 （默认值：1。）
	--  scale_y_or_origin_x: 比例因子（y 轴）。 （默认值：sx。）
	--  origin_x_or_origin_y: 原点偏移（x 轴）。 （默认值：0。）
	--  origin_y_or_shear_x: 原点偏移（y 轴）。 （默认值：0。）
	--  shear_x_or_shear_y: 剪切因子（x 轴）。 （默认值：0。）
	--  shear_y: 剪切因子（y 轴）。 （默认值：0。）
	--
	-- 返回值：
	--  spriteindex: 添加的精灵的索引，与 SpriteBatch:set 或 SpriteBatch:setLayer 一起使用。
	addLayer: function(self: SpriteBatch, layer: integer, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number): integer
	-- 在使用数组纹理创建的批处理中更改先前使用 add 或 addLayer 添加的精灵。
	--
	-- 重载说明：
	-- 1. 更改SpriteBatch 中的精灵。 2.使用指定的Quad添加SpriteBatch的ArrayTexture的一层。指定的图层索引会覆盖通过 Quad:setLayer 在 Quad 上设置的任何图层索引。 3.
	-- 使用指定的 Transform 添加 SpriteBatch 的数组纹理层。 4.使用指定的Quad和Transform添加SpriteBatch的ArrayTexture层。指定的图层索引会覆盖通过
	-- Quad:setLayer 在 Quad 上设置的任何图层索引。
	--
	-- 参数：
	--  index: 要替换的现有精灵的索引。
	--  layer: 用于该精灵的图层索引。
	--  quad_or_x: 绘制精灵时使用的纹理层的分段。
	--  x_or_y: 绘制精灵的位置（x 轴）。 （默认值：0。）
	--  y_or_angle: 绘制精灵的位置（y 轴）。 （默认值：0。）
	--  angle_or_scale_x: 方向（弧度）。 （默认值：0。）
	--  scale_x_or_scale_y: 比例因子（x 轴）。 （默认值：1。）
	--  scale_y_or_origin_x: 比例因子（y 轴）。 （默认值：sx。）
	--  origin_x_or_origin_y: 原点偏移（x 轴）。 （默认值：0。）
	--  origin_y_or_shear_x: 原点偏移（y 轴）。 （默认值：0。）
	--  shear_x_or_shear_y: 剪切因子（x 轴）。 （默认值：0。）
	--  shear_y: 剪切因子（y 轴）。 （默认值：0。）
	setLayer: function(self: SpriteBatch, index: integer, layer: integer, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y_or_shear_x?: number, shear_x_or_shear_y?: number, shear_y?: number)
	-- 从缓冲区中删除所有精灵。
	clear: function(self: SpriteBatch)
	-- 立即将批次中所有新的和修改的精灵数据发送到显卡。
	--
	-- 通常不需要调用此方法，因为 love.graphics.draw(spritebatch, ...) 会在需要时自动执行此操作，但显式使用 SpriteBatch:flush 可以更好地控制工作何时发生。
	--
	-- 如果使用此方法，则通常不应在 love.graphics.draw(spritebatch, ...) 调用之间多次（最多）调用它。
	flush: function(self: SpriteBatch)
	-- 设置绘制时用于批处理中的精灵的纹理（图像或画布）。
	--
	-- 参数：
	--  texture: 用于批处理中的精灵的新图像或画布。
	setTexture: function(self: SpriteBatch, texture: Image | Canvas)
	-- 获取SpriteBatch使用的纹理（Image或Canvas）。
	--
	-- 返回值：
	--  texture: SpriteBatch 使用的图像或画布。
	getTexture: function(self: SpriteBatch): Image | Canvas
	-- 设置将用于下一个添加和设置操作的颜色。调用不带参数的函数将禁用 SpriteBatch 的所有每个精灵颜色。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 在版本 0.9.2 及更早版本中，如果任何精灵有自己的颜色，则使用 love.graphics.setColor 设置的全局颜色将无法在 SpriteBatch 上工作。
	--
	-- 重载说明：
	-- 1. 禁用此 SpriteBatch 的所有每个精灵颜色。
	--
	-- 参数：
	--  red_or_color: 红色的量。
	--  green: 绿色量。
	--  blue: 蓝色的量。
	--  alpha: 阿尔法的数量。 （默认值：1。）
	setColor: function(self: SpriteBatch, red_or_color?: number | {number}, green?: number, blue?: number, alpha?: number)
	-- 获取将用于下一个添加和设置操作的颜色。
	--
	-- 如果没有使用 SpriteBatch:setColor 设置颜色或当前 SpriteBatch 颜色已被清除，则此方法将返回 nil。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 返回值：
	--  r: 红色分量 (0-1)。
	--  g: 绿色分量 (0-1)。
	--  b: 蓝色分量 (0-1)。
	--  a: alpha 分量 (0-1)。
	getColor: function(self: SpriteBatch): number, number, number, number
	-- 获取SpriteBatch中当前精灵的数量。
	--
	-- 返回值：
	--  count: 当前批次中的精灵数量。
	getCount: function(self: SpriteBatch): integer
	-- 获取 SpriteBatch 可以容纳的最大精灵数。
	--
	-- 返回值：
	--  size: 批次可以容纳的精灵的最大数量。
	getBufferSize: function(self: SpriteBatch): integer
	-- 将网格中的每顶点属性附加到此 SpriteBatch 上，以供绘制时使用。它可以与 Shader 结合使用，以使用每个顶点或附加的每个精灵信息来增强 SpriteBatch，而不仅仅是每个精灵颜色。
	--
	-- SpriteBatch 中的每个精灵都有 4 个顶点，按以下顺序排列：左上、左下、右上、右下。 SpriteBatch:add 返回的索引（并由 SpriteBatch:set 使用）可用于通过公式 1 + 4 * ( id
	-- - 1 ) 确定特定精灵的第一个顶点。
	--
	-- 重载说明：
	-- 1. 如果使用自定义顶点格式创建，它将有 3 个顶点属性，分别为 VertexPosition、VertexTexCoord 和 VertexColor。如果具有这些名称的顶点属性附加到 SpriteBatch，它将分别覆盖
	-- SpriteBatch 的精灵位置、纹理坐标和精灵颜色。 可以通过将自定义命名属性声明为属性 vec4 MyCustomAttributeName
	-- 在顶点着色器中访问它们；位于顶点着色器代码的顶层。该名称必须与网格体顶点格式和 SpriteBatch:attachAttribute 的名称参数中指定的名称相匹配。网格体必须至少有 4 *
	-- SpriteBatch:getBufferSize 顶点才能附加到 SpriteBatch。
	--
	-- 参数：
	--  name: 要附加的顶点属性的名称。
	--  mesh: 要从中获取顶点属性的网格体。
	attachAttribute: function(self: SpriteBatch, name: string, mesh: Mesh)
	-- 将 SpriteBatch 中绘制的精灵限制为总数的子集。
	--
	-- 重载说明：
	-- 1. 允许绘制SpriteBatch中的所有精灵。
	--
	-- 参数：
	--  start: 要绘制的第一个精灵的索引。索引 1 对应于添加了 SpriteBatch:add 的第一个精灵。
	--  count: 要绘制的精灵数量。
	setDrawRange: function(self: SpriteBatch, start?: integer, count?: integer)
	getDrawRange: function(self: SpriteBatch): number, number
end

-- 粒子系统可用于创建粒子效果，例如火焰或烟雾。
local record ParticleSystem
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: ParticleSystem): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: ParticleSystem, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: ParticleSystem): boolean
	-- 创建处于停止状态的粒子系统的相同副本。
	--
	-- 重载说明：
	-- 1. 克隆的粒子系统继承原始粒子系统的所有可设置状态，但它们被初始化为停止状态。
	--
	-- 返回值：
	--  particlesystem: 此粒子系统的新的相同副本。
	clone: function(self: ParticleSystem): ParticleSystem
	-- 设置用于粒子的纹理（图像或画布）。
	--
	-- 参数：
	--  texture: 用于粒子的图像或画布。
	setTexture: function(self: ParticleSystem, texture: Image | Canvas)
	-- 获取用于粒子的纹理（图像或画布）。
	--
	-- 返回值：
	--  texture: 用于粒子的图像或画布。
	getTexture: function(self: ParticleSystem): Image | Canvas
	-- 设置缓冲区的大小（系统中允许的最大粒子量）。
	--
	-- 参数：
	--  size: 缓冲区大小。
	setBufferSize: function(self: ParticleSystem, size: integer)
	-- 获取粒子系统一次可以拥有的最大粒子数。
	--
	-- 返回值：
	--  size: 最大粒子数。
	getBufferSize: function(self: ParticleSystem): integer
	-- 设置粒子系统添加新粒子时使用的模式。
	--
	-- 参数：
	--  mode: 粒子系统添加新粒子时使用的模式。
	setInsertMode: function(self: ParticleSystem, mode: string)
	-- 获取粒子系统添加新粒子时使用的模式。
	--
	-- 返回值：
	--  mode: 粒子系统添加新粒子时使用的模式。
	getInsertMode: function(self: ParticleSystem): string
	-- 设置每秒发射的粒子数量。
	--
	-- 参数：
	--  rate: 每秒的粒子数。
	setEmissionRate: function(self: ParticleSystem, rate: number)
	-- 获取每秒发射的粒子数。
	--
	-- 返回值：
	--  rate: 每秒的粒子数。
	getEmissionRate: function(self: ParticleSystem): number
	-- 设置粒子系统应发射粒子的时间长度（如果为 -1，则它将永远发射粒子）。
	--
	-- 参数：
	--  lifetime: 发射器的生命周期（以秒为单位）。
	setEmitterLifetime: function(self: ParticleSystem, lifetime: number)
	-- 获取粒子系统将发射粒子的时间（如果为-1则永远发射粒子）。
	--
	-- 返回值：
	--  life: 发射器的生命周期（以秒为单位）。
	getEmitterLifetime: function(self: ParticleSystem): number
	-- 设置粒子的寿命。
	--
	-- 参数：
	--  minimum: 粒子的最短寿命（以秒为单位）。
	--  maximum: 粒子的最大寿命（以秒为单位）。 （默认值：分钟。）
	setParticleLifetime: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- 获取粒子的寿命。
	--
	-- 返回值：
	--  min: 粒子的最短寿命（以秒为单位）。
	--  max: 粒子的最大寿命（以秒为单位）。
	getParticleLifetime: function(self: ParticleSystem): number, number
	-- 设置发射器的位置。
	--
	-- 参数：
	--  x: 沿 x 轴的位置。
	--  y: 沿 y 轴的位置。
	setPosition: function(self: ParticleSystem, x: number, y: number)
	-- 获取发射器的位置。
	--
	-- 返回值：
	--  x: 沿 x 轴的位置。
	--  y: 沿 y 轴的位置。
	getPosition: function(self: ParticleSystem): number, number
	-- 移动发射器的位置。与每帧使用 ParticleSystem:setPosition 相比，这会导致更平滑的粒子生成行为。
	--
	-- 参数：
	--  x: 沿 x 轴的位置。
	--  y: 沿 y 轴的位置。
	moveTo: function(self: ParticleSystem, x: number, y: number)
	-- 设置粒子的基于区域的生成参数。新创建的粒子将根据此函数的参数在发射器周围的区域中生成。
	--
	-- 参数：
	--  distribution: 新粒子的分布类型。
	--  x: 均匀分布时沿 x 轴距发射器的最大生成距离，或正态分布时沿 x 轴的标准偏差。
	--  y: 均匀分布时沿 y 轴距发射器的最大生成距离，或正态分布时沿 y 轴的标准偏差。
	--  angle: 发射区域的角度（以弧度表示）。 （默认值：0。）
	--  relative: 如果新生成的粒子将相对于发射区域的中心定向，则为 true，否则为 false。 （默认值：假。）
	setEmissionArea: function(self: ParticleSystem, distribution?: string, x?: number, y?: number, angle?: number, relative?: boolean)
	-- 获取粒子基于区域的生成参数。
	--
	-- 返回值：
	--  distribution: 新粒子的分布类型。
	--  dx: 均匀分布时沿 x 轴距发射器的最大生成距离，或正态分布时沿 x 轴的标准偏差。
	--  dy: 均匀分布时沿 y 轴距发射器的最大生成距离，或正态分布时沿 y 轴的标准偏差。
	--  angle: 发射区域的角度（以弧度表示）。
	--  directionRelativeToCenter: 如果新生成的粒子将相对于发射区域的中心定向，则为 true，否则为 false。
	getEmissionArea: function(self: ParticleSystem): string, number, number, number, boolean
	setAreaSpread: function(self: ParticleSystem, distribution?: string, x?: number, y?: number)
	getAreaSpread: function(self: ParticleSystem): string, number, number
	-- 设置粒子发射的方向。
	--
	-- 参数：
	--  direction: 粒子的方向（以弧度为单位）。
	setDirection: function(self: ParticleSystem, direction: number)
	-- 获取粒子发射器的方向（以弧度为单位）。
	--
	-- 返回值：
	--  direction: 发射器的方向（弧度）。
	getDirection: function(self: ParticleSystem): number
	-- 设置系统的传播量。
	--
	-- 参数：
	--  spread: 传播量（弧度）。
	setSpread: function(self: ParticleSystem, spread: number)
	-- 获取粒子发射器的方向扩散量（以弧度为单位）。
	--
	-- 返回值：
	--  spread: 发射器的扩散（弧度）。
	getSpread: function(self: ParticleSystem): number
	-- 设置粒子的速度。
	--
	-- 参数：
	--  minimum: 粒子的最小线速度。
	--  maximum: 粒子的最大线速度。 （默认值：分钟。）
	setSpeed: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- 获取粒子的速度。
	--
	-- 返回值：
	--  min: 粒子的最小线速度。
	--  max: 粒子的最大线速度。
	getSpeed: function(self: ParticleSystem): number, number
	-- 设置粒子的线性加速度（沿x轴和y轴的加速度）。
	--
	-- 创建的每个粒子都会沿着 x 轴和 y 轴在 xmin,ymin 和 xmax,ymax 之间加速。
	--
	-- 参数：
	--  xmin: 沿 x 轴的最小加速度。
	--  ymin: 沿 y 轴的最小加速度。
	--  xmax: 沿 x 轴的最大加速度。 （默认值：xmin。）
	--  ymax: 沿 y 轴的最大加速度。 （默认值：ymin。）
	setLinearAcceleration: function(self: ParticleSystem, xmin: number, ymin: number, xmax?: number, ymax?: number)
	-- 获取粒子的线性加速度（沿x轴和y轴的加速度）。
	--
	-- 创建的每个粒子都会沿着 x 轴和 y 轴在 xmin,ymin 和 xmax,ymax 之间加速。
	--
	-- 返回值：
	--  xmin: 沿 x 轴的最小加速度。
	--  ymin: 沿 y 轴的最小加速度。
	--  xmax: 沿 x 轴的最大加速度。
	--  ymax: 沿 y 轴的最大加速度。
	getLinearAcceleration: function(self: ParticleSystem): number, number, number, number
	-- 设置径向加速度（远离发射器）。
	--
	-- 参数：
	--  minimum: 最小加速度。
	--  maximum: 最大加速度。 （默认值：分钟。）
	setRadialAcceleration: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- 获取径向加速度（远离发射器）。
	--
	-- 返回值：
	--  min: 最小加速度。
	--  max: 最大加速度。
	getRadialAcceleration: function(self: ParticleSystem): number, number
	-- 设置切向加速度（垂直于粒子方向的加速度）。
	--
	-- 参数：
	--  minimum: 最小加速度。
	--  maximum: 最大加速度。 （默认值：分钟。）
	setTangentialAcceleration: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- 获取切向加速度（垂直于粒子方向的加速度）。
	--
	-- 返回值：
	--  min: 最小加速度。
	--  max: 最大加速度。
	getTangentialAcceleration: function(self: ParticleSystem): number, number
	-- 设置粒子的线性阻尼（恒定减速度）量。
	--
	-- 参数：
	--  minimum: 应用于粒子的最小线性阻尼量。
	--  maximum: 应用于粒子的最大线性阻尼量。 （默认值：分钟。）
	setLinearDamping: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- 获取粒子的线性阻尼（恒定减速度）量。
	--
	-- 返回值：
	--  min: 应用于粒子的最小线性阻尼量。
	--  max: 应用于粒子的最大线性阻尼量。
	getLinearDamping: function(self: ParticleSystem): number, number
	-- 设置一系列用于缩放粒子精灵的尺寸。 1.0是正常尺寸。粒子系统将在粒子的生命周期内均匀地在每个尺寸之间进行插值。
	--
	-- 必须至少指定一种尺寸。最多可以使用八个。
	--
	-- 参数：
	--  sizes: 第一个尺寸。
	setSizes: function(self: ParticleSystem, sizes: number...)
	-- 获取精灵缩放的一系列尺寸。 1.0是正常尺寸。粒子系统将在粒子的生命周期内均匀地在每个尺寸之间进行插值。
	--
	-- 返回值：
	--  size1: 第一个尺寸。
	--  size2: 第二个尺寸。
	--  size8: 第八号。
	getSizes: function(self: ParticleSystem): number...
	-- 设置大小变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	--
	-- 参数：
	--  variation: 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	setSizeVariation: function(self: ParticleSystem, variation: number)
	-- 获取大小变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	--
	-- 返回值：
	--  variation: 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	getSizeVariation: function(self: ParticleSystem): number
	-- 设置粒子创建时图像的旋转（以弧度为单位）。
	--
	-- 参数：
	--  minimum: 最小初始角度（弧度）。
	--  maximum: 最大初始角度（弧度）。 （默认值：分钟。）
	setRotation: function(self: ParticleSystem, minimum: number, maximum?: number)
	-- 获取粒子创建时图像的旋转（以弧度为单位）。
	--
	-- 返回值：
	--  min: 最小初始角度（弧度）。
	--  max: 最大初始角度（弧度）。
	getRotation: function(self: ParticleSystem): number, number
	-- 设置精灵的旋转。
	--
	-- 参数：
	--  start: 最小旋转（弧度每秒）。
	--  finish: 最大旋转（弧度每秒）。 （默认值：分钟。）
	setSpin: function(self: ParticleSystem, start: number, finish?: number)
	-- 获取精灵的旋转。
	--
	-- 返回值：
	--  min: 最小旋转（弧度每秒）。
	--  max: 最大旋转（弧度每秒）。
	--  variation: 变化程度（0 表示没有变化，1 表示开始和结束之间完全变化）。
	getSpin: function(self: ParticleSystem): number, number
	-- 设置旋转变化量（0 表示无变化，1 表示开始和结束之间完全变化）。
	--
	-- 参数：
	--  variation: 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	setSpinVariation: function(self: ParticleSystem, variation: number)
	-- 获取旋转变化量（0 表示无变化，1 表示开始和结束之间的完全变化）。
	--
	-- 返回值：
	--  variation: 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	getSpinVariation: function(self: ParticleSystem): number
	-- 设置粒子精灵旋转的偏移位置。
	--
	-- 如果不使用此功能，粒子将绕其中心旋转。
	--
	-- 参数：
	--  x: 旋转偏移的x坐标。
	--  y: 旋转偏移的 y 坐标。
	setOffset: function(self: ParticleSystem, x: number, y: number)
	-- 获取粒子图像的绘制偏移量。
	--
	-- 返回值：
	--  ox: 粒子图像绘制偏移的x坐标。
	--  oy: 粒子图像绘制偏移的 y 坐标。
	getOffset: function(self: ParticleSystem): number, number
	-- 设置一系列应用于粒子精灵的颜色。粒子系统将在粒子的生命周期内均匀地在每种颜色之间进行插值。
	--
	-- 参数可以以四个为一组传递，代表所需 RGBA 值的分量，或者作为 RGBA 分量值表，如果仅给出三个值，则默认 alpha 值为 1。必须至少指定一种颜色。最多可以使用八个。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 参数：
	--  colors: 第一种颜色，一个数字索引表，其中红色、绿色、蓝色和 alpha 值作为数字 (0-1)。 alpha 是可选的，如果省略则默认为 1。
	setColors: function(self: ParticleSystem, colors: any...)
	-- 获取应用于粒子精灵的一系列颜色。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 返回值：
	--  r1: 第一种颜色，红色分量 (0-1)。
	--  g1: 第一种颜色，绿色分量 (0-1)。
	--  b1: 第一种颜色，蓝色分量 (0-1)。
	--  a1: 第一种颜色，alpha 分量 (0-1)。
	--  r2: 第二颜色，红色分量 (0-1)。
	--  g2: 第二颜色，绿色分量 (0-1)。
	--  b2: 第二颜色，蓝色分量 (0-1)。
	--  a2: 第二个颜色，alpha 分量 (0-1)。
	--  r8: 第八种颜色，红色分量 (0-1)。
	--  g8: 第八种颜色，绿色分量 (0-1)。
	--  b8: 第八种颜色，蓝色分量 (0-1)。
	--  a8: 第八种颜色，alpha 分量 (0-1)。
	getColors: function(self: ParticleSystem): {number}...
	-- 设置一系列用于粒子精灵的四边形。粒子将根据粒子当前的生命周期从列表中选择一个四边形，从而允许将动画精灵表与粒子系统一起使用。
	--
	-- 参数：
	--  quads: 包含要使用的四边形的表。
	setQuads: function(self: ParticleSystem, quads: any...)
	-- 获取用于粒子精灵的四边形系列。
	--
	-- 返回值：
	--  quads: 包含所使用的四边形的表。
	getQuads: function(self: ParticleSystem): {Quad}
	-- 设置粒子角度和旋转是否与其速度相关。如果启用，粒子将与其速度角度对齐并相对于该角度旋转。
	--
	-- 参数：
	--  enabled: true 则启用相对粒子旋转， false 则禁用它。
	setRelativeRotation: function(self: ParticleSystem, enabled: boolean)
	-- 获取粒子角度和旋转是否与其速度相关。如果启用，粒子将与其速度角度对齐并相对于该角度旋转。
	--
	-- 返回值：
	--  enable: 如果启用相对粒子旋转则为 True，如果禁用则为 false。
	hasRelativeRotation: function(self: ParticleSystem): boolean
	-- 获取当前系统中的粒子数。
	--
	-- 返回值：
	--  count: 当前活动粒子的数量。
	getCount: function(self: ParticleSystem): integer
	-- 启动粒子发射器。
	start: function(self: ParticleSystem)
	-- 停止粒子发射器，重置生命周期计数器。
	stop: function(self: ParticleSystem)
	-- 暂停粒子发射器。
	pause: function(self: ParticleSystem)
	-- 重置粒子发射器，删除任何现有粒子并重置生命周期计数器。
	reset: function(self: ParticleSystem)
	-- 从粒子发射器中发射出一阵粒子。
	--
	-- 参数：
	--  count: 要发射的粒子数量。如果达到粒子系统的最大缓冲区大小，发射的粒子数量将被截断。
	emit: function(self: ParticleSystem, count: integer)
	-- 检查粒子系统是否正在主动发射粒子。
	--
	-- 返回值：
	--  active: 如果系统处于活动状态，则为 true，否则为 false。
	isActive: function(self: ParticleSystem): boolean
	-- 检查粒子系统是否暂停。
	--
	-- 返回值：
	--  paused: 如果系统暂停则为 true，否则为 false。
	isPaused: function(self: ParticleSystem): boolean
	-- 检查粒子系统是否停止。
	--
	-- 返回值：
	--  stopped: 如果系统停止则为 true，否则为 false。
	isStopped: function(self: ParticleSystem): boolean
	isEmpty: function(self: ParticleSystem): boolean
	isFull: function(self: ParticleSystem): boolean
	-- 更新粒子系统；移动、产生和杀死粒子。
	--
	-- 参数：
	--  delta_time: 自上一帧以来的时间（秒）。
	update: function(self: ParticleSystem, delta_time: number)
end

-- 着色器用于高级硬件加速像素或顶点操作。这些效果是用基于 GLSL（OpenGL 着色语言）的语言编写的，并进行了一些简化以便于编码。
local record Shader
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Shader): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Shader, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Shader): boolean
	-- 返回编译着色器代码时的任何警告和错误消息。如果图形硬件有任何不喜欢的地方，这可以用于调试着色器。
	--
	-- 返回值：
	--  warnings: 警告和错误消息（如果有）。
	getWarnings: function(self: Shader): string
	-- 获取Shader中是否存在指定的extern变量。
	--
	-- 这是用于兼容LÖVE 0.10之前版本的旧接口，请改用hasUniform。
	getExternVariable: function(self: Shader, name: string): boolean
	-- 获取Shader中是否存在uniform / extern变量。
	--
	-- 如果图形驱动程序的着色器编译器确定统一/外部变量不会影响着色器的最终输出，它可能会优化该变量。在这种情况下该函数将返回 false。
	--
	-- 参数：
	--  name: 统一变量的名称。
	--
	-- 返回值：
	--  hasuniform: 着色器中是否存在uniform并影响其最终输出。
	hasUniform: function(self: Shader, name: string): boolean
	-- 将一个或多个值发送到特殊的 (''uniform'') variable inside the shader. Uniform variables have to be marked using the
	-- ''uniform'' or ''extern'' 关键字，例如
	--
	-- 统一浮动时间； // 'float' 是 GLSL 着色器中使用的典型数字类型。
	--
	-- 统一浮点varsvec2 light_pos；
	--
	-- 统一vec4颜色[4;
	--
	-- 相应的发送调用将是
	--
	-- 着色器：发送('time', t)
	--
	-- 着色器：发送('vars',a,b)
	--
	-- 着色器：发送('light_pos', {light_x, light_y})
	--
	-- 着色器：发送（'colors'，{r1，g1，b1，a1}，{r2，g2，b2，a2}，{r3，g3，b3，a3}，{r4，g4，b4，a4}）
	--
	-- 统一/外部变量在着色器代码中是只读的，并保持不变，直到被 Shader:send 调用修改。统一变量可以在着色器的顶点和像素组件中访问，只要在每个组件中声明该变量即可。
	--
	-- 重载说明：
	-- 1. 由于Lua中的所有数字都是浮点型，因此在0.10.2之前的版本中，必须使用函数Shader:sendInt将值发送到着色器代码中的uniform int变量。 2.
	-- 将源自数据对象内容的统一值发送到着色器。这直接复制数据的字节。 3. 将源自数据对象内容的统一矩阵发送到着色器。这直接复制数据的字节。
	--
	-- 参数：
	--  name: 发送到着色器的数字名称。取决于重载：发送到着色器的向量的名称。取决于重载：发送到着色器的矩阵的名称。取决于重载：发送到着色器的纹理的名称。取决于重载：发送到着色器的布尔值的名称。取决于过载：发送到着色器的制服名称。取决于重载：发送到着色器的统一矩阵的名称。
	--  values: 纹理（图像或画布）发送到统一变量。
	send: function(self: Shader, name: string, values: any...)
	-- 将一种或多种颜色发送到着色器内的特殊 (''extern'' / ''uniform'') vec3 或 vec4 变量。颜色分量必须在 1 的范围内。如果启用全局伽玛校正，则对颜色进行伽玛校正。
	--
	-- 外部变量必须使用“'extern'”关键字进行标记，例如
	--
	-- 外部 vec4 颜色；
	--
	-- 相应的 sendColor 调用将是
	--
	-- 着色器:sendColor('Color', {r, g, b, a})
	--
	-- 外部变量可以在着色器的顶点和像素阶段访问，只要在每个阶段声明该变量即可。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 参数：
	--  name: 要在着色器中发送到的颜色外部变量的名称。
	--  values: 一个表，其中包含红色、绿色、蓝色和 1 范围内的可选 alpha 颜色分量，以向量形式发送到外部。
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

-- 提供用于修改和检索有关程序窗口的信息的接口。
local record Window
	-- 获取桌面的宽度和高度。
	--
	-- 参数：
	--  display: 显示的索引（如果有多个监视器可用）。 （默认值：1。）
	--
	-- 返回值：
	--  width: 桌面的宽度。
	--  height: 桌面的高度。
	getDesktopDimensions: function(display?: integer): integer, integer
	-- 获取已连接显示器的数量。
	--
	-- 返回值：
	--  count: 当前连接的显示器数量。
	getDisplayCount: function(): integer
	-- 获取显示器的名称。
	--
	-- 参数：
	--  display: 要获取其名称的显示器的索引。 （默认值：1。）
	--
	-- 返回值：
	--  name: 指定显示器的名称。
	getDisplayName: function(display: integer): string
	-- 获取当前设备显示方向。
	--
	-- 参数：
	--  display: 显示索引以获取其显示方向，或 nil 以获得默认显示索引。 （默认值：无。）
	--
	-- 返回值：
	--  orientation: 当前设备显示方向。
	getDisplayOrientation: function(display?: integer): string
	-- 获取支持的全屏模式列表。
	--
	-- 参数：
	--  display: 显示的索引（如果有多个监视器可用）。 （默认值：1。）
	--
	-- 返回值：
	--  modes: 宽度/高度对的表。 （请注意，这可能不按顺序排列。）
	getFullscreenModes: function(display?: integer): {WindowSize}
	-- 进入或退出全屏。如果连接了多个显示器，则根据窗口当前所在的显示来选择进入全屏时要使用的显示。
	--
	-- 重载说明：
	-- 1. 如果进入全屏模式并且窗口大小与显示器的显示模式之一不匹配（在普通全屏模式下）或窗口大小与桌面大小不匹配（在 'desktop' 全屏模式下），窗口将适当调整大小。当使用此功能退出全屏模式时，窗口将再次恢复到其原始大小。
	--
	-- 参数：
	--  fullscreen: 是否进入或退出全屏模式。
	--  fullscreen_type: 要使用的全屏模式类型。
	--
	-- 返回值：
	--  success: 如果尝试进入全屏成功则为 true，否则为 false。
	setFullscreen: function(fullscreen: boolean, fullscreen_type?: string): boolean
	-- 获取窗口是否全屏。
	--
	-- 返回值：
	--  fullscreen: 如果窗口是全屏则为 true，否则为 false。
	--  fstype: 使用的全屏模式类型。
	getFullscreen: function(): boolean, string
	-- 检查窗口是否打开。
	--
	-- 返回值：
	--  open: 如果窗口打开则为 true，否则为 false。
	isOpen: function(): boolean
	-- 获取窗口图标。
	--
	-- 返回值：
	--  imagedata: 窗口图标图像数据，如果没有使用 love.window.setIcon. 设置图标则为零
	getIcon: function(): any
	-- 使用 ImageData 设置窗口图标。
	--
	-- 嵌入式 LoveNode 会接受该请求，但不会修改 Dora 宿主应用的图标。
	-- 参数：
	--  imagedata: 窗口图标的图像数据。
	-- 返回值：
	--  success: 图标请求被接受时返回 true。
	setIcon: function(imagedata: any): boolean
	-- 获取窗口的显示模式和属性。
	--
	-- 返回值：
	--  width: 窗口宽度。
	--  height: 窗口高度。
	--  flags: 具有窗口属性的表：
	getMode: function(): integer, integer, WindowMode
	-- 设置窗口的显示模式和属性。
	--
	-- 如果宽度或高度为0，setMode 将使用桌面的宽度和高度。
	--
	-- 更改显示模式可能会产生副作用：例如，画布将被清除，并且值会预先发送到带有画布的着色器，或者如果需要的话，之后重新绘制到它们。
	--
	-- 重载说明：
	-- 1. * 如果启用全屏并且不支持宽度或高度（请参阅 resize 事件将被触发。 * 如果全屏类型为 'desktop' ，那么窗口将自动调整大小到桌面分辨率。 * 如果宽度和高度大于或等于桌面尺寸（包括都设置为
	-- 0）并且全屏设置为 false，则会显示 'visually' 全屏，但不是真正的全屏和 conf.lua （即 t.window = false）并使用此函数手动创建窗口，那么您不得在此函数之前调用任何其他
	-- love.graphics.* 函数，否则将导致未定义的行为和/或崩溃，因为没有窗口，OpenGL 无法正常运行 * 目前不支持透明背景。
	--
	-- 参数：
	--  width: 显示宽度。
	--  height: 显示高度。
	--  settings: 带有选项的标志表：
	--  settings.fullscreen: 全屏（true）或窗口化（false）。 （默认值：假。）
	--  settings.fullscreentype: 要使用的全屏类型。在 0.9.0 到 0.9.2 中默认为 'normal'，在 0.10.0 及更早版本中默认为 'desktop'。 （默认：'desktop'。）
	--  settings.vsync: 如果 LÖVE 应该等待垂直同步则为 true，否则为 false。 （默认值：true。）
	--  settings.msaa: 抗锯齿样本数。 （默认值：0。）
	--  settings.stencil: 是否应分配模板缓冲区。如果为 true，模板缓冲区将有 8 位。 （默认值：true。）
	--  settings.depth: 深度缓冲区中的位数。 （默认值：0。）
	--  settings.resizable: 如果窗口应在窗口模式下调整大小，则为 true，否则为 false。 （默认值：假。）
	--  settings.borderless: 如果窗口在窗口模式下应无边框，则为 true，否则为 false。 （默认值：假。）
	--  settings.centered: 如果窗口应在窗口模式下居中，则为 true，否则为 false。 （默认值：true。）
	--  settings.display: 如果有多个监视器可用，则显示窗口的显示器索引。 （默认值：1。）
	--  settings.minwidth: 窗口的最小宽度（如果可以调整大小）。不能小于 1。（默认值：1。）
	--  settings.minheight: 窗口的最小高度（如果可以调整大小）。不能小于 1。（默认值：1。）
	--  settings.highdpi: 如果应在 macOS 和 iOS 中的 Retina 显示屏上使用高 dpi 模式，则为 true。在非 Retina 显示器上不执行任何操作。 （默认值：假。）
	--  settings.x: 指定显示中窗口位置的 x 坐标。 （默认值：无。）
	--  settings.y: 指定显示中窗口位置的 y 坐标。 （默认值：无。）
	--  settings.usedpiscale: 如果为 false，则禁用自动 DPI 缩放。 （默认值：true。）
	--  settings.srgb: 在0.10.0中删除（改为在conf.lua中设置t.gamma Correct）。如果在绘制到屏幕时应应用 sRGB gamma 校正，则为 True。 （默认值：假。）
	--
	-- 返回值：
	--  success: 如果成功则为 true，否则为 false。
	setMode: function(width: integer, height: integer, settings?: WindowMode): boolean
	-- 设置窗口的显示模式和属性，不修改未指定的属性。
	--
	-- 如果宽度或高度为0，updateMode 将使用桌面的宽度和高度。
	--
	-- 更改显示模式可能会产生副作用：例如，画布将被清除。确保事先保存画布的内容，或者如果需要的话，之后重新绘制。
	--
	-- 重载说明：
	-- 1.如果启用全屏且不支持宽度或高度（请参阅resize事件将被触发。如果全屏类型为'desktop'，则窗口将自动调整大小到桌面分辨率。目前不支持透明背景。
	--
	-- 参数：
	--  settings_or_width: 窗口宽度。
	--  height: 窗口高度。
	--  settings: 具有以下可选字段的设置表。任何未填写的字段将使用 love.window.getMode.
	--  settings.fullscreen: 全屏（true）或窗口化（false）。
	--  settings.fullscreentype: 要使用的全屏类型。
	--  settings.vsync: 如果 LÖVE 应该等待垂直同步则为 true，否则为 false。
	--  settings.msaa: 抗锯齿样本数。
	--  settings.resizable: 如果窗口应在窗口模式下调整大小，则为 true，否则为 false。
	--  settings.borderless: 如果窗口在窗口模式下应无边框，则为 true，否则为 false。
	--  settings.centered: 如果窗口应在窗口模式下居中，则为 true，否则为 false。
	--  settings.display: 如果有多个监视器可用，则显示窗口的显示器索引。
	--  settings.minwidth: 窗口的最小宽度（如果可以调整大小）。不能小于 1。
	--  settings.minheight: 窗口的最小高度（如果可调整大小）。不能小于 1。
	--  settings.highdpi: 如果应在 macOS 和 iOS 中的 Retina 显示屏上使用高 dpi 模式，则为 true。在非 Retina 显示器上不执行任何操作。
	--  settings.x: 指定显示中窗口位置的 x 坐标。
	--  settings.y: 指定显示中窗口位置的 y 坐标。
	--
	-- 返回值：
	--  success: 如果成功则为 true，否则为 false。
	updateMode: function(settings_or_width: WindowMode | integer, height?: integer, settings?: WindowMode): boolean
	-- 获取窗口在屏幕上的位置。
	--
	-- 窗口位置位于其当前所在显示器的坐标空间中。
	--
	-- 返回值：
	--  x: 窗口位置的 x 坐标。
	--  y: 窗口位置的 y 坐标。
	--  displayindex: 窗口所在显示器的索引。
	getPosition: function(): integer, integer, integer
	-- 获取窗口内已知未被系统标题栏、iPhone X 缺口等遮挡的区域。有助于确保用户可以看到 UI 元素。
	--
	-- 重载说明：
	-- 1. 返回的值采用 DPI 缩放单位（与大多数其他与窗口相关的 API 相同的坐标系），而不是像素。
	--
	-- 返回值：
	--  x: 安全区域的起始位置（x 轴）。
	--  y: 安全区域的起始位置（y 轴）。
	--  w: 安全区域的宽度。
	--  h: 安全区域的高度。
	getSafeArea: function(): number, number, number, number
	-- 设置窗口标题。
	--
	-- 参数：
	--  title: 新窗口标题。
	setTitle: function(title: string)
	-- 获取窗口标题。
	--
	-- 返回值：
	--  title: 当前窗口标题。
	getTitle: function(): string
	-- 设置垂直同步模式。
	--
	-- 重载说明：
	-- 1. * 并非所有图形驱动程序都支持自适应垂直同步（-1 值）。在这种情况下，它将自动设置为 1。 * 如果您不知道关闭垂直同步可能产生的影响，建议保持垂直同步处于激活状态。 * 与 love.window.setMode
	-- 和 love.window.updateMode. 不同，该函数不会重新创建窗口
	--
	-- 参数：
	--  vsync: 垂直同步编号：1 表示启用，0 表示禁用，-1 表示自适应垂直同步。
	setVSync: function(vsync: boolean | integer)
	-- 获取当前垂直同步（vsync）。
	--
	-- 重载说明：
	-- 1. 如果您想获取当前的垂直同步状态，这可能是 love.window.getMode 的更便宜的替代方案。
	--
	-- 返回值：
	--  vsync: 当前垂直同步状态。如果启用，则为 1；如果禁用，则为 0；如果为自适应垂直同步，则为 -1。
	getVSync: function(): integer
	-- 设置程序运行时是否允许显示器休眠。
	--
	-- 默认情况下禁用显示睡眠。如果允许显示器休眠，某些类型的输入（例如按下操纵杆按钮）可能不会阻止显示器休眠。
	--
	-- 参数：
	--  enabled: true 则启用系统显示睡眠， false 则禁用它。
	setDisplaySleepEnabled: function(enabled: boolean)
	-- 获取程序运行时是否允许显示器休眠。
	--
	-- 默认情况下禁用显示睡眠。如果允许显示器休眠，某些类型的输入（例如按下操纵杆按钮）可能不会阻止显示器休眠。
	--
	-- 返回值：
	--  enabled: 如果启用/允许系统显示睡眠则为 true，否则为 false。
	isDisplaySleepEnabled: function(): boolean
	-- 检查游戏窗口是否有键盘焦点。
	--
	-- 返回值：
	--  focus: 如果窗口具有焦点则为 True，否则为 false。
	hasFocus: function(): boolean
	-- 检查游戏窗口是否有鼠标焦点。
	--
	-- 返回值：
	--  focus: 如果窗口有鼠标焦点则为 true，否则为 false。
	hasMouseFocus: function(): boolean
	-- 检查游戏窗口是否可见。
	--
	-- 如果窗口未最小化且程序未隐藏，则窗口被视为可见。
	--
	-- 返回值：
	--  visible: 如果窗口可见则为 true，如果不可见则为 false。
	isVisible: function(): boolean
	-- 获取Window当前是否最大化。
	--
	-- 如果窗口不是全屏且可调整大小，并且用户已按下窗口的最大化按钮或已调用 love.window.maximize ，则窗口可以最大化。
	--
	-- 返回值：
	--  maximized: 如果窗口当前在窗口模式下最大化，则为 true，否则为 false。
	isMaximized: function(): boolean
	-- 获取窗口当前是否最小化。
	--
	-- 返回值：
	--  minimized: 如果窗口当前最小化则为 true，否则为 false。
	isMinimized: function(): boolean
	-- 获取与窗口关联的 DPI 比例因子。
	--
	-- 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用
	-- 1600x1200 像素。在这种情况下，love.window.getDPIScale() 将返回 2.0。
	--
	-- love.window.fromPixels 和 love.window.toPixels 函数也可用于单位之间的转换。
	--
	-- 必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android
	-- 上它实际上始终处于启用状态。
	--
	-- 重载说明：
	-- 1. love.graphics.getWidth、love.graphics.getHeight、love.mouse.getPosition、鼠标事件、love.touch.getPosition
	-- 和触摸事件的单位始终以像素为单位。
	--
	-- 返回值：
	--  scale: 与窗口关联的像素比例因子。
	getDPIScale: function(): number
	getNativeDPIScale: function(): number
	-- 将数字从与密度无关的单位转换为像素。
	--
	-- 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用
	-- 1600x1200 像素。在这种情况下，love.window.toPixels(800) 将返回 1600。
	--
	-- 这用于将坐标从用户期望它们在屏幕上显示的尺寸转换为像素。 love.window.fromPixels 则相反。必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina
	-- 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android 上它实际上始终处于启用状态。
	--
	-- 大多数 LÖVE 函数返回值并期望参数以像素为单位，而不是与密度无关的单位。
	--
	-- 重载说明：
	-- 1. love.graphics.getWidth、love.graphics.getHeight、love.mouse.getPosition、鼠标事件、love.touch.getPosition
	-- 和触摸事件的单位始终以像素为单位。
	--
	-- 参数：
	--  value: 与密度无关的单位中要转换为像素的数字。
	--  y: 以与密度无关的单位表示的坐标的 y 轴值，以转换为像素。
	--
	-- 返回值：
	--  pixelvalue: 转换后的数字，以像素为单位。
	--  px: 转换后的 x 轴坐标值，以像素为单位。
	--  py: 转换后的 y 轴坐标值，以像素为单位。
	toPixels: function(value: number, y?: number): number, number
	-- 将数字从像素转换为与密度无关的单位。
	--
	-- 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用
	-- 1600x1200 像素。在这种情况下，love.window.fromPixels(1600) 将返回 800。
	--
	-- 此函数将坐标从像素转换为用户期望它们在屏幕上显示的大小。 love.window.toPixels 则相反。必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina
	-- 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android 上它实际上始终处于启用状态。
	--
	-- 大多数 LÖVE 函数返回值并期望参数以像素为单位，而不是与密度无关的单位。
	--
	-- 重载说明：
	-- 1. love.graphics.getWidth、love.graphics.getHeight、love.mouse.getPosition、鼠标事件、love.touch.getPosition
	-- 和触摸事件的单位始终以像素为单位。
	--
	-- 参数：
	--  value: 坐标的 x 轴值（以像素为单位）。
	--  y: 坐标的 y 轴值（以像素为单位）。
	--
	-- 返回值：
	--  value: 转换后的数字，采用与密度无关的单位。
	--  x: 转换后的 x 轴坐标值，采用与密度无关的单位。
	--  y: 转换后的 y 轴坐标值，采用与密度无关的单位。
	fromPixels: function(value: number, y?: number): number, number
end

-- 管理事件，例如按键。
local record Event
	-- Dora 拥有平台事件泵；这不会泵送第二个操作系统队列。将事件泵入事件队列。
	--
	-- 这是一个低级函数，通常不由用户调用，而是由 love.run.
	--
	-- 请注意，确实需要调用此命令才能让任何操作系统认为您仍在运行，
	--
	-- 如果您想处理操作系统生成的事件（考虑回调）。
	pump: function()
	-- 返回事件队列中消息的迭代器。
	--
	-- 返回值：
	--  i: 可在 for 循环中使用的迭代器函数。
	poll: function(): function(): any...
	-- 与 love.event.poll() 类似，但会阻塞，直到队列中有事件为止。
	--
	-- 返回值：
	--  n: 事件名称。
	--  a: 第一个事件参数。
	--  b: 第二个事件参数。
	--  c: 第三个事件参数。
	--  d: 第四个事件参数。
	--  e: 第五个事件参数。
	--  f: 第六个事件参数。
	--  ...: 可能会出现更多事件参数。
	wait: function(): any...
	-- 将事件添加到事件队列。
	--
	-- 从 0.10.0 开始，您可以使用此函数传递任意数量的参数，但默认回调不会使用超过六个。
	--
	-- 参数：
	--  name: 事件的名称。
	--  args: 第一个事件参数。 （默认值：无。）
	push: function(name: string, args: any...): boolean
	-- 清除事件队列。
	clear: function()
	-- 将退出事件添加到队列中。
	--
	-- quit 事件是事件处理程序关闭 LÖVE 的信号。可以使用 love.quit 回调中止退出过程。
	--
	-- 重载说明：
	-- 1. 重新启动游戏而不重新启动可执行文件。这会干净地关闭主 Lua 状态实例并创建一个全新的实例。
	--
	-- 参数：
	--  exit_status: 关闭应用程序时使用的程序退出状态。 （默认值：0。）
	quit: function(exit_status?: integer | string): boolean
end

local type FileType = string
local type FileMode = string
local type BufferMode = string
-- 表示文件内容的数据。
local record FileData
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: FileData): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: FileData, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: FileData): boolean
	-- 获取字符串形式的完整数据。
	--
	-- 返回值：
	--  data: 原始数据。
	getString: function(self: FileData): string
	-- 获取数据的大小（以字节为单位）。
	--
	-- 返回值：
	--  size: 数据的大小（以字节为单位）。
	getSize: function(self: FileData): integer
	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	--
	-- 返回值：
	--  pointer: 指向数据的原始指针。
	getPointer: function(self: FileData): any
	-- 获取指向数据的 FFI 指针。
	--
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	--
	-- 返回值：
	--  pointer: 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: FileData): nil
	-- 创建数据对象的新副本。
	--
	-- 返回值：
	--  clone: 新副本。
	clone: function(self: FileData): FileData
	-- 获取FileData 的文件名。
	--
	-- 返回值：
	--  name: FileData 代表的文件的名称。
	getFilename: function(self: FileData): string
	-- 获取FileData 的扩展名。
	--
	-- 返回值：
	--  ext: FileData 代表的文件的扩展名。
	getExtension: function(self: FileData): string
end
-- 原始（解码）图像数据。
local record ImageData
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: ImageData): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: ImageData): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: ImageData, type_name: string): boolean
	-- 获取字符串形式的完整数据。
	--
	-- 返回值：
	--  data: 原始数据。
	getString: function(self: ImageData): string
	-- 获取数据的大小（以字节为单位）。
	--
	-- 返回值：
	--  size: 数据的大小（以字节为单位）。
	getSize: function(self: ImageData): integer
	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	--
	-- 返回值：
	--  pointer: 指向数据的原始指针。
	getPointer: function(self: ImageData): any
	-- 获取指向数据的 FFI 指针。
	--
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	--
	-- 返回值：
	--  pointer: 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: ImageData): nil
	-- 创建数据对象的新副本。
	--
	-- 返回值：
	--  clone: 新副本。
	clone: function(self: ImageData): ImageData
	-- 获取 ImageData 的宽度（以像素为单位）。
	--
	-- 返回值：
	--  width: ImageData 的宽度（以像素为单位）。
	getWidth: function(self: ImageData): integer
	-- 获取 ImageData 的高度（以像素为单位）。
	--
	-- 返回值：
	--  height: ImageData 的高度（以像素为单位）。
	getHeight: function(self: ImageData): integer
	-- 获取 ImageData 的宽度和高度（以像素为单位）。
	--
	-- 返回值：
	--  width: ImageData 的宽度（以像素为单位）。
	--  height: ImageData 的高度（以像素为单位）。
	getDimensions: function(self: ImageData): integer, integer
	-- 获取ImageData的像素格式。
	--
	-- 返回值：
	--  format: 创建 ImageData 时使用的像素格式。
	getFormat: function(self: ImageData): string
	-- 获取图像中特定位置的像素的颜色。
	--
	-- 有效的 x 和 y 值从 0 开始，直到图像宽度和高度减 1。非整数值将被下限。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 参数：
	--  x: 像素在 x 轴上的位置。
	--  y: 像素在 y 轴上的位置。
	--
	-- 返回值：
	--  r: 红色分量 (0-1)。
	--  g: 绿色分量 (0-1)。
	--  b: 蓝色分量 (0-1)。
	--  a: alpha 分量 (0-1)。
	getPixel: function(self: ImageData, x: integer, y: integer): number, number, number, number
	-- 设置图像中特定位置的像素颜色。
	--
	-- 有效的 x 和 y 值从 0 开始，直到图像宽度和高度减 1。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 参数：
	--  x: 像素在 x 轴上的位置。
	--  y: 像素在 y 轴上的位置。
	--  red: 红色分量 (0-1)。
	--  green: 绿色分量 (0-1)。
	--  blue: 蓝色分量 (0-1)。
	--  alpha: alpha 分量 (0-1)。
	setPixel: function(self: ImageData, x: integer, y: integer, red: number, green: number, blue: number, alpha?: number)
	-- 通过对每个像素应用函数来变换图像。
	--
	-- 该函数是一个高阶函数。它采用另一个函数作为参数，并为 ImageData 中的每个像素调用一次。
	--
	-- 传递的函数被依次调用，每个像素有六个参数。这些参数是代表像素的 x 和 y 坐标及其红色、绿色、蓝色和 alpha 值的数字。该函数应返回该像素的新红色、绿色、蓝色和 alpha 值。
	--
	-- 函数pixelFunction(x,y,r,g,b,a)
	--
	-- -- 用于定义您自己的像素映射函数的模板
	--
	-- -- 执行计算，给出 r、g、b 和 a 的新值
	--
	-- -- ...
	--
	-- 返回r，g，b，a
	--
	-- 结束
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 参数：
	--  mapper: 应用于每个像素的函数。
	--  x: ImageData 中要应用函数的区域左上角的 x 轴。 （默认值：0。）
	--  y: ImageData 中要应用函数的区域左上角的 y 轴。 （默认值：0。）
	--  width: ImageData 中应用函数的区域的宽度。 （默认：ImageData:getWidth()。）
	--  height: ImageData 中要应用函数的区域的高度。 （默认：ImageData:getHeight()。）
	mapPixel: function(self: ImageData, mapper: function(x: integer, y: integer, red: number, green: number, blue: number, alpha: number): (number, number, number, number), x?: integer, y?: integer, width?: integer, height?: integer)
	-- 从另一个源 ImageData 粘贴到 ImageData 中。
	--
	-- 重载说明：
	-- 1. 请注意，此函数只是替换目标矩形中的内容；它不进行任何 alpha 混合。
	--
	-- 参数：
	--  source: 要从中复制的源图像数据。
	--  destination_x: x 轴上的目标左上角位置。
	--  destination_y: y 轴上的目标左上角位置。
	--  source_x: x 轴上的源左上角位置。
	--  source_y: y 轴上的源左上角位置。
	--  source_width: 源宽度。
	--  source_height: 源高度。
	paste: function(self: ImageData, source: ImageData, destination_x: integer, destination_y: integer, source_x?: integer, source_y?: integer, source_width?: integer, source_height?: integer)
	-- 对 ImageData 进行编码并可选择将其写入保存目录。
	--
	-- 参数：
	--  format: 图像编码的格式。取决于重载：对图像进行编码的格式。
	--  filename: 将文件写入的文件名。如果为 nil，则不会写入任何文件，但仍会返回 FileData。 （默认值：无。）
	--
	-- 返回值：
	--  filedata: 作为新 FileData 对象的编码图像。
	encode: function(self: ImageData, format: string, filename?: string): FileData
end
-- 表示旨在在 RAM 中保持压缩状态的压缩图像数据。
local record CompressedImageData
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: CompressedImageData): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: CompressedImageData): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: CompressedImageData, type_name: string): boolean
	-- 获取字符串形式的完整数据。
	--
	-- 返回值：
	--  data: 原始数据。
	getString: function(self: CompressedImageData): string
	-- 获取数据的大小（以字节为单位）。
	--
	-- 返回值：
	--  size: 数据的大小（以字节为单位）。
	getSize: function(self: CompressedImageData): integer
	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	--
	-- 返回值：
	--  pointer: 指向数据的原始指针。
	getPointer: function(self: CompressedImageData): any
	-- 获取指向数据的 FFI 指针。
	--
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	--
	-- 返回值：
	--  pointer: 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: CompressedImageData): nil
	-- 创建数据对象的新副本。
	--
	-- 返回值：
	--  clone: 新副本。
	clone: function(self: CompressedImageData): CompressedImageData
	-- 获取压缩图像数据的宽度。
	--
	-- 参数：
	--  mipmap: mipmap 级别。必须在 CompressedImageData:getMipmapCount() 范围内。
	--
	-- 返回值：
	--  width: 压缩图像数据的宽度。取决于重载： CompressedImageData 的特定 mipmap 级别的宽度。
	getWidth: function(self: CompressedImageData, mipmap?: integer): integer
	-- 获取 CompressedImageData 的高度。
	--
	-- 参数：
	--  mipmap: mipmap 级别。必须在 CompressedImageData:getMipmapCount() 范围内。
	--
	-- 返回值：
	--  height: 压缩图像数据的高度。取决于过载：压缩图像数据的特定 mipmap 级别的高度。
	getHeight: function(self: CompressedImageData, mipmap?: integer): integer
	-- 获取 CompressedImageData 的宽度和高度。
	--
	-- 参数：
	--  mipmap: mipmap 级别。必须在 CompressedImageData:getMipmapCount() 范围内。
	--
	-- 返回值：
	--  width: 压缩图像数据的宽度。取决于重载： CompressedImageData 的特定 mipmap 级别的宽度。
	--  height: 压缩图像数据的高度。取决于过载：压缩图像数据的特定 mipmap 级别的高度。
	getDimensions: function(self: CompressedImageData, mipmap?: integer): integer, integer
	-- 获取 CompressedImageData 中的 mipmap 级别数。基本 mipmap 级别（原始图像）包含在计数中。
	--
	-- 重载说明：
	-- 1. Mipmap 过滤无法激活，会出现 Image:setMipmapFilter 错误。大多数可以创建压缩纹理的工具都能够在同一文件中自动为其生成 mipmap。
	--
	-- 返回值：
	--  mipmaps: 压缩图像数据中存储的 mipmap 级别数。
	getMipmapCount: function(self: CompressedImageData): integer
	-- 获取压缩图像数据的格式。
	--
	-- 返回值：
	--  format: 压缩图像数据的格式。
	getFormat: function(self: CompressedImageData): string
end
-- 提供解码编码图像数据的接口。
local record ImageModule
	-- 创建一个新的 ImageData 对象。
	--
	-- 参数：
	--  filename_or_width_or_data: ImageData 的宽度。
	--  height: ImageData 的高度。
	--  format: ImageData 的像素格式。 （默认：'rgba8'。）
	--  data: 可选的原始字节数据，以“'format'”指定的格式加载到 ImageData 中。 （默认值：nil。）取决于重载：要加载到 ImageData 中的数据（RGBA 字节，从左到右、从上到下）。
	--
	-- 返回值：
	--  imageData: 新的空白 ImageData 对象。每个像素的颜色值（包括 Alpha 值！）将设置为零。取决于重载：新的 ImageData 对象。
	newImageData: function(filename_or_width_or_data: string | integer | FileData, height?: integer, format?: string, data?: string | FileData): ImageData
	-- 从压缩图像文件创建一个新的 CompressedImageData 对象。 LÖVE 支持多种压缩纹理格式，在 CompressedImageFormat 页面中列出。
	--
	-- 参数：
	--  filename_or_data: 压缩图像文件的文件名。取决于重载：包含压缩图像的 FileData。
	--
	-- 返回值：
	--  compressedImageData: 新的 CompressedImageData 对象。
	newCompressedData: function(filename_or_data: string | FileData): CompressedImageData
	-- 确定文件是否可以作为 CompressedImageData 加载。
	--
	-- 参数：
	--  filename_or_data: 可能压缩的图像文件的文件名。根据重载：可能包含压缩图像的 FileData。
	--
	-- 返回值：
	--  compressed: 文件是否可以作为 CompressedImageData 加载。取决于重载：FileData 是否可以作为 CompressedImageData 加载。
	isCompressed: function(filename_or_data: string | FileData): boolean
end
-- 光栅化器处理字体渲染，包含字体数据（图像或TrueType字体）和可绘制的字形。
local record Rasterizer
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Rasterizer): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Rasterizer): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Rasterizer, type_name: string): boolean
	-- 获取字体高度。
	--
	-- 返回值：
	--  height: 字体高度
	getHeight: function(self: Rasterizer): integer
	-- 获取字体提前。
	--
	-- 返回值：
	--  advance: 字体提前。
	getAdvance: function(self: Rasterizer): integer
	-- 获取上升高度。
	--
	-- 返回值：
	--  height: 上升高度。
	getAscent: function(self: Rasterizer): integer
	-- 获取下降高度。
	--
	-- 返回值：
	--  height: 下降高度。
	getDescent: function(self: Rasterizer): integer
	-- 获取字体的行高。
	--
	-- 返回值：
	--  height: 字体的行高。
	getLineHeight: function(self: Rasterizer): integer
	-- 获取指定字形的字形数据。
	--
	-- 参数：
	--  glyph: 字形
	--
	-- 返回值：
	--  glyphData: 字形数据
	getGlyphData: function(self: Rasterizer, glyph: string | integer): GlyphData
	-- 获取字体中的字形数量。
	--
	-- 返回值：
	--  count: 字形计数。
	getGlyphCount: function(self: Rasterizer): integer
	-- 检查字体是否包含指定的字形。
	--
	-- 参数：
	--  glyph: 字形
	--
	-- 返回值：
	--  hasGlyphs: 任何包含指定字形的字体。
	hasGlyphs: function(self: Rasterizer, glyph: string | integer, ...: string | integer): boolean
end
-- GlyphData 表示字体光栅化器的可绘制符号。
local record GlyphData
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: GlyphData): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: GlyphData): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: GlyphData, type_name: string): boolean
	-- 获取字符串形式的完整数据。
	--
	-- 返回值：
	--  data: 原始数据。
	getString: function(self: GlyphData): string
	-- 获取数据的大小（以字节为单位）。
	--
	-- 返回值：
	--  size: 数据的大小（以字节为单位）。
	getSize: function(self: GlyphData): integer
	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	--
	-- 返回值：
	--  pointer: 指向数据的原始指针。
	getPointer: function(self: GlyphData): any
	-- 获取指向数据的 FFI 指针。
	--
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	--
	-- 返回值：
	--  pointer: 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: GlyphData): nil
	-- 创建数据对象的新副本。
	--
	-- 返回值：
	--  clone: 新副本。
	clone: function(self: GlyphData): GlyphData
	-- 获取字形宽度。
	--
	-- 返回值：
	--  width: 字形宽度。
	getWidth: function(self: GlyphData): integer
	-- 获取字形高度。
	--
	-- 返回值：
	--  height: 字形高度。
	getHeight: function(self: GlyphData): integer
	-- 获取字形尺寸。
	--
	-- 返回值：
	--  width: 字形宽度。
	--  height: 字形高度。
	getDimensions: function(self: GlyphData): integer, integer
	-- 获取字形编号。
	--
	-- 返回值：
	--  glyph: 字形编号。
	getGlyph: function(self: GlyphData): integer
	-- 获取字形字符串。
	--
	-- 返回值：
	--  glyph: 字形字符串。
	getGlyphString: function(self: GlyphData): string
	-- 获取字形提前。
	--
	-- 返回值：
	--  advance: 字形前进。
	getAdvance: function(self: GlyphData): integer
	-- 获取字形方位。
	--
	-- 返回值：
	--  bx: 字形轴承 X.
	--  by: 字形轴承 Y。
	getBearing: function(self: GlyphData): integer, integer
	-- 获取字形边界框。
	--
	-- 返回值：
	--  x: 字形位置 x。
	--  y: 字形位置 y。
	--  width: 字形宽度。
	--  height: 字形高度。
	getBoundingBox: function(self: GlyphData): integer, integer, integer, integer
	-- 获取字形像素格式。
	--
	-- 返回值：
	--  format: 字形像素格式。
	getFormat: function(self: GlyphData): string
end
-- 允许您使用字体。
local record FontModule
	-- 创建一个新的图像光栅化器。
	--
	-- 重载说明：
	-- 1. 从图像数据创建一个ImageRasterizer。
	--
	-- 参数：
	--  image_data: 字体图像数据。
	--  glyphs: 包含字体字形的字符串。
	--  extra_spacing: 字体额外间距。 （默认值：0。）
	--  dpi_scale: 字体 DPI 比例。 （默认值：1。）
	--
	-- 返回值：
	--  rasterizer: 光栅器。
	newImageRasterizer: function(image_data: ImageData, glyphs: string, extra_spacing?: integer, dpi_scale?: number): Rasterizer
	-- 创建一个新的 BMFont 光栅化器。
	--
	-- 参数：
	--  filename_or_file_data: 包含字体字形的可绘制图片的图像数据。取决于重载：包含字体字形的可绘制图片的文件的路径。
	--  images: ImageData 中的字形序列。
	--  dpi_scale: DPI 比例。 （默认值：1。）
	--
	-- 返回值：
	--  rasterizer: 光栅器。
	newBMFontRasterizer: function(filename_or_file_data: string | FileData, images?: ImageData | string | FileData | {ImageData | string | FileData}, dpi_scale?: number): Rasterizer
	-- 创建一个新的 TrueType 光栅化器。
	--
	-- 重载说明：
	-- 1. 使用默认字体创建一个TrueTypeRasterizer。 2. 使用自定义字体创建 TrueTypeRasterizer。
	--
	-- 参数：
	--  filename_or_size_or_data: 字体文件的路径。取决于重载：包含字体的文件数据。
	--  size_or_hinting: 字体大小。 （默认值：12。）
	--  hinting_or_dpi: True Type 提示模式。 （默认：'normal'。）
	--  dpi_scale: 字体 DPI 比例。 （默认：love.window.getDPIScale()。）
	--
	-- 返回值：
	--  rasterizer: 光栅器。
	newTrueTypeRasterizer: function(filename_or_size_or_data?: string | integer | FileData, size_or_hinting?: integer | string, hinting_or_dpi?: string | number, dpi_scale?: number): Rasterizer
	-- 创建一个新的光栅化器。
	--
	-- 重载说明：
	-- 1. 使用默认字体创建一个 TrueTypeRasterizer。 2. 使用自定义字体创建 TrueTypeRasterizer。 3. 创建一个新的 BMFont Rasterizer。
	--
	-- 参数：
	--  filename_or_size_or_data: 字体文件的路径。取决于重载：包含字体的文件数据。
	--  size_or_hinting: 字体大小。 （默认值：12。）
	--  hinting_or_dpi: True Type 提示模式。 （默认：'normal'。）
	--  dpi_scale: 字体 DPI 比例。 （默认值：love.window.getDPIScale()。）取决于过载：DPI 比例。 （默认值：1。）
	--
	-- 返回值：
	--  rasterizer: 光栅器。
	newRasterizer: function(filename_or_size_or_data?: string | integer | FileData, size_or_hinting?: integer | string, hinting_or_dpi?: string | number, dpi_scale?: number): Rasterizer
	-- 创建一个新的 GlyphData。
	--
	-- 参数：
	--  rasterizer: 包含字体的光栅化器。
	--  glyph: 字形的字符代码。
	newGlyphData: function(rasterizer: Rasterizer, glyph: string | integer): GlyphData
end
-- 包含原始音频样本。
local record SoundData
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: SoundData): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: SoundData, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: SoundData): boolean
	-- 获取字符串形式的完整数据。
	--
	-- 返回值：
	--  data: 原始数据。
	getString: function(self: SoundData): string
	-- 获取数据的大小（以字节为单位）。
	--
	-- 返回值：
	--  size: 数据的大小（以字节为单位）。
	getSize: function(self: SoundData): integer
	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	--
	-- 返回值：
	--  pointer: 指向数据的原始指针。
	getPointer: function(self: SoundData): any
	-- 获取指向数据的 FFI 指针。
	--
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	--
	-- 返回值：
	--  pointer: 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: SoundData): nil
	-- 创建数据对象的新副本。
	--
	-- 返回值：
	--  clone: 新副本。
	clone: function(self: SoundData): SoundData
	-- 返回 SoundData 中的通道数。
	--
	-- 返回值：
	--  channels: 1 用于单声道，2 用于立体声。
	getChannelCount: function(self: SoundData): integer
	getChannels: function(self: SoundData): integer
	-- 返回每个样本的位数。
	--
	-- 返回值：
	--  bitdepth: 8 或 16。
	getBitDepth: function(self: SoundData): integer
	-- 返回声音数据的采样率。
	--
	-- 返回值：
	--  rate: 每秒的样本数。
	getSampleRate: function(self: SoundData): integer
	-- 返回 SoundData 每个通道的样本数。
	--
	-- 返回值：
	--  count: 样本总数。
	getSampleCount: function(self: SoundData): integer
	-- 获取声音数据的持续时间。
	--
	-- 返回值：
	--  duration: 声音数据的持续时间（以秒为单位）。
	getDuration: function(self: SoundData): number
	getSample: function(self: SoundData, index: integer, channel?: integer): number
	-- 设置指定位置的采样点值。对于立体声 SoundData 对象，来自左声道和右声道的数据按该顺序交错。
	--
	-- 重载说明：
	-- 1. 使用显式样本索引设置样本值，而不是在样本位置参数中交错它们。
	--
	-- 参数：
	--  index: 指定样本位置的整数值（从 0 开始）。
	--  channel_or_sample: 在给定样本中设置的通道索引。
	--  sample: 归一化采样点（范围 -1.0 到 1.0）。
	setSample: function(self: SoundData, index: integer, channel_or_sample: number, sample?: number)
end
-- 一个可以逐步解码声音文件的对象。
local record Decoder
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Decoder): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Decoder, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Decoder): boolean
	-- 创建当前解码器的新副本。
	--
	-- 新解码器将从音频流的开头开始解码。
	--
	-- 返回值：
	--  decoder: 解码器的新副本。
	clone: function(self: Decoder): Decoder
	-- 返回流中的通道数。
	--
	-- 返回值：
	--  channels: 1 用于单声道，2 用于立体声。
	getChannelCount: function(self: Decoder): integer
	getChannels: function(self: Decoder): integer
	-- 返回每个样本的位数。
	--
	-- 返回值：
	--  bitDepth: 8 或 16。
	getBitDepth: function(self: Decoder): integer
	-- 返回解码器的采样率。
	--
	-- 返回值：
	--  rate: 每秒的样本数。
	getSampleRate: function(self: Decoder): integer
	-- 获取声音文件的持续时间。它可能并不总是样本准确的，如果根本无法确定持续时间，它可能会返回 -1。
	--
	-- 返回值：
	--  duration: 声音文件的持续时间（以秒为单位），如果无法确定则为 -1。
	getDuration: function(self: Decoder): number
	-- 解码音频并返回包含解码后的音频数据的 SoundData 对象。
	--
	-- 返回值：
	--  soundData: 解码的音频数据。
	decode: function(self: Decoder): SoundData | nil
	-- 设置解码器当前的播放位置。
	--
	-- 参数：
	--  offset: 要寻找的位置，以秒为单位。
	seek: function(self: Decoder, offset: number)
end
-- 该模块负责解码声音文件。它无法播放声音，请参阅 love.audio 。
local record SoundModule
	-- 尝试在指定文件中查找编码声音数据的解码器。
	--
	-- 参数：
	--  filename_or_data: 包含编码声音数据的文件。取决于过载：带有编码声音数据的文件的文件名。
	--  buffer_size: 每个解码块的大小（以字节为单位）。 （默认值：2048。）
	--
	-- 返回值：
	--  decoder: 一个新的解码器对象。
	newDecoder: function(filename_or_data: string | FileData, buffer_size?: integer): Decoder
	-- 从文件路径、文件或解码器创建新的 SoundData。还可以创建具有自定义采样率、通道和位深度的 SoundData。
	--
	-- 声音数据将以原始格式解码到内存中。建议仅创建简短的声音（例如效果），因为这样 3 分钟的歌曲会使用 30 MB 的内存。
	--
	-- 参数：
	--  filename_or_samples_or_data_or_decoder: 样本总数。
	--  sample_rate_or_buffer_size: 每秒采样数（默认值：44100。）
	--  bit_depth: 每个样本的位数（8 或 16）。 （默认值：16。）
	--  channels: 1 表示单声道，2 表示立体声。 （默认值：2。）
	--
	-- 返回值：
	--  soundData: 一个新的 SoundData 对象。
	newSoundData: function(filename_or_samples_or_data_or_decoder: string | integer | FileData | Decoder, sample_rate_or_buffer_size?: integer, bit_depth?: integer, channels?: integer): SoundData
end
-- 连续内存中包含任意字节的数据对象。
local record ByteData
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: ByteData): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: ByteData, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: ByteData): boolean
	-- 获取字符串形式的完整数据。
	--
	-- 返回值：
	--  data: 原始数据。
	getString: function(self: ByteData): string
	-- 获取数据的大小（以字节为单位）。
	--
	-- 返回值：
	--  size: 数据的大小（以字节为单位）。
	getSize: function(self: ByteData): integer
	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	--
	-- 返回值：
	--  pointer: 指向数据的原始指针。
	getPointer: function(self: ByteData): any
	-- 获取指向数据的 FFI 指针。
	--
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	--
	-- 返回值：
	--  pointer: 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: ByteData): nil
	-- 创建数据对象的新副本。
	--
	-- 返回值：
	--  clone: 新副本。
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
-- 表示使用特定算法压缩的字节数据。
local record CompressedData
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: CompressedData): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: CompressedData, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: CompressedData): boolean
	-- 获取字符串形式的完整数据。
	--
	-- 返回值：
	--  data: 原始数据。
	getString: function(self: CompressedData): string
	-- 获取数据的大小（以字节为单位）。
	--
	-- 返回值：
	--  size: 数据的大小（以字节为单位）。
	getSize: function(self: CompressedData): integer
	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	--
	-- 返回值：
	--  pointer: 指向数据的原始指针。
	getPointer: function(self: CompressedData): any
	-- 获取指向数据的 FFI 指针。
	--
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	--
	-- 返回值：
	--  pointer: 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: CompressedData): nil
	-- 创建数据对象的新副本。
	--
	-- 返回值：
	--  clone: 新副本。
	clone: function(self: CompressedData): CompressedData
	-- 获取CompressedData的压缩格式。
	--
	-- 返回值：
	--  format: 压缩数据的格式。
	getFormat: function(self: CompressedData): string
end
-- 提供创建和转换数据的功能。
local record DataModule
	-- 创建一个包含任意字节的新数据对象。
	--
	-- Data:getPointer 与 LuaJIT 的 FFI 一起可用于在创建 ByteData 对象后对其内容进行操作。
	--
	-- 重载说明：
	-- 1. 通过复制指定字符串的内容来创建新的ByteData。 2. 通过从现有数据对象复制来创建新的 ByteData。 3. 创建一个具有特定大小的新空ByteData。
	--
	-- 参数：
	--  size_or_string_or_data: 要复制的现有数据对象。
	--  offset: 要复制的子节的偏移量（以字节为单位）。 （默认值：0。）
	--  size: 新数据对象的大小（以字节为单位）。 （默认值：data:getSize()。）取决于重载：新数据对象的大小（以字节为单位）。
	--
	-- 返回值：
	--  bytedata: 新的数据对象。
	newByteData: function(size_or_string_or_data: any, offset?: integer, size?: integer): ByteData
	-- 创建引用现有数据对象的一部分的新数据。
	--
	-- 重载说明：
	-- 1. Data:getString 和 Data:getPointer 将返回原始数据对象的内容，并应用视图的偏移量和大小。
	--
	-- 参数：
	--  data: 要引用的数据对象。
	--  offset: 要引用的子节的偏移量（以字节为单位）。
	--  size: 要引用的小节的大小（以字节为单位）。
	--
	-- 返回值：
	--  view: 新的数据视图。
	newDataView: function(data: any, offset: integer, size: integer): DataView
	-- 将数据或字符串编码为采用一种编码格式的数据或字符串。
	--
	-- 参数：
	--  container: 返回编码数据的类型。
	--  format: 输出数据的格式。
	--  source: 要编码的原始数据。
	--  line_length: 输出的最大行长度。仅支持 base64，如果为 0，则忽略。（默认值：0。）
	--
	-- 返回值：
	--  encoded: ByteData/string，其中包含源的编码版本。
	encode: function(container: string, format: string, source: any, line_length?: integer): string | ByteData
	-- 将数据或字符串从任何 EncodeFormat 解码为数据或字符串。
	--
	-- 参数：
	--  container: 解码后的数据返回什么类型。
	--  format: 输入数据的格式。
	--  source: 要解码的原始（编码）数据。
	--
	-- 返回值：
	--  decoded: ByteData/string，其中包含源的解码版本。
	decode: function(container: string, format: string, source: any): string | ByteData
	-- 使用特定的压缩算法压缩字符串或数据。
	--
	-- 参数：
	--  container: 返回压缩数据的类型。
	--  format: 压缩字符串时使用的格式。取决于过载：压缩数据时使用的格式。
	--  source: 要压缩的原始（未压缩）字符串。取决于重载：包含要压缩的原始（未压缩）数据的数据对象。
	--  level: 要使用的压缩级别，介于 0 和 9 之间。-1 表示默认级别。该参数的含义取决于所使用的压缩格式。 （默认值：-1。）
	--
	-- 返回值：
	--  compressedData: 压缩数据/字符串，其中包含原始字符串的压缩版本。取决于重载：压缩数据/字符串，其中包含数据的压缩版本。
	compress: function(container: string, format: string, source: any, level?: integer): string | CompressedData
	-- 解压缩 CompressedData 或先前压缩的字符串或数据对象。
	--
	-- 参数：
	--  container: 解压后的数据返回什么类型。
	--  format_or_data: 用于压缩给定字符串的格式。取决于过载：用于压缩给定数据的格式。
	--  source: 包含先前使用 love.data.compress. 压缩的数据的字符串 取决于重载：包含先前使用 love.data.compress. 压缩的数据的数据对象
	--
	-- 返回值：
	--  decompressedData: 包含原始解压缩数据的数据/字符串。
	decompress: function(container: string, format_or_data: any, source?: any): string | ByteData
	-- 打包（序列化）简单的 Lua 值。
	--
	-- 该函数的行为与 Lua 5.3 的 string.pack 相同。
	--
	-- 重载说明：
	-- 1. 不支持打包大于2^52的整数，因为Lua 5.1无法用其数字类型表示这些值。
	--
	-- 参数：
	--  container: 返回编码数据的类型。
	--  format: 确定如何打包值的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
	--  values: 要序列化的第一个值（数字、布尔值或字符串）。
	--
	-- 返回值：
	--  data: 包含序列化数据的数据/字符串。
	pack: function(container: string, format: string, values: any...): string | ByteData
	-- 将字节字符串或数据解包（反序列化）为简单的 Lua 值。
	--
	-- 该函数的行为与 Lua 5.3 的 string.unpack 相同。
	--
	-- 重载说明：
	-- 1. 不支持解压大于2^52的整数，因为Lua 5.1无法用数字类型表示这些值。
	--
	-- 参数：
	--  format: 确定值如何打包的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
	--  source: 包含打包（序列化）数据的字符串。根据重载：包含打包（序列化）数据的数据对象。
	--  position: 从哪里开始读取字符串。负值可用于从字符串末尾读取相对值。 （默认值：1。）取决于过载：从 1 开始的索引，指示从何处开始读取数据。负值可用于从数据对象末尾读取相对值。 （默认值：1。）
	--
	-- 返回值：
	--  v1: 解压的第一个值（数字、布尔值或字符串）。
	--  ...: 附加解压值。
	--  index: 数据字符串中第一个未读字节的索引。取决于过载：数据中第一个未读字节的从 1 开始的索引。
	unpack: function(format: string, source: any, position?: integer): any...
	-- 获取与 love.data.pack 一起使用的给定格式将使用的大小（以字节为单位）。
	--
	-- 该函数的行为与 Lua 5.3 的 string.packsize 相同。
	--
	-- 重载说明：
	-- 1. 格式字符串不能有可变长度选项's' 或'z'。
	--
	-- 参数：
	--  format: 确定如何打包值的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
	--
	-- 返回值：
	--  size: 打包数据将使用的大小（以字节为单位）。
	getPackedSize: function(format: string): integer
	-- 使用指定的哈希算法计算字符串的消息摘要。
	--
	-- 重载说明：
	-- 1. 要返回哈希值的十六进制字符串表示形式，请使用 love.data.encode hexDigestString = love.data.encode('string', 'hex',
	-- love.data.hash(algo, data))
	--
	-- 参数：
	--  hash_function: 要使用的哈希算法。
	--  source: 要散列的字符串。根据过载：要散列的数据。
	--
	-- 返回值：
	--  rawdigest: 原始消息摘要字符串。
	hash: function(hash_function: string, source: any): string
end
-- 一个随机数生成对象，有自己的随机状态。
local record RandomGenerator
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: RandomGenerator): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: RandomGenerator, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: RandomGenerator): boolean
	-- 以独立于平台的方式生成伪随机数。
	--
	-- 重载说明：
	-- 1. 获取1以内均匀分布的伪随机数。 2. 获取max.以内均匀分布的伪随机整数。
	--
	-- 参数：
	--  lower_or_upper: 它应该返回的最小可能值。
	--  upper: 它应该返回的最大可能值。
	--
	-- 返回值：
	--  number: 伪随机数。取决于过载：伪随机整数。
	random: function(self: RandomGenerator, lower_or_upper?: number, upper?: number): number
	-- 获取正态分布的伪随机数。
	--
	-- 参数：
	--  standard_deviation: 分布的标准偏差。 （默认值：1。）
	--  mean: 分布的平均值。 （默认值：0。）
	--
	-- 返回值：
	--  number: 具有方差 (stddev)² 和指定平均值的正态分布随机数。
	randomNormal: function(self: RandomGenerator, standard_deviation?: number, mean?: number): number
	-- 使用指定的整数设置随机数生成器的种子。
	--
	-- 重载说明：
	-- 1. 由于Lua使用双精度浮点数，无法准确表示2^53以上的值。如果您的种子具有更大的值，请使用此函数的其他变体。 2. 将两个 32 位整数组合成一个 64 位整数值，并使用该值设置随机数生成器的种子。
	--
	-- 参数：
	--  low_or_seed: 种子值的低 32 位。必须在 2^32 - 1 范围内。
	--  high: 种子值的高 32 位。必须在 2^32 - 1 范围内。
	setSeed: function(self: RandomGenerator, low_or_seed: number, high?: number)
	-- 获取随机数生成器对象的种子。
	--
	-- 由于 Lua 对所有数值都使用双精度数，因此种子被分成两个数字 - 双精度数无法准确表示 2^53 以上的整数值，但种子值是 2^64 - 1 范围内的整数。
	--
	-- 返回值：
	--  low: 表示 RandomGenerator 的 64 位种子值的低 32 位的整数。
	--  high: 表示 RandomGenerator 的 64 位种子值的高 32 位的整数。
	getSeed: function(self: RandomGenerator): number, number
	-- 设置随机数生成器的当前状态。用作此函数参数的值是一个不透明字符串，并且只能源自 LÖVE 的同一主要版本中之前对 RandomGenerator:getState 的调用。
	--
	-- 这与 RandomGenerator:setSeed 不同，setState 直接设置 RandomGenerator 的当前依赖于实现的状态，而 setSeed 为其提供新的种子值。
	--
	-- 重载说明：
	-- 1. 状态字符串的效果与当前操作系统无关。
	--
	-- 参数：
	--  state: RandomGenerator 对象的新状态，表示为字符串。这应该源自之前对 RandomGenerator:getState 的调用。
	setState: function(self: RandomGenerator, state: string)
	-- 获取随机数生成器的当前状态。这会返回一个不透明的字符串，该字符串仅适用于以后与 LÖVE 的相同主要版本中的 RandomGenerator:setState 一起使用。
	--
	-- 这与 RandomGenerator:getSeed 不同，getState 获取 RandomGenerator 的当前状态，而 getSeed 获取之前设置的种子数。
	--
	-- 重载说明：
	-- 1. 状态字符串的值与当前操作系统无关。
	--
	-- 返回值：
	--  state: RandomGenerator 对象的当前状态，表示为字符串。
	getState: function(self: RandomGenerator): string
end
-- 包含坐标系变换的对象。
local record Transform
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Transform): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Transform, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Transform): boolean
	-- 创建此变换的新副本。
	--
	-- 返回值：
	--  clone: 此变换的副本。
	clone: function(self: Transform): Transform
	-- 创建一个包含此变换的逆变换的新变换。
	--
	-- 返回值：
	--  inverse: 一个新的 Transform 对象，表示此 Transform 矩阵的逆矩阵。
	inverse: function(self: Transform): Transform
	-- 将给定的其他 Transform 对象应用于此对象。
	--
	-- 这有效地将此 Transform 的内部变换矩阵与其他 Transform 的（即 self * other）相乘，并将结果存储在此对象中。
	--
	-- 参数：
	--  other: 应用于此变换的另一个变换对象。
	--
	-- 返回值：
	--  transform: 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	apply: function(self: Transform, other: Transform): Transform
	-- 检查变换是否是仿射变换。
	--
	-- 返回值：
	--  affine: 如果变换对象是仿射变换，则为 true，否则为 false。
	isAffine2DTransform: function(self: Transform): boolean
	-- 将平移应用到变换的坐标系。此方法不会重置任何先前应用的转换。
	--
	-- 参数：
	--  x: 沿 x 轴的相对平移。
	--  y: 沿 y 轴的相对平移。
	--
	-- 返回值：
	--  transform: 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	translate: function(self: Transform, x: number, y: number): Transform
	-- 对变换的坐标系应用旋转。此方法不会重置任何先前应用的转换。
	--
	-- 参数：
	--  angle: 旋转此变换的相对角度（以弧度为单位）。
	--
	-- 返回值：
	--  transform: 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	rotate: function(self: Transform, angle: number): Transform
	-- 缩放变换的坐标系。此方法不会重置任何先前应用的转换。
	--
	-- 参数：
	--  x: 沿 x 轴的相对比例因子。
	--  y: 沿 y 轴的相对比例因子。 （默认值：sx。）
	--
	-- 返回值：
	--  transform: 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	scale: function(self: Transform, x: number, y?: number): Transform
	-- 将剪切因子（倾斜）应用于变换的坐标系。此方法不会重置任何先前应用的转换。
	--
	-- 参数：
	--  x: 沿 x 轴的剪切因子。
	--  y: 沿 y 轴的剪切因子。
	--
	-- 返回值：
	--  transform: 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	shear: function(self: Transform, x: number, y: number): Transform
	-- 将变换重置为同一状态。所有先前应用的转换都将被删除。
	--
	-- 返回值：
	--  transform: 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	reset: function(self: Transform): Transform
	-- 将变换重置为指定的变换参数。
	--
	-- 参数：
	--  x: 变换在 x 轴上的位置。
	--  y: 变换在 y 轴上的位置。
	--  angle: 变换的方向（以弧度为单位）。 （默认值：0。）
	--  scale_x: x 轴上的比例因子。 （默认值：1。）
	--  scale_y: y 轴的比例因子。 （默认值：sx。）
	--  origin_x: x 轴上的原点偏移。 （默认值：0。）
	--  origin_y: y 轴上的原点偏移。 （默认值：0。）
	--  shear_x: x 轴上的剪切/倾斜因子。 （默认值：0。）
	--  shear_y: y 轴上的剪切/倾斜因子。 （默认值：0。）
	--
	-- 返回值：
	--  transform: 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	setTransformation: function(self: Transform, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): Transform
	-- 直接设置Transform的内部4x4变换矩阵。
	--
	-- 参数：
	--  layout_or_elements: 如何解释矩阵元素参数（行优先或列优先）。
	--  elements: 包含 16 个矩阵元素的平面表。取决于过载：一个由 4 个表组成的表，每个子表包含 4 个矩阵元素。
	--
	-- 返回值：
	--  transform: 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	setMatrix: function(self: Transform, layout_or_elements: string | {number} | {{number}}, elements?: {number} | {{number}}): Transform
	-- 获取此Transform存储的内部4x4变换矩阵。矩阵按行优先顺序返回。
	--
	-- 返回值：
	--  e1_1: 矩阵第一行的第一列。
	--  e1_2: 矩阵第一行的第二列。
	--  e1_3: 矩阵第一行的第三列。
	--  e1_4: 矩阵第一行的第四列。
	--  e2_1: 矩阵第二行第一列。
	--  e2_2: 矩阵第二行的第二列。
	--  e2_3: 矩阵第二行第三列。
	--  e2_4: 矩阵第二行第四列。
	--  e3_1: 矩阵第三行第一列。
	--  e3_2: 矩阵第三行第二列。
	--  e3_3: 矩阵第三行第三列。
	--  e3_4: 矩阵第三行第四列。
	--  e4_1: 矩阵第四行第一列。
	--  e4_2: 矩阵第四行第二列。
	--  e4_3: 矩阵第四行第三列。
	--  e4_4: 矩阵第四行第四列。
	getMatrix: function(self: Transform): number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number
	-- 将 Transform 对象的变换应用到给定的 2D 位置。
	--
	-- 这有效地将给定位置从全局坐标转换到变换的局部坐标空间。
	--
	-- 参数：
	--  x: 全局坐标中位置的 x 分量。
	--  y: 全局坐标中位置的 y 分量。
	--
	-- 返回值：
	--  localX: 应用变换的位置的 x 分量。
	--  localY: 应用变换的位置的 y 分量。
	transformPoint: function(self: Transform, x: number, y: number): number, number
	-- 将 Transform 对象的变换反向应用到给定的 2D 位置。
	--
	-- 这有效地将给定位置从变换的局部坐标空间转换为全局坐标。
	--
	-- 如果给定的变换应用了用于游戏中相机系统的变换，则此方法的一种用途是将屏幕空间鼠标位置转换为全局世界坐标。
	--
	-- 参数：
	--  x: 应用变换的位置的 x 分量。
	--  y: 应用变换的位置的 y 分量。
	--
	-- 返回值：
	--  globalX: 全局坐标中位置的 x 分量。
	--  globalY: 全局坐标中位置的 y 分量。
	inverseTransformPoint: function(self: Transform, x: number, y: number): number, number
end
-- 一个贝塞尔曲线对象，可以评估和渲染任意阶数的贝塞尔曲线。
local record BezierCurve
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: BezierCurve): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: BezierCurve, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: BezierCurve): boolean
	-- 获取贝塞尔曲线的阶数。次数等于控制点数 - 1。
	--
	-- 返回值：
	--  degree: 贝塞尔曲线的阶数。
	getDegree: function(self: BezierCurve): integer
	-- 获取贝塞尔曲线的导数。
	--
	-- 该函数可用于旋转沿着曲线移动的精灵的运动方向，并在某个参数 t 处计算垂直于曲线的方向。
	--
	-- 返回值：
	--  derivative: 导数曲线。
	getDerivative: function(self: BezierCurve): BezierCurve
	-- 获取第i个控制点的坐标。索引从 1 开始。
	--
	-- 参数：
	--  index: 控制点的索引。
	--
	-- 返回值：
	--  x: 控制点沿 x 轴的位置。
	--  y: 控制点沿 y 轴的位置。
	getControlPoint: function(self: BezierCurve, index: integer): number, number
	-- 设置第i个控制点的坐标。索引从 1 开始。
	--
	-- 参数：
	--  index: 控制点的索引。
	--  x: 控制点沿 x 轴的位置。
	--  y: 控制点沿 y 轴的位置。
	setControlPoint: function(self: BezierCurve, index: integer, x: number, y: number)
	-- 插入控制点作为新的第 i 个控制点。从 i 开始的现有控制点向后推 1。索引从 1 开始。负索引环绕：-1 是最后一个控制点，-2 是最后一个控制点之前的控制点，等等。
	--
	-- 参数：
	--  x: 控制点沿 x 轴的位置。
	--  y: 控制点沿 y 轴的位置。
	--  index: 控制点的索引。 （默认值：-1。）
	insertControlPoint: function(self: BezierCurve, x: number, y: number, index?: integer)
	-- 删除指定的控制点。
	--
	-- 参数：
	--  index: 要删除的控制点的索引。
	removeControlPoint: function(self: BezierCurve, index: integer)
	-- 获取贝塞尔曲线中控制点的数量。
	--
	-- 返回值：
	--  count: 控制点数。
	getControlPointCount: function(self: BezierCurve): integer
	-- 将贝塞尔曲线移动一个偏移量。
	--
	-- 参数：
	--  x: 沿 x 轴的偏移。
	--  y: 沿 y 轴的偏移。
	translate: function(self: BezierCurve, x: number, y: number)
	-- 将贝塞尔曲线旋转一个角度。
	--
	-- 参数：
	--  angle: 以弧度为单位的旋转角度。
	--  origin_x: 旋转中心的X坐标。 （默认值：0。）
	--  origin_y: 旋转中心的Y坐标。 （默认值：0。）
	rotate: function(self: BezierCurve, angle: number, origin_x?: number, origin_y?: number)
	-- 将贝塞尔曲线缩放一个因子。
	--
	-- 参数：
	--  scale: 比例因子。
	--  origin_x: 缩放中心的X坐标。 （默认值：0。）
	--  origin_y: 缩放中心的Y坐标。 （默认值：0。）
	scale: function(self: BezierCurve, scale: number, origin_x?: number, origin_y?: number)
	-- 在参数 t 处评估贝塞尔曲线。该参数必须介于 0 和 1 之间（包含 0 和 1）。
	--
	-- 此函数可用于沿路径或补间参数移动对象。但是，它不应该用于渲染曲线，为此目的请参阅 BezierCurve:render 。
	--
	-- 参数：
	--  time: 在哪里评估曲线。
	--
	-- 返回值：
	--  x: 参数 t 处曲线的 x 坐标。
	--  y: 参数 t 处曲线的 y 坐标。
	evaluate: function(self: BezierCurve, time: number): number, number
	-- 获取与此 BezierCurve 的指定段相对应的 BezierCurve。
	--
	-- 参数：
	--  start: 沿曲线的起点。必须介于 0 和 1 之间。
	--  finish: 段结束。必须介于 0 和 1 之间。
	--
	-- 返回值：
	--  curve: 与指定线段相对应的贝塞尔曲线。
	getSegment: function(self: BezierCurve, start: number, finish: number): BezierCurve
	-- 获取要与love.graphics.line.
	--
	-- 该函数使用递归细分对贝塞尔曲线进行采样。您可以使用深度参数控制递归深度。
	--
	-- 如果您只是想知道给定参数的曲线上的位置，请使用 BezierCurve:evaluate。
	--
	-- 参数：
	--  accuracy: 递归细分步骤数。 （默认值：5。）
	--
	-- 返回值：
	--  coordinates: 曲线上 x,y 坐标点对的列表。
	render: function(self: BezierCurve, accuracy?: integer): {number}
	-- 获取曲线特定部分的坐标列表，与 love.graphics.line.
	--
	-- 该函数使用递归细分对贝塞尔曲线进行采样。您可以使用深度参数控制递归深度。
	--
	-- 如果您只需要知道给定参数的曲线上的位置，请使用BezierCurve:evaluate。
	--
	-- 参数：
	--  start: 沿曲线的起点。必须介于 0 和 1 之间。
	--  finish: 要渲染的段的结尾。必须介于 0 和 1 之间。
	--  accuracy: 递归细分步骤数。 （默认值：5。）
	--
	-- 返回值：
	--  coordinates: 曲线指定部分上的点的 x,y 坐标对列表。
	renderSegment: function(self: BezierCurve, start: number, finish: number, accuracy?: integer): {number}
end
-- 提供与系统无关的数学函数。
local record MathModule
	-- 创建一个新的 RandomGenerator 对象，该对象完全独立于其他 RandomGenerator 对象和随机函数。
	--
	-- 重载说明：
	-- 1. 请参阅RandomGenerator:setSeed。
	--
	-- 参数：
	--  low_or_seed: 用于此对象的种子号的低 32 位。
	--  high: 用于此对象的种子号的高 32 位。
	--
	-- 返回值：
	--  rng: 新的随机数生成器对象。
	newRandomGenerator: function(low_or_seed?: number, high?: number): RandomGenerator
	-- 创建一个新的 Transform 对象。
	--
	-- 重载说明：
	-- 1. 创建一个不应用任何变换的变换。对返回的对象调用方法以应用转换。 2. 使用创建时应用的指定变换来创建变换。
	--
	-- 参数：
	--  x: 新变换在 x 轴上的位置。
	--  y: 新变换在 y 轴上的位置。
	--  angle: 新变换的方向（以弧度为单位）。 （默认值：0。）
	--  scale_x: x 轴上的比例因子。 （默认值：1。）
	--  scale_y: y 轴的比例因子。 （默认值：sx。）
	--  origin_x: x 轴上的原点偏移。 （默认值：0。）
	--  origin_y: y 轴上的原点偏移。 （默认值：0。）
	--  shear_x: x 轴上的剪切/倾斜因子。 （默认值：0。）
	--  shear_y: y 轴上的剪切/倾斜因子。 （默认值：0。）
	--
	-- 返回值：
	--  transform: 新的变换对象。
	newTransform: function(x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): Transform
	-- 创建一个新的 BezierCurve 对象。
	--
	-- 控制多边形中的顶点数决定了曲线的阶数，例如三个顶点定义二次（2 次）贝塞尔曲线，四个顶点定义三次（3 次）贝塞尔曲线，等等。
	--
	-- 参数：
	--  vertices_or_coordinates: 控制多边形的顶点作为表格，形式为{x1, y1, x2, y2, x3, y3, ...}。
	--  coordinates: 控制多边形的第一个顶点在 y 轴上的位置。
	--
	-- 返回值：
	--  curve: 贝塞尔曲线对象。
	newBezierCurve: function(vertices_or_coordinates: any, coordinates: number...): BezierCurve
	-- 生成 1-4 维的 Simplex 或 Perlin 噪声值。给定相同的参数，返回值将始终相同。
	--
	-- 单纯形噪声与 Perlin 噪声密切相关。它广泛用于程序内容生成。
	--
	-- 有很多网页详细讨论了 Perlin 和 Simplex 噪声。
	--
	-- 重载说明：
	-- 1. 从一维生成单纯形噪声。 2. 从 2 维生成单纯形噪声。 3. 从 3 个维度生成 Perlin 噪声（0.9.2 及更早版本中的 Simplex 噪声）。 4. 从 4 个维度生成 Perlin 噪声（0.9.2
	-- 及更早版本中的 Simplex 噪声）。
	--
	-- 参数：
	--  x: 用于生成噪声值的数字。取决于过载：用于生成噪声值的二维向量的第一个值。取决于过载：用于生成噪声值的 3 维向量的第一个值。取决于过载：用于生成噪声值的 4 维向量的第一个值。
	--  y: 用于生成噪声值的二维向量的第二个值。取决于过载：用于生成噪声值的 3 维向量的第二个值。取决于过载：用于生成噪声值的 4 维向量的第二个值。
	--  z: 用于生成噪声值的三维向量的第三个值。取决于过载：用于生成噪声值的 4 维向量的第三个值。
	--  w: 用于生成噪声值的 4 维向量的第四个值。
	--
	-- 返回值：
	--  value: 1范围内的噪声值。
	noise: function(x: number, y?: number, z?: number, w?: number): number
	-- 以独立于平台的方式生成伪随机数。默认的 love.run 在启动时为该函数设置种子，因此您通常不需要自己为其设置种子。
	--
	-- 重载说明：
	-- 1. 得到1以内均匀分布的伪随机实数。 2. 得到max以内均匀分布的伪随机整数。 3. 获取max内均匀分布的伪随机整数。
	--
	-- 参数：
	--  lower_or_upper: 它应该返回的最小可能值。
	--  upper: 它应该返回的最大可能值。
	--
	-- 返回值：
	--  number: 伪随机数。取决于过载：伪随机整数。
	random: function(lower_or_upper?: number, upper?: number): number
	-- 获取正态分布的伪随机数。
	--
	-- 参数：
	--  standard_deviation: 分布的标准偏差。 （默认值：1。）
	--  mean: 分布的平均值。 （默认值：0。）
	--
	-- 返回值：
	--  number: 具有方差 (stddev)² 和指定平均值的正态分布随机数。
	randomNormal: function(standard_deviation?: number, mean?: number): number
	-- 使用指定的整数设置随机数生成器的种子。这是在启动时内部调用的，因此您通常不需要自己调用它。
	--
	-- 重载说明：
	-- 1. 由于Lua使用双精度浮点数，无法准确表示2^53以上的整数值。如果您想使用更大的数字，请使用该函数的其他变体。 2. 将两个 32 位整数组合成一个 64 位整数值，并使用该值设置随机数生成器的种子。
	--
	-- 参数：
	--  low_or_seed: 种子值的低 32 位。必须在 2^32 - 1 范围内。
	--  high: 种子值的高 32 位。必须在 2^32 - 1 范围内。
	setRandomSeed: function(low_or_seed: number, high?: number)
	-- 获取随机数生成器的种子。
	--
	-- 由于Lua对所有数值都使用双精度数，因此种子被分成两个数字 - 双精度数无法准确表示大于2^53的整数值，但种子可以是最大2^64的整数值。
	--
	-- 返回值：
	--  low: 表示随机数生成器的 64 位种子值的低 32 位的整数。
	--  high: 表示随机数生成器的 64 位种子值的高 32 位的整数。
	getRandomSeed: function(): number, number
	-- 设置随机数生成器的当前状态。用作此函数参数的值是一个不透明的依赖于实现的字符串，并且只能源自先前对 love.math.getRandomState.
	--
	-- 这与 love.math.setRandomSeed 不同，setRandomState 直接设置随机数生成器的当前依赖于实现的状态，而 setRandomSeed 为其提供新的种子值。
	--
	-- 重载说明：
	-- 1. 状态字符串的效果与当前操作系统无关。
	--
	-- 参数：
	--  state: 随机数生成器的新状态，表示为字符串。这应该源自之前对 love.math.getRandomState.
	setRandomState: function(state: string)
	-- 获取随机数生成器的当前状态。这将返回一个不透明的依赖于实现的字符串，该字符串仅对以后与 love.math.setRandomState 或 RandomGenerator:setState 一起使用有用。
	--
	-- 这与 love.math.getRandomSeed 不同，getRandomState 获取随机数生成器的当前状态，而 getRandomSeed 获取之前设置的种子数。
	--
	-- 重载说明：
	-- 1. 状态字符串的值与当前操作系统无关。
	--
	-- 返回值：
	--  state: 随机数生成器的当前状态，表示为字符串。
	getRandomState: function(): string
	-- 将颜色从 0..1 转换到 0..255 范围。
	--
	-- 重载说明：
	-- 1. 这是 11.2 及更早版本的实现。函数 love.math.colorToBytes(r, g, b, a) if type(r) == 'table' then r, g, b, a = rr[2, rr[4 end
	-- r = 地板(clamp01(r) * 255 + 0.5) g = 地板(clamp01(g) * 255 + 0.5) b = 地板(clamp01(b) * 255 + 0.5) a = a ~= nil and
	-- Floor(clamp01(a) * 255 + 0.5) or nil return r, g, b, a end 其中clamp01定义如下局部函数clamp01(x) return
	-- math.min(math.max(x, 0), 1) end
	--
	-- 参数：
	--  red_or_color: 红色分量。
	--  green: 绿色分量。
	--  blue: 蓝色分量。
	--  alpha: Alpha 颜色分量。 （默认值：无。）
	--
	-- 返回值：
	--  rb: 0..255 范围内的红色分量。
	--  gb: 0..255 范围内的绿色分量。
	--  bb: 0..255 范围内的蓝色分量。
	--  ab: 0..255 范围内的 Alpha 颜色分量，如果未指定 alpha，则为零。
	colorToBytes: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number, number, number | nil
	-- 将颜色从 0..255 转换为 0..1 范围。
	--
	-- 重载说明：
	-- 1. 这是 11.2 及更早版本的实现。函数 love.math.colorFromBytes(r, g, b, a) if type(r) == 'table' then r, g, b, a = rr[2, rr[4
	-- end r = lamp01(floor(r + 0.5) / 255) g =限定器01(floor(g + 0.5) / 255) b =限定器01(floor(b + 0.5) / 255) a = a ~=
	-- nil并且clamp01(floor(a + 0.5) / 255) or nil return r, g, b, a end 其中clamp01定义如下局部函数clamp01(x) return
	-- math.min(math.max(x, 0), 1) end
	--
	-- 参数：
	--  red_or_color: 0..255 范围内的红色分量。
	--  green: 0..255 范围内的绿色分量。
	--  blue: 0..255 范围内的蓝色分量。
	--  alpha: 0..255 范围内的 Alpha 颜色分量。 （默认值：无。）
	--
	-- 返回值：
	--  r: 0..1 范围内的红色分量。
	--  g: 0..1 范围内的绿色分量。
	--  b: 0..1 范围内的蓝色分量。
	--  a: 0..1 范围内的 Alpha 颜色分量，如果未指定 alpha，则为零。
	colorFromBytes: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number, number, number | nil
	-- 将颜色从伽玛空间 (sRGB) 转换为线性空间 (RGB)。这在进行伽马校正渲染时非常有用，并且在 LÖVE 无法自动处理转换的少数情况下，您需要使用线性 RGB 进行数学计算。
	--
	-- 在此处、此处和此处阅读有关伽玛校正渲染的更多信息。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 重载说明：
	-- 1. 可以将 alpha 值作为第四个参数传递到函数中，但它将原封不动地返回，因为 alpha 始终是线性的。
	--
	-- 参数：
	--  red_or_color: 要转换的 sRGB 颜色的红色通道。
	--  green: 要转换的 sRGB 颜色的绿色通道。
	--  blue: 要转换的 sRGB 颜色的蓝色通道。
	--
	-- 返回值：
	--  lr: 线性 RGB 空间中转换颜色的红色通道。
	--  lg: 线性 RGB 空间中转换颜色的绿色通道。
	--  lb: 线性RGB空间中转换颜色的蓝色通道。
	--  lc: 线性RGB空间中颜色通道的值。
	gammaToLinear: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number | nil, number | nil, number | nil
	-- 将颜色从线性空间 (RGB) 转换为伽玛空间 (sRGB)。这在图像中存储线性 RGB 颜色值时非常有用，因为对于深色，线性 RGB 颜色空间的精度低于 sRGB，这可能会导致绘图时出现明显的色带。
	--
	-- 一般来说，根据屏幕上的外观选择的颜色已经在伽马空间中，不应该进行双重转换。使用数学计算的颜色通常位于线性 RGB 空间中。
	--
	-- 在此处、此处和此处阅读有关伽玛校正渲染的更多信息。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 重载说明：
	-- 1. 可以将 alpha 值作为第四个参数传递到函数中，但它将原封不动地返回，因为 alpha 始终是线性的。
	--
	-- 参数：
	--  red_or_color: 要转换的线性 RGB 颜色的红色通道。
	--  green: 要转换的线性 RGB 颜色的绿色通道。
	--  blue: 要转换的线性 RGB 颜色的蓝色通道。
	--
	-- 返回值：
	--  cr: gamma sRGB 空间中转换颜色的红色通道。
	--  cg: gamma sRGB 空间中转换颜色的绿色通道。
	--  cb: gamma sRGB 空间中转换颜色的蓝色通道。
	--  c: gamma sRGB 空间中颜色通道的值。
	linearToGamma: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number): number, number | nil, number | nil, number | nil
	-- 检查多边形是否为凸多边形。
	--
	-- love.physics 中的 PolygonShapes、某些形式的网格以及使用 love.graphics.polygon 绘制的多边形必须是简单的凸多边形。
	--
	-- 参数：
	--  vertices_or_coordinates: 多边形的顶点作为表格，形式为{x1, y1, x2, y2, x3, y3, ...}。
	--  coordinates: 多边形第一个顶点在 y 轴上的位置。
	--
	-- 返回值：
	--  convex: 给定的多边形是否是凸的。
	isConvex: function(vertices_or_coordinates: any, coordinates: number...): boolean
	-- 将简单的凸多边形或凹多边形分解为三角形。
	--
	-- 参数：
	--  vertices_or_coordinates: 用于三角测量的多边形。不得与自身相交。
	--  coordinates: 多边形第一个顶点在 y 轴上的位置。
	--
	-- 返回值：
	--  triangles: 多边形组成的三角形列表，格式为 {{x1, y1, x2, y2, x3, y3}, {x1, y1, x2, y2, x3, y3}, ...}。
	triangulate: function(vertices_or_coordinates: any, coordinates: number...): {{number}}
	compress: function(container: string, format: string, source: any, level?: integer): string | CompressedData
	decompress: function(container: string, format_or_data: any, source?: any): string | ByteData
end
-- 表示文件系统上的一个文件。接受文件路径的函数也可以接受文件。
local record File
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: File): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: File, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: File): boolean
	-- 打开文件进行写入、读取或追加。
	--
	-- 重载说明：
	-- 1. 如果您收到错误消息'Could not set write directory'，请尝试设置保存目录。这可以通过 love.filesystem.setIdentity 或通过在 love.conf
	-- 中设置身份字段来完成（仅适用于 love 0.7 或更高版本）。
	--
	-- 参数：
	--  mode: 打开文件的模式。
	--
	-- 返回值：
	--  ok: 成功则为 true，否则为 false。
	--  err: 发生错误时的错误字符串。
	open: function(self: File, mode: FileMode): boolean | nil, string | nil
	-- 关闭文件。
	--
	-- 返回值：
	--  success: 是否关闭成功。
	close: function(self: File): boolean
	-- 获取文件是否打开。
	--
	-- 返回值：
	--  open: 如果文件当前打开则为 true，否则为 false。
	isOpen: function(self: File): boolean
	-- 返回文件大小。
	--
	-- 返回值：
	--  size: 文件大小（以字节为单位）。
	getSize: function(self: File): number | nil, string | nil
	-- 从文件中读取多个字节。
	--
	-- 重载说明：
	-- 1. 将文件内容读入字符串或 FileData 对象。
	--
	-- 参数：
	--  container_or_size: 返回文件内容的类型。
	--  size: 要读取的字节数。 （默认值：全部。）
	--
	-- 返回值：
	--  contents: 读取字节的内容。取决于重载：FileData 或包含读取字节的字符串。
	--  size: 已读取多少字节。
	read: function(self: File, container_or_size?: string | integer, size?: integer): string | FileData | nil, number | string
	-- 将数据写入文件。
	--
	-- 重载说明：
	--  1. '''Writing to multiple lines''': 在Windows中，某些文本编辑器（例如Windows 10 1809之前的记事本）仅限
	-- 将 CRLF ('\r\n') 视为新行。 --example f = love.filesystem.newFile('note.txt') f:open('w') for i = 1, 10 do
	-- f:write('This is line '..i..'!\r\n') end f:close()
	--
	-- 参数：
	--  data: 要写入的字符串数据。取决于重载：要写入的数据对象。
	--  size: 要写入多少字节。 （默认值：全部。）
	--
	-- 返回值：
	--  success: 操作是否成功。
	--  err: 发生错误时的错误字符串。
	--  errorstr: 发生错误时的错误字符串。
	write: function(self: File, data: string | FileData, size?: integer): boolean | nil, string | nil
	-- 将文件中所有缓冲的写入数据刷新到磁盘。
	--
	-- 返回值：
	--  success: 文件是否成功将任何缓冲数据刷新到磁盘。
	--  err: 错误字符串，如果发生错误并且文件无法刷新。
	flush: function(self: File): boolean | nil, string | nil
	-- 获取是否已到达文件结尾。
	--
	-- 返回值：
	--  eof: 是否已到达EOF。
	isEOF: function(self: File): boolean
	-- 返回文件中的位置。
	--
	-- 返回值：
	--  pos: 当前位置。
	tell: function(self: File): number | nil, string | nil
	-- 查找文件中的位置
	--
	-- 参数：
	--  position: 寻求
	--
	-- 返回值：
	--  success: 操作是否成功
	seek: function(self: File, position: number): boolean
	-- 迭代文件中的所有行。
	--
	-- 返回值：
	--  iterator: 迭代器（可用于 for 循环）。
	lines: function(self: File): function(): string | nil
	-- 设置为写入或追加而打开的文件的缓冲模式。启用缓冲的文件在达到缓冲区大小限制之前不会将数据写入磁盘，具体取决于缓冲模式。
	--
	-- File:flush 将强制将所有缓冲数据写入磁盘。
	--
	-- 参数：
	--  mode: 要使用的缓冲模式。
	--  size: 文件缓冲区的最大大小（以字节为单位）。 （默认值：0。）
	--
	-- 返回值：
	--  success: 缓冲模式是否设置成功。
	--  errorstr: 错误字符串，如果无法设置缓冲模式并且发生错误。
	setBuffer: function(self: File, mode: BufferMode, size?: integer): boolean
	-- 获取文件的缓冲模式。
	--
	-- 返回值：
	--  mode: 文件当前的缓冲模式。
	--  size: 文件缓冲区的最大大小（以字节为单位）。
	getBuffer: function(self: File): BufferMode, integer
	-- 获取打开文件的FileMode。
	--
	-- 返回值：
	--  mode: 此文件打开的模式。
	getMode: function(self: File): FileMode
	-- 获取创建 File 对象时使用的文件名。如果文件对象源自 love.filedropped 回调，则文件名将是完整的与平台相关的文件路径。
	--
	-- 返回值：
	--  filename: 文件的文件名。
	getFilename: function(self: File): string
	getExtension: function(self: File): string
end
local record FileInfo
	type: FileType
	size: number | nil
	modtime: number | nil
end
-- 提供用户文件系统的接口。
local record Filesystem
	-- 设置游戏的写入目录。
	--
	-- 请注意，您只能设置用于存储文件的文件夹名称，而不能设置位置。
	--
	-- 参数：
	--  identity: 将用作写入目录的新标识。
	setIdentity: function(identity: string, append_to_path?: boolean)
	-- 获取游戏的写入目录名称。
	--
	-- 请注意，这仅返回存储文件的文件夹的名称，而不是完整路径。
	--
	-- 返回值：
	--  name: 用作写入目录的标识。
	getIdentity: function(): string
	-- 返回 .love 文件或目录的完整路径。如果游戏融合到 LÖVE 可执行文件，则返回可执行文件。
	--
	-- 返回值：
	--  path: .love 文件或目录的完整平台相关路径。
	getSource: function(): string
	-- 获取指定保存目录的完整路径。
	--
	-- 如果您想使用标准 io 库（或其他库）来
	--
	-- 在保存目录中读取或写入。
	--
	-- 返回值：
	--  dir: 保存目录的绝对路径。
	getSaveDirectory: function(): string
	-- 获取当前工作目录。
	--
	-- 返回值：
	--  cwd: 当前工作目录。
	getWorkingDirectory: function(): string
	-- 返回用户目录
	--
	-- 返回值：
	--  path: 用户目录的路径
	getUserDirectory: function(): string
	-- 返回应用程序数据目录（可能与 getUserDirectory 相同）
	--
	-- 返回值：
	--  path: 应用程序数据目录的路径
	getAppdataDirectory: function(): string
	-- 返回包含 .love 文件的目录的完整路径。如果游戏融合到 LÖVE 可执行文件，则返回包含可执行文件的目录。
	--
	-- 如果 love.filesystem.isFused 为 true，则该函数返回的路径可以传递给 love.filesystem.mount，这将使包含主游戏的目录（例如 C:\Program
	-- Files\coolgame\）可以被 love.filesystem. 读取
	--
	-- 返回值：
	--  path: 包含 .love 文件的目录的完整平台相关路径。
	getSourceBaseDirectory: function(): string
	getExecutablePath: function(): string
	-- 获取包含文件路径的目录的特定于平台的绝对路径。
	--
	-- 这可用于确定文件是否位于保存目录或游戏源.love 内。
	--
	-- 重载说明：
	-- 1. 该函数返回包含给定“'file path'”的目录，而不是文件。例如，如果文件 snapshot1.png 存在于游戏保存目录中名为 snapshots 的目录中，则
	-- love.filesystem.getRealDirectory('screenshots/screenshot1.png') 将返回与 love.filesystem.getSaveDirectory.
	--
	-- 参数：
	--  filename: 要获取目录的文件路径。
	--
	-- 返回值：
	--  realdir: 包含文件路径的目录的特定于平台的完整路径。
	getRealDirectory: function(filename: string): string | nil, string | nil
	-- 获取调用 require 时将搜索的文件系统路径。
	--
	-- 该函数返回的路径字符串是由分号分隔的路径模板序列。传递给 ''require'' will be inserted in place of any question mark ('?') character in each
	-- template (after the dot characters in the argument passed to ''require'' 的参数被目录分隔符替换。）
	--
	-- 路径相对于游戏的源目录和保存目录，以及使用 love.filesystem.mount.
	--
	-- 重载说明：
	-- 1. 默认路径字符串是'?.lua;?/init.lua'，这使得require('cool')尝试加载cool.lua，然后如果cool.lua不存在则尝试cool/init.lua。
	--
	-- 返回值：
	--  paths: ''require''函数将在love的文件系统中检查的路径。
	getRequirePath: function(): string
	-- 设置调用 require 时将搜索的文件系统路径。
	--
	-- 提供给此函数的路径字符串是由分号分隔的路径模板序列。传递给 ''require'' will be inserted in place of any question mark ('?') character in each
	-- template (after the dot characters in the argument passed to ''require'' 的参数被目录分隔符替换。）
	--
	-- 路径相对于游戏的源目录和保存目录，以及使用 love.filesystem.mount.
	--
	-- 重载说明：
	-- 1. 默认路径字符串是'?.lua;?/init.lua'，这使得require('cool')尝试加载cool.lua，然后如果cool.lua不存在则尝试cool/init.lua。
	--
	-- 参数：
	--  path: ''require''函数将在love的文件系统中检查的路径。
	setRequirePath: function(path: string)
	-- 在游戏的保存目录中安装zip文件或文件夹以供读取。
	--
	-- 如果游戏处于融合模式，也可以挂载love.filesystem.getSourceBaseDirectory。
	--
	-- 重载说明：
	-- 1. 将给定 FileData 的内容装载到内存中。 FileData 的数据必须包含压缩的目录结构。 2. 将给定数据对象的内容装载到内存中。数据必须包含压缩目录结构。
	--
	-- 参数：
	--  archive: 游戏保存目录中要挂载的文件夹或zip文件。
	--  mountpoint: 存档将安装到的新路径。
	--  append_to_path: 读取已挂载存档之前或之后的文件路径时是否搜索存档。这包括游戏的源目录和保存目录。 （默认值：假。）
	--
	-- 返回值：
	--  success: 如果存档已成功安装，则为 true，否则为 false。
	mount: function(archive: string | FileData, mountpoint: string, append_to_path?: boolean): boolean
	-- 卸载之前使用 love.filesystem.mount.
	--
	-- 参数：
	--  archive: 当前挂载的游戏保存目录中的文件夹或zip文件。
	--
	-- 返回值：
	--  success: 如果存档已成功卸载，则为 true，否则为 false。
	unmount: function(archive: string | FileData): boolean
	-- 获取游戏是否处于融合模式。
	--
	-- 如果游戏处于融合模式，其保存目录将直接位于Appdata目录中，而不是Appdata/LOVE/中。游戏还能够加载位于保存目录中的 C Lua 动态库。
	--
	-- 如果源 .love 已融合到可执行文件（请参阅游戏分发），或者在启动游戏时将 '--fused' 作为命令行参数给出，则游戏处于融合模式。
	--
	-- 返回值：
	--  fused: 如果游戏处于融合模式则为 true，否则为 false。
	isFused: function(): boolean
	-- 创建一个新的文件对象。
	--
	-- 需要打开才可以访问。
	--
	-- 重载说明：
	-- 1. 请注意，此函数不会返回任何错误消息（例如，如果您使用无效的文件名），因为它只是创建文件对象。您仍然可以使用 File:open 检查文件是否有效，如果打开文件时出现问题，它会返回一个布尔值和一条错误消息。 2.
	-- 创建一个 File 对象并打开它以进行读取、写入或追加。
	--
	-- 参数：
	--  filename: 文件的文件名。
	--  mode: 打开文件的模式。
	--
	-- 返回值：
	--  file: 新的文件对象。取决于重载：新的 File 对象，如果发生错误则为 nil。
	--  errorstr: 发生错误时的错误字符串。
	newFile: function(filename: string, mode?: FileMode): File
	-- 从磁盘上的文件或内存中的字符串创建一个新的 FileData 对象。
	--
	-- 重载说明：
	-- 1. 从内存中的字符串创建一个新的 FileData 对象。 2. 从内存中的 Data 对象创建一个新的 FileData 对象。 3. 从存储设备上的文件创建新的 FileData。
	--
	-- 参数：
	--  data_or_filename_or_file: 内存中文件的内容表示为字符串。根据重载：要复制到新 FileData 对象中的 Data 对象。
	--  filename: 文件名。当将 FileData 对象传递到 love.audio.newSource.
	--
	-- 返回值：
	--  data: 新的文件数据。取决于重载：新的 FileData，如果发生错误则为零。
	--  err: 错误字符串（如果发生错误）。
	newFileData: function(data_or_filename_or_file: string | File, filename?: string): FileData
	-- 读取文件的内容。
	--
	-- 重载说明：
	-- 1. 将文件内容读入字符串或 FileData 对象。
	--
	-- 参数：
	--  container_or_filename: 返回文件内容的类型。
	--  filename_or_size: 文件的名称（和路径）
	--  size: 读取多少字节。 （默认：全部。）取决于过载：读取多少字节（默认：全部。）
	--
	-- 返回值：
	--  contents: 文件内容。根据重载：返回 nil 作为内容。取决于重载：FileData 或包含文件内容的字符串。
	--  size: 已读取多少字节。
	--  error: 返回错误消息。
	read: function(container_or_filename: string, filename_or_size?: string | integer, size?: integer): string | FileData | nil, number | string
	-- 加载 Lua 文件（但不运行它）。
	--
	-- 参数：
	--  filename: 文件的名称（和路径）。
	--
	-- 返回值：
	--  chunk: 加载的块。
	--  errormsg: 文件无法打开时的错误消息。
	load: function(filename: string): function | nil, string | nil
	-- 迭代文件中的行。
	--
	-- 参数：
	--  filename: 文件的名称（和路径）
	--
	-- 返回值：
	--  iterator: 迭代文件
	lines: function(filename: string): function(): string | nil
	-- 将数据写入保存目录中的文件。如果该文件已经存在，它将被新内容完全替换。
	--
	-- 重载说明：
	-- 1. 如果您收到错误消息'Could not set write directory'，请尝试设置保存目录。这可以通过 love.filesystem.setIdentity 或通过在 love.conf.
	-- '''Writing to
	--     multiple lines''': 在 Windows 中，某些文本编辑器（例如记事本）仅将 CRLF ('\r\n') 视为新行。
	--
	-- 参数：
	--  filename: 文件的名称（和路径）。
	--  data: 要写入文件的字符串数据。根据重载：要写入文件的数据对象。
	--  size: 要写入多少字节。 （默认值：全部。）
	--
	-- 返回值：
	--  success: 如果操作成功。
	--  message: 如果操作不成功，则会出现错误消息。
	write: function(filename: string, data: string | FileData, size?: integer): boolean, string | nil
	-- 将数据附加到现有文件。
	--
	-- 参数：
	--  filename: 文件的名称（和路径）。
	--  data: 要附加到文件的字符串数据。根据重载：要附加到文件的数据对象。
	--  size: 要写入多少字节。 （默认值：全部。）
	--
	-- 返回值：
	--  success: 如果操作成功则为 True，如果有错误则为 nil。
	--  errormsg: 失败时的错误消息。
	append: function(filename: string, data: string | FileData, size?: integer): boolean, string | nil
	-- 获取有关指定文件或目录的信息。
	--
	-- 重载说明：
	-- 1. 此变体接受现有表进行填充，而不是创建新表。 2. 仅当给定路径中的项目与 filtertype 参数中指定的文件类型相同时，此变体才返回信息，并接受现有表进行填充，而不是创建新表。
	--
	-- 参数：
	--  filename: 要检查的文件或目录路径。
	--  filter_type: 如果提供，此参数将导致 getInfo 仅在给定路径中的项目与指定文件类型匹配时返回信息表。 （默认值：nil。）取决于重载：如果给定路径中的项目与指定的文件类型匹配，则导致 getInfo
	--               仅返回信息表。
	--
	-- 返回值：
	--  info: 包含有关指定路径的信息的表，如果路径中不存在任何内容，则返回 nil。该表包含以下字段： 取决于重载：作为参数给出的表，如果路径中不存在任何内容，则为 nil。该表将填写以下字段：
	getInfo: function(filename: string, filter_type?: FileType): FileInfo | nil
	exists: function(filename: string): boolean
	isDirectory: function(filename: string): boolean
	isFile: function(filename: string): boolean
	isSymlink: function(filename: string): boolean
	getLastModified: function(filename: string): number | nil, string | nil
	getSize: function(filename: string): number | nil, string | nil
	-- 递归创建一个目录。
	--
	-- 当使用 'a/b' 调用时，它会创建 'a' 和 'a/b'（如果它们尚不存在）。
	--
	-- 参数：
	--  name: 要创建的目录。
	--
	-- 返回值：
	--  success: 如果目录已创建则为 True，否则为 false。
	createDirectory: function(name: string): boolean, string | nil
	-- 删除文件或空目录。
	--
	-- 重载说明：
	-- 1. 删除前目录必须为空，否则会失败。只需事先删除目录中的所有文件和文件夹即可。如果文件存在于 .love 但不存在于保存目录中，它也会返回 false。打开的文件会阻止删除底层文件。只需关闭文件即可将其删除。
	--
	-- 参数：
	--  name: 要删除的文件或目录。
	--
	-- 返回值：
	--  success: 如果文件/目录被删除则为 true，否则为 false。
	remove: function(name: string): boolean, string | nil
	-- 返回一个表，其中包含指定路径中的文件和子目录的名称。该表未以任何方式排序；顺序未定义。
	--
	-- 如果传递给函数的路径存在于游戏和保存目录中，它将列出两个地方的文件和目录。
	--
	-- 参数：
	--  directory: 目录。
	--
	-- 返回值：
	--  files: 以字符串形式包含所有文件和子目录名称的序列。
	getDirectoryItems: function(directory?: string): {string}
end

local type QuitCallback = function(): boolean | nil

-- 提供用户键盘的接口。
local record Keyboard
	-- 启用或禁用 love.keypressed. 的按键重复 默认情况下禁用。
	--
	-- 重载说明：
	-- 1. 重复之间的间隔取决于用户的系统设置。此函数不会影响按住某个键时是否多次调用 love.textinput 。
	--
	-- 参数：
	--  enabled: 按住某个键时是否应启用重复按键事件。
	setKeyRepeat: function(enabled: boolean)
	-- 获取是否启用按键重复。
	--
	-- 返回值：
	--  enabled: 是否启用按键重复。
	hasKeyRepeat: function(): boolean
	-- 检查某个键是否按下。不要与 love.keypressed 或 love.keyreleased.
	--
	-- 参数：
	--  keys: 包含要检查的键的表。
	--
	-- 返回值：
	--  down: 如果按键按下则为 True，否则为 false。
	--  anyDown: 如果提供的任何键按下则为 true，否则为 false。取决于过载：如果表中的任何键已关闭，则为 true，否则为 false。
	isDown: function(keys: string...): boolean
	-- 检查指定的扫描码是否被按下。不要与 love.keypressed 或 love.keyreleased.
	--
	-- 与常规的 KeyConstants 不同，扫描码与键盘布局无关。如果按下与美式键盘上的 'w' 键相同位置的键，则使用扫描码 'w'，无论该键的标签是什么或用户的操作系统设置是什么。
	--
	-- 参数：
	--  scancodes: 要检查的扫描码。
	--
	-- 返回值：
	--  down: 如果提供的任何扫描码已关闭，则为 True，否则为 false。
	isScancodeDown: function(scancodes: string...): boolean
	-- 获取给定按键对应的硬件扫描码。
	--
	-- 与按键常量不同，扫描码与键盘布局无关。例如，如果按下与美式键盘上的 'w' 键相同位置的键，则无论该键的标签是什么或用户的操作系统设置是什么，都会生成扫描码 'w' 。
	--
	-- 扫描码对于创建在所有系统上具有相同物理位置的默认控件非常有用。
	--
	-- 参数：
	--  key: 获取扫描码的密钥。
	--
	-- 返回值：
	--  scancode: 与给定键对应的扫描码，如果给定键在当前系统上没有已知的物理表示，则为 'unknown' 。
	getScancodeFromKey: function(key: string): string
	-- 获取与给定硬件扫描码对应的密钥。
	--
	-- 与按键常量不同，扫描码与键盘布局无关。例如，如果按下与美式键盘上的 'w' 键相同位置的键，则无论该键的标签是什么或用户的操作系统设置是什么，都会生成扫描码 'w' 。
	--
	-- 扫描码对于创建在所有系统上具有相同物理位置的默认控件非常有用。
	--
	-- 参数：
	--  scancode: 用于获取密钥的扫描码。
	--
	-- 返回值：
	--  key: 与给定扫描码相对应的键，如果扫描码未映射到当前系统上的 KeyConstant，则为 'unknown' 。
	getKeyFromScancode: function(scancode: string): string
	-- 启用或禁用文本输入事件。它在 Windows、Mac 和 Linux 上默认启用，在 iOS 和 Android 上默认禁用。
	--
	-- 在触摸设备上，这会在启用时显示系统的本机屏幕键盘。
	--
	-- 重载说明：
	-- 1. 在 iOS 和 Android 上，此变体告诉操作系统指定的矩形是游戏中显示文本的位置，这会阻止系统屏幕键盘覆盖文本。
	--
	-- 参数：
	--  enabled: 是否应启用文本输入事件。
	--  x: 文本矩形 x 位置。
	--  y: 文本矩形 y 位置。
	--  width: 文本矩形宽度。
	--  height: 文本矩形高度。
	setTextInput: function(enabled: boolean, x?: number, y?: number, width?: number, height?: number)
	-- 获取是否启用文本输入事件。
	--
	-- 返回值：
	--  enabled: 是否启用文本输入事件。
	hasTextInput: function(): boolean
	-- 获取是否支持屏幕键盘。
	--
	-- 返回值：
	--  supported: 是否支持屏幕键盘。
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

-- 代表硬件光标。
local record Cursor
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Cursor): boolean
	-- 获取光标的类型。
	--
	-- 返回值：
	--  ctype: 光标的类型。
	getType: function(self: Cursor): CursorType
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Cursor): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Cursor, type_name: string): boolean
end

-- 提供用户鼠标的接口。
local record Mouse
	-- 返回鼠标的当前位置。
	--
	-- 返回值：
	--  x: 鼠标沿 x 轴的位置。
	--  y: 鼠标沿 y 轴的位置。
	getPosition: function(): number, number
	-- 返回鼠标当前的 x 位置。
	--
	-- 返回值：
	--  x: 鼠标沿 x 轴的位置。
	getX: function(): number
	-- 返回鼠标当前的 y 位置。
	--
	-- 返回值：
	--  y: 鼠标沿 y 轴的位置。
	getY: function(): number
	-- 设置鼠标的当前位置。非整数值被下限。
	--
	-- 参数：
	--  x: 鼠标沿 x 轴的新位置。
	--  y: 鼠标沿 y 轴的新位置。
	setPosition: function(x: number, y: number)
	-- 设置鼠标当前的 X 位置。
	--
	-- 非整数值被下限。
	--
	-- 参数：
	--  x: 鼠标沿 x 轴的新位置。
	setX: function(x: number)
	-- 设置鼠标当前的 Y 位置。
	--
	-- 非整数值被下限。
	--
	-- 参数：
	--  y: 鼠标沿 y 轴的新位置。
	setY: function(y: number)
	-- 检查某个鼠标按钮是否按下。
	--
	-- 该函数不检测鼠标滚轮滚动；您必须使用 love.wheelmoved （或 0.9.2 及更早版本中的 love.mousepressed ）回调。
	--
	-- 参数：
	--  buttons: 要检查的按钮的索引。 1 是鼠标主按钮，2 是鼠标辅助按钮，3 是中间按钮。其他按钮取决于鼠标。
	--
	-- 返回值：
	--  down: 如果任何指定的按钮被按下，则为真。
	isDown: function(buttons: integer | {integer}, ...: integer): boolean
	-- 设置光标的当前可见性。
	--
	-- 参数：
	--  visible: true 将光标设置为可见， false 将隐藏光标。
	setVisible: function(visible: boolean)
	-- 检查光标是否可见。
	--
	-- 返回值：
	--  visible: 如果光标可见则为 true，如果光标隐藏则为 false。
	isVisible: function(): boolean
	-- 抓住鼠标并将其限制在窗口内。
	--
	-- 参数：
	--  grabbed: True 限制鼠标，False 让它离开窗口。
	setGrabbed: function(grabbed: boolean)
	-- 检查鼠标是否被抓住。
	--
	-- 返回值：
	--  grabbed: 如果光标被抓取则为 true，否则为 false。
	isGrabbed: function(): boolean
	-- 设置鼠标是否启用相对模式。
	--
	-- 当启用相对模式时，光标被隐藏，并且在鼠标移动时不会移动，但仍然通过 love.mousemoved. 生成相对鼠标运动事件，这使得鼠标可以无限期地向任何方向移动，而光标不会卡在屏幕边缘。
	--
	-- 在启用相对模式时，即使生成了相对鼠标运动事件，报告的鼠标位置也可能不会更新。
	--
	-- 参数：
	--  relative: true 则启用相对模式， false 则禁用它。
	setRelativeMode: function(relative: boolean): boolean
	-- 获取鼠标是否启用相对模式。
	--
	-- 如果启用相对模式，光标将被隐藏，并且在鼠标移动时不会移动，但仍然通过 love.mousemoved. 生成相对鼠标运动事件，这使鼠标可以无限期地向任何方向移动，而光标不会卡在屏幕边缘。
	--
	-- 在启用相对模式时，即使生成了相对鼠标运动事件，报告的鼠标位置也不会更新。
	--
	-- 返回值：
	--  enabled: 如果启用相对模式则为 True，如果禁用则为 false。
	getRelativeMode: function(): boolean
	-- 从图像文件或 ImageData 创建新的硬件 Cursor 对象。
	--
	-- 硬件光标与帧速率无关，并且与普通操作系统光标的工作方式相同。与在鼠标的当前坐标处绘制图像不同，即使在低帧速率下，硬件光标在鼠标移动和光标位置更新之间也不会出现明显的滞后。
	--
	-- 热点是操作系统用来确定单击的内容以及鼠标光标所在位置的点。例如，普通箭头指针通常将其热点放在图像的左上角，但十字光标可能将其放在中间。
	--
	-- 参数：
	--  image: 用于新 Cursor 的 ImageData。根据重载：用于新光标的图像路径。取决于重载：表示用于新光标的图像的数据。
	--  hot_x: 光标热点的 ImageData 中的 x 坐标。 （默认值：0。）取决于重载：光标热点图像中的 x 坐标。 （默认值：0。）
	--  hot_y: 光标热点的 ImageData 中的 y 坐标。 （默认值：0。）取决于过载：光标热点图像中的 y 坐标。 （默认值：0。）
	--
	-- 返回值：
	--  cursor: 新的 Cursor 对象。
	newCursor: function(image: ImageData | FileData | string, hot_x?: integer, hot_y?: integer): Cursor
	-- 获取表示系统本机硬件光标的 Cursor 对象。
	--
	-- 硬件光标与帧速率无关，并且与普通操作系统光标的工作方式相同。与在鼠标的当前坐标处绘制图像不同，即使在低帧速率下，硬件光标在鼠标移动和光标位置更新之间也不会出现明显的滞后。
	--
	-- 重载说明：
	-- 1. 'image' CursorType 不是有效参数。使用 love.mouse.newCursor 使用自定义图像创建硬件光标。
	--
	-- 参数：
	--  cursor_type: 要获取的系统光标的类型。
	--
	-- 返回值：
	--  cursor: 表示系统游标类型的 Cursor 对象。
	getSystemCursor: function(cursor_type: SystemCursor): Cursor
	-- 设置当前鼠标光标。
	--
	-- 重载说明：
	-- 1. 将当前鼠标光标重置为默认值。
	--
	-- 参数：
	--  cursor: 用作当前鼠标光标的 Cursor 对象。
	setCursor: function(cursor?: Cursor)
	-- 获取当前光标。
	--
	-- 返回值：
	--  cursor: 当前光标，如果未设置光标则为零。
	getCursor: function(): Cursor | nil
	-- 获取是否支持光标功能。
	--
	-- 如果不支持，调用 love.mouse.newCursor 和 love.mouse.getSystemCursor 会出错。移动设备不支持光标。
	--
	-- 返回值：
	--  supported: 系统是否有光标功能。
	isCursorSupported: function(): boolean
end

-- 提供用户时钟的接口。
local record Timer
	-- 测量两帧之间的时间。
	--
	-- 调用此函数会更改 love.timer.getDelta.
	--
	-- 返回值：
	--  dt: 过去的时间（以秒为单位）。
	step: function(): number
	-- 返回最后两帧之间的时间。
	--
	-- 返回值：
	--  dt: 过去的时间（以秒为单位）。
	getDelta: function(): number
	-- 返回当前每秒帧数。
	--
	-- 返回值：
	--  fps: 当前的 FPS。
	getFPS: function(): integer
	-- 返回最后一秒的平均增量时间（每帧秒数）。
	--
	-- 返回值：
	--  delta: 最后一秒的平均增量时间。
	getAverageDelta: function(): number
	-- 将当前线程暂停指定的时间。
	--
	-- 参数：
	--  seconds: 还需要睡觉几秒。
	sleep: function(seconds: number)
	-- 返回未指定起始时间的计时器的值。
	--
	-- 该函数只能用于计算时间点之间的差异，因为计时器的启动时间未知。
	--
	-- 返回值：
	--  time: 时间以秒为单位。以十进制形式给出，精确到微秒。
	getTime: function(): number
end

-- 提供对有关用户系统的信息的访问。
local record System
	-- 获取当前操作系统。一般来说，LÖVE 抽象了了解当前操作系统的需要，但在某些情况下它可能很有用（特别是与 os.execute 结合使用。）
	--
	-- 重载说明：
	-- 1. 在LÖVE 0.8.0 版本中，“'love._os'”字符串包含当前操作系统。
	--
	-- 返回值：
	--  osString: 当前操作系统。 'OS X'、'Windows'、'Linux'、'Android' 或 'iOS'。
	getOS: function(): string
	-- 获取系统中逻辑处理器的数量。
	--
	-- 重载说明：
	-- 1. 该数字包括启用英特尔超线程等技术时报告的线程数。例如，在具有超线程的 4 核 CPU 上，此函数将返回 8。
	--
	-- 返回值：
	--  processorCount: 逻辑处理器的数量。
	getProcessorCount: function(): integer
	-- 将文本放入剪贴板。
	--
	-- 参数：
	--  text: 要保存在系统剪贴板中的新文本。
	setClipboardText: function(text: string)
	-- 从剪贴板获取文本。
	--
	-- 返回值：
	--  text: 当前保存在系统剪贴板中的文本。
	getClipboardText: function(): string
	-- 获取有关系统电源的信息。
	--
	-- 返回值：
	--  state: 电源的基本状态。
	--  percent: 剩余电池寿命百分比，介于 0 和 100 之间。如果无法确定该值或没有电池，则为零。
	--  seconds: 电池寿命还剩几秒。如果无法确定该值或没有电池，则为零。
	getPowerInfo: function(): string, integer | nil, integer | nil
	-- 使用用户的 Web 或文件浏览器打开 URL。
	--
	-- 重载说明：
	-- 1. 在 Android 7.0 (Nougat) 及更高版本中传递 file:// 方案总是会导致失败。在 11.2 之前，这会使 LÖVE 崩溃而不是返回 false。
	--
	-- 参数：
	--  url: 要打开的 URL。必须格式化为正确的 URL。
	--
	-- 返回值：
	--  success: URL是否打开成功。
	openURL: function(url: string): boolean
	-- 如果可能的话，使设备振动。目前，这仅适用于具有内置振动电机的 Android 和 iOS 设备。
	--
	-- 参数：
	--  seconds: 振动的持续时间。如果在iOS设备上调用，由于iOS系统API的限制，它总是会振动0.5秒。 （默认值：0.5。）
	vibrate: function(seconds?: number)
	-- 获取系统上的另一个应用程序是否正在后台播放音乐。
	--
	-- 目前这是在 iOS 和 Android 上实现的，并且在其他操作系统上将始终返回 false。 love.conf 中的 t.audio.mixwithsystem 标志可用于配置 LÖVE
	-- 打开时是否应播放其他应用程序的背景音频/音乐。
	--
	-- 返回值：
	--  backgroundmusic: 如果用户通过另一个应用程序在后台播放音乐，则为 true，否则为 false。
	hasBackgroundMusic: function(): boolean
end

-- 线程是可以与其他线程并行运行的代码块。可以使用 Channel 对象在不同线程之间发送数据。
local record Thread
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Thread): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Thread): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Thread, type_name: string): boolean
	-- 启动线程。
	--
	-- 从0.9.0版本开始，线程可以在执行完成后重新启动。
	--
	-- 重载说明：
	-- 1. 传递给 Thread:start 的参数可以通过“'...'”（可变参数表达式）在线程的主文件中访问。
	--
	-- 参数：
	--  args: 字符串、数字、布尔值、LÖVE 对象或简单表格。
	start: function(self: Thread, args: any...): boolean
	-- 等待线程完成。
	--
	-- 该调用将阻塞，直到线程完成。
	wait: function(self: Thread)
	-- 如果线程产生错误，则从线程中检索错误字符串。
	--
	-- 返回值：
	--  err: 错误消息，如果线程没有引起错误则为零。
	getError: function(self: Thread): string | nil
	-- 返回线程当前是否正在运行。
	--
	-- 未运行的线程可以用Thread:start（重新）启动。
	--
	-- 返回值：
	--  value: 如果线程正在运行则为 true，否则为 false。
	isRunning: function(self: Thread): boolean
end

-- 可用于在不同线程之间发送和接收数据的对象。
local record Channel
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Channel): boolean
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Channel): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Channel, type_name: string): boolean
	-- 向线程Channel发送消息。
	--
	-- 有关受支持类型的列表，请参阅变体。
	--
	-- 参数：
	--  value: 消息的内容。
	--
	-- 返回值：
	--  id: 可以提供给Channel:hasRead
	push: function(self: Channel, value: any): number
	-- 向线程Channel发送消息并等待线程接受它。
	--
	-- 有关受支持类型的列表，请参阅变体。
	--
	-- 参数：
	--  value: 消息的内容。
	--  timeout: 等待的最长时间。
	--
	-- 返回值：
	--  success: 消息是否已成功提供（始终为真）。取决于过载：在超时到期之前消息是否成功提供。
	supply: function(self: Channel, value: any, timeout?: number): boolean
	-- 检索 Channel 消息的值并将其从消息队列中删除。
	--
	-- 如果队列中没有消息，则返回 nil。
	--
	-- 返回值：
	--  value: 消息的内容。
	pop: function(self: Channel): any
	-- 检索 Channel 消息的值并将其从消息队列中删除。
	--
	-- 它会等待消息进入队列，然后返回消息值。
	--
	-- 参数：
	--  timeout: 等待的最长时间。
	--
	-- 返回值：
	--  value: 消息的内容。取决于过载：消息的内容或 nil（如果超时）。
	demand: function(self: Channel, timeout?: number): any
	-- 检索 Channel 消息的值，但将其保留在队列中。
	--
	-- 如果队列中没有消息，则返回 nil。
	--
	-- 返回值：
	--  value: 消息的内容。
	peek: function(self: Channel): any
	-- 检索线程 Channel 队列中的消息数。
	--
	-- 返回值：
	--  count: 队列中的消息数。
	getCount: function(self: Channel): integer
	-- 获取推送的值是否已被弹出或以其他方式从通道中删除。
	--
	-- 参数：
	--  id: Channel:push 之前返回的 id 值。
	--
	-- 返回值：
	--  hasread: id 表示的值是否已通过 Channel:pop、Channel:demand 或 Channel:clear 从 Channel 中删除。
	hasRead: function(self: Channel, id: number): boolean
	-- 清除Channel队列中的所有消息。
	clear: function(self: Channel)
	-- 相对于此 Channel 以原子方式执行指定的函数。
	--
	-- 在同一个 Channel 上连续调用多个方法通常很有用。但是，如果多个线程同时调用此 Channel 的方法，则每个线程上的不同调用可能最终会交错（例如，第二个线程的一个或多个调用可能发生在第一个线程的调用之间。）
	--
	-- 此方法通过确保调用该方法的线程在指定函数返回之前具有对 Channel 的独占访问权来避免该问题。
	--
	-- 参数：
	--  callback: 要调用的函数，形式为 function(channel, arg1, arg2, ...) end。调用函数时，通道将作为第一个参数传递给该函数。
	--  args: 调用给定函数时将收到的附加参数。
	--
	-- 返回值：
	--  ret1: 给定函数的第一个返回值（如果有）。
	--  ...: 任何其他返回值。
	performAtomic: function(self: Channel, callback: any, args: any...): any
end

-- 允许您使用线程。
local record ThreadModule
	-- 从包含 Lua 代码的文件名、字符串或 FileData 对象创建一个新线程。
	--
	-- 参数：
	--  code_or_filename: 用作源的 Lua 文件的名称。取决于重载：包含用作源的 Lua 代码的 FileData。取决于重载：包含用作源的 Lua 代码的字符串。它的长度至少需要 1024
	--                    个字符，或者至少包含一个换行符。
	--
	-- 返回值：
	--  thread: 尚未启动的新线程。
	newThread: function(code_or_filename: string | any): Thread
	-- 创建一个新的未命名线程通道。
	--
	-- 它们的一种用途是通过命名通道上的 Channel:push 将新的未命名通道传递到其他线程。
	--
	-- 返回值：
	--  channel: 新的 Channel 对象。
	newChannel: function(): Channel
	-- 创建或检索命名线程通道。
	--
	-- 参数：
	--  name: 您要创建或检索的频道的名称。
	--
	-- 返回值：
	--  channel: 与名称关联的 Channel 对象。
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

-- Source 代表您可以播放的音频。
local record Source
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Source): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Source, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Source): boolean
	-- 创建处于停止状态的源的相同副本。
	--
	-- 静态源将使用显着更少的内存，并且创建它们所需的时间也更少，因此在制作播放相同声音的多个源时应首选此方法。
	--
	-- 重载说明：
	-- 1. 克隆源继承原始源的所有可设置状态，但它们被初始化为停止状态。
	--
	-- 返回值：
	--  source: 此源的新的相同副本。
	clone: function(self: Source): Source
	-- 开始播放源。
	--
	-- 返回值：
	--  success: Source是否能够成功开始播放。
	play: function(self: Source): boolean
	-- 暂停源。
	pause: function(self: Source)
	-- 停止源。
	stop: function(self: Source)
	-- 返回源是否正在播放。
	--
	-- 返回值：
	--  playing: 如果源正在播放则为 true，否则为 false。
	isPlaying: function(self: Source): boolean
	-- 返回此 Source 是否处于停止状态。此方法是兼容旧版 LÖVE 的废弃接口，仅当 Source 既未播放也未暂停时返回 true。
	isStopped: function(self: Source): boolean
	isPaused: function(self: Source): boolean
	-- 设置源是否应循环。
	--
	-- 参数：
	--  looping: 如果源应该循环则为 true，否则为 false。
	setLooping: function(self: Source, looping: boolean)
	-- 返回 Source 是否循环。
	--
	-- 返回值：
	--  loop: 如果源将循环则为 true，否则为 false。
	isLooping: function(self: Source): boolean
	-- 设置源的当前音量。
	--
	-- 参数：
	--  volume: 源的音量，其中 1.0 是正常音量。音量不能调高到 1.0 以上。
	setVolume: function(self: Source, volume: number)
	-- 获取源的当前音量。
	--
	-- 返回值：
	--  volume: 源的音量，其中 1.0 是正常音量。
	getVolume: function(self: Source): number
	-- 设置源的音高。
	--
	-- 参数：
	--  pitch: 以 1 为基距计算。每降低 50% 就等于音高移动 -12 个半音（降低一个八度）。每次加倍等于音高移动 12 个半音（增加一个八度）。零不是合法值。
	setPitch: function(self: Source, pitch: number)
	-- 获取源的当前音高。
	--
	-- 返回值：
	--  pitch: 音高，其中 1.0 为正常值。
	getPitch: function(self: Source): number
	-- 设置源的当前播放位置。
	--
	-- 参数：
	--  offset: 要寻求的位置。
	--  unit: 位置值的单位。 （默认：'seconds'。）
	seek: function(self: Source, offset: number, unit?: string)
	-- 获取Source 当前的播放位置。
	--
	-- 参数：
	--  unit: 返回值的单位类型。 （默认：'seconds'。）
	--
	-- 返回值：
	--  position: 源的当前播放位置。
	tell: function(self: Source, unit?: string): number
	-- 获取源的持续时间。对于流源，它可能并不总是样本准确的，并且如果根本无法确定持续时间，则可能返回 -1。
	--
	-- 参数：
	--  unit: 返回值的时间单位。 （默认：'seconds'。）
	--
	-- 返回值：
	--  duration: 源的持续时间，如果无法确定则为 -1。
	getDuration: function(self: Source, unit?: string): number
	-- 获取源中的通道数。只有 1 通道（单声道）源可以使用方向和位置效果。
	--
	-- 返回值：
	--  channels: 1 用于单声道，2 用于立体声。
	getChannelCount: function(self: Source): integer
	getChannels: function(self: Source): integer
	-- 获取可排队源中的空闲缓冲区槽数。如果可排队源正在播放，则该值将增加到创建源时所用的数量。如果可排队源停止，它将首先处理其所有内部缓冲区，在这种情况下，该函数将始终返回其创建时所用的数量。
	--
	-- 返回值：
	--  buffers: 还有多少个 SoundData 对象可以排队。
	getFreeBufferCount: function(self: Source): integer
	-- 将 SoundData 排队以便在可排队源中播放。
	--
	-- 此方法需要通过 love.audio.newQueueableSource. 创建源
	--
	-- 参数：
	--  data: 要排队的数据。 SoundData 的采样率、位深度和通道数必须与 Source 相匹配。
	--
	-- 返回值：
	--  success: 如果数据已成功排队播放，则为 true；如果没有可用于排队的可用缓冲区，则为 false。
	queue: function(self: Source, data: SoundData, offset_or_length?: number, length?: number): boolean
	-- 设置源的位置。请注意，这仅适用于单声道（即非立体声）声音文件！
	--
	-- 参数：
	--  x: 源的 X 位置。
	--  y: 源的 Y 位置。
	--  z: 源的 Z 位置。
	setPosition: function(self: Source, x: number, y: number, z?: number)
	-- 获取源的位置。
	--
	-- 返回值：
	--  x: 源的 X 位置。
	--  y: 源的 Y 位置。
	--  z: 源的 Z 位置。
	getPosition: function(self: Source): number, number, number
	-- 设置源的速度。
	--
	-- 这确实“'not'”改变了源的位置，但让应用程序知道它如何计算多普勒效应。
	--
	-- 参数：
	--  x: 速度矢量的 X 部分。
	--  y: 速度矢量的 Y 部分。
	--  z: 速度矢量的 Z 部分。
	setVelocity: function(self: Source, x: number, y: number, z?: number)
	-- 获取源的速度。
	--
	-- 返回值：
	--  x: 速度矢量的 X 部分。
	--  y: 速度矢量的 Y 部分。
	--  z: 速度矢量的 Z 部分。
	getVelocity: function(self: Source): number, number, number
	-- 设置源的方向向量。零矢量使源无方向性。
	--
	-- 参数：
	--  x: 方向向量的X部分。
	--  y: 方向向量的Y部分。
	--  z: 方向向量的 Z 部分。
	setDirection: function(self: Source, x: number, y: number, z?: number)
	-- 获取源的方向。
	--
	-- 返回值：
	--  x: 方向向量的X部分。
	--  y: 方向向量的Y部分。
	--  z: 方向向量的 Z 部分。
	getDirection: function(self: Source): number, number, number
	-- 设置源的定向体积锥体。与 Source:setDirection 一起，锥角允许源的体积根据其方向而变化。
	--
	-- 参数：
	--  inner_angle: 与源方向的内角，以弧度为单位。如果听者位于此角度定义的圆锥体内，则源将以正常音量播放。
	--  outer_angle: 与源方向的外角，以弧度为单位。如果听者位于由内角和外角定义的锥体之间，则源将以正常音量和外音量之间的音量播放。
	--  outer_volume: 当听者位于内锥角和外锥角之外时源的音量。 （默认值：0。）
	setCone: function(self: Source, inner_angle: number, outer_angle: number, outer_volume?: number, outer_high_gain?: number)
	-- 获取源的定向体积锥体。与 Source:setDirection 一起，锥角允许源的体积根据其方向而变化。
	--
	-- 返回值：
	--  innerAngle: 与源方向的内角，以弧度为单位。如果听者位于此角度定义的圆锥体内，则源将以正常音量播放。
	--  outerAngle: 与源方向的外角，以弧度为单位。如果听者位于由内角和外角定义的锥体之间，则源将以正常音量和外音量之间的音量播放。
	--  outerVolume: 当听者位于内锥角和外锥角之外时源的音量。
	getCone: function(self: Source): number, number, number, number
	-- 设置应用于源的空气吸收量。
	--
	-- 默认情况下，该值设置为 0，这意味着空气吸收效果被禁用。值为 1 将以每米 0.05 dB 的速率对源应用高频衰减。
	--
	-- 空气吸收可以模拟声音在雾气、干燥空气、烟雾气氛等中的传播。它可以用来模拟一个区域内不同地点的不同大气条件。
	--
	-- 重载说明：
	-- 1. iOS 不支持音频空气吸收功能。
	--
	-- 参数：
	--  factor: 应用于源的空气吸收量。必须介于 0 和 10 之间。
	setAirAbsorption: function(self: Source, factor: number)
	-- 获取应用于源的空气吸收量。
	--
	-- 默认情况下，该值设置为 0，这意味着空气吸收效果被禁用。值为 1 将以每米 0.05 dB 的速率对源应用高频衰减。
	--
	-- 重载说明：
	-- 1. iOS 不支持音频空气吸收功能。
	--
	-- 返回值：
	--  amount: 应用于源的空气吸收量。
	getAirAbsorption: function(self: Source): number
	-- 设置源的音量限制。限制必须是 0 到 1 之间的数字。
	--
	-- 参数：
	--  min_volume: 最小音量。
	--  max_volume: 最大音量。
	setVolumeLimits: function(self: Source, min_volume: number, max_volume: number)
	-- 返回源的音量限制。
	--
	-- 返回值：
	--  min: 最小音量。
	--  max: 最大音量。
	getVolumeLimits: function(self: Source): number, number
	-- 设置源的位置、速度、方向和锥角是相对于听者的还是绝对的。
	--
	-- 默认情况下，所有源都是绝对源，因此相对于爱的坐标系 0, 0 的原点。只有绝对源才会受到听者位置的影响。请注意，位置音频仅适用于单声道（即非立体声）源。
	--
	-- 参数：
	--  relative: True 使位置、速度、方向和锥角相对于听者，为 false 使它们绝对。 （默认值：假。）
	setRelative: function(self: Source, relative: boolean)
	-- 获取Source 的位置、速度、方向和锥角是否相对于听者。
	--
	-- 返回值：
	--  relative: 如果位置、速度、方向和锥角是相对于听者的，则为 true；如果是绝对的，则为 false。
	isRelative: function(self: Source): boolean
	-- 设置源的参考距离和最大衰减距离。这些参数与当前的 DistanceModel 相结合，会影响源的音量如何根据距离衰减。
	--
	-- 距离衰减仅适用于基于单声道（而不是立体声）音频的源。
	--
	-- 参数：
	--  reference_distance: 新的参考衰减距离。如果当前距离模型被钳位，则这是最小衰减距离。
	--  max_distance: 新的最大衰减距离。
	setAttenuationDistances: function(self: Source, reference_distance: number, max_distance: number)
	-- 获取源的参考距离和最大衰减距离。这些值与当前的 DistanceModel 相结合，会影响源的音量如何根据距收听者的距离衰减。
	--
	-- 返回值：
	--  ref: 当前参考衰减距离。如果当前距离模型被钳制，则这是源不再衰减之前的最小距离。
	--  max: 当前最大衰减距离。
	getAttenuationDistances: function(self: Source): number, number
	-- 设置影响所用距离衰减强度的滚降系数。
	--
	-- 扩展信息和详细公式可以在OpenAL 1.1规范的'3.4. Attenuation By Distance'章节中找到。
	--
	-- 参数：
	--  rolloff: 新的滚降因子。
	setRolloff: function(self: Source, rolloff: number)
	-- 返回源的滚降系数。
	--
	-- 返回值：
	--  rolloff: 滚降因子。
	getRolloff: function(self: Source): number
	-- 设置播放源时要应用的低通、高通或带通滤波器。
	--
	-- 重载说明：
	-- 1. 禁用对此源的过滤。
	--
	-- 参数：
	--  filter: 用于此源的过滤器设置，具有以下字段：
	--  filter.type: 要使用的过滤器类型。
	--  filter.volume: 音频的总音量。必须介于 0 和 1 之间。
	--  filter.highgain: 高频音频的音量。仅适用于低通和带通滤波器。必须介于 0 和 1 之间。
	--  filter.lowgain: 低频音频的音量。仅适用于高通和带通滤波器。必须介于 0 和 1 之间。
	--
	-- 返回值：
	--  success: 过滤器是否成功应用于源。
	setFilter: function(self: Source, filter?: AudioFilterSettings): boolean
	-- 获取当前应用于源的过滤器设置。
	--
	-- 返回值：
	--  settings: 用于此源的过滤器设置，如果源没有活动过滤器则为零。该表具有以下字段：
	getFilter: function(self: Source, target?: AudioFilterSettings): AudioFilterSettings | nil
	-- 将音频效果应用于源。
	--
	-- 该效果必须事先使用 love.audio.setEffect.
	--
	-- 重载说明：
	-- 1. 将给定的先前定义的效果应用于此源。 2. 将给定的先前定义的效果应用到该源，并将滤波器应用到影响输入到效果中的声音的源。 iOS 不支持音频效果功能。
	--
	-- 参数：
	--  name: 之前使用 love.audio.setEffect. 设置的效果名称
	--  enabled: 如果为 false 并且给定的效果名称先前已在此源上启用，则禁用该效果。 （默认值：true。）取决于过载：在效果之前应用的过滤器设置，具有以下字段：
	--  enabled.type: 要使用的过滤器类型。
	--  enabled.volume: 音频的总音量。必须介于 0 和 1 之间。
	--  enabled.highgain: 高频音频的音量。仅适用于低通和带通滤波器。必须介于 0 和 1 之间。
	--  enabled.lowgain: 低频音频的音量。仅适用于高通和带通滤波器。必须介于 0 和 1 之间。
	--
	-- 返回值：
	--  success: 效果是否成功应用于此源。取决于过载：效果和滤波器是否成功应用于此源。
	setEffect: function(self: Source, name: string, enabled?: boolean | AudioFilterSettings): boolean
	-- 获取与特定效果关联的过滤器设置。
	--
	-- 如果应用效果时没有与其关联的滤镜设置，则此函数返回 nil。
	--
	-- 参数：
	--  name: 效果的名称。
	--  target: 一个可选的空表，将填充过滤器设置。 （默认值：{}。）
	--
	-- 返回值：
	--  filtersettings: 与此效果关联的过滤器的设置，如果此源中不存在该效果或没有关联的过滤器，则为零。该表具有以下字段：
	getEffect: function(self: Source, name: string, target?: AudioFilterSettings): boolean, AudioFilterSettings | nil
	-- 获取源的活动效果名称列表。
	--
	-- 返回值：
	--  effects: 源的活动效果名称列表。
	getActiveEffects: function(self: Source): {string}
	-- 获取源的类型。
	--
	-- 返回值：
	--  sourcetype: 源的类型。
	getType: function(self: Source): string
end

-- 表示能够录制声音的音频输入设备。
local record RecordingDevice
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: RecordingDevice): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: RecordingDevice, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: RecordingDevice): boolean
	-- 开始使用此设备录制音频。
	--
	-- 重载说明：
	-- 1. 在调用 RecordingDevice:getData 或 RecordingDevice:stop 之前，内部使用环形缓冲区来存储记录的数据 - 前者会清除缓冲区。如果在调用 getData 或 stop
	-- 之前缓冲区完全填满，则不适合缓冲区的最旧数据将丢失。
	--
	-- 参数：
	--  samples: 记录时在内部环形缓冲区中存储的最大样本数。 RecordingDevice:getData 调用时会清除内部缓冲区。
	--  sample_rate: 记录时每秒存储的样本数。 （默认值：8000。）
	--  bit_depth: 每个样本的位数。 （默认值：16。）
	--  channels: 是否以单声道或立体声录制。大多数麦克风不支持超过 1 个通道。 （默认值：1。）
	--
	-- 返回值：
	--  success: 如果设备使用指定参数成功开始录制，则为 true，否则为 false。
	start: function(self: RecordingDevice, samples?: integer, sample_rate?: integer, bit_depth?: integer, channels?: integer): boolean
	-- 停止从此设备录制音频。当前位于设备缓冲区中的任何声音数据都将被返回。
	--
	-- 返回值：
	--  data: 当前在设备缓冲区中的声音数据，如果设备没有录音则为零。
	stop: function(self: RecordingDevice): SoundData | nil
	-- 获取存储在设备内部环形缓冲区中的所有录制音频 SoundData。
	--
	-- 调用此函数时，内部环形缓冲区会被清除，因此再次调用它只会在上次调用后录制音频。如果设备的内部环形缓冲区在调用 getData 之前完全填满，则不适合缓冲区的最旧数据将丢失。
	--
	-- 返回值：
	--  data: 录制的音频数据，如果设备未录制则为零。
	getData: function(self: RecordingDevice): SoundData | nil
	-- 获取当前记录的样本数。
	--
	-- 返回值：
	--  samples: 迄今为止已记录的样本数。
	getSampleCount: function(self: RecordingDevice): integer
	-- 获取当前记录的每秒样本数。
	--
	-- 返回值：
	--  rate: 每秒记录的样本数（采样率）。
	getSampleRate: function(self: RecordingDevice): integer
	-- 获取当前记录的数据中每个样本的位数。
	--
	-- 返回值：
	--  bits: 当前记录的数据中每个样本的位数。
	getBitDepth: function(self: RecordingDevice): integer
	-- 获取当前正在录制的通道数（单声道或立体声）。
	--
	-- 返回值：
	--  channels: 正在录制的通道数（1 个为单声道，2 个为立体声）。
	getChannelCount: function(self: RecordingDevice): integer
	-- 获取录音设备的名称。
	--
	-- 返回值：
	--  name: 设备的名称。
	getName: function(self: RecordingDevice): string
	-- 获取设备当前是否正在录制。
	--
	-- 返回值：
	--  recording: 如果录音则为 true，否则为 false。
	isRecording: function(self: RecordingDevice): boolean
end

-- 提供一个用用户扬声器产生噪音的接口。
local record Audio
	-- 从文件路径、文件、解码器或声音数据创建新的源。
	--
	-- 从 SoundData 创建的源始终是静态的。
	--
	-- 参数：
	--  filename_or_data: 音频文件的文件路径。根据过载：指向音频文件的文件。 取决于重载：从中创建源的解码器。取决于重载：从中创建源的 FileData。
	--  source_type: 流式或静态源。
	--
	-- 返回值：
	--  source: 可以播放指定音频的新源。根据过载：可以播放指定音频的新源。返回音频的SourceType是'static'。
	newSource: function(filename_or_data: string | SoundData, source_type?: string): Source
	-- 创建一个新的源，可用于使用 Source:queue 实时生成的声音播放。
	--
	-- 重载说明：
	-- 1. 与 Source:queue 一起使用的任何 SoundData 的采样率、位深度和通道数必须与提供给此构造函数的参数相匹配。
	--
	-- 参数：
	--  sample_rate: 播放时每秒的采样数。
	--  bit_depth: 每个样本的位数（8 或 16）。
	--  channels: 1 用于单声道或 2 用于立体声。
	--  buffers: 在任何给定时间可以使用 Source:queue 排队的缓冲区数量。不能大于 64。如果未指定值，则选择合理的默认值 (~8)。 （默认值：0。）
	--
	-- 返回值：
	--  source: 可与 Source:queue 一起使用的新源。
	newQueueableSource: function(sample_rate: integer, bit_depth: integer, channels: integer, buffers?: integer): Source
	-- 播放指定的源。
	--
	-- 重载说明：
	-- 1. 开始同时播放多个源。
	--
	-- 参数：
	--  sources: 包含要播放的源列表的表。
	play: function(sources: {Source}): boolean
	play: function(sources: Source...): boolean
	-- 暂停特定或所有当前播放的源。
	--
	-- 重载说明：
	-- 1. 暂停所有当前活动的源并返回它们。 2. 暂停给定的源。
	--
	-- 返回值：
	--  Sources: 包含由此调用暂停的源列表的表。
	pause: function(): {Source}
	pause: function(sources: {Source})
	pause: function(sources: Source...)
	-- 停止当前播放的源。
	--
	-- 重载说明：
	-- 1. 此功能将停止所有当前活动的源。 2. 该功能只会停止指定的源。 3. 同时停止所有给定的源。
	--
	-- 参数：
	--  sources: 包含要停止的源列表的表。
	stop: function(sources: {Source})
	stop: function(sources: Source...)
	-- 获取当前同时播放的音源数量。
	--
	-- 返回值：
	--  count: 当前同时播放的音源数量。
	getActiveSourceCount: function(): integer
	getSourceCount: function(): integer
	-- 设置主音量。
	--
	-- 参数：
	--  volume: 1.0 为最大值，0.0 为关闭。
	setVolume: function(volume: number)
	-- 返回主卷。
	--
	-- 返回值：
	--  volume: 当前主卷
	getVolume: function(): number
	-- 设置系统是否应将音频与系统的音频混合。
	--
	-- 参数：
	--  mix: true 启用混合， false 禁用它。
	--
	-- 返回值：
	--  success: 如果更改成功则为 true，否则为 false。
	setMixWithSystem: function(mix: boolean): boolean
	-- 设置听者的位置，这决定了声音的播放方式。
	--
	-- 参数：
	--  x: 听者的 x 位置。
	--  y: 听者的 y 位置。
	--  z: 听者的 z 位置。
	setPosition: function(x: number, y: number, z?: number)
	-- 返回听者的位置。请注意，位置音频仅适用于单声道（即非立体声）源。
	--
	-- 返回值：
	--  x: 听者的 X 位置。
	--  y: 听者的 Y 位置。
	--  z: 听者的 Z 位置。
	getPosition: function(): number, number, number
	-- 设置听者的方向。
	setOrientation: function(forward_x: number, forward_y: number, forward_z: number,
		up_x: number, up_y: number, up_z: number)
	-- 返回听者的方向。
	--
	-- 返回值：
	--  fx: 收听者方向的前向 x。
	--  fy: 向前 y 收听者方向。
	--  fz: 收听者方向的正向 z。
	--  ux: 听者方向的向上 x。
	--  uy: 听者方向的向上 y。
	--  uz: 听者方向的 z 上方向。
	getOrientation: function(): number, number, number, number, number, number
	-- 设置听者的速度。
	--
	-- 参数：
	--  x: 听者的 X 速度。
	--  y: 听者的 Y 速度。
	--  z: 听者的 Z 速度。
	setVelocity: function(x: number, y: number, z?: number)
	-- 返回听者的速度。
	--
	-- 返回值：
	--  x: 听者的 X 速度。
	--  y: 听者的 Y 速度。
	--  z: 听者的 Z 速度。
	getVelocity: function(): number, number, number
	-- 为基于速度的多普勒效应设置全局比例因子。默认比例值为 1。
	--
	-- 参数：
	--  scale: 新的多普勒比例因子。小数位数必须大于 0。
	setDopplerScale: function(scale: number)
	-- 获取基于速度的多普勒效应的当前全局比例因子。
	--
	-- 返回值：
	--  scale: 当前的多普勒比例因子。
	getDopplerScale: function(): number
	-- 设置距离衰减模型。
	--
	-- 参数：
	--  model: 新的距离模型。
	setDistanceModel: function(model: string)
	-- 返回距离衰减模型。
	--
	-- 返回值：
	--  model: 当前距离模型。默认值为 'inverseclamped'。
	getDistanceModel: function(): string
	-- 定义可以应用于源的效果。
	--
	-- 并非所有系统都支持音频效果。使用love.audio.isEffectsSupported进行检查。
	--
	-- 参数：
	--  name: 效果的名称。
	--  settings: 用于此效果的设置，具有以下字段：
	--  settings.type: 要使用的效果类型。
	--  settings.volume: 效果的音量。
	--  settings....: 特定于效果的设置。请参阅 EffectType 了解可用效果及其相应的设置。
	--
	-- 返回值：
	--  success: 效果是否创建成功。取决于过载：效果是否成功禁用。
	setEffect: function(name: string, settings?: AudioEffectSettings | boolean): boolean
	-- 获取与效果关联的设置。
	--
	-- 参数：
	--  name: 效果的名称。
	--
	-- 返回值：
	--  settings: 与效果相关的设置。
	getEffect: function(name: string, target?: AudioEffectSettings): AudioEffectSettings | nil
	-- 获取当前启用的效果的名称列表。
	--
	-- 返回值：
	--  effects: 当前启用的效果名称列表。
	getActiveEffects: function(): {string}
	-- 获取系统支持的最大活动效果数。
	--
	-- 返回值：
	--  maximum: 活动效果的最大数量。
	getMaxSceneEffects: function(): integer
	-- 获取系统可以支持的单个源对象中活动效果的最大数量。
	--
	-- 重载说明：
	-- 1. 对于不支持音效的系统，该函数返回0。
	--
	-- 返回值：
	--  maximum: 每个源的活动效果的最大数量。
	getMaxSourceEffects: function(): integer
	-- 获取系统上的 RecordingDevices 列表。
	--
	-- 列表中的第一个设备是用户的默认录音设备。如果没有麦克风连接到系统，则该列表可能为空。
	--
	-- iOS 目前不支持录音。
	--
	-- 重载说明：
	-- 1. Android从11.3开始支持录音。但是，使用 Play Store 中的 APK 时不支持。
	--
	-- 返回值：
	--  devices: 连接的录音设备列表。
	getRecordingDevices: function(): {RecordingDevice}
	-- 获取系统是否支持音效。
	--
	-- 重载说明：
	-- 1. 附带旧版 OpenAL 库的旧版 Linux 发行版可能不支持音频效果。此外，iOS根本不支持音频效果。
	--
	-- 返回值：
	--  supported: 如果支持效果则为 true，否则为 false。
	isEffectsSupported: function(): boolean
end

-- 物体是具有速度和位置的物体。
local record Body
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Body): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Body, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Body): boolean
	-- 显式地破坏身体以及附着在其上的所有固定装置和关节。
	--
	-- 如果您在调用此函数后尝试使用该对象，将会发生错误。在0.7.2中，当你没有时间等待垃圾回收时，可以使用此函数立即释放对象。
	destroy: function(self: Body)
	-- 获取Body是否被破坏。被毁坏的尸体无法使用。
	--
	-- 返回值：
	--  destroyed: 本体是否被破坏。
	isDestroyed: function(self: Body): boolean
	-- 获取身体的位置。
	--
	-- 请注意，这可能不是身体的质心。
	--
	-- 返回值：
	--  x: x 位置。
	--  y: y 位置。
	getPosition: function(self: Body): number, number
	-- 设置主体的位置。
	--
	-- 请注意，这可能不是身体的质心。
	--
	-- 该功能无法唤醒本体。
	--
	-- 参数：
	--  x: x 位置。
	--  y: y 位置。
	setPosition: function(self: Body, x: number, y: number)
	-- 获取身体在世界坐标中的 x 位置。
	--
	-- 返回值：
	--  x: 世界坐标中的 x 位置。
	getX: function(self: Body): number
	-- 设置主体的 x 位置。
	--
	-- 该功能无法唤醒本体。
	--
	-- 参数：
	--  x: x 位置。
	setX: function(self: Body, x: number)
	-- 获取身体在世界坐标中的 y 位置。
	--
	-- 返回值：
	--  y: 世界坐标中的 y 位置。
	getY: function(self: Body): number
	-- 设置主体的 y 位置。
	--
	-- 该功能无法唤醒本体。
	--
	-- 参数：
	--  y: y 位置。
	setY: function(self: Body, y: number)
	-- 获取身体的位置和角度。
	--
	-- 请注意，该位置可能不是身体的质心。 0 弧度的角度意味着 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成顺时针。
	--
	-- 返回值：
	--  x: 位置的 x 分量。
	--  y: 位置的 y 分量。
	--  angle: 以弧度表示的角度。
	getTransform: function(self: Body): number, number, number
	-- 设置主体的位置和角度。
	--
	-- 请注意，该位置可能不是身体的质心。 0 弧度的角度意味着 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成顺时针。
	--
	-- 该功能无法唤醒本体。
	--
	-- 参数：
	--  x: 位置的 x 分量。
	--  y: 位置的 y 分量。
	--  angle: 以弧度表示的角度。
	setTransform: function(self: Body, x: number, y: number, angle: number)
	-- 获取身体的角度。
	--
	-- 角度以弧度为单位测量。如果需要将其转换为度数，请使用 math.deg。
	--
	-- 0 弧度值表示 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成了“'clockwise'”。
	--
	-- 返回值：
	--  angle: 以弧度表示的角度。
	getAngle: function(self: Body): number
	-- 设置主体的角度。
	--
	-- 角度以弧度为单位测量。如果您需要将其从度数转换，请使用 math.rad。
	--
	-- 0 弧度值表示 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成了“'clockwise'”。
	--
	-- 通过改变角度有可能与另一个物体发生碰撞。
	--
	-- 参数：
	--  angle: 以弧度表示的角度。
	setAngle: function(self: Body, angle: number)
	-- 获取 Body 从其质心开始的线速度。
	--
	-- 线速度是“'rate of change of position over time'”。
	--
	-- 如果您需要“'rate of change of angle over time'”，请使用Body:getAngularVelocity。
	--
	-- 如果需要获取与质心不同的点的线速度：
	--
	-- * Body:getLinearVelocityFromLocalPoint 允许您指定本地坐标中的点。
	--
	-- * Body:getLinearVelocityFromWorldPoint 允许您指定世界坐标中的点。
	--
	-- 请参阅 'Essential Mathematics for Games and Interactive Applications' 第 136 页了解本地坐标和世界坐标的定义。
	--
	-- 返回值：
	--  x: 速度矢量的 x 分量
	--  y: 速度矢量的 y 分量
	getLinearVelocity: function(self: Body): number, number
	-- 为主体设置新的线速度。
	--
	-- 该函数不会累积任何东西；自上次调用 World:update 以来先前应用的任何脉冲都将丢失。
	--
	-- 参数：
	--  x: 速度矢量的 x 分量。
	--  y: 速度矢量的 y 分量。
	setLinearVelocity: function(self: Body, x: number, y: number)
	-- 获取Body的角速度。
	--
	-- 角速度是“'rate of change of angle over time'”。
	--
	-- 通过施加扭矩、偏心力/脉冲和角阻尼在 World:update 中进行更改。可以直接用Body:setAngularVelocity设置。
	--
	-- 如果您需要“'rate of change of position over time'”，请使用Body:getLinearVelocity。
	--
	-- 返回值：
	--  w: 以弧度/秒为单位的角速度。
	getAngularVelocity: function(self: Body): number
	-- 设置物体的角速度。
	--
	-- 角速度是“'rate of change of angle over time'”。
	--
	-- 该函数不会累积任何东西；自上次调用 World:update 以来先前应用的任何脉冲都将丢失。
	--
	-- 参数：
	--  velocity: 新的角速度，以弧度每秒为单位
	setAngularVelocity: function(self: Body, velocity: number)
	-- 获取Body的线性阻尼。
	--
	-- 线性阻尼是“'rate of decrease of the linear velocity over time'”。没有阻尼且没有外力的运动物体将无限期地继续运动，就像在太空中的情况一样。具有阻尼的运动体会逐渐停止运动。
	--
	-- 阻尼与摩擦不同 - 它们可以一起建模。
	--
	-- 返回值：
	--  damping: 线性阻尼值。
	getLinearDamping: function(self: Body): number
	-- 设置主体的线性阻尼
	--
	-- 有关线性阻尼的定义，请参阅Body:getLinearDamping。
	--
	-- 线性阻尼可以取从 0 到无穷大的任何值。不过，建议保持在 0 到 0.1 之间。其他值将使对象看起来 'floaty'（如果启用重力）。
	--
	-- 参数：
	--  damping: 新的线性阻尼
	setLinearDamping: function(self: Body, damping: number)
	-- 获取Body的角阻尼
	--
	-- 角度阻尼是“'rate of decrease of the angular velocity over time'”：没有阻尼且没有外力的旋转体将无限期地继续旋转。具有阻尼的旋转体将逐渐停止旋转。
	--
	-- 阻尼与摩擦不同 - 它们可以一起建模。然而，Box2D（和 LOVE）仅提供阻尼。
	--
	-- 阻尼参数应介于 0 和无穷大之间，0 表示无阻尼，无穷大表示完全阻尼。通常您将使用 0 到 0.1 之间的阻尼值。
	--
	-- 返回值：
	--  damping: 角度阻尼值。
	getAngularDamping: function(self: Body): number
	-- 设置主体的角度阻尼
	--
	-- 有关角度阻尼的定义，请参阅Body:getAngularDamping。
	--
	-- 角度阻尼可以取从 0 到无穷大的任何值。不过，建议保持在 0 到 0.1 之间。其他值看起来不切实际。
	--
	-- 参数：
	--  damping: 新的角度阻尼。
	setAngularDamping: function(self: Body, damping: number)
	-- 获取物体的质量。
	--
	-- 静态物体的质量始终为 0。
	--
	-- 返回值：
	--  mass: 身体的质量（以千克为单位）。
	getMass: function(self: Body): number
	-- 设置新的体重。
	--
	-- 参数：
	--  mass: 质量，以千克为单位。
	setMass: function(self: Body, mass: number)
	-- 获取物体的转动惯量。
	--
	-- 转动惯量是指使身体旋转的难度。
	--
	-- 返回值：
	--  inertia: 身体的旋转惯性。
	getInertia: function(self: Body): number
	-- 设置物体的惯性。
	--
	-- 参数：
	--  inertia: 新的转动惯量，单位为千克 * 像素平方。
	setInertia: function(self: Body, inertia: number)
	-- 返回质量、中心和转动惯量。
	--
	-- 返回值：
	--  x: 质心的 x 位置。
	--  y: 质心的 y 位置。
	--  mass: 身体的质量。
	--  inertia: 转动惯量。
	getMassData: function(self: Body): number, number, number, number
	-- 覆盖计算的质量数据。
	--
	-- 参数：
	--  center_x: 质心的 x 位置。
	--  center_y: 质心的 y 位置。
	--  mass: 身体的质量。
	--  inertia: 转动惯量。
	setMassData: function(self: Body, center_x: number, center_y: number, mass: number, inertia: number)
	-- 通过根据夹具的质量属性重新计算来重置主体的质量。
	resetMassData: function(self: Body)
	-- 返回重力比例因子。
	--
	-- 返回值：
	--  scale: 重力比例因子。
	getGravityScale: function(self: Body): number
	-- 为主体设置新的重力比例因子。
	--
	-- 参数：
	--  scale: 新的重力比例因子。
	setGravityScale: function(self: Body, scale: number)
	-- 获取本地坐标中的质心位置。
	--
	-- 使用 Body:getWorldCenter 获取世界坐标中的质心。
	--
	-- 返回值：
	--  x: 质心的 x 坐标。
	--  y: 质心的 y 坐标。
	getLocalCenter: function(self: Body): number, number
	-- 获取世界坐标中的质心位置。
	--
	-- 使用 Body:getLocalCenter 获取局部坐标中的质心。
	--
	-- 返回值：
	--  x: 质心的 x 坐标。
	--  y: 质心的 y 坐标。
	getWorldCenter: function(self: Body): number, number
	-- 返回主体旋转是否被锁定。
	--
	-- 返回值：
	--  fixed: 如果身体的旋转被锁定则为 True，否则为 false。
	isFixedRotation: function(self: Body): boolean
	-- 设置物体是否有固定旋转。
	--
	-- 具有固定旋转的物体不会改变它们旋转的速度。调用此函数会导致质量重置。
	--
	-- 参数：
	--  fixed: 身体是否应该有固定的旋转。
	setFixedRotation: function(self: Body, fixed: boolean)
	-- 返回主体的睡眠状态。
	--
	-- 返回值：
	--  status: 如果身体清醒则为真，否则为假。
	isAwake: function(self: Body): boolean
	-- 唤醒身体或使其进入睡眠状态。
	--
	-- 参数：
	--  awake: 身体睡眠状态。
	setAwake: function(self: Body, awake: boolean)
	-- 返回主体的睡眠行为。
	--
	-- 返回值：
	--  allowed: 如果允许身体睡眠则为 true，否则为 false。
	isSleepingAllowed: function(self: Body): boolean
	-- 设置身体的睡眠行为。如果允许睡觉，休息的身体就会自动睡觉。除非与清醒的身体发生碰撞，否则不会模拟睡眠的身体。请注意，如果地板被拆除，人们最终可能会遇到像漂浮的睡着的身体这样的情况。
	--
	-- 参数：
	--  allowed: 如果允许身体睡眠则为 true，否则为 false。
	setSleepingAllowed: function(self: Body, allowed: boolean)
	-- 返回模拟中是否主动使用主体。
	--
	-- 返回值：
	--  status: 如果主体处于活动状态，则为 True，否则为 false。
	isActive: function(self: Body): boolean
	-- 设置物体在世界中是否活跃。
	--
	-- 不活跃的物体不参与模拟。它不会移动或造成任何碰撞。
	--
	-- 参数：
	--  active: 身体是否活跃。
	setActive: function(self: Body, active: boolean)
	-- 获取主体的子弹状态。
	--
	-- 有两种方法来检查身体碰撞：
	--
	-- * 世界更新时的位置（默认）
	--
	-- * 使用连续碰撞检测 (CCD)
	--
	-- 默认方法很有效，但是移动速度非常快的物体有时可能会跳过另一个物体而不会产生碰撞。被设置为子弹的物体将使用 CCD。这样效率较低，但保证快速移动时不会跳跃。
	--
	-- 请注意，静态物体（质量为零）始终使用 CCD，因此您的墙壁不会让快速移动的物体穿过，即使它不是子弹。
	--
	-- 返回值：
	--  status: 主体的子弹状态。
	isBullet: function(self: Body): boolean
	-- 设置正文的项目符号状态。
	--
	-- 有两种方法来检查身体碰撞：
	--
	-- * 世界更新时的位置（默认）
	--
	-- * 使用连续碰撞检测 (CCD)
	--
	-- 默认方法很有效，但是移动速度非常快的物体有时可能会跳过另一个物体而不会产生碰撞。被设置为子弹的物体将使用 CCD。这样效率较低，但保证快速移动时不会跳跃。
	--
	-- 请注意，静态物体（质量为零）始终使用 CCD，因此您的墙壁不会让快速移动的物体穿过，即使它不是子弹。
	--
	-- 参数：
	--  bullet: 主体的子弹状态。
	setBullet: function(self: Body, bullet: boolean)
	-- 对身体施加脉冲。
	--
	-- 这使得身体动量瞬间增加。
	--
	-- 冲动将身体推向一个方向。质量较大的物体反应较小。反应“'not'”取决于时间步长，相当于连续施加一个力 1 秒。脉冲最好用于对身体进行一次推力。对于连续推动身体，最好使用 Body:applyForce。
	--
	-- 如果没有给出施加脉冲的位置，它将作用于身体的质心。未指向质心的部分脉冲将导致身体旋转（并且取决于旋转惯性）。
	--
	-- 请注意，脉冲分量和位置必须在世界坐标中给出。
	--
	-- 参数：
	--  x_impulse: 脉冲的 x 分量。
	--  y_impulse: 脉冲的 y 分量。
	--  point_x: 应用脉冲的 x 位置。
	--  point_y: 施加脉冲的 y 位置。
	applyLinearImpulse: function(self: Body, x_impulse: number, y_impulse: number, point_x?: number, point_y?: number)
	-- 对物体施加角冲量。这使得身体动量瞬间增加。
	--
	-- 质量越大的物体反应越小。反应“'not'”取决于时间步长，相当于连续施加一个力 1 秒。脉冲最好用于对身体进行一次推力。对于连续推动身体，最好使用 Body:applyForce。
	--
	-- 参数：
	--  impulse: 每秒千克平方米的脉冲。
	applyAngularImpulse: function(self: Body, impulse: number)
	-- 对身体施加力。
	--
	-- 力将物体推向一个方向。质量较大的物体反应较小。该反应还取决于施加力的时间长短：由于力在整个时间步长内连续作用，因此短时间步长只会推动身体很短的时间。因此，力最好在多个时间步中使用，以持续推动物体（如重力）。对于与时间步无关的单次推送，最好使用
	-- Body:applyLinearImpulse。
	--
	-- 如果没有给出施加力的位置，它将作用在身体的质心上。不指向质心的部分力将导致身体旋转（并且取决于旋转惯性）。
	--
	-- 请注意，力的分量和位置必须在世界坐标中给出。
	--
	-- 参数：
	--  x_force: 要施加的力的 x 分量。
	--  y_force: 要施加的力的 y 分量。
	--  point_x: 施加力的 x 位置。
	--  point_y: 施加力的 y 位置。
	applyForce: function(self: Body, x_force: number, y_force: number, point_x?: number, point_y?: number)
	-- 对主体施加扭矩。
	--
	-- 扭矩就像一种会改变物体角速度（旋转）的力。效果取决于物体的转动惯量。
	--
	-- 参数：
	--  torque: 要施加的扭矩。
	applyTorque: function(self: Body, torque: number)
	-- 返回主体的类型。
	--
	-- 返回值：
	--  type: 体型。
	getType: function(self: Body): string
	-- 设置新的身体类型。
	--
	-- 参数：
	--  body_type: 新类型。
	setType: function(self: Body, body_type: string)
	-- 将点从本地坐标转换为世界坐标。
	--
	-- 参数：
	--  x: 本地坐标中的 x 位置。
	--  y: 本地坐标中的 y 位置。
	--
	-- 返回值：
	--  worldX: 世界坐标中的 x 位置。
	--  worldY: 世界坐标中的 y 位置。
	getWorldPoint: function(self: Body, x: number, y: number): number, number
	-- 将向量从本地坐标转换为世界坐标。
	--
	-- 参数：
	--  x: 局部坐标中的向量 x 分量。
	--  y: 局部坐标中的向量 y 分量。
	--
	-- 返回值：
	--  worldX: 世界坐标中的向量 x 分量。
	--  worldY: 世界坐标中的向量 y 分量。
	getWorldVector: function(self: Body, x: number, y: number): number, number
	-- 将多个点从本地坐标转换为世界坐标。
	--
	-- 参数：
	--  x: 第一个点的 x 位置。
	--  y: 第一个点的 y 位置。
	--  coordinates: 第二个点的 x 位置。
	--
	-- 返回值：
	--  x1: 第一个点的变换后的 x 位置。
	--  y1: 第一个点的变换 y 位置。
	--  x2: 第二个点的变换后的 x 位置。
	--  y2: 第二个点的变换后的 y 位置。
	getWorldPoints: function(self: Body, x: number, y: number, coordinates: number...): number...
	-- 将点从世界坐标转换为本地坐标。
	--
	-- 参数：
	--  x: 世界坐标中的 x 位置。
	--  y: 世界坐标中的 y 位置。
	--
	-- 返回值：
	--  localX: 本地坐标中的 x 位置。
	--  localY: 本地坐标中的 y 位置。
	getLocalPoint: function(self: Body, x: number, y: number): number, number
	-- 将向量从世界坐标转换为局部坐标。
	--
	-- 参数：
	--  x: 世界坐标中的向量 x 分量。
	--  y: 世界坐标中的向量 y 分量。
	--
	-- 返回值：
	--  localX: 局部坐标中的向量 x 分量。
	--  localY: 局部坐标中的向量 y 分量。
	getLocalVector: function(self: Body, x: number, y: number): number, number
	-- 将多个点从世界坐标转换为本地坐标。
	--
	-- 参数：
	--  x: （参数）第一个点的 x 位置。
	--  y: （参数）第一个点的 y 位置。
	--  coordinates: （参数）第二个点的 x 位置。
	--
	-- 返回值：
	--  x1: （结果）第一个点的变换后的 x 位置。
	--  y1: （结果）第一个点的变换后的 y 位置。
	--  x2: （结果）第二个点的变换后的 x 位置。
	--  y2: （结果）第二个点的变换后的 y 位置。
	--  ...: （结果）额外变换的点的 x 和 y 位置。
	getLocalPoints: function(self: Body, x: number, y: number, coordinates: number...): number...
	-- 获取物体上一点的线速度。
	--
	-- 身体上一点的线速度是身体质心的速度加上该点处身体旋转的速度。
	--
	-- 身体上的点必须以世界坐标给出。使用 Body:getLinearVelocityFromLocalPoint 来指定本地坐标。
	--
	-- 参数：
	--  x: 测量速度的 x 位置。
	--  y: 测量速度的 y 位置。
	--
	-- 返回值：
	--  vx: (x,y) 点速度的 x 分量。
	--  vy: (x,y) 点速度的 y 分量。
	getLinearVelocityFromWorldPoint: function(self: Body, x: number, y: number): number, number
	-- 获取物体上一点的线速度。
	--
	-- 身体上一点的线速度是身体质心的速度加上该点处身体旋转的速度。
	--
	-- 物体上的点必须以本地坐标给出。使用 Body:getLinearVelocityFromWorldPoint 来指定世界坐标。
	--
	-- 参数：
	--  x: 测量速度的 x 位置。
	--  y: 测量速度的 y 位置。
	--
	-- 返回值：
	--  vx: (x,y) 点速度的 x 分量。
	--  vy: (x,y) 点速度的 y 分量。
	getLinearVelocityFromLocalPoint: function(self: Body, x: number, y: number): number, number
end

-- 形状是固体二维几何对象，用于处理 love.physics.
local record Shape
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Shape): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Shape, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Shape): boolean
	-- 获取表示形状的字符串。
	--
	-- 此函数对于条件调试绘图很有用。
	--
	-- 返回值：
	--  type: 形状的类型。
	getType: function(self: Shape): string
	-- 获取形状的半径。
	--
	-- 返回值：
	--  radius: 形状的半径。
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

-- 夹具将形状附加到主体上。
local record Fixture
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Fixture): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Fixture, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Fixture): boolean
	-- 摧毁灯具。
	destroy: function(self: Fixture)
	-- 获取Fixture是否被破坏。损坏的固定装置不能再使用。
	--
	-- 返回值：
	--  destroyed: Fixture是否被破坏。
	isDestroyed: function(self: Fixture): boolean
	getType: function(self: Fixture): string
	-- 设置夹具的摩擦力。
	--
	-- 摩擦力决定了形状沿着其他形状 'slide' 时如何反应。低摩擦力表示光滑的表面，如冰，而高摩擦力表示粗糙的表面，如混凝土。范围：0.0 - 1.0。
	--
	-- 参数：
	--  friction: 夹具摩擦力。
	setFriction: function(self: Fixture, friction: number)
	-- 返回夹具的摩擦力。
	--
	-- 返回值：
	--  friction: 夹具摩擦力。
	getFriction: function(self: Fixture): number
	-- 设置灯具的恢复。
	--
	-- 参数：
	--  restitution: 灯具恢复原状。
	setRestitution: function(self: Fixture, restitution: number)
	-- 返回灯具的恢复状态。
	--
	-- 返回值：
	--  restitution: 灯具恢复原状。
	getRestitution: function(self: Fixture): number
	-- 设置灯具的密度。如果需要立即生效，请调用Body:resetMassData。
	--
	-- 参数：
	--  density: 灯具密度，单位为千克每平方米。
	setDensity: function(self: Fixture, density: number)
	-- 返回灯具的密度。
	--
	-- 返回值：
	--  density: 灯具密度，单位为千克每平方米。
	getDensity: function(self: Fixture): number
	-- 设置灯具是否应充当传感器。
	--
	-- 传感器不会引起碰撞响应，但该装置仍会调用开始接触和结束接触世界回调。
	--
	-- 参数：
	--  sensor: 传感器状态。
	setSensor: function(self: Fixture, sensor: boolean)
	-- 返回夹具是否为传感器。
	--
	-- 返回值：
	--  sensor: 如果夹具是传感器。
	isSensor: function(self: Fixture): boolean
	-- 返回固定装置所连接的主体。
	--
	-- 返回值：
	--  body: 父体。
	getBody: function(self: Fixture): Body
	-- 返回夹具的形状。该形状是对模拟中使用的实际数据的参考。可以在时间步之间更改其值。
	--
	-- 返回值：
	--  shape: 灯具的形状。
	getShape: function(self: Fixture): Shape
	-- 检查点是否位于夹具形状内部。
	--
	-- 参数：
	--  x: 点的 x 位置。
	--  y: 点的 y 位置。
	--
	-- 返回值：
	--  isInside: 如果该点在内部，则为 True；如果在外部，则为 false。
	testPoint: function(self: Fixture, x: number, y: number): boolean
	-- 将光线投射到夹具的形状上，并返回表面法线向量和光线击中的线位置。如果光线错过了形状，则返回 nil。
	--
	-- 射线从输入线的第一个点开始，朝向该线的第二个点。第五个参数是光线将行进的最大距离，作为输入线长度的比例因子。
	--
	-- childIndex 参数用于指定父形状（例如 ChainShape）的哪个子形状将进行光线投射。对于 ChainShapes，索引 1
	-- 是链上的第一条边。射线投射父形状只会测试指定的子形状，因此如果您想测试父形状的每个形状，则必须循环遍历其所有子形状。
	--
	-- 撞击的世界位置可以通过将线向量乘以第三个返回值并将其与线起点相加来计算。
	--
	-- hitx，hity = x1 + (x2 - x1) * 分数，y1 + (y2 - y1) * 分数
	--
	-- 参数：
	--  x1: 输入线起点的 x 位置。
	--  y1: 输入线起点的 y 位置。
	--  x2: 输入线终点的 x 位置。
	--  y2: 输入线终点的 y 位置。
	--  max_fraction: 光线长度参数。
	--  child_index: 光线投射到的子项的索引。 （默认值：1。）
	--
	-- 返回值：
	--  xn: 光线击中形状的边缘的法线向量的 x 分量。
	--  yn: 光线照射到形状的边缘的法线向量的 y 分量。
	--  fraction: 输入线上相交的位置，是线长度的一个因素。
	rayCast: function(self: Fixture, x1: number, y1: number, x2: number, y2: number, max_fraction: number, child_index?: integer): number | nil, number | nil, number | nil
	-- 设置灯具的滤波器数据。
	--
	-- 组、类别和遮罩可用于定义夹具的碰撞行为。
	--
	-- 如果两个灯具位于同一组中，则它们要么在组为正时总是发生碰撞，要么在组为负时从不发生碰撞。如果该组为零或它们不匹配，则接触过滤器将检查灯具是否选择了具有其掩码的其他灯具的类别。如果不是这种情况，灯具就不会发生碰撞。如果他们确实选择了彼此的类别，则将使用自定义联系人过滤器的返回值。如果没有设置，它们总是会发生碰撞。
	--
	-- 最多可以有 16 个类别。类别和掩码被编码为 16 位整数的位。
	--
	-- 创建后，在调用此函数之前，所有灯具的类别设置为 1，掩码设置为 65535（所有类别），组设置为 0。
	--
	-- 此功能允许一次设置灯具的所有过滤器数据。要仅设置类别、掩码或组，可以分别使用 Fixture:setCategory、Fixture:setMask 或 Fixture:setGroupIndex。
	--
	-- 参数：
	--  category_bits: 类别为 0 到 65535 之间的整数。
	--  mask_bits: 掩码为 0 到 65535 之间的整数。
	--  group_index: 组为从 -32768 到 32767 的整数。
	setFilterData: function(self: Fixture, category_bits: integer, mask_bits: integer, group_index: integer)
	-- 返回灯具的滤波器数据。
	--
	-- 类别和掩码被编码为 16 位整数的位。
	--
	-- 返回值：
	--  categories: 类别为 0 到 65535 之间的整数。
	--  mask: 掩码为 0 到 65535 之间的整数。
	--  group: 组为从 -32768 到 32767 的整数。
	getFilterData: function(self: Fixture): integer, integer, integer
	-- 设置灯具所属的类别。最多可以有 16 个类别，以 1 到 16 之间的数字表示。
	--
	-- 所有灯具的默认类别为 1。
	--
	-- 参数：
	--  categories: 类别。
	setCategory: function(self: Fixture, categories: integer | {integer}, ...: integer)
	-- 返回灯具所属的类别。
	--
	-- 返回值：
	--  ...: 类别。
	getCategory: function(self: Fixture): integer...
	-- 设置灯具的类别掩码。最多可以有 16 个类别，以 1 到 16 之间的数字表示。
	--
	-- 如果其他灯具也选择了该灯具的类别，则该灯具将与所选类别中的灯具发生“'NOT'”碰撞。
	--
	-- 参数：
	--  categories: 面具。
	setMask: function(self: Fixture, categories: integer | {integer}, ...: integer)
	-- 返回该装置应与“'NOT'”碰撞的类别。
	--
	-- 返回值：
	--  ...: 面具。
	getMask: function(self: Fixture): integer...
	-- 将 Lua 值与固定装置相关联。
	--
	-- 要删除引用，请显式传递 nil。
	--
	-- 参数：
	--  value: 与装置关联的Lua值。
	setUserData: function(self: Fixture, value: any)
	-- 返回与该装置关联的Lua值。
	--
	-- 返回值：
	--  value: 与装置关联的Lua值。
	getUserData: function(self: Fixture): any
	-- 返回夹具边界框的点。如果灯具有多个子级，则可以指定从 1 开始的索引。例如，一个固定装置将有多个呈链状的子项。
	--
	-- 参数：
	--  child_index: 夹具的边界框。 （默认值：1。）
	--
	-- 返回值：
	--  topLeftX: 左上角点的 x 位置。
	--  topLeftY: 左上角点的 y 位置。
	--  bottomRightX: 右下点的 x 位置。
	--  bottomRightY: 右下点的 y 位置。
	getBoundingBox: function(self: Fixture, child_index?: integer): number, number, number, number
	-- 返回质量、中心和转动惯量。
	--
	-- 返回值：
	--  x: 质心的 x 位置。
	--  y: 质心的 y 位置。
	--  mass: 夹具的质量。
	--  inertia: 转动惯量。
	getMassData: function(self: Fixture): number, number, number, number
	-- 返回灯具所属的组。如果该组为正，则具有同一组的灯具将始终发生碰撞；如果该组为负，则永远不会发生碰撞。组零表示没有组。
	--
	-- 组范围从 -32768 到 32767。
	--
	-- 返回值：
	--  group: 灯具组。
	getGroupIndex: function(self: Fixture): integer
	-- 设置灯具所属的组。如果该组为正，则具有同一组的灯具将始终发生碰撞；如果该组为负，则永远不会发生碰撞。组零表示没有组。
	--
	-- 组范围从 -32768 到 32767。
	--
	-- 参数：
	--  index: 组为从 -32768 到 32767 的整数。
	setGroupIndex: function(self: Fixture, index: integer)
end

-- 联系人是为了管理世界中的碰撞而创建的对象。
local record Contact
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Contact): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Contact, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Contact): boolean
	isValid: function(self: Contact): boolean
	-- 获取保持接触形状的两个夹具。
	--
	-- 返回值：
	--  fixtureA: 第一个装置。
	--  fixtureB: 第二场比赛。
	getFixtures: function(self: Contact): Fixture, Fixture
	-- 获取两个碰撞灯具形状的子索引。对于 ChainShapes，索引 1 是链中的第一条边。与 Fixture:rayCast 或 ChainShape:getChildEdge 一起使用。
	--
	-- 返回值：
	--  indexA: 第一个灯具形状的子索引。
	--  indexB: 第二个灯具形状的子索引。
	getChildren: function(self: Contact): integer, integer
	-- 返回两个碰撞夹具的接触点。可以有一个或两个点。
	--
	-- 返回值：
	--  x1: 第一个接触点的 x 坐标。
	--  y1: 第一个接触点的 y 坐标。
	--  x2: 第二个接触点的 x 坐标。
	--  y2: 第二个接触点的 y 坐标。
	getPositions: function(self: Contact): number...
	-- 获取两个接触形状之间的法向量。
	--
	-- 该函数返回从第一个形状指向第二个形状的单位向量的坐标。
	--
	-- 返回值：
	--  nx: 法线向量的 x 分量。
	--  ny: 法向量的 y 分量。
	getNormal: function(self: Contact): number, number
	-- 获取两个接触形状之间的摩擦力。
	--
	-- 返回值：
	--  friction: 接触的摩擦力。
	getFriction: function(self: Contact): number
	-- 设置接触摩擦力。
	--
	-- 参数：
	--  friction: 接触摩擦力。
	setFriction: function(self: Contact, friction: number)
	-- 将接触摩擦重置为两个夹具的混合值。
	resetFriction: function(self: Contact)
	-- 获取两个接触形状之间的恢复。
	--
	-- 返回值：
	--  restitution: 两个形状之间的恢复。
	getRestitution: function(self: Contact): number
	-- 设置接触恢复。
	--
	-- 参数：
	--  restitution: 联系人恢复原状。
	setRestitution: function(self: Contact, restitution: number)
	-- 将接触恢复重置为两个灯具的混合值。
	resetRestitution: function(self: Contact)
	-- 返回联系人是否已启用。如果在 preSolve 回调中禁用了接触，则碰撞将被忽略。
	--
	-- 返回值：
	--  enabled: 如果启用则为 true，否则为 false。
	isEnabled: function(self: Contact): boolean
	-- 启用或禁用联系人。
	--
	-- 参数：
	--  enabled: True 表示启用，False 表示禁用。
	setEnabled: function(self: Contact, enabled: boolean)
	-- 返回两个碰撞的装置是否相互接触。
	--
	-- 返回值：
	--  touching: 如果它们接触则为真，否则为假。
	isTouching: function(self: Contact): boolean
	getTangentSpeed: function(self: Contact): number
	setTangentSpeed: function(self: Contact, speed: number)
end

-- 世界是一个包含所有身体和关节的对象。
local record World
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: World): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: World, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: World): boolean
	-- 毁灭世界，带走所有的身体、关节、固定装置及其形状。
	--
	-- 如果您在调用此函数后尝试使用任何已销毁的对象，将会发生错误。
	destroy: function(self: World)
	-- 获取世界是否被毁灭。被摧毁的世界无法使用。
	--
	-- 返回值：
	--  destroyed: 世界是否毁灭。
	isDestroyed: function(self: World): boolean
	-- 更新世界状况。
	--
	-- 参数：
	--  delta_time: 推进物理模拟的时间（以秒为单位）。
	--  velocity_iterations: 解决碰撞时用于确定新速度的最大步数。 （默认值：8。）
	--  position_iterations: 解决碰撞时用于确定新位置的最大步数。 （默认值：3。）
	update: function(self: World, delta_time: number, velocity_iterations?: integer, position_iterations?: integer)
	-- 设置世界的重力。
	--
	-- 参数：
	--  x: 重力的 x 分量。
	--  y: 重力的 y 分量。
	setGravity: function(self: World, x: number, y: number)
	-- 获取世界的重力。
	--
	-- 返回值：
	--  x: 重力的 x 分量。
	--  y: 重力的 y 分量。
	getGravity: function(self: World): number, number
	-- 设置世界的睡眠行为。
	--
	-- 参数：
	--  allowed: 如果世界上的物体被允许睡觉，则为真，否则为假。
	setSleepingAllowed: function(self: World, allowed: boolean)
	-- 获取世界的睡眠行为。
	--
	-- 返回值：
	--  allow: 如果世界上的物体被允许睡觉，则为真，否则为假。
	isSleepingAllowed: function(self: World): boolean
	-- 通过搜索任何重叠的边界框 (Fixture:getBoundingBox)，为指定区域内的每个灯具调用函数。
	--
	-- 参数：
	--  x1: 左上角点的 x 位置。
	--  y1: 左上角点的 y 位置。
	--  x2: 右下点的 x 位置。
	--  y2: 右下点的 y 位置。
	--  callback: 该函数传递一个参数，即固定装置，并且应该返回一个布尔值。如果为 true，则继续搜索；如果为 false，则停止搜索。
	queryBoundingBox: function(self: World, x1: number, y1: number, x2: number, y2: number, callback: function(any): boolean)
	-- 投射光线并为其相交的每个灯具调用函数。
	--
	-- 重载说明：
	-- 1. LÖVE 0.8.0 中有一个错误，传递给回调函数的法线向量按 love.physics.getMeter.
	--
	-- 参数：
	--  x1: 射线起点的 x 位置。
	--  y1: 射线起点的 x 位置。
	--  x2: 射线终点的 x 位置。
	--  y2: 形状边缘的表面法线向量的 x 值。
	--  callback: 为与光线相交的每个夹具调用的函数。该函数有六个参数，并应返回一个数字作为控制值。输入到函数中的交点将采用任意顺序。如果您希望找到最近的交点，则需要在函数内自行完成。最简单的方法是使用分数值。
	rayCast: function(self: World, x1: number, y1: number, x2: number, y2: number, callback: function(any, number, number, number, number, number): number)
	-- 设置世界更新期间碰撞回调的函数。
	--
	-- 四个 Lua 函数可以作为参数给出。值 nil 删除一个函数。
	--
	-- 调用时，每个函数将传递三个参数。前两个参数是碰撞装置，第三个参数是它们之间的接触。 postSolve 回调还获取每个接触点的法线和切线冲量。参见注释。
	--
	-- 如果您有兴趣了解每个回调的确切调用时间，请参阅 Box2d 手册
	--
	-- 参数：
	--  begin_contact: 当两个灯具开始重叠时被调用。
	--  end_contact: 当两个灯具不再重叠时被调用。当碰撞对象被破坏时，这也会在世界更新之外被调用。
	--  pre_solve: 在冲突解决之前被调用。 （默认值：无。）
	--  post_solve: 冲突解决后被调用。 （默认值：无。）
	setCallbacks: function(self: World, begin_contact?: function(any, any, any), end_contact?: function(any, any, any), pre_solve?: function(any, any, any), post_solve?: function(any, any, any, ...: number))
	-- 返回世界更新期间回调的函数。
	--
	-- 返回值：
	--  beginContact: 当两个灯具开始重叠时被调用。
	--  endContact: 当两个灯具不再重叠时被调用。
	--  preSolve: 在冲突解决之前被调用。
	--  postSolve: 冲突解决后被调用。
	getCallbacks: function(self: World): function(any, any, any) | nil, function(any, any, any) | nil, function(any, any, any) | nil, function(any, any, any, ...: number) | nil
end

-- 将多个物体连接在一起以独特的方式进行交互。
local record Joint
	-- 获取字符串形式的对象类型。
	--
	-- 返回值：
	--  type: 字符串类型。
	type: function(self: Joint): string
	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	--
	-- 参数：
	--  type_name: 要检查的类型的名称。
	--
	-- 返回值：
	--  b: 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Joint, type_name: string): boolean
	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	--
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	--
	-- 返回值：
	--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Joint): boolean
	-- 明确摧毁关节。如果您在调用此函数后尝试使用该对象，将会发生错误。
	--
	-- 在0.7.2中，当你没有时间等待垃圾回收时，这个函数
	--
	-- 可用于立即释放对象。
	destroy: function(self: Joint)
	-- 获取关节是否被破坏。损坏的关节无法使用。
	--
	-- 返回值：
	--  destroyed: 关节是否被破坏。
	isDestroyed: function(self: Joint): boolean
	-- 获取表示类型的字符串。
	--
	-- 返回值：
	--  type: 带有关节类型名称的字符串。
	getType: function(self: Joint): string
	-- 获取关节所附加的实体。
	--
	-- 返回值：
	--  bodyA: 第一个身体。
	--  bodyB: 第二个身体。
	getBodies: function(self: Joint): Body, Body
	-- 获取关节的锚点。
	--
	-- 返回值：
	--  x1: 主体 1 上锚点的 x 分量。
	--  y1: 主体 1 上锚点的 y 分量。
	--  x2: 主体 2 上锚点的 x 分量。
	--  y2: 主体 2 上锚点的 y 分量。
	getAnchors: function(self: Joint): number, number, number, number
	-- 返回第二个物体上的反作用力（以牛顿为单位）
	--
	-- 参数：
	--  inverse_delta_time: 力作用多长时间。通常为反时间步长或 1/dt。
	--
	-- 返回值：
	--  x: 力的 x 分量。
	--  y: 力的 y 分量。
	getReactionForce: function(self: Joint, inverse_delta_time: number): number, number
	-- 返回第二个物体上的反作用扭矩。
	--
	-- 参数：
	--  inverse_delta_time: 力作用多长时间。通常为反时间步长或 1/dt。
	--
	-- 返回值：
	--  torque: 第二个物体上的反作用扭矩。
	getReactionTorque: function(self: Joint, inverse_delta_time: number): number
	-- 获取连接的Bodies是否发生碰撞。
	--
	-- 返回值：
	--  c: 如果碰撞则为 true，否则为 false。
	getCollideConnected: function(self: Joint): boolean
	-- 将 Lua 值与关节相关联。
	--
	-- 要删除引用，请显式传递 nil。
	--
	-- 参数：
	--  value: 与关节关联的 Lua 值。
	setUserData: function(self: Joint, value: any)
	-- 返回与此关节关联的 Lua 值。
	--
	-- 返回值：
	--  value: 与关节关联的 Lua 值。
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

-- 可以真实地模拟二维刚体物理。该模块基于Box2D，并且该API与Box2D API尽可能接近地对应。
local record Physics
	-- 将像素设置为米比例因子。
	--
	-- 物理模块中的所有坐标都除以该数字并转换为米，它创建了一种将对象直接绘制到屏幕上而不需要图形转换的便捷方法。
	--
	-- 建议创建不大于10倍比例的形状。这很重要，因为 Box2D 经过调整，可以很好地处理 0.1 到 10 米的形状尺寸。默认仪表刻度为 30。
	--
	-- 参数：
	--  scale: 整数比例因子。
	setMeter: function(scale: number)
	-- 返回仪表比例因子。
	--
	-- 物理模块中的所有坐标都除以这个数字，创建了一种将对象直接绘制到屏幕上的便捷方法，而无需进行图形转换。
	--
	-- 建议创建不大于10倍比例的形状。这很重要，因为 Box2D 经过调整，可以很好地处理 0.1 到 10 米的形状尺寸。
	--
	-- 返回值：
	--  scale: 整数比例因子。
	getMeter: function(): number
	-- 创造一个新世界。
	--
	-- 参数：
	--  x_gravity: 重力的 x 分量。 （默认值：0。）
	--  y_gravity: 重力的 y 分量。 （默认值：0。）
	--  sleep: 这个世界的身体是否可以睡觉。 （默认值：true。）
	--
	-- 返回值：
	--  world: 美丽的新世界。
	newWorld: function(x_gravity?: number, y_gravity?: number, sleep?: boolean): World
	-- 创建一个新的实体。
	--
	-- 身体分为三种类型。
	--
	-- * 静态物体不移动，具有无限质量，可用于关卡边界。
	--
	-- * 动态物体是模拟中的主要角色，它们与一切物体发生碰撞。
	--
	-- * 运动体不会对力产生反应，只会与动态体发生碰撞。
	--
	-- 连接或移除夹具时会计算主体的质量，但可以随时使用 Body:setMass 或 Body:resetMassData 进行更改。
	--
	-- 参数：
	--  world: 创造身体的世界。
	--  x: 主体的 x 位置。 （默认值：0。）
	--  y: 主体的 y 位置。 （默认值：0。）
	--  body_type: 主体的类型。 （默认：'static'。）
	--
	-- 返回值：
	--  body: 一个新的身体。
	newBody: function(world: World, x?: number, y?: number, body_type?: string): Body
	-- 创建夹具并将其附加到主体。
	--
	-- 请注意，在创建 Fixture 时，Shape 对象被复制而不是保留为引用。要获取 Fixture 拥有的 Shape 对象，请使用 Fixture:getShape。
	--
	-- 参数：
	--  body: 连接固定装置的主体。
	--  shape: 要复制到夹具的形状。
	--  density: 灯具的密度。 （默认值：1。）
	--
	-- 返回值：
	--  fixture: 新的固定装置。
	newFixture: function(body: Body, shape: Shape, density?: number): Fixture
	-- 创建一个新的 CircleShape。
	--
	-- 参数：
	--  first: 圆的 x 位置。
	--  second: 圆的 y 位置。
	--  radius: 圆的半径。
	--
	-- 返回值：
	--  shape: 新形状。
	newCircleShape: function(first: number, second?: number, radius?: number): Shape
	-- 创建矩形 PolygonShapes 的简写。
	--
	-- 默认情况下，本地原点位于矩形的“'center'”，而不是图形的左上角。
	--
	-- 参数：
	--  first: 沿 x 轴的偏移。
	--  second: 沿 y 轴的偏移量。
	--  third: 矩形的宽度。
	--  fourth: 矩形的高度。
	--  angle: 矩形的初始角度。 （默认值：0。）
	--
	-- 返回值：
	--  shape: 一个新的多边形形状。
	newRectangleShape: function(first: number, second: number, third?: number, fourth?: number, angle?: number): Shape
	-- 创建一个新的PolygonShape。
	--
	-- 这个形状最多可以有8个顶点，并且必须形成一个凸形状。
	--
	-- 参数：
	--  first: 用于构造多边形的顶点列表，格式为{x1, y1, x2, y2, x3, y3, ...}。
	--
	-- 返回值：
	--  shape: 一个新的多边形形状。
	newPolygonShape: function(first: number | {number}, ...: number): Shape
	-- 创建一个新的 EdgeShape。
	--
	-- 参数：
	--  x1: 第一个点的 x 位置。
	--  y1: 第一个点的 y 位置。
	--  x2: 第二个点的 x 位置。
	--  y2: 第二个点的 y 位置。
	--
	-- 返回值：
	--  shape: 新形状。
	newEdgeShape: function(x1: number, y1: number, x2: number, y2: number): Shape
	-- 创建一个新的 ChainShape。
	--
	-- 参数：
	--  loop: 如果链应该循环回到第一个点。
	--  first: 用于构造 ChainShape 的点列表，格式为 {x1, y1, x2, y2, ...}。
	--
	-- 返回值：
	--  shape: 新形状。
	newChainShape: function(loop: boolean, first: number | {number}, ...: number): Shape
	-- 在两个实体之间创建一个 DistanceJoint。
	--
	-- 该关节将两个物体上两点之间的距离限制为恒定。这两个点是在世界坐标中指定的，并且在创建此关节时假定两个主体就位。第一个锚点连接到第一主体，第二个锚点连接到第二主体，并且这些点限定距离关节的长度。
	--
	-- 参数：
	--  body1: 第一个连接到关节的主体。
	--  body2: 连接到关节的第二个主体。
	--  x1: 第一个锚点（世界空间）的 x 位置。
	--  y1: 第一个锚点（世界空间）的 y 位置。
	--  x2: 第二个锚点（世界空间）的 x 位置。
	--  y2: 第二个锚点（世界空间）的 y 位置。
	--  collide_connected: 指定两个实体是否应该相互碰撞。 （默认值：假。）
	--
	-- 返回值：
	--  joint: 新的距离关节。
	newDistanceJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean): Joint
	-- 在两个实体之间创建枢轴关节。
	--
	-- 这个关节将两个物体连接到一个点，它们可以围绕该点旋转。
	--
	-- 参数：
	--  body1: 第一具尸体。
	--  body2: 第二具尸体。
	--  x1: 第一个连接点的 x 位置。
	--  y1: 第一个连接点的 y 位置。
	--  x2_or_collide: 第二个连接点的 x 位置。
	--  y2: 第二个连接点的 y 位置。
	--  collide_connected: 指定两个实体是否应该相互碰撞。 （默认值：假。）
	--  reference_angle: body1 和 body2 之间的参考角度，以弧度为单位。 （默认值：0。）
	--
	-- 返回值：
	--  joint: 新的旋转接头。
	newRevoluteJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2_or_collide?: number | boolean, y2?: number, collide_connected?: boolean, reference_angle?: number): Joint
	-- 在两个实体之间创建 PrismaticJoint。
	--
	-- 棱柱关节约束两个实体在指定轴上相对移动。它不允许相对旋转。其定义和操作与旋转关节类似，但用平移和力代替角度和扭矩。
	--
	-- 参数：
	--  body1: 第一个用棱柱关节连接的主体。
	--  body2: 用棱柱关节连接的第二个主体。
	--  x1: 第一个锚点的 x 坐标。
	--  y1: 第一个锚点的 y 坐标。
	--  fifth: 第二个锚点的 x 坐标。
	--  sixth: 第二个锚点的 y 坐标。
	--  axis_x_or_collide: 轴单位向量的x坐标。
	--  axis_y: 轴单位向量的 y 坐标。
	--  collide_connected: 指定两个实体是否应该相互碰撞。 （默认值：假。）
	--  reference_angle: body1 和 body2 之间的参考角度，以弧度为单位。 （默认值：0。）
	--
	-- 返回值：
	--  joint: 新的棱柱形关节。
	newPrismaticJoint: function(body1: Body, body2: Body, x1: number, y1: number, fifth: number, sixth: number, axis_x_or_collide?: number | boolean, axis_y?: number, collide_connected?: boolean, reference_angle?: number): Joint
	-- 在两个实体之间创建约束关节。 WeldJoint 本质上是将两个实体粘合在一起。然而，由于 Box2D 的迭代求解器，约束有点软。
	--
	-- 参数：
	--  body1: 第一个连接到关节的主体。
	--  body2: 连接到关节的第二个主体。
	--  x1: 第一个锚点（世界空间）的 x 位置。
	--  y1: 第一个锚点（世界空间）的 y 位置。
	--  x2_or_collide: 第二个锚点（世界空间）的 x 位置。
	--  y2: 第二个锚点（世界空间）的 y 位置。
	--  collide_connected: 指定两个实体是否应该相互碰撞。 （默认值：假。）
	--  reference_angle: body1 和 body2 之间的参考角度，以弧度为单位。 （默认值：0。）
	--
	-- 返回值：
	--  joint: 新的 WeldJoint。
	newWeldJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2_or_collide?: number | boolean, y2?: number, collide_connected?: boolean, reference_angle?: number): Joint
	-- 在两个物体之间创建摩擦接头。 FrictionJoint 将摩擦力施加到物体上。
	--
	-- 参数：
	--  body1: 第一个连接到关节的主体。
	--  body2: 连接到关节的第二个主体。
	--  x1: 第一个锚点的 x 位置。
	--  y1: 第一个锚点的 y 位置。
	--  x2_or_collide: 第二个锚点的 x 位置。
	--  y2: 第二个锚点的 y 位置。
	--  collide_connected: 指定两个实体是否应该相互碰撞。 （默认值：假。）
	--
	-- 返回值：
	--  joint: 新的摩擦关节。
	newFrictionJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2_or_collide?: number | boolean, y2?: number, collide_connected?: boolean): Joint
	-- 在两个实体之间创建关节。它的唯一功能是强制这些实体之间的最大距离。
	--
	-- 参数：
	--  body1: 第一个连接到关节的主体。
	--  body2: 连接到关节的第二个主体。
	--  x1: 第一个锚点的 x 位置。
	--  y1: 第一个锚点的 y 位置。
	--  x2: 第二个锚点的 x 位置。
	--  y2: 第二个锚点的 y 位置。
	--  max_length: 实体的最大距离。
	--  collide_connected: 指定两个实体是否应该相互碰撞。 （默认值：假。）
	--
	-- 返回值：
	--  joint: 新的 RopeJoint。
	newRopeJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, max_length: number, collide_connected?: boolean): Joint
	-- 创建一个 PulleyJoint 将两个实体相互连接并连接到地面。
	--
	-- 滑轮接头模拟带有可选滑轮组的滑轮。如果比率参数的值不同于 1，则模拟绳索在一侧比另一侧延伸得更快。在滑轮接头中，模拟绳索的总长度为常数 length1 +ratio * length2，该值在创建滑轮接头时设置。
	--
	-- 如果一侧完全伸展，滑轮接头可能会出现不可预测的行为。建议使用 setMaxLengths 方法来限制每条边可以达到的最大长度。
	--
	-- 参数：
	--  body1: 第一个与滑轮接头连接的主体。
	--  body2: 与滑轮接头连接的第二个主体。
	--  ground_x1: 第一个主体的地锚点的 x 坐标。
	--  ground_y1: 第一个主体的地锚的 y 坐标。
	--  ground_x2: 第二个主体的地锚点的 x 坐标。
	--  ground_y2: 第二个物体的地锚点的 y 坐标。
	--  x1: 第一个主体中滑轮关节锚点的 x 坐标。
	--  y1: 第一个主体中滑轮关节锚点的 y 坐标。
	--  x2: 第二个主体中滑轮关节锚点的 x 坐标。
	--  y2: 第二个主体中滑轮关节锚点的 y 坐标。
	--  ratio: 关节比例。 （默认值：1。）
	--  collide_connected: 指定两个实体是否应该相互碰撞。 （默认值：true。）
	--
	-- 返回值：
	--  joint: 新的滑轮接头。
	newPulleyJoint: function(body1: Body, body2: Body, ground_x1: number, ground_y1: number, ground_x2: number, ground_y2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collide_connected?: boolean): Joint
	-- 创建车轮接头。
	--
	-- 参数：
	--  body1: 第一具尸体。
	--  body2: 第二具尸体。
	--  x1: 第一个锚点的 x 位置。
	--  y1: 第一个锚点的 y 位置。
	--  fifth: 第二个锚点的 x 位置。
	--  sixth: 第二个锚点的 y 位置。
	--  axis_x_or_collide: 轴单位向量的 x 位置。
	--  axis_y: 轴单位向量的 y 位置。
	--  collide_connected: 指定两个实体是否应该相互碰撞。 （默认值：假。）
	--
	-- 返回值：
	--  joint: 新的 WheelJoint。
	newWheelJoint: function(body1: Body, body2: Body, x1: number, y1: number, fifth: number, sixth: number, axis_x_or_collide?: number | boolean, axis_y?: number, collide_connected?: boolean): Joint
	-- 在身体和鼠标之间创建一个关节。
	--
	-- 这个关节实际上将身体连接到世界上的一个固定点。为了使其跟随鼠标，固定点必须在每个时间步更新（示例如下）。
	--
	-- 使用 MouseJoint 而不是直接更改身体位置的优点是，对其他关节的碰撞和反应由物理引擎处理。
	--
	-- 参数：
	--  body: 连接到鼠标的主体。
	--  x: 连接点的 x 位置。
	--  y: 连接点的 y 位置。
	--
	-- 返回值：
	--  joint: 新的鼠标关节。
	newMouseJoint: function(body: Body, x: number, y: number): Joint
	-- 在两个实体之间创建一个关节，控制它们之间的相对运动。
	--
	-- 一旦创建了 MotorJoint，就可以指定位置和旋转偏移，以及为达到目标偏移而应用的最大电机力和扭矩。
	--
	-- 参数：
	--  body1: 第一个连接到关节的主体。
	--  body2: 连接到关节的第二个主体。
	--  correction_factor: 关节的初始位置修正系数，取值范围为1。（默认：0.3。）
	--  collide_connected: 指定两个实体是否应该相互碰撞。 （默认值：假。）
	--
	-- 返回值：
	--  joint: 新的 MotorJoint。
	newMotorJoint: function(body1: Body, body2: Body, correction_factor?: number, collide_connected?: boolean): Joint
	-- 创建连接两个关节的 GearJoint。
	--
	-- 齿轮接头连接两个必须是棱柱或旋转接头的接头。使用这个关节需要它使用的关节将各自的身体连接到地面，并以地面作为第一身体。破坏主体和关节时，必须确保先破坏齿轮关节，然后再破坏其他关节。
	--
	-- 齿轮接头具有一个比率，该比率确定所连接接头的角度或距离值如何相互关联。公式坐标 1 + 比率 * 坐标 2 始终具有在创建齿轮接头时设置的常量值。
	--
	-- 参数：
	--  joint1: 第一个与齿轮接头连接的接头。
	--  joint2: 与齿轮接头连接的第二个接头。
	--  ratio: 齿轮比。 （默认值：1。）
	--  collide_connected: 指定两个实体是否应该相互碰撞。 （默认值：假。）
	--
	-- 返回值：
	--  joint: 新的齿轮接头。
	newGearJoint: function(joint1: Joint, joint2: Joint, ratio?: number, collide_connected?: boolean): Joint
end

-- love.graphics 模块的主要职责是将线条、形状、文本、图像和其他可绘制对象绘制到屏幕上。它的次要职责包括将外部文件（包括图像和字体）加载到内存中、创建专用对象（例如粒子系统或画布）以及管理屏幕几何形状。
local record Graphics
	-- 将屏幕或活动画布清除为指定颜色。
	--
	-- 在默认的 love.run 函数中，该函数在 love.draw 之前自动调用。有关此函数的典型用法，请参阅 love.run 中的示例。
	--
	-- 请注意，剪刀区域限制了清除区域。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 在背景颜色之前的版本中。
	--
	-- 重载说明：
	-- 1. 在 0.9.2 及更早版本中将屏幕清除为背景颜色，或在 LÖVE 0.10.0 及更高版本中将屏幕清除为透明黑色 (0, 0, 0, 0)。 2. 将屏幕或活动画布清除为指定颜色。 3. 如果多个画布通过
	-- love.graphics.setCanvas. 同时处于活动状态，则将多个活动画布清除为不同的颜色。使用此函数变体时，必须为每个活动画布指定颜色。 4. 清除模板或深度缓冲区，而无需清除彩色画布。
	--
	-- 参数：
	--  red: {r, g, b, a} 形式的表格，包含要清除第一个活动画布的颜色。
	--  green: 每个活动画布的附加表。
	--  blue: 是否清除活动模板缓冲区（如果存在）。它也可以是 0 到 255 之间的整数，用于将模板缓冲区清除为特定值。 （默认值：true。）
	--  alpha: 是否清除活动深度缓冲区（如果存在）。它也可以是 0 到 1 之间的数字，用于将深度缓冲区清除为特定值。 （默认值：true。）
	clear: function(red?: number, green?: number, blue?: number, alpha?: number)
	-- 丢弃（垃圾）屏幕或活动画布的内容。这是一个具有利基用例的性能优化功能。
	--
	-- 如果活动画布刚刚更改，并且 'replace' BlendMode 将用于绘制覆盖整个屏幕的内容，则调用 love.graphics.discard 而不是调用 love.graphics.clear
	-- 或不执行任何操作可能会提高移动设备上的性能。
	--
	-- 在某些桌面系统上，此功能可能不执行任何操作。
	--
	-- 参数：
	--  discard_color: 是否丢弃活动画布的纹理（如果没有活动画布，则丢弃屏幕的内容。）（默认值：true。）
	--  discard_depth_stencil: 是否丢弃屏幕/活动画布的模板缓冲区的内容。 （默认值：true。）
	discard: function(discard_color?: boolean | {boolean}, discard_depth_stencil?: boolean)
	-- 立即渲染任何挂起的自动批量绘制。
	--
	-- LÖVE 在大多数状态发生变化时会根据需要在内部调用此函数，因此无需手动调用它。
	--
	-- 当前批次将由 love.graphics 状态更改（变换堆栈和当前颜色除外）以及 Shader:send 和纹理上更改其状态的方法自动刷新。在连续的 love.graphics.draw
	-- 调用中使用不同的图像也会刷新当前批次。
	--
	-- SpriteBatches、ParticleSystems、Meshes 和 Text 对象执行自己的批处理，除了在绘制时刷新当前批处理之外，不会影响其他绘制的自动批处理。
	flushBatch: function()
	-- 设置背景颜色。
	--
	-- 参数：
	--  red_or_color: 红色分量 (0-1)。
	--  green: 绿色分量 (0-1)。
	--  blue: 蓝色分量 (0-1)。
	--  alpha: alpha 分量 (0-1)。 （默认值：1。）
	setBackgroundColor: function(red_or_color: number | {number}, green?: number, blue?: number, alpha?: number)
	-- 获取当前背景颜色。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 返回值：
	--  r: 红色分量 (0-1)。
	--  g: 绿色分量 (0-1)。
	--  b: 蓝色分量 (0-1)。
	--  a: alpha 分量 (0-1)。
	getBackgroundColor: function(): number, number, number, number
	-- 设置与图像、画布和字体一起使用的默认缩放过滤器。
	--
	-- 重载说明：
	-- 1. 此功能不适用于已加载的图像。
	--
	-- 参数：
	--  min_filter: 缩小图像时使用的滤镜模式。
	--  mag_filter: 放大图像时使用的滤镜模式。 （默认值：分钟。）
	--  anisotropy: 使用的各向异性过滤的最大数量。 （默认值：1。）
	setDefaultFilter: function(min_filter: string, mag_filter?: string, anisotropy?: number)
	-- 返回与图像、画布和字体一起使用的默认缩放过滤器。
	--
	-- 返回值：
	--  min: 缩小图像时使用的滤镜模式。
	--  mag: 放大图像时使用的滤镜模式。
	--  anisotropy: 使用的各向异性过滤的最大数量。
	getDefaultFilter: function(): string, string, number
	setDefaultMipmapFilter: function(filter?: string, sharpness?: number)
	getDefaultMipmapFilter: function(): string | nil, number
	-- 设置用于绘图的颜色。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 参数：
	--  red: 红色的量。
	--  green: 绿色量。
	--  blue: 蓝色的量。
	--  alpha: Alpha 量。 alpha 值将应用于所有后续的绘制操作，甚至是图像的绘制。 （默认值：1。）
	setColor: function(red: number, green: number, blue: number, alpha?: number)
	-- 获取当前颜色。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 返回值：
	--  r: 红色分量 (0-1)。
	--  g: 绿色分量 (0-1)。
	--  b: 蓝色分量 (0-1)。
	--  a: alpha 分量 (0-1)。
	getColor: function(): number, number, number, number
	-- 设置线宽。
	--
	-- 参数：
	--  width: 线的宽度。
	setLineWidth: function(width: number)
	-- 获取当前线宽。
	--
	-- 重载说明：
	-- 1. 该功能在0.8.0版本中不起作用，但在0.9.0版本中已修复。在 0.8.0 中使用以下代码片段来规避此问题； love.graphics._getLineWidth =
	-- love.graphics.getLineWidth love.graphics._setLineWidth = love.graphics.setLineWidth 函数
	-- love.graphics.getLineWidth() 返回 love.graphics.varlinewidth 或 1 结束函数 love.graphics.setLineWidth(w)
	-- love.graphics.varlinewidth = w; 返回love.graphics._setLineWidth(w)结束
	--
	-- 返回值：
	--  width: 当前线宽。
	getLineWidth: function(): number
	-- 设置线条样式。
	--
	-- 参数：
	--  style: 要使用的线条样式。线条样式包括平滑和粗糙。
	setLineStyle: function(style: string)
	-- 获取线条样式。
	--
	-- 返回值：
	--  style: 当前的线条样式。
	getLineStyle: function(): string
	-- 设置线连接样式。请参阅 LineJoin 了解可能的选项。
	--
	-- 参数：
	--  join: 要使用的 LineJoin。
	setLineJoin: function(join: string)
	-- 获取线连接样式。
	--
	-- 返回值：
	--  join: LineJoin 风格。
	getLineJoin: function(): string
	-- 设置绘图时是否使用线框线。
	--
	-- 参数：
	--  enable: 如果为 True，则在绘制时启用线框模式；如果为 false，则禁用它。
	setWireframe: function(enable: boolean)
	-- 获取绘制时是否使用线框模式。
	--
	-- 返回值：
	--  wireframe: 如果绘制时使用线框线则为 True，否则为 false。
	isWireframe: function(): boolean
	-- 设置磅值。
	--
	-- 参数：
	--  size: 新的磅值。
	setPointSize: function(size: number)
	-- 获取磅值。
	--
	-- 返回值：
	--  size: 当前磅值。
	getPointSize: function(): number
	-- 获取窗口的宽度和高度（以像素为单位）。
	--
	-- 返回值：
	--  width: 窗口的宽度。
	--  height: 窗口的高度。
	getDimensions: function(): number, number
	-- 获取窗口的宽度（以像素为单位）。
	--
	-- 返回值：
	--  width: 窗口的宽度。
	getWidth: function(): number
	-- 获取窗口的高度（以像素为单位）。
	--
	-- 返回值：
	--  height: 窗口的高度。
	getHeight: function(): number
	-- 获取窗口的宽度和高度（以像素为单位）。
	--
	-- love.graphics.getDimensions 获取窗口的尺寸，单位是按屏幕 DPI 比例因子缩放的单位，而不是像素。使用 getDimensions
	-- 进行与绘制到屏幕和使用图形坐标系相关的计算（例如，计算屏幕中心），并且仅在专门处理底层像素时使用 getPixelDimensions（例如，像素着色器中与像素相关的计算）。
	--
	-- 返回值：
	--  pixelwidth: 窗口的宽度（以像素为单位）。
	--  pixelheight: 窗口的高度（以像素为单位）。
	getPixelDimensions: function(): number, number
	-- 获取窗口的宽度（以像素为单位）。
	--
	-- 图形坐标系和DPI比例因子，而不是原始像素。使用 getWidth 进行与绘制到屏幕和使用坐标系相关的计算（例如，计算屏幕中心），并且仅在专门处理底层像素时使用
	-- getPixelWidth（例如，像素着色器中与像素相关的计算）。
	--
	-- 返回值：
	--  pixelwidth: 窗口的宽度（以像素为单位）。
	getPixelWidth: function(): number
	-- 获取窗口的高度（以像素为单位）。
	--
	-- 图形坐标系和DPI比例因子，而不是原始像素。使用 getHeight 进行与绘制到屏幕和使用坐标系相关的计算（例如，计算屏幕中心），并且仅在专门处理底层像素时使用
	-- getPixelHeight（例如，像素着色器中与像素相关的计算）。
	--
	-- 返回值：
	--  pixelheight: 窗口的高度（以像素为单位）。
	getPixelHeight: function(): number
	-- 获取窗口的DPI比例因子。
	--
	-- DPI 比例因子表示相对像素密度。窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600
	-- 窗口相同的物理尺寸，但窗口内的区域使用 1600x1200 像素。在这种情况下，love.graphics.getDPIScale() 将返回 2。
	--
	-- love.window.fromPixels 和 love.window.toPixels 函数也可用于单位之间的转换。
	--
	-- 必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android
	-- 上它实际上始终处于启用状态。
	--
	-- 重载说明：
	-- 1. love.graphics.getWidth、love.graphics.getHeight、love.mouse.getPosition、鼠标事件、love.touch.getPosition
	-- 和触摸事件的单位始终采用 DPI 缩放单位，而不是像素。在 LÖVE 0.10 及更早版本中，它们以像素为单位。
	--
	-- 返回值：
	--  scale: 与窗口关联的像素比例因子。
	getDPIScale: function(): number
	-- 获取可选的图形功能以及系统是否支持它们。
	--
	-- 一些较旧或低端的系统并不总是支持所有图形功能。
	--
	-- 返回值：
	--  features: 包含 GraphicsFeature 键和指示是否支持每个功能的布尔值的表。
	getSupported: function(target?: any): GraphicsFeatures
	-- 获取可用的纹理类型，以及是否支持每种纹理类型。
	--
	-- 返回值：
	--  texturetypes: 包含纹理类型作为键的表，以及指示是否支持该类型作为值的布尔值。并非所有系统都支持所有类型。
	getTextureTypes: function(target?: any): {string: boolean}
	-- 获取可用于图像的原始和压缩像素格式，以及是否支持每种格式。
	--
	-- 返回值：
	--  formats: 包含 PixelFormats 作为键的表，以及一个指示是否支持该格式作为值的布尔值。并非所有系统都支持所有格式。
	getImageFormats: function(target?: any): {string: boolean}
	-- 获取有关系统显卡和驱动程序的信息。
	--
	-- 返回值：
	--  name: 渲染器的名称，例如'OpenGL' 或 'OpenGL ES'。
	--  version: 渲染器的版本，带有一些额外的依赖于驱动程序的版本信息，例如'2.1 INTEL-8.10.44'。
	--  vendor: 显卡供应商的名称，例如'Intel Inc'。
	--  device: 显卡的名称，例如'Intel HD Graphics 3000 OpenGL Engine'。
	getRendererInfo: function(): string, string, string, string
	-- 获取 love.graphics 功能的系统相关最大值。
	--
	-- 返回值：
	--  limits: 包含 GraphicsLimit 键和数值的表。
	getSystemLimits: function(target?: any): GraphicsSystemLimits
	-- 获取与性能相关的渲染统计信息。
	--
	-- 重载说明：
	-- 1. 此变体接受现有表进行填充，而不是创建新表。
	--
	-- 参数：
	--  target: 将用下面的统计字段填充的表格。
	--
	-- 返回值：
	--  stats: 包含以下字段的表：取决于重载：上面传入的表，现在包含以下字段：
	getStats: function(target?: any): GraphicsStats
	-- 当前帧完成后（love.draw 完成后）创建屏幕截图。
	--
	-- 由于此函数将屏幕截图放入队列而不是立即执行它，因此可以从输入回调或 love.update 调用它，并且它仍然会捕获该帧中绘制到屏幕上的所有内容。
	--
	-- 重载说明：
	-- 1. 截取屏幕截图并将其保存到当前帧末尾的文件中。 2. 捕获屏幕截图并在当前帧末尾使用生成的 ImageData 调用回调。 3. 截图并将生成的ImageData推送到当前帧末尾的Channel中。
	--
	-- 参数：
	--  filename_callback_or_channel: 保存屏幕截图的文件名。编码图像类型根据文件名的扩展名确定，并且必须是 ImageFormat 之一。取决于重载：捕获屏幕截图后调用的函数。 ImageData
	--                                作为唯一参数传递到函数中。取决于过载：将生成的 ImageData 推送到的 Channel。
	captureScreenshot: function(filename_callback_or_channel: string | function(image_data: ImageData) | Channel)
	-- 绘制一个矩形。
	--
	-- 重载说明：
	-- 1. 绘制一个圆角矩形。
	--
	-- 参数：
	--  mode: 如何绘制矩形。
	--  x: 左上角沿x轴的位置。
	--  y: 左上角沿 y 轴的位置。
	--  width: 矩形的宽度。
	--  height: 矩形的高度。
	rectangle: function(mode: string, x: number, y: number, width: number, height: number)
	-- 画一个圆。
	--
	-- 参数：
	--  mode: 如何画圆。
	--  x: 中心沿 x 轴的位置。
	--  y: 中心沿 y 轴的位置。
	--  radius: 圆的半径。
	circle: function(mode: string, x: number, y: number, radius: number)
	-- 在位置 (x, y) 处绘制填充或未填充的圆弧。弧线以弧度为单位从角度 1 到角度 2 绘制。段参数确定使用多少段来绘制圆弧。分段越多，边缘越平滑。
	--
	-- 重载说明：
	-- 1. 使用'pie' ArcType 绘制圆弧。
	--
	-- 参数：
	--  mode: 如何绘制圆弧。
	--  arc_mode_or_x: 要绘制的圆弧类型。
	--  y_or_x: 中心沿 x 轴的位置。
	--  radius_or_y: 中心沿 y 轴的位置。
	--  angle1_or_radius: 圆弧半径。
	--  angle2_or_angle1: 圆弧开始的角度。
	--  segments_or_angle2: 圆弧终止的角度。
	--  segments: 用于绘制圆弧的段数。 （默认值：10。）
	arc: function(mode: string, arc_mode_or_x: string | number, y_or_x: number, radius_or_y: number, angle1_or_radius: number, angle2_or_angle1: number, segments_or_angle2?: number, segments?: integer)
	-- 绘制一个椭圆。
	--
	-- 参数：
	--  mode: 如何绘制椭圆。
	--  x: 中心沿 x 轴的位置。
	--  y: 中心沿 y 轴的位置。
	--  radius_x: 椭圆沿 x 轴的半径（椭圆宽度的一半）。
	--  radius_y: 椭圆沿 y 轴的半径（椭圆高度的一半）。
	--  segments: 用于绘制椭圆的线段数。
	ellipse: function(mode: string, x: number, y: number, radius_x: number, radius_y: number, segments?: integer)
	-- 在点之间绘制线。
	--
	-- 参数：
	--  x1: x 轴上第一个点的位置。
	--  y1: y 轴上第一个点的位置。
	--  x2: x 轴上第二个点的位置。
	--  y2: y 轴上第二个点的位置。
	--  coordinates: 您可以继续通过点位置来绘制折线。
	line: function(x1: number, y1: number, x2: number, y2: number, coordinates: number...)
	-- 画一个多边形。
	--
	-- 在模式参数之后，该函数可以接受多个数字参数或单个数字参数表。无论哪种情况，参数都被解释为多边形顶点的交替 x 和 y 坐标。
	--
	-- 参数：
	--  mode: 如何绘制多边形。
	--  x1: 多边形的顶点。取决于重载：将多边形的顶点作为表格。
	polygon: function(mode: string, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, coordinates: number...)
	-- 绘制一个或多个点。
	--
	-- 重载说明：
	-- 1. 绘制一个或多个单独着色的点。在 11.0 之前的版本中，颜色分量值的范围是 0 到 255，而不是 0 到 1。像素网格实际上偏移到每个像素的中心。因此，要获得干净的像素绘制，请使用 0.5 +
	-- 整数增量。点不受大小影响，始终以像素为单位。
	--
	-- 参数：
	--  x1: x 轴上第一个点的位置。
	--  y1: y 轴上第一个点的位置。
	--  coordinates: 附加点的 x 和 y 坐标。
	points: function(x1: number, y1: number, coordinates: number...)
	-- 在屏幕上显示绘图操作的结果。
	--
	-- 在编写自己的 love.run 函数时使用该函数。它在屏幕上显示绘图操作的所有结果。有关此函数的典型用法，请参阅 love.run 中的示例。
	--
	-- 重载说明：
	-- 1. * 如果 love.window.setMode 的 vsync 等于 true，则该函数的运行频率不能高于刷新率（例如 60 Hz），并且将暂停程序直到准备就绪（如有必要）。
	present: function()
	-- 复制当前坐标变换并将其推入变换堆栈。
	--
	-- 这个函数总是用来为后面相应的出栈操作做准备。它将当前坐标变换状态存储到变换堆栈中并保持其活动状态。稍后对变换所做的更改可以通过使用 pop 操作来撤消，该操作会将坐标变换返回到调用 push 之前的状态。
	--
	-- 重载说明：
	-- 1. 将当前转换推入转换堆栈。 2. 将特定类型的状态压入堆栈。
	--
	-- 参数：
	--  stack_type: 要推送的堆栈类型（例如，仅转换状态，或所有 love.graphics 状态）。
	push: function(stack_type?: string)
	-- 从变换堆栈中弹出当前坐标变换。
	--
	-- 该函数始终用于反转先前的推送操作。它将当前转换状态返回到上次推送之前的状态。
	pop: function()
	-- 获取变换/状态堆栈的当前深度（没有相应弹出的压入次数）。
	--
	-- 返回值：
	--  depth: 变换和状态 love.graphics 堆栈的当前深度。
	getStackDepth: function(): integer
	-- 重置当前坐标变换。
	--
	-- 此函数始终用于反转任何先前对 love.graphics.rotate、love.graphics.scale、love.graphics.shear 或 love.graphics.translate.
	-- 的调用，它将当前转换状态返回为其默认值。
	origin: function()
	-- 将坐标系转换为二维。
	--
	-- 当使用两个数字 dx 和 dy 调用此函数时，以下所有绘图操作都会生效，就好像它们的 x 和 y 坐标为 x+dx 和 y+dy 一样。
	--
	-- 缩放和平移不是可交换操作，因此，以不同的顺序调用它们将改变结果。
	--
	-- 此更改将持续到 love.draw() 退出，否则 love.graphics.pop 恢复为之前的 love.graphics.push.
	--
	-- 使用整数进行翻译将防止翻译后绘制的图像和字体出现撕裂/模糊。
	--
	-- 参数：
	--  dx: 相对于 x 轴的平移。
	--  dy: 相对于 y 轴的平移。
	translate: function(dx: number, dy: number)
	-- 二维旋转坐标系。
	--
	-- 调用此函数会通过将坐标系围绕原点旋转给定的弧度来影响所有将来的绘图操作。此更改将持续到 love.draw() 退出为止。
	--
	-- 参数：
	--  angle: 坐标系的旋转量（以弧度为单位）。
	rotate: function(angle: number)
	-- 在二维中缩放坐标系。
	--
	-- LÖVE中的坐标系默认与水平和垂直方向的显示像素一一对应，x轴向右增大，y轴向下增大。缩放坐标系会改变这种关系。
	--
	-- 经过 sx 和 sy 缩放后，所有坐标都被视为乘以 sx 和 sy。绘图操作的每个结果也会相应地缩放，因此例如缩放 (2, 2) 意味着将所有内容在 x 和 y
	-- 方向上放大两倍。按负值缩放会沿相应方向翻转坐标系，这也意味着所有内容都将被翻转或颠倒或两者都绘制。按零缩放并不是一个有用的操作。
	--
	-- 缩放和平移不是可交换操作，因此，以不同的顺序调用它们将改变结果。
	--
	-- 缩放持续到 love.draw() 退出。
	--
	-- 参数：
	--  sx: x轴方向的缩放。
	--  sy: y轴方向的缩放。如果省略，则默认与参数 sx 相同。 （默认值：sx。）
	scale: function(sx: number, sy?: number)
	-- 剪切坐标系。
	--
	-- 参数：
	--  kx: x 轴上的剪切因子。
	--  ky: y 轴上的剪切因子。
	shear: function(kx: number, ky: number)
	-- 将给定的 Transform 对象应用于当前坐标变换。
	--
	-- 这有效地将现有坐标变换的矩阵与 Transform 对象的内部矩阵相乘以产生新的坐标变换。
	--
	-- 参数：
	--  transform: 应用于当前图形坐标变换的 Transform 对象。
	applyTransform: function(transform: Transform)
	-- 用给定的 Transform 对象替换当前的坐标变换。
	--
	-- 参数：
	--  transform: 用于替换当前图形坐标变换的 Transform 对象。
	replaceTransform: function(transform: Transform)
	-- 将给定的 2D 位置从全局坐标转换为屏幕空间。
	--
	-- 这有效地将当前图形变换应用于给定位置。 Transform 对象也存在类似的 Transform:transformPoint 方法。
	--
	-- 参数：
	--  x: 全局坐标中位置的 x 分量。
	--  y: 全局坐标中位置的 y 分量。
	--
	-- 返回值：
	--  screenX: 应用了图形变换的位置的 x 分量。
	--  screenY: 应用了图形变换的位置的 y 分量。
	transformPoint: function(x: number, y: number): number, number
	-- 将给定的 2D 位置从屏幕空间转换为全局坐标。
	--
	-- 这有效地将当前图形变换的反向应用到给定位置。 Transform 对象也存在类似的 Transform:inverseTransformPoint 方法。
	--
	-- 参数：
	--  x: 屏幕空间位置的 x 分量。
	--  y: 屏幕空间位置的 y 分量。
	--
	-- 返回值：
	--  globalX: 全局坐标中位置的 x 分量。
	--  globalY: 全局坐标中位置的 y 分量。
	inverseTransformPoint: function(x: number, y: number): number, number
	-- 获取图形模块是否可以使用。如果未激活，love.graphics 函数和方法调用将无法正常工作，并可能导致程序崩溃。如果窗口未打开，或者应用程序在 iOS
	-- 上处于后台，则图形模块处于非活动状态。通常，在后一种情况下，应用程序的执行将被系统自动暂停。
	--
	-- 返回值：
	--  active: 图形模块是否处于活动状态并且可以使用。
	isActive: function(): boolean
	isCreated: function(): boolean
	-- 获取是否支持并启用伽玛校正渲染。可以通过在 love.conf.
	--
	-- 并非所有设备都支持伽玛校正渲染，在这种情况下它将自动禁用，并且此函数将返回 false。它在具有能够使用 OpenGL 3 / DirectX 10 的显卡的桌面系统以及可以使用 OpenGL ES 3 的 iOS
	-- 设备上受支持。
	--
	-- 重载说明：
	-- 1. 启用伽马校正渲染后，许多函数和对象会在 sRGB 和线性 RGB 之间执行自动颜色转换，以便混合和着色器数学在数学上正确（如果未启用，则不会。） * 传递的颜色从 sRGB 转换为线性 RGB。 *
	-- 当绘制这些对象时，文本中设置的每个字符颜色、每个点颜色的点、使用 'VertexColor' 属性名称的标准自定义网格将自动从 sRGB 转换为线性 RGB。 * 创建图像。 * 绘制到屏幕上的所有内容都将以线性 RGB
	-- 混合，然后结果将转换为 sRGB 进行显示。 * 使用 'normal' 或 'srgb' CanvasFormat 的画布将其内容以线性 RGB 混合，并且在绘制时结果将以 sRGB
	-- 形式存储在画布中。当画布本身被绘制时，其像素颜色将以与图像相同的方式从 sRGB 转换为线性 RGB。与 'rgba8' 相比，将画布像素数据存储为 sRGB
	-- 可以为较暗的颜色提供更好的精度（更少的条带）。由于大多数转换都是自动处理的，因此当启用伽玛校正渲染时，您自己的代码无需担心 sRGB 和线性 RGB 颜色转换，除非在
	--     a couple cases: * 如果使用具有自定义顶点属性的网格体，并且其中一个属性应为
	-- 在着色器中用作颜色，并且该属性未命名为 'VertexColor'。 * 如果使用的着色器具有统一/外部变量或其他用作颜色的变量，则不使用 Shader:sendColor
	-- 。在这两种情况下，love.math.gammaToLinear 可用于在 Lua 代码中将颜色值转换为线性 RGB，或者可在着色器代码内部使用 gammaCorrectColor（或
	-- unGammaCorrectColor，如果需要）着色器函数。如果确实启用了伽玛校正渲染，则这些着色器函数“'only'”会进行转换。如果是这样，将设置 LOVE_GAMMA_CORRECT
	-- 着色器预处理器定义。请在此处、此处和此处阅读有关伽玛校正渲染的更多信息。
	--
	-- 返回值：
	--  gammacorrect: 如果支持伽玛校正渲染并在 love.conf 中启用，则为 true，否则为 false。
	isGammaCorrect: function(): boolean
	-- 重置当前图形设置。
	--
	-- 调用reset使当前绘图颜色为白色，当前背景颜色为黑色，禁用任何活动的颜色组件蒙版，禁用线框模式并将当前图形变换重置为原点。它还将点和线绘制模式设置为平滑，并将它们的大小设置为 1.0。
	reset: function()
	-- 设置混合模式。
	--
	-- 重载说明：
	-- 1. 通常应首选默认的 'alphamultiply' alpha 模式，除非使用预乘 alpha 绘制内容。如果使用 'alphamultiply' 模式将内容绘制到 Canvas，则 Canvas 纹理随后将具有预乘
	-- alpha，因此在将 Canvas 绘制到屏幕时通常应使用 'premultiplied' alpha 模式。
	--
	-- 参数：
	--  mode: 要使用的混合模式。
	--  alpha_mode: 混合时如何处理绘制对象的 Alpha。 （默认：'alphamultiply'。）
	setBlendMode: function(mode: string, alpha_mode?: string)
	-- 获取混合模式。
	--
	-- 返回值：
	--  mode: 当前的混合模式。
	--  alphamode: 当前混合 Alpha 模式 – 它确定绘制对象的 Alpha 如何影响混合。
	getBlendMode: function(): string, string
	-- 设置或禁用剪刀。
	--
	-- 剪刀将绘图区域限制在指定的矩形内。这会影响所有图形调用，包括 love.graphics.clear.
	--
	-- 剪刀的尺寸不受图形变换（平移、缩放……）的影响。
	--
	-- 重载说明：
	-- 1. 将绘图区域限制在指定的矩形内。 2. 禁用剪刀。
	--
	-- 参数：
	--  x: 左上角的x坐标。
	--  y: 左上角的y坐标。
	--  width: 剪切矩形的宽度。
	--  height: 剪切矩形的高度。
	setScissor: function(x?: number, y?: number, width?: number, height?: number)
	-- 获取当前剪刀框。
	--
	-- 返回值：
	--  x: 框左上角点的 x 分量。
	--  y: 框左上角点的 y 分量。
	--  width: 框的宽度。
	--  height: 盒子的高度。
	getScissor: function(): number | nil, number | nil, number | nil, number | nil
	-- 将剪刀设置为由指定矩形与现有剪刀相交而创建的矩形。如果还没有激活的剪刀，则其行为类似于 love.graphics.setScissor.
	--
	-- 剪刀将绘图区域限制在指定的矩形内。这会影响所有图形调用，包括 love.graphics.clear.
	--
	-- 剪刀的尺寸不受图形变换（平移、缩放……）的影响。
	--
	-- 参数：
	--  x: 与现有剪刀矩形相交的矩形左上角的 x 坐标。
	--  y: 与现有剪刀矩形相交的矩形左上角的 y 坐标。
	--  width: 与现有剪刀矩形相交的矩形的宽度。
	--  height: 与现有剪刀矩形相交的矩形的高度。
	intersectScissor: function(x: number, y: number, width: number, height: number)
	-- 设置颜色遮罩。渲染和清除屏幕时启用或禁用特定颜色组件。例如，如果“'red''' is set to '''false'”，则不会对任何像素的红色分量进行进一步的更改。
	--
	-- 重载说明：
	-- 1. 启用指定颜色分量的颜色屏蔽。 2. 禁用颜色掩蔽。
	--
	-- 参数：
	--  red: 渲染红色分量。
	--  green: 渲染绿色组件。
	--  blue: 渲染蓝色分量。
	--  alpha: 渲染 alpha 分量。
	setColorMask: function(red?: boolean, green?: boolean, blue?: boolean, alpha?: boolean)
	-- 获取绘图时使用的活动颜色分量。通常，除非使用 love.graphics.setColorMask，否则所有 4 个组件均处于活动状态。
	--
	-- 颜色掩码确定绘制对象的颜色的各个分量是否会影响屏幕的颜色。它们也会影响 love.graphics.clear 和 Canvas:clear 。
	--
	-- 返回值：
	--  r: 渲染时红色分量是否处于活动状态。
	--  g: 渲染时绿色分量是否处于活动状态。
	--  b: 渲染时蓝色分量是否处于活动状态。
	--  a: 渲染时 Alpha 颜色分量是否处于活动状态。
	getColorMask: function(): boolean, boolean, boolean, boolean
	-- 配置深度测试并写入深度缓冲区。
	--
	-- 这是低级功能，设计用于自定义顶点着色器和具有自定义顶点属性的网格。没有提供更高级别的 API 来设置 2D 图形（例如形状、线条和图像）的深度。
	--
	-- 重载说明：
	-- 1. 禁用深度测试和深度写入。
	--
	-- 参数：
	--  compare: 用于深度测试的深度比较模式。
	--  write: 渲染时是否将更新/写入值写入深度缓冲区。
	setDepthMode: function(compare?: string, write?: boolean)
	-- 获取当前深度测试模式以及是否启用写入深度缓冲区。
	--
	-- 这是低级功能，设计用于自定义顶点着色器和具有自定义顶点属性的网格。没有提供更高级别的 API 来设置 2D 图形（例如形状、线条和图像）的深度。
	--
	-- 返回值：
	--  comparemode: 用于深度测试的深度比较模式。
	--  write: 渲染时是否将更新/写入值写入深度缓冲区。
	getDepthMode: function(): string, boolean
	-- 设置是否剔除网格中的背面三角形。
	--
	-- 它设计用于通过网格上的自定义顶点属性、自定义顶点着色器以及使用深度缓冲区进行深度测试来与低级自定义硬件加速 3D 渲染一起使用。
	--
	-- 默认情况下，网格中的正面和背面三角形都会被渲染。
	--
	-- 参数：
	--  mode: 要使用的网格面剔除模式（是否渲染所有内容、剔除背面三角形或剔除正面三角形）。
	setMeshCullMode: function(mode: string)
	-- 获取网格中的背面三角形是否被剔除。
	--
	-- 网格面剔除旨在通过网格上的自定义顶点属性、自定义顶点着色器以及使用深度缓冲区的深度测试与低级自定义硬件加速 3D 渲染一起使用。
	--
	-- 返回值：
	--  mode: 使用中的网格面剔除模式（是否渲染所有内容、剔除背面三角形或剔除正面三角形）。
	getMeshCullMode: function(): string
	-- 设置是否将具有顺时针或逆时针顺序顶点的三角形视为正面。
	--
	-- 这是设计用于与网格面剔除结合使用的。其他 love.graphics 形状、线条和精灵不保证其内部顶点具有特定的缠绕顺序。
	--
	-- 参数：
	--  winding: 使用的绕线模式。默认绕线为逆时针方向 ('ccw')。
	setFrontFaceWinding: function(winding: string)
	-- 获取具有顺时针或逆时针顺序顶点的三角形是否被视为正面。
	--
	-- 这是设计用于与网格面剔除结合使用的。其他 love.graphics 形状、线条和精灵不保证其内部顶点具有特定的缠绕顺序。
	--
	-- 返回值：
	--  winding: 使用的绕线模式。默认绕线为逆时针方向 ('ccw')。
	getFrontFaceWinding: function(): string
	-- 将几何图形绘制为模板。
	--
	-- 所提供的函数绘制的几何图形设置像素的不可见模板值，而不是设置像素颜色。模板缓冲区（包含这些模板值）可以像蒙版/模板一样工作 - 随后可以使用 love.graphics.setStencilTest
	-- 来确定每个像素中的模板值如何影响进一步的渲染。
	--
	-- 模板值是 255 范围内的整数。
	--
	-- 重载说明：
	-- 1. 通过在 stencil 函数中使用 love.graphics.setColorMask 来启用对所有颜色分量的绘制，可以同时绘制到屏幕和像素的模板值。
	--
	-- 参数：
	--  draw: 绘制几何图形的函数。像素的模板值，而不是每个像素的颜色，将受到几何形状的影响。
	--  action: 如何修改模板函数中绘制的内容所涉及的像素的任何模板值。 （默认：'replace'。）
	--  value: 如果使用 'replace' 模板操作，则用于像素的新模板值。对其他模板操作没有影响。必须介于 0 到 255 之间。（默认值：1。）
	--  keep_values_or_clear_value: 如果为 true，则保留像素的旧模板值；如果为 false，则在执行模板函数之前将每个像素的模板值重新设置为 0。 love.graphics.clear
	--                              还将重置所有模板值。 （默认值：假。）
	stencil: function(draw: function(), action?: string, value?: integer, keep_values_or_clear_value?: boolean | integer)
	-- 配置或禁用模板测试。
	--
	-- 当启用模板测试时，之后绘制的所有内容的几何图形都将根据该函数的参数与几何图形接触的每个像素的模板值之间的比较被剪裁/模板化。像素的模板值受 love.graphics.stencil.
	--
	-- 重载说明：
	-- 1. 禁用模板测试。
	--
	-- 参数：
	--  compare: 对每个像素进行比较的类型。
	--  value: 与每个像素的模板值进行比较时使用的值。必须介于 0 到 255 之间。
	setStencilTest: function(compare?: string, value?: integer)
	-- 获取当前模板测试配置。
	--
	-- 当启用模板测试时，之后绘制的所有内容的几何图形都将根据该函数的参数与几何图形接触的每个像素的模板值之间的比较被剪裁/模板化。像素的模板值受 love.graphics.stencil.
	--
	-- 每个画布都有自己的每像素模板值。
	--
	-- 返回值：
	--  comparemode: 对每个像素进行的比较类型。如果禁用模板测试，则将为 'always'。
	--  comparevalue: 与每个像素的模板值进行比较时使用的值。
	getStencilTest: function(): string, integer
	-- 从 TrueType 字体或 BMFont 文件创建新字体。创建的字体不会被缓存，因为使用相同的参数调用此函数将始终创建一个新的 Font 对象。
	--
	-- 所有接受文件名的变体也可以接受数据对象。
	--
	-- 重载说明：
	-- 1. 创建新的 BMFont 或 TrueType 字体。如果文件是 TrueType 字体，则其大小将为 12。使用下面的变体创建具有自定义大小的 TrueType 字体。 2. 创建新的 TrueType 字体。 3.
	-- 创建一个新的BMFont。 4. 创建具有自定义大小的默认字体 (Vera Sans) 的新实例。
	--
	-- 参数：
	--  filename_or_size: BMFont 文件的文件路径。
	--  size: 字体大小（以像素为单位）。取决于过载：字体的大小（以像素为单位）。 （默认值：12。）
	--
	-- 返回值：
	--  font: 可用于在屏幕上绘制文本的 Font 对象。
	newFont: function(filename_or_size?: string | number, size?: integer): Font
	-- 创建并设置新字体。
	--
	-- 参数：
	--  filename_or_size: 字体文件的路径和名称。根据过载：带有字体的文件。 取决于重载：带有字体的数据。
	--  size: 字体大小。 （默认值：12。）
	--
	-- 返回值：
	--  font: 新字体。
	setNewFont: function(filename_or_size?: string | number, size?: integer): Font
	-- 创建一个新的特定格式的图像。
	--
	-- 在 0.9.0 之前的版本中，LÖVE 期望字形字符串采用 ISO 8859-1 编码。
	--
	-- 参数：
	--  source_or_rasterizer: 图像文件的文件路径。取决于重载：用于创建字体的 ImageData 对象。
	--  glyphs: 图像中从左到右排列的字符字符串。
	--  extra_spacing: 应用于字体中每个字形的附加间距（正或负）。 （默认值：0。）
	--
	-- 返回值：
	--  font: 可用于在屏幕上绘制文本的 Font 对象。
	newImageFont: function(source_or_rasterizer: string | FileData | ImageData | Rasterizer, glyphs?: string, extra_spacing?: integer, dpi_scale?: number): Font
	-- 创建一个新的可绘制文本对象。
	--
	-- 参数：
	--  font: 用于文本的字体。
	--  text: 新 Text 对象将包含的初始文本字符串。可能为零。 （默认值：nil。）取决于重载：包含要添加到对象的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
	--  text.color1: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
	--  text.string1: 文本字符串，其颜色由前一个颜色指定。
	--  text.color2: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。
	--  text.string2: 文本字符串，其颜色由前一个颜色指定。
	--  text....: 附加颜色和字符串。
	--
	-- 返回值：
	--  text: 新的可绘制文本对象。
	newText: function(font: Font, text?: any): Text
	-- 将已加载的字体设置为当前字体，或根据文件和大小创建并加载新字体。
	--
	-- 建议在加载阶段使用 love.graphics.newFont 创建 Font 对象，然后在绘图阶段传递给此函数。
	--
	-- 参数：
	--  font: 要使用的 Font 对象。
	setFont: function(font: Font)
	-- 获取当前的 Font 对象。
	--
	-- 返回值：
	--  font: 当前字体。自动创建并设置默认字体（如果尚未设置）。
	getFont: function(): Font
	-- 在屏幕上绘制文本。如果未设置字体，则将根据需要创建并设置（一次）字体。
	--
	-- 从 LOVE 0.7.1 开始，当在绘制文本时使用平移和缩放函数时，此函数假设首先发生缩放。如果您在编写脚本时没有考虑到这一点，则文本将不会位于正确的位置，甚至可能不会出现在屏幕上。
	--
	-- love.graphics.print 和 love.graphics.printf 均支持 UTF-8 编码。您还需要适合特殊字符的字体。
	--
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	--
	-- 重载说明：
	-- 1. love.graphics.setColor 设置的颜色将与文本的颜色组合（相乘）。
	--
	-- 参数：
	--  text: 要绘制的文本。
	--  x: 绘制对象的位置（x 轴）。 （默认值：0。）取决于过载：文本在 x 轴上的位置。 （默认值：0。）
	--  y: 绘制对象的位置（y 轴）。 （默认值：0。）取决于过载：文本在 y 轴上的位置。 （默认值：0。）
	--  angle: 以弧度表示的文本方向。 （默认值：0。）
	--  scale_x: 比例因子（x 轴）。 （默认值：1。）取决于过载：x 轴上的比例因子。 （默认值：1。）
	--  scale_y: 比例因子（y 轴）。 （默认值：sx。）取决于过载：y 轴上的比例因子。 （默认值：sx。）
	--  origin_x: 原点偏移（x 轴）。 （默认值：0。）取决于过载：x 轴上的原点偏移。 （默认值：0。）
	--  origin_y: 原点偏移（y 轴）。 （默认值：0。）取决于过载：y 轴上的原点偏移。 （默认值：0。）
	--  shear_x: 剪切因子（x 轴）。 （默认值：0。）取决于过载：x 轴上的剪切/倾斜系数。 （默认值：0。）
	--  shear_y: 剪切因子（y 轴）。 （默认值：0。）取决于过载：y 轴上的剪切/倾斜系数。 （默认值：0。）
	print: function(text: string | number, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)
	-- 绘制格式化文本，并进行自动换行和对齐。
	--
	-- 请参阅 love.graphics.print.
	--
	-- 在任何缩放、旋转和其他坐标转换之前应用自动换行限制。因此，即使比例参数发生变化，在给定相同的换行限制的情况下，每行的文本量也保持不变。
	--
	-- 在版本 0.9.2
	-- 及更早版本中，换行是通过用空格分隔单词并将它们重新组合在一起来实现的，以确保事物在提供的限制内很好地契合。但是，由于这样做的方式，在屏幕上打印时，单词之间的额外空格最终会丢失，并且某些行可能会溢出超过提供的换行限制。在
	-- 0.10.0 及更高版本中，情况不再如此。
	--
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	--
	-- 重载说明：
	-- 1. love.graphics.setColor 设置的颜色将与文本的颜色组合（相乘）。
	--
	-- 参数：
	--  text: 文本字符串。
	--  x: x 轴上的位置。取决于过载：文本的位置（x 轴）。
	--  y: y 轴上的位置。取决于过载：文本的位置（y 轴）。
	--  limit: 在这么多水平像素之后换行。取决于过载：自动换行之前文本的最大宽度（以像素为单位）。
	--  align: 对齐。 （默认值：'left'。）取决于重载：文本的对齐方式。
	--  angle: 方向（弧度）。 （默认值：0。）
	--  scale_x: 比例因子（x 轴）。 （默认值：1。）
	--  scale_y: 比例因子（y 轴）。 （默认值：sx。）
	--  origin_x: 原点偏移（x 轴）。 （默认值：0。）
	--  origin_y: 原点偏移（y 轴）。 （默认值：0。）
	--  shear_x: 剪切因子（x 轴）。 （默认值：0。）取决于过载：剪切/倾斜系数（x 轴）。 （默认值：0。）
	--  shear_y: 剪切因子（y 轴）。 （默认值：0。）取决于过载：剪切/倾斜系数（y 轴）。 （默认值：0。）
	printf: function(text: string | number, x: number, y: number, limit: number, align?: string, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)
	-- 从文件路径、FileData、ImageData 或 CompressedImageData 创建新图像，并可选择生成或指定图像的 mipmap。
	--
	-- 参数：
	--  filename_or_data: 图像文件的文件路径。根据重载：包含图像文件的 FileData。 取决于重载：包含图像的 ImageData。根据重载：一个 CompressedImageData 对象。当调用
	--                    love.window.setMode 时，Image 将使用此 CompressedImageData 重新加载自身。
	--  settings: 包含以下字段的表：（默认值：nil。）
	--  settings.dpiscale: 绘制图像和调用 getWidth/getHeight 时使用的 DPI 比例。 （默认值：1。）
	--  settings.linear: 如果启用伽马校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。）
	--  settings.mipmaps: 如果为 true，将自动生成图像的 mipmap（如果可能，如果图像源自 CompressedImageData，则从图像文件中获取）。 （默认值：假。）
	--
	-- 返回值：
	--  image: 一个可以在屏幕上绘制的新图像对象。
	newImage: function(filename_or_data: string | FileData | ImageData | CompressedImageData, settings?: LayeredImageSettings): Image
	-- 创建一个新的可绘制视频。目前仅支持 Ogg Theora 视频文件。
	--
	-- 参数：
	--  filename_or_stream: Ogg Theora 视频文件（或 VideoStream）的文件路径。取决于过载：Ogg Theora 视频文件的文件路径。取决于过载：视频流对象。
	--  settings: 包含以下字段的表：（默认值：nil。）
	--  settings.audio: 是否尝试将视频的音频加载到音频源中。如果未明确设置为 true 或 false，则如果视频没有音频，它将尝试，而不会导致错误。 （默认值：假。）
	--  settings.dpiscale: 视频的 DPI 比例因子。 （默认：love.graphics.getDPIScale()。）
	--
	-- 返回值：
	--  video: 一个新视频。
	newVideo: function(filename_or_stream: string | VideoStream, settings?: any): Video
	_newVideo: function(filename_or_stream: string | VideoStream, dpi_scale?: number): Video
	-- 创建一个新的数组图像。
	--
	-- 数组图像/数组纹理是包含多个 'layers' 或 'slices' 2D 子图像的单个对象。它可以被认为类似于纹理图集或精灵表，但它不会遭受与纹理图集相同的平铺/四边形渗色伪影的影响 - 尽管每个子图像必须具有相同的尺寸。
	--
	-- 阵列图像的特定层可以使用 love.graphics.drawLayer / SpriteBatch:addLayer 绘制，或者使用 love.graphics.draw 和 Quad:setLayer 的 Quad
	-- 变体，或者通过自定义着色器绘制。
	--
	-- 要在Shader 中使用数组图像，必须将其声明为ArrayImage 或sampler2DArray 类型（而不是Image 或sampler2D）。必须使用 Texel(ArrayImage image,
	-- vec3texturecoord) 着色器函数从数组图像的切片中获取像素颜色。 vec3 参数包含前两个组件中的纹理坐标，以及第三个组件中从 0 开始的切片索引。
	--
	-- 重载说明：
	-- 1. 创建一个数组图像，为生成的数组图像对象的每个切片指定不同的图像文件。
	--     Illustration of how an array image works: 外部插图 DPI 比例为 2（正常像素的两倍
	-- 密度）将导致图像在屏幕上占据与 DPI 比例为 1 的像素尺寸一半的图像相同的空间。这允许轻松交换在屏幕上占据相同空间但具有不同像素密度的图像资源，这使得支持高 dpi / 视网膜分辨率需要更少的代码逻辑。为了在自定义
	-- void effect() 变体中使用数组纹理或其他非 2D 纹理类型作为主纹理，必须在像素着色器中使用变体，并且必须将 MainTex 声明为
	--     ArrayImage or sampler2DArray like so: 统一ArrayImage MainTex;。
	--
	-- 参数：
	--  layers: 一个表，其中包含数组中图像（或 File、FileData、ImageData 或 CompressedImageData
	--          对象）的文件路径。每个子图像必须具有相同的尺寸。还可以给出表的表，其中每个子表包含该子表的切片索引的所有mipmap级别。
	--  settings: 用于配置阵列映像的可选设置表，包含以下字段：（默认值：nil。）
	--  settings.mipmaps: 如果为 true 则使图像使用 mipmap，为 false 则禁用它们。如果图像不是压缩纹理格式，则会自动生成 Mipmap。 （默认值：假。）
	--  settings.linear: 如果启用伽马校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。）
	--  settings.dpiscale: 绘制数组图像并调用 getWidth/getHeight 时使用的 DPI 比例。 （默认值：1。）
	--
	-- 返回值：
	--  image: 数组图像对象。
	newArrayImage: function(layers: {ImageData}, settings?: LayeredImageSettings): Image
	-- 创建一个新的立方体贴图图像。
	--
	-- 立方体贴图图像有 6 个面（侧面），代表一个立方体。它们不能直接渲染，只能在着色器代码中使用（并通过 Shader:send 发送到着色器）。
	--
	-- 要在Shader 中使用立方体贴图图像，必须将其声明为CubeImage 或samplerCube 类型（而不是Image 或sampler2D）。必须使用 Texel(CubeImage image, vec3
	-- Direction) 着色器函数从立方体贴图中获取像素颜色。 vec3 参数是从立方体中心开始的标准化方向，而不是显式的纹理坐标。
	--
	-- 立方体贴图图像中的每个面都必须具有正方形尺寸。
	--
	-- 对于接受包含多个立方体贴图面的单个图像的此函数的变体，它们必须在图像中以以下形式之一布局：
	--
	-- +y
	--
	-- +z +x -z
	--
	-- -y
	--
	-- -x
	--
	-- 或：
	--
	-- +y
	--
	-- -x +z +x -z
	--
	-- -y
	--
	-- 或：
	--
	-- +x
	--
	-- -x
	--
	-- +y
	--
	-- -y
	--
	-- +z
	--
	-- -z
	--
	-- 或：
	--
	-- +x -x +y -y +z -z
	--
	-- 重载说明：
	-- 1. 在给定包含多个立方体面的单个图像文件的情况下创建立方体贴图图像。 2. 创建立方体贴图图像，并为每个立方体面指定不同的图像文件。
	--
	-- 参数：
	--  faces: 包含 6 个图像文件路径（或 File、FileData、ImageData 或 CompressedImageData
	--         对象）的表，位于数组中。每个面部图像必须具有相同的尺寸。还可以给出表的表，其中每个子表包含该子表的立方体面索引的所有mipmap级别。
	--  settings: 用于配置立方体贴图图像的可选设置表，包含以下字段：（默认值：nil。）
	--  settings.mipmaps: 如果为 true 则使图像使用 mipmap，为 false 则禁用它们。如果图像不是压缩纹理格式，则会自动生成 Mipmap。 （默认值：假。）
	--  settings.linear: 如果启用伽马校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。）
	--
	-- 返回值：
	--  image: 立方体贴图图像对象。
	newCubeImage: function(faces: {ImageData}, settings?: LayeredImageSettings): Image
	-- 创建新体积 (3D) 图像。
	--
	-- 体积图像是具有宽度、高度和深度的 3D 纹理。它们不能直接渲染，只能在着色器代码中使用（并通过 Shader:send 发送到着色器）。
	--
	-- 要在Shader中使用体积图像，必须将其声明为VolumeImage或sampler3D类型（而不是Image或sampler2D）。必须使用 Texel(VolumeImage image, vec3 texcoords)
	-- 着色器函数从体积图像中获取像素颜色。 vec3 参数是标准化纹理坐标，其中 z 分量表示采样深度（范围从 1 开始）。
	--
	-- 体积图像通常用作着色器中颜色分级的查找表，例如，因为使用两个像素之间的纹理坐标进行采样可以在体积图像中的所有 3 个维度上进行插值，从而即使在使用小尺寸体积图像作为查找表时也会产生平滑的渐变。
	--
	-- 数组图像是比体积图像更好的选择，用于将多个不同的精灵存储在单个数组图像中以便直接绘制它们。
	--
	-- 重载说明：
	-- 1. 在给定多个具有匹配尺寸的图像文件的情况下创建体积图像。某些较旧的移动设备不支持卷映像。使用 love.graphics.getTextureTypes 在运行时检查。
	--
	-- 参数：
	--  slices: 一个表，其中包含数组中图像（或 File、FileData、ImageData 或 CompressedImageData 对象）的文件路径。还可以给出表中的表，其中每个子表代表单个 mipmap
	--          级别并包含该 mipmap 的所有层。
	--  settings: 用于配置卷映像的可选设置表，包含以下字段：（默认值：nil。）
	--  settings.mipmaps: 如果为 true 则使图像使用 mipmap，为 false 则禁用它们。如果图像不是压缩纹理格式，则会自动生成 Mipmap。 （默认值：假。）
	--  settings.linear: 如果启用伽马校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。）
	--
	-- 返回值：
	--  image: 体积图像对象。
	newVolumeImage: function(slices: {ImageData}, settings?: LayeredImageSettings): Image
	-- 创建一个新的 Canvas 对象用于离屏渲染。
	--
	-- 重载说明：
	-- 1. 使用给定的设置创建 2D 或立方体贴图画布。某些 Canvas 格式的系统要求比默认格式更高。使用 love.graphics.getCanvasFormats 检查支持。 2.
	-- 创建一个体积或数组纹理类型的Canvas。
	--
	-- 参数：
	--  width: 画布所需的宽度。
	--  height: 画布所需的高度。
	--  settings: 包含给定字段的表：（默认值：nil。）
	--  settings.type: 要创建的画布类型。 （默认值：'2d'。）取决于重载：要创建的画布类型。 （默认：'array'。）
	--  settings.format: 画布的格式。 （默认：'normal'。）
	--  settings.readable: Canvas 是否可读（可在着色器中绘制和访问）。对于常规格式默认为 true，对于深度/模板格式默认为
	--                     false。取决于重载：画布是否可读（可在着色器中绘制和访问）。对于常规格式默认为 true，对于深度/模板格式默认为 false。 （默认值：无。）
	--  settings.msaa: 绘制到画布时所需的多重采样抗锯齿 (MSAA) 样本数。 （默认值：0。）
	--  settings.dpiscale: Canvas 的 DPI 比例因子，在绘制到 Canvas 以及将 Canvas 绘制到屏幕上时使用。 （默认：love.graphics.getDPIScale()。）
	--  settings.mipmaps: Canvas是否有mipmap，如果有的话是否自动重新生成它们。 （默认：'none'。）
	--
	-- 返回值：
	--  canvas: 尺寸等于窗口大小（以像素为单位）的新画布。根据过载：具有指定宽度和高度的新画布。
	newCanvas: function(width?: integer, height?: integer, settings?: CanvasSettings): Canvas
	-- 获取可用的 Canvas 格式以及是否支持每种格式。
	--
	-- 参数：
	--  readable: 如果为 true，则仅当该格式的可读标志设置为 true 时，返回的格式才会被指示为受支持，反之亦然，如果参数为 false。
	--
	-- 返回值：
	--  formats: 包含 CanvasFormats 作为键的表，以及一个指示是否支持该格式作为值的布尔值。并非所有系统都支持所有格式。取决于重载：包含 CanvasFormats
	--           作为键的表，以及指示是否支持该格式作为值的布尔值（考虑到可读参数）。并非所有系统都支持所有格式。
	getCanvasFormats: function(readable?: boolean, formats?: {string: boolean}): {string: boolean}
	-- 将绘图操作捕获到画布上。
	--
	-- 重载说明：
	-- 1. 将渲染目标设为指定 Canvas；模板或深度缓冲必须在创建 Canvas 时显式启用。默认 love.run 会在
	--    love.draw 结束时调用 love.graphics.present，因此在本帧结束前应切回屏幕。
	-- 2. 不传参数时将渲染目标重置为屏幕。
	-- 3. 可同时设置多个二维 Canvas。后续绘图会写入全部目标；所有 Canvas 必须具有相同的尺寸和纹理类型。
	--    使用 love.graphics.isSupported('multicanvas') 检查设备是否支持多渲染目标。
	-- 4. 可指定非二维 Canvas 的图层、切片或 mipmap 级别。
	-- 5. 可用 RenderTargetSetup 同时配置目标 Canvas、模板缓冲与深度缓冲。
	--
	-- 参数：
	--  Canvas: 作为渲染目标的画布。
	--  mipmap: 要渲染到的 mipmap 级别。
	--  layer: 数组纹理的层，或体积纹理的深度切片。
	--  face: 立方体贴图的面索引（1 至 6）。
	setCanvas: function(...: any)
	-- 获取当前目标Canvas。
	--
	-- 返回值：
	--  canvas: setCanvas 设置的 Canvas。如果绘制到真实屏幕则返回 nil。
	getCanvas: function(): Canvas | nil
	-- 创建一个新的四边形。
	--
	-- Quad
	-- 的目的是使用图像的一部分来绘制对象，而不是绘制整个图像。它对于精灵表和图集最有用：在精灵图集中，多个精灵驻留在同一图像中，四边形用于从该图像中绘制特定的精灵；在所有帧都驻留在同一图像中的动画精灵中，四边形用于从动画中绘制特定帧。
	--
	-- 参数：
	--  x: 图像中沿 x 轴的左上角位置。
	--  y: 图像中沿 y 轴的左上角位置。
	--  width: 图像中四边形的宽度。 （必须大于 0。）
	--  height: 图像中四边形的高度。 （必须大于 0。）
	--  image_or_texture_width: 参考宽度，Image的宽度。 （必须大于 0。）
	--  texture_height: 参考高度，Image的高度。 （必须大于 0。）
	--
	-- 返回值：
	--  quad: 新的四边形。
	newQuad: function(x: number, y: number, width: number, height: number, image_or_texture_width: any, texture_height?: number): Quad
	-- 创建一个新的网格。
	--
	-- 如果网格在绘制时应使用图像或画布进行纹理化，请使用 Mesh:setTexture 。
	--
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	--
	-- 重载说明：
	-- 1. 创建具有指定顶点的标准网格。 2. 创建具有指定顶点数的标准网格。创建网格后，可以使用 Mesh:setVertices 或 Mesh:setVertex 和 Mesh:setDrawRange 指定顶点信息。 3.
	-- 创建具有自定义顶点属性和指定顶点数据的网格。每个顶点表中的值的顺序与指定顶点格式中的顶点属性的顺序相同。如果没有为特定顶点属性组件提供值，则如果其数据类型为 'float'，则将设置为默认值 0；如果其数据类型为
	-- 'byte'，则将设置为 1。如果属性的数据类型为 'float'，则组件的范围可以为 1 到 4，如果数据类型为 'byte'，则必须为 4。如果自定义顶点属性使用名称
	-- 'VertexPosition'、'VertexTexCoord' 或 'VertexColor'，则该顶点属性的顶点数据将用于标准顶点位置、纹理坐标或顶点颜色分别在绘制网格时。
	-- 否则，需要顶点着色器才能在绘制网格时使用顶点属性。网格体“'must'”具有 'VertexPosition' 属性以便绘制，但它可以通过 Mesh:attachAttribute
	-- 从不同的网格体附加。要在顶点着色器中使用自定义命名顶点属性，必须将其声明为同名的属性变量。变量可以从顶点着色器代码发送到像素
	--     Shader code by making a varying variable. For example: ''Vertex Shader code'' 属性 vec2
	-- CoolVertexAttribute；改变 vec2 CoolVariable； vec4 位置（mat4 变换投影，vec4 顶点位置）{ CoolVariable =
	-- CoolVertexAttribute;返回变换投影*顶点位置； ''Pixel Shader code'' 变化 vec2 CoolVariable; vec4 效果（vec4 颜色，图像 tex，vec2
	-- texcoord，vec2 pixcoord）{ vec4 texcolor = Texel（tex，texcoord + CoolVariable）;返回 texcolor * 颜色； } 4.
	-- 创建具有自定义顶点属性和指定顶点数的网格。如果每个顶点属性组件的数据类型为 'float'，则其初始化为 0；如果其数据类型为 'byte'，则初始化为
	-- 1。为了在绘制网格时使用顶点属性，需要顶点着色器。网格体“'must'”具有 'VertexPosition' 属性以便绘制，但它可以通过 Mesh:attachAttribute 从不同的网格体附加。 5. 创建 Mesh
	-- 后，可以使用 Mesh:setVertices 或 Mesh:setVertex 和 Mesh:setDrawRange 来指定顶点信息。
	--
	-- 参数：
	--  vertices_or_format: {attribute, ...} 形式的表。每个属性都是一个表，其中指定用于每个顶点的自定义顶点属性。
	--  vertices_or_format.attribute: 包含属性名称、数据类型以及属性中组件数量的表，格式为{名称、数据类型、组件}。
	--  vertices_or_format....: 附加顶点属性格式表。
	--  vertices_or_mode: 该表填充了每个顶点的顶点信息表，其形式为{vertex, ...}，其中每个顶点是一个形式为{attributecomponent, ...}的表。取决于过载：网格将使用的顶点总数。
	--  vertices_or_mode.attributecomponent: 顶点中第一个顶点属性的第一个组成部分。
	--  vertices_or_mode....: 顶点中所有顶点属性的附加组件。
	--  draw_mode_or_usage: 绘制时如何使用顶点。默认模式 'fan' 对于简单的凸多边形来说已经足够了。 （默认：'fan'。）
	--  usage: 网格的预期用途。指定的使用模式会影响Mesh的内存使用和性能。 （默认：'dynamic'。）
	--
	-- 返回值：
	--  mesh: 新网格。
	newMesh: function(vertices_or_format: any, vertices_or_mode?: any, draw_mode_or_usage?: string, usage?: string): Mesh
	-- 创建一个新的 SpriteBatch 对象。
	--
	-- 参数：
	--  texture: 用于精灵的图像或画布。
	--  size: SpriteBatch 在任何给定时间可以包含的精灵的最大数量。自版本 11.0 起，添加超过此数量的额外精灵将自动增加精灵批次。 （默认值：1000。）
	--  usage: SpriteBatch 的预期用法。指定的使用模式会影响SpriteBatch的内存使用和性能。 （默认：'dynamic'。）
	--
	-- 返回值：
	--  spriteBatch: 新的 SpriteBatch。
	newSpriteBatch: function(texture: Image | Canvas, size?: integer, usage?: string): SpriteBatch
	-- 创建一个新的粒子系统。
	--
	-- 参数：
	--  texture: 要使用的纹理（图像或画布）。
	--  size: 同时最大粒子数。 （默认值：1000。）
	--
	-- 返回值：
	--  system: 一个新的粒子系统。
	newParticleSystem: function(texture: Image | Canvas, size?: integer): ParticleSystem
	-- 为硬件加速顶点和像素效果创建一个新的 Shader 对象。着色器包含顶点着色器代码、像素着色器代码或两者。
	--
	-- 着色器是绘图时在显卡上运行的小程序。顶点着色器针对每个顶点运行一次（例如，图像有 4 个顶点 -
	-- 每个角各一个。网格可能有更多。）像素着色器针对绘制对象接触的屏幕上的每个像素运行一次。像素着色器代码在顶点着色器处理完所有对象的顶点后执行。
	--
	-- 参数：
	--  source: 像素着色器代码，或指向包含该代码的文件的文件名。
	--  pixel_source: 顶点着色器代码，或指向包含该代码的文件的文件名。
	--
	-- 返回值：
	--  shader: 用于绘图操作的 Shader 对象。
	newShader: function(source: string | FileData, pixel_source?: string | FileData): Shader
	-- 验证着色器代码。检查指定的着色器代码是否不包含任何错误。
	--
	-- 参数：
	--  gles: 验证代码为 GLSL ES 着色器。
	--  source: 像素着色器代码，或指向包含该代码的文件的文件名。
	--  pixel_source: 顶点着色器代码，或指向包含该代码的文件的文件名。
	--
	-- 返回值：
	--  status: true 如果指定的着色器代码不包含任何错误。否则为假。
	--  message: 着色器代码验证失败的原因（如果验证成功则为零）。
	validateShader: function(gles: boolean, source: string | FileData, pixel_source?: string | FileData): boolean, string | nil
	-- 将着色器设置或重置为当前像素效果或顶点着色器。直到下一个“'love.graphics.setShader'”之前的所有绘制操作都将使用指定的 Shader 对象进行绘制。
	--
	-- 重载说明：
	-- 1. 将当前着色器设置为指定的着色器。直到下一个“'love.graphics.setShader'”之前的所有绘制操作都将使用指定的 Shader 对象进行绘制。 2. 禁用着色器，允许未过滤的绘图操作。
	--
	-- 参数：
	--  shader: 新的着色器。
	setShader: function(shader?: Shader)
	-- 获取当前的Shader。如果未设置则返回 nil。
	--
	-- 返回值：
	--  shader: 当前活动的着色器，如果未设置则为零。
	getShader: function(): Shader | nil
	-- 在屏幕上绘制可绘制对象（图像、画布、SpriteBatch、粒子系统、网格、文本对象或视频），并可选择旋转、缩放和剪切。
	--
	-- 对象是相对于其局部坐标系绘制的。原点默认位于图像和画布的左上角。所有缩放、剪切和旋转参数都会相对于该点变换对象。另外，还可以在屏幕坐标系上指定原点位置。
	--
	-- 通过将原点偏移到中心，可以绕其中心旋转对象。旋转角度必须以弧度为单位。还可以使用负比例因子来围绕其中心线翻转。
	--
	-- 请注意，偏移是在旋转、缩放或剪切之前应用的；缩放和剪切在旋转之前应用。
	--
	-- 对象的右边缘和底边缘以剪切因子定义的角度移动。
	--
	-- 使用默认着色器时，使用此函数绘制的任何内容都将根据当前选择的颜色进行着色。将其设置为纯白色以保留对象的原始颜色。
	--
	-- 参数：
	--  image: 可绘制对象。
	--  quad_or_x: 绘制对象的位置（x 轴）。 （默认值：0。）
	--  x_or_y: 绘制对象的位置（y 轴）。 （默认值：0。）
	--  y_or_angle: 方向（弧度）。 （默认值：0。）
	--  angle_or_scale_x: 比例因子（x 轴）。 （默认值：1。）
	--  scale_x_or_scale_y: 比例因子（y 轴）。 （默认值：sx。）
	--  scale_y_or_origin_x: 原点偏移（x 轴）。 （默认值：0。）
	--  origin_x_or_origin_y: 原点偏移（y 轴）。 （默认值：0。）
	--  origin_y: 剪切因子（x 轴）。 （默认值：0。）
	draw: function(image: any, quad_or_x?: any, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y?: number)
	-- 绘制数组纹理的一层。
	--
	-- 重载说明：
	-- 1. 绘制一层阵列纹理。 2. 使用指定的Quad绘制一层ArrayTexture。指定的图层索引会覆盖通过 Quad:setLayer 在 Quad 上设置的任何图层索引。 3. 使用指定的变换绘制一层阵列纹理。 4.
	-- 使用指定的四边形和变换绘制一层阵列纹理。为了使用数组纹理或其他非 2D 纹理类型作为自定义 void effect() 变体中的主纹理，必须在像素中使用
	--     shader, and MainTex must be declared as an ArrayImage or sampler2DArray like so: 统一ArrayImage MainTex;。
	--
	-- 参数：
	--  image: 要绘制的数组纹理。
	--  layer: 绘制时使用的图层的索引。
	--  quad_or_x: 绘制纹理的位置（x 轴）。 （默认值：0。）
	--  x_or_y: 绘制纹理的位置（y 轴）。 （默认值：0。）
	--  y_or_angle: 方向（弧度）。 （默认值：0。）
	--  angle_or_scale_x: 比例因子（x 轴）。 （默认值：1。）
	--  scale_x_or_scale_y: 比例因子（y 轴）。 （默认值：sx。）
	--  scale_y_or_origin_x: 原点偏移（x 轴）。 （默认值：0。）
	--  origin_x_or_origin_y: 原点偏移（y 轴）。 （默认值：0。）
	--  origin_y: 剪切因子（x 轴）。 （默认值：0。）
	drawLayer: function(image: Image, layer: integer, quad_or_x?: Quad | number, x_or_y?: number, y_or_angle?: number, angle_or_scale_x?: number, scale_x_or_scale_y?: number, scale_y_or_origin_x?: number, origin_x_or_origin_y?: number, origin_y?: number)
	-- 使用硬件几何实例，通过一次绘制调用绘制网格的许多实例。
	--
	-- 每个实例都可以具有唯一的属性（位置、颜色等），但默认情况下不会，除非使用自定义的每个实例顶点属性或 love_InstanceID GLSL 3 顶点着色器变量，否则它们将全部渲染在彼此之上的相同位置。
	--
	-- 某些旧版 GPU 不支持实例化，这些 GPU 只能使用 OpenGL ES 2 或 OpenGL 2。使用 love.graphics.getSupported 进行检查。
	--
	-- 参数：
	--  mesh: 要渲染的网格物体。
	--  instance_count: 要渲染的实例数。
	--  x: 绘制实例的位置（x 轴）。 （默认值：0。）
	--  y: 绘制实例的位置（y 轴）。 （默认值：0。）
	--  angle: 方向（弧度）。 （默认值：0。）
	--  scale_x: 比例因子（x 轴）。 （默认值：1。）
	--  scale_y: 比例因子（y 轴）。 （默认值：sx。）
	--  origin_x: 原点偏移（x 轴）。 （默认值：0。）
	--  origin_y: 原点偏移（y 轴）。 （默认值：0。）
	--  shear_x: 剪切因子（x 轴）。 （默认值：0。）
	--  shear_y: 剪切因子（y 轴）。 （默认值：0。）
	drawInstanced: function(mesh: Mesh, instance_count: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)
end

-- 喜欢11.5根模块。该文件仅声明当前实现的子集。
local record Love
	record TouchID
		userdata
	end
	-- 提供触摸屏按键的界面。
	record Touch
		-- 获取所有活动触摸按键的列表。
		--
		-- 重载说明：
		-- 1. id 值与用作 love.touchpressed、love.touchmoved 和 love.touchreleased. 参数的 id 值相同。特定触摸按下的 id 值仅保证在该触摸按下期间是唯一的。一旦使用该
		-- ID 调用 love.touchreleased，它就可以通过 love.touchpressed.
		--
		-- 返回值：
		--  touches: 活动触摸按键 ID 值列表，可与 love.touch.getPosition.
		getTouches: function(): {TouchID}
		-- 获取指定触摸的当前位置（以像素为单位）。
		--
		-- 重载说明：
		-- 1. LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为 1 范围内的标准化值，而此 API 报告的位置以像素为单位。
		--
		-- 参数：
		--  id: 触摸按键的标识符。使用 love.touch.getTouches、love.touchpressed 或 love.touchmoved 获取触摸 ID 值。
		--
		-- 返回值：
		--  x: 窗口内触摸按键沿 x 轴的位置（以像素为单位）。
		--  y: 窗口内触摸按键沿 y 轴的位置（以像素为单位）。
		getPosition: function(id: TouchID): number, number
		-- 获取指定触摸的当前压力。
		--
		-- 参数：
		--  id: 触摸按键的标识符。使用 love.touch.getTouches、love.touchpressed 或 love.touchmoved 获取触摸 ID 值。
		--
		-- 返回值：
		--  pressure: 触摸压力。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
		getPressure: function(id: TouchID): number
	end
	-- 代表物理操纵杆。
	record Joystick
		-- 获取字符串形式的对象类型。
		--
		-- 返回值：
		--  type: 字符串类型。
		type: function(self: Joystick): string
		-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
		--
		-- 参数：
		--  type_name: 要检查的类型的名称。
		--
		-- 返回值：
		--  b: 如果对象属于指定类型，则为 true，否则为 false。
		typeOf: function(self: Joystick, type_name: string): boolean
		-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
		--
		-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
		--
		-- 返回值：
		--  success: 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
		release: function(self: Joystick): boolean
		-- 获取Joystick是否已连接。
		--
		-- 返回值：
		--  connected: 如果操纵杆当前已连接，则为 true，否则为 false。
		isConnected: function(self: Joystick): boolean
		-- 获取操纵杆的名称。
		--
		-- 返回值：
		--  name: 操纵杆的名称。
		getName: function(self: Joystick): string
		-- 获取操纵杆的唯一标识符。即使操纵杆断开连接并重新连接，标识符在游戏的生命周期中也将保持不变，但当游戏重新启动时，它“'will'”会发生变化。
		--
		-- 返回值：
		--  id: 操纵杆的唯一标识符。只要游戏运行，就保持不变。
		--  instanceid: 唯一实例标识符。每次重新连接操纵杆时都会发生变化。如果操纵杆未连接则为零。
		getID: function(self: Joystick): integer, integer | nil
		-- 获取物理操纵杆类型所特有的稳定 GUID，该 GUID 不会随时间变化。例如，OS X 中的所有 Sony Dualshock 3 控制器都具有相同的 GUID。该值取决于平台。
		--
		-- 返回值：
		--  guid: 操纵杆类型的依赖于操作系统的唯一标识符。
		getGUID: function(self: Joystick): string
		-- 获取操纵杆的 USB 供应商 ID、产品 ID 和产品版本号，这些信息在不同操作系统中保持一致。
		--
		-- 可用于为不同的游戏手柄显示不同的图标等。
		--
		-- 重载说明：
		-- 1. 某些 Linux 发行版可能未附带 SDL 2.0.6 或更高版本，在这种情况下，此函数将为所有三个值返回 0。
		--
		-- 返回值：
		--  vendorID: 操纵杆的 USB 供应商 ID。
		--  productID: 操纵杆的 USB 产品 ID。
		--  productVersion: 操纵杆的产品版本。
		getDeviceInfo: function(self: Joystick): integer, integer, integer
		-- 获取操纵杆上的轴数。
		--
		-- 返回值：
		--  axes: 可用轴的数量。
		getAxisCount: function(self: Joystick): integer
		-- 获取操纵杆上的按钮数量。
		--
		-- 返回值：
		--  buttons: 可用按钮的数量。
		getButtonCount: function(self: Joystick): integer
		-- 获取操纵杆上的帽子数量。
		--
		-- 返回值：
		--  hats: 操纵杆有多少顶帽子。
		getHatCount: function(self: Joystick): integer
		-- 获取轴的方向。
		--
		-- 参数：
		--  axis: 要检查的轴的索引。
		--
		-- 返回值：
		--  direction: 轴的当前值。
		getAxis: function(self: Joystick, axis: integer): number
		-- 获取每个轴的方向。
		--
		-- 返回值：
		--  axisDir1: 轴 1 的方向。
		--  axisDir2: 轴2的方向。
		--  axisDirN: 轴方向N。
		getAxes: function(self: Joystick): number...
		-- 获取操纵杆帽子的方向。
		--
		-- 参数：
		--  hat: 要检查的帽子的索引。
		--
		-- 返回值：
		--  direction: 帽子被推的方向。
		getHat: function(self: Joystick, hat: integer): string
		-- 检查操纵杆上的按钮是否被按下。
		--
		-- LÖVE 0.9.0 有一个错误，要求传递给 Joystick:isDown 的按钮索引是基于 0 的而不是基于 1 的，例如对于此功能，按钮 1 将为 0。它在 0.9.1 中被修复。
		--
		-- 参数：
		--  buttons: 要检查的按钮的索引。
		--
		-- 返回值：
		--  anyDown: 如果任何提供的按钮被按下，则为 True，否则为 false。
		isDown: function(self: Joystick, buttons: integer...): boolean
		-- 获取Joystick是否被识别为游戏手柄。如果是这种情况，则可以通过 Joystick:getGamepadAxis、Joystick:isGamepadDown、love.gamepadpressed
		-- 和相关函数，在不同的操作系统和操纵杆型号中以标准化方式使用操纵杆的按钮和轴。
		--
		-- LÖVE 自动识别与 Xbox 360 控制器布局相似的最流行的控制器作为游戏手柄，但您可以使用 love.joystick.setGamepadMapping.
		--
		-- 重载说明：
		-- 1. 如果操纵杆被识别为游戏手柄，则虚拟游戏手柄轴和按钮的物理位置尽可能与标准 Xbox 360 控制器的布局相对应。
		--
		-- 返回值：
		--  isgamepad: 如果操纵杆被识别为游戏手柄则为 true，否则为 false。
		isGamepad: function(self: Joystick): boolean
		-- 检查是否按下了操纵杆上的虚拟游戏手柄按钮。如果操纵杆未被识别为游戏手柄或未连接，则此函数将始终返回 false。
		--
		-- 参数：
		--  buttons: 要检查的游戏手柄按钮。
		--
		-- 返回值：
		--  anyDown: 如果任何提供的按钮被按下，则为 True，否则为 false。
		isGamepadDown: function(self: Joystick, buttons: string...): boolean
		-- 获取虚拟游戏手柄轴的方向。如果操纵杆未被识别为游戏手柄或未连接，此函数将始终返回 0。
		--
		-- 参数：
		--  axis: 要检查的虚拟轴。
		--
		-- 返回值：
		--  direction: 轴的当前值。
		getGamepadAxis: function(self: Joystick, axis: string): number
		-- 获取虚拟游戏手柄输入绑定的按钮、轴或帽子。
		--
		-- 重载说明：
		-- 1. 如果操纵杆未被识别为游戏手柄或虚拟游戏手柄轴未绑定到操纵杆输入，则返回 nil。 2. 虚拟游戏手柄轴和按钮的物理位置尽可能与标准 Xbox 360 控制器的布局相对应。
		--
		-- 参数：
		--  input: 要获取绑定的虚拟游戏手柄轴。根据过载：要获取绑定的虚拟游戏手柄按钮。
		--
		-- 返回值：
		--  inputtype: 虚拟游戏手柄轴绑定的输入类型。取决于过载：虚拟游戏手柄按钮绑定的输入类型。
		--  inputindex: 虚拟游戏手柄轴绑定到的操纵杆按钮、轴或帽子的索引。 取决于过载：虚拟游戏手柄按钮绑定到的操纵杆按钮、轴或帽子的索引。
		--  hatdirection: 帽子的方向（如果虚拟游戏手柄轴绑定到帽子）。否则为零。取决于过载：帽子的方向（如果虚拟游戏手柄按钮绑定到帽子）。否则为零。
		getGamepadMapping: function(self: Joystick, input: string): string | nil, integer | nil, string | nil
		-- 获取此操纵杆的完整游戏手柄映射字符串，如果未将其识别为游戏手柄，则返回 nil。
		--
		-- 映射字符串包含用于将操纵杆的按钮和轴映射到标准游戏手柄布局的绑定信息，并且可以在以后与 love.joystick.loadGamepadMappings.
		--
		-- 返回值：
		--  mappingstring: 包含操纵杆的游戏手柄映射的字符串，如果操纵杆未被识别为游戏手柄则为零。
		getGamepadMappingString: function(self: Joystick): string | nil
		-- 获取Joystick是否支持振动。
		--
		-- 重载说明：
		-- 1. 第一次调用此函数可能会比预期花费更多时间，因为需要初始化 SDL 的触觉/力反馈子系统。
		--
		-- 返回值：
		--  supported: 如果此操纵杆支持隆隆声/力反馈振动，则为 true，否则为 false。
		isVibrationSupported: function(self: Joystick): boolean
		-- 设置带有震动支持的操纵杆上的振动电机速度。大多数常见的游戏手柄都具有此功能，但并非所有驱动程序都提供适当的支持。使用Joystick:isVibrationSupported进行检查。
		--
		-- 重载说明：
		-- 1. 禁用振动。 2. 如果摇杆只有一个振动电机，则仍会工作，但会使用左右参数中的最大值。如果使用 Tattiebogle 驱动程序的修改版本，则 Mac OS X 上的 Xbox 360
		-- 控制器仅支持振动。第一次调用此函数可能会比预期花费更多时间，因为需要初始化 SDL 的触觉/力反馈子系统。
		--
		-- 参数：
		--  left: 操纵杆上左侧振动电机的强度。必须在 1 范围内。
		--  right: 操纵杆上右侧振动电机的强度。必须在 1 范围内。
		--  duration: 振动的持续时间（以秒为单位）。负值意味着无限的持续时间。 （默认值：-1。）
		--
		-- 返回值：
		--  success: 如果振动成功应用则为 True，否则为 false。取决于过载：如果振动已成功禁用，则为 true；如果未成功禁用，则为 false。
		setVibration: function(self: Joystick, left?: number, right?: number, duration?: number): boolean
		-- 获取支持震动的操纵杆上当前的振动电机强度。
		--
		-- 返回值：
		--  left: 操纵杆上左侧振动电机的当前强度。
		--  right: 操纵杆上右侧振动电机的当前强度。
		getVibration: function(self: Joystick): number, number
		getConnectedIndex: function(self: Joystick): integer | nil
	end
	-- 提供用户操纵杆的接口。
	record JoystickModule
		-- 获取已连接操纵杆的列表。
		--
		-- 返回值：
		--  joysticks: 当前连接的操纵杆列表。
		getJoysticks: function(): {Joystick}
		-- 获取连接的操纵杆数量。
		--
		-- 返回值：
		--  joystickcount: 连接的操纵杆数量。
		getJoystickCount: function(): integer
		-- 将虚拟游戏手柄输入绑定到特定类型的所有操纵杆的按钮、轴或帽子。例如，如果此函数与 OS X 中的 Dualshock 3 控制器返回的 GUID 一起使用，则绑定将影响在 OS X
		-- 中运行时与游戏一起使用的“'all'”Dualshock 3 控制器的 Joystick:getGamepadAxis 和 Joystick:isGamepadDown。
		--
		-- LÖVE 包含许多常见控制器的内置游戏手柄绑定。此功能允许您更改默认情况下不被识别为游戏手柄的操纵杆类型的绑定或添加新的绑定。
		--
		-- 虚拟游戏手柄按钮和轴是围绕 Xbox 360 控制器布局设计的。
		--
		-- 重载说明：
		-- 1. 绑定游戏手柄轴和按钮的物理位置应尽可能与标准 Xbox 360 控制器的布局相对应。
		--
		-- 参数：
		--  guid: 绑定将影响的操纵杆类型的依赖于操作系统的 GUID。
		--  input: 要绑定的虚拟游戏手柄按钮。根据过载：要绑定的虚拟游戏手柄轴。
		--  input_type: 虚拟游戏手柄按钮绑定的输入类型。取决于过载：将虚拟游戏手柄轴绑定到的输入类型。
		--  index: 将虚拟游戏手柄按钮绑定到的轴、按钮或帽子的索引。取决于过载：将虚拟游戏手柄轴绑定到的轴、按钮或帽子的索引。
		--  direction: 帽子的方向，如果虚拟手柄按钮会绑定到帽子上。否则为零。 （默认值：nil。）取决于过载：帽子的方向，如果虚拟游戏手柄轴将绑定到帽子。否则为零。 （默认值：无。）
		--
		-- 返回值：
		--  success: 虚拟手柄按键是否绑定成功。根据过载情况：虚拟手柄轴是否绑定成功。
		setGamepadMapping: function(guid: string, input: string, input_type: string, index: integer, direction?: string): boolean
		-- 加载使用 love.joystick.saveGamepadMappings. 创建的游戏手柄映射字符串或文件
		--
		-- 它还可以识别任何 SDL 游戏控制器映射字符串，例如使用 Steam 的 Big Picture 控制器配置界面或这个漂亮的数据库创建的字符串。如果为已知的控制器 GUID 加载新映射，则更高版本将覆盖当前加载的映射。
		--
		-- 重载说明：
		-- 1. 从文件加载游戏手柄映射字符串。 2. 直接加载游戏手柄映射字符串。
		--
		-- 参数：
		--  mappings_or_filename: 从中加载映射字符串的文件名。取决于重载：要加载的映射字符串。
		loadGamepadMappings: function(mappings_or_filename: string)
		-- 保存所有被识别为游戏手柄并且最近使用过或者其游戏手柄绑定已被修改的虚拟游戏手柄映射。
		--
		-- 映射存储为字符串，以便与 love.joystick.loadGamepadMappings.
		--
		-- 重载说明：
		-- 1. 将所有相关摇杆的游戏手柄映射保存到文件中。 2. 返回映射字符串而不写入文件。
		--
		-- 参数：
		--  filename: 保存映射字符串的文件名。
		--
		-- 返回值：
		--  mappings: 写入文件的映射字符串。取决于重载：映射字符串。
		saveGamepadMappings: function(filename?: string): string
		-- 获取具有给定 GUID 的操纵杆的完整游戏手柄映射字符串，如果 GUID 未被识别为游戏手柄，则返回 nil。
		--
		-- 映射字符串包含用于将操纵杆的按钮和轴映射到标准游戏手柄布局的绑定信息，并且可以在以后与 love.joystick.loadGamepadMappings.
		--
		-- 参数：
		--  guid: 要获取其映射字符串的 GUID 值。
		--
		-- 返回值：
		--  mappingstring: 包含操纵杆游戏手柄映射的字符串，如果 GUID 未被识别为游戏手柄则为零。
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

	-- 如果您的游戏文件夹（或 .love 文件）中存在名为 conf.lua 的文件，则该文件会在加载 LÖVE 模块之前运行。您可以使用此文件覆盖 love.conf 函数，该函数稍后由 LÖVE 'boot' 脚本调用。使用
	-- love.conf 函数，您可以设置一些配置选项，并更改窗口的默认大小、加载哪些模块等内容。
	--
	-- 参数：
	--  config: love.conf 函数采用一个参数：一张包含所有默认值的表，您可以根据自己的喜好覆盖这些默认值。例如，如果您想更改默认窗口大小，请执行以下操作： function love.conf(t)
	--          t.window.width = 1024 t.window.height = 768 end 如果您不需要物理模块或操纵杆模块，请执行以下操作。 function love.conf(t)
	--          t.modules.joystick = false t.modules.physicals = false end 当您发布游戏时，鼓励将未使用的模块设置为
	--          false。它会稍微减少启动时间（特别是在禁用操纵杆模块的情况下）并减少内存使用量（稍微）。请注意，您无法禁用 love.filesystem；这是强制性的。爱情模块本身也是如此。
	--          love.graphics 需要启用 love.window。
	--  config.identity: 该标志确定游戏的保存目录的名称。请注意，您只能指定名称，而不能指定创建位置： t.identity = "gabe_HL3" -- 正确 t.identity =
	--                   "c:/Users/gabe/HL3" -- 不正确 或者 love.filesystem.setIdentity 可用于在配置文件之外设置保存目录。 （默认值：无。）
	--  config.appendidentity: 该标志决定是否应先搜索游戏目录然后保存目录（true）或否则（false）（默认值：false。）
	--  config.version: t.version 应该是一个字符串，代表您的游戏所针对的 LÖVE 版本。它的格式应为 "X.Y.Z"，其中 X 是主要版本号，Y 是次要版本号，Z 是补丁级别。它允许 LÖVE
	--                  在不兼容时显示警告。它的默认值是运行的 LÖVE 版本。 （默认："11.5"。）
	--  config.console: 确定是否应在游戏窗口旁边打开控制台（仅限 Windows）。 注意：在 OSX 上，您可以通过终端运行 LÖVE 来获取控制台输出。 （默认值：假。）
	--  config.accelerometerjoystick: 设置 iOS 和 Android 上的设备加速计是否应显示为 3 轴操纵杆。不使用时禁用加速计可能会减少 CPU 使用率。 （默认值：true。）
	--  config.externalstorage: 设置文件是保存在 Android 上的外部存储（true）还是内部存储（false）中。 （默认值：假。）
	--  config.gammacorrect: 确定是否启用伽玛校正渲染（当系统支持时）。 （默认值：假。）
	--  config.audio: 音频选项。
	--  config.audio.mic: 向用户请求麦克风权限。当用户允许时，love.audio.getRecordingDevices 将列出可用的录音设备。否则，love.audio.getRecordingDevices
	--                    返回空表，并在调用时显示一条消息以通知用户。 （默认值：假。）
	--  config.audio.mixwithsystem: 设置 LÖVE 打开时是否播放其他应用程序的背景音频/音乐。有关更多详细信息，请参阅 love.system.hasBackgroundMusic。
	--                              （默认值：true。）
	--  config.window: 可以推迟窗口创建，直到在代码中首次调用 love.window.setMode 。 为此，请在 love.conf 中设置 t.window = nil （或在旧版本中设置 t.screen
	--                 = nil。）如果这样做，如果在代码中的第一个 love.window.setMode 之前调用 love.graphics 中的任何函数，LÖVE 可能会崩溃。 t.window 表在
	--                 0.9.0 之前的版本中被命名为 t.screen。 0.9.0 中的 love.conf 中不存在 t.screen 表，0.8.0 中的 love.conf 中不存在 t.window
	--                 表。这意味着如果不注意为正在使用的 LÖVE 版本使用正确的表，love.conf 将无法执行（因此它将回退到默认值）。
	--  config.window.title: 设置游戏所在窗口的标题。或者可以使用 love.window.setTitle 在配置文件之外更改窗口标题。 （默认："Untitled"。）
	--  config.window.icon: 用作窗口图标的图像的文件路径。并非所有操作系统都支持非常大的图标图像。也可以使用 love.window.setIcon. 更改图标（默认值：nil。）
	--  config.window.width: 设置窗口的尺寸。如果这些标志设置为 0，LÖVE 会自动使用用户的桌面尺寸。 （默认值：800。）
	--  config.window.height: 设置窗口的尺寸。如果这些标志设置为 0，LÖVE 会自动使用用户的桌面尺寸。 （默认值：600。）
	--  config.window.borderless: 从窗口中删除所有边框视觉效果。请注意，不同操作系统的影响可能会有所不同。 （默认值：假。）
	--  config.window.resizable: 如果设置为 true，则允许用户调整游戏窗口的大小。 （默认值：假。）
	--  config.window.minwidth: 设置游戏窗口的最小宽度和高度（如果用户可以调整其大小）。如果您将 window.width 和 window.height 设置较低的值，LÖVE 将始终支持通过
	--                          window.minwidth 和 window.minheight 设置的最小尺寸。 （默认值：1。）
	--  config.window.minheight: 设置游戏窗口的最小宽度和高度（如果用户可以调整其大小）。如果您将 window.width 和 window.height 设置较低的值，LÖVE 将始终支持通过
	--                           window.minwidth 和 window.minheight 设置的最小尺寸。 （默认值：1。）
	--  config.window.fullscreen: 是否以全屏（true）或窗口（false）模式运行游戏。也可以通过 love.window.setFullscreen 或 love.window.setMode.
	--                            切换全屏（默认： false。）
	--  config.window.fullscreentype: 指定要使用的全屏模式类型（正常或桌面）。通常建议使用桌面，因为它在某些操作系统上比正常模式限制更少。 （默认："desktop"。）
	--  config.window.usedpiscale: 设置是否启用或禁用自动 DPI 缩放。 （默认值：true。）
	--  config.window.vsync: 启用或禁用垂直同步。垂直同步尝试使游戏保持稳定的帧速率，并可以防止屏幕撕裂等问题。如果您不知道关闭垂直同步可能产生的影响，建议保持垂直同步处于激活状态。在 LÖVE 11.0
	--                       之前，该值是布尔值（true 或 false）。从 LÖVE 11.0 开始，该值为数字（1 表示启用垂直同步，0 表示禁用垂直同步，-1
	--                       表示在支持时使用自适应垂直同步）。请注意，在 iOS 中，垂直同步始终处于启用状态且无法更改。 （默认值：true。）
	--  config.window.depth: 深度缓冲区中每个样本的位数（16/24/32，默认为 nil）（默认：nil。）
	--  config.window.stencil: 然后是深度缓冲区中每个样本的位数（一般为 8，默认为 nil）（默认：nil。）
	--  config.window.msaa: 用于多重采样抗锯齿的样本数。 （默认值：0。）
	--  config.window.display: 如果有多个监视器可用，则显示窗口的显示器索引。 （默认值：1。）
	--  config.window.highdpi: 请参阅 love.window.getPixelScale、love.window.toPixels 和 love.window.fromPixels. 如果您无法在具有
	--                         Retina 显示屏的 Mac 或 iOS 系统上测试游戏，建议禁用此选项，因为代码需要调整以确保内容看起来正确。 （默认值：假。）
	--  config.window.x: 确定窗口在用户屏幕上的位置。或者 love.window.setPosition 可用于动态更改位置。 （默认值：无。）
	--  config.window.y: 确定窗口在用户屏幕上的位置。或者 love.window.setPosition 可用于动态更改位置。 （默认值：无。）
	--  config.modules: 模块选项。
	--  config.modules.audio: 启用音频模块。 （默认值：true。）
	--  config.modules.event: 启用事件模块。 （默认值：true。）
	--  config.modules.graphics: 启用图形模块。 （默认值：true。）
	--  config.modules.image: 启用图像模块。 （默认值：true。）
	--  config.modules.joystick: 启用摇杆模块。 （默认值：true。）
	--  config.modules.keyboard: 启用键盘模块。 （默认值：true。）
	--  config.modules.math: 启用数学模块。 （默认值：true。）
	--  config.modules.mouse: 启用鼠标模块。 （默认值：true。）
	--  config.modules.physics: 启用物理模块。 （默认值：true。）
	--  config.modules.sound: 启用声音模块。 （默认值：true。）
	--  config.modules.system: 启用系统模块。 （默认值：true。）
	--  config.modules.timer: 启用定时器模块。 （默认值：true。）
	--  config.modules.touch: 启用触摸模块。 （默认值：true。）
	--  config.modules.video: 启用视频模块。 （默认值：true。）
	--  config.modules.window: 启用窗口模块。 （默认值：true。）
	--  config.modules.thread: 启用线程模块。 （默认值：true。）
	conf: function(config: Config) | nil
	-- 该函数在游戏开始时仅调用一次。
	--
	-- 重载说明：
	-- 1. 在 LÖVE 11.0 中，当从非 fused LÖVE 可执行文件运行时，传递的参数不包括游戏名称和 fused 命令行标志（如果存在）。以前的版本按原样传递参数，不进行任何过滤。
	load: function() | nil
	-- 回调函数用于更新游戏每一帧的状态。
	--
	-- 参数：
	--  deltaTime: 自上次更新以来的时间（以秒为单位）。
	update: function(deltaTime: number) | nil
	-- 用于在屏幕上绘制每一帧的回调函数。
	draw: function() | nil
	-- 游戏关闭时触发的回调函数。
	--
	-- 返回值：
	--  r: 中止退出。如果属实，请勿关闭游戏。
	quit: QuitCallback | nil
	-- 按键时触发的回调函数。
	--
	-- 重载说明：
	-- 1. 扫描码与键盘布局无关，因此如果按下与美式键盘上的 'w' 键相同位置的键，无论该键的标签是什么或用户的操作系统设置是什么，都会生成扫描码 'w' 。需要使用 love.keyboard.setKeyRepeat
	-- 启用按键重复才能接收重复按键事件。这不会影响 love.textinput. 2。需要使用 love.keyboard.setKeyRepeat 启用按键重复才能接收重复按键事件。
	--
	-- 参数：
	--  key: 按键的字符。取决于过载：按下的按键的字符。
	--  scancode: 代表按下的键的扫描码。
	--  is_repeat: 该按键事件是否重复。按键重复之间的延迟取决于用户的系统设置。
	keypressed: function(key: string, scancode: string, is_repeat: boolean) | nil
	-- 释放键盘按键时触发的回调函数。
	--
	-- 重载说明：
	-- 1. 扫描码与键盘布局无关，因此如果按下美式键盘上与 'w' 键相同位置的键，将使用扫描码 'w'，无论该键的标签是什么或用户的操作系统设置是什么。
	--
	-- 参数：
	--  key: 已释放按键的字符。
	--  scancode: 代表释放密钥的扫描码。
	keyreleased: function(key: string, scancode: string) | nil
	-- 当用户输入文本时调用。例如，如果在美式键盘布局上按下 shift-2，将生成文本 '@'。
	--
	-- 重载说明：
	-- 1. 虽然Lua字符串可以很好地存储UTF-8编码的unicode文本，但是Lua字符串库中的许多函数不会像您期望的那样处理文本。例如，#text（和
	-- string.len(text)）将给出字符串中“'bytes'”的数量，而不是 unicode 字符的数量。 Lua wiki 和 Lua 创建者之一的演示给出了更深入的解释，并提供了一些技巧。 utf8 库可用于操作
	-- UTF-8 编码的 unicode 文本（例如此函数中给出的 text 参数）。在 Android 和 iOS 上，默认情况下禁用 textinput；调用 love.keyboard.setTextInput 来启用它。
	--
	-- 参数：
	--  text: UTF-8 编码的 unicode 文本。
	textinput: function(text: string) | nil
	-- 当 IME（输入法编辑器）的候选文本发生更改时调用。
	--
	-- 候选文本并不是用户最终选择的最终文本。为此使用 love.textinput 。
	--
	-- 参数：
	--  text: UTF-8 编码的 unicode 候选文本。
	--  start: 所选候选文本的起始光标。
	--  length: 所选候选文本的长度。可能是 0。
	textedited: function(text: string, start: integer, length: integer) | nil
	-- 按下鼠标按钮时触发的回调函数。
	--
	-- 重载说明：
	-- 1. 使用love.wheelmoved 检测鼠标滚轮运动。在 0.10.0 及更高版本中，它不会注册为按钮按下。
	--
	-- 参数：
	--  x: 鼠标 x 位置，以像素为单位。
	--  y: 鼠标 y 位置（以像素为单位）。
	--  button: 按下的按钮索引。 1 是鼠标主按钮，2 是鼠标辅助按钮，3 是中间按钮。其他按钮取决于鼠标。
	--  is_touch: 如果鼠标按钮按下源自触摸屏触摸，则为 true。
	--  presses: 短时间、小面积的按下次数，用于模拟双击、三击
	mousepressed: function(x: number, y: number, button: integer, is_touch: boolean, presses: integer) | nil
	-- 释放鼠标按钮时触发的回调函数。
	--
	-- 参数：
	--  x: 鼠标 x 位置，以像素为单位。
	--  y: 鼠标 y 位置（以像素为单位）。
	--  button: 已释放的按钮索引。 1 是鼠标主按钮，2 是鼠标辅助按钮，3 是中间按钮。其他按钮取决于鼠标。
	--  is_touch: 如果鼠标按钮释放源自触摸屏触摸释放，则为 true。
	--  presses: 短时间、小面积的按下次数，用于模拟双击、三击
	mousereleased: function(x: number, y: number, button: integer, is_touch: boolean, presses: integer) | nil
	-- 鼠标移动时触发的回调函数。
	--
	-- 重载说明：
	-- 1. 如果鼠标启用了相对模式，则不保证 '''dx''' and '''dy''' arguments of this callback will update but '''x''' and '''y''' 。
	--
	-- 参数：
	--  x: x 轴上的鼠标位置。
	--  y: y 轴上的鼠标位置。
	--  delta_x: 自上次调用 love.mousemoved 以来沿 x 轴移动的量。
	--  delta_y: 自上次调用 love.mousemoved 以来沿 y 轴移动的量。
	--  is_touch: 如果鼠标按钮按下源自触摸屏触摸，则为 true。
	mousemoved: function(x: number, y: number, delta_x: number, delta_y: number, is_touch: boolean) | nil
	-- 鼠标滚轮移动时触发的回调函数。
	--
	-- 参数：
	--  x: 水平鼠标滚轮移动量。正值表示向右移动。
	--  y: 垂直鼠标滚轮移动量。正值表示向上移动。
	wheelmoved: function(x: number, y: number) | nil
	-- 触摸屏被触摸时触发的回调函数。
	--
	-- 重载说明：
	-- 1. 仅保证特定触摸按压的标识符是唯一的，直到使用该标识符调用 love.touchreleased 为止，此时可以将其重新用于新的触摸按压。 LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为
	-- 1 范围内的标准化值，而此 API 报告以像素为单位的位置。
	--
	-- 参数：
	--  id: 触摸按键的标识符。
	--  x: 触摸按键在窗口内的 x 轴位置（以像素为单位）。
	--  y: 触摸按键在窗口内的 y 轴位置（以像素为单位）。
	--  delta_x: 触摸按键在窗口内的 x 轴移动（以像素为单位）。这应该始终为零。
	--  delta_y: 触摸按键在窗口内的 y 轴移动（以像素为单位）。这应该始终为零。
	--  pressure: 施加的压力大小。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
	touchpressed: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil
	-- 触摸屏停止触摸时触发的回调函数。
	--
	-- 重载说明：
	-- 1. 仅保证特定触摸按压的标识符是唯一的，直到使用该标识符调用 love.touchreleased 为止，此时可以将其重新用于新的触摸按压。 LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为
	-- 1 范围内的标准化值，而此 API 报告以像素为单位的位置。
	--
	-- 参数：
	--  id: 触摸按键的标识符。
	--  x: 窗口内触摸的 x 轴位置（以像素为单位）。
	--  y: 窗口内触摸的 y 轴位置（以像素为单位）。
	--  delta_x: 窗口内触摸的 x 轴移动（以像素为单位）。
	--  delta_y: 窗口内触摸的 y 轴移动（以像素为单位）。
	--  pressure: 施加的压力大小。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
	touchreleased: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil
	-- 触摸按键在触摸屏内移动时触发的回调函数。
	--
	-- 重载说明：
	-- 1. 仅保证特定触摸按压的标识符是唯一的，直到使用该标识符调用 love.touchreleased 为止，此时可以将其重新用于新的触摸按压。 LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为
	-- 1 范围内的标准化值，而此 API 报告以像素为单位的位置。
	--
	-- 参数：
	--  id: 触摸按键的标识符。
	--  x: 窗口内触摸的 x 轴位置（以像素为单位）。
	--  y: 窗口内触摸的 y 轴位置（以像素为单位）。
	--  delta_x: 窗口内触摸的 x 轴移动（以像素为单位）。
	--  delta_y: 窗口内触摸的 y 轴移动（以像素为单位）。
	--  pressure: 施加的压力大小。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
	touchmoved: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil
	-- 线程遇到错误时触发的回调函数。
	--
	-- 参数：
	--  thread: 产生错误的线程。
	--  error: 错误消息。
	threaderror: function(thread: Thread, error: string) | nil
	-- 连接操纵杆时调用。
	--
	-- 重载说明：
	-- 1. 对于游戏启动时已连接的每个摇杆，也会在 love.load 之后触发此回调。
	--
	-- 参数：
	--  joystick: 新连接的操纵杆对象。
	joystickadded: function(joystick: Joystick) | nil
	-- 当操纵杆断开连接时调用。
	--
	-- 参数：
	--  joystick: 现在断开连接的操纵杆对象。
	joystickremoved: function(joystick: Joystick) | nil
	-- 当按下操纵杆按钮时调用。
	--
	-- 参数：
	--  joystick: 操纵杆对象。
	--  button: 按钮编号。
	joystickpressed: function(joystick: Joystick, button: integer) | nil
	-- 释放操纵杆按钮时调用。
	--
	-- 参数：
	--  joystick: 操纵杆对象。
	--  button: 按钮编号。
	joystickreleased: function(joystick: Joystick, button: integer) | nil
	-- 当操纵杆轴移动时调用。
	--
	-- 参数：
	--  joystick: 操纵杆对象。
	--  axis: 轴编号。
	--  value: 新的轴值。
	joystickaxis: function(joystick: Joystick, axis: integer, value: number) | nil
	-- 当操纵杆帽方向改变时调用。
	--
	-- 参数：
	--  joystick: 操纵杆对象。
	--  hat: 帽子号码。
	--  direction: 新帽子方向。
	joystickhat: function(joystick: Joystick, hat: integer, direction: string) | nil
	-- 当按下操纵杆的虚拟游戏手柄按钮时调用。
	--
	-- 参数：
	--  joystick: 操纵杆对象。
	--  button: 虚拟游戏手柄按钮。
	gamepadpressed: function(joystick: Joystick, button: string) | nil
	-- 当操纵杆的虚拟游戏手柄按钮被释放时调用。
	--
	-- 参数：
	--  joystick: 操纵杆对象。
	--  button: 虚拟游戏手柄按钮。
	gamepadreleased: function(joystick: Joystick, button: string) | nil
	-- 当操纵杆的虚拟游戏手柄轴移动时调用。
	--
	-- 参数：
	--  joystick: 操纵杆对象。
	--  axis: 虚拟游戏手柄轴。
	--  value: 新的轴值。
	gamepadaxis: function(joystick: Joystick, axis: string, value: number) | nil

	-- 兼容性入口点； Dora 仍然是应用程序循环所有者。 main 函数，包含主循环。省略时使用合理的默认值。
	--
	-- 返回值：
	--  mainLoop: 处理一帧的函数，包括调用时的事件和渲染。
	run: function()
end

local love: Love
return love
-- LÖVE 11.5 API 文档，包括参数和返回值说明，改编自官方 LÖVE Wiki。版权所有© 2006-2010 LÖVE 开发团队。文档根据 FreeBSD 文档许可证重新分发。 Dora
-- 特定的兼容性说明仍会明确标记。
