# LLM CLI tools & misc system utils

# Nixpkgs
pkgs:

{
  # Shell to use inside the jail
  shell ? pkgs.bashInteractive,
  # LLMs
  llms ? [
    pkgs.codex
    pkgs.claude-code
    pkgs.github-copilot-cli
    pkgs.gemini-cli
  ],
  # Entrypoint for the jail
  entry ? if builtins.length llms == 1 then builtins.head llms else shell,
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
  inherit entry shell;
  env = pkgs.buildEnv {
    name = "jaillm-env";
    paths = llms ++ utils;
  };
}
