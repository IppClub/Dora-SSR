function main(...)
    local C = import("common", {rootdir = os.scriptdir()})
    local args = C.args({...}, {variant = "value"})
    assert(#args.positional == 2, "Usage: xmake lua import_macos_compile_db.lua DB OUTPUT [--variant NAME]")
    assert(not (args.variant or "macos_arm64"):find("[^%w_]"), "variant must be an alphanumeric identifier")
    import("import_compile_db", {rootdir = os.scriptdir()}).convert(args.positional[1], args.positional[2], args, true)
end
