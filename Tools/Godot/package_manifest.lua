-- Versioned, content-addressed deployment inventory (not runtime acceptance).
local SOURCE_SHA256 = "e954996374cbd1cb5d72e0e3781cc537408e6ce73b010b12c6c2f308a820690a"
function source_sha256() return SOURCE_SHA256 end

function seal(package, manifest)
    local C = import("common", {rootdir = os.scriptdir()})
    local identity = {package_format = "dora-godot-runtime", package_version = 1,
        godot_version = "4.7.2-stable", bridge_abi = 1, source_archive_sha256 = SOURCE_SHA256}
    for key, expected in pairs(identity) do
        assert(manifest[key] == nil or manifest[key] == expected, "Cannot seal incompatible identity: " .. key)
        manifest[key] = expected
    end
    manifest.artifacts = {}
    for _, file in ipairs(C.files(package)) do
        local name = C.relative(file, package)
        if name ~= "manifest.json" then manifest.artifacts[name] = C.digest(file) end
    end
    return manifest
end
