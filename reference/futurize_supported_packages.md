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
#>  [4] "GenomicAlignments"    "Rsamtools"            "Rsolnp"              
#>  [7] "SimDesign"            "SingleCellExperiment" "TSP"                 
#> [10] "base"                 "boot"                 "caret"               
#> [13] "crossmap"             "fgsea"                "foreach"             
#> [16] "fwb"                  "gamlss"               "glmmTMB"             
#> [19] "glmnet"               "kernelshap"           "lme4"                
#> [22] "metafor"              "mgcv"                 "partykit"            
#> [25] "pbapply"              "plyr"                 "purrr"               
#> [28] "riskRegression"       "rmgarch"              "scater"              
#> [31] "scuttle"              "seriation"            "shapr"               
#> [34] "stats"                "strucchange"          "sva"                 
#> [37] "tm"                   "vegan"               

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
