{ pkgs }:

rec {
  vast-cli = pkgs.stdenv.mkDerivation rec {
    pname = "vast-cli";
    version = "0.3.1";
    meta.mainProgram = "vastai";
    
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
  
  generate-ssh-config = pkgs.writeScriptBin "generate-ssh-config" ''
    #!${pkgs.python312.withPackages (ps: with ps; [ requests ])}/bin/python3
    ${builtins.readFile ./generate-ssh-config.py}
  '';
}