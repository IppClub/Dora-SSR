function main(source)
    local vendor=import("Tools.Godot.vendor_source",{rootdir=path.absolute(path.join(os.scriptdir(),"../.."))})
    vendor.verify_android(assert(source,"Godot source path is required"))
    print("Vendored Godot android bridge: PASS")
end
