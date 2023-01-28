{
  description = "cross compilation test";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      # let armPkgs = nixpkgs.legacyPackages."aarch64-linux"; in
      {
        packages = flake-utils.lib.flattenTree { };
        devShells.default =
          pkgs.mkShell {
            buildInputs = [
            ];
          };
      });
}
