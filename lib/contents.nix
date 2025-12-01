# LLM CLI tools & misc system utils

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
    pkgs.curl
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnugrep
    pkgs.gnused
    pkgs.util-linux
  ]
  ++ extraUtils,
}:

{
  inherit shell;
  env = pkgs.buildEnv {
    name = "jaillm-env";
    paths = llms ++ utils;
  };
}
