import { isCorrelation } from '@dora-studio/contracts';
import { installRuntimeBridge } from './runtime-bridge';
import { runtimeStorageId } from './runtime-storage';
import { createRuntimeCapture, type CaptureModule } from './runtime-capture';

declare const __STUDIO_ENGINE_BUILD__: string;
declare const __STUDIO_ENGINE_VERSION__: string;
declare global {
  interface Window {
    Module: CaptureModule & { doraSnapshot?: Promise<unknown>; doraStorageId?: string | Promise<string> };
    doraSetState: (state: string, message: string) => void;
  }
}
const runtimeWindow = window;
try {
  const params = new URLSearchParams(location.hash.slice(1));
  const identity: unknown = JSON.parse(params.get('identity') || 'null');
  if (!isCorrelation(identity) || !('runId' in identity) || typeof identity.runId !== 'string' || !identity.runId.trim()) {
    throw new Error('Invalid runtime identity');
  }
  const bridge = installRuntimeBridge(window, runtimeWindow.Module, {
    parentOrigin: params.get('parentOrigin') || '', nonce: params.get('nonce') || '',
    identity: { ...identity, runId: identity.runId }, engineBuild: __STUDIO_ENGINE_BUILD__,
    engineVersion: __STUDIO_ENGINE_VERSION__,
    captureGame: createRuntimeCapture(runtimeWindow.Module),
  });
  runtimeWindow.Module.doraStorageId = runtimeStorageId(params.get('parentOrigin')!, identity.projectId);
  window.addEventListener('pagehide', bridge.dispose, { once: true });
} catch (error) {
  // Do not fall back to the bundled demo if configuration/handshake is invalid.
  runtimeWindow.Module.doraSnapshot = Promise.reject(error);
  void runtimeWindow.Module.doraSnapshot.catch(() => {});
  runtimeWindow.doraSetState('faulted', String(error));
}
