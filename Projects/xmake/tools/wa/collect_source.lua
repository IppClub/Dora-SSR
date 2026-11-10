function main(source, destination, module_path)
    assert(source and destination and module_path, "Usage: xmake lua collect_source.lua SOURCE DEST MODULE")
    import("collect", {rootdir = os.scriptdir()}).collect_source(source, destination, module_path)
end
