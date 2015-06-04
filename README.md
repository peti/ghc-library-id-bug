# Empiric data about GHC's non-deterministic library id bug

## How to contribute

Please help us to acquire some hard data about the frequency with which
[GHC 7.10.x assigns different library IDs to the same
build](https://ghc.haskell.org/trac/ghc/ticket/4012). You can contribute
as follows:

1. Clone this repository:

        git clone https://github.com/peti/ghc-library-id-bug.git
        cd ghc-library-id-bug

2. Choose a unique id for your host, i.e. your fully qualified domain name:

        hostname=my-host.example.com

3. Choose the number of builds you'd like to run:

        iterations=25

4. Choose the package to run test builds for. Good choices are "text" or "aeson".

        pkg=text

5. Run test builds

        nix-build --argstr hostname $hostname --argstr pkg $pkg --arg iterations $iterations

6. Collect the resulting CSV file and e-mail it to Peter Simons \<simons@cryp.to\>.

        ls -l result/*csv

## Results

Generate the following data by running:

    $ nix-shell --command "Rscript create-report.r"

### Multi-threading Configuration with GHC 7.10.1

#### Summary

~~~~~~~~~~
   builds correct    %
1:   3205    2727 85.1
~~~~~~~~~~

#### Summary by package

~~~~~~~~~~
         package builds correct     %
1:     mtl-2.2.1    700     700 100.0
2:  text-1.2.0.4   1655    1585  95.8
3: aeson-0.8.1.0    850     442  52.0
~~~~~~~~~~

#### Summary by package and system

~~~~~~~~~~
         package        system builds correct     %
1:     mtl-2.2.1  x86_64-linux    700     700 100.0
2:  text-1.2.0.4  x86_64-linux   1430    1385  96.9
3:  text-1.2.0.4 x86_64-darwin    225     200  88.9
4: aeson-0.8.1.0  x86_64-linux    750     425  56.7
5: aeson-0.8.1.0 x86_64-darwin    100      17  17.0
~~~~~~~~~~

### Single-threaded Configuration with GHC 7.10.1

#### Summary

~~~~~~~~~~
   builds correct   %
1:   2000    2000 100
~~~~~~~~~~

#### Summary by package

~~~~~~~~~~
         package builds correct   %
1: aeson-0.8.1.0   1500    1500 100
2:  text-1.2.0.4    500     500 100
~~~~~~~~~~

#### Summary by package and system

~~~~~~~~~~
         package       system builds correct   %
1: aeson-0.8.1.0 x86_64-linux   1500    1500 100
2:  text-1.2.0.4 x86_64-linux    500     500 100
~~~~~~~~~~
