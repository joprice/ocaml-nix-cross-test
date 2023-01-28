{
  description = "cross compilation test";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  #inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";
  inputs.nixpkgs.url = "/home/josephp/dev/nix-overlays";
  # Precisely filter files copied to the nix store
  inputs.nix-filter.url = "github:numtide/nix-filter";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}".extend (self: super: {
          ocamlPackages = self.ocaml-ng.ocamlPackages_4_14;
        });
        armv7l-static-pkg = (package:
          let
            pkgs' = pkgs.pkgsCross.armv7l-hf-multiplatform;
          in
          pkgs'.lib.callPackageWith pkgs' ./default.nix {
            inherit nix-filter package;
            inherit (pkgs') ocamlPackages;
            crossName = "armv7l";
            static = true;
            glibc = pkgs'.glibc;
            glibcStatic = pkgs'.glibc.static;
            alsaLib = pkgs'.pkgsStatic.alsaLib;
            SDL2 = pkgs'.SDL2.override { withStatic = true; };
            SDL2_mixer = pkgs'.SDL2_mixer.overrideAttrs (
              o: {
                configureFlags = o.configureFlags or [ ] ++ [
                  "--enable-shared=no"
                  "--enable-static=yes"
                ];
              }
            );
            libffi = pkgs'.pkgsStatic.libffi;
          });
      in
      {
        packages = {
          default =
            let ocamlPackages = pkgs.ocamlPackages;
            in
            pkgs.callPackage ./default.nix {
              inherit nix-filter;
            };
          arm64 =
            let pkgs' = pkgs.pkgsCross.aarch64-multiplatform;
            in
            pkgs'.lib.callPackageWith pkgs' ./default.nix {
              inherit nix-filter;
              crossName = "aarch64";
            };
          arm64-musl =
            let
              pkgs' = pkgs.pkgsCross.aarch64-multiplatform-musl;
            in
            pkgs'.lib.callPackageWith pkgs' ./default.nix {
              inherit nix-filter;
              crossName = "aarch64";
              static = true;
            };
          musl =
            let
              pkgs' = pkgs.pkgsCross.musl64;
            in
            pkgs'.lib.callPackageWith pkgs' ./default.nix {
              inherit nix-filter;
              inherit (pkgs') ocamlPackages;
              static = true;
            };
          armv7l =
            let
              pkgs' = pkgs.pkgsCross.armv7l-hf-multiplatform;
            in
            pkgs'.lib.callPackageWith pkgs' ./default.nix {
              inherit nix-filter;
              inherit (pkgs') ocamlPackages;
              crossName = "armv7l";
            };
          armv7l-musl =
            let
              pkgs' = pkgs.pkgsCross.armv7l-hf-multiplatform;
            in
            pkgs'.lib.callPackageWith pkgs'.pkgsMusl ./default.nix {
              inherit nix-filter;
              inherit (pkgs') ocamlPackages;
              crossName = "armv7l";
              static = true;
            };
          armv7l-static = armv7l-static-pkg "bin";
          armv7l-static-no-ctypes = armv7l-static-pkg "bin-no-ctypes";
        };
        devShells.default =
          pkgs.mkShell {
            #OCAMLFIND_TOOLCHAIN = "aarch64";
            OCAMLFIND_TOOLCHAIN = "armv7l";
            OCAMLFIND_CONF = self.packages.${system}.armv7l-static.OCAMLFIND_CONF;
            packages = with pkgs; [
              self.packages.${system}.armv7l-static.stdenv.cc
              #  dune_3
              #  nixpkgs-fmt
              #  ocamlPackages.ocamlformat
              #  # For `dune build --watch ...`
              #  fswatch
              #  # For `dune build @doc`
              #  ocamlPackages.odoc
              #  ocamlPackages.ocaml-lsp
              #  ocamlPackages.ocamlformat-rpc-lib
              #  ocamlPackages.utop
            ];
            inputsFrom = [
              self.packages.${system}.default
              # adding both of these allows for building with dune statically or dynamically
              #self.packages.${system}.armv7l-static
            ];
          };
      }
    );
}
