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
    let
      lib = import ./lib { inherit jail-nix; };
    in {
      inherit lib;
      overlays.default = lib.overlay;
    }
    // (
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config = {
            allowUnfreePredicate = self.lib.allowUnfree;
          };
        };
      in
      {
        packages.${system} = {
          default = pkgs.jaillm;
          jaillm = pkgs.jaillm;
          image = import lib/image.nix pkgs { };
        };
      }
    );
}
