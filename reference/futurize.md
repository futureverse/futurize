# Turn common R function calls into concurrent calls for parallel evaluation

## Usage

``` r
futurize(
  expr,
  substitute = TRUE,
  options = futurize_options(...),
  ...,
  when = TRUE,
  eval = TRUE,
  envir = parent.frame()
)
```

## Arguments

- expr:

  An R expression, typically a function call to futurize. If FALSE, then
  futurization is disabled, and if TRUE, it is re-enabled.

- substitute:

  If TRUE, argument `expr` is
  [`substitute()`](https://rdrr.io/r/base/substitute.html):d, otherwise
  not.

- options, ...:

  Named options, passed to
  [`futurize_options()`](https://futurize.futureverse.org/reference/futurize_options.md),
  controlling how futures are resolved.

- when:

  If TRUE (default), the expression is futurized, otherwise not.

- eval:

  If TRUE (default), the futurized expression is evaluated, otherwise it
  is returned.

- envir:

  The [environment](https://rdrr.io/r/base/environment.html) from where
  global objects should be identified.

## Value

Returns the value of the evaluated expression `expr`.

If `expr` is TRUE or FALSE, then a logical is returned indicating
whether futurization was previously enabled or disabled.

## Expression unwrapping

The transpilation mechanism includes logic to "unwrap" expressions
enclosed in constructs such as
[`{ }`](https://rdrr.io/r/base/Paren.html), `( )`,
[`local()`](https://rdrr.io/r/base/eval.html),
[`I()`](https://rdrr.io/r/base/AsIs.html),
[`identity()`](https://rdrr.io/r/base/identity.html),
[`invisible()`](https://rdrr.io/r/base/invisible.html),
[`suppressMessages()`](https://rdrr.io/r/base/message.html), and
[`suppressWarnings()`](https://rdrr.io/r/base/warning.html). The
transpiler descends through wrapping constructs until it finds a
transpilable expression, avoiding the need to place `futurize()` inside
such constructs. This allows for patterns like:

    y <- {
      lapply(xs, fcn)
    } |> suppressMessages() |> futurize()

avoiding having to write:

    y <- {
      lapply(xs, fcn) |> futurize()
    } |> suppressMessages()

## Conditional futurization

It is possible to control whether futurization should take place at
run-time. For example,

    y <- lapply(xs, fun) |> futurize(when = { length(xs) >= 10 })

will be futurized, unless `length(xs)` is less than ten, in which case
it is evaluated as:

    y <- lapply(xs, fun)

## Disable and re-enable all futurization

It is possible to globally disable the effect of all `futurize()` calls
by calling `futurize(FALSE)`. The effect is as if `futurize()` was never
applied. For example,

    futurize(FALSE)
    y <- lapply(xs, fun) |> futurize()

evaluates as:

    y <- lapply(xs, fun)

To re-enable futurization, call `futurize(TRUE)`. Please note that it is
only the end-user that may control whether futurization should be
disabled and enabled. A package must *never* disable or enable
futurization.

## Examples

``` r
xs <- list(1, 1:2, 1:2, 1:5)

# ------------------------------------------
# Base R apply functions
# ------------------------------------------
# Sequential lapply()
y <- lapply(X = xs, FUN = function(x) {
  sum(x)
})
   
# Parallel version
y <- lapply(X = xs, FUN = function(x) {
  sum(x)
}) |> futurize()
str(y)
#> List of 4
#>  $ : num 1
#>  $ : int 3
#>  $ : int 3
#>  $ : int 15


# ------------------------------------------
# purrr map-reduce functions with pipes
# ------------------------------------------
if (require("purrr") && requireNamespace("furrr", quietly = TRUE)) {

# Sequential map()
y <- xs |> map(sum)
   
# Parallel version
y <- xs |> map(sum) |> futurize()
str(y)

} ## if (require ...)
#> Loading required package: purrr
#> List of 4
#>  $ : num 1
#>  $ : int 3
#>  $ : int 3
#>  $ : int 15


# ------------------------------------------
# foreach map-reduce functions
# ------------------------------------------
if (require("foreach") && requireNamespace("doFuture", quietly = TRUE)) {

# Sequential foreach()
y <- foreach(x = xs) %do% {
  sum(x)
}
   
# Parallel version
y <- foreach(x = xs) %do% {
  sum(x)
} |> futurize()
str(y)


# Sequential times()
y <- times(3) %do% rnorm(1)
str(y)
   
# Parallel version
y <- times(3) %do% rnorm(1) |> futurize()
str(y)

} ## if (require ...)
#> Loading required package: foreach
#> 
#> Attaching package: ‘foreach’
#> The following objects are masked from ‘package:purrr’:
#> 
#>     accumulate, when
#> List of 4
#>  $ : num 1
#>  $ : int 3
#>  $ : int 3
#>  $ : int 15
#>  num [1:3] 0.25532 -2.43726 -0.00557
#>  num [1:3] 0.4575 -0.6196 -0.0144


# ------------------------------------------
# plyr map-reduce functions
# ------------------------------------------
if (require("plyr") && requireNamespace("doFuture", quietly = TRUE)) {

# Sequential llply()
y <- llply(xs, sum)
   
# Parallel version
y <- llply(xs, sum) |> futurize()
str(y)

} ## if (require ...)
#> Loading required package: plyr
#> 
#> Attaching package: ‘plyr’
#> The following object is masked from ‘package:purrr’:
#> 
#>     compact
#> Warning: No parallel backend registered
#> List of 4
#>  $ : num 1
#>  $ : int 3
#>  $ : int 3
#>  $ : int 15
```
