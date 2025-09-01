{
  description = "Nix flake for Vast.AI CLI and SSH config generator";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      
      flake = {
        homeManagerModules.default = ./home-manager-module.nix;
        homeManagerModules.vastai = ./home-manager-module.nix;
      };
      
      perSystem = { config, self', inputs', pkgs, system, ... }: let
        packages = import ./packages.nix { inherit pkgs; };
      in {
        packages = {
          default = packages.vast-cli;
          inherit (packages) generate-ssh-config;
        };
        
        devShells.default = pkgs.mkShell {
          inputsFrom = [ self'.packages.default ];
        };
      };
    };
}
