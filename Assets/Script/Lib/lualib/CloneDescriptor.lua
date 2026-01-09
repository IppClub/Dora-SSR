local function __TS__CloneDescriptor(____bindingPattern0)
	local value
	local writable
	local set
	local get
	local configurable
	local enumerable
	enumerable = ____bindingPattern0.enumerable
	configurable = ____bindingPattern0.configurable
	get = ____bindingPattern0.get
	set = ____bindingPattern0.set
	writable = ____bindingPattern0.writable
	value = ____bindingPattern0.value
	local descriptor = {enumerable = enumerable == true, configurable = configurable == true}
	local hasGetterOrSetter = get ~= nil or set ~= nil
	local hasValueOrWritableAttribute = writable ~= nil or value ~= nil
	if hasGetterOrSetter and hasValueOrWritableAttribute then
		error("Invalid property descriptor. Cannot both specify accessors and a value or writable attribute.", 0)
	end
	if get or set then
		descriptor.get = get
		descriptor.set = set
	else
		descriptor.value = value
		descriptor.writable = writable == true
	end
	return descriptor
end
