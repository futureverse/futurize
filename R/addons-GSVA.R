# GSVA::gsva(gsvaParam(expr, geneSets)) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   GSVA::gsva(gsvaParam(expr, geneSets), BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_GSVA <- function() {
  ns <- getNamespace("GSVA")

  ## gsva() in GSVA (< 2.4.2) and GSVA (>= 2.5.0 & < 2.5.7) relies on
  ## BiocParallel::bpiterate(), which does _not_ support DoparParam.
  ns_version <- package_version(getNamespaceVersion(ns))
  supports_gsva <- (ns_version >= "2.5.7") ||
                   (ns_version >= "2.4.2" && ns_version < "2.5.0")

  ## gsvaRowNorm(), gsvaColRanks(), and gsvaColScores() replace the
  ## deprecated gsvaRanks() and gsvaScores() as of GSVA (>= 2.7.25)
  ## https://github.com/futureverse/futurize/issues/14
  supports_colranks <- (ns_version >= "2.7.25")

  ## GSVA (>= 2.7.0 & < 2.7.25) is not supported. As of GSVA (>= 2.7.25),
  ## support is back, with an additional check for early 2.7.25 builds.
  ## https://github.com/futureverse/futurize/issues/14
  ##
  ## Note, we keep the transpiler templates as-is, in case things
  ## change in GSVA or BiocParallel
  gsva_doparparam_broken <- (ns_version >= "2.7.0") &&
    (ns_version < "2.7.25" || exists(".gsva_bpiterate", envir = ns, inherits = FALSE))

  ## These GSVA functions accept BPPARAM via '...' (S4 generics)
  names <- c(
    if (supports_gsva) "gsva",
    "gsvaRanks", "gsvaScores",
    if (supports_colranks) c("gsvaRowNorm", "gsvaColRanks", "gsvaColScores"),
    "spatCor"
  )

  transpilers <- list()
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = TRUE)) {
      args <- list(BPPARAM = quote(BiocParallel::DoparParam()))
      transpiler <- make_futurize_for_doFuture(
        args = args,
        defaults = list(label = sprintf("fz:GSVA::%s-%%d", name))
      )

      if (gsva_doparparam_broken) {
        transpiler <- local({
          name <- name
          function(expr, options = NULL) {
            stop(sprintf(
              "futurize() does not support GSVA::%s() with GSVA %s. Support requires GSVA (< 2.7.0) or GSVA (>= 2.7.25). See https://github.com/futureverse/futurize/issues/14 for details.",
              name, as.character(ns_version)
            ))
          }
        })
      }

      transpilers[[name]] <- list(
        label = sprintf("GSVA::%s() ~> GSVA::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
        transpiler = transpiler
      )
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "GSVA"

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c("GSVA", "BiocParallel", "doFuture")
}
