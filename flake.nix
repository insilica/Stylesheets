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
          runtimePkgs = [
            pkgs.ant
            pkgs.gnused
            pkgs.jdk11
            pkgs.libxml2
            pkgs.nodejs
            pkgs.perl
            pkgs.texlive.combined.scheme-full
          ];
          app = pkgs.runCommand "app" {} ''
            mkdir -p $out/app
            cp -r ${self}/. $out/app
          '';
      in {
        packages = { inherit runtimePkgs; };
        devShells.default = pkgs.mkShell {
          buildInputs = runtimePkgs ++ [ pkgs.clojure ];
        };
        image = pkgs.dockerTools.buildLayeredImage {
          name = "insilica/Stylesheets";
          tag = "latest";
          contents = pkgs.buildEnv {
            name = "image-root";
            paths = runtimePkgs ++ [ app pkgs.bash pkgs.coreutils];
            pathsToLink = [ "/bin" "/etc" "/var" "/app" ];
          };
          config = {
            WorkingDir = "/app";
            Cmd = ["/bin/java" "-jar" "target/stylesheets.jar"];
            ExposedPorts = { "7979/tcp" = {}; };
          };
        };
      });
}
