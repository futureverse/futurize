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

## Examples

``` r
pkgs <- futurize_supported_packages()
pkgs
#>  [1] "BiocParallel" "base"         "boot"         "caret"        "crossmap"    
#>  [6] "foreach"      "fwb"          "glmnet"       "lme4"         "mgcv"        
#> [11] "pbapply"      "plyr"         "purrr"        "stats"        "strucchange" 
#> [16] "tm"          

fcns <- futurize_supported_functions("base")
fcns
#>  [1] ".mapply"   "Filter"    "Map"       "apply"     "by"        "eapply"   
#>  [7] "lapply"    "mapply"    "replicate" "sapply"    "tapply"    "vapply"   
```
