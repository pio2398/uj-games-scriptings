with import <nixpkgs> {};

let

in
{ nixpkgs ? import <nixpkgs> {} }:
 mkShell {
  buildInputs = [
    (python3.withPackages (ps: with ps; with python3Packages; [
      black
    ]))
    poetry
    ruff
  ];

    LD_LIBRARY_PATH = "${nixpkgs.stdenv.cc.cc.lib}/lib";
}

