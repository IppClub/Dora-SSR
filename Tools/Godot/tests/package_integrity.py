#!/usr/bin/env python3
"""Negative deployment checks; no runtime or GPU execution."""
import json,sys,tempfile,unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from package_manifest import seal,digest
from verify_package import verify

class PackageIntegrity(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        (self.root/'runtime.so').write_bytes(b'fixture library')
        (self.root/'LICENSE.txt').write_text('fixture license')
        self.manifest=seal(self.root,{'library':'runtime.so','library_sha256':digest(self.root/'runtime.so'),'licenses':['LICENSE.txt']})
        self.save()
    def save(self):
        (self.root/'manifest.json').write_text(json.dumps(self.manifest))
    def rejects(self):
        with self.assertRaises((ValueError,FileNotFoundError)):verify(self.root)
    def test_valid(self):self.assertTrue(verify(self.root)['passed'])
    def test_corrupt_library(self):
        (self.root/'runtime.so').write_bytes(b'corrupt');self.rejects()
    def test_missing_license(self):
        (self.root/'LICENSE.txt').unlink();self.rejects()
    def test_changed_license(self):
        (self.root/'LICENSE.txt').write_text('different');self.rejects()
    def test_extra_library(self):
        (self.root/'stale.so').write_bytes(b'old');self.rejects()
    def test_bad_abi(self):
        self.manifest['bridge_abi']=99;self.save();self.rejects()
    def test_bad_source(self):
        self.manifest['source_archive_sha256']='0'*64;self.save();self.rejects()
    def test_valid_architectures(self):
        self.manifest['architectures']=['arm64','x86_64'];self.save();self.assertTrue(verify(self.root)['passed'])
    def test_empty_architectures(self):
        self.manifest['architectures']=[];self.save();self.rejects()
    def test_duplicate_architectures(self):
        self.manifest['architectures']=['arm64','arm64'];self.save();self.rejects()
    def test_unknown_architecture(self):
        self.manifest['architectures']=['mips64'];self.save();self.rejects()
    def test_seal_preserves_identity(self):
        with self.assertRaises(ValueError):seal(self.root,{'source_archive_sha256':'0'*64})
    def test_missing_payload(self):
        self.manifest.pop('library');self.manifest.pop('library_sha256');self.save();self.rejects()
    def test_path_escape(self):
        self.manifest['artifacts']['../outside']='0'*64;self.save();self.rejects()
    def test_symlink(self):
        (self.root/'alias.so').symlink_to(self.root/'runtime.so')
        self.manifest['artifacts']['alias.so']=digest(self.root/'runtime.so');self.save();self.rejects()

if __name__=='__main__':unittest.main()
