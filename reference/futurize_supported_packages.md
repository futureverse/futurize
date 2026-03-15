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
#>  [1] "BiocParallel" "DESeq2"       "GSVA"         "TSP"          "base"        
#>  [6] "boot"         "caret"        "crossmap"     "fgsea"        "foreach"     
#> [11] "fwb"          "glmmTMB"      "glmnet"       "lme4"         "mgcv"        
#> [16] "mice"         "partykit"     "pbapply"      "plyr"         "purrr"       
#> [21] "scater"       "seriation"    "shapr"        "stats"        "strucchange" 
#> [26] "tm"           "vegan"       

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
