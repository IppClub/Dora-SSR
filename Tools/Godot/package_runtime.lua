-- Stage a runtime with upstream notices and a content-addressed manifest.
function package_runtime(args)
    local C = import("common", {rootdir = os.scriptdir()})
    local M = import("package_manifest", {rootdir = os.scriptdir()})
    local source, library, output = C.required(args, "source"), C.required(args, "library"), C.required(args, "output")
    assert(os.isfile(library), "Missing runtime library: " .. library)
    local suffix = C.choice(path.extension(library), {".dylib", ".so", ".dll"})
    assert(C.real(output) ~= C.real(source), "Output must differ from the vendor source")
    local name = args["library-name"] or (suffix == ".dll" and "dora_godot.dll" or "libdora_godot" .. suffix)
    C.safe_relative(name)
    assert(not name:find("/", 1, true) and name:endswith(suffix), "Invalid library basename")
    local destination = path.join(output, name)
    assert(C.real(destination) ~= C.real(library), "Output library must differ from input")
    if args["build-target"] then C.choice(args["build-target"], {"template_debug", "template_release"}) end
    local backend = args["graphics-backend"]
    if backend then C.choice(backend, {"metal", "egl", "wgl", "d3d12", "webgl2"}) end
    local architectures = {}
    for _, arch in ipairs(args.architecture or {}) do architectures[C.choice(arch, {"arm64", "arm32", "x86_64", "x64"})] = true end
    os.mkdir(output); os.tryrm(path.join(output, "manifest.json"))
    C.copy(library, destination)
    for from, to in pairs({["LICENSE.txt"] = "GODOT-LICENSE.txt", ["COPYRIGHT.txt"] = "GODOT-THIRD-PARTY-NOTICES.txt"}) do
        C.copy(path.join(source, from), path.join(output, to))
    end
    for _, directory in ipairs(args["extra-directory"] or {}) do
        assert(os.isdir(directory), "Invalid dependency directory: " .. directory)
        local actual, out = C.real(directory), C.real(output)
        assert(out ~= actual and not out:startswith(actual .. path.sep()), "Dependency tree contains output directory")
        local basename = path.filename(directory); C.safe_relative(basename)
        for _, file in ipairs(C.files(directory)) do
            C.copy(file, path.join(output, basename, C.relative(file, directory)))
        end
    end
    local notices = table.clone(args["license-file"] or {})
    local provenance = {}
    local function dependency(directory, notice, metadata)
        notices[#notices + 1] = path.join(directory, notice)
        metadata = metadata or path.join(directory, "GODOT-ACCESSKIT-PROVENANCE.json")
        local basename = path.filename(metadata)
        assert(not table.contains(provenance, basename), "Duplicate dependency provenance")
        C.copy(metadata, path.join(output, basename)); provenance[#provenance + 1] = basename
    end
    if backend == "metal" and suffix == ".dylib" then
        dependency(path.join(os.scriptdir(), "licenses/accesskit-0.22.3"), "GODOT-ACCESSKIT-NOTICES.txt")
    end
    if args["static-accesskit-sdk"] then
        assert(args["static-accesskit-sdk"] == "linux" and backend == "egl" and suffix == ".so", "Linux AccessKit requires the EGL shared runtime")
        local directory = path.join(os.scriptdir(), "licenses/accesskit-0.22.3")
        local basename = "GODOT-ACCESSKIT-PROVENANCE.json"
        C.copy(path.join(C.root(), "Projects/xmake/godot/linux_accesskit_sdk.json"), path.join(output, basename))
        notices[#notices + 1] = path.join(directory, "GODOT-ACCESSKIT-NOTICES.txt"); provenance[#provenance + 1] = basename
    end
    if backend == "d3d12" then
        local directory = path.join(os.scriptdir(), "licenses/nir-25.3.1-1")
        local metadata = path.join(directory, "GODOT-NIR-PROVENANCE.json")
        assert(C.load(metadata).schema == 3, "Regenerate current NIR notices before packaging D3D12")
        dependency(directory, "GODOT-NIR-THIRD-PARTY-NOTICES.txt", metadata)
    end
    local reserved = {[name] = true, ["manifest.json"] = true, ["GODOT-LICENSE.txt"] = true, ["GODOT-THIRD-PARTY-NOTICES.txt"] = true}
    for _, item in ipairs(provenance) do reserved[item] = true end
    local licenses = {"GODOT-LICENSE.txt", "GODOT-THIRD-PARTY-NOTICES.txt"}
    for _, notice in ipairs(notices) do
        local basename = path.filename(notice)
        assert(os.isfile(notice) and not reserved[basename], "Notice missing or basename collides")
        reserved[basename] = true
        local target = path.join(output, basename)
        assert(not os.islink(target) and (not os.exists(target) or os.isfile(target)), "Unsafe notice destination")
        C.copy(notice, target); licenses[#licenses + 1] = basename
    end
    local manifest = {
        vendor_validation_script_sha256 = C.digest(path.join(os.scriptdir(), "vendor_source.lua")),
        vendor_provenance_sha256 = C.digest(path.join(source, "UPSTREAM.json")),
        upstream_commit = "ed1daf0bf001b61586d9930840f2f1394092c079",
        particle_material_key_header_sha256 = C.digest(path.join(source, "scene/resources/particle_process_material.h")),
        source = "https://github.com/godotengine/godot/tree/4.7.2-stable",
        library = name, library_sha256 = C.digest(destination), licenses = licenses,
        scope = "development runtime; platform output validation is recorded separately"}
    local metal = path.join(source, "drivers/metal/rendering_device_driver_metal.cpp")
    if os.isfile(metal) then
        manifest.metal_driver_source_sha256 = C.digest(metal)
        if C.read(metal):find("// Dora embedded Metal: no asynchronous library compilation past shutdown.", 1, true) then
            manifest.embedded_metal_shader_loading = "lazy"
        end
    end
    manifest.static_accesskit_sdk = args["static-accesskit-sdk"]
    if #provenance > 0 then manifest.dependency_provenance = provenance end
    manifest.build_target = args["build-target"]
    if not table.empty(architectures) then manifest.architectures = C.keys(architectures) end
    manifest.graphics_backend = backend
    C.save(path.join(output, "manifest.json"), M.seal(output, manifest))
    import("verify_package", {rootdir = os.scriptdir()}).verify(output)
    return C.real(output)
end

function main(...)
    local C = import("common", {rootdir = os.scriptdir()})
    local args = C.args({...}, {source = "value", library = "value", output = "value", ["library-name"] = "value",
        ["build-target"] = "value", architecture = "many", ["graphics-backend"] = "value", ["static-accesskit-sdk"] = "value",
        ["extra-directory"] = "many", ["license-file"] = "many"})
    assert(#args.positional == 0, "Unexpected positional arguments")
    print(package_runtime(args))
end
