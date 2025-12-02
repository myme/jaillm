let
  jaillm = builtins.getFlake "git+file:./";
in
  jaillm.lib.build (import <nixpkgs>) (pkgs: {
    llms = [
      pkgs.claude-code
    ];
    extraUtils = [
      pkgs.python313
    ];
  })
