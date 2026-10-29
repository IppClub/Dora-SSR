#!/usr/bin/env python3
"""Check the actual PE export table against generated/manual .NET imports.

This is a static ABI check, not native execution or GPU acceptance.
"""
import argparse, hashlib, json, re, struct
from pathlib import Path
root=Path(__file__).resolve().parents[4]
def pe_exports(path):
    data=path.read_bytes();assert data[:2]==b'MZ', 'Expected a Windows PE DLL'
    header=struct.unpack_from('<I',data,0x3c)[0];assert data[header:header+4]==b'PE\0\0'
    machine,sections=struct.unpack_from('<HH',data,header+4)
    optional_size=struct.unpack_from('<H',data,header+20)[0];optional=header+24
    magic=struct.unpack_from('<H',data,optional)[0];assert magic in (0x10b,0x20b)
    directory=optional+(112 if magic==0x20b else 96)
    export_rva,export_size=struct.unpack_from('<II',data,directory);assert export_rva and export_size
    mappings=[]
    for i in range(sections):
        size,address,raw_size,offset=struct.unpack_from('<IIII',data,optional+optional_size+i*40+8)
        mappings.append((address,max(size,raw_size),offset))
    def resolve(rva):
        for address,size,offset in mappings:
            if address<=rva<address+size:
                result=offset+rva-address;assert result<len(data);return result
        raise ValueError('Unmapped PE RVA: '+hex(rva))
    export=resolve(export_rva);count=struct.unpack_from('<I',data,export+24)[0]
    names=resolve(struct.unpack_from('<I',data,export+32)[0]);result=set()
    for i in range(count):
        start=resolve(struct.unpack_from('<I',data,names+i*4)[0]);end=data.index(b'\0',start)
        result.add(data[start:end].decode('ascii'))
    return machine,result,hashlib.sha256(data).hexdigest()
def required_imports():
    pattern=r'\[DllImport\((?:Dll|"Dora")[^\]]*\)\]\s*(?:public|private|internal)\s+static\s+extern\s+\S+\s+(\w+)\s*\('
    files=list((root/'Tools/dora-cs/DoraCS/Dora').glob('**/*.cs'))+[Path(__file__).with_name('main.cs')]
    return {name for path in files for name in re.findall(pattern,path.read_text(encoding='utf-8-sig'))}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--library',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    a.output.unlink(missing_ok=True)
    machine,exports,sha=pe_exports(a.library);required=required_imports()
    assert len(required)>1000 and 'str_new' in required and 'godotnode_resize_viewport' in required, 'Import parser did not discover the binding ABI'
    missing=sorted(required-exports)
    result={'passed':not missing,'scope':'static PE export table vs all C# imports, including test entrypoints; no runtime/GPU test',
        'machine':hex(machine),'native_sha256':sha,'required_imports':len(required),'exported_names':len(exports),'missing':missing}
    a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2));assert not missing, 'C# imports missing from native DLL'
