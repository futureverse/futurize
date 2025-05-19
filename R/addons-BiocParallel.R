# BiocParallel::bplapply(xs, fcn) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   BiocParallel::bplapply(xs, fcn, BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_BiocParallel <- function() {
  template_stdout <- quote(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = OPTS)
      EXPR
    })
  )

  ## WORKAROUNDS for BiocParallel
  ## https://github.com/Bioconductor/BiocParallel/issues/276
  ## https://github.com/Bioconductor/BiocParallel/issues/277
  template_no_stdout <- quote(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = OPTS)
      ...futurize.result <- tryCatch({
        ...futurize.nullcon <- file(nullfile(), open = "w")
        sink(file = ...futurize.nullcon, type = "output")
        sink(file = ...futurize.nullcon, type = "message")
        withVisible(EXPR)
      }, finally = {
        sink(NULL, type = "message")
        sink(NULL, type = "output")
        close(...futurize.nullcon)
      })
      if (...futurize.result[["visible"]]) {
        ...futurize.result[["value"]]
      } else {
        invisible(...futurize.result[["value"]])
      }
    })
  )

  make_options <- function(options) {
    options
  }

  transpiler <- eval(bquote(function(expr, options = NULL) {
    stdout <- options[["stdout"]]
    if (isFALSE(stdout)) {
      template <- template_no_stdout
      idx_EXPR <- c(3, 3, 3, 2, 5, 2)
    } else {
      template <- template_stdout
      idx_EXPR <- c(3, 3)
    }
    
    ## Update 'OPTS'
    idx_OPTS <- c(3, 2, 2)
    template[[idx_OPTS]] <- make_options(options)
    
    ## Update 'EXPR'
    parts <- c(
      as.list(expr),
      BPPARAM = BiocParallel::DoparParam()
    )
    template[[idx_EXPR]] <- as.call(parts)
    
    template
  }))
  body(transpiler) <- body(transpiler)

  transpilers <- list()

  ns <- getNamespace("BiocParallel")
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- exports
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
      fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
      if ("BPPARAM" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("BiocParallel::%s() ~> BiocParallel::%s(..., BPPARAM = BiocParallel::DoparParam())", name, name),
          transpiler = transpiler
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "BiocParallel"

  append_transpilers("add-on", transpilers)

  ## Return required packages
  c("BiocParallel", "doFuture")
}
