# scuttle::logNormCounts(sce) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   scuttle::logNormCounts(sce, BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_scuttle <- function() {
  ## These scuttle functions accept BPPARAM via '...' (S4 generics) or
  ## directly in their formals
  names <- c(
    "calculateAverage",
    "logNormCounts", "normalizeCounts",
    "perCellQCMetrics", "perFeatureQCMetrics",
    "addPerCellQCMetrics", "addPerFeatureQCMetrics",
    "addPerCellQC", "addPerFeatureQC",
    "numDetectedAcrossCells", "numDetectedAcrossFeatures",
    "sumCountsAcrossCells", "sumCountsAcrossFeatures",
    "summarizeAssayByGroup",
    "aggregateAcrossCells", "aggregateAcrossFeatures",
    "librarySizeFactors", "computeLibraryFactors",
    "geometricSizeFactors", "computeGeometricFactors",
    "medianSizeFactors", "computeMedianFactors",
    "pooledSizeFactors", "computePooledFactors",
    "fitLinearModel"
  )

  ns <- getNamespace("scuttle")
  transpilers <- list()
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = TRUE)) {
      args <- list(BPPARAM = quote(BiocParallel::DoparParam()))
      transpilers[[name]] <- list(
        label = sprintf("scuttle::%s() ~> scuttle::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
        transpiler = make_futurize_for_doFuture(
          args = args,
          defaults = list(label = sprintf("fz:scuttle::%s-%%d", name))
        )
      )
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "scuttle"

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("scuttle", "BiocParallel", "doFuture")
}
