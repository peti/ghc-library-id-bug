# Empiric data about ghc's non-deterministic library id bug

Please help us to acquire some hard data about the frequency with which
[GHC 7.10.x assigns different library IDs to the same
build](https://ghc.haskell.org/trac/ghc/ticket/4012). You can contribute
as follows:

1. Clone this repository

        git clone https://github.com/peti/ghc-library-id-bug.git
        cd ghc-library-id-bug

2. Choose a unique id for your host, i.e. your fully qualified domain name

        hostname=my-host.example.com

3. Choose the number of builds you'd like to run.

        iterations=25

4. Choose the package to run test builds for. Good choices are "text" or "aeson".

        pkg=text

5. Run test builds

        nix-build --argstr hostname $hostname --argstr pkg $pkg --arg iterations $iterations

6. Collect the resulting CSV file and e-mail it to Peter Simons \<simons@cryp.to\>.

        ls -l result/*csv
