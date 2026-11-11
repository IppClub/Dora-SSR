// @preview-file off
import { App, Color, Node, Vec2 } from "Dora";
import * as ImGui from "ImGui";
import { SetCond, WindowFlag, StyleColor, StyleVarNum, StyleVarVec } from "ImGui";
import { windowsUpdatePlatform } from "Tools/SelfUpdater/Manifest";
import * as Updater from "Tools/SelfUpdater/Service";

export const createUpdaterPanel = () => {
 const node = Node();
 let confirm = false;
 let backend = Updater.getState().packagePlatform?.includes("-opengl") ? 2 : 1;
 const zh = string.match(App.locale, "^zh")[0] !== undefined;
 if (Updater.getState().phase === "idle") Updater.checkForUpdates();
 node.schedule(() => {
  const state = Updater.getState();
  const width = math.min(460, App.visualSize.width - 24);
  const height = math.min(600, App.visualSize.height - 24);
  ImGui.SetNextWindowPos(Vec2(App.visualSize.width / 2, App.visualSize.height / 2), SetCond.Always, Vec2(0.5, 0.5));
  ImGui.SetNextWindowSize(Vec2(width, height), SetCond.Always);
  ImGui.PushStyleVar(StyleVarNum.WindowRounding, 16, () => ImGui.PushStyleVar(StyleVarVec.WindowPadding, Vec2(20, 18), () => {
   ImGui.Begin("EngineUpdate", [WindowFlag.NoDecoration, WindowFlag.NoSavedSettings, WindowFlag.NoMove], () => {
    ImGui.Text(zh ? "引擎更新" : "Engine update");
    ImGui.SameLine(width - 70);
    if (ImGui.Button("X##close-update", Vec2(30, 30))) node.removeFromParent(true);
    ImGui.Separator();
    ImGui.BeginChild("UpdateContent", Vec2(0, -62), () => {
     const title = state.phase === "checking" ? (zh ? "正在检查更新…" : "Checking for updates…")
      : state.phase === "ready" ? (zh ? "更新已准备好" : "Update ready")
      : state.available ? (zh ? "有可用更新" : "Update available")
      : state.comparison === 1 ? (zh ? "当前版本高于稳定版" : "Newer than stable")
      : state.comparison === 0 ? (zh ? "版本相同" : "Matching release version")
      : (zh ? "检查引擎更新" : "Check engine updates");
     ImGui.TextColored(App.themeColor, title);
     if (state.targetVersion) ImGui.Text(state.targetVersion);
     ImGui.TextDisabled(`${zh ? "当前版本" : "Installed"} ${state.currentVersion}`);
     ImGui.Dummy(Vec2(0, 10));
     ImGui.Text(`${state.platform}${state.packagePlatform ? ` · ${state.packagePlatform}` : ""}`);
     const disabled = state.prepared || state.phase === "checking" || state.phase === "downloading" || state.phase === "canceling" || state.phase === "installing";
     const sources = () => {
      const [changed, index] = ImGui.Combo(zh ? "更新源" : "Source", state.source === "AtomGit" ? 1 : 2, ["AtomGit", "GitHub"]);
      if (changed) Updater.checkForUpdates(index === 1 ? "AtomGit" : "GitHub");
     };
     if (disabled) ImGui.BeginDisabled(sources); else sources();
     if (state.publishedAt) ImGui.TextWrapped(`${zh ? "发布时间" : "Published"}: ${state.publishedAt}`);
     if (state.packageSize) ImGui.TextDisabled(`${string.format("%.1f", state.packageSize / 1048576)} MiB`);
     if (state.usedCache) ImGui.TextWrapped(zh ? "离线缓存结果，不作为新版本提示。请联网重新检查。" : "Offline cached result. Check again online to confirm availability.");
     if (state.source === "GitHub" && state.comparison === 0) ImGui.TextWrapped(zh ? "GitHub 无法判断发布修订；如需修复，可在安装选项中重新下载。" : "GitHub cannot compare release revisions. Redownload under installation options.");
     if (state.message !== "") ImGui.TextWrapped(state.message);
     if (state.progress) {
      ImGui.TextWrapped(state.progress.message);
      ImGui.ProgressBar(state.progress.progress, Vec2(-1, 22));
     }
     if (state.releaseUrl && ImGui.Button(zh ? "查看发布说明" : "Release notes", Vec2(-1, 32))) App.openURL(state.releaseUrl);
     if (state.platform === "Linux") ImGui.TextWrapped(zh ? "请在引擎所在设备通过 PPA / apt 更新：\nsudo apt update\nsudo apt install --only-upgrade dora-ssr" : "Update on the engine device via PPA / apt:\nsudo apt update\nsudo apt install --only-upgrade dora-ssr");
     if (ImGui.CollapsingHeader(zh ? "安装选项与校验信息" : "Installation and verification")) {
      ImGui.TextWrapped(zh ? "保留项目与设置。安装前验证文件大小和 SHA-256；AtomGit 同时验证发布签名。" : "Projects and settings are preserved. Size and SHA-256 are checked; AtomGit also verifies release signatures.");
      if (state.platform === "macOS") ImGui.TextWrapped(zh ? "Homebrew 用户也可继续使用 brew upgrade。" : "Homebrew installations can also use brew upgrade.");
      if (state.windows && state.packagePlatform && !disabled) {
       const [changed, choice] = ImGui.Combo(zh ? "图形后端" : "Graphics backend", backend, ["D3D12", "OpenGL"]);
       if (changed) backend = choice;
       const target = windowsUpdatePlatform(backend === 2 ? "wgl" : "d3d12", state.packagePlatform.endsWith("-msi"));
       if (target !== state.packagePlatform && state.canDownload && ImGui.Button(zh ? "下载切换版本" : "Download selected backend")) Updater.downloadUpdate(target);
      }
      if (state.canDownload && state.comparison === 0 && ImGui.Button(zh ? "重新下载安装包" : "Redownload package")) Updater.downloadUpdate();
      if (state.prepared && state.phase !== "installing" && ImGui.Button(zh ? "丢弃安装包" : "Discard package")) { confirm = false; Updater.discardPrepared(); }
     }
     if (confirm) ImGui.TextWrapped(zh ? "请先保存作品。确认后将退出并重启引擎，Android 将打开系统安装器。" : "Save your work first. Installation exits and restarts the engine, or opens the Android installer.");
    });
    ImGui.Separator();
    const cancelable = state.phase === "checking" || state.phase === "downloading";
    if (ImGui.Button(confirm ? (zh ? "返回" : "Back") : cancelable ? (zh ? "取消" : "Cancel") : state.prepared ? (zh ? "稍后安装" : "Later") : (zh ? "重新检查" : "Check again"), Vec2((width - 52) / 2, 40))) {
     if (confirm) confirm = false;
     else if (cancelable) Updater.cancelOperation();
     else if (state.prepared) node.removeFromParent(true);
     else Updater.checkForUpdates();
    }
    ImGui.SameLine();
    const action = () => {
     if (ImGui.Button(state.prepared ? confirm ? (zh ? "确认安装" : "Confirm install") : (zh ? "安装并重启" : "Install and restart") : (zh ? "下载更新" : "Download update"), Vec2((width - 52) / 2, 40))) {
      if (state.prepared) { if (confirm) { confirm = false; Updater.installUpdate(true); } else confirm = true; }
      else Updater.downloadUpdate();
     }
    };
    if ((state.available && state.canDownload) || state.phase === "ready") ImGui.PushStyleColor(StyleColor.Button, App.themeColor, () => ImGui.PushStyleColor(StyleColor.Text, Color(0xff17130a), action));
    else ImGui.BeginDisabled(action);
   });
  }));
  return false;
 });
 return node;
};
