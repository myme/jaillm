# A Docker image around various LLM CLI tools

# Nixpkgs
pkgs:

args:

let
  contents = import ./contents.nix pkgs args;
in
pkgs.dockerTools.streamLayeredImage {
  name = "jaillm";
  tag = "latest";
  contents = contents.env;
  config = {
    Env = [
      "HOME=/root"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
  fakeRootCommands = ''
    mkdir -p /root
  '';
  enableFakechroot = true;
}
