local socket = require("socket")
local type Source = socket.Source
local type Sink = socket.Sink
local type Filter = socket.Filter
local type LowLevelFilter = function(context: any, chunk?: string, extra?: any): string | nil, any

local record Filters
	-- 串联一个或多个高级过滤器。
	chain: function(...: Filter): Filter
	-- 将低级有状态过滤器适配为高级过滤器。
	cycle: function(lowLevel: LowLevelFilter, context: any, extra?: any): Filter
end

local record Sources
	cat: function(...: Source): Source
	chain: function(source: Source, ...: Filter): Source
	empty: function(): Source
	error: function(message: string): Source
	rewind: function(source: Source): Source
	simplify: function(source: Source): Source
	string: function(value?: string): Source
	table: function(values: {string}): Source
end

local record Sinks
	chain: function(...: Filter | Sink): Sink
	error: function(message: string): Sink
	null: function(): Sink
	simplify: function(sink: Sink): Sink
	-- 创建一个把数据块追加到表中的接收器，并同时返回接收器和目标表。
	table: function(target?: {string}): Sink, {string}
end

local record Pumps
	-- 传输全部数据块，直到完成或失败。
	all: function(source: Source, sink: Sink, step?: function(source: Source, sink: Sink): integer | nil, string | nil): integer | nil, string | nil
	-- 传输一个数据块。
	step: function(source: Source, sink: Sink): integer | nil, string | nil
end

-- LTN12 流式过滤器、数据源、数据接收器和传输泵。
local record ltn12
	const BLOCKSIZE: integer
	const _VERSION: string
	const filter: Filters
	const source: Sources
	const sink: Sinks
	const pump: Pumps
end

return ltn12
