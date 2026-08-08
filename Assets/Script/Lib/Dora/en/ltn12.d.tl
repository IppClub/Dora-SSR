local socket = require("socket")
local type Source = socket.Source
local type Sink = socket.Sink
local type Filter = socket.Filter
local type LowLevelFilter = function(context: any, chunk?: string, extra?: any): string | nil, any

local record Filters
	-- Chains one or more high-level filters.
	chain: function(...: Filter): Filter
	-- Adapts a low-level stateful filter into a high-level filter.
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
	-- Creates a sink that appends chunks to a table and returns both values.
	table: function(target?: {string}): Sink, {string}
end

local record Pumps
	-- Transfers all chunks until completion or failure.
	all: function(source: Source, sink: Sink, step?: function(source: Source, sink: Sink): integer | nil, string | nil): integer | nil, string | nil
	-- Transfers one chunk.
	step: function(source: Source, sink: Sink): integer | nil, string | nil
end

-- LTN12 streaming filters, sources, sinks and transfer pumps.
local record ltn12
	const BLOCKSIZE: integer
	const _VERSION: string
	const filter: Filters
	const source: Sources
	const sink: Sinks
	const pump: Pumps
end

return ltn12
