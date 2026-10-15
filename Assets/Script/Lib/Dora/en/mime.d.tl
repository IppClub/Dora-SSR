local socket = require("socket")
local type Filter = socket.Filter

-- MIME Base64, quoted-printable, line normalization and wrapping filters.
local record mime
	const _VERSION: string
	-- Creates a Base64 or quoted-printable encoder filter.
	encode: function(name?: string, mode?: string): Filter
	-- Creates a Base64 or quoted-printable decoder filter.
	decode: function(name?: string): Filter
	-- Creates a text, Base64, or quoted-printable wrapping filter.
	wrap: function(name?: string, length?: integer): Filter
	-- Creates an end-of-line normalization filter.
	normalize: function(marker?: string): Filter
	-- Creates an SMTP dot-stuffing filter.
	stuff: function(): Filter
	-- Low-level incremental Base64 encoder and decoder.
	b64: function(context?: string, chunk?: string): string | nil, string | nil
	unb64: function(context?: string, chunk?: string): string | nil, string | nil
	-- Low-level incremental quoted-printable encoder and decoder.
	qp: function(context?: string, chunk?: string, marker?: string): string | nil, string | nil
	unqp: function(context?: string, chunk?: string): string | nil, string | nil
	wrp: function(remaining: integer, chunk?: string, length?: integer): string | nil, integer
	qpwrp: function(remaining: integer, chunk?: string, length?: integer): string | nil, integer
	eol: function(context: integer, chunk?: string, marker?: string): string | nil, integer
	dot: function(context: integer, chunk?: string): string | nil, integer
end

return mime
