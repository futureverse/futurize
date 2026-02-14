# BiocParallel::bplapply(xs, fcn) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
#   options(future.disposable = <future arguments>)
#   BiocParallel::bplapply(xs, fcn, BPPARAM = BiocParallel::DoparParam())
# })
#
append_transpilers_for_BiocParallel <- function() {
  package <- "BiocParallel"
  
  template_stdout <- bquote_compile(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = .(OPTS))
      .(EXPR)
    })
  )

  ## WORKAROUNDS for BiocParallel
  ## https://github.com/Bioconductor/BiocParallel/issues/276
  ## https://github.com/Bioconductor/BiocParallel/issues/277
  template_no_stdout <- bquote_compile(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), {
      ## This will be automatically removed by doFuture
      options(future.disposable = .(OPTS))
      ...futurize.result <- tryCatch({
        ...futurize.nullcon <- file(nullfile(), open = "w")
        sink(file = ...futurize.nullcon, type = "output")
        sink(file = ...futurize.nullcon, type = "message")
        withVisible(.(EXPR))
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

  transpiler <- function(expr, options = NULL) {
    stdout <- options[["stdout"]]
    if (isFALSE(stdout)) {
      template <- template_no_stdout
    } else {
      template <- template_stdout
    }

    expr <- append_call_arguments(expr,
      BPPARAM = BiocParallel::DoparParam()
    )

    opts <- make_options_for_doFuture(options, wrap = TRUE)
    
    ## Update 'OPTS'
    bquote_apply(template,
      OPTS = opts,
      EXPR = expr
    )
  }
  body(transpiler) <- body(transpiler)

  transpilers <- list()

  ns <- getNamespace(package)
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- exports
  ## Exclude some BiocParallel functions
  names <- setdiff(names, c("bpvectorize", "register"))
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
      fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
      if ("BPPARAM" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("%s::%s() ~> %s::%s(..., BPPARAM = BiocParallel::DoparParam())", package, name, package, name),
          transpiler = transpiler
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  c(package, "doFuture")
}
