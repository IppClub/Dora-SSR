local __TS__Symbol, Symbol
do
	local symbolMetatable = {__tostring = function(self)
		return ("Symbol(" .. (self.description or "")) .. ")"
	end}
	function __TS__Symbol(description)
		return setmetatable({description = description}, symbolMetatable)
	end
	Symbol = {
		asyncDispose = __TS__Symbol("Symbol.asyncDispose"),
		dispose = __TS__Symbol("Symbol.dispose"),
		iterator = __TS__Symbol("Symbol.iterator"),
		hasInstance = __TS__Symbol("Symbol.hasInstance"),
		species = __TS__Symbol("Symbol.species"),
		toStringTag = __TS__Symbol("Symbol.toStringTag")
	}
end
