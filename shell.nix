{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    terraform
    awscli2
    nodejs-18_x
  ];
}
