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
#>  [1] "BiocParallel"         "DESeq2"               "GSVA"                
#>  [4] "GenomicAlignments"    "Rsamtools"            "SingleCellExperiment"
#>  [7] "TSP"                  "base"                 "boot"                
#> [10] "caret"                "crossmap"             "fgsea"               
#> [13] "foreach"              "fwb"                  "glmmTMB"             
#> [16] "glmnet"               "lme4"                 "mgcv"                
#> [19] "partykit"             "pbapply"              "plyr"                
#> [22] "purrr"                "scater"               "scuttle"             
#> [25] "seriation"            "shapr"                "stats"               
#> [28] "strucchange"          "sva"                  "tm"                  
#> [31] "vegan"               

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
