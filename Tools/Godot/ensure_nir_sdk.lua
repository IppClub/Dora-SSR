-- Fetch and verify the pinned x64 GCC NIR SDK used by production D3D12.
function ensure_sdk()
    local C = import("common", {rootdir = os.scriptdir()})
    local V = import("verify_d3d12_sdk", {rootdir = os.scriptdir()})
    local metadata = path.join(C.root(), "Projects/xmake/godot/windows_d3d12_sdk.json")
    local spec = C.load(metadata)
    local destination = path.join(C.root(), "build/godot-sdk/nir-25.3.1-1-x64-gcc")
    if os.isfile(path.join(destination, "bin/libNIR.windows.x86_64.a")) then V.verify(destination, metadata); return destination end
    local archive_file = destination .. ".zip"
    C.download(spec.source_url, archive_file)
    assert(C.digest(archive_file) == spec.source_archive_sha256, "NIR SDK archive hash mismatch")
    -- No untrusted/unpinned ZIP is passed to the extractor.
    C.extract(archive_file, destination)
    V.verify(destination, metadata)
    return destination
end
function main() print(ensure_sdk()) end
