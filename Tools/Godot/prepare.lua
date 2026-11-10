function main(source)
    local vendor=import("Tools.Godot.vendor_source",{rootdir=path.absolute(path.join(os.scriptdir(),"../.."))})
    vendor.verify_common(assert(source,"Godot source path is required"))
    print("Vendored Godot common bridge: PASS")
end
