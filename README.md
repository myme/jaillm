# JaiLLM

`jaillm` is a `nix` wrapper around various LLM TUIs, using [jail.nix](https://git.sr.ht/~alexdavid/jail.nix) for sandboxing.

## Basic Usage

### `jaillm.nix`

```nix
pkgs:
{
  entry = pkgs.bashInteractive;
  llms = [ pkgs.claude-code pkgs.gemini-cli ];
  shareHomePaths = [ ".claude" ];
  extraUtils = [
    pkgs.curl
  ];
}
```

### Claude

Write `jaillm.nix`:

```nix
pkgs:
{
  llms = [ pkgs.claude-code ];
  shareHomePaths = [ ".claude" ];
}
```

Run [Claude](https://claude.ai):

```bash
nix run github:myme/jaillm
```

### Gemini

Write `jaillm.nix`:

```nix
pkgs:
{
  llms = [ pkgs.gemini-cli ];
}
```

Run [Gemini](https://gemini.google.com):

```bash
nix run github:myme/jaillm
```

### Shell with multiple LLMs

Launch a `bash` shell with multiple LLMs available:

```nix
pkgs:
{
  entry = pkgs.bashInteractive;
  llms = [ pkgs.claude-code pkgs.gemini-cli ];
  shareHomePaths = [ ".claude" ];
}
```

```bash
nix run github:myme/jaillm
```

## Configuration

### Options

| Option | Default | Description |
|---|---|---|
| `entry` | First LLM if only one, otherwise `shell` | Entrypoint for the jail |
| `shell` | `pkgs.bashInteractive` | Shell to use inside the jail |
| `llms` | `[ pkgs.codex pkgs.claude-code pkgs.github-copilot-cli pkgs.gemini-cli ]` | LLM packages to include |
| `shareHomePaths` | `[]` | Paths relative to `$HOME` to bind-mount (read-write) from the host into the jail |
| `extraUtils` | `[]` | Additional packages to include |
| `extraCombinators` | `_: []` | Additional [jail.nix](https://git.sr.ht/~alexdavid/jail.nix) combinators |

### Sharing host paths

By default, the jail uses a dedicated `$HOME` directory that persists across restarts.
This means tools like `claude` need to re-authenticate on first use.

Use `shareHomePaths` to bind-mount directories from your real `$HOME` into the jail:

```nix
pkgs:
{
  llms = [ pkgs.claude-code ];
  shareHomePaths = [ ".claude" ];
}
```

The paths are bind-mounted read-write and only if they exist on the host.

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
