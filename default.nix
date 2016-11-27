{ iterations ? 25, compiler ? "ghc7101", hostname, pkg }:

let

  nixpkgs = (import <nixpkgs> {}).pkgs.fetchgit {
              url = "https://github.com/nixos/nixpkgs-channels";
              rev = "f93a8ee1105f4cc3770ce339a8c1a4acea3b2fb6";
              sha256 = "01fnyw711p6kf9qpdabys9im10hlih1l1pxwp06wkq7b9wsljawd";
            };

in

with import nixpkgs {};

let

  build = iteration: haskellPackages: haskell.lib.overrideCabal haskellPackages.${pkg} (drv: {
            doCheck = false;
            doHaddock = false;
            configureFlags = (drv.configureFlags or []) ++ ["-fignore-me-${hostname}-${toString iteration}"];
          });

  ghc = iteration: haskell.packages.${compiler}.ghcWithPackages (p: lib.singleton (build iteration p));

  builder = i: ''
                  echo -n '${ghc i},${toString i},' >>$fout
                  ${ghc i}/bin/ghc-pkg --simple-output field ${pkg} id >>$fout
               '';

in

# TODO: Greater values won't work. Nix runs into a bash size limit
#       trying to create the build script.
assert iterations <= 700;

stdenv.mkDerivation {

  name = "haskell-library-id-challenge-${hostname}-0";

  buildCommand = writeScript "collect-ids" (''
              #! ${stdenv.shell}
              export PATH=${coreutils}/bin
              mkdir -p $out
              pkg=$(basename ${haskell.packages.${compiler}.${pkg}})
              fout="$out/${system}-${compiler}-$pkg-${hostname}-id.csv"
              echo >$fout 'storepath,iteration,libraryid'
            '' + lib.concatStrings (map builder (lib.range 1 iterations)));

}
