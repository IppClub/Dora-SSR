#!/usr/bin/env python3
"""Real native Git/Content regression for Catalog project sync.

Requires a running Dora service and connected Web IDE. All repositories and
writes are temporary; Content.writablePath is restored after every command.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dora", type=Path, required=True)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[2]
    environment = {k: v for k, v in os.environ.items() if k.lower() not in
                   {"http_proxy", "https_proxy", "all_proxy", "no_proxy"}}
    with tempfile.TemporaryDirectory(prefix="dora-catalog-sync-") as temporary:
        root = Path(temporary)
        workspace = root / "workspace"
        workspace.mkdir()
        def git(path, *arguments):
            return subprocess.check_output(["git", "-C", str(path), *arguments], text=True).strip()
        def commit(path, text):
            (path / "game.txt").write_text(text)
            git(path, "add", "-A")
            git(path, "-c", "user.name=Dora Test", "-c", "user.email=test@example.com", "commit", "-qm", text.strip())
            return git(path, "rev-parse", "HEAD")
        def remote(name, text):
            path = root / name
            path.mkdir()
            git(path, "init", "-q", "-b", "main")
            (path / "init.lua").write_text("return true\n")
            commit(path, text)
            return path
        upstream = remote("upstream", "first\n")
        unrelated = remote("replacement", "new repository\n")
        bad = remote("unsafe", "unsafe\n")
        (bad / "escape").symlink_to("../outside")
        commit(bad, "unsafe\n")
        target = workspace / "Download" / "sync-test"
        prelude = r'''local D = requireProjectModule("Dora")
local installer = requireProjectModule("Tools/ResourceDownloader/GitInstaller")
local C = D.Content
local previousWritable = C.writablePath
local function await(p)
    local done, result, failure = false, nil, nil
    p["then"](p, function(_, value) result=value;done=true end,
        function(_, err) failure=err;done=true end)
    while not done do sleep(0.01) end
    assert(not failure, tostring(failure))
    return result
end
local resource = {id="sync-test", status="active", title={en="Sync test", ["zh-Hans"]="同步测试"},
    description={en="Fixture", ["zh-Hans"]="测试"}, categories={}, runnable=true,
    entrypoints={{name="Game", path="init"}}, selectedVersion=1}
local function version(url) return {name="latest", sources={{url=url,role="upstream"}}} end
local options = {catalogCommit="fixture"}
local function run()
'''
        def command(code):
            request = root / "request.json"
            request.write_text(json.dumps({"mode": "lua", "timeoutSeconds": 120,
                "code": prelude + "C.writablePath = " + json.dumps(str(workspace)) + "\n" + code + r'''
end
local ok, err = pcall(run)
C.writablePath = previousWritable
assert(ok, tostring(err))
'''}))
            result = subprocess.run([str(args.dora.resolve()), "--asset", str(repo / "Assets"),
                "cli", "agent", "command", "-p", str(root), "--input", str(request)],
                capture_output=True, text=True, timeout=140, env=environment)
            reply = json.loads(result.stdout)
            assert result.returncode == 0 and reply.get("success"), reply
            print(reply.get("output", "").strip())
        def operation(url, force=False, extra=""):
            return "local result=await(installer.syncResource(resource, version(" + json.dumps(str(url)) + "), options, " + str(force).lower() + "))\n" + extra
        command("local result=await(installer.installResource(resource, version(" + json.dumps(str(upstream)) + "), options))\nassert(result.success,result.message)\nprint('installed fixture')")
        second = commit(upstream, "second\n")
        command(operation(upstream, extra="assert(result.success,result.message);print('ordinary pull succeeded')"))
        assert (target / "game.txt").read_text() == "second\n"
        assert git(target, "rev-parse", "HEAD") == second
        (target / "game.txt").write_text("local edit\n")
        (target / "local-only.txt").write_text("untracked\n")
        third = commit(upstream, "third\n")
        command(operation(upstream, extra="assert(not result.success and result.forceable, result.message);print('dirty pull failed with force offer')"))
        assert (target / "game.txt").read_text() == "local edit\n"
        assert (target / "local-only.txt").exists()
        commit(target, "local commit\n")
        command(operation(upstream, True, "assert(result.success,result.message);print('force replaced local edits, commits and files')"))
        assert git(target, "rev-parse", "HEAD") == third
        assert not (target / "local-only.txt").exists()
        moved = root / "moved-upstream"
        subprocess.run(["git", "clone", "-q", str(upstream), str(moved)], check=True)
        fourth = commit(moved, "same history at new address\n")
        command(operation(moved, extra="assert(result.success,result.message);print('changed address with shared history pulled normally')"))
        assert git(target, "rev-parse", "HEAD") == fourth
        assert git(target, "remote", "get-url", "origin") == str(moved)
        command(operation(unrelated, extra="assert(not result.success and result.forceable,result.message);print('unrelated changed address offers force')"))
        assert git(target, "remote", "get-url", "origin") == str(moved)
        command(operation(unrelated, True, "assert(result.success,result.message);print('force cloned changed repository')"))
        assert (target / "game.txt").read_text() == "new repository\n"
        assert git(target, "remote", "get-url", "origin") == str(unrelated)
        original = git(target, "rev-parse", "HEAD")
        command(operation(root / "missing", True, "assert(not result.success);print('failed force clone preserved original')"))
        assert git(target, "rev-parse", "HEAD") == original
        command(operation(bad, True, "assert(not result.success);print('unsafe force clone rejected')"))
        assert git(target, "rev-parse", "HEAD") == original
        command("local canceled=false;options.isCanceled=function() return canceled end;options.onProgress=function(_,status) if status.progress>=0.92 then canceled=true end end;\n" + operation(upstream, True, "assert(not result.success and result.canceled);print('cancellation before swap preserved original')"))
        assert git(target, "rev-parse", "HEAD") == original
        command("options.onProgress=function(_,status) if status.progress==0.97 then for _,dir in ipairs(C:getDirs(D.Path(C.writablePath,'.download'))) do if not dir:match('previous$') then C:remove(D.Path(C.writablePath,'.download',dir)) end end end end;\n" + operation(upstream, True, "print('rollback result',result.success,result.message);assert(not result.success and result.message:find('restored'),result.message);print('failed replacement restored original')"))
        assert git(target, "rev-parse", "HEAD") == original
        command("local v=version(" + json.dumps(str(upstream)) + ");local first=installer.syncResource(resource,v,options,true);local second=await(installer.syncResource(resource,v,options,true));assert(not second.success and second.message:find('already in progress'));assert(await(first).success);print('concurrent project sync blocked')")
        assert not list((workspace / ".download").iterdir())
        state = json.loads((target / ".dora/resource-state.json").read_text())
        assert state["commit"] == third and state["source"] == str(upstream)
        release = git(upstream, "rev-list", "--max-parents=0", "HEAD")
        git(upstream, "tag", "v1.0.0", release)
        command("resource.id='tag-test';local v=version(" + json.dumps(str(upstream)) + ");v.tag='v1.0.0';assert(await(installer.installResource(resource,v,options)).success);assert(await(installer.syncResource(resource,v,options)).success);print('detached tag installation pulled default branch normally')")
        assert git(workspace / "Download/tag-test", "rev-parse", "HEAD") == third
        command("resource.id='tag-test';local v=version(" + json.dumps(str(upstream)) + ");v.tag='v1.0.0';assert(await(installer.syncResource(resource,v,options,true)).success);print('forced replacement honored Catalog tag')")
        assert git(workspace / "Download/tag-test", "rev-parse", "HEAD") == release
        command("local nested=installer.getInstalledCatalogResource(D.Path(C.writablePath,'Download','sync-test','game'),{resource});assert(nested==resource);assert(not installer.getInstalledCatalogResource(D.Path(C.writablePath,'Download','sync-test-copy'),{resource}));print('nested Catalog identity matched with path boundary')")
        command("resource.versions={version(" + json.dumps(str(upstream)) + ")};local cache=requireProjectModule('Tools/ResourceDownloader/CatalogSync');local oldLoad,oldSync=cache.loadCachedCatalog,cache.syncCatalog;cache.loadCachedCatalog=function() return {success=true,snapshot={commit='cached-fixture',catalog={resources={resource}}}} end;cache.syncCatalog=function() error('project sync must not refresh Catalog') end;local ok,err=pcall(function() local life=requireProjectModule('Dev/Mobile/Lifecycle');local done,result=false,nil;life.syncMobileResource(resource.id,false,function() end,function(r) result=r;done=true end);while not done do sleep(0.01) end;assert(result.success,result.message) end);cache.loadCachedCatalog,cache.syncCatalog=oldLoad,oldSync;requireProjectModule('Dev/Mobile/Lifecycle');assert(ok,err);print('mobile sync used cached Catalog without refreshing it')")
        command("resource.entrypoints={};resource.versions={version(" + json.dumps(str(upstream)) + ")};local cache=requireProjectModule('Tools/ResourceDownloader/CatalogSync');local oldLoad,oldSync=cache.loadCachedCatalog,cache.syncCatalog;cache.loadCachedCatalog=function() return {success=true,snapshot={commit='cached-fixture',catalog={resources={resource}}}} end;cache.syncCatalog=function() error('must not refresh Catalog') end;local ok,err=pcall(function() local life=requireProjectModule('Dev/Mobile/Lifecycle');local count,result=0,nil;life.syncMobileResource(resource.id,true,function() end,function(r) result=r;count=count+1 end);while count==0 do sleep(0.01) end;assert(count==1 and result.success and result.entry.workDir==installer.getResourceInstallPath(resource.id),result.message);count=0;life.syncMobileResource(resource.id,false,function() error('injected sync failure') end,function(r) result=r;count=count+1 end);while count==0 do sleep(0.01) end;assert(count==1 and not result.success and result.message:find('injected sync failure'),result.message) end);cache.loadCachedCatalog,cache.syncCatalog=oldLoad,oldSync;assert(ok,err);print('empty entrypoint force sync completed once; async exceptions delivered completion')")
        legacy = workspace / "Download/legacy-test"
        (legacy / ".dora").mkdir(parents=True)
        (legacy / ".dora/repo.json").write_text(json.dumps({"name": "legacy-test"}))
        (legacy / "init.lua").write_text("return true\n")
        (legacy / "local-only.txt").write_text("legacy local edit\n")
        command("resource.id='legacy-test';assert(installer.getInstalledCatalogResource(D.Path(C.writablePath,'Download',resource.id,'game'),{resource})==resource);local result=await(installer.syncResource(resource,version(" + json.dumps(str(upstream)) + "),options));assert(not result.success and result.forceable,result.message);print('legacy archive recognized and ordinary sync offered force')")
        assert (legacy / "local-only.txt").exists()
        state_file = legacy / ".dora/resource-state.json"
        state_file.write_text(json.dumps({"resourceId": "other-project"}))
        command("resource.id='legacy-test';assert(not installer.getInstalledCatalogResource(D.Path(C.writablePath,'Download',resource.id),{resource}));print('mismatched Git state cannot fall back to legacy identity')")
        state_file.unlink()
        command("resource.id='legacy-test';assert(await(installer.syncResource(resource,version(" + json.dumps(str(upstream)) + "),options,true)).success);print('legacy archive force sync migrated to Git installation')")
        assert not (legacy / "local-only.txt").exists()
        assert git(legacy, "rev-parse", "HEAD") == third
        assert json.loads(state_file.read_text())["resourceId"] == "legacy-test"
        print("All native Catalog synchronization checks passed")


if __name__ == "__main__":
    main()
