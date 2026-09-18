import { validateSnapshot, isProjectPath } from '@dora-studio/contracts';

/** One immutable project and one isolated Lua state per compiler binding. */
export async function createTealCompiler(input, inputDeclarations, createModule) {
  const snapshot = structuredClone(input), declarations = structuredClone(inputDeclarations);
  const errors = validateSnapshot(snapshot);
  if (errors.length) throw new Error(errors.join('; '));
  const reserved = new Set();
  if (!Array.isArray(declarations)) throw new Error('Invalid Teal declarations');
  for (const file of declarations) {
    if (!isProjectPath(file.path) || !file.path.endsWith('.d.tl') || file.kind !== 'text' || typeof file.text !== 'string' || reserved.has(file.path)) {
      throw new Error('Invalid or duplicate Teal declaration');
    }
    reserved.add(file.path);
  }
  if (!reserved.has('Dora.d.tl') || !reserved.has('lua.d.tl')) throw new Error('Missing Teal base declarations');
  if (snapshot.files.some(file => reserved.has(file.path))) throw new Error('Project shadows a compiler declaration');
  const module = await createModule();
  const error = module.cwrap('teal_error', 'string', []);
  const addFile = module.cwrap('teal_add_file', null, ['string', 'number', 'number']);
  const check = module.cwrap('teal_check', 'number', ['number', 'number', 'string', 'number']);
  const checkLua = module.cwrap('teal_check_lua', 'number', ['number', 'number', 'string']);
  const compile = module.cwrap('teal_compile', 'number', ['number', 'number', 'string']);
  const getCode = module.cwrap('teal_compiled_source', 'string', []);
  const diagnostic = module.cwrap('teal_diagnostic', 'string', ['number', 'number']);
  let disposed = false;
  const dispose = () => { if (!disposed) { disposed = true; module._teal_close(); } };
  const withText = (text, callback) => {
    const bytes = new TextEncoder().encode(text), pointer = module._malloc(Math.max(1, bytes.length));
    if (!pointer) throw new Error('Teal allocation failed');
    try { module.HEAPU8.set(bytes, pointer); return callback(pointer, bytes.length); }
    finally { module._free(pointer); }
  };
  try {
    if (module._teal_open()) throw new Error(error() || 'Teal initialization failed');
    for (const file of declarations) withText(file.text, (pointer, length) => addFile(file.path, pointer, length));
    if (module._teal_init()) throw new Error(error() || 'Teal declaration initialization failed');
    for (const file of snapshot.files) if (file.kind === 'text') withText(file.text, (pointer, length) => addFile(file.path, pointer, length));
  } catch (error) { dispose(); throw error; }
  const target = (projectId, path) => {
    if (disposed) throw new Error('Teal compiler disposed');
    if (projectId !== snapshot.projectId || !isProjectPath(path)) throw new Error('Invalid Teal project target');
    const file = snapshot.files.find(file => file.path === path);
    if (!file || file.kind !== 'text') throw new Error('Teal target is not a text file');
    return file;
  };
  return {
    dispose,
    check(projectId, path, lax = false) {
      const file = target(projectId, path);
      // Lua follows the original load + filtered Teal pipeline, not raw lax Teal.
      const status = withText(file.text, (pointer, length) => path.endsWith('.lua')
        ? checkLua(pointer, length, path) : check(pointer, length, path, +lax));
      if (status === 2) throw new Error(error() || 'Teal check failed');
      const diagnostics = Array.from({ length: module._teal_diagnostic_count() }, (_, index) => ({
        type: diagnostic(index + 1, 1), path: diagnostic(index + 1, 2),
        line: Number(diagnostic(index + 1, 3)), column: Number(diagnostic(index + 1, 4)), message: diagnostic(index + 1, 5),
      }));
      return { success: status === 0, diagnostics, projectId, revision: snapshot.revision };
    },
    compile(projectId, path) {
      const file = target(projectId, path);
      const status = withText(file.text, (pointer, length) => compile(pointer, length, path));
      if (status === 2) throw new Error(error() || 'Teal compilation failed');
      return status === 0 ? { success: true, code: getCode(), tic80: Boolean(module._teal_compiled_tic80()), projectId, revision: snapshot.revision }
        : { success: false, message: error(), projectId, revision: snapshot.revision };
    },
  };
}
