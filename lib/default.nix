{ jail-nix }:

let
  jaillm = import ./jail.nix { inherit jail-nix; };
  # Allow unfree packages for specific AI code generation tools.
  allowUnfree = pkg: builtins.elem pkg.pname [
    "claude-code"
    "codex"
    "github-copilot-cli"
    "gemini-cli"
  ];

in {
  inherit allowUnfree jaillm;
  build = nixpkgs: configure:
    let 
      pkgs = nixpkgs {
        config = {
          allowUnfreePredicate = allowUnfree;
        };
      };
    in jaillm pkgs (configure pkgs);
}
