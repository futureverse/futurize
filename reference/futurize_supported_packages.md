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
#>  [4] "GenomicAlignments"    "Rsamtools"            "SimDesign"           
#>  [7] "SingleCellExperiment" "TSP"                  "base"                
#> [10] "boot"                 "caret"                "crossmap"            
#> [13] "fgsea"                "foreach"              "fwb"                 
#> [16] "glmmTMB"              "glmnet"               "kernelshap"          
#> [19] "lme4"                 "metafor"              "mgcv"                
#> [22] "partykit"             "pbapply"              "plyr"                
#> [25] "purrr"                "riskRegression"       "scater"              
#> [28] "scuttle"              "seriation"            "shapr"               
#> [31] "stats"                "strucchange"          "sva"                 
#> [34] "tm"                   "vegan"               

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
