# List packages and functions supporting futurization

List packages and functions supporting futurization

## Usage

``` r
futurize_supported_packages()

futurize_supported_functions(package)
```

## Arguments

- package:

  A package name.

## Value

A character vector of package or function names.
`futurize_supported_functions()` produces an error if packages required
by the futurize transpiler are not installed.

## Examples

``` r
pkgs <- futurize_supported_packages()
pkgs
#>  [1] "BiocParallel" "TSP"          "base"         "boot"         "caret"       
#>  [6] "crossmap"     "foreach"      "fwb"          "glmmTMB"      "glmnet"      
#> [11] "lme4"         "mgcv"         "mice"         "partykit"     "pbapply"     
#> [16] "plyr"         "purrr"        "seriation"    "stats"        "strucchange" 
#> [21] "tm"           "vegan"       

if (requireNamespace("future.apply")) {
  fcns <- futurize_supported_functions("base")
  print(fcns)
}
#>  [1] ".mapply"   "Filter"    "Map"       "apply"     "by"        "eapply"   
#>  [7] "lapply"    "mapply"    "replicate" "sapply"    "tapply"    "vapply"   

if (requireNamespace("doFuture")) {
  fcns <- futurize_supported_functions("foreach")
  print(fcns)
}
#> [1] "%do%"    "%dopar%"
```
