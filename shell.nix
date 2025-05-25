{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {

  hardeningDisable = [ "all" ];

  buildInputs = [
    pkgs.autoconf
    pkgs.automake
    pkgs.bash
    pkgs.bison
    pkgs.curl
    pkgs.gcc
    pkgs.gnumake
    pkgs.gnutar
    pkgs.shellcheck

    # keep this line if you use bash
    pkgs.bashInteractive
  ];

}
