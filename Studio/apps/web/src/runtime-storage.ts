/** Stable preview namespace; never use revision/runId, which change on replay. */
export async function runtimeStorageId(parentOrigin: string, projectId: string): Promise<string> {
  const input = new TextEncoder().encode(JSON.stringify(['studio-preview-v1', parentOrigin, projectId]));
  const hash = await crypto.subtle.digest('SHA-256', input);
  return `preview-${[...new Uint8Array(hash)].map(byte => byte.toString(16).padStart(2, '0')).join('')}`;
}
