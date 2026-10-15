import { isProjectPath } from '@dora-studio/contracts';

// Integrity checking, not authenticity: the host must load this from its trusted build.
export async function verifyDocumentBundle(input, language) {
  if (!['en', 'zh'].includes(language) || input?.version !== 1 || input.language !== language ||
      !Array.isArray(input.documents) || input.documents.length > 10000) throw new Error('Invalid document bundle');
  const documents = [];
  const names = new Set();
  let total = 0;
  for (const document of input.documents) {
    if (!document || typeof document.path !== 'string' || typeof document.text !== 'string' ||
        typeof document.sha256 !== 'string' || !/^[0-9a-f]{64}$/.test(document.sha256) ||
        !/^@dora-doc\/(dora-api|love-api|tic80-api|dora-tutorial)\//.test(document.path) ||
        !isProjectPath(document.path.slice('@dora-doc/'.length)) || names.has(document.path)) throw new Error('Invalid document record');
    if (document.text.length > 64 * 1024 * 1024) throw new Error('Document exceeds size limit');
    const bytes = new TextEncoder().encode(document.text);
    total += bytes.length;
    if (bytes.length > 64 * 1024 * 1024 || total > 256 * 1024 * 1024) throw new Error('Document bundle exceeds size limit');
    names.add(document.path);
    documents.push({ path: document.path, text: document.text, sha256: document.sha256, bytes });
  }
  // Capture the entire input before the first await, so callers cannot mutate later entries.
  for (const document of documents) {
    const digest = [...new Uint8Array(await crypto.subtle.digest('SHA-256', document.bytes))].map(byte => byte.toString(16).padStart(2, '0')).join('');
    if (digest !== document.sha256) throw new Error(`Document integrity mismatch: ${document.path}`);
  }
  return documents.map(({ path, text }) => ({ path, text }));
}
