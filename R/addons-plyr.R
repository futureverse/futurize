# plyr::llply(xs, fcn) =>
#
# with(doFuture::registerDoFuture(flavor = "%dofuture%"), 
#   plyr::llply(xs, fcn,
#     .parallel = TRUE,
#     .paropts = list(.options.future = <future arguments>)
#   )
# )
#
append_transpilers_for_plyr <- function() {
  package <- "plyr"
  
  template <- quote(
    with(doFuture::registerDoFuture(flavor = "%dofuture%"), (EXPR))
  )

  make_options <- function(options) {
    names_options <- sprintf("future.%s", names(options))
    names <- names(formals(future.apply::future_lapply))
    keep <- intersect(names, names_options)
    keep <- match(keep, table = names_options)
    options <- options[keep]
    options <- list(.options.future = options)
    options
  }

  transpiler <- eval(bquote(function(expr, options = NULL) {
    parts <- c(
      as.list(expr),
      .parallel = TRUE
    )
    options <- make_options(options)
    parts[[".paropts"]] <- options
    template[[3]][[2]] <- as.call(parts)
    template
  }))
  body(transpiler) <- body(transpiler)

  transpilers <- list()

  ns <- getNamespace(package)
  exports <- names(ns[[".__NAMESPACE__."]][["exports"]])
  names <- exports
  for (name in names) {
    if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
      fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
      if (".parallel" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("%s::%s() ~> %s::%s(..., parallel = TRUE)", package, name, package, name),
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
