{ jail-nix }:

{
  # Allow unfree packages for specific AI code generation tools.
  allowUnfree = pkg: builtins.elem pkg.pname [
    "claude-code"
    "codex"
    "github-copilot-cli"
    "gemini-cli"
  ];
  jaillm = import ./jail.nix { inherit jail-nix; };
}
