-- Verify an optional runtime package without loading executable code.
function verify(package)
    local C = import("common", {rootdir = os.scriptdir()})
    local M = import("package_manifest", {rootdir = os.scriptdir()})
    local J = import("ordered_json", {rootdir = os.scriptdir()})
    package = C.real(package)
    local manifest = C.load(path.join(package, "manifest.json"))
    assert(manifest.package_format == "dora-godot-runtime" and manifest.package_version == 1,
        "Unsupported package format; rebuild the package with current tools")
    assert(manifest.bridge_abi == 1 and manifest.godot_version == "4.7.2-stable"
        and manifest.source_archive_sha256 == M.source_sha256(), "Runtime version, bridge ABI or pinned source mismatch")
    if manifest.architectures then
        assert(type(manifest.architectures) == "table" and #manifest.architectures > 0, "Invalid runtime architecture inventory")
        local seen = {}
        for _, name in ipairs(manifest.architectures) do
            C.choice(name, {"arm64", "arm32", "x86_64", "x64"})
            assert(not seen[name], "Invalid runtime architecture inventory"); seen[name] = true
        end
    end
    local backend = manifest.graphics_backend
    if backend then C.choice(backend, {"metal", "egl", "wgl", "d3d12", "webgl2"}) end
    local artifacts = manifest.artifacts
    assert(type(artifacts) == "table" and not table.empty(artifacts), "Missing artifact inventory")
    local count, size = 0, 0
    for name, expected in pairs(artifacts) do
        local file = C.safe_file(package, name)
        assert(type(expected) == "string" and #expected == 64 and not expected:find("[^0-9a-f]")
            and C.digest(file) == expected, "Artifact hash mismatch: " .. name)
        count = count + 1; size = size + os.filesize(file)
    end
    for _, file in ipairs(C.files(package)) do
        local name = C.relative(file, package)
        assert(name == "manifest.json" or artifacts[name], "Unlisted package file: " .. name)
    end
    local licenses = manifest.licenses or {}
    assert(type(licenses) == "table" and #licenses > 0, "License inventory missing or incomplete")
    for _, name in ipairs(licenses) do assert(artifacts[name], "License inventory missing or incomplete") end
    local profile = manifest.static_accesskit_sdk
    assert(profile == nil or profile == "linux", "Unknown static AccessKit SDK profile")
    local library = manifest.library or ""
    if profile == "linux" then
        assert(backend == "egl" and library:endswith(".so"), "Linux static AccessKit SDK requires an EGL shared runtime")
    end
    if (backend == "metal" and library:endswith(".dylib")) or profile == "linux" then
        local notice, provenance = "GODOT-ACCESSKIT-NOTICES.txt", "GODOT-ACCESSKIT-PROVENANCE.json"
        assert(table.contains(licenses, notice) and artifacts[provenance], "Static AccessKit dependency notices/provenance missing")
        local dependency = C.load(path.join(package, provenance))
        local spec = C.load(path.join(C.root(), "Projects/xmake/godot", profile == "linux" and "linux_accesskit_sdk.json" or "macos_accesskit_sdk.json"))
        for key, value in pairs(spec) do assert(C.equal(dependency[key], value), "Static AccessKit dependency provenance mismatch") end
        assert(artifacts[notice] == C.digest(path.join(os.scriptdir(), "licenses/accesskit-0.22.3", notice)),
            "Static AccessKit license text differs from pinned notice")
    end
    local dependency
    if backend == "d3d12" then
        local notice, provenance = "GODOT-NIR-THIRD-PARTY-NOTICES.txt", "GODOT-NIR-PROVENANCE.json"
        assert(table.contains(licenses, notice) and artifacts[provenance], "D3D12 NIR dependency notices/provenance missing")
        dependency = J.decode(C.read(path.join(package, provenance)))
        assert(dependency.godot_nir_tag == "25.3.1-1" and dependency.notice_sha256 == artifacts[notice], "D3D12 NIR notice provenance mismatch")
        C.choice(dependency.schema, {1, 2, 3})
        if dependency.schema >= 2 then
            local expected = {
                ["mesa/src/util/drm_is_nouveau.h"] = "10e68930ffc4bd3919989b33ac4ec0c0174174c95d20c4ed1339143063e25e2a",
                ["mesa/src/util/format/u_format.yaml"] = "8cc08434fdf13defe70ab210941ac18d04332d2148af680794fe8e7b6a14bacf"}
            local history = dependency.historical_notice_sources
            assert(type(history) == "table" and #history == 2, "D3D12 inherited notices missing or invalid")
            local seen, body = {}, C.read(path.join(package, notice))
            for _, entry in ipairs(history) do
                local target, text = entry.applies_to, entry.notice_text
                assert(expected[target] and not seen[target] and type(text) == "string" and body:find(text, 1, true)
                    and entry.notice_sha256 == expected[target] and C.data_digest(text) == expected[target], "D3D12 inherited notices missing or invalid")
                seen[target] = true
            end
        end
        if dependency.schema >= 3 then
            import("verify_nir_review", {rootdir = os.scriptdir()}).verify_review(dependency.license_review, dependency)
        end
    end
    if library == "" then
        for _, name in ipairs({"dora-godot.js", "dora-godot.wasm", "runtime_bridge.mjs", "shared_gl.mjs"}) do
            assert(artifacts[name], "Missing native library or complete Web runtime payload")
        end
    else assert(artifacts[library] and manifest.library_sha256 == artifacts[library], "Library inventory mismatch") end
    local result = {passed = true,
        scope = "Package integrity/version/license inventory only; no library execution, signature verification or GPU acceptance",
        package = package, manifest_sha256 = C.digest(path.join(package, "manifest.json")), files = count, bytes = size,
        godot_version = manifest.godot_version, bridge_abi = manifest.bridge_abi, graphics_backend = backend}
    if dependency then result.nir_notice_schema = dependency.schema; result.nir_inherited_notice_sources = #(dependency.historical_notice_sources or {}) end
    return result
end

function main(...)
    local C = import("common", {rootdir = os.scriptdir()})
    local args = C.args({...}, {output = "value"})
    assert(#args.positional == 1, "Usage: xmake lua Tools/Godot/verify_package.lua PACKAGE [--output REPORT]")
    if args.output then
        local output, package = C.real(args.output), C.real(args.positional[1])
        assert(output ~= package and not output:startswith(package .. path.sep()), "Verification report must be outside the sealed package")
        os.tryrm(output)
    end
    local result = verify(args.positional[1])
    if args.output then C.save(args.output, result) end
    import("core.base.json"); print(C.serialize(result))
end
