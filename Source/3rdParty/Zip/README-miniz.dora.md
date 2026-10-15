# Dora miniz integration

`miniz.c` and `miniz.h` are Dora's single canonical miniz source copy. The
current baseline is miniz 3.0.0. It supplies:

- ZIP archive support used by `ZipUtils` and Dora content loading;
- zlib-compatible `mz_*` functions used by libopenmpt J2B loading;
- compression functions used by TinyEXR through bimg.

The final Dora application target compiles `miniz.c` exactly once. The static
Love/OpenMPT and bimg libraries include this directory for declarations but do
not contain their own miniz object, so their references resolve to that one
final implementation. The optional standalone `bgfx-shared` final product
also compiles this canonical source once to resolve its internal TinyEXR
references.

The former libopenmpt 2.1.0 copy carried several OpenMPT hardening changes.
The 3.0.0 baseline already has their general equivalents: unaligned loads are
disabled, platform feature checks are guarded, allocator declarations are
correct, and stdio-dependent APIs have `MINIZ_NO_STDIO` guards. OpenMPT-only
feature selection remains in its build configuration instead of changing the
full ZIP API required by Dora globally.
