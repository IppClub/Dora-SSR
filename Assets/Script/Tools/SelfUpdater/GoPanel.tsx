// @preview-file off
import { React, toNode } from "DoraX";
import { App, Node, TextAlign, Vec2 } from "Dora";
import * as ScrollArea from "UI/Control/Basic/ScrollArea";
// Use native draw nodes so the panel, clip area and text share one render queue.
const vertices = (width: number, height: number, radius = 14) => {
 const result: Vec2.Type[] = [];
 for (const corner of [{x: width-radius,y: radius,start: -math.pi/2},{x: width-radius,y: height-radius,start: 0},{x: radius,y: height-radius,start: math.pi/2},{x: radius,y: radius,start: math.pi}]) {
  for (let i=0;i<=6;i++) { const angle=corner.start+i*math.pi/12; result.push(Vec2(corner.x+math.cos(angle)*radius,corner.y+math.sin(angle)*radius)); }
 }
 return result;
};
function MobilePanelSurface(props: {width: number; height: number; renderOrder?: number}) {
 return <draw-node renderOrder={props.renderOrder}><polygon-shape verts={vertices(props.width,props.height,24)} fillColor={0xff212225} borderWidth={1} borderColor={0xff525458} /></draw-node>;
}
function MobileButton(props: {x:number;y:number;width:number;height?:number;text:string;tag?:string;fontSize?:number;primary?:boolean;renderOrder?:number;onTapped():void}) {
 const height=props.height??48;
 return <node tag={props.tag} x={props.x} y={props.y} width={props.width} height={height} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={props.onTapped}>
  <draw-node renderOrder={props.renderOrder}><polygon-shape verts={vertices(props.width,height)} fillColor={props.primary?0xffffcc33:0xff2f3134} borderWidth={1} borderColor={props.primary?0xffffdd63:0xff525458} /></draw-node>
  <label x={props.width/2} y={height/2} renderOrder={0} fontName="sarasa-mono-sc-regular" fontSize={props.fontSize??17} text={props.text} color3={props.primary?0x17130a:0xf4f1e8} />
 </node>;
}
function MobileChoiceButton(props: {x:number;y:number;width:number;text:string;selected:boolean;disabled?:boolean;renderOrder?:number;onTapped():void}) {
 return <node opacity={props.disabled?0.45:1}><MobileButton {...props} height={40} fontSize={14} primary={props.selected} onTapped={()=>{if(!props.disabled)props.onTapped();}} /></node>;
}
import { attachGamepad } from "Dev/Mobile/Gamepad";
import { windowsUpdatePlatform } from "Tools/SelfUpdater/Manifest";
import * as Updater from "Tools/SelfUpdater/Service";

type Scroll = ReturnType<typeof ScrollArea> & {offset: Vec2.Type};
export const createGoUpdaterPanel = (onClosed: (this: void) => void) => {
 if (Updater.getState().phase === "idle") Updater.checkForUpdates();
 const host = Node();
 host.order = 16000; host.renderOrder = 16000; host.renderGroup = false;
 let serial = -1;
 let confirm = false;
 let details = false;
 let scroll: Scroll | undefined;
 let maxScroll = 0;
 const zh = string.match(App.locale, "^zh")[0] !== undefined;
 const close = () => host.removeFromParent(true);
 host.onCleanup(onClosed);
 const render = () => {
  const state = Updater.getState();
  serial = state.serial;
  const offset = scroll?.offset;
  host.removeAllChildren();
  host.scaleX = App.devicePixelRatio; host.scaleY = App.devicePixelRatio;
  const safe = App.safeArea;
  const width = math.min(460, safe.width - 24);
  const height = math.min(560, safe.height - 24);
  const x = safe.left + (safe.width - width) / 2 - App.visualSize.width / 2;
  const y = safe.bottom + (safe.height - height) / 2 - App.visualSize.height / 2;
  const busy = state.phase === "checking" || state.phase === "downloading" || state.phase === "canceling" || state.phase === "installing";
  const viewHeight = math.max(40, height - 160);
  const viewportWidth = width - 44;
  // ScrollArea paints its 10px scrollbar inside the viewport. Keep an 8px gap
  // between that track and every label/button, including expanded options.
  const contentWidth = viewportWidth - 18;
  const title = state.phase === "ready" ? (zh ? "更新已准备好" : "Update ready") : state.ignored ? (zh ? "已忽略此版本" : "This version is ignored") : state.available ? (zh ? "有可用更新" : "Update available") : state.phase === "checking" ? (zh ? "正在检查更新…" : "Checking for updates…") : state.comparison === 1 ? (zh ? "当前版本高于稳定版" : "Newer than stable") : (zh ? "引擎更新" : "Engine update");
  const text = (value: string, top: number, size = 14, color = 0xf4f1e8) => <label x={0} y={contentHeight - top} anchorX={0} anchorY={1} fontName="sarasa-mono-sc-regular" fontSize={size} renderOrder={0} text={value} textWidth={contentWidth} alignment={TextAlign.Left} color3={color} />;
  const click = (action: (this: void) => void) => () => { action(); if (host.parent) render(); };
  const message = confirm ? (zh ? "请先保存作品。确认后安装并重启；Android 将打开系统安装器。" : "Save your work first. Installation restarts the engine or opens the Android installer.") : state.usedCache ? (zh ? "当前为离线缓存结果，请联网重新检查。" : "Offline cached result. Check again online.") : state.progress?.message ?? state.message;
  // The fixed header/footer stay reachable even on a short landscape screen.
  const messageHeight = message !== "" ? 100 : 0;
  let contentHeight = 180 + messageHeight;
  if (state.releaseUrl) contentHeight += 48;
  contentHeight += 46;
  if (state.canIgnore) contentHeight += 46;
  if (details) contentHeight += 120 + (state.windows && state.canDownload ? 100 : 0) + (state.prepared || state.canDownload ? 50 : 0);
  const scrollNode = () => {
   scroll = ScrollArea({width: viewportWidth, height: viewHeight, viewWidth: viewportWidth, viewHeight: contentHeight, paddingX: 0, paddingY: 0, scrollBar: true}) as Scroll;
   scroll.renderOrder = 0;
   maxScroll = math.max(0, contentHeight - viewHeight);
   scroll.offset = Vec2(0, math.min(maxScroll, offset?.y ?? 0));
   let top = 180 + messageHeight;
   const notesTop = top; if (state.releaseUrl) top += 48;
   const detailTop = top; top += 46;
   const ignoreTop = top; if (state.canIgnore) top += 46;
   const descriptionTop = top; top += 120;
   const graphicsTop = top;
   if (state.windows && state.canDownload) top += 100;
   const repairTop = top;
   const body = toNode(<node width={contentWidth} height={contentHeight} anchorX={0} anchorY={0} y={viewHeight - contentHeight}>
    {text(title, 0, 15, 0xffcc33)}
    {text(state.targetVersion ?? "—", 30, 24)}
    {text(`${zh ? "当前版本" : "Installed"} ${state.currentVersion}`, 70, 12, 0xa8afbd)}
    {text(`${state.platform}${state.packageSize ? ` · ${string.format("%.1f", state.packageSize / 1048576)} MiB` : ""}`, 96, 12, 0xa8afbd)}
    <MobileChoiceButton renderOrder={0} x={0} y={contentHeight - 165} width={(contentWidth - 10) / 2} text="AtomGit" selected={state.source === "AtomGit"} disabled={busy || state.prepared} onTapped={click(() => { Updater.checkForUpdates("AtomGit"); })} />
    <MobileChoiceButton renderOrder={0} x={10 + (contentWidth - 10) / 2} y={contentHeight - 165} width={(contentWidth - 10) / 2} text="GitHub" selected={state.source === "GitHub"} disabled={busy || state.prepared} onTapped={click(() => { Updater.checkForUpdates("GitHub"); })} />
    {messageHeight > 0 ? text(message, 180, 12, 0xa8afbd) : undefined}
    {state.releaseUrl ? <MobileButton renderOrder={0} tag="engine-update-notes" x={0} y={contentHeight - notesTop - 36} width={contentWidth} height={36} fontSize={13} text={zh ? "查看发布说明" : "Release notes"} onTapped={() => App.openURL(state.releaseUrl!)} /> : undefined}
    <MobileButton renderOrder={0} tag="engine-update-details" x={0} y={contentHeight - detailTop - 34} width={contentWidth} height={34} fontSize={12} text={details ? (zh ? "收起安装信息" : "Hide installation info") : (zh ? "安装选项与校验信息" : "Installation and verification")} onTapped={click(() => { details = !details; })} />
    {state.canIgnore ? <MobileButton renderOrder={0} tag="engine-update-ignore" x={0} y={contentHeight - ignoreTop - 34} width={contentWidth} height={34} fontSize={12} text={zh ? "忽略此版本" : "Ignore this version"} onTapped={() => { if (Updater.ignoreUpdate()) close(); }} /> : undefined}
    {details ? text(state.platform === "Linux" ? "sudo apt update\nsudo apt install --only-upgrade dora-ssr" : (zh ? "项目和设置保留。安装前校验大小、SHA-256；AtomGit 另验证发布签名。\nmacOS 的 Homebrew 用户也可使用 brew upgrade。" : "Projects and settings are preserved. Package size, SHA-256 and AtomGit signatures are verified.\nHomebrew users can also use brew upgrade."), descriptionTop, 12, 0xa8afbd) : undefined}
    {details && state.windows && state.canDownload && state.packagePlatform ? <node>
     <MobileButton renderOrder={0} tag="engine-update-d3d12" x={0} y={contentHeight - graphicsTop - 40} width={contentWidth} height={40} fontSize={13} text={zh ? "下载 D3D12 图形版本" : "Download D3D12 backend"} onTapped={click(() => { Updater.downloadUpdate(windowsUpdatePlatform("d3d12", state.packagePlatform!.endsWith("-msi"))); })} />
     <MobileButton renderOrder={0} tag="engine-update-opengl" x={0} y={contentHeight - graphicsTop - 90} width={contentWidth} height={40} fontSize={13} text={zh ? "下载 OpenGL 兼容版本" : "Download OpenGL backend"} onTapped={click(() => { Updater.downloadUpdate(windowsUpdatePlatform("wgl", state.packagePlatform!.endsWith("-msi"))); })} />
    </node> : undefined}
    {details && ((state.canDownload && state.comparison === 0) || state.prepared) ? <MobileButton renderOrder={0} tag="engine-update-repair" x={0} y={contentHeight - repairTop - 40} width={contentWidth} height={40} fontSize={13} text={state.prepared ? (zh ? "丢弃安装包" : "Discard package") : (zh ? "重新下载安装包" : "Redownload package")} onTapped={click(() => { if (state.prepared) { confirm = false; Updater.discardPrepared(); } else Updater.downloadUpdate(); })} /> : undefined}
   </node>);
   body?.addTo(scroll.view);
   return scroll;
  };
  const scene = toNode(<node>
   <node x={-App.visualSize.width / 2} y={-App.visualSize.height / 2} width={App.visualSize.width} height={App.visualSize.height} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true}>
    <draw-node renderOrder={0}><rect-shape width={App.visualSize.width} height={App.visualSize.height} centerX={App.visualSize.width / 2} centerY={App.visualSize.height / 2} fillColor={0xb007080a} /></draw-node>
   </node>
   <node x={x} y={y} width={width} height={height} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true}>
    <MobilePanelSurface width={width} height={height} renderOrder={0} />
    <label x={22} y={height - 20} anchorX={0} anchorY={1} fontName="sarasa-mono-sc-regular" fontSize={20} renderOrder={0} text={zh ? "引擎更新" : "Engine update"} color3={0xf4f1e8} />
    <MobileButton renderOrder={0} tag="engine-update-close" x={width - 64} y={height - 62} width={44} height={40} text="×" onTapped={close} />
    <custom-node x={width / 2} y={86 + viewHeight / 2} onCreate={scrollNode} />
    <MobileButton renderOrder={0} tag="engine-update-secondary" x={22} y={24} width={(width - 56) / 2} height={48} fontSize={14} text={confirm ? (zh ? "返回" : "Back") : state.prepared ? (zh ? "稍后安装" : "Later") : busy ? (zh ? "取消" : "Cancel") : (zh ? "重新检查" : "Check again")} onTapped={click(() => { if (confirm) confirm = false; else if (state.prepared) close(); else if (busy) Updater.cancelOperation(); else Updater.checkForUpdates(); })} />
    {(state.comparison === -1 && state.canDownload) || state.phase === "ready" ? <MobileButton renderOrder={0} tag="engine-update-primary" x={34 + (width - 56) / 2} y={24} width={(width - 56) / 2} height={48} primary={true} fontSize={14} text={state.prepared ? confirm ? (zh ? "确认安装" : "Confirm install") : state.platform === "Android" ? (zh ? "打开安装器" : "Open installer") : (zh ? "安装并重启" : "Install & restart") : (zh ? "下载更新" : "Download update")} onTapped={click(() => { if (state.prepared) { if (confirm) { confirm = false; Updater.installUpdate(true); } else confirm = true; } else Updater.downloadUpdate(); })} /> : undefined}
   </node>
  </node>);
  scene?.addTo(host);
 };
 host.schedule(() => { if (serial !== Updater.getState().serial) render(); return false; });
 attachGamepad(host, { initialTag: "engine-update-primary", isEnabled: () => host.parent !== undefined, onBack: close, onScroll: amount => { if (scroll) scroll.offset = Vec2(0, math.max(0, math.min(maxScroll, scroll.offset.y + amount))); } });
 host.onAppChange(setting => { if (setting === "Size") render(); });
 host.onAppEvent(event => { if (event === "BackButton") close(); });
 render(); return host;
};
