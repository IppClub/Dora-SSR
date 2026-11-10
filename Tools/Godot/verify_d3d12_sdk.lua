-- Verify the exact prebuilt NIR headers/archive used by the D3D12 profile.
function verify(sdk, metadata_path)
    local C = import("common", {rootdir = os.scriptdir()})
    sdk = C.real(sdk)
    local metadata = C.load(metadata_path)
    assert(metadata.schema_version == 1, "Unsupported NIR SDK inventory schema")
    local version = C.read(path.join(sdk, "godot-mesa/VERSION.info")):trim()
    assert(version == metadata.mesa_version, "NIR SDK version differs from the audited compiler profile: " .. version)
    for name, expected in pairs(metadata.files) do
        assert(C.digest(C.safe_file(sdk, name)) == expected, "NIR SDK input differs from the audited release: " .. name)
    end
    return {passed = true,
        scope = "Exact pinned NIR SDK file inventory only; not compiler, linker, license-completeness or GPU acceptance",
        sdk = sdk, godot_nir_tag = metadata.godot_nir_tag, mesa_version = version, files = #C.keys(metadata.files),
        inventory_sha256 = C.digest(metadata_path), source_archive_sha256 = metadata.source_archive_sha256}
end

function main(...)
    local C = import("common", {rootdir = os.scriptdir()})
    local args = C.args({...}, {sdk = "value", metadata = "value", architecture = "value", output = "value"})
    local sdk = C.required(args, "sdk")
    local arch = C.choice(args.architecture or "x86_64", {"x86_64", "arm64"})
    local metadata = args.metadata
    if not metadata then
        local names = arch == "arm64" and {"windows_d3d12_arm64_sdk.json"}
            or {"windows_d3d12_sdk.json", "windows_d3d12_x86_64_llvm_sdk.json"}
        local library = "bin/libNIR.windows." .. arch .. ".a"
        local actual, matches = C.digest(path.join(sdk, library)), {}
        for _, name in ipairs(names) do
            local file = path.join(C.root(), "Projects/xmake/godot", name)
            if C.load(file).files[library] == actual then matches[#matches + 1] = file end
        end
        assert(#matches == 1, "NIR library does not match a pinned SDK for this architecture")
        metadata = matches[1]
    end
    local report = verify(sdk, metadata)
    if args.output then C.save(args.output, report) end
    print("Godot NIR SDK: PASS; %d exact audited inputs", report.files)
end
