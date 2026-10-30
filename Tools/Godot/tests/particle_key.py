#!/usr/bin/env python3
"""Compile the owning Godot MaterialKey and test padding-independent identity.

CPU invariant only. Reads the actual pinned/prepared header and hash function,
not a second hand-written version of the key or a GPU simulation.
"""
import argparse, hashlib, json, re, subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
p.add_argument('--expect-broken',action='store_true');p.add_argument('--cxx',default='c++');a=p.parse_args()
out=a.output.resolve();out.mkdir(parents=True,exist_ok=True);report=out/'verification.json';report.unlink(missing_ok=True)
header=(a.source/'scene/resources/particle_process_material.h').read_text()
key=re.search(r'\tstruct MaterialKey \{\n.*?\n\t\};',header,re.S).group()
enums='\n'.join(re.search(r'\tenum '+name+r' \{\n.*?\n\t\};',header,re.S).group() for name in ('Parameter','ParticleFlags'))
hashes=(a.source/'core/templates/hashfuncs.h').read_text();hash_function=re.search(r'_FORCE_INLINE_ uint32_t hash_djb2_buffer\(.*?\n}',hashes,re.S).group()
widths=re.findall(r'uint64_t \w+ : (\w+);',key);assert len(widths)>10
program='#include <cstdint>\n#include <cstring>\n#define _FORCE_INLINE_ inline\n'+hash_function+'\n'+enums+'\n'+key+'''
int main() {
    static_assert(sizeof(MaterialKey)==8);
    static_assert(('''+'+'.join(widths)+''')<=56);
    MaterialKey first, second;
    first.texture_color=1;
    second=first;
    // Only unused high padding changes; all logical shader features stay equal.
    reinterpret_cast<unsigned char*>(&second)[sizeof(second)-1]^=0x80;
    if (!(first==second) || MaterialKey::hash(first)!=MaterialKey::hash(second)
        || first<second || second<first) return 7;
    second.texture_color=0;
    if (first==second) return 8;
    return 0;
}
'''
cpp=out/'particle_key.cpp';cpp.write_text(program);binary=out/'particle-key'
subprocess.run([a.cxx,'-std=c++20','-Wall','-Wextra','-Werror',str(cpp),'-o',str(binary)],check=True)
result=subprocess.run([str(binary)])
assert result.returncode==(7 if a.expect_broken else 0),('Material-key invariant',result.returncode)
value={'passed':True,'scope':'CPU-only actual Godot MaterialKey identity/hash/order under padding perturbation; no GPU execution',
       'expected_broken':a.expect_broken,'program_exit_code':result.returncode,'header_sha256':hashlib.sha256(header.encode()).hexdigest()}
report.write_text(json.dumps(value,indent=2)+'\n');print(json.dumps(value,indent=2))
