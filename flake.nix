{
  description = "A nix jail environment around LLM CLI tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
  };

  outputs =
    {
      self,
      jail-nix,
      nixpkgs,
      ...
    }:
    {
      lib.jaillm = import ./lib { inherit jail-nix; };
      overlays.default = (
        final: prev: {
          jaillm = self.lib.jaillm final {
            # Example: Add git to the jail
            # extraCombinators = cs: [
            #   (cs.add-pkg-deps [ final.git ])
            # ];
          };
        }
      );
    }
    // (
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config = {
            allowUnfreePredicate =
              pkg:
              builtins.elem pkg.pname [
                "claude-code"
                "codex"
                "github-copilot-cli"
                "gemini-cli"
              ];
          };
        };
      in
      {
        packages.${system} = {
          default = self.packages.${system}.jaillm;
          jaillm = pkgs.jaillm;
        };
      }
    );
}
