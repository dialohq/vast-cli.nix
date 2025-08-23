{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "vast-cli";
          version = "0.3.1";
          src = ./.;
          nativeBuildInputs = [ 
            pkgs.uv
            pkgs.python312
          ];
          dontStrip = true;
          dontFixup = true;
          buildPhase = ''
            uv venv --no-cache --relocatable
            uv sync --no-cache
          '';
          installPhase = ''
            mkdir -p $out/
            mv .venv/* $out/
          '';
          __noChroot = true;
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [ self'.packages.default ];
        };
      };
    };
}
