# vast-cli.nix

A Nix flake for installing the Vast.ai CLI tool and automatically generating SSH configurations for your Vast.ai instances.

## Features

- Vast.ai CLI tool (`vastai`)
- SSH config generator for easy connection to instances
- Home Manager module for declarative configuration

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

### Using Home Manager

Add the module to your home-manager configuration:

```nix
{
  inputs = {
    vast-cli.url = "github:dialohq/vast-cli.nix";
  };

  # In your home.nix or home-manager configuration:
  imports = [ vast-cli.homeManagerModules.default ];

  programs.vastai = {
    enable = true;
    
    sshConfig = {
      enable = true;
      # Optional: specify API key file path
      # apiKeyFile = /path/to/api/key;
      # Defaults to ~/.config/vastai/vast_api_key
    };
  };
}
```

### Direct usage

You can also run the CLI directly without installation:

```bash
nix run github:dialohq/vast-cli.nix -- help
```

Or to run specific commands:

```bash
nix run github:dialohq/vast-cli.nix -- search offers
```

## SSH Config Generator

The flake includes a tool to generate SSH configurations for your Vast.ai instances:

```bash
# Generate SSH config (outputs to stdout)
nix run github:dialohq/vast-cli.nix#generate-ssh-config

# Or if installed via Home Manager:
generate-vast-ssh-config > ~/.ssh/vast-instances
```

The generated config will create entries like:
```
# Connection: direct
Host RTX-4090-20241220_143022-12345
    HostName 192.168.1.100
    Port 22001
    User root
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

### Authentication

The SSH config generator reads your API key from:
1. `VAST_API_KEY` environment variable (if set)
2. `~/.config/vastai/vast_api_key` file (default location)

## Usage

Once installed, see the [official Vast.ai documentation](https://vast.ai/docs/cli) to learn how to use the CLI tool.