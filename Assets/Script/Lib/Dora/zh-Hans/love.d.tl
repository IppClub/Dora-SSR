-- 可绘制图像类型。
local record Image

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Image): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Image): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Image, type_name: string): boolean

	-- 获取纹理的宽度。
	-- @return (number) 纹理的宽度。
	getWidth: function(self: Image): number

	-- 获取纹理的高度。
	-- @return (number) 纹理的高度。
	getHeight: function(self: Image): number

	-- 获取纹理的宽度和高度。
	-- @return (number) 纹理的宽度。
	-- @return (number) 纹理的高度。
	getDimensions: function(self: Image): number, number

	-- 获取纹理的宽度（以像素为单位）。
	-- DPI 比例因子，而不是像素。使用 getWidth 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelWidth。
	-- @return (integer) 纹理的宽度，以像素为单位。
	getPixelWidth: function(self: Image): integer

	-- 获取纹理的高度（以像素为单位）。
	-- DPI 比例因子，而不是像素。使用 getHeight 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelHeight。
	-- @return (integer) 纹理的高度，以像素为单位。
	getPixelHeight: function(self: Image): integer

	-- 获取纹理的宽度和高度（以像素为单位）。
	-- Texture:getDimensions 获取纹理的尺寸，单位是按纹理的 DPI 比例因子缩放的单位，而不是像素。使用 getDimensions
	-- 进行与绘制纹理相关的计算（例如计算原点偏移），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelDimensions。
	-- @return (integer) 纹理的宽度，以像素为单位。
	-- @return (integer) 纹理的高度，以像素为单位。
	getPixelDimensions: function(self: Image): integer, integer

	-- 获取纹理的DPI比例因子。
	-- DPI 比例因子表示相对像素密度。 DPI 比例因子为 2 意味着纹理在每个维度上的像素密度是 DPI 比例因子为 1 的纹理的两倍（同一区域中像素数量的 4 倍）。
	-- 例如，像素尺寸为 100x100、DPI 比例因子为 2 的纹理将被绘制为 50x50。这对于高 dpi/视网膜显示器非常有用，可以轻松地交换更高或更低像素密度的图像和画布，而无需任何额外的手动缩放逻辑。
	-- @return (number) 纹理的 DPI 比例因子。
	getDPIScale: function(self: Image): number

	-- 获取纹理的类型。
	-- @return (string) 纹理的类型。
	getTextureType: function(self: Image): string

	-- 获取体积纹理的深度。对于 2D、立方体贴图和数组纹理返回 1。
	-- @return (integer) 体积纹理的深度。
	getDepth: function(self: Image): integer

	-- 获取数组纹理中的层数/切片数。对于 2D、立方体贴图和体积纹理，返回 1。
	-- @return (integer) 阵列纹理中的层数。
	getLayerCount: function(self: Image): integer

	-- 获取纹理中包含的 mipmap 数量。如果纹理不是使用 mipmap 创建的，它将返回 1。
	-- @return (integer) 纹理中 mipmap 的数量。
	getMipmapCount: function(self: Image): integer

	-- 获取纹理的 mipmap 过滤模式。在 11.0 之前，此方法仅适用于图像。
	-- @return (string) 在 mipmap 级别之间使用的过滤模式。如果未启用 mipmap 过滤，则为 nil。
	-- @return (number) 用于确定图像在绘制时是否应使用比正常情况更多或更少详细的 mipmap 级别的值。
	getMipmapFilter: function(self: Image): string, number

	-- 设置纹理的 mipmap 过滤器模式。在 11.0 之前，此方法仅适用于图像。
	--
	-- Mipmapping 在以缩小比例绘制纹理时非常有用。它可以提高性能并减少锯齿问题。
	--
	-- 在创建时启用了 mipmaps 标志，以便 mipmap 过滤器产生任何效果。在 0.10.0 之前的版本中，最好在使用 love.graphics.newImage 创建图像后直接调用此方法，以避免某些图形驱动程序中的错误。
	--
	-- 由于硬件限制和驱动程序错误，在 0.10.0 之前的版本中，未从 CompressedData 加载的图像必须具有二维幂（64x64、512x256 等）才能使用 mipmap。
	setMipmapFilter: function(self: Image)

	-- 设置纹理的 mipmap 过滤器模式。在 11.0 之前，此方法仅适用于图像。
	--
	-- Mipmapping 在以缩小比例绘制纹理时非常有用。它可以提高性能并减少锯齿问题。
	--
	-- 在创建时启用了 mipmaps 标志，以便 mipmap 过滤器产生任何效果。在 0.10.0 之前的版本中，最好在使用 love.graphics.newImage 创建图像后直接调用此方法，以避免某些图形驱动程序中的错误。
	--
	-- 由于硬件限制和驱动程序错误，在 0.10.0 之前的版本中，未从 CompressedData 加载的图像必须具有二维幂（64x64、512x256 等）才能使用 mipmap。
	-- @param filter (FilterMode) 在 mipmap 级别之间使用的过滤模式。 'nearest' 通常会提供更好的性能。
	-- @param sharpness (number) 正的锐度值使纹理在绘制时使用更详细的 mipmap 级别，但会牺牲性能。负值则相反。 （默认值：0。）
	setMipmapFilter: function(self: Image, filter: FilterMode, sharpness?: number)

	-- 获取纹理的像素格式。
	-- @return (string) 创建纹理时使用的像素格式。
	getFormat: function(self: Image): string

	-- 获取图像是否是从压缩数据创建的。
	-- 压缩图像在 VRAM 中占用的空间更少，并且绘制压缩图像通常比绘制根据原始像素数据创建的图像更有效。
	-- @return (boolean) 图像是否作为压缩纹理存储在 GPU 上。
	isCompressed: function(self: Image): boolean

	-- 获取图像是否是在线性（非伽玛校正）标志设置为 true 的情况下创建的。
	-- 当未启用伽玛校正渲染时，此方法始终返回 false。
	-- @return (boolean) 当启用伽玛校正渲染时，图像的内部像素格式是否是线性的（未进行伽玛校正）。
	isFormatLinear: function(self: Image): boolean

	-- 替换图像的内容。
	-- @param data (any) 用于替换内容的新 ImageData。
	-- @param slice (integer) 要替换哪个立方体贴图面、数组索引或体积层（如果适用）。 （默认值：1。）
	-- @param mipmap (integer) 如果图像具有 mipmap，则要替换的 mimap 级别。 （默认值：1。）
	-- @param x (integer) 距要替换的图像左上角的 x 偏移量（以像素为单位）。给定 ImageData 的宽度加上此值不得大于图像指定 mipmap 级别的像素宽度。 （默认值：0。）
	-- @param y (integer) 距要替换的图像左上角的 y 偏移量（以像素为单位）。给定 ImageData 的高度加上此值不得大于图像指定 mipmap 级别的像素高度。 （默认值：0。）
	-- @param reload_mipmaps (boolean) 替换图像像素后是否生成新的 mipmap。如果图像是使用自动生成的 mipmap 创建的，则默认为 true，否则默认为 false。 （默认值：假。）
	replacePixels: function(self: Image, data: any, slice?: integer, mipmap?: integer, x?: integer, y?: integer, reload_mipmaps?: boolean)

	-- 获取是否可以绘制纹理并将其发送到着色器。
	-- 使用模板和/或深度 PixelFormat 创建的画布默认情况下不可读，除非在传递到 love.graphics.newCanvas. 的设置表中指定 Readable=true
	-- 仍然可以渲染不可读的画布。
	-- @return (boolean) 纹理是否可读。
	isReadable: function(self: Image): boolean

	-- 获取在着色器中从深度纹理采样时使用的比较模式。
	-- 深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
	-- @return (string or nil) 在着色器中从此纹理采样时使用的比较模式，如果尚未在此纹理上调用 setDepthSampleMode，则为 nil。 （默认值：无。）
	getDepthSampleMode: function(self: Image): string | nil

	-- 设置从着色器中的深度纹理采样时使用的比较模式。深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
	-- 在着色器中使用具有比较模式设置的深度纹理时，必须将其声明为sampler2DShadow 并在GLSL 3 着色器中使用。在着色器中访问纹理的结果将返回一个介于 0 和 1
	-- 之间的浮点数，与通过比较操作的测试集的样本数量成正比（如果启用双线性过滤，最多将使用 4 个样本）。
	-- 深度纹理比较只能与可读的深度格式画布一起使用。
	-- @param mode (string) 在着色器中从此纹理采样时使用的比较模式。
	setDepthSampleMode: function(self: Image, mode?: string)

	-- 设置纹理的过滤模式。
	-- @param min_filter (string) 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	-- @param mag_filter (string) 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更大的尺寸渲染它）。 （默认值：分钟。）
	-- @param anisotropy (number) 使用的各向异性过滤的最大数量。 （默认值：1。）
	setFilter: function(self: Image, min_filter: string, mag_filter?: string, anisotropy?: number)

	-- 获取纹理的滤镜模式。
	-- @return (string) 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	-- @return (string) 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	-- @return (number) 使用的各向异性过滤的最大量。
	getFilter: function(self: Image): string, string, number

	-- 设置纹理的环绕属性。
	-- 当使用大于纹理范围的四边形绘制纹理时，或者使用使用 [0, 1] 之外的纹理坐标的自定义着色器时，此函数设置纹理的重复方式。纹理可以被夹紧或设置为在水平和垂直方向上重复。
	-- 夹紧的纹理仅出现一次（纹理的边缘拉伸以填充四边形的范围），而重复的纹理则根据四边形中的空间重复多次。
	-- @param horizontal (string) 纹理的水平环绕模式。
	-- @param vertical (string) 纹理的垂直环绕模式。 （默认：水平。）
	-- @param depth (string) 体积纹理 z 轴的包裹模式。 （默认值：水平。）
	setWrap: function(self: Image, horizontal: string, vertical?: string, depth?: string): boolean

	-- 获取纹理的环绕属性。
	-- 该函数返回当前设置的纹理水平和垂直环绕模式。
	-- @return (string) 纹理的水平环绕模式。
	-- @return (string) 纹理的垂直环绕模式。
	-- @return (string) 体积纹理 z 轴的包裹模式。
	getWrap: function(self: Image): string, string, string
end

-- 解码、流式传输和控制视频的对象。
local record VideoStream

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: VideoStream): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: VideoStream): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: VideoStream, type_name: string): boolean

	-- 播放视频流。
	play: function(self: VideoStream)

	-- 暂停视频流。
	pause: function(self: VideoStream)

	-- 设置VideoStream的当前播放位置。
	-- @param seconds (number) 自视频流开始以来的时间（以秒为单位）。
	seek: function(self: VideoStream, seconds: number)

	-- 倒带视频流。与 VideoStream:seek(0) 同义词。
	rewind: function(self: VideoStream)

	-- 获取VideoStream的当前播放位置。
	-- @return (number) 视频流开始处的秒数。
	tell: function(self: VideoStream): number

	-- 获取VideoStream是否正在播放。
	-- @return (boolean) VideoStream是否正在播放。
	isPlaying: function(self: VideoStream): boolean

	-- 获取视频流的文件名。
	-- @param source (Source) source 参数。
	-- @return (string) 视频流的文件名
	getFilename: function(self: VideoStream): string
	setSync: function(self: VideoStream, source?: Source)
end

local record Video

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Video): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Video): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Video, type_name: string): boolean

	-- 获取用于解码和控制视频的VideoStream对象。
	-- @return (VideoStream) 用于解码和控制视频的VideoStream。
	getStream: function(self: Video): VideoStream

	-- 获取用于播放视频音频的音频源。如果视频没有音频，或者使用 nil 参数调用 Video:setSource ，则可能返回 nil。
	-- @return (Source or nil) 用于音频播放的音频源，如果视频没有音频则为零。
	getSource: function(self: Video): Source | nil

	-- 设置用于播放视频音频的音频源。音频源还控制播放速度和同步。
	-- @param source (Source) 用于音频播放的音频源，或 nil 以禁用音频同步。 （默认值：无。）
	setSource: function(self: Video, source?: Source)

	-- 获取视频的宽度（以像素为单位）。
	-- @return (integer) 视频的宽度。
	getWidth: function(self: Video): integer

	-- 获取视频的高度（以像素为单位）。
	-- @return (integer) 视频的高度。
	getHeight: function(self: Video): integer

	-- 获取视频的宽度和高度（以像素为单位）。
	-- @return (integer) 视频的宽度。
	-- @return (integer) 视频的高度。
	getDimensions: function(self: Video): integer, integer
	getPixelWidth: function(self: Video): integer
	getPixelHeight: function(self: Video): integer
	getPixelDimensions: function(self: Video): integer, integer

	-- 设置绘制视频时使用的缩放过滤器。
	-- @param min_filter (string) 缩小视频时使用的过滤模式。
	-- @param mag_filter (string) 放大视频时使用的过滤模式。
	-- @param anisotropy (number) 使用的各向异性过滤的最大量。 （默认值：1。）
	setFilter: function(self: Video, min_filter: string, mag_filter?: string, anisotropy?: number)

	-- 获取绘制视频时使用的缩放过滤器。
	-- @return (string) 缩小视频时使用的过滤模式。
	-- @return (string) 放大视频时使用的过滤模式。
	-- @return (number) 使用的各向异性过滤的最大量。
	getFilter: function(self: Video): string, string, number
end

-- 该模块负责解码、控制和流式传输视频文件。
local record VideoModule

	-- 创建一个新的视频流。目前仅支持 Ogg Theora 视频文件。 VideoStreams 无法绘制视频，请参阅 love.graphics.newVideo 。
	-- @param filename (string) Ogg Theora 视频文件的文件路径。
	-- @return (VideoStream) 一个新的视频流。
	newVideoStream: function(filename: string): VideoStream
end

-- Canvas 用于离屏渲染。将其视为您可以绘制的不可见屏幕，但只有将其绘制到实际可见屏幕上时，它才会可见。它也称为 "render to texture"。
local record Canvas

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Canvas): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Canvas): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Canvas, type_name: string): boolean

	-- 获取纹理的宽度。
	-- @return (integer) 纹理的宽度。
	getWidth: function(self: Canvas): integer

	-- 获取纹理的高度。
	-- @return (integer) 纹理的高度。
	getHeight: function(self: Canvas): integer

	-- 获取纹理的宽度和高度。
	-- @return (integer) 纹理的宽度。
	-- @return (integer) 纹理的高度。
	getDimensions: function(self: Canvas): integer, integer

	-- 获取纹理的宽度（以像素为单位）。
	-- DPI 比例因子，而不是像素。使用 getWidth 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelWidth。
	-- @return (integer) 纹理的宽度，以像素为单位。
	getPixelWidth: function(self: Canvas): integer

	-- 获取纹理的高度（以像素为单位）。
	-- DPI 比例因子，而不是像素。使用 getHeight 进行与绘制纹理相关的计算（例如，计算原点偏移量），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelHeight。
	-- @return (integer) 纹理的高度，以像素为单位。
	getPixelHeight: function(self: Canvas): integer

	-- 获取纹理的宽度和高度（以像素为单位）。
	-- Texture:getDimensions 获取纹理的尺寸，单位是按纹理的 DPI 比例因子缩放的单位，而不是像素。使用 getDimensions
	-- 进行与绘制纹理相关的计算（例如计算原点偏移），并且仅在专门处理像素时（例如使用 Canvas:newImageData 时）使用 getPixelDimensions。
	-- @return (integer) 纹理的宽度，以像素为单位。
	-- @return (integer) 纹理的高度，以像素为单位。
	getPixelDimensions: function(self: Canvas): integer, integer

	-- 获取纹理的DPI比例因子。
	-- DPI 比例因子表示相对像素密度。 DPI 比例因子为 2 意味着纹理在每个维度上的像素密度是 DPI 比例因子为 1 的纹理的两倍（同一区域中像素数量的 4 倍）。
	-- 例如，像素尺寸为 100x100、DPI 比例因子为 2 的纹理将被绘制为 50x50。这对于高 dpi/视网膜显示器非常有用，可以轻松地交换更高或更低像素密度的图像和画布，而无需任何额外的手动缩放逻辑。
	-- @return (number) 纹理的 DPI 比例因子。
	getDPIScale: function(self: Canvas): number

	-- 获取纹理的像素格式。
	-- @return (string) 创建纹理时使用的像素格式。
	getFormat: function(self: Canvas): string

	-- 获取绘制到画布时使用的多重采样抗锯齿 (MSAA) 样本数。
	-- 如果运行 LÖVE 的系统不支持该数字，则该数字可能与用作 love.graphics.newCanvas 参数的数字不同。
	-- @return (integer) 画布在绘制时使用的多重采样抗锯齿样本数。
	getMSAA: function(self: Canvas): integer

	-- 获取纹理的类型。
	-- @return (string) 纹理的类型。
	getTextureType: function(self: Canvas): string

	-- 获取体积纹理的深度。对于 2D、立方体贴图和数组纹理返回 1。
	-- @return (integer) 体积纹理的深度。
	getDepth: function(self: Canvas): integer

	-- 获取数组纹理中的层数/切片数。对于 2D、立方体贴图和体积纹理，返回 1。
	-- @return (integer) 阵列纹理中的层数。
	getLayerCount: function(self: Canvas): integer

	-- 获取纹理中包含的 mipmap 数量。如果纹理不是使用 mipmap 创建的，它将返回 1。
	-- @return (integer) 纹理中 mipmap 的数量。
	getMipmapCount: function(self: Canvas): integer

	-- 获取创建此 Canvas 时使用的 MipmapMode。
	-- @return (string) 创建此 Canvas 时使用的 mipmap 模式。
	getMipmapMode: function(self: Canvas): string

	-- 获取纹理的 mipmap 过滤模式。在 11.0 之前，此方法仅适用于图像。
	-- @return (string) 在 mipmap 级别之间使用的过滤模式。如果未启用 mipmap 过滤，则为 nil。
	-- @return (number) 用于确定图像在绘制时是否应使用比正常情况更多或更少详细的 mipmap 级别的值。
	getMipmapFilter: function(self: Canvas): string, number

	-- 设置纹理的 mipmap 过滤器模式。在 11.0 之前，此方法仅适用于图像。
	--
	-- Mipmapping 在以缩小比例绘制纹理时非常有用。它可以提高性能并减少锯齿问题。
	--
	-- 在创建时启用了 mipmaps 标志，以便 mipmap 过滤器产生任何效果。在 0.10.0 之前的版本中，最好在使用 love.graphics.newImage 创建图像后直接调用此方法，以避免某些图形驱动程序中的错误。
	--
	-- 由于硬件限制和驱动程序错误，在 0.10.0 之前的版本中，未从 CompressedData 加载的图像必须具有二维幂（64x64、512x256 等）才能使用 mipmap。
	setMipmapFilter: function(self: Canvas)

	-- 设置纹理的 mipmap 过滤器模式。在 11.0 之前，此方法仅适用于图像。
	--
	-- Mipmapping 在以缩小比例绘制纹理时非常有用。它可以提高性能并减少锯齿问题。
	--
	-- 在创建时启用了 mipmaps 标志，以便 mipmap 过滤器产生任何效果。在 0.10.0 之前的版本中，最好在使用 love.graphics.newImage 创建图像后直接调用此方法，以避免某些图形驱动程序中的错误。
	--
	-- 由于硬件限制和驱动程序错误，在 0.10.0 之前的版本中，未从 CompressedData 加载的图像必须具有二维幂（64x64、512x256 等）才能使用 mipmap。
	-- @param filter (FilterMode) 在 mipmap 级别之间使用的过滤模式。 'nearest' 通常会提供更好的性能。
	-- @param sharpness (number) 正的锐度值使纹理在绘制时使用更详细的 mipmap 级别，但会牺牲性能。负值则相反。 （默认值：0。）
	setMipmapFilter: function(self: Canvas, filter: FilterMode, sharpness?: number)

	-- 获取在着色器中从深度纹理采样时使用的比较模式。
	-- 深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
	-- @return (string or nil) 在着色器中从此纹理采样时使用的比较模式，如果尚未在此纹理上调用 setDepthSampleMode，则为 nil。 （默认值：无。）
	getDepthSampleMode: function(self: Canvas): string | nil

	-- 设置从着色器中的深度纹理采样时使用的比较模式。深度纹理比较模式是高级低级功能，通常与 3D 阴影贴图一起使用。
	-- 在着色器中使用具有比较模式设置的深度纹理时，必须将其声明为sampler2DShadow 并在GLSL 3 着色器中使用。在着色器中访问纹理的结果将返回一个介于 0 和 1
	-- 之间的浮点数，与通过比较操作的测试集的样本数量成正比（如果启用双线性过滤，最多将使用 4 个样本）。
	-- 深度纹理比较只能与可读的深度格式画布一起使用。
	-- @param mode (string) 在着色器中从此纹理采样时使用的比较模式。
	setDepthSampleMode: function(self: Canvas, mode?: string)

	-- 根据最高分辨率 mipmap 级别的内容为画布生成 mipmap。
	-- 创建画布时必须将 mipmap 设置为除 'none' 之外的 MipmapMode，此函数才能正常工作。仅当 Canvas 不是活动渲染目标时才应调用它。
	-- 如果mipmap模式设置为'auto'，当从这个Canvas切换到另一个Canvas或切换到主屏幕时，会在love.graphics.setCanvas内部自动调用此函数。
	generateMipmaps: function(self: Canvas)

	-- 使用函数渲染到画布。
	-- 这是 love.graphics.setCanvas 的快捷方式：
	-- canvas:renderTo( func )
	-- 与
	-- love.graphics.setCanvas( 画布 )
	-- func()
	-- love.graphics.setCanvas()
	-- @param callback (function) 执行绘图操作的函数。
	renderTo: function(self: Canvas, callback: function())

	-- 获取是否可以绘制纹理并将其发送到着色器。
	-- 使用模板和/或深度 PixelFormat 创建的画布默认情况下不可读，除非在传递到 love.graphics.newCanvas. 的设置表中指定 Readable=true
	-- 仍然可以渲染不可读的画布。
	-- @return (boolean) 纹理是否可读。
	isReadable: function(self: Canvas): boolean

	-- 从画布的内容生成图像数据。
	-- @param slice (integer) 分别是立方体贴图、数组或体积类型画布的立方体贴图面索引、数组索引或深度层。对于常规 2D 画布，此参数将被忽略。
	-- @param mipmap (integer) 要使用的 mipmap 索引，用于具有 mipmap 的画布。 （默认值：1。）
	-- @param x (integer) 画布内要捕获的区域的左上角（以像素为单位）的 x 轴。
	-- @param y (integer) 画布内要捕获的区域的左上角（以像素为单位）的 y 轴。
	-- @param width (integer) 画布内要捕获的区域的宽度（以像素为单位）。
	-- @param height (integer) 画布内要捕获的区域的高度（以像素为单位）。
	-- @return (any) 由画布内容制成的新 ImageData。
	newImageData: function(self: Canvas, slice?: integer, mipmap?: integer, x?: integer, y?: integer, width?: integer, height?: integer): any

	-- 设置纹理的过滤模式。
	-- @param min_filter (string) 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	-- @param mag_filter (string) 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更大的尺寸渲染它）。 （默认值：分钟。）
	-- @param anisotropy (number) 使用的各向异性过滤的最大数量。 （默认值：1。）
	setFilter: function(self: Canvas, min_filter: string, mag_filter?: string, anisotropy?: number)

	-- 获取纹理的滤镜模式。
	-- @return (string) 缩小纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	-- @return (string) 放大纹理时使用的过滤器模式（在屏幕上以比其像素大小更小的尺寸渲染它）。
	-- @return (number) 使用的各向异性过滤的最大量。
	getFilter: function(self: Canvas): string, string, number

	-- 设置纹理的环绕属性。
	-- 当使用大于纹理范围的四边形绘制纹理时，或者使用使用 [0, 1] 之外的纹理坐标的自定义着色器时，此函数设置纹理的重复方式。纹理可以被夹紧或设置为在水平和垂直方向上重复。
	-- 夹紧的纹理仅出现一次（纹理的边缘拉伸以填充四边形的范围），而重复的纹理则根据四边形中的空间重复多次。
	-- @param horizontal (string) 纹理的水平环绕模式。
	-- @param vertical (string) 纹理的垂直环绕模式。 （默认：水平。）
	-- @param depth (string) 体积纹理 z 轴的包裹模式。 （默认值：水平。）
	setWrap: function(self: Canvas, horizontal: string, vertical?: string, depth?: string): boolean

	-- 获取纹理的环绕属性。
	-- 该函数返回当前设置的纹理水平和垂直环绕模式。
	-- @return (string) 纹理的水平环绕模式。
	-- @return (string) 纹理的垂直环绕模式。
	-- @return (string) 体积纹理 z 轴的包裹模式。
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
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Font): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Font): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Font, type_name: string): boolean

	-- 确定给定字符串所采用的最大宽度（考虑换行符）。
	-- @param text (string) 一个字符串。
	-- @return (number) 文本的宽度。
	getWidth: function(self: Font, text: string): number

	-- 获取字体的高度。
	-- 字体的高度是包括任何间距的大小；它需要的高度。
	-- @return (number) 字体的高度（以像素为单位）。
	getHeight: function(self: Font): number

	-- 获取字体的基线。
	-- 大多数脚本都共享基线的概念：字符所在的假想水平线。在某些脚本中，部分字形位于基线下方。
	-- @return (number) 字体的基线（以像素为单位）。
	getBaseline: function(self: Font): number

	-- 获取字体的上升度。
	-- 上升跨越基线和距基线最远的字形顶部之间的距离。
	-- @return (number) 字体的上升（以像素为单位）。
	getAscent: function(self: Font): number

	-- 获取字体的血统。
	-- 下降跨越字体中基线和最低下降字形之间的距离。
	-- @return (number) 字体的下降（以像素为单位）。
	getDescent: function(self: Font): number

	-- 获取 Font 是否可以渲染字符或字符串。
	-- @param text_or_codepoint (string or integer) UTF-8 编码的 unicode 字符串。
	-- @param ... (string or integer) ... 参数。
	-- @return (boolean) 字体是否可以渲染字符串中的所有UTF-8字符。取决于重载：字体是否可以渲染字符表示的所有字形。取决于重载：字体是否可以渲染由代码点数字表示的所有字形。
	hasGlyphs: function(self: Font, text_or_codepoint: string | integer, ...: string | integer): boolean

	-- 获取字体中两个字符之间的字距调整。
	-- 字距调整通常在 love.graphics.print、文本对象、Font:getWidth、Font:getWrap 等中自动处理。当手动将文本拼接在一起时，此功能非常有用。
	-- @param left (string or integer) 左边的字符。取决于重载：左侧字形的 unicode 编号。
	-- @param right (string or integer) 正确的字符。取决于重载：正确字形的 unicode 编号。
	-- @return (number) 添加到两个字符之间的间距的字距调整量。可能是负值。
	getKerning: function(self: Font, left: string | integer, right: string | integer): number

	-- 设置后备字体。当字体不包含字形时，它将替换下一个后续后备字体中的字形。这类似于在层叠样式表 (CSS) 中设置 'font stack'。
	-- 重载说明：
	-- 1. 如果调用此函数，则应在调用 love.graphics.print、Font:getWrap 和其他使用字形定位信息的 Font 方法之前调用。每个后备字体必须从与主字体相同的文件类型创建。例如，从 .ttf
	-- 文件创建的字体只能使用从 .ttf 文件创建的后备字体。
	-- @param ... (Font) ... 参数。
	setFallbacks: function(self: Font, ...: Font)

	-- 设置行高。
	-- 当以行渲染字体时，实际高度将由行高乘以字体高度确定。默认值为 1.0。
	-- @param height (number) 新行高。
	setLineHeight: function(self: Font, height: number)

	-- 获取行高。
	-- 这将是之前由 Font:setLineHeight 设置的值，默认情况下为 1.0。
	-- @return (number) 当前行高。
	getLineHeight: function(self: Font): number

	-- 获取字体的 DPI 比例因子。
	-- DPI 比例因子表示相对像素密度。 DPI 比例因子为 2 意味着与 DPI 比例因子为 1 的字体相比，字体的字形在每个维度上的像素密度是两倍（同一区域中像素数量的 4 倍）。
	-- TrueType 字体的字体大小在内部按字体指定的 DPI 比例因子进行缩放。默认情况下，LÖVE 在创建 TrueType 字体时使用屏幕的 DPI 比例因子。
	-- @return (number) 字体的 DPI 比例因子。
	getDPIScale: function(self: Font): number

	-- 获取字体的过滤模式。
	-- @return (string) 缩小字体时使用的过滤模式。
	-- @return (string) 放大字体时使用的过滤模式。
	-- @return (number) 使用的各向异性过滤的最大量。
	getFilter: function(self: Font): string, string, number

	-- 设置字体的过滤模式。
	-- @param min (string) 如何缩小字体。
	-- @param mag (string) 如何放大字体。
	-- @param anisotropy (number) 使用的各向异性过滤的最大量。 （默认值：1。）
	setFilter: function(self: Font, min: string, mag?: string, anisotropy?: number)

	-- 获取文本的格式信息（给定换行限制）。
	-- 此函数正确解释换行符（即 '\n'）。
	-- @param text (string) 将被换行的文本。
	-- @param wrap_limit (number) 在换行之前允许“'text'”每行的最大宽度（以像素为单位）。
	-- @return (number) 换行文本的最大宽度。
	-- @return ({string}) 包含换行的每一行文本的序列。
	getWrap: function(self: Font, text: string, wrap_limit: number): number, {string}
end

-- 可绘制文本。
local record Text

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Text): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Text, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Text): boolean

	-- 用新的未格式化字符串替换 Text 对象的内容。
	-- @param text (string) 要使用的新文本字符串。
	set: function(self: Text, text: string)

	-- 用新的未格式化字符串替换 Text 对象的内容。
	-- @param text ({string | Color}) 包含用作新文本的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
	set: function(self: Text, text: {string | Color})

	-- 用新的格式化字符串替换 Text 对象的内容。
	-- @param text (string) 要使用的新文本字符串。
	-- @param wrap_limit (number) 自动换行之前文本的最大宽度（以像素为单位）。
	-- @param align (AlignMode) 文本的对齐方式。
	setf: function(self: Text, text: string, wrap_limit: number, align: AlignMode)

	-- 用新的格式化字符串替换 Text 对象的内容。
	-- @param text ({string | Color}) 包含用作新文本的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
	-- @param wrap_limit (number) 自动换行之前文本的最大宽度（以像素为单位）。
	-- @param align (AlignMode) 文本的对齐方式。
	setf: function(self: Text, text: {string | Color}, wrap_limit: number, align: AlignMode)

	-- 将附加彩色文本添加到 Text 对象的指定位置。
	-- @param text (ColoredText) 要添加到对象的文本。
	-- @param transform (Transform) 新文本在 x 轴上的位置。 （默认值：0。）
	-- @return (integer) index — 可与 Text:getWidth 或 Text:getHeight 一起使用的索引号。
	add: function(self: Text, text: ColoredText, transform: Transform): integer

	-- 将附加彩色文本添加到 Text 对象的指定位置。
	-- @param text (ColoredText) 包含要添加到对象的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
	-- @param x (number) 新文本在 x 轴上的位置。 （默认值：0。）
	-- @param y (number) 新文本在 y 轴上的位置。 （默认值：0。）
	-- @param angle (number) 新文本的方向（以弧度表示）。 （默认值：0。）
	-- @param scale_x (number) x 轴上的比例因子。 （默认值：1。）
	-- @param scale_y (number) y 轴的比例因子。 （默认值：sx。）
	-- @param origin_x (number) x 轴上的原点偏移。 （默认值：0。）
	-- @param origin_y (number) y 轴上的原点偏移。 （默认值：0。）
	-- @param shear_x (number) x 轴上的剪切/倾斜因子。 （默认值：0。）
	-- @param shear_y (number) y 轴上的剪切/倾斜因子。 （默认值：0。）
	-- @return (integer) index — 可与 Text:getWidth 或 Text:getHeight 一起使用的索引号。
	add: function(self: Text, text: ColoredText, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- 将附加格式化/彩色文本添加到 Text 对象的指定位置。
	--
	-- 在任何缩放、旋转和其他坐标转换之前应用自动换行限制。因此，即使比例参数发生变化，在给定相同的换行限制的情况下，每行的文本量也保持不变。
	-- @param text (ColoredText) 要添加到对象的文本。
	-- @param wrap_limit (number) 自动换行之前文本的最大宽度（以像素为单位）。
	-- @param align (AlignMode) 文本的对齐方式。
	-- @param transform (Transform) 新文本的位置（x 轴）。
	-- @return (integer) index — 可与 Text:getWidth 或 Text:getHeight 一起使用的索引号。
	addf: function(self: Text, text: ColoredText, wrap_limit: number, align: AlignMode, transform: Transform): integer

	-- 将附加格式化/彩色文本添加到 Text 对象的指定位置。
	--
	-- 在任何缩放、旋转和其他坐标转换之前应用自动换行限制。因此，即使比例参数发生变化，在给定相同的换行限制的情况下，每行的文本量也保持不变。
	-- @param text (ColoredText) 包含要添加到对象的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。
	-- @param wrap_limit (number) 自动换行之前文本的最大宽度（以像素为单位）。
	-- @param align (AlignMode) 文本的对齐方式。
	-- @param x (number) 新文本的位置（x 轴）。
	-- @param y (number) 新文本的位置（y 轴）。
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切/倾斜因子（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切/倾斜因子（y 轴）。 （默认值：0。）
	-- @return (integer) index — 可与 Text:getWidth 或 Text:getHeight 一起使用的索引号。
	addf: function(self: Text, text: ColoredText, wrap_limit: number, align: AlignMode, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- 清除文本对象的内容。
	clear: function(self: Text)

	-- 替换文本使用的字体。
	-- @param font (Font) 与此 Text 对象一起使用的新字体。
	setFont: function(self: Text, font: Font)

	-- 获取与 Text 对象一起使用的 Font。
	-- @return (Font) 此文本对象使用的字体。
	getFont: function(self: Text): Font

	-- 获取文本的宽度（以像素为单位）。
	-- @return (number) width — 文本的宽度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的宽度。
	getWidth: function(self: Text): number

	-- 获取文本的宽度（以像素为单位）。
	-- @param index (integer) Text:add 或 Text:addf 返回的索引号。
	-- @return (number) 子字符串的宽度（在缩放和其他转换之前）。
	getWidth: function(self: Text, index: integer): number

	-- 获取文本的高度（以像素为单位）。
	-- @return (number) height  — 文本的高度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的高度。
	getHeight: function(self: Text): number

	-- 获取文本的高度（以像素为单位）。
	-- @param index (integer) Text:add 或 Text:addf 返回的索引号。
	-- @return (number) height  — 文本的高度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的高度。
	getHeight: function(self: Text, index: integer): number

	-- 获取文本的宽度和高度（以像素为单位）。
	-- @return (number) width — 文本的宽度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的宽度。
	-- @return (number) height — 文本的高度。如果使用 Text:add 添加了多个子字符串，则返回最后一个子字符串的高度。
	getDimensions: function(self: Text): number, number

	-- 获取文本的宽度和高度（以像素为单位）。
	-- @param index (integer) Text:add 或 Text:addf 返回的索引号。
	-- @return (number) 子字符串的宽度（在缩放和其他转换之前）。
	-- @return (number) 子字符串的高度（在缩放和其他转换之前）。
	getDimensions: function(self: Text, index: integer): number, number
end

-- 具有纹理坐标信息的四边形（具有四个边和四个角的多边形）。
local record Quad

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Quad): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Quad, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Quad): boolean

	-- 根据视口设置纹理坐标。
	-- @param x (number) 沿 x 轴的左上角。
	-- @param y (number) y 轴的左上角。
	-- @param width (number) 视口的宽度。
	-- @param height (number) 视口的高度。
	-- @param texture_width (number) 可选的新参考宽度，纹理的宽度。如果设置，则必须大于 0。 （默认值：无。）
	-- @param texture_height (number) 可选的新参考高度，纹理的高度。如果设置，则必须大于 0。 （默认值：无。）
	setViewport: function(self: Quad, x: number, y: number, width: number, height: number, texture_width?: number, texture_height?: number)

	-- 获取此Quad 的当前视口。
	-- @return (number) 沿 x 轴的左上角。
	-- @return (number) y 轴的左上角。
	-- @return (number) 视口的宽度。
	-- @return (number) 视口的高度。
	getViewport: function(self: Quad): number, number, number, number

	-- 获取最初在 love.graphics.newQuad.
	-- @param layer (integer) layer 参数。
	-- @return (number or integer) 四边形使用的纹理宽度。
	-- @return (number) 四边形使用的纹理高度。
	getTextureDimensions: function(self: Quad): number, number
	setLayer: function(self: Quad, layer: integer)
	getLayer: function(self: Quad): integer
end

-- 用于绘制任意纹理形状的 2D 多边形网格。
local record Mesh

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Mesh): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Mesh, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Mesh): boolean

	-- 用新顶点替换网格中的一系列顶点。网格体的顶点总数在创建后就无法更改。这通常比在循环中调用 Mesh:setVertex 更有效。
	-- @param vertices ({MeshVertex}) 该表填充了每个顶点的顶点信息表，其形式为{vertex, ...}，其中每个顶点是一个形式为{attributecomponent, ...}的表。
	-- @param start_vertex (integer) 要替换的第一个顶点的索引。 （默认值：1。）
	-- @param vertex_count (integer) 要替换的顶点数量。 （默认值：全部。）
	setVertices: function(self: Mesh, vertices: {MeshVertex}, start_vertex?: integer, vertex_count?: integer)

	-- 用新顶点替换网格中的一系列顶点。网格体的顶点总数在创建后就无法更改。这通常比在循环中调用 Mesh:setVertex 更有效。
	-- @param data (Data) 要复制的数据对象。数据的内容必须与该网格体的顶点格式的布局相匹配。
	-- @param start_vertex (integer) 要替换的第一个顶点的索引。 （默认值：1。）
	-- @param vertex_count (integer) 要替换的顶点数量。 （默认值：全部。）
	setVertices: function(self: Mesh, data: Data, start_vertex?: integer, vertex_count?: integer)

	-- 设置网格中顶点的属性。
	--
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	-- @param index (integer) 要修改的顶点的索引（从一开始）。
	-- @param vertex (MeshVertex) 包含顶点信息的表，格式为{attributecomponent, ...}。
	setVertex: function(self: Mesh, index: integer, vertex: MeshVertex)

	-- 设置网格中顶点的属性。
	--
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	-- @param index (integer) 要修改的顶点的索引（从一开始）。
	-- @param components (number...) 带有顶点信息的表。
	setVertex: function(self: Mesh, index: integer, components: number...)

	-- 获取网格中顶点的属性。
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	-- 重载说明：
	-- 1. 返回值的顺序与网格顶点格式中顶点属性的顺序相同。不是使用自定义顶点格式创建的标准网格将返回两个位置号、两个纹理坐标
	--     numbers, and four color components: x, y, u, v, r, g, b, a.
	-- 2. 获取不是使用自定义顶点格式创建的网格的顶点组件。
	-- @param index (integer) 要检索其信息的顶点的从一开始的索引。取决于过载：要检索其信息的顶点的索引。
	-- @return (any) 指定顶点中第一个顶点属性的第一个组件。
	getVertex: function(self: Mesh, index: integer): any

	-- 设置网格中顶点内特定属性的属性。
	-- 没有在 love.graphics.newMesh 中指定的自定义顶点格式的网格体将位置作为其第一个属性，将纹理坐标作为其第二个属性，将颜色作为其第三个属性。
	-- 重载说明：
	-- 1. 存在于属性中但未指定为参数的属性组件对于浮点数据类型的属性默认为 0，对于字节数据类型默认为 255。
	-- @param vertex_index (integer) 要修改的顶点的索引（从一开始）。
	-- @param attribute_index (integer) 要修改的顶点中属性的索引（从一开始）。
	-- @param components (number...) 属性第一个组件的新值。
	setVertexAttribute: function(self: Mesh, vertex_index: integer, attribute_index: integer, components: number...)

	-- 获取网格中顶点内特定属性的属性。
	-- 没有在 love.graphics.newMesh 中指定的自定义顶点格式的网格体将位置作为其第一个属性，将纹理坐标作为其第二个属性，将颜色作为其第三个属性。
	-- @param vertex_index (integer) 要检索其属性的顶点的索引（从一开始）。
	-- @param attribute_index (integer) 要检索的顶点中的属性索引（从一开始）。
	-- @return (any) 属性第一个组成部分的值。
	getVertexAttribute: function(self: Mesh, vertex_index: integer, attribute_index: integer): any

	-- 获取Mesh中的顶点总数。
	-- @return (integer) 网格中的顶点总数。
	getVertexCount: function(self: Mesh): integer

	-- 获取创建网格体所用的顶点格式。
	-- 重载说明：
	--  1. If a Mesh wasn't created with a custom vertex format, it will have the following vertex format: 默认格式
	-- = { {'VertexPosition', 'float', 2}, -- 每个顶点的 x,y 位置。 {'VertexTexCoord', 'float', 2}, -- 每个顶点的 u,v 纹理坐标。
	-- {'VertexColor', 'byte', 4} -- 每个顶点的 r,g,b,a 颜色。 }
	-- @return ({{any}}) 网格体的顶点格式，它是一个表，其中包含用于创建网格体的每个顶点属性的表，格式为 {attribute, ...}。
	getVertexFormat: function(self: Mesh): {{any}}

	-- 启用或禁用网格中的特定顶点属性。绘制网格时不使用禁用属性中的顶点数据。
	-- 重载说明：
	-- 1. 如果网格不是使用自定义顶点格式创建的，它将具有 3 个顶点属性，分别名为 VertexPosition、VertexTexCoord 和
	-- VertexColor。否则，属性名称必须与创建网格体时以顶点格式指定的顶点属性之一匹配，或者必须与通过 Mesh:attachAttribute 连接到此网格体的另一个网格体的顶点属性匹配。
	-- @param name (string) 要启用或禁用的顶点属性的名称。
	-- @param enabled (boolean) 绘制此Mesh时是否使用顶点属性。
	setAttributeEnabled: function(self: Mesh, name: string, enabled: boolean)

	-- 获取Mesh中特定顶点属性是否启用。绘制网格时不使用禁用属性中的顶点数据。
	-- 重载说明：
	-- 1. 如果网格不是使用自定义顶点格式创建的，它将具有 3 个顶点属性，分别名为 VertexPosition、VertexTexCoord 和
	-- VertexColor。否则，属性名称必须与创建网格体时以顶点格式指定的顶点属性之一匹配，或者必须与通过 Mesh:attachAttribute 连接到此网格体的另一个网格体的顶点属性匹配。
	-- @param name (string) 要检查的顶点属性的名称。
	-- @return (boolean) 绘制此Mesh时是否使用顶点属性。
	isAttributeEnabled: function(self: Mesh, name: string): boolean

	-- 将来自不同网格的顶点属性附加到此网格上，以供绘制时使用。这可用于在多个不同网格之间共享顶点属性数据。
	-- 重载说明：
	-- 1. 如果网格不是使用自定义顶点格式创建的，它将具有 3 个顶点属性，分别名为 VertexPosition、VertexTexCoord 和 VertexColor。可以通过将自定义命名属性声明为属性 vec4
	-- MyCustomAttributeName 在顶点着色器中访问它们；位于顶点着色器代码的顶层。该名称必须与网格体顶点格式和 Mesh:attachAttribute 的名称参数中指定的名称相匹配。
	-- @param name (string) 要附加的顶点属性的名称。
	-- @param mesh (Mesh) 要从中获取顶点属性的网格体。
	-- @param step (string) 绘制网格时该属性是按顶点还是按实例。 （默认：'pervertex'。）
	-- @param attribute_name (string) 在着色器代码中使用的属性的名称。默认为给定网格中的属性名称。可用于在渲染时为此属性使用不同的名称。 （默认值：名称。）
	attachAttribute: function(self: Mesh, name: string, mesh: Mesh, step?: string, attribute_name?: string)

	-- 从此网格中删除先前附加的顶点属性。
	-- @param name (string) 要分离的附加顶点属性的名称。
	-- @return (boolean) 属性是否已成功分离。
	detachAttribute: function(self: Mesh, name: string): boolean

	-- 设置网格的顶点贴图。顶点图描述了绘制Mesh时顶点的使用顺序。顶点、顶点贴图和网格绘制模式共同确定屏幕上显示的内容。
	--
	-- 顶点贴图允许您在绘制时重新排序或重用顶点，而无需更改实际的顶点参数或复制顶点。当与不同的网格绘制模式结合使用时，它特别有用。
	setVertexMap: function(self: Mesh)

	-- 设置网格的顶点贴图。顶点图描述了绘制Mesh时顶点的使用顺序。顶点、顶点贴图和网格绘制模式共同确定屏幕上显示的内容。
	--
	-- 顶点贴图允许您在绘制时重新排序或重用顶点，而无需更改实际的顶点参数或复制顶点。当与不同的网格绘制模式结合使用时，它特别有用。
	-- @param indices ({number}) 包含绘图时使用的顶点索引列表的表。值必须在 Mesh:getVertexCount() 范围内。
	setVertexMap: function(self: Mesh, indices: {number})

	-- 设置网格的顶点贴图。顶点图描述了绘制Mesh时顶点的使用顺序。顶点、顶点贴图和网格绘制模式共同确定屏幕上显示的内容。
	--
	-- 顶点贴图允许您在绘制时重新排序或重用顶点，而无需更改实际的顶点参数或复制顶点。当与不同的网格绘制模式结合使用时，它特别有用。
	-- @param indices (number...) 包含绘图时使用的顶点索引列表的表。值必须在 Mesh:getVertexCount() 范围内。
	setVertexMap: function(self: Mesh, indices: number...)

	-- 设置网格的顶点贴图。顶点图描述了绘制Mesh时顶点的使用顺序。顶点、顶点贴图和网格绘制模式共同确定屏幕上显示的内容。
	--
	-- 顶点贴图允许您在绘制时重新排序或重用顶点，而无需更改实际的顶点参数或复制顶点。当与不同的网格绘制模式结合使用时，它特别有用。
	-- @param data (Data) 绘制时使用的顶点索引表。值必须在 Mesh:getVertexCount()-1
	-- @param data_type (IndexDataType) 上面顶点索引表的数据类型。
	-- @param index_count (number) 绘制时使用的第三个顶点的索引。
	setVertexMap: function(self: Mesh, data: Data, data_type: IndexDataType, index_count?: number)

	-- 获取网格的顶点贴图。顶点图描述了绘制Mesh时顶点的使用顺序。顶点、顶点贴图和网格绘制模式共同确定屏幕上显示的内容。
	-- 如果之前没有通过 Mesh:setVertexMap 设置顶点贴图，那么该函数在 LÖVE 0.10.0+ 中将返回 nil，或者在 0.9.2 及更早版本中返回空表。
	-- @return ({integer} or nil) 包含绘图时使用的顶点索引列表的表。
	getVertexMap: function(self: Mesh): {integer} | nil

	-- 设置绘制网格时使用的纹理（图像或画布）。
	setTexture: function(self: Mesh)

	-- 设置绘制网格时使用的纹理（图像或画布）。
	-- @param texture (Image | Canvas) 绘制时用于纹理网格的图像或画布。
	setTexture: function(self: Mesh, texture: Image | Canvas)

	-- 获取绘制网格时使用的纹理（图像或画布）。
	-- @return (Image or Canvas or nil) 绘制时用于纹理网格的图像或画布，如果未设置则为零。
	getTexture: function(self: Mesh): Image | Canvas | nil

	-- 设置绘制网格时使用的模式。
	-- @param mode (string) 绘制网格时使用的模式。
	setDrawMode: function(self: Mesh, mode: string)

	-- 获取绘制网格时使用的模式。
	-- @return (string) 绘制网格时使用的模式。
	getDrawMode: function(self: Mesh): string

	-- 将网格的绘制顶点限制为总数的子集。
	setDrawRange: function(self: Mesh)

	-- 将网格的绘制顶点限制为总数的子集。
	-- @param start (integer) 绘制时要使用的第一个顶点的索引，或者如果为此网格设置了一个，则要使用的顶点映射中的第一个值的索引。
	-- @param count (integer) 绘制时要使用的顶点数，或者如果为此网格设置了一个，则要使用的顶点映射中的值的数量。
	setDrawRange: function(self: Mesh, start: integer, count: integer)

	-- 获取绘制Mesh时使用的顶点范围。
	-- 重载说明：
	-- 1. 如果之前没有用Mesh:setDrawRange设置Mesh的绘制范围，该函数将返回nil。
	-- @return (any) 绘制时使用的第一个顶点的索引，或者如果为此网格设置了一个，则使用顶点映射中的第一个值的索引。
	getDrawRange: function(self: Mesh): any

	-- 立即将Mesh中所有修改的顶点数据发送到显卡。
	-- 通常不需要调用此方法，因为 love.graphics.draw(mesh, ...) 会在需要时自动执行此操作，但显式使用 **Mesh:flush** 可以更好地控制工作何时发生。
	-- 如果使用此方法，则通常不应在 love.graphics.draw(mesh, ...) 调用之间多次（最多）调用它。
	flush: function(self: Mesh)
end

-- 使用单个图像，通过一次调用 love.graphics.draw() 绘制任意数量的相同图像副本。例如，这可用于以高性能绘制单个背景图像的重复副本。
local record SpriteBatch

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: SpriteBatch): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: SpriteBatch, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: SpriteBatch): boolean

	-- 将精灵添加到批次中。精灵按照添加的顺序绘制。
	-- @param x (number) 绘制对象的位置（x 轴）。
	-- @param y (number) 绘制对象的位置（y 轴）。
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）
	-- @return (integer) id — 添加的精灵的标识符。
	add: function(self: SpriteBatch, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- 将精灵添加到批次中。精灵按照添加的顺序绘制。
	-- @param quad (Quad) 要添加的四边形。
	-- @param x (number) 绘制对象的位置（x 轴）。
	-- @param y (number) 绘制对象的位置（y 轴）。
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）
	-- @return (integer) id — 添加的精灵的标识符。
	add: function(self: SpriteBatch, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- 更改批次中的精灵。这需要 SpriteBatch:add 或 SpriteBatch:addLayer 返回的精灵索引。
	-- @param index (integer) 将要更改的精灵的索引。
	-- @param x (number) 绘制对象的位置（x 轴）。
	-- @param y (number) 绘制对象的位置（y 轴）。
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）
	set: function(self: SpriteBatch, index: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 更改批次中的精灵。这需要 SpriteBatch:add 或 SpriteBatch:addLayer 返回的精灵索引。
	-- @param index (integer) 将要更改的精灵的索引。
	-- @param quad (Quad) 批次图像上使用的 Quad。
	-- @param x (number) 绘制对象的位置（x 轴）。
	-- @param y (number) 绘制对象的位置（y 轴）。
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）
	set: function(self: SpriteBatch, index: integer, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 将精灵添加到使用表纹理创建的批次中。
	-- @param layer (integer) 用于该精灵的图层索引。
	-- @param x (number) 绘制精灵的位置（x 轴）。 （默认值：0。）
	-- @param y (number) 绘制精灵的位置（y 轴）。 （默认值：0。）
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）
	-- @return (integer) spriteindex — 添加的精灵的索引，与 SpriteBatch:set 或 SpriteBatch:setLayer 一起使用。
	addLayer: function(self: SpriteBatch, layer: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- 将精灵添加到使用表纹理创建的批次中。
	-- @param layer (integer) 用于该精灵的图层索引。
	-- @param quad (Quad) 绘制精灵时使用的纹理层的分段。
	-- @param x (number) 绘制精灵的位置（x 轴）。 （默认值：0。）
	-- @param y (number) 绘制精灵的位置（y 轴）。 （默认值：0。）
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）
	-- @return (integer) spriteindex — 添加的精灵的索引，与 SpriteBatch:set 或 SpriteBatch:setLayer 一起使用。
	addLayer: function(self: SpriteBatch, layer: integer, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): integer

	-- 在使用表纹理创建的批处理中更改先前使用 add 或 addLayer 添加的精灵。
	-- @param index (integer) 要替换的现有精灵的索引。
	-- @param layer (integer) 用于此精灵的阵列纹理中的图层索引。
	-- @param x (number) 绘制精灵的位置（x 轴）。 （默认值：0。）
	-- @param y (number) 绘制精灵的位置（y 轴）。 （默认值：0。）
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）
	setLayer: function(self: SpriteBatch, index: integer, layer: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 在使用表纹理创建的批处理中更改先前使用 add 或 addLayer 添加的精灵。
	-- @param index (integer) 要替换的现有精灵的索引。
	-- @param layer (integer) 用于此精灵的图层的索引。
	-- @param quad (Quad) 绘制精灵时使用的纹理层的分段。
	-- @param x (number) 绘制精灵的位置（x 轴）。 （默认值：0。）
	-- @param y (number) 绘制精灵的位置（y 轴）。 （默认值：0。）
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）
	setLayer: function(self: SpriteBatch, index: integer, layer: integer, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 从缓冲区中删除所有精灵。
	clear: function(self: SpriteBatch)

	-- 立即将批次中所有新的和修改的精灵数据发送到显卡。
	-- 通常不需要调用此方法，因为 love.graphics.draw(spritebatch, ...) 会在需要时自动执行此操作，但显式使用 SpriteBatch:flush 可以更好地控制工作何时发生。
	-- 如果使用此方法，则通常不应在 love.graphics.draw(spritebatch, ...) 调用之间多次（最多）调用它。
	flush: function(self: SpriteBatch)

	-- 设置绘制时用于批处理中的精灵的纹理（图像或画布）。
	-- @param texture (Image or Canvas) 用于批处理中的精灵的新图像或画布。
	setTexture: function(self: SpriteBatch, texture: Image | Canvas)

	-- 获取SpriteBatch使用的纹理（Image或Canvas）。
	-- @return (Image or Canvas) SpriteBatch 使用的图像或画布。
	getTexture: function(self: SpriteBatch): Image | Canvas

	-- 设置将用于下一个添加和设置操作的颜色。调用不带参数的函数将禁用 SpriteBatch 的所有每个精灵颜色。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 在版本 0.9.2 及更早版本中，如果任何精灵有自己的颜色，则使用 love.graphics.setColor 设置的全局颜色将无法在 SpriteBatch 上工作。
	setColor: function(self: SpriteBatch)

	-- 设置将用于下一个添加和设置操作的颜色。调用不带参数的函数将禁用 SpriteBatch 的所有每个精灵颜色。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 在版本 0.9.2 及更早版本中，如果任何精灵有自己的颜色，则使用 love.graphics.setColor 设置的全局颜色将无法在 SpriteBatch 上工作。
	-- @param red (number) 红色的量。
	-- @param green (number) 绿色量。
	-- @param blue (number) 蓝色的量。
	-- @param alpha (number) 阿尔法的数量。 （默认值：1。）
	setColor: function(self: SpriteBatch, red: number, green: number, blue: number, alpha?: number)

	-- 设置将用于下一个添加和设置操作的颜色。调用不带参数的函数将禁用 SpriteBatch 的所有每个精灵颜色。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 在版本 0.9.2 及更早版本中，如果任何精灵有自己的颜色，则使用 love.graphics.setColor 设置的全局颜色将无法在 SpriteBatch 上工作。
	-- @param color (Color) 红色的量。
	setColor: function(self: SpriteBatch, color: Color)

	-- 获取将用于下一个添加和设置操作的颜色。
	-- 如果没有使用 SpriteBatch:setColor 设置颜色或当前 SpriteBatch 颜色已被清除，则此方法将返回 nil。
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @return (number) 红色分量 (0-1)。
	-- @return (number) 绿色分量 (0-1)。
	-- @return (number) 蓝色分量 (0-1)。
	-- @return (number) alpha 分量 (0-1)。
	getColor: function(self: SpriteBatch): number, number, number, number

	-- 获取SpriteBatch中当前精灵的数量。
	-- @return (integer) 当前批次中的精灵数量。
	getCount: function(self: SpriteBatch): integer

	-- 获取 SpriteBatch 可以容纳的最大精灵数。
	-- @return (integer) 批次可以容纳的精灵的最大数量。
	getBufferSize: function(self: SpriteBatch): integer

	-- 将网格中的每顶点属性附加到此 SpriteBatch 上，以供绘制时使用。它可以与 Shader 结合使用，以使用每个顶点或附加的每个精灵信息来增强 SpriteBatch，而不仅仅是每个精灵颜色。
	-- SpriteBatch 中的每个精灵都有 4 个顶点，按以下顺序排列：左上、左下、右上、右下。 SpriteBatch:add 返回的索引（并由 SpriteBatch:set 使用）可用于通过公式 1 + 4 * ( id
	-- - 1 ) 确定特定精灵的第一个顶点。
	-- 重载说明：
	-- 1. 如果使用自定义顶点格式创建，它将有 3 个顶点属性，分别为 VertexPosition、VertexTexCoord 和 VertexColor。如果具有这些名称的顶点属性附加到 SpriteBatch，它将分别覆盖
	-- SpriteBatch 的精灵位置、纹理坐标和精灵颜色。 可以通过将自定义命名属性声明为属性 vec4 MyCustomAttributeName
	-- 在顶点着色器中访问它们；位于顶点着色器代码的顶层。该名称必须与网格体顶点格式和 SpriteBatch:attachAttribute 的名称参数中指定的名称相匹配。网格体必须至少有 4 *
	-- SpriteBatch:getBufferSize 顶点才能附加到 SpriteBatch。
	-- @param name (string) 要附加的顶点属性的名称。
	-- @param mesh (Mesh) 要从中获取顶点属性的网格体。
	attachAttribute: function(self: SpriteBatch, name: string, mesh: Mesh)

	-- 将 SpriteBatch 中绘制的精灵限制为总数的子集。
	setDrawRange: function(self: SpriteBatch)

	-- 将 SpriteBatch 中绘制的精灵限制为总数的子集。
	-- @param start (integer) 要绘制的第一个精灵的索引。索引 1 对应于添加了 SpriteBatch:add 的第一个精灵。
	-- @param count (integer) 要绘制的精灵数量。
	setDrawRange: function(self: SpriteBatch, start: integer, count: integer)
	getDrawRange: function(self: SpriteBatch): number, number
end

-- 粒子系统可用于创建粒子效果，例如火焰或烟雾。
local record ParticleSystem

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: ParticleSystem): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: ParticleSystem, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: ParticleSystem): boolean

	-- 创建处于停止状态的粒子系统的相同副本。
	-- 重载说明：
	-- 1. 克隆的粒子系统继承原始粒子系统的所有可设置状态，但它们被初始化为停止状态。
	-- @return (ParticleSystem) 此粒子系统的新的相同副本。
	clone: function(self: ParticleSystem): ParticleSystem

	-- 设置用于粒子的纹理（图像或画布）。
	-- @param texture (Image or Canvas) 用于粒子的图像或画布。
	setTexture: function(self: ParticleSystem, texture: Image | Canvas)

	-- 获取用于粒子的纹理（图像或画布）。
	-- @return (Image or Canvas) 用于粒子的图像或画布。
	getTexture: function(self: ParticleSystem): Image | Canvas

	-- 设置缓冲区的大小（系统中允许的最大粒子量）。
	-- @param size (integer) 缓冲区大小。
	setBufferSize: function(self: ParticleSystem, size: integer)

	-- 获取粒子系统一次可以拥有的最大粒子数。
	-- @return (integer) 最大粒子数。
	getBufferSize: function(self: ParticleSystem): integer

	-- 设置粒子系统添加新粒子时使用的模式。
	-- @param mode (string) 粒子系统添加新粒子时使用的模式。
	setInsertMode: function(self: ParticleSystem, mode: string)

	-- 获取粒子系统添加新粒子时使用的模式。
	-- @return (string) 粒子系统添加新粒子时使用的模式。
	getInsertMode: function(self: ParticleSystem): string

	-- 设置每秒发射的粒子数量。
	-- @param rate (number) 每秒的粒子数。
	setEmissionRate: function(self: ParticleSystem, rate: number)

	-- 获取每秒发射的粒子数。
	-- @return (number) 每秒的粒子数。
	getEmissionRate: function(self: ParticleSystem): number

	-- 设置粒子系统应发射粒子的时间长度（如果为 -1，则它将永远发射粒子）。
	-- @param lifetime (number) 发射器的生命周期（以秒为单位）。
	setEmitterLifetime: function(self: ParticleSystem, lifetime: number)

	-- 获取粒子系统将发射粒子的时间（如果为-1则永远发射粒子）。
	-- @return (number) 发射器的生命周期（以秒为单位）。
	getEmitterLifetime: function(self: ParticleSystem): number

	-- 设置粒子的寿命。
	-- @param minimum (number) 粒子的最短寿命（以秒为单位）。
	-- @param maximum (number) 粒子的最大寿命（以秒为单位）。 （默认值：分钟。）
	setParticleLifetime: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- 获取粒子的寿命。
	-- @return (number) 粒子的最短寿命（以秒为单位）。
	-- @return (number) 粒子的最大寿命（以秒为单位）。
	getParticleLifetime: function(self: ParticleSystem): number, number

	-- 设置发射器的位置。
	-- @param x (number) 沿 x 轴的位置。
	-- @param y (number) 沿 y 轴的位置。
	setPosition: function(self: ParticleSystem, x: number, y: number)

	-- 获取发射器的位置。
	-- @return (number) 沿 x 轴的位置。
	-- @return (number) 沿 y 轴的位置。
	getPosition: function(self: ParticleSystem): number, number

	-- 移动发射器的位置。与每帧使用 ParticleSystem:setPosition 相比，这会导致更平滑的粒子生成行为。
	-- @param x (number) 沿 x 轴的位置。
	-- @param y (number) 沿 y 轴的位置。
	moveTo: function(self: ParticleSystem, x: number, y: number)

	-- 设置粒子的基于区域的生成参数。新创建的粒子将根据此函数的参数在发射器周围的区域中生成。
	-- @param distribution (string) 新粒子的分布类型。
	-- @param x (number) 均匀分布时沿 x 轴距发射器的最大生成距离，或正态分布时沿 x 轴的标准偏差。
	-- @param y (number) 均匀分布时沿 y 轴距发射器的最大生成距离，或正态分布时沿 y 轴的标准偏差。
	-- @param angle (number) 发射区域的角度（以弧度表示）。 （默认值：0。）
	-- @param relative (boolean) 如果新生成的粒子将相对于发射区域的中心定向，则为 true，否则为 false。 （默认值：假。）
	setEmissionArea: function(self: ParticleSystem, distribution?: string, x?: number, y?: number, angle?: number, relative?: boolean)

	-- 获取粒子基于区域的生成参数。
	-- @param distribution (string) distribution 参数。
	-- @param x (number) x 参数。
	-- @param y (number) y 参数。
	-- @return (string) 新粒子的分布类型。
	-- @return (number) 均匀分布时沿 x 轴距发射器的最大生成距离，或正态分布时沿 x 轴的标准偏差。
	-- @return (number) 均匀分布时沿 y 轴距发射器的最大生成距离，或正态分布时沿 y 轴的标准偏差。
	-- @return (number) 发射区域的角度（以弧度表示）。
	-- @return (boolean) 如果新生成的粒子将相对于发射区域的中心定向，则为 true，否则为 false。
	getEmissionArea: function(self: ParticleSystem): string, number, number, number, boolean
	setAreaSpread: function(self: ParticleSystem, distribution?: string, x?: number, y?: number)
	getAreaSpread: function(self: ParticleSystem): string, number, number

	-- 设置粒子发射的方向。
	-- @param direction (number) 粒子的方向（以弧度为单位）。
	setDirection: function(self: ParticleSystem, direction: number)

	-- 获取粒子发射器的方向（以弧度为单位）。
	-- @return (number) 发射器的方向（弧度）。
	getDirection: function(self: ParticleSystem): number

	-- 设置系统的传播量。
	-- @param spread (number) 传播量（弧度）。
	setSpread: function(self: ParticleSystem, spread: number)

	-- 获取粒子发射器的方向扩散量（以弧度为单位）。
	-- @return (number) 发射器的扩散（弧度）。
	getSpread: function(self: ParticleSystem): number

	-- 设置粒子的速度。
	-- @param minimum (number) 粒子的最小线速度。
	-- @param maximum (number) 粒子的最大线速度。 （默认值：分钟。）
	setSpeed: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- 获取粒子的速度。
	-- @return (number) 粒子的最小线速度。
	-- @return (number) 粒子的最大线速度。
	getSpeed: function(self: ParticleSystem): number, number

	-- 设置粒子的线性加速度（沿x轴和y轴的加速度）。
	-- 创建的每个粒子都会沿着 x 轴和 y 轴在 xmin,ymin 和 xmax,ymax 之间加速。
	-- @param xmin (number) 沿 x 轴的最小加速度。
	-- @param ymin (number) 沿 y 轴的最小加速度。
	-- @param xmax (number) 沿 x 轴的最大加速度。 （默认值：xmin。）
	-- @param ymax (number) 沿 y 轴的最大加速度。 （默认值：ymin。）
	setLinearAcceleration: function(self: ParticleSystem, xmin: number, ymin: number, xmax?: number, ymax?: number)

	-- 获取粒子的线性加速度（沿x轴和y轴的加速度）。
	-- 创建的每个粒子都会沿着 x 轴和 y 轴在 xmin,ymin 和 xmax,ymax 之间加速。
	-- @return (number) 沿 x 轴的最小加速度。
	-- @return (number) 沿 y 轴的最小加速度。
	-- @return (number) 沿 x 轴的最大加速度。
	-- @return (number) 沿 y 轴的最大加速度。
	getLinearAcceleration: function(self: ParticleSystem): number, number, number, number

	-- 设置径向加速度（远离发射器）。
	-- @param minimum (number) 最小加速度。
	-- @param maximum (number) 最大加速度。 （默认值：分钟。）
	setRadialAcceleration: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- 获取径向加速度（远离发射器）。
	-- @return (number) 最小加速度。
	-- @return (number) 最大加速度。
	getRadialAcceleration: function(self: ParticleSystem): number, number

	-- 设置切向加速度（垂直于粒子方向的加速度）。
	-- @param minimum (number) 最小加速度。
	-- @param maximum (number) 最大加速度。 （默认值：分钟。）
	setTangentialAcceleration: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- 获取切向加速度（垂直于粒子方向的加速度）。
	-- @return (number) 最小加速度。
	-- @return (number) 最大加速度。
	getTangentialAcceleration: function(self: ParticleSystem): number, number

	-- 设置粒子的线性阻尼（恒定减速度）量。
	-- @param minimum (number) 应用于粒子的最小线性阻尼量。
	-- @param maximum (number) 应用于粒子的最大线性阻尼量。 （默认值：分钟。）
	setLinearDamping: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- 获取粒子的线性阻尼（恒定减速度）量。
	-- @return (number) 应用于粒子的最小线性阻尼量。
	-- @return (number) 应用于粒子的最大线性阻尼量。
	getLinearDamping: function(self: ParticleSystem): number, number

	-- 设置一系列用于缩放粒子精灵的尺寸。 1.0是正常尺寸。粒子系统将在粒子的生命周期内均匀地在每个尺寸之间进行插值。
	-- 必须至少指定一种尺寸。最多可以使用八个。
	-- @param sizes (number...) 第一个尺寸。
	setSizes: function(self: ParticleSystem, sizes: number...)

	-- 获取精灵缩放的一系列尺寸。 1.0是正常尺寸。粒子系统将在粒子的生命周期内均匀地在每个尺寸之间进行插值。
	-- @return (number...) 第一个尺寸。
	getSizes: function(self: ParticleSystem): number...

	-- 设置大小变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	-- @param variation (number) 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	setSizeVariation: function(self: ParticleSystem, variation: number)

	-- 获取大小变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	-- @return (number) 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	getSizeVariation: function(self: ParticleSystem): number

	-- 设置粒子创建时图像的旋转（以弧度为单位）。
	-- @param minimum (number) 最小初始角度（弧度）。
	-- @param maximum (number) 最大初始角度（弧度）。 （默认值：分钟。）
	setRotation: function(self: ParticleSystem, minimum: number, maximum?: number)

	-- 获取粒子创建时图像的旋转（以弧度为单位）。
	-- @return (number) 最小初始角度（弧度）。
	-- @return (number) 最大初始角度（弧度）。
	getRotation: function(self: ParticleSystem): number, number

	-- 设置精灵的旋转。
	-- @param start (number) 最小旋转（弧度每秒）。
	-- @param finish (number) 最大旋转（弧度每秒）。 （默认值：分钟。）
	setSpin: function(self: ParticleSystem, start: number, finish?: number)

	-- 获取精灵的旋转。
	-- @return (number) 最小旋转（弧度每秒）。
	-- @return (number) 最大旋转（弧度每秒）。
	getSpin: function(self: ParticleSystem): number, number

	-- 设置旋转变化量（0 表示无变化，1 表示开始和结束之间完全变化）。
	-- @param variation (number) 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	setSpinVariation: function(self: ParticleSystem, variation: number)

	-- 获取旋转变化量（0 表示无变化，1 表示开始和结束之间的完全变化）。
	-- @return (number) 变化量（0 表示没有变化，1 表示开始和结束之间完全变化）。
	getSpinVariation: function(self: ParticleSystem): number

	-- 设置粒子精灵旋转的偏移位置。
	-- 如果不使用此功能，粒子将绕其中心旋转。
	-- @param x (number) 旋转偏移的x坐标。
	-- @param y (number) 旋转偏移的 y 坐标。
	setOffset: function(self: ParticleSystem, x: number, y: number)

	-- 获取粒子图像的绘制偏移量。
	-- @return (number) 粒子图像绘制偏移的x坐标。
	-- @return (number) 粒子图像绘制偏移的 y 坐标。
	getOffset: function(self: ParticleSystem): number, number

	-- 设置一系列应用于粒子精灵的颜色。粒子系统将在粒子的生命周期内均匀地在每种颜色之间进行插值。
	-- 参数可以以四个为一组传递，代表所需 RGBA 值的分量，或者作为 RGBA 分量值表，如果仅给出三个值，则默认 alpha 值为 1。必须至少指定一种颜色。最多可以使用八个。
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @param colors (any...) 第一种颜色，一个数字索引表，其中红色、绿色、蓝色和 alpha 值作为数字 (0-1)。 alpha 是可选的，如果省略则默认为 1。
	setColors: function(self: ParticleSystem, colors: any...)

	-- 获取应用于粒子精灵的一系列颜色。
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @return ({number}...) 第一种颜色，红色分量 (0-1)。
	getColors: function(self: ParticleSystem): {number}...

	-- 设置一系列用于粒子精灵的四边形。粒子将根据粒子当前的生命周期从列表中选择一个四边形，从而允许将动画精灵表与粒子系统一起使用。
	-- @param quads (any...) 包含要使用的四边形的表。
	setQuads: function(self: ParticleSystem, quads: any...)

	-- 获取用于粒子精灵的四边形系列。
	-- @return ({Quad}) 包含所使用的四边形的表。
	getQuads: function(self: ParticleSystem): {Quad}

	-- 设置粒子角度和旋转是否与其速度相关。如果启用，粒子将与其速度角度对齐并相对于该角度旋转。
	-- @param enabled (boolean) true 则启用相对粒子旋转， false 则禁用它。
	setRelativeRotation: function(self: ParticleSystem, enabled: boolean)

	-- 获取粒子角度和旋转是否与其速度相关。如果启用，粒子将与其速度角度对齐并相对于该角度旋转。
	-- @return (boolean) 如果启用相对粒子旋转则为 True，如果禁用则为 false。
	hasRelativeRotation: function(self: ParticleSystem): boolean

	-- 获取当前系统中的粒子数。
	-- @return (integer) 当前活动粒子的数量。
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
	-- @param count (integer) 要发射的粒子数量。如果达到粒子系统的最大缓冲区大小，发射的粒子数量将被截断。
	emit: function(self: ParticleSystem, count: integer)

	-- 检查粒子系统是否正在主动发射粒子。
	-- @return (boolean) 如果系统处于活动状态，则为 true，否则为 false。
	isActive: function(self: ParticleSystem): boolean

	-- 检查粒子系统是否暂停。
	-- @return (boolean) 如果系统暂停则为 true，否则为 false。
	isPaused: function(self: ParticleSystem): boolean

	-- 检查粒子系统是否停止。
	-- @return (boolean) 如果系统停止则为 true，否则为 false。
	isStopped: function(self: ParticleSystem): boolean
	isEmpty: function(self: ParticleSystem): boolean
	isFull: function(self: ParticleSystem): boolean

	-- 更新粒子系统；移动、产生和杀死粒子。
	-- @param delta_time (number) 自上一帧以来的时间（秒）。
	update: function(self: ParticleSystem, delta_time: number)
end

-- 着色器用于高级硬件加速像素或顶点操作。这些效果是用基于 GLSL（OpenGL 着色语言）的语言编写的，并进行了一些简化以便于编码。
local record Shader

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Shader): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Shader, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Shader): boolean

	-- 返回编译着色器代码时的任何警告和错误消息。如果图形硬件有任何不喜欢的地方，这可以用于调试着色器。
	-- @return (string) 警告和错误消息（如果有）。
	getWarnings: function(self: Shader): string

	-- 获取Shader中是否存在指定的extern变量。
	-- 这是用于兼容LÖVE 0.10之前版本的旧接口，请改用hasUniform。
	-- @param name (string) name 参数。
	getExternVariable: function(self: Shader, name: string): boolean

	-- 获取Shader中是否存在uniform / extern变量。
	-- 如果图形驱动程序的着色器编译器确定统一/外部变量不会影响着色器的最终输出，它可能会优化该变量。在这种情况下该函数将返回 false。
	-- @param name (string) 统一变量的名称。
	-- @return (boolean) 着色器中是否存在uniform并影响其最终输出。
	hasUniform: function(self: Shader, name: string): boolean

	-- 将一个或多个值发送到特殊的 (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' 关键字，例如
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
	-- @param name (string) 发送到着色器的数字名称。
	-- @param texture (Image | Canvas) 纹理（图像或画布）发送到统一变量。
	-- @param textures (Image | Canvas...) 如果统一变量是表，则要发送的附加数字。
	send: function(self: Shader, name: string, texture: Image | Canvas, textures: Image | Canvas...)

	-- 将一个或多个值发送到特殊的 (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' 关键字，例如
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
	-- @param name (string) 发送到着色器的向量的名称。
	-- @param matrix_layout (MatrixLayout) 内存中矩阵的布局（行优先或列优先）。
	-- @param matrices ({number} | {{number}}...) Additional matrices of the same type as ''matrix'' 才能存储在统一表中。
	send: function(self: Shader, name: string, matrix_layout: MatrixLayout, matrices: {number} | {{number}}...)

	-- 将一个或多个值发送到特殊的 (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' 关键字，例如
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
	-- @param name (string) 发送到着色器的矩阵的名称。
	-- @param data (Data) 包含要发送的值的数据对象。
	-- @param offset (number) 从数据对象开始处的偏移量（以字节为单位）。 （默认值：0。）
	-- @param size (number) 要发送的数据的大小（以字节为单位）。如果为零，则将复制与指定的统一用途一样多的字节。 （默认值：全部。）
	send: function(self: Shader, name: string, data: Data, offset?: number, size?: number)

	-- 将一个或多个值发送到特殊的 (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' 关键字，例如
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
	-- @param name (string) 发送到着色器的纹理的名称。
	-- @param matrix_layout (MatrixLayout) 内存中矩阵的布局（行优先或列优先）。
	-- @param data (Data) 包含要发送的值的数据对象。
	-- @param offset (number) 从数据对象开始处的偏移量（以字节为单位）。 （默认值：0。）
	-- @param size (number) 要发送的数据的大小（以字节为单位）。如果为零，则将复制与指定的统一用途一样多的字节。 （默认值：全部。）
	send: function(self: Shader, name: string, matrix_layout: MatrixLayout, data: Data, offset?: number, size?: number)

	-- 将一个或多个值发送到特殊的 (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' 关键字，例如
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
	-- @param name (string) 发送到着色器的制服名称。
	-- @param data (Data) 包含要发送的值的数据对象。
	-- @param matrix_layout (MatrixLayout) 内存中矩阵的布局（行优先或列优先）。
	-- @param offset (number) 从数据对象开始处的偏移量（以字节为单位）。 （默认值：0。）
	-- @param size (number) 要发送的数据的大小（以字节为单位）。如果为零，则将复制与指定的统一用途一样多的字节。 （默认值：全部。）
	send: function(self: Shader, name: string, data: Data, matrix_layout: MatrixLayout, offset?: number, size?: number)

	-- 将一个或多个值发送到特殊的 (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' 关键字，例如
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
	-- @param name (string) 发送到着色器的统一矩阵的名称。
	-- @param values (ShaderValue...) 纹理（图像或画布）发送到统一变量。
	send: function(self: Shader, name: string, values: ShaderValue...)

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
	-- @param name (string) 要在着色器中发送到的颜色外部变量的名称。
	-- @param data (Data) 一个表，其中包含红色、绿色、蓝色和 1 范围内的可选 alpha 颜色分量，以向量形式发送到外部。
	-- @param offset (number) 当 extern 是表时要发送的附加颜色。所有颜色都必须具有相同的大小（例如仅 vec3）。
	-- @param size (number) 从 Data 对象读取的字节数。
	sendColor: function(self: Shader, name: string, data: Data, offset?: number, size?: number)

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
	-- @param name (string) 要在着色器中发送到的颜色外部变量的名称。
	-- @param values (ShaderValue...) 一个表，其中包含红色、绿色、蓝色和 1 范围内的可选 alpha 颜色分量，以向量形式发送到外部。
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

-- 提供用于修改和检索有关程序窗口的信息的接口。
local record Window
	-- 当前窗口尺寸的已弃用别名。
	getWidth: function(): integer
	getHeight: function(): integer
	getDimensions: function(): integer, integer

	-- 获取桌面的宽度和高度。
	-- @param display (integer) 显示的索引（如果有多个监视器可用）。 （默认值：1。）
	-- @return (integer) 桌面的宽度。
	-- @return (integer) 桌面的高度。
	getDesktopDimensions: function(display?: integer): integer, integer

	-- 获取已连接显示器的数量。
	-- @return (integer) 当前连接的显示器数量。
	getDisplayCount: function(): integer

	-- 获取显示器的名称。
	-- @param display (integer) 要获取其名称的显示器的索引。 （默认值：1。）
	-- @return (string) 指定显示器的名称。
	getDisplayName: function(display: integer): string

	-- 获取当前设备显示方向。
	-- @param display (integer) 显示索引以获取其显示方向，或 nil 以获得默认显示索引。 （默认值：无。）
	-- @return (string) 当前设备显示方向。
	getDisplayOrientation: function(display?: integer): string

	-- 获取支持的全屏模式列表。
	-- @param display (integer) 显示的索引（如果有多个监视器可用）。 （默认值：1。）
	-- @return ({WindowSize}) 宽度/高度对的表。 （请注意，这可能不按顺序排列。）
	getFullscreenModes: function(display?: integer): {WindowSize}

	-- 进入或退出全屏。如果连接了多个显示器，则根据窗口当前所在的显示来选择进入全屏时要使用的显示。
	-- 重载说明：
	-- 1. 如果进入全屏模式并且窗口大小与显示器的显示模式之一不匹配（在普通全屏模式下）或窗口大小与桌面大小不匹配（在 'desktop' 全屏模式下），窗口将适当调整大小。当使用此功能退出全屏模式时，窗口将再次恢复到其原始大小。
	-- @param fullscreen (boolean) 是否进入或退出全屏模式。
	-- @param fullscreen_type (string) 要使用的全屏模式类型。
	-- @return (boolean) 如果尝试进入全屏成功则为 true，否则为 false。
	setFullscreen: function(fullscreen: boolean, fullscreen_type?: string): boolean

	-- 获取窗口是否全屏。
	-- @return (boolean) 如果窗口是全屏则为 true，否则为 false。
	-- @return (string) 使用的全屏模式类型。
	getFullscreen: function(): boolean, string

	-- 检查窗口是否打开。
	-- @return (boolean) 如果窗口打开则为 true，否则为 false。
	isOpen: function(): boolean

	-- 获取窗口图标。
	-- @return (any) 窗口图标图像数据，如果没有使用 love.window.setIcon. 设置图标则为零
	getIcon: function(): any

	-- 使用 ImageData 设置窗口图标。
	-- 嵌入式 LoveNode 会接受该请求，但不会修改 Dora 宿主应用的图标。
	-- @param imagedata (any) 窗口图标的图像数据。
	-- @return (boolean) 图标请求被接受时返回 true。
	setIcon: function(imagedata: any): boolean

	-- 获取窗口的显示模式和属性。
	-- @return (integer) 窗口宽度。
	-- @return (integer) 窗口高度。
	-- @return (WindowMode) 具有窗口属性的表：
	getMode: function(): integer, integer, WindowMode

	-- 设置窗口的显示模式和属性。
	-- 如果宽度或高度为0，setMode 将使用桌面的宽度和高度。
	-- 更改显示模式可能会产生副作用：例如，画布将被清除，并且值会预先发送到带有画布的着色器，或者如果需要的话，之后重新绘制到它们。
	-- 重载说明：
	-- 1. * 如果启用全屏并且不支持宽度或高度（请参阅 resize 事件将被触发。 * 如果全屏类型为 'desktop' ，那么窗口将自动调整大小到桌面分辨率。 * 如果宽度和高度大于或等于桌面尺寸（包括都设置为
	-- 0）并且全屏设置为 false，则会显示 'visually' 全屏，但不是真正的全屏和 conf.lua （即 t.window = false）并使用此函数手动创建窗口，那么您不得在此函数之前调用任何其他
	-- love.graphics.* 函数，否则将导致未定义的行为和/或崩溃，因为没有窗口，OpenGL 无法正常运行 * 目前不支持透明背景。
	-- @param width (integer) 显示宽度。
	-- @param height (integer) 显示高度。
	-- @param settings (WindowMode) 带有选项的标志表： fullscreen: 全屏（true）或窗口化（false）。 （默认值：假。） fullscreentype: 要使用的全屏类型。在 0.9.0 到 0.9.2 中默认为 'normal'，在 0.10.0 及更早版本中默认为 'desktop'。 （默认：'desktop'。） vsync: 如果 LÖVE 应该等待垂直同步则为 true，否则为 false。 （默认值：true。） msaa: 抗锯齿样本数。 （默认值：0。） stencil: 是否应分配模板缓冲区。如果为 true，模板缓冲区将有 8 位。 （默认值：true。） depth: 深度缓冲区中的位数。 （默认值：0。） resizable: 如果窗口应在窗口模式下调整大小，则为 true，否则为 false。 （默认值：假。） borderless: 如果窗口在窗口模式下应无边框，则为 true，否则为 false。 （默认值：假。） centered: 如果窗口应在窗口模式下居中，则为 true，否则为 false。 （默认值：true。） display: 如果有多个监视器可用，则显示窗口的显示器索引。 （默认值：1。） minwidth: 窗口的最小宽度（如果可以调整大小）。不能小于 1。（默认值：1。） minheight: 窗口的最小高度（如果可以调整大小）。不能小于 1。（默认值：1。） highdpi: 如果应在 macOS 和 iOS 中的 Retina 显示屏上使用高 dpi 模式，则为 true。在非 Retina 显示器上不执行任何操作。 （默认值：假。） x: 指定显示中窗口位置的 x 坐标。 （默认值：无。） y: 指定显示中窗口位置的 y 坐标。 （默认值：无。） usedpiscale: 如果为 false，则禁用自动 DPI 缩放。 （默认值：true。） srgb: 在0.10.0中删除（改为在conf.lua中设置t.gamma Correct）。如果在绘制到屏幕时应应用 sRGB gamma 校正，则为 True。 （默认值：假。）
	-- @return (boolean) 如果成功则为 true，否则为 false。
	setMode: function(width: integer, height: integer, settings?: WindowMode): boolean

	-- 设置窗口的显示模式和属性，不修改未指定的属性。
	--
	-- 如果宽度或高度为0，updateMode 将使用桌面的宽度和高度。
	--
	-- 更改显示模式可能会产生副作用：例如，画布将被清除。确保事先保存画布的内容，或者如果需要的话，之后重新绘制。
	-- @param settings (WindowModeSettings) 具有以下可选字段的设置表。任何未填写的字段都将使用 love.window.getMode.
	-- @return (boolean) success — 如果成功则为 true，否则为 false。
	updateMode: function(settings: WindowModeSettings): boolean

	-- 设置窗口的显示模式和属性，不修改未指定的属性。
	--
	-- 如果宽度或高度为0，updateMode 将使用桌面的宽度和高度。
	--
	-- 更改显示模式可能会产生副作用：例如，画布将被清除。确保事先保存画布的内容，或者如果需要的话，之后重新绘制。
	-- @param width (number) 窗口宽度。
	-- @param height (integer) 窗口高度。
	-- @param settings (WindowModeSettings) 具有以下可选字段的设置表。任何未填写的字段都将使用 love.window.getMode.
	-- @return (boolean) success — 如果成功则为 true，否则为 false。
	updateMode: function(width: number, height: integer, settings?: WindowModeSettings): boolean

	-- 获取窗口在屏幕上的位置。
	-- 窗口位置位于其当前所在显示器的坐标空间中。
	-- @return (integer) 窗口位置的 x 坐标。
	-- @return (integer) 窗口位置的 y 坐标。
	-- @return (integer) 窗口所在显示器的索引。
	getPosition: function(): integer, integer, integer

	-- 获取窗口内已知未被系统标题栏、iPhone X 缺口等遮挡的区域。有助于确保用户可以看到 UI 元素。
	-- 重载说明：
	-- 1. 返回的值采用 DPI 缩放单位（与大多数其他与窗口相关的 API 相同的坐标系），而不是像素。
	-- @return (number) 安全区域的起始位置（x 轴）。
	-- @return (number) 安全区域的起始位置（y 轴）。
	-- @return (number) 安全区域的宽度。
	-- @return (number) 安全区域的高度。
	getSafeArea: function(): number, number, number, number

	-- 设置窗口标题。
	-- @param title (string) 新窗口标题。
	setTitle: function(title: string)

	-- 获取窗口标题。
	-- @return (string) 当前窗口标题。
	getTitle: function(): string

	-- 设置垂直同步模式。
	-- 重载说明：
	-- 1. * 并非所有图形驱动程序都支持自适应垂直同步（-1 值）。在这种情况下，它将自动设置为 1。 * 如果您不知道关闭垂直同步可能产生的影响，建议保持垂直同步处于激活状态。 * 与 love.window.setMode
	-- 和 love.window.updateMode. 不同，该函数不会重新创建窗口
	-- @param vsync (boolean or integer) 垂直同步编号：1 表示启用，0 表示禁用，-1 表示自适应垂直同步。
	setVSync: function(vsync: boolean | integer)

	-- 获取当前垂直同步（vsync）。
	-- 重载说明：
	-- 1. 如果您想获取当前的垂直同步状态，这可能是 love.window.getMode 的更便宜的替代方案。
	-- @return (integer) 当前垂直同步状态。如果启用，则为 1；如果禁用，则为 0；如果为自适应垂直同步，则为 -1。
	getVSync: function(): integer

	-- 设置程序运行时是否允许显示器休眠。
	-- 默认情况下禁用显示睡眠。如果允许显示器休眠，某些类型的输入（例如按下操纵杆按钮）可能不会阻止显示器休眠。
	-- @param enabled (boolean) true 则启用系统显示睡眠， false 则禁用它。
	setDisplaySleepEnabled: function(enabled: boolean)

	-- 获取程序运行时是否允许显示器休眠。
	-- 默认情况下禁用显示睡眠。如果允许显示器休眠，某些类型的输入（例如按下操纵杆按钮）可能不会阻止显示器休眠。
	-- @return (boolean) 如果启用/允许系统显示睡眠则为 true，否则为 false。
	isDisplaySleepEnabled: function(): boolean

	-- 检查游戏窗口是否有键盘焦点。
	-- @return (boolean) 如果窗口具有焦点则为 True，否则为 false。
	hasFocus: function(): boolean

	-- 检查游戏窗口是否有鼠标焦点。
	-- @return (boolean) 如果窗口有鼠标焦点则为 true，否则为 false。
	hasMouseFocus: function(): boolean

	-- 检查游戏窗口是否可见。
	-- 如果窗口未最小化且程序未隐藏，则窗口被视为可见。
	-- @return (boolean) 如果窗口可见则为 true，如果不可见则为 false。
	isVisible: function(): boolean

	-- 获取Window当前是否最大化。
	-- 如果窗口不是全屏且可调整大小，并且用户已按下窗口的最大化按钮或已调用 love.window.maximize ，则窗口可以最大化。
	-- @return (boolean) 如果窗口当前在窗口模式下最大化，则为 true，否则为 false。
	isMaximized: function(): boolean

	-- 获取窗口当前是否最小化。
	-- @return (boolean) 如果窗口当前最小化则为 true，否则为 false。
	isMinimized: function(): boolean

	-- 获取与窗口关联的 DPI 比例因子。
	-- 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用
	-- 1600x1200 像素。在这种情况下，love.window.getDPIScale() 将返回 2.0。
	-- love.window.fromPixels 和 love.window.toPixels 函数也可用于单位之间的转换。
	-- 必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android
	-- 上它实际上始终处于启用状态。
	-- 重载说明：
	-- 1. love.graphics.getWidth、love.graphics.getHeight、love.mouse.getPosition、鼠标事件、love.touch.getPosition
	-- 和触摸事件的单位始终以像素为单位。
	-- @return (number) 与窗口关联的像素比例因子。
	getDPIScale: function(): number
	getNativeDPIScale: function(): number

	-- 将数字从与密度无关的单位转换为像素。
	--
	-- 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用 1600x1200 像素。在这种情况下，love.window.toPixels(800) 将返回 1600。
	--
	-- 这用于将坐标从用户期望它们在屏幕上显示的尺寸转换为像素。 love.window.fromPixels 则相反。必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android 上它实际上始终处于启用状态。
	--
	-- 大多数 LÖVE 函数返回值并期望参数以像素为单位，而不是与密度无关的单位。
	-- @param value (number) 与密度无关的单位中要转换为像素的数字。
	-- @return (number) pixelvalue — 转换后的数字，以像素为单位。
	toPixels: function(value: number): number

	-- 将数字从与密度无关的单位转换为像素。
	--
	-- 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用 1600x1200 像素。在这种情况下，love.window.toPixels(800) 将返回 1600。
	--
	-- 这用于将坐标从用户期望它们在屏幕上显示的尺寸转换为像素。 love.window.fromPixels 则相反。必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android 上它实际上始终处于启用状态。
	--
	-- 大多数 LÖVE 函数返回值并期望参数以像素为单位，而不是与密度无关的单位。
	-- @param x (number) 以与密度无关的单位表示的坐标的 x 轴值，以转换为像素。
	-- @param y (number) 以与密度无关的单位表示的坐标的 y 轴值，以转换为像素。
	-- @return (number) pixelvalue — 转换后的数字，以像素为单位。
	-- @return (number) px — 转换后的 x 轴坐标值，以像素为单位。
	toPixels: function(x: number, y: number): number, number

	-- 将数字从像素转换为与密度无关的单位。
	--
	-- 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用 1600x1200 像素。在这种情况下，love.window.fromPixels(1600) 将返回 800。
	--
	-- 此函数将坐标从像素转换为用户期望它们在屏幕上显示的大小。 love.window.toPixels 则相反。必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android 上它实际上始终处于启用状态。
	--
	-- 大多数 LÖVE 函数返回值并期望参数以像素为单位，而不是与密度无关的单位。
	-- @param value (number) 以像素为单位的数字，要转换为与密度无关的单位。
	-- @return (number) value — 转换后的数字，采用与密度无关的单位。
	fromPixels: function(value: number): number

	-- 将数字从像素转换为与密度无关的单位。
	--
	-- 窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600 窗口相同的物理尺寸，但窗口内的区域使用 1600x1200 像素。在这种情况下，love.window.fromPixels(1600) 将返回 800。
	--
	-- 此函数将坐标从像素转换为用户期望它们在屏幕上显示的大小。 love.window.toPixels 则相反。必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android 上它实际上始终处于启用状态。
	--
	-- 大多数 LÖVE 函数返回值并期望参数以像素为单位，而不是与密度无关的单位。
	-- @param x (number) 坐标的 x 轴值（以像素为单位）。
	-- @param y (number) 坐标的 y 轴值（以像素为单位）。
	-- @return (number) value — 转换后的数字，采用与密度无关的单位。
	-- @return (number) x — 转换后的 x 轴坐标值，采用与密度无关的单位。
	fromPixels: function(x: number, y: number): number, number
end

-- 管理事件，例如按键。
local record Event

	-- Dora 拥有平台事件泵；这不会泵送第二个操作系统队列。将事件泵入事件队列。
	-- 这是一个低级函数，通常不由用户调用，而是由 love.run.
	-- 请注意，确实需要调用此命令才能让任何操作系统认为您仍在运行，
	-- 如果您想处理操作系统生成的事件（考虑回调）。
	pump: function()

	-- 返回事件队列中消息的迭代器。
	-- @return (function or any...) 可在 for 循环中使用的迭代器函数。
	poll: function(): function(): any...

	-- 与 love.event.poll() 类似，但会阻塞，直到队列中有事件为止。
	-- @return (any...) 事件名称。
	wait: function(): any...

	-- 将事件添加到事件队列。
	-- 从 0.10.0 开始，您可以使用此函数传递任意数量的参数，但默认回调不会使用超过六个。
	-- @param name (string) 事件的名称。
	-- @param args (any...) 第一个事件参数。 （默认值：无。）
	push: function(name: string, args: any...): boolean

	-- 清除事件队列。
	clear: function()

	-- 将退出事件添加到队列中。
	--
	-- quit 事件是事件处理程序关闭 LÖVE 的信号。可以使用 love.quit 回调中止退出过程。
	-- @param exit_status (number) 关闭应用程序时使用的程序退出状态。 （默认值：0。）
	-- @return (boolean) 退出事件加入队列后始终返回 true。
	quit: function(exit_status?: number): boolean

	-- 将退出事件添加到队列中。
	--
	-- quit 事件是事件处理程序关闭 LÖVE 的信号。可以使用 love.quit 回调中止退出过程。
	-- @param reason (string) 告诉默认的 love.run 退出并重新启动游戏，而不重新启动可执行文件。
	-- @return (boolean) 重启退出事件加入队列后始终返回 true。
	quit: function(reason: string): boolean
end

local type FileType = string
local type FileMode = string
local type BufferMode = string

-- 表示文件内容的数据。
local record FileData

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: FileData): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: FileData, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: FileData): boolean

	-- 获取字符串形式的完整数据。
	-- @return (string) 原始数据。
	getString: function(self: FileData): string

	-- 获取数据的大小（以字节为单位）。
	-- @return (integer) 数据的大小（以字节为单位）。
	getSize: function(self: FileData): integer

	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	-- @return (any) 指向数据的原始指针。
	getPointer: function(self: FileData): any

	-- 获取指向数据的 FFI 指针。
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	-- @return (nil) 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: FileData): nil

	-- 创建数据对象的新副本。
	-- @return (FileData) 新副本。
	clone: function(self: FileData): FileData

	-- 获取FileData 的文件名。
	-- @return (string) FileData 代表的文件的名称。
	getFilename: function(self: FileData): string

	-- 获取FileData 的扩展名。
	-- @return (string) FileData 代表的文件的扩展名。
	getExtension: function(self: FileData): string
end

-- 原始（解码）图像数据。
local record ImageData

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: ImageData): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: ImageData): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: ImageData, type_name: string): boolean

	-- 获取字符串形式的完整数据。
	-- @return (string) 原始数据。
	getString: function(self: ImageData): string

	-- 获取数据的大小（以字节为单位）。
	-- @return (integer) 数据的大小（以字节为单位）。
	getSize: function(self: ImageData): integer

	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	-- @return (any) 指向数据的原始指针。
	getPointer: function(self: ImageData): any

	-- 获取指向数据的 FFI 指针。
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	-- @return (nil) 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: ImageData): nil

	-- 创建数据对象的新副本。
	-- @return (ImageData) 新副本。
	clone: function(self: ImageData): ImageData

	-- 获取 ImageData 的宽度（以像素为单位）。
	-- @return (integer) ImageData 的宽度（以像素为单位）。
	getWidth: function(self: ImageData): integer

	-- 获取 ImageData 的高度（以像素为单位）。
	-- @return (integer) ImageData 的高度（以像素为单位）。
	getHeight: function(self: ImageData): integer

	-- 获取 ImageData 的宽度和高度（以像素为单位）。
	-- @return (integer) ImageData 的宽度（以像素为单位）。
	-- @return (integer) ImageData 的高度（以像素为单位）。
	getDimensions: function(self: ImageData): integer, integer

	-- 获取ImageData的像素格式。
	-- @return (string) 创建 ImageData 时使用的像素格式。
	getFormat: function(self: ImageData): string

	-- 获取图像中特定位置的像素的颜色。
	-- 有效的 x 和 y 值从 0 开始，直到图像宽度和高度减 1。非整数值将被下限。
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @param x (integer) 像素在 x 轴上的位置。
	-- @param y (integer) 像素在 y 轴上的位置。
	-- @return (number) 红色分量 (0-1)。
	-- @return (number) 绿色分量 (0-1)。
	-- @return (number) 蓝色分量 (0-1)。
	-- @return (number) alpha 分量 (0-1)。
	getPixel: function(self: ImageData, x: integer, y: integer): number, number, number, number

	-- 设置图像中特定位置的像素颜色。
	-- 有效的 x 和 y 值从 0 开始，直到图像宽度和高度减 1。
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @param x (integer) 像素在 x 轴上的位置。
	-- @param y (integer) 像素在 y 轴上的位置。
	-- @param red (number) 红色分量 (0-1)。
	-- @param green (number) 绿色分量 (0-1)。
	-- @param blue (number) 蓝色分量 (0-1)。
	-- @param alpha (number) alpha 分量 (0-1)。
	setPixel: function(self: ImageData, x: integer, y: integer, red: number, green: number, blue: number, alpha?: number)

	-- 通过对每个像素应用函数来变换图像。
	-- 该函数是一个高阶函数。它采用另一个函数作为参数，并为 ImageData 中的每个像素调用一次。
	-- 传递的函数被依次调用，每个像素有六个参数。这些参数是代表像素的 x 和 y 坐标及其红色、绿色、蓝色和 alpha 值的数字。该函数应返回该像素的新红色、绿色、蓝色和 alpha 值。
	-- 函数pixelFunction(x,y,r,g,b,a)
	-- -- 用于定义您自己的像素映射函数的模板
	-- -- 执行计算，给出 r、g、b 和 a 的新值
	-- -- ...
	-- 返回r，g，b，a
	-- 结束
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @param mapper (function) 应用于每个像素的函数。
	-- @param x (integer) ImageData 中要应用函数的区域左上角的 x 轴。 （默认值：0。）
	-- @param y (integer) ImageData 中要应用函数的区域左上角的 y 轴。 （默认值：0。）
	-- @param width (integer) ImageData 中应用函数的区域的宽度。 （默认：ImageData:getWidth()。）
	-- @param height (integer) ImageData 中要应用函数的区域的高度。 （默认：ImageData:getHeight()。）
	mapPixel: function(self: ImageData, mapper: function(x: integer, y: integer, red: number, green: number, blue: number, alpha: number): (number, number, number, number), x?: integer, y?: integer, width?: integer, height?: integer)

	-- 从另一个源 ImageData 粘贴到 ImageData 中。
	-- 重载说明：
	-- 1. 请注意，此函数只是替换目标矩形中的内容；它不进行任何 alpha 混合。
	-- @param source (ImageData) 要从中复制的源图像数据。
	-- @param destination_x (integer) x 轴上的目标左上角位置。
	-- @param destination_y (integer) y 轴上的目标左上角位置。
	-- @param source_x (integer) x 轴上的源左上角位置。
	-- @param source_y (integer) y 轴上的源左上角位置。
	-- @param source_width (integer) 源宽度。
	-- @param source_height (integer) 源高度。
	paste: function(self: ImageData, source: ImageData, destination_x: integer, destination_y: integer, source_x?: integer, source_y?: integer, source_width?: integer, source_height?: integer)

	-- 对 ImageData 进行编码并可选择将其写入保存目录。
	-- @param format (string) 图像编码的格式。取决于重载：对图像进行编码的格式。
	-- @param filename (string) 将文件写入的文件名。如果为 nil，则不会写入任何文件，但仍会返回 FileData。 （默认值：无。）
	-- @return (FileData) 作为新 FileData 对象的编码图像。
	encode: function(self: ImageData, format: string, filename?: string): FileData
end

-- 表示旨在在 RAM 中保持压缩状态的压缩图像数据。
local record CompressedImageData

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: CompressedImageData): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: CompressedImageData): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: CompressedImageData, type_name: string): boolean

	-- 获取字符串形式的完整数据。
	-- @return (string) 原始数据。
	getString: function(self: CompressedImageData): string

	-- 获取数据的大小（以字节为单位）。
	-- @return (integer) 数据的大小（以字节为单位）。
	getSize: function(self: CompressedImageData): integer

	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	-- @return (any) 指向数据的原始指针。
	getPointer: function(self: CompressedImageData): any

	-- 获取指向数据的 FFI 指针。
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	-- @return (nil) 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: CompressedImageData): nil

	-- 创建数据对象的新副本。
	-- @return (CompressedImageData) 新副本。
	clone: function(self: CompressedImageData): CompressedImageData

	-- 获取压缩图像数据的宽度。
	-- @return (integer) width — 压缩图像数据的宽度。
	getWidth: function(self: CompressedImageData): integer

	-- 获取压缩图像数据的宽度。
	-- @param mipmap (integer) mipmap 级别。必须在 CompressedImageData:getMipmapCount() 范围内。
	-- @return (integer) CompressedImageData 的特定 mipmap 级别的宽度。
	getWidth: function(self: CompressedImageData, mipmap: integer): integer

	-- 获取 CompressedImageData 的高度。
	-- @return (integer) height — 压缩图像数据的高度。
	getHeight: function(self: CompressedImageData): integer

	-- 获取 CompressedImageData 的高度。
	-- @param mipmap (integer) mipmap 级别。必须在 CompressedImageData:getMipmapCount() 范围内。
	-- @return (integer) 压缩图像数据的特定 mipmap 级别的高度。
	getHeight: function(self: CompressedImageData, mipmap: integer): integer

	-- 获取 CompressedImageData 的宽度和高度。
	-- @return (integer) width — 压缩图像数据的宽度。
	-- @return (integer) height — 压缩图像数据的高度。
	getDimensions: function(self: CompressedImageData): integer, integer

	-- 获取 CompressedImageData 的宽度和高度。
	-- @param mipmap (integer) mipmap 级别。必须在 CompressedImageData:getMipmapCount() 范围内。
	-- @return (integer) CompressedImageData 的特定 mipmap 级别的宽度。
	-- @return (integer) 压缩图像数据的特定 mipmap 级别的高度。
	getDimensions: function(self: CompressedImageData, mipmap: integer): integer, integer

	-- 获取 CompressedImageData 中的 mipmap 级别数。基本 mipmap 级别（原始图像）包含在计数中。
	-- 重载说明：
	-- 1. Mipmap 过滤无法激活，会出现 Image:setMipmapFilter 错误。大多数可以创建压缩纹理的工具都能够在同一文件中自动为其生成 mipmap。
	-- @return (integer) 压缩图像数据中存储的 mipmap 级别数。
	getMipmapCount: function(self: CompressedImageData): integer

	-- 获取压缩图像数据的格式。
	-- @return (string) 压缩图像数据的格式。
	getFormat: function(self: CompressedImageData): string
end

-- 提供解码编码图像数据的接口。
local record ImageModule

	-- 创建一个新的 ImageData 对象。
	-- @param width (number) ImageData 的宽度。
	-- @param height (integer) ImageData 的高度。
	-- @param format (ImagePixelFormat) ImageData 的像素格式。 （默认：'rgba8'。）
	-- @param data (string | Data) 可选的原始字节数据，以“'format'”指定的格式加载到 ImageData 中。 （默认值：nil。）
	-- @return (ImageData) imageData — 新的空白 ImageData 对象。每个像素的颜色值（包括 Alpha 值！）将设置为零。
	newImageData: function(width: number, height: integer, format?: ImagePixelFormat, data?: string | Data): ImageData

	-- 创建一个新的 ImageData 对象。
	-- @param filename (string) 图像文件的文件名。
	-- @return (ImageData) 新的 ImageData 对象。
	newImageData: function(filename: string): ImageData

	-- 创建一个新的 ImageData 对象。
	-- @param data (Data) 要解码为 ImageData 的编码图像数据。
	-- @return (ImageData) 新的 ImageData 对象。
	newImageData: function(data: Data): ImageData

	-- 从压缩图像文件创建一个新的 CompressedImageData 对象。 LÖVE 支持多种压缩纹理格式，在 CompressedImageFormat 页面中列出。
	-- @param filename_or_data (string or FileData) 压缩图像文件的文件名。取决于重载：包含压缩图像的 FileData。
	-- @return (CompressedImageData) 新的 CompressedImageData 对象。
	newCompressedData: function(filename_or_data: string | FileData): CompressedImageData

	-- 确定文件是否可以作为 CompressedImageData 加载。
	-- @param filename_or_data (string or FileData) 可能压缩的图像文件的文件名。根据重载：可能包含压缩图像的 FileData。
	-- @return (boolean) 文件是否可以作为 CompressedImageData 加载。取决于重载：FileData 是否可以作为 CompressedImageData 加载。
	isCompressed: function(filename_or_data: string | FileData): boolean
end

-- 光栅化器处理字体渲染，包含字体数据（图像或TrueType字体）和可绘制的字形。
local record Rasterizer

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Rasterizer): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Rasterizer): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Rasterizer, type_name: string): boolean

	-- 获取字体高度。
	-- @return (integer) 字体高度
	getHeight: function(self: Rasterizer): integer

	-- 获取字体提前。
	-- @return (integer) 字体提前。
	getAdvance: function(self: Rasterizer): integer

	-- 获取上升高度。
	-- @return (integer) 上升高度。
	getAscent: function(self: Rasterizer): integer

	-- 获取下降高度。
	-- @return (integer) 下降高度。
	getDescent: function(self: Rasterizer): integer

	-- 获取字体的行高。
	-- @return (integer) 字体的行高。
	getLineHeight: function(self: Rasterizer): integer

	-- 获取指定字形的字形数据。
	-- @param glyph (string or integer) 字形
	-- @return (GlyphData) 字形数据
	getGlyphData: function(self: Rasterizer, glyph: string | integer): GlyphData

	-- 获取字体中的字形数量。
	-- @return (integer) 字形计数。
	getGlyphCount: function(self: Rasterizer): integer

	-- 检查字体是否包含指定的字形。
	-- @param glyph (string or integer) 字形
	-- @param ... (string or integer) ... 参数。
	-- @return (boolean) 任何包含指定字形的字体。
	hasGlyphs: function(self: Rasterizer, glyph: string | integer, ...: string | integer): boolean
end

-- GlyphData 表示字体光栅化器的可绘制符号。
local record GlyphData

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: GlyphData): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: GlyphData): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: GlyphData, type_name: string): boolean

	-- 获取字符串形式的完整数据。
	-- @return (string) 原始数据。
	getString: function(self: GlyphData): string

	-- 获取数据的大小（以字节为单位）。
	-- @return (integer) 数据的大小（以字节为单位）。
	getSize: function(self: GlyphData): integer

	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	-- @return (any) 指向数据的原始指针。
	getPointer: function(self: GlyphData): any

	-- 获取指向数据的 FFI 指针。
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	-- @return (nil) 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: GlyphData): nil

	-- 创建数据对象的新副本。
	-- @return (GlyphData) 新副本。
	clone: function(self: GlyphData): GlyphData

	-- 获取字形宽度。
	-- @return (integer) 字形宽度。
	getWidth: function(self: GlyphData): integer

	-- 获取字形高度。
	-- @return (integer) 字形高度。
	getHeight: function(self: GlyphData): integer

	-- 获取字形尺寸。
	-- @return (integer) 字形宽度。
	-- @return (integer) 字形高度。
	getDimensions: function(self: GlyphData): integer, integer

	-- 获取字形编号。
	-- @return (integer) 字形编号。
	getGlyph: function(self: GlyphData): integer

	-- 获取字形字符串。
	-- @return (string) 字形字符串。
	getGlyphString: function(self: GlyphData): string

	-- 获取字形提前。
	-- @return (integer) 字形前进。
	getAdvance: function(self: GlyphData): integer

	-- 获取字形方位。
	-- @return (integer) 字形轴承 X.
	-- @return (integer) 字形轴承 Y。
	getBearing: function(self: GlyphData): integer, integer

	-- 获取字形边界框。
	-- @return (integer) 字形位置 x。
	-- @return (integer) 字形位置 y。
	-- @return (integer) 字形宽度。
	-- @return (integer) 字形高度。
	getBoundingBox: function(self: GlyphData): integer, integer, integer, integer

	-- 获取字形像素格式。
	-- @return (string) 字形像素格式。
	getFormat: function(self: GlyphData): string
end

-- 允许您使用字体。
local record FontModule

	-- 创建一个新的图像光栅化器。
	-- 重载说明：
	-- 1. 从图像数据创建一个ImageRasterizer。
	-- @param image_data (ImageData) 字体图像数据。
	-- @param glyphs (string) 包含字体字形的字符串。
	-- @param extra_spacing (integer) 字体额外间距。 （默认值：0。）
	-- @param dpi_scale (number) 字体 DPI 比例。 （默认值：1。）
	-- @return (Rasterizer) 光栅器。
	newImageRasterizer: function(image_data: ImageData, glyphs: string, extra_spacing?: integer, dpi_scale?: number): Rasterizer

	-- 创建一个新的 BMFont 光栅化器。
	-- @param filename_or_file_data (string or FileData) 包含字体字形的可绘制图片的图像数据。取决于重载：包含字体字形的可绘制图片的文件的路径。
	-- @param images (ImageData or string or FileData or {ImageData or string or FileData}) ImageData 中的字形序列。
	-- @param dpi_scale (number) DPI 比例。 （默认值：1。）
	-- @return (Rasterizer) 光栅器。
	newBMFontRasterizer: function(filename_or_file_data: string | FileData, images?: ImageData | string | FileData | {ImageData | string | FileData}, dpi_scale?: number): Rasterizer

	-- 创建一个新的 TrueType 光栅化器。
	-- @param size (number) 字体大小。 （默认值：12。）
	-- @param hinting (string) True Type 提示模式。 （默认：'normal'。）
	-- @param dpi_scale (number) 字体 DPI 比例。 （默认：love.window.getDPIScale()。）
	-- @return (Rasterizer) rasterizer — 光栅器。
	newTrueTypeRasterizer: function(size?: number, hinting?: string, dpi_scale?: number): Rasterizer

	-- 创建一个新的 TrueType 光栅化器。
	-- @param filename_or_data (string | Data) 包含字体的文件数据。
	-- @param size (number) 字体大小。 （默认值：12。）
	-- @param hinting (string) True Type 提示模式。 （默认：'normal'。）
	-- @param dpi_scale (number) 字体 DPI 比例。 （默认：love.window.getDPIScale()。）
	-- @return (Rasterizer) rasterizer — 光栅器。
	newTrueTypeRasterizer: function(filename_or_data: string | Data, size?: number, hinting?: string, dpi_scale?: number): Rasterizer

	-- 创建一个新的光栅化器。
	-- @param size (number) 字体大小。 （默认值：12。）
	-- @param hinting (string) True Type 提示模式。 （默认：'normal'。）
	-- @param dpi_scale (number) 字体 DPI 比例。 （默认值：love.window.getDPIScale()。）
	-- @return (Rasterizer) rasterizer — 光栅器。
	newRasterizer: function(size?: number, hinting?: string, dpi_scale?: number): Rasterizer

	-- 创建一个新的光栅化器。
	-- @param filename_or_data (string | Data) 包含字体的文件数据。
	-- @param size (number) 字体大小。 （默认值：12。）
	-- @param hinting (string) True Type 提示模式。 （默认：'normal'。）
	-- @param dpi_scale (number) DPI 比例。 （默认值：1。）
	-- @return (Rasterizer) rasterizer — 光栅器。
	newRasterizer: function(filename_or_data: string | Data, size?: number, hinting?: string, dpi_scale?: number): Rasterizer

	-- 创建一个新的 GlyphData。
	-- @param rasterizer (Rasterizer) 包含字体的光栅化器。
	-- @param glyph (string or integer) 字形的字符代码。
	newGlyphData: function(rasterizer: Rasterizer, glyph: string | integer): GlyphData
end

-- 包含原始音频样本。
local record SoundData

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: SoundData): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: SoundData, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: SoundData): boolean

	-- 获取字符串形式的完整数据。
	-- @return (string) 原始数据。
	getString: function(self: SoundData): string

	-- 获取数据的大小（以字节为单位）。
	-- @return (integer) 数据的大小（以字节为单位）。
	getSize: function(self: SoundData): integer

	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	-- @return (any) 指向数据的原始指针。
	getPointer: function(self: SoundData): any

	-- 获取指向数据的 FFI 指针。
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	-- @return (nil) 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: SoundData): nil

	-- 创建数据对象的新副本。
	-- @return (SoundData) 新副本。
	clone: function(self: SoundData): SoundData

	-- 返回 SoundData 中的通道数。
	-- @return (integer) 1 用于单声道，2 用于立体声。
	getChannelCount: function(self: SoundData): integer
	getChannels: function(self: SoundData): integer

	-- 返回每个样本的位数。
	-- @return (integer) 8 或 16。
	getBitDepth: function(self: SoundData): integer

	-- 返回声音数据的采样率。
	-- @return (integer) 每秒的样本数。
	getSampleRate: function(self: SoundData): integer

	-- 返回 SoundData 每个通道的样本数。
	-- @return (integer) 样本总数。
	getSampleCount: function(self: SoundData): integer

	-- 获取声音数据的持续时间。
	-- @param index (integer) index 参数。
	-- @param channel (integer) channel 参数。
	-- @return (number) 声音数据的持续时间（以秒为单位）。
	getDuration: function(self: SoundData): number
	getSample: function(self: SoundData, index: integer, channel?: integer): number

	-- 设置指定位置的采样点值。对于立体声 SoundData 对象，来自左声道和右声道的数据按该顺序交错。
	-- @param index (integer) 指定样本位置的整数值（从 0 开始）。
	-- @param sample (number) 归一化采样点（范围 -1.0 到 1.0）。
	setSample: function(self: SoundData, index: integer, sample: number)

	-- 设置指定位置的采样点值。对于立体声 SoundData 对象，来自左声道和右声道的数据按该顺序交错。
	-- @param index (integer) 指定样本位置的整数值（从 0 开始）。
	-- @param channel (number) 在给定样本中设置的通道索引。
	-- @param sample (number) 归一化采样点（范围 -1.0 到 1.0）。
	setSample: function(self: SoundData, index: integer, channel: number, sample: number)
end

-- 一个可以逐步解码声音文件的对象。
local record Decoder

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Decoder): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Decoder, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Decoder): boolean

	-- 创建当前解码器的新副本。
	-- 新解码器将从音频流的开头开始解码。
	-- @return (Decoder) 解码器的新副本。
	clone: function(self: Decoder): Decoder

	-- 返回流中的通道数。
	-- @return (integer) 1 用于单声道，2 用于立体声。
	getChannelCount: function(self: Decoder): integer
	getChannels: function(self: Decoder): integer

	-- 返回每个样本的位数。
	-- @return (integer) 8 或 16。
	getBitDepth: function(self: Decoder): integer

	-- 返回解码器的采样率。
	-- @return (integer) 每秒的样本数。
	getSampleRate: function(self: Decoder): integer

	-- 获取声音文件的持续时间。它可能并不总是样本准确的，如果根本无法确定持续时间，它可能会返回 -1。
	-- @return (number) 声音文件的持续时间（以秒为单位），如果无法确定则为 -1。
	getDuration: function(self: Decoder): number

	-- 解码音频并返回包含解码后的音频数据的 SoundData 对象。
	-- @return (SoundData or nil) 解码的音频数据。
	decode: function(self: Decoder): SoundData | nil

	-- 设置解码器当前的播放位置。
	-- @param offset (number) 要寻找的位置，以秒为单位。
	seek: function(self: Decoder, offset: number)
end

-- 该模块负责解码声音文件。它无法播放声音，请参阅 love.audio 。
local record SoundModule

	-- 尝试在指定文件中查找编码声音数据的解码器。
	-- @param filename (string) 带有编码声音数据的文件的文件名。
	-- @param buffer_size (integer) 每个解码块的大小（以字节为单位）。 （默认值：2048。）
	-- @return (Decoder) decoder — 一个新的解码器对象。
	newDecoder: function(filename: string, buffer_size?: integer): Decoder

	-- 尝试在指定文件中查找编码声音数据的解码器。
	-- @param data (FileData) 带有编码声音数据的文件的文件名。
	-- @param buffer_size (integer) 每个解码块的大小（以字节为单位）。 （默认值：2048。）
	-- @return (Decoder) decoder — 一个新的解码器对象。
	newDecoder: function(data: FileData, buffer_size?: integer): Decoder

	-- 从文件路径、文件或解码器创建新的 SoundData。还可以创建具有自定义采样率、通道和位深度的 SoundData。
	--
	-- 声音数据将以原始格式解码到内存中。建议仅创建简短的声音（例如效果），因为这样 3 分钟的歌曲会使用 30 MB 的内存。
	-- @param samples (number) 样本总数。
	-- @param sample_rate (integer) 每秒采样数（默认值：44100。）
	-- @param bit_depth (integer) 每个样本的位数（8 或 16）。 （默认值：16。）
	-- @param channels (integer) 1 表示单声道，2 表示立体声。 （默认值：2。）
	-- @return (SoundData) soundData — 一个新的 SoundData 对象。
	newSoundData: function(samples: number, sample_rate?: integer, bit_depth?: integer, channels?: integer): SoundData

	-- 从文件路径、文件或解码器创建新的 SoundData。还可以创建具有自定义采样率、通道和位深度的 SoundData。
	--
	-- 声音数据将以原始格式解码到内存中。建议仅创建简短的声音（例如效果），因为这样 3 分钟的歌曲会使用 30 MB 的内存。
	-- @param filename (string) 要加载的文件的文件名。
	-- @param buffer_size (integer) 每秒采样数（默认值：44100。）
	-- @return (SoundData) soundData — 一个新的 SoundData 对象。
	newSoundData: function(filename: string, buffer_size?: integer): SoundData

	-- 从文件路径、文件或解码器创建新的 SoundData。还可以创建具有自定义采样率、通道和位深度的 SoundData。
	--
	-- 声音数据将以原始格式解码到内存中。建议仅创建简短的声音（例如效果），因为这样 3 分钟的歌曲会使用 30 MB 的内存。
	-- @param data (FileData) 从此解码器解码数据直到 EOF。
	-- @param buffer_size (integer) 每秒采样数（默认值：44100。）
	-- @return (SoundData) soundData — 一个新的 SoundData 对象。
	newSoundData: function(data: FileData, buffer_size?: integer): SoundData

	-- 从文件路径、文件或解码器创建新的 SoundData。还可以创建具有自定义采样率、通道和位深度的 SoundData。
	--
	-- 声音数据将以原始格式解码到内存中。建议仅创建简短的声音（例如效果），因为这样 3 分钟的歌曲会使用 30 MB 的内存。
	-- @param decoder (Decoder) 从该解码器解码数据直到 EOF。
	-- @return (SoundData) soundData — 一个新的 SoundData 对象。
	newSoundData: function(decoder: Decoder): SoundData
end

-- 连续内存中包含任意字节的数据对象。
local record ByteData

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: ByteData): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: ByteData, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: ByteData): boolean

	-- 获取字符串形式的完整数据。
	-- @return (string) 原始数据。
	getString: function(self: ByteData): string

	-- 获取数据的大小（以字节为单位）。
	-- @return (integer) 数据的大小（以字节为单位）。
	getSize: function(self: ByteData): integer

	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	-- @return (any) 指向数据的原始指针。
	getPointer: function(self: ByteData): any

	-- 获取指向数据的 FFI 指针。
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	-- @return (nil) 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: ByteData): nil

	-- 创建数据对象的新副本。
	-- @param type_name (string) type_name 参数。
	-- @return (ByteData or string or boolean or integer or any or nil or DataView) 新副本。
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
	-- @return (string) 字符串类型。
	type: function(self: CompressedData): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: CompressedData, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: CompressedData): boolean

	-- 获取字符串形式的完整数据。
	-- @return (string) 原始数据。
	getString: function(self: CompressedData): string

	-- 获取数据的大小（以字节为单位）。
	-- @return (integer) 数据的大小（以字节为单位）。
	getSize: function(self: CompressedData): integer

	-- 获取指向数据的指针。可以与 LuaJIT 的 FFI 等库一起使用。
	-- @return (any) 指向数据的原始指针。
	getPointer: function(self: CompressedData): any

	-- 获取指向数据的 FFI 指针。
	-- 这个函数应该是首选，而不是 Data:getPointer ，因为后者使用轻量用户数据，当使用 LuaJIT 时，它无法在一些新的 ARM64 架构上存储更多所有可能的内存地址。
	-- @return (nil) 指向数据的原始 void* 指针，如果 FFI 不可用则为零。
	getFFIPointer: function(self: CompressedData): nil

	-- 创建数据对象的新副本。
	-- @return (CompressedData) 新副本。
	clone: function(self: CompressedData): CompressedData

	-- 获取CompressedData的压缩格式。
	-- @return (string) 压缩数据的格式。
	getFormat: function(self: CompressedData): string
end

-- 提供创建和转换数据的功能。
local record DataModule

	-- 创建一个包含任意字节的新数据对象。
	--
	-- Data:getPointer 与 LuaJIT 的 FFI 一起可用于在创建 ByteData 对象后对其内容进行操作。
	-- @param size (integer) 新数据对象的大小（以字节为单位）。 （默认值：data:getSize()。）
	-- @return (ByteData) bytedata — 新的数据对象。
	newByteData: function(size: integer): ByteData

	-- 创建一个包含任意字节的新数据对象。
	--
	-- Data:getPointer 与 LuaJIT 的 FFI 一起可用于在创建 ByteData 对象后对其内容进行操作。
	-- @param bytes (string) 新数据对象的大小（以字节为单位）。
	-- @return (ByteData) bytedata — 新的数据对象。
	newByteData: function(bytes: string): ByteData

	-- 创建一个包含任意字节的新数据对象。
	--
	-- Data:getPointer 与 LuaJIT 的 FFI 一起可用于在创建 ByteData 对象后对其内容进行操作。
	-- @param data (Data) 要复制的现有数据对象。
	-- @param offset (integer) 要复制的子节的偏移量（以字节为单位）。 （默认值：0。）
	-- @param size (integer) 新数据对象的大小（以字节为单位）。
	-- @return (ByteData) bytedata — 新的数据对象。
	newByteData: function(data: Data, offset?: integer, size?: integer): ByteData

	-- 创建引用现有数据对象的一部分的新数据。
	-- 重载说明：
	-- 1. Data:getString 和 Data:getPointer 将返回原始数据对象的内容，并应用视图的偏移量和大小。
	-- @param data (any) 要引用的数据对象。
	-- @param offset (integer) 要引用的子节的偏移量（以字节为单位）。
	-- @param size (integer) 要引用的小节的大小（以字节为单位）。
	-- @return (DataView) 新的数据视图。
	newDataView: function(data: any, offset: integer, size: integer): DataView

	-- 将数据或字符串编码为采用一种编码格式的数据或字符串。
	-- @param container (string) 返回编码数据的类型。
	-- @param format (EncodeFormat) 输出数据的格式。
	-- @param source (string | Data) 要编码的原始数据。
	-- @param line_length (integer) 输出的最大行长度。仅支持 base64，如果为 0，则忽略。（默认值：0。）
	-- @return (string) encoded — ByteData/string，其中包含源的编码版本。
	encode: function(container: string, format: EncodeFormat, source: string | Data, line_length?: integer): string

	-- 将数据或字符串编码为采用一种编码格式的数据或字符串。
	-- @param container (string) 返回编码数据的类型。
	-- @param format (EncodeFormat) 输出数据的格式。
	-- @param source (string | Data) 要编码的原始数据。
	-- @param line_length (integer) 输出的最大行长度。仅支持 base64，如果为 0，则忽略。（默认值：0。）
	-- @return (ByteData) encoded — ByteData/string，其中包含源的编码版本。
	encode: function(container: string, format: EncodeFormat, source: string | Data, line_length?: integer): ByteData

	-- 将数据或字符串从任何 EncodeFormat 解码为数据或字符串。
	-- @param container (string) 解码后的数据返回什么类型。
	-- @param format (EncodeFormat) 输入数据的格式。
	-- @param source (string | Data) 要解码的原始（编码）数据。
	-- @return (string) decoded — ByteData/string，其中包含源的解码版本。
	decode: function(container: string, format: EncodeFormat, source: string | Data): string

	-- 将数据或字符串从任何 EncodeFormat 解码为数据或字符串。
	-- @param container (string) 解码后的数据返回什么类型。
	-- @param format (EncodeFormat) 输入数据的格式。
	-- @param source (string | Data) 要解码的原始（编码）数据。
	-- @return (ByteData) decoded — ByteData/string，其中包含源的解码版本。
	decode: function(container: string, format: EncodeFormat, source: string | Data): ByteData

	-- 使用特定的压缩算法压缩字符串或数据。
	-- @param container (string) 返回压缩数据的类型。
	-- @param format (CompressionFormat) 压缩字符串时使用的格式。
	-- @param source (string | Data) 要压缩的原始（未压缩）字符串。
	-- @param level (integer) 要使用的压缩级别，介于 0 和 9 之间。-1 表示默认级别。该参数的含义取决于所使用的压缩格式。 （默认值：-1。）
	-- @return (string) compressedData — 压缩数据/字符串，其中包含原始字符串的压缩版本。
	compress: function(container: string, format: CompressionFormat, source: string | Data, level?: integer): string

	-- 使用特定的压缩算法压缩字符串或数据。
	-- @param container (string) 返回压缩数据的类型。
	-- @param format (CompressionFormat) 压缩数据时使用的格式。
	-- @param source (string | Data) 包含要压缩的原始（未压缩）数据的数据对象。
	-- @param level (integer) 要使用的压缩级别，介于 0 和 9 之间。-1 表示默认级别。该参数的含义取决于所使用的压缩格式。 （默认值：-1。）
	-- @return (CompressedData) 压缩数据/字符串，其中包含数据的压缩版本。
	compress: function(container: string, format: CompressionFormat, source: string | Data, level?: integer): CompressedData

	-- 解压缩 CompressedData 或先前压缩的字符串或数据对象。
	-- @param container (string) 解压后的数据返回什么类型。
	-- @param compressed (CompressedData) 要解压的压缩数据。
	-- @return (string) decompressedData — 包含原始解压缩数据的数据/字符串。
	decompress: function(container: string, compressed: CompressedData): string

	-- 解压缩 CompressedData 或先前压缩的字符串或数据对象。
	-- @param container (string) 解压后的数据返回什么类型。
	-- @param compressed (CompressedData) 要解压的压缩数据。
	-- @return (ByteData) decompressedData — 包含原始解压缩数据的数据/字符串。
	decompress: function(container: string, compressed: CompressedData): ByteData

	-- 解压缩 CompressedData 或先前压缩的字符串或数据对象。
	-- @param container (string) 解压后的数据返回什么类型。
	-- @param format (CompressionFormat) 用于压缩给定数据的格式。
	-- @param source (string | Data) 包含先前使用 love.data.compress. 压缩的数据的数据对象
	-- @return (string) decompressedData — 包含原始解压缩数据的数据/字符串。
	decompress: function(container: string, format: CompressionFormat, source: string | Data): string

	-- 解压缩 CompressedData 或先前压缩的字符串或数据对象。
	-- @param container (string) 解压后的数据返回什么类型。
	-- @param format (CompressionFormat) 用于压缩给定数据的格式。
	-- @param source (string | Data) 包含先前使用 love.data.compress. 压缩的数据的数据对象
	-- @return (ByteData) decompressedData — 包含原始解压缩数据的数据/字符串。
	decompress: function(container: string, format: CompressionFormat, source: string | Data): ByteData

	-- 打包（序列化）简单的 Lua 值。
	--
	-- 该函数的行为与 Lua 5.3 的 string.pack 相同。
	-- @param container (string) 返回编码数据的类型。
	-- @param format (string) 决定如何打包值的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
	-- @param values (any...) 要序列化的第一个值（数字、布尔值或字符串）。
	-- @return (string) data — 包含序列化数据的数据/字符串。
	pack: function(container: string, format: string, values: any...): string

	-- 打包（序列化）简单的 Lua 值。
	--
	-- 该函数的行为与 Lua 5.3 的 string.pack 相同。
	-- @param container (string) 返回编码数据的类型。
	-- @param format (string) 决定如何打包值的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
	-- @param values (any...) 要序列化的第一个值（数字、布尔值或字符串）。
	-- @return (ByteData) data — 包含序列化数据的数据/字符串。
	pack: function(container: string, format: string, values: any...): ByteData

	-- 将字节字符串或数据解包（反序列化）为简单的 Lua 值。
	--
	-- 该函数的行为与 Lua 5.3 的 string.unpack 相同。
	-- @param format (string) 确定值如何打包的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
	-- @param source (string) 包含打包（序列化）数据的字符串。
	-- @param position (integer) 从哪里开始读取字符串。负值可用于从字符串末尾读取相对值。 （默认值：1。）
	-- @return (any...) v1 — 解压的第一个值（数字、布尔值或字符串）。
	unpack: function(format: string, source: string, position?: integer): any...

	-- 将字节字符串或数据解包（反序列化）为简单的 Lua 值。
	--
	-- 该函数的行为与 Lua 5.3 的 string.unpack 相同。
	-- @param format (string) 确定值如何打包的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
	-- @param source (Data) 包含打包（序列化）数据的数据对象。
	-- @param position (integer) 从 1 开始的索引，指示从何处开始读取数据。负值可用于从数据对象末尾读取相对值。 （默认值：1。）
	-- @return (any...) v1 — 解压的第一个值（数字、布尔值或字符串）。
	unpack: function(format: string, source: Data, position?: integer): any...

	-- 获取与 love.data.pack 一起使用的给定格式将使用的大小（以字节为单位）。
	-- 该函数的行为与 Lua 5.3 的 string.packsize 相同。
	-- 重载说明：
	-- 1. 格式字符串不能有可变长度选项's' 或'z'。
	-- @param format (string) 确定如何打包值的字符串。遵循 Lua 5.3 的 string.pack 格式字符串的规则。
	-- @return (integer) 打包数据将使用的大小（以字节为单位）。
	getPackedSize: function(format: string): integer

	-- 使用指定的哈希算法计算字符串的消息摘要。
	-- @param hash_function (HashFunction) 要使用的哈希算法。
	-- @param source (string) 要散列的字符串。
	-- @return (string) rawdigest — 原始消息摘要字符串。
	hash: function(hash_function: HashFunction, source: string): string

	-- 使用指定的哈希算法计算字符串的消息摘要。
	-- @param hash_function (HashFunction) 要使用的哈希算法。
	-- @param source (Data) 要散列的数据。
	-- @return (string) rawdigest — 原始消息摘要字符串。
	hash: function(hash_function: HashFunction, source: Data): string
end

-- 一个随机数生成对象，有自己的随机状态。
local record RandomGenerator

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: RandomGenerator): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: RandomGenerator, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: RandomGenerator): boolean

	-- 以独立于平台的方式生成伪随机数。
	-- @return (number) number — 伪随机数。
	random: function(self: RandomGenerator): number

	-- 以独立于平台的方式生成伪随机数。
	-- @param upper (number) 它应该返回的最大可能值。
	-- @return (number) 伪随机整数。
	random: function(self: RandomGenerator, upper: number): number

	-- 以独立于平台的方式生成伪随机数。
	-- @param lower (number) 它应该返回的最小可能值。
	-- @param upper (number) 它应该返回的最大可能值。
	-- @return (number) 伪随机整数。
	random: function(self: RandomGenerator, lower: number, upper: number): number

	-- 获取正态分布的伪随机数。
	-- @param standard_deviation (number) 分布的标准偏差。 （默认值：1。）
	-- @param mean (number) 分布的平均值。 （默认值：0。）
	-- @return (number) 具有方差 (stddev)² 和指定平均值的正态分布随机数。
	randomNormal: function(self: RandomGenerator, standard_deviation?: number, mean?: number): number

	-- 使用指定的整数设置随机数生成器的种子。
	-- @param seed (number) 您想要用于随机化种子的整数。必须在 2^53 范围内。
	setSeed: function(self: RandomGenerator, seed: number)

	-- 使用指定的整数设置随机数生成器的种子。
	-- @param low (number) 种子值的低 32 位。必须在 2^32 - 1 范围内。
	-- @param high (number) 种子值的高 32 位。必须在 2^32 - 1 范围内。
	setSeed: function(self: RandomGenerator, low: number, high: number)

	-- 获取随机数生成器对象的种子。
	-- 由于 Lua 对所有数值都使用双精度数，因此种子被分成两个数字 - 双精度数无法准确表示 2^53 以上的整数值，但种子值是 2^64 - 1 范围内的整数。
	-- @return (number) 表示 RandomGenerator 的 64 位种子值的低 32 位的整数。
	-- @return (number) 表示 RandomGenerator 的 64 位种子值的高 32 位的整数。
	getSeed: function(self: RandomGenerator): number, number

	-- 设置随机数生成器的当前状态。用作此函数参数的值是一个不透明字符串，并且只能源自 LÖVE 的同一主要版本中之前对 RandomGenerator:getState 的调用。
	-- 这与 RandomGenerator:setSeed 不同，setState 直接设置 RandomGenerator 的当前依赖于实现的状态，而 setSeed 为其提供新的种子值。
	-- 重载说明：
	-- 1. 状态字符串的效果与当前操作系统无关。
	-- @param state (string) RandomGenerator 对象的新状态，表示为字符串。这应该源自之前对 RandomGenerator:getState 的调用。
	setState: function(self: RandomGenerator, state: string)

	-- 获取随机数生成器的当前状态。这会返回一个不透明的字符串，该字符串仅适用于以后与 LÖVE 的相同主要版本中的 RandomGenerator:setState 一起使用。
	-- 这与 RandomGenerator:getSeed 不同，getState 获取 RandomGenerator 的当前状态，而 getSeed 获取之前设置的种子数。
	-- 重载说明：
	-- 1. 状态字符串的值与当前操作系统无关。
	-- @return (string) RandomGenerator 对象的当前状态，表示为字符串。
	getState: function(self: RandomGenerator): string
end

-- 包含坐标系变换的对象。
local record Transform

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Transform): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Transform, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Transform): boolean

	-- 创建此变换的新副本。
	-- @return (Transform) 此变换的副本。
	clone: function(self: Transform): Transform

	-- 创建一个包含此变换的逆变换的新变换。
	-- @return (Transform) 一个新的 Transform 对象，表示此 Transform 矩阵的逆矩阵。
	inverse: function(self: Transform): Transform

	-- 将给定的其他 Transform 对象应用于此对象。
	-- 这有效地将此 Transform 的内部变换矩阵与其他 Transform 的（即 self * other）相乘，并将结果存储在此对象中。
	-- @param other (Transform) 应用于此变换的另一个变换对象。
	-- @return (Transform) 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	apply: function(self: Transform, other: Transform): Transform

	-- 检查变换是否是仿射变换。
	-- @return (boolean) 如果变换对象是仿射变换，则为 true，否则为 false。
	isAffine2DTransform: function(self: Transform): boolean

	-- 将平移应用到变换的坐标系。此方法不会重置任何先前应用的转换。
	-- @param x (number) 沿 x 轴的相对平移。
	-- @param y (number) 沿 y 轴的相对平移。
	-- @return (Transform) 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	translate: function(self: Transform, x: number, y: number): Transform

	-- 对变换的坐标系应用旋转。此方法不会重置任何先前应用的转换。
	-- @param angle (number) 旋转此变换的相对角度（以弧度为单位）。
	-- @return (Transform) 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	rotate: function(self: Transform, angle: number): Transform

	-- 缩放变换的坐标系。此方法不会重置任何先前应用的转换。
	-- @param x (number) 沿 x 轴的相对比例因子。
	-- @param y (number) 沿 y 轴的相对比例因子。 （默认值：sx。）
	-- @return (Transform) 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	scale: function(self: Transform, x: number, y?: number): Transform

	-- 将剪切因子（倾斜）应用于变换的坐标系。此方法不会重置任何先前应用的转换。
	-- @param x (number) 沿 x 轴的剪切因子。
	-- @param y (number) 沿 y 轴的剪切因子。
	-- @return (Transform) 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	shear: function(self: Transform, x: number, y: number): Transform

	-- 将变换重置为同一状态。所有先前应用的转换都将被删除。
	-- @return (Transform) 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	reset: function(self: Transform): Transform

	-- 将变换重置为指定的变换参数。
	-- @param x (number) 变换在 x 轴上的位置。
	-- @param y (number) 变换在 y 轴上的位置。
	-- @param angle (number) 变换的方向（以弧度为单位）。 （默认值：0。）
	-- @param scale_x (number) x 轴上的比例因子。 （默认值：1。）
	-- @param scale_y (number) y 轴的比例因子。 （默认值：sx。）
	-- @param origin_x (number) x 轴上的原点偏移。 （默认值：0。）
	-- @param origin_y (number) y 轴上的原点偏移。 （默认值：0。）
	-- @param shear_x (number) x 轴上的剪切/倾斜因子。 （默认值：0。）
	-- @param shear_y (number) y 轴上的剪切/倾斜因子。 （默认值：0。）
	-- @return (Transform) 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	setTransformation: function(self: Transform, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): Transform

	-- 直接设置Transform的内部4x4变换矩阵。
	-- @param layout (string) 如何解释矩阵元素参数（行优先或列优先）。
	-- @param elements ({number} | {{number}}) 包含 16 个矩阵元素的平面表。
	-- @return (Transform) transform — 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	setMatrix: function(self: Transform, layout: string, elements: {number} | {{number}}): Transform

	-- 直接设置Transform的内部4x4变换矩阵。
	-- @param elements ({number} | {{number}}) 如何解释矩阵元素参数（行优先或列优先）。
	-- @return (Transform) transform — 调用该方法的 Transform 对象。允许轻松链接 Transform 方法。
	setMatrix: function(self: Transform, elements: {number} | {{number}}): Transform

	-- 获取此Transform存储的内部4x4变换矩阵。矩阵按行优先顺序返回。
	-- @return (number) 矩阵第一行的第一列。
	-- @return (number) 矩阵第一行的第二列。
	-- @return (number) 矩阵第一行的第三列。
	-- @return (number) 矩阵第一行的第四列。
	-- @return (number) 矩阵第二行第一列。
	-- @return (number) 矩阵第二行的第二列。
	-- @return (number) 矩阵第二行第三列。
	-- @return (number) 矩阵第二行第四列。
	-- @return (number) 矩阵第三行第一列。
	-- @return (number) 矩阵第三行第二列。
	-- @return (number) 矩阵第三行第三列。
	-- @return (number) 矩阵第三行第四列。
	-- @return (number) 矩阵第四行第一列。
	-- @return (number) 矩阵第四行第二列。
	-- @return (number) 矩阵第四行第三列。
	-- @return (number) 矩阵第四行第四列。
	getMatrix: function(self: Transform): number, number, number, number, number, number, number, number, number, number, number, number, number, number, number, number

	-- 将 Transform 对象的变换应用到给定的 2D 位置。
	-- 这有效地将给定位置从全局坐标转换到变换的局部坐标空间。
	-- @param x (number) 全局坐标中位置的 x 分量。
	-- @param y (number) 全局坐标中位置的 y 分量。
	-- @return (number) 应用变换的位置的 x 分量。
	-- @return (number) 应用变换的位置的 y 分量。
	transformPoint: function(self: Transform, x: number, y: number): number, number

	-- 将 Transform 对象的变换反向应用到给定的 2D 位置。
	-- 这有效地将给定位置从变换的局部坐标空间转换为全局坐标。
	-- 如果给定的变换应用了用于游戏中相机系统的变换，则此方法的一种用途是将屏幕空间鼠标位置转换为全局世界坐标。
	-- @param x (number) 应用变换的位置的 x 分量。
	-- @param y (number) 应用变换的位置的 y 分量。
	-- @return (number) 全局坐标中位置的 x 分量。
	-- @return (number) 全局坐标中位置的 y 分量。
	inverseTransformPoint: function(self: Transform, x: number, y: number): number, number
end

-- 一个贝塞尔曲线对象，可以评估和渲染任意阶数的贝塞尔曲线。
local record BezierCurve

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: BezierCurve): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: BezierCurve, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: BezierCurve): boolean

	-- 获取贝塞尔曲线的阶数。次数等于控制点数 - 1。
	-- @return (integer) 贝塞尔曲线的阶数。
	getDegree: function(self: BezierCurve): integer

	-- 获取贝塞尔曲线的导数。
	-- 该函数可用于旋转沿着曲线移动的精灵的运动方向，并在某个参数 t 处计算垂直于曲线的方向。
	-- @return (BezierCurve) 导数曲线。
	getDerivative: function(self: BezierCurve): BezierCurve

	-- 获取第i个控制点的坐标。索引从 1 开始。
	-- @param index (integer) 控制点的索引。
	-- @return (number) 控制点沿 x 轴的位置。
	-- @return (number) 控制点沿 y 轴的位置。
	getControlPoint: function(self: BezierCurve, index: integer): number, number

	-- 设置第i个控制点的坐标。索引从 1 开始。
	-- @param index (integer) 控制点的索引。
	-- @param x (number) 控制点沿 x 轴的位置。
	-- @param y (number) 控制点沿 y 轴的位置。
	setControlPoint: function(self: BezierCurve, index: integer, x: number, y: number)

	-- 插入控制点作为新的第 i 个控制点。从 i 开始的现有控制点向后推 1。索引从 1 开始。负索引环绕：-1 是最后一个控制点，-2 是最后一个控制点之前的控制点，等等。
	-- @param x (number) 控制点沿 x 轴的位置。
	-- @param y (number) 控制点沿 y 轴的位置。
	-- @param index (integer) 控制点的索引。 （默认值：-1。）
	insertControlPoint: function(self: BezierCurve, x: number, y: number, index?: integer)

	-- 删除指定的控制点。
	-- @param index (integer) 要删除的控制点的索引。
	removeControlPoint: function(self: BezierCurve, index: integer)

	-- 获取贝塞尔曲线中控制点的数量。
	-- @return (integer) 控制点数。
	getControlPointCount: function(self: BezierCurve): integer

	-- 将贝塞尔曲线移动一个偏移量。
	-- @param x (number) 沿 x 轴的偏移。
	-- @param y (number) 沿 y 轴的偏移。
	translate: function(self: BezierCurve, x: number, y: number)

	-- 将贝塞尔曲线旋转一个角度。
	-- @param angle (number) 以弧度为单位的旋转角度。
	-- @param origin_x (number) 旋转中心的X坐标。 （默认值：0。）
	-- @param origin_y (number) 旋转中心的Y坐标。 （默认值：0。）
	rotate: function(self: BezierCurve, angle: number, origin_x?: number, origin_y?: number)

	-- 将贝塞尔曲线缩放一个因子。
	-- @param scale (number) 比例因子。
	-- @param origin_x (number) 缩放中心的X坐标。 （默认值：0。）
	-- @param origin_y (number) 缩放中心的Y坐标。 （默认值：0。）
	scale: function(self: BezierCurve, scale: number, origin_x?: number, origin_y?: number)

	-- 在参数 t 处评估贝塞尔曲线。该参数必须介于 0 和 1 之间（包含 0 和 1）。
	-- 此函数可用于沿路径或补间参数移动对象。但是，它不应该用于渲染曲线，为此目的请参阅 BezierCurve:render 。
	-- @param time (number) 在哪里评估曲线。
	-- @return (number) 参数 t 处曲线的 x 坐标。
	-- @return (number) 参数 t 处曲线的 y 坐标。
	evaluate: function(self: BezierCurve, time: number): number, number

	-- 获取与此 BezierCurve 的指定段相对应的 BezierCurve。
	-- @param start (number) 沿曲线的起点。必须介于 0 和 1 之间。
	-- @param finish (number) 段结束。必须介于 0 和 1 之间。
	-- @return (BezierCurve) 与指定线段相对应的贝塞尔曲线。
	getSegment: function(self: BezierCurve, start: number, finish: number): BezierCurve

	-- 获取要与love.graphics.line.
	-- 该函数使用递归细分对贝塞尔曲线进行采样。您可以使用深度参数控制递归深度。
	-- 如果您只是想知道给定参数的曲线上的位置，请使用 BezierCurve:evaluate。
	-- @param accuracy (integer) 递归细分步骤数。 （默认值：5。）
	-- @return ({number}) 曲线上 x,y 坐标点对的列表。
	render: function(self: BezierCurve, accuracy?: integer): {number}

	-- 获取曲线特定部分的坐标列表，与 love.graphics.line.
	-- 该函数使用递归细分对贝塞尔曲线进行采样。您可以使用深度参数控制递归深度。
	-- 如果您只需要知道给定参数的曲线上的位置，请使用BezierCurve:evaluate。
	-- @param start (number) 沿曲线的起点。必须介于 0 和 1 之间。
	-- @param finish (number) 要渲染的段的结尾。必须介于 0 和 1 之间。
	-- @param accuracy (integer) 递归细分步骤数。 （默认值：5。）
	-- @return ({number}) 曲线指定部分上的点的 x,y 坐标对列表。
	renderSegment: function(self: BezierCurve, start: number, finish: number, accuracy?: integer): {number}
end

-- 提供与系统无关的数学函数。
local record MathModule

	-- 创建一个新的 RandomGenerator 对象，该对象完全独立于其他 RandomGenerator 对象和随机函数。
	-- @param seed (number) 用于此对象的初始种子号。
	-- @return (RandomGenerator) rng — 新的随机数生成器对象。
	newRandomGenerator: function(seed?: number): RandomGenerator

	-- 创建一个新的 RandomGenerator 对象，该对象完全独立于其他 RandomGenerator 对象和随机函数。
	-- @param low (number) 用于此对象的种子号的低 32 位。
	-- @param high (number) 用于此对象的种子号的高 32 位。
	-- @return (RandomGenerator) rng — 新的随机数生成器对象。
	newRandomGenerator: function(low: number, high: number): RandomGenerator

	-- 创建一个新的 Transform 对象。
	-- @return (Transform) transform — 新的变换对象。
	newTransform: function(): Transform

	-- 创建一个新的 Transform 对象。
	-- @param x (number) 新变换在 x 轴上的位置。
	-- @param y (number) 新变换在 y 轴上的位置。
	-- @param angle (number) 新变换的方向（以弧度为单位）。 （默认值：0。）
	-- @param scale_x (number) x 轴上的比例因子。 （默认值：1。）
	-- @param scale_y (number) y 轴的比例因子。 （默认值：sx。）
	-- @param origin_x (number) x 轴上的原点偏移。 （默认值：0。）
	-- @param origin_y (number) y 轴上的原点偏移。 （默认值：0。）
	-- @param shear_x (number) x 轴上的剪切/倾斜因子。 （默认值：0。）
	-- @param shear_y (number) y 轴上的剪切/倾斜因子。 （默认值：0。）
	-- @return (Transform) transform — 新的变换对象。
	newTransform: function(x: number, y: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number): Transform

	-- 创建一个新的 BezierCurve 对象。
	--
	-- 控制多边形中的顶点数决定了曲线的阶数，例如三个顶点定义二次（2 次）贝塞尔曲线，四个顶点定义三次（3 次）贝塞尔曲线，等等。
	-- @param vertices ({number}) 控制多边形的顶点作为表格，形式为{x1, y1, x2, y2, x3, y3, ...}。
	-- @return (BezierCurve) curve — 贝塞尔曲线对象。
	newBezierCurve: function(vertices: {number}): BezierCurve

	-- 创建一个新的 BezierCurve 对象。
	--
	-- 控制多边形中的顶点数决定了曲线的阶数，例如三个顶点定义二次（2 次）贝塞尔曲线，四个顶点定义三次（3 次）贝塞尔曲线，等等。
	-- @param coordinates (number...) 控制多边形的顶点作为表格，形式为{x1, y1, x2, y2, x3, y3, ...}。
	-- @return (BezierCurve) curve — 贝塞尔曲线对象。
	newBezierCurve: function(coordinates: number...): BezierCurve

	-- 生成 1-4 维的 Simplex 或 Perlin 噪声值。给定相同的参数，返回值将始终相同。
	--
	-- 单纯形噪声与 Perlin 噪声密切相关。它广泛用于程序内容生成。
	--
	-- 有很多网页详细讨论了 Perlin 和 Simplex 噪声。
	-- @param x (number) 用于生成噪声值的数字。
	-- @return (number) value — 1范围内的噪声值。
	noise: function(x: number): number

	-- 生成 1-4 维的 Simplex 或 Perlin 噪声值。给定相同的参数，返回值将始终相同。
	--
	-- 单纯形噪声与 Perlin 噪声密切相关。它广泛用于程序内容生成。
	--
	-- 有很多网页详细讨论了 Perlin 和 Simplex 噪声。
	-- @param x (number) 用于生成噪声值的二维向量的第一个值。
	-- @param y (number) 用于生成噪声值的二维向量的第二个值。
	-- @return (number) value — 1范围内的噪声值。
	noise: function(x: number, y: number): number

	-- 生成 1-4 维的 Simplex 或 Perlin 噪声值。给定相同的参数，返回值将始终相同。
	--
	-- 单纯形噪声与 Perlin 噪声密切相关。它广泛用于程序内容生成。
	--
	-- 有很多网页详细讨论了 Perlin 和 Simplex 噪声。
	-- @param x (number) 用于生成噪声值的 3 维向量的第一个值。
	-- @param y (number) 用于生成噪声值的三维向量的第二个值。
	-- @param z (number) 用于生成噪声值的三维向量的第三个值。
	-- @return (number) value — 1范围内的噪声值。
	noise: function(x: number, y: number, z: number): number

	-- 生成 1-4 维的 Simplex 或 Perlin 噪声值。给定相同的参数，返回值将始终相同。
	--
	-- 单纯形噪声与 Perlin 噪声密切相关。它广泛用于程序内容生成。
	--
	-- 有很多网页详细讨论了 Perlin 和 Simplex 噪声。
	-- @param x (number) 用于生成噪声值的 4 维向量的第一个值。
	-- @param y (number) 用于生成噪声值的 4 维向量的第二个值。
	-- @param z (number) 用于生成噪声值的 4 维向量的第三个值。
	-- @param w (number) 用于生成噪声值的 4 维向量的第四个值。
	-- @return (number) value — 1范围内的噪声值。
	noise: function(x: number, y: number, z: number, w: number): number

	-- 以独立于平台的方式生成伪随机数。默认的 love.run 在启动时为该函数设置种子，因此您通常不需要自己为其设置种子。
	-- @return (number) number — 伪随机数。
	random: function(): number

	-- 以独立于平台的方式生成伪随机数。默认的 love.run 在启动时为该函数设置种子，因此您通常不需要自己为其设置种子。
	-- @param upper (number) 它应该返回的最大可能值。
	-- @return (number) 伪随机整数。
	random: function(upper: number): number

	-- 以独立于平台的方式生成伪随机数。默认的 love.run 在启动时为该函数设置种子，因此您通常不需要自己为其设置种子。
	-- @param lower (number) 它应该返回的最小可能值。
	-- @param upper (number) 它应该返回的最大可能值。
	-- @return (number) 伪随机整数。
	random: function(lower: number, upper: number): number

	-- 获取正态分布的伪随机数。
	-- @param standard_deviation (number) 分布的标准偏差。 （默认值：1。）
	-- @param mean (number) 分布的平均值。 （默认值：0。）
	-- @return (number) 具有方差 (stddev)² 和指定平均值的正态分布随机数。
	randomNormal: function(standard_deviation?: number, mean?: number): number

	-- 使用指定的整数设置随机数生成器的种子。这是在启动时内部调用的，因此您通常不需要自己调用它。
	-- @param seed (number) 您想要用于随机化种子的整数。必须在 2^53 - 1 范围内。
	setRandomSeed: function(seed: number)

	-- 使用指定的整数设置随机数生成器的种子。这是在启动时内部调用的，因此您通常不需要自己调用它。
	-- @param low (number) 种子值的低 32 位。必须在 2^32 - 1 范围内。
	-- @param high (number) 种子值的高 32 位。必须在 2^32 - 1 范围内。
	setRandomSeed: function(low: number, high: number)

	-- 获取随机数生成器的种子。
	-- 由于Lua对所有数值都使用双精度数，因此种子被分成两个数字 - 双精度数无法准确表示大于2^53的整数值，但种子可以是最大2^64的整数值。
	-- @return (number) 表示随机数生成器的 64 位种子值的低 32 位的整数。
	-- @return (number) 表示随机数生成器的 64 位种子值的高 32 位的整数。
	getRandomSeed: function(): number, number

	-- 设置随机数生成器的当前状态。用作此函数参数的值是一个不透明的依赖于实现的字符串，并且只能源自先前对 love.math.getRandomState.
	-- 这与 love.math.setRandomSeed 不同，setRandomState 直接设置随机数生成器的当前依赖于实现的状态，而 setRandomSeed 为其提供新的种子值。
	-- 重载说明：
	-- 1. 状态字符串的效果与当前操作系统无关。
	-- @param state (string) 随机数生成器的新状态，表示为字符串。这应该源自之前对 love.math.getRandomState.
	setRandomState: function(state: string)

	-- 获取随机数生成器的当前状态。这将返回一个不透明的依赖于实现的字符串，该字符串仅对以后与 love.math.setRandomState 或 RandomGenerator:setState 一起使用有用。
	-- 这与 love.math.getRandomSeed 不同，getRandomState 获取随机数生成器的当前状态，而 getRandomSeed 获取之前设置的种子数。
	-- 重载说明：
	-- 1. 状态字符串的值与当前操作系统无关。
	-- @return (string) 随机数生成器的当前状态，表示为字符串。
	getRandomState: function(): string

	-- 将颜色从 0..1 转换到 0..255 范围。
	-- @param red (number) 红色分量。
	-- @param green (number) 绿色分量。
	-- @param blue (number) 蓝色分量。
	-- @param alpha (number) Alpha 颜色分量。 （默认值：无。）
	-- @return (number) rb — 0..255 范围内的红色分量。
	-- @return (number) gb — 0..255 范围内的绿色分量。
	-- @return (number) bb — 0..255 范围内的蓝色分量。
	-- @return (number | nil) ab — 0..255 范围内的 Alpha 颜色分量，如果未指定 alpha，则为零。
	colorToBytes: function(red: number, green: number, blue: number, alpha?: number): number, number, number, number | nil

	-- 将颜色从 0..1 转换到 0..255 范围。
	-- @param color ({number}) 红色分量。
	-- @return (number) rb — 0..255 范围内的红色分量。
	-- @return (number) gb — 0..255 范围内的绿色分量。
	-- @return (number) bb — 0..255 范围内的蓝色分量。
	-- @return (number | nil) ab — 0..255 范围内的 Alpha 颜色分量，如果未指定 alpha，则为零。
	colorToBytes: function(color: {number}): number, number, number, number | nil

	-- 将颜色从 0..255 转换为 0..1 范围。
	-- @param red (number) 0..255 范围内的红色分量。
	-- @param green (number) 0..255 范围内的绿色分量。
	-- @param blue (number) 0..255 范围内的蓝色分量。
	-- @param alpha (number) 0..255 范围内的 Alpha 颜色分量。 （默认值：无。）
	-- @return (number) r — 0..1 范围内的红色分量。
	-- @return (number) g — 0..1 范围内的绿色分量。
	-- @return (number) b — 0..1 范围内的蓝色分量。
	-- @return (number | nil) a — 0..1 范围内的 Alpha 颜色分量，如果未指定 alpha，则为零。
	colorFromBytes: function(red: number, green: number, blue: number, alpha?: number): number, number, number, number | nil

	-- 将颜色从 0..255 转换为 0..1 范围。
	-- @param color ({number}) 0..255 范围内的红色分量。
	-- @return (number) r — 0..1 范围内的红色分量。
	-- @return (number) g — 0..1 范围内的绿色分量。
	-- @return (number) b — 0..1 范围内的蓝色分量。
	-- @return (number | nil) a — 0..1 范围内的 Alpha 颜色分量，如果未指定 alpha，则为零。
	colorFromBytes: function(color: {number}): number, number, number, number | nil

	-- 将颜色从伽玛空间 (sRGB) 转换为线性空间 (RGB)。这在进行伽马校正渲染时非常有用，并且在 LÖVE 无法自动处理转换的少数情况下，您需要使用线性 RGB 进行数学计算。
	--
	-- 在此处、此处和此处阅读有关伽玛校正渲染的更多信息。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @param red (number) 要转换的 sRGB 颜色的红色通道。
	-- @param green (number) 要转换的 sRGB 颜色的绿色通道。
	-- @param blue (number) 要转换的 sRGB 颜色的蓝色通道。
	-- @param alpha (number) Alpha 通道，将保持不变并原样返回。（默认值：nil。）
	-- @return (number) lr — 线性 RGB 空间中转换颜色的红色通道。
	-- @return (number | nil) lg — 线性 RGB 空间中转换颜色的绿色通道。
	-- @return (number | nil) lb — 线性RGB空间中转换颜色的蓝色通道。
	-- @return (number | nil) lc — 线性RGB空间中颜色通道的值。
	gammaToLinear: function(red: number, green?: number, blue?: number, alpha?: number): number, number | nil, number | nil, number | nil

	-- 将颜色从伽玛空间 (sRGB) 转换为线性空间 (RGB)。这在进行伽马校正渲染时非常有用，并且在 LÖVE 无法自动处理转换的少数情况下，您需要使用线性 RGB 进行数学计算。
	--
	-- 在此处、此处和此处阅读有关伽玛校正渲染的更多信息。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @param color ({number}) 一个表，其中包含要转换的 sRGB 颜色的红色、绿色和蓝色通道。
	-- @return (number) lr — 线性 RGB 空间中转换颜色的红色通道。
	-- @return (number | nil) lg — 线性 RGB 空间中转换颜色的绿色通道。
	-- @return (number | nil) lb — 线性RGB空间中转换颜色的蓝色通道。
	-- @return (number | nil) lc — 线性RGB空间中颜色通道的值。
	gammaToLinear: function(color: {number}): number, number | nil, number | nil, number | nil

	-- 将颜色从线性空间 (RGB) 转换为伽玛空间 (sRGB)。这在图像中存储线性 RGB 颜色值时非常有用，因为对于深色，线性 RGB 颜色空间的精度低于 sRGB，这可能会导致绘图时出现明显的色带。
	--
	-- 一般来说，根据屏幕上的外观选择的颜色已经在伽马空间中，不应该进行双重转换。使用数学计算的颜色通常位于线性 RGB 空间中。
	--
	-- 在此处、此处和此处阅读有关伽玛校正渲染的更多信息。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @param red (number) 要转换的线性 RGB 颜色的红色通道。
	-- @param green (number) 要转换的线性 RGB 颜色的绿色通道。
	-- @param blue (number) 要转换的线性 RGB 颜色的蓝色通道。
	-- @param alpha (number) Alpha 通道，将保持不变并原样返回。（默认值：nil。）
	-- @return (number) cr — gamma sRGB 空间中转换颜色的红色通道。
	-- @return (number | nil) cg — gamma sRGB 空间中转换颜色的绿色通道。
	-- @return (number | nil) cb — gamma sRGB 空间中转换颜色的蓝色通道。
	-- @return (number | nil) c — gamma sRGB 空间中颜色通道的值。
	linearToGamma: function(red: number, green?: number, blue?: number, alpha?: number): number, number | nil, number | nil, number | nil

	-- 将颜色从线性空间 (RGB) 转换为伽玛空间 (sRGB)。这在图像中存储线性 RGB 颜色值时非常有用，因为对于深色，线性 RGB 颜色空间的精度低于 sRGB，这可能会导致绘图时出现明显的色带。
	--
	-- 一般来说，根据屏幕上的外观选择的颜色已经在伽马空间中，不应该进行双重转换。使用数学计算的颜色通常位于线性 RGB 空间中。
	--
	-- 在此处、此处和此处阅读有关伽玛校正渲染的更多信息。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @param color ({number}) 一个表，其中包含要转换的线性 RGB 颜色的红色、绿色和蓝色通道。
	-- @return (number) cr — gamma sRGB 空间中转换颜色的红色通道。
	-- @return (number | nil) cg — gamma sRGB 空间中转换颜色的绿色通道。
	-- @return (number | nil) cb — gamma sRGB 空间中转换颜色的蓝色通道。
	-- @return (number | nil) c — gamma sRGB 空间中颜色通道的值。
	linearToGamma: function(color: {number}): number, number | nil, number | nil, number | nil

	-- 检查多边形是否为凸多边形。
	--
	-- love.physics 中的 PolygonShapes、某些形式的网格以及使用 love.graphics.polygon 绘制的多边形必须是简单的凸多边形。
	-- @param vertices ({number}) 多边形的顶点作为表格，形式为{x1, y1, x2, y2, x3, y3, ...}。
	-- @return (boolean) convex — 给定的多边形是否是凸的。
	isConvex: function(vertices: {number}): boolean

	-- 检查多边形是否为凸多边形。
	--
	-- love.physics 中的 PolygonShapes、某些形式的网格以及使用 love.graphics.polygon 绘制的多边形必须是简单的凸多边形。
	-- @param coordinates (number...) 多边形的顶点作为表格，形式为{x1, y1, x2, y2, x3, y3, ...}。
	-- @return (boolean) convex — 给定的多边形是否是凸的。
	isConvex: function(coordinates: number...): boolean

	-- 将简单的凸多边形或凹多边形分解为三角形。
	-- @param vertices ({number}) 用于三角测量的多边形。不得与自身相交。
	-- @return ({{number}}) triangles — 多边形组成的三角形列表，格式为 {{x1, y1, x2, y2, x3, y3}, {x1, y1, x2, y2, x3, y3}, ...}。
	triangulate: function(vertices: {number}): {{number}}

	-- 将简单的凸多边形或凹多边形分解为三角形。
	-- @param coordinates (number...) 用于三角测量的多边形。不得与自身相交。
	-- @return ({{number}}) triangles — 多边形组成的三角形列表，格式为 {{x1, y1, x2, y2, x3, y3}, {x1, y1, x2, y2, x3, y3}, ...}。
	triangulate: function(coordinates: number...): {{number}}

	-- love.data.compress 的弃用别名。
	-- @param container (string) 要返回的值类型。
	-- @param format (CompressionFormat) 使用的压缩格式。
	-- @param source (string | Data) 未压缩的源数据。
	-- @param level (integer) 压缩级别，范围为 0 到 9；-1 表示使用默认级别。
	-- @return (string) 字符串形式的压缩数据。
	compress: function(container: string, format: CompressionFormat, source: string | Data, level?: integer): string

	-- love.data.compress 的弃用别名。
	-- @param container (string) 要返回的值类型。
	-- @param format (CompressionFormat) 使用的压缩格式。
	-- @param source (string | Data) 未压缩的源数据。
	-- @param level (integer) 压缩级别，范围为 0 到 9；-1 表示使用默认级别。
	-- @return (CompressedData) CompressedData 对象形式的压缩数据。
	compress: function(container: string, format: CompressionFormat, source: string | Data, level?: integer): CompressedData

	-- love.data.decompress 的弃用别名。
	-- @param container (string) 要返回的值类型。
	-- @param compressed (CompressedData) 要解压的压缩数据。
	-- @return (string) 字符串形式的解压缩数据。
	decompress: function(container: string, compressed: CompressedData): string

	-- love.data.decompress 的弃用别名。
	-- @param container (string) 要返回的值类型。
	-- @param compressed (CompressedData) 要解压的压缩数据。
	-- @return (ByteData) ByteData 对象形式的解压缩数据。
	decompress: function(container: string, compressed: CompressedData): ByteData
end

-- 表示文件系统上的一个文件。接受文件路径的函数也可以接受文件。
local record File

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: File): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: File, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: File): boolean

	-- 打开文件进行写入、读取或追加。
	-- 重载说明：
	-- 1. 如果您收到错误消息'Could not set write directory'，请尝试设置保存目录。这可以通过 love.filesystem.setIdentity 或通过在 love.conf
	-- 中设置身份字段来完成（仅适用于 love 0.7 或更高版本）。
	-- @param mode (FileMode) 打开文件的模式。
	-- @return (boolean or nil) 成功则为 true，否则为 false。
	-- @return (string or nil) 发生错误时的错误字符串。
	open: function(self: File, mode: FileMode): boolean | nil, string | nil

	-- 关闭文件。
	-- @return (boolean) 是否关闭成功。
	close: function(self: File): boolean

	-- 获取文件是否打开。
	-- @return (boolean) 如果文件当前打开则为 true，否则为 false。
	isOpen: function(self: File): boolean

	-- 返回文件大小。
	-- @return (number or nil) 文件大小（以字节为单位）。
	getSize: function(self: File): number | nil, string | nil

	-- 从文件中读取多个字节。
	-- @param size (integer) 要读取的字节数。 （默认值：全部。）
	-- @return (string | nil) contents — 读取字节的内容。
	-- @return (number | string) size — 已读取多少字节。
	read: function(self: File, size?: integer): string | nil, number | string

	-- 从文件中读取多个字节。
	-- @param container (string) 返回文件内容的类型。
	-- @param size (integer) 要读取的字节数。 （默认值：全部。）
	-- @return (string | nil) FileData 或包含读取字节的字符串。
	-- @return (number | string) size — 已读取多少字节。
	read: function(self: File, container: string, size?: integer): string | nil, number | string

	-- 从文件中读取多个字节。
	-- @param container (string) 返回文件内容的类型。
	-- @param size (integer) 要读取的字节数。 （默认值：全部。）
	-- @return (FileData | nil) FileData 或包含读取字节的字符串。
	-- @return (number | string) size — 已读取多少字节。
	read: function(self: File, container: string, size?: integer): FileData | nil, number | string

	-- 将数据写入文件。
	-- @param data (string) 要写入的字符串数据。
	-- @param size (integer) 要写入多少字节。 （默认值：全部。）
	-- @return (boolean | nil) success — 操作是否成功。
	-- @return (string | nil) err — 发生错误时的错误字符串。
	write: function(self: File, data: string, size?: integer): boolean | nil, string | nil

	-- 将数据写入文件。
	-- @param data (FileData) 要写入的数据对象。
	-- @param size (integer) 要写入多少字节。 （默认值：全部。）
	-- @return (boolean | nil) success — 操作是否成功。
	-- @return (string | nil) err — 发生错误时的错误字符串。
	write: function(self: File, data: FileData, size?: integer): boolean | nil, string | nil

	-- 将文件中所有缓冲的写入数据刷新到磁盘。
	-- @return (boolean or nil) 文件是否成功将任何缓冲数据刷新到磁盘。
	-- @return (string or nil) 错误字符串，如果发生错误并且文件无法刷新。
	flush: function(self: File): boolean | nil, string | nil

	-- 获取是否已到达文件结尾。
	-- @return (boolean) 是否已到达EOF。
	isEOF: function(self: File): boolean

	-- 返回文件中的位置。
	-- @return (number or nil) 当前位置。
	tell: function(self: File): number | nil, string | nil

	-- 查找文件中的位置
	-- @param position (number) 寻求
	-- @return (boolean) 操作是否成功
	seek: function(self: File, position: number): boolean

	-- 迭代文件中的所有行。
	-- @return (function or string or nil) 迭代器（可用于 for 循环）。
	lines: function(self: File): function(): string | nil

	-- 设置为写入或追加而打开的文件的缓冲模式。启用缓冲的文件在达到缓冲区大小限制之前不会将数据写入磁盘，具体取决于缓冲模式。
	-- File:flush 将强制将所有缓冲数据写入磁盘。
	-- @param mode (BufferMode) 要使用的缓冲模式。
	-- @param size (integer) 文件缓冲区的最大大小（以字节为单位）。 （默认值：0。）
	-- @return (boolean) 缓冲模式是否设置成功。
	setBuffer: function(self: File, mode: BufferMode, size?: integer): boolean

	-- 获取文件的缓冲模式。
	-- @return (BufferMode) 文件当前的缓冲模式。
	-- @return (integer) 文件缓冲区的最大大小（以字节为单位）。
	getBuffer: function(self: File): BufferMode, integer

	-- 获取打开文件的FileMode。
	-- @return (FileMode) 此文件打开的模式。
	getMode: function(self: File): FileMode

	-- 获取创建 File 对象时使用的文件名。如果文件对象源自 love.filedropped 回调，则文件名将是完整的与平台相关的文件路径。
	-- @return (string) 文件的文件名。
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
	-- 请注意，您只能设置用于存储文件的文件夹名称，而不能设置位置。
	-- @param identity (string) 将用作写入目录的新标识。
	-- @param append_to_path (boolean) append_to_path 参数。
	setIdentity: function(identity: string, append_to_path?: boolean)

	-- 获取游戏的写入目录名称。
	-- 请注意，这仅返回存储文件的文件夹的名称，而不是完整路径。
	-- @return (string) 用作写入目录的标识。
	getIdentity: function(): string

	-- 返回 .love 文件或目录的完整路径。如果游戏融合到 LÖVE 可执行文件，则返回可执行文件。
	-- @return (string) .love 文件或目录的完整平台相关路径。
	getSource: function(): string

	-- 获取指定保存目录的完整路径。
	-- 如果您想使用标准 io 库（或其他库）来
	-- 在保存目录中读取或写入。
	-- @return (string) 保存目录的绝对路径。
	getSaveDirectory: function(): string

	-- 获取当前工作目录。
	-- @return (string) 当前工作目录。
	getWorkingDirectory: function(): string

	-- 返回用户目录
	-- @return (string) 用户目录的路径
	getUserDirectory: function(): string

	-- 返回应用程序数据目录（可能与 getUserDirectory 相同）
	-- @return (string) 应用程序数据目录的路径
	getAppdataDirectory: function(): string

	-- 返回包含 .love 文件的目录的完整路径。如果游戏融合到 LÖVE 可执行文件，则返回包含可执行文件的目录。
	-- 如果 love.filesystem.isFused 为 true，则该函数返回的路径可以传递给 love.filesystem.mount，这将使包含主游戏的目录（例如 C:\Program
	-- Files\coolgame\）可以被 love.filesystem. 读取
	-- @return (string) 包含 .love 文件的目录的完整平台相关路径。
	getSourceBaseDirectory: function(): string
	getExecutablePath: function(): string

	-- 获取包含文件路径的目录的特定于平台的绝对路径。
	-- 这可用于确定文件是否位于保存目录或游戏源.love 内。
	-- 重载说明：
	-- 1. 该函数返回包含给定“'file path'”的目录，而不是文件。例如，如果文件 snapshot1.png 存在于游戏保存目录中名为 snapshots 的目录中，则
	-- love.filesystem.getRealDirectory('screenshots/screenshot1.png') 将返回与 love.filesystem.getSaveDirectory.
	-- @param filename (string) 要获取目录的文件路径。
	-- @return (string or nil) 包含文件路径的目录的特定于平台的完整路径。
	getRealDirectory: function(filename: string): string | nil, string | nil

	-- 获取调用 require 时将搜索的文件系统路径。
	-- 该函数返回的路径字符串是由分号分隔的路径模板序列。传递给 ''require'' will be inserted in place of any question mark ('?') character in each
	-- template (after the dot characters in the argument passed to ''require'' 的参数被目录分隔符替换。）
	-- 路径相对于游戏的源目录和保存目录，以及使用 love.filesystem.mount.
	-- 重载说明：
	-- 1. 默认路径字符串是'?.lua;?/init.lua'，这使得require('cool')尝试加载cool.lua，然后如果cool.lua不存在则尝试cool/init.lua。
	-- @return (string) ''require''函数将在love的文件系统中检查的路径。
	getRequirePath: function(): string

	-- 设置调用 require 时将搜索的文件系统路径。
	-- 提供给此函数的路径字符串是由分号分隔的路径模板序列。传递给 ''require'' will be inserted in place of any question mark ('?') character in each
	-- template (after the dot characters in the argument passed to ''require'' 的参数被目录分隔符替换。）
	-- 路径相对于游戏的源目录和保存目录，以及使用 love.filesystem.mount.
	-- 重载说明：
	-- 1. 默认路径字符串是'?.lua;?/init.lua'，这使得require('cool')尝试加载cool.lua，然后如果cool.lua不存在则尝试cool/init.lua。
	-- @param path (string) ''require''函数将在love的文件系统中检查的路径。
	setRequirePath: function(path: string)

	-- 在游戏的保存目录中安装zip文件或文件夹以供读取。
	--
	-- 如果游戏处于融合模式，也可以挂载love.filesystem.getSourceBaseDirectory。
	-- @param archive (string) 游戏保存目录中要挂载的文件夹或zip文件。
	-- @param mountpoint (string) 存档将安装到的新路径。
	-- @param append_to_path (boolean) 读取已安装存档之前或之后的文件路径时是否搜索存档。这包括游戏的源目录和保存目录。 （默认值：假。）
	-- @return (boolean) success — 如果存档已成功安装，则为 true，否则为 false。
	mount: function(archive: string, mountpoint: string, append_to_path?: boolean): boolean

	-- 在游戏的保存目录中安装zip文件或文件夹以供读取。
	--
	-- 如果游戏处于融合模式，也可以挂载love.filesystem.getSourceBaseDirectory。
	-- @param archive (FileData) 游戏保存目录中要挂载的文件夹或zip文件。
	-- @param mountpoint (string) 存档将安装到的新路径。
	-- @param append_to_path (boolean) 读取已安装存档之前或之后的文件路径时是否搜索存档。这包括游戏的源目录和保存目录。 （默认值：假。）
	-- @return (boolean) success — 如果存档已成功安装，则为 true，否则为 false。
	mount: function(archive: FileData, mountpoint: string, append_to_path?: boolean): boolean

	-- 卸载之前使用 love.filesystem.mount.
	-- @param archive (string) 当前挂载的游戏保存目录中的文件夹或zip文件。
	-- @return (boolean) success — 如果存档已成功卸载，则为 true，否则为 false。
	unmount: function(archive: string): boolean

	-- 卸载之前使用 love.filesystem.mount.
	-- @param archive (FileData) 当前挂载的游戏保存目录中的文件夹或zip文件。
	-- @return (boolean) success — 如果存档已成功卸载，则为 true，否则为 false。
	unmount: function(archive: FileData): boolean

	-- 获取游戏是否处于融合模式。
	-- 如果游戏处于融合模式，其保存目录将直接位于Appdata目录中，而不是Appdata/LOVE/中。游戏还能够加载位于保存目录中的 C Lua 动态库。
	-- 如果源 .love 已融合到可执行文件（请参阅游戏分发），或者在启动游戏时将 '--fused' 作为命令行参数给出，则游戏处于融合模式。
	-- @return (boolean) 如果游戏处于融合模式则为 true，否则为 false。
	isFused: function(): boolean

	-- 创建一个新的文件对象。
	--
	-- 需要打开才可以访问。
	-- @param filename (string) 文件的文件名。
	-- @return (File) file — 新的文件对象。
	newFile: function(filename: string): File

	-- 创建一个新的文件对象。
	--
	-- 需要打开才可以访问。
	-- @param filename (string) 文件的文件名。
	-- @param mode (OpenFileMode) 打开文件的模式。
	-- @return (File) 新的 File 对象，如果发生错误则为 nil。
	newFile: function(filename: string, mode: OpenFileMode): File

	-- 从磁盘上的文件或内存中的字符串创建一个新的 FileData 对象。
	-- @param filename (string) 文件路径。
	-- @return (FileData) data — 新的文件数据。
	newFileData: function(filename: string): FileData

	-- 从磁盘上的文件或内存中的字符串创建一个新的 FileData 对象。
	-- @param file (File) 文件路径。
	-- @return (FileData) 新的 FileData，如果发生错误则为零。
	newFileData: function(file: File): FileData

	-- 从磁盘上的文件或内存中的字符串创建一个新的 FileData 对象。
	-- @param data (string) 要复制到新 FileData 对象中的 Data 对象。
	-- @param filename (string) 文件的名称。当将 FileData 对象传递到 love.audio.newSource.
	-- @return (FileData) 新的 FileData，如果发生错误则为零。
	newFileData: function(data: string, filename: string): FileData

	-- 读取文件的内容。
	-- @param filename (string) 文件的名称（和路径）。
	-- @param size (integer) 读取多少字节。 （默认：全部。）
	-- @return (string | nil) contents — 文件内容。
	-- @return (number | string) size — 已读取多少字节。
	read: function(filename: string, size?: integer): string | nil, number | string

	-- 读取文件的内容。
	-- @param container (string) 返回文件内容的类型。
	-- @param filename (string) 文件的名称（和路径）
	-- @param size (integer) 读取多少字节（默认：全部。）
	-- @return (string | nil) 返回 nil 作为内容。
	-- @return (number | string) size — 已读取多少字节。
	read: function(container: string, filename: string, size?: integer): string | nil, number | string

	-- 读取文件的内容。
	-- @param container (string) 返回文件内容的类型。
	-- @param filename (string) 文件的名称（和路径）
	-- @param size (integer) 读取多少字节（默认：全部。）
	-- @return (FileData | nil) FileData 或包含文件内容的字符串。
	-- @return (number | string) size — 已读取多少字节。
	read: function(container: string, filename: string, size?: integer): FileData | nil, number | string

	-- 加载 Lua 文件（但不运行它）。
	-- @param filename (string) 文件的名称（和路径）。
	-- @return (function) 加载的块。
	-- @return (string or nil) 文件无法打开时的错误消息。
	load: function(filename: string): function | nil, string | nil

	-- 迭代文件中的行。
	-- @param filename (string) 文件的名称（和路径）
	-- @return (function or string or nil) 迭代文件
	lines: function(filename: string): function(): string | nil

	-- 将数据写入保存目录中的文件。如果该文件已经存在，它将被新内容完全替换。
	-- @param filename (string) 文件的名称（和路径）。
	-- @param data (string) 要写入文件的字符串数据。
	-- @param size (integer) 要写入多少字节。 （默认值：全部。）
	-- @return (boolean) success — 如果操作成功。
	-- @return (string | nil) message — 如果操作不成功，则会出现错误消息。
	write: function(filename: string, data: string, size?: integer): boolean, string | nil

	-- 将数据写入保存目录中的文件。如果该文件已经存在，它将被新内容完全替换。
	-- @param filename (string) 文件的名称（和路径）。
	-- @param data (FileData) 要写入文件的数据对象。
	-- @param size (integer) 要写入多少字节。 （默认值：全部。）
	-- @return (boolean) success — 如果操作成功。
	-- @return (string | nil) message — 如果操作不成功，则会出现错误消息。
	write: function(filename: string, data: FileData, size?: integer): boolean, string | nil

	-- 将数据附加到现有文件。
	-- @param filename (string) 文件的名称（和路径）。
	-- @param data (string) 要附加到文件的字符串数据。
	-- @param size (integer) 要写入多少字节。 （默认值：全部。）
	-- @return (boolean) success — 如果操作成功则为 True，如果有错误则为 nil。
	-- @return (string | nil) errormsg — 失败时的错误消息。
	append: function(filename: string, data: string, size?: integer): boolean, string | nil

	-- 将数据附加到现有文件。
	-- @param filename (string) 文件的名称（和路径）。
	-- @param data (FileData) 要附加到文件的数据对象。
	-- @param size (integer) 要写入多少字节。 （默认值：全部。）
	-- @return (boolean) success — 如果操作成功则为 True，如果有错误则为 nil。
	-- @return (string | nil) errormsg — 失败时的错误消息。
	append: function(filename: string, data: FileData, size?: integer): boolean, string | nil

	-- 获取有关指定文件或目录的信息。
	-- @param filename (string) 要检查的文件或目录路径。
	-- @return (FileInfo | nil) info — 包含有关指定路径的信息的表，如果路径中不存在任何内容，则为零。该表包含以下字段：
	getInfo: function(filename: string): FileInfo | nil

	-- 获取有关指定文件或目录的信息。
	-- @param filename (string) 要检查的文件或目录路径。
	-- @param filter_type (FileType) 如果给定路径中的项目与指定的文件类型匹配，则导致 getInfo 仅返回信息表。
	-- @return (FileInfo | nil) 作为参数给出的表，如果路径中不存在任何内容，则为 nil。该表将填写以下字段：
	getInfo: function(filename: string, filter_type: FileType): FileInfo | nil
	exists: function(filename: string): boolean
	isDirectory: function(filename: string): boolean
	isFile: function(filename: string): boolean
	isSymlink: function(filename: string): boolean
	getLastModified: function(filename: string): number | nil, string | nil
	getSize: function(filename: string): number | nil, string | nil

	-- 递归创建一个目录。
	-- 当使用 'a/b' 调用时，它会创建 'a' 和 'a/b'（如果它们尚不存在）。
	-- @param name (string) 要创建的目录。
	-- @return (boolean) 如果目录已创建则为 True，否则为 false。
	createDirectory: function(name: string): boolean, string | nil

	-- 删除文件或空目录。
	-- 重载说明：
	-- 1. 删除前目录必须为空，否则会失败。只需事先删除目录中的所有文件和文件夹即可。如果文件存在于 .love 但不存在于保存目录中，它也会返回 false。打开的文件会阻止删除底层文件。只需关闭文件即可将其删除。
	-- @param name (string) 要删除的文件或目录。
	-- @return (boolean) 如果文件/目录被删除则为 true，否则为 false。
	remove: function(name: string): boolean, string | nil

	-- 返回一个表，其中包含指定路径中的文件和子目录的名称。该表未以任何方式排序；顺序未定义。
	-- 如果传递给函数的路径存在于游戏和保存目录中，它将列出两个地方的文件和目录。
	-- @param directory (string) 目录。
	-- @return ({string}) 以字符串形式包含所有文件和子目录名称的序列。
	getDirectoryItems: function(directory?: string): {string}
end

local type QuitCallback = function(): boolean | nil

-- 提供用户键盘的接口。
local record Keyboard

	-- 启用或禁用 love.keypressed. 的按键重复 默认情况下禁用。
	-- 重载说明：
	-- 1. 重复之间的间隔取决于用户的系统设置。此函数不会影响按住某个键时是否多次调用 love.textinput 。
	-- @param enabled (boolean) 按住某个键时是否应启用重复按键事件。
	setKeyRepeat: function(enabled: boolean)

	-- 获取是否启用按键重复。
	-- @return (boolean) 是否启用按键重复。
	hasKeyRepeat: function(): boolean

	-- 检查某个键是否按下。不要与 love.keypressed 或 love.keyreleased.
	-- @param keys (string...) 包含要检查的键的表。
	-- @return (boolean) down — 如果按键按下则为 True，否则为 false。
	isDown: function(keys: string...): boolean

	-- 检查某个键是否按下。不要与 love.keypressed 或 love.keyreleased.
	-- @param keys ({string}) 包含要检查的键的表。
	-- @return (boolean) down — 如果按键按下则为 True，否则为 false。
	isDown: function(keys: {string}): boolean

	-- 检查指定的扫描码是否被按下。不要与 love.keypressed 或 love.keyreleased.
	--
	-- 与常规的 KeyConstants 不同，扫描码与键盘布局无关。如果按下与美式键盘上的 'w' 键相同位置的键，则使用扫描码 'w'，无论该键的标签是什么或用户的操作系统设置是什么。
	-- @param scancodes (string...) 要检查的扫描码。
	-- @return (boolean) down — 如果提供的任何扫描码已关闭，则为 True，否则为 false。
	isScancodeDown: function(scancodes: string...): boolean

	-- 检查指定的扫描码是否被按下。不要与 love.keypressed 或 love.keyreleased.
	--
	-- 与常规的 KeyConstants 不同，扫描码与键盘布局无关。如果按下与美式键盘上的 'w' 键相同位置的键，则使用扫描码 'w'，无论该键的标签是什么或用户的操作系统设置是什么。
	-- @param scancodes ({string}) 要检查的扫描码。
	-- @return (boolean) down — 如果提供的任何扫描码已关闭，则为 True，否则为 false。
	isScancodeDown: function(scancodes: {string}): boolean

	-- 获取给定按键对应的硬件扫描码。
	-- 与按键常量不同，扫描码与键盘布局无关。例如，如果按下与美式键盘上的 'w' 键相同位置的键，则无论该键的标签是什么或用户的操作系统设置是什么，都会生成扫描码 'w' 。
	-- 扫描码对于创建在所有系统上具有相同物理位置的默认控件非常有用。
	-- @param key (string) 获取扫描码的密钥。
	-- @return (string) 与给定键对应的扫描码，如果给定键在当前系统上没有已知的物理表示，则为 'unknown' 。
	getScancodeFromKey: function(key: string): string

	-- 获取与给定硬件扫描码对应的密钥。
	-- 与按键常量不同，扫描码与键盘布局无关。例如，如果按下与美式键盘上的 'w' 键相同位置的键，则无论该键的标签是什么或用户的操作系统设置是什么，都会生成扫描码 'w' 。
	-- 扫描码对于创建在所有系统上具有相同物理位置的默认控件非常有用。
	-- @param scancode (string) 用于获取密钥的扫描码。
	-- @return (string) 与给定扫描码相对应的键，如果扫描码未映射到当前系统上的 KeyConstant，则为 'unknown' 。
	getKeyFromScancode: function(scancode: string): string

	-- 启用或禁用文本输入事件。它在 Windows、Mac 和 Linux 上默认启用，在 iOS 和 Android 上默认禁用。
	--
	-- 在触摸设备上，这会在启用时显示系统的本机屏幕键盘。
	-- @param enabled (boolean) 是否应启用文本输入事件。
	setTextInput: function(enabled: boolean)

	-- 启用或禁用文本输入事件。它在 Windows、Mac 和 Linux 上默认启用，在 iOS 和 Android 上默认禁用。
	--
	-- 在触摸设备上，这会在启用时显示系统的本机屏幕键盘。
	-- @param enabled (boolean) 是否应启用文本输入事件。
	-- @param x (number) 文本矩形 x 位置。
	-- @param y (number) 文本矩形 y 位置。
	-- @param width (number) 文本矩形宽度。
	-- @param height (number) 文本矩形高度。
	setTextInput: function(enabled: boolean, x: number, y: number, width: number, height: number)

	-- 获取是否启用文本输入事件。
	-- @return (boolean) 是否启用文本输入事件。
	hasTextInput: function(): boolean

	-- 获取是否支持屏幕键盘。
	-- @return (boolean) 是否支持屏幕键盘。
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
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Cursor): boolean

	-- 获取光标的类型。
	-- @return (CursorType) 光标的类型。
	getType: function(self: Cursor): CursorType

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Cursor): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Cursor, type_name: string): boolean
end

-- 提供用户鼠标的接口。
local record Mouse

	-- 返回鼠标的当前位置。
	-- @return (number) 鼠标沿 x 轴的位置。
	-- @return (number) 鼠标沿 y 轴的位置。
	getPosition: function(): number, number

	-- 返回鼠标当前的 x 位置。
	-- @return (number) 鼠标沿 x 轴的位置。
	getX: function(): number

	-- 返回鼠标当前的 y 位置。
	-- @return (number) 鼠标沿 y 轴的位置。
	getY: function(): number

	-- 设置鼠标的当前位置。非整数值被下限。
	-- @param x (number) 鼠标沿 x 轴的新位置。
	-- @param y (number) 鼠标沿 y 轴的新位置。
	setPosition: function(x: number, y: number)

	-- 设置鼠标当前的 X 位置。
	-- 非整数值被下限。
	-- @param x (number) 鼠标沿 x 轴的新位置。
	setX: function(x: number)

	-- 设置鼠标当前的 Y 位置。
	-- 非整数值被下限。
	-- @param y (number) 鼠标沿 y 轴的新位置。
	setY: function(y: number)

	-- 检查某个鼠标按钮是否按下。
	--
	-- 该函数不检测鼠标滚轮滚动；您必须使用 love.wheelmoved （或 0.9.2 及更早版本中的 love.mousepressed ）回调。
	-- @param buttons (number...) 要检查的按钮的索引。 1 是鼠标主按钮，2 是鼠标辅助按钮，3 是中间按钮。其他按钮取决于鼠标。
	-- @return (boolean) down — 如果任何指定的按钮被按下，则为真。
	isDown: function(buttons: number...): boolean

	-- 检查某个鼠标按钮是否按下。
	--
	-- 该函数不检测鼠标滚轮滚动；您必须使用 love.wheelmoved （或 0.9.2 及更早版本中的 love.mousepressed ）回调。
	-- @param buttons ({number}) 要检查的按钮的索引。 1 是鼠标主按钮，2 是鼠标辅助按钮，3 是中间按钮。其他按钮取决于鼠标。
	-- @return (boolean) down — 如果任何指定的按钮被按下，则为真。
	isDown: function(buttons: {number}): boolean

	-- 设置光标的当前可见性。
	-- @param visible (boolean) true 将光标设置为可见， false 将隐藏光标。
	setVisible: function(visible: boolean)

	-- 检查光标是否可见。
	-- @return (boolean) 如果光标可见则为 true，如果光标隐藏则为 false。
	isVisible: function(): boolean

	-- 抓住鼠标并将其限制在窗口内。
	-- @param grabbed (boolean) True 限制鼠标，False 让它离开窗口。
	setGrabbed: function(grabbed: boolean)

	-- 检查鼠标是否被抓住。
	-- @return (boolean) 如果光标被抓取则为 true，否则为 false。
	isGrabbed: function(): boolean

	-- 设置鼠标是否启用相对模式。
	-- 当启用相对模式时，光标被隐藏，并且在鼠标移动时不会移动，但仍然通过 love.mousemoved. 生成相对鼠标运动事件，这使得鼠标可以无限期地向任何方向移动，而光标不会卡在屏幕边缘。
	-- 在启用相对模式时，即使生成了相对鼠标运动事件，报告的鼠标位置也可能不会更新。
	-- @param relative (boolean) true 则启用相对模式， false 则禁用它。
	setRelativeMode: function(relative: boolean): boolean

	-- 获取鼠标是否启用相对模式。
	-- 如果启用相对模式，光标将被隐藏，并且在鼠标移动时不会移动，但仍然通过 love.mousemoved. 生成相对鼠标运动事件，这使鼠标可以无限期地向任何方向移动，而光标不会卡在屏幕边缘。
	-- 在启用相对模式时，即使生成了相对鼠标运动事件，报告的鼠标位置也不会更新。
	-- @return (boolean) 如果启用相对模式则为 True，如果禁用则为 false。
	getRelativeMode: function(): boolean

	-- 从图像文件或 ImageData 创建新的硬件 Cursor 对象。
	-- 硬件光标与帧速率无关，并且与普通操作系统光标的工作方式相同。与在鼠标的当前坐标处绘制图像不同，即使在低帧速率下，硬件光标在鼠标移动和光标位置更新之间也不会出现明显的滞后。
	-- 热点是操作系统用来确定单击的内容以及鼠标光标所在位置的点。例如，普通箭头指针通常将其热点放在图像的左上角，但十字光标可能将其放在中间。
	-- @param image (ImageData or FileData or string) 用于新 Cursor 的 ImageData。根据重载：用于新光标的图像路径。取决于重载：表示用于新光标的图像的数据。
	-- @param hot_x (integer) 光标热点的 ImageData 中的 x 坐标。 （默认值：0。）取决于重载：光标热点图像中的 x 坐标。 （默认值：0。）
	-- @param hot_y (integer) 光标热点的 ImageData 中的 y 坐标。 （默认值：0。）取决于过载：光标热点图像中的 y 坐标。 （默认值：0。）
	-- @return (Cursor) 新的 Cursor 对象。
	newCursor: function(image: ImageData | FileData | string, hot_x?: integer, hot_y?: integer): Cursor

	-- 获取表示系统本机硬件光标的 Cursor 对象。
	-- 硬件光标与帧速率无关，并且与普通操作系统光标的工作方式相同。与在鼠标的当前坐标处绘制图像不同，即使在低帧速率下，硬件光标在鼠标移动和光标位置更新之间也不会出现明显的滞后。
	-- 重载说明：
	-- 1. 'image' CursorType 不是有效参数。使用 love.mouse.newCursor 使用自定义图像创建硬件光标。
	-- @param cursor_type (SystemCursor) 要获取的系统光标的类型。
	-- @return (Cursor) 表示系统游标类型的 Cursor 对象。
	getSystemCursor: function(cursor_type: SystemCursor): Cursor

	-- 设置当前鼠标光标。
	setCursor: function()

	-- 设置当前鼠标光标。
	-- @param cursor (Cursor) 用作当前鼠标光标的 Cursor 对象。
	setCursor: function(cursor: Cursor)

	-- 获取当前光标。
	-- @return (Cursor or nil) 当前光标，如果未设置光标则为零。
	getCursor: function(): Cursor | nil

	-- 获取是否支持光标功能。
	-- 如果不支持，调用 love.mouse.newCursor 和 love.mouse.getSystemCursor 会出错。移动设备不支持光标。
	-- @return (boolean) 系统是否有光标功能。
	isCursorSupported: function(): boolean
end

-- 提供用户时钟的接口。
local record Timer

	-- 测量两帧之间的时间。
	-- 调用此函数会更改 love.timer.getDelta.
	-- @return (number) 过去的时间（以秒为单位）。
	step: function(): number

	-- 返回最后两帧之间的时间。
	-- @return (number) 过去的时间（以秒为单位）。
	getDelta: function(): number

	-- 返回当前每秒帧数。
	-- @return (integer) 当前的 FPS。
	getFPS: function(): integer

	-- 返回最后一秒的平均增量时间（每帧秒数）。
	-- @return (number) 最后一秒的平均增量时间。
	getAverageDelta: function(): number

	-- 将当前线程暂停指定的时间。
	-- @param seconds (number) 还需要睡觉几秒。
	sleep: function(seconds: number)

	-- 返回未指定起始时间的计时器的值。
	-- 该函数只能用于计算时间点之间的差异，因为计时器的启动时间未知。
	-- @return (number) 时间以秒为单位。以十进制形式给出，精确到微秒。
	getTime: function(): number
end

-- 提供对有关用户系统的信息的访问。
local record System

	-- 获取当前操作系统。一般来说，LÖVE 抽象了了解当前操作系统的需要，但在某些情况下它可能很有用（特别是与 os.execute 结合使用。）
	-- 重载说明：
	-- 1. 在LÖVE 0.8.0 版本中，“'love._os'”字符串包含当前操作系统。
	-- @return (string) 当前操作系统。 'OS X'、'Windows'、'Linux'、'Android' 或 'iOS'。
	getOS: function(): string

	-- 获取系统中逻辑处理器的数量。
	-- 重载说明：
	-- 1. 该数字包括启用英特尔超线程等技术时报告的线程数。例如，在具有超线程的 4 核 CPU 上，此函数将返回 8。
	-- @return (integer) 逻辑处理器的数量。
	getProcessorCount: function(): integer

	-- 将文本放入剪贴板。
	-- @param text (string) 要保存在系统剪贴板中的新文本。
	setClipboardText: function(text: string)

	-- 从剪贴板获取文本。
	-- @return (string) 当前保存在系统剪贴板中的文本。
	getClipboardText: function(): string

	-- 获取有关系统电源的信息。
	-- @return (string) 电源的基本状态。
	-- @return (integer or nil) 剩余电池寿命百分比，介于 0 和 100 之间。如果无法确定该值或没有电池，则为零。
	-- @return (integer or nil) 电池寿命还剩几秒。如果无法确定该值或没有电池，则为零。
	getPowerInfo: function(): string, integer | nil, integer | nil

	-- 使用用户的 Web 或文件浏览器打开 URL。
	-- 重载说明：
	-- 1. 在 Android 7.0 (Nougat) 及更高版本中传递 file:// 方案总是会导致失败。在 11.2 之前，这会使 LÖVE 崩溃而不是返回 false。
	-- @param url (string) 要打开的 URL。必须格式化为正确的 URL。
	-- @return (boolean) URL是否打开成功。
	openURL: function(url: string): boolean

	-- 如果可能的话，使设备振动。目前，这仅适用于具有内置振动电机的 Android 和 iOS 设备。
	-- @param seconds (number) 振动的持续时间。如果在iOS设备上调用，由于iOS系统API的限制，它总是会振动0.5秒。 （默认值：0.5。）
	vibrate: function(seconds?: number)

	-- 获取系统上的另一个应用程序是否正在后台播放音乐。
	-- 目前这是在 iOS 和 Android 上实现的，并且在其他操作系统上将始终返回 false。 love.conf 中的 t.audio.mixwithsystem 标志可用于配置 LÖVE
	-- 打开时是否应播放其他应用程序的背景音频/音乐。
	-- @return (boolean) 如果用户通过另一个应用程序在后台播放音乐，则为 true，否则为 false。
	hasBackgroundMusic: function(): boolean
end

-- 线程是可以与其他线程并行运行的代码块。可以使用 Channel 对象在不同线程之间发送数据。
local record Thread

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Thread): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Thread): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Thread, type_name: string): boolean

	-- 启动线程。
	-- 从0.9.0版本开始，线程可以在执行完成后重新启动。
	-- 重载说明：
	-- 1. 传递给 Thread:start 的参数可以通过“'...'”（可变参数表达式）在线程的主文件中访问。
	-- @param args (any...) 字符串、数字、布尔值、LÖVE 对象或简单表格。
	start: function(self: Thread, args: any...): boolean

	-- 等待线程完成。
	-- 该调用将阻塞，直到线程完成。
	wait: function(self: Thread)

	-- 如果线程产生错误，则从线程中检索错误字符串。
	-- @return (string or nil) 错误消息，如果线程没有引起错误则为零。
	getError: function(self: Thread): string | nil

	-- 返回线程当前是否正在运行。
	-- 未运行的线程可以用Thread:start（重新）启动。
	-- @return (boolean) 如果线程正在运行则为 true，否则为 false。
	isRunning: function(self: Thread): boolean
end

-- 可用于在不同线程之间发送和接收数据的对象。
local record Channel

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Channel): boolean

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Channel): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Channel, type_name: string): boolean

	-- 向线程Channel发送消息。
	-- 有关受支持类型的列表，请参阅变体。
	-- @param value (any) 消息的内容。
	-- @return (number) 可以提供给Channel:hasRead
	push: function(self: Channel, value: any): number

	-- 向线程Channel发送消息并等待线程接受它。
	-- 有关受支持类型的列表，请参阅变体。
	-- @param value (any) 消息的内容。
	-- @param timeout (number) 等待的最长时间。
	-- @return (boolean) 消息是否已成功提供（始终为真）。取决于过载：在超时到期之前消息是否成功提供。
	supply: function(self: Channel, value: any, timeout?: number): boolean

	-- 检索 Channel 消息的值并将其从消息队列中删除。
	-- 如果队列中没有消息，则返回 nil。
	-- @return (any) 消息的内容。
	pop: function(self: Channel): any

	-- 检索 Channel 消息的值并将其从消息队列中删除。
	-- 它会等待消息进入队列，然后返回消息值。
	-- @param timeout (number) 等待的最长时间。
	-- @return (any) 消息的内容。取决于过载：消息的内容或 nil（如果超时）。
	demand: function(self: Channel, timeout?: number): any

	-- 检索 Channel 消息的值，但将其保留在队列中。
	-- 如果队列中没有消息，则返回 nil。
	-- @return (any) 消息的内容。
	peek: function(self: Channel): any

	-- 检索线程 Channel 队列中的消息数。
	-- @return (integer) 队列中的消息数。
	getCount: function(self: Channel): integer

	-- 获取推送的值是否已被弹出或以其他方式从通道中删除。
	-- @param id (number) Channel:push 之前返回的 id 值。
	-- @return (boolean) id 表示的值是否已通过 Channel:pop、Channel:demand 或 Channel:clear 从 Channel 中删除。
	hasRead: function(self: Channel, id: number): boolean

	-- 清除Channel队列中的所有消息。
	clear: function(self: Channel)

	-- 相对于此 Channel 以原子方式执行指定的函数。
	-- 在同一个 Channel 上连续调用多个方法通常很有用。但是，如果多个线程同时调用此 Channel 的方法，则每个线程上的不同调用可能最终会交错（例如，第二个线程的一个或多个调用可能发生在第一个线程的调用之间。）
	-- 此方法通过确保调用该方法的线程在指定函数返回之前具有对 Channel 的独占访问权来避免该问题。
	-- @param callback (any) 要调用的函数，形式为 function(channel, arg1, arg2, ...) end。调用函数时，通道将作为第一个参数传递给该函数。
	-- @param args (any...) 调用给定函数时将收到的附加参数。
	-- @return (any) 给定函数的第一个返回值（如果有）。
	performAtomic: function(self: Channel, callback: any, args: any...): any
end

-- 允许您使用线程。
local record ThreadModule

	-- 从包含 Lua 代码的文件名、字符串或 FileData 对象创建一个新线程。
	-- @param code_or_filename (string or any) 用作源的 Lua 文件的名称。取决于重载：包含用作源的 Lua 代码的 FileData。取决于重载：包含用作源的 Lua 代码的字符串。它的长度至少需要 1024 个字符，或者至少包含一个换行符。
	-- @return (Thread) 尚未启动的新线程。
	newThread: function(code_or_filename: string | any): Thread

	-- 创建一个新的未命名线程通道。
	-- 它们的一种用途是通过命名通道上的 Channel:push 将新的未命名通道传递到其他线程。
	-- @return (Channel) 新的 Channel 对象。
	newChannel: function(): Channel

	-- 创建或检索命名线程通道。
	-- @param name (string) 您要创建或检索的频道的名称。
	-- @return (Channel) 与名称关联的 Channel 对象。
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
	-- @return (string) 字符串类型。
	type: function(self: Source): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Source, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Source): boolean

	-- 创建处于停止状态的源的相同副本。
	-- 静态源将使用显着更少的内存，并且创建它们所需的时间也更少，因此在制作播放相同声音的多个源时应首选此方法。
	-- 重载说明：
	-- 1. 克隆源继承原始源的所有可设置状态，但它们被初始化为停止状态。
	-- @return (Source) 此源的新的相同副本。
	clone: function(self: Source): Source

	-- 开始播放源。
	-- @return (boolean) Source是否能够成功开始播放。
	play: function(self: Source): boolean

	-- 暂停源。
	pause: function(self: Source)

	-- 停止源。
	stop: function(self: Source)

	-- 返回源是否正在播放。
	-- @return (boolean) 如果源正在播放则为 true，否则为 false。
	isPlaying: function(self: Source): boolean

	-- 返回此 Source 是否处于停止状态。此方法是兼容旧版 LÖVE 的废弃接口，仅当 Source 既未播放也未暂停时返回 true。
	isStopped: function(self: Source): boolean
	isPaused: function(self: Source): boolean

	-- 设置源是否应循环。
	-- @param looping (boolean) 如果源应该循环则为 true，否则为 false。
	setLooping: function(self: Source, looping: boolean)

	-- 返回 Source 是否循环。
	-- @return (boolean) 如果源将循环则为 true，否则为 false。
	isLooping: function(self: Source): boolean

	-- 设置源的当前音量。
	-- @param volume (number) 源的音量，其中 1.0 是正常音量。音量不能调高到 1.0 以上。
	setVolume: function(self: Source, volume: number)

	-- 获取源的当前音量。
	-- @return (number) 源的音量，其中 1.0 是正常音量。
	getVolume: function(self: Source): number

	-- 设置源的音高。
	-- @param pitch (number) 以 1 为基距计算。每降低 50% 就等于音高移动 -12 个半音（降低一个八度）。每次加倍等于音高移动 12 个半音（增加一个八度）。零不是合法值。
	setPitch: function(self: Source, pitch: number)

	-- 获取源的当前音高。
	-- @return (number) 音高，其中 1.0 为正常值。
	getPitch: function(self: Source): number

	-- 设置源的当前播放位置。
	-- @param offset (number) 要寻求的位置。
	-- @param unit (string) 位置值的单位。 （默认：'seconds'。）
	seek: function(self: Source, offset: number, unit?: string)

	-- 获取Source 当前的播放位置。
	-- @param unit (string) 返回值的单位类型。 （默认：'seconds'。）
	-- @return (number) 源的当前播放位置。
	tell: function(self: Source, unit?: string): number

	-- 获取源的持续时间。对于流源，它可能并不总是样本准确的，并且如果根本无法确定持续时间，则可能返回 -1。
	-- @param unit (string) 返回值的时间单位。 （默认：'seconds'。）
	-- @return (number) 源的持续时间，如果无法确定则为 -1。
	getDuration: function(self: Source, unit?: string): number

	-- 获取源中的通道数。只有 1 通道（单声道）源可以使用方向和位置效果。
	-- @return (integer) 1 用于单声道，2 用于立体声。
	getChannelCount: function(self: Source): integer
	getChannels: function(self: Source): integer

	-- 获取可排队源中的空闲缓冲区槽数。如果可排队源正在播放，则该值将增加到创建源时所用的数量。如果可排队源停止，它将首先处理其所有内部缓冲区，在这种情况下，该函数将始终返回其创建时所用的数量。
	-- @return (integer) 还有多少个 SoundData 对象可以排队。
	getFreeBufferCount: function(self: Source): integer

	-- 将 SoundData 排队以便在可排队源中播放。
	--
	-- 此方法需要通过 love.audio.newQueueableSource. 创建源
	-- @param data (SoundData) 要排队的数据。 SoundData 的采样率、位深度和通道数必须与 Source 相匹配。
	-- @param length (number) 要排队的字节数。（默认值：全部剩余数据。）
	-- @return (boolean) success — 如果数据已成功排队播放，则为 true；如果没有可用于排队的可用缓冲区，则为 false。
	queue: function(self: Source, data: SoundData, length?: number): boolean

	-- 将 SoundData 排队以便在可排队源中播放。
	--
	-- 此方法需要通过 love.audio.newQueueableSource. 创建源
	-- @param data (SoundData) 要排队的数据。 SoundData 的采样率、位深度和通道数必须与 Source 相匹配。
	-- @param offset (number) 开始排队数据的字节偏移量。
	-- @param length (number) 要排队的字节数。
	-- @return (boolean) success — 如果数据已成功排队播放，则为 true；如果没有可用于排队的可用缓冲区，则为 false。
	queue: function(self: Source, data: SoundData, offset: number, length: number): boolean

	-- 设置源的位置。请注意，这仅适用于单声道（即非立体声）声音文件！
	-- @param x (number) 源的 X 位置。
	-- @param y (number) 源的 Y 位置。
	-- @param z (number) 源的 Z 位置。
	setPosition: function(self: Source, x: number, y: number, z?: number)

	-- 获取源的位置。
	-- @return (number) 源的 X 位置。
	-- @return (number) 源的 Y 位置。
	-- @return (number) 源的 Z 位置。
	getPosition: function(self: Source): number, number, number

	-- 设置源的速度。
	-- 这确实“'not'”改变了源的位置，但让应用程序知道它如何计算多普勒效应。
	-- @param x (number) 速度矢量的 X 部分。
	-- @param y (number) 速度矢量的 Y 部分。
	-- @param z (number) 速度矢量的 Z 部分。
	setVelocity: function(self: Source, x: number, y: number, z?: number)

	-- 获取源的速度。
	-- @return (number) 速度矢量的 X 部分。
	-- @return (number) 速度矢量的 Y 部分。
	-- @return (number) 速度矢量的 Z 部分。
	getVelocity: function(self: Source): number, number, number

	-- 设置源的方向向量。零矢量使源无方向性。
	-- @param x (number) 方向向量的X部分。
	-- @param y (number) 方向向量的Y部分。
	-- @param z (number) 方向向量的 Z 部分。
	setDirection: function(self: Source, x: number, y: number, z?: number)

	-- 获取源的方向。
	-- @return (number) 方向向量的X部分。
	-- @return (number) 方向向量的Y部分。
	-- @return (number) 方向向量的 Z 部分。
	getDirection: function(self: Source): number, number, number

	-- 设置源的定向体积锥体。与 Source:setDirection 一起，锥角允许源的体积根据其方向而变化。
	-- @param inner_angle (number) 与源方向的内角，以弧度为单位。如果听者位于此角度定义的圆锥体内，则源将以正常音量播放。
	-- @param outer_angle (number) 与源方向的外角，以弧度为单位。如果听者位于由内角和外角定义的锥体之间，则源将以正常音量和外音量之间的音量播放。
	-- @param outer_volume (number) 当听者位于内锥角和外锥角之外时源的音量。 （默认值：0。）
	-- @param outer_high_gain (number) outer_high_gain 参数。
	setCone: function(self: Source, inner_angle: number, outer_angle: number, outer_volume?: number, outer_high_gain?: number)

	-- 获取源的定向体积锥体。与 Source:setDirection 一起，锥角允许源的体积根据其方向而变化。
	-- @return (number) 与源方向的内角，以弧度为单位。如果听者位于此角度定义的圆锥体内，则源将以正常音量播放。
	-- @return (number) 与源方向的外角，以弧度为单位。如果听者位于由内角和外角定义的锥体之间，则源将以正常音量和外音量之间的音量播放。
	-- @return (number) 当听者位于内锥角和外锥角之外时源的音量。
	getCone: function(self: Source): number, number, number, number

	-- 设置应用于源的空气吸收量。
	-- 默认情况下，该值设置为 0，这意味着空气吸收效果被禁用。值为 1 将以每米 0.05 dB 的速率对源应用高频衰减。
	-- 空气吸收可以模拟声音在雾气、干燥空气、烟雾气氛等中的传播。它可以用来模拟一个区域内不同地点的不同大气条件。
	-- 重载说明：
	-- 1. iOS 不支持音频空气吸收功能。
	-- @param factor (number) 应用于源的空气吸收量。必须介于 0 和 10 之间。
	setAirAbsorption: function(self: Source, factor: number)

	-- 获取应用于源的空气吸收量。
	-- 默认情况下，该值设置为 0，这意味着空气吸收效果被禁用。值为 1 将以每米 0.05 dB 的速率对源应用高频衰减。
	-- 重载说明：
	-- 1. iOS 不支持音频空气吸收功能。
	-- @return (number) 应用于源的空气吸收量。
	getAirAbsorption: function(self: Source): number

	-- 设置源的音量限制。限制必须是 0 到 1 之间的数字。
	-- @param min_volume (number) 最小音量。
	-- @param max_volume (number) 最大音量。
	setVolumeLimits: function(self: Source, min_volume: number, max_volume: number)

	-- 返回源的音量限制。
	-- @return (number) 最小音量。
	-- @return (number) 最大音量。
	getVolumeLimits: function(self: Source): number, number

	-- 设置源的位置、速度、方向和锥角是相对于听者的还是绝对的。
	-- 默认情况下，所有源都是绝对源，因此相对于爱的坐标系 0, 0 的原点。只有绝对源才会受到听者位置的影响。请注意，位置音频仅适用于单声道（即非立体声）源。
	-- @param relative (boolean) True 使位置、速度、方向和锥角相对于听者，为 false 使它们绝对。 （默认值：假。）
	setRelative: function(self: Source, relative: boolean)

	-- 获取Source 的位置、速度、方向和锥角是否相对于听者。
	-- @return (boolean) 如果位置、速度、方向和锥角是相对于听者的，则为 true；如果是绝对的，则为 false。
	isRelative: function(self: Source): boolean

	-- 设置源的参考距离和最大衰减距离。这些参数与当前的 DistanceModel 相结合，会影响源的音量如何根据距离衰减。
	-- 距离衰减仅适用于基于单声道（而不是立体声）音频的源。
	-- @param reference_distance (number) 新的参考衰减距离。如果当前距离模型被钳位，则这是最小衰减距离。
	-- @param max_distance (number) 新的最大衰减距离。
	setAttenuationDistances: function(self: Source, reference_distance: number, max_distance: number)

	-- 获取源的参考距离和最大衰减距离。这些值与当前的 DistanceModel 相结合，会影响源的音量如何根据距收听者的距离衰减。
	-- @return (number) 当前参考衰减距离。如果当前距离模型被钳制，则这是源不再衰减之前的最小距离。
	-- @return (number) 当前最大衰减距离。
	getAttenuationDistances: function(self: Source): number, number

	-- 设置影响所用距离衰减强度的滚降系数。
	-- 扩展信息和详细公式可以在OpenAL 1.1规范的'3.4. Attenuation By Distance'章节中找到。
	-- @param rolloff (number) 新的滚降因子。
	setRolloff: function(self: Source, rolloff: number)

	-- 返回源的滚降系数。
	-- @return (number) 滚降因子。
	getRolloff: function(self: Source): number

	-- 设置播放源时要应用的低通、高通或带通滤波器。
	-- @return (boolean) success — 过滤器是否成功应用于源。
	setFilter: function(self: Source): boolean

	-- 设置播放源时要应用的低通、高通或带通滤波器。
	-- @param filter (AudioFilterSettings) 用于此源的过滤器设置，具有以下字段：
	-- @return (boolean) success — 过滤器是否成功应用于源。
	setFilter: function(self: Source, filter: AudioFilterSettings): boolean

	-- 获取当前应用于源的过滤器设置。
	-- @param target (AudioFilterSettings) target 参数。
	-- @return (AudioFilterSettings or nil) 用于此源的过滤器设置，如果源没有活动过滤器则为零。该表具有以下字段：
	getFilter: function(self: Source, target?: AudioFilterSettings): AudioFilterSettings | nil

	-- 将音频效果应用于源。
	--
	-- 该效果必须事先使用 love.audio.setEffect.
	-- @param name (string) 之前使用 love.audio.setEffect. 设置的效果名称
	-- @return (boolean) success — 效果是否成功应用于此源。
	setEffect: function(self: Source, name: string): boolean

	-- 将音频效果应用于源。
	--
	-- 该效果必须事先使用 love.audio.setEffect.
	-- @param name (string) 之前使用 love.audio.setEffect. 设置的效果名称
	-- @param enabled (boolean) 是否启用该效果。传入 false 会禁用已激活的效果。（默认值：true。）
	-- @return (boolean) success — 效果是否成功应用于此源。
	setEffect: function(self: Source, name: string, enabled: boolean): boolean

	-- 将音频效果应用于源。
	--
	-- 该效果必须事先使用 love.audio.setEffect.
	-- @param name (string) 之前使用 love.audio.setEffect. 设置的效果名称
	-- @param enabled (AudioFilterSettings) 在效果之前应用的过滤器设置，具有以下字段：
	-- @return (boolean) 效果和滤波器是否成功应用于此源。
	setEffect: function(self: Source, name: string, enabled: AudioFilterSettings): boolean

	-- 获取与特定效果关联的过滤器设置。
	-- 如果应用效果时没有与其关联的滤镜设置，则此函数返回 nil。
	-- @param name (string) 效果的名称。
	-- @param target (AudioFilterSettings) 一个可选的空表，将填充过滤器设置。 （默认值：{}。）
	-- @return (boolean) 与此效果关联的过滤器的设置，如果此源中不存在该效果或没有关联的过滤器，则为零。该表具有以下字段：
	getEffect: function(self: Source, name: string, target?: AudioFilterSettings): boolean, AudioFilterSettings | nil

	-- 获取源的活动效果名称列表。
	-- @return ({string}) 源的活动效果名称列表。
	getActiveEffects: function(self: Source): {string}

	-- 获取源的类型。
	-- @return (string) 源的类型。
	getType: function(self: Source): string
end

-- 表示能够录制声音的音频输入设备。
local record RecordingDevice

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: RecordingDevice): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: RecordingDevice, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: RecordingDevice): boolean

	-- 开始使用此设备录制音频。
	-- 重载说明：
	-- 1. 在调用 RecordingDevice:getData 或 RecordingDevice:stop 之前，内部使用环形缓冲区来存储记录的数据 - 前者会清除缓冲区。如果在调用 getData 或 stop
	-- 之前缓冲区完全填满，则不适合缓冲区的最旧数据将丢失。
	-- @param samples (integer) 记录时在内部环形缓冲区中存储的最大样本数。 RecordingDevice:getData 调用时会清除内部缓冲区。
	-- @param sample_rate (integer) 记录时每秒存储的样本数。 （默认值：8000。）
	-- @param bit_depth (integer) 每个样本的位数。 （默认值：16。）
	-- @param channels (integer) 是否以单声道或立体声录制。大多数麦克风不支持超过 1 个通道。 （默认值：1。）
	-- @return (boolean) 如果设备使用指定参数成功开始录制，则为 true，否则为 false。
	start: function(self: RecordingDevice, samples?: integer, sample_rate?: integer, bit_depth?: integer, channels?: integer): boolean

	-- 停止从此设备录制音频。当前位于设备缓冲区中的任何声音数据都将被返回。
	-- @return (SoundData or nil) 当前在设备缓冲区中的声音数据，如果设备没有录音则为零。
	stop: function(self: RecordingDevice): SoundData | nil

	-- 获取存储在设备内部环形缓冲区中的所有录制音频 SoundData。
	-- 调用此函数时，内部环形缓冲区会被清除，因此再次调用它只会在上次调用后录制音频。如果设备的内部环形缓冲区在调用 getData 之前完全填满，则不适合缓冲区的最旧数据将丢失。
	-- @return (SoundData or nil) 录制的音频数据，如果设备未录制则为零。
	getData: function(self: RecordingDevice): SoundData | nil

	-- 获取当前记录的样本数。
	-- @return (integer) 迄今为止已记录的样本数。
	getSampleCount: function(self: RecordingDevice): integer

	-- 获取当前记录的每秒样本数。
	-- @return (integer) 每秒记录的样本数（采样率）。
	getSampleRate: function(self: RecordingDevice): integer

	-- 获取当前记录的数据中每个样本的位数。
	-- @return (integer) 当前记录的数据中每个样本的位数。
	getBitDepth: function(self: RecordingDevice): integer

	-- 获取当前正在录制的通道数（单声道或立体声）。
	-- @return (integer) 正在录制的通道数（1 个为单声道，2 个为立体声）。
	getChannelCount: function(self: RecordingDevice): integer

	-- 获取录音设备的名称。
	-- @return (string) 设备的名称。
	getName: function(self: RecordingDevice): string

	-- 获取设备当前是否正在录制。
	-- @return (boolean) 如果录音则为 true，否则为 false。
	isRecording: function(self: RecordingDevice): boolean
end

-- 提供一个用用户扬声器产生噪音的接口。
local record Audio

	-- 从文件路径、文件、解码器或声音数据创建新的源。
	--
	-- 从 SoundData 创建的源始终是静态的。
	-- @param filename (string) 音频文件的文件路径。
	-- @param source_type (string) 流式或静态源。
	-- @return (Source) source — 可以播放指定音频的新源。
	newSource: function(filename: string, source_type?: string): Source

	-- 从文件路径、文件、解码器或声音数据创建新的源。
	--
	-- 从 SoundData 创建的源始终是静态的。
	-- @param data (SoundData) 要从中创建源的 SoundData。
	-- @return (Source) 可以播放指定音频的新源。返回音频的SourceType是'static'。
	newSource: function(data: SoundData): Source

	-- 创建一个新的源，可用于使用 Source:queue 实时生成的声音播放。
	-- 重载说明：
	-- 1. 与 Source:queue 一起使用的任何 SoundData 的采样率、位深度和通道数必须与提供给此构造函数的参数相匹配。
	-- @param sample_rate (integer) 播放时每秒的采样数。
	-- @param bit_depth (integer) 每个样本的位数（8 或 16）。
	-- @param channels (integer) 1 用于单声道或 2 用于立体声。
	-- @param buffers (integer) 在任何给定时间可以使用 Source:queue 排队的缓冲区数量。不能大于 64。如果未指定值，则选择合理的默认值 (~8)。 （默认值：0。）
	-- @return (Source) 可与 Source:queue 一起使用的新源。
	newQueueableSource: function(sample_rate: integer, bit_depth: integer, channels: integer, buffers?: integer): Source

	-- 同时播放表中包含的所有源。
	-- @param sources ({Source}) 包含要播放的源的表。
	-- @return (boolean) 是否成功开始播放所有指定的源。
	play: function(sources: {Source}): boolean

	-- 同时播放所有传入的源。
	-- @param sources (Source...) 要播放的源。
	-- @return (boolean) 是否成功开始播放所有指定的源。
	play: function(sources: Source...): boolean

	-- 暂停所有当前活动的源并返回它们。
	-- @return ({Source}) Sources — 包含由此调用暂停的源列表的表。
	pause: function(): {Source}

	-- 暂停表中包含的所有源。
	-- @param sources ({Source}) 包含要暂停的源的表。
	pause: function(sources: {Source})

	-- 暂停所有传入的源。
	-- @param sources (Source...) 要暂停的源。
	pause: function(sources: Source...)

	-- 停止所有当前活动的源。
	stop: function()

	-- 停止表中包含的所有源。
	-- @param sources ({Source}) 包含要停止的源的表。
	stop: function(sources: {Source})

	-- 同时停止所有传入的源。
	-- @param sources (Source...) 要停止的源。
	stop: function(sources: Source...)

	-- 获取当前同时播放的音源数量。
	-- @return (integer) 当前同时播放的音源数量。
	getActiveSourceCount: function(): integer
	getSourceCount: function(): integer

	-- 设置主音量。
	-- @param volume (number) 1.0 为最大值，0.0 为关闭。
	setVolume: function(volume: number)

	-- 返回主卷。
	-- @return (number) 当前主卷
	getVolume: function(): number

	-- 设置系统是否应将音频与系统的音频混合。
	-- @param mix (boolean) true 启用混合， false 禁用它。
	-- @return (boolean) 如果更改成功则为 true，否则为 false。
	setMixWithSystem: function(mix: boolean): boolean

	-- 设置听者的位置，这决定了声音的播放方式。
	-- @param x (number) 听者的 x 位置。
	-- @param y (number) 听者的 y 位置。
	-- @param z (number) 听者的 z 位置。
	setPosition: function(x: number, y: number, z?: number)

	-- 返回听者的位置。请注意，位置音频仅适用于单声道（即非立体声）源。
	-- @return (number) 听者的 X 位置。
	-- @return (number) 听者的 Y 位置。
	-- @return (number) 听者的 Z 位置。
	getPosition: function(): number, number, number

	-- 设置听者的方向。
	-- @param forward_x (number) forward_x 参数。
	-- @param forward_y (number) forward_y 参数。
	-- @param forward_z (number) forward_z 参数。
	-- @param up_x (number) up_x 参数。
	-- @param up_y (number) up_y 参数。
	-- @param up_z (number) up_z 参数。
	setOrientation: function(forward_x: number, forward_y: number, forward_z: number,
		up_x: number, up_y: number, up_z: number)

	-- 返回听者的方向。
	-- @return (number) 收听者方向的前向 x。
	-- @return (number) 向前 y 收听者方向。
	-- @return (number) 收听者方向的正向 z。
	-- @return (number) 听者方向的向上 x。
	-- @return (number) 听者方向的向上 y。
	-- @return (number) 听者方向的 z 上方向。
	getOrientation: function(): number, number, number, number, number, number

	-- 设置听者的速度。
	-- @param x (number) 听者的 X 速度。
	-- @param y (number) 听者的 Y 速度。
	-- @param z (number) 听者的 Z 速度。
	setVelocity: function(x: number, y: number, z?: number)

	-- 返回听者的速度。
	-- @return (number) 听者的 X 速度。
	-- @return (number) 听者的 Y 速度。
	-- @return (number) 听者的 Z 速度。
	getVelocity: function(): number, number, number

	-- 为基于速度的多普勒效应设置全局比例因子。默认比例值为 1。
	-- @param scale (number) 新的多普勒比例因子。小数位数必须大于 0。
	setDopplerScale: function(scale: number)

	-- 获取基于速度的多普勒效应的当前全局比例因子。
	-- @return (number) 当前的多普勒比例因子。
	getDopplerScale: function(): number

	-- 设置距离衰减模型。
	-- @param model (string) 新的距离模型。
	setDistanceModel: function(model: string)

	-- 返回距离衰减模型。
	-- @return (string) 当前距离模型。默认值为 'inverseclamped'。
	getDistanceModel: function(): string

	-- 定义可以应用于源的效果。
	-- 并非所有系统都支持音频效果。使用love.audio.isEffectsSupported进行检查。
	-- @param name (string) 效果的名称。
	-- @param settings (AudioEffectSettings or boolean) 用于此效果的设置，具有以下字段： type: 要使用的效果类型。 volume: 效果的音量。 ...: 特定于效果的设置。请参阅 EffectType 了解可用效果及其相应的设置。
	-- @return (boolean) 效果是否创建成功。取决于过载：效果是否成功禁用。
	setEffect: function(name: string, settings?: AudioEffectSettings | boolean): boolean

	-- 获取与效果关联的设置。
	-- @param name (string) 效果的名称。
	-- @param target (AudioEffectSettings) target 参数。
	-- @return (AudioEffectSettings or nil) 与效果相关的设置。
	getEffect: function(name: string, target?: AudioEffectSettings): AudioEffectSettings | nil

	-- 获取当前启用的效果的名称列表。
	-- @return ({string}) 当前启用的效果名称列表。
	getActiveEffects: function(): {string}

	-- 获取系统支持的最大活动效果数。
	-- @return (integer) 活动效果的最大数量。
	getMaxSceneEffects: function(): integer

	-- 获取系统可以支持的单个源对象中活动效果的最大数量。
	-- 重载说明：
	-- 1. 对于不支持音效的系统，该函数返回0。
	-- @return (integer) 每个源的活动效果的最大数量。
	getMaxSourceEffects: function(): integer

	-- 获取系统上的 RecordingDevices 列表。
	-- 列表中的第一个设备是用户的默认录音设备。如果没有麦克风连接到系统，则该列表可能为空。
	-- iOS 目前不支持录音。
	-- 重载说明：
	-- 1. Android从11.3开始支持录音。但是，使用 Play Store 中的 APK 时不支持。
	-- @return ({RecordingDevice}) 连接的录音设备列表。
	getRecordingDevices: function(): {RecordingDevice}

	-- 获取系统是否支持音效。
	-- 重载说明：
	-- 1. 附带旧版 OpenAL 库的旧版 Linux 发行版可能不支持音频效果。此外，iOS根本不支持音频效果。
	-- @return (boolean) 如果支持效果则为 true，否则为 false。
	isEffectsSupported: function(): boolean
end

-- 物体是具有速度和位置的物体。
local record Body

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Body): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Body, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Body): boolean

	-- 显式地破坏身体以及附着在其上的所有固定装置和关节。
	-- 如果您在调用此函数后尝试使用该对象，将会发生错误。在0.7.2中，当你没有时间等待垃圾回收时，可以使用此函数立即释放对象。
	destroy: function(self: Body)

	-- 获取Body是否被破坏。被毁坏的尸体无法使用。
	-- @return (boolean) 本体是否被破坏。
	isDestroyed: function(self: Body): boolean

	-- 获取身体的位置。
	-- 请注意，这可能不是身体的质心。
	-- @return (number) x 位置。
	-- @return (number) y 位置。
	getPosition: function(self: Body): number, number

	-- 设置主体的位置。
	-- 请注意，这可能不是身体的质心。
	-- 该功能无法唤醒本体。
	-- @param x (number) x 位置。
	-- @param y (number) y 位置。
	setPosition: function(self: Body, x: number, y: number)

	-- 获取身体在世界坐标中的 x 位置。
	-- @return (number) 世界坐标中的 x 位置。
	getX: function(self: Body): number

	-- 设置主体的 x 位置。
	-- 该功能无法唤醒本体。
	-- @param x (number) x 位置。
	setX: function(self: Body, x: number)

	-- 获取身体在世界坐标中的 y 位置。
	-- @return (number) 世界坐标中的 y 位置。
	getY: function(self: Body): number

	-- 设置主体的 y 位置。
	-- 该功能无法唤醒本体。
	-- @param y (number) y 位置。
	setY: function(self: Body, y: number)

	-- 获取身体的位置和角度。
	-- 请注意，该位置可能不是身体的质心。 0 弧度的角度意味着 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成顺时针。
	-- @return (number) 位置的 x 分量。
	-- @return (number) 位置的 y 分量。
	-- @return (number) 以弧度表示的角度。
	getTransform: function(self: Body): number, number, number

	-- 设置主体的位置和角度。
	-- 请注意，该位置可能不是身体的质心。 0 弧度的角度意味着 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成顺时针。
	-- 该功能无法唤醒本体。
	-- @param x (number) 位置的 x 分量。
	-- @param y (number) 位置的 y 分量。
	-- @param angle (number) 以弧度表示的角度。
	setTransform: function(self: Body, x: number, y: number, angle: number)

	-- 获取身体的角度。
	-- 角度以弧度为单位测量。如果需要将其转换为度数，请使用 math.deg。
	-- 0 弧度值表示 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成了“'clockwise'”。
	-- @return (number) 以弧度表示的角度。
	getAngle: function(self: Body): number

	-- 设置主体的角度。
	-- 角度以弧度为单位测量。如果您需要将其从度数转换，请使用 math.rad。
	-- 0 弧度值表示 'looking to the right'。尽管弧度逆时针增加，但 y 轴指向下方，因此从我们的角度来看它变成了“'clockwise'”。
	-- 通过改变角度有可能与另一个物体发生碰撞。
	-- @param angle (number) 以弧度表示的角度。
	setAngle: function(self: Body, angle: number)

	-- 获取 Body 从其质心开始的线速度。
	-- 线速度是“'rate of change of position over time'”。
	-- 如果您需要“'rate of change of angle over time'”，请使用Body:getAngularVelocity。
	-- 如果需要获取与质心不同的点的线速度：
	-- * Body:getLinearVelocityFromLocalPoint 允许您指定本地坐标中的点。
	-- * Body:getLinearVelocityFromWorldPoint 允许您指定世界坐标中的点。
	-- 请参阅 'Essential Mathematics for Games and Interactive Applications' 第 136 页了解本地坐标和世界坐标的定义。
	-- @return (number) 速度矢量的 x 分量
	-- @return (number) 速度矢量的 y 分量
	getLinearVelocity: function(self: Body): number, number

	-- 为主体设置新的线速度。
	-- 该函数不会累积任何东西；自上次调用 World:update 以来先前应用的任何脉冲都将丢失。
	-- @param x (number) 速度矢量的 x 分量。
	-- @param y (number) 速度矢量的 y 分量。
	setLinearVelocity: function(self: Body, x: number, y: number)

	-- 获取Body的角速度。
	-- 角速度是“'rate of change of angle over time'”。
	-- 通过施加扭矩、偏心力/脉冲和角阻尼在 World:update 中进行更改。可以直接用Body:setAngularVelocity设置。
	-- 如果您需要“'rate of change of position over time'”，请使用Body:getLinearVelocity。
	-- @return (number) 以弧度/秒为单位的角速度。
	getAngularVelocity: function(self: Body): number

	-- 设置物体的角速度。
	-- 角速度是“'rate of change of angle over time'”。
	-- 该函数不会累积任何东西；自上次调用 World:update 以来先前应用的任何脉冲都将丢失。
	-- @param velocity (number) 新的角速度，以弧度每秒为单位
	setAngularVelocity: function(self: Body, velocity: number)

	-- 获取Body的线性阻尼。
	-- 线性阻尼是“'rate of decrease of the linear velocity over time'”。没有阻尼且没有外力的运动物体将无限期地继续运动，就像在太空中的情况一样。具有阻尼的运动体会逐渐停止运动。
	-- 阻尼与摩擦不同 - 它们可以一起建模。
	-- @return (number) 线性阻尼值。
	getLinearDamping: function(self: Body): number

	-- 设置主体的线性阻尼
	-- 有关线性阻尼的定义，请参阅Body:getLinearDamping。
	-- 线性阻尼可以取从 0 到无穷大的任何值。不过，建议保持在 0 到 0.1 之间。其他值将使对象看起来 'floaty'（如果启用重力）。
	-- @param damping (number) 新的线性阻尼
	setLinearDamping: function(self: Body, damping: number)

	-- 获取Body的角阻尼
	-- 角度阻尼是“'rate of decrease of the angular velocity over time'”：没有阻尼且没有外力的旋转体将无限期地继续旋转。具有阻尼的旋转体将逐渐停止旋转。
	-- 阻尼与摩擦不同 - 它们可以一起建模。然而，Box2D（和 LOVE）仅提供阻尼。
	-- 阻尼参数应介于 0 和无穷大之间，0 表示无阻尼，无穷大表示完全阻尼。通常您将使用 0 到 0.1 之间的阻尼值。
	-- @return (number) 角度阻尼值。
	getAngularDamping: function(self: Body): number

	-- 设置主体的角度阻尼
	-- 有关角度阻尼的定义，请参阅Body:getAngularDamping。
	-- 角度阻尼可以取从 0 到无穷大的任何值。不过，建议保持在 0 到 0.1 之间。其他值看起来不切实际。
	-- @param damping (number) 新的角度阻尼。
	setAngularDamping: function(self: Body, damping: number)

	-- 获取物体的质量。
	-- 静态物体的质量始终为 0。
	-- @return (number) 身体的质量（以千克为单位）。
	getMass: function(self: Body): number

	-- 设置新的体重。
	-- @param mass (number) 质量，以千克为单位。
	setMass: function(self: Body, mass: number)

	-- 获取物体的转动惯量。
	-- 转动惯量是指使身体旋转的难度。
	-- @return (number) 身体的旋转惯性。
	getInertia: function(self: Body): number

	-- 设置物体的惯性。
	-- @param inertia (number) 新的转动惯量，单位为千克 * 像素平方。
	setInertia: function(self: Body, inertia: number)

	-- 返回质量、中心和转动惯量。
	-- @return (number) 质心的 x 位置。
	-- @return (number) 质心的 y 位置。
	-- @return (number) 身体的质量。
	-- @return (number) 转动惯量。
	getMassData: function(self: Body): number, number, number, number

	-- 覆盖计算的质量数据。
	-- @param center_x (number) 质心的 x 位置。
	-- @param center_y (number) 质心的 y 位置。
	-- @param mass (number) 身体的质量。
	-- @param inertia (number) 转动惯量。
	setMassData: function(self: Body, center_x: number, center_y: number, mass: number, inertia: number)

	-- 通过根据夹具的质量属性重新计算来重置主体的质量。
	resetMassData: function(self: Body)

	-- 返回重力比例因子。
	-- @return (number) 重力比例因子。
	getGravityScale: function(self: Body): number

	-- 为主体设置新的重力比例因子。
	-- @param scale (number) 新的重力比例因子。
	setGravityScale: function(self: Body, scale: number)

	-- 获取本地坐标中的质心位置。
	-- 使用 Body:getWorldCenter 获取世界坐标中的质心。
	-- @return (number) 质心的 x 坐标。
	-- @return (number) 质心的 y 坐标。
	getLocalCenter: function(self: Body): number, number

	-- 获取世界坐标中的质心位置。
	-- 使用 Body:getLocalCenter 获取局部坐标中的质心。
	-- @return (number) 质心的 x 坐标。
	-- @return (number) 质心的 y 坐标。
	getWorldCenter: function(self: Body): number, number

	-- 返回主体旋转是否被锁定。
	-- @return (boolean) 如果身体的旋转被锁定则为 True，否则为 false。
	isFixedRotation: function(self: Body): boolean

	-- 设置物体是否有固定旋转。
	-- 具有固定旋转的物体不会改变它们旋转的速度。调用此函数会导致质量重置。
	-- @param fixed (boolean) 身体是否应该有固定的旋转。
	setFixedRotation: function(self: Body, fixed: boolean)

	-- 返回主体的睡眠状态。
	-- @return (boolean) 如果身体清醒则为真，否则为假。
	isAwake: function(self: Body): boolean

	-- 唤醒身体或使其进入睡眠状态。
	-- @param awake (boolean) 身体睡眠状态。
	setAwake: function(self: Body, awake: boolean)

	-- 返回主体的睡眠行为。
	-- @return (boolean) 如果允许身体睡眠则为 true，否则为 false。
	isSleepingAllowed: function(self: Body): boolean

	-- 设置身体的睡眠行为。如果允许睡觉，休息的身体就会自动睡觉。除非与清醒的身体发生碰撞，否则不会模拟睡眠的身体。请注意，如果地板被拆除，人们最终可能会遇到像漂浮的睡着的身体这样的情况。
	-- @param allowed (boolean) 如果允许身体睡眠则为 true，否则为 false。
	setSleepingAllowed: function(self: Body, allowed: boolean)

	-- 返回模拟中是否主动使用主体。
	-- @return (boolean) 如果主体处于活动状态，则为 True，否则为 false。
	isActive: function(self: Body): boolean

	-- 设置物体在世界中是否活跃。
	-- 不活跃的物体不参与模拟。它不会移动或造成任何碰撞。
	-- @param active (boolean) 身体是否活跃。
	setActive: function(self: Body, active: boolean)

	-- 获取主体的子弹状态。
	-- 有两种方法来检查身体碰撞：
	-- * 世界更新时的位置（默认）
	-- * 使用连续碰撞检测 (CCD)
	-- 默认方法很有效，但是移动速度非常快的物体有时可能会跳过另一个物体而不会产生碰撞。被设置为子弹的物体将使用 CCD。这样效率较低，但保证快速移动时不会跳跃。
	-- 请注意，静态物体（质量为零）始终使用 CCD，因此您的墙壁不会让快速移动的物体穿过，即使它不是子弹。
	-- @return (boolean) 主体的子弹状态。
	isBullet: function(self: Body): boolean

	-- 设置正文的项目符号状态。
	-- 有两种方法来检查身体碰撞：
	-- * 世界更新时的位置（默认）
	-- * 使用连续碰撞检测 (CCD)
	-- 默认方法很有效，但是移动速度非常快的物体有时可能会跳过另一个物体而不会产生碰撞。被设置为子弹的物体将使用 CCD。这样效率较低，但保证快速移动时不会跳跃。
	-- 请注意，静态物体（质量为零）始终使用 CCD，因此您的墙壁不会让快速移动的物体穿过，即使它不是子弹。
	-- @param bullet (boolean) 主体的子弹状态。
	setBullet: function(self: Body, bullet: boolean)

	-- 对身体施加脉冲。
	-- 这使得身体动量瞬间增加。
	-- 冲动将身体推向一个方向。质量较大的物体反应较小。反应“'not'”取决于时间步长，相当于连续施加一个力 1 秒。脉冲最好用于对身体进行一次推力。对于连续推动身体，最好使用 Body:applyForce。
	-- 如果没有给出施加脉冲的位置，它将作用于身体的质心。未指向质心的部分脉冲将导致身体旋转（并且取决于旋转惯性）。
	-- 请注意，脉冲分量和位置必须在世界坐标中给出。
	-- @param x_impulse (number) 脉冲的 x 分量。
	-- @param y_impulse (number) 脉冲的 y 分量。
	-- @param point_x (number) 应用脉冲的 x 位置。
	-- @param point_y (number) 施加脉冲的 y 位置。
	applyLinearImpulse: function(self: Body, x_impulse: number, y_impulse: number, point_x?: number, point_y?: number)

	-- 对物体施加角冲量。这使得身体动量瞬间增加。
	-- 质量越大的物体反应越小。反应“'not'”取决于时间步长，相当于连续施加一个力 1 秒。脉冲最好用于对身体进行一次推力。对于连续推动身体，最好使用 Body:applyForce。
	-- @param impulse (number) 每秒千克平方米的脉冲。
	applyAngularImpulse: function(self: Body, impulse: number)

	-- 对身体施加力。
	-- 力将物体推向一个方向。质量较大的物体反应较小。该反应还取决于施加力的时间长短：由于力在整个时间步长内连续作用，因此短时间步长只会推动身体很短的时间。因此，力最好在多个时间步中使用，以持续推动物体（如重力）。对于与时间步无关的单次推送，最好使用
	-- Body:applyLinearImpulse。
	-- 如果没有给出施加力的位置，它将作用在身体的质心上。不指向质心的部分力将导致身体旋转（并且取决于旋转惯性）。
	-- 请注意，力的分量和位置必须在世界坐标中给出。
	-- @param x_force (number) 要施加的力的 x 分量。
	-- @param y_force (number) 要施加的力的 y 分量。
	-- @param point_x (number) 施加力的 x 位置。
	-- @param point_y (number) 施加力的 y 位置。
	applyForce: function(self: Body, x_force: number, y_force: number, point_x?: number, point_y?: number)

	-- 对主体施加扭矩。
	-- 扭矩就像一种会改变物体角速度（旋转）的力。效果取决于物体的转动惯量。
	-- @param torque (number) 要施加的扭矩。
	applyTorque: function(self: Body, torque: number)

	-- 返回主体的类型。
	-- @return (string) 体型。
	getType: function(self: Body): string

	-- 设置新的身体类型。
	-- @param body_type (string) 新类型。
	setType: function(self: Body, body_type: string)

	-- 将点从本地坐标转换为世界坐标。
	-- @param x (number) 本地坐标中的 x 位置。
	-- @param y (number) 本地坐标中的 y 位置。
	-- @return (number) 世界坐标中的 x 位置。
	-- @return (number) 世界坐标中的 y 位置。
	getWorldPoint: function(self: Body, x: number, y: number): number, number

	-- 将向量从本地坐标转换为世界坐标。
	-- @param x (number) 局部坐标中的向量 x 分量。
	-- @param y (number) 局部坐标中的向量 y 分量。
	-- @return (number) 世界坐标中的向量 x 分量。
	-- @return (number) 世界坐标中的向量 y 分量。
	getWorldVector: function(self: Body, x: number, y: number): number, number

	-- 将多个点从本地坐标转换为世界坐标。
	-- @param x (number) 第一个点的 x 位置。
	-- @param y (number) 第一个点的 y 位置。
	-- @param coordinates (number...) 第二个点的 x 位置。
	-- @return (number...) 第一个点的变换后的 x 位置。
	getWorldPoints: function(self: Body, x: number, y: number, coordinates: number...): number...

	-- 将点从世界坐标转换为本地坐标。
	-- @param x (number) 世界坐标中的 x 位置。
	-- @param y (number) 世界坐标中的 y 位置。
	-- @return (number) 本地坐标中的 x 位置。
	-- @return (number) 本地坐标中的 y 位置。
	getLocalPoint: function(self: Body, x: number, y: number): number, number

	-- 将向量从世界坐标转换为局部坐标。
	-- @param x (number) 世界坐标中的向量 x 分量。
	-- @param y (number) 世界坐标中的向量 y 分量。
	-- @return (number) 局部坐标中的向量 x 分量。
	-- @return (number) 局部坐标中的向量 y 分量。
	getLocalVector: function(self: Body, x: number, y: number): number, number

	-- 将多个点从世界坐标转换为本地坐标。
	-- @param x (number) （参数）第一个点的 x 位置。
	-- @param y (number) （参数）第一个点的 y 位置。
	-- @param coordinates (number...) （参数）第二个点的 x 位置。
	-- @return (number...) （结果）第一个点的变换后的 x 位置。
	getLocalPoints: function(self: Body, x: number, y: number, coordinates: number...): number...

	-- 获取物体上一点的线速度。
	-- 身体上一点的线速度是身体质心的速度加上该点处身体旋转的速度。
	-- 身体上的点必须以世界坐标给出。使用 Body:getLinearVelocityFromLocalPoint 来指定本地坐标。
	-- @param x (number) 测量速度的 x 位置。
	-- @param y (number) 测量速度的 y 位置。
	-- @return (number) (x,y) 点速度的 x 分量。
	-- @return (number) (x,y) 点速度的 y 分量。
	getLinearVelocityFromWorldPoint: function(self: Body, x: number, y: number): number, number

	-- 获取物体上一点的线速度。
	-- 身体上一点的线速度是身体质心的速度加上该点处身体旋转的速度。
	-- 物体上的点必须以本地坐标给出。使用 Body:getLinearVelocityFromWorldPoint 来指定世界坐标。
	-- @param x (number) 测量速度的 x 位置。
	-- @param y (number) 测量速度的 y 位置。
	-- @return (number) (x,y) 点速度的 x 分量。
	-- @return (number) (x,y) 点速度的 y 分量。
	getLinearVelocityFromLocalPoint: function(self: Body, x: number, y: number): number, number

	-- 返回附加到刚体的所有碰撞体。
	-- @return (Fixture[]) 包含刚体所有碰撞体的表。
	getFixtures: function(self: Body): {Fixture}
end

-- 形状是固体二维几何对象，用于处理 love.physics.
local record Shape

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Shape): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Shape, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Shape): boolean

	-- 获取表示形状的字符串。
	-- 此函数对于条件调试绘图很有用。
	-- @return (string) 形状的类型。
	getType: function(self: Shape): string

	-- 获取形状的半径。
	-- @param index (integer) index 参数。
	-- @param x (number) x 参数。
	-- @param y (number) y 参数。
	-- @return (number or number... or boolean or integer or Shape or number or nil) 形状的半径。
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
	-- @return (string) 字符串类型。
	type: function(self: Fixture): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Fixture, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Fixture): boolean

	-- 摧毁灯具。
	destroy: function(self: Fixture)

	-- 获取Fixture是否被破坏。损坏的固定装置不能再使用。
	-- @return (boolean or string) Fixture是否被破坏。
	isDestroyed: function(self: Fixture): boolean
	getType: function(self: Fixture): string

	-- 设置夹具的摩擦力。
	-- 摩擦力决定了形状沿着其他形状 'slide' 时如何反应。低摩擦力表示光滑的表面，如冰，而高摩擦力表示粗糙的表面，如混凝土。范围：0.0 - 1.0。
	-- @param friction (number) 夹具摩擦力。
	setFriction: function(self: Fixture, friction: number)

	-- 返回夹具的摩擦力。
	-- @return (number) 夹具摩擦力。
	getFriction: function(self: Fixture): number

	-- 设置灯具的恢复。
	-- @param restitution (number) 灯具恢复原状。
	setRestitution: function(self: Fixture, restitution: number)

	-- 返回灯具的恢复状态。
	-- @return (number) 灯具恢复原状。
	getRestitution: function(self: Fixture): number

	-- 设置灯具的密度。如果需要立即生效，请调用Body:resetMassData。
	-- @param density (number) 灯具密度，单位为千克每平方米。
	setDensity: function(self: Fixture, density: number)

	-- 返回灯具的密度。
	-- @return (number) 灯具密度，单位为千克每平方米。
	getDensity: function(self: Fixture): number

	-- 设置灯具是否应充当传感器。
	-- 传感器不会引起碰撞响应，但该装置仍会调用开始接触和结束接触世界回调。
	-- @param sensor (boolean) 传感器状态。
	setSensor: function(self: Fixture, sensor: boolean)

	-- 返回夹具是否为传感器。
	-- @return (boolean) 如果夹具是传感器。
	isSensor: function(self: Fixture): boolean

	-- 返回固定装置所连接的主体。
	-- @return (Body) 父体。
	getBody: function(self: Fixture): Body

	-- 返回夹具的形状。该形状是对模拟中使用的实际数据的参考。可以在时间步之间更改其值。
	-- @return (Shape) 灯具的形状。
	getShape: function(self: Fixture): Shape

	-- 检查点是否位于夹具形状内部。
	-- @param x (number) 点的 x 位置。
	-- @param y (number) 点的 y 位置。
	-- @return (boolean) 如果该点在内部，则为 True；如果在外部，则为 false。
	testPoint: function(self: Fixture, x: number, y: number): boolean

	-- 将光线投射到夹具的形状上，并返回表面法线向量和光线击中的线位置。如果光线错过了形状，则返回 nil。
	-- 射线从输入线的第一个点开始，朝向该线的第二个点。第五个参数是光线将行进的最大距离，作为输入线长度的比例因子。
	-- childIndex 参数用于指定父形状（例如 ChainShape）的哪个子形状将进行光线投射。对于 ChainShapes，索引 1
	-- 是链上的第一条边。射线投射父形状只会测试指定的子形状，因此如果您想测试父形状的每个形状，则必须循环遍历其所有子形状。
	-- 撞击的世界位置可以通过将线向量乘以第三个返回值并将其与线起点相加来计算。
	-- hitx，hity = x1 + (x2 - x1) * 分数，y1 + (y2 - y1) * 分数
	-- @param x1 (number) 输入线起点的 x 位置。
	-- @param y1 (number) 输入线起点的 y 位置。
	-- @param x2 (number) 输入线终点的 x 位置。
	-- @param y2 (number) 输入线终点的 y 位置。
	-- @param max_fraction (number) 光线长度参数。
	-- @param child_index (integer) 光线投射到的子项的索引。 （默认值：1。）
	-- @return (number or nil) 光线击中形状的边缘的法线向量的 x 分量。
	-- @return (number or nil) 光线照射到形状的边缘的法线向量的 y 分量。
	-- @return (number or nil) 输入线上相交的位置，是线长度的一个因素。
	rayCast: function(self: Fixture, x1: number, y1: number, x2: number, y2: number, max_fraction: number, child_index?: integer): number | nil, number | nil, number | nil

	-- 设置灯具的滤波器数据。
	-- 组、类别和遮罩可用于定义夹具的碰撞行为。
	-- 如果两个灯具位于同一组中，则它们要么在组为正时总是发生碰撞，要么在组为负时从不发生碰撞。如果该组为零或它们不匹配，则接触过滤器将检查灯具是否选择了具有其掩码的其他灯具的类别。如果不是这种情况，灯具就不会发生碰撞。如果他们确实选择了彼此的类别，则将使用自定义联系人过滤器的返回值。如果没有设置，它们总是会发生碰撞。
	-- 最多可以有 16 个类别。类别和掩码被编码为 16 位整数的位。
	-- 创建后，在调用此函数之前，所有灯具的类别设置为 1，掩码设置为 65535（所有类别），组设置为 0。
	-- 此功能允许一次设置灯具的所有过滤器数据。要仅设置类别、掩码或组，可以分别使用 Fixture:setCategory、Fixture:setMask 或 Fixture:setGroupIndex。
	-- @param category_bits (integer) 类别为 0 到 65535 之间的整数。
	-- @param mask_bits (integer) 掩码为 0 到 65535 之间的整数。
	-- @param group_index (integer) 组为从 -32768 到 32767 的整数。
	setFilterData: function(self: Fixture, category_bits: integer, mask_bits: integer, group_index: integer)

	-- 返回灯具的滤波器数据。
	-- 类别和掩码被编码为 16 位整数的位。
	-- @return (integer) 类别为 0 到 65535 之间的整数。
	-- @return (integer) 掩码为 0 到 65535 之间的整数。
	-- @return (integer) 组为从 -32768 到 32767 的整数。
	getFilterData: function(self: Fixture): integer, integer, integer

	-- 设置灯具所属的类别。最多可以有 16 个类别，以 1 到 16 之间的数字表示。
	--
	-- 所有灯具的默认类别为 1。
	-- @param categories ({number}) 类别。
	setCategory: function(self: Fixture, categories: {number})

	-- 设置灯具所属的类别。最多可以有 16 个类别，以 1 到 16 之间的数字表示。
	--
	-- 所有灯具的默认类别为 1。
	-- @param categories (number...) 类别。
	setCategory: function(self: Fixture, categories: number...)

	-- 返回灯具所属的类别。
	-- @return (integer...) 类别。
	getCategory: function(self: Fixture): integer...

	-- 设置灯具的类别掩码。最多可以有 16 个类别，以 1 到 16 之间的数字表示。
	--
	-- 如果其他灯具也选择了该灯具的类别，则该灯具将与所选类别中的灯具发生“'NOT'”碰撞。
	-- @param categories ({number}) 面具。
	setMask: function(self: Fixture, categories: {number})

	-- 设置灯具的类别掩码。最多可以有 16 个类别，以 1 到 16 之间的数字表示。
	--
	-- 如果其他灯具也选择了该灯具的类别，则该灯具将与所选类别中的灯具发生“'NOT'”碰撞。
	-- @param categories (number...) 面具。
	setMask: function(self: Fixture, categories: number...)

	-- 返回该装置应与“'NOT'”碰撞的类别。
	-- @return (integer...) 面具。
	getMask: function(self: Fixture): integer...

	-- 将 Lua 值与固定装置相关联。
	-- 要删除引用，请显式传递 nil。
	-- @param value (any) 与装置关联的Lua值。
	setUserData: function(self: Fixture, value: any)

	-- 返回与该装置关联的Lua值。
	-- @return (any) 与装置关联的Lua值。
	getUserData: function(self: Fixture): any

	-- 返回夹具边界框的点。如果灯具有多个子级，则可以指定从 1 开始的索引。例如，一个固定装置将有多个呈链状的子项。
	-- @param child_index (integer) 夹具的边界框。 （默认值：1。）
	-- @return (number) 左上角点的 x 位置。
	-- @return (number) 左上角点的 y 位置。
	-- @return (number) 右下点的 x 位置。
	-- @return (number) 右下点的 y 位置。
	getBoundingBox: function(self: Fixture, child_index?: integer): number, number, number, number

	-- 返回质量、中心和转动惯量。
	-- @return (number) 质心的 x 位置。
	-- @return (number) 质心的 y 位置。
	-- @return (number) 夹具的质量。
	-- @return (number) 转动惯量。
	getMassData: function(self: Fixture): number, number, number, number

	-- 返回灯具所属的组。如果该组为正，则具有同一组的灯具将始终发生碰撞；如果该组为负，则永远不会发生碰撞。组零表示没有组。
	-- 组范围从 -32768 到 32767。
	-- @return (integer) 灯具组。
	getGroupIndex: function(self: Fixture): integer

	-- 设置灯具所属的组。如果该组为正，则具有同一组的灯具将始终发生碰撞；如果该组为负，则永远不会发生碰撞。组零表示没有组。
	-- 组范围从 -32768 到 32767。
	-- @param index (integer) 组为从 -32768 到 32767 的整数。
	setGroupIndex: function(self: Fixture, index: integer)
end

-- 联系人是为了管理世界中的碰撞而创建的对象。
local record Contact

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Contact): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Contact, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Contact): boolean
	isValid: function(self: Contact): boolean

	-- 获取保持接触形状的两个夹具。
	-- @return (Fixture) 第一个装置。
	-- @return (Fixture) 第二场比赛。
	getFixtures: function(self: Contact): Fixture, Fixture

	-- 获取两个碰撞灯具形状的子索引。对于 ChainShapes，索引 1 是链中的第一条边。与 Fixture:rayCast 或 ChainShape:getChildEdge 一起使用。
	-- @return (integer) 第一个灯具形状的子索引。
	-- @return (integer) 第二个灯具形状的子索引。
	getChildren: function(self: Contact): integer, integer

	-- 返回两个碰撞夹具的接触点。可以有一个或两个点。
	-- @return (number...) 第一个接触点的 x 坐标。
	getPositions: function(self: Contact): number...

	-- 获取两个接触形状之间的法向量。
	-- 该函数返回从第一个形状指向第二个形状的单位向量的坐标。
	-- @return (number) 法线向量的 x 分量。
	-- @return (number) 法向量的 y 分量。
	getNormal: function(self: Contact): number, number

	-- 获取两个接触形状之间的摩擦力。
	-- @return (number) 接触的摩擦力。
	getFriction: function(self: Contact): number

	-- 设置接触摩擦力。
	-- @param friction (number) 接触摩擦力。
	setFriction: function(self: Contact, friction: number)

	-- 将接触摩擦重置为两个夹具的混合值。
	resetFriction: function(self: Contact)

	-- 获取两个接触形状之间的恢复。
	-- @return (number) 两个形状之间的恢复。
	getRestitution: function(self: Contact): number

	-- 设置接触恢复。
	-- @param restitution (number) 联系人恢复原状。
	setRestitution: function(self: Contact, restitution: number)

	-- 将接触恢复重置为两个灯具的混合值。
	resetRestitution: function(self: Contact)

	-- 返回联系人是否已启用。如果在 preSolve 回调中禁用了接触，则碰撞将被忽略。
	-- @return (boolean) 如果启用则为 true，否则为 false。
	isEnabled: function(self: Contact): boolean

	-- 启用或禁用联系人。
	-- @param enabled (boolean) True 表示启用，False 表示禁用。
	setEnabled: function(self: Contact, enabled: boolean)

	-- 返回两个碰撞的装置是否相互接触。
	-- @param speed (number) speed 参数。
	-- @return (boolean or number) 如果它们接触则为真，否则为假。
	isTouching: function(self: Contact): boolean
	getTangentSpeed: function(self: Contact): number
	setTangentSpeed: function(self: Contact, speed: number)
end

-- 世界是一个包含所有身体和关节的对象。
local record World

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: World): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: World, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: World): boolean

	-- 毁灭世界，带走所有的身体、关节、固定装置及其形状。
	-- 如果您在调用此函数后尝试使用任何已销毁的对象，将会发生错误。
	destroy: function(self: World)

	-- 获取世界是否被毁灭。被摧毁的世界无法使用。
	-- @return (boolean) 世界是否毁灭。
	isDestroyed: function(self: World): boolean

	-- 返回世界中的所有刚体。
	-- @return (Body[]) 包含世界中所有刚体的表。
	getBodies: function(self: World): {Body}

	-- 更新世界状况。
	-- @param delta_time (number) 推进物理模拟的时间（以秒为单位）。
	-- @param velocity_iterations (integer) 解决碰撞时用于确定新速度的最大步数。 （默认值：8。）
	-- @param position_iterations (integer) 解决碰撞时用于确定新位置的最大步数。 （默认值：3。）
	update: function(self: World, delta_time: number, velocity_iterations?: integer, position_iterations?: integer)

	-- 设置世界的重力。
	-- @param x (number) 重力的 x 分量。
	-- @param y (number) 重力的 y 分量。
	setGravity: function(self: World, x: number, y: number)

	-- 获取世界的重力。
	-- @return (number) 重力的 x 分量。
	-- @return (number) 重力的 y 分量。
	getGravity: function(self: World): number, number

	-- 设置世界的睡眠行为。
	-- @param allowed (boolean) 如果世界上的物体被允许睡觉，则为真，否则为假。
	setSleepingAllowed: function(self: World, allowed: boolean)

	-- 获取世界的睡眠行为。
	-- @return (boolean) 如果世界上的物体被允许睡觉，则为真，否则为假。
	isSleepingAllowed: function(self: World): boolean

	-- 通过搜索任何重叠的边界框 (Fixture:getBoundingBox)，为指定区域内的每个灯具调用函数。
	-- @param x1 (number) 左上角点的 x 位置。
	-- @param y1 (number) 左上角点的 y 位置。
	-- @param x2 (number) 右下点的 x 位置。
	-- @param y2 (number) 右下点的 y 位置。
	-- @param callback (function) 该函数传递一个参数，即固定装置，并且应该返回一个布尔值。如果为 true，则继续搜索；如果为 false，则停止搜索。
	queryBoundingBox: function(self: World, x1: number, y1: number, x2: number, y2: number, callback: function(any): boolean)

	-- 投射光线并为其相交的每个灯具调用函数。
	-- 重载说明：
	-- 1. LÖVE 0.8.0 中有一个错误，传递给回调函数的法线向量按 love.physics.getMeter.
	-- @param x1 (number) 射线起点的 x 位置。
	-- @param y1 (number) 射线起点的 x 位置。
	-- @param x2 (number) 射线终点的 x 位置。
	-- @param y2 (number) 形状边缘的表面法线向量的 x 值。
	-- @param callback (function) 为与光线相交的每个夹具调用的函数。该函数有六个参数，并应返回一个数字作为控制值。输入到函数中的交点将采用任意顺序。如果您希望找到最近的交点，则需要在函数内自行完成。最简单的方法是使用分数值。
	rayCast: function(self: World, x1: number, y1: number, x2: number, y2: number, callback: function(any, number, number, number, number, number): number)

	-- 设置世界更新期间碰撞回调的函数。
	-- 四个 Lua 函数可以作为参数给出。值 nil 删除一个函数。
	-- 调用时，每个函数将传递三个参数。前两个参数是碰撞装置，第三个参数是它们之间的接触。 postSolve 回调还获取每个接触点的法线和切线冲量。参见注释。
	-- 如果您有兴趣了解每个回调的确切调用时间，请参阅 Box2d 手册
	-- @param begin_contact (function) 当两个灯具开始重叠时被调用。
	-- @param end_contact (function) 当两个灯具不再重叠时被调用。当碰撞对象被破坏时，这也会在世界更新之外被调用。
	-- @param pre_solve (function) 在冲突解决之前被调用。 （默认值：无。）
	-- @param post_solve (function) 冲突解决后被调用。 （默认值：无。）
	setCallbacks: function(self: World, begin_contact?: function(any, any, any), end_contact?: function(any, any, any), pre_solve?: function(any, any, any), post_solve?: function(any, any, any, ...: number))

	-- 返回世界更新期间回调的函数。
	-- @param ... (number) ... 参数。
	-- @return (function) 当两个灯具开始重叠时被调用。
	-- @return (function) 当两个灯具不再重叠时被调用。
	-- @return (function) 在冲突解决之前被调用。
	-- @return (function) 冲突解决后被调用。
	getCallbacks: function(self: World): function(any, any, any) | nil, function(any, any, any) | nil, function(any, any, any) | nil, function(any, any, any, ...: number) | nil
end

-- 将多个物体连接在一起以独特的方式进行交互。
local record Joint

	-- 获取字符串形式的对象类型。
	-- @return (string) 字符串类型。
	type: function(self: Joint): string

	-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
	-- @param type_name (string) 要检查的类型的名称。
	-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
	typeOf: function(self: Joint, type_name: string): boolean

	-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
	-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
	-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
	release: function(self: Joint): boolean

	-- 明确摧毁关节。如果您在调用此函数后尝试使用该对象，将会发生错误。
	-- 在0.7.2中，当你没有时间等待垃圾回收时，这个函数
	-- 可用于立即释放对象。
	destroy: function(self: Joint)

	-- 获取关节是否被破坏。损坏的关节无法使用。
	-- @return (boolean) 关节是否被破坏。
	isDestroyed: function(self: Joint): boolean

	-- 获取表示类型的字符串。
	-- @return (string) 带有关节类型名称的字符串。
	getType: function(self: Joint): string

	-- 获取关节所附加的实体。
	-- @return (Body) 第一个身体。
	-- @return (Body) 第二个身体。
	getBodies: function(self: Joint): Body, Body

	-- 获取关节的锚点。
	-- @return (number) 主体 1 上锚点的 x 分量。
	-- @return (number) 主体 1 上锚点的 y 分量。
	-- @return (number) 主体 2 上锚点的 x 分量。
	-- @return (number) 主体 2 上锚点的 y 分量。
	getAnchors: function(self: Joint): number, number, number, number

	-- 返回第二个物体上的反作用力（以牛顿为单位）
	-- @param inverse_delta_time (number) 力作用多长时间。通常为反时间步长或 1/dt。
	-- @return (number) 力的 x 分量。
	-- @return (number) 力的 y 分量。
	getReactionForce: function(self: Joint, inverse_delta_time: number): number, number

	-- 返回第二个物体上的反作用扭矩。
	-- @param inverse_delta_time (number) 力作用多长时间。通常为反时间步长或 1/dt。
	-- @return (number) 第二个物体上的反作用扭矩。
	getReactionTorque: function(self: Joint, inverse_delta_time: number): number

	-- 获取连接的Bodies是否发生碰撞。
	-- @return (boolean) 如果碰撞则为 true，否则为 false。
	getCollideConnected: function(self: Joint): boolean

	-- 将 Lua 值与关节相关联。
	-- 要删除引用，请显式传递 nil。
	-- @param value (any) 与关节关联的 Lua 值。
	setUserData: function(self: Joint, value: any)

	-- 返回与此关节关联的 Lua 值。
	-- @param length (number) length 参数。
	-- @param frequency (number) frequency 参数。
	-- @param ratio (number) ratio 参数。
	-- @param enabled (boolean) enabled 参数。
	-- @param torque (number) torque 参数。
	-- @param speed (number) speed 参数。
	-- @param inverse_delta_time (number) inverse_delta_time 参数。
	-- @param upper (number) upper 参数。
	-- @param lower (number) lower 参数。
	-- @param force (number) force 参数。
	-- @param x (number) x 参数。
	-- @param y (number) y 参数。
	-- @param angle (number) angle 参数。
	-- @param factor (number) factor 参数。
	-- @return (any or number or boolean or Joint) 与关节关联的 Lua 值。
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
	-- 物理模块中的所有坐标都除以该数字并转换为米，它创建了一种将对象直接绘制到屏幕上而不需要图形转换的便捷方法。
	-- 建议创建不大于10倍比例的形状。这很重要，因为 Box2D 经过调整，可以很好地处理 0.1 到 10 米的形状尺寸。默认仪表刻度为 30。
	-- @param scale (number) 整数比例因子。
	setMeter: function(scale: number)

	-- 返回仪表比例因子。
	-- 物理模块中的所有坐标都除以这个数字，创建了一种将对象直接绘制到屏幕上的便捷方法，而无需进行图形转换。
	-- 建议创建不大于10倍比例的形状。这很重要，因为 Box2D 经过调整，可以很好地处理 0.1 到 10 米的形状尺寸。
	-- @return (number) 整数比例因子。
	getMeter: function(): number

	-- 创造一个新世界。
	-- @param x_gravity (number) 重力的 x 分量。 （默认值：0。）
	-- @param y_gravity (number) 重力的 y 分量。 （默认值：0。）
	-- @param sleep (boolean) 这个世界的身体是否可以睡觉。 （默认值：true。）
	-- @return (World) 美丽的新世界。
	newWorld: function(x_gravity?: number, y_gravity?: number, sleep?: boolean): World

	-- 创建一个新的实体。
	-- 身体分为三种类型。
	-- * 静态物体不移动，具有无限质量，可用于关卡边界。
	-- * 动态物体是模拟中的主要角色，它们与一切物体发生碰撞。
	-- * 运动体不会对力产生反应，只会与动态体发生碰撞。
	-- 连接或移除夹具时会计算主体的质量，但可以随时使用 Body:setMass 或 Body:resetMassData 进行更改。
	-- @param world (World) 创造身体的世界。
	-- @param x (number) 主体的 x 位置。 （默认值：0。）
	-- @param y (number) 主体的 y 位置。 （默认值：0。）
	-- @param body_type (string) 主体的类型。 （默认：'static'。）
	-- @return (Body) 一个新的身体。
	newBody: function(world: World, x?: number, y?: number, body_type?: string): Body

	-- 创建夹具并将其附加到主体。
	-- 请注意，在创建 Fixture 时，Shape 对象被复制而不是保留为引用。要获取 Fixture 拥有的 Shape 对象，请使用 Fixture:getShape。
	-- @param body (Body) 连接固定装置的主体。
	-- @param shape (Shape) 要复制到夹具的形状。
	-- @param density (number) 灯具的密度。 （默认值：1。）
	-- @return (Fixture) 新的固定装置。
	newFixture: function(body: Body, shape: Shape, density?: number): Fixture

	-- 创建一个新的 CircleShape。
	-- @param radius (number) 圆的半径。
	-- @return (CircleShape) shape — 新形状。
	newCircleShape: function(radius: number): CircleShape

	-- 创建一个新的 CircleShape。
	-- @param x (number) 圆的 x 位置。
	-- @param y (number) 圆的 y 位置。
	-- @param radius (number) 圆的半径。
	-- @return (CircleShape) shape — 新形状。
	newCircleShape: function(x: number, y: number, radius: number): CircleShape

	-- 创建矩形 PolygonShapes 的简写。
	--
	-- 默认情况下，本地原点位于矩形的“'center'”，而不是图形的左上角。
	-- @param width (number) 矩形的宽度。
	-- @param height (number) 矩形的高度。
	-- @return (PolygonShape) shape — 一个新的多边形形状。
	newRectangleShape: function(width: number, height: number): PolygonShape

	-- 创建矩形 PolygonShapes 的简写。
	--
	-- 默认情况下，本地原点位于矩形的“'center'”，而不是图形的左上角。
	-- @param x (number) 沿 x 轴的偏移。
	-- @param y (number) 沿 y 轴的偏移量。
	-- @param width (number) 矩形的宽度。
	-- @param height (number) 矩形的高度。
	-- @param angle (number) 矩形的初始角度。 （默认值：0。）
	-- @return (PolygonShape) shape — 一个新的多边形形状。
	newRectangleShape: function(x: number, y: number, width: number, height: number, angle?: number): PolygonShape

	-- 创建一个新的PolygonShape。
	--
	-- 这个形状最多可以有8个顶点，并且必须形成一个凸形状。
	-- @param points ({number}) 用于构造多边形的顶点列表，格式为{x1, y1, x2, y2, x3, y3, ...}。
	-- @return (PolygonShape) shape — 一个新的多边形形状。
	newPolygonShape: function(points: {number}): PolygonShape

	-- 创建一个新的PolygonShape。
	--
	-- 这个形状最多可以有8个顶点，并且必须形成一个凸形状。
	-- @param points (number...) 用于构造多边形的顶点列表，格式为{x1, y1, x2, y2, x3, y3, ...}。
	-- @return (PolygonShape) shape — 一个新的多边形形状。
	newPolygonShape: function(points: number...): PolygonShape

	-- 创建一个新的 EdgeShape。
	-- @param x1 (number) 第一个点的 x 位置。
	-- @param y1 (number) 第一个点的 y 位置。
	-- @param x2 (number) 第二个点的 x 位置。
	-- @param y2 (number) 第二个点的 y 位置。
	-- @return (Shape) 新形状。
	newEdgeShape: function(x1: number, y1: number, x2: number, y2: number): Shape

	-- 创建一个新的 ChainShape。
	-- @param loop (boolean) 如果链应该循环回到第一个点。
	-- @param points ({number}) 用于构造 ChainShape 的点列表，格式为 {x1, y1, x2, y2, ...}。
	-- @return (ChainShape) shape — 新形状。
	newChainShape: function(loop: boolean, points: {number}): ChainShape

	-- 创建一个新的 ChainShape。
	-- @param loop (boolean) 如果链应该循环回到第一个点。
	-- @param points (number...) 用于构造 ChainShape 的点列表，格式为 {x1, y1, x2, y2, ...}。
	-- @return (ChainShape) shape — 新形状。
	newChainShape: function(loop: boolean, points: number...): ChainShape

	-- 在两个实体之间创建一个 DistanceJoint。
	-- 该关节将两个物体上两点之间的距离限制为恒定。这两个点是在世界坐标中指定的，并且在创建此关节时假定两个主体就位。第一个锚点连接到第一主体，第二个锚点连接到第二主体，并且这些点限定距离关节的长度。
	-- @param body1 (Body) 第一个连接到关节的主体。
	-- @param body2 (Body) 连接到关节的第二个主体。
	-- @param x1 (number) 第一个锚点（世界空间）的 x 位置。
	-- @param y1 (number) 第一个锚点（世界空间）的 y 位置。
	-- @param x2 (number) 第二个锚点（世界空间）的 x 位置。
	-- @param y2 (number) 第二个锚点（世界空间）的 y 位置。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (Joint) 新的距离关节。
	newDistanceJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean): Joint

	-- 在两个实体之间创建枢轴关节。
	--
	-- 这个关节将两个物体连接到一个点，它们可以围绕该点旋转。
	-- @param body1 (Body) 第一具尸体。
	-- @param body2 (Body) 第二具尸体。
	-- @param x (number) 连接点的 x 位置。
	-- @param y (number) 连接点的 y 位置。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (RevoluteJoint) joint — 新的旋转接头。
	newRevoluteJoint: function(body1: Body, body2: Body, x: number, y: number, collide_connected?: boolean): RevoluteJoint

	-- 在两个实体之间创建枢轴关节。
	--
	-- 这个关节将两个物体连接到一个点，它们可以围绕该点旋转。
	-- @param body1 (Body) 第一具尸体。
	-- @param body2 (Body) 第二具尸体。
	-- @param x1 (number) 第一个连接点的 x 位置。
	-- @param y1 (number) 第一个连接点的 y 位置。
	-- @param x2 (number) 第二个连接点的 x 位置。
	-- @param y2 (number) 第二个连接点的 y 位置。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @param reference_angle (number) body1 和 body2 之间的参考角度，以弧度为单位。 （默认值：0。）
	-- @return (RevoluteJoint) joint — 新的旋转接头。
	newRevoluteJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean, reference_angle?: number): RevoluteJoint

	-- 在两个实体之间创建 PrismaticJoint。
	--
	-- 棱柱关节约束两个实体在指定轴上相对移动。它不允许相对旋转。其定义和操作与旋转关节类似，但用平移和力代替角度和扭矩。
	-- @param body1 (Body) 第一个用棱柱关节连接的主体。
	-- @param body2 (Body) 用棱柱关节连接的第二个主体。
	-- @param x (number) 锚点的 x 坐标。
	-- @param y (number) 锚点的 y 坐标。
	-- @param axis_x (number) 轴向量的 x 坐标。
	-- @param axis_y (number) 轴向量的 y 坐标。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (PrismaticJoint) joint — 新的棱柱形关节。
	newPrismaticJoint: function(body1: Body, body2: Body, x: number, y: number, axis_x: number, axis_y: number, collide_connected?: boolean): PrismaticJoint

	-- 在两个实体之间创建 PrismaticJoint。
	--
	-- 棱柱关节约束两个实体在指定轴上相对移动。它不允许相对旋转。其定义和操作与旋转关节类似，但用平移和力代替角度和扭矩。
	-- @param body1 (Body) 第一个用棱柱关节连接的主体。
	-- @param body2 (Body) 用棱柱关节连接的第二个主体。
	-- @param x1 (number) 第一个锚点的 x 坐标。
	-- @param y1 (number) 第一个锚点的 y 坐标。
	-- @param x2 (number) 第二个锚点的 x 坐标。
	-- @param y2 (number) 第二个锚点的 y 坐标。
	-- @param axis_x (number) 轴单位矢量的 x 坐标。
	-- @param axis_y (number) 轴单位矢量的 y 坐标。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @param reference_angle (number) body1 和 body2 之间的参考角度，以弧度为单位。 （默认值：0。）
	-- @return (PrismaticJoint) joint — 新的棱柱形关节。
	newPrismaticJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axis_x: number, axis_y: number, collide_connected?: boolean, reference_angle?: number): PrismaticJoint

	-- 在两个实体之间创建约束关节。 WeldJoint 本质上是将两个实体粘合在一起。然而，由于 Box2D 的迭代求解器，约束有点软。
	-- @param body1 (Body) 第一个连接到关节的主体。
	-- @param body2 (Body) 连接到关节的第二个主体。
	-- @param x (number) 锚点的 x 位置（世界空间）。
	-- @param y (number) 锚点（世界空间）的 y 位置。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (WeldJoint) joint — 新的 WeldJoint。
	newWeldJoint: function(body1: Body, body2: Body, x: number, y: number, collide_connected?: boolean): WeldJoint

	-- 在两个实体之间创建约束关节。 WeldJoint 本质上是将两个实体粘合在一起。然而，由于 Box2D 的迭代求解器，约束有点软。
	-- @param body1 (Body) 第一个连接到关节的主体。
	-- @param body2 (Body) 连接到关节的第二个主体。
	-- @param x1 (number) 第一个锚点（世界空间）的 x 位置。
	-- @param y1 (number) 第一个锚点（世界空间）的 y 位置。
	-- @param x2 (number) 第二个锚点（世界空间）的 x 位置。
	-- @param y2 (number) 第二个锚点（世界空间）的 y 位置。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @param reference_angle (number) body1 和 body2 之间的参考角度，以弧度为单位。 （默认值：0。）
	-- @return (WeldJoint) joint — 新的 WeldJoint。
	newWeldJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean, reference_angle?: number): WeldJoint

	-- 在两个物体之间创建摩擦接头。 FrictionJoint 将摩擦力施加到物体上。
	-- @param body1 (Body) 第一个连接到关节的主体。
	-- @param body2 (Body) 连接到关节的第二个主体。
	-- @param x (number) 锚点的 x 位置。
	-- @param y (number) 锚点的 y 位置。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (FrictionJoint) joint — 新的摩擦关节。
	newFrictionJoint: function(body1: Body, body2: Body, x: number, y: number, collide_connected?: boolean): FrictionJoint

	-- 在两个物体之间创建摩擦接头。 FrictionJoint 将摩擦力施加到物体上。
	-- @param body1 (Body) 第一个连接到关节的主体。
	-- @param body2 (Body) 连接到关节的第二个主体。
	-- @param x1 (number) 第一个锚点的 x 位置。
	-- @param y1 (number) 第一个锚点的 y 位置。
	-- @param x2 (number) 第二个锚点的 x 位置。
	-- @param y2 (number) 第二个锚点的 y 位置。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (FrictionJoint) joint — 新的摩擦关节。
	newFrictionJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, collide_connected?: boolean): FrictionJoint

	-- 在两个实体之间创建关节。它的唯一功能是强制这些实体之间的最大距离。
	-- @param body1 (Body) 第一个连接到关节的主体。
	-- @param body2 (Body) 连接到关节的第二个主体。
	-- @param x1 (number) 第一个锚点的 x 位置。
	-- @param y1 (number) 第一个锚点的 y 位置。
	-- @param x2 (number) 第二个锚点的 x 位置。
	-- @param y2 (number) 第二个锚点的 y 位置。
	-- @param max_length (number) 实体的最大距离。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (Joint) 新的 RopeJoint。
	newRopeJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, max_length: number, collide_connected?: boolean): Joint

	-- 创建一个 PulleyJoint 将两个实体相互连接并连接到地面。
	-- 滑轮接头模拟带有可选滑轮组的滑轮。如果比率参数的值不同于 1，则模拟绳索在一侧比另一侧延伸得更快。在滑轮接头中，模拟绳索的总长度为常数 length1 +ratio * length2，该值在创建滑轮接头时设置。
	-- 如果一侧完全伸展，滑轮接头可能会出现不可预测的行为。建议使用 setMaxLengths 方法来限制每条边可以达到的最大长度。
	-- @param body1 (Body) 第一个与滑轮接头连接的主体。
	-- @param body2 (Body) 与滑轮接头连接的第二个主体。
	-- @param ground_x1 (number) 第一个主体的地锚点的 x 坐标。
	-- @param ground_y1 (number) 第一个主体的地锚的 y 坐标。
	-- @param ground_x2 (number) 第二个主体的地锚点的 x 坐标。
	-- @param ground_y2 (number) 第二个物体的地锚点的 y 坐标。
	-- @param x1 (number) 第一个主体中滑轮关节锚点的 x 坐标。
	-- @param y1 (number) 第一个主体中滑轮关节锚点的 y 坐标。
	-- @param x2 (number) 第二个主体中滑轮关节锚点的 x 坐标。
	-- @param y2 (number) 第二个主体中滑轮关节锚点的 y 坐标。
	-- @param ratio (number) 关节比例。 （默认值：1。）
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：true。）
	-- @return (Joint) 新的滑轮接头。
	newPulleyJoint: function(body1: Body, body2: Body, ground_x1: number, ground_y1: number, ground_x2: number, ground_y2: number, x1: number, y1: number, x2: number, y2: number, ratio?: number, collide_connected?: boolean): Joint

	-- 创建车轮接头。
	-- @param body1 (Body) 第一具尸体。
	-- @param body2 (Body) 第二具尸体。
	-- @param x (number) 锚点的 x 位置。
	-- @param y (number) 锚点的 y 位置。
	-- @param axis_x (number) 轴单位向量的 x 位置。
	-- @param axis_y (number) 轴单位向量的 y 位置。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (WheelJoint) joint — 新的 WheelJoint。
	newWheelJoint: function(body1: Body, body2: Body, x: number, y: number, axis_x: number, axis_y: number, collide_connected?: boolean): WheelJoint

	-- 创建车轮接头。
	-- @param body1 (Body) 第一具尸体。
	-- @param body2 (Body) 第二具尸体。
	-- @param x1 (number) 第一个锚点的 x 位置。
	-- @param y1 (number) 第一个锚点的 y 位置。
	-- @param x2 (number) 第二个锚点的 x 位置。
	-- @param y2 (number) 第二个锚点的 y 位置。
	-- @param axis_x (number) 轴单位向量的 x 位置。
	-- @param axis_y (number) 轴单位向量的 y 位置。
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (WheelJoint) joint — 新的 WheelJoint。
	newWheelJoint: function(body1: Body, body2: Body, x1: number, y1: number, x2: number, y2: number, axis_x: number, axis_y: number, collide_connected?: boolean): WheelJoint

	-- 在身体和鼠标之间创建一个关节。
	-- 这个关节实际上将身体连接到世界上的一个固定点。为了使其跟随鼠标，固定点必须在每个时间步更新（示例如下）。
	-- 使用 MouseJoint 而不是直接更改身体位置的优点是，对其他关节的碰撞和反应由物理引擎处理。
	-- @param body (Body) 连接到鼠标的主体。
	-- @param x (number) 连接点的 x 位置。
	-- @param y (number) 连接点的 y 位置。
	-- @return (Joint) 新的鼠标关节。
	newMouseJoint: function(body: Body, x: number, y: number): Joint

	-- 在两个实体之间创建一个关节，控制它们之间的相对运动。
	-- 一旦创建了 MotorJoint，就可以指定位置和旋转偏移，以及为达到目标偏移而应用的最大电机力和扭矩。
	-- @param body1 (Body) 第一个连接到关节的主体。
	-- @param body2 (Body) 连接到关节的第二个主体。
	-- @param correction_factor (number) 关节的初始位置修正系数，取值范围为1。（默认：0.3。）
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (Joint) 新的 MotorJoint。
	newMotorJoint: function(body1: Body, body2: Body, correction_factor?: number, collide_connected?: boolean): Joint

	-- 创建连接两个关节的 GearJoint。
	-- 齿轮接头连接两个必须是棱柱或旋转接头的接头。使用这个关节需要它使用的关节将各自的身体连接到地面，并以地面作为第一身体。破坏主体和关节时，必须确保先破坏齿轮关节，然后再破坏其他关节。
	-- 齿轮接头具有一个比率，该比率确定所连接接头的角度或距离值如何相互关联。公式坐标 1 + 比率 * 坐标 2 始终具有在创建齿轮接头时设置的常量值。
	-- @param joint1 (Joint) 第一个与齿轮接头连接的接头。
	-- @param joint2 (Joint) 与齿轮接头连接的第二个接头。
	-- @param ratio (number) 齿轮比。 （默认值：1。）
	-- @param collide_connected (boolean) 指定两个实体是否应该相互碰撞。 （默认值：假。）
	-- @return (Joint) 新的齿轮接头。
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
	clear: function()

	-- 将屏幕或活动画布清除为指定颜色。
	--
	-- 在默认的 love.run 函数中，该函数在 love.draw 之前自动调用。有关此函数的典型用法，请参阅 love.run 中的示例。
	--
	-- 请注意，剪刀区域限制了清除区域。
	--
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	--
	-- 在背景颜色之前的版本中。
	-- @param red (number) , g, b, a} 形式的表格，包含要清除第一个活动画布的颜色。
	-- @param green (number) 每个活动画布的附加表。
	-- @param blue (number) 是否清除活动模板缓冲区（如果存在）。它也可以是 0 到 255 之间的整数，用于将模板缓冲区清除为特定值。 （默认值：true。）
	-- @param alpha (number) 是否清除活动深度缓冲区（如果存在）。它也可以是 0 到 1 之间的数字，用于将深度缓冲区清除为特定值。 （默认值：true。）
	clear: function(red: number, green: number, blue: number, alpha?: number)

	-- 丢弃（垃圾）屏幕或活动画布的内容。这是一个具有利基用例的性能优化功能。
	-- 如果活动画布刚刚更改，并且 'replace' BlendMode 将用于绘制覆盖整个屏幕的内容，则调用 love.graphics.discard 而不是调用 love.graphics.clear
	-- 或不执行任何操作可能会提高移动设备上的性能。
	-- 在某些桌面系统上，此功能可能不执行任何操作。
	-- @param discard_color (boolean or {boolean}) 是否丢弃活动画布的纹理（如果没有活动画布，则丢弃屏幕的内容。）（默认值：true。）
	-- @param discard_depth_stencil (boolean) 是否丢弃屏幕/活动画布的模板缓冲区的内容。 （默认值：true。）
	discard: function(discard_color?: boolean | {boolean}, discard_depth_stencil?: boolean)

	-- 立即渲染任何挂起的自动批量绘制。
	-- LÖVE 在大多数状态发生变化时会根据需要在内部调用此函数，因此无需手动调用它。
	-- 当前批次将由 love.graphics 状态更改（变换堆栈和当前颜色除外）以及 Shader:send 和纹理上更改其状态的方法自动刷新。在连续的 love.graphics.draw
	-- 调用中使用不同的图像也会刷新当前批次。
	-- SpriteBatches、ParticleSystems、Meshes 和 Text 对象执行自己的批处理，除了在绘制时刷新当前批处理之外，不会影响其他绘制的自动批处理。
	flushBatch: function()

	-- 设置背景颜色。
	-- @param red (number) 红色分量 (0-1)。
	-- @param green (number) 绿色分量 (0-1)。
	-- @param blue (number) 蓝色分量 (0-1)。
	-- @param alpha (number) alpha 分量 (0-1)。 （默认值：1。）
	setBackgroundColor: function(red: number, green: number, blue: number, alpha?: number)

	-- 设置背景颜色。
	-- @param color (Color) 数字索引表，其中红色、绿色、蓝色和 alpha 值作为数字。 alpha 是可选的，如果省略则默认为 1。
	setBackgroundColor: function(color: Color)

	-- 获取当前背景颜色。
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @return (number) 红色分量 (0-1)。
	-- @return (number) 绿色分量 (0-1)。
	-- @return (number) 蓝色分量 (0-1)。
	-- @return (number) alpha 分量 (0-1)。
	getBackgroundColor: function(): number, number, number, number

	-- 设置与图像、画布和字体一起使用的默认缩放过滤器。
	-- 重载说明：
	-- 1. 此功能不适用于已加载的图像。
	-- @param min_filter (string) 缩小图像时使用的滤镜模式。
	-- @param mag_filter (string) 放大图像时使用的滤镜模式。 （默认值：分钟。）
	-- @param anisotropy (number) 使用的各向异性过滤的最大数量。 （默认值：1。）
	setDefaultFilter: function(min_filter: string, mag_filter?: string, anisotropy?: number)

	-- 返回与图像、画布和字体一起使用的默认缩放过滤器。
	-- @param filter (string) filter 参数。
	-- @param sharpness (number) sharpness 参数。
	-- @return (string or string or nil) 缩小图像时使用的滤镜模式。
	-- @return (string or number) 放大图像时使用的滤镜模式。
	-- @return (number) 使用的各向异性过滤的最大数量。
	getDefaultFilter: function(): string, string, number
	setDefaultMipmapFilter: function(filter?: string, sharpness?: number)
	getDefaultMipmapFilter: function(): string | nil, number

	-- 设置用于绘图的颜色。
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @param red (number) 红色的量。
	-- @param green (number) 绿色量。
	-- @param blue (number) 蓝色的量。
	-- @param alpha (number) Alpha 量。 alpha 值将应用于所有后续的绘制操作，甚至是图像的绘制。 （默认值：1。）
	setColor: function(red: number, green: number, blue: number, alpha?: number)

	-- 获取当前颜色。
	-- 在11.0之前的版本中，颜色分量值的范围是0到255，而不是0到1。
	-- @return (number) 红色分量 (0-1)。
	-- @return (number) 绿色分量 (0-1)。
	-- @return (number) 蓝色分量 (0-1)。
	-- @return (number) alpha 分量 (0-1)。
	getColor: function(): number, number, number, number

	-- 设置线宽。
	-- @param width (number) 线的宽度。
	setLineWidth: function(width: number)

	-- 获取当前线宽。
	-- 重载说明：
	-- 1. 该功能在0.8.0版本中不起作用，但在0.9.0版本中已修复。在 0.8.0 中使用以下代码片段来规避此问题； love.graphics._getLineWidth =
	-- love.graphics.getLineWidth love.graphics._setLineWidth = love.graphics.setLineWidth 函数
	-- love.graphics.getLineWidth() 返回 love.graphics.varlinewidth 或 1 结束函数 love.graphics.setLineWidth(w)
	-- love.graphics.varlinewidth = w; 返回love.graphics._setLineWidth(w)结束
	-- @return (number) 当前线宽。
	getLineWidth: function(): number

	-- 设置线条样式。
	-- @param style (string) 要使用的线条样式。线条样式包括平滑和粗糙。
	setLineStyle: function(style: string)

	-- 获取线条样式。
	-- @return (string) 当前的线条样式。
	getLineStyle: function(): string

	-- 设置线连接样式。请参阅 LineJoin 了解可能的选项。
	-- @param join (string) 要使用的 LineJoin。
	setLineJoin: function(join: string)

	-- 获取线连接样式。
	-- @return (string) LineJoin 风格。
	getLineJoin: function(): string

	-- 设置绘图时是否使用线框线。
	-- @param enable (boolean) 如果为 True，则在绘制时启用线框模式；如果为 false，则禁用它。
	setWireframe: function(enable: boolean)

	-- 获取绘制时是否使用线框模式。
	-- @return (boolean) 如果绘制时使用线框线则为 True，否则为 false。
	isWireframe: function(): boolean

	-- 设置磅值。
	-- @param size (number) 新的磅值。
	setPointSize: function(size: number)

	-- 获取磅值。
	-- @return (number) 当前磅值。
	getPointSize: function(): number

	-- 获取窗口的宽度和高度（以像素为单位）。
	-- @return (number) 窗口的宽度。
	-- @return (number) 窗口的高度。
	getDimensions: function(): number, number

	-- 获取窗口的宽度（以像素为单位）。
	-- @return (number) 窗口的宽度。
	getWidth: function(): number

	-- 获取窗口的高度（以像素为单位）。
	-- @return (number) 窗口的高度。
	getHeight: function(): number

	-- 获取窗口的宽度和高度（以像素为单位）。
	-- love.graphics.getDimensions 获取窗口的尺寸，单位是按屏幕 DPI 比例因子缩放的单位，而不是像素。使用 getDimensions
	-- 进行与绘制到屏幕和使用图形坐标系相关的计算（例如，计算屏幕中心），并且仅在专门处理底层像素时使用 getPixelDimensions（例如，像素着色器中与像素相关的计算）。
	-- @return (number) 窗口的宽度（以像素为单位）。
	-- @return (number) 窗口的高度（以像素为单位）。
	getPixelDimensions: function(): number, number

	-- 获取窗口的宽度（以像素为单位）。
	-- 图形坐标系和DPI比例因子，而不是原始像素。使用 getWidth 进行与绘制到屏幕和使用坐标系相关的计算（例如，计算屏幕中心），并且仅在专门处理底层像素时使用
	-- getPixelWidth（例如，像素着色器中与像素相关的计算）。
	-- @return (number) 窗口的宽度（以像素为单位）。
	getPixelWidth: function(): number

	-- 获取窗口的高度（以像素为单位）。
	-- 图形坐标系和DPI比例因子，而不是原始像素。使用 getHeight 进行与绘制到屏幕和使用坐标系相关的计算（例如，计算屏幕中心），并且仅在专门处理底层像素时使用
	-- getPixelHeight（例如，像素着色器中与像素相关的计算）。
	-- @return (number) 窗口的高度（以像素为单位）。
	getPixelHeight: function(): number

	-- 获取窗口的DPI比例因子。
	-- DPI 比例因子表示相对像素密度。窗口内的像素密度可能大于（或小于）窗口的 'size' 。例如，在启用了 highdpi 窗口标志的 Mac OS X 中的视网膜屏幕上，窗口可能占用与 800x600
	-- 窗口相同的物理尺寸，但窗口内的区域使用 1600x1200 像素。在这种情况下，love.graphics.getDPIScale() 将返回 2。
	-- love.window.fromPixels 和 love.window.toPixels 函数也可用于单位之间的转换。
	-- 必须启用 highdpi 窗口标志才能在 Mac OS X 和 iOS 上使用 Retina 屏幕的完整像素密度。该标志目前在 Windows 和 Linux 上没有任何作用，而在 Android
	-- 上它实际上始终处于启用状态。
	-- 重载说明：
	-- 1. love.graphics.getWidth、love.graphics.getHeight、love.mouse.getPosition、鼠标事件、love.touch.getPosition
	-- 和触摸事件的单位始终采用 DPI 缩放单位，而不是像素。在 LÖVE 0.10 及更早版本中，它们以像素为单位。
	-- @return (number) 与窗口关联的像素比例因子。
	getDPIScale: function(): number

	-- 获取可选的图形功能以及系统是否支持它们。
	-- 一些较旧或低端的系统并不总是支持所有图形功能。
	-- @param target (any) target 参数。
	-- @return (GraphicsFeatures) 包含 GraphicsFeature 键和指示是否支持每个功能的布尔值的表。
	getSupported: function(target?: any): GraphicsFeatures

	-- 获取可用的纹理类型，以及是否支持每种纹理类型。
	-- @param target (any) target 参数。
	-- @return ({string: boolean}) 包含纹理类型作为键的表，以及指示是否支持该类型作为值的布尔值。并非所有系统都支持所有类型。
	getTextureTypes: function(target?: any): {string: boolean}

	-- 获取可用于图像的原始和压缩像素格式，以及是否支持每种格式。
	-- @param target (any) target 参数。
	-- @return ({string: boolean}) 包含 PixelFormats 作为键的表，以及一个指示是否支持该格式作为值的布尔值。并非所有系统都支持所有格式。
	getImageFormats: function(target?: any): {string: boolean}

	-- 获取有关系统显卡和驱动程序的信息。
	-- @return (string) 渲染器的名称，例如'OpenGL' 或 'OpenGL ES'。
	-- @return (string) 渲染器的版本，带有一些额外的依赖于驱动程序的版本信息，例如'2.1 INTEL-8.10.44'。
	-- @return (string) 显卡供应商的名称，例如'Intel Inc'。
	-- @return (string) 显卡的名称，例如'Intel HD Graphics 3000 OpenGL Engine'。
	getRendererInfo: function(): string, string, string, string

	-- 获取 love.graphics 功能的系统相关最大值。
	-- @param target (any) target 参数。
	-- @return (GraphicsSystemLimits) 包含 GraphicsLimit 键和数值的表。
	getSystemLimits: function(target?: any): GraphicsSystemLimits

	-- 获取与性能相关的渲染统计信息。
	-- @return (GraphicsStats) stats — 包含以下字段的表：
	getStats: function(): GraphicsStats

	-- 获取与性能相关的渲染统计信息。
	-- @param target (any) 将用下面的统计字段填充的表格。
	-- @return (GraphicsStats) 上面传入的表，现在包含以下字段：
	getStats: function(target: any): GraphicsStats

	-- 当前帧完成后（love.draw 完成后）创建屏幕截图。
	--
	-- 由于此函数将屏幕截图放入队列而不是立即执行它，因此可以从输入回调或 love.update 调用它，并且它仍然会捕获该帧中绘制到屏幕上的所有内容。
	-- @param filename (string) 保存屏幕截图的文件名。编码图像类型根据文件名的扩展名确定，并且必须是 ImageFormat 之一。
	captureScreenshot: function(filename: string)

	-- 当前帧完成后（love.draw 完成后）创建屏幕截图。
	--
	-- 由于此函数将屏幕截图放入队列而不是立即执行它，因此可以从输入回调或 love.update 调用它，并且它仍然会捕获该帧中绘制到屏幕上的所有内容。
	-- @param callback (function(image_data: ImageData)) 捕获屏幕截图后调用的函数。 ImageData 作为唯一参数传递到函数中。
	captureScreenshot: function(callback: function(image_data: ImageData))

	-- 当前帧完成后（love.draw 完成后）创建屏幕截图。
	--
	-- 由于此函数将屏幕截图放入队列而不是立即执行它，因此可以从输入回调或 love.update 调用它，并且它仍然会捕获该帧中绘制到屏幕上的所有内容。
	-- @param channel (Channel) 将生成的 ImageData 推送到的 Channel。
	captureScreenshot: function(channel: Channel)

	-- 绘制一个矩形。
	-- 重载说明：
	-- 1. 绘制一个圆角矩形。
	-- @param mode (string) 如何绘制矩形。
	-- @param x (number) 左上角沿x轴的位置。
	-- @param y (number) 左上角沿 y 轴的位置。
	-- @param width (number) 矩形的宽度。
	-- @param height (number) 矩形的高度。
	rectangle: function(mode: string, x: number, y: number, width: number, height: number)

	-- 画一个圆。
	-- @param mode (string) 如何画圆。
	-- @param x (number) 中心沿 x 轴的位置。
	-- @param y (number) 中心沿 y 轴的位置。
	-- @param radius (number) 圆的半径。
	circle: function(mode: string, x: number, y: number, radius: number)

	-- 在位置 (x, y) 处绘制填充或未填充的圆弧。弧线以弧度为单位从角度 1 到角度 2 绘制。段参数确定使用多少段来绘制圆弧。分段越多，边缘越平滑。
	-- @param mode (DrawMode) 如何绘制圆弧。
	-- @param x (number) 中心沿 x 轴的位置。
	-- @param y (number) 中心沿 y 轴的位置。
	-- @param radius (number) 圆弧半径。
	-- @param angle1 (number) 圆弧开始的角度。
	-- @param angle2 (number) 圆弧终止的角度。
	-- @param segments (integer) 用于绘制圆弧的段数。 （默认值：10。）
	arc: function(mode: DrawMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: integer)

	-- 在位置 (x, y) 处绘制填充或未填充的圆弧。弧线以弧度为单位从角度 1 到角度 2 绘制。段参数确定使用多少段来绘制圆弧。分段越多，边缘越平滑。
	-- @param mode (DrawMode) 如何绘制圆弧。
	-- @param arc_mode (ArcMode) 要绘制的圆弧类型。
	-- @param x (number) 中心沿 x 轴的位置。
	-- @param y (number) 中心沿 y 轴的位置。
	-- @param radius (number) 圆弧半径。
	-- @param angle1 (number) 圆弧开始的角度。
	-- @param angle2 (number) 圆弧终止的角度。
	-- @param segments (integer) 用于绘制圆弧的段数。 （默认值：10。）
	arc: function(mode: DrawMode, arc_mode: ArcMode, x: number, y: number, radius: number, angle1: number, angle2: number, segments?: integer)

	-- 绘制一个椭圆。
	-- @param mode (string) 如何绘制椭圆。
	-- @param x (number) 中心沿 x 轴的位置。
	-- @param y (number) 中心沿 y 轴的位置。
	-- @param radius_x (number) 椭圆沿 x 轴的半径（椭圆宽度的一半）。
	-- @param radius_y (number) 椭圆沿 y 轴的半径（椭圆高度的一半）。
	-- @param segments (integer) 用于绘制椭圆的线段数。
	ellipse: function(mode: string, x: number, y: number, radius_x: number, radius_y: number, segments?: integer)

	-- 在点之间绘制线。
	-- @param x1 (number) x 轴上第一个点的位置。
	-- @param y1 (number) y 轴上第一个点的位置。
	-- @param x2 (number) x 轴上第二个点的位置。
	-- @param y2 (number) y 轴上第二个点的位置。
	-- @param coordinates (number...) 您可以继续通过点位置来绘制折线。
	line: function(x1: number, y1: number, x2: number, y2: number, coordinates: number...)

	-- 画一个多边形。
	-- 在模式参数之后，该函数可以接受多个数字参数或单个数字参数表。无论哪种情况，参数都被解释为多边形顶点的交替 x 和 y 坐标。
	-- @param mode (string) 如何绘制多边形。
	-- @param x1 (number) 多边形的顶点。取决于重载：将多边形的顶点作为表格。
	-- @param y1 (number) y1 参数。
	-- @param x2 (number) x2 参数。
	-- @param y2 (number) y2 参数。
	-- @param x3 (number) x3 参数。
	-- @param y3 (number) y3 参数。
	-- @param coordinates (number...) coordinates 参数。
	polygon: function(mode: string, x1: number, y1: number, x2: number, y2: number, x3: number, y3: number, coordinates: number...)

	-- 绘制一个或多个点。
	-- 重载说明：
	-- 1. 绘制一个或多个单独着色的点。在 11.0 之前的版本中，颜色分量值的范围是 0 到 255，而不是 0 到 1。像素网格实际上偏移到每个像素的中心。因此，要获得干净的像素绘制，请使用 0.5 +
	-- 整数增量。点不受大小影响，始终以像素为单位。
	-- @param x1 (number) x 轴上第一个点的位置。
	-- @param y1 (number) y 轴上第一个点的位置。
	-- @param coordinates (number...) 附加点的 x 和 y 坐标。
	points: function(x1: number, y1: number, coordinates: number...)

	-- 在屏幕上显示绘图操作的结果。
	-- 在编写自己的 love.run 函数时使用该函数。它在屏幕上显示绘图操作的所有结果。有关此函数的典型用法，请参阅 love.run 中的示例。
	-- 重载说明：
	-- 1. * 如果 love.window.setMode 的 vsync 等于 true，则该函数的运行频率不能高于刷新率（例如 60 Hz），并且将暂停程序直到准备就绪（如有必要）。
	present: function()

	-- 复制当前坐标变换并将其推入变换堆栈。
	--
	-- 这个函数总是用来为后面相应的出栈操作做准备。它将当前坐标变换状态存储到变换堆栈中并保持其活动状态。稍后对变换所做的更改可以通过使用 pop 操作来撤消，该操作会将坐标变换返回到调用 push 之前的状态。
	push: function()

	-- 复制当前坐标变换并将其推入变换堆栈。
	--
	-- 这个函数总是用来为后面相应的出栈操作做准备。它将当前坐标变换状态存储到变换堆栈中并保持其活动状态。稍后对变换所做的更改可以通过使用 pop 操作来撤消，该操作会将坐标变换返回到调用 push 之前的状态。
	-- @param stack_type (string) 要推送的堆栈类型（例如，仅转换状态，或所有 love.graphics 状态）。
	push: function(stack_type: string)

	-- 从变换堆栈中弹出当前坐标变换。
	-- 该函数始终用于反转先前的推送操作。它将当前转换状态返回到上次推送之前的状态。
	pop: function()

	-- 获取变换/状态堆栈的当前深度（没有相应弹出的压入次数）。
	-- @return (integer) 变换和状态 love.graphics 堆栈的当前深度。
	getStackDepth: function(): integer

	-- 重置当前坐标变换。
	-- 此函数始终用于反转任何先前对 love.graphics.rotate、love.graphics.scale、love.graphics.shear 或 love.graphics.translate.
	-- 的调用，它将当前转换状态返回为其默认值。
	origin: function()

	-- 将坐标系转换为二维。
	-- 当使用两个数字 dx 和 dy 调用此函数时，以下所有绘图操作都会生效，就好像它们的 x 和 y 坐标为 x+dx 和 y+dy 一样。
	-- 缩放和平移不是可交换操作，因此，以不同的顺序调用它们将改变结果。
	-- 此更改将持续到 love.draw() 退出，否则 love.graphics.pop 恢复为之前的 love.graphics.push.
	-- 使用整数进行翻译将防止翻译后绘制的图像和字体出现撕裂/模糊。
	-- @param dx (number) 相对于 x 轴的平移。
	-- @param dy (number) 相对于 y 轴的平移。
	translate: function(dx: number, dy: number)

	-- 二维旋转坐标系。
	-- 调用此函数会通过将坐标系围绕原点旋转给定的弧度来影响所有将来的绘图操作。此更改将持续到 love.draw() 退出为止。
	-- @param angle (number) 坐标系的旋转量（以弧度为单位）。
	rotate: function(angle: number)

	-- 在二维中缩放坐标系。
	-- LÖVE中的坐标系默认与水平和垂直方向的显示像素一一对应，x轴向右增大，y轴向下增大。缩放坐标系会改变这种关系。
	-- 经过 sx 和 sy 缩放后，所有坐标都被视为乘以 sx 和 sy。绘图操作的每个结果也会相应地缩放，因此例如缩放 (2, 2) 意味着将所有内容在 x 和 y
	-- 方向上放大两倍。按负值缩放会沿相应方向翻转坐标系，这也意味着所有内容都将被翻转或颠倒或两者都绘制。按零缩放并不是一个有用的操作。
	-- 缩放和平移不是可交换操作，因此，以不同的顺序调用它们将改变结果。
	-- 缩放持续到 love.draw() 退出。
	-- @param sx (number) x轴方向的缩放。
	-- @param sy (number) y轴方向的缩放。如果省略，则默认与参数 sx 相同。 （默认值：sx。）
	scale: function(sx: number, sy?: number)

	-- 剪切坐标系。
	-- @param kx (number) x 轴上的剪切因子。
	-- @param ky (number) y 轴上的剪切因子。
	shear: function(kx: number, ky: number)

	-- 将给定的 Transform 对象应用于当前坐标变换。
	-- 这有效地将现有坐标变换的矩阵与 Transform 对象的内部矩阵相乘以产生新的坐标变换。
	-- @param transform (Transform) 应用于当前图形坐标变换的 Transform 对象。
	applyTransform: function(transform: Transform)

	-- 用给定的 Transform 对象替换当前的坐标变换。
	-- @param transform (Transform) 用于替换当前图形坐标变换的 Transform 对象。
	replaceTransform: function(transform: Transform)

	-- 将给定的 2D 位置从全局坐标转换为屏幕空间。
	-- 这有效地将当前图形变换应用于给定位置。 Transform 对象也存在类似的 Transform:transformPoint 方法。
	-- @param x (number) 全局坐标中位置的 x 分量。
	-- @param y (number) 全局坐标中位置的 y 分量。
	-- @return (number) 应用了图形变换的位置的 x 分量。
	-- @return (number) 应用了图形变换的位置的 y 分量。
	transformPoint: function(x: number, y: number): number, number

	-- 将给定的 2D 位置从屏幕空间转换为全局坐标。
	-- 这有效地将当前图形变换的反向应用到给定位置。 Transform 对象也存在类似的 Transform:inverseTransformPoint 方法。
	-- @param x (number) 屏幕空间位置的 x 分量。
	-- @param y (number) 屏幕空间位置的 y 分量。
	-- @return (number) 全局坐标中位置的 x 分量。
	-- @return (number) 全局坐标中位置的 y 分量。
	inverseTransformPoint: function(x: number, y: number): number, number

	-- 获取图形模块是否可以使用。如果未激活，love.graphics 函数和方法调用将无法正常工作，并可能导致程序崩溃。如果窗口未打开，或者应用程序在 iOS
	-- 上处于后台，则图形模块处于非活动状态。通常，在后一种情况下，应用程序的执行将被系统自动暂停。
	-- @return (boolean) 图形模块是否处于活动状态并且可以使用。
	isActive: function(): boolean
	isCreated: function(): boolean

	-- 获取是否支持并启用伽玛校正渲染。可以通过在 love.conf.
	-- 并非所有设备都支持伽玛校正渲染，在这种情况下它将自动禁用，并且此函数将返回 false。它在具有能够使用 OpenGL 3 / DirectX 10 的显卡的桌面系统以及可以使用 OpenGL ES 3 的 iOS
	-- 设备上受支持。
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
	-- @return (boolean) 如果支持伽玛校正渲染并在 love.conf 中启用，则为 true，否则为 false。
	isGammaCorrect: function(): boolean

	-- 重置当前图形设置。
	-- 调用reset使当前绘图颜色为白色，当前背景颜色为黑色，禁用任何活动的颜色组件蒙版，禁用线框模式并将当前图形变换重置为原点。它还将点和线绘制模式设置为平滑，并将它们的大小设置为 1.0。
	reset: function()

	-- 设置混合模式。
	-- 重载说明：
	-- 1. 通常应首选默认的 'alphamultiply' alpha 模式，除非使用预乘 alpha 绘制内容。如果使用 'alphamultiply' 模式将内容绘制到 Canvas，则 Canvas 纹理随后将具有预乘
	-- alpha，因此在将 Canvas 绘制到屏幕时通常应使用 'premultiplied' alpha 模式。
	-- @param mode (string) 要使用的混合模式。
	-- @param alpha_mode (string) 混合时如何处理绘制对象的 Alpha。 （默认：'alphamultiply'。）
	setBlendMode: function(mode: string, alpha_mode?: string)

	-- 获取混合模式。
	-- @return (string) 当前的混合模式。
	-- @return (string) 当前混合 Alpha 模式 – 它确定绘制对象的 Alpha 如何影响混合。
	getBlendMode: function(): string, string

	-- 设置或禁用剪刀。
	--
	-- 剪刀将绘图区域限制在指定的矩形内。这会影响所有图形调用，包括 love.graphics.clear.
	--
	-- 剪刀的尺寸不受图形变换（平移、缩放……）的影响。
	setScissor: function()

	-- 设置或禁用剪刀。
	--
	-- 剪刀将绘图区域限制在指定的矩形内。这会影响所有图形调用，包括 love.graphics.clear.
	--
	-- 剪刀的尺寸不受图形变换（平移、缩放……）的影响。
	-- @param x (number) 左上角的x坐标。
	-- @param y (number) 左上角的y坐标。
	-- @param width (number) 剪切矩形的宽度。
	-- @param height (number) 剪切矩形的高度。
	setScissor: function(x: number, y: number, width: number, height: number)

	-- 获取当前剪刀框。
	-- @return (number or nil) 框左上角点的 x 分量。
	-- @return (number or nil) 框左上角点的 y 分量。
	-- @return (number or nil) 框的宽度。
	-- @return (number or nil) 盒子的高度。
	getScissor: function(): number | nil, number | nil, number | nil, number | nil

	-- 将剪刀设置为由指定矩形与现有剪刀相交而创建的矩形。如果还没有激活的剪刀，则其行为类似于 love.graphics.setScissor.
	-- 剪刀将绘图区域限制在指定的矩形内。这会影响所有图形调用，包括 love.graphics.clear.
	-- 剪刀的尺寸不受图形变换（平移、缩放……）的影响。
	-- @param x (number) 与现有剪刀矩形相交的矩形左上角的 x 坐标。
	-- @param y (number) 与现有剪刀矩形相交的矩形左上角的 y 坐标。
	-- @param width (number) 与现有剪刀矩形相交的矩形的宽度。
	-- @param height (number) 与现有剪刀矩形相交的矩形的高度。
	intersectScissor: function(x: number, y: number, width: number, height: number)

	-- 设置颜色遮罩。渲染和清除屏幕时启用或禁用特定颜色组件。例如，如果“'red''' is set to '''false'”，则不会对任何像素的红色分量进行进一步的更改。
	setColorMask: function()

	-- 设置颜色遮罩。渲染和清除屏幕时启用或禁用特定颜色组件。例如，如果“'red''' is set to '''false'”，则不会对任何像素的红色分量进行进一步的更改。
	-- @param red (boolean) 渲染红色分量。
	-- @param green (boolean) 渲染绿色组件。
	-- @param blue (boolean) 渲染蓝色分量。
	-- @param alpha (boolean) 渲染 alpha 分量。
	setColorMask: function(red: boolean, green: boolean, blue: boolean, alpha: boolean)

	-- 获取绘图时使用的活动颜色分量。通常，除非使用 love.graphics.setColorMask，否则所有 4 个组件均处于活动状态。
	-- 颜色掩码确定绘制对象的颜色的各个分量是否会影响屏幕的颜色。它们也会影响 love.graphics.clear 和 Canvas:clear 。
	-- @return (boolean) 渲染时红色分量是否处于活动状态。
	-- @return (boolean) 渲染时绿色分量是否处于活动状态。
	-- @return (boolean) 渲染时蓝色分量是否处于活动状态。
	-- @return (boolean) 渲染时 Alpha 颜色分量是否处于活动状态。
	getColorMask: function(): boolean, boolean, boolean, boolean

	-- 配置深度测试并写入深度缓冲区。
	--
	-- 这是低级功能，设计用于自定义顶点着色器和具有自定义顶点属性的网格。没有提供更高级别的 API 来设置 2D 图形（例如形状、线条和图像）的深度。
	setDepthMode: function()

	-- 配置深度测试并写入深度缓冲区。
	--
	-- 这是低级功能，设计用于自定义顶点着色器和具有自定义顶点属性的网格。没有提供更高级别的 API 来设置 2D 图形（例如形状、线条和图像）的深度。
	-- @param compare (CompareMode) 用于深度测试的深度比较模式。
	-- @param write (boolean) 渲染时是否将更新/写入值写入深度缓冲区。
	setDepthMode: function(compare: CompareMode, write: boolean)

	-- 获取当前深度测试模式以及是否启用写入深度缓冲区。
	-- 这是低级功能，设计用于自定义顶点着色器和具有自定义顶点属性的网格。没有提供更高级别的 API 来设置 2D 图形（例如形状、线条和图像）的深度。
	-- @return (string) 用于深度测试的深度比较模式。
	-- @return (boolean) 渲染时是否将更新/写入值写入深度缓冲区。
	getDepthMode: function(): string, boolean

	-- 设置是否剔除网格中的背面三角形。
	-- 它设计用于通过网格上的自定义顶点属性、自定义顶点着色器以及使用深度缓冲区进行深度测试来与低级自定义硬件加速 3D 渲染一起使用。
	-- 默认情况下，网格中的正面和背面三角形都会被渲染。
	-- @param mode (string) 要使用的网格面剔除模式（是否渲染所有内容、剔除背面三角形或剔除正面三角形）。
	setMeshCullMode: function(mode: string)

	-- 获取网格中的背面三角形是否被剔除。
	-- 网格面剔除旨在通过网格上的自定义顶点属性、自定义顶点着色器以及使用深度缓冲区的深度测试与低级自定义硬件加速 3D 渲染一起使用。
	-- @return (string) 使用中的网格面剔除模式（是否渲染所有内容、剔除背面三角形或剔除正面三角形）。
	getMeshCullMode: function(): string

	-- 设置是否将具有顺时针或逆时针顺序顶点的三角形视为正面。
	-- 这是设计用于与网格面剔除结合使用的。其他 love.graphics 形状、线条和精灵不保证其内部顶点具有特定的缠绕顺序。
	-- @param winding (string) 使用的绕线模式。默认绕线为逆时针方向 ('ccw')。
	setFrontFaceWinding: function(winding: string)

	-- 获取具有顺时针或逆时针顺序顶点的三角形是否被视为正面。
	-- 这是设计用于与网格面剔除结合使用的。其他 love.graphics 形状、线条和精灵不保证其内部顶点具有特定的缠绕顺序。
	-- @return (string) 使用的绕线模式。默认绕线为逆时针方向 ('ccw')。
	getFrontFaceWinding: function(): string

	-- 将几何图形绘制为模板。
	--
	-- 所提供的函数绘制的几何图形设置像素的不可见模板值，而不是设置像素颜色。模板缓冲区（包含这些模板值）可以像蒙版/模板一样工作 - 随后可以使用 love.graphics.setStencilTest 来确定每个像素中的模板值如何影响进一步的渲染。
	--
	-- 模板值是 255 范围内的整数。
	-- @param draw (function()) 绘制几何图形的函数。像素的模板值，而不是每个像素的颜色，将受到几何形状的影响。
	-- @param action (StencilAction) 如何修改模板函数中绘制的内容所涉及的像素的任何模板值。 （默认：'replace'。）
	-- @param value (integer) 如果使用 'replace' 模板操作，则用于像素的新模板值。对其他模板操作没有影响。必须介于 0 到 255 之间。（默认值：1。）
	-- @param keep_values_or_clear_value (boolean) 如果为 true，则保留像素的旧模板值；如果为 false，则在执行模板函数之前将每个像素的模板值重置为 0。 love.graphics.clear 还将重置所有模板值。 （默认值：假。）
	stencil: function(draw: function(), action?: StencilAction, value?: integer, keep_values_or_clear_value?: boolean)

	-- 将几何图形绘制为模板。
	--
	-- 所提供的函数绘制的几何图形设置像素的不可见模板值，而不是设置像素颜色。模板缓冲区（包含这些模板值）可以像蒙版/模板一样工作 - 随后可以使用 love.graphics.setStencilTest 来确定每个像素中的模板值如何影响进一步的渲染。
	--
	-- 模板值是 255 范围内的整数。
	-- @param draw (function()) 绘制几何图形的函数。像素的模板值，而不是每个像素的颜色，将受到几何形状的影响。
	-- @param action (StencilAction) 如何修改模板函数中绘制的内容所涉及的像素的任何模板值。 （默认：'replace'。）
	-- @param value (integer) 如果使用 'replace' 模板操作，则用于像素的新模板值。对其他模板操作没有影响。必须介于 0 到 255 之间。（默认值：1。）
	-- @param keep_values_or_clear_value (number) 如果为 true，则保留像素的旧模板值；如果为 false，则在执行模板函数之前将每个像素的模板值重置为 0。 love.graphics.clear 还将重置所有模板值。 （默认值：假。）
	stencil: function(draw: function(), action: StencilAction, value: integer, keep_values_or_clear_value: number)

	-- 配置或禁用模板测试。
	--
	-- 当启用模板测试时，之后绘制的所有内容的几何图形都将根据该函数的参数与几何图形接触的每个像素的模板值之间的比较被剪裁/模板化。像素的模板值受 love.graphics.stencil.
	setStencilTest: function()

	-- 配置或禁用模板测试。
	--
	-- 当启用模板测试时，之后绘制的所有内容的几何图形都将根据该函数的参数与几何图形接触的每个像素的模板值之间的比较被剪裁/模板化。像素的模板值受 love.graphics.stencil.
	-- @param compare (CompareMode) 对每个像素进行比较的类型。
	-- @param value (integer) 与每个像素的模板值进行比较时使用的值。必须介于 0 到 255 之间。
	setStencilTest: function(compare: CompareMode, value: integer)

	-- 获取当前模板测试配置。
	-- 当启用模板测试时，之后绘制的所有内容的几何图形都将根据该函数的参数与几何图形接触的每个像素的模板值之间的比较被剪裁/模板化。像素的模板值受 love.graphics.stencil.
	-- 每个画布都有自己的每像素模板值。
	-- @return (string) 对每个像素进行的比较类型。如果禁用模板测试，则将为 'always'。
	-- @return (integer) 与每个像素的模板值进行比较时使用的值。
	getStencilTest: function(): string, integer

	-- 从 TrueType 字体或 BMFont 文件创建新字体。创建的字体不会被缓存，因为使用相同的参数调用此函数将始终创建一个新的 Font 对象。
	--
	-- 所有接受文件名的变体也可以接受数据对象。
	-- @param size (integer) 字体大小（以像素为单位）。
	-- @return (Font) font — 可用于在屏幕上绘制文本的 Font 对象。
	newFont: function(size?: integer): Font

	-- 从 TrueType 字体或 BMFont 文件创建新字体。创建的字体不会被缓存，因为使用相同的参数调用此函数将始终创建一个新的 Font 对象。
	--
	-- 所有接受文件名的变体也可以接受数据对象。
	-- @param filename (string) TrueType 字体文件的文件路径。
	-- @param size (integer) 字体的大小（以像素为单位）。 （默认值：12。）
	-- @return (Font) font — 可用于在屏幕上绘制文本的 Font 对象。
	newFont: function(filename: string, size?: integer): Font

	-- 创建并设置新字体。
	-- @param size (integer) 字体大小。 （默认值：12。）
	-- @return (Font) font — 新字体。
	setNewFont: function(size?: integer): Font

	-- 创建并设置新字体。
	-- @param filename (string) 字体文件的路径和名称。
	-- @param size (integer) 字体大小。 （默认值：12。）
	-- @return (Font) font — 新字体。
	setNewFont: function(filename: string, size?: integer): Font

	-- 创建一个新的特定格式的图像。
	--
	-- 在 0.9.0 之前的版本中，LÖVE 期望字形字符串采用 ISO 8859-1 编码。
	-- @param source (string | FileData | ImageData) 图像文件的文件路径。
	-- @param glyphs (string) 图像中从左到右排列的字符字符串。
	-- @param extra_spacing (integer) 应用于字体中每个字形的附加间距（正或负）。 （默认值：0。）
	-- @param dpi_scale (number) 字体的 DPI 缩放系数。（默认值：1。）
	-- @return (Font) font — 可用于在屏幕上绘制文本的 Font 对象。
	newImageFont: function(source: string | FileData | ImageData, glyphs: string, extra_spacing?: integer, dpi_scale?: number): Font

	-- 创建一个新的特定格式的图像。
	--
	-- 在 0.9.0 之前的版本中，LÖVE 期望字形字符串采用 ISO 8859-1 编码。
	-- @param rasterizer (Rasterizer) 用于创建字体的 ImageData 对象。
	-- @return (Font) font — 可用于在屏幕上绘制文本的 Font 对象。
	newImageFont: function(rasterizer: Rasterizer): Font

	-- 创建一个新的可绘制文本对象。
	-- @param font (Font) 用于文本的字体。
	-- @param text (any) 新 Text 对象将包含的初始文本字符串。可能为零。 （默认值：nil。）取决于重载：包含要添加到对象的颜色和字符串的表，格式为 {color1, string1, color2, string2, ...}。 color1: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。 string1: 文本字符串，其颜色由前一个颜色指定。 color2: 包含红色、绿色、蓝色和可选 alpha 分量的表，用作表中下一个字符串的颜色，格式为 {red, green, blue, alpha}。 string2: 文本字符串，其颜色由前一个颜色指定。 ...: 附加颜色和字符串。
	-- @return (Text) 新的可绘制文本对象。
	newText: function(font: Font, text?: any): Text

	-- 将已加载的字体设置为当前字体，或根据文件和大小创建并加载新字体。
	-- 建议在加载阶段使用 love.graphics.newFont 创建 Font 对象，然后在绘图阶段传递给此函数。
	-- @param font (Font) 要使用的 Font 对象。
	setFont: function(font: Font)

	-- 获取当前的 Font 对象。
	-- @return (Font) 当前字体。自动创建并设置默认字体（如果尚未设置）。
	getFont: function(): Font

	-- 在屏幕上绘制文本。如果未设置字体，则将根据需要创建并设置（一次）字体。
	-- 从 LOVE 0.7.1 开始，当在绘制文本时使用平移和缩放函数时，此函数假设首先发生缩放。如果您在编写脚本时没有考虑到这一点，则文本将不会位于正确的位置，甚至可能不会出现在屏幕上。
	-- love.graphics.print 和 love.graphics.printf 均支持 UTF-8 编码。您还需要适合特殊字符的字体。
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	-- 重载说明：
	-- 1. love.graphics.setColor 设置的颜色将与文本的颜色组合（相乘）。
	-- @param text (string or number) 要绘制的文本。
	-- @param x (number) 绘制对象的位置（x 轴）。 （默认值：0。）取决于过载：文本在 x 轴上的位置。 （默认值：0。）
	-- @param y (number) 绘制对象的位置（y 轴）。 （默认值：0。）取决于过载：文本在 y 轴上的位置。 （默认值：0。）
	-- @param angle (number) 以弧度表示的文本方向。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）取决于过载：x 轴上的比例因子。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）取决于过载：y 轴上的比例因子。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）取决于过载：x 轴上的原点偏移。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）取决于过载：y 轴上的原点偏移。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）取决于过载：x 轴上的剪切/倾斜系数。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）取决于过载：y 轴上的剪切/倾斜系数。 （默认值：0。）
	print: function(text: string | number, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 绘制格式化文本，并进行自动换行和对齐。
	-- 请参阅 love.graphics.print.
	-- 在任何缩放、旋转和其他坐标转换之前应用自动换行限制。因此，即使比例参数发生变化，在给定相同的换行限制的情况下，每行的文本量也保持不变。
	-- 在版本 0.9.2
	-- 及更早版本中，换行是通过用空格分隔单词并将它们重新组合在一起来实现的，以确保事物在提供的限制内很好地契合。但是，由于这样做的方式，在屏幕上打印时，单词之间的额外空格最终会丢失，并且某些行可能会溢出超过提供的换行限制。在
	-- 0.10.0 及更高版本中，情况不再如此。
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	-- 重载说明：
	-- 1. love.graphics.setColor 设置的颜色将与文本的颜色组合（相乘）。
	-- @param text (string or number) 文本字符串。
	-- @param x (number) x 轴上的位置。取决于过载：文本的位置（x 轴）。
	-- @param y (number) y 轴上的位置。取决于过载：文本的位置（y 轴）。
	-- @param limit (number) 在这么多水平像素之后换行。取决于过载：自动换行之前文本的最大宽度（以像素为单位）。
	-- @param align (string) 对齐。 （默认值：'left'。）取决于重载：文本的对齐方式。
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）取决于过载：剪切/倾斜系数（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）取决于过载：剪切/倾斜系数（y 轴）。 （默认值：0。）
	printf: function(text: string | number, x: number, y: number, limit: number, align?: string, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 从文件路径、FileData、ImageData 或 CompressedImageData 创建新图像，并可选择生成或指定图像的 mipmap。
	-- @param filename (string) 图像文件的文件路径。
	-- @param settings (ImageSettings) 包含以下字段的表：（默认值：nil。）
	-- @return (Image) image — 一个可以在屏幕上绘制的新图像对象。
	newImage: function(filename: string, settings?: ImageSettings): Image

	-- 从文件路径、FileData、ImageData 或 CompressedImageData 创建新图像，并可选择生成或指定图像的 mipmap。
	-- @param data (FileData) 包含图像文件的 FileData。
	-- @param settings (CompressedImageSettings) 包含以下字段的表：（默认值：nil。）
	-- @return (Image) image — 一个可以在屏幕上绘制的新图像对象。
	newImage: function(data: FileData, settings?: CompressedImageSettings): Image

	-- 从文件路径、FileData、ImageData 或 CompressedImageData 创建新图像，并可选择生成或指定图像的 mipmap。
	-- @param data (ImageData) 包含图像的 ImageData。
	-- @param settings (ImageSettings) 包含以下字段的表：（默认值：nil。）
	-- @return (Image) image — 一个可以在屏幕上绘制的新图像对象。
	newImage: function(data: ImageData, settings?: ImageSettings): Image

	-- 从文件路径、FileData、ImageData 或 CompressedImageData 创建新图像，并可选择生成或指定图像的 mipmap。
	-- @param data (CompressedImageData) 一个 CompressedImageData 对象。当调用 love.window.setMode 时，Image 将使用此 CompressedImageData 重新加载自身。
	-- @param settings (CompressedImageSettings) 包含以下字段的表：（默认值：nil。）
	-- @return (Image) image — 一个可以在屏幕上绘制的新图像对象。
	newImage: function(data: CompressedImageData, settings?: CompressedImageSettings): Image

	-- 创建一个新的可绘制视频。目前仅支持 Ogg Theora 视频文件。
	-- @param filename (string) Ogg Theora 视频文件的文件路径。
	-- @param settings (any) 包含以下字段的表：（默认值：nil。）
	-- @return (Video) video — 一个新视频。
	newVideo: function(filename: string, settings?: any): Video

	-- 创建一个新的可绘制视频。目前仅支持 Ogg Theora 视频文件。
	-- @param stream (VideoStream) Ogg Theora 视频文件的文件路径。
	-- @param settings (any) 包含以下字段的表：（默认值：nil。）
	-- @return (Video) video — 一个新视频。
	newVideo: function(stream: VideoStream, settings?: any): Video
	_newVideo: function(filename_or_stream: string | VideoStream, dpi_scale?: number): Video

	-- 创建一个新的数组图像。
	-- 数组图像/数组纹理是包含多个 'layers' 或 'slices' 2D 子图像的单个对象。它可以被认为类似于纹理图集或精灵表，但它不会遭受与纹理图集相同的平铺/四边形渗色伪影的影响 - 尽管每个子图像必须具有相同的尺寸。
	-- 阵列图像的特定层可以使用 love.graphics.drawLayer / SpriteBatch:addLayer 绘制，或者使用 love.graphics.draw 和 Quad:setLayer 的 Quad
	-- 变体，或者通过自定义着色器绘制。
	-- 要在Shader 中使用数组图像，必须将其声明为ArrayImage 或sampler2DArray 类型（而不是Image 或sampler2D）。必须使用 Texel(ArrayImage image,
	-- vec3texturecoord) 着色器函数从数组图像的切片中获取像素颜色。 vec3 参数包含前两个组件中的纹理坐标，以及第三个组件中从 0 开始的切片索引。
	-- 重载说明：
	-- 1. 创建一个数组图像，为生成的数组图像对象的每个切片指定不同的图像文件。
	--     Illustration of how an array image works: 外部插图 DPI 比例为 2（正常像素的两倍
	-- 密度）将导致图像在屏幕上占据与 DPI 比例为 1 的像素尺寸一半的图像相同的空间。这允许轻松交换在屏幕上占据相同空间但具有不同像素密度的图像资源，这使得支持高 dpi / 视网膜分辨率需要更少的代码逻辑。为了在自定义
	-- void effect() 变体中使用数组纹理或其他非 2D 纹理类型作为主纹理，必须在像素着色器中使用变体，并且必须将 MainTex 声明为
	--     ArrayImage or sampler2DArray like so: 统一ArrayImage MainTex;。
	-- @param layers ({ImageData}) 一个表，其中包含数组中图像（或 File、FileData、ImageData 或 CompressedImageData 对象）的文件路径。每个子图像必须具有相同的尺寸。还可以给出表的表，其中每个子表包含该子表的切片索引的所有mipmap级别。
	-- @param settings (LayeredImageSettings) 用于配置阵列映像的可选设置表，包含以下字段：（默认值：nil。） mipmaps: 如果为 true 则使图像使用 mipmap，为 false 则禁用它们。如果图像不是压缩纹理格式，则会自动生成 Mipmap。 （默认值：假。） linear: 如果启用伽马校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。） dpiscale: 绘制数组图像并调用 getWidth/getHeight 时使用的 DPI 比例。 （默认值：1。）
	-- @return (Image) 数组图像对象。
	newArrayImage: function(layers: {ImageData}, settings?: LayeredImageSettings): Image

	-- 创建一个新的立方体贴图图像。
	-- 立方体贴图图像有 6 个面（侧面），代表一个立方体。它们不能直接渲染，只能在着色器代码中使用（并通过 Shader:send 发送到着色器）。
	-- 要在Shader 中使用立方体贴图图像，必须将其声明为CubeImage 或samplerCube 类型（而不是Image 或sampler2D）。必须使用 Texel(CubeImage image, vec3
	-- Direction) 着色器函数从立方体贴图中获取像素颜色。 vec3 参数是从立方体中心开始的标准化方向，而不是显式的纹理坐标。
	-- 立方体贴图图像中的每个面都必须具有正方形尺寸。
	-- 对于接受包含多个立方体贴图面的单个图像的此函数的变体，它们必须在图像中以以下形式之一布局：
	-- +y
	-- +z +x -z
	-- -y
	-- -x
	-- 或：
	-- +y
	-- -x +z +x -z
	-- -y
	-- 或：
	-- +x
	-- -x
	-- +y
	-- -y
	-- +z
	-- -z
	-- 或：
	-- +x -x +y -y +z -z
	-- 重载说明：
	-- 1. 在给定包含多个立方体面的单个图像文件的情况下创建立方体贴图图像。 2. 创建立方体贴图图像，并为每个立方体面指定不同的图像文件。
	-- @param faces ({ImageData}) 包含 6 个图像文件路径（或 File、FileData、ImageData 或 CompressedImageData 对象）的表，位于数组中。每个面部图像必须具有相同的尺寸。还可以给出表的表，其中每个子表包含该子表的立方体面索引的所有mipmap级别。
	-- @param settings (LayeredImageSettings) 用于配置立方体贴图图像的可选设置表，包含以下字段：（默认值：nil。） mipmaps: 如果为 true 则使图像使用 mipmap，为 false 则禁用它们。如果图像不是压缩纹理格式，则会自动生成 Mipmap。 （默认值：假。） linear: 如果启用伽马校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。）
	-- @return (Image) 立方体贴图图像对象。
	newCubeImage: function(faces: {ImageData}, settings?: LayeredImageSettings): Image

	-- 创建新体积 (3D) 图像。
	-- 体积图像是具有宽度、高度和深度的 3D 纹理。它们不能直接渲染，只能在着色器代码中使用（并通过 Shader:send 发送到着色器）。
	-- 要在Shader中使用体积图像，必须将其声明为VolumeImage或sampler3D类型（而不是Image或sampler2D）。必须使用 Texel(VolumeImage image, vec3 texcoords)
	-- 着色器函数从体积图像中获取像素颜色。 vec3 参数是标准化纹理坐标，其中 z 分量表示采样深度（范围从 1 开始）。
	-- 体积图像通常用作着色器中颜色分级的查找表，例如，因为使用两个像素之间的纹理坐标进行采样可以在体积图像中的所有 3 个维度上进行插值，从而即使在使用小尺寸体积图像作为查找表时也会产生平滑的渐变。
	-- 数组图像是比体积图像更好的选择，用于将多个不同的精灵存储在单个数组图像中以便直接绘制它们。
	-- 重载说明：
	-- 1. 在给定多个具有匹配尺寸的图像文件的情况下创建体积图像。某些较旧的移动设备不支持卷映像。使用 love.graphics.getTextureTypes 在运行时检查。
	-- @param slices ({ImageData}) 一个表，其中包含数组中图像（或 File、FileData、ImageData 或 CompressedImageData 对象）的文件路径。还可以给出表中的表，其中每个子表代表单个 mipmap 级别并包含该 mipmap 的所有层。
	-- @param settings (LayeredImageSettings) 用于配置卷映像的可选设置表，包含以下字段：（默认值：nil。） mipmaps: 如果为 true 则使图像使用 mipmap，为 false 则禁用它们。如果图像不是压缩纹理格式，则会自动生成 Mipmap。 （默认值：假。） linear: 如果启用伽马校正渲染，则将图像像素视为线性而不是 sRGB。大多数图像都是以 sRGB 格式创作的。 （默认值：假。）
	-- @return (Image) 体积图像对象。
	newVolumeImage: function(slices: {ImageData}, settings?: LayeredImageSettings): Image

	-- 创建一个新的 Canvas 对象用于离屏渲染。
	-- @return (Canvas) canvas — 尺寸等于窗口大小（以像素为单位）的新画布。
	newCanvas: function(): Canvas

	-- 创建一个新的 Canvas 对象用于离屏渲染。
	-- @param width (integer) 画布所需的宽度。
	-- @param height (integer) 画布所需的高度。
	-- @param settings (CanvasSettings) 包含给定字段的表：（默认值：nil。）
	-- @return (Canvas) 具有指定宽度和高度的新画布。
	newCanvas: function(width: integer, height: integer, settings?: CanvasSettings): Canvas

	-- 获取可用的 Canvas 格式以及是否支持每种格式。
	-- @param readable (boolean) 如果为 true，则仅当该格式的可读标志设置为 true 时，返回的格式才会被指示为受支持，反之亦然，如果参数为 false。
	-- @param formats ({string: boolean}) formats 参数。
	-- @return ({string: boolean}) 包含 CanvasFormats 作为键的表，以及一个指示是否支持该格式作为值的布尔值。并非所有系统都支持所有格式。取决于重载：包含 CanvasFormats 作为键的表，以及指示是否支持该格式作为值的布尔值（考虑到可读参数）。并非所有系统都支持所有格式。
	getCanvasFormats: function(readable?: boolean, formats?: {string: boolean}): {string: boolean}

	-- 将绘图操作捕获到画布上。
	setCanvas: function()

	-- 将绘图操作捕获到画布上。
	-- @param canvas (Canvas) 新的渲染目标。
	-- @param canvases (Canvas...) 指定活动画布、其 mipmap 级别和活动图层（如果适用）以及是否使用模板和/或深度缓冲区的表。
	setCanvas: function(canvas: Canvas, canvases: Canvas...)

	-- 将绘图操作捕获到画布上。
	-- @param canvases ({Canvas}) 指定活动画布、其 mipmap 级别和活动图层（如果适用）以及是否使用模板和/或深度缓冲区的表。
	setCanvas: function(canvases: {Canvas})

	-- 将绘图操作捕获到画布上。
	-- @param setup (CanvasSetup) 指定活动画布、其 mipmap 级别和活动层（如果适用）以及是否使用模板和/或深度缓冲区的表格。
	setCanvas: function(setup: CanvasSetup)

	-- 获取当前目标Canvas。
	-- @return (Canvas or nil) setCanvas 设置的 Canvas。如果绘制到真实屏幕则返回 nil。
	getCanvas: function(): Canvas | nil

	-- 创建一个新的四边形。
	--
	-- Quad 的目的是使用图像的一部分来绘制对象，而不是绘制整个图像。它对于精灵表和图集最有用：在精灵图集中，多个精灵驻留在同一图像中，四边形用于从该图像中绘制特定的精灵；在所有帧都驻留在同一图像中的动画精灵中，四边形用于从动画中绘制特定帧。
	-- @param x (number) 图像中沿 x 轴的左上角位置。
	-- @param y (number) 图像中沿 y 轴的左上角位置。
	-- @param width (number) 图像中四边形的宽度。 （必须大于 0。）
	-- @param height (number) 图像中四边形的高度。 （必须大于 0。）
	-- @param image (Image | Canvas) 纹理的宽度和高度将用作参考宽度和高度。
	-- @return (Quad) quad — 新的四边形。
	newQuad: function(x: number, y: number, width: number, height: number, image: Image | Canvas): Quad

	-- 创建一个新的四边形。
	--
	-- Quad 的目的是使用图像的一部分来绘制对象，而不是绘制整个图像。它对于精灵表和图集最有用：在精灵图集中，多个精灵驻留在同一图像中，四边形用于从该图像中绘制特定的精灵；在所有帧都驻留在同一图像中的动画精灵中，四边形用于从动画中绘制特定帧。
	-- @param x (number) 图像中沿 x 轴的左上角位置。
	-- @param y (number) 图像中沿 y 轴的左上角位置。
	-- @param width (number) 图像中四边形的宽度。 （必须大于 0。）
	-- @param height (number) 图像中四边形的高度。 （必须大于 0。）
	-- @param texture_width (number) 参考宽度，Image的宽度。 （必须大于 0。）
	-- @param texture_height (number) 参考高度，Image的高度。 （必须大于 0。）
	-- @return (Quad) quad — 新的四边形。
	newQuad: function(x: number, y: number, width: number, height: number, texture_width: number, texture_height: number): Quad

	-- 创建一个新的网格。
	--
	-- 如果网格在绘制时应使用图像或画布进行纹理化，请使用 Mesh:setTexture 。
	--
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	-- @param vertices ({MeshVertex} | number) 该表填充了每个顶点的顶点信息表，如下所示：
	-- @param draw_mode (MeshDrawMode) 绘制时如何使用顶点。默认模式 'fan' 对于简单的凸多边形来说已经足够了。 （默认值：'fan'。）
	-- @param usage (MeshUsage) 网格的预期用途。指定的使用模式会影响Mesh的内存使用和性能。 （默认：'dynamic'。）
	-- @return (Mesh) mesh — 新网格。
	newMesh: function(vertices: {MeshVertex} | number, draw_mode?: MeshDrawMode, usage?: MeshUsage): Mesh

	-- 创建一个新的网格。
	--
	-- 如果网格在绘制时应使用图像或画布进行纹理化，请使用 Mesh:setTexture 。
	--
	-- 在11.0之前的版本中，颜色和字节分量值的范围是0到255，而不是0到1。
	-- @param format ({MeshVertexFormat}) , ...} 形式的表。每个属性都是一个表，其中指定用于每个顶点的自定义顶点属性。
	-- @param vertices ({MeshVertex} | number | Data) 该表填充了每个顶点的顶点信息表，其形式为{vertex, ...}，其中每个顶点是一个形式为{attributecomponent, ...}的表。
	-- @param draw_mode (MeshDrawMode) 绘制网格时使用的图像或画布。不使用纹理可能为零。 （默认值：无。）
	-- @param usage (MeshUsage) 网格的预期用途。指定的使用模式会影响Mesh的内存使用和性能。 （默认：'dynamic'。）
	-- @return (Mesh) mesh — 新网格。
	newMesh: function(format: {MeshVertexFormat}, vertices: {MeshVertex} | number | Data, draw_mode?: MeshDrawMode, usage?: MeshUsage): Mesh

	-- 创建一个新的 SpriteBatch 对象。
	-- @param texture (Image or Canvas) 用于精灵的图像或画布。
	-- @param size (integer) SpriteBatch 在任何给定时间可以包含的精灵的最大数量。自版本 11.0 起，添加超过此数量的额外精灵将自动增加精灵批次。 （默认值：1000。）
	-- @param usage (string) SpriteBatch 的预期用法。指定的使用模式会影响SpriteBatch的内存使用和性能。 （默认：'dynamic'。）
	-- @return (SpriteBatch) 新的 SpriteBatch。
	newSpriteBatch: function(texture: Image | Canvas, size?: integer, usage?: string): SpriteBatch

	-- 创建一个新的粒子系统。
	-- @param texture (Image or Canvas) 要使用的纹理（图像或画布）。
	-- @param size (integer) 同时最大粒子数。 （默认值：1000。）
	-- @return (ParticleSystem) 一个新的粒子系统。
	newParticleSystem: function(texture: Image | Canvas, size?: integer): ParticleSystem

	-- 为硬件加速顶点和像素效果创建一个新的 Shader 对象。着色器包含顶点着色器代码、像素着色器代码或两者。
	-- 着色器是绘图时在显卡上运行的小程序。顶点着色器针对每个顶点运行一次（例如，图像有 4 个顶点 -
	-- 每个角各一个。网格可能有更多。）像素着色器针对绘制对象接触的屏幕上的每个像素运行一次。像素着色器代码在顶点着色器处理完所有对象的顶点后执行。
	-- @param source (string or FileData) 像素着色器代码，或指向包含该代码的文件的文件名。
	-- @param pixel_source (string or FileData) 顶点着色器代码，或指向包含该代码的文件的文件名。
	-- @return (Shader) 用于绘图操作的 Shader 对象。
	newShader: function(source: string | FileData, pixel_source?: string | FileData): Shader

	-- 验证着色器代码。检查指定的着色器代码是否不包含任何错误。
	-- @param gles (boolean) 验证代码为 GLSL ES 着色器。
	-- @param source (string or FileData) 像素着色器代码，或指向包含该代码的文件的文件名。
	-- @param pixel_source (string or FileData) 顶点着色器代码，或指向包含该代码的文件的文件名。
	-- @return (boolean) true 如果指定的着色器代码不包含任何错误。否则为假。
	-- @return (string or nil) 着色器代码验证失败的原因（如果验证成功则为零）。
	validateShader: function(gles: boolean, source: string | FileData, pixel_source?: string | FileData): boolean, string | nil

	-- 将着色器设置或重置为当前像素效果或顶点着色器。直到下一个“'love.graphics.setShader'”之前的所有绘制操作都将使用指定的 Shader 对象进行绘制。
	setShader: function()

	-- 将着色器设置或重置为当前像素效果或顶点着色器。直到下一个“'love.graphics.setShader'”之前的所有绘制操作都将使用指定的 Shader 对象进行绘制。
	-- @param shader (Shader) 新的着色器。
	setShader: function(shader: Shader)

	-- 获取当前的Shader。如果未设置则返回 nil。
	-- @return (Shader or nil) 当前活动的着色器，如果未设置则为零。
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
	-- @param image (Image) 可绘制对象。
	-- @param x (number) 绘制对象的位置（x 轴）。 （默认值：0。）
	-- @param y (number) 绘制对象的位置（y 轴）。 （默认值：0。）
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	draw: function(image: Image, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

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
	-- @param image (Image) 可绘制对象。
	-- @param quad (Quad) 在屏幕上绘制的四边形。
	-- @param x (number) 绘制对象的位置（x 轴）。
	-- @param y (number) 绘制对象的位置（y 轴）。
	-- @param angle (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_x (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param scale_y (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_x (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param origin_y (number) 剪切系数（x 轴）。 （默认值：0。）
	draw: function(image: Image, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- 在屏幕上绘制 Canvas，并可选择旋转、缩放和剪切。
	-- @param canvas (Canvas) 要绘制的 Canvas。
	-- @param x (number) 对象在 x 轴上的绘制位置。（默认值：0。）
	-- @param y (number) 对象在 y 轴上的绘制位置。（默认值：0。）
	-- @param angle (number) 以弧度表示的旋转角度。（默认值：0。）
	-- @param scale_x (number) x 轴缩放系数。（默认值：1。）
	-- @param scale_y (number) y 轴缩放系数。（默认值：scaleX。）
	-- @param origin_x (number) x 轴原点偏移。（默认值：0。）
	-- @param origin_y (number) y 轴原点偏移。（默认值：0。）
	draw: function(canvas: Canvas, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- 在屏幕上绘制 Canvas，并可选择旋转、缩放和剪切。
	-- @param canvas (Canvas) 要绘制的 Canvas。
	-- @param quad (Quad) 要绘制的可绘制对象子区域。
	-- @param x (number) 对象在 x 轴上的绘制位置。（默认值：0。）
	-- @param y (number) 对象在 y 轴上的绘制位置。（默认值：0。）
	-- @param angle (number) 以弧度表示的旋转角度。（默认值：0。）
	-- @param scale_x (number) x 轴缩放系数。（默认值：1。）
	-- @param scale_y (number) y 轴缩放系数。（默认值：scaleX。）
	-- @param origin_x (number) x 轴原点偏移。（默认值：0。）
	-- @param origin_y (number) y 轴原点偏移。（默认值：0。）
	draw: function(canvas: Canvas, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- 在屏幕上绘制 Mesh，并可选择旋转、缩放和剪切。
	-- @param mesh (Mesh) 要绘制的 Mesh。
	-- @param x (number) 对象在 x 轴上的绘制位置。（默认值：0。）
	-- @param y (number) 对象在 y 轴上的绘制位置。（默认值：0。）
	-- @param angle (number) 以弧度表示的旋转角度。（默认值：0。）
	-- @param scale_x (number) x 轴缩放系数。（默认值：1。）
	-- @param scale_y (number) y 轴缩放系数。（默认值：scaleX。）
	-- @param origin_x (number) x 轴原点偏移。（默认值：0。）
	-- @param origin_y (number) y 轴原点偏移。（默认值：0。）
	-- @param shear_x (number) x 轴剪切系数。（默认值：0。）
	-- @param shear_y (number) y 轴剪切系数。（默认值：0。）
	draw: function(mesh: Mesh, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 在屏幕上绘制 SpriteBatch，并可选择旋转、缩放和剪切。
	-- @param batch (SpriteBatch) 要绘制的 SpriteBatch。
	-- @param x (number) 对象在 x 轴上的绘制位置。（默认值：0。）
	-- @param y (number) 对象在 y 轴上的绘制位置。（默认值：0。）
	-- @param angle (number) 以弧度表示的旋转角度。（默认值：0。）
	-- @param scale_x (number) x 轴缩放系数。（默认值：1。）
	-- @param scale_y (number) y 轴缩放系数。（默认值：scaleX。）
	-- @param origin_x (number) x 轴原点偏移。（默认值：0。）
	-- @param origin_y (number) y 轴原点偏移。（默认值：0。）
	-- @param shear_x (number) x 轴剪切系数。（默认值：0。）
	-- @param shear_y (number) y 轴剪切系数。（默认值：0。）
	draw: function(batch: SpriteBatch, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 在屏幕上绘制 ParticleSystem，并可选择旋转、缩放和剪切。
	-- @param particles (ParticleSystem) 要绘制的 ParticleSystem。
	-- @param x (number) 对象在 x 轴上的绘制位置。（默认值：0。）
	-- @param y (number) 对象在 y 轴上的绘制位置。（默认值：0。）
	-- @param angle (number) 以弧度表示的旋转角度。（默认值：0。）
	-- @param scale_x (number) x 轴缩放系数。（默认值：1。）
	-- @param scale_y (number) y 轴缩放系数。（默认值：scaleX。）
	-- @param origin_x (number) x 轴原点偏移。（默认值：0。）
	-- @param origin_y (number) y 轴原点偏移。（默认值：0。）
	-- @param shear_x (number) x 轴剪切系数。（默认值：0。）
	-- @param shear_y (number) y 轴剪切系数。（默认值：0。）
	draw: function(particles: ParticleSystem, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 在屏幕上绘制 Text，并可选择旋转、缩放和剪切。
	-- @param text (Text) 要绘制的 Text 对象。
	-- @param x (number) 对象在 x 轴上的绘制位置。（默认值：0。）
	-- @param y (number) 对象在 y 轴上的绘制位置。（默认值：0。）
	-- @param angle (number) 以弧度表示的旋转角度。（默认值：0。）
	-- @param scale_x (number) x 轴缩放系数。（默认值：1。）
	-- @param scale_y (number) y 轴缩放系数。（默认值：scaleX。）
	-- @param origin_x (number) x 轴原点偏移。（默认值：0。）
	-- @param origin_y (number) y 轴原点偏移。（默认值：0。）
	-- @param shear_x (number) x 轴剪切系数。（默认值：0。）
	-- @param shear_y (number) y 轴剪切系数。（默认值：0。）
	draw: function(text: Text, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 在屏幕上绘制 Video，并可选择旋转、缩放和剪切。
	-- @param video (Video) 要绘制的 Video。
	-- @param x (number) 对象在 x 轴上的绘制位置。（默认值：0。）
	-- @param y (number) 对象在 y 轴上的绘制位置。（默认值：0。）
	-- @param angle (number) 以弧度表示的旋转角度。（默认值：0。）
	-- @param scale_x (number) x 轴缩放系数。（默认值：1。）
	-- @param scale_y (number) y 轴缩放系数。（默认值：scaleX。）
	-- @param origin_x (number) x 轴原点偏移。（默认值：0。）
	-- @param origin_y (number) y 轴原点偏移。（默认值：0。）
	-- @param shear_x (number) x 轴剪切系数。（默认值：0。）
	-- @param shear_y (number) y 轴剪切系数。（默认值：0。）
	draw: function(video: Video, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number, shear_x?: number, shear_y?: number)

	-- 绘制表纹理的一层。
	-- @param image (Image) 要绘制的表纹理。
	-- @param layer (integer) 绘制时使用的图层的索引。
	-- @param x (number) 绘制纹理的位置（x 轴）。 （默认值：0。）
	-- @param y (number) 绘制纹理的位置（y 轴）。 （默认值：0。）
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	drawLayer: function(image: Image, layer: integer, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- 绘制表纹理的一层。
	-- @param image (Image) 要绘制的表纹理。
	-- @param layer (integer) 绘制时使用的图层的索引。
	-- @param quad (Quad) 绘制时使用的纹理层的分段。
	-- @param x (number) 绘制纹理的位置（x 轴）。 （默认值：0。）
	-- @param y (number) 绘制纹理的位置（y 轴）。 （默认值：0。）
	-- @param angle (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_x (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param scale_y (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_x (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param origin_y (number) 剪切系数（x 轴）。 （默认值：0。）
	drawLayer: function(image: Image, layer: integer, quad: Quad, x?: number, y?: number, angle?: number, scale_x?: number, scale_y?: number, origin_x?: number, origin_y?: number)

	-- 使用硬件几何实例，通过一次绘制调用绘制网格的许多实例。
	-- 每个实例都可以具有唯一的属性（位置、颜色等），但默认情况下不会，除非使用自定义的每个实例顶点属性或 love_InstanceID GLSL 3 顶点着色器变量，否则它们将全部渲染在彼此之上的相同位置。
	-- 某些旧版 GPU 不支持实例化，这些 GPU 只能使用 OpenGL ES 2 或 OpenGL 2。使用 love.graphics.getSupported 进行检查。
	-- @param mesh (Mesh) 要渲染的网格物体。
	-- @param instance_count (integer) 要渲染的实例数。
	-- @param x (number) 绘制实例的位置（x 轴）。 （默认值：0。）
	-- @param y (number) 绘制实例的位置（y 轴）。 （默认值：0。）
	-- @param angle (number) 方向（弧度）。 （默认值：0。）
	-- @param scale_x (number) 比例因子（x 轴）。 （默认值：1。）
	-- @param scale_y (number) 比例因子（y 轴）。 （默认值：sx。）
	-- @param origin_x (number) 原点偏移（x 轴）。 （默认值：0。）
	-- @param origin_y (number) 原点偏移（y 轴）。 （默认值：0。）
	-- @param shear_x (number) 剪切因子（x 轴）。 （默认值：0。）
	-- @param shear_y (number) 剪切因子（y 轴）。 （默认值：0。）
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
		-- 重载说明：
		-- 1. id 值与用作 love.touchpressed、love.touchmoved 和 love.touchreleased. 参数的 id 值相同。特定触摸按下的 id 值仅保证在该触摸按下期间是唯一的。一旦使用该
		-- ID 调用 love.touchreleased，它就可以通过 love.touchpressed.
		-- @return ({TouchID}) 活动触摸按键 ID 值列表，可与 love.touch.getPosition.
		getTouches: function(): {TouchID}

		-- 获取指定触摸的当前位置（以像素为单位）。
		-- 重载说明：
		-- 1. LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为 1 范围内的标准化值，而此 API 报告的位置以像素为单位。
		-- @param id (TouchID) 触摸按键的标识符。使用 love.touch.getTouches、love.touchpressed 或 love.touchmoved 获取触摸 ID 值。
		-- @return (number) 窗口内触摸按键沿 x 轴的位置（以像素为单位）。
		-- @return (number) 窗口内触摸按键沿 y 轴的位置（以像素为单位）。
		getPosition: function(id: TouchID): number, number

		-- 获取指定触摸的当前压力。
		-- @param id (TouchID) 触摸按键的标识符。使用 love.touch.getTouches、love.touchpressed 或 love.touchmoved 获取触摸 ID 值。
		-- @return (number) 触摸压力。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
		getPressure: function(id: TouchID): number
	end

	-- 代表物理操纵杆。
	record Joystick

		-- 获取字符串形式的对象类型。
		-- @return (string) 字符串类型。
		type: function(self: Joystick): string

		-- 检查对象是否属于某种类型。如果对象的层次结构中具有指定名称的类型，则此函数将返回 true。
		-- @param type_name (string) 要检查的类型的名称。
		-- @return (boolean) 如果对象属于指定类型，则为 true，否则为 false。
		typeOf: function(self: Joystick, type_name: string): boolean

		-- 销毁对象的 Lua 引用。如果该对象未被任何其他 LÖVE 对象或线程引用，则该对象将被完全删除。
		-- 这个方法可以用来立即清理资源，而不需要等待Lua的垃圾收集器。
		-- @return (boolean) 如果对象已通过此调用释放，则为 true；如果先前已释放过该对象，则为 false。
		release: function(self: Joystick): boolean

		-- 获取Joystick是否已连接。
		-- @return (boolean) 如果操纵杆当前已连接，则为 true，否则为 false。
		isConnected: function(self: Joystick): boolean

		-- 获取操纵杆的名称。
		-- @return (string) 操纵杆的名称。
		getName: function(self: Joystick): string

		-- 获取操纵杆的唯一标识符。即使操纵杆断开连接并重新连接，标识符在游戏的生命周期中也将保持不变，但当游戏重新启动时，它“'will'”会发生变化。
		-- @return (integer) 操纵杆的唯一标识符。只要游戏运行，就保持不变。
		-- @return (integer or nil) 唯一实例标识符。每次重新连接操纵杆时都会发生变化。如果操纵杆未连接则为零。
		getID: function(self: Joystick): integer, integer | nil

		-- 获取物理操纵杆类型所特有的稳定 GUID，该 GUID 不会随时间变化。例如，OS X 中的所有 Sony Dualshock 3 控制器都具有相同的 GUID。该值取决于平台。
		-- @return (string) 操纵杆类型的依赖于操作系统的唯一标识符。
		getGUID: function(self: Joystick): string

		-- 获取操纵杆的 USB 供应商 ID、产品 ID 和产品版本号，这些信息在不同操作系统中保持一致。
		-- 可用于为不同的游戏手柄显示不同的图标等。
		-- 重载说明：
		-- 1. 某些 Linux 发行版可能未附带 SDL 2.0.6 或更高版本，在这种情况下，此函数将为所有三个值返回 0。
		-- @return (integer) 操纵杆的 USB 供应商 ID。
		-- @return (integer) 操纵杆的 USB 产品 ID。
		-- @return (integer) 操纵杆的产品版本。
		getDeviceInfo: function(self: Joystick): integer, integer, integer

		-- 获取操纵杆上的轴数。
		-- @return (integer) 可用轴的数量。
		getAxisCount: function(self: Joystick): integer

		-- 获取操纵杆上的按钮数量。
		-- @return (integer) 可用按钮的数量。
		getButtonCount: function(self: Joystick): integer

		-- 获取操纵杆上的帽子数量。
		-- @return (integer) 操纵杆有多少顶帽子。
		getHatCount: function(self: Joystick): integer

		-- 获取轴的方向。
		-- @param axis (integer) 要检查的轴的索引。
		-- @return (number) 轴的当前值。
		getAxis: function(self: Joystick, axis: integer): number

		-- 获取每个轴的方向。
		-- @return (number...) 轴 1 的方向。
		getAxes: function(self: Joystick): number...

		-- 获取操纵杆帽子的方向。
		-- @param hat (integer) 要检查的帽子的索引。
		-- @return (string) 帽子被推的方向。
		getHat: function(self: Joystick, hat: integer): string

		-- 检查操纵杆上的按钮是否被按下。
		-- LÖVE 0.9.0 有一个错误，要求传递给 Joystick:isDown 的按钮索引是基于 0 的而不是基于 1 的，例如对于此功能，按钮 1 将为 0。它在 0.9.1 中被修复。
		-- @param buttons (integer...) 要检查的按钮的索引。
		-- @return (boolean) 如果任何提供的按钮被按下，则为 True，否则为 false。
		isDown: function(self: Joystick, buttons: integer...): boolean

		-- 获取Joystick是否被识别为游戏手柄。如果是这种情况，则可以通过 Joystick:getGamepadAxis、Joystick:isGamepadDown、love.gamepadpressed
		-- 和相关函数，在不同的操作系统和操纵杆型号中以标准化方式使用操纵杆的按钮和轴。
		-- LÖVE 自动识别与 Xbox 360 控制器布局相似的最流行的控制器作为游戏手柄，但您可以使用 love.joystick.setGamepadMapping.
		-- 重载说明：
		-- 1. 如果操纵杆被识别为游戏手柄，则虚拟游戏手柄轴和按钮的物理位置尽可能与标准 Xbox 360 控制器的布局相对应。
		-- @return (boolean) 如果操纵杆被识别为游戏手柄则为 true，否则为 false。
		isGamepad: function(self: Joystick): boolean

		-- 检查是否按下了操纵杆上的虚拟游戏手柄按钮。如果操纵杆未被识别为游戏手柄或未连接，则此函数将始终返回 false。
		-- @param buttons (string...) 要检查的游戏手柄按钮。
		-- @return (boolean) 如果任何提供的按钮被按下，则为 True，否则为 false。
		isGamepadDown: function(self: Joystick, buttons: string...): boolean

		-- 获取虚拟游戏手柄轴的方向。如果操纵杆未被识别为游戏手柄或未连接，此函数将始终返回 0。
		-- @param axis (string) 要检查的虚拟轴。
		-- @return (number) 轴的当前值。
		getGamepadAxis: function(self: Joystick, axis: string): number

		-- 获取虚拟游戏手柄输入绑定的按钮、轴或帽子。
		-- 重载说明：
		-- 1. 如果操纵杆未被识别为游戏手柄或虚拟游戏手柄轴未绑定到操纵杆输入，则返回 nil。 2. 虚拟游戏手柄轴和按钮的物理位置尽可能与标准 Xbox 360 控制器的布局相对应。
		-- @param input (string) 要获取绑定的虚拟游戏手柄轴。根据过载：要获取绑定的虚拟游戏手柄按钮。
		-- @return (string or nil) 虚拟游戏手柄轴绑定的输入类型。取决于过载：虚拟游戏手柄按钮绑定的输入类型。
		-- @return (integer or nil) 虚拟游戏手柄轴绑定到的操纵杆按钮、轴或帽子的索引。 取决于过载：虚拟游戏手柄按钮绑定到的操纵杆按钮、轴或帽子的索引。
		-- @return (string or nil) 帽子的方向（如果虚拟游戏手柄轴绑定到帽子）。否则为零。取决于过载：帽子的方向（如果虚拟游戏手柄按钮绑定到帽子）。否则为零。
		getGamepadMapping: function(self: Joystick, input: string): string | nil, integer | nil, string | nil

		-- 获取此操纵杆的完整游戏手柄映射字符串，如果未将其识别为游戏手柄，则返回 nil。
		-- 映射字符串包含用于将操纵杆的按钮和轴映射到标准游戏手柄布局的绑定信息，并且可以在以后与 love.joystick.loadGamepadMappings.
		-- @return (string or nil) 包含操纵杆的游戏手柄映射的字符串，如果操纵杆未被识别为游戏手柄则为零。
		getGamepadMappingString: function(self: Joystick): string | nil

		-- 获取Joystick是否支持振动。
		-- 重载说明：
		-- 1. 第一次调用此函数可能会比预期花费更多时间，因为需要初始化 SDL 的触觉/力反馈子系统。
		-- @return (boolean) 如果此操纵杆支持隆隆声/力反馈振动，则为 true，否则为 false。
		isVibrationSupported: function(self: Joystick): boolean

	-- 设置带有震动支持的操纵杆上的振动电机速度。大多数常见的游戏手柄都具有此功能，但并非所有驱动程序都提供适当的支持。使用Joystick:isVibrationSupported进行检查。
	-- @return (boolean) success — 如果振动成功应用则为 true，否则为 false。
	setVibration: function(self: Joystick): boolean

	-- 设置带有震动支持的操纵杆上的振动电机速度。大多数常见的游戏手柄都具有此功能，但并非所有驱动程序都提供适当的支持。使用Joystick:isVibrationSupported进行检查。
	-- @param left (number) 操纵杆上左侧振动电机的强度。必须在 1 范围内。
	-- @param right (number) 操纵杆上右侧振动电机的强度。必须在 1 范围内。
	-- @param duration (number) 振动的持续时间（以秒为单位）。负值意味着无限的持续时间。 （默认值：-1。）
	-- @return (boolean) 如果振动已成功禁用，则为 true；如果未成功禁用，则为 false。
	setVibration: function(self: Joystick, left: number, right?: number, duration?: number): boolean

		-- 获取支持震动的操纵杆上当前的振动电机强度。
		-- @return (number or integer or nil) 操纵杆上左侧振动电机的当前强度。
		-- @return (number) 操纵杆上右侧振动电机的当前强度。
		getVibration: function(self: Joystick): number, number
		getConnectedIndex: function(self: Joystick): integer | nil
	end

	-- 提供用户操纵杆的接口。
	record JoystickModule

		-- 获取已连接操纵杆的列表。
		-- @return ({Joystick}) 当前连接的操纵杆列表。
		getJoysticks: function(): {Joystick}

		-- 获取连接的操纵杆数量。
		-- @return (integer) 连接的操纵杆数量。
		getJoystickCount: function(): integer

	-- 将虚拟游戏手柄输入绑定到特定类型的所有操纵杆的按钮、轴或帽子。例如，如果此函数与 OS X 中的 Dualshock 3 控制器返回的 GUID 一起使用，则绑定将影响在 OS X 中运行时与游戏一起使用的“'all'”Dualshock 3 控制器的 Joystick:getGamepadAxis 和 Joystick:isGamepadDown。
	--
	-- LÖVE 包含许多常见控制器的内置游戏手柄绑定。此功能允许您更改默认情况下不被识别为游戏手柄的操纵杆类型的绑定或添加新的绑定。
	--
	-- 虚拟游戏手柄按钮和轴是围绕 Xbox 360 控制器布局设计的。
	-- @param guid (string) 绑定将影响的操纵杆类型的依赖于操作系统的 GUID。
	-- @param input (GamepadAxis | GamepadButton) 要绑定的虚拟游戏手柄按钮。
	-- @param type (string) 将虚拟游戏手柄按钮绑定到的输入类型。
	-- @param index (integer) 将虚拟游戏手柄按钮绑定到的轴、按钮或帽子的索引。
	-- @return (boolean) success — 虚拟手柄按键是否绑定成功。
	setGamepadMapping: function(guid: string, input: GamepadAxis | GamepadButton, type: string, index: integer): boolean

	-- 将虚拟游戏手柄输入绑定到特定类型的所有操纵杆的按钮、轴或帽子。例如，如果此函数与 OS X 中的 Dualshock 3 控制器返回的 GUID 一起使用，则绑定将影响在 OS X 中运行时与游戏一起使用的“'all'”Dualshock 3 控制器的 Joystick:getGamepadAxis 和 Joystick:isGamepadDown。
	--
	-- LÖVE 包含许多常见控制器的内置游戏手柄绑定。此功能允许您更改默认情况下不被识别为游戏手柄的操纵杆类型的绑定或添加新的绑定。
	--
	-- 虚拟游戏手柄按钮和轴是围绕 Xbox 360 控制器布局设计的。
	-- @param guid (string) 绑定将影响的操纵杆类型的依赖于操作系统的 GUID。
	-- @param input (GamepadAxis | GamepadButton) 要绑定的虚拟游戏手柄轴。
	-- @param type (string) 将虚拟游戏手柄轴绑定到的输入类型。
	-- @param index (integer) 将虚拟游戏手柄轴绑定到的轴、按钮或帽子的索引。
	-- @param direction (JoystickHat) 帽子的方向，如果虚拟游戏手柄轴将绑定到帽子。否则为零。 （默认值：无。）
	-- @return (boolean) 情况：虚拟手柄轴是否绑定成功。
	setGamepadMapping: function(guid: string, input: GamepadAxis | GamepadButton, type: string, index: integer, direction: JoystickHat): boolean

		-- 加载使用 love.joystick.saveGamepadMappings. 创建的游戏手柄映射字符串或文件
		-- 它还可以识别任何 SDL 游戏控制器映射字符串，例如使用 Steam 的 Big Picture 控制器配置界面或这个漂亮的数据库创建的字符串。如果为已知的控制器 GUID 加载新映射，则更高版本将覆盖当前加载的映射。
		-- 重载说明：
		-- 1. 从文件加载游戏手柄映射字符串。 2. 直接加载游戏手柄映射字符串。
		-- @param mappings_or_filename (string) 从中加载映射字符串的文件名。取决于重载：要加载的映射字符串。
		loadGamepadMappings: function(mappings_or_filename: string)

	-- 保存所有被识别为游戏手柄并且最近使用过或者其游戏手柄绑定已被修改的虚拟游戏手柄映射。
	--
	-- 映射存储为字符串，以便与 love.joystick.loadGamepadMappings.
	-- @return (string) mappings — 写入文件的映射字符串。
	saveGamepadMappings: function(): string

	-- 保存所有被识别为游戏手柄并且最近使用过或者其游戏手柄绑定已被修改的虚拟游戏手柄映射。
	--
	-- 映射存储为字符串，以便与 love.joystick.loadGamepadMappings.
	-- @param filename (string) 保存映射字符串的文件名。
	-- @return (string) 映射字符串。
	saveGamepadMappings: function(filename: string): string

		-- 获取具有给定 GUID 的操纵杆的完整游戏手柄映射字符串，如果 GUID 未被识别为游戏手柄，则返回 nil。
		-- 映射字符串包含用于将操纵杆的按钮和轴映射到标准游戏手柄布局的绑定信息，并且可以在以后与 love.joystick.loadGamepadMappings.
		-- @param guid (string) 要获取其映射字符串的 GUID 值。
		-- @return (string or nil) 包含操纵杆游戏手柄映射的字符串，如果 GUID 未被识别为游戏手柄则为零。
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
	-- @param config (Config) love.conf 函数采用一个参数：一张包含所有默认值的表，您可以根据自己的喜好覆盖这些默认值。例如，如果您想更改默认窗口大小，请执行以下操作： function love.conf(t) t.window.width = 1024 t.window.height = 768 end 如果您不需要物理模块或操纵杆模块，请执行以下操作。 function love.conf(t) t.modules.joystick = false t.modules.physicals = false end 当您发布游戏时，鼓励将未使用的模块设置为 false。它会稍微减少启动时间（特别是在禁用操纵杆模块的情况下）并减少内存使用量（稍微）。请注意，您无法禁用 love.filesystem；这是强制性的。爱情模块本身也是如此。 love.graphics 需要启用 love.window。 identity: 该标志确定游戏的保存目录的名称。请注意，您只能指定名称，而不能指定创建位置： t.identity = "gabe_HL3" -- 正确 t.identity = "c:/Users/gabe/HL3" -- 不正确 或者 love.filesystem.setIdentity 可用于在配置文件之外设置保存目录。 （默认值：无。） appendidentity: 该标志决定是否应先搜索游戏目录然后保存目录（true）或否则（false）（默认值：false。） version: t.version 应该是一个字符串，代表您的游戏所针对的 LÖVE 版本。它的格式应为 "X.Y.Z"，其中 X 是主要版本号，Y 是次要版本号，Z 是补丁级别。它允许 LÖVE 在不兼容时显示警告。它的默认值是运行的 LÖVE 版本。 （默认："11.5"。） console: 确定是否应在游戏窗口旁边打开控制台（仅限 Windows）。 注意：在 OSX 上，您可以通过终端运行 LÖVE 来获取控制台输出。 （默认值：假。） accelerometerjoystick: 设置 iOS 和 Android 上的设备加速计是否应显示为 3 轴操纵杆。不使用时禁用加速计可能会减少 CPU 使用率。 （默认值：true。） externalstorage: 设置文件是保存在 Android 上的外部存储（true）还是内部存储（false）中。 （默认值：假。） gammacorrect: 确定是否启用伽玛校正渲染（当系统支持时）。 （默认值：假。） audio: 音频选项。 audio.mic: 向用户请求麦克风权限。当用户允许时，love.audio.getRecordingDevices 将列出可用的录音设备。否则，love.audio.getRecordingDevices 返回空表，并在调用时显示一条消息以通知用户。 （默认值：假。） audio.mixwithsystem: 设置 LÖVE 打开时是否播放其他应用程序的背景音频/音乐。有关更多详细信息，请参阅 love.system.hasBackgroundMusic。 （默认值：true。） window: 可以推迟窗口创建，直到在代码中首次调用 love.window.setMode 。 为此，请在 love.conf 中设置 t.window = nil （或在旧版本中设置 t.screen = nil。）如果这样做，如果在代码中的第一个 love.window.setMode 之前调用 love.graphics 中的任何函数，LÖVE 可能会崩溃。 t.window 表在 0.9.0 之前的版本中被命名为 t.screen。 0.9.0 中的 love.conf 中不存在 t.screen 表，0.8.0 中的 love.conf 中不存在 t.window 表。这意味着如果不注意为正在使用的 LÖVE 版本使用正确的表，love.conf 将无法执行（因此它将回退到默认值）。 window.title: 设置游戏所在窗口的标题。或者可以使用 love.window.setTitle 在配置文件之外更改窗口标题。 （默认："Untitled"。） window.icon: 用作窗口图标的图像的文件路径。并非所有操作系统都支持非常大的图标图像。也可以使用 love.window.setIcon. 更改图标（默认值：nil。） window.width: 设置窗口的尺寸。如果这些标志设置为 0，LÖVE 会自动使用用户的桌面尺寸。 （默认值：800。） window.height: 设置窗口的尺寸。如果这些标志设置为 0，LÖVE 会自动使用用户的桌面尺寸。 （默认值：600。） window.borderless: 从窗口中删除所有边框视觉效果。请注意，不同操作系统的影响可能会有所不同。 （默认值：假。） window.resizable: 如果设置为 true，则允许用户调整游戏窗口的大小。 （默认值：假。） window.minwidth: 设置游戏窗口的最小宽度和高度（如果用户可以调整其大小）。如果您将 window.width 和 window.height 设置较低的值，LÖVE 将始终支持通过 window.minwidth 和 window.minheight 设置的最小尺寸。 （默认值：1。） window.minheight: 设置游戏窗口的最小宽度和高度（如果用户可以调整其大小）。如果您将 window.width 和 window.height 设置较低的值，LÖVE 将始终支持通过 window.minwidth 和 window.minheight 设置的最小尺寸。 （默认值：1。） window.fullscreen: 是否以全屏（true）或窗口（false）模式运行游戏。也可以通过 love.window.setFullscreen 或 love.window.setMode. 切换全屏（默认： false。） window.fullscreentype: 指定要使用的全屏模式类型（正常或桌面）。通常建议使用桌面，因为它在某些操作系统上比正常模式限制更少。 （默认："desktop"。） window.usedpiscale: 设置是否启用或禁用自动 DPI 缩放。 （默认值：true。） window.vsync: 启用或禁用垂直同步。垂直同步尝试使游戏保持稳定的帧速率，并可以防止屏幕撕裂等问题。如果您不知道关闭垂直同步可能产生的影响，建议保持垂直同步处于激活状态。在 LÖVE 11.0 之前，该值是布尔值（true 或 false）。从 LÖVE 11.0 开始，该值为数字（1 表示启用垂直同步，0 表示禁用垂直同步，-1 表示在支持时使用自适应垂直同步）。请注意，在 iOS 中，垂直同步始终处于启用状态且无法更改。 （默认值：true。） window.depth: 深度缓冲区中每个样本的位数（16/24/32，默认为 nil）（默认：nil。） window.stencil: 然后是深度缓冲区中每个样本的位数（一般为 8，默认为 nil）（默认：nil。） window.msaa: 用于多重采样抗锯齿的样本数。 （默认值：0。） window.display: 如果有多个监视器可用，则显示窗口的显示器索引。 （默认值：1。） window.highdpi: 请参阅 love.window.getPixelScale、love.window.toPixels 和 love.window.fromPixels. 如果您无法在具有 Retina 显示屏的 Mac 或 iOS 系统上测试游戏，建议禁用此选项，因为代码需要调整以确保内容看起来正确。 （默认值：假。） window.x: 确定窗口在用户屏幕上的位置。或者 love.window.setPosition 可用于动态更改位置。 （默认值：无。） window.y: 确定窗口在用户屏幕上的位置。或者 love.window.setPosition 可用于动态更改位置。 （默认值：无。） modules: 模块选项。 modules.audio: 启用音频模块。 （默认值：true。） modules.event: 启用事件模块。 （默认值：true。） modules.graphics: 启用图形模块。 （默认值：true。） modules.image: 启用图像模块。 （默认值：true。） modules.joystick: 启用摇杆模块。 （默认值：true。） modules.keyboard: 启用键盘模块。 （默认值：true。） modules.math: 启用数学模块。 （默认值：true。） modules.mouse: 启用鼠标模块。 （默认值：true。） modules.physics: 启用物理模块。 （默认值：true。） modules.sound: 启用声音模块。 （默认值：true。） modules.system: 启用系统模块。 （默认值：true。） modules.timer: 启用定时器模块。 （默认值：true。） modules.touch: 启用触摸模块。 （默认值：true。） modules.video: 启用视频模块。 （默认值：true。） modules.window: 启用窗口模块。 （默认值：true。） modules.thread: 启用线程模块。 （默认值：true。）
	conf: function(config: Config) | nil

	-- 该函数在游戏开始时仅调用一次。
	-- 重载说明：
	-- 1. 在 LÖVE 11.0 中，当从非 fused LÖVE 可执行文件运行时，传递的参数不包括游戏名称和 fused 命令行标志（如果存在）。以前的版本按原样传递参数，不进行任何过滤。
	load: function() | nil

	-- 回调函数用于更新游戏每一帧的状态。
	-- @param deltaTime (number) 自上次更新以来的时间（以秒为单位）。
	update: function(deltaTime: number) | nil

	-- 用于在屏幕上绘制每一帧的回调函数。
	draw: function() | nil

	-- 游戏关闭时触发的回调函数。
	quit: QuitCallback | nil

	-- 按键时触发的回调函数。
	-- 重载说明：
	-- 1. 扫描码与键盘布局无关，因此如果按下与美式键盘上的 'w' 键相同位置的键，无论该键的标签是什么或用户的操作系统设置是什么，都会生成扫描码 'w' 。需要使用 love.keyboard.setKeyRepeat
	-- 启用按键重复才能接收重复按键事件。这不会影响 love.textinput. 2。需要使用 love.keyboard.setKeyRepeat 启用按键重复才能接收重复按键事件。
	-- @param key (string) 按键的字符。取决于过载：按下的按键的字符。
	-- @param scancode (string) 代表按下的键的扫描码。
	-- @param is_repeat (boolean) 该按键事件是否重复。按键重复之间的延迟取决于用户的系统设置。
	keypressed: function(key: string, scancode: string, is_repeat: boolean) | nil

	-- 释放键盘按键时触发的回调函数。
	-- 重载说明：
	-- 1. 扫描码与键盘布局无关，因此如果按下美式键盘上与 'w' 键相同位置的键，将使用扫描码 'w'，无论该键的标签是什么或用户的操作系统设置是什么。
	-- @param key (string) 已释放按键的字符。
	-- @param scancode (string) 代表释放密钥的扫描码。
	keyreleased: function(key: string, scancode: string) | nil

	-- 当用户输入文本时调用。例如，如果在美式键盘布局上按下 shift-2，将生成文本 '@'。
	-- 重载说明：
	-- 1. 虽然Lua字符串可以很好地存储UTF-8编码的unicode文本，但是Lua字符串库中的许多函数不会像您期望的那样处理文本。例如，#text（和
	-- string.len(text)）将给出字符串中“'bytes'”的数量，而不是 unicode 字符的数量。 Lua wiki 和 Lua 创建者之一的演示给出了更深入的解释，并提供了一些技巧。 utf8 库可用于操作
	-- UTF-8 编码的 unicode 文本（例如此函数中给出的 text 参数）。在 Android 和 iOS 上，默认情况下禁用 textinput；调用 love.keyboard.setTextInput 来启用它。
	-- @param text (string) UTF-8 编码的 unicode 文本。
	textinput: function(text: string) | nil

	-- 当 IME（输入法编辑器）的候选文本发生更改时调用。
	-- 候选文本并不是用户最终选择的最终文本。为此使用 love.textinput 。
	-- @param text (string) UTF-8 编码的 unicode 候选文本。
	-- @param start (integer) 所选候选文本的起始光标。
	-- @param length (integer) 所选候选文本的长度。可能是 0。
	textedited: function(text: string, start: integer, length: integer) | nil

	-- 按下鼠标按钮时触发的回调函数。
	-- 重载说明：
	-- 1. 使用love.wheelmoved 检测鼠标滚轮运动。在 0.10.0 及更高版本中，它不会注册为按钮按下。
	-- @param x (number) 鼠标 x 位置，以像素为单位。
	-- @param y (number) 鼠标 y 位置（以像素为单位）。
	-- @param button (integer) 按下的按钮索引。 1 是鼠标主按钮，2 是鼠标辅助按钮，3 是中间按钮。其他按钮取决于鼠标。
	-- @param is_touch (boolean) 如果鼠标按钮按下源自触摸屏触摸，则为 true。
	-- @param presses (integer) 短时间、小面积的按下次数，用于模拟双击、三击
	mousepressed: function(x: number, y: number, button: integer, is_touch: boolean, presses: integer) | nil

	-- 释放鼠标按钮时触发的回调函数。
	-- @param x (number) 鼠标 x 位置，以像素为单位。
	-- @param y (number) 鼠标 y 位置（以像素为单位）。
	-- @param button (integer) 已释放的按钮索引。 1 是鼠标主按钮，2 是鼠标辅助按钮，3 是中间按钮。其他按钮取决于鼠标。
	-- @param is_touch (boolean) 如果鼠标按钮释放源自触摸屏触摸释放，则为 true。
	-- @param presses (integer) 短时间、小面积的按下次数，用于模拟双击、三击
	mousereleased: function(x: number, y: number, button: integer, is_touch: boolean, presses: integer) | nil

	-- 鼠标移动时触发的回调函数。
	-- 重载说明：
	-- 1. 如果鼠标启用了相对模式，则不保证 '''dx''' and '''dy''' arguments of this callback will update but '''x''' and '''y''' 。
	-- @param x (number) x 轴上的鼠标位置。
	-- @param y (number) y 轴上的鼠标位置。
	-- @param delta_x (number) 自上次调用 love.mousemoved 以来沿 x 轴移动的量。
	-- @param delta_y (number) 自上次调用 love.mousemoved 以来沿 y 轴移动的量。
	-- @param is_touch (boolean) 如果鼠标按钮按下源自触摸屏触摸，则为 true。
	mousemoved: function(x: number, y: number, delta_x: number, delta_y: number, is_touch: boolean) | nil

	-- 鼠标滚轮移动时触发的回调函数。
	-- @param x (number) 水平鼠标滚轮移动量。正值表示向右移动。
	-- @param y (number) 垂直鼠标滚轮移动量。正值表示向上移动。
	wheelmoved: function(x: number, y: number) | nil

	-- 触摸屏被触摸时触发的回调函数。
	-- 重载说明：
	-- 1. 仅保证特定触摸按压的标识符是唯一的，直到使用该标识符调用 love.touchreleased 为止，此时可以将其重新用于新的触摸按压。 LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为
	-- 1 范围内的标准化值，而此 API 报告以像素为单位的位置。
	-- @param id (TouchID) 触摸按键的标识符。
	-- @param x (number) 触摸按键在窗口内的 x 轴位置（以像素为单位）。
	-- @param y (number) 触摸按键在窗口内的 y 轴位置（以像素为单位）。
	-- @param delta_x (number) 触摸按键在窗口内的 x 轴移动（以像素为单位）。这应该始终为零。
	-- @param delta_y (number) 触摸按键在窗口内的 y 轴移动（以像素为单位）。这应该始终为零。
	-- @param pressure (number) 施加的压力大小。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
	touchpressed: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil

	-- 触摸屏停止触摸时触发的回调函数。
	-- 重载说明：
	-- 1. 仅保证特定触摸按压的标识符是唯一的，直到使用该标识符调用 love.touchreleased 为止，此时可以将其重新用于新的触摸按压。 LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为
	-- 1 范围内的标准化值，而此 API 报告以像素为单位的位置。
	-- @param id (TouchID) 触摸按键的标识符。
	-- @param x (number) 窗口内触摸的 x 轴位置（以像素为单位）。
	-- @param y (number) 窗口内触摸的 y 轴位置（以像素为单位）。
	-- @param delta_x (number) 窗口内触摸的 x 轴移动（以像素为单位）。
	-- @param delta_y (number) 窗口内触摸的 y 轴移动（以像素为单位）。
	-- @param pressure (number) 施加的压力大小。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
	touchreleased: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil

	-- 触摸按键在触摸屏内移动时触发的回调函数。
	-- 重载说明：
	-- 1. 仅保证特定触摸按压的标识符是唯一的，直到使用该标识符调用 love.touchreleased 为止，此时可以将其重新用于新的触摸按压。 LÖVE 0.9.2 的非官方 Android 和 iOS 端口将触摸位置报告为
	-- 1 范围内的标准化值，而此 API 报告以像素为单位的位置。
	-- @param id (TouchID) 触摸按键的标识符。
	-- @param x (number) 窗口内触摸的 x 轴位置（以像素为单位）。
	-- @param y (number) 窗口内触摸的 y 轴位置（以像素为单位）。
	-- @param delta_x (number) 窗口内触摸的 x 轴移动（以像素为单位）。
	-- @param delta_y (number) 窗口内触摸的 y 轴移动（以像素为单位）。
	-- @param pressure (number) 施加的压力大小。大多数触摸屏对压力不敏感，在这种情况下压力将为 1。
	touchmoved: function(id: TouchID, x: number, y: number, delta_x: number, delta_y: number, pressure: number) | nil

	-- 线程遇到错误时触发的回调函数。
	-- @param thread (Thread) 产生错误的线程。
	-- @param error (string) 错误消息。
	threaderror: function(thread: Thread, error: string) | nil

	-- 连接操纵杆时调用。
	-- 重载说明：
	-- 1. 对于游戏启动时已连接的每个摇杆，也会在 love.load 之后触发此回调。
	-- @param joystick (Joystick) 新连接的操纵杆对象。
	joystickadded: function(joystick: Joystick) | nil

	-- 当操纵杆断开连接时调用。
	-- @param joystick (Joystick) 现在断开连接的操纵杆对象。
	joystickremoved: function(joystick: Joystick) | nil

	-- 当按下操纵杆按钮时调用。
	-- @param joystick (Joystick) 操纵杆对象。
	-- @param button (integer) 按钮编号。
	joystickpressed: function(joystick: Joystick, button: integer) | nil

	-- 释放操纵杆按钮时调用。
	-- @param joystick (Joystick) 操纵杆对象。
	-- @param button (integer) 按钮编号。
	joystickreleased: function(joystick: Joystick, button: integer) | nil

	-- 当操纵杆轴移动时调用。
	-- @param joystick (Joystick) 操纵杆对象。
	-- @param axis (integer) 轴编号。
	-- @param value (number) 新的轴值。
	joystickaxis: function(joystick: Joystick, axis: integer, value: number) | nil

	-- 当操纵杆帽方向改变时调用。
	-- @param joystick (Joystick) 操纵杆对象。
	-- @param hat (integer) 帽子号码。
	-- @param direction (string) 新帽子方向。
	joystickhat: function(joystick: Joystick, hat: integer, direction: string) | nil

	-- 当按下操纵杆的虚拟游戏手柄按钮时调用。
	-- @param joystick (Joystick) 操纵杆对象。
	-- @param button (string) 虚拟游戏手柄按钮。
	gamepadpressed: function(joystick: Joystick, button: string) | nil

	-- 当操纵杆的虚拟游戏手柄按钮被释放时调用。
	-- @param joystick (Joystick) 操纵杆对象。
	-- @param button (string) 虚拟游戏手柄按钮。
	gamepadreleased: function(joystick: Joystick, button: string) | nil

	-- 当操纵杆的虚拟游戏手柄轴移动时调用。
	-- @param joystick (Joystick) 操纵杆对象。
	-- @param axis (string) 虚拟游戏手柄轴。
	-- @param value (number) 新的轴值。
	gamepadaxis: function(joystick: Joystick, axis: string, value: number) | nil

	-- 兼容性入口点； Dora 仍然是应用程序循环所有者。 main 函数，包含主循环。省略时使用合理的默认值。
	run: function()
end

local love: Love
return love

-- LÖVE 11.5 API 文档，包括参数和返回值说明，改编自官方 LÖVE Wiki。版权所有© 2006-2010 LÖVE 开发团队。文档根据 FreeBSD 文档许可证重新分发。 Dora
-- 特定的兼容性说明仍会明确标记。
