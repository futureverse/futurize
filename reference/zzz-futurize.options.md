# Options used by futurize

Below are the R options and environment variables that are used by the
futurize package and packages enhancing it.\
\
*WARNING: Note that the names and the default values of these options
may change in future versions of the package. Please use with care until
further notice.*

## Packages must not change futurize options

Just like for other R options, as a package developer you must *not*
change any of the below `futurize.*` options. Only the end-user should
set these. If you find yourself having to tweak one of the options, make
sure to undo your changes immediately afterward.

## Options for debugging

- futurize.debug::

  (logical) If `TRUE`, extensive debug messages are generated. (Default:
  `FALSE`)

## Options for controlling futurization

- futurize.enable::

  (logical) If `TRUE` (default),
  [`futurize()`](https://futurize.futureverse.org/reference/futurize.md)
  transpilation will be applied, otherwise not.

## Environment variables that set R options

All of the above R futurize.\* options can be set by corresponding
environment variable `R_FUTURIZE_*` *when the futurize package is
loaded*. This means that those environment variables must be set before
the futurize package is loaded in order to have an effect. For example,
if `R_FUTURIZE_DEBUG=true`, then option futurize.debug is set to `TRUE`
(logical).

## See also

To set R options or environment variables when R starts (even before the
futurize package is loaded), see the
[Startup](https://rdrr.io/r/base/Startup.html) help page. The
[startup](https://cran.r-project.org/package=startup) package provides a
friendly mechanism for configuring R's startup process.
