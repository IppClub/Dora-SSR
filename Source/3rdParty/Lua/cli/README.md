These standalone CLI sources (`lua.c`, `luac.c`, and `Makefile`) are copied
unchanged from Lua 5.5.1: https://www.lua.org/ftp/lua-5.5.1.tar.gz

They use the Lua license in `../LICENSE`. Keep them in sync when upgrading
the engine's bundled Lua version.

The CLI entry points live in this subdirectory so builds collecting runtime
`*.c` files do not pick up their `main` functions. CI copies these files and
the parent directory's runtime sources into a temporary build directory;
`.github/actions/setup-engine-lua/setup.sh` builds the test interpreter
without downloading sources or writing build products into this directory.
