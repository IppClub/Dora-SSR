import type {PackageFiles} from './Archive';

// Conservative static detection: aliases/imports and dynamic property names
// retain their original API token. Unrelated binary assets are never decoded.
export function projectNeedsGodot(project: PackageFiles): boolean {
  return Object.entries(project).some(([name, bytes]) => {
    if (/(?:^|\/)project\.godot$|\.(?:pck|gd|tscn|scn|tres|gdshader)$/i.test(name)) return true;
    if (!/\.(?:lua|yue|tl|ts|tsx|js|jsx|xml|wasm)$/i.test(name)) return false;
    let source = new TextDecoder().decode(bytes);
    // Preserve strings (including quoted API/property names), discard comments.
    const comments = /\.(?:lua|yue|tl)$/i.test(name)
      ? /(["'])(?:\\.|(?!\1)[\s\S])*\1|--\[(=*)\[[\s\S]*?\]\2\]|--[^\r\n]*/g
      : /\.(?:ts|tsx|js|jsx)$/i.test(name)
        ? /(["'`])(?:\\.|(?!\1)[\s\S])*\1|\/\*[\s\S]*?\*\/|\/\/[^\r\n]*/g
        : /\.xml$/i.test(name) ? /<!--[\s\S]*?-->/g : undefined;
    if (comments) source = source.replace(comments, (text, quote) => typeof quote === 'string' ? text : '');
    return /\b(?:GodotNode|GodotPlayer)\b|\bgodotnode_[a-z_]+\b/.test(source);
  });
}
