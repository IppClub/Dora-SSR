#!/usr/bin/env python3
"""Exercise the actual shared-library ABI without starting an OS/GPU runtime."""
import ctypes as c
import json
from pathlib import Path
import sys
class API(c.Structure):
    _fields_=[('size',c.c_uint32),('abi_version',c.c_uint32)]+[(name,c.c_void_p) for name in
        ['version','open','last_error','get_slot','advance','input','set_paused','restart_scene','close','shutdown']]
lib=c.CDLL(sys.argv[1])
get=lib.dora_godot_get_api
get.argtypes=[c.c_uint32,c.POINTER(API)]; get.restype=c.c_int
api=API(); api.size=c.sizeof(api)
assert get(2,c.byref(api))==0 and not api.open
api.size=4
assert get(1,c.byref(api))==0
api.size=c.sizeof(api)
assert get(1,c.byref(api))==1 and api.abi_version==1
assert all(getattr(api,name) for name,_ in API._fields_[2:])
version=c.CFUNCTYPE(c.c_char_p)(api.version)().decode()
assert '4.6' in version
assert not c.CFUNCTYPE(c.c_void_p,c.c_void_p)(api.open)(None)
error=c.CFUNCTYPE(c.c_char_p,c.c_void_p)(api.last_error)(None).decode()
assert 'invalid' in error
assert c.CFUNCTYPE(c.c_int,c.c_void_p,c.c_uint32,c.c_void_p)(api.get_slot)(None,0,None)==0
assert c.CFUNCTYPE(c.c_uint64,c.c_void_p,c.c_uint32,c.c_uint64)(api.advance)(None,0,0)==0
assert c.CFUNCTYPE(c.c_int,c.c_void_p,c.c_void_p)(api.input)(None,None)==0
assert c.CFUNCTYPE(c.c_int,c.c_void_p,c.c_int)(api.set_paused)(None,1)==0
assert c.CFUNCTYPE(c.c_int,c.c_void_p,c.c_char_p)(api.restart_scene)(None,None)==0
c.CFUNCTYPE(None,c.c_void_p,c.c_void_p)(api.close)(None,None)
c.CFUNCTYPE(None)(api.shutdown)()
print(json.dumps({'passed':True,'scope':'actual C ABI negotiation and invalid-handle calls (no GPU runtime)','version':version},indent=2))
