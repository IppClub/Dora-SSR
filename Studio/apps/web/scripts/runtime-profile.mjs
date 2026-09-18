export function validateGameRuntimeProfile(features) {
  if (features.studioAgentHost === true) throw new Error('Trusted Agent host builds cannot be staged as game runtimes');
  if (features.studioAgentHost !== undefined && features.studioAgentHost !== false) throw new Error('Invalid Agent host build marker');
  if (features.activeProfile !== 'dora-preset' || !features.modules?.threads || !features.modules?.crossOriginIsolationRequired) {
    throw new Error('Studio runtime requires the verified pthread build');
  }
}
