# A nix wrapper around various LLM CLI tools using jail.nix

{ jail-nix }:

# Nixpkgs
pkgs:

{
  extraCombinators ? _: [],
  extraUtils ? [],
  ...
}@args:

let
  jail = jail-nix.lib.init pkgs;
  cs = jail.combinators;
  contents = import ./contents.nix pkgs (builtins.removeAttrs args [ "extraCombinators" ]);
in
jail "jaillm" contents.entry (
  [
    # Packages
    (cs.add-pkg-deps [ contents.env ])
    # Configuration
    cs.network
    cs.open-urls-in-browser
    # Persist $HOME directory across jail restarts (~/.local/share/jail.nix/home/...)
    (cs.persist-home "jaillm")
    # Mount "$PWD" read-write into the jail at "$PWD"
    cs.mount-cwd
    # Bind DNS configuration (especially important for WSL)
    # If /etc/resolv.conf is a symlink, bind the target as well
    (cs.add-runtime ''
      if [ -L /etc/resolv.conf ]; then
        resolv_target=$(readlink -f /etc/resolv.conf)
        RUNTIME_ARGS+=(--ro-bind "$resolv_target" "$resolv_target")
      fi
    '')
    # 0.5% POSIX
    (cs.ro-bind "${pkgs.coreutils}/bin/env" "/usr/bin/env")
    (cs.set-env "SHELL" "${contents.shell}/bin/bash")
    # Allocate a PTY for interactive commands
    (cs.wrap-entry (entry: ''
      safe_cmd=$(printf '%q ' ${entry})
      script -qc "$safe_cmd" /dev/null
    ''))
  ]
  ++ (extraCombinators jail.combinators)
)
