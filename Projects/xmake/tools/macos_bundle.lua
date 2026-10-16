-- Xmake tracks source inputs for plist/catalog rules, but not their outputs.
-- Recover a deleted .app and refresh installfiles before the application rule
-- copies resources and signs it; otherwise the firewall sees a fallback UUID
-- identity instead of the bundle identifier.
function main(target)
    local bundle = path.absolute(assert(target:data("xcode.bundle.rootdir")))
    local contents = path.absolute(assert(target:data("xcode.bundle.contentsdir")))
    local resources = path.absolute(assert(target:data("xcode.bundle.resourcesdir")))
    local root = os.projectdir()
    local missing_metadata = false
    if not os.isfile(path.join(contents, "Info.plist")) then
        os.tryrm(target:dependfile(path.join(root, "Projects/macOS/Dora/Info.plist")))
        missing_metadata = true
    end
    if not os.isfile(path.join(resources, "Assets.car")) or not os.isfile(path.join(resources, "AppIcon.icns")) then
        os.tryrm(target:dependfile(path.join(root, "Projects/macOS/Dora/Assets.xcassets")))
        missing_metadata = true
    end
    local records = {}
    local srcfiles, dstfiles = target:installfiles(resources)
    local missing_resource = false
    for i, source in ipairs(srcfiles or {}) do
        table.insert(records, source .. ":" .. assert(hash.sha256(source)))
        if not os.isfile(dstfiles[i]) then missing_resource = true end
    end
    local metadata = {path.join(root, "Projects/macOS/Dora/Info.plist")}
    table.join2(metadata, os.files(path.join(root, "Projects/macOS/Dora/Assets.xcassets/**")))
    for _, source in ipairs(metadata) do
        table.insert(records, source .. ":" .. assert(hash.sha256(source)))
    end
    table.sort(records)
    local fingerprint = table.concat(records, "\n")
    local stamp = target:dependfile(bundle .. ".resources")
    if missing_metadata or missing_resource or io.readfile(stamp) ~= fingerprint then
        -- This generated folder must not retain old raw/hashed Web IDE files.
        -- Other outputs (plist, catalogs, executable) belong to separate rules.
        os.tryrm(path.join(resources, "www"))
        os.tryrm(target:dependfile(bundle))
        -- If building/signing fails the application dependfile stays invalid,
        -- so the next invocation still retries even with this stamp present.
        io.writefile(stamp, fingerprint)
    end
end
