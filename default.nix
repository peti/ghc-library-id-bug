{ nixpkgs ? import <nixpkgs> {}, iterations ? 5, compiler ? "ghc7101", hostname, pkg }:

with nixpkgs.pkgs;

let

  build = iteration: haskellPackages: haskell.lib.overrideCabal haskellPackages.${pkg} (drv: {
            doCheck = false;
            doHaddock = false;
            configureFlags = (drv.configureFlags or []) ++ ["-fignore-me-${hostname}-${toString iteration}"];
          });

  ghc = iteration: haskell.packages.${compiler}.ghcWithPackages (p: lib.singleton (build iteration p));

  builder = i: '' echo -n '${ghc i},${toString i},' >>$fout
                  ${ghc i}/bin/ghc-pkg --simple-output field ${pkg} id >>$fout
               '';

in

stdenv.mkDerivation {

  name = "haskell-library-id-challenge-${hostname}-0";

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out
    pkg=$(basename ${haskell.packages.${compiler}.${pkg}})
    fout="$out/${system}-${compiler}-$pkg-${hostname}-id.csv"
    echo >$fout 'storepath,iteration,libraryid'
  '' + lib.concatStringsSep "\n" (map builder (lib.range 1 iterations));

}
