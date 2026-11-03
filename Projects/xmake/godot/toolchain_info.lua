-- Record the tools selected for this target, rather than the caller's PATH.
import("core.project.project")
import("core.project.config")
import("core.base.json")
function main(output)
    config.load()
    local target = assert(project.target("godot-runtime"))
    local compiler = target:tool("cxx")
    local linker = target:tool("ld")
    local report = {
        compiler = compiler, linker = linker,
        compiler_version = os.iorunv(compiler, {"--version"}),
        linker_version = os.iorunv(linker, {"--version"}),
        link_flags = target:get("ldflags"),
        shared_link_flags = target:get("shflags"),
        system_links = target:get("syslinks"),
        targetfile = target:targetfile(), plat = target:plat(), arch = target:arch()
    }
    if target:is_plat("iphoneos") then
        local toolchain = assert(target:toolchain("xcode"))
        report.sdk = toolchain:config("xcode_sysroot")
        report.appledev = toolchain:config("appledev")
        report.target_minver = toolchain:config("target_minver")
    end
    json.savefile(output, report)
end
