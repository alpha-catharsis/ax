{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {

  buildInputs = [
    pkgs.bash
    pkgs.gnumake
    pkgs.shellcheck

    # keep this line if you use bash
    pkgs.bashInteractive
  ];

}
