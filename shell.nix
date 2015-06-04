{ nixpkgs ? import <nixpkgs> {} }:

let

  inherit (nixpkgs) pkgs;

  env = pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [
            testthat data_table foreach
          ];
        };

in

pkgs.stdenv.mkDerivation {

  name = "haskell-library-id-challenge-0";

  buildInputs = [ env ];

}
