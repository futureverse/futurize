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
#>  [1] "BiocParallel"         "DESeq2"               "DiceKriging"         
#>  [4] "GSVA"                 "GenomicAlignments"    "Rsamtools"           
#>  [7] "Sim.DiffProc"         "SimDesign"            "SingleCellExperiment"
#> [10] "SuperLearner"         "TSP"                  "base"                
#> [13] "boot"                 "caret"                "crossmap"            
#> [16] "ez"                   "fgsea"                "foreach"             
#> [19] "fwb"                  "gamlss"               "glmmTMB"             
#> [22] "glmnet"               "kernelshap"           "lme4"                
#> [25] "metafor"              "mgcv"                 "modelsummary"        
#> [28] "parameters"           "partykit"             "pbapply"             
#> [31] "pls"                  "plyr"                 "purrr"               
#> [34] "pvclust"              "riskRegression"       "rugarch"             
#> [37] "sandwich"             "scater"               "scuttle"             
#> [40] "seriation"            "shapr"                "stars"               
#> [43] "stats"                "strucchange"          "sva"                 
#> [46] "tm"                   "vegan"               

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
