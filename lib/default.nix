{ jail-nix }:

let
  jaillm = import ./jail.nix { inherit jail-nix; };
  overlay = import ./overlay.nix jaillm;
  # Allow unfree packages for specific AI code generation tools.
  allowUnfree = pkg: builtins.elem pkg.pname [
    "claude-code"
    "codex"
    "github-copilot-cli"
    "gemini-cli"
  ];

in {
  inherit allowUnfree jaillm overlay;
  build = nixpkgs: configure:
    let 
      pkgs = nixpkgs {
        config = {
          allowUnfreePredicate = allowUnfree;
        };
      };
    in jaillm pkgs (configure pkgs);
}
