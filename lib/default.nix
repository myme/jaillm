# A nix wrapper around various LLM CLI tools using jail.nix

{ jail-nix }:

# Nixpkgs
pkgs:

{
  # Shell to use inside the jail
  shell ? pkgs.bashInteractive,
  # LLMs
  llms ? [
    pkgs.claude-code
    pkgs.codex
    pkgs.github-copilot-cli
    pkgs.gemini-cli
  ],
  # Additional Unix/Linux utilities
  extraUtils ? [ ],
  # Unix/Linux tools
  utils ? [
    shell
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.util-linux
  ]
  ++ extraUtils,
  # Jail combinators :: (jail.combinators -> [ jail.combinators ])
  extraCombinators ? _: [ ],
}:

let
  jail = jail-nix.lib.init pkgs;
in
jail "jaillm" shell (
  with jail.combinators;
  [
    # Packages
    (add-pkg-deps (llms ++ utils))
    # Configuration
    network
    open-urls-in-browser
    # Persist $HOME directory across jail restarts (~/.local/share/jail.nix/home/...)
    (persist-home "jaillm")
    # Mount "$PWD" read-write into the jail at "$PWD"
    mount-cwd
    # 0.5% POSIX
    (ro-bind "${pkgs.coreutils}/bin/env" "/usr/bin/env")
    (set-env "SHELL" "${shell}/bin/bash")
    # Allocate a PTY for interactive commands
    (wrap-entry (entry: ''
      safe_cmd=$(printf '%q ' ${entry})
      script -qc "$safe_cmd" /dev/null
    ''))
  ]
  ++ (extraCombinators jail.combinators)
)
