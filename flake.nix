{
  description = "Stylesheets";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let system = flake-utils.lib.system;
    in flake-utils.lib.eachSystem [
      system.x86_64-linux
      system.aarch64-linux
      system.aarch64-darwin
    ] (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in with pkgs; {
        packages = { inherit source; };
        devShells.default = mkShell {
          buildInputs = [
            ant
            jdk11
            libxml2
            nodejs
            perl
            texlive.combined.scheme-full
          ];
        };
      });
}
