export function runtimeSupportProblem(features: {
  secure: boolean; isolated: boolean; sharedMemory: boolean; offscreen: boolean; transferCanvas: boolean;
}): string | null {
  if (!features.secure) return '试玩需要 HTTPS 或 localhost 安全环境。';
  if (!features.isolated || !features.sharedMemory) return '试玩需要跨来源隔离与共享内存，请检查服务的 COOP/COEP 配置或浏览器支持。';
  if (!features.offscreen || !features.transferCanvas) return '当前浏览器不支持独立线程画布，暂时无法试玩；项目仍可编辑和保存。';
  return null;
}
