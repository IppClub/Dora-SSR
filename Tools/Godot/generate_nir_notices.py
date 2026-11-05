#!/usr/bin/env python3
"""Reproduce notices for the pinned Godot NIR 25.3.1-1 GCC SDK.

Inputs are upstream source archives, never executed. Godot's patch is applied
only to a temporary copy. This is a conservative source-notice inventory;
component presence does not imply every header contributes executable code.
"""
import argparse
import ast
import fnmatch
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile
import tempfile

MESA_SHA = '15a688666aca976d1479c8bd43d319a55613da9a91aaf42a07691daec96ba7be'
NIR_SHA = '21ba3c0532caa580b50c530aefc851686b747b41d7984c228bcc0cef7ef5db82'
MESA_COMMIT = '5005a50879b11b953ade113fccd13a208f706ba0'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_archive(path, expected, prefix):
    assert digest(path.read_bytes()) == expected, 'Unrecognized source archive: ' + str(path)
    with tarfile.open(path) as archive:
        files = {}
        for entry in archive.getmembers():
            if not entry.isfile():
                continue
            assert entry.name.startswith(prefix + '/'), entry.name
            name = entry.name[len(prefix) + 1:]
            assert '..' not in PurePosixPath(name).parts, name
            files[name] = archive.extractfile(entry).read()
        return files


def comments(text):
    # Keep full comment blocks, including every copyright/permission paragraph.
    blocks = re.findall(r'/\*[\s\S]*?\*/|<!--[^>]*-->|(?:^[ \t]*(?://|\#)[^\n]*(?:\n|$))+', text, re.M)
    return [block.strip() for block in blocks if re.search(
        r'copyright|SPDX|licen[cs]e|permission|public domain|warranty|all rights reserved', block, re.I)]


def archive_object_names(data):
    """Read GNU ar long names portably, including on macOS's BSD ar host."""
    assert data.startswith(b'!<arch>\n'), 'Invalid static archive'
    offset, table, names = 8, b'', []
    while offset < len(data):
        header = data[offset:offset + 60]
        assert len(header) == 60 and header[-2:] == b'`\n', offset
        size = int(header[48:58])
        member = data[offset + 60:offset + 60 + size]
        assert len(member) == size, offset
        name = header[:16].decode('ascii').strip()
        if name == '//':
            table = member
        elif name not in ('/', '/SYM64/'):
            if name.startswith('/'):
                start = int(name[1:])
                end = table.index(b'/\n', start)
                name = table[start:end].decode('ascii')
            else:
                name = name.rstrip('/')
            assert name.endswith('.windows.x86_64.o'), name
            assert member[:2] == bytes([0x64, 0x86]), 'Non AMD64 object: ' + name
            names.append(name)
        offset += 60 + size + size % 2
    assert len(names) == len(set(names)) == 309, len(names)
    return names


def map_objects(sdk, selected, nir, script):
    sources = {}
    for name in selected:
        if PurePosixPath(name).suffix in ('.c', '.cpp'):
            stem = PurePosixPath(name).stem
            assert stem not in sources, 'Ambiguous source: ' + stem
            sources[stem] = name
    # Read literal build metadata only; never import or execute SConstruct.
    steps = next(ast.literal_eval(node.value) for node in ast.parse(nir['SConstruct']).body
                 if isinstance(node, ast.Assign) and any(
                     isinstance(target, ast.Name) and target.id == 'custom_build_steps'
                     for target in node.targets))
    generators = {PurePosixPath(output).stem: (folder, command, output, 'SConstruct')
                  for folder, command, output in steps if output.endswith('.c')}
    source_steps = script.split('run_custom_steps_at_source() {', 1)[1].split('copy_file() {', 1)[0]
    for folder, command in re.findall(r"^    run_step (\S+) '([^']+)'", source_steps, re.M):
        outputs = re.findall(r'\$OUTDIR/([\w.]+\.c)', command)
        for output in outputs:
            generators[PurePosixPath(output).stem] = (folder, command, output, 'update_mesa.sh')
    mapped = []
    for name in archive_object_names((sdk / 'bin/libNIR.windows.x86_64.a').read_bytes()):
        stem = name.split('.windows.', 1)[0]
        if stem in sources:
            mapped.append({'object': name, 'source': 'mesa/' + sources[stem]})
        else:
            assert stem in generators, 'Unmapped object: ' + name
            folder, command, output, origin = generators[stem]
            generator = folder + '/' + command.split()[0]
            assert generator in selected, generator
            mapped.append({'object': name, 'generated_source': folder + '/' + output,
                           'generator': 'mesa/' + generator, 'command': command,
                           'command_origin': origin})
    assert sum('source' in entry for entry in mapped) == 299
    assert sum('generator' in entry for entry in mapped) == 10
    return mapped


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mesa-source', type=Path, required=True)
    parser.add_argument('--nir-source', type=Path, required=True)
    parser.add_argument('--sdk-root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    # The SDK validator pins every header and the prebuilt static archive.
    from verify_d3d12_sdk import verify
    verify(args.sdk_root, Path(__file__).resolve().parents[2] /
           'Projects/xmake/godot/windows_d3d12_sdk.json')
    mesa = read_archive(args.mesa_source, MESA_SHA, 'mesa-' + MESA_COMMIT)
    nir = read_archive(args.nir_source, NIR_SHA, 'godot-nir-static-25.3.1-1')
    script = nir['update_mesa.sh'].decode()
    section = script.split('copy_sources() {', 1)[1].split('blacklist_sources()', 1)[0]
    selected = set()
    for kind, folder, pattern in re.findall(
            r'^\s+copy_(subir_sources|subir_headers|file)\s+(\S+)(?:\s+(\S+))?\s*$', section, re.M):
        if '$' in folder:
            continue
        folder = '' if folder == '.' else folder
        for name in mesa:
            path = PurePosixPath(name)
            if str(path.parent) != folder:
                continue
            if ((kind == 'subir_sources' and path.suffix in ('.c', '.cpp', '.h')) or
                    (kind == 'subir_headers' and path.suffix == '.h') or
                    (kind == 'file' and fnmatch.fnmatch(path.name, pattern))):
                selected.add(name)
    selected -= set(re.findall(r'^\s+rm godot-mesa/(\S+)', script, re.M))
    assert len(selected) == 696, len(selected)
    custom = script.split('copy_custom_steps_sources() {', 1)[1].split('copy_sources() {', 1)[0]
    for folder, name in re.findall(r'^\s*copy_file[ \t]+(\S+)[ \t]+(\S+)[ \t]*$', custom, re.M):
        selected.add(folder + '/' + name)
    selected.add('src/util/blake3/README')
    selected.update(['VERSION', 'bin/git_sha1_gen.py', 'src/compiler/spirv/spirv_info_gen.py',
                     'src/compiler/spirv/vtn_gather_types_c.py', 'src/compiler/spirv/spirv.core.grammar.json'])
    object_sources = map_objects(args.sdk_root, selected, nir, script)
    records = []
    groups = {}

    def collect(name, data):
        text = data.decode('utf-8')
        found = comments(text)
        if name.endswith('.json'):
            document = json.loads(text)
            if isinstance(document, dict) and 'copyright' in document:
                value = document['copyright']
                found.append('\n'.join(value) if isinstance(value, list) else str(value))
        records.append({'path': name, 'sha256': digest(data), 'notice_blocks': len(found)})
        for block in found:
            groups.setdefault(block, []).append(name)

    with tempfile.TemporaryDirectory(prefix='dora-nir-notices-') as temporary:
        work = Path(temporary)
        for name in sorted(selected):
            p = work / 'godot-mesa' / name
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_bytes(mesa[name])
        patch = work / 'godot.patch'
        patch.write_bytes(nir['godot-patches/01_godot_nir_goodies.patch'])
        subprocess.run(['patch', '--batch', '--fuzz=0', '-p1', '-i', str(patch)],
                       cwd=work, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for name in sorted(selected):
            collect('mesa/' + name, (work / 'godot-mesa' / name).read_bytes())
        compared = 0
        generated = []
        for p in sorted((args.sdk_root / 'godot-mesa').rglob('*.h')):
            name = p.relative_to(args.sdk_root / 'godot-mesa').as_posix()
            source = work / 'godot-mesa' / name
            if source.exists():
                assert source.read_bytes().replace(b'\r\n', b'\n') == p.read_bytes().replace(b'\r\n', b'\n'), name
                compared += 1
            else:
                generated.append(name)
                collect('sdk-generated/' + name, p.read_bytes())
        assert compared == 397 and len(generated) == 11, (compared, generated)
    # Include Vulkan headers and bridge notices from the same source tag.
    for name, data in sorted(nir.items()):
        if (name.endswith(('.h', '.c', '.cpp')) and
                (name.startswith('vulkan/') or name.startswith('drivers/'))):
            collect('godot-nir-static/' + name, data)
    text = ['Godot NIR 25.3.1-1 — third-party notices\n',
            'Mesa commit: ' + MESA_COMMIT + '\n',
            'Includes source/header/generator notices conservatively. Headers in this inventory\n'
            'may not contribute code to the runtime. Individual notices retain their own scope.\n'
            'Object/source mapping and source acquisition are recorded separately.\n']
    # Complete referenced license texts; unrelated Mesa GPL licenses are not copied.
    full_texts = [('Godot NIR wrapper license', nir['LICENSE.md']),
                  ('Vulkan headers license', nir['vulkan/LICENSE.txt']),
                  ('Mesa licensing overview', mesa['docs/license.rst'])]
    for name in ('MIT', 'Apache-2.0', 'BSL-1.0', 'SGI-B-2.0'):
        full_texts.append(('Mesa licenses/' + name, mesa['licenses/' + name]))
    blake3 = Path(__file__).parent / 'licenses/nir-25.3.1-1/blake3-1.8.2'
    blake3_sources = json.loads((blake3 / 'sources.json').read_text())
    for item in blake3_sources:
        data = (blake3 / item['file']).read_bytes()
        assert digest(data) == item['sha256'], item['file']
        if item['file'].startswith('LICENSE_'):
            full_texts.append(('BLAKE3 1.8.2 ' + item['file'], data))
    license_choice = (blake3 / 'README.md').read_text().split('## Licenses', 1)[1].split('## ', 1)[0]
    full_texts.append(('BLAKE3 upstream license choices', license_choice.encode()))
    full_texts.append(('Mesa BLAKE3 provenance', mesa['src/util/blake3/README']))
    for title, data in full_texts:
        text.extend(['\n' + '=' * 72 + '\n' + title + '\n\n', data.decode('utf-8'), '\n'])
    # Code/data extracted into files without their own notices retains the
    # predecessor's attribution. These are pinned source materials, not new
    # copyright statements written by Dora.
    lineage_path = Path(__file__).parent / 'licenses/nir-25.3.1-1/SOURCE_LINEAGE.json'
    lineage = json.loads(lineage_path.read_text())
    assert lineage['mesa_commit'] == MESA_COMMIT
    inherited = []
    for entry in lineage['historical_notices']:
        assert Path(entry['file']).name == entry['file']
        data = (lineage_path.parent / entry['file']).read_bytes()
        assert digest(data) == entry['notice_sha256'], 'Historical notice changed'
        assert entry['applies_to'] in {record['path'] for record in records}
        text.extend(['\n' + '=' * 72 + '\nHistorical predecessor notice for ',
                     entry['applies_to'], '\nSource: ', entry['source_path'],
                     '\nSource commit: ', entry['source_ref'], '\n\n', data.decode(), '\n'])
        inherited.append(dict(entry, notice_text=data.decode()))
    text.extend(['\n' + '=' * 72 + '\nGallium pipe_box component notice\n\n', (lineage_path.parent / 'box-component.NOTICE.txt').read_text()])
    for block, paths in sorted(groups.items(), key=lambda item: item[1][0]):
        text.extend(['\n' + '=' * 72 + '\nFiles:\n', '\n'.join(paths), '\n\n', block, '\n'])
    args.output.mkdir(parents=True, exist_ok=True)
    notice = args.output / 'GODOT-NIR-THIRD-PARTY-NOTICES.txt'
    notice.write_text(''.join(text), encoding='utf-8')
    provenance = {'schema': 3, 'godot_nir_tag': '25.3.1-1', 'mesa_commit': MESA_COMMIT,
                  'mesa_source_sha256': MESA_SHA, 'nir_source_sha256': NIR_SHA,
                  'object_sources': object_sources,
                  'object_mapping_scope': 'All 309 static archive members matched by unique source basename or literal upstream generator metadata; not a full rebuild or final-link contribution proof',
                  'blake3_license_sources': blake3_sources,
                  'patch_sha256': digest(nir['godot-patches/01_godot_nir_goodies.patch']),
                  'sdk_matching_headers': compared, 'sdk_generated_headers': generated,
                  'notice_sha256': digest(notice.read_bytes()), 'files': records,
                  'files_without_notice_blocks': [r['path'] for r in records if not r['notice_blocks']],
                  'historical_notice_sources': inherited,
                  'source_lineage_registry_sha256': digest(lineage_path.read_bytes()),
                  'scope': 'Conservative notice inventory, not a binary link contribution or legal opinion'}
    review_file = lineage_path.parent / 'LICENSE_REVIEW.json'
    review = json.loads(review_file.read_text())
    from verify_nir_review import verify_review
    verify_review(review, provenance, require_hash=False)
    for name, expected in review['evidence'].items():
        assert digest((lineage_path.parent / name).read_bytes()) == expected, 'License review evidence changed: ' + name
    for header in review.get('header_notice_sources', []):
        data = mesa[header['source']]
        assert digest(data) == header['source_sha256'], 'License header source changed'
        assert (lineage_path.parent / header['notice_file']).read_text().strip() == '\n\n'.join(comments(data.decode())), 'License header notice changed'
    provenance['license_review'] = review
    provenance['license_review_sha256'] = digest(review_file.read_bytes())
    (args.output / 'GODOT-NIR-PROVENANCE.json').write_text(json.dumps(provenance, indent=2) + '\n')
    print(json.dumps({'files': len(records), 'notice_groups': len(groups), 'bytes': notice.stat().st_size}))


if __name__ == '__main__':
    main()
