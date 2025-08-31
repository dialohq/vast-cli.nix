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
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "vast-cli";
          version = "0.3.1";
          
          src = pkgs.fetchFromGitHub {
            owner = "vast-ai";
            repo = "vast-cli";
            rev = "252fe5a6a20ab433b000f09547a218968717dd0d";
            sha256 = "sha256-lD6rEjBfhmL9NgQaRnvQECGQZDZ0PbAghkbtoRmF+NI=";
          };
          
          nativeBuildInputs = [ 
            (pkgs.python312.withPackages (ps: with ps; [
              requests
              urllib3
            ]))
          ];
          
          installPhase = ''
            mkdir -p $out/bin
            cp vast.py $out/bin/vastai
            chmod +x $out/bin/vastai
            patchShebangs $out/bin/vastai
          '';
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [ self'.packages.default ];
        };
      };
    };
}
