"""Regression tests for exported asset paths and HTML chunk delivery."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

import webbuild


class WebBuildTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.template = self.root / 'template'
        (self.template / 'html-assets').mkdir(parents=True)
        # Same loader/config protocol as HtmlArchive.ts; no WASM needed to
        # exercise paths, serialization, hashes and delivery validation.
        config = {'manifest': {'engineVersion': '1.9.3'}, 'records': {
            'dora-player-runtime.wasm': {'script': 'html-assets/0.js', 'size': 6,
                                         'sha256': webbuild.sha256_bytes(b'engine')}}}
        (self.template / 'html-assets/0.js').write_bytes(b'engine')
        (self.template / 'html-loader.js').write_text('(function(config){})(' + json.dumps(config) + ');')
        (self.template / 'runtime.json').write_text(json.dumps({
            'engineVersion': '1.9.3', 'sourceCommit': 'commit', 'sourceFingerprint': 'dirty-fingerprint'}))
        (self.template / 'index.html').write_text('<html><head></head><body></body></html>')
        self.entry = self.root / 'init.lua'
        self.entry.write_text('return true')
        self.image = self.root / 'Image'
        self.image.mkdir()
        (self.image / 'hero.png').write_bytes(b'image')
        self.args = argparse.Namespace(template=str(self.template), entry=str(self.entry),
            entry_src='Script/Game/init.lua', audio=None, extra=[str(self.image)], lualib='none',
            no_compat_patches=False, out=str(self.root / 'out'), zip=str(self.root / 'game.zip'), quiet=True)

    def build(self):
        return webbuild.build(self.args)

    def config(self, files):
        return json.loads(files['html-loader.js'].decode().split('})(', 1)[1][:-2])

    def test_directory_path_and_fingerprints(self):
        files = self.build()
        self.assertEqual([x['path'] for x in self.config(files)['manifest']['files']],
                         ['Image/hero.png', 'Script/Game/init.lua', 'init.lua'])
        self.assertEqual(webbuild.verify(self.args.zip, True), [])
        self.assertEqual(webbuild.verify(self.args.out, True), [])
        runtime = json.loads(files['runtime.json'])
        self.assertEqual(runtime['sourceCommit'], 'commit')
        self.assertEqual(runtime['sourceFingerprint'], 'dirty-fingerprint')

    def test_escaped_and_unicode_filenames_are_executable(self):
        for name in ['人物.png', 'bad"name.png', 'percent%23.png', 'space #.png']:
            (self.image / name).write_bytes(name.encode())
        files = self.build()
        config = self.config(files)
        scripts = [files[record['script']].decode() for url, record in config['records'].items()
                   if url.startswith('assets/')]
        delivered = subprocess.check_output(['node', '-e',
            'const got=[];global.DoraHtmlPackage={deliver:(url,data)=>got.push(url)};'
            + '\n'.join(scripts) + '\nconsole.log(JSON.stringify(got));'], text=True)
        self.assertEqual(set(json.loads(delivered)),
                         {webbuild.unquote(x['url']) for x in config['manifest']['files']})
        self.assertEqual(webbuild.verify(self.args.zip, True), [])

    def test_semantic_verification_catches_misdelivered_chunk(self):
        files = self.build()
        config = self.config(files)
        script = config['records'][webbuild.unquote(config['manifest']['files'][0]['url'])]['script']
        bad = webbuild.chunk_script('wrong-url', b'image').encode()
        (Path(self.args.out) / script).write_bytes(bad)
        runtime = json.loads(files['runtime.json'])
        runtime['files'][script] = {'size': len(bad), 'sha256': webbuild.sha256_bytes(bad)}
        (Path(self.args.out) / 'runtime.json').write_text(json.dumps(runtime))
        self.assertIn('invalid project delivery: Image/hero.png', webbuild.verify(self.args.out, True))

    def test_rejects_dirty_output_directory(self):
        out = Path(self.args.out)
        out.mkdir()
        (out / 'stale.js').write_text('stale')
        with self.assertRaisesRegex(SystemExit, 'output directory must be empty'):
            self.build()
        self.assertEqual((out / 'stale.js').read_text(), 'stale')

    def test_rejects_invalid_entry_path_and_missing_audio(self):
        self.args.entry_src = '../init.lua'
        with self.assertRaisesRegex(SystemExit, 'invalid package path'):
            self.build()
        self.args.entry_src = None
        self.args.audio = str(self.root / 'missing')
        with self.assertRaisesRegex(SystemExit, 'audio directory not found'):
            self.build()

    def test_compat_patch_keeps_animation_frame_contract(self):
        html = webbuild.apply_compat_patches('<head></head><body></body>')
        self.assertNotIn('requestAnimationFrame=', html)
        self.assertNotIn('Date.now()', html)


if __name__ == '__main__':
    unittest.main()
