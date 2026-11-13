#!/usr/bin/env python3
"""Compare common PBR variants with the full shader in a running native Dora service.

Usage: python3 Tools/Tests/Model3D/test_base_color_pbr.py --dora PATH [--output DIR]
Requires Pillow. Fixtures are generated locally; no game or external assets are needed.
"""
import argparse
import base64
import copy
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import time

from PIL import Image, ImageChops, ImageStat


def make_fixtures(root):
    image = Image.new('RGBA', (64, 64))
    image.putdata([
        (230 if (x // 8 + y // 8) % 2 else 40, x * 4, y * 4, 0 if x < 16 else 128 if x < 32 else 255)
        for y in range(64) for x in range(64)
    ])
    image.save(root / 'checker.png')
    Image.new('RGB', (1, 1), 'white').save(root / 'white.png')
    normal_image = Image.new('RGB', (64, 64))
    normal_image.putdata([(100 + x, 100 + y, 240) for y in range(64) for x in range(64)])
    normal_image.save(root / 'normal.png')
    for name, pixel in [('mr', (255, 150, 180)), ('ao', (160, 255, 255)), ('emissive', (220, 80, 30))]:
        Image.new('RGB', (1, 1), pixel).save(root / (name + '.png'))
    for name, pixels in [
        ('mr-pattern', [(255, 64 + 3 * y, 32 + 3 * x) for y in range(64) for x in range(64)]),
        ('ao-pattern', [(64 + 3 * x, 255, 255) for y in range(64) for x in range(64)]),
        ('emissive-pattern', [(48 + 3 * x, 20 + 2 * y, 20 + (x + y) // 2) for y in range(64) for x in range(64)]),
    ]:
        pattern = Image.new('RGB', (64, 64))
        pattern.putdata(pixels)
        pattern.save(root / (name + '.png'))
    data = bytearray()
    views, accessors = [], []

    def accessor(values, fmt, kind, count, **extra):
        offset = len(data)
        data.extend(struct.pack('<' + fmt, *values))
        views.append({'buffer': 0, 'byteOffset': offset, 'byteLength': len(data) - offset})
        accessors.append({'bufferView': len(views) - 1, 'componentType': 5123 if fmt.endswith('H') else 5126,
                          'type': kind, 'count': count, **extra})
        return len(accessors) - 1

    positions = accessor([-.5, 0, -.5, .5, 0, -.5, .5, 0, .5, -.5, 0, .5], '12f', 'VEC3', 4,
                         min=[-.5, 0, -.5], max=[.5, 0, .5])
    normals = accessor([0, 1, 0] * 4, '12f', 'VEC3', 4)
    uv0 = accessor([0, 0, 1, 0, 1, 1, 0, 1], '8f', 'VEC2', 4)
    uv1 = accessor([1, 0, 1, 1, 0, 1, 0, 0], '8f', 'VEC2', 4)
    indices = accessor([0, 2, 1, 0, 3, 2], '6H', 'SCALAR', 6)
    material = {'doubleSided': True, 'pbrMetallicRoughness': {
        'baseColorFactor': [.7, .8, .9, .8], 'baseColorTexture': {'index': 0},
        'metallicFactor': 0, 'roughnessFactor': .7}}
    template = {
        'asset': {'version': '2.0'}, 'scene': 0, 'scenes': [{'nodes': [0]}], 'nodes': [{'mesh': 0}],
        'meshes': [{'primitives': [{'attributes': {'POSITION': positions, 'NORMAL': normals,
                        'TEXCOORD_0': uv0, 'TEXCOORD_1': uv1}, 'indices': indices, 'material': 0}]}],
        'materials': [material], 'buffers': [{'byteLength': len(data),
            'uri': 'data:application/octet-stream;base64,' + base64.b64encode(data).decode()}],
        'bufferViews': views, 'accessors': accessors,
        'images': [{'uri': name + '.png'} for name in ['checker', 'normal', 'white', 'mr', 'ao', 'emissive', 'mr-pattern', 'ao-pattern', 'emissive-pattern']],
        'textures': [{'source': i, 'sampler': 0} for i in range(9)],
        'samplers': [{'magFilter': 9728, 'minFilter': 9728, 'wrapS': 10497, 'wrapT': 10497}],
    }
    cases = ['opaque', 'mask', 'blend', 'uv1-transform', 'metallic', 'point-light', 'shadow', 'normal', 'clearcoat', 'emissive', 'transmission', 'sheen', 'anisotropy', 'core-uv', 'mirrored-tangent', 'runtime-normal'] + ['maps-' + str(i) for i in range(1, 32)]
    for name in cases:
        doc = copy.deepcopy(template)
        mat = doc['materials'][0]
        if name == 'mask':
            mat.update(alphaMode='MASK', alphaCutoff=.45)
        elif name == 'blend':
            mat['alphaMode'] = 'BLEND'
        elif name == 'uv1-transform':
            doc['extensionsUsed'] = ['KHR_texture_transform']
            mat['pbrMetallicRoughness']['baseColorTexture']['extensions'] = {
                'KHR_texture_transform': {'offset': [.2, .1], 'scale': [1.5, .7], 'rotation': .4, 'texCoord': 1}}
        elif name == 'metallic':
            mat['pbrMetallicRoughness'].update(metallicFactor=.8, roughnessFactor=.2)
        elif name == 'normal':
            mat['normalTexture'] = {'index': 1, 'scale': .8}
        elif name == 'clearcoat':
            doc['extensionsUsed'] = ['KHR_materials_clearcoat']
            mat['extensions'] = {'KHR_materials_clearcoat': {'clearcoatFactor': .8, 'clearcoatRoughnessFactor': .2}}
        elif name == 'emissive':
            mat['emissiveFactor'] = [.2, .1, .05]
        if name.startswith('maps-'):
            mask = int(name[5:])
            mat['pbrMetallicRoughness'].pop('baseColorTexture', None)
            if mask & 1: mat['pbrMetallicRoughness']['baseColorTexture'] = {'index': 0}
            if mask & 2: mat['pbrMetallicRoughness']['metallicRoughnessTexture'] = {'index': 3}
            if mask & 4: mat['normalTexture'] = {'index': 1, 'scale': .8}
            if mask & 8:
                mat['emissiveTexture'] = {'index': 5}
                mat['emissiveFactor'] = [.2, .1, .05]
            if mask & 16: mat['occlusionTexture'] = {'index': 4, 'strength': .7}
            mat['pbrMetallicRoughness']['metallicFactor'] = .6
        if name in ['transmission', 'sheen', 'anisotropy']:
            extension = 'KHR_materials_' + name
            doc['extensionsUsed'] = [extension]
            mat['extensions'] = {extension: {
                'transmission': {'transmissionFactor': .4},
                'sheen': {'sheenColorFactor': [.2, .1, .1], 'sheenRoughnessFactor': .3},
                'anisotropy': {'anisotropyStrength': .5},
            }[name]}
        if name in ['core-uv', 'mirrored-tangent']:
            mat['pbrMetallicRoughness']['metallicRoughnessTexture'] = {'index': 3}
            mat['normalTexture'] = {'index': 1, 'scale': .7}
            mat['occlusionTexture'] = {'index': 4, 'strength': .6}
            mat['emissiveTexture'] = {'index': 5}
            mat['emissiveFactor'] = [.2, .1, .05]
            if name == 'core-uv':
                doc['extensionsUsed'] = ['KHR_texture_transform']
                mat['pbrMetallicRoughness']['metallicRoughnessTexture']['index'] = 6
                mat['occlusionTexture']['index'] = 7
                mat['emissiveTexture']['index'] = 8
                doc['samplers'][0].update(magFilter=9729, minFilter=9729)
                for i, info in enumerate([mat['pbrMetallicRoughness']['baseColorTexture'], mat['pbrMetallicRoughness']['metallicRoughnessTexture'], mat['normalTexture'], mat['occlusionTexture'], mat['emissiveTexture']]):
                    info['extensions'] = {'KHR_texture_transform': {
                        'offset': [.1 + .03 * i, .2 - .02 * i], 'scale': [1.5 - .1 * i, .7 + .1 * i],
                        'rotation': .4 - .2 * i, 'texCoord': i % 2}}
            else:
                # Append explicit mirrored tangents, with a vec4-aligned buffer view.
                buf = bytearray(base64.b64decode(doc['buffers'][0]['uri'].split(',')[1]))
                buf.extend(bytes((-len(buf)) % 4))
                offset = len(buf)
                buf.extend(struct.pack('<16f', *([1, 0, 0, -1] * 4)))
                doc['bufferViews'].append({'buffer': 0, 'byteOffset': offset, 'byteLength': 64})
                doc['accessors'].append({'bufferView': len(doc['bufferViews']) - 1, 'componentType': 5126, 'type': 'VEC4', 'count': 4})
                doc['meshes'][0]['primitives'][0]['attributes']['TANGENT'] = len(doc['accessors']) - 1
                doc['buffers'][0] = {'byteLength': len(buf), 'uri': 'data:application/octet-stream;base64,' + base64.b64encode(buf).decode()}
        full = copy.deepcopy(doc)
        # A white specular map is visually neutral and requires the complete shader.
        full.setdefault('extensionsUsed', []).append('KHR_materials_specular')
        full['materials'][0].setdefault('extensions', {})['KHR_materials_specular'] = {'specularTexture': {'index': 2}}
        (root / (name + '.gltf')).write_text(json.dumps(doc))
        (root / (name + '-full.gltf')).write_text(json.dumps(full))
    return cases


def summarize_benchmark(root):
    import collections
    import statistics
    samples = collections.defaultdict(list)
    for line in (root / 'profiler.jsonl').read_text().splitlines():
        row = json.loads(line)
        samples[(row['case'], row['mode'])].append(row['sample']['info'])
    result = {}
    for case in ['maps-1', 'maps-5', 'maps-3', 'maps-7', 'maps-31']:
        result[case] = {}
        for mode in ['basic', 'full']:
            values = samples[(case, mode)]
            assert len(values) >= 6, (case, mode, 'Not enough steady-state samples')
            result[case][mode] = {'samples': len(values), **{
                key: statistics.mean(v[key] for v in values)
                for key in ['avgGPU', 'avgCPU', 'currentFPS', 'drawCall', 'tri']}}
        a, b = result[case]['basic'], result[case]['full']
        assert a['drawCall'] == b['drawCall'] and a['tri'] == b['tri'], case
        result[case]['gpu_reduction_percent'] = 100 * (1 - a['avgGPU'] / b['avgGPU'])
        result[case]['fps_gain_percent'] = 100 * (a['currentFPS'] / b['currentFPS'] - 1)
    (root / 'performance.json').write_text(json.dumps(result, indent=2))
    print(json.dumps(result, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dora', type=Path, required=True)
    parser.add_argument('--output', type=Path, default=Path('build/base-color-pbr-regression'))
    parser.add_argument('--benchmark', action='store_true', help='Three alternating rounds of five common PBR combinations, without frame limiting')
    parser.add_argument('--case', action='append', help='Run only the named material case (repeatable)')
    args = parser.parse_args()
    root = args.output.resolve()
    root.mkdir(parents=True, exist_ok=True)
    cases = make_fixtures(root)
    if args.benchmark: cases = ['maps-1', 'maps-5', 'maps-3', 'maps-7', 'maps-31']
    if args.case:
        assert set(args.case) <= set(cases), args.case
        cases = args.case
    shutil.copy2(Path(__file__).with_name('BaseColorPbr.ts'), root / 'init.ts')
    (root / 'BaseColorPbrConfig.ts').write_text('export const resultRoot = ' + json.dumps(root.as_posix()) + ';\nexport const caseNames: string[] = ' + json.dumps(cases) + ';\nexport const benchmark: boolean = ' + str(args.benchmark).lower() + ';\n')
    marker = root / 'result.txt'
    marker.unlink(missing_ok=True)
    env = {k: v for k, v in os.environ.items() if k.lower() not in ('http_proxy', 'https_proxy', 'all_proxy', 'no_proxy')}
    repo = Path(__file__).resolve().parents[3]
    command = [str(args.dora.resolve()), '--asset', str(repo / 'Assets'), 'cli']
    subprocess.run(command + ['buildrun', '-p', str(root)], env=env, check=True)
    deadline = time.monotonic() + 300
    while not marker.exists() and time.monotonic() < deadline:
        time.sleep(.2)
    if not marker.exists() or marker.read_text() != 'passed':
        raise AssertionError(marker.read_text() if marker.exists() else 'Runtime timed out')
    results = {}
    for case in cases:
        basic = Image.open(root / (case + '-basic.png')).convert('RGB')
        full = Image.open(root / (case + '-full.png')).convert('RGB')
        assert basic.size == full.size
        assert max(ImageStat.Stat(basic).var) > 1, (case, 'Empty capture')
        diff = ImageChops.difference(basic, full)
        maximum = max(channel[1] for channel in diff.getextrema())
        mean = sum(ImageStat.Stat(diff).mean) / 3
        results[case] = {'max_channel_error': maximum, 'mean_channel_error': mean}
        diff.save(root / (case + '-diff.png'))
        # Allow shader arithmetic rounding while catching UV, alpha, lighting or routing regressions.
        assert maximum <= 2 and mean < .01, (case, maximum, mean)
    (root / 'comparison.json').write_text(json.dumps(results, indent=2))
    print(json.dumps(results, indent=2))
    print(f'Passed: {len(cases)} material cases match the full shader.')
    if args.benchmark:
        summarize_benchmark(root)


if __name__ == '__main__':
    main()
