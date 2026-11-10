function main(source)
    local vendor=import("Tools.Godot.vendor_source",{rootdir=path.absolute(path.join(os.scriptdir(),"../.."))})
    vendor.verify_ios(assert(source,"Godot source path is required"))
    print("Vendored Godot ios bridge: PASS")
end
