append_transpilers_for_doFuture <- function() {
  package <- "doFuture"
  
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
    ## Replace `%do%` with doFuture::`%dofuture%`
    expr[[1]] <- quote(doFuture::`%dofuture%`)
    options <- make_options(options)
    parts <- c(as.list(expr[[2]]), options)
    expr[[2]] <- as.call(parts)
    expr
  }))
  body(transpiler) <- body(transpiler)

  transpilers <- list()
  transpilers[["%do%"]] <- list(
    label = "foreach::foreach() %do% { ... } -> foreach::foreach() %dofuture% { ... }",
    transpiler = transpiler
  )

  transpilers <- list(transpilers)
  names(transpilers) <- "foreach"

  append_transpilers("add-on", transpilers)
  
  ## Return required packages
  c(package)
}
