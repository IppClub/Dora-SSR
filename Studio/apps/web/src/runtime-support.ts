import type {ProjectMessageKey} from './locales';

export function runtimeSupportProblem(features: {
  secure: boolean; isolated: boolean; sharedMemory: boolean; offscreen: boolean; transferCanvas: boolean;
}): ProjectMessageKey | null {
  if (!features.secure) return 'projects.runtimeSecureRequired';
  if (!features.isolated || !features.sharedMemory) return 'projects.runtimeIsolationRequired';
  if (!features.offscreen || !features.transferCanvas) return 'projects.runtimeCanvasUnsupported';
  return null;
}
