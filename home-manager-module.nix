{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.vastai;
  packages = import ./packages.nix { inherit pkgs; };

in {
  options.programs.vastai = {
    enable = mkEnableOption "Vast.AI CLI and SSH config generator";
    
    package = mkOption {
      type = types.package;
      default = packages.vast-cli;
      defaultText = literalExpression "vast-cli package";
      description = "The Vast.AI CLI package to use";
    };
    
    sshConfig = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable SSH config generation for Vast.AI instances";
      };
      
      apiKeyFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to file containing Vast.AI API key. If not set, will try to read from ~/.config/vastai/vast_api_key
        '';
      };
      
      includeFile = mkOption {
        type = types.str;
        default = "~/.ssh/vast-instances";
        description = ''
          Path where the generated SSH config will be included from. Run 'generate-vast-ssh-config' to update.
        '';
      };
      
      package = mkOption {
        type = types.package;
        default = packages.generate-ssh-config;
        defaultText = literalExpression "generate-vast-ssh-config script";
        description = "The SSH config generator script package to use";
      };
    };
  };
  
  config = mkIf cfg.enable {
    home.packages = [ 
      cfg.package
    ] ++ (optional cfg.sshConfig.enable cfg.sshConfig.package);
    
    programs.ssh = mkIf (cfg.sshConfig.enable && config.programs.ssh.enable) {
      includes = config.programs.ssh.includes ++ [ cfg.sshConfig.includeFile ];
    };
  };
}