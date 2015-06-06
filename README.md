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

### Summary

~~~~~~~~~~
            config builds correct    %
1: single-threaded   3660    3625 99.0
2:  multi-threaded   1675    1260 75.2
~~~~~~~~~~

### Summary by package

~~~~~~~~~~
            config       package builds correct     %
1:  multi-threaded     mtl-2.2.1    700     700 100.0
2: single-threaded  text-1.2.0.4   1580    1570  99.4
3: single-threaded aeson-0.8.1.0   2080    2055  98.8
4:  multi-threaded  text-1.2.0.4    625     565  90.4
5:  multi-threaded aeson-0.8.1.0    450      95  21.1
~~~~~~~~~~

### Summary by package and system

~~~~~~~~~~
            config       package        system builds correct     %
1:  multi-threaded     mtl-2.2.1  x86_64-linux    700     700 100.0
2: single-threaded  text-1.2.0.4  x86_64-linux   1580    1570  99.4
3: single-threaded aeson-0.8.1.0  x86_64-linux   2080    2055  98.8
4:  multi-threaded  text-1.2.0.4  x86_64-linux    400     365  91.2
5:  multi-threaded  text-1.2.0.4 x86_64-darwin    225     200  88.9
6:  multi-threaded aeson-0.8.1.0  x86_64-linux    350      78  22.3
7:  multi-threaded aeson-0.8.1.0 x86_64-darwin    100      17  17.0
~~~~~~~~~~

### Summary by package and build machine

~~~~~~~~~~
          package                       machine          config builds ids correct     %
 1:  text-1.2.0.4                 lassulus.mors  multi-threaded     25   1      25 100.0
 2:     mtl-2.2.1                 leroy.geek.nz  multi-threaded    100   1     100 100.0
 3:     mtl-2.2.1                mobile.cryp.to  multi-threaded    100   1     100 100.0
 4:     mtl-2.2.1                  work.cryp.to  multi-threaded    500   1     500 100.0
 5: aeson-0.8.1.0                  work.cryp.to single-threaded    500   1     500 100.0
 6: aeson-0.8.1.0 archachatina.mtlaa.gebner.org single-threaded    100   1     100 100.0
 7: aeson-0.8.1.0                   jagajaga.me single-threaded     30   1      30 100.0
 8: aeson-0.8.1.0                      jude.bio single-threaded     25   1      25 100.0
 9: aeson-0.8.1.0                lin.wiwaxia.se single-threaded    100   1     100 100.0
10: aeson-0.8.1.0              m-nix.wiwaxia.se single-threaded    100   1     100 100.0
11: aeson-0.8.1.0              mobile-1.cryp.to single-threaded    700   1     700 100.0
12: aeson-0.8.1.0              mobile-2.cryp.to single-threaded    300   1     300 100.0
13: aeson-0.8.1.0      paxton.munchkin.earth.li single-threaded    100   1     100 100.0
14: aeson-0.8.1.0                      phreedom single-threaded    100   1     100 100.0
15:  text-1.2.0.4                  work.cryp.to single-threaded    500   1     500 100.0
16:  text-1.2.0.4 archachatina.mtlaa.gebner.org single-threaded    100   1     100 100.0
17:  text-1.2.0.4                c-cube.bennofs single-threaded     25   1      25 100.0
18:  text-1.2.0.4                   jagajaga.me single-threaded     30   1      30 100.0
19:  text-1.2.0.4                      jude.bio single-threaded    500   1     500 100.0
20:  text-1.2.0.4                lin.wiwaxia.se single-threaded    100   1     100 100.0
21:  text-1.2.0.4              m-nix.wiwaxia.se single-threaded    100   1     100 100.0
22:  text-1.2.0.4      paxton.munchkin.earth.li single-threaded     25   1      25 100.0
23:  text-1.2.0.4                      phreedom single-threaded    100   1     100 100.0
24:  text-1.2.0.4                  work.cryp.to  multi-threaded     75   3      73  97.3
25:  text-1.2.0.4                     Toothless  multi-threaded    100   2      96  96.0
26:  text-1.2.0.4                 leroy.geek.nz  multi-threaded    100   2      96  96.0
27:  text-1.2.0.4                mobile.cryp.to  multi-threaded     25   2      24  96.0
28:  text-1.2.0.4      moritz-x23.tarn-vedra.de  multi-threaded     25   2      24  96.0
29:  text-1.2.0.4                eric.seidel.io  multi-threaded     25   2      23  92.0
30:  text-1.2.0.4           zap.wearewizards.io single-threaded    100   2      90  90.0
31:  text-1.2.0.4                  abbradar.net  multi-threaded    100   2      89  89.0
32:  text-1.2.0.4                   mango.local  multi-threaded    100   2      81  81.0
33:  text-1.2.0.4                mono.rycee.net  multi-threaded     25   2      20  80.0
34: aeson-0.8.1.0                  work.cryp.to  multi-threaded    100  35      58  58.0
35:  text-1.2.0.4    blackburne.lancelotsix.com  multi-threaded     25   2      14  56.0
36: aeson-0.8.1.0                mono.rycee.net  multi-threaded     25  17       9  36.0
37: aeson-0.8.1.0                   mango.local  multi-threaded    100  71      17  17.0
38: aeson-0.8.1.0                 leroy.geek.nz  multi-threaded    100  78       6   6.0
39: aeson-0.8.1.0                  abbradar.net  multi-threaded    100  78       5   5.0
40: aeson-0.8.1.0                mobile.cryp.to  multi-threaded     25  20       0   0.0
41: aeson-0.8.1.0                c-cube.bennofs single-threaded     25   1       0   0.0
          package                       machine          config builds ids correct     %
~~~~~~~~~~
