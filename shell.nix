{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {

  buildInputs = [
    pkgs.bash
    pkgs.curl
    pkgs.gnumake
    pkgs.gnutar
    pkgs.shellcheck

    # keep this line if you use bash
    pkgs.bashInteractive
  ];

}
