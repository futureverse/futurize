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
      options <- make_options_for_doFuture(options)
      parts <- c(as.list(expr[[2]][[3]]), options)
      expr[[2]][[3]] <- as.call(parts)
    } else {
      options <- make_options_for_doFuture(options)    
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

  for (name in c("%dofuture%", "%dopar%")) {
    transpilers[[name]] <- list(
      label = sprintf("foreach::foreach() %s { ... } - not supported", name),
      transpiler = eval(bquote(function(...) {
        stop(sprintf("Cannot futurize foreach::foreach() %s { ... } - use %%do%% instead", .(name)))
      }))
    )
  }

  transpilers <- list(transpilers)
  names(transpilers) <- "foreach"

  append_transpilers("futurize::add-on", transpilers)
  
  ## Return required packages
  c("doFuture")
}


make_options_for_doFuture <- local({
  defaults <- NULL

  function(options) {
    ## Nothing to do?
    if (length(options) == 0) return(options)

    if (is.null(defaults)) {
      ## The 'doFuture' package already imports 'future.apply'
      defaults <<- names(formals(future.apply::future_lapply))
    }

    names <- names(options)
    
    ## Remap chunk_size -> chunk.size
    idxs <- which(names == "chunk_size")
    if (length(idxs) > 0) names[idxs] <- "chunk.size"

    ## Remap future options for doFuture
    names <- sprintf("future.%s", names)

    ## Drop unknown future options silently
    keep <- intersect(defaults, names)
    idxs <- match(keep, table = names)
    options <- options[idxs]
    
    list(.options.future = options)
  }
})

