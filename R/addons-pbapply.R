# pbapply::pblapply(xs, fcn, ...) =>
#
# local({
#   options(future.disposable = structure(OPTS, dispose = FALSE))
#   on.exit(options(future.disposable = NULL))
#   pbapply::pblapply(xs, fcn, ..., cl = "future")
# })
#
append_transpilers_for_pbapply <- function() {
  package <- "pbapply"
  
  template <- quote(
   local({
      ## This will be automatically consumed and removed by 'future.apply'
      options(future.disposable = structure(OPTS, dispose = FALSE))
      on.exit(options(future.disposable = NULL))
      EXPR
    })
  )

  transpiler <- eval(bquote(function(expr, options = NULL) {
    ## Specified future.* arguments
    specified <- attr(options, "specified")

    names(options) <- sub("chunk_size", "chunk.size", names(options), fixed = TRUE)
    
    ## pbapply does not handle stdout, messages, and warnings, so disable
    ## those by default
    if (!"stdout" %in% specified) {
      options$stdout <- FALSE
    }
    if (!"conditions" %in% specified) {
      options$conditions <- structure(options$conditions,
                               exclude = c("message", "warning"))
    }

    template[[c(2,2,2,2)]] <- options
    
    parts <- c(
      as.list(expr),
      cl = "future"
    )
    template[[c(2,4)]] <- as.call(parts)
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
      if ("cl" %in% names(formals(fcn))) {
        transpilers[[name]] <- list(
          label = sprintf("%s::%s() ~> %s::%s(..., cl = \"future\")", package, name, package, name),
          transpiler = transpiler
        )
      }
    }
  }

  transpilers <- list(transpilers)
  names(transpilers) <- package

  append_transpilers("futurize::add-on", transpilers)

  ## Return required packages
  package
}
