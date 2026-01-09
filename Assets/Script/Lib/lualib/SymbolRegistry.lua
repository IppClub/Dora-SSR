local __TS__SymbolRegistryFor, __TS__SymbolRegistryKeyFor
do
	local symbolRegistry = {}
	function __TS__SymbolRegistryFor(key)
		if not symbolRegistry[key] then
			symbolRegistry[key] = __TS__Symbol(key)
		end
		return symbolRegistry[key]
	end
	function __TS__SymbolRegistryKeyFor(sym)
		for key in pairs(symbolRegistry) do
			if symbolRegistry[key] == sym then
				return key
			end
		end
		return nil
	end
end
