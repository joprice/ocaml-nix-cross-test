{ package ? "bin", libffi, pkg-config, SDL2, SDL2_mixer, alsaLib, ocamlPackages, nix-filter, crossName ? null, static ? false, patchelf, glibc ? null, glibcStatic ? null }:
ocamlPackages.buildDunePackage rec {
  pname = "cross_test";
  version = "0.1.0";
  duneVersion = "3";
  src = nix-filter.lib {
    root = ./cross_test;
    include = [
      ".ocamlformat"
      "dune-project"
      (nix-filter.lib.inDirectory "bin")
      (nix-filter.lib.inDirectory "bin-no-ctypes")
      (nix-filter.lib.inDirectory "lib")
      (nix-filter.lib.inDirectory "test")
    ];
  };
  strictDeps = true;
  OCAMLFIND_TOOLCHAIN = crossName;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = (if glibcStatic != null then [ glibcStatic ] else [ ]) ++
    [
      SDL2
      SDL2_mixer
    ];
  propagatedBuildInputs = with ocamlPackages; [
    yojson
    ppx_deriving_yojson
    bigstringaf
    ctypes
  ];
  buildPhase = ''
    dune build --profile ${if static then "static" else "release"} ${package}/main.exe 
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv _build/default/${package}/main.exe $out/bin/${pname}
    chmod +w $out/bin/${pname}
    # TODO: generalize to other arch
    #patchelf --set-interpreter /lib/ld-linux-armhf.so.3 $out/bin/${pname}
    chmod -w $out/bin/${pname}
  '';
}
