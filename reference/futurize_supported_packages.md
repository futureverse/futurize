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
#>  [4] "GenomicAlignments"    "Rsamtools"            "Sim.DiffProc"        
#>  [7] "SimDesign"            "SingleCellExperiment" "SuperLearner"        
#> [10] "TSP"                  "base"                 "boot"                
#> [13] "caret"                "crossmap"             "fgsea"               
#> [16] "foreach"              "fwb"                  "gamlss"              
#> [19] "glmmTMB"              "glmnet"               "kernelshap"          
#> [22] "lme4"                 "metafor"              "mgcv"                
#> [25] "modelsummary"         "parameters"           "partykit"            
#> [28] "pbapply"              "pls"                  "plyr"                
#> [31] "purrr"                "pvclust"              "riskRegression"      
#> [34] "rugarch"              "sandwich"             "scater"              
#> [37] "scuttle"              "seriation"            "shapr"               
#> [40] "stars"                "stats"                "strucchange"         
#> [43] "sva"                  "tm"                   "vegan"               

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
