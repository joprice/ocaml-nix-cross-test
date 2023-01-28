
- `dune build -x armv7l bin-no-ctypes/main.exe`
  - this is an empty executable to test normal static linking without ctypes
- `dune build -x armv7l bin/main.exe`
  - running this command fails to link against dlopen

- `nix build  -L .#armv7l-static`
- `nix build  -L .#armv7l-static-no-ctypes`
