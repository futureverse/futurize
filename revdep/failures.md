# marcxmlr (0.5.0)

* GitHub: <https://github.com/larry77/marcxmlr>
* Email: <mailto:lorenzo.isella@gmail.com>
* GitHub mirror: <https://github.com/cran/marcxmlr>

Run `revdepcheck::revdep_details(, "marcxmlr")` for more info

## In both

*   checking whether package ‘marcxmlr’ can be installed ... ERROR
     ```
     Installation failed.
     See ‘/scratch/henrik/revdep/futurize/checks/marcxmlr/new/marcxmlr.Rcheck/00install.out’ for details.
     ```

## Installation

### Devel

```
* installing *source* package ‘marcxmlr’ ...
** this is package ‘marcxmlr’ version ‘0.5.0’
** package ‘marcxmlr’ successfully unpacked and MD5 sums checked
** using staged installation
Using PKG_CFLAGS=-I/usr/include/libxml2
Using PKG_LIBS=-lxml2 -lz -llzma -lm -ldl
Expat found: offset filtering enabled.
** libs
using C compiler: ‘gcc (GCC) 13.3.1 20240611 (Red Hat 13.3.1-2)’
gcc -std=gnu2x -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -I/usr/include/libxml2  -DMARCXMLR_HAS_EXPAT  -I/usr/local/include    -fpic  -g -O2  -c marcxml-native.c -o marcxml-native.o
...
In file included from /usr/include/libxml2/libxml/globals.h:20,
                 from /usr/include/libxml2/libxml/xmlIO.h:117,
                 from /usr/include/libxml2/libxml/parser.h:808,
                 from marcxml-native.c:11:
/usr/include/libxml2/libxml/SAX.h:104:17: note: previous declaration of ‘attribute’ with type ‘void(void *, const xmlChar *, const xmlChar *)’ {aka ‘void(void *, const unsigned char *, const unsigned char *)’}
  104 |                 attribute                       (void *ctx,
      |                 ^~~~~~~~~
make: *** [/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/etc/Makeconf:190: marcxml-native.o] Error 1
ERROR: compilation failed for package ‘marcxmlr’
* removing ‘/scratch/henrik/revdep/futurize/checks/marcxmlr/new/marcxmlr.Rcheck/marcxmlr’


```
### CRAN

```
* installing *source* package ‘marcxmlr’ ...
** this is package ‘marcxmlr’ version ‘0.5.0’
** package ‘marcxmlr’ successfully unpacked and MD5 sums checked
** using staged installation
Using PKG_CFLAGS=-I/usr/include/libxml2
Using PKG_LIBS=-lxml2 -lz -llzma -lm -ldl
Expat found: offset filtering enabled.
** libs
using C compiler: ‘gcc (GCC) 13.3.1 20240611 (Red Hat 13.3.1-2)’
gcc -std=gnu2x -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -I/usr/include/libxml2  -DMARCXMLR_HAS_EXPAT  -I/usr/local/include    -fpic  -g -O2  -c marcxml-native.c -o marcxml-native.o
...
In file included from /usr/include/libxml2/libxml/globals.h:20,
                 from /usr/include/libxml2/libxml/xmlIO.h:117,
                 from /usr/include/libxml2/libxml/parser.h:808,
                 from marcxml-native.c:11:
/usr/include/libxml2/libxml/SAX.h:104:17: note: previous declaration of ‘attribute’ with type ‘void(void *, const xmlChar *, const xmlChar *)’ {aka ‘void(void *, const unsigned char *, const unsigned char *)’}
  104 |                 attribute                       (void *ctx,
      |                 ^~~~~~~~~
make: *** [/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/etc/Makeconf:190: marcxml-native.o] Error 1
ERROR: compilation failed for package ‘marcxmlr’
* removing ‘/scratch/henrik/revdep/futurize/checks/marcxmlr/old/marcxmlr.Rcheck/marcxmlr’


```
# xmlrectr ()

* GitHub: <https://github.com/futureverse/futurize>
* Email: <mailto:henrikb@braju.com>

Run `revdepcheck::revdep_details(, "xmlrectr")` for more info

## Error before installation

### Devel

```
Found pkg-config cflags and libs!
Using PKG_CFLAGS=-I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi 
Using PKG_LIBS=-L/usr/lib64 -lharfbuzz -lfreetype -lfribidi 
g++ -std=gnu++20 -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -DNDEBUG -I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi  -I'/scratch/henrik/revdep/futurize/library/xmlrectr/cpp11/include' -I'/scratch/henrik/revdep/futurize/library/xmlrectr/systemfonts/include' -I/usr/local/include    -fpic  -g -O2   -c cpp11.cpp -o cpp11.o
g++ -std=gnu++20 -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -DNDEBUG -I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi  -I'/scratch/henrik/revdep/futurize/library/xmlrectr/cpp11/include' -I'/scratch/henrik/revdep/futurize/library/xmlrectr/systemfonts/include' -I/usr/local/include    -fpic  -g -O2   -c face_feature.cpp -o face_feature.o
g++ -std=gnu++20 -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -DNDEBUG -I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi  -I'/scratch/henrik/revdep/futurize/library/xmlrectr/cpp11/include' -I'/scratch/henrik/revdep/futurize/library/xmlrectr/systemfonts/include' -I/usr/local/include    -fpic  -g -O2   -c hb_shaper.cpp -o hb_shaper.o
g++ -std=gnu++20 -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -DNDEBUG -I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi  -I'/scratch/henrik/revdep/futurize/library/xmlrectr/cpp11/include' -I'/scratch/henrik/revdep/futurize/library/xmlrectr/systemfonts/include' -I/usr/local/include    -fpic  -g -O2   -c init.cpp -o init.o
g++ -std=gnu++20 -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -DNDEBUG -I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi  -I'/scratch/henrik/revdep/futurize/library/xmlrectr/cpp11/include' -I'/scratch/henrik/revdep/futurize/library/xmlrectr/systemfonts/include' -I/usr/local/include    -fpic  -g -O2   -c math_layout.cpp -o math_layout.o


* installing *binary* package ‘assertthat’ ...
* package ‘assertthat’ successfully unpacked and SHA256 sums checked
* DONE (assertthat)
* installing *binary* package ‘base64enc’ ...
* package ‘base64enc’ successfully unpacked and SHA256 sums checked
* DONE (base64enc)
* installing *binary* package ‘bit’ ...
* package ‘bit’ successfully unpacked and SHA256 sums checked
* DONE (bit)
* installing *binary* package ‘brio’ ...
...

The downloaded source packages are in
	‘/scratch/hb/RtmpMPy29L/downloaded_packages’
Error in (function (libdir, packages, quiet, repos)  : 
  all(packages %in% rownames(installed.packages(libdir[1]))) is not TRUE
In addition: Warning messages:
1: In utils::install.packages(pkgs = pkgs, lib = lib, repos = myrepos,  :
  installation of package ‘textshaping’ had non-zero exit status
2: In utils::install.packages(pkgs = pkgs, lib = lib, repos = myrepos,  :
  installation of package ‘textshaping’ had non-zero exit status


```
### CRAN

```
Found pkg-config cflags and libs!
Using PKG_CFLAGS=-I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi 
Using PKG_LIBS=-L/usr/lib64 -lharfbuzz -lfreetype -lfribidi 
g++ -std=gnu++20 -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -DNDEBUG -I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi  -I'/scratch/henrik/revdep/futurize/library/xmlrectr/cpp11/include' -I'/scratch/henrik/revdep/futurize/library/xmlrectr/systemfonts/include' -I/usr/local/include    -fpic  -g -O2   -c cpp11.cpp -o cpp11.o
g++ -std=gnu++20 -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -DNDEBUG -I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi  -I'/scratch/henrik/revdep/futurize/library/xmlrectr/cpp11/include' -I'/scratch/henrik/revdep/futurize/library/xmlrectr/systemfonts/include' -I/usr/local/include    -fpic  -g -O2   -c face_feature.cpp -o face_feature.o
g++ -std=gnu++20 -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -DNDEBUG -I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi  -I'/scratch/henrik/revdep/futurize/library/xmlrectr/cpp11/include' -I'/scratch/henrik/revdep/futurize/library/xmlrectr/systemfonts/include' -I/usr/local/include    -fpic  -g -O2   -c hb_shaper.cpp -o hb_shaper.o
g++ -std=gnu++20 -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -DNDEBUG -I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi  -I'/scratch/henrik/revdep/futurize/library/xmlrectr/cpp11/include' -I'/scratch/henrik/revdep/futurize/library/xmlrectr/systemfonts/include' -I/usr/local/include    -fpic  -g -O2   -c init.cpp -o init.o
g++ -std=gnu++20 -I"/wynton/home/cbi/shared/software/CBI/_rocky8/R-4.6.1-gcc13/lib64/R/include" -DNDEBUG -DNDEBUG -I/usr/include/harfbuzz -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/freetype2 -I/usr/include/libpng16 -I/usr/include/fribidi  -I'/scratch/henrik/revdep/futurize/library/xmlrectr/cpp11/include' -I'/scratch/henrik/revdep/futurize/library/xmlrectr/systemfonts/include' -I/usr/local/include    -fpic  -g -O2   -c math_layout.cpp -o math_layout.o


* installing *binary* package ‘assertthat’ ...
* package ‘assertthat’ successfully unpacked and SHA256 sums checked
* DONE (assertthat)
* installing *binary* package ‘base64enc’ ...
* package ‘base64enc’ successfully unpacked and SHA256 sums checked
* DONE (base64enc)
* installing *binary* package ‘bit’ ...
* package ‘bit’ successfully unpacked and SHA256 sums checked
* DONE (bit)
* installing *binary* package ‘brio’ ...
...

The downloaded source packages are in
	‘/scratch/hb/RtmpMPy29L/downloaded_packages’
Error in (function (libdir, packages, quiet, repos)  : 
  all(packages %in% rownames(installed.packages(libdir[1]))) is not TRUE
In addition: Warning messages:
1: In utils::install.packages(pkgs = pkgs, lib = lib, repos = myrepos,  :
  installation of package ‘textshaping’ had non-zero exit status
2: In utils::install.packages(pkgs = pkgs, lib = lib, repos = myrepos,  :
  installation of package ‘textshaping’ had non-zero exit status


```
