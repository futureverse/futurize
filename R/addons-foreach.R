# foreach(...) %do% { ... } =>
#   foreach(..., .options.future = <future arguments>) %dofuture% { ... }
#'
# times(...) %do% { ... } =>
#   local({
#     oopts <- options(future.disposable = <future arguments>)
#     on.exit(options(oopts))
#     times(...) %dofuture% { ... }
#   })
#
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
    call <- expr[[2]]
    fcn <- call[[1]]
    ## times()?
    if (identical(fcn, as.symbol("times")) ||
        identical(fcn, quote(foreach::times))) {
      ## Default to seed = TRUE
      if (!"seed" %in% attr(options, "specified")) {
        options[["seed"]] <- TRUE
      }
      expr2 <- quote(local({
        oopts <- options(future.disposable = OPTS)
        on.exit(options(oopts))
        EXPR
      }))
      expr2[[2]][[2]][[3]][[2]] <- options
      expr2[[2]][[4]] <- expr
      expr <- expr2
    } else if (identical(fcn, as.symbol("%:%")) ||
               identical(fcn, quote(foreach::`%:%`))) {
      options <- make_options(options)
      parts <- c(as.list(expr[[2]][[3]]), options)
      expr[[2]][[3]] <- as.call(parts)
    } else {
      options <- make_options(options)    
      parts <- c(as.list(expr[[2]]), options)
      expr[[2]] <- as.call(parts)
    }
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

  append_transpilers("futurize", "add-on", transpilers)
  
  ## Return required packages
  c(package)
}
