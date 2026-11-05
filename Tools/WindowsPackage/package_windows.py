#!/usr/bin/env python3
"""Package one Windows x64 backend from a single verified staging directory."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess
import uuid
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[2]
UPGRADE_CODE = '6C06B597-3476-5181-AFBD-270E98D79035'
NS = 'http://wixtoolset.org/schemas/v4/wxs'
UI = NS + '/ui'
ET.register_namespace('', NS)
ET.register_namespace('ui', UI)

def element(parent, name, **attrs):
    return ET.SubElement(parent, '{'+NS+'}'+name, {k:str(v) for k,v in attrs.items()})

def pe_x64(file):
    with file.open('rb') as f:
        if f.read(2) != b'MZ': raise ValueError('Not a Windows executable: '+str(file))
        f.seek(60); offset=struct.unpack('<I', f.read(4))[0]
        f.seek(offset)
        if f.read(4) != b'PE\0\0' or f.read(2) != b'\x64\x86':
            raise ValueError('Expected x64 PE: '+str(file))

def package(stage, output, backend, format, version=None, mode="release"):
    stage=stage.resolve(); output=output.resolve(); output.mkdir(parents=True, exist_ok=True)
    if not version:
        version=json.loads((ROOT/'Tools/dora-dora/package.json').read_text()).get('doraVersion')
        version=re.search(r'DORA_VERSION\s+"([0-9.]+)"',(ROOT/'Source/Basic/Application.cpp').read_text()).group(1) if not version else version
    version='.'.join(version.lstrip('v').split('.')[:3])
    if not re.fullmatch(r'\d+\.\d+\.\d+',version): raise ValueError('Invalid MSI version')
    for name in ['Dora.exe','wa.dll']: pe_x64(stage/name)
    manifest_file=stage/'GodotRuntimeNotices/manifest.json'
    if manifest_file.is_file():
        pe_x64(stage/'dora_godot.dll')
        manifest=json.loads(manifest_file.read_text())
        if manifest['graphics_backend']!=backend or manifest['build_target']!='template_'+mode:
            raise ValueError('Wrong Godot backend or build mode')
        if manifest.get('architectures') != ['x86_64'] or hashlib.file_digest((stage/'dora_godot.dll').open('rb'),'sha256').hexdigest() != manifest.get('library_sha256'):
            raise ValueError('Godot DLL architecture or digest mismatch')
        artifacts=manifest.get('artifacts')
        if not isinstance(artifacts,dict) or not artifacts:
            raise ValueError('Missing Godot runtime artifact inventory')
        for relative, expected in artifacts.items():
            if relative == manifest['library']: continue
            relative_path=Path(relative)
            if relative_path.is_absolute() or '..' in relative_path.parts or '\\' in relative:
                raise ValueError('Unsafe Godot runtime artifact path')
            artifact=manifest_file.parent/relative_path
            if not artifact.is_file() or hashlib.sha256(artifact.read_bytes()).hexdigest()!=expected:
                raise ValueError('Missing or changed Godot runtime artifact: '+relative)

    elif (stage/'dora_godot.dll').exists():
        raise ValueError('Godot DLL has no runtime manifest')
    (stage/'DoraDistribution.json').write_text(json.dumps({'schema':1,'architecture':'x64','backend':backend,'version':version},indent=2)+'\n')
    stem='dora-ssr-v'+version+'-windows-x64'+('-opengl' if backend=='wgl' else '')+('-debug' if mode=='debug' else '')
    files=sorted(p for p in stage.rglob('*') if p.is_file() and p.name!='.DS_Store' and not p.name.startswith('._'))
    if (stage/'DoraInstallation.json').exists(): raise ValueError('MSI marker must not be present in portable staging')
    if any(p.is_symlink() for p in stage.rglob('*')): raise ValueError('Package contains symbolic links')
    if format in ['zip','both']:
        with zipfile.ZipFile(output/(stem+'.zip'),'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
            for p in files:z.write(p,p.relative_to(stage).as_posix())
    if format in ['msi','both']:
        work=output/'installer'; work.mkdir(exist_ok=True)
        marker=work/'DoraInstallation.json'
        marker.write_text(json.dumps({'schema':1,'format':'msi','upgradeCode':UPGRADE_CODE},indent=2)+'\n')
        identity='\n'.join(p.relative_to(stage).as_posix()+':'+hashlib.file_digest(p.open('rb'),'sha256').hexdigest() for p in files)
        identity=hashlib.sha256(identity.encode()).hexdigest()
        wix=ET.Element('{'+NS+'}Wix')
        product=element(wix,'Package',Name='Dora SSR',Manufacturer='IppClub',Version=version,Language='1033',Scope='perUser',UpgradeCode=UPGRADE_CODE,
                        ProductCode=str(uuid.uuid5(uuid.NAMESPACE_URL,'https://dora-ssr.net/msi/'+version+'/'+backend+'/'+identity)))
        element(product,'MajorUpgrade',AllowSameVersionUpgrades='yes',DowngradeErrorMessage='A newer Dora SSR version is already installed.')
        element(product,'MediaTemplate',EmbedCab='yes',CompressionLevel='high')
        element(product,'Property',Id='ARPCOMMENTS',Value='Dora SSR x64 '+('OpenGL' if backend=='wgl' else 'D3D12'))
        local=element(product,'StandardDirectory',Id='LocalAppDataFolder')
        programs=element(local,'Directory',Id='DoraPrograms',Name='Programs')
        install=element(programs,'Directory',Id='INSTALLFOLDER',Name='Dora SSR')
        feature=element(product,'Feature',Id='Main',Title='Dora SSR',Level='1')
        directories={'':install}
        def ident(prefix,value):return prefix+hashlib.sha256(value.encode()).hexdigest()[:28]
        def directory(rel):
            if rel in directories:return directories[rel]
            p=Path(rel); parent=directory('' if str(p.parent)=='.' else p.parent.as_posix())
            directories[rel]=element(parent,'Directory',Id=ident('D',rel),Name=p.name)
            return directories[rel]
        def component(parent,key):
            cid=ident('C',key)
            c=element(parent,'Component',Id=cid,Guid=str(uuid.uuid5(uuid.NAMESPACE_URL,'https://dora-ssr.net/component/'+key)),Bitness='always64')
            element(c,'RegistryValue',Root='HKCU',Key=r'Software\IppClub\DoraSSR\Installer',Name=cid,Type='integer',Value='1',KeyPath='yes')
            element(feature,'ComponentRef',Id=cid)
            return c
        for file in files+[marker]:
            rel=file.relative_to(stage).as_posix() if file!=marker else marker.name
            parent='' if str(Path(rel).parent)=='.' else Path(rel).parent.as_posix()
            c=component(directory(parent),rel)
            element(c,'File',Id=ident('F',rel),Source=str(file),Name=file.name)
        for rel,d in directories.items():
            c=component(d,'directory:'+rel)
            element(c,'RemoveFolder',Id=ident('R',rel),On='uninstall')
        menu=element(product,'StandardDirectory',Id='ProgramMenuFolder')
        menu=element(menu,'Directory',Id='DoraMenu',Name='Dora SSR')
        c=component(menu,'shortcut')
        element(c,'Shortcut',Id='DoraShortcut',Name='Dora SSR',Target='[INSTALLFOLDER]Dora.exe',WorkingDirectory='INSTALLFOLDER',Arguments='--asset "[INSTALLFOLDER]."')
        element(c,'RemoveFolder',Id='RemoveMenu',On='uninstall')
        ET.SubElement(product,'{'+UI+'}WixUI',{'Id':'WixUI_InstallDir','InstallDirectory':'INSTALLFOLDER'})
        license=work/'license.rtf'; raw=(ROOT/'LICENSE.txt').read_text().replace('\\','\\\\').replace('{','\\{').replace('}','\\}')
        license.write_text('{\\rtf1\\ansi '+raw.replace('\n','\\par\n')+'}')
        element(product,'WixVariable',Id='WixUILicenseRtf',Value=str(license))
        source=work/'Dora.wxs';ET.ElementTree(wix).write(source,encoding='utf-8',xml_declaration=True)
        subprocess.run(['wix','build',str(source),'-arch','x64','-ext','WixToolset.UI.wixext','-o',str(output/(stem+'.msi'))],check=True)
    hashes={p.name:hashlib.file_digest(p.open('rb'),'sha256').hexdigest() for p in output.glob(stem+'.*') if p.suffix in ['.zip','.msi']}
    (output/'SHA256SUMS').write_text(''.join(v+'  '+k+'\n' for k,v in hashes.items()))
    return hashes

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for key in ['stage','output']:p.add_argument('--'+key,type=Path,required=True)
    p.add_argument('--backend',choices=['d3d12','wgl'],required=True)
    p.add_argument('--format',choices=['zip','msi','both'],default='both');p.add_argument('--version')
    p.add_argument('--mode',choices=['debug','release'],default='release')
    a=p.parse_args(); print(json.dumps(package(a.stage,a.output,a.backend,a.format,a.version,a.mode),indent=2))
