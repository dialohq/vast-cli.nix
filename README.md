# vast-cli.nix

A Nix flake for installing the Vast.ai CLI tool.

## Installation

### In a NixOS/nix-darwin configuration

Add this flake to your inputs:

```nix
{
  inputs = {
    vast-cli.url = "github:dialohq/vast-cli.nix";
    vast-cli.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, vast-cli, ... }: {
    # In your system configuration:
    environment.systemPackages = [
      vast-cli.packages.${pkgs.system}.default
    ];
  };
}
```

### In a development shell

Create a `flake.nix` in your project:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    vast-cli.url = "github:dialohq/vast-cli.nix";
  };

  outputs = { self, nixpkgs, vast-cli }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = [ vast-cli.packages.x86_64-linux.default ];
    };
  };
}
```

Then run `nix develop` to enter the shell with `vastai` available.

### Direct usage

You can also run the CLI directly without installation:

```bash
nix run github:dialohq/vast-cli.nix -- help
```

Or to run specific commands:

```bash
nix run github:dialohq/vast-cli.nix -- search offers
```

## Usage

Once installed, see the [official Vast.ai documentation](https://vast.ai/docs/cli) to learn how to use the CLI tool.