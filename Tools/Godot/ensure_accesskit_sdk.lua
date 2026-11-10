-- Fetch/verify the fixed upstream static SDK for a pinned platform profile.
function verify(destination, spec)
    local C = import("common", {rootdir = os.scriptdir()})
    local J = import("ordered_json", {rootdir = os.scriptdir()})
    for _, name in ipairs(J.keys(spec.artifacts)) do
        local expected = spec.artifacts[name]
        assert(C.digest(C.safe_file(destination, name)) == expected, "AccessKit SDK hash mismatch: " .. name)
    end
    assert(C.digest(path.join(C.root(), "Source/3rdParty/Godot/thirdparty/accesskit/include/accesskit.h"))
        == C.digest(path.join(destination, "include/accesskit.h")), "AccessKit SDK and vendored header differ")
end

function ensure(destination, archive_file, spec_path)
    local C = import("common", {rootdir = os.scriptdir()})
    destination = destination or path.join(C.root(), "build/godot-sdk/accesskit-0.22.3-macos-arm64")
    local spec = C.load(spec_path or path.join(C.root(), "Projects/xmake/godot/macos_accesskit_sdk.json"))
    if os.exists(destination) then verify(destination, spec); return destination end
    os.mkdir(path.directory(destination))
    archive_file = archive_file or destination .. ".zip"
    if not os.isfile(archive_file) then C.download(spec.source_url, archive_file) end
    assert(C.digest(archive_file) == spec.source_archive_sha256, "AccessKit SDK archive hash mismatch")
    local temporary = os.tmpfile() .. ".accesskit"
    try {
        function ()
            -- Only the hash-pinned upstream archive is extracted. Copy just the audited inputs.
            C.extract(archive_file, path.join(temporary, "archive"))
            local staging = path.join(temporary, "staging")
            for name in pairs(spec.artifacts) do
                C.safe_relative(name)
                C.copy(path.join(temporary, "archive", spec.archive_prefix .. name), path.join(staging, name))
            end
            verify(staging, spec)
            os.cp(staging, destination)
        end,
        finally {function (ok, errors)
            os.tryrm(temporary)
            if not ok then raise(errors) end
        end}
    }
    return destination
end

function main(...)
    local C = import("common", {rootdir = os.scriptdir()})
    local args = C.args({...}, {output = "value", archive = "value", spec = "value"})
    print(ensure(args.output, args.archive, args.spec))
end
