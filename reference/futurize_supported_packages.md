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
#> [13] "boot"                 "bumphunter"           "caret"               
#> [16] "crossmap"             "ez"                   "fgsea"               
#> [19] "foreach"              "fwb"                  "gamlss"              
#> [22] "glmmTMB"              "glmnet"               "kernelshap"          
#> [25] "lme4"                 "metafor"              "mgcv"                
#> [28] "mlr3"                 "mlr3tuning"           "modelsummary"        
#> [31] "parameters"           "partykit"             "pbapply"             
#> [34] "pls"                  "plyr"                 "purrr"               
#> [37] "pvclust"              "riskRegression"       "rugarch"             
#> [40] "sandwich"             "scater"               "scuttle"             
#> [43] "seriation"            "shapr"                "stars"               
#> [46] "stats"                "strucchange"          "sva"                 
#> [49] "terra"                "tm"                   "vegan"               

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
