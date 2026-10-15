#!/usr/bin/env python3
"""Dora SSR Web package builder.

Builds a distributable single-site Web game package for Dora SSR projects,
using an official Web IDE export as the engine template. Only the project
files (compiled Lua entry, optional audio assets) are replaced; engine
chunks, the HTML loader and licenses are cloned from the template, so the
output stays byte-compatible with what the IDE produces.

Usage:
    python3 webbuild.py --template <official-export.zip|export-dir> \
        --entry <init.lua> --out <out-dir> \
        [--zip <out.zip>] [--audio <sfx-dir>] [--entry-src <Script/Game/init.lua>] \
        [--lualib auto|none|<path>] [--no-compat-patches] [--quiet]

Hard rules encoded here (violating any of them makes the package fail the
Dora platform preflight or misbehave on real devices):

1. Manifest order must follow the IDE export convention: ``Audio/*`` files
   first, the ``lualib_bundle.lua`` file last. The platform-side preflight
   pairs manifest entries against package records in this exact order.
2. Project chunk files are named ``html-assets/<N>.js`` where N starts right
   after the last engine chunk index from the template (IDE reserves 0..3
   for the engine, projects start at 4).
3. ``runtime.json`` must be generated LAST and must match the ZIP content
   exactly (every file listed with size + sha256, runtime.json itself not
   listed - this matches the official export format).
4. ``html-loader.js`` keeps its loader body and only swaps the trailing
   config JSON: engine records survive, project records are appended.
5. The entry file must exist twice in the package (``init.lua`` plus its
   ``Script/Game/init.lua`` source copy) exactly like the IDE exports it.

The tool was battle-tested on 14 published Dora SSR Web games (see
README.md for the list of repositories).

Exit code 0 on success (including built-in verification), 1 on any failure.
"""

import argparse
import base64
import hashlib
import json
import os
import re
import sys
import zipfile

ENGINE_KEEP_FILES = [
    'dora-player-runtime.js', 'dora-web-features.json', 'dora-logo.png',
    'LICENSE-Dora.txt', 'LICENSES.3rdparty.md', 'NOTICE.txt', 'README-Web.txt',
    'index.html',
]

# index.html compatibility patches applied by default (all discovered while
# shipping real games; disable with --no-compat-patches):
#  * mobile viewport lock + touch handling
#  * requestAnimationFrame watchdog shim for embedded/older WebViews
#  * audio unlock on first user gesture (browser autoplay policies)
#  * canvas size bridge for responsive games


def sha256_bytes(data):
    return hashlib.sha256(data).hexdigest()


def read_template_file(template, name):
    """Read one file from the template, which may be a ZIP or a directory."""
    if isinstance(template, zipfile.ZipFile):
        return template.read(name)
    path = os.path.join(template, name)
    with open(path, 'rb') as handle:
        return handle.read()


def template_names(template):
    if isinstance(template, zipfile.ZipFile):
        return {n for n in template.namelist() if not n.endswith('/')}
    found = set()
    for root, _dirs, files in os.walk(template):
        for name in files:
            found.add(os.path.relpath(os.path.join(root, name), template).replace('\\', '/'))
    return found


def load_engine_chunks(template, names):
    """Extract the loader body, engine records and engine chunk list."""
    loader = read_template_file(template, 'html-loader.js').decode('utf-8')
    match = re.search(r'\}\)\((\{.*\})\);?\s*$', loader, re.S)
    if not match:
        raise SystemExit('template html-loader.js: trailing config JSON not found')
    cut = loader.rindex('})(')
    body = loader[:cut + 3]
    config = json.loads(match.group(1))
    records = config.get('records')
    if not isinstance(records, dict) or not records:
        raise SystemExit('template html-loader.js: records table not found')
    engine_records = {k: v for k, v in records.items() if not k.startswith('assets/')}
    engine_scripts = sorted({v['script'] for v in engine_records.values()})
    missing = [s for s in engine_scripts if s not in names]
    if missing:
        raise SystemExit('template missing engine chunks: %s' % ', '.join(missing))
    engine_version = config.get('manifest', {}).get('engineVersion')
    source_commit = None
    if 'runtime.json' in names:
        runtime = json.loads(read_template_file(template, 'runtime.json'))
        source_commit = runtime.get('sourceCommit') or runtime.get('sourceFingerprint')
        engine_version = engine_version or runtime.get('engineVersion')
    if not engine_version:
        raise SystemExit('template: engine version not found (html-loader.js / runtime.json)')
    return body, engine_records, engine_scripts, engine_version, source_commit


def collect_project_files(entry_path, entry_src, audio_dir, extra, lualib, names):
    """Project files in manifest order: audio first, extras, entry, lualib last."""
    project = {}
    if audio_dir and os.path.isdir(audio_dir):
        for name in sorted(os.listdir(audio_dir)):
            if name.lower().endswith('.wav'):
                with open(os.path.join(audio_dir, name), 'rb') as handle:
                    project['Audio/' + name] = handle.read()
    for source in extra:
        if os.path.isfile(source):
            with open(source, 'rb') as handle:
                project[os.path.basename(source)] = handle.read()
        elif os.path.isdir(source):
            walk = []
            for root, _dirs, files in os.walk(source):
                for name in files:
                    walk.append(os.path.relpath(os.path.join(root, name), source))
            for relative in sorted(walk):
                with open(os.path.join(source, relative), 'rb') as handle:
                    project[relative.replace('\\', '/')] = handle.read()
        else:
            raise SystemExit('extra asset path not found: %s' % source)
    with open(entry_path, 'rb') as handle:
        entry_data = handle.read()
    if entry_src:
        project[entry_src] = entry_data
    project['init.lua'] = entry_data
    if lualib and lualib != 'none':
        lib_path = lualib
        if lualib == 'auto':
            lib_path = os.path.join(os.path.dirname(os.path.abspath(entry_path)), 'lualib_bundle.lua')
        if os.path.isfile(lib_path):
            with open(lib_path, 'rb') as handle:
                project['lualib_bundle.lua'] = handle.read()
        elif lualib != 'auto':
            raise SystemExit('lualib bundle not found: %s' % lib_path)
    if not project:
        raise SystemExit('no project files collected')
    return project


def chunk_script(url, data):
    return 'DoraHtmlPackage.deliver("%s","%s");\n' % (url, base64.b64encode(data).decode('ascii'))


def apply_compat_patches(html):
    """Device compatibility patches for index.html (see module docstring)."""
    html = html.replace(
        '<meta name="viewport" content="width=device-width,initial-scale=1">',
        '<meta name="viewport" content="width=device-width,initial-scale=1,'
        'maximum-scale=1,user-scalable=no,viewport-fit=cover">')
    html = html.replace(
        'canvas { display: block; }',
        'canvas { display: block; touch-action: none; -webkit-user-select: none; '
        'user-select: none; -webkit-touch-callout: none; -webkit-tap-highlight-color: transparent; }')
    html = html.replace('</head>',
        '<script>(function(){var n=0,f=0,shimmed=false;'
        'var raw=window.requestAnimationFrame?window.requestAnimationFrame.bind(window):null;if(!raw)return;'
        'var shim=function(cb){return setTimeout(function(){cb(Date.now())},16)};'
        'window.requestAnimationFrame=function(cb){if(shimmed)return shim(cb);'
        'n++;var done=false;raw(function(t){done=true;f++;cb(t)});'
        'setTimeout(function(){if(!done&&n>1)shimmed=true},450)};})();</script></head>', 1)
    html = html.replace('</body>',
        '<script>(function(){'
        'var u=function(){try{window.DoraWebPlatform&&DoraWebPlatform.unlockAudio&&DoraWebPlatform.unlockAudio()}catch(e){}'
        'try{window.Module&&Module.doraAudio&&Module.doraAudio.resume&&Module.doraAudio.resume()}catch(e){}};'
        "['pointerdown','touchstart','click','keydown'].forEach(function(ev){window.addEventListener(ev,u,{passive:true})});"
        '})();</script></body>', 1)
    return html


def build(args):
    template = args.template
    if os.path.isdir(template):
        template = os.path.abspath(template)
    elif os.path.isfile(template) and template.lower().endswith('.zip'):
        template = zipfile.ZipFile(template)
    else:
        raise SystemExit('template must be an official Web export ZIP or extracted directory: %s' % template)

    names = template_names(template)
    for required in ('html-loader.js', 'index.html', 'runtime.json'):
        if required not in names:
            raise SystemExit('template missing required file: %s' % required)

    loader_body, engine_records, engine_scripts, engine_version, source_commit = \
        load_engine_chunks(template, names)

    # Rule 1: manifest order - audio first, extras, entry, lualib last.
    project = collect_project_files(args.entry, args.entry_src, args.audio,
                                    args.extra, args.lualib, names)

    # Rule 2: project chunk numbering continues after the engine chunks.
    last_engine_index = max(int(re.search(r'(\d+)\.js$', s).group(1)) for s in engine_scripts)
    records = dict(engine_records)
    manifest_files = []
    chunk_index = last_engine_index + 1
    for path, data in project.items():
        digest = sha256_bytes(data)
        url = 'assets/%s/%s' % (digest, path)
        script = 'html-assets/%d.js' % chunk_index
        records[url] = {'script': script, 'size': len(data), 'sha256': digest}
        manifest_files.append({'path': path, 'url': url, 'size': len(data),
                               'sha256': digest, 'startup': True})
        chunk_index += 1

    config = {'manifest': {'format': 'dora-web-game', 'version': 1,
                           'engineVersion': engine_version,
                           'profile': 'dora-preset', 'entry': 'init.lua',
                           'files': manifest_files},
              'records': records}
    html_loader = loader_body + json.dumps(config, separators=(',', ':'),
                                           ensure_ascii=False) + ');'

    files = {name: read_template_file(template, name)
             for name in ENGINE_KEEP_FILES if name in names}
    for script in engine_scripts:
        files[script] = read_template_file(template, script)
    files['html-loader.js'] = html_loader.encode('utf-8')

    if not args.no_compat_patches:
        files['index.html'] = apply_compat_patches(
            files['index.html'].decode('utf-8')).encode('utf-8')

    for manifest_entry in manifest_files:
        script = records[manifest_entry['url']]['script']
        files[script] = chunk_script(manifest_entry['url'],
                                     project[manifest_entry['path']]).encode('utf-8')

    # Rule 3: runtime.json is generated last and must match everything else.
    runtime = {'version': 1, 'engineVersion': engine_version,
               'sourceFingerprint': source_commit or engine_version,
               'files': {name: {'size': len(data), 'sha256': sha256_bytes(data)}
                         for name, data in files.items()},
               'format': 'html'}
    if source_commit:
        runtime['sourceCommit'] = source_commit
    files['runtime.json'] = json.dumps(runtime, separators=(',', ':'),
                                       ensure_ascii=False).encode('utf-8')

    os.makedirs(args.out, exist_ok=True)
    for name, data in files.items():
        path = os.path.join(args.out, name)
        os.makedirs(os.path.dirname(path) or args.out, exist_ok=True)
        with open(path, 'wb') as handle:
            handle.write(data)
    if args.zip:
        with zipfile.ZipFile(args.zip, 'w', zipfile.ZIP_DEFLATED) as archive:
            for name, data in sorted(files.items()):
                archive.writestr(name, data)
    if not args.quiet:
        print('built %d files (engine %s, %d project files) -> %s'
              % (len(files), engine_version, len(manifest_files), args.out))
    return files


def verify(zip_path, quiet=False):
    """Same checks as the Dora platform preflight: runtime.json vs ZIP content."""
    archive = zipfile.ZipFile(zip_path)
    names = {n for n in archive.namelist() if not n.endswith('/')}
    runtime = json.loads(archive.read('runtime.json'))
    listed = set(runtime['files'].keys())
    names.discard('runtime.json')  # official format: runtime.json does not list itself
    problems = []
    if listed != names:
        problems.append('manifest mismatch: extra=%s missing=%s'
                        % (sorted(listed - names)[:5], sorted(names - listed)[:5]))
    for name, meta in runtime['files'].items():
        if name in names:
            data = archive.read(name)
            if len(data) != meta['size'] or hashlib.sha256(data).hexdigest() != meta['sha256']:
                problems.append('content mismatch: %s' % name)
    if not quiet:
        print(('VERIFY OK: ' + zip_path) if not problems
              else ('VERIFY FAIL: ' + '; '.join(problems)))
    return problems


def main(argv=None):
    parser = argparse.ArgumentParser(description='Dora SSR Web package builder '
                                     '(template-based, IDE-export compatible)')
    parser.add_argument('--template', required=True,
                        help='official Web IDE export (.zip or extracted directory)')
    parser.add_argument('--entry', required=True,
                        help='compiled project entry file (init.lua)')
    parser.add_argument('--out', required=True, help='output directory')
    parser.add_argument('--zip', help='also write a distributable ZIP')
    parser.add_argument('--audio', help='directory of .wav files shipped as Audio/*')
    parser.add_argument('--extra', action='append', default=[], metavar='PATH',
                        help='additional asset file or directory to ship '
                             '(repeatable; directory trees keep relative paths)')
    parser.add_argument('--entry-src', help='source-tree copy of the entry '
                        '(IDE convention, e.g. Script/Game/init.lua)')
    parser.add_argument('--lualib', default='auto',
                        help="'auto' (lualib_bundle.lua next to entry), 'none', or a path")
    parser.add_argument('--no-compat-patches', action='store_true',
                        help='skip the index.html device compatibility patches')
    parser.add_argument('--quiet', action='store_true')
    args = parser.parse_args(argv)

    if not os.path.isfile(args.entry):
        raise SystemExit('entry file not found: %s' % args.entry)
    build(args)
    if args.zip:
        problems = verify(args.zip, args.quiet)
        return 1 if problems else 0
    return 0


if __name__ == '__main__':
    sys.exit(main())
