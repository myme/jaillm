# JaiLLM 

`jaillm` is an `nix` wrapper around various LLM TUIs, using [jail.nix](https://git.sr.ht/~alexdavid/jail.nix) for sandboxing.

## Basic Usage

Run [Claude](https://claude.ai):

```nix
nix run github:myme/jaillm claude
```

Run [Gemini](https://gemini.google.com):

```nix
nix run github:myme/jaillm gemini
```

Launch a basic `bash` shell:

```nix
nix run github:myme/jaillm
```

## Nix Flakes

```nix
{
  description = "An example nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    jaillm.url = "github:myme/jaillm";
  };

  outputs =
    { nixpkgs, jaillm, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ jaillm.overlays.default ];
        config = {
          allowUnfreePredicate =
            pkg:
            builtins.elem pkg.pname [
              "claude-code"
              "codex"
              "copilot-cli"
              "gemini-cli"
            ];
        };
      };
    in
    {
      devShell.${system}.default = nixpkgs.lib.mkShell {
        buildInputs = [
          pkgs.jaillm
        ];
      };
    };
}
```

## Docker

### Build and load the image

```bash
nix build github:myme/jaillm && ./result | docker load
```

### Run the image

```bash
docker run --rm -it myme/jaillm claude
```
